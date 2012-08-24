From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/16] sfc: Assign efx and efx->type as early as
 possible in efx_pci_probe()
Date: Fri, 24 Aug 2012 20:53:10 +0100
Message-ID: <1345837990.2694.37.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56848 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760132Ab2HXTxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:53:13 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We also stop clearing *efx in efx_init_struct().  This is safe because
alloc_etherdev_mq() already clears it for us.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 4105a666..92f0020 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2422,13 +2422,12 @@ static const struct efx_phy_operations efx_dummy_phy_operations = {
 /* This zeroes out and then fills in the invariants in a struct
  * efx_nic (including all sub-structures).
  */
-static int efx_init_struct(struct efx_nic *efx, const struct efx_nic_type *type,
+static int efx_init_struct(struct efx_nic *efx,
 			   struct pci_dev *pci_dev, struct net_device *net_dev)
 {
 	int i;
 
 	/* Initialise common structures */
-	memset(efx, 0, sizeof(*efx));
 	spin_lock_init(&efx->biu_lock);
 #ifdef CONFIG_SFC_MTD
 	INIT_LIST_HEAD(&efx->mtd_list);
@@ -2455,8 +2454,6 @@ static int efx_init_struct(struct efx_nic *efx, const struct efx_nic_type *type,
 			goto fail;
 	}
 
-	efx->type = type;
-
 	EFX_BUG_ON_PARANOID(efx->type->phys_addr_channels > EFX_MAX_CHANNELS);
 
 	/* Higher numbered interrupt modes are less capable! */
@@ -2660,7 +2657,6 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 				   const struct pci_device_id *entry)
 {
-	const struct efx_nic_type *type = (const struct efx_nic_type *) entry->driver_data;
 	struct net_device *net_dev;
 	struct efx_nic *efx;
 	int rc;
@@ -2670,10 +2666,12 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 				     EFX_MAX_RX_QUEUES);
 	if (!net_dev)
 		return -ENOMEM;
-	net_dev->features |= (type->offload_features | NETIF_F_SG |
+	efx = netdev_priv(net_dev);
+	efx->type = (const struct efx_nic_type *) entry->driver_data;
+	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
 			      NETIF_F_HIGHDMA | NETIF_F_TSO |
 			      NETIF_F_RXCSUM);
-	if (type->offload_features & NETIF_F_V6_CSUM)
+	if (efx->type->offload_features & NETIF_F_V6_CSUM)
 		net_dev->features |= NETIF_F_TSO6;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
@@ -2681,10 +2679,9 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 				   NETIF_F_RXCSUM);
 	/* All offloads can be toggled */
 	net_dev->hw_features = net_dev->features & ~NETIF_F_HIGHDMA;
-	efx = netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
-	rc = efx_init_struct(efx, type, pci_dev, net_dev);
+	rc = efx_init_struct(efx, pci_dev, net_dev);
 	if (rc)
 		goto fail1;
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
