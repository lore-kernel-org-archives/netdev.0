From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: support rx-fcs and rx-all
Date: Tue, 31 Oct 2017 14:29:47 +0000
Message-ID: <9ab2b13c-dbcd-5769-0a5d-08162569369d@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:50822 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751876AbdJaO3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 10:29:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet FCS inclusion (rx-fcs) is supported on EF10 NICs, conditional on
 a firmware capability bit (MC_CMD_GET_CAPABILITIES_OUT_RX_INCLUDE_FCS).
To receive frames with bad FCS (rx-all) we just don't return the discard
 flag EFX_RX_PKT_DISCARD from efx_ef10_handle_rx_event_errors() or
 efx_farch_handle_rx_not_ok().

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c      | 16 ++++++++++++----
 drivers/net/ethernet/sfc/efx.c       | 14 ++++++++++----
 drivers/net/ethernet/sfc/farch.c     |  4 ++++
 drivers/net/ethernet/sfc/mcdi_port.c |  4 ++++
 4 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 13f72f5..19a9188 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -674,6 +674,10 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	efx->rx_packet_len_offset =
 		ES_DZ_RX_PREFIX_PKTLEN_OFST - ES_DZ_RX_PREFIX_SIZE;
 
+	if (nic_data->datapath_caps &
+	    (1 << MC_CMD_GET_CAPABILITIES_OUT_RX_INCLUDE_FCS_LBN))
+		efx->net_dev->hw_features |= NETIF_F_RXFCS;
+
 	rc = efx_mcdi_port_get_number(efx);
 	if (rc < 0)
 		goto fail5;
@@ -3199,11 +3203,15 @@ static u16 efx_ef10_handle_rx_event_errors(struct efx_channel *channel,
 					   const efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
+	bool handled = false;
 
 	if (EFX_QWORD_FIELD(*event, ESF_DZ_RX_ECRC_ERR)) {
-		if (!efx->loopback_selftest)
-			channel->n_rx_eth_crc_err += n_packets;
-		return EFX_RX_PKT_DISCARD;
+		if (!(efx->net_dev->features & NETIF_F_RXALL)) {
+			if (!efx->loopback_selftest)
+				channel->n_rx_eth_crc_err += n_packets;
+			return EFX_RX_PKT_DISCARD;
+		}
+		handled = true;
 	}
 	if (EFX_QWORD_FIELD(*event, ESF_DZ_RX_IPCKSUM_ERR)) {
 		if (unlikely(rx_encap_hdr != ESE_EZ_ENCAP_HDR_VXLAN &&
@@ -3274,7 +3282,7 @@ static u16 efx_ef10_handle_rx_event_errors(struct efx_channel *channel,
 		return 0;
 	}
 
-	WARN_ON(1); /* No error bits were recognised */
+	WARN_ON(!handled); /* No error bits were recognised */
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8fdcf7a..6668e37 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2315,8 +2315,11 @@ static int efx_set_features(struct net_device *net_dev, netdev_features_t data)
 			return rc;
 	}
 
-	/* If Rx VLAN filter is changed, update filters via mac_reconfigure */
-	if ((net_dev->features ^ data) & NETIF_F_HW_VLAN_CTAG_FILTER) {
+	/* If Rx VLAN filter is changed, update filters via mac_reconfigure.
+	 * If rx-fcs is changed, mac_reconfigure updates that too.
+	 */
+	if ((net_dev->features ^ data) & (NETIF_F_HW_VLAN_CTAG_FILTER |
+					  NETIF_F_RXFCS)) {
 		/* efx_set_rx_mode() will schedule MAC work to update filters
 		 * when a new features are finally set in net_dev.
 		 */
@@ -3242,7 +3245,7 @@ static int efx_pci_probe_post_io(struct efx_nic *efx)
 
 	/* Determine netdevice features */
 	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
-			      NETIF_F_TSO | NETIF_F_RXCSUM);
+			      NETIF_F_TSO | NETIF_F_RXCSUM | NETIF_F_RXALL);
 	if (efx->type->offload_features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
 		net_dev->features |= NETIF_F_TSO6;
 	/* Check whether device supports TSO */
@@ -3253,7 +3256,10 @@ static int efx_pci_probe_post_io(struct efx_nic *efx)
 				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
 				   NETIF_F_RXCSUM);
 
-	net_dev->hw_features = net_dev->features & ~efx->fixed_features;
+	net_dev->hw_features |= net_dev->features & ~efx->fixed_features;
+
+	/* Disable receiving frames with bad FCS, by default. */
+	net_dev->features &= ~NETIF_F_RXALL;
 
 	/* Disable VLAN filtering by default.  It may be enforced if
 	 * the feature is fixed (i.e. VLAN filters are required to
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index ba45150..6608dfe 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -927,6 +927,10 @@ static u16 efx_farch_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	}
 #endif
 
+	if (efx->net_dev->features & NETIF_F_RXALL)
+		/* don't discard frame for CRC error */
+		rx_ev_eth_crc_err = false;
+
 	/* The frame must be discarded if any of these are true. */
 	return (rx_ev_eth_crc_err | rx_ev_frm_trunc |
 		rx_ev_tobe_disc | rx_ev_pause_frm) ?
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index c7407d1..6e1f282 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -1029,6 +1029,10 @@ int efx_mcdi_set_mac(struct efx_nic *efx)
 	MCDI_POPULATE_DWORD_1(cmdbytes, SET_MAC_IN_REJECT,
 			      SET_MAC_IN_REJECT_UNCST, efx->unicast_filter);
 
+	MCDI_POPULATE_DWORD_1(cmdbytes, SET_MAC_IN_FLAGS,
+			      SET_MAC_IN_FLAG_INCLUDE_FCS,
+			      !!(efx->net_dev->features & NETIF_F_RXFCS));
+
 	switch (efx->wanted_fc) {
 	case EFX_FC_RX | EFX_FC_TX:
 		fcntl = MC_CMD_FCNTL_BIDIR;
