From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 2/5 2.6.21] L2TP: Changes to existing ppp and socket kernel headers for L2TP
Date: Mon, 30 Apr 2007 10:52:01 +0100
Message-ID: <200704300952.l3U9q10p031847@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:42315 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031524AbXD3Jwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 05:52:43 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HiSYj-0006EX-OM
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 04:52:42 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3U9q1kF031860
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 10:52:01 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3U9q10p031847
	for netdev@vger.kernel.org; Mon, 30 Apr 2007 10:52:01 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add struct sockaddr_pppol2tp to carry L2TP-specific address
information for the PPPoX (PPPoL2TP) socket. Unfortunately we can't
use the union inside struct sockaddr_pppox because the L2TP-specific
data is larger than the current size of the union and we must preserve
the size of struct sockaddr_pppox for binary compatibility.

Also add a PPPIOCGL2TPSTATS ioctl to allow userspace to obtain
L2TP counters and state from the kernel.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21/include/linux/if_ppp.h
===================================================================
--- linux-2.6.21.orig/include/linux/if_ppp.h
+++ linux-2.6.21/include/linux/if_ppp.h
@@ -110,6 +110,21 @@ struct ifpppcstatsreq {
 	struct ppp_comp_stats stats;
 };
 
+/* For PPPIOCGL2TPSTATS */
+struct pppol2tp_ioc_stats {
+	__u16	tunnel_id;	/* redundant */
+	__u16	session_id;	/* if zero, get tunnel stats */
+	__u32	using_ipsec:1;	/* valid only for session_id == 0 */
+	__u64	tx_packets;
+	__u64	tx_bytes;
+	__u64	tx_errors;
+	__u64	rx_packets;
+	__u64	rx_bytes;
+	__u64	rx_seq_discards;
+	__u64	rx_oos_packets;
+	__u64	rx_errors;
+};
+
 #define ifr__name       b.ifr_ifrn.ifrn_name
 #define stats_ptr       b.ifr_ifru.ifru_data
 
@@ -146,6 +161,7 @@ struct ifpppcstatsreq {
 #define PPPIOCDISCONN	_IO('t', 57)		/* disconnect channel */
 #define PPPIOCATTCHAN	_IOW('t', 56, int)	/* attach to ppp channel */
 #define PPPIOCGCHAN	_IOR('t', 55, int)	/* get ppp channel number */
+#define PPPIOCGL2TPSTATS _IOR('t', 54, struct pppol2tp_ioc_stats)
 
 #define SIOCGPPPSTATS   (SIOCDEVPRIVATE + 0)
 #define SIOCGPPPVER     (SIOCDEVPRIVATE + 1)	/* NEVER change this!! */
Index: linux-2.6.21/include/linux/if_pppox.h
===================================================================
--- linux-2.6.21.orig/include/linux/if_pppox.h
+++ linux-2.6.21/include/linux/if_pppox.h
@@ -27,6 +27,7 @@
 #include <asm/semaphore.h>
 #include <linux/ppp_channel.h>
 #endif /* __KERNEL__ */
+#include <linux/if_pppol2tp.h>
 
 /* For user-space programs to pick up these definitions
  * which they wouldn't get otherwise without defining __KERNEL__
@@ -50,8 +51,9 @@ struct pppoe_addr{ 
  * Protocols supported by AF_PPPOX 
  */ 
 #define PX_PROTO_OE    0 /* Currently just PPPoE */
-#define PX_MAX_PROTO   1	
- 
+#define PX_PROTO_OL2TP 1 /* Now L2TP also */
+#define PX_MAX_PROTO   2
+
 struct sockaddr_pppox { 
        sa_family_t     sa_family;            /* address family, AF_PPPOX */ 
        unsigned int    sa_protocol;          /* protocol identifier */ 
@@ -60,6 +62,16 @@ struct sockaddr_pppox { 
        }sa_addr; 
 }__attribute__ ((packed)); 
 
+/* The use of the above union isn't viable because the size of this
+ * struct must stay fixed over time -- applications use sizeof(struct
+ * sockaddr_pppox) to fill it. We use a protocol specific sockaddr
+ * type instead.
+ */
+struct sockaddr_pppol2tp {
+	sa_family_t     sa_family;      /* address family, AF_PPPOX */
+	unsigned int    sa_protocol;    /* protocol identifier */
+	struct pppol2tp_addr pppol2tp;
+}__attribute__ ((packed));
 
 /*********************************************************************
  *
Index: linux-2.6.21/include/linux/socket.h
===================================================================
--- linux-2.6.21.orig/include/linux/socket.h
+++ linux-2.6.21/include/linux/socket.h
@@ -284,6 +284,7 @@ struct ucred {
 #define SOL_DCCP	269
 #define SOL_NETLINK	270
 #define SOL_TIPC	271
+#define SOL_PPPOL2TP	272
 
 /* IPX options */
 #define IPX_TYPE	1
