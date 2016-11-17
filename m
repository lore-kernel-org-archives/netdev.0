From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH] net: sky2: Fix shutdown crash
Date: Thu, 17 Nov 2016 09:14:25 -0600
Message-ID: <1479395665-27784-1-git-send-email-jeremy.linton@arm.com>
Cc: mlindner@marvell.com, stephen@networkplumber.org,
        Sudeep.Holla@arm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:57654 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941552AbcKQRmV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:42:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sky2 frequently crashes during machine shutdown with:

sky2_get_stats+0x60/0x3d8 [sky2]
dev_get_stats+0x68/0xd8
rtnl_fill_stats+0x54/0x140
rtnl_fill_ifinfo+0x46c/0xc68
rtmsg_ifinfo_build_skb+0x7c/0xf0
rtmsg_ifinfo.part.22+0x3c/0x70
rtmsg_ifinfo+0x50/0x5c
netdev_state_change+0x4c/0x58
linkwatch_do_dev+0x50/0x88
__linkwatch_run_queue+0x104/0x1a4
linkwatch_event+0x30/0x3c
process_one_work+0x140/0x3e0
worker_thread+0x60/0x44c
kthread+0xdc/0xf0
ret_from_fork+0x10/0x50

This is caused by the sky2 being called after it has been shutdown.
A previous thread about this can be found here:

https://lkml.org/lkml/2016/4/12/410

An alternative fix is to assure that IFF_UP gets cleared by
calling dev_close() during shutdown. This is similar to what the
bnx2/tg3/xgene and maybe others are doing to assure that the driver
isn't being called following _shutdown().

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/marvell/sky2.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index f05ea56..941c8e2 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -5220,6 +5220,19 @@ static SIMPLE_DEV_PM_OPS(sky2_pm_ops, sky2_suspend, sky2_resume);
 
 static void sky2_shutdown(struct pci_dev *pdev)
 {
+	struct sky2_hw *hw = pci_get_drvdata(pdev);
+	int port;
+
+	for (port = 0; port < hw->ports; port++) {
+		struct net_device *ndev = hw->dev[port];
+
+		rtnl_lock();
+		if (netif_running(ndev)) {
+			dev_close(ndev);
+			netif_device_detach(ndev);
+		}
+		rtnl_unlock();
+	}
 	sky2_suspend(&pdev->dev);
 	pci_wake_from_d3(pdev, device_may_wakeup(&pdev->dev));
 	pci_set_power_state(pdev, PCI_D3hot);
-- 
2.5.5
