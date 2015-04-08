From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: Own header for nic-specific sriov functions,
 single instance of netdev_ops and sriov removed from Falcon code
Date: Wed, 8 Apr 2015 15:24:45 +0100
Message-ID: <55253A2D.8090901@solarflare.com>
References: <552539BA.6070707@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:18408 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932211AbbDHOYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 10:24:52 -0400
In-Reply-To: <552539BA.6070707@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By putting all the efx_{siena,ef10}_sriov_* declarations in
{siena,ef10}_sriov.h, ensure they cannot be called from nic-generic code.
Also fixes up an instance of this, where mcdi.c was calling
efx_siena_sriov_flr.

The single instance of netdev_ops should call general high level
functions that can then call something adapter specific in efx_nic_type.
We should only do adapter specialisation via efx_nic_type.

Removal of sriov functionality from the Falcon code means that tests
are needed for the presence of some callbacks.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/Makefile      |   2 +-
 drivers/net/ethernet/sfc/ef10.c        |   6 ++
 drivers/net/ethernet/sfc/ef10_sriov.h  |  56 +++++++++++++++++
 drivers/net/ethernet/sfc/efx.c         |  95 ++++++++++++----------------
 drivers/net/ethernet/sfc/efx.h         |   7 +++
 drivers/net/ethernet/sfc/falcon.c      |  10 ---
 drivers/net/ethernet/sfc/farch.c       |  48 +++++++-------
 drivers/net/ethernet/sfc/mcdi.c        |   4 +-
 drivers/net/ethernet/sfc/net_driver.h  |   8 +++
 drivers/net/ethernet/sfc/nic.h         | 111 ---------------------------------
 drivers/net/ethernet/sfc/siena.c       |   6 ++
 drivers/net/ethernet/sfc/siena_sriov.c |  53 +++++++++++++---
 drivers/net/ethernet/sfc/siena_sriov.h |  78 +++++++++++++++++++++++
 drivers/net/ethernet/sfc/sriov.c       |  64 +++++++++++++++++++
 drivers/net/ethernet/sfc/sriov.h       |  27 ++++++++
 15 files changed, 368 insertions(+), 207 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.h
 create mode 100644 drivers/net/ethernet/sfc/siena_sriov.h
 create mode 100644 drivers/net/ethernet/sfc/sriov.c
 create mode 100644 drivers/net/ethernet/sfc/sriov.h

diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
index 3a83c0d..a08a789 100644
--- a/drivers/net/ethernet/sfc/Makefile
+++ b/drivers/net/ethernet/sfc/Makefile
@@ -3,6 +3,6 @@ sfc-y			+= efx.o nic.o farch.o falcon.o siena.o ef10.o tx.o \
 			   tenxpress.o txc43128_phy.o falcon_boards.o \
 			   mcdi.o mcdi_port.o mcdi_mon.o ptp.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
-sfc-$(CONFIG_SFC_SRIOV)	+= siena_sriov.o
+sfc-$(CONFIG_SFC_SRIOV)	+= sriov.o siena_sriov.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index fbb6cfa..4dab1b9 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -15,6 +15,7 @@
 #include "nic.h"
 #include "workarounds.h"
 #include "selftest.h"
+#include "ef10_sriov.h"
 #include <linux/in.h>
 #include <linux/jhash.h>
 #include <linux/wait.h>
@@ -3694,6 +3695,11 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.sriov_mac_address_changed = efx_ef10_sriov_mac_address_changed,
 	.sriov_wanted = efx_ef10_sriov_wanted,
 	.sriov_reset = efx_ef10_sriov_reset,
+	.sriov_flr = efx_ef10_sriov_flr,
+	.sriov_set_vf_mac = efx_ef10_sriov_set_vf_mac,
+	.sriov_set_vf_vlan = efx_ef10_sriov_set_vf_vlan,
+	.sriov_set_vf_spoofchk = efx_ef10_sriov_set_vf_spoofchk,
+	.sriov_get_vf_config = efx_ef10_sriov_get_vf_config,
 
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
new file mode 100644
index 0000000..030bca4
--- /dev/null
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -0,0 +1,56 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF10_SRIOV_H
+#define EF10_SRIOV_H
+
+#include "net_driver.h"
+
+static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx)
+{
+	return false;
+}
+
+static inline int efx_ef10_sriov_init(struct efx_nic *efx)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void efx_ef10_sriov_mac_address_changed(struct efx_nic *efx) {}
+static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
+static inline void efx_ef10_sriov_fini(struct efx_nic *efx) {}
+static inline void efx_ef10_sriov_flr(struct efx_nic *efx, unsigned vf_i) {}
+
+#ifdef CONFIG_SFC_SRIOV
+static inline int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf,
+					    u8 *mac)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf,
+					     u16 vlan, u8 qos)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int efx_ef10_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf,
+						 bool spoofchk)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf,
+					       struct ifla_vf_info *ivf)
+{
+	return -EOPNOTSUPP;
+}
+#endif /* CONFIG_SFC_SRIOV */
+
+#endif /* EF10_SRIOV_H */
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 33d2f9a..232c766 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -26,6 +26,7 @@
 #include "efx.h"
 #include "nic.h"
 #include "selftest.h"
