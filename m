From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 07/17] solos-pci: Wait for pending TX to complete when releasing vcc
Date: Fri, 30 Nov 2012 00:35:26 +0000
Message-ID: <1354235736-26833-8-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47043
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755190Ab2K3Agl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:41 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <David.Woodhouse@intel.com>

We should no longer be calling the old pop routine for the vcc, after
vcc_release() has completed. Make sure we wait for any pending TX skbs
to complete, by waiting for our own PKT_PCLOSE control skb to be sent.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 9851093..387052d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -92,6 +92,7 @@ struct pkt_hdr {
 };
 
 struct solos_skb_cb {
+	struct completion c;
 	struct atm_vcc *vcc;
 	uint32_t dma_addr;
 };
@@ -881,11 +882,18 @@ static void pclose(struct atm_vcc *vcc)
 	header->vci = cpu_to_le16(vcc->vci);
 	header->type = cpu_to_le16(PKT_PCLOSE);
 
+	init_completion(&SKB_CB(skb)->c);
+
 	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
 
 	clear_bit(ATM_VF_ADDR, &vcc->flags);
 	clear_bit(ATM_VF_READY, &vcc->flags);
 
+	if (!wait_for_completion_timeout(&SKB_CB(skb)->c,
+					 msecs_to_jiffies(5000)))
+		dev_warn(&card->dev->dev, "Timeout waiting for VCC close on port %d\n",
+			 SOLOS_CHAN(vcc->dev));
+
 	/* Hold up vcc_destroy_socket() (our caller) until solos_bh() in the
 	   tasklet has finished processing any incoming packets (and, more to
 	   the point, using the vcc pointer). */
@@ -1011,9 +1019,12 @@ static uint32_t fpga_tx(struct solos_card *card)
 			if (vcc) {
 				atomic_inc(&vcc->stats->tx);
 				solos_pop(vcc, oldskb);
-			} else
+			} else {
+				struct pkt_hdr *header = (void *)oldskb->data;
+				if (le16_to_cpu(header->type) == PKT_PCLOSE)
+					complete(&SKB_CB(oldskb)->c);
 				dev_kfree_skb_irq(oldskb);
-
+			}
 		}
 	}
 	/* For non-DMA TX, write the 'TX start' bit for all four ports simultaneously */
@@ -1345,6 +1356,8 @@ static struct pci_driver fpga_driver = {
 
 static int __init solos_pci_init(void)
 {
+	BUILD_BUG_ON(sizeof(struct solos_skb_cb) > sizeof(((struct sk_buff *)0)->cb));
+
 	printk(KERN_INFO "Solos PCI Driver Version %s\n", VERSION);
 	return pci_register_driver(&fpga_driver);
 }
-- 
1.8.0
