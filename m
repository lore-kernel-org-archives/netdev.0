From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH 1/2] net: Let inet_diag and friends autoload
Date: Tue, 16 Oct 2007 17:28:23 +0200
Message-ID: <200710161728.23733.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:36213 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933093AbXJPP0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 11:26:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By adding module aliases to inet_diag, tcp_diag and dccp_diag, we let
them load automatically as needed. This makes tools like "ss" run
faster.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
The alias naming scheme for tcp_diag and dccp_diag follows what was
done for dccp_ipv4 and dccp_ipv6.

 include/linux/net.h  |    4 ++++
 net/dccp/diag.c      |    1 +
 net/ipv4/inet_diag.c |    7 +++++++
 net/ipv4/tcp_diag.c  |    1 +
 4 files changed, 13 insertions(+)

--- linux-2.6.23-rc0.orig/net/ipv4/inet_diag.c	2007-10-16 13:32:13.000000000 +0200
+++ linux-2.6.23-rc0/net/ipv4/inet_diag.c	2007-10-16 13:46:34.000000000 +0200
@@ -815,6 +815,12 @@ static int inet_diag_rcv_msg(struct sk_b
 	    nlmsg_len(nlh) < hdrlen)
 		return -EINVAL;
 
+#ifdef CONFIG_KMOD
+	if (inet_diag_table[nlh->nlmsg_type] == NULL)
+		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+			       NETLINK_INET_DIAG, nlh->nlmsg_type);
+#endif
+
 	if (inet_diag_table[nlh->nlmsg_type] == NULL)
 		return -ENOENT;
 
@@ -914,3 +920,4 @@ static void __exit inet_diag_exit(void)
 module_init(inet_diag_init);
 module_exit(inet_diag_exit);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_INET_DIAG);
--- linux-2.6.23-rc0.orig/include/linux/net.h	2007-10-15 21:39:08.000000000 +0200
+++ linux-2.6.23-rc0/include/linux/net.h	2007-10-16 14:31:02.000000000 +0200
@@ -313,6 +313,10 @@ static const struct proto_ops name##_ops
 #define MODULE_ALIAS_NET_PF_PROTO(pf, proto) \
 	MODULE_ALIAS("net-pf-" __stringify(pf) "-proto-" __stringify(proto))
 
+#define MODULE_ALIAS_NET_PF_PROTO_TYPE(pf, proto, type) \
+	MODULE_ALIAS("net-pf-" __stringify(pf) "-proto-" __stringify(proto) \
+		     "-type-" __stringify(type))
+
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 extern ctl_table net_table[];
--- linux-2.6.23-rc0.orig/net/ipv4/tcp_diag.c	2007-10-16 13:32:13.000000000 +0200
+++ linux-2.6.23-rc0/net/ipv4/tcp_diag.c	2007-10-16 13:51:09.000000000 +0200
@@ -56,3 +56,4 @@ static void __exit tcp_diag_exit(void)
 module_init(tcp_diag_init);
 module_exit(tcp_diag_exit);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_INET_DIAG, TCPDIAG_GETSOCK);
--- linux-2.6.23-rc0.orig/net/dccp/diag.c	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.23-rc0/net/dccp/diag.c	2007-10-16 14:27:10.000000000 +0200
@@ -68,3 +68,4 @@ module_exit(dccp_diag_fini);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@mandriva.com>");
 MODULE_DESCRIPTION("DCCP inet_diag handler");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_INET_DIAG, DCCPDIAG_GETSOCK);

-- 
Jean Delvare
Suse L3