+#include "sriov.h"
 
 #include "mcdi.h"
 #include "workarounds.h"
@@ -1314,15 +1315,19 @@ static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
 	/* If RSS is requested for the PF *and* VFs then we can't write RSS
 	 * table entries that are inaccessible to VFs
 	 */
-	if (efx->type->sriov_wanted(efx) && efx_vf_size(efx) > 1 &&
-	    count > efx_vf_size(efx)) {
-		netif_warn(efx, probe, efx->net_dev,
-			   "Reducing number of RSS channels from %u to %u for "
-			   "VF support. Increase vf-msix-limit to use more "
-			   "channels on the PF.\n",
-			   count, efx_vf_size(efx));
-		count = efx_vf_size(efx);
+#ifdef CONFIG_SFC_SRIOV
+	if (efx->type->sriov_wanted) {
+		if (efx->type->sriov_wanted(efx) && efx_vf_size(efx) > 1 &&
+		    count > efx_vf_size(efx)) {
+			netif_warn(efx, probe, efx->net_dev,
+				   "Reducing number of RSS channels from %u to %u for "
+				   "VF support. Increase vf-msix-limit to use more "
+				   "channels on the PF.\n",
+				   count, efx_vf_size(efx));
+			count = efx_vf_size(efx);
+		}
 	}
+#endif
 
 	return count;
 }
@@ -1426,10 +1431,13 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 	}
 
 	/* RSS might be usable on VFs even if it is disabled on the PF */
-
-	efx->rss_spread = ((efx->n_rx_channels > 1 ||
-			    !efx->type->sriov_wanted(efx)) ?
-			   efx->n_rx_channels : efx_vf_size(efx));
+#ifdef CONFIG_SFC_SRIOV
+	if (efx->type->sriov_wanted) {
+		efx->rss_spread = ((efx->n_rx_channels > 1 ||
+				    !efx->type->sriov_wanted(efx)) ?
+				   efx->n_rx_channels : efx_vf_size(efx));
+	}
+#endif
 
 	return 0;
 }
@@ -2168,7 +2176,8 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	}
 
 	ether_addr_copy(net_dev->dev_addr, new_addr);
-	efx->type->sriov_mac_address_changed(efx);
+	if (efx->type->sriov_mac_address_changed)
+		efx->type->sriov_mac_address_changed(efx);
 
 	/* Reconfigure the MAC */
 	mutex_lock(&efx->mac_lock);
@@ -2199,7 +2208,7 @@ static int efx_set_features(struct net_device *net_dev, netdev_features_t data)
 	return 0;
 }
 
