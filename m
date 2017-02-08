From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/6] sfc: harden driver against MC resets during
 initial probe
Date: Wed, 8 Feb 2017 16:51:18 +0000
Message-ID: <d64c6a95-978b-a6f1-360c-ae3a23370b38@solarflare.com>
References: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:51896 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752707AbdBHQ6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:58:31 -0500
In-Reply-To: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

This is mainly to prepare for a future overlay networking patch that
 could cause an MC reset at probe time if the UDP tunnel port list is
 set immediately upon driver load.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 99 +++++++++++++++++++++++++++---------------
 1 file changed, 64 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index c28cd9d..baab0a2 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3136,6 +3136,51 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	return rc;
 }
 
+static int efx_pci_probe_post_io(struct efx_nic *efx)
+{
+	struct net_device *net_dev = efx->net_dev;
+	int rc = efx_pci_probe_main(efx);
+
+	if (rc)
+		return rc;
+
+	if (efx->type->sriov_init) {
+		rc = efx->type->sriov_init(efx);
+		if (rc)
+			netif_err(efx, probe, efx->net_dev,
+				  "SR-IOV can't be enabled rc %d\n", rc);
+	}
+
+	/* Determine netdevice features */
+	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
+			      NETIF_F_TSO | NETIF_F_RXCSUM);
+	if (efx->type->offload_features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
+		net_dev->features |= NETIF_F_TSO6;
+	/* Check whether device supports TSO */
+	if (!efx->type->tso_versions || !efx->type->tso_versions(efx))
+		net_dev->features &= ~NETIF_F_ALL_TSO;
+	/* Mask for features that also apply to VLAN devices */
+	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
+				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
+				   NETIF_F_RXCSUM);
+
+	net_dev->hw_features = net_dev->features & ~efx->fixed_features;
+
+	/* Disable VLAN filtering by default.  It may be enforced if
+	 * the feature is fixed (i.e. VLAN filters are required to
+	 * receive VLAN tagged packets due to vPort restrictions).
+	 */
+	net_dev->features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+	net_dev->features |= efx->fixed_features;
+
+	rc = efx_register_netdev(efx);
+	if (!rc)
+		return 0;
+
+	efx_pci_remove_main(efx);
+	return rc;
+}
+
 /* NIC initialisation
  *
  * This is called at module load (or hotplug insertion,
@@ -3178,42 +3223,28 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	if (rc)
 		goto fail2;
 
-	rc = efx_pci_probe_main(efx);
+	rc = efx_pci_probe_post_io(efx);
+	if (rc) {
+		/* On failure, retry once immediately.
+		 * If we aborted probe due to a scheduled reset, dismiss it.
+		 */
+		efx->reset_pending = 0;
+		rc = efx_pci_probe_post_io(efx);
+		if (rc) {
+			/* On another failure, retry once more
+			 * after a 50-305ms delay.
+			 */
+			unsigned char r;
+
+			get_random_bytes(&r, 1);
+			msleep((unsigned int)r + 50);
+			efx->reset_pending = 0;
+			rc = efx_pci_probe_post_io(efx);
+		}
+	}
 	if (rc)
 		goto fail3;
 
-	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
-			      NETIF_F_TSO | NETIF_F_RXCSUM);
-	if (efx->type->offload_features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
-		net_dev->features |= NETIF_F_TSO6;
-	/* Check whether device supports TSO */
-	if (!efx->type->tso_versions || !efx->type->tso_versions(efx))
-		net_dev->features &= ~NETIF_F_ALL_TSO;
-	/* Mask for features that also apply to VLAN devices */
-	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
-				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
-				   NETIF_F_RXCSUM);
-
-	net_dev->hw_features = net_dev->features & ~efx->fixed_features;
-
-	/* Disable VLAN filtering by default.  It may be enforced if
-	 * the feature is fixed (i.e. VLAN filters are required to
-	 * receive VLAN tagged packets due to vPort restrictions).
-	 */
-	net_dev->features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
-	net_dev->features |= efx->fixed_features;
-
-	rc = efx_register_netdev(efx);
-	if (rc)
-		goto fail4;
-
-	if (efx->type->sriov_init) {
-		rc = efx->type->sriov_init(efx);
-		if (rc)
-			netif_err(efx, probe, efx->net_dev,
-				  "SR-IOV can't be enabled rc %d\n", rc);
-	}
-
 	netif_dbg(efx, probe, efx->net_dev, "initialisation successful\n");
 
 	/* Try to create MTDs, but allow this to fail */
@@ -3232,8 +3263,6 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 
 	return 0;
 
- fail4:
-	efx_pci_remove_main(efx);
  fail3:
 	efx_fini_io(efx);
  fail2:
