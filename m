From: Holger Hans Peter Freyther <holger@freyther.de>
Subject: [PATCH][RFC] Allow to use adler32 for SCTP
Date: Sun, 09 Jan 2011 22:36:09 +0100
Message-ID: <4D2A2A49.2000806@freyther.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060504050204060609080609"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gandharva.secretlabs.de ([78.46.147.237]:54422 "EHLO
	gandharva.secretlabs.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab1AIVoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 16:44:10 -0500
Received: from [192.168.0.101] (91-64-83-241-dynip.superkabel.de [91.64.83.241])
	by gandharva.secretlabs.de (Postfix) with ESMTPA id AE6431B10C05
	for <netdev@vger.kernel.org>; Sun,  9 Jan 2011 21:43:53 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060504050204060609080609
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,

with OpenBSC I have to connect to some equipment that is configured to use
adler32 as the checksum. I wonder if something a long the lines of this patch
is acceptable? It adds a module parameter that globally allows to use adler32
and then there is a sockopt to enable adler32 on a per process basis. For the
receive path I have to decode both checksums.

I could probably just use the code to disable checksums for rx but I will need
to generate them on tx to make the other equipment accept these.

regards
	holger

PS: While adding my field to struct sctp_sock I saw that there are quite some
holes (on both ia32,x86_64) in the struct and that one can save 16byte by
re-ordering. I am not sure how to and if to benchmark such a change. Does it
make sense to re-order those?

--------------060504050204060609080609
Content-Type: text/x-patch;
 name="0001-sctp-Allow-to-use-adler32-as-checksum-for-old-equipm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-sctp-Allow-to-use-adler32-as-checksum-for-old-equipm.pa";
 filename*1="tch"

>From bc332df3e078e4ddac93415a4e11de018604537a Mon Sep 17 00:00:00 2001
From: Holger Hans Peter Freyther <zecke@selfish.org>
Date: Sun, 9 Jan 2011 21:18:04 +0100
Subject: [PATCH] sctp: Allow to use adler32 as checksum for old equipment

Make it possible to use adler32 for outgoing packets. For
incoming packets add an option to determine the crc32 and
adler32. Discard the packet if the socket was not using the
adler32 checksum.

