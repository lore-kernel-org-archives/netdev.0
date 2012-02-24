From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 1/5] be2net: cancel be_worker during EEH recovery
Date: Fri, 24 Feb 2012 10:20:13 +0530
Message-ID: <1330059017-5976-2-git-send-email-sathya.perla@emulex.com>
References: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:20274 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755680Ab2BXEzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 23:55:42 -0500
In-Reply-To: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEH recovery involves ring cleanup and re-creation. The worker
thread must not run during EEH cleanup/resume.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |   13 ++++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 86f51de..4b1994d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -304,6 +304,7 @@ struct be_vf_cfg {
 };
 
 #define BE_FLAGS_LINK_STATUS_INIT		1
+#define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
 
 struct be_adapter {
 	struct pci_dev *pdev;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 28f2b25..68408d5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2447,6 +2447,11 @@ static void be_vf_clear(struct be_adapter *adapter)
 
 static int be_clear(struct be_adapter *adapter)
 {
+	if (adapter->flags & BE_FLAGS_WORKER_SCHEDULED) {
+		cancel_delayed_work_sync(&adapter->work);
+		adapter->flags &= ~BE_FLAGS_WORKER_SCHEDULED;
+	}
+
 	if (sriov_enabled(adapter))
 		be_vf_clear(adapter);
 
@@ -2648,6 +2653,9 @@ static int be_setup(struct be_adapter *adapter)
 			goto err;
 	}
 
+	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
+	adapter->flags |= BE_FLAGS_WORKER_SCHEDULED;
+
 	return 0;
 err:
 	be_clear(adapter);
@@ -3208,8 +3216,6 @@ static void __devexit be_remove(struct pci_dev *pdev)
 	if (!adapter)
 		return;
 
-	cancel_delayed_work_sync(&adapter->work);
-
 	unregister_netdev(adapter->netdev);
 
 	be_clear(adapter);
@@ -3533,7 +3539,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	dev_info(&pdev->dev, "%s: %s port %d\n", netdev->name, nic_name(pdev),
 		adapter->port_num);
 
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 
 unsetup:
@@ -3563,7 +3568,6 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev =  adapter->netdev;
 
-	cancel_delayed_work_sync(&adapter->work);
 	if (adapter->wol)
 		be_setup_wol(adapter, true);
 
@@ -3612,7 +3616,6 @@ static int be_resume(struct pci_dev *pdev)
 	if (adapter->wol)
 		be_setup_wol(adapter, false);
 
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 }
 
-- 
1.7.4
