From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v4 5/9] ipv6: sr: implement API to control SR HMAC structure
Date: Fri, 4 Nov 2016 11:32:19 +0100
Message-ID: <1478255543-32588-1-git-send-email-david.lebrun@uclouvain.be>
References: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34724 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760889AbcKDKai (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 06:30:38 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp5.sgsi.ucl.ac.be (Postfix) with ESMTPS id EA2BC67DA56
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 11:30:26 +0100 (CET)
In-Reply-To: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides an implementation of the genetlink commands
to associate a given HMAC key identifier with an hashing algorithm
and a secret.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6.c | 229 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 229 insertions(+)

diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 8114ece..7e44c12 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -25,6 +25,9 @@
 #include <net/genetlink.h>
 #include <linux/seg6.h>
 #include <linux/seg6_genl.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 static struct genl_family seg6_genl_family;
 
@@ -39,11 +42,90 @@ static const struct nla_policy seg6_genl_policy[SEG6_ATTR_MAX + 1] = {
 	[SEG6_ATTR_HMACINFO]		= { .type = NLA_NESTED, },
 };
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
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
+		if (!hinfo)
+			err = -ENOENT;
+
+		err = seg6_hmac_info_del(net, hmackeyid);
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
+		err = seg6_hmac_info_del(net, hmackeyid);
+		if (err)
+			goto out_unlock;
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
+	err = seg6_hmac_info_add(net, hmackeyid, hinfo);
+	if (err)
+		kfree(hinfo);
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
@@ -108,11 +190,135 @@ static int seg6_genl_get_tunsrc(struct sk_buff *skb, struct genl_info *info)
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
+static int seg6_genl_dumphmac_start(struct netlink_callback *cb)
+{
+	struct net *net = sock_net(cb->skb->sk);
+	struct seg6_pernet_data *sdata;
+	struct rhashtable_iter *iter;
+
+	sdata = seg6_pernet(net);
+	iter = (struct rhashtable_iter *)cb->args[0];
+
+	if (!iter) {
+		iter = kmalloc(sizeof(*iter), GFP_KERNEL);
+		if (!iter)
+			return -ENOMEM;
+
+		cb->args[0] = (long)iter;
+	}
+
+	rhashtable_walk_enter(&sdata->hmac_infos, iter);
+
+	return 0;
+}
+
+static int seg6_genl_dumphmac_done(struct netlink_callback *cb)
+{
+	struct rhashtable_iter *iter = (struct rhashtable_iter *)cb->args[0];
+
+	rhashtable_walk_exit(iter);
+
+	kfree(iter);
+
+	return 0;
+}
+
+static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct rhashtable_iter *iter = (struct rhashtable_iter *)cb->args[0];
+	struct net *net = sock_net(skb->sk);
+	struct seg6_pernet_data *sdata;
+	struct seg6_hmac_info *hinfo;
+	int ret;
+
+	sdata = seg6_pernet(net);
+
+	ret = rhashtable_walk_start(iter);
+	if (ret && ret != -EAGAIN)
+		goto done;
+
+	for (;;) {
+		hinfo = rhashtable_walk_next(iter);
+
+		if (IS_ERR(hinfo)) {
+			if (PTR_ERR(hinfo) == -EAGAIN)
+				continue;
+			ret = PTR_ERR(hinfo);
+			goto done;
+		} else if (!hinfo) {
+			break;
+		}
+
+		ret = __seg6_genl_dumphmac_element(hinfo,
+						   NETLINK_CB(cb->skb).portid,
+						   cb->nlh->nlmsg_seq,
+						   NLM_F_MULTI,
+						   skb, SEG6_CMD_DUMPHMAC);
+		if (ret)
+			goto done;
+	}
+
+	ret = skb->len;
+
+done:
+	rhashtable_walk_stop(iter);
+	return ret;
+}
+
+#else
+
+static int seg6_genl_dumphmac_start(struct netlink_callback *cb)
+{
+	return 0;
+}
+
+static int seg6_genl_dumphmac_done(struct netlink_callback *cb)
+{
+	return 0;
+}
+
 static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	return -ENOTSUPP;
 }
 
+#endif
+
 static int __net_init seg6_net_init(struct net *net)
 {
 	struct seg6_pernet_data *sdata;
@@ -131,6 +337,10 @@ static int __net_init seg6_net_init(struct net *net)
 
 	net->ipv6.seg6_data = sdata;
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_net_init(net);
+#endif
+
 	return 0;
 }
 
@@ -138,6 +348,10 @@ static void __net_exit seg6_net_exit(struct net *net)
 {
 	struct seg6_pernet_data *sdata = seg6_pernet(net);
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_net_exit(net);
+#endif
+
 	kfree(sdata->tun_src);
 	kfree(sdata);
 }
@@ -156,7 +370,9 @@ static const struct genl_ops seg6_genl_ops[] = {
 	},
 	{
 		.cmd	= SEG6_CMD_DUMPHMAC,
+		.start	= seg6_genl_dumphmac_start,
 		.dumpit	= seg6_genl_dumphmac,
+		.done	= seg6_genl_dumphmac_done,
 		.policy	= seg6_genl_policy,
 		.flags	= GENL_ADMIN_PERM,
 	},
@@ -202,10 +418,20 @@ int __init seg6_init(void)
 	if (err)
 		goto out_unregister_pernet;
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	err = seg6_hmac_init();
+	if (err)
+		goto out_unregister_iptun;
+#endif
+
 	pr_info("Segment Routing with IPv6\n");
 
 out:
 	return err;
+#ifdef CONFIG_IPV6_SEG6_HMAC
+out_unregister_iptun:
+	seg6_iptunnel_exit();
+#endif
 out_unregister_pernet:
 	unregister_pernet_subsys(&ip6_segments_ops);
 out_unregister_genl:
@@ -215,6 +441,9 @@ int __init seg6_init(void)
 
 void seg6_exit(void)
 {
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	seg6_hmac_exit();
+#endif
 	seg6_iptunnel_exit();
 	unregister_pernet_subsys(&ip6_segments_ops);
 	genl_unregister_family(&seg6_genl_family);
-- 
2.7.3