Signed-off-by: Holger Hans Peter Freyther <zecke@selfish.org>
---
 include/net/sctp/checksum.h |   35 ++++++++++++++++++++++++++++++++
 include/net/sctp/structs.h  |    6 +++++
 include/net/sctp/user.h     |    1 +
 net/sctp/input.c            |   46 +++++++++++++++++++++++++++++++++++++++---
 net/sctp/output.c           |   17 +++++++++++++--
 net/sctp/protocol.c         |    3 ++
 net/sctp/socket.c           |   23 +++++++++++++++++++++
 7 files changed, 124 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index befc8d2..9111f52 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -1,6 +1,7 @@
 /* SCTP kernel reference Implementation
  * Copyright (c) 1999-2001 Motorola, Inc.
  * Copyright (c) 2001-2003 International Business Machines, Corp.
+ * Copyright (c) 2011 Holger Hans Peter Freyther
  *
  * This file is part of the SCTP kernel reference Implementation
  *
@@ -34,6 +35,7 @@
  *    Dinakaran Joseph
  *    Jon Grimm <jgrimm@us.ibm.com>
  *    Sridhar Samudrala <sri@us.ibm.com>
+ *    Holger Hans Peter Freyther <holger@freyther.de>
  *
  * Rewritten to use libcrc32c by:
  *    Vlad Yasevich <vladislav.yasevich@hp.com>
@@ -45,6 +47,7 @@
 #include <linux/types.h>
 #include <net/sctp/sctp.h>
 #include <linux/crc32c.h>
+#include <linux/zutil.h>
 
 static inline __u32 sctp_crc32c(__u32 crc, u8 *buffer, u16 length)
 {
@@ -81,3 +84,35 @@ static inline __le32 sctp_end_cksum(__be32 crc32)
 {
 	return cpu_to_le32(~crc32);
 }
+
+static inline __u32 sctp_start_cksum_adler(__u8 *buffer, __u16 length)
+{
+	__u32 adler = 1;
+	__u8  zero[sizeof(__u32)] = {0};
+
+	/* Optimize this routine to be SCTP specific, knowing how
+	 * to skip the checksum field of the SCTP header.
+	 */
+
+	/* Calculate adler32 up to the checksum. */
+	adler = zlib_adler32(adler, buffer,
+				sizeof(struct sctphdr) -sizeof(__u32));
+
+	/* Skip checksum field of the header. */
+	adler = zlib_adler32(adler, zero, sizeof(__u32));
+
+	/* Calculate the rest of the adler32. */
+	adler = zlib_adler32(adler, &buffer[sizeof(struct sctphdr)],
+				length - sizeof(struct sctphdr));
+	return adler;
+}
+
+static inline __u32 sctp_update_cksum_adler(__u8 *buffer, __u16 len, __u32 a32)
+{
+	return zlib_adler32(a32, buffer, len);
+}
+
+static inline __u32 sctp_end_cksum_adler(__u32 a32)
+{
+	return htonl(a32);
+}
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index cc9185c..d44eb7a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -236,6 +236,9 @@ extern struct sctp_globals {
 	 * bits is an indicator of when to send and window update SACK.
 	 */
 	int rwnd_update_shift;
+
+	/* Allow Adler32 as Checksum fallback */
+	int allow_adler32;
 } sctp_globals;
 
 #define sctp_rto_initial		(sctp_globals.rto_initial)
