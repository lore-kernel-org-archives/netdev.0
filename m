From: xeb@mail.ru
Subject: =?koi8-r?Q?[PATCH_1/3_update]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Thu, 05 Aug 2010 09:48:30 +0400
Message-ID: <E1OgtJe-0004W9-00.xeb-mail-ru@f162.mail.ru>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from f162.mail.ru ([217.69.128.114]:49494 "EHLO f162.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756643Ab0HEFsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 01:48:31 -0400
Received: from mail by f162.mail.ru with local
	id 1OgtJe-0004W9-00
	for netdev@vger.kernel.org; Thu, 05 Aug 2010 09:48:30 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is patch 1/3 which contains gre demultiplexer driver source
for demultiplexing gre packets with different gre version.
Update: included forgotten net/ipv4/ip_gre.c

 include/net/gre.h |   18 ++++++
 net/ipv4/Kconfig  |    7 +++
 net/ipv4/Makefile |    1 +
 net/ipv4/gre.c    |  151 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c |   10 ++--
 5 files changed, 182 insertions(+), 5 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
new file mode 100644
index 0000000..31a0f76
--- /dev/null
+++ b/include/net/gre.h
@@ -0,0 +1,18 @@
+#ifndef __LINUX_GRE_H
+#define __LINUX_GRE_H
+
+#include <linux/skbuff.h>
+
+#define GREPROTO_CISCO		0
+#define GREPROTO_PPTP		1
+#define GREPROTO_MAX		2
+
+struct gre_protocol {
+	int		(*handler)(struct sk_buff *skb);
+	void	(*err_handler)(struct sk_buff *skb, u32 info);
+};
+
+int gre_add_protocol(const struct gre_protocol *proto, u8 version);
+int gre_del_protocol(const struct gre_protocol *proto, u8 version);
+
+#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 7c3a7d1..7458bda 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -215,8 +215,15 @@ config NET_IPIP
 	  be inserted in and removed from the running kernel whenever you
 	  want). Most people won't need this and can say N.
 
+config NET_IPGRE_DEMUX
+	tristate "IP: GRE demultiplexer"
+	help
+	 This is helper module to demultiplex GRE packets on GRE version field criteria.
+	 Required by ip_gre and pptp modules.
+
 config NET_IPGRE
 	tristate "IP: GRE tunnels over IP"
+	depends on NET_IPGRE_DEMUX
 	help
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 80ff87c..4978d22 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
+obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
 obj-$(CONFIG_INET_AH) += ah4.o
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
new file mode 100644
index 0000000..993f3cf
--- /dev/null
+++ b/net/ipv4/gre.c
@@ -0,0 +1,151 @@
+/*
+ *	GRE over IPv4 demultiplexer driver
+ *
+ *	Authors: Dmitry Kozlov (xeb@mail.ru)
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/kmod.h>
+#include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/netdevice.h>
+#include <linux/version.h>
+#include <linux/spinlock.h>
+#include <net/protocol.h>
+#include <net/gre.h>
+
+
+const struct gre_protocol *gre_proto[GREPROTO_MAX] ____cacheline_aligned_in_smp;
+static DEFINE_RWLOCK(gre_proto_lock);
+
+int gre_add_protocol(const struct gre_protocol *proto, u8 version)
+{
+	int ret;
+
+	if (version >= GREPROTO_MAX)
+		return -1;
+	
+	write_lock_bh(&gre_proto_lock);
+	if (gre_proto[version]) {
+		ret = -1;
+	} else {
+		gre_proto[version]=proto;
+		ret = 0;
+	}
+	write_unlock_bh(&gre_proto_lock);
+
+	return ret;
+}
+int gre_del_protocol(const struct gre_protocol *proto, u8 version)
+{
+	int ret;
+
+	if (version >= GREPROTO_MAX)
+		return -1;
+
+	write_lock_bh(&gre_proto_lock);
+	if (gre_proto[version] == proto) {
+		gre_proto[version] = NULL;
+		ret = 0;
+	} else {
+		ret = -1;
+	}
+	write_unlock_bh(&gre_proto_lock);
+
+	return ret;
+}
+static int gre_rcv(struct sk_buff *skb)
+{
+	u8 ver;
+	int ret;
+
+	if (!pskb_may_pull(skb, 12))
+		goto drop_nolock;
+
+	ver = skb->data[1]&0x7f;
+	if (ver >= GREPROTO_MAX)
+		goto drop_nolock;
+	
+	read_lock(&gre_proto_lock);
+	if (!gre_proto[ver] || !gre_proto[ver]->handler)
+		goto drop;
+
+	ret = gre_proto[ver]->handler(skb);
+	read_unlock(&gre_proto_lock);
+
+	return ret;
+
+drop:
+	read_unlock(&gre_proto_lock);
+drop_nolock:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+static void gre_err(struct sk_buff *skb, u32 info)
+{
+	u8 ver;
+
+	printk("err\n");
+
+	if (!pskb_may_pull(skb, 12))
+		goto drop_nolock;
+
+	ver=skb->data[1];
+	if (ver>=GREPROTO_MAX)
+		goto drop_nolock;
+		
+	read_lock(&gre_proto_lock);
+	if (!gre_proto[ver] || !gre_proto[ver]->err_handler)
+		goto drop;
+
+	gre_proto[ver]->err_handler(skb,info);
+	read_unlock(&gre_proto_lock);
+
+	return;
+
+drop:
+	read_unlock(&gre_proto_lock);
+drop_nolock:
+	kfree_skb(skb);
+}
+
+
+static struct net_protocol net_gre_protocol = {
+	.handler	= gre_rcv,
+	.err_handler	=	gre_err,
+//	.netns_ok=1,
+};
+
+static int __init gre_init(void)
+{
+	printk(KERN_INFO "GRE over IPv4 demultiplexor driver");
+	
+	if (inet_add_protocol(&net_gre_protocol, IPPROTO_GRE) < 0) {
+		printk(KERN_INFO "gre: can't add protocol\n");
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+static void __exit gre_exit(void)
+{
+	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
+}
+
+module_init(gre_init);
+module_exit(gre_exit);
+
+MODULE_DESCRIPTION("GRE over IPv4 demultiplexer driver");
+MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
+MODULE_LICENSE("GPL");
+EXPORT_SYMBOL_GPL(gre_add_protocol);
+EXPORT_SYMBOL_GPL(gre_del_protocol);
+
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 32618e1..f0391b3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -44,6 +44,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/gre.h>
 
 #ifdef CONFIG_IPV6
 #include <net/ipv6.h>
@@ -1276,10 +1277,9 @@ static void ipgre_fb_tunnel_init(struct net_device *dev)
 }
 
 
-static const struct net_protocol ipgre_protocol = {
+static const struct gre_protocol ipgre_protocol = {
 	.handler	=	ipgre_rcv,
 	.err_handler	=	ipgre_err,
-	.netns_ok	=	1,
 };
 
 static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list_head *head)
@@ -1661,7 +1661,7 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		return err;
 
-	err = inet_add_protocol(&ipgre_protocol, IPPROTO_GRE);
+	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	if (err < 0) {
 		printk(KERN_INFO "ipgre init: can't add protocol\n");
 		goto add_proto_failed;
@@ -1681,7 +1681,7 @@ out:
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
-	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 add_proto_failed:
 	unregister_pernet_device(&ipgre_net_ops);
 	goto out;
@@ -1691,7 +1691,7 @@ static void __exit ipgre_fini(void)
 {
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
-	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
+	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
 		printk(KERN_INFO "ipgre close: can't remove protocol\n");
 	unregister_pernet_device(&ipgre_net_ops);
 }
