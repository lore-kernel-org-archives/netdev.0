From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] subset of RFC2553
Date: 12 Feb 2003 15:15:39 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1045091741.8858.320.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@redhat.com
List-Id: netdev.vger.kernel.org

This patch against 2.5.59 adds bits of RFC 2553 Basic Socket Interface
Extensions for IPv6; specifically the in6addr_any wildcard address and
in6addr_loopback address structures, the respective IN6ADDR_*_INIT
constants, and moves the definition of struct sockaddr_storage from the
SCTP code to a common IPv6 header file. These changes will assist in
making certain networking kernel code portable across multiple address
families.
--
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR
========================================================================
diff -Naur linux-2.5.59/include/linux/in6.h linux-2.5.59-RFC2553/include/linux/in6.h
--- linux-2.5.59/include/linux/in6.h	2003-02-12 10:29:14.000000000 -0800
+++ linux-2.5.59-RFC2553/include/linux/in6.h	2003-02-12 10:09:23.000000000 -0800
@@ -40,6 +40,15 @@
 #define s6_addr32		in6_u.u6_addr32
 };
 
+/* IPv6 Wildcard Address (::) and Loopback Address (::1) defined in RFC2553
+ * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
+ * in network byte order, not in host byte order as are the IPv4 equivalents
+ */
+extern const struct in6_addr in6addr_any;
+#define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
+extern const struct in6_addr in6addr_loopback;
+#define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
+
 struct sockaddr_in6 {
 	unsigned short int	sin6_family;    /* AF_INET6 */
 	__u16			sin6_port;      /* Transport layer port # */
diff -Naur linux-2.5.59/include/linux/socket.h linux-2.5.59-RFC2553/include/linux/socket.h
--- linux-2.5.59/include/linux/socket.h	2003-02-12 10:29:14.000000000 -0800
+++ linux-2.5.59-RFC2553/include/linux/socket.h	2003-02-12 10:09:09.000000000 -0800
@@ -25,6 +25,34 @@
 };
 
 /*
+ * Desired design of maximum size and alignment
+ */
+#define _SS_MAXSIZE    128	/* Implementation specific max size */
+#define _SS_ALIGNSIZE  (sizeof (int64_t))
+				/* Implementation specific desired alignment */
+/* 
+ * Definitions used for sockaddr_storage structure paddings design.
+ */
+#define _SS_PAD1SIZE   (_SS_ALIGNSIZE - sizeof (sa_family_t))
+#define _SS_PAD2SIZE   (_SS_MAXSIZE - (sizeof (sa_family_t) + \
+		       	      _SS_PAD1SIZE + _SS_ALIGNSIZE))
+
+struct sockaddr_storage {
+	sa_family_t  ss_family;			/* address family */
+	/* Following fields are implementation specific */
+	char      __ss_pad1[_SS_PAD1SIZE];
+				/* 6 byte pad, this is to make implementation */
+				/* specific pad up to alignment field that */
+				/* follows explicit in the data structure */
+	int64_t   __ss_align; 	/* field to force desired structure */
+				/* storage alignment */
+	char      __ss_pad2[_SS_PAD2SIZE];
+				/* 112 byte pad to achieve desired size, */
+				/* _SS_MAXSIZE value minus size of ss_family */
+				/* __ss_pad1, __ss_align fields is 112 */
+};
+
+/*
  *	As we do 4.4BSD message passing we use a 4.4BSD message passing
  *	system, not 4.3. Thus msg_accrights(len) are now missing. They
  *	belong in an obscure libc emulation or the bin.
diff -Naur linux-2.5.59/include/net/sctp/structs.h linux-2.5.59-RFC2553/include/net/sctp/structs.h
--- linux-2.5.59/include/net/sctp/structs.h	2003-02-12 10:29:14.000000000 -0800
+++ linux-2.5.59-RFC2553/include/net/sctp/structs.h	2003-02-12 08:35:07.000000000 -0800
@@ -61,38 +61,6 @@
 #include <linux/workqueue.h>	/* We need tq_struct.    */
 #include <linux/sctp.h>         /* We need sctp* header structs.  */
 
-/*
- * This is (almost) a direct quote from RFC 2553.
- */
-
-/*
- * Desired design of maximum size and alignment
- */
-#define _SS_MAXSIZE    128		/* Implementation specific max size */
-#define _SS_ALIGNSIZE  (sizeof (__s64))
-				/* Implementation specific desired alignment */
-/*
- * Definitions used for sockaddr_storage structure paddings design.
- */
-#define _SS_PAD1SIZE   (_SS_ALIGNSIZE - sizeof (sa_family_t))
-#define _SS_PAD2SIZE   (_SS_MAXSIZE - (sizeof (sa_family_t)+ \
-                              _SS_PAD1SIZE + _SS_ALIGNSIZE))
-
-struct sockaddr_storage {
-	sa_family_t  __ss_family;		/* address family */
-	/* Following fields are implementation specific */
-	char      __ss_pad1[_SS_PAD1SIZE];
-				/* 6 byte pad, to make implementation */
-				/* specific pad up to alignment field that */
-				/* follows explicit in the data structure */
-	__s64   __ss_align;	/* field to force desired structure */
-				/* storage alignment */
-	char      __ss_pad2[_SS_PAD2SIZE];
-				/* 112 byte pad to achieve desired size, */
-				/* _SS_MAXSIZE value minus size of ss_family */
-				/* __ss_pad1, __ss_align fields is 112 */
-};
-
 /* A convenience structure for handling sockaddr structures.
  * We should wean ourselves off this.
  */
diff -Naur linux-2.5.59/net/ipv6/addrconf.c linux-2.5.59-RFC2553/net/ipv6/addrconf.c
--- linux-2.5.59/net/ipv6/addrconf.c	2003-01-16 18:22:44.000000000 -0800
+++ linux-2.5.59-RFC2553/net/ipv6/addrconf.c	2003-02-12 13:55:03.000000000 -0800
@@ -136,6 +136,10 @@
 	MAX_RTR_SOLICITATION_DELAY,	/* rtr solicit delay	*/
 };
 
+/* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
+const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
+const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
+
 int ipv6_addr_type(struct in6_addr *addr)
 {
 	u32 st;