@@ -271,6 +274,7 @@ extern struct sctp_globals {
 #define sctp_auth_enable		(sctp_globals.auth_enable)
 #define sctp_checksum_disable		(sctp_globals.checksum_disable)
 #define sctp_rwnd_upd_shift		(sctp_globals.rwnd_update_shift)
+#define sctp_allow_adler32_csum		(sctp_globals.allow_adler32)
 
 /* SCTP Socket type: UDP or TCP style. */
 typedef enum {
@@ -338,6 +342,8 @@ struct sctp_sock {
 	__u32 adaptation_ind;
 	__u32 pd_point;
 
+	__u8 cksum_adler;
+
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
 	struct sk_buff_head pd_lobby;
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 2b2769c..427da93 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -103,6 +103,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_GET_LOCAL_ADDRS	109		/* Get all local addresss. */
 #define SCTP_SOCKOPT_CONNECTX	110		/* CONNECTX requests. */
 #define SCTP_SOCKOPT_CONNECTX3	111	/* CONNECTX requests (updated) */
+#define SCTP_COMPAT_ADLER_CRC	112	/* User ADLER32 for the checksum. */
 
 /*
  * 5.2.1 SCTP Initiation Structure (SCTP_INIT)
diff --git a/net/sctp/input.c b/net/sctp/input.c
index ea21924..471e048 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -5,6 +5,7 @@
  * Copyright (c) 2001 Intel Corp.
  * Copyright (c) 2001 Nokia, Inc.
  * Copyright (c) 2001 La Monte H.P. Yarroll
+ * Copyright (c) 2011 Holger Hans Peter Freyther
  *
  * This file is part of the SCTP kernel implementation
  *
@@ -43,6 +44,7 @@
  *    Daisy Chang <daisyc@us.ibm.com>
  *    Sridhar Samudrala <sri@us.ibm.com>
  *    Ardelle Fan <ardelle.fan@intel.com>
+ *    Holger Hans Peter Freyther <holger@freyther.de>
  *
  * Any bugs reported given to us we will try to fix... any fixes shared will
  * be incorporated into the next SCTP release.
@@ -80,7 +82,7 @@ static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb);
 
 
 /* Calculate the SCTP checksum of an SCTP packet.  */
-static inline int sctp_rcv_checksum(struct sk_buff *skb)
+static inline int sctp_rcv_checksum_crc32(struct sk_buff *skb)
 {
 	struct sctphdr *sh = sctp_hdr(skb);
 	__le32 cmp = sh->checksum;
@@ -102,6 +104,24 @@ static inline int sctp_rcv_checksum(struct sk_buff *skb)
 	return 0;
 }
 
+static inline int sctp_rcv_checksum_adler32(struct sk_buff *skb)
+{
+	struct sk_buff *list = skb_shinfo(skb)->frag_list;
+	struct sctphdr *sh = sctp_hdr(skb);
+	__u32 cmp = ntohl(sh->checksum);
+	__u32 val = sctp_start_cksum_adler((__u8 *)sh, skb_headlen(skb));
+
+	for (; list; list = list->next)
+		val = sctp_update_cksum_adler((__u8 *)list->data,
+						skb_headlen(list), val);
+
+	val = sctp_end_cksum_adler(val);
+
+	if (val != cmp)
+		return -1;
+	return 0;
+}
+
 struct sctp_input_cb {
 	union {
 		struct inet_skb_parm	h4;
@@ -129,6 +149,8 @@ int sctp_rcv(struct sk_buff *skb)
 	union sctp_addr dest;
 	int family;
 	struct sctp_af *af;
+	int crc32_valid = 0, adler_valid = 0;
+
 
 	if (skb->pkt_type!=PACKET_HOST)
 		goto discard_it;
@@ -144,9 +166,15 @@ int sctp_rcv(struct sk_buff *skb)
 	__skb_pull(skb, skb_transport_offset(skb));
 	if (skb->len < sizeof(struct sctphdr))
 		goto discard_it;
-	if (!sctp_checksum_disable && !skb_csum_unnecessary(skb) &&
-		  sctp_rcv_checksum(skb) < 0)
-		goto discard_it;
+
+	/* Check up to two checksums for each packet */
+	if (!sctp_checksum_disable && !skb_csum_unnecessary(skb)) {
+		crc32_valid = sctp_rcv_checksum_crc32(skb) >= 0;
+		if (!crc32_valid && sctp_allow_adler32_csum)
+			adler_valid = sctp_rcv_checksum_adler32(skb) >= 0;
+		if (!crc32_valid && !adler_valid)
+			goto discard_it;
+	}
 
 	skb_pull(skb, sizeof(struct sctphdr));
 
@@ -188,6 +216,16 @@ int sctp_rcv(struct sk_buff *skb)
 	sk = rcvr->sk;
 
 	/*
+	 * We have the sctp_sock* now and can see if adler32
+	 * fallback is implemented. If not we will have to stop
+	 * processing the packet now.
+	 */
+	if (!crc32_valid && !sctp_sk(sk)->cksum_adler)
+		goto discard_release;
+	else if (!adler_valid && sctp_sk(sk)->cksum_adler)
+		goto discard_release;
+
+	/*
 	 * If a frame arrives on an interface and the receiving socket is
 	 * bound to another interface, via SO_BINDTODEVICE, treat it as OOTB
 	 */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 60600d3..02b2f26 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -2,6 +2,7 @@
  * (C) Copyright IBM Corp. 2001, 2004
  * Copyright (c) 1999-2000 Cisco, Inc.
  * Copyright (c) 1999-2001 Motorola, Inc.
+ * Copyright (c) 2011 Holger Hans Peter Freyther
  *
  * This file is part of the SCTP kernel implementation
  *
@@ -36,6 +37,7 @@
  *    Karl Knutson          <karl@athena.chicago.il.us>
  *    Jon Grimm             <jgrimm@austin.ibm.com>
  *    Sridhar Samudrala     <sri@us.ibm.com>
+ *    Holger Freyther       <holger@freyther.de>
  *
  * Any bugs reported given to us we will try to fix... any fixes shared will
  * be incorporated into the next SCTP release.
@@ -502,12 +504,21 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 */
 	if (!sctp_checksum_disable &&
 	    !(dst->dev->features & (NETIF_F_NO_CSUM | NETIF_F_SCTP_CSUM))) {
-		__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
-
 		/* 3) Put the resultant value into the checksum field in the
 		 *    common header, and leave the rest of the bits unchanged.
 		 */
-		sh->checksum = sctp_end_cksum(crc32);
+		__u32 crc32;
+
+		if (sctp_sk(sk)->cksum_adler && sctp_allow_adler32_csum) {
+			crc32 = sctp_start_cksum_adler((__u8 *)sh,
+							cksum_buf_len);
+			crc32 = sctp_end_cksum_adler(crc32);
+		} else {
+			crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
+			crc32 = sctp_end_cksum(crc32);
+		}
+
+		sh->checksum = crc32;
 	} else {
 		if (dst->dev->features & NETIF_F_SCTP_CSUM) {
 			/* no need to seed psuedo checksum for SCTP */
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index e58f947..f078ef6 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1397,4 +1397,7 @@ MODULE_AUTHOR("Linux Kernel SCTP developers <lksctp-developers@lists.sourceforge
 MODULE_DESCRIPTION("Support for the SCTP protocol (RFC2960)");
 module_param_named(no_checksums, sctp_checksum_disable, bool, 0644);
 MODULE_PARM_DESC(no_checksums, "Disable checksums computing and verification");
+module_param_named(adler_checksums, sctp_allow_adler32_csum, bool, 0644);
+MODULE_PARM_DESC(adler_checksums,
+		"Allow to use adler32 checksums for historic reasons.");
 MODULE_LICENSE("GPL");
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index a09b0dd..e47e39e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5,6 +5,7 @@
  * Copyright (c) 2001-2003 Intel Corp.
  * Copyright (c) 2001-2002 Nokia, Inc.
  * Copyright (c) 2001 La Monte H.P. Yarroll
+ * Copyright (c) 2011 Holger Hans Peter Freyther
  *
  * This file is part of the SCTP kernel implementation
  *
@@ -52,6 +53,7 @@
  *    Ryan Layer	    <rmlayer@us.ibm.com>
  *    Anup Pemmaiah         <pemmaiah@cc.usu.edu>
  *    Kevin Gao             <kevin.gao@intel.com>
+ *    Holger Freyther       <holger@freyther.de>
  *
  * Any bugs reported given to us we will try to fix... any fixes shared will
  * be incorporated into the next SCTP release.
@@ -3343,6 +3345,23 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 
 }
 
+static int sctp_setsockopt_adler_crc(struct sock *sk,
+					char __user *optval,
+					int optlen)
+{
+	int val;
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+	if (!sctp_allow_adler32_csum)
+		return -EACCES;
+
+	sctp_sk(sk)->cksum_adler = 1;
+	return 0;
+}
+
 
 /* API 6.2 setsockopt(), getsockopt()
  *
@@ -3490,6 +3509,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_AUTH_DELETE_KEY:
 		retval = sctp_setsockopt_del_key(sk, optval, optlen);
 		break;
+	case SCTP_COMPAT_ADLER_CRC:
+		retval = sctp_setsockopt_adler_crc(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6490,6 +6512,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	pp = sctp_sk(oldsk)->bind_hash;
 	sk_add_bind_node(newsk, &pp->owner);
 	sctp_sk(newsk)->bind_hash = pp;
+	sctp_sk(newsk)->cksum_adler = sctp_sk(oldsk)->cksum_adler;
 	inet_sk(newsk)->inet_num = inet_sk(oldsk)->inet_num;
 	sctp_spin_unlock(&head->lock);
 	sctp_local_bh_enable();
-- 
1.7.3.4


--------------060504050204060609080609--
