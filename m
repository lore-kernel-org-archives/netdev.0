From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/8] tg3: Fix potential netpoll crash
Date: Thu, 30 Sep 2010 13:34:30 -0700
Message-ID: <1285878877-12148-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2216 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756612Ab0I3Uey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Up until now the tg3 driver would call netif_napi_add() for the maximum
number of NAPI instances the driver could use.  The problem is that
netpoll could call tg3_poll() on instances that are not active.  The net
effect is that the driver will crash attempting to dereference
uninitialized pointers.

The fix is to only allocate as many NAPI instances as the driver would
use in tg3_open() and deleted them in tg3_close().

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  111 +++++++++++++++++++++++++++++++----------------------
 1 files changed, 65 insertions(+), 46 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fdb438d..d64fec1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -752,42 +752,6 @@ static void tg3_int_reenable(struct tg3_napi *tnapi)
 		     HOSTCC_MODE_ENABLE | tnapi->coal_now);
 }
 
-static void tg3_napi_disable(struct tg3 *tp)
-{
-	int i;
-
-	for (i = tp->irq_cnt - 1; i >= 0; i--)
-		napi_disable(&tp->napi[i].napi);
-}
-
-static void tg3_napi_enable(struct tg3 *tp)
-{
-	int i;
-
-	for (i = 0; i < tp->irq_cnt; i++)
-		napi_enable(&tp->napi[i].napi);
-}
-
-static inline void tg3_netif_stop(struct tg3 *tp)
-{
-	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
-	tg3_napi_disable(tp);
-	netif_tx_disable(tp->dev);
-}
-
-static inline void tg3_netif_start(struct tg3 *tp)
-{
-	/* NOTE: unconditional netif_tx_wake_all_queues is only
-	 * appropriate so long as all callers are assured to
-	 * have free tx slots (such as after tg3_init_hw)
-	 */
-	netif_tx_wake_all_queues(tp->dev);
-
-	tg3_napi_enable(tp);
-	tp->napi[0].hw_status->status |= SD_STATUS_UPDATED;
-	tg3_enable_ints(tp);
-}
-
 static void tg3_switch_clocks(struct tg3 *tp)
 {
 	u32 clock_ctrl;
@@ -4338,6 +4302,11 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 	return err;
 }
 
+static inline int tg3_irq_sync(struct tg3 *tp)
+{
+	return tp->irq_sync;
+}
+
 /* This is called whenever we suspect that the system chipset is re-
  * ordering the sequence of MMIO to the tx send mailbox. The symptom
  * is bogus tx completions. We try to recover by setting the
@@ -5083,6 +5052,59 @@ tx_recovery:
 	return work_done;
 }
 
+static void tg3_napi_disable(struct tg3 *tp)
+{
+	int i;
+
+	for (i = tp->irq_cnt - 1; i >= 0; i--)
+		napi_disable(&tp->napi[i].napi);
+}
+
+static void tg3_napi_enable(struct tg3 *tp)
+{
+	int i;
+
+	for (i = 0; i < tp->irq_cnt; i++)
+		napi_enable(&tp->napi[i].napi);
+}
+
+static void tg3_napi_init(struct tg3 *tp)
+{
+	int i;
+
+	netif_napi_add(tp->dev, &tp->napi[0].napi, tg3_poll, 64);
+	for (i = 1; i < tp->irq_cnt; i++)
+		netif_napi_add(tp->dev, &tp->napi[i].napi, tg3_poll_msix, 64);
+}
+
+static void tg3_napi_fini(struct tg3 *tp)
+{
+	int i;
+
+	for (i = 0; i < tp->irq_cnt; i++)
+		netif_napi_del(&tp->napi[i].napi);
+}
+
+static inline void tg3_netif_stop(struct tg3 *tp)
+{
+	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	tg3_napi_disable(tp);
+	netif_tx_disable(tp->dev);
+}
+
+static inline void tg3_netif_start(struct tg3 *tp)
+{
+	/* NOTE: unconditional netif_tx_wake_all_queues is only
+	 * appropriate so long as all callers are assured to
+	 * have free tx slots (such as after tg3_init_hw)
+	 */
+	netif_tx_wake_all_queues(tp->dev);
+
+	tg3_napi_enable(tp);
+	tp->napi[0].hw_status->status |= SD_STATUS_UPDATED;
+	tg3_enable_ints(tp);
+}
+
 static void tg3_irq_quiesce(struct tg3 *tp)
 {
 	int i;
@@ -5096,11 +5118,6 @@ static void tg3_irq_quiesce(struct tg3 *tp)
 		synchronize_irq(tp->napi[i].irq_vec);
 }
 
-static inline int tg3_irq_sync(struct tg3 *tp)
-{
-	return tp->irq_sync;
-}
-
 /* Fully shutdown all tg3 driver activity elsewhere in the system.
  * If irq_sync is non-zero, then the IRQ handler must be synchronized
  * with as well.  Most of the time, this is not necessary except when
@@ -8915,6 +8932,8 @@ static int tg3_open(struct net_device *dev)
 	if (err)
 		goto err_out1;
 
+	tg3_napi_init(tp);
+
 	tg3_napi_enable(tp);
 
 	for (i = 0; i < tp->irq_cnt; i++) {
@@ -9002,6 +9021,7 @@ err_out3:
 
 err_out2:
 	tg3_napi_disable(tp);
+	tg3_napi_fini(tp);
 	tg3_free_consistent(tp);
 
 err_out1:
@@ -9049,6 +9069,8 @@ static int tg3_close(struct net_device *dev)
 	memcpy(&tp->estats_prev, tg3_get_estats(tp),
 	       sizeof(tp->estats_prev));
 
+	tg3_napi_fini(tp);
+
 	tg3_free_consistent(tp);
 
 	tg3_set_power_state(tp, PCI_D3hot);
@@ -14599,13 +14621,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tnapi->consmbox = rcvmbx;
 		tnapi->prodmbox = sndmbx;
 
-		if (i) {
+		if (i)
 			tnapi->coal_now = HOSTCC_MODE_COAL_VEC1_NOW << (i - 1);
-			netif_napi_add(dev, &tnapi->napi, tg3_poll_msix, 64);
-		} else {
+		else
 			tnapi->coal_now = HOSTCC_MODE_NOW;
-			netif_napi_add(dev, &tnapi->napi, tg3_poll, 64);
-		}
 
 		if (!(tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX))
 			break;
-- 
1.7.2.2


