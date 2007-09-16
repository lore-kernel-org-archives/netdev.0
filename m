From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 2/3] Blackfin EMAC driver: add power management interface
	and change the bf537mac_reset to bf537mac_disable
Date: Sun, 16 Sep 2007 10:57:33 +0800
Message-ID: <1189911453.9901.6.camel@roc-laptop>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:6038 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbXIPC5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 22:57:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 8d61ca9..3015385 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -677,7 +677,7 @@ static void bf537mac_poll(struct net_device *dev)
 }
 #endif				/* CONFIG_NET_POLL_CONTROLLER */
 
-static void bf537mac_reset(void)
+static void bf537mac_disable(void)
 {
 	unsigned int opmode;
 
@@ -735,7 +735,7 @@ static void bf537mac_timeout(struct net_device *dev)
 {
 	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
 
-	bf537mac_reset();
+	bf537mac_disable();
 
 	/* reset tx queue */
 	tx_list_tail = tx_list_head->next;
@@ -829,7 +829,7 @@ static int bf537mac_open(struct net_device *dev)
 
 	bf537mac_setphy(dev);
 	setup_system_regs(dev);
-	bf537mac_reset();
+	bf537mac_disable();
 	bf537mac_enable(dev);
 
 	pr_debug("hardware init finished\n");
@@ -989,15 +989,30 @@ static int bfin_mac_remove(struct platform_device *pdev)
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

