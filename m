From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [Patch 2.6.24 1/2]S2io: Fix for LRO Bugs
Date: Thu, 24 Jan 2008 13:08:46 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10801241307550.3800-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33705 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922AbYAXSIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 13:08:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmitting patch from Al Viro <viro@zeniv.linux.org.uk>, with subject -
[PATCH] s2io LRO bugs.
a) initiate_new_session() sets ->tcp_ack to ntohl(...); everything
   else stores and expects to find there the net-endian value.
b) check for monotonic timestamps in verify_l3_l4_lro_capable()
   compares the value sitting in TCP option (right there in the skb->data,
   net-endian 32bit) with the value picked from earlier packet.
   Doing that without ntohl() is an interesting idea and it might even
   work occasionally; unfortunately, it's quite broken.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-18-1/drivers/net/s2io.c 2-0-26-18-2/drivers/net/s2io.c
--- 2-0-26-18-1/drivers/net/s2io.c	2008-01-24 04:32:22.000000000 +0530
+++ 2-0-26-18-2/drivers/net/s2io.c	2008-01-24 04:43:36.000000000 +0530
@@ -7901,7 +7901,7 @@ static void initiate_new_session(struct 
 	lro->iph = ip;
 	lro->tcph = tcp;
 	lro->tcp_next_seq = tcp_pyld_len + ntohl(tcp->seq);
-	lro->tcp_ack = ntohl(tcp->ack_seq);
+	lro->tcp_ack = tcp->ack_seq;
 	lro->sg_num = 1;
 	lro->total_len = ntohs(ip->tot_len);
 	lro->frags_len = 0;
@@ -7911,10 +7911,10 @@ static void initiate_new_session(struct 
 	 * already been done.
  	 */
 	if (tcp->doff == 8) {
-		u32 *ptr;
-		ptr = (u32 *)(tcp+1);
+		__be32 *ptr;
+		ptr = (__be32 *)(tcp+1);
 		lro->saw_ts = 1;
-		lro->cur_tsval = *(ptr+1);
+		lro->cur_tsval = ntohl(*(ptr+1));
 		lro->cur_tsecr = *(ptr+2);
 	}
 	lro->in_use = 1;
@@ -7940,7 +7940,7 @@ static void update_L3L4_header(struct s2
 
 	/* Update tsecr field if this session has timestamps enabled */
 	if (lro->saw_ts) {
-		u32 *ptr = (u32 *)(tcp + 1);
+		__be32 *ptr = (__be32 *)(tcp + 1);
 		*(ptr+2) = lro->cur_tsecr;
 	}
 
@@ -7965,10 +7965,10 @@ static void aggregate_new_rx(struct lro 
 	lro->window = tcp->window;
 
 	if (lro->saw_ts) {
-		u32 *ptr;
+		__be32 *ptr;
 		/* Update tsecr and tsval from this packet */
-		ptr = (u32 *) (tcp + 1);
-		lro->cur_tsval = *(ptr + 1);
+		ptr = (__be32 *)(tcp+1);
+		lro->cur_tsval = ntohl(*(ptr+1));
 		lro->cur_tsecr = *(ptr + 2);
 	}
 }
@@ -8019,11 +8019,11 @@ static int verify_l3_l4_lro_capable(stru
 
 		/* Ensure timestamp value increases monotonically */
 		if (l_lro)
-			if (l_lro->cur_tsval > *((u32 *)(ptr+2)))
+			if (l_lro->cur_tsval > ntohl(*((__be32 *)(ptr+2))))
 				return -1;
 
 		/* timestamp echo reply should be non-zero */
-		if (*((u32 *)(ptr+6)) == 0)
+		if (*((__be32 *)(ptr+6)) == 0)
 			return -1;
 	}
 
diff -Nurp 2-0-26-18-1/drivers/net/s2io.h 2-0-26-18-2/drivers/net/s2io.h
--- 2-0-26-18-1/drivers/net/s2io.h	2008-01-24 04:26:10.000000000 +0530
+++ 2-0-26-18-2/drivers/net/s2io.h	2008-01-24 04:27:28.000000000 +0530
@@ -799,7 +799,7 @@ struct lro {
 	__be16		window;
 	u16             vlan_tag;
 	u32		cur_tsval;
-	u32		cur_tsecr;
+	__be32		cur_tsecr;
 	u8		saw_ts;
 } ____cacheline_aligned;
 

