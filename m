From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv5 net-next 10/10] openvswitch: Allow attaching helpers to ct action
Date: Mon, 24 Aug 2015 17:32:20 -0700
Message-ID: <1440462740-23358-11-git-send-email-joestringer@nicira.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for using conntrack helpers to assist protocol detection.
The new OVS_CT_ATTR_HELPER attribute of the CT action specifies a helper
to be used for this connection. If no helper is specified, then helpers
will be automatically applied as per the sysctl configuration of
net.netfilter.nf_conntrack_helper.

The helper may be specified as part of the conntrack action, eg:
ct(helper=ftp). Initial packets for related connections should be
committed to allow later packets for the flow to be considered
established.

Example ovs-ofctl flows allowing FTP connections from ports 1->2:
in_port=1,tcp,action=ct(helper=ftp,commit),2
in_port=2,tcp,ct_state=-trk,action=ct(recirc)
in_port=2,tcp,ct_state=+trk-new+est,action=1
in_port=2,tcp,ct_state=+trk+rel,action=1

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2-v3: No change.
v4: Change error code for unknown helper ENOENT->EINVAL.
v5: Fix rcu access of helpers.
    Rebase.
---
 include/uapi/linux/openvswitch.h |   3 ++
 net/openvswitch/conntrack.c      | 109 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 110 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 9d52058..32e07d8 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -626,6 +626,7 @@ struct ovs_action_hash {
  * @OVS_CT_ATTR_LABEL: %OVS_CT_LABEL_LEN value followed by %OVS_CT_LABEL_LEN
  * mask. For each bit set in the mask, the corresponding bit in the value is
  * copied to the connection tracking label field in the connection.
+ * @OVS_CT_ATTR_HELPER: variable length string defining conntrack ALG.
  */
 enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
@@ -633,6 +634,8 @@ enum ovs_ct_attr {
 	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
 	OVS_CT_ATTR_MARK,       /* mark to associate with this connection. */
 	OVS_CT_ATTR_LABEL,      /* label to associate with this connection. */
+	OVS_CT_ATTR_HELPER,     /* netlink helper to assist detection of
+				   related connections. */
 	__OVS_CT_ATTR_MAX
 };
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 8cb0987..ac6d1d2 100644
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
@@ -43,6 +44,7 @@ struct md_label {
 
 /* Conntrack action context for execution. */
 struct ovs_conntrack_info {
+	struct nf_conntrack_helper *helper;
 	struct nf_conntrack_zone zone;
 	struct nf_conn *ct;
 	u32 flags;
@@ -213,6 +215,51 @@ static int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
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
@@ -285,6 +332,13 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
 		return false;
 	if (!nf_ct_zone_equal_any(info->ct, nf_ct_zone(ct)))
 		return false;
+	if (info->helper) {
+		struct nf_conn_help *help;
+
+		help = nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
+		if (help && rcu_access_pointer(help->helper) != info->helper)
+			return false;
+	}
 
 	return true;
 }
@@ -313,6 +367,11 @@ static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
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
@@ -421,6 +480,30 @@ err:
 	return err;
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
+		return -EINVAL;
+	}
+
+	help = nf_ct_helper_ext_add(info->ct, helper, GFP_KERNEL);
+	if (!help) {
+		module_put(helper->me);
+		return -ENOMEM;
+	}
+
+	rcu_assign_pointer(help->helper, helper);
+	info->helper = helper;
+	return 0;
+}
+
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_FLAGS]	= { .minlen = sizeof(u32),
 				    .maxlen = sizeof(u32) },
@@ -430,10 +513,12 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 				    .maxlen = sizeof(struct md_mark) },
 	[OVS_CT_ATTR_LABEL]	= { .minlen = sizeof(struct md_label),
 				    .maxlen = sizeof(struct md_label) },
+	[OVS_CT_ATTR_HELPER]	= { .minlen = 1,
+				    .maxlen = NF_CT_HELPER_NAME_LEN }
 };
 
 static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
-		    bool log)
+		    const char **helper, bool log)
 {
 	struct nlattr *a;
 	int rem;
@@ -481,6 +566,13 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 			break;
 		}
 #endif
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
@@ -521,6 +613,7 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 		       struct sw_flow_actions **sfa,  bool log)
 {
 	struct ovs_conntrack_info ct_info;
+	const char *helper = NULL;
 	u16 family;
 	int err;
 
@@ -536,7 +629,7 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
 	nf_ct_zone_init(&ct_info.zone, NF_CT_DEFAULT_ZONE_ID,
 			NF_CT_DEFAULT_ZONE_DIR, 0);
 
-	err = parse_ct(attr, &ct_info, log);
+	err = parse_ct(attr, &ct_info, &helper, log);
 	if (err)
 		return err;
 
@@ -546,6 +639,11 @@ int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
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
@@ -582,6 +680,11 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	    nla_put(skb, OVS_CT_ATTR_LABEL, sizeof(ct_info->label),
 		    &ct_info->label))
 		return -EMSGSIZE;
+	if (ct_info->helper) {
+		if (nla_put_string(skb, OVS_CT_ATTR_HELPER,
+				   ct_info->helper->name))
+			return -EMSGSIZE;
+	}
 
 	nla_nest_end(skb, start);
 
@@ -592,6 +695,8 @@ void ovs_ct_free_action(const struct nlattr *a)
 {
 	struct ovs_conntrack_info *ct_info = nla_data(a);
 
+	if (ct_info->helper)
+		module_put(ct_info->helper->me);
 	if (ct_info->ct)
 		nf_ct_put(ct_info->ct);
 }
-- 
2.1.4
