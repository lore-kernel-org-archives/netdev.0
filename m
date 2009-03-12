From: Dave Jones <davej@redhat.com>
Subject: Re: VIA velocity skb leak.
Date: Thu, 12 Mar 2009 00:39:54 -0400
Message-ID: <20090312043954.GA7132@redhat.com>
References: <20090312041352.GA6035@redhat.com> <20090311.211706.68465072.davem@davemloft.net> <20090311.212009.51140677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59835 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbZCLEj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 00:39:58 -0400
Content-Disposition: inline
In-Reply-To: <20090311.212009.51140677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 09:20:09PM -0700, David Miller wrote:
 > From: David Miller <davem@davemloft.net>
 > Date: Wed, 11 Mar 2009 21:17:06 -0700 (PDT)
 > 
 > > 
 > > velocity_xmit() needs to set 'pktlen = skb->len;' after,
 > > not before, the skb_padto() call.
 > 
 > Actually that won't work since, as you suggest, skb->len
 > isn't updated by skb_padto().
 > 
 > So the transmit needs something like:
 > 
 > 	pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);
 > 
 > velocity_free_tx_buf() needs to make the same calculation
 > instead of just plain skb->len

Something like this ?
(It looks like the ZERO_COPY_SUPPORT is never enabled anywhere,
 so I didn't dig into how that works).

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index c5691fd..cd34dda 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1838,6 +1838,7 @@ static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_
 {
 	struct sk_buff *skb = tdinfo->skb;
 	int i;
+	int pktlen;
 
 	/*
 	 *	Don't unmap the pre-allocated tx_bufs
@@ -1845,10 +1846,11 @@ static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_
 	if (tdinfo->skb_dma) {
 
+		pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);
 		for (i = 0; i < tdinfo->nskb_dma; i++) {
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], le16_to_cpu(td->tdesc1.len), PCI_DMA_TODEVICE);
 #else
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], skb->len, PCI_DMA_TODEVICE);
+			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], pktlen, PCI_DMA_TODEVICE);
 #endif
 			tdinfo->skb_dma[i] = 0;
 		}
@@ -2080,17 +2083,14 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct tx_desc *td_ptr;
 	struct velocity_td_info *tdinfo;
 	unsigned long flags;
-	int pktlen = skb->len;
+	int pktlen;
 	__le16 len;
 	int index;
 
 
-
-	if (skb->len < ETH_ZLEN) {
-		if (skb_padto(skb, ETH_ZLEN))
-			goto out;
-		pktlen = ETH_ZLEN;
-	}
+	if (skb_padto(skb, ETH_ZLEN))
+		goto out;
+	pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);
 
 	len = cpu_to_le16(pktlen);
 
 

 > This bug probably exists in every other driver using
 > skb_padto() :-)

Once I've tested this (tomorrow), I'll do a sweep through some of the others.
I expect the dma-debug stuff will pick them up eventually when that hits mainline,
so it'd be good to fix up the lower hanging fruit.

The dma-debug patches are kinda neat, this is just one type of bug class
it picks up. I forwarded another type to the e1000 list earlier today.

	Dave

-- 
http://www.codemonkey.org.uk
