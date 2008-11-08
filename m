From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] net: fix setting of skb->tail in skb_recycle_check()
Date: Sun, 9 Nov 2008 00:09:43 +0100
Message-ID: <20081108230943.GW32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@ddcrew.com, dirk@upexia.nl
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:54847 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbYKHXJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 18:09:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since skb_reset_tail_pointer() reads skb->data, we need to set
skb->data before calling skb_reset_tail_pointer().  This was causing
spurious skb_over_panic()s from skb_put() being called on a recycled
skb that had its skb->tail set to beyond where it should have been.

Bug report from Peter van Valderen <linux@ddcrew.com>.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
--
Please apply for 2.6.28, thanks!

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2c218a0..a17117e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -454,8 +454,8 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	shinfo->frag_list = NULL;
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb_reset_tail_pointer(skb);
 	skb->data = skb->head + NET_SKB_PAD;
+	skb_reset_tail_pointer(skb);
 
 	return 1;
 }

