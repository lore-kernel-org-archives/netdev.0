From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH 1/3] Advance fast path pointer for first block only
Date: Sat, 27 Jan 2007 18:48:46 +0200
Message-ID: <20070127164846.GB4829@galon.ev-en.org>
References: <20070127164702.GA4829@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:54595
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbXA0Qsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 11:48:47 -0500
Content-Disposition: inline
In-Reply-To: <20070127164702.GA4829@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only advance the SACK fast-path pointer for the first block, the fast-path
assumes that only the first block advances next time so we should not move the
skb for the next sack blocks.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

---

I'm not sure about the fack_count part, this patch changes the value that is
maintained in this case.

Index: 2.6-rc6/net/ipv4/tcp_input.c
===================================================================
--- 2.6-rc6.orig/net/ipv4/tcp_input.c	2007-01-27 14:53:27.000000000 +0200
+++ 2.6-rc6/net/ipv4/tcp_input.c	2007-01-27 15:59:22.000000000 +0200
@@ -1048,8 +1048,13 @@
 			int in_sack, pcount;
 			u8 sacked;
 
-			tp->fastpath_skb_hint = skb;
-			tp->fastpath_cnt_hint = fack_count;
+			if (i == 0) {
+				/* Only advance the hint for the first SACK
+				 * block, the hint is for quickly handling the
+				 * advancing of the first SACK blocks only. */
+				tp->fastpath_skb_hint = skb;
+				tp->fastpath_cnt_hint = fack_count;
+			}
 
 			/* The retransmission queue is always in order, so
 			 * we can short-circuit the walk early.
