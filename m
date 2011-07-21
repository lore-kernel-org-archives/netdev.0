From: cooldavid@cooldavid.org
Subject: [PATCH net-2.6] jme: Fix unmap error (Causing system
	freeze)
Date: Thu, 21 Jul 2011 10:57:36 +0800
Message-ID: <1311217056-9073-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jason Lamb <jason@lambhome.org>, linux-netdev <netdev@vger.kernel.org>,
        Guo-Fu Tseng <cooldavid@cooldavid.org>,
        Jason Long <jason@octgsoftware.com>,
        Marcus Becker <marcus.disi@gmail.com>,
        Aries Lee <arieslee@jmicron.com>, Devinchiu <devinchiu@jmicron.com>,
        Marc Schiffbauer <mschiff@gentoo.org>, stable@kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <stable-bounces@linux.kernel.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Guo-Fu Tseng <cooldavid@cooldavid.org>


This patch add the missing dma_unmap().
Which solved the critical issue of system freeze on heavy load.

Michal Miroslaw's rejected patch:
[PATCH v2 10/46] net: jme: convert to generic DMA API
Pointed out the issue also, thank you Michal.
But the fix was incorrect. It would unmap needed address
when low memory.

Got lots of feedback from End user and Gentoo Bugzilla.
https://bugs.gentoo.org/show_bug.cgi?id=373109
Thank you all. :)

Cc: stable@kernel.org
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index b5b174a..1973814 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -753,20 +753,28 @@ jme_make_new_rx_buf(struct jme_adapter *jme, int i)
 	struct jme_ring *rxring = &(jme->rxring[0]);
 	struct jme_buffer_info *rxbi = rxring->bufinf + i;
 	struct sk_buff *skb;
+	dma_addr_t mapping;
 
 	skb = netdev_alloc_skb(jme->dev,
 		jme->dev->mtu + RX_EXTRA_LEN);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
+	mapping = pci_map_page(jme->pdev, virt_to_page(skb->data),
+			       offset_in_page(skb->data), skb_tailroom(skb),
+			       PCI_DMA_FROMDEVICE);
+	if (unlikely(pci_dma_mapping_error(jme->pdev, mapping))) {
+		dev_kfree_skb(skb);
+		return -ENOMEM;
+	}
+
+	if (likely(rxbi->mapping))
+		pci_unmap_page(jme->pdev, rxbi->mapping,
+			       rxbi->len, PCI_DMA_FROMDEVICE);
+
 	rxbi->skb = skb;
 	rxbi->len = skb_tailroom(skb);
-	rxbi->mapping = pci_map_page(jme->pdev,
-					virt_to_page(skb->data),
-					offset_in_page(skb->data),
-					rxbi->len,
-					PCI_DMA_FROMDEVICE);
-
+	rxbi->mapping = mapping;
 	return 0;
 }
 
-- 
1.7.3.4

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
