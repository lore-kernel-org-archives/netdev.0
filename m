From: leitao@linux.vnet.ibm.com
Subject: [PATCH] qlge: Fix a deadlock when the interface is going down
Date: Tue, 24 Aug 2010 19:50:40 -0300
Message-ID: <1282690240-5301-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:40894 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216Ab0HXWuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 18:50:46 -0400
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id o7OMl1RZ015838
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 19:47:01 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7OMuGWq1962058
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 19:56:17 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7OMoQ4Z004991
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 19:50:26 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently qlge can deadlock when the interface is going
down, and the mpi_port_cfg_work() is executing on another
processor. It happens because unregister_netdev() holds
the rtnl lock, and the mpi_port_cfg_work() also request
this lock.

Since unregiter_netdev() may wait mpi_port_cfg_work(), who
also request the holding lock, it can cause an deadlock,
displaying the following error:

 "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
 rmmod         D 00000080c6c1d190     0  3993   2081 0x00008080
 Call Trace:
 [c000000975f56ee0] [c0000000000152a0] .__switch_to+0x100/0x1d0
 [c000000975f56f70] [c0000000005781b4] .schedule+0x3a4/0x8c0
 [c000000975f570c0] [c000000000578e8c] .schedule_timeout+0x24c/0x350
 [c000000975f571e0] [c000000000578a88] .wait_for_common+0x198/0x210
 [c000000975f572c0] [c0000000000abbb4] .__cancel_work_timer+0x2c4/0x2e0
 [c000000975f57400] [d0000000078e7a20] .ql_adapter_down+0x80/0x260 [qlge]
 [c000000975f574b0] [d0000000078e7d80] .qlge_close+0x70/0x130 [qlge]
 [c000000975f57540] [c000000000497ef8] .__dev_close+0x98/0xf0
 [c000000975f575d0] [c000000000497f74] .dev_close+0x24/0x60
 [c000000975f57650] [c000000000498080] .rollback_registered_many+0xd0/0x2b0
 [c000000975f576f0] [c000000000498338] .rollback_registered+0x38/0x50
 [c000000975f57780] [c0000000004983d8] .unregister_netdevice_queue+0x88/0xe0
 [c000000975f57810] [c000000000498574] .unregister_netdev+0x24/0x40
 [c000000975f57890] [d0000000078f6f38] .qlge_remove+0x3c/0x78 [qlge]
 [c000000975f57920] [c0000000002d9298] .pci_device_remove+0x48/0x90
 [c000000975f579a0] [c000000000372850] .__device_release_driver+0xa0/0x130
 [c000000975f57a30] [c000000000372a08] .driver_detach+0x128/0x150
 [c000000975f57ad0] [c000000000371134] .bus_remove_driver+0xc4/0x1a0
 [c000000975f57b70] [c00000000037357c] .driver_unregister+0x8c/0xd0
 [c000000975f57c00] [c0000000002d968c] .pci_unregister_driver+0x5c/0x110
 [c000000975f57ca0] [d0000000078f6ee4] .qlge_exit+0x1c/0x34 [qlge]

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/qlge/qlge_main.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c9f9754..5a24521 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3889,11 +3889,8 @@ int ql_wol(struct ql_adapter *qdev)
 	return status;
 }
 
-static int ql_adapter_down(struct ql_adapter *qdev)
+static void ql_cancel_all_work_sync(struct ql_adapter *qdev)
 {
-	int i, status = 0;
-
-	ql_link_off(qdev);
 
 	/* Don't kill the reset worker thread if we
 	 * are in the process of recovery.
@@ -3905,6 +3902,15 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
 	cancel_delayed_work_sync(&qdev->mpi_core_to_log);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
+}
+
+static int ql_adapter_down(struct ql_adapter *qdev)
+{
+	int i, status = 0;
+
+	ql_link_off(qdev);
+
+	ql_cancel_all_work_sync(qdev);
 
 	for (i = 0; i < qdev->rss_ring_count; i++)
 		napi_disable(&qdev->rx_ring[i].napi);
@@ -4727,6 +4733,7 @@ static void __devexit qlge_remove(struct pci_dev *pdev)
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	del_timer_sync(&qdev->timer);
+	ql_cancel_all_work_sync(qdev);
 	unregister_netdev(ndev);
 	ql_release_all(pdev);
 	pci_disable_device(pdev);
@@ -4746,13 +4753,7 @@ static void ql_eeh_close(struct net_device *ndev)
 
 	/* Disabling the timer */
 	del_timer_sync(&qdev->timer);
-	if (test_bit(QL_ADAPTER_UP, &qdev->flags))
-		cancel_delayed_work_sync(&qdev->asic_reset_work);
-	cancel_delayed_work_sync(&qdev->mpi_reset_work);
-	cancel_delayed_work_sync(&qdev->mpi_work);
-	cancel_delayed_work_sync(&qdev->mpi_idc_work);
-	cancel_delayed_work_sync(&qdev->mpi_core_to_log);
-	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
+	ql_cancel_all_work_sync(qdev);
 
 	for (i = 0; i < qdev->rss_ring_count; i++)
 		netif_napi_del(&qdev->rx_ring[i].napi);
-- 
1.6.5.2

