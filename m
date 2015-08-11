From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net-next 10/10] openvswitch: Allow attaching helpers to ct action
Date: Tue, 11 Aug 2015 15:59:21 -0700
Message-ID: <1439333961-24474-11-git-send-email-joestringer@nicira.com>
References: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36727 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932930AbbHKXAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 19:00:23 -0400
Received: by pacrr5 with SMTP id rr5so135460pac.3
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 16:00:23 -0700 (PDT)
In-Reply-To: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for using conntrack helpers to assist protocol detection.
The new OVS_CT_ATTR_HELPER attribute of the ct action specifies a helper
to be used for this connection.

Example ODP flows allowing FTP connections from ports 1->2:
in_port=1,tcp,action=ct(helper=ftp,commit),2
in_port=2,tcp,ct_state=-trk,action=ct(),recirc(1)
recirc_id=1,in_port=2,tcp,ct_state=+trk-new+est,action=1
recirc_id=1,in_port=2,tcp,ct_state=+trk+rel,action=1

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/uapi/linux/openvswitch.h |   1 +
 net/openvswitch/conntrack.c      | 109 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 108 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index f360dc9..e816170 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -626,6 +626,7 @@ enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
 	OVS_CT_ATTR_FLAGS,      /* u8 bitmask of OVS_CT_F_*. */
 	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
+	OVS_CT_ATTR_HELPER,
 	__OVS_CT_ATTR_MAX
 };
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6a64a32..1f2a9bc 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -15,6 +15,7 @@
 #include <linux/openvswitch.h>
 #include <net/ip.h>
 #include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_labels.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
@@ -30,6 +31,7 @@ struct ovs_ct_len_tbl {
 };
 
 struct ovs_conntrack_info {
+	struct nf_conntrack_helper *helper;
 	struct nf_conn *ct;
 	u32 flags;
 	u16 zone;
@@ -145,6 +147,51 @@ bool ovs_ct_state_valid(const struct sw_flow_key *key)
 	return __ovs_ct_state_valid(key->ct.state);
 }
 
+/* 'skb' should already be pulled to nh_ofs. */
+static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
+{
+	const struct nf_conntrack_helper *helper;
+	const struct nf_conn_help *help;
+	enum ip_conntrack_info ctinfo;
+	unsigned int protoff;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct || ctinfo == IP_CT_RELATED_REPLY)
+		return NF_ACCEPT;
+
+	help = nfct_help(ct);
+	if (!help)
+		return NF_ACCEPT;
+
+	helper = rcu_dereference(help->helper);
+	if (!helper)
+		return NF_ACCEPT;
+
+	switch (proto) {
+	case NFPROTO_IPV4:
+		protoff = ip_hdrlen(skb);
+		break;
+	case NFPROTO_IPV6: {
+		u8 nexthdr = ipv6_hdr(skb)->nexthdr;
+		__be16 frag_off;
+
+		protoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr),
+					   &nexthdr, &frag_off);
+		if (protoff < 0 || (frag_off & htons(~0x7)) != 0) {
+			pr_debug("proto header not found\n");
+			return NF_ACCEPT;
+		}
+		break;
+	}
+	default:
+		WARN_ONCE(1, "helper invoked on non-IP family!");
+		return NF_DROP;
+	}
+
+	return helper->help(skb, protoff, ct, ctinfo);
+}
+
 static int handle_fragments(struct net *net, struct sw_flow_key *key,
 			    u16 zone, struct sk_buff *skb)
 {
@@ -217,6 +264,13 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
 		return false;
 	if (info->zone != nf_ct_zone(ct))
 		return false;
+	if (info->helper) {
+		struct nf_conn_help *help;
+
+		help = nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
+		if (help && help->helper != info->helper)
+			return false;
+	}
 
 	return true;
 }
@@ -274,6 +328,11 @@ static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
 		if (nf_conntrack_in(net, info->family, NF_INET_PRE_ROUTING,
 				    skb) != NF_ACCEPT)
 			return -ENOENT;
+
+		if (ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
+			WARN_ONCE(1, "helper rejected packet");
+			return -EINVAL;
+		}
 	}
 
 	return 0;
@@ -420,15 +479,41 @@ int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
 #endif
 }
 
+static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
+			     const struct sw_flow_key *key, bool log)
+{
+	struct nf_conntrack_helper *helper;
+	struct nf_conn_help *help;
+
+	helper = nf_conntrack_helper_try_module_get(name, info->family,
+						    key->ip.proto);
+	if (!helper) {
+		OVS_NLERR(log, "Unknown helper \"%s\"", name);
+		return -ENOENT;
+	}
+
+	help = nf_ct_helper_ext_add(info->ct, helper, GFP_KERNEL);
+	if (!help) {
+		module_put(helper->me);
+		return -ENOMEM;
+	}
+
+	help->helper = helper;
+	info->helper = helper;
+	return 0;
+}
+
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_FLAGS]	= { .minlen = sizeof(u32),
 				    .maxlen = sizeof(u32) },
 	[OVS_CT_ATTR_ZONE]	= { .minlen = sizeof(u16),
 				    .maxlen = sizeof(u16) },
+	[OVS_CT_ATTR_HELPER]	= { .minlen = 1,
+				    .maxlen = NF_CT_HELPER_NAME_LEN }
 };
 
 static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
-		    bool log)
+		    const char **helper, bool log)
 {
 	struct nlattr *a;
 	int rem;
@@ -460,6 +545,13 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		case OVS_CT_ATTR_FLAGS:
 			info->flags = nla_get_u32(a);
 			break;
+		case OVS_CT_ATTR_HELPER:
+			*helper = nla_data(a);
+			if (!memchr(*helper, '\0', nla_len(a))) {
+				OVS_NLERR(log, "Invalid conntrack helper");
+				return -EINVAL;
+			}
+			break;
 		default:
 			OVS_NLERR(log, "Unknown conntrack attr (%d)",
 				  type);
@@ -500,6 +592,7 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 		       struct sw_flow_actions **sfa,  bool log)
 {
 	struct ovs_conntrack_info ct_info;
+	const char *helper = NULL;
 	u16 family;
 	int err;
 
@@ -512,7 +605,7 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 	memset(&ct_info, 0, sizeof(ct_info));
 	ct_info.family = family;
 
-	err = parse_ct(attr, &ct_info, log);
+	err = parse_ct(attr, &ct_info, &helper, log);
 	if (err)
 		return err;
 
@@ -522,6 +615,11 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 		OVS_NLERR(log, "Failed to allocate conntrack template");
 		return -ENOMEM;
 	}
+	if (helper) {
+		err = ovs_ct_add_helper(&ct_info, helper, key, log);
+		if (err)
+			goto err_free_ct;
+	}
 
 	err = ovs_nla_add_action(sfa, OVS_ACTION_ATTR_CT, &ct_info,
 				 sizeof(ct_info), log);
@@ -551,6 +649,11 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	if (nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone))
 		return -EMSGSIZE;
 #endif
+	if (ct_info->helper) {
+		if (nla_put_string(skb, OVS_CT_ATTR_HELPER,
+				   ct_info->helper->name))
+			return -EMSGSIZE;
+	}
 
 	nla_nest_end(skb, start);
 
@@ -561,6 +664,8 @@ void ovs_ct_free_action(const struct nlattr *a)
 {
 	struct ovs_conntrack_info *ct_info = nla_data(a);
 
+	if (ct_info->helper)
+		module_put(ct_info->helper->me);
 	if (ct_info->ct)
 		nf_ct_put(ct_info->ct);
 }
-- 
2.1.4
