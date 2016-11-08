From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v5 2/9] ipv6: sr: add code base for control plane support of SR-IPv6
Date: Tue, 8 Nov 2016 14:57:40 +0100
Message-ID: <1478613467-27712-3-git-send-email-david.lebrun@uclouvain.be>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:43158 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbcKHN4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 08:56:11 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id BB89867DA79
        for <netdev@vger.kernel.org>; Tue,  8 Nov 2016 14:56:01 +0100 (CET)
In-Reply-To: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary hooks and structures to provide support
for SR-IPv6 control plane, essentially the Generic Netlink commands
that will be used for userspace control over the Segment Routing
kernel structures.

The genetlink commands provide control over two different structures:
tunnel source and HMAC data. The tunnel source is the source address
that will be used by default when encapsulating packets into an
outer IPv6 header + SRH. If the tunnel source is set to :: then an
address of the outgoing interface will be selected as the source.

The HMAC commands currently just return ENOTSUPP and will be implemented
in a future patch.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/linux/seg6_genl.h      |   6 ++
 include/net/netns/ipv6.h       |   1 +
 include/net/seg6.h             |  16 +++
 include/uapi/linux/seg6_genl.h |  32 ++++++
 net/ipv6/Makefile              |   2 +-
 net/ipv6/af_inet6.c            |   9 +-
 net/ipv6/seg6.c                | 214 +++++++++++++++++++++++++++++++++++++++++
 7 files changed, 278 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/seg6_genl.h
 create mode 100644 include/uapi/linux/seg6_genl.h
 create mode 100644 net/ipv6/seg6.c

