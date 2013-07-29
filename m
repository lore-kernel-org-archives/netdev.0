From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 3/6] tg3: Implement the shutdown handler
Date: Mon, 29 Jul 2013 13:58:37 -0700
Message-ID: <1375131520-1746-4-git-send-email-nsujir@broadcom.com>
References: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2530 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825Ab3G2U6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 16:58:52 -0400
In-Reply-To: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove the call to tg3_power_down_prepare() in tg3_power_down()
since tg3_close() calls it.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ec244c9..9351707 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4226,8 +4226,6 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 static void tg3_power_down(struct tg3 *tp)
 {
-	tg3_power_down_prepare(tp);
-
 	pci_wake_from_d3(tp->pdev, tg3_flag(tp, WOL_ENABLE));
 	pci_set_power_state(tp->pdev, PCI_D3hot);
 }
@@ -17743,6 +17741,23 @@ out:
 
 static SIMPLE_DEV_PM_OPS(tg3_pm_ops, tg3_suspend, tg3_resume);
 
+static void tg3_shutdown(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tg3 *tp = netdev_priv(dev);
+
+	rtnl_lock();
+	netif_device_detach(dev);
+
+	if (netif_running(dev))
+		dev_close(dev);
+
+	if (system_state == SYSTEM_POWER_OFF)
+		tg3_power_down(tp);
+
+	rtnl_unlock();
+}
+
 /**
  * tg3_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
@@ -17898,6 +17913,7 @@ static struct pci_driver tg3_driver = {
 	.remove		= tg3_remove_one,
 	.err_handler	= &tg3_err_handler,
 	.driver.pm	= &tg3_pm_ops,
+	.shutdown	= tg3_shutdown,
 };
 
 module_pci_driver(tg3_driver);
-- 
1.8.1.4
