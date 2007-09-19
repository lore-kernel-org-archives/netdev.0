From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 2/4] Blackfin EMAC driver: add power management interface
	and change the bf537mac_reset to bf537mac_disable
Date: Wed, 19 Sep 2007 23:37:14 +0800
Message-ID: <1190216234.15707.28.camel@roc-laptop>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760862AbXISPnh@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Bryan Wu <bryan.wu@analog.com>
Acked-by: Jeff Garzik <jeff@garzik.org>
---
 drivers/net/bfin_mac.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index ead7be9..5cb4433 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -672,7 +672,7 @@ static void bf537mac_poll(struct net_device *dev)
 }
 #endif				/* CONFIG_NET_POLL_CONTROLLER */
 
-static void bf537mac_reset(void)
+static void bf537mac_disable(void)
 {
 	unsigned int opmode;
 
@@ -730,7 +730,7 @@ static void bf537mac_timeout(struct net_device *dev)
 {
 	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
 
-	bf537mac_reset();
+	bf537mac_disable();
 
 	/* reset tx queue */
 	tx_list_tail = tx_list_head->next;
@@ -810,7 +810,7 @@ static int bf537mac_open(struct net_device *dev)
 
 	bf537mac_setphy(dev);
 	setup_system_regs(dev);
-	bf537mac_reset();
+	bf537mac_disable();
 	bf537mac_enable(dev);
 
 	pr_debug("hardware init finished\n");
@@ -968,15 +968,30 @@ static int bfin_mac_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t state)
+#ifdef CONFIG_PM
+static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t mesg)
 {
+	struct net_device *net_dev = platform_get_drvdata(pdev);
+
+	if (netif_running(net_dev))
+		bf537mac_close(net_dev);
+
 	return 0;
 }
 
 static int bfin_mac_resume(struct platform_device *pdev)
 {
+	struct net_device *net_dev = platform_get_drvdata(pdev);
+
+	if (netif_running(net_dev))
+		bf537mac_open(net_dev);
+
 	return 0;
 }
+#else
+#define bfin_mac_suspend NULL
+#define bfin_mac_resume NULL
+#endif	/* CONFIG_PM */
 
 static struct platform_driver bfin_mac_driver = {
 	.probe = bfin_mac_probe,
-- 
1.5.2
