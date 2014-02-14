From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 04/14] i40evf: get rid of pci_using_dac
Date: Fri, 14 Feb 2014 14:57:58 -0800
Message-ID: <1392418688-23895-5-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33318 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166AbaBNXBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:20 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

PCI DAC doesn't really mean much on a virtualized PCI Express part, so
get rid of that check and just always set the HIGHDMA flag in the net
device.

Change-ID: I2040272be0e7934323f470c2bc73fbdd4f93e2b6
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e0eb27d..e9da5d5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2034,8 +2034,8 @@ static void i40evf_init_task(struct work_struct *work)
 	netdev->netdev_ops = &i40evf_netdev_ops;
 	i40evf_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
-
-	netdev->features |= NETIF_F_SG |
+	netdev->features |= NETIF_F_HIGHDMA |
+			    NETIF_F_SG |
 			    NETIF_F_IP_CSUM |
 			    NETIF_F_SCTP_CSUM |
 			    NETIF_F_IPV6_CSUM |
@@ -2180,20 +2180,18 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct net_device *netdev;
 	struct i40evf_adapter *adapter = NULL;
 	struct i40e_hw *hw = NULL;
-	int err, pci_using_dac;
+	int err;
 
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
 
 	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
-		pci_using_dac = true;
 		/* coherent mask for the same size will always succeed if
 		 * dma_set_mask does
 		 */
 		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
 	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
-		pci_using_dac = false;
 		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
 	} else {
 		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
@@ -2224,8 +2222,6 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
 
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
-- 
1.8.5.GIT
