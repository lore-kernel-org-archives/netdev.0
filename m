From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next v2] sfc: Use ether_addr_copy and
 eth_broadcast_addr
Date: Fri, 7 Mar 2014 18:27:41 +0000
Message-ID: <alpine.LFD.2.03.1403071759510.11827@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Shradha Shah <sshah@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21298 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaCGS1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 13:27:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Faster than memcpy/memset on some architectures.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
v2: fixed indentation
---
 drivers/net/ethernet/sfc/ef10.c        | 13 +++++--------
 drivers/net/ethernet/sfc/efx.c         |  4 ++--
 drivers/net/ethernet/sfc/ethtool.c     | 18 +++++++++---------
 drivers/net/ethernet/sfc/falcon.c      |  2 +-
 drivers/net/ethernet/sfc/filter.h      |  2 +-
 drivers/net/ethernet/sfc/mcdi.c        | 14 ++++++++------
 drivers/net/ethernet/sfc/mcdi_port.c   |  4 ++--
 drivers/net/ethernet/sfc/selftest.c    |  6 +++---
 drivers/net/ethernet/sfc/siena_sriov.c | 13 ++++++-------
 9 files changed, 37 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 3b39798..eb75675 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -162,8 +162,8 @@ static int efx_ef10_get_mac_address(struct efx_nic *efx, u8 *mac_address)
 	if (outlen < MC_CMD_GET_MAC_ADDRESSES_OUT_LEN)
 		return -EIO;
 
-	memcpy(mac_address,
-	       MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE), ETH_ALEN);
+	ether_addr_copy(mac_address,
+			MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE));
 	return 0;
 }
 
@@ -3145,12 +3145,10 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		table->dev_uc_count = -1;
 	} else {
 		table->dev_uc_count = 1 + netdev_uc_count(net_dev);
-		memcpy(table->dev_uc_list[0].addr, net_dev->dev_addr,
-		       ETH_ALEN);
+		ether_addr_copy(table->dev_uc_list[0].addr, net_dev->dev_addr);
 		i = 1;
 		netdev_for_each_uc_addr(uc, net_dev) {
-			memcpy(table->dev_uc_list[i].addr,
-			       uc->addr, ETH_ALEN);
+			ether_addr_copy(table->dev_uc_list[i].addr, uc->addr);
 			i++;
 		}
 	}
@@ -3162,8 +3160,7 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		eth_broadcast_addr(table->dev_mc_list[0].addr);
 		i = 1;
 		netdev_for_each_mc_addr(mc, net_dev) {
-			memcpy(table->dev_mc_list[i].addr,
-			       mc->addr, ETH_ALEN);
+			ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
 			i++;
 		}
 	}
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index d72e003..52589f6 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1012,7 +1012,7 @@ static int efx_probe_port(struct efx_nic *efx)
 		return rc;
 
 	/* Initialise MAC address to permanent address */
-	memcpy(efx->net_dev->dev_addr, efx->net_dev->perm_addr, ETH_ALEN);
+	ether_addr_copy(efx->net_dev->dev_addr, efx->net_dev->perm_addr);
 
 	return 0;
 }
@@ -2120,7 +2120,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 		return -EADDRNOTAVAIL;
 	}
 
-	memcpy(net_dev->dev_addr, new_addr, net_dev->addr_len);
+	ether_addr_copy(net_dev->dev_addr, new_addr);
 	efx_sriov_mac_address_changed(efx);
 
 	/* Reconfigure the MAC */
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 89fcaff..0de8b07 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -727,7 +727,7 @@ static int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
 }
 
 /* MAC address mask including only I/G bit */
-static const u8 mac_addr_ig_mask[ETH_ALEN] = { 0x01, 0, 0, 0, 0, 0 };
+static const u8 mac_addr_ig_mask[ETH_ALEN] __aligned(2) = {0x01, 0, 0, 0, 0, 0};
 
 #define IP4_ADDR_FULL_MASK	((__force __be32)~0)
 #define PORT_FULL_MASK		((__force __be16)~0)
