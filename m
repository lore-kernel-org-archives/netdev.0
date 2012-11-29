From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH] solos-pci: don't call vcc->pop() after pclose()
Date: Thu, 29 Nov 2012 13:43:44 +0100
Message-ID: <20121129124344.GA7704@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
 <1354141115.21562.101.camel@shinybook.infradead.org>
 <20121129105715.GA10226@shrek.podlesie.net>
 <1354190143.21562.145.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shrek-wifi.podlesie.net ([93.179.225.50]:51971 "EHLO
	shrek.podlesie.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab2K2Mnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 07:43:47 -0500
Content-Disposition: inline
In-Reply-To: <1354190143.21562.145.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 29, 2012 at 11:55:43AM +0000, David Woodhouse wrote:
> On Thu, 2012-11-29 at 11:57 +0100, Krzysztof Mazur wrote:
> > do we really need to wait here?
> > Why don't just do something like that:
> > 
> > 	tasklet_disable(&card->tlet);
> > 	spin_lock(&card->tx_queue_lock);
> > 	for each skb in queue
> > 		SKB_CB(skb)->vcc = NULL;
> > 	spin_unlock(&card->tx_queue_lock);
> > 	tasklet_enable(&card->tlet);
> > 
> > or if we really want to call vcc->pop() for such skbs:
> > 
> > 	tasklet_disable(&card->tlet);
> > 	spin_lock(&card->tx_queue_lock);
> > 	for each skb in queue {
> > 		skb_get(skb);
> > 		solos_pop(SKB_CB(skb)->vcc, skb);
> > 		SKB_CB(skb)->vcc = NULL;
> > 	}
> > 	spin_unlock(&card->tx_queue_lock);
> > 	tasklet_enable(&card->tlet);
> 
> Yes, we could certainly remove the packets from the tx_queue first.
> 
> However, in the card->using_dma case there might be a skb for this vcc
> *currently* being DMA'd, and we'd still need to wait for that one.

Removing packets from tx_queue is not needed. We can transmit packets
also after close. We just can't call vcc->pop() after close,
so we can just set SKB_CB(skb)->vcc of such packets to NULL so fpga_tx()
won't call vcc->pop().

Maybe I was not precise enough, I'm think that all we need is
something like that:

-- >8 --
Subject: [PATCH] solos-pci: don't call vcc->pop() after pclose()

After atmdev_ops->close() we cannot use vcc->pop() because the vcc may,
and probably will be destroyed.

We can just set vcc for such frames to NULL because fpga_tx() after
completion will call dev_kfree_skb() in that case.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 drivers/atm/solos-pci.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 9851093..aabe021 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -868,6 +868,19 @@ static void pclose(struct atm_vcc *vcc)
 	struct solos_card *card = vcc->dev->dev_data;
 	struct sk_buff *skb;
 	struct pkt_hdr *header;
+	unsigned int port;
+
+	tasklet_disable(&card->tlet);
+	spin_lock(&card->tx_queue_lock);
+	for (port = 0; port < card->nr_ports; port++)
+		skb_queue_walk(&card->tx_queue[port], skb)
+			if (SKB_CB(skb)->vcc == vcc) {
+				skb_get(skb);
+				solos_pop(SKB_CB(skb)->vcc, skb);
+				SKB_CB(skb)->vcc = NULL;
+			}
+	spin_unlock(&card->tx_queue_lock);
+	tasklet_enable(&card->tlet);
 
 	skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
 	if (!skb) {
-- 
1.8.0.411.g71a7da8
