From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/9] tg3: Unwedge stuck MSI-X vectors
Date: Fri, 12 Feb 2010 16:47:07 -0800
Message-ID: <1266022033-3546-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2536 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755634Ab0BMArd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 19:47:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous patch changed the code so that new rx buffer submissions to
the hardware stall if a new submission would overwrite data needed by an
unserviced rx packet.  On very busy 5717 and 57765 asic rev devices,
there is a corner case where the hardware will fail to assert an MSI-X
interrupt for rx traffic.  If that vector's interrupt never has another
reason to assert, any rx buffers held will never be serviced.  If the
buffers are never serviced and the hardware consumes all the available
rx packets for other rx rings, deadlock will result.

The most reliable and least intrusive way to work around the problem is
to detect the case where new submissions would overwrite existing data
and force all rx interrupt vectors to fire.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   29 +++++++++++++++++++----------
 drivers/net/tg3.h |    1 +
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 115fb7c..e6ee291 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -642,7 +642,6 @@ static void tg3_disable_ints(struct tg3 *tp)
 static void tg3_enable_ints(struct tg3 *tp)
 {
 	int i;
-	u32 coal_now = 0;
 
 	tp->irq_sync = 0;
 	wmb();
@@ -650,13 +649,14 @@ static void tg3_enable_ints(struct tg3 *tp)
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     (tp->misc_host_ctrl & ~MISC_HOST_CTRL_MASK_PCI_INT));
 
+	tp->coal_now = tp->coalesce_mode | HOSTCC_MODE_ENABLE;
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 		tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 			tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 
-		coal_now |= tnapi->coal_now;
+		tp->coal_now |= tnapi->coal_now;
 	}
 
 	/* Force an initial interrupt */
@@ -664,8 +664,9 @@ static void tg3_enable_ints(struct tg3 *tp)
 	    (tp->napi[0].hw_status->status & SD_STATUS_UPDATED))
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
 	else
-		tw32(HOSTCC_MODE, tp->coalesce_mode |
-		     HOSTCC_MODE_ENABLE | coal_now);
+		tw32(HOSTCC_MODE, tp->coal_now);
+
+	tp->coal_now &= ~(tp->napi[0].coal_now | tp->napi[1].coal_now);
 }
 
 static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
@@ -4794,12 +4795,12 @@ static void tg3_poll_link(struct tg3 *tp)
 	}
 }
 
-static void tg3_rx_prodring_xfer(struct tg3 *tp,
-				 struct tg3_rx_prodring_set *dpr,
-				 struct tg3_rx_prodring_set *spr)
+static int tg3_rx_prodring_xfer(struct tg3 *tp,
+				struct tg3_rx_prodring_set *dpr,
+				struct tg3_rx_prodring_set *spr)
 {
 	u32 si, di, cpycnt, src_prod_idx;
-	int i;
+	int i, err = 0;
 
 	while (1) {
 		src_prod_idx = spr->rx_std_prod_idx;
@@ -4825,6 +4826,7 @@ static void tg3_rx_prodring_xfer(struct tg3 *tp,
 		for (i = di; i < di + cpycnt; i++) {
 			if (dpr->rx_std_buffers[i].skb) {
 				cpycnt = i - di;
+				err = -ENOSPC;
 				break;
 			}
 		}
@@ -4881,6 +4883,7 @@ static void tg3_rx_prodring_xfer(struct tg3 *tp,
 		for (i = di; i < di + cpycnt; i++) {
 			if (dpr->rx_jmb_buffers[i].skb) {
 				cpycnt = i - di;
+				err = -ENOSPC;
 				break;
 			}
 		}
@@ -4911,6 +4914,8 @@ static void tg3_rx_prodring_xfer(struct tg3 *tp,
 		dpr->rx_jmb_prod_idx = (dpr->rx_jmb_prod_idx + cpycnt) %
 				       TG3_RX_JUMBO_RING_SIZE;
 	}
+
+	return err;
 }
 
 static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
@@ -4933,12 +4938,13 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 
 	if ((tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS) && tnapi == &tp->napi[1]) {
 		struct tg3_rx_prodring_set *dpr = &tp->prodring[0];
-		int i;
+		int i, err = 0;
 		u32 std_prod_idx = dpr->rx_std_prod_idx;
 		u32 jmb_prod_idx = dpr->rx_jmb_prod_idx;
 
 		for (i = 1; i < tp->irq_cnt; i++)
-			tg3_rx_prodring_xfer(tp, dpr, tp->napi[i].prodring);
+			err |= tg3_rx_prodring_xfer(tp, dpr,
+						    tp->napi[i].prodring);
 
 		wmb();
 
@@ -4951,6 +4957,9 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 				     dpr->rx_jmb_prod_idx);
 
 		mmiowb();
+
+		if (err)
+			tw32_f(HOSTCC_MODE, tp->coal_now);
 	}
 
 	return work_done;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 88a87bb..cc8bf7d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2699,6 +2699,7 @@ struct tg3 {
 	struct net_device		*dev;
 	struct pci_dev			*pdev;
 
+	u32				coal_now;
 	u32				msg_enable;
 
 	/* begin "tx thread" cacheline section */
-- 
1.6.4.4


