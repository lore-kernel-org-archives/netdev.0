From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/16] sfc: Cleanup Falcon-arch simple MAC filter
 state
Date: Tue, 27 Aug 2013 21:50:15 +0100
Message-ID: <1377636615.13272.88.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6188 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064Ab3H0UuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:50:18 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Falcon we implement MAC filtering requested by the stack using the
MAC wrapper's single unicast filter and multicast hash filter.  Siena
is very similar, though MAC configuration is mediated by the MC.

Since MCDI operations may sleep, reconfiguration is deferred from
ndo_set_rx_mode to a work item.  However, it still updates the private
variables describing the filter state synchronously.  Contrary to
comments, the later use of these variables is not protected using the
address lock, resulting in race conditions.

Move the state update to a new function
efx_farch_filter_sync_rx_mode() and make the Falcon-arch MAC
configuration functions call that, so that its use is consistently
serialised by the mac_lock.

Invert and rename the promiscuous flag to the more accurate
unicast_filter, and comment that both this and multicast_hash are
not used on EF10.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 34 ++--------------------------------
 drivers/net/ethernet/sfc/falcon.c     |  6 ++++--
 drivers/net/ethernet/sfc/farch.c      | 34 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/mcdi_port.c  | 11 ++++-------
 drivers/net/ethernet/sfc/net_driver.h |  8 +++++---
 drivers/net/ethernet/sfc/nic.h        |  1 +
 drivers/net/ethernet/sfc/siena.c      |  2 ++
 7 files changed, 52 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index a2daaae..1d4f388 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -17,7 +17,6 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/in.h>
-#include <linux/crc32.h>
 #include <linux/ethtool.h>
 #include <linux/topology.h>
 #include <linux/gfp.h>
@@ -876,10 +875,9 @@ void efx_link_status_changed(struct efx_nic *efx)
 	/* Status message for kernel log */
 	if (link_state->up)
 		netif_info(efx, link, efx->net_dev,
-			   "link up at %uMbps %s-duplex (MTU %d)%s\n",
+			   "link up at %uMbps %s-duplex (MTU %d)\n",
 			   link_state->speed, link_state->fd ? "full" : "half",
-			   efx->net_dev->mtu,
-			   (efx->promiscuous ? " [PROMISC]" : ""));
+			   efx->net_dev->mtu);
 	else
 		netif_info(efx, link, efx->net_dev, "link down\n");
 }
@@ -928,10 +926,6 @@ int __efx_reconfigure_port(struct efx_nic *efx)
 
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 
-	/* Serialise the promiscuous flag with efx_set_rx_mode. */
-	netif_addr_lock_bh(efx->net_dev);
-	netif_addr_unlock_bh(efx->net_dev);
-
 	/* Disable PHY transmit in mac level loopbacks */
 	phy_mode = efx->phy_mode;
 	if (LOOPBACK_INTERNAL(efx))
@@ -2027,30 +2021,6 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 static void efx_set_rx_mode(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	struct netdev_hw_addr *ha;
-	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
-	u32 crc;
-	int bit;
-
-	efx->promiscuous = !!(net_dev->flags & IFF_PROMISC);
-
-	/* Build multicast hash table */
-	if (efx->promiscuous || (net_dev->flags & IFF_ALLMULTI)) {
-		memset(mc_hash, 0xff, sizeof(*mc_hash));
-	} else {
-		memset(mc_hash, 0x00, sizeof(*mc_hash));
-		netdev_for_each_mc_addr(ha, net_dev) {
-			crc = ether_crc_le(ETH_ALEN, ha->addr);
-			bit = crc & (EFX_MCAST_HASH_ENTRIES - 1);
-			__set_bit_le(bit, mc_hash);
-		}
-
-		/* Broadcast packets go through the multicast hash filter.
-		 * ether_crc_le() of the broadcast address is 0xbe2612ff
-		 * so we always add bit 0xff to the mask.
-		 */
-		__set_bit_le(0xff, mc_hash);
-	}
 
 	if (efx->port_enabled)
 		queue_work(efx->workqueue, &efx->mac_work);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 6ea28f8..983e7f5 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -764,7 +764,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     FRF_AB_XM_RXEN, 1,
 			     FRF_AB_XM_AUTO_DEPAD, 0,
 			     FRF_AB_XM_ACPT_ALL_MCAST, 1,
-			     FRF_AB_XM_ACPT_ALL_UCAST, efx->promiscuous,
+			     FRF_AB_XM_ACPT_ALL_UCAST, !efx->unicast_filter,
 			     FRF_AB_XM_PASS_CRC_ERR, 1);
 	efx_writeo(efx, &reg, FR_AB_XM_RX_CFG);
 
