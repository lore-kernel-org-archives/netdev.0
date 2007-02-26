From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 06/13] qla3xxx: Remove API to change MTU.
Date: Mon, 26 Feb 2007 11:06:36 -0800
Message-ID: <11725168032636-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030457AbXBZTHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:44 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This network device driver shares the same hardware as the qla4xxx
iSCSI driver. Changing the MTU via the device interface will
cause qla4xxx to crash as there is no way to make notification.
Users wishing to change the MTU must do so using an iSCSI
utility such as Qlogic SanSurfer. This forces the user to
unload/reload this network device driver after the MTU
value has been changed in flash.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 59cebd6..b86cef0 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3372,27 +3372,6 @@ static struct net_device_stats *ql3xxx_get_stats(struct net_device *dev)
 	return &qdev->stats;
 }
 
-static int ql3xxx_change_mtu(struct net_device *ndev, int new_mtu)
-{
-	struct ql3_adapter *qdev = netdev_priv(ndev);
-	printk(KERN_ERR PFX "%s:  new mtu size = %d.\n", ndev->name, new_mtu);
-	if (new_mtu != NORMAL_MTU_SIZE && new_mtu != JUMBO_MTU_SIZE) {
-		printk(KERN_ERR PFX
-		       "%s: mtu size of %d is not valid.  Use exactly %d or "
-		       "%d.\n", ndev->name, new_mtu, NORMAL_MTU_SIZE,
-		       JUMBO_MTU_SIZE);
-		return -EINVAL;
-	}
-
-	if (!netif_running(ndev)) {
-		ndev->mtu = new_mtu;
-		return 0;
-	}
-
-	ndev->mtu = new_mtu;
-	return ql_cycle_adapter(qdev,QL_DO_RESET);
-}
-
 static void ql3xxx_set_multicast_list(struct net_device *ndev)
 {
 	/*
@@ -3684,7 +3663,6 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	ndev->hard_start_xmit = ql3xxx_send;
 	ndev->stop = ql3xxx_close;
 	ndev->get_stats = ql3xxx_get_stats;
-	ndev->change_mtu = ql3xxx_change_mtu;
 	ndev->set_multicast_list = ql3xxx_set_multicast_list;
 	SET_ETHTOOL_OPS(ndev, &ql3xxx_ethtool_ops);
 	ndev->set_mac_address = ql3xxx_set_mac_address;
@@ -3709,9 +3687,11 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	/* Validate and set parameters */
 	if (qdev->mac_index) {
+		ndev->mtu = qdev->nvram_data.macCfg_port1.etherMtu_mac ;
 		memcpy(ndev->dev_addr, &qdev->nvram_data.funcCfg_fn2.macAddress,
 		       ETH_ALEN);
 	} else {
+		ndev->mtu = qdev->nvram_data.macCfg_port0.etherMtu_mac ;
 		memcpy(ndev->dev_addr, &qdev->nvram_data.funcCfg_fn0.macAddress,
 		       ETH_ALEN);
 	}
-- 
1.5.0.rc4.16.g9e258

