From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] fm10k: set netdev features in one location
Date: Thu,  3 Dec 2015 16:29:39 -0800
Message-ID: <1449188994-64940-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22000 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278AbbLDA34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:56 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Don't change netdev hw_features later in fm10k_probe, instead set all
values inside fm10k_alloc_netdev. To do so, we need to know the MAC type
(whether it is PF or VF) in order to determine what to do. This helps
ensure that all logic regarding features is co-located.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 31 +++++++++++++++----------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  9 +------
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 48809e5..b178905 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -484,7 +484,7 @@ void fm10k_netpoll(struct net_device *netdev);
 #endif
 
 /* Netdev */
-struct net_device *fm10k_alloc_netdev(void);
+struct net_device *fm10k_alloc_netdev(const struct fm10k_info *info);
 int fm10k_setup_rx_resources(struct fm10k_ring *);
 int fm10k_setup_tx_resources(struct fm10k_ring *);
 void fm10k_free_rx_resources(struct fm10k_ring *);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 96364c7..38fe2d8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1391,8 +1391,9 @@ static const struct net_device_ops fm10k_netdev_ops = {
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
 
-struct net_device *fm10k_alloc_netdev(void)
+struct net_device *fm10k_alloc_netdev(const struct fm10k_info *info)
 {
+	netdev_features_t hw_features;
 	struct fm10k_intfc *interface;
 	struct net_device *dev;
 
@@ -1415,27 +1416,31 @@ struct net_device *fm10k_alloc_netdev(void)
 			 NETIF_F_TSO |
 			 NETIF_F_TSO6 |
 			 NETIF_F_TSO_ECN |
-			 NETIF_F_GSO_UDP_TUNNEL |
 			 NETIF_F_RXHASH |
 			 NETIF_F_RXCSUM;
 
+	/* Only the PF can support VXLAN and NVGRE tunnel offloads */
+	if (info->mac == fm10k_mac_pf) {
+		dev->hw_enc_features = NETIF_F_IP_CSUM |
+				       NETIF_F_TSO |
+				       NETIF_F_TSO6 |
+				       NETIF_F_TSO_ECN |
+				       NETIF_F_GSO_UDP_TUNNEL |
+				       NETIF_F_IPV6_CSUM |
+				       NETIF_F_SG;
+
+		dev->features |= NETIF_F_GSO_UDP_TUNNEL;
+	}
+
 	/* all features defined to this point should be changeable */
-	dev->hw_features |= dev->features;
+	hw_features = dev->features;
 
 	/* allow user to enable L2 forwarding acceleration */
-	dev->hw_features |= NETIF_F_HW_L2FW_DOFFLOAD;
+	hw_features |= NETIF_F_HW_L2FW_DOFFLOAD;
 
 	/* configure VLAN features */
 	dev->vlan_features |= dev->features;
 
-	/* configure tunnel offloads */
-	dev->hw_enc_features |= NETIF_F_IP_CSUM |
-				NETIF_F_TSO |
-				NETIF_F_TSO6 |
-				NETIF_F_TSO_ECN |
-				NETIF_F_GSO_UDP_TUNNEL |
-				NETIF_F_IPV6_CSUM;
-
 	/* we want to leave these both on as we cannot disable VLAN tag
 	 * insertion or stripping on the hardware since it is contained
 	 * in the FTAG and not in the frame itself.
@@ -1446,5 +1451,7 @@ struct net_device *fm10k_alloc_netdev(void)
 
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
+	dev->hw_features |= hw_features;
+
 	return dev;
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 5fbffba..1af4b22 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1722,13 +1722,6 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 					     pci_resource_len(pdev, 4));
 	hw->sw_addr = interface->sw_addr;
 
-	/* Only the PF can support VXLAN and NVGRE offloads */
-	if (hw->mac.type != fm10k_mac_pf) {
-		netdev->hw_enc_features = 0;
-		netdev->features &= ~NETIF_F_GSO_UDP_TUNNEL;
-		netdev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
-	}
-
 	/* initialize DCBNL interface */
 	fm10k_dcbnl_set_ops(netdev);
 
@@ -1894,7 +1887,7 @@ static int fm10k_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
-	netdev = fm10k_alloc_netdev();
+	netdev = fm10k_alloc_netdev(fm10k_info_tbl[ent->driver_data]);
 	if (!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_netdev;
-- 
2.5.0
