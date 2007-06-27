From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 2/5 2.6.22-rc6] L2TP: Changes to existing ppp and socket kernel headers for L2TP
Date: Wed, 27 Jun 2007 23:20:38 +0100
Message-ID: <200706272220.l5RMKcv9004943@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60938 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758839AbXF0WVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 18:21:20 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1I3fk2-00050N-UD
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 17:12:03 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l5RMKcei004950
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 23:20:38 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l5RMKcv9004943
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 23:20:38 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add struct sockaddr_pppol2tp to carry L2TP-specific address
information for the PPPoX (PPPoL2TP) socket. Unfortunately we can't
use the union inside struct sockaddr_pppox because the L2TP-specific
data is larger than the current size of the union and we must preserve
the size of struct sockaddr_pppox for binary compatibility.

Also add a PPPIOCGL2TPSTATS ioctl to allow userspace to obtain
L2TP counters and state from the kernel.

Add new if_pppol2tp.h header.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.22-rc6/include/linux/if_ppp.h
===================================================================
--- linux-2.6.22-rc6.orig/include/linux/if_ppp.h
+++ linux-2.6.22-rc6/include/linux/if_ppp.h
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
Index: linux-2.6.22-rc6/include/linux/if_pppox.h
===================================================================
--- linux-2.6.22-rc6.orig/include/linux/if_pppox.h
+++ linux-2.6.22-rc6/include/linux/if_pppox.h
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
Index: linux-2.6.22-rc6/include/linux/socket.h
===================================================================
--- linux-2.6.22-rc6.orig/include/linux/socket.h
+++ linux-2.6.22-rc6/include/linux/socket.h
@@ -287,6 +287,7 @@ struct ucred {
 #define SOL_NETLINK	270
 #define SOL_TIPC	271
 #define SOL_RXRPC	272
+#define SOL_PPPOL2TP	273
 
 /* IPX options */
 #define IPX_TYPE	1
Index: linux-2.6.22-rc6/include/linux/if_pppol2tp.h
===================================================================
--- /dev/null
+++ linux-2.6.22-rc6/include/linux/if_pppol2tp.h
@@ -0,0 +1,69 @@
+/***************************************************************************
+ * Linux PPP over L2TP (PPPoL2TP) Socket Implementation (RFC 2661)
+ *
+ * This file supplies definitions required by the PPP over L2TP driver
+ * (pppol2tp.c).  All version information wrt this file is located in pppol2tp.c
+ *
+ * License:
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ */
+
+#ifndef __LINUX_IF_PPPOL2TP_H
+#define __LINUX_IF_PPPOL2TP_H
+
+#include <asm/types.h>
+
+#ifdef __KERNEL__
+#include <linux/in.h>
+#endif
+
+/* Structure used to connect() the socket to a particular tunnel UDP
+ * socket.
+ */
+struct pppol2tp_addr
+{
+	pid_t	pid;			/* pid that owns the fd.
+					 * 0 => current */
+	int	fd;			/* FD of UDP socket to use */
+
+	struct sockaddr_in addr;	/* IP address and port to send to */
+
+	__be16 s_tunnel, s_session;	/* For matching incoming packets */
+	__be16 d_tunnel, d_session;	/* For sending outgoing packets */
+};
+
+/* Socket options:
+ * DEBUG	- bitmask of debug message categories
+ * SENDSEQ	- 0 => don't send packets with sequence numbers
+ *		  1 => send packets with sequence numbers
+ * RECVSEQ	- 0 => receive packet sequence numbers are optional
+ *		  1 => drop receive packets without sequence numbers
+ * LNSMODE	- 0 => act as LAC.
+ *		  1 => act as LNS.
+ * REORDERTO	- reorder timeout (in millisecs). If 0, don't try to reorder.
+ */
+enum {
+	PPPOL2TP_SO_DEBUG	= 1,
+	PPPOL2TP_SO_RECVSEQ	= 2,
+	PPPOL2TP_SO_SENDSEQ	= 3,
+	PPPOL2TP_SO_LNSMODE	= 4,
+	PPPOL2TP_SO_REORDERTO	= 5,
+};
+
+/* Debug message categories for the DEBUG socket option */
+enum {
+	PPPOL2TP_MSG_DEBUG	= (1 << 0),	/* verbose debug (if
+						 * compiled in) */
+	PPPOL2TP_MSG_CONTROL	= (1 << 1),	/* userspace - kernel
+						 * interface */
+	PPPOL2TP_MSG_SEQ	= (1 << 2),	/* sequence numbers */
+	PPPOL2TP_MSG_DATA	= (1 << 3),	/* data packets */
+};
+
+
+
+#endif
Index: linux-2.6.22-rc6/include/linux/Kbuild
===================================================================
--- linux-2.6.22-rc6.orig/include/linux/Kbuild
+++ linux-2.6.22-rc6/include/linux/Kbuild
@@ -225,6 +225,7 @@ unifdef-y += if_fddi.h
 unifdef-y += if_frad.h
 unifdef-y += if_ltalk.h
 unifdef-y += if_link.h
+unifdef-y += if_pppol2tp.h
 unifdef-y += if_pppox.h
 unifdef-y += if_shaper.h
 unifdef-y += if_tr.h
