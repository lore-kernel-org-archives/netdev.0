From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/10] tg3: Allow single MSI-X vector
 allocations
Date: Sat, 5 Jun 2010 20:24:34 -0700
Message-ID: <1275794679-11085-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4676 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933985Ab0FFDYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the code to make it legal to allocate only one MSI-X
vector.  It also fixes a bug where the driver was not checking for error
return codes from pci_enable_msix().

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3dccc58..d169337 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -145,8 +145,6 @@
 #define TG3_RX_JMB_BUFF_RING_SIZE \
 	(sizeof(struct ring_info) * TG3_RX_JUMBO_RING_SIZE)
 
-#define TG3_RSS_MIN_NUM_MSIX_VECS	2
-
 /* Due to a hardware bug, the 5701 can only DMA to memory addresses
  * that are at least dword aligned when used in PCIX mode.  The driver
  * works around this bug by double copying the packet.  This workaround
@@ -8797,9 +8795,9 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	}
 
 	rc = pci_enable_msix(tp->pdev, msix_ent, tp->irq_cnt);
-	if (rc != 0) {
-		if (rc < TG3_RSS_MIN_NUM_MSIX_VECS)
-			return false;
+	if (rc < 0) {
+		return false;
+	} else if (rc != 0) {
 		if (pci_enable_msix(tp->pdev, msix_ent, rc))
 			return false;
 		netdev_notice(tp->dev, "Requested %d MSI-X vectors, received %d\n",
@@ -8807,16 +8805,18 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		tp->irq_cnt = rc;
 	}
 
-	tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
-
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].irq_vec = msix_ent[i].vector;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
-		tp->tg3_flags3 |= TG3_FLG3_ENABLE_TSS;
-		tp->dev->real_num_tx_queues = tp->irq_cnt - 1;
-	} else
-		tp->dev->real_num_tx_queues = 1;
+	tp->dev->real_num_tx_queues = 1;
+	if (tp->irq_cnt > 1) {
+		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+			tp->tg3_flags3 |= TG3_FLG3_ENABLE_TSS;
+			tp->dev->real_num_tx_queues = tp->irq_cnt - 1;
+		}
+	}
 
 	return true;
 }
-- 
1.6.4.4


