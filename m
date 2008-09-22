From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 01/11] Phonet global definitions
Date: Mon, 22 Sep 2008 18:47:15 +0300
Message-ID: <1222098445-26175-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:53009 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbYIVPrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:48 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlZFf027641
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 18:47:45 +0300
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/if_ether.h  |    1 +
 include/linux/if_phonet.h |   14 +++++
 include/linux/phonet.h    |  125 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/rtnetlink.h |    4 ++
 include/linux/socket.h    |    4 +-
 net/core/sock.c           |    9 ++-
 6 files changed, 153 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/if_phonet.h
 create mode 100644 include/linux/phonet.h

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 5028e0b..723a1c5 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -100,6 +100,7 @@
 #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
 #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
 #define ETH_P_ARCNET	0x001A		/* 1A for ArcNet :-)            */
+#define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/linux/if_phonet.h b/include/linux/if_phonet.h
new file mode 100644
index 0000000..22df25f
--- /dev/null
+++ b/include/linux/if_phonet.h
@@ -0,0 +1,14 @@
+/*
+ * File: if_phonet.h
+ *
+ * Phonet interface kernel definitions
+ *
+ * Copyright (C) 2008 Nokia Corporation. All rights reserved.
+ */
+
+#define PHONET_HEADER_LEN	8	/* Phonet header length */
+
+#define PHONET_MIN_MTU		6
+/* 6 bytes header + 65535 bytes payload */
+#define PHONET_MAX_MTU		65541
+#define PHONET_DEV_MTU		PHONET_MAX_MTU
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
new file mode 100644
index 0000000..6a764f8
--- /dev/null
+++ b/include/linux/phonet.h
@@ -0,0 +1,125 @@
+/**
+ * file phonet.h
+ *
+ * Phonet sockets kernel interface
+ *
+ * Copyright (C) 2008 Nokia Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#ifndef LINUX_PHONET_H
+#define LINUX_PHONET_H
+
+/* Automatic protocol selection */
+#define PN_PROTO_TRANSPORT	0
+/* Phonet datagram socket */
+#define PN_PROTO_PHONET		1
+#define PHONET_NPROTO		2
+
+#define PNADDR_ANY		0
+#define PNPORT_RESOURCE_ROUTING	0
+
+/* Phonet protocol header */
+struct phonethdr {
+	__u8	pn_rdev;
+	__u8	pn_sdev;
+	__u8	pn_res;
+	__be16	pn_length;
+	__u8	pn_robj;
+	__u8	pn_sobj;
+} __attribute__((packed));
+
+/* Phonet socket address structure */
+struct sockaddr_pn {
+	sa_family_t spn_family;
+	__u8 spn_obj;
+	__u8 spn_dev;
+	__u8 spn_resource;
+	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(sa_family_t) - 3];
+} __attribute__ ((packed));
+
+static inline __u16 pn_object(__u8 addr, __u16 port)
+{
+	return (addr << 8) | (port & 0x3ff);
+}
+
+static inline __u8 pn_obj(__u16 handle)
+{
+	return handle & 0xff;
+}
+
+static inline __u8 pn_dev(__u16 handle)
+{
+	return handle >> 8;
+}
+
+static inline __u16 pn_port(__u16 handle)
+{
+	return handle & 0x3ff;
+}
+
+static inline __u8 pn_addr(__u16 handle)
+{
+	return (handle >> 8) & 0xfc;
+}
+
+static inline void pn_sockaddr_set_addr(struct sockaddr_pn *spn, __u8 addr)
+{
+	spn->spn_dev &= 0x03;
+	spn->spn_dev |= addr & 0xfc;
+}
+
+static inline void pn_sockaddr_set_port(struct sockaddr_pn *spn, __u16 port)
+{
+	spn->spn_dev &= 0xfc;
+	spn->spn_dev |= (port >> 8) & 0x03;
+	spn->spn_obj = port & 0xff;
+}
+
+static inline void pn_sockaddr_set_object(struct sockaddr_pn *spn,
+						__u16 handle)
+{
+	spn->spn_dev = pn_dev(handle);
+	spn->spn_obj = pn_obj(handle);
+}
+
+static inline void pn_sockaddr_set_resource(struct sockaddr_pn *spn,
+						__u8 resource)
+{
+	spn->spn_resource = resource;
+}
+
+static inline __u8 pn_sockaddr_get_addr(const struct sockaddr_pn *spn)
+{
+	return spn->spn_dev & 0xfc;
+}
+
+static inline __u16 pn_sockaddr_get_port(const struct sockaddr_pn *spn)
+{
+	return ((spn->spn_dev & 0x03) << 8) | spn->spn_obj;
+}
+
+static inline __u16 pn_sockaddr_get_object(const struct sockaddr_pn *spn)
+{
+	return pn_object(spn->spn_dev, spn->spn_obj);
+}
+
+static inline __u8 pn_sockaddr_get_resource(const struct sockaddr_pn *spn)
+{
+	return spn->spn_resource;
+}
+
+#endif
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index ca643b1..2b3d51c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -582,6 +582,10 @@ enum rtnetlink_groups {
 #define RTNLGRP_IPV6_RULE	RTNLGRP_IPV6_RULE
 	RTNLGRP_ND_USEROPT,
 #define RTNLGRP_ND_USEROPT	RTNLGRP_ND_USEROPT
+	RTNLGRP_PHONET_IFADDR,
+#define RTNLGRP_PHONET_IFADDR	RTNLGRP_PHONET_IFADDR
+	RTNLGRP_PHONET_ROUTE,
+#define RTNLGRP_PHONET_ROUTE	RTNLGRP_PHONET_ROUTE
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/include/linux/socket.h b/include/linux/socket.h
index dc5086f..818ca33 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -190,7 +190,8 @@ struct ucred {
 #define AF_IUCV		32	/* IUCV sockets			*/
 #define AF_RXRPC	33	/* RxRPC sockets 		*/
 #define AF_ISDN		34	/* mISDN sockets 		*/
-#define AF_MAX		35	/* For now.. */
+#define AF_PHONET	35	/* Phonet sockets		*/
+#define AF_MAX		36	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -227,6 +228,7 @@ struct ucred {
 #define PF_IUCV		AF_IUCV
 #define PF_RXRPC	AF_RXRPC
 #define PF_ISDN		AF_ISDN
+#define PF_PHONET	AF_PHONET
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/net/core/sock.c b/net/core/sock.c
index 23b8b9d..2d358dd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -154,7 +154,8 @@ static const char *af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_PPPOX" , "sk_lock-AF_WANPIPE"  , "sk_lock-AF_LLC"      ,
   "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
-  "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_MAX"
+  "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
+  "sk_lock-AF_MAX"
 };
 static const char *af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -168,7 +169,8 @@ static const char *af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_PPPOX" , "slock-AF_WANPIPE"  , "slock-AF_LLC"      ,
   "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
-  "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_MAX"
+  "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
+  "slock-AF_MAX"
 };
 static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -182,7 +184,8 @@ static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
   "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
-  "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_MAX"
+  "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
+  "clock-AF_MAX"
 };
 #endif
 
-- 
1.5.4.3

