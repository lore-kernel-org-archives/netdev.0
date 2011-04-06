From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH] be2net: Fix a potential crash during shutdown.
Date: Wed, 6 Apr 2011 10:53:13 -0500
Message-ID: <20110406155313.GA2246@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:45021 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756325Ab1DFPxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 11:53:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adapter could remain uninitialized if probe fails for some reason.
A null pointer access could cause a crash if be_shutdown
is called after that.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a71163f..6e8e211 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3141,12 +3141,14 @@ static int be_resume(struct pci_dev *pdev)
 static void be_shutdown(struct pci_dev *pdev)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev =  adapter->netdev;
 
-	if (netif_running(netdev))
+	if (!adapter)
+		return;
+
+	if (netif_running(adapter->netdev))
 		cancel_delayed_work_sync(&adapter->work);
 
-	netif_device_detach(netdev);
+	netif_device_detach(adapter->netdev);
 
 	be_cmd_reset_function(adapter);
 
-- 
1.7.1

