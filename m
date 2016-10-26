From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH v2 5/9] ipv6: sr: implement API to control SR HMAC structure
Date: Wed, 26 Oct 2016 17:56:13 +0200
Message-ID: <1477497377-22372-1-git-send-email-david.lebrun@uclouvain.be>
References: <1477497292-22155-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34671 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933547AbcJZPyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 11:54:39 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 28E6067DBEB
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 17:54:29 +0200 (CEST)
In-Reply-To: <1477497292-22155-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides an implementation of the genetlink commands
to associate a given HMAC key identifier with an hashing algorithm
and a secret. It also provides a per-interface sysctl called
seg6_require_hmac, allowing a user-defined policy for processing
HMAC-signed SR-enabled packets. A value of -1 means that the HMAC
field will always be ignored. A value of 0 means that if an HMAC
field is present, its validity will be enforced (the packet is
dropped is the signature is incorrect). Finally, a value of 1 means
that any SR-enabled packet that does not contain an HMAC signature
or whose signature is incorrect will be dropped.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/linux/ipv6.h      |   3 +
 include/net/seg6.h        |  10 +++
 include/net/seg6_hmac.h   |   1 +
 include/uapi/linux/ipv6.h |   1 +
 net/ipv6/Makefile         |   1 +
 net/ipv6/addrconf.c       |  18 +++++
 net/ipv6/seg6.c           | 189 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 223 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 76830e6..bad8363 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -65,6 +65,9 @@ struct ipv6_devconf {
 	__s32		use_oif_addrs_only;
 	__s32		keep_addr_on_down;
 	__s32		seg6_enabled;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	__s32		seg6_require_hmac;
+#endif
 
 	struct ctl_table_header *sysctl_header;
 };
diff --git a/include/net/seg6.h b/include/net/seg6.h
index 53d3bdb..a4062db 100644
--- a/include/net/seg6.h
+++ b/include/net/seg6.h
@@ -17,10 +17,16 @@
 #include <linux/net.h>
 #include <linux/ipv6.h>
 #include <net/lwtunnel.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 struct seg6_pernet_data {
 	struct mutex lock;
 	struct in6_addr __rcu *tun_src;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	struct list_head hmac_infos;
+#endif
 };
 
 static inline struct seg6_pernet_data *seg6_pernet(struct net *net)
@@ -28,4 +34,8 @@ static inline struct seg6_pernet_data *seg6_pernet(struct net *net)
 	return net->ipv6.seg6_data;
 }
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+extern struct sr6_tlv_hmac *seg6_get_tlv_hmac(struct ipv6_sr_hdr *srh);
+#endif
+
 #endif
diff --git a/include/net/seg6_hmac.h b/include/net/seg6_hmac.h
index 6e5ee6a..9646b7e 100644
--- a/include/net/seg6_hmac.h
+++ b/include/net/seg6_hmac.h
@@ -21,6 +21,7 @@
 #include <linux/ipv6.h>
 #include <linux/route.h>
 #include <net/seg6.h>
+#include <linux/seg6.h>
 #include <linux/seg6_hmac.h>
 
 #define SEG6_HMAC_MAX_DIGESTSIZE	160
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 7ff1d65..53561be 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -180,6 +180,7 @@ enum {
 	DEVCONF_KEEP_ADDR_ON_DOWN,
 	DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
 	DEVCONF_SEG6_ENABLED,
+	DEVCONF_SEG6_REQUIRE_HMAC,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 4bd1e73..81a70b1 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -44,6 +44,7 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 obj-$(CONFIG_IPV6_FOU) += fou6.o
+obj-$(CONFIG_IPV6_SEG6_HMAC) += seg6_hmac.o
 
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o seg6.o seg6_iptunnel.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8d068ee..6e5f72b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -240,6 +240,9 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
 	.seg6_enabled		= 0,
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	.seg6_require_hmac	= 0,
+#endif
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -287,6 +290,9 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
 	.seg6_enabled		= 0,
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	.seg6_require_hmac	= 0,
+#endif
 };
 
 /* Check if a valid qdisc is available */
