From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/20] tg3: Create tg3_poll_msix() for non-zero MSIX
 vecs
Date: Fri, 13 Nov 2009 15:03:41 -0800
Message-ID: <1258153432-7036-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3239 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932467AbZKMXEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gives all non-zero MSIX vectors their own NAPI handler.  This
will make NAPI handling for those vectors slightly more efficient.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   68 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 60 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1c1cf68..5e17abb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4706,18 +4706,17 @@ next_pkt_nopost:
 	return received;
 }
 
-static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
+static void tg3_poll_link(struct tg3 *tp)
 {
-	struct tg3 *tp = tnapi->tp;
-	struct tg3_hw_status *sblk = tnapi->hw_status;
-
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
 	      (TG3_FLAG_USE_LINKCHG_REG |
 	       TG3_FLAG_POLL_SERDES))) {
+		struct tg3_hw_status *sblk = tp->napi[0].hw_status;
+
 		if (sblk->status & SD_STATUS_LINK_CHG) {
 			sblk->status = SD_STATUS_UPDATED |
-				(sblk->status & ~SD_STATUS_LINK_CHG);
+				       (sblk->status & ~SD_STATUS_LINK_CHG);
 			spin_lock(&tp->lock);
 			if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 				tw32_f(MAC_STATUS,
@@ -4731,6 +4730,11 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 			spin_unlock(&tp->lock);
 		}
 	}
+}
+
+static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
+{
+	struct tg3 *tp = tnapi->tp;
 
 	/* run TX completion thread */
 	if (tnapi->hw_status->idx[0].tx_consumer != tnapi->tx_cons) {
@@ -4749,6 +4753,50 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	return work_done;
 }
 
+static int tg3_poll_msix(struct napi_struct *napi, int budget)
+{
+	struct tg3_napi *tnapi = container_of(napi, struct tg3_napi, napi);
+	struct tg3 *tp = tnapi->tp;
+	int work_done = 0;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
+
+	while (1) {
+		work_done = tg3_poll_work(tnapi, work_done, budget);
+
+		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
+			goto tx_recovery;
+
+		if (unlikely(work_done >= budget))
+			break;
+
+		/* tp->last_tag is used in tg3_restart_ints() below
+		 * to tell the hw how much work has been processed,
+		 * so we must read it before checking for more work.
+		 */
+		tnapi->last_tag = sblk->status_tag;
+		tnapi->last_irq_tag = tnapi->last_tag;
+		rmb();
+
+		/* check for RX/TX work to do */
+		if (sblk->idx[0].tx_consumer == tnapi->tx_cons &&
+		    *(tnapi->rx_rcb_prod_idx) == tnapi->rx_rcb_ptr) {
+			napi_complete(napi);
+			/* Reenable interrupts. */
+			tw32_mailbox(tnapi->int_mbox, tnapi->last_tag << 24);
+			mmiowb();
+			break;
+		}
+	}
+
+	return work_done;
+
+tx_recovery:
+	/* work_done is guaranteed to be less than budget. */
+	napi_complete(napi);
+	schedule_work(&tp->reset_task);
+	return work_done;
+}
+
 static int tg3_poll(struct napi_struct *napi, int budget)
 {
 	struct tg3_napi *tnapi = container_of(napi, struct tg3_napi, napi);
@@ -4757,6 +4805,8 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 	struct tg3_hw_status *sblk = tnapi->hw_status;
 
 	while (1) {
+		tg3_poll_link(tp);
+
 		work_done = tg3_poll_work(tnapi, work_done, budget);
 
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
@@ -14057,10 +14107,13 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tnapi->consmbox = rcvmbx;
 		tnapi->prodmbox = sndmbx;
 
-		if (i)
+		if (i) {
 			tnapi->coal_now = HOSTCC_MODE_COAL_VEC1_NOW << (i - 1);
-		else
+			netif_napi_add(dev, &tnapi->napi, tg3_poll_msix, 64);
+		} else {
 			tnapi->coal_now = HOSTCC_MODE_NOW;
+			netif_napi_add(dev, &tnapi->napi, tg3_poll, 64);
+		}
 
 		if (!(tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX))
 			break;
@@ -14083,7 +14136,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 			sndmbx += 0xc;
 	}
 
-	netif_napi_add(dev, &tp->napi[0].napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->irq = pdev->irq;
-- 
1.6.4.4


