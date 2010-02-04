From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 3/3] qlge: Add watchdog timer.
Date: Thu, 4 Feb 2010 12:06:03 -0800
Message-ID: <20100204200603.GB9938@linux-ox1b.qlogic.org>
References: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com> <1265217853-26959-4-git-send-email-ron.mercer@qlogic.com> <20100203.193222.64773800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23219 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865Ab0BDUM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 15:12:58 -0500
Content-Disposition: inline
In-Reply-To: <20100203.193222.64773800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 81cc7ea1ce2b906a29ad250daeb120101b70f4f1 Mon Sep 17 00:00:00 2001
From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 4 Feb 2010 11:54:37 -0800
Subject: [net-next PATCH 1/1] qlge: Add watchdog timer.

Add deferred timer for 5-second periodic heartbeat register read to
trigger the eeh recovery process.
We see cases where an eeh error was injected and the slot was
suspended.  An asic access attempt is required to flush the recovery process,
but without interrupts the process can stall.
Adding this periodic register read causes the recovery process to begin.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |   27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 780a387..ebfd177 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2145,6 +2145,7 @@ struct ql_adapter {
 	struct completion ide_completion;
 	struct nic_operations *nic_ops;
 	u16 device_id;
+	struct timer_list timer;
 	atomic_t lb_count;
 };
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 7e00029..f1fc3a8 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4574,6 +4574,20 @@ static const struct net_device_ops qlge_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= qlge_vlan_rx_kill_vid,
 };
 
+static void ql_timer(unsigned long data)
+{
+	struct ql_adapter *qdev = (struct ql_adapter *)data;
+	u32 var = 0;
+
+	var = ql_read32(qdev, STS);
+	if (pci_channel_offline(qdev->pdev)) {
+		QPRINTK(qdev, IFUP, ERR, "EEH STS = 0x%.08x.\n", var);
+		return;
+	}
+
+	add_timer(&qdev->timer);
+}
+
 static int __devinit qlge_probe(struct pci_dev *pdev,
 				const struct pci_device_id *pci_entry)
 {
@@ -4625,6 +4639,14 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 		pci_disable_device(pdev);
 		return err;
 	}
+	/* Start up the timer to trigger EEH if
+	 * the bus goes dead
+	 */
+	init_timer_deferrable(&qdev->timer);
+	qdev->timer.data = (unsigned long)qdev;
+	qdev->timer.function = ql_timer;
+	qdev->timer.expires = jiffies + (5*HZ);
+	add_timer(&qdev->timer);
 	ql_link_off(qdev);
 	ql_display_dev_info(ndev);
 	atomic_set(&qdev->lb_count, 0);
@@ -4645,6 +4667,8 @@ int ql_clean_lb_rx_ring(struct rx_ring *rx_ring, int budget)
 static void __devexit qlge_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
+	struct ql_adapter *qdev = netdev_priv(ndev);
+	del_timer_sync(&qdev->timer);
 	unregister_netdev(ndev);
 	ql_release_all(pdev);
 	pci_disable_device(pdev);
@@ -4757,6 +4781,7 @@ static void qlge_io_resume(struct pci_dev *pdev)
 		QPRINTK(qdev, IFUP, ERR,
 			"Device was not running prior to EEH.\n");
 	}
+	add_timer(&qdev->timer);
 	netif_device_attach(ndev);
 }
 
@@ -4773,6 +4798,7 @@ static int qlge_suspend(struct pci_dev *pdev, pm_message_t state)
 	int err;
 
 	netif_device_detach(ndev);
+	del_timer_sync(&qdev->timer);
 
 	if (netif_running(ndev)) {
 		err = ql_adapter_down(qdev);
@@ -4817,6 +4843,7 @@ static int qlge_resume(struct pci_dev *pdev)
 			return err;
 	}
 
+	add_timer(&qdev->timer);
 	netif_device_attach(ndev);
 
 	return 0;
-- 
1.6.0.2