@@ -4968,6 +4974,9 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
 	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
 	array[DEVCONF_SEG6_ENABLED] = cnf->seg6_enabled;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	array[DEVCONF_SEG6_REQUIRE_HMAC] = cnf->seg6_require_hmac;
+#endif
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -6066,6 +6075,15 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	{
+		.procname	= "seg6_require_hmac",
+		.data		= &ipv6_devconf.seg6_require_hmac,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{
 		/* sentinel */
 	}
diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 24111662..e967f4f 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -25,6 +25,9 @@
 #include <net/genetlink.h>
 #include <linux/seg6.h>
 #include <linux/seg6_genl.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 static const struct nla_policy seg6_genl_policy[SEG6_ATTR_MAX + 1] = {
 	[SEG6_ATTR_DST]				= { .type = NLA_BINARY,
@@ -46,11 +49,108 @@ static struct genl_family seg6_genl_family = {
 	.netnsok = true,
 };
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+struct sr6_tlv_hmac *seg6_get_tlv_hmac(struct ipv6_sr_hdr *srh)
+{
+	struct sr6_tlv_hmac *tlv;
+
+	if (srh->hdrlen < (srh->first_segment + 1) * 2 + 5)
+		return NULL;
+
+	if (!sr_has_hmac(srh))
+		return NULL;
+
+	tlv = (struct sr6_tlv_hmac *)
+	      ((char *)srh + ((srh->hdrlen + 1) << 3) - 40);
+
+	if (tlv->type != SR6_TLV_HMAC || tlv->len != 38)
+		return NULL;
+
+	return tlv;
+}
+
+static int seg6_genl_sethmac(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct seg6_pernet_data *sdata;
+	struct seg6_hmac_info *hinfo;
+	u32 hmackeyid;
+	char *secret;
+	int err = 0;
+	u8 algid;
+	u8 slen;
+
+	sdata = seg6_pernet(net);
+
+	if (!info->attrs[SEG6_ATTR_HMACKEYID] ||
+	    !info->attrs[SEG6_ATTR_SECRETLEN] ||
+	    !info->attrs[SEG6_ATTR_ALGID])
+		return -EINVAL;
+
+	hmackeyid = nla_get_u32(info->attrs[SEG6_ATTR_HMACKEYID]);
+	slen = nla_get_u8(info->attrs[SEG6_ATTR_SECRETLEN]);
+	algid = nla_get_u8(info->attrs[SEG6_ATTR_ALGID]);
+
+	if (hmackeyid == 0)
+		return -EINVAL;
+
+	if (slen > SEG6_HMAC_SECRET_LEN)
+		return -EINVAL;
+
+	mutex_lock(&sdata->lock);
+	hinfo = seg6_hmac_info_lookup(net, hmackeyid);
+
+	if (!slen) {
+		if (!hinfo || seg6_hmac_info_del(net, hmackeyid, hinfo))
+			err = -ENOENT;
+		else
+			kfree(hinfo);
+
+		goto out_unlock;
+	}
+
+	if (!info->attrs[SEG6_ATTR_SECRET]) {
+		err = -EINVAL;
+		goto out_unlock;
+	}
+
+	if (hinfo) {
+		if (seg6_hmac_info_del(net, hmackeyid, hinfo)) {
+			err = -ENOENT;
+			goto out_unlock;
+		}
+		kfree(hinfo);
+	}
+
+	secret = (char *)nla_data(info->attrs[SEG6_ATTR_SECRET]);
+
+	hinfo = kzalloc(sizeof(*hinfo), GFP_KERNEL);
+	if (!hinfo) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
+
+	memcpy(hinfo->secret, secret, slen);
+	hinfo->slen = slen;
+	hinfo->alg_id = algid;
+	hinfo->hmackeyid = hmackeyid;
+
+	seg6_hmac_info_add(net, hmackeyid, hinfo);
+
+out_unlock:
+	mutex_unlock(&sdata->lock);
+	return err;
+}
+
+#else
+
 static int seg6_genl_sethmac(struct sk_buff *skb, struct genl_info *info)
 {
 	return -ENOTSUPP;
 }
 
+#endif
+
 static int seg6_genl_set_tunsrc(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
@@ -115,11 +215,78 @@ static int seg6_genl_get_tunsrc(struct sk_buff *skb, struct genl_info *info)
 	return -ENOMEM;
 }
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+
+static int __seg6_hmac_fill_info(struct seg6_hmac_info *hinfo,
+				 struct sk_buff *msg)
+{
+	if (nla_put_u32(msg, SEG6_ATTR_HMACKEYID, hinfo->hmackeyid) ||
+	    nla_put_u8(msg, SEG6_ATTR_SECRETLEN, hinfo->slen) ||
+	    nla_put(msg, SEG6_ATTR_SECRET, hinfo->slen, hinfo->secret) ||
+	    nla_put_u8(msg, SEG6_ATTR_ALGID, hinfo->alg_id))
+		return -1;
+
+	return 0;
+}
+
+static int __seg6_genl_dumphmac_element(struct seg6_hmac_info *hinfo,
+					u32 portid, u32 seq, u32 flags,
+					struct sk_buff *skb, u8 cmd)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, portid, seq, &seg6_genl_family, flags, cmd);
+	if (!hdr)
+		return -ENOMEM;
+
+	if (__seg6_hmac_fill_info(hinfo, skb) < 0)
+		goto nla_put_failure;
+
+	genlmsg_end(skb, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct seg6_pernet_data *sdata;
+	struct seg6_hmac_info *hinfo;
+	int idx = 0, ret;
+
+	sdata = seg6_pernet(net);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hinfo, &sdata->hmac_infos, list) {
+		if (idx++ < cb->args[0])
+			continue;
+
+		ret = __seg6_genl_dumphmac_element(hinfo,
+						   NETLINK_CB(cb->skb).portid,
+						   cb->nlh->nlmsg_seq,
+						   NLM_F_MULTI,
+						   skb, SEG6_CMD_DUMPHMAC);
+		if (ret)
+			break;
+	}
+	rcu_read_unlock();
+
+	cb->args[0] = idx;
+	return skb->len;
+}
+
+#else
+
 static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	return -ENOTSUPP;
 }
 
