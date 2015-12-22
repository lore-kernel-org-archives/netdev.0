From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] fm10k: Cleanup exception handling for changing queues
Date: Tue, 22 Dec 2015 06:02:05 -0800
Message-ID: <1450792932-96015-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29757 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490AbbLVODO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:14 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch is meant to cleanup the exception handling for the paths where
we reset the interrupts and then reconfigure them.  In all of these paths
we had very different levels of exception handling.  I have updated the
driver so that all of the paths should result in a similar state if we
fail.

Specifically the driver will now unload the mailbox interrupt, free the
queue vectors and MSI-X, and then detach the interface.

In addition for any of the PCIe related resets I have added a check with
the hw_ready function to just make sure the registers are in a readable
state prior to reopening the interface.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 22 ++++++++--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 53 +++++++++++++++++++------
 2 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 83ddf36..6fdb782 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1153,6 +1153,7 @@ static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
 int fm10k_setup_tc(struct net_device *dev, u8 tc)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
+	int err;
 
 	/* Currently only the PF supports priority classes */
 	if (tc && (interface->hw.mac.type != fm10k_mac_pf))
@@ -1177,17 +1178,30 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 	netdev_reset_tc(dev);
 	netdev_set_num_tc(dev, tc);
 
-	fm10k_init_queueing_scheme(interface);
+	err = fm10k_init_queueing_scheme(interface);
+	if (err)
+		goto err_queueing_scheme;
 
-	fm10k_mbx_request_irq(interface);
+	err = fm10k_mbx_request_irq(interface);
+	if (err)
+		goto err_mbx_irq;
 
-	if (netif_running(dev))
-		fm10k_open(dev);
+	err = netif_running(dev) ? fm10k_open(dev) : 0;
+	if (err)
+		goto err_open;
 
 	/* flag to indicate SWPRI has yet to be updated */
 	interface->flags |= FM10K_FLAG_SWPRI_CONFIG;
 
 	return 0;
+err_open:
+	fm10k_mbx_free_irq(interface);
+err_mbx_irq:
+	fm10k_clear_queueing_scheme(interface);
+err_queueing_scheme:
+	netif_device_detach(dev);
+
+	return err;
 }
 
 static int fm10k_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 020f6dc..202468f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -186,7 +186,13 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	}
 
 	/* reassociate interrupts */
-	fm10k_mbx_request_irq(interface);
+	err = fm10k_mbx_request_irq(interface);
+	if (err)
+		goto err_mbx_irq;
+
+	err = fm10k_hw_ready(interface);
+	if (err)
+		goto err_open;
 
 	/* update hardware address for VFs if perm_addr has changed */
 	if (hw->mac.type == fm10k_mac_vf) {
@@ -206,14 +212,23 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	/* reset clock */
 	fm10k_ts_reset(interface);
 
-	if (netif_running(netdev))
-		fm10k_open(netdev);
+	err = netif_running(netdev) ? fm10k_open(netdev) : 0;
+	if (err)
+		goto err_open;
 
 	fm10k_iov_resume(interface->pdev);
 
+	rtnl_unlock();
+
+	clear_bit(__FM10K_RESETTING, &interface->state);
+
+	return;
+err_open:
+	fm10k_mbx_free_irq(interface);
+err_mbx_irq:
+	fm10k_clear_queueing_scheme(interface);
 reinit_err:
-	if (err)
-		netif_device_detach(netdev);
+	netif_device_detach(netdev);
 
 	rtnl_unlock();
 
@@ -2131,16 +2146,22 @@ static int fm10k_resume(struct pci_dev *pdev)
 	rtnl_lock();
 
 	err = fm10k_init_queueing_scheme(interface);
-	if (!err) {
-		fm10k_mbx_request_irq(interface);
-		if (netif_running(netdev))
-			err = fm10k_open(netdev);
-	}
+	if (err)
+		goto err_queueing_scheme;
 
-	rtnl_unlock();
+	err = fm10k_mbx_request_irq(interface);
+	if (err)
+		goto err_mbx_irq;
 
+	err = fm10k_hw_ready(interface);
 	if (err)
-		return err;
+		goto err_open;
+
+	err = netif_running(netdev) ? fm10k_open(netdev) : 0;
+	if (err)
+		goto err_open;
+
+	rtnl_unlock();
 
 	/* assume host is not ready, to prevent race with watchdog in case we
 	 * actually don't have connection to the switch
@@ -2158,6 +2179,14 @@ static int fm10k_resume(struct pci_dev *pdev)
 	netif_device_attach(netdev);
 
 	return 0;
+err_open:
+	fm10k_mbx_free_irq(interface);
+err_mbx_irq:
+	fm10k_clear_queueing_scheme(interface);
+err_queueing_scheme:
+	rtnl_unlock();
+
+	return err;
 }
 
 /**
-- 
2.5.0