-static const struct net_device_ops efx_farch_netdev_ops = {
+static const struct net_device_ops efx_netdev_ops = {
 	.ndo_open		= efx_net_open,
 	.ndo_stop		= efx_net_stop,
 	.ndo_get_stats64	= efx_net_stats,
@@ -2212,10 +2221,10 @@ static const struct net_device_ops efx_farch_netdev_ops = {
 	.ndo_set_rx_mode	= efx_set_rx_mode,
 	.ndo_set_features	= efx_set_features,
 #ifdef CONFIG_SFC_SRIOV
-	.ndo_set_vf_mac		= efx_siena_sriov_set_vf_mac,
-	.ndo_set_vf_vlan	= efx_siena_sriov_set_vf_vlan,
-	.ndo_set_vf_spoofchk	= efx_siena_sriov_set_vf_spoofchk,
-	.ndo_get_vf_config	= efx_siena_sriov_get_vf_config,
+	.ndo_set_vf_mac		= efx_sriov_set_vf_mac,
+	.ndo_set_vf_vlan	= efx_sriov_set_vf_vlan,
+	.ndo_set_vf_spoofchk	= efx_sriov_set_vf_spoofchk,
+	.ndo_get_vf_config	= efx_sriov_get_vf_config,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
@@ -2229,29 +2238,6 @@ static const struct net_device_ops efx_farch_netdev_ops = {
 #endif
 };
 
-static const struct net_device_ops efx_ef10_netdev_ops = {
-	.ndo_open		= efx_net_open,
-	.ndo_stop		= efx_net_stop,
-	.ndo_get_stats64	= efx_net_stats,
-	.ndo_tx_timeout		= efx_watchdog,
-	.ndo_start_xmit		= efx_hard_start_xmit,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_do_ioctl		= efx_ioctl,
-	.ndo_change_mtu		= efx_change_mtu,
-	.ndo_set_mac_address	= efx_set_mac_address,
-	.ndo_set_rx_mode	= efx_set_rx_mode,
-	.ndo_set_features	= efx_set_features,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= efx_netpoll,
-#endif
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= efx_busy_poll,
-#endif
-#ifdef CONFIG_RFS_ACCEL
-	.ndo_rx_flow_steer	= efx_filter_rfs,
-#endif
-};
-
 static void efx_update_name(struct efx_nic *efx)
 {
 	strcpy(efx->name, efx->net_dev->name);
@@ -2264,8 +2250,7 @@ static int efx_netdev_event(struct notifier_block *this,
 {
 	struct net_device *net_dev = netdev_notifier_info_to_dev(ptr);
 
-	if ((net_dev->netdev_ops == &efx_farch_netdev_ops ||
-	     net_dev->netdev_ops == &efx_ef10_netdev_ops) &&
+	if ((net_dev->netdev_ops == &efx_netdev_ops) &&
 	    event == NETDEV_CHANGENAME)
 		efx_update_name(netdev_priv(net_dev));
 
@@ -2292,12 +2277,9 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 	net_dev->watchdog_timeo = 5 * HZ;
 	net_dev->irq = efx->pci_dev->irq;
-	if (efx_nic_rev(efx) >= EFX_REV_HUNT_A0) {
-		net_dev->netdev_ops = &efx_ef10_netdev_ops;
+	net_dev->netdev_ops = &efx_netdev_ops;
+	if (efx_nic_rev(efx) >= EFX_REV_HUNT_A0)
 		net_dev->priv_flags |= IFF_UNICAST_FLT;
-	} else {
-		net_dev->netdev_ops = &efx_farch_netdev_ops;
-	}
 	net_dev->ethtool_ops = &efx_ethtool_ops;
 	net_dev->gso_max_segs = EFX_TSO_MAX_SEGS;
 
@@ -2435,7 +2417,8 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	if (rc)
 		goto fail;
 	efx_restore_filters(efx);
-	efx->type->sriov_reset(efx);
+	if (efx->type->sriov_reset)
+		efx->type->sriov_reset(efx);
 
 	mutex_unlock(&efx->mac_lock);
 
@@ -2828,7 +2811,9 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	efx_disable_interrupts(efx);
 	rtnl_unlock();
 
-	efx->type->sriov_fini(efx);
+	if (efx->type->sriov_fini)
+		efx->type->sriov_fini(efx);
+
 	efx_unregister_netdev(efx);
 
 	efx_mtd_remove(efx);
@@ -3025,10 +3010,12 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	if (rc)
 		goto fail4;
 
-	rc = efx->type->sriov_init(efx);
-	if (rc)
-		netif_err(efx, probe, efx->net_dev,
-			  "SR-IOV can't be enabled rc %d\n", rc);
+	if (efx->type->sriov_init) {
+		rc = efx->type->sriov_init(efx);
+		if (rc)
+			netif_err(efx, probe, efx->net_dev,
+				  "SR-IOV can't be enabled rc %d\n", rc);
+	}
 
 	netif_dbg(efx, probe, efx->net_dev, "initialisation successful\n");
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 2587c58..bc4e4b3 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -220,6 +220,13 @@ static inline void efx_mtd_rename(struct efx_nic *efx) {}
 static inline void efx_mtd_remove(struct efx_nic *efx) {}
 #endif
 
+#ifdef CONFIG_SFC_SRIOV
+static inline unsigned int efx_vf_size(struct efx_nic *efx)
+{
+	return 1 << efx->vi_scale;
+}
+#endif
+
 static inline void efx_schedule_channel(struct efx_channel *channel)
 {
 	netif_vdbg(channel->efx, intr, channel->efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index f166c8e..1570375 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2766,11 +2766,6 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.mtd_write = falcon_mtd_write,
 	.mtd_sync = falcon_mtd_sync,
 #endif
-	.sriov_init = efx_falcon_sriov_init,
-	.sriov_fini = efx_falcon_sriov_fini,
-	.sriov_mac_address_changed = efx_falcon_sriov_mac_address_changed,
-	.sriov_wanted = efx_falcon_sriov_wanted,
-	.sriov_reset = efx_falcon_sriov_reset,
 
 	.revision = EFX_REV_FALCON_A1,
 	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
@@ -2867,11 +2862,6 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.mtd_write = falcon_mtd_write,
 	.mtd_sync = falcon_mtd_sync,
 #endif
-	.sriov_init = efx_falcon_sriov_init,
-	.sriov_fini = efx_falcon_sriov_fini,
-	.sriov_mac_address_changed = efx_falcon_sriov_mac_address_changed,
-	.sriov_wanted = efx_falcon_sriov_wanted,
-	.sriov_reset = efx_falcon_sriov_reset,
 
 	.revision = EFX_REV_FALCON_B0,
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index bb89e96..c3a032e 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -20,6 +20,8 @@
 #include "efx.h"
 #include "nic.h"
 #include "farch_regs.h"
+#include "sriov.h"
+#include "siena_sriov.h"
 #include "io.h"
 #include "workarounds.h"
 
@@ -1685,28 +1687,32 @@ void efx_farch_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw)
 	vi_count = max(efx->n_channels, efx->n_tx_channels * EFX_TXQ_TYPES);
 
 #ifdef CONFIG_SFC_SRIOV
-	if (efx->type->sriov_wanted(efx)) {
-		unsigned vi_dc_entries, buftbl_free, entries_per_vf, vf_limit;
-
-		nic_data->vf_buftbl_base = buftbl_min;
-
-		vi_dc_entries = RX_DC_ENTRIES + TX_DC_ENTRIES;
-		vi_count = max(vi_count, EFX_VI_BASE);
-		buftbl_free = (sram_lim_qw - buftbl_min -
-			       vi_count * vi_dc_entries);
-
-		entries_per_vf = ((vi_dc_entries + EFX_VF_BUFTBL_PER_VI) *
-				  efx_vf_size(efx));
-		vf_limit = min(buftbl_free / entries_per_vf,
-			       (1024U - EFX_VI_BASE) >> efx->vi_scale);
-
-		if (efx->vf_count > vf_limit) {
-			netif_err(efx, probe, efx->net_dev,
-				  "Reducing VF count from from %d to %d\n",
-				  efx->vf_count, vf_limit);
-			efx->vf_count = vf_limit;
+	if (efx->type->sriov_wanted) {
+		if (efx->type->sriov_wanted(efx)) {
+			unsigned vi_dc_entries, buftbl_free;
+			unsigned entries_per_vf, vf_limit;
+
+			nic_data->vf_buftbl_base = buftbl_min;
+
+			vi_dc_entries = RX_DC_ENTRIES + TX_DC_ENTRIES;
+			vi_count = max(vi_count, EFX_VI_BASE);
+			buftbl_free = (sram_lim_qw - buftbl_min -
+				       vi_count * vi_dc_entries);
+
+			entries_per_vf = ((vi_dc_entries +
+					   EFX_VF_BUFTBL_PER_VI) *
+					  efx_vf_size(efx));
+			vf_limit = min(buftbl_free / entries_per_vf,
+				       (1024U - EFX_VI_BASE) >> efx->vi_scale);
+
+			if (efx->vf_count > vf_limit) {
+				netif_err(efx, probe, efx->net_dev,
+					  "Reducing VF count from from %d to %d\n",
+					  efx->vf_count, vf_limit);
+				efx->vf_count = vf_limit;
+			}
+			vi_count += efx->vf_count * efx_vf_size(efx);
 		}
-		vi_count += efx->vf_count * efx_vf_size(efx);
 	}
 #endif
 
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index d37928f..6502ada 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1035,7 +1035,9 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		/* MAC stats are gather lazily.  We can ignore this. */
 		break;
 	case MCDI_EVENT_CODE_FLR:
-		efx_siena_sriov_flr(efx, MCDI_EVENT_FIELD(*event, FLR_VF));
+		if (efx->type->sriov_flr)
+			efx->type->sriov_flr(efx,
+					     MCDI_EVENT_FIELD(*event, FLR_VF));
 		break;
 	case MCDI_EVENT_CODE_PTP_RX:
 	case MCDI_EVENT_CODE_PTP_FAULT:
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 325dd94..ae0d145 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1335,6 +1335,14 @@ struct efx_nic_type {
 	void (*sriov_mac_address_changed)(struct efx_nic *efx);
 	bool (*sriov_wanted)(struct efx_nic *efx);
 	void (*sriov_reset)(struct efx_nic *efx);
+	void (*sriov_flr)(struct efx_nic *efx, unsigned vf_i);
+	int (*sriov_set_vf_mac)(struct efx_nic *efx, int vf_i, u8 *mac);
+	int (*sriov_set_vf_vlan)(struct efx_nic *efx, int vf_i, u16 vlan,
+				 u8 qos);
+	int (*sriov_set_vf_spoofchk)(struct efx_nic *efx, int vf_i,
+				     bool spoofchk);
+	int (*sriov_get_vf_config)(struct efx_nic *efx, int vf_i,
+				   struct ifla_vf_info *ivi);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 93d10cbb..ea4ca18 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -509,120 +509,9 @@ struct efx_ef10_nic_data {
 	u32 datapath_caps;
 };
 
-/*
- * On the SFC9000 family each port is associated with 1 PCI physical
- * function (PF) handled by sfc and a configurable number of virtual
- * functions (VFs) that may be handled by some other driver, often in
- * a VM guest.  The queue pointer registers are mapped in both PF and
- * VF BARs such that an 8K region provides access to a single RX, TX
- * and event queue (collectively a Virtual Interface, VI or VNIC).
- *
- * The PF has access to all 1024 VIs while VFs are mapped to VIs
- * according to VI_BASE and VI_SCALE: VF i has access to VIs numbered
- * in range [VI_BASE + i << VI_SCALE, VI_BASE + i + 1 << VI_SCALE).
- * The number of VIs and the VI_SCALE value are configurable but must
- * be established at boot time by firmware.
- */
-
-/* Maximum VI_SCALE parameter supported by Siena */
-#define EFX_VI_SCALE_MAX 6
-/* Base VI to use for SR-IOV. Must be aligned to (1 << EFX_VI_SCALE_MAX),
- * so this is the smallest allowed value. */
-#define EFX_VI_BASE 128U
-/* Maximum number of VFs allowed */
-#define EFX_VF_COUNT_MAX 127
-/* Limit EVQs on VFs to be only 8k to reduce buffer table reservation */
-#define EFX_MAX_VF_EVQ_SIZE 8192UL
-/* The number of buffer table entries reserved for each VI on a VF */
-#define EFX_VF_BUFTBL_PER_VI					\
-	((EFX_MAX_VF_EVQ_SIZE + 2 * EFX_MAX_DMAQ_SIZE) *	\
-	 sizeof(efx_qword_t) / EFX_BUF_SIZE)
-
-#ifdef CONFIG_SFC_SRIOV
-
-/* SIENA */
-static inline bool efx_siena_sriov_wanted(struct efx_nic *efx)
-{
-	return efx->vf_count != 0;
-}
-
-static inline bool efx_siena_sriov_enabled(struct efx_nic *efx)
-{
-	return efx->vf_init_count != 0;
-}
-
-static inline unsigned int efx_vf_size(struct efx_nic *efx)
-{
-	return 1 << efx->vi_scale;
-}
-
 int efx_init_sriov(void);
-void efx_siena_sriov_probe(struct efx_nic *efx);
-int efx_siena_sriov_init(struct efx_nic *efx);
-void efx_siena_sriov_mac_address_changed(struct efx_nic *efx);
-void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event);
-void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event);
-void efx_siena_sriov_event(struct efx_channel *channel, efx_qword_t *event);
-void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq);
-void efx_siena_sriov_flr(struct efx_nic *efx, unsigned flr);
-void efx_siena_sriov_reset(struct efx_nic *efx);
-void efx_siena_sriov_fini(struct efx_nic *efx);
 void efx_fini_sriov(void);
 
-/* EF10 */
-static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx) { return false; }
-static inline int efx_ef10_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
-static inline void efx_ef10_sriov_mac_address_changed(struct efx_nic *efx) {}
-static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
-static inline void efx_ef10_sriov_fini(struct efx_nic *efx) {}
-
-#else
-
-/* SIENA */
-static inline bool efx_siena_sriov_wanted(struct efx_nic *efx) { return false; }
-static inline bool efx_siena_sriov_enabled(struct efx_nic *efx) { return false; }
-static inline unsigned int efx_vf_size(struct efx_nic *efx) { return 0; }
-static inline int efx_init_sriov(void) { return 0; }
-static inline void efx_siena_sriov_probe(struct efx_nic *efx) {}
-static inline int efx_siena_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
-static inline void efx_siena_sriov_mac_address_changed(struct efx_nic *efx) {}
-static inline void efx_siena_sriov_tx_flush_done(struct efx_nic *efx,
-						 efx_qword_t *event) {}
-static inline void efx_siena_sriov_rx_flush_done(struct efx_nic *efx,
-						 efx_qword_t *event) {}
-static inline void efx_siena_sriov_event(struct efx_channel *channel,
-					 efx_qword_t *event) {}
-static inline void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx,
-						  unsigned dmaq) {}
-static inline void efx_siena_sriov_flr(struct efx_nic *efx, unsigned flr) {}
-static inline void efx_siena_sriov_reset(struct efx_nic *efx) {}
-static inline void efx_siena_sriov_fini(struct efx_nic *efx) {}
-static inline void efx_fini_sriov(void) {}
-
-/* EF10 */
-static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx) { return false; }
-static inline int efx_ef10_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
-static inline void efx_ef10_sriov_mac_address_changed(struct efx_nic *efx) {}
-static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
-static inline void efx_ef10_sriov_fini(struct efx_nic *efx) {}
-
-#endif
-
-/* FALCON */
-static inline bool efx_falcon_sriov_wanted(struct efx_nic *efx) { return false; }
-static inline int efx_falcon_sriov_init(struct efx_nic *efx) { return -EOPNOTSUPP; }
-static inline void efx_falcon_sriov_mac_address_changed(struct efx_nic *efx) {}
-static inline void efx_falcon_sriov_reset(struct efx_nic *efx) {}
-static inline void efx_falcon_sriov_fini(struct efx_nic *efx) {}
-
-int efx_siena_sriov_set_vf_mac(struct net_device *dev, int vf, u8 *mac);
-int efx_siena_sriov_set_vf_vlan(struct net_device *dev, int vf,
-				u16 vlan, u8 qos);
-int efx_siena_sriov_get_vf_config(struct net_device *dev, int vf,
-				  struct ifla_vf_info *ivf);
-int efx_siena_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
-				    bool spoofchk);
-
 struct ethtool_ts_info;
 int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel);
 void efx_ptp_defer_probe_with_channel(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 3583f02..3671e1d 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -25,6 +25,7 @@
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 #include "selftest.h"
+#include "siena_sriov.h"
 
 /* Hardware control for SFC9000 family including SFL9021 (aka Siena). */
 
@@ -1002,6 +1003,11 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.sriov_mac_address_changed = efx_siena_sriov_mac_address_changed,
 	.sriov_wanted = efx_siena_sriov_wanted,
 	.sriov_reset = efx_siena_sriov_reset,
+	.sriov_flr = efx_siena_sriov_flr,
+	.sriov_set_vf_mac = efx_siena_sriov_set_vf_mac,
+	.sriov_set_vf_vlan = efx_siena_sriov_set_vf_vlan,
+	.sriov_set_vf_spoofchk = efx_siena_sriov_set_vf_spoofchk,
+	.sriov_get_vf_config = efx_siena_sriov_get_vf_config,
 
 	.revision = EFX_REV_SIENA_A0,
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index fe83430..ccadd46 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -16,6 +16,7 @@
 #include "filter.h"
 #include "mcdi_pcol.h"
 #include "farch_regs.h"
+#include "siena_sriov.h"
 #include "vfdi.h"
 
 /* Number of longs required to track all the VIs in a VF */
@@ -1050,6 +1051,7 @@ static const struct efx_channel_type efx_siena_sriov_channel_type = {
 
 void efx_siena_sriov_probe(struct efx_nic *efx)
 {
+#ifdef CONFIG_SFC_SRIOV
 	unsigned count;
 
 	if (!max_vfs)
@@ -1064,8 +1066,10 @@ void efx_siena_sriov_probe(struct efx_nic *efx)
 	efx->vf_count = count;
 
 	efx->extra_channel_type[EFX_EXTRA_CHANNEL_IOV] = &efx_siena_sriov_channel_type;
+#endif
 }
 
+#ifdef CONFIG_SFC_SRIOV
 /* Copy the list of individual addresses into the vfdi_status.peers
  * array and auxiliary pages, protected by %local_lock. Drop that lock
  * and then broadcast the address list to every VF.
@@ -1276,9 +1280,11 @@ fail:
 	efx_siena_sriov_vfs_fini(efx);
 	return rc;
 }
+#endif
 
 int efx_siena_sriov_init(struct efx_nic *efx)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct net_device *net_dev = efx->net_dev;
 	struct siena_nic_data *nic_data = efx->nic_data;
 	struct vfdi_status *vfdi_status;
@@ -1357,10 +1363,14 @@ fail_status:
 	efx_siena_sriov_cmd(efx, false, NULL, NULL);
 fail_cmd:
 	return rc;
+#else /* CONFIG_SFC_SRIOV */
+	return -EOPNOTSUPP;
+#endif
 }
 
 void efx_siena_sriov_fini(struct efx_nic *efx)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct efx_vf *vf;
 	unsigned int pos;
 	struct siena_nic_data *nic_data = efx->nic_data;
@@ -1391,10 +1401,12 @@ void efx_siena_sriov_fini(struct efx_nic *efx)
 	kfree(efx->vf);
 	efx_nic_free_buffer(efx, &nic_data->vfdi_status);
 	efx_siena_sriov_cmd(efx, false, NULL, NULL);
+#endif /* CONFIG_SFC_SRIOV*/
 }
 
 void efx_siena_sriov_event(struct efx_channel *channel, efx_qword_t *event)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct efx_nic *efx = channel->efx;
 	struct efx_vf *vf;
 	unsigned qid, seq, type, data;
@@ -1448,10 +1460,12 @@ error:
 	/* Reset the request and sequence number */
 	vf->req_type = VFDI_EV_TYPE_REQ_WORD0;
 	vf->req_seqno = seq + 1;
+#endif /* CONFIG_SFC_SRIOV */
 }
 
 void efx_siena_sriov_flr(struct efx_nic *efx, unsigned vf_i)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct efx_vf *vf;
 
 	if (vf_i > efx->vf_init_count)
@@ -1465,10 +1479,12 @@ void efx_siena_sriov_flr(struct efx_nic *efx, unsigned vf_i)
 	efx_vfdi_flush_clear(vf);
 
 	vf->evq0_count = 0;
+#endif /* CONFIG_SFC_SRIOV */
 }
 
 void efx_siena_sriov_mac_address_changed(struct efx_nic *efx)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct siena_nic_data *nic_data = efx->nic_data;
 	struct vfdi_status *vfdi_status = nic_data->vfdi_status.addr;
 
@@ -1477,10 +1493,12 @@ void efx_siena_sriov_mac_address_changed(struct efx_nic *efx)
 	ether_addr_copy(vfdi_status->peers[0].mac_addr,
 			efx->net_dev->dev_addr);
 	queue_work(vfdi_workqueue, &nic_data->peer_work);
+#endif /* CONFIG_SFC_SRIOV */
 }
 
 void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct efx_vf *vf;
 	unsigned queue, qid;
 