+#endif
+
 static const struct genl_ops seg6_genl_ops[] = {
 	{
 		.cmd	= SEG6_CMD_SETHMAC,
@@ -165,6 +332,10 @@ static int __net_init seg6_net_init(struct net *net)
 
 	net->ipv6.seg6_data = sdata;
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_net_init(net);
+#endif
+
 	return 0;
 }
 
@@ -172,6 +343,10 @@ static void __net_exit seg6_net_exit(struct net *net)
 {
 	struct seg6_pernet_data *sdata = seg6_pernet(net);
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_net_exit(net);
+#endif
+
 	kfree(sdata->tun_src);
 	kfree(sdata);
 }
@@ -193,10 +368,20 @@ static int __init seg6_init(void)
 	if (err)
 		goto out_unregister_genl;
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	err = seg6_hmac_init();
+	if (err)
+		goto out_unregister_pernet;
+#endif
+
 	pr_info("Segment Routing with IPv6\n");
 
 out:
 	return err;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+out_unregister_pernet:
+	unregister_pernet_subsys(&ip6_segments_ops);
+#endif
 out_unregister_genl:
 	genl_unregister_family(&seg6_genl_family);
 	goto out;
@@ -205,6 +390,10 @@ module_init(seg6_init);
 
 static void __exit seg6_exit(void)
 {
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_exit();
+#endif
+
 	unregister_pernet_subsys(&ip6_segments_ops);
 	genl_unregister_family(&seg6_genl_family);
 }
-- 
2.7.3