@@ -787,16 +787,16 @@ static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 		rule->flow_type = ETHER_FLOW;
 		if (spec.match_flags &
 		    (EFX_FILTER_MATCH_LOC_MAC | EFX_FILTER_MATCH_LOC_MAC_IG)) {
-			memcpy(mac_entry->h_dest, spec.loc_mac, ETH_ALEN);
+			ether_addr_copy(mac_entry->h_dest, spec.loc_mac);
 			if (spec.match_flags & EFX_FILTER_MATCH_LOC_MAC)
-				memset(mac_mask->h_dest, ~0, ETH_ALEN);
+				eth_broadcast_addr(mac_mask->h_dest);
 			else
-				memcpy(mac_mask->h_dest, mac_addr_ig_mask,
-				       ETH_ALEN);
+				ether_addr_copy(mac_mask->h_dest,
+						mac_addr_ig_mask);
 		}
 		if (spec.match_flags & EFX_FILTER_MATCH_REM_MAC) {
-			memcpy(mac_entry->h_source, spec.rem_mac, ETH_ALEN);
-			memset(mac_mask->h_source, ~0, ETH_ALEN);
+			ether_addr_copy(mac_entry->h_source, spec.rem_mac);
+			eth_broadcast_addr(mac_mask->h_source);
 		}
 		if (spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE) {
 			mac_entry->h_proto = spec.ether_type;
@@ -968,13 +968,13 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 				spec.match_flags |= EFX_FILTER_MATCH_LOC_MAC;
 			else
 				return -EINVAL;
-			memcpy(spec.loc_mac, mac_entry->h_dest, ETH_ALEN);
+			ether_addr_copy(spec.loc_mac, mac_entry->h_dest);
 		}
 		if (!is_zero_ether_addr(mac_mask->h_source)) {
 			if (!is_broadcast_ether_addr(mac_mask->h_source))
 				return -EINVAL;
 			spec.match_flags |= EFX_FILTER_MATCH_REM_MAC;
-			memcpy(spec.rem_mac, mac_entry->h_source, ETH_ALEN);
+			ether_addr_copy(spec.rem_mac, mac_entry->h_source);
 		}
 		if (mac_mask->h_proto) {
 			if (mac_mask->h_proto != ETHER_TYPE_FULL_MASK)
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 72652f3..8ec20b7 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2183,7 +2183,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	}
 
 	/* Read the MAC addresses */
-	memcpy(efx->net_dev->perm_addr, nvconfig->mac_address[0], ETH_ALEN);
+	ether_addr_copy(efx->net_dev->perm_addr, nvconfig->mac_address[0]);
 
 	netif_dbg(efx, probe, efx->net_dev, "PHY is %d phy_id %d\n",
 		  efx->phy_type, efx->mdio.prtad);
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index 3ef298d..d0ed7f7 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -243,7 +243,7 @@ static inline int efx_filter_set_eth_local(struct efx_filter_spec *spec,
 	}
 	if (addr != NULL) {
 		spec->match_flags |= EFX_FILTER_MATCH_LOC_MAC;
-		memcpy(spec->loc_mac, addr, ETH_ALEN);
+		ether_addr_copy(spec->loc_mac, addr);
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index eb59abb..7bd4b14 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1187,6 +1187,9 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 	int rc;
 
 	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_IN_LEN != 0);
+	/* we need __aligned(2) for ether_addr_copy */
+	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST & 1);
+	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT1_OFST & 1);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_GET_BOARD_CFG, NULL, 0,
 			  outbuf, sizeof(outbuf), &outlen);
@@ -1199,11 +1202,10 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 	}
 
 	if (mac_address)