@@ -1496,10 +1514,12 @@ void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 
 	if (efx_vfdi_flush_wake(vf))
 		wake_up(&vf->flush_waitq);
+#endif /* CONFIG_SFC_SRIOV */
 }
 
 void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct efx_vf *vf;
 	unsigned ev_failed, queue, qid;
 
@@ -1520,11 +1540,13 @@ void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 	}
 	if (efx_vfdi_flush_wake(vf))
 		wake_up(&vf->flush_waitq);
+#endif /* CONFIG_SFC_SRIOV */
 }
 
 /* Called from napi. Schedule the reset work item */
 void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
 {
+#ifdef CONFIG_SFC_SRIOV
 	struct efx_vf *vf;
 	unsigned int rel;
 
@@ -1536,11 +1558,13 @@ void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
 			  "VF %d DMA Q %d reports descriptor fetch error.\n",
 			  vf->index, rel);
 	queue_work(vfdi_workqueue, &vf->reset_work);
+#endif /* CONFIG_SFC_SRIOV */
 }
 
 /* Reset all VFs */
 void efx_siena_sriov_reset(struct efx_nic *efx)
 {
+#ifdef CONFIG_SFC_SRIOV
 	unsigned int vf_i;
 	struct efx_buffer buf;
 	struct efx_vf *vf;
@@ -1562,10 +1586,12 @@ void efx_siena_sriov_reset(struct efx_nic *efx)
 	}
 
 	efx_nic_free_buffer(efx, &buf);
