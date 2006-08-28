From: shemminger@osdl.org
Subject: [PATCH 1/9] sky2: remove cloned/pskb_expand_head check
Date: Mon, 28 Aug 2006 10:00:45 -0700
Message-ID: <20060828170214.888770919@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60292 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750889AbWH1SUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:20:20 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-no-overwrite.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code to handle cloned skb overwriting is unnecessary in the
sky2 driver and is buggy. The bug is that pskb_expand_head can change the
skb but the driver has already mapped in the header.

Since the sky2 hardware doesn't need to overwrite memory, the buggy
code can just be removed; it was mistakenly copied from the tg3
driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- sky2.orig/drivers/net/sky2.c	2006-08-25 16:00:28.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-25 16:01:33.000000000 -0700
@@ -1239,13 +1239,6 @@
 	/* Check for TCP Segmentation Offload */
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss != 0) {
-		/* just drop the packet if non-linear expansion fails */
-		if (skb_header_cloned(skb) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			goto out_unlock;
-		}
-
 		mss += ((skb->h.th->doff - 5) * 4);	/* TCP options */
 		mss += (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
 		mss += ETH_HLEN;
@@ -1341,7 +1334,6 @@
 
 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);
 
-out_unlock:
 	spin_unlock(&sky2->tx_lock);
 
 	dev->trans_start = jiffies;

--
Stephen Hemminger <shemminger@osdl.org>

