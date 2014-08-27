From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] tg3: prevent ifup/ifdown during PCI error recovery
Date: Wed, 27 Aug 2014 15:01:32 +0200
Message-ID: <1409144492-22790-1-git-send-email-ivecera@redhat.com>
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932179AbaH0N3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 09:29:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes race conditions between PCI error recovery callbacks and
potential ifup/ifdown.

First, if ifup (tg3_open) is called between tg3_io_error_detected() and
tg3_io_resume() then tp->timer is armed twice before expiry. Once during
tg3_open() and again during tg3_io_resume(). This results in BUG
at kernel/time/timer.c:945.

Second, if ifdown (tg3_close) is called between tg3_io_error_detected()
and tg3_io_resume() then tg3_napi_disable() is called twice without
a tg3_napi_enable between. Once during tg3_io_error_detected() and again
during tg3_close(). The tg3_io_resume() then hangs on rtnl_lock().

Cc: Prashant Sreedharan <prashant@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 10 ++++++++++
 drivers/net/ethernet/broadcom/tg3.h |  1 +
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3ac5d23..8d9c774 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11617,6 +11617,9 @@ static int tg3_open(struct net_device *dev)
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
+	if (tp->pcierr_recovery)
+		return -EAGAIN;
+
 	if (tp->fw_needed) {
 		err = tg3_request_firmware(tp);
 		if (tg3_asic_rev(tp) == ASIC_REV_57766) {
@@ -11674,6 +11677,9 @@ static int tg3_close(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	if (tp->pcierr_recovery)
+		return -EAGAIN;
+
 	tg3_ptp_fini(tp);
 
 	tg3_stop(tp);
@@ -17561,6 +17567,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 	tp->rx_mode = TG3_DEF_RX_MODE;
 	tp->tx_mode = TG3_DEF_TX_MODE;
 	tp->irq_sync = 1;
+	tp->pcierr_recovery = false;
 
 	if (tg3_debug > 0)
 		tp->msg_enable = tg3_debug;
@@ -18071,6 +18078,8 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 
 	rtnl_lock();
 
+	tp->pcierr_recovery = true;
+
 	/* We probably don't have netdev yet */
 	if (!netdev || !netif_running(netdev))
 		goto done;
@@ -18195,6 +18204,7 @@ static void tg3_io_resume(struct pci_dev *pdev)
 	tg3_phy_start(tp);
 
 done:
+	tp->pcierr_recovery = false;
 	rtnl_unlock();
 }
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 461acca..31c9f82 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3407,6 +3407,7 @@ struct tg3 {
 
 	struct device			*hwmon_dev;
 	bool				link_up;
+	bool				pcierr_recovery;
 };
 
 /* Accessor macros for chip and asic attributes
-- 
1.8.5.5
