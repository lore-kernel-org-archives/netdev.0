From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v3] sky2:  receive dma mapping error handling
Date: Mon, 1 Feb 2010 22:27:41 +0100
Message-ID: <20100201212740.GA3289@del.dom.local>
References: <20100128225621.GD3109@del.dom.local>
 <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam>
 <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local>
 <4B650D53.2010607@majjas.com>
 <4B65D0F9.2020602@majjas.com>
 <4B65FD12.7090101@majjas.com>
 <20100131221835.GA3317@del.dom.local>
 <20100201102018.7b597992@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100201102018.7b597992@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 01, 2010 at 10:20:18AM -0800, Stephen Hemminger wrote:
> This fixes the fact that re->flags is always zero without causing
> other confusion.

Here it is, with only sky2->tx_cons update in tx_init().

Thanks,
Jarek P.
---------------> (take 3)
Michael Breuer reported that dma-debug entries added by sky2 driver
weren't unmapped, and found out "re->flags is always NULL upon entry
to sky2_tx_unmap". It is overwritten by get_tx_le() after changes
introduced by commit 6b84dacadbdc3dab6a5b313d20d5a93b0d998641.

This patch moves re->flags and re->skb initializations from
get_tx_le() to sky2_tx_unmap() and sky2_tx_complete() respectively.
Additionally sky2->tx_cons is updated to sky2->tx_prod in tx_init()
to remove one needless tx completion.

With debugging by: Michael Breuer <mbreuer@majjas.com>
Improved by: Stephen Hemminger <shemminger@vyatta.com>

Reported-by: Michael Breuer <mbreuer@majjas.com>
Tested-by: Michael Breuer <mbreuer@majjas.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
---

 drivers/net/sky2.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d760650..08cd65b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1025,11 +1025,8 @@ static void sky2_prefetch_init(struct sky2_hw *hw, u32 qaddr,
 static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
 {
 	struct sky2_tx_le *le = sky2->tx_le + *slot;
-	struct tx_ring_info *re = sky2->tx_ring + *slot;
 
 	*slot = RING_NEXT(*slot, sky2->tx_ring_size);
-	re->flags = 0;
-	re->skb = NULL;
 	le->ctrl = 0;
 	return le;
 }
@@ -1038,13 +1035,14 @@ static void tx_init(struct sky2_port *sky2)
 {
 	struct sky2_tx_le *le;
 
-	sky2->tx_prod = sky2->tx_cons = 0;
+	sky2->tx_prod = 0;
 	sky2->tx_tcpsum = 0;
 	sky2->tx_last_mss = 0;
 
 	le = get_tx_le(sky2, &sky2->tx_prod);
 	le->addr = 0;
 	le->opcode = OP_ADDR64 | HW_OWNER;
+	sky2->tx_cons = sky2->tx_prod;
 	sky2->tx_last_upper = 0;
 }
 
@@ -1622,8 +1620,7 @@ static unsigned tx_le_req(const struct sk_buff *skb)
 	return count;
 }
 
-static void sky2_tx_unmap(struct pci_dev *pdev,
-			  const struct tx_ring_info *re)
+static void sky2_tx_unmap(struct pci_dev *pdev, struct tx_ring_info *re)
 {
 	if (re->flags & TX_MAP_SINGLE)
 		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
@@ -1633,6 +1630,7 @@ static void sky2_tx_unmap(struct pci_dev *pdev,
 		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
 			       pci_unmap_len(re, maplen),
 			       PCI_DMA_TODEVICE);
+	re->flags = 0;
 }
 
 /*
@@ -1839,6 +1837,7 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += skb->len;
 
+			re->skb = NULL;
 			dev_kfree_skb_any(skb);
 
 			sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
