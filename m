From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC 6/9] ipv6: sr: implement API to control SR HMAC structures
Date: Fri, 26 Aug 2016 17:54:09 +0200
Message-ID: <1472226852-10075-2-git-send-email-david.lebrun@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:46947 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753716AbcHZQEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 12:04:38 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp3.sgsi.ucl.ac.be (Postfix) with ESMTPS id 1E45467DFE1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:53:43 +0200 (CEST)
In-Reply-To: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
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
 net/ipv6/Kconfig          |   7 ++
 net/ipv6/Makefile         |   1 +
 net/ipv6/addrconf.c       |  18 +++++
 net/ipv6/seg6.c           | 179 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/seg6_hmac.c      |   2 +-
 9 files changed, 221 insertions(+), 1 deletion(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index d3d8bd5..5a5998b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -65,6 +65,9 @@ struct ipv6_devconf {
 	__s32		keep_addr_on_down;
 #ifdef CONFIG_IPV6_SEG6
 	__s32		seg6_enabled;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	__s32		seg6_require_hmac;
+#endif
 #endif
 
 	struct ctl_table_header *sysctl_header;
diff --git a/include/net/seg6.h b/include/net/seg6.h
index af817f6..6d40e21 100644
--- a/include/net/seg6.h
+++ b/include/net/seg6.h
@@ -19,6 +19,9 @@
 #if IS_ENABLED(CONFIG_IPV6_SEG6_IPTUNNEL)
 #include <net/lwtunnel.h>
 #endif
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 #define SEG6_VERSION_MAJOR	0
 #define SEG6_VERSION_MINOR	30
@@ -26,6 +29,9 @@
 struct seg6_pernet_data {
 	spinlock_t lock;
 	struct in6_addr __rcu *tun_src;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	struct list_head hmac_infos;
+#endif
 };
 
 static inline struct seg6_pernet_data *seg6_pernet(struct net *net)
@@ -51,4 +57,8 @@ seg6_lwtunnel_encap(struct lwtunnel_state *lwtstate)
 }
 #endif
 
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
index a4addc8..b96c831 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -179,6 +179,7 @@ enum {
 	DEVCONF_DROP_UNSOLICITED_NA,
 	DEVCONF_KEEP_ADDR_ON_DOWN,
 	DEVCONF_SEG6_ENABLED,
+	DEVCONF_SEG6_REQUIRE_HMAC,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 192c59f..94b3f04 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -319,4 +319,11 @@ config IPV6_SEG6_IPTUNNEL
 
 	  If unsure, say N.
 
+config IPV6_SEG6_HMAC
+	bool "IPv6: Segment Routing HMAC support"
+	depends on IPV6_SEG6_CORE=y
+	select CRYPTO_HMAC
+	select CRYPTO_SHA1
+	select CRYPTO_SHA256
+
 endif # IPV6
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index a040f90..2df6d18 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 obj-$(CONFIG_IPV6_FOU) += fou6.o
 obj-$(CONFIG_IPV6_SEG6_CORE) += seg6.o
 obj-$(CONFIG_IPV6_SEG6_IPTUNNEL) += seg6_iptunnel.o
+obj-$(CONFIG_IPV6_SEG6_HMAC) += seg6_hmac.o
 
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9cc7dac..07f6f6b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -219,6 +219,9 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.keep_addr_on_down	= 0,
 #ifdef CONFIG_IPV6_SEG6
 	.seg6_enabled		= 0,
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	.seg6_require_hmac	= 0,
+#endif
 #endif
 };
 
@@ -267,6 +270,9 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.keep_addr_on_down	= 0,
 #ifdef CONFIG_IPV6_SEG6
 	.seg6_enabled		= 0,
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	.seg6_require_hmac	= 0,
+#endif
 #endif
 };
 