-		memcpy(mac_address,
-		       port_num ?
-		       MCDI_PTR(outbuf, GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT1) :
-		       MCDI_PTR(outbuf, GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0),
-		       ETH_ALEN);
+		ether_addr_copy(mac_address,
+				port_num ?
+				MCDI_PTR(outbuf, GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT1) :
+				MCDI_PTR(outbuf, GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0));
 	if (fw_subtype_list) {
 		for (i = 0;
 		     i < MCDI_VAR_ARRAY_LEN(outlen,
@@ -1532,7 +1534,7 @@ static int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
 	MCDI_SET_DWORD(inbuf, WOL_FILTER_SET_IN_WOL_TYPE, type);
 	MCDI_SET_DWORD(inbuf, WOL_FILTER_SET_IN_FILTER_MODE,
 		       MC_CMD_FILTER_MODE_SIMPLE);
-	memcpy(MCDI_PTR(inbuf, WOL_FILTER_SET_IN_MAGIC_MAC), mac, ETH_ALEN);
+	ether_addr_copy(MCDI_PTR(inbuf, WOL_FILTER_SET_IN_MAGIC_MAC), mac);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_WOL_FILTER_SET, inbuf, sizeof(inbuf),
 			  outbuf, sizeof(outbuf), &outlen);
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 91d2325..e5fc4e1 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -854,8 +854,8 @@ int efx_mcdi_set_mac(struct efx_nic *efx)
 
 	BUILD_BUG_ON(MC_CMD_SET_MAC_OUT_LEN != 0);
 
-	memcpy(MCDI_PTR(cmdbytes, SET_MAC_IN_ADDR),
-	       efx->net_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(MCDI_PTR(cmdbytes, SET_MAC_IN_ADDR),
+			efx->net_dev->dev_addr);
 
 	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_MTU,
 			EFX_MAX_FRAME_LEN(efx->net_dev->mtu));
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 2664181..0fc5bae 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -50,7 +50,7 @@ struct efx_loopback_payload {
 } __packed;
 
 /* Loopback test source MAC address */
-static const unsigned char payload_source[ETH_ALEN] = {
+static const u8 payload_source[ETH_ALEN] __aligned(2) = {
 	0x00, 0x0f, 0x53, 0x1b, 0x1b, 0x1b,
 };
 
@@ -366,8 +366,8 @@ static void efx_iterate_state(struct efx_nic *efx)
 	struct efx_loopback_payload *payload = &state->payload;
 
 	/* Initialise the layerII header */
-	memcpy(&payload->header.h_dest, net_dev->dev_addr, ETH_ALEN);
-	memcpy(&payload->header.h_source, &payload_source, ETH_ALEN);
+	ether_addr_copy((u8 *)&payload->header.h_dest, net_dev->dev_addr);
+	ether_addr_copy((u8 *)&payload->header.h_source, payload_source);
 	payload->header.h_proto = htons(ETH_P_IP);
 
 	/* saddr set later and used as incrementing count */
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 0c38f92..9a9205e 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -1095,7 +1095,7 @@ static void efx_sriov_peer_work(struct work_struct *data)
 
 	/* Fill the remaining addresses */
 	list_for_each_entry(local_addr, &efx->local_addr_list, link) {
-		memcpy(peer->mac_addr, local_addr->addr, ETH_ALEN);
+		ether_addr_copy(peer->mac_addr, local_addr->addr);
 		peer->tci = 0;
 		++peer;
 		++peer_count;
@@ -1303,8 +1303,7 @@ int efx_sriov_init(struct efx_nic *efx)
 		goto fail_vfs;
 
 	rtnl_lock();
-	memcpy(vfdi_status->peers[0].mac_addr,
-	       net_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(vfdi_status->peers[0].mac_addr, net_dev->dev_addr);
 	efx->vf_init_count = efx->vf_count;
 	rtnl_unlock();
 
@@ -1452,8 +1451,8 @@ void efx_sriov_mac_address_changed(struct efx_nic *efx)
 
 	if (!efx->vf_init_count)
 		return;
-	memcpy(vfdi_status->peers[0].mac_addr,
-	       efx->net_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(vfdi_status->peers[0].mac_addr,
+			efx->net_dev->dev_addr);
 	queue_work(vfdi_workqueue, &efx->peer_work);
 }
 
@@ -1570,7 +1569,7 @@ int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
 	vf = efx->vf + vf_i;
 
 	mutex_lock(&vf->status_lock);
-	memcpy(vf->addr.mac_addr, mac, ETH_ALEN);
+	ether_addr_copy(vf->addr.mac_addr, mac);
 	__efx_sriov_update_vf_addr(vf);
 	mutex_unlock(&vf->status_lock);
 
@@ -1633,7 +1632,7 @@ int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
 	vf = efx->vf + vf_i;
 
 	ivi->vf = vf_i;
-	memcpy(ivi->mac, vf->addr.mac_addr, ETH_ALEN);
+	ether_addr_copy(ivi->mac, vf->addr.mac_addr);
 	ivi->tx_rate = 0;
 	tci = ntohs(vf->addr.tci);
 	ivi->vlan = tci & VLAN_VID_MASK;
-- 
1.7.11.7
