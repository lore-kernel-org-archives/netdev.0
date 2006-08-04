From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/9] [IPv4]: Move interface address bits to linux/if_addr.h
Date: Sat, 05 Aug 2006 00:00:06 +0200
Message-ID: <20060805003537.140393407@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:9709 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422679AbWHEAna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:30 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_if_addr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/include/linux/if_addr.h
===================================================================
--- /dev/null
+++ net-2.6.19/include/linux/if_addr.h
@@ -0,0 +1,53 @@
+#ifndef __LINUX_IF_ADDR_H
+#define __LINUX_IF_ADDR_H
+
+#include <linux/netlink.h>
+
+struct ifaddrmsg
+{
+	__u8		ifa_family;
+	__u8		ifa_prefixlen;	/* The prefix length		*/
+	__u8		ifa_flags;	/* Flags			*/
+	__u8		ifa_scope;	/* Address scope		*/
+	__u32		ifa_index;	/* Link index			*/
+};
+
+/*
+ * Important comment:
+ * IFA_ADDRESS is prefix address, rather than local interface address.
+ * It makes no difference for normally configured broadcast interfaces,
+ * but for point-to-point IFA_ADDRESS is DESTINATION address,
+ * local address is supplied in IFA_LOCAL attribute.
+ */
+enum
+{
+	IFA_UNSPEC,
+	IFA_ADDRESS,
+	IFA_LOCAL,
+	IFA_LABEL,
+	IFA_BROADCAST,
+	IFA_ANYCAST,
+	IFA_CACHEINFO,
+	IFA_MULTICAST,
+	__IFA_MAX,
+};
+
+#define IFA_MAX (__IFA_MAX - 1)
+
+/* ifa_flags */
+#define IFA_F_SECONDARY		0x01
+#define IFA_F_TEMPORARY		IFA_F_SECONDARY
+
+#define IFA_F_DEPRECATED	0x20
+#define IFA_F_TENTATIVE		0x40
+#define IFA_F_PERMANENT		0x80
+
+struct ifa_cacheinfo
+{
+	__u32	ifa_prefered;
+	__u32	ifa_valid;
+	__u32	cstamp; /* created timestamp, hundredths of seconds */
+	__u32	tstamp; /* updated timestamp, hundredths of seconds */
+};
+
+#endif
Index: net-2.6.19/net/decnet/dn_dev.c
===================================================================
--- net-2.6.19.orig/net/decnet/dn_dev.c
+++ net-2.6.19/net/decnet/dn_dev.c
@@ -34,6 +34,7 @@
 #include <linux/seq_file.h>
 #include <linux/timer.h>
 #include <linux/string.h>
+#include <linux/if_addr.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/skbuff.h>
Index: net-2.6.19/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.orig/net/ipv4/devinet.c
+++ net-2.6.19/net/ipv4/devinet.c
@@ -43,6 +43,7 @@
 #include <linux/in.h>
 #include <linux/errno.h>
 #include <linux/interrupt.h>
+#include <linux/if_addr.h>
 #include <linux/if_ether.h>
 #include <linux/inet.h>
 #include <linux/netdevice.h>
Index: net-2.6.19/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.19.orig/net/ipv4/fib_frontend.c
+++ net-2.6.19/net/ipv4/fib_frontend.c
@@ -32,6 +32,7 @@
 #include <linux/inet.h>
 #include <linux/inetdevice.h>
 #include <linux/netdevice.h>
+#include <linux/if_addr.h>
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c
+++ net-2.6.19/net/ipv6/addrconf.c
@@ -48,6 +48,7 @@
 #include <linux/net.h>
 #include <linux/in6.h>
 #include <linux/netdevice.h>
+#include <linux/if_addr.h>
 #include <linux/if_arp.h>
 #include <linux/if_arcnet.h>
 #include <linux/if_infiniband.h>
Index: net-2.6.19/net/ipv6/ndisc.c
===================================================================
--- net-2.6.19.orig/net/ipv6/ndisc.c
+++ net-2.6.19/net/ipv6/ndisc.c
@@ -62,6 +62,7 @@
 #include <linux/sysctl.h>
 #endif
 
+#include <linux/if_addr.h>
 #include <linux/if_arp.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
Index: net-2.6.19/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.orig/net/core/rtnetlink.c
+++ net-2.6.19/net/core/rtnetlink.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/security.h>
 #include <linux/mutex.h>
+#include <linux/if_addr.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
Index: net-2.6.19/include/linux/rtnetlink.h
===================================================================
--- net-2.6.19.orig/include/linux/rtnetlink.h
+++ net-2.6.19/include/linux/rtnetlink.h
@@ -384,62 +384,6 @@ struct rta_session
 };
 
 
-/*********************************************************
- *		Interface address.
- ****/
-
-struct ifaddrmsg
-{
-	unsigned char	ifa_family;
-	unsigned char	ifa_prefixlen;	/* The prefix length		*/
-	unsigned char	ifa_flags;	/* Flags			*/
-	unsigned char	ifa_scope;	/* See above			*/
-	int		ifa_index;	/* Link index			*/
-};
-
-enum
-{
-	IFA_UNSPEC,
-	IFA_ADDRESS,
-	IFA_LOCAL,
-	IFA_LABEL,
-	IFA_BROADCAST,
-	IFA_ANYCAST,
-	IFA_CACHEINFO,
-	IFA_MULTICAST,
-	__IFA_MAX
-};
-
-#define IFA_MAX (__IFA_MAX - 1)
-
-/* ifa_flags */
-
-#define IFA_F_SECONDARY		0x01
-#define IFA_F_TEMPORARY		IFA_F_SECONDARY
-
-#define IFA_F_DEPRECATED	0x20
-#define IFA_F_TENTATIVE		0x40
-#define IFA_F_PERMANENT		0x80
-
-struct ifa_cacheinfo
-{
-	__u32	ifa_prefered;
-	__u32	ifa_valid;
-	__u32	cstamp; /* created timestamp, hundredths of seconds */
-	__u32	tstamp; /* updated timestamp, hundredths of seconds */
-};
-
-
-#define IFA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
-#define IFA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
-
-/*
-   Important comment:
-   IFA_ADDRESS is prefix address, rather than local interface address.
-   It makes no difference for normally configured broadcast interfaces,
-   but for point-to-point IFA_ADDRESS is DESTINATION address,
-   local address is supplied in IFA_LOCAL attribute.
- */
 
 /**************************************************************
  *		Neighbour discovery.

