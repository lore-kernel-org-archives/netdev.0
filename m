From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 17/17] sfc: Fix VLAN filtering feature if vPort has
 VLAN_RESTRICT flag
Date: Wed, 15 Jun 2016 17:52:08 +0100
Message-ID: <ed1a97d2-bbb4-ffcf-96e5-a1fe6d70703a@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:5533 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932141AbcFOQwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:52:21 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

If vPort has VLAN_RESTRICT flag, VLAN tagged traffic will not be
delivered without corresponding Rx filters which may be proxied to and
moderated by hypervisor.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 39 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.c | 37 ++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/ef10_sriov.h |  3 +++
 3 files changed, 74 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 353ceef..f658fee 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -878,6 +878,45 @@ static int efx_ef10_probe_pf(struct efx_nic *efx)
 	return efx_ef10_probe(efx);
 }
 
+int efx_ef10_vadaptor_query(struct efx_nic *efx, unsigned int port_id,
+			    u32 *port_flags, u32 *vadaptor_flags,
+			    unsigned int *vlan_tags)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_QUERY_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_VADAPTOR_QUERY_OUT_LEN);
+	size_t outlen;
+	int rc;
+
+	if (nic_data->datapath_caps &
+	    (1 << MC_CMD_GET_CAPABILITIES_OUT_VADAPTOR_QUERY_LBN)) {
+		MCDI_SET_DWORD(inbuf, VADAPTOR_QUERY_IN_UPSTREAM_PORT_ID,
+			       port_id);
+
+		rc = efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_QUERY, inbuf, sizeof(inbuf),
+				  outbuf, sizeof(outbuf), &outlen);
+		if (rc)
+			return rc;
+
+		if (outlen < sizeof(outbuf)) {
+			rc = -EIO;
+			return rc;
+		}
+	}
+
+	if (port_flags)
+		*port_flags = MCDI_DWORD(outbuf, VADAPTOR_QUERY_OUT_PORT_FLAGS);
+	if (vadaptor_flags)
+		*vadaptor_flags =
+			MCDI_DWORD(outbuf, VADAPTOR_QUERY_OUT_VADAPTOR_FLAGS);
+	if (vlan_tags)
+		*vlan_tags =
+			MCDI_DWORD(outbuf,
+				   VADAPTOR_QUERY_OUT_NUM_AVAILABLE_VLAN_TAGS);
+
+	return 0;
+}
+
 int efx_ef10_vadaptor_alloc(struct efx_nic *efx, unsigned int port_id)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_ALLOC_IN_LEN);
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index a76610a..a949b9d 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -232,6 +232,35 @@ fail:
 	return rc;
 }
 
+static int efx_ef10_vadaptor_alloc_set_features(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	u32 port_flags;
+	int rc;
+
+	rc = efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+	if (rc)
+		goto fail_vadaptor_alloc;
+
+	rc = efx_ef10_vadaptor_query(efx, nic_data->vport_id,
+				     &port_flags, NULL, NULL);
+	if (rc)
+		goto fail_vadaptor_query;
+
+	if (port_flags &
+	    (1 << MC_CMD_VPORT_ALLOC_IN_FLAG_VLAN_RESTRICT_LBN))
+		efx->fixed_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+	else
+		efx->fixed_features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	return 0;
+
+fail_vadaptor_query:
+	efx_ef10_vadaptor_free(efx, EVB_PORT_ID_ASSIGNED);
+fail_vadaptor_alloc:
+	return rc;
+}
+
 /* On top of the default firmware vswitch setup, create a VEB vswitch and
  * expansion vport for use by this function.
  */
@@ -243,7 +272,7 @@ int efx_ef10_vswitching_probe_pf(struct efx_nic *efx)
 
 	if (pci_sriov_get_totalvfs(efx->pci_dev) <= 0) {
 		/* vswitch not needed as we have no VFs */
-		efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+		efx_ef10_vadaptor_alloc_set_features(efx);
 		return 0;
 	}
 
@@ -263,7 +292,7 @@ int efx_ef10_vswitching_probe_pf(struct efx_nic *efx)
 		goto fail3;
 	ether_addr_copy(nic_data->vport_mac, net_dev->dev_addr);
 
-	rc = efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+	rc = efx_ef10_vadaptor_alloc_set_features(efx);
 	if (rc)
 		goto fail4;
 
@@ -282,9 +311,7 @@ fail1:
 
 int efx_ef10_vswitching_probe_vf(struct efx_nic *efx)
 {
-	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-
-	return efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+	return efx_ef10_vadaptor_alloc_set_features(efx);
 }
 
 int efx_ef10_vswitching_restore_pf(struct efx_nic *efx)
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 6d25b92..9ceb7ef 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -70,6 +70,9 @@ int efx_ef10_vport_add_mac(struct efx_nic *efx,
 int efx_ef10_vport_del_mac(struct efx_nic *efx,
 			   unsigned int port_id, u8 *mac);
 int efx_ef10_vadaptor_alloc(struct efx_nic *efx, unsigned int port_id);
+int efx_ef10_vadaptor_query(struct efx_nic *efx, unsigned int port_id,
+			    u32 *port_flags, u32 *vadaptor_flags,
+			    unsigned int *vlan_tags);
 int efx_ef10_vadaptor_free(struct efx_nic *efx, unsigned int port_id);
 
 #endif /* EF10_SRIOV_H */