+#endif /* CONFIG_SFC_SRIOV */
 }
 
 int efx_init_sriov(void)
 {
+#ifdef CONFIG_SFC_SRIOV
 	/* A single threaded workqueue is sufficient. efx_siena_sriov_vfdi() and
 	 * efx_siena_sriov_peer_work() spend almost all their time sleeping for
 	 * MCDI to complete anyway
@@ -1573,18 +1599,20 @@ int efx_init_sriov(void)
 	vfdi_workqueue = create_singlethread_workqueue("sfc_vfdi");
 	if (!vfdi_workqueue)
 		return -ENOMEM;
-
+#endif
 	return 0;
 }
 
 void efx_fini_sriov(void)
 {
+#ifdef CONFIG_SFC_SRIOV
 	destroy_workqueue(vfdi_workqueue);
+#endif
 }
 
-int efx_siena_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
+#ifdef CONFIG_SFC_SRIOV
+int efx_siena_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
 {
-	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
 
 	if (vf_i >= efx->vf_init_count)
@@ -1599,10 +1627,9 @@ int efx_siena_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
 	return 0;
 }
 
-int efx_siena_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i,
+int efx_siena_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i,
 				u16 vlan, u8 qos)
 {
-	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
 	u16 tci;
 
@@ -1619,10 +1646,9 @@ int efx_siena_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i,
 	return 0;
 }
 
-int efx_siena_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
+int efx_siena_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf_i,
 				    bool spoofchk)
 {
-	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
 	int rc;
 
@@ -1643,10 +1669,9 @@ int efx_siena_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
 	return rc;
 }
 
-int efx_siena_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
+int efx_siena_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 				  struct ifla_vf_info *ivi)
 {
-	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_vf *vf;
 	u16 tci;
 
@@ -1666,3 +1691,13 @@ int efx_siena_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
 	return 0;
 }
 
+#endif /* CONFIG_SFC_SRIOV */
+
+bool efx_siena_sriov_wanted(struct efx_nic *efx)
+{
+#ifdef CONFIG_SFC_SRIOV
+	return efx->vf_count != 0;
+#else
+	return false;
+#endif
+}
diff --git a/drivers/net/ethernet/sfc/siena_sriov.h b/drivers/net/ethernet/sfc/siena_sriov.h
new file mode 100644
index 0000000..5014ae4
--- /dev/null
+++ b/drivers/net/ethernet/sfc/siena_sriov.h
@@ -0,0 +1,78 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef SIENA_SRIOV_H
+#define SIENA_SRIOV_H
+
+#include "net_driver.h"
+
+/* On the SFC9000 family each port is associated with 1 PCI physical
+ * function (PF) handled by sfc and a configurable number of virtual
+ * functions (VFs) that may be handled by some other driver, often in
+ * a VM guest.  The queue pointer registers are mapped in both PF and
+ * VF BARs such that an 8K region provides access to a single RX, TX
+ * and event queue (collectively a Virtual Interface, VI or VNIC).
+ *
+ * The PF has access to all 1024 VIs while VFs are mapped to VIs
+ * according to VI_BASE and VI_SCALE: VF i has access to VIs numbered
+ * in range [VI_BASE + i << VI_SCALE, VI_BASE + i + 1 << VI_SCALE).
+ * The number of VIs and the VI_SCALE value are configurable but must
+ * be established at boot time by firmware.
+ */
+
+/* Maximum VI_SCALE parameter supported by Siena */
+#define EFX_VI_SCALE_MAX 6
+/* Base VI to use for SR-IOV. Must be aligned to (1 << EFX_VI_SCALE_MAX),
+ * so this is the smallest allowed value.
+ */
+#define EFX_VI_BASE 128U
+/* Maximum number of VFs allowed */
+#define EFX_VF_COUNT_MAX 127
+/* Limit EVQs on VFs to be only 8k to reduce buffer table reservation */
+#define EFX_MAX_VF_EVQ_SIZE 8192UL
+/* The number of buffer table entries reserved for each VI on a VF */
+#define EFX_VF_BUFTBL_PER_VI					\
+	((EFX_MAX_VF_EVQ_SIZE + 2 * EFX_MAX_DMAQ_SIZE) *	\
+	 sizeof(efx_qword_t) / EFX_BUF_SIZE)
+
+int efx_siena_sriov_init(struct efx_nic *efx);
+void efx_siena_sriov_fini(struct efx_nic *efx);
+void efx_siena_sriov_mac_address_changed(struct efx_nic *efx);
+bool efx_siena_sriov_wanted(struct efx_nic *efx);
+void efx_siena_sriov_reset(struct efx_nic *efx);
+void efx_siena_sriov_flr(struct efx_nic *efx, unsigned flr);
+
+#ifdef CONFIG_SFC_SRIOV
+
+int efx_siena_sriov_set_vf_mac(struct efx_nic *efx, int vf, u8 *mac);
+int efx_siena_sriov_set_vf_vlan(struct efx_nic *efx, int vf,
+				u16 vlan, u8 qos);
+int efx_siena_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf,
+				    bool spoofchk);
+int efx_siena_sriov_get_vf_config(struct efx_nic *efx, int vf,
+				  struct ifla_vf_info *ivf);
+
+static inline bool efx_siena_sriov_enabled(struct efx_nic *efx)
+{
+	return efx->vf_init_count != 0;
+}
+#else /* !CONFIG_SFC_SRIOV */
+static inline bool efx_siena_sriov_enabled(struct efx_nic *efx)
+{
+	return false;
+}
+#endif /* CONFIG_SFC_SRIOV */
+
+void efx_siena_sriov_probe(struct efx_nic *efx);
+void efx_siena_sriov_tx_flush_done(struct efx_nic *efx, efx_qword_t *event);
+void efx_siena_sriov_rx_flush_done(struct efx_nic *efx, efx_qword_t *event);
+void efx_siena_sriov_event(struct efx_channel *channel, efx_qword_t *event);
+void efx_siena_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq);
+
+#endif /* SIENA_SRIOV_H */
diff --git a/drivers/net/ethernet/sfc/sriov.c b/drivers/net/ethernet/sfc/sriov.c
new file mode 100644
index 0000000..ea0b6e7
--- /dev/null
+++ b/drivers/net/ethernet/sfc/sriov.c
@@ -0,0 +1,64 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2014-2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+#include <linux/module.h>
+#include "net_driver.h"
+#include "nic.h"
+#include "sriov.h"
+
+#ifdef CONFIG_SFC_SRIOV
+
+int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->sriov_set_vf_mac)
+		return efx->type->sriov_set_vf_mac(efx, vf_i, mac);
+	else
+		return -EOPNOTSUPP;
+}
+
+int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i, u16 vlan,
+			  u8 qos)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->sriov_set_vf_vlan) {
+		if ((vlan & ~VLAN_VID_MASK) ||
+		    (qos & ~(VLAN_PRIO_MASK >> VLAN_PRIO_SHIFT)))
+			return -EINVAL;
+
+		return efx->type->sriov_set_vf_vlan(efx, vf_i, vlan, qos);
+	} else {
+		return -EOPNOTSUPP;
+	}
+}
+
+int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
+			      bool spoofchk)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->sriov_set_vf_spoofchk)
+		return efx->type->sriov_set_vf_spoofchk(efx, vf_i, spoofchk);
+	else
+		return -EOPNOTSUPP;
+}
+
+int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
+			    struct ifla_vf_info *ivi)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->sriov_get_vf_config)
+		return efx->type->sriov_get_vf_config(efx, vf_i, ivi);
+	else
+		return -EOPNOTSUPP;
+}
+
+#endif
diff --git a/drivers/net/ethernet/sfc/sriov.h b/drivers/net/ethernet/sfc/sriov.h
new file mode 100644
index 0000000..0b9f0f6
--- /dev/null
+++ b/drivers/net/ethernet/sfc/sriov.h
@@ -0,0 +1,27 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2014-2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_SRIOV_H
+#define EFX_SRIOV_H
+
+#include "net_driver.h"
+
+#ifdef CONFIG_SFC_SRIOV
+
+int efx_sriov_set_vf_mac(struct net_device *net_dev, int vf_i, u8 *mac);
+int efx_sriov_set_vf_vlan(struct net_device *net_dev, int vf_i, u16 vlan,
+			  u8 qos);
+int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
+			      bool spoofchk);
+int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
+			    struct ifla_vf_info *ivi);
+
+#endif /* CONFIG_SFC_SRIOV */
+
+#endif /* EFX_SRIOV_H */