@@ -4928,6 +4934,9 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
 #ifdef CONFIG_IPV6_SEG6
 	array[DEVCONF_SEG6_ENABLED] = cnf->seg6_enabled;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	array[DEVCONF_SEG6_REQUIRE_HMAC] = cnf->seg6_require_hmac;
+#endif
 #endif
 }
 
@@ -6026,6 +6035,15 @@ static const struct ctl_table addrconf_sysctl[] = {
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
 #endif
 	{
 		/* sentinel */
diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 5b8b4a1..bf6627f 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -25,6 +25,9 @@
 #include <net/genetlink.h>
 #include <linux/seg6.h>
 #include <linux/seg6_genl.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 static struct nla_policy seg6_genl_policy[SEG6_ATTR_MAX + 1] = {
 	[SEG6_ATTR_DST]				= { .type = NLA_BINARY,
@@ -46,10 +49,103 @@ static struct genl_family seg6_genl_family = {
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
+	if (!(sr_get_flags(srh) & SR6_FLAG_HMAC))
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
+#endif
+
+#ifdef CONFIG_IPV6_SEG6_HMAC
+static int seg6_genl_sethmac(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	char *secret;
+	u32 hmackeyid;
+	u8 algid;
+	u8 slen;
+	struct seg6_hmac_info *hinfo;
+	int err = 0;
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
+	seg6_pernet_lock(net);
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
+	seg6_pernet_unlock(net);
+	return err;
+}
+#else
 static int seg6_genl_sethmac(struct sk_buff *skb, struct genl_info *info)
 {
 	return -ENOTSUPP;
 }
+#endif
 
 static int seg6_genl_set_tunsrc(struct sk_buff *skb, struct genl_info *info)
 {
@@ -113,10 +209,71 @@ free_msg:
 	return -ENOMEM;
 }
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
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
+	struct seg6_pernet_data *sdata = seg6_pernet(net);
+	struct seg6_hmac_info *hinfo;
+	int idx = 0, ret;
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
+#else
 static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	return -ENOTSUPP;
 }
+#endif
 
 static struct genl_ops seg6_genl_ops[] = {
 	{
@@ -163,6 +320,10 @@ static int __net_init seg6_net_init(struct net *net)
 
 	net->ipv6.seg6_data = sdata;
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_net_init(net);
+#endif
+
 	return 0;
 }
 
@@ -170,6 +331,10 @@ static void __net_exit seg6_net_exit(struct net *net)
 {
 	struct seg6_pernet_data *sdata = seg6_pernet(net);
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_net_exit(net);
+#endif
+
 	kfree(sdata->tun_src);
 	kfree(sdata);
 }
@@ -191,10 +356,20 @@ static int __init seg6_init(void)
 	if (err)
 		goto out_unregister_genl;
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	err = seg6_hmac_init();
+	if (err)
+		goto out_unregister_pernet;
+#endif
+
 	pr_info("SR-IPv6: Release v%d.%d\n", SEG6_VERSION_MAJOR,
 		SEG6_VERSION_MINOR);
 out:
 	return err;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+out_unregister_pernet:
+	unregister_pernet_subsys(&ip6_segments_ops);
+#endif
 out_unregister_genl:
 	genl_unregister_family(&seg6_genl_family);
 	goto out;
@@ -203,6 +378,10 @@ module_init(seg6_init);
 
 static void __exit seg6_exit(void)
 {
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_exit();
+#endif
+
 	unregister_pernet_subsys(&ip6_segments_ops);
 	genl_unregister_family(&seg6_genl_family);
 }
diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index 91bd59a..99e90c8 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -289,7 +289,7 @@ int seg6_push_hmac(struct net *net, struct in6_addr *saddr,
 	int err = -ENOENT;
 	struct sr6_tlv_hmac *tlv;
 
-	tlv = seg6_get_tlv(srh, SR6_TLV_HMAC);
+	tlv = seg6_get_tlv_hmac(srh);
 	if (!tlv)
 		return -EINVAL;
 
-- 
2.3.6
