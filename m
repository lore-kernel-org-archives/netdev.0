From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 01/12] tg3: Enforce DMA mapping / skb
 assignment ordering
Date: Wed, 17 Feb 2010 17:16:54 -0800
Message-ID: <1266455825-16150-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3246 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754591Ab0BRBR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan noted that there is nothing in the code that would prevent
the compiler from delaying the access of the "mapping" member of the
newly arrived packet until much later.  If this happened after the
skb = NULL assignment, it is possible for the driver to pass a bad
dma_addr value to pci_unmap_single().  To enforce this ordering, we need
a write memory barrier.  The pairing read memory barrier already exists
in tg3_rx_prodring_xfer() under the comments starting with
"Ensure that updates to the...".

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 385434f..344490e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4659,11 +4659,16 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			if (skb_size < 0)
 				goto drop_it;

-			ri->skb = NULL;
-
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);

+			/* Ensure that the update to the skb happens
+			 * after the usage of the old DMA mapping.
+			 */
+			smp_wmb();
+
+			ri->skb = NULL;
+
 			skb_put(skb, len);
 		} else {
 			struct sk_buff *copy_skb;
--
1.6.4.4
---
 drivers/net/tg3.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 385434f..344490e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4659,11 +4659,16 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			if (skb_size < 0)
 				goto drop_it;
 
-			ri->skb = NULL;
-
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
 
+			/* Ensure that the update to the skb happens
+			 * after the usage of the old DMA mapping.
+			 */
+			smp_wmb();
+
+			ri->skb = NULL;
+
 			skb_put(skb, len);
 		} else {
 			struct sk_buff *copy_skb;
-- 
1.6.4.4


