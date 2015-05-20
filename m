From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 10/16] sfc: add ndo_set_vf_mac() function for
 EF10
Date: Wed, 20 May 2015 11:11:03 +0100
Message-ID: <555C5DB7.7060902@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:27313 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751655AbbETKLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:11:12 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a response to this entrypoint.
The ndo_set_vf_mac() entrypoint is only exposed in the driver if
CONFIG_SFC_SRIOV is defined.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 90 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h |  6 +--
 drivers/net/ethernet/sfc/efx.c        |  4 +-
 drivers/net/ethernet/sfc/efx.h        |  3 ++
 4 files changed, 96 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 6208dd7..42a3b16 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -431,3 +431,93 @@ void efx_ef10_sriov_fini(struct efx_nic *efx)
 	else
 		netif_dbg(efx, drv, efx->net_dev, "SRIOV disabled\n");
 }
+
+static int efx_ef10_vport_del_vf_mac(struct efx_nic *efx, unsigned int port_id,
+				     u8 *mac)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_DEL_MAC_ADDRESS_IN_LEN);
+	MCDI_DECLARE_BUF_ERR(outbuf);
+	size_t outlen;
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, VPORT_DEL_MAC_ADDRESS_IN_VPORT_ID, port_id);
+	ether_addr_copy(MCDI_PTR(inbuf, VPORT_DEL_MAC_ADDRESS_IN_MACADDR), mac);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_VPORT_DEL_MAC_ADDRESS, inbuf,
+			  sizeof(inbuf), outbuf, sizeof(outbuf), &outlen);
+
+	return rc;
+}
+
+int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct ef10_vf *vf;
+	int rc;
+
+	if (!nic_data->vf)
+		return -EOPNOTSUPP;
+
+	if (vf_i >= efx->vf_count)
+		return -EINVAL;
+	vf = nic_data->vf + vf_i;
+
+	if (vf->efx) {
+		efx_device_detach_sync(vf->efx);
+		efx_net_stop(vf->efx->net_dev);
+
+		down_write(&vf->efx->filter_sem);
+		vf->efx->type->filter_table_remove(vf->efx);
+
+		rc = efx_ef10_vadaptor_free(vf->efx, EVB_PORT_ID_ASSIGNED);
+		if (rc) {
+			up_write(&vf->efx->filter_sem);
+			return rc;
+		}
+	}
+
+	rc = efx_ef10_evb_port_assign(efx, EVB_PORT_ID_NULL, vf_i);
+	if (rc)
+		return rc;
+
+	if (!is_zero_ether_addr(vf->mac)) {
+		rc = efx_ef10_vport_del_vf_mac(efx, vf->vport_id, vf->mac);
+		if (rc)
+			return rc;
+	}
+
+	if (!is_zero_ether_addr(mac)) {
+		rc = efx_ef10_vport_add_mac(efx, vf->vport_id, mac);
+		if (rc) {
+			eth_zero_addr(vf->mac);
+			goto fail;
+		}
+		if (vf->efx)
+			ether_addr_copy(vf->efx->net_dev->dev_addr, mac);
+	}
+
+	ether_addr_copy(vf->mac, mac);
+
+	rc = efx_ef10_evb_port_assign(efx, vf->vport_id, vf_i);
+	if (rc)
+		goto fail;
+
+	if (vf->efx) {
+		/* VF cannot use the vport_id that the PF created */
+		rc = efx_ef10_vadaptor_alloc(vf->efx, EVB_PORT_ID_ASSIGNED);
+		if (rc) {
+			up_write(&vf->efx->filter_sem);
+			return rc;
+		}
+		vf->efx->type->filter_table_probe(vf->efx);
+		up_write(&vf->efx->filter_sem);
+		efx_net_open(vf->efx->net_dev);
+		netif_device_attach(vf->efx->net_dev);
+	}
+
+	return 0;
+
+fail:
+	memset(vf->mac, 0, ETH_ALEN);
+	return rc;
+}
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 6f27a0d..7f12942 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -41,11 +41,7 @@ static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
 void efx_ef10_sriov_fini(struct efx_nic *efx);
 static inline void efx_ef10_sriov_flr(struct efx_nic *efx, unsigned vf_i) {}
 
-static inline int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf,
-					    u8 *mac)
-{
-	return -EOPNOTSUPP;
-}
+int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf, u8 *mac);
 
 static inline int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf,
 					     u16 vlan, u8 qos)
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 50816cd..abb9c0e 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2113,7 +2113,7 @@ static int efx_busy_poll(struct napi_struct *napi)
  *************************************************************************/
 
 /* Context: process, rtnl_lock() held. */
-static int efx_net_open(struct net_device *net_dev)
+int efx_net_open(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
@@ -2142,7 +2142,7 @@ static int efx_net_open(struct net_device *net_dev)
  * Note that the kernel will ignore our return code; this method
  * should really be a void.
  */
-static int efx_net_stop(struct net_device *net_dev)
+int efx_net_stop(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 46aee41..acb1e07 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -19,6 +19,9 @@
 #define EFX_MEM_BAR 2
 #define EFX_MEM_VF_BAR 0
 
+int efx_net_open(struct net_device *net_dev);
+int efx_net_stop(struct net_device *net_dev);
+
 /* TX */
 int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