diff --git a/include/linux/seg6_genl.h b/include/linux/seg6_genl.h
new file mode 100644
index 0000000..d6c3fb4f
--- /dev/null
+++ b/include/linux/seg6_genl.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_SEG6_GENL_H
+#define _LINUX_SEG6_GENL_H
+
+#include <uapi/linux/seg6_genl.h>
+
+#endif
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 10d0848..de7745e 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -85,6 +85,7 @@ struct netns_ipv6 {
 #endif
 	atomic_t		dev_addr_genid;
 	atomic_t		fib6_sernum;
+	struct seg6_pernet_data *seg6_data;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/include/net/seg6.h b/include/net/seg6.h
index 4dd52a7..7c7b8ed 100644
--- a/include/net/seg6.h
+++ b/include/net/seg6.h
@@ -14,6 +14,9 @@
 #ifndef _NET_SEG6_H
 #define _NET_SEG6_H
 
+#include <linux/net.h>
+#include <linux/ipv6.h>
+
 static inline void update_csum_diff4(struct sk_buff *skb, __be32 from,
 				     __be32 to)
 {
@@ -33,4 +36,17 @@ static inline void update_csum_diff16(struct sk_buff *skb, __be32 *from,
 	skb->csum = ~csum_partial((char *)diff, sizeof(diff), ~skb->csum);
 }
 
+struct seg6_pernet_data {
+	struct mutex lock;
+	struct in6_addr __rcu *tun_src;
+};
+
+static inline struct seg6_pernet_data *seg6_pernet(struct net *net)
+{
+	return net->ipv6.seg6_data;
+}
+
+extern int seg6_init(void);
+extern void seg6_exit(void);
+
 #endif
diff --git a/include/uapi/linux/seg6_genl.h b/include/uapi/linux/seg6_genl.h
new file mode 100644
index 0000000..fcf1c60
--- /dev/null
+++ b/include/uapi/linux/seg6_genl.h
@@ -0,0 +1,32 @@
+#ifndef _UAPI_LINUX_SEG6_GENL_H
+#define _UAPI_LINUX_SEG6_GENL_H
+
+#define SEG6_GENL_NAME		"SEG6"
+#define SEG6_GENL_VERSION	0x1
+
+enum {
+	SEG6_ATTR_UNSPEC,
+	SEG6_ATTR_DST,
+	SEG6_ATTR_DSTLEN,
+	SEG6_ATTR_HMACKEYID,
+	SEG6_ATTR_SECRET,
+	SEG6_ATTR_SECRETLEN,
+	SEG6_ATTR_ALGID,
+	SEG6_ATTR_HMACINFO,
+	__SEG6_ATTR_MAX,
+};
+
+#define SEG6_ATTR_MAX (__SEG6_ATTR_MAX - 1)
+
+enum {
+	SEG6_CMD_UNSPEC,
+	SEG6_CMD_SETHMAC,
+	SEG6_CMD_DUMPHMAC,
+	SEG6_CMD_SET_TUNSRC,
+	SEG6_CMD_GET_TUNSRC,
+	__SEG6_CMD_MAX,
+};
+
+#define SEG6_CMD_MAX (__SEG6_CMD_MAX - 1)
+
+#endif
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index c174ccb..c92010d 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -9,7 +9,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o \
-		udp_offload.o
+		udp_offload.o seg6.o
 
 ipv6-offload :=	ip6_offload.o tcpv6_offload.o exthdrs_offload.o
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c86911b..d424f3a 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -61,6 +61,7 @@
 #include <net/ip6_tunnel.h>
 #endif
 #include <net/calipso.h>
+#include <net/seg6.h>
 
 #include <asm/uaccess.h>
 #include <linux/mroute6.h>
@@ -991,6 +992,10 @@ static int __init inet6_init(void)
 	if (err)
 		goto calipso_fail;
 
+	err = seg6_init();
+	if (err)
+		goto seg6_fail;
+
 #ifdef CONFIG_SYSCTL
 	err = ipv6_sysctl_register();
 	if (err)
@@ -1001,8 +1006,10 @@ static int __init inet6_init(void)
 
 #ifdef CONFIG_SYSCTL
 sysctl_fail:
-	calipso_exit();
+	seg6_exit();
 #endif
+seg6_fail:
+	calipso_exit();
 calipso_fail:
 	pingv6_exit();
 pingv6_fail:
diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
new file mode 100644
index 0000000..e246b0b
--- /dev/null
+++ b/net/ipv6/seg6.c
@@ -0,0 +1,214 @@
+/*
+ *  SR-IPv6 implementation
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *	  modify it under the terms of the GNU General Public License
+ *	  as published by the Free Software Foundation; either version
+ *	  2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/net.h>
+#include <linux/in6.h>
+#include <linux/slab.h>
+
+#include <net/ipv6.h>
+#include <net/protocol.h>
+
+#include <net/seg6.h>
+#include <net/genetlink.h>
+#include <linux/seg6.h>
+#include <linux/seg6_genl.h>
+
+static struct genl_family seg6_genl_family;
+
+static const struct nla_policy seg6_genl_policy[SEG6_ATTR_MAX + 1] = {
+	[SEG6_ATTR_DST]				= { .type = NLA_BINARY,
+		.len = sizeof(struct in6_addr) },
+	[SEG6_ATTR_DSTLEN]			= { .type = NLA_S32, },
+	[SEG6_ATTR_HMACKEYID]		= { .type = NLA_U32, },
+	[SEG6_ATTR_SECRET]			= { .type = NLA_BINARY, },
+	[SEG6_ATTR_SECRETLEN]		= { .type = NLA_U8, },
+	[SEG6_ATTR_ALGID]			= { .type = NLA_U8, },
+	[SEG6_ATTR_HMACINFO]		= { .type = NLA_NESTED, },
+};
+
+static int seg6_genl_sethmac(struct sk_buff *skb, struct genl_info *info)
+{
+	return -ENOTSUPP;
+}
+
+static int seg6_genl_set_tunsrc(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct in6_addr *val, *t_old, *t_new;
+	struct seg6_pernet_data *sdata;
+
+	sdata = seg6_pernet(net);
+
+	if (!info->attrs[SEG6_ATTR_DST])
+		return -EINVAL;
+
+	val = nla_data(info->attrs[SEG6_ATTR_DST]);
+	t_new = kmemdup(val, sizeof(*val), GFP_KERNEL);
+
+	mutex_lock(&sdata->lock);
+
+	t_old = sdata->tun_src;
+	rcu_assign_pointer(sdata->tun_src, t_new);
+
+	mutex_unlock(&sdata->lock);
+
+	synchronize_net();
+	kfree(t_old);
+
+	return 0;
+}
+
+static int seg6_genl_get_tunsrc(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct in6_addr *tun_src;
+	struct sk_buff *msg;
+	void *hdr;
+
+	msg = genlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &seg6_genl_family, 0, SEG6_CMD_GET_TUNSRC);
+	if (!hdr)
+		goto free_msg;
+
+	rcu_read_lock();
+	tun_src = rcu_dereference(seg6_pernet(net)->tun_src);
+
+	if (nla_put(msg, SEG6_ATTR_DST, sizeof(struct in6_addr), tun_src))
+		goto nla_put_failure;
+
+	rcu_read_unlock();
+
+	genlmsg_end(msg, hdr);
+	genlmsg_reply(msg, info);
+
+	return 0;
+
+nla_put_failure:
+	rcu_read_unlock();
+	genlmsg_cancel(msg, hdr);
+free_msg:
+	nlmsg_free(msg);
+	return -ENOMEM;
+}
+
+static int seg6_genl_dumphmac(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return -ENOTSUPP;
+}
+
+static int __net_init seg6_net_init(struct net *net)
+{
+	struct seg6_pernet_data *sdata;
+
+	sdata = kzalloc(sizeof(*sdata), GFP_KERNEL);
+	if (!sdata)
+		return -ENOMEM;
+
+	mutex_init(&sdata->lock);
+
+	sdata->tun_src = kzalloc(sizeof(*sdata->tun_src), GFP_KERNEL);
+	if (!sdata->tun_src) {
+		kfree(sdata);
+		return -ENOMEM;
+	}
+
+	net->ipv6.seg6_data = sdata;
+
+	return 0;
+}
+
+static void __net_exit seg6_net_exit(struct net *net)
+{
+	struct seg6_pernet_data *sdata = seg6_pernet(net);
+
+	kfree(sdata->tun_src);
+	kfree(sdata);
+}
+
+static struct pernet_operations ip6_segments_ops = {
+	.init = seg6_net_init,
+	.exit = seg6_net_exit,
+};
+
+static const struct genl_ops seg6_genl_ops[] = {
+	{
+		.cmd	= SEG6_CMD_SETHMAC,
+		.doit	= seg6_genl_sethmac,
+		.policy	= seg6_genl_policy,
+		.flags	= GENL_ADMIN_PERM,
+	},
+	{
+		.cmd	= SEG6_CMD_DUMPHMAC,
+		.dumpit	= seg6_genl_dumphmac,
+		.policy	= seg6_genl_policy,
+		.flags	= GENL_ADMIN_PERM,
+	},
+	{
+		.cmd	= SEG6_CMD_SET_TUNSRC,
+		.doit	= seg6_genl_set_tunsrc,
+		.policy	= seg6_genl_policy,
+		.flags	= GENL_ADMIN_PERM,
+	},
+	{
+		.cmd	= SEG6_CMD_GET_TUNSRC,
+		.doit	= seg6_genl_get_tunsrc,
+		.policy = seg6_genl_policy,
+		.flags	= GENL_ADMIN_PERM,
+	},
+};
+
+static struct genl_family seg6_genl_family __ro_after_init = {
+	.hdrsize	= 0,
+	.name		= SEG6_GENL_NAME,
+	.version	= SEG6_GENL_VERSION,
+	.maxattr	= SEG6_ATTR_MAX,
+	.netnsok	= true,
+	.parallel_ops	= true,
+	.ops		= seg6_genl_ops,
+	.n_ops		= ARRAY_SIZE(seg6_genl_ops),
+	.module		= THIS_MODULE,
+};
+
+int __init seg6_init(void)
+{
+	int err = -ENOMEM;
+
+	err = genl_register_family(&seg6_genl_family);
+	if (err)
+		goto out;
+
+	err = register_pernet_subsys(&ip6_segments_ops);
+	if (err)
+		goto out_unregister_genl;
+
+	pr_info("Segment Routing with IPv6\n");
+
+out:
+	return err;
+out_unregister_genl:
+	genl_unregister_family(&seg6_genl_family);
+	goto out;
+}
+
+void seg6_exit(void)
+{
+	unregister_pernet_subsys(&ip6_segments_ops);
+	genl_unregister_family(&seg6_genl_family);
+}
-- 
2.7.3
