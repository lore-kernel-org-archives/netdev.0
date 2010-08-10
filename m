From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: i386 allmodconfig, current mainline
Date: Tue, 10 Aug 2010 00:07:51 -0700 (PDT)
Message-ID: <20100810.000751.260105232.davem@davemloft.net>
References: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org, kevin.curtis-AP8L3A0T/wQqdlJmJB21zg@public.gmane.org,
	phillip-cnXvMjJKhjYG2Il/BtU0GPXRex20P6io@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100809164346.6e30cf8c.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date: Mon, 9 Aug 2010 16:43:46 -0700

> drivers/net/wan/farsync.c: In function 'fst_intr_rx':
> drivers/net/wan/farsync.c:1312: warning: cast to pointer from integer of different size
> drivers/net/wan/farsync.c: In function 'do_bottom_half_tx':
> drivers/net/wan/farsync.c:1407: warning: cast to pointer from integer of different size

I'll toss the following into net-2.6:

--------------------
farsync: Fix compile warnings.

drivers/net/wan/farsync.c: In function 'fst_intr_rx':
drivers/net/wan/farsync.c:1312: warning: cast to pointer from integer of different size
drivers/net/wan/farsync.c: In function 'do_bottom_half_tx':
drivers/net/wan/farsync.c:1407: warning: cast to pointer from integer of different size

The "skb" and "mem" arguments being passed here are DMA addresses
being programmed into the hardware registers, so pass them as the type
that they actually are.  And use the correct printf formatting in
debug logging statements for these things to match the type change.

Reported-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/wan/farsync.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index ad7719f..e050bd6 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -885,20 +885,21 @@ fst_rx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
  *      Receive a frame through the DMA
  */
 static inline void
-fst_rx_dma(struct fst_card_info *card, unsigned char *skb,
-	   unsigned char *mem, int len)
+fst_rx_dma(struct fst_card_info *card, dma_addr_t skb,
+	   dma_addr_t mem, int len)
 {
 	/*
 	 * This routine will setup the DMA and start it
 	 */
 
-	dbg(DBG_RX, "In fst_rx_dma %p %p %d\n", skb, mem, len);
+	dbg(DBG_RX, "In fst_rx_dma %lx %lx %d\n",
+	    (unsigned long) skb, (unsigned long) mem, len);
 	if (card->dmarx_in_progress) {
 		dbg(DBG_ASS, "In fst_rx_dma while dma in progress\n");
 	}
 
-	outl((unsigned long) skb, card->pci_conf + DMAPADR0);	/* Copy to here */
-	outl((unsigned long) mem, card->pci_conf + DMALADR0);	/* from here */
+	outl(skb, card->pci_conf + DMAPADR0);	/* Copy to here */
+	outl(mem, card->pci_conf + DMALADR0);	/* from here */
 	outl(len, card->pci_conf + DMASIZ0);	/* for this length */
 	outl(0x00000000c, card->pci_conf + DMADPR0);	/* In this direction */
 
@@ -1309,8 +1310,8 @@ fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 		card->dma_port_rx = port;
 		card->dma_len_rx = len;
 		card->dma_rxpos = rxp;
-		fst_rx_dma(card, (char *) card->rx_dma_handle_card,
-			   (char *) BUF_OFFSET(rxBuffer[pi][rxp][0]), len);
+		fst_rx_dma(card, card->rx_dma_handle_card,
+			   BUF_OFFSET(rxBuffer[pi][rxp][0]), len);
 	}
 	if (rxp != port->rxpos) {
 		dbg(DBG_ASS, "About to increment rxpos by more than 1\n");
-- 
1.7.2.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
