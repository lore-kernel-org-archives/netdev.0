From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH 3/3] Check num sacks in SACK fast path
Date: Sat, 27 Jan 2007 18:50:40 +0200
Message-ID: <20070127165040.GD4829@galon.ev-en.org>
References: <20070127164702.GA4829@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:54602
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbXA0Qul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 11:50:41 -0500
Content-Disposition: inline
In-Reply-To: <20070127164702.GA4829@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we check for SACK fast path make sure that we also have the same number of
SACK blocks in the cache and in the new SACK data. This prevents us from
mistakenly taking the cache data if the old data in the SACK cache is the same
as the data in the SACK block.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6-rc6/include/linux/tcp.h
===================================================================
--- 2.6-rc6.orig/include/linux/tcp.h	2007-01-27 15:06:02.000000000 +0200
+++ 2.6-rc6/include/linux/tcp.h	2007-01-27 15:19:04.000000000 +0200
@@ -317,6 +317,7 @@
 	struct tcp_sack_block selective_acks[4]; /* The SACKS themselves*/
 
 	struct tcp_sack_block recv_sack_cache[4];
+	u32     recv_sack_cache_size;
 
 	/* from STCP, retrans queue hinting */
 	struct sk_buff* lost_skb_hint;
Index: 2.6-rc6/net/ipv4/tcp_input.c
===================================================================
--- 2.6-rc6.orig/net/ipv4/tcp_input.c	2007-01-27 15:18:30.000000000 +0200
+++ 2.6-rc6/net/ipv4/tcp_input.c	2007-01-27 15:30:09.000000000 +0200
@@ -979,7 +979,8 @@
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
 	 * and use retrans queue hinting otherwise slowpath */
-	flag = 1;
+	flag = num_sacks == tp->recv_sack_cache_size;
+	tp->recv_sack_cache_size = num_sacks;
 	for (i = 0; i < num_sacks; i++) {
 		__u32 start_seq = sp[i].start_seq;
 		__u32 end_seq = sp[i].end_seq;
