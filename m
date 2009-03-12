From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver (updated)
Date: Wed, 11 Mar 2009 23:29:40 -0700 (PDT)
Message-ID: <20090311.232940.18208055.davem@davemloft.net>
References: <49B7377A.2070006@cosmosbay.com>
	<1236814387-31108-1-git-send-email-yanok@emcraft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, wd@denx.de,
	dzu@denx.de
To: yanok@emcraft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54623
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750955AbZCLG3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 02:29:54 -0400
In-Reply-To: <1236814387-31108-1-git-send-email-yanok@emcraft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Yanok <yanok@emcraft.com>
Date: Thu, 12 Mar 2009 02:33:07 +0300

> Driver for Dave DNET ethernet controller found on Dave/DENX QongEVB-LITE
> FPGA. Heavily based on Dave sources, I've just adopted it to current
> kernel version and done some code cleanup.
> 
> Signed-off-by: Ilya Yanok <yanok@emcraft.com>

Applied, but I had to add the following patch to fix warnings
and actual errors on 64-bit.

dnet: Fix warnings on 64-bit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/dnet.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 92c3bd3..4b96974 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -553,8 +553,8 @@ static int dnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_status = dnet_readl(bp, TX_STATUS);
 
-	pr_debug("start_xmit: len %u head %p data %p tail %p end %p\n",
-	       skb->len, skb->head, skb->data, skb->tail, skb->end);
+	pr_debug("start_xmit: len %u head %p data %p\n",
+	       skb->len, skb->head, skb->data);
 	dnet_print_skb(skb);
 
 	/* frame size (words) */
@@ -564,11 +564,11 @@ static int dnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_status = dnet_readl(bp, TX_STATUS);
 
-	bufp = (unsigned int *)(((u32) skb->data) & 0xFFFFFFFC);
+	bufp = (unsigned int *)(((unsigned long) skb->data) & ~0x3UL);
 	wrsz = (u32) skb->len + 3;
-	wrsz += ((u32) skb->data) & 0x3;
+	wrsz += ((unsigned long) skb->data) & 0x3;
 	wrsz >>= 2;
-	tx_cmd = ((((unsigned int)(skb->data)) & 0x03) << 16) | (u32) skb->len;
+	tx_cmd = ((((unsigned long)(skb->data)) & 0x03) << 16) | (u32) skb->len;
 
 	/* check if there is enough room for the current frame */
 	if (wrsz < (DNET_FIFO_SIZE - dnet_readl(bp, TX_FIFO_WCNT))) {
-- 
1.6.2