@@ -864,6 +864,8 @@ static int falcon_reconfigure_xmac(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 
+	efx_farch_filter_sync_rx_mode(efx);
+
 	falcon_reconfigure_xgxs_core(efx);
 	falcon_reconfigure_xmac_core(efx);
 
@@ -1081,7 +1083,7 @@ static void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	EFX_POPULATE_OWORD_5(reg,
 			     FRF_AB_MAC_XOFF_VAL, 0xffff /* max pause time */,
 			     FRF_AB_MAC_BCAD_ACPT, 1,
-			     FRF_AB_MAC_UC_PROM, efx->promiscuous,
+			     FRF_AB_MAC_UC_PROM, !efx->unicast_filter,
 			     FRF_AB_MAC_LINK_STATUS, 1, /* always set */
 			     FRF_AB_MAC_SPEED, link_speed);
 	/* On B0, MAC backpressure can be disabled and packets get
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 1e21e51..b6af8f4 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -14,6 +14,7 @@
 #include <linux/pci.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
+#include <linux/crc32.h>
 #include "net_driver.h"
 #include "bitfield.h"
 #include "efx.h"
@@ -2906,3 +2907,36 @@ bool efx_farch_filter_rfs_expire_one(struct efx_nic *efx, u32 flow_id,
 }
 
 #endif /* CONFIG_RFS_ACCEL */
+
+void efx_farch_filter_sync_rx_mode(struct efx_nic *efx)
+{
+	struct net_device *net_dev = efx->net_dev;
+	struct netdev_hw_addr *ha;
+	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
+	u32 crc;
+	int bit;
+
+	netif_addr_lock_bh(net_dev);
+
+	efx->unicast_filter = !(net_dev->flags & IFF_PROMISC);
+
+	/* Build multicast hash table */
+	if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
+		memset(mc_hash, 0xff, sizeof(*mc_hash));
+	} else {
+		memset(mc_hash, 0x00, sizeof(*mc_hash));
+		netdev_for_each_mc_addr(ha, net_dev) {
+			crc = ether_crc_le(ETH_ALEN, ha->addr);
+			bit = crc & (EFX_MCAST_HASH_ENTRIES - 1);
+			__set_bit_le(bit, mc_hash);
+		}
+
+		/* Broadcast packets go through the multicast hash filter.
+		 * ether_crc_le() of the broadcast address is 0xbe2612ff
+		 * so we always add bit 0xff to the mask.
+		 */
+		__set_bit_le(0xff, mc_hash);
+	}
+
+	netif_addr_unlock_bh(net_dev);
+}
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 30e8a19..42d52f3 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -861,7 +861,7 @@ void efx_mcdi_process_link_change(struct efx_nic *efx, efx_qword_t *ev)
 
 int efx_mcdi_set_mac(struct efx_nic *efx)
 {
-	u32 reject, fcntl;
+	u32 fcntl;
 	MCDI_DECLARE_BUF(cmdbytes, MC_CMD_SET_MAC_IN_LEN);
 
 	BUILD_BUG_ON(MC_CMD_SET_MAC_OUT_LEN != 0);
@@ -873,12 +873,9 @@ int efx_mcdi_set_mac(struct efx_nic *efx)
 			EFX_MAX_FRAME_LEN(efx->net_dev->mtu));
 	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_DRAIN, 0);
 
-	/* The MCDI command provides for controlling accept/reject
-	 * of broadcast packets too, but the driver doesn't currently
-	 * expose this. */
-	reject = (efx->promiscuous) ? 0 :
-		(1 << MC_CMD_SET_MAC_IN_REJECT_UNCST_LBN);
-	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_REJECT, reject);
+	/* Set simple MAC filter for Siena */
+	MCDI_POPULATE_DWORD_1(cmdbytes, SET_MAC_IN_REJECT,
+			      SET_MAC_IN_REJECT_UNCST, efx->unicast_filter);
 
 	switch (efx->wanted_fc) {
 	case EFX_FC_RX | EFX_FC_TX:
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index d35ce14..555dd01 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -753,8 +753,10 @@ struct vfdi_status;
  * @link_advertising: Autonegotiation advertising flags
  * @link_state: Current state of the link
  * @n_link_state_changes: Number of times the link has changed state
- * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
- * @multicast_hash: Multicast hash table
+ * @unicast_filter: Flag for Falcon-arch simple unicast filter.
+ *	Protected by @mac_lock.
+ * @multicast_hash: Multicast hash table for Falcon-arch.
+ *	Protected by @mac_lock.
  * @wanted_fc: Wanted flow control flags
  * @fc_disable: When non-zero flow control is disabled. Typically used to
  *	ensure that network back pressure doesn't delay dma queue flushes.
@@ -892,7 +894,7 @@ struct efx_nic {
 	struct efx_link_state link_state;
 	unsigned int n_link_state_changes;
 
-	bool promiscuous;
+	bool unicast_filter;
 	union efx_multicast_hash multicast_hash;
 	u8 wanted_fc;
 	unsigned fc_disable;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 69298c9..8baf6a1 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -431,6 +431,7 @@ extern s32 efx_farch_filter_rfs_insert(struct efx_nic *efx,
 extern bool efx_farch_filter_rfs_expire_one(struct efx_nic *efx, u32 flow_id,
 					    unsigned int index);
 #endif
+extern void efx_farch_filter_sync_rx_mode(struct efx_nic *efx);
 
 extern bool efx_nic_event_present(struct efx_channel *channel);
 
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 5120cd8..1be81e4 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -503,6 +503,8 @@ static int siena_mac_reconfigure(struct efx_nic *efx)
 		     MC_CMD_SET_MCAST_HASH_IN_HASH0_OFST +
 		     sizeof(efx->multicast_hash));
 
+	efx_farch_filter_sync_rx_mode(efx);
+
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 
 	rc = efx_mcdi_set_mac(efx);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
