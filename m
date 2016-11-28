From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next] sfc: separate out SFC4000 ("Falcon") support into
 new sfc-falcon driver
Date: Mon, 28 Nov 2016 18:55:34 +0000
Message-ID: <624b8ce9-12dd-1b89-ae9f-8a092751bf12@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:42677 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751824AbcK1S4B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 13:56:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rationale: The differences between Falcon and Siena are in many ways larger
 than those between Siena and EF10 (despite Siena being nominally "Falcon-
 architecture"); for instance, Falcon has no MCPU, so there is no MCDI.
 Removing Falcon support from the sfc driver should simplify the latter,
 and avoid the possibility of Falcon support being broken by changes to sfc
 (which are rarely if ever tested on Falcon, it being end-of-lifed hardware).

The sfc-falcon driver created in this changeset is essentially a copy of the
 sfc driver, but with Siena- and EF10-specific code, including MCDI, removed
 and with the "efx_" identifier prefix changed to "ef4_" (for "EFX 4000-
 series") to avoid collisions when both drivers are built-in.

This changeset removes Falcon from the sfc driver's PCI ID table; then in
 sfc I've removed obvious Falcon-related code: I removed the Falcon NIC
 functions, Falcon PHY code, and EFX_REV_FALCON_*, then fixed up everything
 that referenced them.

Also, increment minor version of both drivers (to 4.1).

For now, CONFIG_SFC selects CONFIG_SFC_FALCON, so that updating old configs
 doesn't cause Falcon support to disappear; but that should be undone at
 some point in the future.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
v2: squashed both patches together, and rebased.  No other changes.
I'm now having doubts about the Kconfig select mentioned above; what's the
usual practice when splitting up a driver?  I would use "imply", but I
don't think that's landed yet.
---
 drivers/net/ethernet/Kconfig                    |    1 +
 drivers/net/ethernet/Makefile                   |    1 +
 drivers/net/ethernet/sfc/Kconfig                |    8 +-
 drivers/net/ethernet/sfc/Makefile               |    7 +-
 drivers/net/ethernet/sfc/efx.c                  |   29 +-
 drivers/net/ethernet/sfc/ethtool.c              |   15 +-
 drivers/net/ethernet/sfc/falcon.c               | 2907 --------------------
 drivers/net/ethernet/sfc/falcon/Kconfig         |   21 +
 drivers/net/ethernet/sfc/falcon/Makefile        |    6 +
 drivers/net/ethernet/sfc/falcon/bitfield.h      |  542 ++++
 drivers/net/ethernet/sfc/falcon/efx.c           | 3350 +++++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/efx.h           |  277 ++
 drivers/net/ethernet/sfc/falcon/enum.h          |  171 ++
 drivers/net/ethernet/sfc/falcon/ethtool.c       | 1343 +++++++++
 drivers/net/ethernet/sfc/falcon/falcon.c        | 2903 ++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/falcon_boards.c |  764 ++++++
 drivers/net/ethernet/sfc/falcon/farch.c         | 2892 +++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/farch_regs.h    | 2932 ++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon/filter.h        |  272 ++
 drivers/net/ethernet/sfc/falcon/io.h            |  290 ++
 drivers/net/ethernet/sfc/falcon/mdio_10g.c      |  323 +++
 drivers/net/ethernet/sfc/falcon/mdio_10g.h      |  110 +
 drivers/net/ethernet/sfc/falcon/mtd.c           |  133 +
 drivers/net/ethernet/sfc/falcon/net_driver.h    | 1464 ++++++++++
 drivers/net/ethernet/sfc/falcon/nic.c           |  527 ++++
 drivers/net/ethernet/sfc/falcon/nic.h           |  513 ++++
 drivers/net/ethernet/sfc/falcon/phy.h           |   50 +
 drivers/net/ethernet/sfc/falcon/qt202x_phy.c    |  495 ++++
 drivers/net/ethernet/sfc/falcon/rx.c            |  974 +++++++
 drivers/net/ethernet/sfc/falcon/selftest.c      |  808 ++++++
 drivers/net/ethernet/sfc/falcon/selftest.h      |   55 +
 drivers/net/ethernet/sfc/falcon/tenxpress.c     |  494 ++++
 drivers/net/ethernet/sfc/falcon/tx.c            |  649 +++++
 drivers/net/ethernet/sfc/falcon/tx.h            |   27 +
 drivers/net/ethernet/sfc/falcon/txc43128_phy.c  |  560 ++++
 drivers/net/ethernet/sfc/falcon/workarounds.h   |   44 +
 drivers/net/ethernet/sfc/falcon_boards.c        |  764 ------
 drivers/net/ethernet/sfc/farch.c                |  165 +-
 drivers/net/ethernet/sfc/mcdi.c                 |    1 -
 drivers/net/ethernet/sfc/mcdi_port.c            |    1 -
 drivers/net/ethernet/sfc/mdio_10g.c             |  323 ---
 drivers/net/ethernet/sfc/mdio_10g.h             |  110 -
 drivers/net/ethernet/sfc/net_driver.h           |    4 +-
 drivers/net/ethernet/sfc/nic.h                  |  172 +-
 drivers/net/ethernet/sfc/phy.h                  |   50 -
 drivers/net/ethernet/sfc/qt202x_phy.c           |  495 ----
 drivers/net/ethernet/sfc/rx.c                   |   19 +-
 drivers/net/ethernet/sfc/siena.c                |    1 -
 drivers/net/ethernet/sfc/tenxpress.c            |  494 ----
 drivers/net/ethernet/sfc/tx.c                   |   22 +-
 drivers/net/ethernet/sfc/txc43128_phy.c         |  560 ----
 drivers/net/ethernet/sfc/workarounds.h          |   21 -
 52 files changed, 23076 insertions(+), 6083 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/falcon.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/Kconfig
 create mode 100644 drivers/net/ethernet/sfc/falcon/Makefile
 create mode 100644 drivers/net/ethernet/sfc/falcon/bitfield.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/efx.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/efx.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/enum.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/ethtool.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/falcon.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/falcon_boards.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/farch.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/farch_regs.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/filter.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/io.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/mdio_10g.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/mdio_10g.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/mtd.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/net_driver.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/nic.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/nic.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/phy.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/qt202x_phy.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/rx.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/selftest.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/selftest.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/tenxpress.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/tx.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/tx.h
 create mode 100644 drivers/net/ethernet/sfc/falcon/txc43128_phy.c
 create mode 100644 drivers/net/ethernet/sfc/falcon/workarounds.h
 delete mode 100644 drivers/net/ethernet/sfc/falcon_boards.c
 delete mode 100644 drivers/net/ethernet/sfc/mdio_10g.c
 delete mode 100644 drivers/net/ethernet/sfc/mdio_10g.h
 delete mode 100644 drivers/net/ethernet/sfc/phy.h
 delete mode 100644 drivers/net/ethernet/sfc/qt202x_phy.c
 delete mode 100644 drivers/net/ethernet/sfc/tenxpress.c
 delete mode 100644 drivers/net/ethernet/sfc/txc43128_phy.c

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 8cc7467..6738fbb 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -165,6 +165,7 @@ source "drivers/net/ethernet/seeq/Kconfig"
 source "drivers/net/ethernet/silan/Kconfig"
 source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
+source "drivers/net/ethernet/sfc/falcon/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a09423d..e762445 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -75,6 +75,7 @@ obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
 obj-$(CONFIG_NET_VENDOR_SILAN) += silan/
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
 obj-$(CONFIG_SFC) += sfc/
+obj-$(CONFIG_SFC_FALCON) += sfc/falcon/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 4dd92b7..0e16197 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -1,20 +1,20 @@
 config SFC
-	tristate "Solarflare SFC4000/SFC9000/SFC9100-family support"
+	tristate "Solarflare SFC9000/SFC9100-family support"
 	depends on PCI
 	select MDIO
 	select CRC32
 	select I2C
 	select I2C_ALGOBIT
 	select PTP_1588_CLOCK
+	select SFC_FALCON
 	---help---
 	  This driver supports 10/40-gigabit Ethernet cards based on
-	  the Solarflare SFC4000, SFC9000-family and SFC9100-family
-	  controllers.
+	  the Solarflare SFC9000-family and SFC9100-family controllers.
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called sfc.
 config SFC_MTD
-	bool "Solarflare SFC4000/SFC9000/SFC9100-family MTD support"
+	bool "Solarflare SFC9000/SFC9100-family MTD support"
 	depends on SFC && MTD && !(SFC=y && MTD=m)
 	default y
 	---help---
diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
index b3b620f..520cfcc 100644
--- a/drivers/net/ethernet/sfc/Makefile
+++ b/drivers/net/ethernet/sfc/Makefile
@@ -1,7 +1,6 @@
-sfc-y			+= efx.o nic.o farch.o falcon.o siena.o ef10.o tx.o \
-			   rx.o selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
-			   tenxpress.o txc43128_phy.o falcon_boards.o \
-			   mcdi.o mcdi_port.o mcdi_mon.o ptp.o tx_tso.o
+sfc-y			+= efx.o nic.o farch.o siena.o ef10.o tx.o rx.o \
+			   selftest.o ethtool.o ptp.o tx_tso.o \
+			   mcdi.o mcdi_port.o mcdi_mon.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 sfc-$(CONFIG_SFC_SRIOV)	+= sriov.o siena_sriov.o ef10_sriov.o
 
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 756a0964..4a234a8 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -733,16 +733,7 @@ static void efx_stop_datapath(struct efx_nic *efx)
 	}
 
 	rc = efx->type->fini_dmaq(efx);
-	if (rc && EFX_WORKAROUND_7803(efx)) {
-		/* Schedule a reset to recover from the flush failure. The
-		 * descriptor caches reference memory we're about to free,
-		 * but falcon_reconfigure_mac_wrapper() won't reconnect
-		 * the MACs because of the pending reset.
-		 */
-		netif_err(efx, drv, efx->net_dev,
-			  "Resetting to recover from flush failure\n");
-		efx_schedule_reset(efx, RESET_TYPE_ALL);
-	} else if (rc) {
+	if (rc) {
 		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
 	} else {
 		netif_dbg(efx, drv, efx->net_dev,
@@ -1892,15 +1883,13 @@ static void efx_start_all(struct efx_nic *efx)
 		queue_delayed_work(efx->workqueue, &efx->monitor_work,
 				   efx_monitor_interval);
 
-	/* If link state detection is normally event-driven, we have
+	/* Link state detection is normally event-driven; we have
 	 * to poll now because we could have missed a change
 	 */
-	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0) {
-		mutex_lock(&efx->mac_lock);
-		if (efx->phy_op->poll(efx))
-			efx_link_status_changed(efx);
-		mutex_unlock(&efx->mac_lock);
-	}
+	mutex_lock(&efx->mac_lock);
+	if (efx->phy_op->poll(efx))
+		efx_link_status_changed(efx);
+	mutex_unlock(&efx->mac_lock);
 
 	efx->type->start_stats(efx);
 	efx->type->pull_stats(efx);
@@ -2842,12 +2831,6 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 
 /* PCI device ID table */
 static const struct pci_device_id efx_pci_table[] = {
-	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
-		    PCI_DEVICE_ID_SOLARFLARE_SFC4000A_0),
-	 .driver_data = (unsigned long) &falcon_a1_nic_type},
-	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
-		    PCI_DEVICE_ID_SOLARFLARE_SFC4000B),
-	 .driver_data = (unsigned long) &falcon_b0_nic_type},
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0803),	/* SFC9020 */
 	 .driver_data = (unsigned long) &siena_a0_nic_type},
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0813),	/* SFL9021 */
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 740cdf0..ca29d3d 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -169,9 +169,8 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, EFX_DRIVER_VERSION, sizeof(info->version));
-	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
-		efx_mcdi_print_fwver(efx, info->fw_version,
-				     sizeof(info->fw_version));
+	efx_mcdi_print_fwver(efx, info->fw_version,
+			     sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
 }
 
@@ -966,8 +965,6 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
 		return 0;
 
 	case ETHTOOL_GRXFH: {
-		unsigned min_revision = 0;
-
 		info->data = 0;
 		switch (info->flow_type) {
 		case UDP_V4_FLOW:
@@ -980,7 +977,6 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
 		case AH_ESP_V4_FLOW:
 		case IPV4_FLOW:
 			info->data |= RXH_IP_SRC | RXH_IP_DST;
-			min_revision = EFX_REV_FALCON_B0;
 			break;
 		case UDP_V6_FLOW:
 			if (efx->rx_hash_udp_4tuple)
@@ -992,13 +988,10 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
 		case AH_ESP_V6_FLOW:
 		case IPV6_FLOW:
 			info->data |= RXH_IP_SRC | RXH_IP_DST;
-			min_revision = EFX_REV_SIENA_A0;
 			break;
 		default:
 			break;
 		}
-		if (efx_nic_rev(efx) < min_revision)
-			info->data = 0;
 		return 0;
 	}
 
@@ -1271,9 +1264,7 @@ static u32 efx_ethtool_get_rxfh_indir_size(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	return ((efx_nic_rev(efx) < EFX_REV_FALCON_B0 ||
-		 efx->n_rx_channels == 1) ?
-		0 : ARRAY_SIZE(efx->rx_indir_table));
+	return (efx->n_rx_channels == 1) ? 0 : ARRAY_SIZE(efx->rx_indir_table);
 }
 
 static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key,
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
deleted file mode 100644
index 6a1e74b..0000000
--- a/drivers/net/ethernet/sfc/falcon.c
+++ /dev/null
@@ -1,2907 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2013 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#include <linux/bitops.h>
-#include <linux/delay.h>
-#include <linux/pci.h>
-#include <linux/module.h>
-#include <linux/seq_file.h>
-#include <linux/i2c.h>
-#include <linux/mii.h>
-#include <linux/slab.h>
-#include "net_driver.h"
-#include "bitfield.h"
-#include "efx.h"
-#include "nic.h"
-#include "farch_regs.h"
-#include "io.h"
-#include "phy.h"
-#include "workarounds.h"
-#include "selftest.h"
-#include "mdio_10g.h"
-
-/* Hardware control for SFC4000 (aka Falcon). */
-
-/**************************************************************************
- *
- * NIC stats
- *
- **************************************************************************
- */
-
-#define FALCON_MAC_STATS_SIZE 0x100
-
-#define XgRxOctets_offset 0x0
-#define XgRxOctets_WIDTH 48
-#define XgRxOctetsOK_offset 0x8
-#define XgRxOctetsOK_WIDTH 48
-#define XgRxPkts_offset 0x10
-#define XgRxPkts_WIDTH 32
-#define XgRxPktsOK_offset 0x14
-#define XgRxPktsOK_WIDTH 32
-#define XgRxBroadcastPkts_offset 0x18
-#define XgRxBroadcastPkts_WIDTH 32
-#define XgRxMulticastPkts_offset 0x1C
-#define XgRxMulticastPkts_WIDTH 32
-#define XgRxUnicastPkts_offset 0x20
-#define XgRxUnicastPkts_WIDTH 32
-#define XgRxUndersizePkts_offset 0x24
-#define XgRxUndersizePkts_WIDTH 32
-#define XgRxOversizePkts_offset 0x28
-#define XgRxOversizePkts_WIDTH 32
-#define XgRxJabberPkts_offset 0x2C
-#define XgRxJabberPkts_WIDTH 32
-#define XgRxUndersizeFCSerrorPkts_offset 0x30
-#define XgRxUndersizeFCSerrorPkts_WIDTH 32
-#define XgRxDropEvents_offset 0x34
-#define XgRxDropEvents_WIDTH 32
-#define XgRxFCSerrorPkts_offset 0x38
-#define XgRxFCSerrorPkts_WIDTH 32
-#define XgRxAlignError_offset 0x3C
-#define XgRxAlignError_WIDTH 32
-#define XgRxSymbolError_offset 0x40
-#define XgRxSymbolError_WIDTH 32
-#define XgRxInternalMACError_offset 0x44
-#define XgRxInternalMACError_WIDTH 32
-#define XgRxControlPkts_offset 0x48
-#define XgRxControlPkts_WIDTH 32
-#define XgRxPausePkts_offset 0x4C
-#define XgRxPausePkts_WIDTH 32
-#define XgRxPkts64Octets_offset 0x50
-#define XgRxPkts64Octets_WIDTH 32
-#define XgRxPkts65to127Octets_offset 0x54
-#define XgRxPkts65to127Octets_WIDTH 32
-#define XgRxPkts128to255Octets_offset 0x58
-#define XgRxPkts128to255Octets_WIDTH 32
-#define XgRxPkts256to511Octets_offset 0x5C
-#define XgRxPkts256to511Octets_WIDTH 32
-#define XgRxPkts512to1023Octets_offset 0x60
-#define XgRxPkts512to1023Octets_WIDTH 32
-#define XgRxPkts1024to15xxOctets_offset 0x64
-#define XgRxPkts1024to15xxOctets_WIDTH 32
-#define XgRxPkts15xxtoMaxOctets_offset 0x68
-#define XgRxPkts15xxtoMaxOctets_WIDTH 32
-#define XgRxLengthError_offset 0x6C
-#define XgRxLengthError_WIDTH 32
-#define XgTxPkts_offset 0x80
-#define XgTxPkts_WIDTH 32
-#define XgTxOctets_offset 0x88
-#define XgTxOctets_WIDTH 48
-#define XgTxMulticastPkts_offset 0x90
-#define XgTxMulticastPkts_WIDTH 32
-#define XgTxBroadcastPkts_offset 0x94
-#define XgTxBroadcastPkts_WIDTH 32
-#define XgTxUnicastPkts_offset 0x98
-#define XgTxUnicastPkts_WIDTH 32
-#define XgTxControlPkts_offset 0x9C
-#define XgTxControlPkts_WIDTH 32
-#define XgTxPausePkts_offset 0xA0
-#define XgTxPausePkts_WIDTH 32
-#define XgTxPkts64Octets_offset 0xA4
-#define XgTxPkts64Octets_WIDTH 32
-#define XgTxPkts65to127Octets_offset 0xA8
-#define XgTxPkts65to127Octets_WIDTH 32
-#define XgTxPkts128to255Octets_offset 0xAC
-#define XgTxPkts128to255Octets_WIDTH 32
-#define XgTxPkts256to511Octets_offset 0xB0
-#define XgTxPkts256to511Octets_WIDTH 32
-#define XgTxPkts512to1023Octets_offset 0xB4
-#define XgTxPkts512to1023Octets_WIDTH 32
-#define XgTxPkts1024to15xxOctets_offset 0xB8
-#define XgTxPkts1024to15xxOctets_WIDTH 32
-#define XgTxPkts1519toMaxOctets_offset 0xBC
-#define XgTxPkts1519toMaxOctets_WIDTH 32
-#define XgTxUndersizePkts_offset 0xC0
-#define XgTxUndersizePkts_WIDTH 32
-#define XgTxOversizePkts_offset 0xC4
-#define XgTxOversizePkts_WIDTH 32
-#define XgTxNonTcpUdpPkt_offset 0xC8
-#define XgTxNonTcpUdpPkt_WIDTH 16
-#define XgTxMacSrcErrPkt_offset 0xCC
-#define XgTxMacSrcErrPkt_WIDTH 16
-#define XgTxIpSrcErrPkt_offset 0xD0
-#define XgTxIpSrcErrPkt_WIDTH 16
-#define XgDmaDone_offset 0xD4
-#define XgDmaDone_WIDTH 32
-
-#define FALCON_XMAC_STATS_DMA_FLAG(efx)				\
-	(*(u32 *)((efx)->stats_buffer.addr + XgDmaDone_offset))
-
-#define FALCON_DMA_STAT(ext_name, hw_name)				\
-	[FALCON_STAT_ ## ext_name] =					\
-	{ #ext_name,							\
-	  /* 48-bit stats are zero-padded to 64 on DMA */		\
-	  hw_name ## _ ## WIDTH == 48 ? 64 : hw_name ## _ ## WIDTH,	\
-	  hw_name ## _ ## offset }
-#define FALCON_OTHER_STAT(ext_name)					\
-	[FALCON_STAT_ ## ext_name] = { #ext_name, 0, 0 }
-#define GENERIC_SW_STAT(ext_name)				\
-	[GENERIC_STAT_ ## ext_name] = { #ext_name, 0, 0 }
-
-static const struct efx_hw_stat_desc falcon_stat_desc[FALCON_STAT_COUNT] = {
-	FALCON_DMA_STAT(tx_bytes, XgTxOctets),
-	FALCON_DMA_STAT(tx_packets, XgTxPkts),
-	FALCON_DMA_STAT(tx_pause, XgTxPausePkts),
-	FALCON_DMA_STAT(tx_control, XgTxControlPkts),
-	FALCON_DMA_STAT(tx_unicast, XgTxUnicastPkts),
-	FALCON_DMA_STAT(tx_multicast, XgTxMulticastPkts),
-	FALCON_DMA_STAT(tx_broadcast, XgTxBroadcastPkts),
-	FALCON_DMA_STAT(tx_lt64, XgTxUndersizePkts),
-	FALCON_DMA_STAT(tx_64, XgTxPkts64Octets),
-	FALCON_DMA_STAT(tx_65_to_127, XgTxPkts65to127Octets),
-	FALCON_DMA_STAT(tx_128_to_255, XgTxPkts128to255Octets),
-	FALCON_DMA_STAT(tx_256_to_511, XgTxPkts256to511Octets),
-	FALCON_DMA_STAT(tx_512_to_1023, XgTxPkts512to1023Octets),
-	FALCON_DMA_STAT(tx_1024_to_15xx, XgTxPkts1024to15xxOctets),
-	FALCON_DMA_STAT(tx_15xx_to_jumbo, XgTxPkts1519toMaxOctets),
-	FALCON_DMA_STAT(tx_gtjumbo, XgTxOversizePkts),
-	FALCON_DMA_STAT(tx_non_tcpudp, XgTxNonTcpUdpPkt),
-	FALCON_DMA_STAT(tx_mac_src_error, XgTxMacSrcErrPkt),
-	FALCON_DMA_STAT(tx_ip_src_error, XgTxIpSrcErrPkt),
-	FALCON_DMA_STAT(rx_bytes, XgRxOctets),
-	FALCON_DMA_STAT(rx_good_bytes, XgRxOctetsOK),
-	FALCON_OTHER_STAT(rx_bad_bytes),
-	FALCON_DMA_STAT(rx_packets, XgRxPkts),
-	FALCON_DMA_STAT(rx_good, XgRxPktsOK),
-	FALCON_DMA_STAT(rx_bad, XgRxFCSerrorPkts),
-	FALCON_DMA_STAT(rx_pause, XgRxPausePkts),
-	FALCON_DMA_STAT(rx_control, XgRxControlPkts),
-	FALCON_DMA_STAT(rx_unicast, XgRxUnicastPkts),
-	FALCON_DMA_STAT(rx_multicast, XgRxMulticastPkts),
-	FALCON_DMA_STAT(rx_broadcast, XgRxBroadcastPkts),
-	FALCON_DMA_STAT(rx_lt64, XgRxUndersizePkts),
-	FALCON_DMA_STAT(rx_64, XgRxPkts64Octets),
-	FALCON_DMA_STAT(rx_65_to_127, XgRxPkts65to127Octets),
-	FALCON_DMA_STAT(rx_128_to_255, XgRxPkts128to255Octets),
-	FALCON_DMA_STAT(rx_256_to_511, XgRxPkts256to511Octets),
-	FALCON_DMA_STAT(rx_512_to_1023, XgRxPkts512to1023Octets),
-	FALCON_DMA_STAT(rx_1024_to_15xx, XgRxPkts1024to15xxOctets),
-	FALCON_DMA_STAT(rx_15xx_to_jumbo, XgRxPkts15xxtoMaxOctets),
-	FALCON_DMA_STAT(rx_gtjumbo, XgRxOversizePkts),
-	FALCON_DMA_STAT(rx_bad_lt64, XgRxUndersizeFCSerrorPkts),
-	FALCON_DMA_STAT(rx_bad_gtjumbo, XgRxJabberPkts),
-	FALCON_DMA_STAT(rx_overflow, XgRxDropEvents),
-	FALCON_DMA_STAT(rx_symbol_error, XgRxSymbolError),
-	FALCON_DMA_STAT(rx_align_error, XgRxAlignError),
-	FALCON_DMA_STAT(rx_length_error, XgRxLengthError),
-	FALCON_DMA_STAT(rx_internal_error, XgRxInternalMACError),
-	FALCON_OTHER_STAT(rx_nodesc_drop_cnt),
-	GENERIC_SW_STAT(rx_nodesc_trunc),
-	GENERIC_SW_STAT(rx_noskb_drops),
-};
-static const unsigned long falcon_stat_mask[] = {
-	[0 ... BITS_TO_LONGS(FALCON_STAT_COUNT) - 1] = ~0UL,
-};
-
-/**************************************************************************
- *
- * Basic SPI command set and bit definitions
- *
- *************************************************************************/
-
-#define SPI_WRSR 0x01		/* Write status register */
-#define SPI_WRITE 0x02		/* Write data to memory array */
-#define SPI_READ 0x03		/* Read data from memory array */
-#define SPI_WRDI 0x04		/* Reset write enable latch */
-#define SPI_RDSR 0x05		/* Read status register */
-#define SPI_WREN 0x06		/* Set write enable latch */
-#define SPI_SST_EWSR 0x50	/* SST: Enable write to status register */
-
-#define SPI_STATUS_WPEN 0x80	/* Write-protect pin enabled */
-#define SPI_STATUS_BP2 0x10	/* Block protection bit 2 */
-#define SPI_STATUS_BP1 0x08	/* Block protection bit 1 */
-#define SPI_STATUS_BP0 0x04	/* Block protection bit 0 */
-#define SPI_STATUS_WEN 0x02	/* State of the write enable latch */
-#define SPI_STATUS_NRDY 0x01	/* Device busy flag */
-
-/**************************************************************************
- *
- * Non-volatile memory layout
- *
- **************************************************************************
- */
-
-/* SFC4000 flash is partitioned into:
- *     0-0x400       chip and board config (see struct falcon_nvconfig)
- *     0x400-0x8000  unused (or may contain VPD if EEPROM not present)
- *     0x8000-end    boot code (mapped to PCI expansion ROM)
- * SFC4000 small EEPROM (size < 0x400) is used for VPD only.
- * SFC4000 large EEPROM (size >= 0x400) is partitioned into:
- *     0-0x400       chip and board config
- *     configurable  VPD
- *     0x800-0x1800  boot config
- * Aside from the chip and board config, all of these are optional and may
- * be absent or truncated depending on the devices used.
- */
-#define FALCON_NVCONFIG_END 0x400U
-#define FALCON_FLASH_BOOTCODE_START 0x8000U
-#define FALCON_EEPROM_BOOTCONFIG_START 0x800U
-#define FALCON_EEPROM_BOOTCONFIG_END 0x1800U
-
-/* Board configuration v2 (v1 is obsolete; later versions are compatible) */
-struct falcon_nvconfig_board_v2 {
-	__le16 nports;
-	u8 port0_phy_addr;
-	u8 port0_phy_type;
-	u8 port1_phy_addr;
-	u8 port1_phy_type;
-	__le16 asic_sub_revision;
-	__le16 board_revision;
-} __packed;
-
-/* Board configuration v3 extra information */
-struct falcon_nvconfig_board_v3 {
-	__le32 spi_device_type[2];
-} __packed;
-
-/* Bit numbers for spi_device_type */
-#define SPI_DEV_TYPE_SIZE_LBN 0
-#define SPI_DEV_TYPE_SIZE_WIDTH 5
-#define SPI_DEV_TYPE_ADDR_LEN_LBN 6
-#define SPI_DEV_TYPE_ADDR_LEN_WIDTH 2
-#define SPI_DEV_TYPE_ERASE_CMD_LBN 8
-#define SPI_DEV_TYPE_ERASE_CMD_WIDTH 8
-#define SPI_DEV_TYPE_ERASE_SIZE_LBN 16
-#define SPI_DEV_TYPE_ERASE_SIZE_WIDTH 5
-#define SPI_DEV_TYPE_BLOCK_SIZE_LBN 24
-#define SPI_DEV_TYPE_BLOCK_SIZE_WIDTH 5
-#define SPI_DEV_TYPE_FIELD(type, field)					\
-	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
-
-#define FALCON_NVCONFIG_OFFSET 0x300
-
-#define FALCON_NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
-struct falcon_nvconfig {
-	efx_oword_t ee_vpd_cfg_reg;			/* 0x300 */
-	u8 mac_address[2][8];			/* 0x310 */
-	efx_oword_t pcie_sd_ctl0123_reg;		/* 0x320 */
-	efx_oword_t pcie_sd_ctl45_reg;			/* 0x330 */
-	efx_oword_t pcie_pcs_ctl_stat_reg;		/* 0x340 */
-	efx_oword_t hw_init_reg;			/* 0x350 */
-	efx_oword_t nic_stat_reg;			/* 0x360 */
-	efx_oword_t glb_ctl_reg;			/* 0x370 */
-	efx_oword_t srm_cfg_reg;			/* 0x380 */
-	efx_oword_t spare_reg;				/* 0x390 */
-	__le16 board_magic_num;			/* 0x3A0 */
-	__le16 board_struct_ver;
-	__le16 board_checksum;
-	struct falcon_nvconfig_board_v2 board_v2;
-	efx_oword_t ee_base_page_reg;			/* 0x3B0 */
-	struct falcon_nvconfig_board_v3 board_v3;	/* 0x3C0 */
-} __packed;
-
-/*************************************************************************/
-
-static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
-static void falcon_reconfigure_mac_wrapper(struct efx_nic *efx);
-
-static const unsigned int
-/* "Large" EEPROM device: Atmel AT25640 or similar
- * 8 KB, 16-bit address, 32 B write block */
-large_eeprom_type = ((13 << SPI_DEV_TYPE_SIZE_LBN)
-		     | (2 << SPI_DEV_TYPE_ADDR_LEN_LBN)
-		     | (5 << SPI_DEV_TYPE_BLOCK_SIZE_LBN)),
-/* Default flash device: Atmel AT25F1024
- * 128 KB, 24-bit address, 32 KB erase block, 256 B write block */
-default_flash_type = ((17 << SPI_DEV_TYPE_SIZE_LBN)
-		      | (3 << SPI_DEV_TYPE_ADDR_LEN_LBN)
-		      | (0x52 << SPI_DEV_TYPE_ERASE_CMD_LBN)
-		      | (15 << SPI_DEV_TYPE_ERASE_SIZE_LBN)
-		      | (8 << SPI_DEV_TYPE_BLOCK_SIZE_LBN));
-
-/**************************************************************************
- *
- * I2C bus - this is a bit-bashing interface using GPIO pins
- * Note that it uses the output enables to tristate the outputs
- * SDA is the data pin and SCL is the clock
- *
- **************************************************************************
- */
-static void falcon_setsda(void *data, int state)
-{
-	struct efx_nic *efx = (struct efx_nic *)data;
-	efx_oword_t reg;
-
-	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO3_OEN, !state);
-	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
-}
-
-static void falcon_setscl(void *data, int state)
-{
-	struct efx_nic *efx = (struct efx_nic *)data;
-	efx_oword_t reg;
-
-	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO0_OEN, !state);
-	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
-}
-
-static int falcon_getsda(void *data)
-{
-	struct efx_nic *efx = (struct efx_nic *)data;
-	efx_oword_t reg;
-
-	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
-	return EFX_OWORD_FIELD(reg, FRF_AB_GPIO3_IN);
-}
-
-static int falcon_getscl(void *data)
-{
-	struct efx_nic *efx = (struct efx_nic *)data;
-	efx_oword_t reg;
-
-	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
-	return EFX_OWORD_FIELD(reg, FRF_AB_GPIO0_IN);
-}
-
-static const struct i2c_algo_bit_data falcon_i2c_bit_operations = {
-	.setsda		= falcon_setsda,
-	.setscl		= falcon_setscl,
-	.getsda		= falcon_getsda,
-	.getscl		= falcon_getscl,
-	.udelay		= 5,
-	/* Wait up to 50 ms for slave to let us pull SCL high */
-	.timeout	= DIV_ROUND_UP(HZ, 20),
-};
-
-static void falcon_push_irq_moderation(struct efx_channel *channel)
-{
-	efx_dword_t timer_cmd;
-	struct efx_nic *efx = channel->efx;
-
-	/* Set timer register */
-	if (channel->irq_moderation_us) {
-		unsigned int ticks;
-
-		ticks = efx_usecs_to_ticks(efx, channel->irq_moderation_us);
-		EFX_POPULATE_DWORD_2(timer_cmd,
-				     FRF_AB_TC_TIMER_MODE,
-				     FFE_BB_TIMER_MODE_INT_HLDOFF,
-				     FRF_AB_TC_TIMER_VAL,
-				     ticks - 1);
-	} else {
-		EFX_POPULATE_DWORD_2(timer_cmd,
-				     FRF_AB_TC_TIMER_MODE,
-				     FFE_BB_TIMER_MODE_DIS,
-				     FRF_AB_TC_TIMER_VAL, 0);
-	}
-	BUILD_BUG_ON(FR_AA_TIMER_COMMAND_KER != FR_BZ_TIMER_COMMAND_P0);
-	efx_writed_page_locked(efx, &timer_cmd, FR_BZ_TIMER_COMMAND_P0,
-			       channel->channel);
-}
-
-static void falcon_deconfigure_mac_wrapper(struct efx_nic *efx);
-
-static void falcon_prepare_flush(struct efx_nic *efx)
-{
-	falcon_deconfigure_mac_wrapper(efx);
-
-	/* Wait for the tx and rx fifo's to get to the next packet boundary
-	 * (~1ms without back-pressure), then to drain the remainder of the
-	 * fifo's at data path speeds (negligible), with a healthy margin. */
-	msleep(10);
-}
-
-/* Acknowledge a legacy interrupt from Falcon
- *
- * This acknowledges a legacy (not MSI) interrupt via INT_ACK_KER_REG.
- *
- * Due to SFC bug 3706 (silicon revision <=A1) reads can be duplicated in the
- * BIU. Interrupt acknowledge is read sensitive so must write instead
- * (then read to ensure the BIU collector is flushed)
- *
- * NB most hardware supports MSI interrupts
- */
-static inline void falcon_irq_ack_a1(struct efx_nic *efx)
-{
-	efx_dword_t reg;
-
-	EFX_POPULATE_DWORD_1(reg, FRF_AA_INT_ACK_KER_FIELD, 0xb7eb7e);
-	efx_writed(efx, &reg, FR_AA_INT_ACK_KER);
-	efx_readd(efx, &reg, FR_AA_WORK_AROUND_BROKEN_PCI_READS);
-}
-
-static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
-{
-	struct efx_nic *efx = dev_id;
-	efx_oword_t *int_ker = efx->irq_status.addr;
-	int syserr;
-	int queues;
-
-	/* Check to see if this is our interrupt.  If it isn't, we
-	 * exit without having touched the hardware.
-	 */
-	if (unlikely(EFX_OWORD_IS_ZERO(*int_ker))) {
-		netif_vdbg(efx, intr, efx->net_dev,
-			   "IRQ %d on CPU %d not for me\n", irq,
-			   raw_smp_processor_id());
-		return IRQ_NONE;
-	}
-	efx->last_irq_cpu = raw_smp_processor_id();
-	netif_vdbg(efx, intr, efx->net_dev,
-		   "IRQ %d on CPU %d status " EFX_OWORD_FMT "\n",
-		   irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
-
-	if (!likely(ACCESS_ONCE(efx->irq_soft_enabled)))
-		return IRQ_HANDLED;
-
-	/* Check to see if we have a serious error condition */
-	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
-	if (unlikely(syserr))
-		return efx_farch_fatal_interrupt(efx);
-
-	/* Determine interrupting queues, clear interrupt status
-	 * register and acknowledge the device interrupt.
-	 */
-	BUILD_BUG_ON(FSF_AZ_NET_IVEC_INT_Q_WIDTH > EFX_MAX_CHANNELS);
-	queues = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_INT_Q);
-	EFX_ZERO_OWORD(*int_ker);
-	wmb(); /* Ensure the vector is cleared before interrupt ack */
-	falcon_irq_ack_a1(efx);
-
-	if (queues & 1)
-		efx_schedule_channel_irq(efx_get_channel(efx, 0));
-	if (queues & 2)
-		efx_schedule_channel_irq(efx_get_channel(efx, 1));
-	return IRQ_HANDLED;
-}
-
-/**************************************************************************
- *
- * RSS
- *
- **************************************************************************
- */
-static int dummy_rx_push_rss_config(struct efx_nic *efx, bool user,
-				    const u32 *rx_indir_table)
-{
-	(void) efx;
-	(void) user;
-	(void) rx_indir_table;
-	return -ENOSYS;
-}
-
-static int falcon_b0_rx_push_rss_config(struct efx_nic *efx, bool user,
-					const u32 *rx_indir_table)
-{
-	efx_oword_t temp;
-
-	(void) user;
-	/* Set hash key for IPv4 */
-	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
-	efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
-
-	memcpy(efx->rx_indir_table, rx_indir_table,
-	       sizeof(efx->rx_indir_table));
-	efx_farch_rx_push_indir_table(efx);
-	return 0;
-}
-
-/**************************************************************************
- *
- * EEPROM/flash
- *
- **************************************************************************
- */
-
-#define FALCON_SPI_MAX_LEN sizeof(efx_oword_t)
-
-static int falcon_spi_poll(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-	efx_reado(efx, &reg, FR_AB_EE_SPI_HCMD);
-	return EFX_OWORD_FIELD(reg, FRF_AB_EE_SPI_HCMD_CMD_EN) ? -EBUSY : 0;
-}
-
-/* Wait for SPI command completion */
-static int falcon_spi_wait(struct efx_nic *efx)
-{
-	/* Most commands will finish quickly, so we start polling at
-	 * very short intervals.  Sometimes the command may have to
-	 * wait for VPD or expansion ROM access outside of our
-	 * control, so we allow up to 100 ms. */
-	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 10);
-	int i;
-
-	for (i = 0; i < 10; i++) {
-		if (!falcon_spi_poll(efx))
-			return 0;
-		udelay(10);
-	}
-
-	for (;;) {
-		if (!falcon_spi_poll(efx))
-			return 0;
-		if (time_after_eq(jiffies, timeout)) {
-			netif_err(efx, hw, efx->net_dev,
-				  "timed out waiting for SPI\n");
-			return -ETIMEDOUT;
-		}
-		schedule_timeout_uninterruptible(1);
-	}
-}
-
-static int
-falcon_spi_cmd(struct efx_nic *efx, const struct falcon_spi_device *spi,
-	       unsigned int command, int address,
-	       const void *in, void *out, size_t len)
-{
-	bool addressed = (address >= 0);
-	bool reading = (out != NULL);
-	efx_oword_t reg;
-	int rc;
-
-	/* Input validation */
-	if (len > FALCON_SPI_MAX_LEN)
-		return -EINVAL;
-
-	/* Check that previous command is not still running */
-	rc = falcon_spi_poll(efx);
-	if (rc)
-		return rc;
-
-	/* Program address register, if we have an address */
-	if (addressed) {
-		EFX_POPULATE_OWORD_1(reg, FRF_AB_EE_SPI_HADR_ADR, address);
-		efx_writeo(efx, &reg, FR_AB_EE_SPI_HADR);
-	}
-
-	/* Program data register, if we have data */
-	if (in != NULL) {
-		memcpy(&reg, in, len);
-		efx_writeo(efx, &reg, FR_AB_EE_SPI_HDATA);
-	}
-
-	/* Issue read/write command */
-	EFX_POPULATE_OWORD_7(reg,
-			     FRF_AB_EE_SPI_HCMD_CMD_EN, 1,
-			     FRF_AB_EE_SPI_HCMD_SF_SEL, spi->device_id,
-			     FRF_AB_EE_SPI_HCMD_DABCNT, len,
-			     FRF_AB_EE_SPI_HCMD_READ, reading,
-			     FRF_AB_EE_SPI_HCMD_DUBCNT, 0,
-			     FRF_AB_EE_SPI_HCMD_ADBCNT,
-			     (addressed ? spi->addr_len : 0),
-			     FRF_AB_EE_SPI_HCMD_ENC, command);
-	efx_writeo(efx, &reg, FR_AB_EE_SPI_HCMD);
-
-	/* Wait for read/write to complete */
-	rc = falcon_spi_wait(efx);
-	if (rc)
-		return rc;
-
-	/* Read data */
-	if (out != NULL) {
-		efx_reado(efx, &reg, FR_AB_EE_SPI_HDATA);
-		memcpy(out, &reg, len);
-	}
-
-	return 0;
-}
-
-static inline u8
-falcon_spi_munge_command(const struct falcon_spi_device *spi,
-			 const u8 command, const unsigned int address)
-{
-	return command | (((address >> 8) & spi->munge_address) << 3);
-}
-
-static int
-falcon_spi_read(struct efx_nic *efx, const struct falcon_spi_device *spi,
-		loff_t start, size_t len, size_t *retlen, u8 *buffer)
-{
-	size_t block_len, pos = 0;
-	unsigned int command;
-	int rc = 0;
-
-	while (pos < len) {
-		block_len = min(len - pos, FALCON_SPI_MAX_LEN);
-
-		command = falcon_spi_munge_command(spi, SPI_READ, start + pos);
-		rc = falcon_spi_cmd(efx, spi, command, start + pos, NULL,
-				    buffer + pos, block_len);
-		if (rc)
-			break;
-		pos += block_len;
-
-		/* Avoid locking up the system */
-		cond_resched();
-		if (signal_pending(current)) {
-			rc = -EINTR;
-			break;
-		}
-	}
-
-	if (retlen)
-		*retlen = pos;
-	return rc;
-}
-
-#ifdef CONFIG_SFC_MTD
-
-struct falcon_mtd_partition {
-	struct efx_mtd_partition common;
-	const struct falcon_spi_device *spi;
-	size_t offset;
-};
-
-#define to_falcon_mtd_partition(mtd)				\
-	container_of(mtd, struct falcon_mtd_partition, common.mtd)
-
-static size_t
-falcon_spi_write_limit(const struct falcon_spi_device *spi, size_t start)
-{
-	return min(FALCON_SPI_MAX_LEN,
-		   (spi->block_size - (start & (spi->block_size - 1))));
-}
-
-/* Wait up to 10 ms for buffered write completion */
-static int
-falcon_spi_wait_write(struct efx_nic *efx, const struct falcon_spi_device *spi)
-{
-	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 100);
-	u8 status;
-	int rc;
-
-	for (;;) {
-		rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
-				    &status, sizeof(status));
-		if (rc)
-			return rc;
-		if (!(status & SPI_STATUS_NRDY))
-			return 0;
-		if (time_after_eq(jiffies, timeout)) {
-			netif_err(efx, hw, efx->net_dev,
-				  "SPI write timeout on device %d"
-				  " last status=0x%02x\n",
-				  spi->device_id, status);
-			return -ETIMEDOUT;
-		}
-		schedule_timeout_uninterruptible(1);
-	}
-}
-
-static int
-falcon_spi_write(struct efx_nic *efx, const struct falcon_spi_device *spi,
-		 loff_t start, size_t len, size_t *retlen, const u8 *buffer)
-{
-	u8 verify_buffer[FALCON_SPI_MAX_LEN];
-	size_t block_len, pos = 0;
-	unsigned int command;
-	int rc = 0;
-
-	while (pos < len) {
-		rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
-		if (rc)
-			break;
-
-		block_len = min(len - pos,
-				falcon_spi_write_limit(spi, start + pos));
-		command = falcon_spi_munge_command(spi, SPI_WRITE, start + pos);
-		rc = falcon_spi_cmd(efx, spi, command, start + pos,
-				    buffer + pos, NULL, block_len);
-		if (rc)
-			break;
-
-		rc = falcon_spi_wait_write(efx, spi);
-		if (rc)
-			break;
-
-		command = falcon_spi_munge_command(spi, SPI_READ, start + pos);
-		rc = falcon_spi_cmd(efx, spi, command, start + pos,
-				    NULL, verify_buffer, block_len);
-		if (memcmp(verify_buffer, buffer + pos, block_len)) {
-			rc = -EIO;
-			break;
-		}
-
-		pos += block_len;
-
-		/* Avoid locking up the system */
-		cond_resched();
-		if (signal_pending(current)) {
-			rc = -EINTR;
-			break;
-		}
-	}
-
-	if (retlen)
-		*retlen = pos;
-	return rc;
-}
-
-static int
-falcon_spi_slow_wait(struct falcon_mtd_partition *part, bool uninterruptible)
-{
-	const struct falcon_spi_device *spi = part->spi;
-	struct efx_nic *efx = part->common.mtd.priv;
-	u8 status;
-	int rc, i;
-
-	/* Wait up to 4s for flash/EEPROM to finish a slow operation. */
-	for (i = 0; i < 40; i++) {
-		__set_current_state(uninterruptible ?
-				    TASK_UNINTERRUPTIBLE : TASK_INTERRUPTIBLE);
-		schedule_timeout(HZ / 10);
-		rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
-				    &status, sizeof(status));
-		if (rc)
-			return rc;
-		if (!(status & SPI_STATUS_NRDY))
-			return 0;
-		if (signal_pending(current))
-			return -EINTR;
-	}
-	pr_err("%s: timed out waiting for %s\n",
-	       part->common.name, part->common.dev_type_name);
-	return -ETIMEDOUT;
-}
-
-static int
-falcon_spi_unlock(struct efx_nic *efx, const struct falcon_spi_device *spi)
-{
-	const u8 unlock_mask = (SPI_STATUS_BP2 | SPI_STATUS_BP1 |
-				SPI_STATUS_BP0);
-	u8 status;
-	int rc;
-
-	rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
-			    &status, sizeof(status));
-	if (rc)
-		return rc;
-
-	if (!(status & unlock_mask))
-		return 0; /* already unlocked */
-
-	rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
-	if (rc)
-		return rc;
-	rc = falcon_spi_cmd(efx, spi, SPI_SST_EWSR, -1, NULL, NULL, 0);
-	if (rc)
-		return rc;
-
-	status &= ~unlock_mask;
-	rc = falcon_spi_cmd(efx, spi, SPI_WRSR, -1, &status,
-			    NULL, sizeof(status));
-	if (rc)
-		return rc;
-	rc = falcon_spi_wait_write(efx, spi);
-	if (rc)
-		return rc;
-
-	return 0;
-}
-
-#define FALCON_SPI_VERIFY_BUF_LEN 16
-
-static int
-falcon_spi_erase(struct falcon_mtd_partition *part, loff_t start, size_t len)
-{
-	const struct falcon_spi_device *spi = part->spi;
-	struct efx_nic *efx = part->common.mtd.priv;
-	unsigned pos, block_len;
-	u8 empty[FALCON_SPI_VERIFY_BUF_LEN];
-	u8 buffer[FALCON_SPI_VERIFY_BUF_LEN];
-	int rc;
-
-	if (len != spi->erase_size)
-		return -EINVAL;
-
-	if (spi->erase_command == 0)
-		return -EOPNOTSUPP;
-
-	rc = falcon_spi_unlock(efx, spi);
-	if (rc)
-		return rc;
-	rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
-	if (rc)
-		return rc;
-	rc = falcon_spi_cmd(efx, spi, spi->erase_command, start, NULL,
-			    NULL, 0);
-	if (rc)
-		return rc;
-	rc = falcon_spi_slow_wait(part, false);
-
-	/* Verify the entire region has been wiped */
-	memset(empty, 0xff, sizeof(empty));
-	for (pos = 0; pos < len; pos += block_len) {
-		block_len = min(len - pos, sizeof(buffer));
-		rc = falcon_spi_read(efx, spi, start + pos, block_len,
-				     NULL, buffer);
-		if (rc)
-			return rc;
-		if (memcmp(empty, buffer, block_len))
-			return -EIO;
-
-		/* Avoid locking up the system */
-		cond_resched();
-		if (signal_pending(current))
-			return -EINTR;
-	}
-
-	return rc;
-}
-
-static void falcon_mtd_rename(struct efx_mtd_partition *part)
-{
-	struct efx_nic *efx = part->mtd.priv;
-
-	snprintf(part->name, sizeof(part->name), "%s %s",
-		 efx->name, part->type_name);
-}
-
-static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
-			   size_t len, size_t *retlen, u8 *buffer)
-{
-	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
-	struct efx_nic *efx = mtd->priv;
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	int rc;
-
-	rc = mutex_lock_interruptible(&nic_data->spi_lock);
-	if (rc)
-		return rc;
-	rc = falcon_spi_read(efx, part->spi, part->offset + start,
-			     len, retlen, buffer);
-	mutex_unlock(&nic_data->spi_lock);
-	return rc;
-}
-
-static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
-{
-	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
-	struct efx_nic *efx = mtd->priv;
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	int rc;
-
-	rc = mutex_lock_interruptible(&nic_data->spi_lock);
-	if (rc)
-		return rc;
-	rc = falcon_spi_erase(part, part->offset + start, len);
-	mutex_unlock(&nic_data->spi_lock);
-	return rc;
-}
-
-static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
-			    size_t len, size_t *retlen, const u8 *buffer)
-{
-	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
-	struct efx_nic *efx = mtd->priv;
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	int rc;
-
-	rc = mutex_lock_interruptible(&nic_data->spi_lock);
-	if (rc)
-		return rc;
-	rc = falcon_spi_write(efx, part->spi, part->offset + start,
-			      len, retlen, buffer);
-	mutex_unlock(&nic_data->spi_lock);
-	return rc;
-}
-
-static int falcon_mtd_sync(struct mtd_info *mtd)
-{
-	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
-	struct efx_nic *efx = mtd->priv;
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	int rc;
-
-	mutex_lock(&nic_data->spi_lock);
-	rc = falcon_spi_slow_wait(part, true);
-	mutex_unlock(&nic_data->spi_lock);
-	return rc;
-}
-
-static int falcon_mtd_probe(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	struct falcon_mtd_partition *parts;
-	struct falcon_spi_device *spi;
-	size_t n_parts;
-	int rc = -ENODEV;
-
-	ASSERT_RTNL();
-
-	/* Allocate space for maximum number of partitions */
-	parts = kcalloc(2, sizeof(*parts), GFP_KERNEL);
-	if (!parts)
-		return -ENOMEM;
-	n_parts = 0;
-
-	spi = &nic_data->spi_flash;
-	if (falcon_spi_present(spi) && spi->size > FALCON_FLASH_BOOTCODE_START) {
-		parts[n_parts].spi = spi;
-		parts[n_parts].offset = FALCON_FLASH_BOOTCODE_START;
-		parts[n_parts].common.dev_type_name = "flash";
-		parts[n_parts].common.type_name = "sfc_flash_bootrom";
-		parts[n_parts].common.mtd.type = MTD_NORFLASH;
-		parts[n_parts].common.mtd.flags = MTD_CAP_NORFLASH;
-		parts[n_parts].common.mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
-		parts[n_parts].common.mtd.erasesize = spi->erase_size;
-		n_parts++;
-	}
-
-	spi = &nic_data->spi_eeprom;
-	if (falcon_spi_present(spi) && spi->size > FALCON_EEPROM_BOOTCONFIG_START) {
-		parts[n_parts].spi = spi;
-		parts[n_parts].offset = FALCON_EEPROM_BOOTCONFIG_START;
-		parts[n_parts].common.dev_type_name = "EEPROM";
-		parts[n_parts].common.type_name = "sfc_bootconfig";
-		parts[n_parts].common.mtd.type = MTD_RAM;
-		parts[n_parts].common.mtd.flags = MTD_CAP_RAM;
-		parts[n_parts].common.mtd.size =
-			min(spi->size, FALCON_EEPROM_BOOTCONFIG_END) -
-			FALCON_EEPROM_BOOTCONFIG_START;
-		parts[n_parts].common.mtd.erasesize = spi->erase_size;
-		n_parts++;
-	}
-
-	rc = efx_mtd_add(efx, &parts[0].common, n_parts, sizeof(*parts));
-	if (rc)
-		kfree(parts);
-	return rc;
-}
-
-#endif /* CONFIG_SFC_MTD */
-
-/**************************************************************************
- *
- * XMAC operations
- *
- **************************************************************************
- */
-
-/* Configure the XAUI driver that is an output from Falcon */
-static void falcon_setup_xaui(struct efx_nic *efx)
-{
-	efx_oword_t sdctl, txdrv;
-
-	/* Move the XAUI into low power, unless there is no PHY, in
-	 * which case the XAUI will have to drive a cable. */
-	if (efx->phy_type == PHY_TYPE_NONE)
-		return;
-
-	efx_reado(efx, &sdctl, FR_AB_XX_SD_CTL);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVC, FFE_AB_XX_SD_CTL_DRV_DEF);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVC, FFE_AB_XX_SD_CTL_DRV_DEF);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVB, FFE_AB_XX_SD_CTL_DRV_DEF);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVB, FFE_AB_XX_SD_CTL_DRV_DEF);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
-	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
-	efx_writeo(efx, &sdctl, FR_AB_XX_SD_CTL);
-
-	EFX_POPULATE_OWORD_8(txdrv,
-			     FRF_AB_XX_DEQD, FFE_AB_XX_TXDRV_DEQ_DEF,
-			     FRF_AB_XX_DEQC, FFE_AB_XX_TXDRV_DEQ_DEF,
-			     FRF_AB_XX_DEQB, FFE_AB_XX_TXDRV_DEQ_DEF,
-			     FRF_AB_XX_DEQA, FFE_AB_XX_TXDRV_DEQ_DEF,
-			     FRF_AB_XX_DTXD, FFE_AB_XX_TXDRV_DTX_DEF,
-			     FRF_AB_XX_DTXC, FFE_AB_XX_TXDRV_DTX_DEF,
-			     FRF_AB_XX_DTXB, FFE_AB_XX_TXDRV_DTX_DEF,
-			     FRF_AB_XX_DTXA, FFE_AB_XX_TXDRV_DTX_DEF);
-	efx_writeo(efx, &txdrv, FR_AB_XX_TXDRV_CTL);
-}
-
-int falcon_reset_xaui(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t reg;
-	int count;
-
-	/* Don't fetch MAC statistics over an XMAC reset */
-	WARN_ON(nic_data->stats_disable_count == 0);
-
-	/* Start reset sequence */
-	EFX_POPULATE_OWORD_1(reg, FRF_AB_XX_RST_XX_EN, 1);
-	efx_writeo(efx, &reg, FR_AB_XX_PWR_RST);
-
-	/* Wait up to 10 ms for completion, then reinitialise */
-	for (count = 0; count < 1000; count++) {
-		efx_reado(efx, &reg, FR_AB_XX_PWR_RST);
-		if (EFX_OWORD_FIELD(reg, FRF_AB_XX_RST_XX_EN) == 0 &&
-		    EFX_OWORD_FIELD(reg, FRF_AB_XX_SD_RST_ACT) == 0) {
-			falcon_setup_xaui(efx);
-			return 0;
-		}
-		udelay(10);
-	}
-	netif_err(efx, hw, efx->net_dev,
-		  "timed out waiting for XAUI/XGXS reset\n");
-	return -ETIMEDOUT;
-}
-
-static void falcon_ack_status_intr(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t reg;
-
-	if ((efx_nic_rev(efx) != EFX_REV_FALCON_B0) || LOOPBACK_INTERNAL(efx))
-		return;
-
-	/* We expect xgmii faults if the wireside link is down */
-	if (!efx->link_state.up)
-		return;
-
-	/* We can only use this interrupt to signal the negative edge of
-	 * xaui_align [we have to poll the positive edge]. */
-	if (nic_data->xmac_poll_required)
-		return;
-
-	efx_reado(efx, &reg, FR_AB_XM_MGT_INT_MSK);
-}
-
-static bool falcon_xgxs_link_ok(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-	bool align_done, link_ok = false;
-	int sync_status;
-
-	/* Read link status */
-	efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
-
-	align_done = EFX_OWORD_FIELD(reg, FRF_AB_XX_ALIGN_DONE);
-	sync_status = EFX_OWORD_FIELD(reg, FRF_AB_XX_SYNC_STAT);
-	if (align_done && (sync_status == FFE_AB_XX_STAT_ALL_LANES))
-		link_ok = true;
-
-	/* Clear link status ready for next read */
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_COMMA_DET, FFE_AB_XX_STAT_ALL_LANES);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_CHAR_ERR, FFE_AB_XX_STAT_ALL_LANES);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_DISPERR, FFE_AB_XX_STAT_ALL_LANES);
-	efx_writeo(efx, &reg, FR_AB_XX_CORE_STAT);
-
-	return link_ok;
-}
-
-static bool falcon_xmac_link_ok(struct efx_nic *efx)
-{
-	/*
-	 * Check MAC's XGXS link status except when using XGMII loopback
-	 * which bypasses the XGXS block.
-	 * If possible, check PHY's XGXS link status except when using
-	 * MAC loopback.
-	 */
-	return (efx->loopback_mode == LOOPBACK_XGMII ||
-		falcon_xgxs_link_ok(efx)) &&
-		(!(efx->mdio.mmds & (1 << MDIO_MMD_PHYXS)) ||
-		 LOOPBACK_INTERNAL(efx) ||
-		 efx_mdio_phyxgxs_lane_sync(efx));
-}
-
-static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
-{
-	unsigned int max_frame_len;
-	efx_oword_t reg;
-	bool rx_fc = !!(efx->link_state.fc & EFX_FC_RX);
-	bool tx_fc = !!(efx->link_state.fc & EFX_FC_TX);
-
-	/* Configure MAC  - cut-thru mode is hard wired on */
-	EFX_POPULATE_OWORD_3(reg,
-			     FRF_AB_XM_RX_JUMBO_MODE, 1,
-			     FRF_AB_XM_TX_STAT_EN, 1,
-			     FRF_AB_XM_RX_STAT_EN, 1);
-	efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
-
-	/* Configure TX */
-	EFX_POPULATE_OWORD_6(reg,
-			     FRF_AB_XM_TXEN, 1,
-			     FRF_AB_XM_TX_PRMBL, 1,
-			     FRF_AB_XM_AUTO_PAD, 1,
-			     FRF_AB_XM_TXCRC, 1,
-			     FRF_AB_XM_FCNTL, tx_fc,
-			     FRF_AB_XM_IPG, 0x3);
-	efx_writeo(efx, &reg, FR_AB_XM_TX_CFG);
-
-	/* Configure RX */
-	EFX_POPULATE_OWORD_5(reg,
-			     FRF_AB_XM_RXEN, 1,
-			     FRF_AB_XM_AUTO_DEPAD, 0,
-			     FRF_AB_XM_ACPT_ALL_MCAST, 1,
-			     FRF_AB_XM_ACPT_ALL_UCAST, !efx->unicast_filter,
-			     FRF_AB_XM_PASS_CRC_ERR, 1);
-	efx_writeo(efx, &reg, FR_AB_XM_RX_CFG);
-
-	/* Set frame length */
-	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
-	EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_MAX_RX_FRM_SIZE, max_frame_len);
-	efx_writeo(efx, &reg, FR_AB_XM_RX_PARAM);
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_XM_MAX_TX_FRM_SIZE, max_frame_len,
-			     FRF_AB_XM_TX_JUMBO_MODE, 1);
-	efx_writeo(efx, &reg, FR_AB_XM_TX_PARAM);
-
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
-			     FRF_AB_XM_DIS_FCNTL, !rx_fc);
-	efx_writeo(efx, &reg, FR_AB_XM_FC);
-
-	/* Set MAC address */
-	memcpy(&reg, &efx->net_dev->dev_addr[0], 4);
-	efx_writeo(efx, &reg, FR_AB_XM_ADR_LO);
-	memcpy(&reg, &efx->net_dev->dev_addr[4], 2);
-	efx_writeo(efx, &reg, FR_AB_XM_ADR_HI);
-}
-
-static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-	bool xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS);
-	bool xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI);
-	bool xgmii_loopback = (efx->loopback_mode == LOOPBACK_XGMII);
-	bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
-
-	/* XGXS block is flaky and will need to be reset if moving
-	 * into our out of XGMII, XGXS or XAUI loopbacks. */
-	efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
-	old_xgxs_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN);
-	old_xgmii_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN);
-
-	efx_reado(efx, &reg, FR_AB_XX_SD_CTL);
-	old_xaui_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_LPBKA);
-
-	/* The PHY driver may have turned XAUI off */
-	if ((xgxs_loopback != old_xgxs_loopback) ||
-	    (xaui_loopback != old_xaui_loopback) ||
-	    (xgmii_loopback != old_xgmii_loopback))
-		falcon_reset_xaui(efx);
-
-	efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_FORCE_SIG,
-			    (xgxs_loopback || xaui_loopback) ?
-			    FFE_AB_XX_FORCE_SIG_ALL_LANES : 0);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN, xgxs_loopback);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN, xgmii_loopback);
-	efx_writeo(efx, &reg, FR_AB_XX_CORE_STAT);
-
-	efx_reado(efx, &reg, FR_AB_XX_SD_CTL);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKD, xaui_loopback);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKC, xaui_loopback);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKB, xaui_loopback);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKA, xaui_loopback);
-	efx_writeo(efx, &reg, FR_AB_XX_SD_CTL);
-}
-
-
-/* Try to bring up the Falcon side of the Falcon-Phy XAUI link */
-static bool falcon_xmac_link_ok_retry(struct efx_nic *efx, int tries)
-{
-	bool mac_up = falcon_xmac_link_ok(efx);
-
-	if (LOOPBACK_MASK(efx) & LOOPBACKS_EXTERNAL(efx) & LOOPBACKS_WS ||
-	    efx_phy_mode_disabled(efx->phy_mode))
-		/* XAUI link is expected to be down */
-		return mac_up;
-
-	falcon_stop_nic_stats(efx);
-
-	while (!mac_up && tries) {
-		netif_dbg(efx, hw, efx->net_dev, "bashing xaui\n");
-		falcon_reset_xaui(efx);
-		udelay(200);
-
-		mac_up = falcon_xmac_link_ok(efx);
-		--tries;
-	}
-
-	falcon_start_nic_stats(efx);
-
-	return mac_up;
-}
-
-static bool falcon_xmac_check_fault(struct efx_nic *efx)
-{
-	return !falcon_xmac_link_ok_retry(efx, 5);
-}
-
-static int falcon_reconfigure_xmac(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-
-	efx_farch_filter_sync_rx_mode(efx);
-
-	falcon_reconfigure_xgxs_core(efx);
-	falcon_reconfigure_xmac_core(efx);
-
-	falcon_reconfigure_mac_wrapper(efx);
-
-	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 5);
-	falcon_ack_status_intr(efx);
-
-	return 0;
-}
-
-static void falcon_poll_xmac(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-
-	/* We expect xgmii faults if the wireside link is down */
-	if (!efx->link_state.up || !nic_data->xmac_poll_required)
-		return;
-
-	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 1);
-	falcon_ack_status_intr(efx);
-}
-
-/**************************************************************************
- *
- * MAC wrapper
- *
- **************************************************************************
- */
-
-static void falcon_push_multicast_hash(struct efx_nic *efx)
-{
-	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
-
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
-
-	efx_writeo(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
-	efx_writeo(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
-}
-
-static void falcon_reset_macs(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t reg, mac_ctrl;
-	int count;
-
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0) {
-		/* It's not safe to use GLB_CTL_REG to reset the
-		 * macs, so instead use the internal MAC resets
-		 */
-		EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_CORE_RST, 1);
-		efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
-
-		for (count = 0; count < 10000; count++) {
-			efx_reado(efx, &reg, FR_AB_XM_GLB_CFG);
-			if (EFX_OWORD_FIELD(reg, FRF_AB_XM_CORE_RST) ==
-			    0)
-				return;
-			udelay(10);
-		}
-
-		netif_err(efx, hw, efx->net_dev,
-			  "timed out waiting for XMAC core reset\n");
-	}
-
-	/* Mac stats will fail whist the TX fifo is draining */
-	WARN_ON(nic_data->stats_disable_count == 0);
-
-	efx_reado(efx, &mac_ctrl, FR_AB_MAC_CTRL);
-	EFX_SET_OWORD_FIELD(mac_ctrl, FRF_BB_TXFIFO_DRAIN_EN, 1);
-	efx_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
-
-	efx_reado(efx, &reg, FR_AB_GLB_CTL);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_XGTX, 1);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_XGRX, 1);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_EM, 1);
-	efx_writeo(efx, &reg, FR_AB_GLB_CTL);
-
-	count = 0;
-	while (1) {
-		efx_reado(efx, &reg, FR_AB_GLB_CTL);
-		if (!EFX_OWORD_FIELD(reg, FRF_AB_RST_XGTX) &&
-		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_XGRX) &&
-		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_EM)) {
-			netif_dbg(efx, hw, efx->net_dev,
-				  "Completed MAC reset after %d loops\n",
-				  count);
-			break;
-		}
-		if (count > 20) {
-			netif_err(efx, hw, efx->net_dev, "MAC reset failed\n");
-			break;
-		}
-		count++;
-		udelay(10);
-	}
-
-	/* Ensure the correct MAC is selected before statistics
-	 * are re-enabled by the caller */
-	efx_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
-
-	falcon_setup_xaui(efx);
-}
-
-static void falcon_drain_tx_fifo(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-
-	if ((efx_nic_rev(efx) < EFX_REV_FALCON_B0) ||
-	    (efx->loopback_mode != LOOPBACK_NONE))
-		return;
-
-	efx_reado(efx, &reg, FR_AB_MAC_CTRL);
-	/* There is no point in draining more than once */
-	if (EFX_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN))
-		return;
-
-	falcon_reset_macs(efx);
-}
-
-static void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
-		return;
-
-	/* Isolate the MAC -> RX */
-	efx_reado(efx, &reg, FR_AZ_RX_CFG);
-	EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 0);
-	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
-
-	/* Isolate TX -> MAC */
-	falcon_drain_tx_fifo(efx);
-}
-
-static void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
-{
-	struct efx_link_state *link_state = &efx->link_state;
-	efx_oword_t reg;
-	int link_speed, isolate;
-
-	isolate = !!ACCESS_ONCE(efx->reset_pending);
-
-	switch (link_state->speed) {
-	case 10000: link_speed = 3; break;
-	case 1000:  link_speed = 2; break;
-	case 100:   link_speed = 1; break;
-	default:    link_speed = 0; break;
-	}
-
-	/* MAC_LINK_STATUS controls MAC backpressure but doesn't work
-	 * as advertised.  Disable to ensure packets are not
-	 * indefinitely held and TX queue can be flushed at any point
-	 * while the link is down. */
-	EFX_POPULATE_OWORD_5(reg,
-			     FRF_AB_MAC_XOFF_VAL, 0xffff /* max pause time */,
-			     FRF_AB_MAC_BCAD_ACPT, 1,
-			     FRF_AB_MAC_UC_PROM, !efx->unicast_filter,
-			     FRF_AB_MAC_LINK_STATUS, 1, /* always set */
-			     FRF_AB_MAC_SPEED, link_speed);
-	/* On B0, MAC backpressure can be disabled and packets get
-	 * discarded. */
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN,
-				    !link_state->up || isolate);
-	}
-
-	efx_writeo(efx, &reg, FR_AB_MAC_CTRL);
-
-	/* Restore the multicast hash registers. */
-	falcon_push_multicast_hash(efx);
-
-	efx_reado(efx, &reg, FR_AZ_RX_CFG);
-	/* Enable XOFF signal from RX FIFO (we enabled it during NIC
-	 * initialisation but it may read back as 0) */
-	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, 1);
-	/* Unisolate the MAC -> RX */
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, !isolate);
-	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
-}
-
-static void falcon_stats_request(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t reg;
-
-	WARN_ON(nic_data->stats_pending);
-	WARN_ON(nic_data->stats_disable_count);
-
-	FALCON_XMAC_STATS_DMA_FLAG(efx) = 0;
-	nic_data->stats_pending = true;
-	wmb(); /* ensure done flag is clear */
-
-	/* Initiate DMA transfer of stats */
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_MAC_STAT_DMA_CMD, 1,
-			     FRF_AB_MAC_STAT_DMA_ADR,
-			     efx->stats_buffer.dma_addr);
-	efx_writeo(efx, &reg, FR_AB_MAC_STAT_DMA);
-
-	mod_timer(&nic_data->stats_timer, round_jiffies_up(jiffies + HZ / 2));
-}
-
-static void falcon_stats_complete(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-
-	if (!nic_data->stats_pending)
-		return;
-
-	nic_data->stats_pending = false;
-	if (FALCON_XMAC_STATS_DMA_FLAG(efx)) {
-		rmb(); /* read the done flag before the stats */
-		efx_nic_update_stats(falcon_stat_desc, FALCON_STAT_COUNT,
-				     falcon_stat_mask, nic_data->stats,
-				     efx->stats_buffer.addr, true);
-	} else {
-		netif_err(efx, hw, efx->net_dev,
-			  "timed out waiting for statistics\n");
-	}
-}
-
-static void falcon_stats_timer_func(unsigned long context)
-{
-	struct efx_nic *efx = (struct efx_nic *)context;
-	struct falcon_nic_data *nic_data = efx->nic_data;
-
-	spin_lock(&efx->stats_lock);
-
-	falcon_stats_complete(efx);
-	if (nic_data->stats_disable_count == 0)
-		falcon_stats_request(efx);
-
-	spin_unlock(&efx->stats_lock);
-}
-
-static bool falcon_loopback_link_poll(struct efx_nic *efx)
-{
-	struct efx_link_state old_state = efx->link_state;
-
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
-	WARN_ON(!LOOPBACK_INTERNAL(efx));
-
-	efx->link_state.fd = true;
-	efx->link_state.fc = efx->wanted_fc;
-	efx->link_state.up = true;
-	efx->link_state.speed = 10000;
-
-	return !efx_link_state_equal(&efx->link_state, &old_state);
-}
-
-static int falcon_reconfigure_port(struct efx_nic *efx)
-{
-	int rc;
-
-	WARN_ON(efx_nic_rev(efx) > EFX_REV_FALCON_B0);
-
-	/* Poll the PHY link state *before* reconfiguring it. This means we
-	 * will pick up the correct speed (in loopback) to select the correct
-	 * MAC.
-	 */
-	if (LOOPBACK_INTERNAL(efx))
-		falcon_loopback_link_poll(efx);
-	else
-		efx->phy_op->poll(efx);
-
-	falcon_stop_nic_stats(efx);
-	falcon_deconfigure_mac_wrapper(efx);
-
-	falcon_reset_macs(efx);
-
-	efx->phy_op->reconfigure(efx);
-	rc = falcon_reconfigure_xmac(efx);
-	BUG_ON(rc);
-
-	falcon_start_nic_stats(efx);
-
-	/* Synchronise efx->link_state with the kernel */
-	efx_link_status_changed(efx);
-
-	return 0;
-}
-
-/* TX flow control may automatically turn itself off if the link
- * partner (intermittently) stops responding to pause frames. There
- * isn't any indication that this has happened, so the best we do is
- * leave it up to the user to spot this and fix it by cycling transmit
- * flow control on this end.
- */
-
-static void falcon_a1_prepare_enable_fc_tx(struct efx_nic *efx)
-{
-	/* Schedule a reset to recover */
-	efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
-}
-
-static void falcon_b0_prepare_enable_fc_tx(struct efx_nic *efx)
-{
-	/* Recover by resetting the EM block */
-	falcon_stop_nic_stats(efx);
-	falcon_drain_tx_fifo(efx);
-	falcon_reconfigure_xmac(efx);
-	falcon_start_nic_stats(efx);
-}
-
-/**************************************************************************
- *
- * PHY access via GMII
- *
- **************************************************************************
- */
-
-/* Wait for GMII access to complete */
-static int falcon_gmii_wait(struct efx_nic *efx)
-{
-	efx_oword_t md_stat;
-	int count;
-
-	/* wait up to 50ms - taken max from datasheet */
-	for (count = 0; count < 5000; count++) {
-		efx_reado(efx, &md_stat, FR_AB_MD_STAT);
-		if (EFX_OWORD_FIELD(md_stat, FRF_AB_MD_BSY) == 0) {
-			if (EFX_OWORD_FIELD(md_stat, FRF_AB_MD_LNFL) != 0 ||
-			    EFX_OWORD_FIELD(md_stat, FRF_AB_MD_BSERR) != 0) {
-				netif_err(efx, hw, efx->net_dev,
-					  "error from GMII access "
-					  EFX_OWORD_FMT"\n",
-					  EFX_OWORD_VAL(md_stat));
-				return -EIO;
-			}
-			return 0;
-		}
-		udelay(10);
-	}
-	netif_err(efx, hw, efx->net_dev, "timed out waiting for GMII\n");
-	return -ETIMEDOUT;
-}
-
-/* Write an MDIO register of a PHY connected to Falcon. */
-static int falcon_mdio_write(struct net_device *net_dev,
-			     int prtad, int devad, u16 addr, u16 value)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t reg;
-	int rc;
-
-	netif_vdbg(efx, hw, efx->net_dev,
-		   "writing MDIO %d register %d.%d with 0x%04x\n",
-		    prtad, devad, addr, value);
-
-	mutex_lock(&nic_data->mdio_lock);
-
-	/* Check MDIO not currently being accessed */
-	rc = falcon_gmii_wait(efx);
-	if (rc)
-		goto out;
-
-	/* Write the address/ID register */
-	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
-	efx_writeo(efx, &reg, FR_AB_MD_PHY_ADR);
-
-	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
-			     FRF_AB_MD_DEV_ADR, devad);
-	efx_writeo(efx, &reg, FR_AB_MD_ID);
-
-	/* Write data */
-	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_TXD, value);
-	efx_writeo(efx, &reg, FR_AB_MD_TXD);
-
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_MD_WRC, 1,
-			     FRF_AB_MD_GC, 0);
-	efx_writeo(efx, &reg, FR_AB_MD_CS);
-
-	/* Wait for data to be written */
-	rc = falcon_gmii_wait(efx);
-	if (rc) {
-		/* Abort the write operation */
-		EFX_POPULATE_OWORD_2(reg,
-				     FRF_AB_MD_WRC, 0,
-				     FRF_AB_MD_GC, 1);
-		efx_writeo(efx, &reg, FR_AB_MD_CS);
-		udelay(10);
-	}
-
-out:
-	mutex_unlock(&nic_data->mdio_lock);
-	return rc;
-}
-
-/* Read an MDIO register of a PHY connected to Falcon. */
-static int falcon_mdio_read(struct net_device *net_dev,
-			    int prtad, int devad, u16 addr)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t reg;
-	int rc;
-
-	mutex_lock(&nic_data->mdio_lock);
-
-	/* Check MDIO not currently being accessed */
-	rc = falcon_gmii_wait(efx);
-	if (rc)
-		goto out;
-
-	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
-	efx_writeo(efx, &reg, FR_AB_MD_PHY_ADR);
-
-	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
-			     FRF_AB_MD_DEV_ADR, devad);
-	efx_writeo(efx, &reg, FR_AB_MD_ID);
-
-	/* Request data to be read */
-	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_RDC, 1, FRF_AB_MD_GC, 0);
-	efx_writeo(efx, &reg, FR_AB_MD_CS);
-
-	/* Wait for data to become available */
-	rc = falcon_gmii_wait(efx);
-	if (rc == 0) {
-		efx_reado(efx, &reg, FR_AB_MD_RXD);
-		rc = EFX_OWORD_FIELD(reg, FRF_AB_MD_RXD);
-		netif_vdbg(efx, hw, efx->net_dev,
-			   "read from MDIO %d register %d.%d, got %04x\n",
-			   prtad, devad, addr, rc);
-	} else {
-		/* Abort the read operation */
-		EFX_POPULATE_OWORD_2(reg,
-				     FRF_AB_MD_RIC, 0,
-				     FRF_AB_MD_GC, 1);
-		efx_writeo(efx, &reg, FR_AB_MD_CS);
-
-		netif_dbg(efx, hw, efx->net_dev,
-			  "read from MDIO %d register %d.%d, got error %d\n",
-			  prtad, devad, addr, rc);
-	}
-
-out:
-	mutex_unlock(&nic_data->mdio_lock);
-	return rc;
-}
-
-/* This call is responsible for hooking in the MAC and PHY operations */
-static int falcon_probe_port(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	int rc;
-
-	switch (efx->phy_type) {
-	case PHY_TYPE_SFX7101:
-		efx->phy_op = &falcon_sfx7101_phy_ops;
-		break;
-	case PHY_TYPE_QT2022C2:
-	case PHY_TYPE_QT2025C:
-		efx->phy_op = &falcon_qt202x_phy_ops;
-		break;
-	case PHY_TYPE_TXC43128:
-		efx->phy_op = &falcon_txc_phy_ops;
-		break;
-	default:
-		netif_err(efx, probe, efx->net_dev, "Unknown PHY type %d\n",
-			  efx->phy_type);
-		return -ENODEV;
-	}
-
-	/* Fill out MDIO structure and loopback modes */
-	mutex_init(&nic_data->mdio_lock);
-	efx->mdio.mdio_read = falcon_mdio_read;
-	efx->mdio.mdio_write = falcon_mdio_write;
-	rc = efx->phy_op->probe(efx);
-	if (rc != 0)
-		return rc;
-
-	/* Initial assumption */
-	efx->link_state.speed = 10000;
-	efx->link_state.fd = true;
-
-	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
-		efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
-	else
-		efx->wanted_fc = EFX_FC_RX;
-	if (efx->mdio.mmds & MDIO_DEVS_AN)
-		efx->wanted_fc |= EFX_FC_AUTO;
-
-	/* Allocate buffer for stats */
-	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
-				  FALCON_MAC_STATS_SIZE, GFP_KERNEL);
-	if (rc)
-		return rc;
-	netif_dbg(efx, probe, efx->net_dev,
-		  "stats buffer at %llx (virt %p phys %llx)\n",
-		  (u64)efx->stats_buffer.dma_addr,
-		  efx->stats_buffer.addr,
-		  (u64)virt_to_phys(efx->stats_buffer.addr));
-
-	return 0;
-}
-
-static void falcon_remove_port(struct efx_nic *efx)
-{
-	efx->phy_op->remove(efx);
-	efx_nic_free_buffer(efx, &efx->stats_buffer);
-}
-
-/* Global events are basically PHY events */
-static bool
-falcon_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
-{
-	struct efx_nic *efx = channel->efx;
-	struct falcon_nic_data *nic_data = efx->nic_data;
-
-	if (EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_G_PHY0_INTR) ||
-	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XG_PHY0_INTR) ||
-	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XFP_PHY0_INTR))
-		/* Ignored */
-		return true;
-
-	if ((efx_nic_rev(efx) == EFX_REV_FALCON_B0) &&
-	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
-		nic_data->xmac_poll_required = true;
-		return true;
-	}
-
-	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ?
-	    EFX_QWORD_FIELD(*event, FSF_AA_GLB_EV_RX_RECOVERY) :
-	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_RX_RECOVERY)) {
-		netif_err(efx, rx_err, efx->net_dev,
-			  "channel %d seen global RX_RESET event. Resetting.\n",
-			  channel->channel);
-
-		atomic_inc(&efx->rx_reset);
-		efx_schedule_reset(efx, EFX_WORKAROUND_6555(efx) ?
-				   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
-		return true;
-	}
-
-	return false;
-}
-
-/**************************************************************************
- *
- * Falcon test code
- *
- **************************************************************************/
-
-static int
-falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	struct falcon_nvconfig *nvconfig;
-	struct falcon_spi_device *spi;
-	void *region;
-	int rc, magic_num, struct_ver;
-	__le16 *word, *limit;
-	u32 csum;
-
-	if (falcon_spi_present(&nic_data->spi_flash))
-		spi = &nic_data->spi_flash;
-	else if (falcon_spi_present(&nic_data->spi_eeprom))
-		spi = &nic_data->spi_eeprom;
-	else
-		return -EINVAL;
-
-	region = kmalloc(FALCON_NVCONFIG_END, GFP_KERNEL);
-	if (!region)
-		return -ENOMEM;
-	nvconfig = region + FALCON_NVCONFIG_OFFSET;
-
-	mutex_lock(&nic_data->spi_lock);
-	rc = falcon_spi_read(efx, spi, 0, FALCON_NVCONFIG_END, NULL, region);
-	mutex_unlock(&nic_data->spi_lock);
-	if (rc) {
-		netif_err(efx, hw, efx->net_dev, "Failed to read %s\n",
-			  falcon_spi_present(&nic_data->spi_flash) ?
-			  "flash" : "EEPROM");
-		rc = -EIO;
-		goto out;
-	}
-
-	magic_num = le16_to_cpu(nvconfig->board_magic_num);
-	struct_ver = le16_to_cpu(nvconfig->board_struct_ver);
-
-	rc = -EINVAL;
-	if (magic_num != FALCON_NVCONFIG_BOARD_MAGIC_NUM) {
-		netif_err(efx, hw, efx->net_dev,
-			  "NVRAM bad magic 0x%x\n", magic_num);
-		goto out;
-	}
-	if (struct_ver < 2) {
-		netif_err(efx, hw, efx->net_dev,
-			  "NVRAM has ancient version 0x%x\n", struct_ver);
-		goto out;
-	} else if (struct_ver < 4) {
-		word = &nvconfig->board_magic_num;
-		limit = (__le16 *) (nvconfig + 1);
-	} else {
-		word = region;
-		limit = region + FALCON_NVCONFIG_END;
-	}
-	for (csum = 0; word < limit; ++word)
-		csum += le16_to_cpu(*word);
-
-	if (~csum & 0xffff) {
-		netif_err(efx, hw, efx->net_dev,
-			  "NVRAM has incorrect checksum\n");
-		goto out;
-	}
-
-	rc = 0;
-	if (nvconfig_out)
-		memcpy(nvconfig_out, nvconfig, sizeof(*nvconfig));
-
- out:
-	kfree(region);
-	return rc;
-}
-
-static int falcon_test_nvram(struct efx_nic *efx)
-{
-	return falcon_read_nvram(efx, NULL);
-}
-
-static const struct efx_farch_register_test falcon_b0_register_tests[] = {
-	{ FR_AZ_ADR_REGION,
-	  EFX_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
-	{ FR_AZ_RX_CFG,
-	  EFX_OWORD32(0xFFFFFFFE, 0x00017FFF, 0x00000000, 0x00000000) },
-	{ FR_AZ_TX_CFG,
-	  EFX_OWORD32(0x7FFF0037, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AZ_TX_RESERVED,
-	  EFX_OWORD32(0xFFFEFE80, 0x1FFFFFFF, 0x020000FE, 0x007FFFFF) },
-	{ FR_AB_MAC_CTRL,
-	  EFX_OWORD32(0xFFFF0000, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AZ_SRM_TX_DC_CFG,
-	  EFX_OWORD32(0x001FFFFF, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AZ_RX_DC_CFG,
-	  EFX_OWORD32(0x0000000F, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AZ_RX_DC_PF_WM,
-	  EFX_OWORD32(0x000003FF, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_BZ_DP_CTRL,
-	  EFX_OWORD32(0x00000FFF, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_GM_CFG2,
-	  EFX_OWORD32(0x00007337, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_GMF_CFG0,
-	  EFX_OWORD32(0x00001F1F, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_XM_GLB_CFG,
-	  EFX_OWORD32(0x00000C68, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_XM_TX_CFG,
-	  EFX_OWORD32(0x00080164, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_XM_RX_CFG,
-	  EFX_OWORD32(0x07100A0C, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_XM_RX_PARAM,
-	  EFX_OWORD32(0x00001FF8, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_XM_FC,
-	  EFX_OWORD32(0xFFFF0001, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_XM_ADR_LO,
-	  EFX_OWORD32(0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000) },
-	{ FR_AB_XX_SD_CTL,
-	  EFX_OWORD32(0x0003FF0F, 0x00000000, 0x00000000, 0x00000000) },
-};
-
-static int
-falcon_b0_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
-{
-	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
-	int rc, rc2;
-
-	mutex_lock(&efx->mac_lock);
-	if (efx->loopback_modes) {
-		/* We need the 312 clock from the PHY to test the XMAC
-		 * registers, so move into XGMII loopback if available */
-		if (efx->loopback_modes & (1 << LOOPBACK_XGMII))
-			efx->loopback_mode = LOOPBACK_XGMII;
-		else
-			efx->loopback_mode = __ffs(efx->loopback_modes);
-	}
-	__efx_reconfigure_port(efx);
-	mutex_unlock(&efx->mac_lock);
-
-	efx_reset_down(efx, reset_method);
-
-	tests->registers =
-		efx_farch_test_registers(efx, falcon_b0_register_tests,
-					 ARRAY_SIZE(falcon_b0_register_tests))
-		? -1 : 1;
-
-	rc = falcon_reset_hw(efx, reset_method);
-	rc2 = efx_reset_up(efx, reset_method, rc == 0);
-	return rc ? rc : rc2;
-}
-
-/**************************************************************************
- *
- * Device reset
- *
- **************************************************************************
- */
-
-static enum reset_type falcon_map_reset_reason(enum reset_type reason)
-{
-	switch (reason) {
-	case RESET_TYPE_RX_RECOVERY:
-	case RESET_TYPE_DMA_ERROR:
-	case RESET_TYPE_TX_SKIP:
-		/* These can occasionally occur due to hardware bugs.
-		 * We try to reset without disrupting the link.
-		 */
-		return RESET_TYPE_INVISIBLE;
-	default:
-		return RESET_TYPE_ALL;
-	}
-}
-
-static int falcon_map_reset_flags(u32 *flags)
-{
-	enum {
-		FALCON_RESET_INVISIBLE = (ETH_RESET_DMA | ETH_RESET_FILTER |
-					  ETH_RESET_OFFLOAD | ETH_RESET_MAC),
-		FALCON_RESET_ALL = FALCON_RESET_INVISIBLE | ETH_RESET_PHY,
-		FALCON_RESET_WORLD = FALCON_RESET_ALL | ETH_RESET_IRQ,
-	};
-
-	if ((*flags & FALCON_RESET_WORLD) == FALCON_RESET_WORLD) {
-		*flags &= ~FALCON_RESET_WORLD;
-		return RESET_TYPE_WORLD;
-	}
-
-	if ((*flags & FALCON_RESET_ALL) == FALCON_RESET_ALL) {
-		*flags &= ~FALCON_RESET_ALL;
-		return RESET_TYPE_ALL;
-	}
-
-	if ((*flags & FALCON_RESET_INVISIBLE) == FALCON_RESET_INVISIBLE) {
-		*flags &= ~FALCON_RESET_INVISIBLE;
-		return RESET_TYPE_INVISIBLE;
-	}
-
-	return -EINVAL;
-}
-
-/* Resets NIC to known state.  This routine must be called in process
- * context and is allowed to sleep. */
-static int __falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t glb_ctl_reg_ker;
-	int rc;
-
-	netif_dbg(efx, hw, efx->net_dev, "performing %s hardware reset\n",
-		  RESET_TYPE(method));
-
-	/* Initiate device reset */
-	if (method == RESET_TYPE_WORLD) {
-		rc = pci_save_state(efx->pci_dev);
-		if (rc) {
-			netif_err(efx, drv, efx->net_dev,
-				  "failed to backup PCI state of primary "
-				  "function prior to hardware reset\n");
-			goto fail1;
-		}
-		if (efx_nic_is_dual_func(efx)) {
-			rc = pci_save_state(nic_data->pci_dev2);
-			if (rc) {
-				netif_err(efx, drv, efx->net_dev,
-					  "failed to backup PCI state of "
-					  "secondary function prior to "
-					  "hardware reset\n");
-				goto fail2;
-			}
-		}
-
-		EFX_POPULATE_OWORD_2(glb_ctl_reg_ker,
-				     FRF_AB_EXT_PHY_RST_DUR,
-				     FFE_AB_EXT_PHY_RST_DUR_10240US,
-				     FRF_AB_SWRST, 1);
-	} else {
-		EFX_POPULATE_OWORD_7(glb_ctl_reg_ker,
-				     /* exclude PHY from "invisible" reset */
-				     FRF_AB_EXT_PHY_RST_CTL,
-				     method == RESET_TYPE_INVISIBLE,
-				     /* exclude EEPROM/flash and PCIe */
-				     FRF_AB_PCIE_CORE_RST_CTL, 1,
-				     FRF_AB_PCIE_NSTKY_RST_CTL, 1,
-				     FRF_AB_PCIE_SD_RST_CTL, 1,
-				     FRF_AB_EE_RST_CTL, 1,
-				     FRF_AB_EXT_PHY_RST_DUR,
-				     FFE_AB_EXT_PHY_RST_DUR_10240US,
-				     FRF_AB_SWRST, 1);
-	}
-	efx_writeo(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
-
-	netif_dbg(efx, hw, efx->net_dev, "waiting for hardware reset\n");
-	schedule_timeout_uninterruptible(HZ / 20);
-
-	/* Restore PCI configuration if needed */
-	if (method == RESET_TYPE_WORLD) {
-		if (efx_nic_is_dual_func(efx))
-			pci_restore_state(nic_data->pci_dev2);
-		pci_restore_state(efx->pci_dev);
-		netif_dbg(efx, drv, efx->net_dev,
-			  "successfully restored PCI config\n");
-	}
-
-	/* Assert that reset complete */
-	efx_reado(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
-	if (EFX_OWORD_FIELD(glb_ctl_reg_ker, FRF_AB_SWRST) != 0) {
-		rc = -ETIMEDOUT;
-		netif_err(efx, hw, efx->net_dev,
-			  "timed out waiting for hardware reset\n");
-		goto fail3;
-	}
-	netif_dbg(efx, hw, efx->net_dev, "hardware reset complete\n");
-
-	return 0;
-
-	/* pci_save_state() and pci_restore_state() MUST be called in pairs */
-fail2:
-	pci_restore_state(efx->pci_dev);
-fail1:
-fail3:
-	return rc;
-}
-
-static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	int rc;
-
-	mutex_lock(&nic_data->spi_lock);
-	rc = __falcon_reset_hw(efx, method);
-	mutex_unlock(&nic_data->spi_lock);
-
-	return rc;
-}
-
-static void falcon_monitor(struct efx_nic *efx)
-{
-	bool link_changed;
-	int rc;
-
-	BUG_ON(!mutex_is_locked(&efx->mac_lock));
-
-	rc = falcon_board(efx)->type->monitor(efx);
-	if (rc) {
-		netif_err(efx, hw, efx->net_dev,
-			  "Board sensor %s; shutting down PHY\n",
-			  (rc == -ERANGE) ? "reported fault" : "failed");
-		efx->phy_mode |= PHY_MODE_LOW_POWER;
-		rc = __efx_reconfigure_port(efx);
-		WARN_ON(rc);
-	}
-
-	if (LOOPBACK_INTERNAL(efx))
-		link_changed = falcon_loopback_link_poll(efx);
-	else
-		link_changed = efx->phy_op->poll(efx);
-
-	if (link_changed) {
-		falcon_stop_nic_stats(efx);
-		falcon_deconfigure_mac_wrapper(efx);
-
-		falcon_reset_macs(efx);
-		rc = falcon_reconfigure_xmac(efx);
-		BUG_ON(rc);
-
-		falcon_start_nic_stats(efx);
-
-		efx_link_status_changed(efx);
-	}
-
-	falcon_poll_xmac(efx);
-}
-
-/* Zeroes out the SRAM contents.  This routine must be called in
- * process context and is allowed to sleep.
- */
-static int falcon_reset_sram(struct efx_nic *efx)
-{
-	efx_oword_t srm_cfg_reg_ker, gpio_cfg_reg_ker;
-	int count;
-
-	/* Set the SRAM wake/sleep GPIO appropriately. */
-	efx_reado(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
-	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OEN, 1);
-	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OUT, 1);
-	efx_writeo(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
-
-	/* Initiate SRAM reset */
-	EFX_POPULATE_OWORD_2(srm_cfg_reg_ker,
-			     FRF_AZ_SRM_INIT_EN, 1,
-			     FRF_AZ_SRM_NB_SZ, 0);
-	efx_writeo(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
-
-	/* Wait for SRAM reset to complete */
-	count = 0;
-	do {
-		netif_dbg(efx, hw, efx->net_dev,
-			  "waiting for SRAM reset (attempt %d)...\n", count);
-
-		/* SRAM reset is slow; expect around 16ms */
-		schedule_timeout_uninterruptible(HZ / 50);
-
-		/* Check for reset complete */
-		efx_reado(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
-		if (!EFX_OWORD_FIELD(srm_cfg_reg_ker, FRF_AZ_SRM_INIT_EN)) {
-			netif_dbg(efx, hw, efx->net_dev,
-				  "SRAM reset complete\n");
-
-			return 0;
-		}
-	} while (++count < 20);	/* wait up to 0.4 sec */
-
-	netif_err(efx, hw, efx->net_dev, "timed out waiting for SRAM reset\n");
-	return -ETIMEDOUT;
-}
-
-static void falcon_spi_device_init(struct efx_nic *efx,
-				  struct falcon_spi_device *spi_device,
-				  unsigned int device_id, u32 device_type)
-{
-	if (device_type != 0) {
-		spi_device->device_id = device_id;
-		spi_device->size =
-			1 << SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_SIZE);
-		spi_device->addr_len =
-			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ADDR_LEN);
-		spi_device->munge_address = (spi_device->size == 1 << 9 &&
-					     spi_device->addr_len == 1);
-		spi_device->erase_command =
-			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ERASE_CMD);
-		spi_device->erase_size =
-			1 << SPI_DEV_TYPE_FIELD(device_type,
-						SPI_DEV_TYPE_ERASE_SIZE);
-		spi_device->block_size =
-			1 << SPI_DEV_TYPE_FIELD(device_type,
-						SPI_DEV_TYPE_BLOCK_SIZE);
-	} else {
-		spi_device->size = 0;
-	}
-}
-
-/* Extract non-volatile configuration */
-static int falcon_probe_nvconfig(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	struct falcon_nvconfig *nvconfig;
-	int rc;
-
-	nvconfig = kmalloc(sizeof(*nvconfig), GFP_KERNEL);
-	if (!nvconfig)
-		return -ENOMEM;
-
-	rc = falcon_read_nvram(efx, nvconfig);
-	if (rc)
-		goto out;
-
-	efx->phy_type = nvconfig->board_v2.port0_phy_type;
-	efx->mdio.prtad = nvconfig->board_v2.port0_phy_addr;
-
-	if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
-		falcon_spi_device_init(
-			efx, &nic_data->spi_flash, FFE_AB_SPI_DEVICE_FLASH,
-			le32_to_cpu(nvconfig->board_v3
-				    .spi_device_type[FFE_AB_SPI_DEVICE_FLASH]));
-		falcon_spi_device_init(
-			efx, &nic_data->spi_eeprom, FFE_AB_SPI_DEVICE_EEPROM,
-			le32_to_cpu(nvconfig->board_v3
-				    .spi_device_type[FFE_AB_SPI_DEVICE_EEPROM]));
-	}
-
-	/* Read the MAC addresses */
-	ether_addr_copy(efx->net_dev->perm_addr, nvconfig->mac_address[0]);
-
-	netif_dbg(efx, probe, efx->net_dev, "PHY is %d phy_id %d\n",
-		  efx->phy_type, efx->mdio.prtad);
-
-	rc = falcon_probe_board(efx,
-				le16_to_cpu(nvconfig->board_v2.board_revision));
-out:
-	kfree(nvconfig);
-	return rc;
-}
-
-static int falcon_dimension_resources(struct efx_nic *efx)
-{
-	efx->rx_dc_base = 0x20000;
-	efx->tx_dc_base = 0x26000;
-	return 0;
-}
-
-/* Probe all SPI devices on the NIC */
-static void falcon_probe_spi_devices(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
-	int boot_dev;
-
-	efx_reado(efx, &gpio_ctl, FR_AB_GPIO_CTL);
-	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
-	efx_reado(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
-
-	if (EFX_OWORD_FIELD(gpio_ctl, FRF_AB_GPIO3_PWRUP_VALUE)) {
-		boot_dev = (EFX_OWORD_FIELD(nic_stat, FRF_AB_SF_PRST) ?
-			    FFE_AB_SPI_DEVICE_FLASH : FFE_AB_SPI_DEVICE_EEPROM);
-		netif_dbg(efx, probe, efx->net_dev, "Booted from %s\n",
-			  boot_dev == FFE_AB_SPI_DEVICE_FLASH ?
-			  "flash" : "EEPROM");
-	} else {
-		/* Disable VPD and set clock dividers to safe
-		 * values for initial programming. */
-		boot_dev = -1;
-		netif_dbg(efx, probe, efx->net_dev,
-			  "Booted from internal ASIC settings;"
-			  " setting SPI config\n");
-		EFX_POPULATE_OWORD_3(ee_vpd_cfg, FRF_AB_EE_VPD_EN, 0,
-				     /* 125 MHz / 7 ~= 20 MHz */
-				     FRF_AB_EE_SF_CLOCK_DIV, 7,
-				     /* 125 MHz / 63 ~= 2 MHz */
-				     FRF_AB_EE_EE_CLOCK_DIV, 63);
-		efx_writeo(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
-	}
-
-	mutex_init(&nic_data->spi_lock);
-
-	if (boot_dev == FFE_AB_SPI_DEVICE_FLASH)
-		falcon_spi_device_init(efx, &nic_data->spi_flash,
-				       FFE_AB_SPI_DEVICE_FLASH,
-				       default_flash_type);
-	if (boot_dev == FFE_AB_SPI_DEVICE_EEPROM)
-		falcon_spi_device_init(efx, &nic_data->spi_eeprom,
-				       FFE_AB_SPI_DEVICE_EEPROM,
-				       large_eeprom_type);
-}
-
-static unsigned int falcon_a1_mem_map_size(struct efx_nic *efx)
-{
-	return 0x20000;
-}
-
-static unsigned int falcon_b0_mem_map_size(struct efx_nic *efx)
-{
-	/* Map everything up to and including the RSS indirection table.
-	 * The PCI core takes care of mapping the MSI-X tables.
-	 */
-	return FR_BZ_RX_INDIRECTION_TBL +
-		FR_BZ_RX_INDIRECTION_TBL_STEP * FR_BZ_RX_INDIRECTION_TBL_ROWS;
-}
-
-static int falcon_probe_nic(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data;
-	struct falcon_board *board;
-	int rc;
-
-	efx->primary = efx; /* only one usable function per controller */
-
-	/* Allocate storage for hardware specific data */
-	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
-	if (!nic_data)
-		return -ENOMEM;
-	efx->nic_data = nic_data;
-
-	rc = -ENODEV;
-
-	if (efx_farch_fpga_ver(efx) != 0) {
-		netif_err(efx, probe, efx->net_dev,
-			  "Falcon FPGA not supported\n");
-		goto fail1;
-	}
-
-	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1) {
-		efx_oword_t nic_stat;
-		struct pci_dev *dev;
-		u8 pci_rev = efx->pci_dev->revision;
-
-		if ((pci_rev == 0xff) || (pci_rev == 0)) {
-			netif_err(efx, probe, efx->net_dev,
-				  "Falcon rev A0 not supported\n");
-			goto fail1;
-		}
-		efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
-		if (EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) == 0) {
-			netif_err(efx, probe, efx->net_dev,
-				  "Falcon rev A1 1G not supported\n");
-			goto fail1;
-		}
-		if (EFX_OWORD_FIELD(nic_stat, FRF_AA_STRAP_PCIE) == 0) {
-			netif_err(efx, probe, efx->net_dev,
-				  "Falcon rev A1 PCI-X not supported\n");
-			goto fail1;
-		}
-
-		dev = pci_dev_get(efx->pci_dev);
-		while ((dev = pci_get_device(PCI_VENDOR_ID_SOLARFLARE,
-					     PCI_DEVICE_ID_SOLARFLARE_SFC4000A_1,
-					     dev))) {
-			if (dev->bus == efx->pci_dev->bus &&
-			    dev->devfn == efx->pci_dev->devfn + 1) {
-				nic_data->pci_dev2 = dev;
-				break;
-			}
-		}
-		if (!nic_data->pci_dev2) {
-			netif_err(efx, probe, efx->net_dev,
-				  "failed to find secondary function\n");
-			rc = -ENODEV;
-			goto fail2;
-		}
-	}
-
-	/* Now we can reset the NIC */
-	rc = __falcon_reset_hw(efx, RESET_TYPE_ALL);
-	if (rc) {
-		netif_err(efx, probe, efx->net_dev, "failed to reset NIC\n");
-		goto fail3;
-	}
-
-	/* Allocate memory for INT_KER */
-	rc = efx_nic_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t),
-				  GFP_KERNEL);
-	if (rc)
-		goto fail4;
-	BUG_ON(efx->irq_status.dma_addr & 0x0f);
-
-	netif_dbg(efx, probe, efx->net_dev,
-		  "INT_KER at %llx (virt %p phys %llx)\n",
-		  (u64)efx->irq_status.dma_addr,
-		  efx->irq_status.addr,
-		  (u64)virt_to_phys(efx->irq_status.addr));
-
-	falcon_probe_spi_devices(efx);
-
-	/* Read in the non-volatile configuration */
-	rc = falcon_probe_nvconfig(efx);
-	if (rc) {
-		if (rc == -EINVAL)
-			netif_err(efx, probe, efx->net_dev, "NVRAM is invalid\n");
-		goto fail5;
-	}
-
-	efx->max_channels = (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ? 4 :
-			     EFX_MAX_CHANNELS);
-	efx->max_tx_channels = efx->max_channels;
-	efx->timer_quantum_ns = 4968; /* 621 cycles */
-	efx->timer_max_ns = efx->type->timer_period_max *
-			    efx->timer_quantum_ns;
-
-	/* Initialise I2C adapter */
-	board = falcon_board(efx);
-	board->i2c_adap.owner = THIS_MODULE;
-	board->i2c_data = falcon_i2c_bit_operations;
-	board->i2c_data.data = efx;
-	board->i2c_adap.algo_data = &board->i2c_data;
-	board->i2c_adap.dev.parent = &efx->pci_dev->dev;
-	strlcpy(board->i2c_adap.name, "SFC4000 GPIO",
-		sizeof(board->i2c_adap.name));
-	rc = i2c_bit_add_bus(&board->i2c_adap);
-	if (rc)
-		goto fail5;
-
-	rc = falcon_board(efx)->type->init(efx);
-	if (rc) {
-		netif_err(efx, probe, efx->net_dev,
-			  "failed to initialise board\n");
-		goto fail6;
-	}
-
-	nic_data->stats_disable_count = 1;
-	setup_timer(&nic_data->stats_timer, &falcon_stats_timer_func,
-		    (unsigned long)efx);
-
-	return 0;
-
- fail6:
-	i2c_del_adapter(&board->i2c_adap);
-	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
- fail5:
-	efx_nic_free_buffer(efx, &efx->irq_status);
- fail4:
- fail3:
-	if (nic_data->pci_dev2) {
-		pci_dev_put(nic_data->pci_dev2);
-		nic_data->pci_dev2 = NULL;
-	}
- fail2:
- fail1:
-	kfree(efx->nic_data);
-	return rc;
-}
-
-static void falcon_init_rx_cfg(struct efx_nic *efx)
-{
-	/* RX control FIFO thresholds (32 entries) */
-	const unsigned ctrl_xon_thr = 20;
-	const unsigned ctrl_xoff_thr = 25;
-	efx_oword_t reg;
-
-	efx_reado(efx, &reg, FR_AZ_RX_CFG);
-	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1) {
-		/* Data FIFO size is 5.5K.  The RX DMA engine only
-		 * supports scattering for user-mode queues, but will
-		 * split DMA writes at intervals of RX_USR_BUF_SIZE
-		 * (32-byte units) even for kernel-mode queues.  We
-		 * set it to be so large that that never happens.
-		 */
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_DESC_PUSH_EN, 0);
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_USR_BUF_SIZE,
-				    (3 * 4096) >> 5);
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_MAC_TH, 512 >> 8);
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_MAC_TH, 2048 >> 8);
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_TX_TH, ctrl_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_TX_TH, ctrl_xoff_thr);
-	} else {
-		/* Data FIFO size is 80K; register fields moved */
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_DESC_PUSH_EN, 0);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_USR_BUF_SIZE,
-				    EFX_RX_USR_BUF_SIZE >> 5);
-		/* Send XON and XOFF at ~3 * max MTU away from empty/full */
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_MAC_TH, 27648 >> 8);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_MAC_TH, 54272 >> 8);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_TX_TH, ctrl_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
-
-		/* Enable hash insertion. This is broken for the
-		 * 'Falcon' hash so also select Toeplitz TCP/IPv4 and
-		 * IPv4 hashes. */
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_INSRT_HDR, 1);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_ALG, 1);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_IP_HASH, 1);
-	}
-	/* Always enable XOFF signal from RX FIFO.  We enable
-	 * or disable transmission of pause frames at the MAC. */
-	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, 1);
-	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
-}
-
-/* This call performs hardware-specific global initialisation, such as
- * defining the descriptor cache sizes and number of RSS channels.
- * It does not set up any buffers, descriptor rings or event queues.
- */
-static int falcon_init_nic(struct efx_nic *efx)
-{
-	efx_oword_t temp;
-	int rc;
-
-	/* Use on-chip SRAM */
-	efx_reado(efx, &temp, FR_AB_NIC_STAT);
-	EFX_SET_OWORD_FIELD(temp, FRF_AB_ONCHIP_SRAM, 1);
-	efx_writeo(efx, &temp, FR_AB_NIC_STAT);
-
-	rc = falcon_reset_sram(efx);
-	if (rc)
-		return rc;
-
-	/* Clear the parity enables on the TX data fifos as
-	 * they produce false parity errors because of timing issues
-	 */
-	if (EFX_WORKAROUND_5129(efx)) {
-		efx_reado(efx, &temp, FR_AZ_CSR_SPARE);
-		EFX_SET_OWORD_FIELD(temp, FRF_AB_MEM_PERR_EN_TX_DATA, 0);
-		efx_writeo(efx, &temp, FR_AZ_CSR_SPARE);
-	}
-
-	if (EFX_WORKAROUND_7244(efx)) {
-		efx_reado(efx, &temp, FR_BZ_RX_FILTER_CTL);
-		EFX_SET_OWORD_FIELD(temp, FRF_BZ_UDP_FULL_SRCH_LIMIT, 8);
-		EFX_SET_OWORD_FIELD(temp, FRF_BZ_UDP_WILD_SRCH_LIMIT, 8);
-		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TCP_FULL_SRCH_LIMIT, 8);
-		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TCP_WILD_SRCH_LIMIT, 8);
-		efx_writeo(efx, &temp, FR_BZ_RX_FILTER_CTL);
-	}
-
-	/* XXX This is documented only for Falcon A0/A1 */
-	/* Setup RX.  Wait for descriptor is broken and must
-	 * be disabled.  RXDP recovery shouldn't be needed, but is.
-	 */
-	efx_reado(efx, &temp, FR_AA_RX_SELF_RST);
-	EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_NODESC_WAIT_DIS, 1);
-	EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_SELF_RST_EN, 1);
-	if (EFX_WORKAROUND_5583(efx))
-		EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_ISCSI_DIS, 1);
-	efx_writeo(efx, &temp, FR_AA_RX_SELF_RST);
-
-	/* Do not enable TX_NO_EOP_DISC_EN, since it limits packets to 16
-	 * descriptors (which is bad).
-	 */
-	efx_reado(efx, &temp, FR_AZ_TX_CFG);
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_NO_EOP_DISC_EN, 0);
-	efx_writeo(efx, &temp, FR_AZ_TX_CFG);
-
-	falcon_init_rx_cfg(efx);
-
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		falcon_b0_rx_push_rss_config(efx, false, efx->rx_indir_table);
-
-		/* Set destination of both TX and RX Flush events */
-		EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
-		efx_writeo(efx, &temp, FR_BZ_DP_CTRL);
-	}
-
-	efx_farch_init_common(efx);
-
-	return 0;
-}
-
-static void falcon_remove_nic(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	struct falcon_board *board = falcon_board(efx);
-
-	board->type->fini(efx);
-
-	/* Remove I2C adapter and clear it in preparation for a retry */
-	i2c_del_adapter(&board->i2c_adap);
-	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
-
-	efx_nic_free_buffer(efx, &efx->irq_status);
-
-	__falcon_reset_hw(efx, RESET_TYPE_ALL);
-
-	/* Release the second function after the reset */
-	if (nic_data->pci_dev2) {
-		pci_dev_put(nic_data->pci_dev2);
-		nic_data->pci_dev2 = NULL;
-	}
-
-	/* Tear down the private nic state */
-	kfree(efx->nic_data);
-	efx->nic_data = NULL;
-}
-
-static size_t falcon_describe_nic_stats(struct efx_nic *efx, u8 *names)
-{
-	return efx_nic_describe_stats(falcon_stat_desc, FALCON_STAT_COUNT,
-				      falcon_stat_mask, names);
-}
-
-static size_t falcon_update_nic_stats(struct efx_nic *efx, u64 *full_stats,
-				      struct rtnl_link_stats64 *core_stats)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	u64 *stats = nic_data->stats;
-	efx_oword_t cnt;
-
-	if (!nic_data->stats_disable_count) {
-		efx_reado(efx, &cnt, FR_AZ_RX_NODESC_DROP);
-		stats[FALCON_STAT_rx_nodesc_drop_cnt] +=
-			EFX_OWORD_FIELD(cnt, FRF_AB_RX_NODESC_DROP_CNT);
-
-		if (nic_data->stats_pending &&
-		    FALCON_XMAC_STATS_DMA_FLAG(efx)) {
-			nic_data->stats_pending = false;
-			rmb(); /* read the done flag before the stats */
-			efx_nic_update_stats(
-				falcon_stat_desc, FALCON_STAT_COUNT,
-				falcon_stat_mask,
-				stats, efx->stats_buffer.addr, true);
-		}
-
-		/* Update derived statistic */
-		efx_update_diff_stat(&stats[FALCON_STAT_rx_bad_bytes],
-				     stats[FALCON_STAT_rx_bytes] -
-				     stats[FALCON_STAT_rx_good_bytes] -
-				     stats[FALCON_STAT_rx_control] * 64);
-		efx_update_sw_stats(efx, stats);
-	}
-
-	if (full_stats)
-		memcpy(full_stats, stats, sizeof(u64) * FALCON_STAT_COUNT);
-
-	if (core_stats) {
-		core_stats->rx_packets = stats[FALCON_STAT_rx_packets];
-		core_stats->tx_packets = stats[FALCON_STAT_tx_packets];
-		core_stats->rx_bytes = stats[FALCON_STAT_rx_bytes];
-		core_stats->tx_bytes = stats[FALCON_STAT_tx_bytes];
-		core_stats->rx_dropped = stats[FALCON_STAT_rx_nodesc_drop_cnt] +
-					 stats[GENERIC_STAT_rx_nodesc_trunc] +
-					 stats[GENERIC_STAT_rx_noskb_drops];
-		core_stats->multicast = stats[FALCON_STAT_rx_multicast];
-		core_stats->rx_length_errors =
-			stats[FALCON_STAT_rx_gtjumbo] +
-			stats[FALCON_STAT_rx_length_error];
-		core_stats->rx_crc_errors = stats[FALCON_STAT_rx_bad];
-		core_stats->rx_frame_errors = stats[FALCON_STAT_rx_align_error];
-		core_stats->rx_fifo_errors = stats[FALCON_STAT_rx_overflow];
-
-		core_stats->rx_errors = (core_stats->rx_length_errors +
-					 core_stats->rx_crc_errors +
-					 core_stats->rx_frame_errors +
-					 stats[FALCON_STAT_rx_symbol_error]);
-	}
-
-	return FALCON_STAT_COUNT;
-}
-
-void falcon_start_nic_stats(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-
-	spin_lock_bh(&efx->stats_lock);
-	if (--nic_data->stats_disable_count == 0)
-		falcon_stats_request(efx);
-	spin_unlock_bh(&efx->stats_lock);
-}
-
-/* We don't acutally pull stats on falcon. Wait 10ms so that
- * they arrive when we call this just after start_stats
- */
-static void falcon_pull_nic_stats(struct efx_nic *efx)
-{
-	msleep(10);
-}
-
-void falcon_stop_nic_stats(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	int i;
-
-	might_sleep();
-
-	spin_lock_bh(&efx->stats_lock);
-	++nic_data->stats_disable_count;
-	spin_unlock_bh(&efx->stats_lock);
-
-	del_timer_sync(&nic_data->stats_timer);
-
-	/* Wait enough time for the most recent transfer to
-	 * complete. */
-	for (i = 0; i < 4 && nic_data->stats_pending; i++) {
-		if (FALCON_XMAC_STATS_DMA_FLAG(efx))
-			break;
-		msleep(1);
-	}
-
-	spin_lock_bh(&efx->stats_lock);
-	falcon_stats_complete(efx);
-	spin_unlock_bh(&efx->stats_lock);
-}
-
-static void falcon_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
-{
-	falcon_board(efx)->type->set_id_led(efx, mode);
-}
-
-/**************************************************************************
- *
- * Wake on LAN
- *
- **************************************************************************
- */
-
-static void falcon_get_wol(struct efx_nic *efx, struct ethtool_wolinfo *wol)
-{
-	wol->supported = 0;
-	wol->wolopts = 0;
-	memset(&wol->sopass, 0, sizeof(wol->sopass));
-}
-
-static int falcon_set_wol(struct efx_nic *efx, u32 type)
-{
-	if (type != 0)
-		return -EINVAL;
-	return 0;
-}
-
-/**************************************************************************
- *
- * Revision-dependent attributes used by efx.c and nic.c
- *
- **************************************************************************
- */
-
-const struct efx_nic_type falcon_a1_nic_type = {
-	.is_vf = false,
-	.mem_bar = EFX_MEM_BAR,
-	.mem_map_size = falcon_a1_mem_map_size,
-	.probe = falcon_probe_nic,
-	.remove = falcon_remove_nic,
-	.init = falcon_init_nic,
-	.dimension_resources = falcon_dimension_resources,
-	.fini = falcon_irq_ack_a1,
-	.monitor = falcon_monitor,
-	.map_reset_reason = falcon_map_reset_reason,
-	.map_reset_flags = falcon_map_reset_flags,
-	.reset = falcon_reset_hw,
-	.probe_port = falcon_probe_port,
-	.remove_port = falcon_remove_port,
-	.handle_global_event = falcon_handle_global_event,
-	.fini_dmaq = efx_farch_fini_dmaq,
-	.prepare_flush = falcon_prepare_flush,
-	.finish_flush = efx_port_dummy_op_void,
-	.prepare_flr = efx_port_dummy_op_void,
-	.finish_flr = efx_farch_finish_flr,
-	.describe_stats = falcon_describe_nic_stats,
-	.update_stats = falcon_update_nic_stats,
-	.start_stats = falcon_start_nic_stats,
-	.pull_stats = falcon_pull_nic_stats,
-	.stop_stats = falcon_stop_nic_stats,
-	.set_id_led = falcon_set_id_led,
-	.push_irq_moderation = falcon_push_irq_moderation,
-	.reconfigure_port = falcon_reconfigure_port,
-	.prepare_enable_fc_tx = falcon_a1_prepare_enable_fc_tx,
-	.reconfigure_mac = falcon_reconfigure_xmac,
-	.check_mac_fault = falcon_xmac_check_fault,
-	.get_wol = falcon_get_wol,
-	.set_wol = falcon_set_wol,
-	.resume_wol = efx_port_dummy_op_void,
-	.test_nvram = falcon_test_nvram,
-	.irq_enable_master = efx_farch_irq_enable_master,
-	.irq_test_generate = efx_farch_irq_test_generate,
-	.irq_disable_non_ev = efx_farch_irq_disable_master,
-	.irq_handle_msi = efx_farch_msi_interrupt,
-	.irq_handle_legacy = falcon_legacy_interrupt_a1,
-	.tx_probe = efx_farch_tx_probe,
-	.tx_init = efx_farch_tx_init,
-	.tx_remove = efx_farch_tx_remove,
-	.tx_write = efx_farch_tx_write,
-	.tx_limit_len = efx_farch_tx_limit_len,
-	.rx_push_rss_config = dummy_rx_push_rss_config,
-	.rx_probe = efx_farch_rx_probe,
-	.rx_init = efx_farch_rx_init,
-	.rx_remove = efx_farch_rx_remove,
-	.rx_write = efx_farch_rx_write,
-	.rx_defer_refill = efx_farch_rx_defer_refill,
-	.ev_probe = efx_farch_ev_probe,
-	.ev_init = efx_farch_ev_init,
-	.ev_fini = efx_farch_ev_fini,
-	.ev_remove = efx_farch_ev_remove,
-	.ev_process = efx_farch_ev_process,
-	.ev_read_ack = efx_farch_ev_read_ack,
-	.ev_test_generate = efx_farch_ev_test_generate,
-
-	/* We don't expose the filter table on Falcon A1 as it is not
-	 * mapped into function 0, but these implementations still
-	 * work with a degenerate case of all tables set to size 0.
-	 */
-	.filter_table_probe = efx_farch_filter_table_probe,
-	.filter_table_restore = efx_farch_filter_table_restore,
-	.filter_table_remove = efx_farch_filter_table_remove,
-	.filter_insert = efx_farch_filter_insert,
-	.filter_remove_safe = efx_farch_filter_remove_safe,
-	.filter_get_safe = efx_farch_filter_get_safe,
-	.filter_clear_rx = efx_farch_filter_clear_rx,
-	.filter_count_rx_used = efx_farch_filter_count_rx_used,
-	.filter_get_rx_id_limit = efx_farch_filter_get_rx_id_limit,
-	.filter_get_rx_ids = efx_farch_filter_get_rx_ids,
-
-#ifdef CONFIG_SFC_MTD
-	.mtd_probe = falcon_mtd_probe,
-	.mtd_rename = falcon_mtd_rename,
-	.mtd_read = falcon_mtd_read,
-	.mtd_erase = falcon_mtd_erase,
-	.mtd_write = falcon_mtd_write,
-	.mtd_sync = falcon_mtd_sync,
-#endif
-
-	.revision = EFX_REV_FALCON_A1,
-	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
-	.rxd_ptr_tbl_base = FR_AA_RX_DESC_PTR_TBL_KER,
-	.buf_tbl_base = FR_AA_BUF_FULL_TBL_KER,
-	.evq_ptr_tbl_base = FR_AA_EVQ_PTR_TBL_KER,
-	.evq_rptr_tbl_base = FR_AA_EVQ_RPTR_KER,
-	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
-	.rx_buffer_padding = 0x24,
-	.can_rx_scatter = false,
-	.max_interrupt_mode = EFX_INT_MODE_MSI,
-	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
-	.offload_features = NETIF_F_IP_CSUM,
-	.mcdi_max_ver = -1,
-};
-
-const struct efx_nic_type falcon_b0_nic_type = {
-	.is_vf = false,
-	.mem_bar = EFX_MEM_BAR,
-	.mem_map_size = falcon_b0_mem_map_size,
-	.probe = falcon_probe_nic,
-	.remove = falcon_remove_nic,
-	.init = falcon_init_nic,
-	.dimension_resources = falcon_dimension_resources,
-	.fini = efx_port_dummy_op_void,
-	.monitor = falcon_monitor,
-	.map_reset_reason = falcon_map_reset_reason,
-	.map_reset_flags = falcon_map_reset_flags,
-	.reset = falcon_reset_hw,
-	.probe_port = falcon_probe_port,
-	.remove_port = falcon_remove_port,
-	.handle_global_event = falcon_handle_global_event,
-	.fini_dmaq = efx_farch_fini_dmaq,
-	.prepare_flush = falcon_prepare_flush,
-	.finish_flush = efx_port_dummy_op_void,
-	.prepare_flr = efx_port_dummy_op_void,
-	.finish_flr = efx_farch_finish_flr,
-	.describe_stats = falcon_describe_nic_stats,
-	.update_stats = falcon_update_nic_stats,
-	.start_stats = falcon_start_nic_stats,
-	.pull_stats = falcon_pull_nic_stats,
-	.stop_stats = falcon_stop_nic_stats,
-	.set_id_led = falcon_set_id_led,
-	.push_irq_moderation = falcon_push_irq_moderation,
-	.reconfigure_port = falcon_reconfigure_port,
-	.prepare_enable_fc_tx = falcon_b0_prepare_enable_fc_tx,
-	.reconfigure_mac = falcon_reconfigure_xmac,
-	.check_mac_fault = falcon_xmac_check_fault,
-	.get_wol = falcon_get_wol,
-	.set_wol = falcon_set_wol,
-	.resume_wol = efx_port_dummy_op_void,
-	.test_chip = falcon_b0_test_chip,
-	.test_nvram = falcon_test_nvram,
-	.irq_enable_master = efx_farch_irq_enable_master,
-	.irq_test_generate = efx_farch_irq_test_generate,
-	.irq_disable_non_ev = efx_farch_irq_disable_master,
-	.irq_handle_msi = efx_farch_msi_interrupt,
-	.irq_handle_legacy = efx_farch_legacy_interrupt,
-	.tx_probe = efx_farch_tx_probe,
-	.tx_init = efx_farch_tx_init,
-	.tx_remove = efx_farch_tx_remove,
-	.tx_write = efx_farch_tx_write,
-	.tx_limit_len = efx_farch_tx_limit_len,
-	.rx_push_rss_config = falcon_b0_rx_push_rss_config,
-	.rx_probe = efx_farch_rx_probe,
-	.rx_init = efx_farch_rx_init,
-	.rx_remove = efx_farch_rx_remove,
-	.rx_write = efx_farch_rx_write,
-	.rx_defer_refill = efx_farch_rx_defer_refill,
-	.ev_probe = efx_farch_ev_probe,
-	.ev_init = efx_farch_ev_init,
-	.ev_fini = efx_farch_ev_fini,
-	.ev_remove = efx_farch_ev_remove,
-	.ev_process = efx_farch_ev_process,
-	.ev_read_ack = efx_farch_ev_read_ack,
-	.ev_test_generate = efx_farch_ev_test_generate,
-	.filter_table_probe = efx_farch_filter_table_probe,
-	.filter_table_restore = efx_farch_filter_table_restore,
-	.filter_table_remove = efx_farch_filter_table_remove,
-	.filter_update_rx_scatter = efx_farch_filter_update_rx_scatter,
-	.filter_insert = efx_farch_filter_insert,
-	.filter_remove_safe = efx_farch_filter_remove_safe,
-	.filter_get_safe = efx_farch_filter_get_safe,
-	.filter_clear_rx = efx_farch_filter_clear_rx,
-	.filter_count_rx_used = efx_farch_filter_count_rx_used,
-	.filter_get_rx_id_limit = efx_farch_filter_get_rx_id_limit,
-	.filter_get_rx_ids = efx_farch_filter_get_rx_ids,
-#ifdef CONFIG_RFS_ACCEL
-	.filter_rfs_insert = efx_farch_filter_rfs_insert,
-	.filter_rfs_expire_one = efx_farch_filter_rfs_expire_one,
-#endif
-#ifdef CONFIG_SFC_MTD
-	.mtd_probe = falcon_mtd_probe,
-	.mtd_rename = falcon_mtd_rename,
-	.mtd_read = falcon_mtd_read,
-	.mtd_erase = falcon_mtd_erase,
-	.mtd_write = falcon_mtd_write,
-	.mtd_sync = falcon_mtd_sync,
-#endif
-
-	.revision = EFX_REV_FALCON_B0,
-	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
-	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
-	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
-	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
-	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
-	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
-	.rx_prefix_size = FS_BZ_RX_PREFIX_SIZE,
-	.rx_hash_offset = FS_BZ_RX_PREFIX_HASH_OFST,
-	.rx_buffer_padding = 0,
-	.can_rx_scatter = true,
-	.max_interrupt_mode = EFX_INT_MODE_MSIX,
-	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
-	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH | NETIF_F_NTUPLE,
-	.mcdi_max_ver = -1,
-	.max_rx_ip_filters = FR_BZ_RX_FILTER_TBL0_ROWS,
-};
diff --git a/drivers/net/ethernet/sfc/falcon/Kconfig b/drivers/net/ethernet/sfc/falcon/Kconfig
new file mode 100644
index 0000000..6248e96
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/Kconfig
@@ -0,0 +1,21 @@
+config SFC_FALCON
+	tristate "Solarflare SFC4000 support"
+	depends on PCI
+	select MDIO
+	select CRC32
+	select I2C
+	select I2C_ALGOBIT
+	---help---
+	  This driver supports 10-gigabit Ethernet cards based on
+	  the Solarflare SFC4000 controller.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called sfc-falcon.
+config SFC_FALCON_MTD
+	bool "Solarflare SFC4000 MTD support"
+	depends on SFC_FALCON && MTD && !(SFC_FALCON=y && MTD=m)
+	default y
+	---help---
+	  This exposes the on-board flash and/or EEPROM as MTD devices
+	  (e.g. /dev/mtd1).  This is required to update the boot
+	  configuration under Linux.
diff --git a/drivers/net/ethernet/sfc/falcon/Makefile b/drivers/net/ethernet/sfc/falcon/Makefile
new file mode 100644
index 0000000..aa1b459
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/Makefile
@@ -0,0 +1,6 @@
+sfc-falcon-y		+= efx.o nic.o farch.o falcon.o tx.o rx.o selftest.o \
+			   ethtool.o qt202x_phy.o mdio_10g.o tenxpress.o \
+			   txc43128_phy.o falcon_boards.o
+
+sfc-falcon-$(CONFIG_SFC_FALCON_MTD)	+= mtd.o
+obj-$(CONFIG_SFC_FALCON)		+= sfc-falcon.o
diff --git a/drivers/net/ethernet/sfc/falcon/bitfield.h b/drivers/net/ethernet/sfc/falcon/bitfield.h
new file mode 100644
index 0000000..230fd77
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/bitfield.h
@@ -0,0 +1,542 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_BITFIELD_H
+#define EF4_BITFIELD_H
+
+/*
+ * Efx bitfield access
+ *
+ * Efx NICs make extensive use of bitfields up to 128 bits
+ * wide.  Since there is no native 128-bit datatype on most systems,
+ * and since 64-bit datatypes are inefficient on 32-bit systems and
+ * vice versa, we wrap accesses in a way that uses the most efficient
+ * datatype.
+ *
+ * The NICs are PCI devices and therefore little-endian.  Since most
+ * of the quantities that we deal with are DMAed to/from host memory,
+ * we define our datatypes (ef4_oword_t, ef4_qword_t and
+ * ef4_dword_t) to be little-endian.
+ */
+
+/* Lowest bit numbers and widths */
+#define EF4_DUMMY_FIELD_LBN 0
+#define EF4_DUMMY_FIELD_WIDTH 0
+#define EF4_WORD_0_LBN 0
+#define EF4_WORD_0_WIDTH 16
+#define EF4_WORD_1_LBN 16
+#define EF4_WORD_1_WIDTH 16
+#define EF4_DWORD_0_LBN 0
+#define EF4_DWORD_0_WIDTH 32
+#define EF4_DWORD_1_LBN 32
+#define EF4_DWORD_1_WIDTH 32
+#define EF4_DWORD_2_LBN 64
+#define EF4_DWORD_2_WIDTH 32
+#define EF4_DWORD_3_LBN 96
+#define EF4_DWORD_3_WIDTH 32
+#define EF4_QWORD_0_LBN 0
+#define EF4_QWORD_0_WIDTH 64
+
+/* Specified attribute (e.g. LBN) of the specified field */
+#define EF4_VAL(field, attribute) field ## _ ## attribute
+/* Low bit number of the specified field */
+#define EF4_LOW_BIT(field) EF4_VAL(field, LBN)
+/* Bit width of the specified field */
+#define EF4_WIDTH(field) EF4_VAL(field, WIDTH)
+/* High bit number of the specified field */
+#define EF4_HIGH_BIT(field) (EF4_LOW_BIT(field) + EF4_WIDTH(field) - 1)
+/* Mask equal in width to the specified field.
+ *
+ * For example, a field with width 5 would have a mask of 0x1f.
+ *
+ * The maximum width mask that can be generated is 64 bits.
+ */
+#define EF4_MASK64(width)			\
+	((width) == 64 ? ~((u64) 0) :		\
+	 (((((u64) 1) << (width))) - 1))
+
+/* Mask equal in width to the specified field.
+ *
+ * For example, a field with width 5 would have a mask of 0x1f.
+ *
+ * The maximum width mask that can be generated is 32 bits.  Use
+ * EF4_MASK64 for higher width fields.
+ */
+#define EF4_MASK32(width)			\
+	((width) == 32 ? ~((u32) 0) :		\
+	 (((((u32) 1) << (width))) - 1))
+
+/* A doubleword (i.e. 4 byte) datatype - little-endian in HW */
+typedef union ef4_dword {
+	__le32 u32[1];
+} ef4_dword_t;
+
+/* A quadword (i.e. 8 byte) datatype - little-endian in HW */
+typedef union ef4_qword {
+	__le64 u64[1];
+	__le32 u32[2];
+	ef4_dword_t dword[2];
+} ef4_qword_t;
+
+/* An octword (eight-word, i.e. 16 byte) datatype - little-endian in HW */
+typedef union ef4_oword {
+	__le64 u64[2];
+	ef4_qword_t qword[2];
+	__le32 u32[4];
+	ef4_dword_t dword[4];
+} ef4_oword_t;
+
+/* Format string and value expanders for printk */
+#define EF4_DWORD_FMT "%08x"
+#define EF4_QWORD_FMT "%08x:%08x"
+#define EF4_OWORD_FMT "%08x:%08x:%08x:%08x"
+#define EF4_DWORD_VAL(dword)				\
+	((unsigned int) le32_to_cpu((dword).u32[0]))
+#define EF4_QWORD_VAL(qword)				\
+	((unsigned int) le32_to_cpu((qword).u32[1])),	\
+	((unsigned int) le32_to_cpu((qword).u32[0]))
+#define EF4_OWORD_VAL(oword)				\
+	((unsigned int) le32_to_cpu((oword).u32[3])),	\
+	((unsigned int) le32_to_cpu((oword).u32[2])),	\
+	((unsigned int) le32_to_cpu((oword).u32[1])),	\
+	((unsigned int) le32_to_cpu((oword).u32[0]))
+
+/*
+ * Extract bit field portion [low,high) from the native-endian element
+ * which contains bits [min,max).
+ *
+ * For example, suppose "element" represents the high 32 bits of a
+ * 64-bit value, and we wish to extract the bits belonging to the bit
+ * field occupying bits 28-45 of this 64-bit value.
+ *
+ * Then EF4_EXTRACT ( element, 32, 63, 28, 45 ) would give
+ *
+ *   ( element ) << 4
+ *
+ * The result will contain the relevant bits filled in in the range
+ * [0,high-low), with garbage in bits [high-low+1,...).
+ */
+#define EF4_EXTRACT_NATIVE(native_element, min, max, low, high)		\
+	((low) > (max) || (high) < (min) ? 0 :				\
+	 (low) > (min) ?						\
+	 (native_element) >> ((low) - (min)) :				\
+	 (native_element) << ((min) - (low)))
+
+/*
+ * Extract bit field portion [low,high) from the 64-bit little-endian
+ * element which contains bits [min,max)
+ */
+#define EF4_EXTRACT64(element, min, max, low, high)			\
+	EF4_EXTRACT_NATIVE(le64_to_cpu(element), min, max, low, high)
+
+/*
+ * Extract bit field portion [low,high) from the 32-bit little-endian
+ * element which contains bits [min,max)
+ */
+#define EF4_EXTRACT32(element, min, max, low, high)			\
+	EF4_EXTRACT_NATIVE(le32_to_cpu(element), min, max, low, high)
+
+#define EF4_EXTRACT_OWORD64(oword, low, high)				\
+	((EF4_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
+	  EF4_EXTRACT64((oword).u64[1], 64, 127, low, high)) &		\
+	 EF4_MASK64((high) + 1 - (low)))
+
+#define EF4_EXTRACT_QWORD64(qword, low, high)				\
+	(EF4_EXTRACT64((qword).u64[0], 0, 63, low, high) &		\
+	 EF4_MASK64((high) + 1 - (low)))
+
+#define EF4_EXTRACT_OWORD32(oword, low, high)				\
+	((EF4_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
+	  EF4_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
+	  EF4_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
+	  EF4_EXTRACT32((oword).u32[3], 96, 127, low, high)) &		\
+	 EF4_MASK32((high) + 1 - (low)))
+
+#define EF4_EXTRACT_QWORD32(qword, low, high)				\
+	((EF4_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
+	  EF4_EXTRACT32((qword).u32[1], 32, 63, low, high)) &		\
+	 EF4_MASK32((high) + 1 - (low)))
+
+#define EF4_EXTRACT_DWORD(dword, low, high)			\
+	(EF4_EXTRACT32((dword).u32[0], 0, 31, low, high) &	\
+	 EF4_MASK32((high) + 1 - (low)))
+
+#define EF4_OWORD_FIELD64(oword, field)				\
+	EF4_EXTRACT_OWORD64(oword, EF4_LOW_BIT(field),		\
+			    EF4_HIGH_BIT(field))
+
+#define EF4_QWORD_FIELD64(qword, field)				\
+	EF4_EXTRACT_QWORD64(qword, EF4_LOW_BIT(field),		\
+			    EF4_HIGH_BIT(field))
+
+#define EF4_OWORD_FIELD32(oword, field)				\
+	EF4_EXTRACT_OWORD32(oword, EF4_LOW_BIT(field),		\
+			    EF4_HIGH_BIT(field))
+
+#define EF4_QWORD_FIELD32(qword, field)				\
+	EF4_EXTRACT_QWORD32(qword, EF4_LOW_BIT(field),		\
+			    EF4_HIGH_BIT(field))
+
+#define EF4_DWORD_FIELD(dword, field)				\
+	EF4_EXTRACT_DWORD(dword, EF4_LOW_BIT(field),		\
+			  EF4_HIGH_BIT(field))
+
+#define EF4_OWORD_IS_ZERO64(oword)					\
+	(((oword).u64[0] | (oword).u64[1]) == (__force __le64) 0)
+
+#define EF4_QWORD_IS_ZERO64(qword)					\
+	(((qword).u64[0]) == (__force __le64) 0)
+
+#define EF4_OWORD_IS_ZERO32(oword)					     \
+	(((oword).u32[0] | (oword).u32[1] | (oword).u32[2] | (oword).u32[3]) \
+	 == (__force __le32) 0)
+
+#define EF4_QWORD_IS_ZERO32(qword)					\
+	(((qword).u32[0] | (qword).u32[1]) == (__force __le32) 0)
+
+#define EF4_DWORD_IS_ZERO(dword)					\
+	(((dword).u32[0]) == (__force __le32) 0)
+
+#define EF4_OWORD_IS_ALL_ONES64(oword)					\
+	(((oword).u64[0] & (oword).u64[1]) == ~((__force __le64) 0))
+
+#define EF4_QWORD_IS_ALL_ONES64(qword)					\
+	((qword).u64[0] == ~((__force __le64) 0))
+
+#define EF4_OWORD_IS_ALL_ONES32(oword)					\
+	(((oword).u32[0] & (oword).u32[1] & (oword).u32[2] & (oword).u32[3]) \
+	 == ~((__force __le32) 0))
+
+#define EF4_QWORD_IS_ALL_ONES32(qword)					\
+	(((qword).u32[0] & (qword).u32[1]) == ~((__force __le32) 0))
+
+#define EF4_DWORD_IS_ALL_ONES(dword)					\
+	((dword).u32[0] == ~((__force __le32) 0))
+
+#if BITS_PER_LONG == 64
+#define EF4_OWORD_FIELD		EF4_OWORD_FIELD64
+#define EF4_QWORD_FIELD		EF4_QWORD_FIELD64
+#define EF4_OWORD_IS_ZERO	EF4_OWORD_IS_ZERO64
+#define EF4_QWORD_IS_ZERO	EF4_QWORD_IS_ZERO64
+#define EF4_OWORD_IS_ALL_ONES	EF4_OWORD_IS_ALL_ONES64
+#define EF4_QWORD_IS_ALL_ONES	EF4_QWORD_IS_ALL_ONES64
+#else
+#define EF4_OWORD_FIELD		EF4_OWORD_FIELD32
+#define EF4_QWORD_FIELD		EF4_QWORD_FIELD32
+#define EF4_OWORD_IS_ZERO	EF4_OWORD_IS_ZERO32
+#define EF4_QWORD_IS_ZERO	EF4_QWORD_IS_ZERO32
+#define EF4_OWORD_IS_ALL_ONES	EF4_OWORD_IS_ALL_ONES32
+#define EF4_QWORD_IS_ALL_ONES	EF4_QWORD_IS_ALL_ONES32
+#endif
+
+/*
+ * Construct bit field portion
+ *
+ * Creates the portion of the bit field [low,high) that lies within
+ * the range [min,max).
+ */
+#define EF4_INSERT_NATIVE64(min, max, low, high, value)		\
+	(((low > max) || (high < min)) ? 0 :			\
+	 ((low > min) ?						\
+	  (((u64) (value)) << (low - min)) :		\
+	  (((u64) (value)) >> (min - low))))
+
+#define EF4_INSERT_NATIVE32(min, max, low, high, value)		\
+	(((low > max) || (high < min)) ? 0 :			\
+	 ((low > min) ?						\
+	  (((u32) (value)) << (low - min)) :		\
+	  (((u32) (value)) >> (min - low))))
+
+#define EF4_INSERT_NATIVE(min, max, low, high, value)		\
+	((((max - min) >= 32) || ((high - low) >= 32)) ?	\
+	 EF4_INSERT_NATIVE64(min, max, low, high, value) :	\
+	 EF4_INSERT_NATIVE32(min, max, low, high, value))
+
+/*
+ * Construct bit field portion
+ *
+ * Creates the portion of the named bit field that lies within the
+ * range [min,max).
+ */
+#define EF4_INSERT_FIELD_NATIVE(min, max, field, value)		\
+	EF4_INSERT_NATIVE(min, max, EF4_LOW_BIT(field),		\
+			  EF4_HIGH_BIT(field), value)
+
+/*
+ * Construct bit field
+ *
+ * Creates the portion of the named bit fields that lie within the
+ * range [min,max).
+ */
+#define EF4_INSERT_FIELDS_NATIVE(min, max,				\
+				 field1, value1,			\
+				 field2, value2,			\
+				 field3, value3,			\
+				 field4, value4,			\
+				 field5, value5,			\
+				 field6, value6,			\
+				 field7, value7,			\
+				 field8, value8,			\
+				 field9, value9,			\
+				 field10, value10)			\
+	(EF4_INSERT_FIELD_NATIVE((min), (max), field1, (value1)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field2, (value2)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field3, (value3)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field4, (value4)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field5, (value5)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field6, (value6)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field7, (value7)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field8, (value8)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field9, (value9)) |	\
+	 EF4_INSERT_FIELD_NATIVE((min), (max), field10, (value10)))
+
+#define EF4_INSERT_FIELDS64(...)				\
+	cpu_to_le64(EF4_INSERT_FIELDS_NATIVE(__VA_ARGS__))
+
+#define EF4_INSERT_FIELDS32(...)				\
+	cpu_to_le32(EF4_INSERT_FIELDS_NATIVE(__VA_ARGS__))
+
+#define EF4_POPULATE_OWORD64(oword, ...) do {				\
+	(oword).u64[0] = EF4_INSERT_FIELDS64(0, 63, __VA_ARGS__);	\
+	(oword).u64[1] = EF4_INSERT_FIELDS64(64, 127, __VA_ARGS__);	\
+	} while (0)
+
+#define EF4_POPULATE_QWORD64(qword, ...) do {				\
+	(qword).u64[0] = EF4_INSERT_FIELDS64(0, 63, __VA_ARGS__);	\
+	} while (0)
+
+#define EF4_POPULATE_OWORD32(oword, ...) do {				\
+	(oword).u32[0] = EF4_INSERT_FIELDS32(0, 31, __VA_ARGS__);	\
+	(oword).u32[1] = EF4_INSERT_FIELDS32(32, 63, __VA_ARGS__);	\
+	(oword).u32[2] = EF4_INSERT_FIELDS32(64, 95, __VA_ARGS__);	\
+	(oword).u32[3] = EF4_INSERT_FIELDS32(96, 127, __VA_ARGS__);	\
+	} while (0)
+
+#define EF4_POPULATE_QWORD32(qword, ...) do {				\
+	(qword).u32[0] = EF4_INSERT_FIELDS32(0, 31, __VA_ARGS__);	\
+	(qword).u32[1] = EF4_INSERT_FIELDS32(32, 63, __VA_ARGS__);	\
+	} while (0)
+
+#define EF4_POPULATE_DWORD(dword, ...) do {				\
+	(dword).u32[0] = EF4_INSERT_FIELDS32(0, 31, __VA_ARGS__);	\
+	} while (0)
+
+#if BITS_PER_LONG == 64
+#define EF4_POPULATE_OWORD EF4_POPULATE_OWORD64
+#define EF4_POPULATE_QWORD EF4_POPULATE_QWORD64
+#else
+#define EF4_POPULATE_OWORD EF4_POPULATE_OWORD32
+#define EF4_POPULATE_QWORD EF4_POPULATE_QWORD32
+#endif
+
+/* Populate an octword field with various numbers of arguments */
+#define EF4_POPULATE_OWORD_10 EF4_POPULATE_OWORD
+#define EF4_POPULATE_OWORD_9(oword, ...) \
+	EF4_POPULATE_OWORD_10(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_8(oword, ...) \
+	EF4_POPULATE_OWORD_9(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_7(oword, ...) \
+	EF4_POPULATE_OWORD_8(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_6(oword, ...) \
+	EF4_POPULATE_OWORD_7(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_5(oword, ...) \
+	EF4_POPULATE_OWORD_6(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_4(oword, ...) \
+	EF4_POPULATE_OWORD_5(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_3(oword, ...) \
+	EF4_POPULATE_OWORD_4(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_2(oword, ...) \
+	EF4_POPULATE_OWORD_3(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_OWORD_1(oword, ...) \
+	EF4_POPULATE_OWORD_2(oword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_ZERO_OWORD(oword) \
+	EF4_POPULATE_OWORD_1(oword, EF4_DUMMY_FIELD, 0)
+#define EF4_SET_OWORD(oword) \
+	EF4_POPULATE_OWORD_4(oword, \
+			     EF4_DWORD_0, 0xffffffff, \
+			     EF4_DWORD_1, 0xffffffff, \
+			     EF4_DWORD_2, 0xffffffff, \
+			     EF4_DWORD_3, 0xffffffff)
+
+/* Populate a quadword field with various numbers of arguments */
+#define EF4_POPULATE_QWORD_10 EF4_POPULATE_QWORD
+#define EF4_POPULATE_QWORD_9(qword, ...) \
+	EF4_POPULATE_QWORD_10(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_8(qword, ...) \
+	EF4_POPULATE_QWORD_9(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_7(qword, ...) \
+	EF4_POPULATE_QWORD_8(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_6(qword, ...) \
+	EF4_POPULATE_QWORD_7(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_5(qword, ...) \
+	EF4_POPULATE_QWORD_6(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_4(qword, ...) \
+	EF4_POPULATE_QWORD_5(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_3(qword, ...) \
+	EF4_POPULATE_QWORD_4(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_2(qword, ...) \
+	EF4_POPULATE_QWORD_3(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_QWORD_1(qword, ...) \
+	EF4_POPULATE_QWORD_2(qword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_ZERO_QWORD(qword) \
+	EF4_POPULATE_QWORD_1(qword, EF4_DUMMY_FIELD, 0)
+#define EF4_SET_QWORD(qword) \
+	EF4_POPULATE_QWORD_2(qword, \
+			     EF4_DWORD_0, 0xffffffff, \
+			     EF4_DWORD_1, 0xffffffff)
+
+/* Populate a dword field with various numbers of arguments */
+#define EF4_POPULATE_DWORD_10 EF4_POPULATE_DWORD
+#define EF4_POPULATE_DWORD_9(dword, ...) \
+	EF4_POPULATE_DWORD_10(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_8(dword, ...) \
+	EF4_POPULATE_DWORD_9(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_7(dword, ...) \
+	EF4_POPULATE_DWORD_8(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_6(dword, ...) \
+	EF4_POPULATE_DWORD_7(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_5(dword, ...) \
+	EF4_POPULATE_DWORD_6(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_4(dword, ...) \
+	EF4_POPULATE_DWORD_5(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_3(dword, ...) \
+	EF4_POPULATE_DWORD_4(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_2(dword, ...) \
+	EF4_POPULATE_DWORD_3(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_POPULATE_DWORD_1(dword, ...) \
+	EF4_POPULATE_DWORD_2(dword, EF4_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EF4_ZERO_DWORD(dword) \
+	EF4_POPULATE_DWORD_1(dword, EF4_DUMMY_FIELD, 0)
+#define EF4_SET_DWORD(dword) \
+	EF4_POPULATE_DWORD_1(dword, EF4_DWORD_0, 0xffffffff)
+
+/*
+ * Modify a named field within an already-populated structure.  Used
+ * for read-modify-write operations.
+ *
+ */
+#define EF4_INVERT_OWORD(oword) do {		\
+	(oword).u64[0] = ~((oword).u64[0]);	\
+	(oword).u64[1] = ~((oword).u64[1]);	\
+	} while (0)
+
+#define EF4_AND_OWORD(oword, from, mask)			\
+	do {							\
+		(oword).u64[0] = (from).u64[0] & (mask).u64[0];	\
+		(oword).u64[1] = (from).u64[1] & (mask).u64[1];	\
+	} while (0)
+
+#define EF4_OR_OWORD(oword, from, mask)				\
+	do {							\
+		(oword).u64[0] = (from).u64[0] | (mask).u64[0];	\
+		(oword).u64[1] = (from).u64[1] | (mask).u64[1];	\
+	} while (0)
+
+#define EF4_INSERT64(min, max, low, high, value)			\
+	cpu_to_le64(EF4_INSERT_NATIVE(min, max, low, high, value))
+
+#define EF4_INSERT32(min, max, low, high, value)			\
+	cpu_to_le32(EF4_INSERT_NATIVE(min, max, low, high, value))
+
+#define EF4_INPLACE_MASK64(min, max, low, high)				\
+	EF4_INSERT64(min, max, low, high, EF4_MASK64((high) + 1 - (low)))
+
+#define EF4_INPLACE_MASK32(min, max, low, high)				\
+	EF4_INSERT32(min, max, low, high, EF4_MASK32((high) + 1 - (low)))
+
+#define EF4_SET_OWORD64(oword, low, high, value) do {			\
+	(oword).u64[0] = (((oword).u64[0]				\
+			   & ~EF4_INPLACE_MASK64(0,  63, low, high))	\
+			  | EF4_INSERT64(0,  63, low, high, value));	\
+	(oword).u64[1] = (((oword).u64[1]				\
+			   & ~EF4_INPLACE_MASK64(64, 127, low, high))	\
+			  | EF4_INSERT64(64, 127, low, high, value));	\
+	} while (0)
+
+#define EF4_SET_QWORD64(qword, low, high, value) do {			\
+	(qword).u64[0] = (((qword).u64[0]				\
+			   & ~EF4_INPLACE_MASK64(0, 63, low, high))	\
+			  | EF4_INSERT64(0, 63, low, high, value));	\
+	} while (0)
+
+#define EF4_SET_OWORD32(oword, low, high, value) do {			\
+	(oword).u32[0] = (((oword).u32[0]				\
+			   & ~EF4_INPLACE_MASK32(0, 31, low, high))	\
+			  | EF4_INSERT32(0, 31, low, high, value));	\
+	(oword).u32[1] = (((oword).u32[1]				\
+			   & ~EF4_INPLACE_MASK32(32, 63, low, high))	\
+			  | EF4_INSERT32(32, 63, low, high, value));	\
+	(oword).u32[2] = (((oword).u32[2]				\
+			   & ~EF4_INPLACE_MASK32(64, 95, low, high))	\
+			  | EF4_INSERT32(64, 95, low, high, value));	\
+	(oword).u32[3] = (((oword).u32[3]				\
+			   & ~EF4_INPLACE_MASK32(96, 127, low, high))	\
+			  | EF4_INSERT32(96, 127, low, high, value));	\
+	} while (0)
+
+#define EF4_SET_QWORD32(qword, low, high, value) do {			\
+	(qword).u32[0] = (((qword).u32[0]				\
+			   & ~EF4_INPLACE_MASK32(0, 31, low, high))	\
+			  | EF4_INSERT32(0, 31, low, high, value));	\
+	(qword).u32[1] = (((qword).u32[1]				\
+			   & ~EF4_INPLACE_MASK32(32, 63, low, high))	\
+			  | EF4_INSERT32(32, 63, low, high, value));	\
+	} while (0)
+
+#define EF4_SET_DWORD32(dword, low, high, value) do {			\
+	(dword).u32[0] = (((dword).u32[0]				\
+			   & ~EF4_INPLACE_MASK32(0, 31, low, high))	\
+			  | EF4_INSERT32(0, 31, low, high, value));	\
+	} while (0)
+
+#define EF4_SET_OWORD_FIELD64(oword, field, value)			\
+	EF4_SET_OWORD64(oword, EF4_LOW_BIT(field),			\
+			 EF4_HIGH_BIT(field), value)
+
+#define EF4_SET_QWORD_FIELD64(qword, field, value)			\
+	EF4_SET_QWORD64(qword, EF4_LOW_BIT(field),			\
+			 EF4_HIGH_BIT(field), value)
+
+#define EF4_SET_OWORD_FIELD32(oword, field, value)			\
+	EF4_SET_OWORD32(oword, EF4_LOW_BIT(field),			\
+			 EF4_HIGH_BIT(field), value)
+
+#define EF4_SET_QWORD_FIELD32(qword, field, value)			\
+	EF4_SET_QWORD32(qword, EF4_LOW_BIT(field),			\
+			 EF4_HIGH_BIT(field), value)
+
+#define EF4_SET_DWORD_FIELD(dword, field, value)			\
+	EF4_SET_DWORD32(dword, EF4_LOW_BIT(field),			\
+			 EF4_HIGH_BIT(field), value)
+
+
+
+#if BITS_PER_LONG == 64
+#define EF4_SET_OWORD_FIELD EF4_SET_OWORD_FIELD64
+#define EF4_SET_QWORD_FIELD EF4_SET_QWORD_FIELD64
+#else
+#define EF4_SET_OWORD_FIELD EF4_SET_OWORD_FIELD32
+#define EF4_SET_QWORD_FIELD EF4_SET_QWORD_FIELD32
+#endif
+
+/* Used to avoid compiler warnings about shift range exceeding width
+ * of the data types when dma_addr_t is only 32 bits wide.
+ */
+#define DMA_ADDR_T_WIDTH	(8 * sizeof(dma_addr_t))
+#define EF4_DMA_TYPE_WIDTH(width) \
+	(((width) < DMA_ADDR_T_WIDTH) ? (width) : DMA_ADDR_T_WIDTH)
+
+
+/* Static initialiser */
+#define EF4_OWORD32(a, b, c, d)				\
+	{ .u32 = { cpu_to_le32(a), cpu_to_le32(b),	\
+		   cpu_to_le32(c), cpu_to_le32(d) } }
+
+#endif /* EF4_BITFIELD_H */
diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
new file mode 100644
index 0000000..5c5cb3c
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -0,0 +1,3350 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/delay.h>
+#include <linux/notifier.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/in.h>
+#include <linux/ethtool.h>
+#include <linux/topology.h>
+#include <linux/gfp.h>
+#include <linux/aer.h>
+#include <linux/interrupt.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "nic.h"
+#include "selftest.h"
+
+#include "workarounds.h"
+
+/**************************************************************************
+ *
+ * Type name strings
+ *
+ **************************************************************************
+ */
+
+/* Loopback mode names (see LOOPBACK_MODE()) */
+const unsigned int ef4_loopback_mode_max = LOOPBACK_MAX;
+const char *const ef4_loopback_mode_names[] = {
+	[LOOPBACK_NONE]		= "NONE",
+	[LOOPBACK_DATA]		= "DATAPATH",
+	[LOOPBACK_GMAC]		= "GMAC",
+	[LOOPBACK_XGMII]	= "XGMII",
+	[LOOPBACK_XGXS]		= "XGXS",
+	[LOOPBACK_XAUI]		= "XAUI",
+	[LOOPBACK_GMII]		= "GMII",
+	[LOOPBACK_SGMII]	= "SGMII",
+	[LOOPBACK_XGBR]		= "XGBR",
+	[LOOPBACK_XFI]		= "XFI",
+	[LOOPBACK_XAUI_FAR]	= "XAUI_FAR",
+	[LOOPBACK_GMII_FAR]	= "GMII_FAR",
+	[LOOPBACK_SGMII_FAR]	= "SGMII_FAR",
+	[LOOPBACK_XFI_FAR]	= "XFI_FAR",
+	[LOOPBACK_GPHY]		= "GPHY",
+	[LOOPBACK_PHYXS]	= "PHYXS",
+	[LOOPBACK_PCS]		= "PCS",
+	[LOOPBACK_PMAPMD]	= "PMA/PMD",
+	[LOOPBACK_XPORT]	= "XPORT",
+	[LOOPBACK_XGMII_WS]	= "XGMII_WS",
+	[LOOPBACK_XAUI_WS]	= "XAUI_WS",
+	[LOOPBACK_XAUI_WS_FAR]  = "XAUI_WS_FAR",
+	[LOOPBACK_XAUI_WS_NEAR] = "XAUI_WS_NEAR",
+	[LOOPBACK_GMII_WS]	= "GMII_WS",
+	[LOOPBACK_XFI_WS]	= "XFI_WS",
+	[LOOPBACK_XFI_WS_FAR]	= "XFI_WS_FAR",
+	[LOOPBACK_PHYXS_WS]	= "PHYXS_WS",
+};
+
+const unsigned int ef4_reset_type_max = RESET_TYPE_MAX;
+const char *const ef4_reset_type_names[] = {
+	[RESET_TYPE_INVISIBLE]          = "INVISIBLE",
+	[RESET_TYPE_ALL]                = "ALL",
+	[RESET_TYPE_RECOVER_OR_ALL]     = "RECOVER_OR_ALL",
+	[RESET_TYPE_WORLD]              = "WORLD",
+	[RESET_TYPE_RECOVER_OR_DISABLE] = "RECOVER_OR_DISABLE",
+	[RESET_TYPE_DATAPATH]           = "DATAPATH",
+	[RESET_TYPE_DISABLE]            = "DISABLE",
+	[RESET_TYPE_TX_WATCHDOG]        = "TX_WATCHDOG",
+	[RESET_TYPE_INT_ERROR]          = "INT_ERROR",
+	[RESET_TYPE_RX_RECOVERY]        = "RX_RECOVERY",
+	[RESET_TYPE_DMA_ERROR]          = "DMA_ERROR",
+	[RESET_TYPE_TX_SKIP]            = "TX_SKIP",
+};
+
+/* Reset workqueue. If any NIC has a hardware failure then a reset will be
+ * queued onto this work queue. This is not a per-nic work queue, because
+ * ef4_reset_work() acquires the rtnl lock, so resets are naturally serialised.
+ */
+static struct workqueue_struct *reset_workqueue;
+
+/* How often and how many times to poll for a reset while waiting for a
+ * BIST that another function started to complete.
+ */
+#define BIST_WAIT_DELAY_MS	100
+#define BIST_WAIT_DELAY_COUNT	100
+
+/**************************************************************************
+ *
+ * Configurable values
+ *
+ *************************************************************************/
+
+/*
+ * Use separate channels for TX and RX events
+ *
+ * Set this to 1 to use separate channels for TX and RX. It allows us
+ * to control interrupt affinity separately for TX and RX.
+ *
+ * This is only used in MSI-X interrupt mode
+ */
+bool ef4_separate_tx_channels;
+module_param(ef4_separate_tx_channels, bool, 0444);
+MODULE_PARM_DESC(ef4_separate_tx_channels,
+		 "Use separate channels for TX and RX");
+
+/* This is the weight assigned to each of the (per-channel) virtual
+ * NAPI devices.
+ */
+static int napi_weight = 64;
+
+/* This is the time (in jiffies) between invocations of the hardware
+ * monitor.
+ * On Falcon-based NICs, this will:
+ * - Check the on-board hardware monitor;
+ * - Poll the link state and reconfigure the hardware as necessary.
+ * On Siena-based NICs for power systems with EEH support, this will give EEH a
+ * chance to start.
+ */
+static unsigned int ef4_monitor_interval = 1 * HZ;
+
+/* Initial interrupt moderation settings.  They can be modified after
+ * module load with ethtool.
+ *
+ * The default for RX should strike a balance between increasing the
+ * round-trip latency and reducing overhead.
+ */
+static unsigned int rx_irq_mod_usec = 60;
+
+/* Initial interrupt moderation settings.  They can be modified after
+ * module load with ethtool.
+ *
+ * This default is chosen to ensure that a 10G link does not go idle
+ * while a TX queue is stopped after it has become full.  A queue is
+ * restarted when it drops below half full.  The time this takes (assuming
+ * worst case 3 descriptors per packet and 1024 descriptors) is
+ *   512 / 3 * 1.2 = 205 usec.
+ */
+static unsigned int tx_irq_mod_usec = 150;
+
+/* This is the first interrupt mode to try out of:
+ * 0 => MSI-X
+ * 1 => MSI
+ * 2 => legacy
+ */
+static unsigned int interrupt_mode;
+
+/* This is the requested number of CPUs to use for Receive-Side Scaling (RSS),
+ * i.e. the number of CPUs among which we may distribute simultaneous
+ * interrupt handling.
+ *
+ * Cards without MSI-X will only target one CPU via legacy or MSI interrupt.
+ * The default (0) means to assign an interrupt to each core.
+ */
+static unsigned int rss_cpus;
+module_param(rss_cpus, uint, 0444);
+MODULE_PARM_DESC(rss_cpus, "Number of CPUs to use for Receive-Side Scaling");
+
+static bool phy_flash_cfg;
+module_param(phy_flash_cfg, bool, 0644);
+MODULE_PARM_DESC(phy_flash_cfg, "Set PHYs into reflash mode initially");
+
+static unsigned irq_adapt_low_thresh = 8000;
+module_param(irq_adapt_low_thresh, uint, 0644);
+MODULE_PARM_DESC(irq_adapt_low_thresh,
+		 "Threshold score for reducing IRQ moderation");
+
+static unsigned irq_adapt_high_thresh = 16000;
+module_param(irq_adapt_high_thresh, uint, 0644);
+MODULE_PARM_DESC(irq_adapt_high_thresh,
+		 "Threshold score for increasing IRQ moderation");
+
+static unsigned debug = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
+			 NETIF_MSG_LINK | NETIF_MSG_IFDOWN |
+			 NETIF_MSG_IFUP | NETIF_MSG_RX_ERR |
+			 NETIF_MSG_TX_ERR | NETIF_MSG_HW);
+module_param(debug, uint, 0);
+MODULE_PARM_DESC(debug, "Bitmapped debugging message enable value");
+
+/**************************************************************************
+ *
+ * Utility functions and prototypes
+ *
+ *************************************************************************/
+
+static int ef4_soft_enable_interrupts(struct ef4_nic *efx);
+static void ef4_soft_disable_interrupts(struct ef4_nic *efx);
+static void ef4_remove_channel(struct ef4_channel *channel);
+static void ef4_remove_channels(struct ef4_nic *efx);
+static const struct ef4_channel_type ef4_default_channel_type;
+static void ef4_remove_port(struct ef4_nic *efx);
+static void ef4_init_napi_channel(struct ef4_channel *channel);
+static void ef4_fini_napi(struct ef4_nic *efx);
+static void ef4_fini_napi_channel(struct ef4_channel *channel);
+static void ef4_fini_struct(struct ef4_nic *efx);
+static void ef4_start_all(struct ef4_nic *efx);
+static void ef4_stop_all(struct ef4_nic *efx);
+
+#define EF4_ASSERT_RESET_SERIALISED(efx)		\
+	do {						\
+		if ((efx->state == STATE_READY) ||	\
+		    (efx->state == STATE_RECOVERY) ||	\
+		    (efx->state == STATE_DISABLED))	\
+			ASSERT_RTNL();			\
+	} while (0)
+
+static int ef4_check_disabled(struct ef4_nic *efx)
+{
+	if (efx->state == STATE_DISABLED || efx->state == STATE_RECOVERY) {
+		netif_err(efx, drv, efx->net_dev,
+			  "device is disabled due to earlier errors\n");
+		return -EIO;
+	}
+	return 0;
+}
+
+/**************************************************************************
+ *
+ * Event queue processing
+ *
+ *************************************************************************/
+
+/* Process channel's event queue
+ *
+ * This function is responsible for processing the event queue of a
+ * single channel.  The caller must guarantee that this function will
+ * never be concurrently called more than once on the same channel,
+ * though different channels may be being processed concurrently.
+ */
+static int ef4_process_channel(struct ef4_channel *channel, int budget)
+{
+	struct ef4_tx_queue *tx_queue;
+	int spent;
+
+	if (unlikely(!channel->enabled))
+		return 0;
+
+	ef4_for_each_channel_tx_queue(tx_queue, channel) {
+		tx_queue->pkts_compl = 0;
+		tx_queue->bytes_compl = 0;
+	}
+
+	spent = ef4_nic_process_eventq(channel, budget);
+	if (spent && ef4_channel_has_rx_queue(channel)) {
+		struct ef4_rx_queue *rx_queue =
+			ef4_channel_get_rx_queue(channel);
+
+		ef4_rx_flush_packet(channel);
+		ef4_fast_push_rx_descriptors(rx_queue, true);
+	}
+
+	/* Update BQL */
+	ef4_for_each_channel_tx_queue(tx_queue, channel) {
+		if (tx_queue->bytes_compl) {
+			netdev_tx_completed_queue(tx_queue->core_txq,
+				tx_queue->pkts_compl, tx_queue->bytes_compl);
+		}
+	}
+
+	return spent;
+}
+
+/* NAPI poll handler
+ *
+ * NAPI guarantees serialisation of polls of the same device, which
+ * provides the guarantee required by ef4_process_channel().
+ */
+static void ef4_update_irq_mod(struct ef4_nic *efx, struct ef4_channel *channel)
+{
+	int step = efx->irq_mod_step_us;
+
+	if (channel->irq_mod_score < irq_adapt_low_thresh) {
+		if (channel->irq_moderation_us > step) {
+			channel->irq_moderation_us -= step;
+			efx->type->push_irq_moderation(channel);
+		}
+	} else if (channel->irq_mod_score > irq_adapt_high_thresh) {
+		if (channel->irq_moderation_us <
+		    efx->irq_rx_moderation_us) {
+			channel->irq_moderation_us += step;
+			efx->type->push_irq_moderation(channel);
+		}
+	}
+
+	channel->irq_count = 0;
+	channel->irq_mod_score = 0;
+}
+
+static int ef4_poll(struct napi_struct *napi, int budget)
+{
+	struct ef4_channel *channel =
+		container_of(napi, struct ef4_channel, napi_str);
+	struct ef4_nic *efx = channel->efx;
+	int spent;
+
+	if (!ef4_channel_lock_napi(channel))
+		return budget;
+
+	netif_vdbg(efx, intr, efx->net_dev,
+		   "channel %d NAPI poll executing on CPU %d\n",
+		   channel->channel, raw_smp_processor_id());
+
+	spent = ef4_process_channel(channel, budget);
+
+	if (spent < budget) {
+		if (ef4_channel_has_rx_queue(channel) &&
+		    efx->irq_rx_adaptive &&
+		    unlikely(++channel->irq_count == 1000)) {
+			ef4_update_irq_mod(efx, channel);
+		}
+
+		ef4_filter_rfs_expire(channel);
+
+		/* There is no race here; although napi_disable() will
+		 * only wait for napi_complete(), this isn't a problem
+		 * since ef4_nic_eventq_read_ack() will have no effect if
+		 * interrupts have already been disabled.
+		 */
+		napi_complete(napi);
+		ef4_nic_eventq_read_ack(channel);
+	}
+
+	ef4_channel_unlock_napi(channel);
+	return spent;
+}
+
+/* Create event queue
+ * Event queue memory allocations are done only once.  If the channel
+ * is reset, the memory buffer will be reused; this guards against
+ * errors during channel reset and also simplifies interrupt handling.
+ */
+static int ef4_probe_eventq(struct ef4_channel *channel)
+{
+	struct ef4_nic *efx = channel->efx;
+	unsigned long entries;
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "chan %d create event queue\n", channel->channel);
+
+	/* Build an event queue with room for one event per tx and rx buffer,
+	 * plus some extra for link state events and MCDI completions. */
+	entries = roundup_pow_of_two(efx->rxq_entries + efx->txq_entries + 128);
+	EF4_BUG_ON_PARANOID(entries > EF4_MAX_EVQ_SIZE);
+	channel->eventq_mask = max(entries, EF4_MIN_EVQ_SIZE) - 1;
+
+	return ef4_nic_probe_eventq(channel);
+}
+
+/* Prepare channel's event queue */
+static int ef4_init_eventq(struct ef4_channel *channel)
+{
+	struct ef4_nic *efx = channel->efx;
+	int rc;
+
+	EF4_WARN_ON_PARANOID(channel->eventq_init);
+
+	netif_dbg(efx, drv, efx->net_dev,
+		  "chan %d init event queue\n", channel->channel);
+
+	rc = ef4_nic_init_eventq(channel);
+	if (rc == 0) {
+		efx->type->push_irq_moderation(channel);
+		channel->eventq_read_ptr = 0;
+		channel->eventq_init = true;
+	}
+	return rc;
+}
+
+/* Enable event queue processing and NAPI */
+void ef4_start_eventq(struct ef4_channel *channel)
+{
+	netif_dbg(channel->efx, ifup, channel->efx->net_dev,
+		  "chan %d start event queue\n", channel->channel);
+
+	/* Make sure the NAPI handler sees the enabled flag set */
+	channel->enabled = true;
+	smp_wmb();
+
+	ef4_channel_enable(channel);
+	napi_enable(&channel->napi_str);
+	ef4_nic_eventq_read_ack(channel);
+}
+
+/* Disable event queue processing and NAPI */
+void ef4_stop_eventq(struct ef4_channel *channel)
+{
+	if (!channel->enabled)
+		return;
+
+	napi_disable(&channel->napi_str);
+	while (!ef4_channel_disable(channel))
+		usleep_range(1000, 20000);
+	channel->enabled = false;
+}
+
+static void ef4_fini_eventq(struct ef4_channel *channel)
+{
+	if (!channel->eventq_init)
+		return;
+
+	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+		  "chan %d fini event queue\n", channel->channel);
+
+	ef4_nic_fini_eventq(channel);
+	channel->eventq_init = false;
+}
+
+static void ef4_remove_eventq(struct ef4_channel *channel)
+{
+	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+		  "chan %d remove event queue\n", channel->channel);
+
+	ef4_nic_remove_eventq(channel);
+}
+
+/**************************************************************************
+ *
+ * Channel handling
+ *
+ *************************************************************************/
+
+/* Allocate and initialise a channel structure. */
+static struct ef4_channel *
+ef4_alloc_channel(struct ef4_nic *efx, int i, struct ef4_channel *old_channel)
+{
+	struct ef4_channel *channel;
+	struct ef4_rx_queue *rx_queue;
+	struct ef4_tx_queue *tx_queue;
+	int j;
+
+	channel = kzalloc(sizeof(*channel), GFP_KERNEL);
+	if (!channel)
+		return NULL;
+
+	channel->efx = efx;
+	channel->channel = i;
+	channel->type = &ef4_default_channel_type;
+
+	for (j = 0; j < EF4_TXQ_TYPES; j++) {
+		tx_queue = &channel->tx_queue[j];
+		tx_queue->efx = efx;
+		tx_queue->queue = i * EF4_TXQ_TYPES + j;
+		tx_queue->channel = channel;
+	}
+
+	rx_queue = &channel->rx_queue;
+	rx_queue->efx = efx;
+	setup_timer(&rx_queue->slow_fill, ef4_rx_slow_fill,
+		    (unsigned long)rx_queue);
+
+	return channel;
+}
+
+/* Allocate and initialise a channel structure, copying parameters
+ * (but not resources) from an old channel structure.
+ */
+static struct ef4_channel *
+ef4_copy_channel(const struct ef4_channel *old_channel)
+{
+	struct ef4_channel *channel;
+	struct ef4_rx_queue *rx_queue;
+	struct ef4_tx_queue *tx_queue;
+	int j;
+
+	channel = kmalloc(sizeof(*channel), GFP_KERNEL);
+	if (!channel)
+		return NULL;
+
+	*channel = *old_channel;
+
+	channel->napi_dev = NULL;
+	INIT_HLIST_NODE(&channel->napi_str.napi_hash_node);
+	channel->napi_str.napi_id = 0;
+	channel->napi_str.state = 0;
+	memset(&channel->eventq, 0, sizeof(channel->eventq));
+
+	for (j = 0; j < EF4_TXQ_TYPES; j++) {
+		tx_queue = &channel->tx_queue[j];
+		if (tx_queue->channel)
+			tx_queue->channel = channel;
+		tx_queue->buffer = NULL;
+		memset(&tx_queue->txd, 0, sizeof(tx_queue->txd));
+	}
+
+	rx_queue = &channel->rx_queue;
+	rx_queue->buffer = NULL;
+	memset(&rx_queue->rxd, 0, sizeof(rx_queue->rxd));
+	setup_timer(&rx_queue->slow_fill, ef4_rx_slow_fill,
+		    (unsigned long)rx_queue);
+
+	return channel;
+}
+
+static int ef4_probe_channel(struct ef4_channel *channel)
+{
+	struct ef4_tx_queue *tx_queue;
+	struct ef4_rx_queue *rx_queue;
+	int rc;
+
+	netif_dbg(channel->efx, probe, channel->efx->net_dev,
+		  "creating channel %d\n", channel->channel);
+
+	rc = channel->type->pre_probe(channel);
+	if (rc)
+		goto fail;
+
+	rc = ef4_probe_eventq(channel);
+	if (rc)
+		goto fail;
+
+	ef4_for_each_channel_tx_queue(tx_queue, channel) {
+		rc = ef4_probe_tx_queue(tx_queue);
+		if (rc)
+			goto fail;
+	}
+
+	ef4_for_each_channel_rx_queue(rx_queue, channel) {
+		rc = ef4_probe_rx_queue(rx_queue);
+		if (rc)
+			goto fail;
+	}
+
+	return 0;
+
+fail:
+	ef4_remove_channel(channel);
+	return rc;
+}
+
+static void
+ef4_get_channel_name(struct ef4_channel *channel, char *buf, size_t len)
+{
+	struct ef4_nic *efx = channel->efx;
+	const char *type;
+	int number;
+
+	number = channel->channel;
+	if (efx->tx_channel_offset == 0) {
+		type = "";
+	} else if (channel->channel < efx->tx_channel_offset) {
+		type = "-rx";
+	} else {
+		type = "-tx";
+		number -= efx->tx_channel_offset;
+	}
+	snprintf(buf, len, "%s%s-%d", efx->name, type, number);
+}
+
+static void ef4_set_channel_names(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		channel->type->get_name(channel,
+					efx->msi_context[channel->channel].name,
+					sizeof(efx->msi_context[0].name));
+}
+
+static int ef4_probe_channels(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+	int rc;
+
+	/* Restart special buffer allocation */
+	efx->next_buffer_table = 0;
+
+	/* Probe channels in reverse, so that any 'extra' channels
+	 * use the start of the buffer table. This allows the traffic
+	 * channels to be resized without moving them or wasting the
+	 * entries before them.
+	 */
+	ef4_for_each_channel_rev(channel, efx) {
+		rc = ef4_probe_channel(channel);
+		if (rc) {
+			netif_err(efx, probe, efx->net_dev,
+				  "failed to create channel %d\n",
+				  channel->channel);
+			goto fail;
+		}
+	}
+	ef4_set_channel_names(efx);
+
+	return 0;
+
+fail:
+	ef4_remove_channels(efx);
+	return rc;
+}
+
+/* Channels are shutdown and reinitialised whilst the NIC is running
+ * to propagate configuration changes (mtu, checksum offload), or
+ * to clear hardware error conditions
+ */
+static void ef4_start_datapath(struct ef4_nic *efx)
+{
+	netdev_features_t old_features = efx->net_dev->features;
+	bool old_rx_scatter = efx->rx_scatter;
+	struct ef4_tx_queue *tx_queue;
+	struct ef4_rx_queue *rx_queue;
+	struct ef4_channel *channel;
+	size_t rx_buf_len;
+
+	/* Calculate the rx buffer allocation parameters required to
+	 * support the current MTU, including padding for header
+	 * alignment and overruns.
+	 */
+	efx->rx_dma_len = (efx->rx_prefix_size +
+			   EF4_MAX_FRAME_LEN(efx->net_dev->mtu) +
+			   efx->type->rx_buffer_padding);
+	rx_buf_len = (sizeof(struct ef4_rx_page_state) +
+		      efx->rx_ip_align + efx->rx_dma_len);
+	if (rx_buf_len <= PAGE_SIZE) {
+		efx->rx_scatter = efx->type->always_rx_scatter;
+		efx->rx_buffer_order = 0;
+	} else if (efx->type->can_rx_scatter) {
+		BUILD_BUG_ON(EF4_RX_USR_BUF_SIZE % L1_CACHE_BYTES);
+		BUILD_BUG_ON(sizeof(struct ef4_rx_page_state) +
+			     2 * ALIGN(NET_IP_ALIGN + EF4_RX_USR_BUF_SIZE,
+				       EF4_RX_BUF_ALIGNMENT) >
+			     PAGE_SIZE);
+		efx->rx_scatter = true;
+		efx->rx_dma_len = EF4_RX_USR_BUF_SIZE;
+		efx->rx_buffer_order = 0;
+	} else {
+		efx->rx_scatter = false;
+		efx->rx_buffer_order = get_order(rx_buf_len);
+	}
+
+	ef4_rx_config_page_split(efx);
+	if (efx->rx_buffer_order)
+		netif_dbg(efx, drv, efx->net_dev,
+			  "RX buf len=%u; page order=%u batch=%u\n",
+			  efx->rx_dma_len, efx->rx_buffer_order,
+			  efx->rx_pages_per_batch);
+	else
+		netif_dbg(efx, drv, efx->net_dev,
+			  "RX buf len=%u step=%u bpp=%u; page batch=%u\n",
+			  efx->rx_dma_len, efx->rx_page_buf_step,
+			  efx->rx_bufs_per_page, efx->rx_pages_per_batch);
+
+	/* Restore previously fixed features in hw_features and remove
+	 * features which are fixed now
+	 */
+	efx->net_dev->hw_features |= efx->net_dev->features;
+	efx->net_dev->hw_features &= ~efx->fixed_features;
+	efx->net_dev->features |= efx->fixed_features;
+	if (efx->net_dev->features != old_features)
+		netdev_features_change(efx->net_dev);
+
+	/* RX filters may also have scatter-enabled flags */
+	if (efx->rx_scatter != old_rx_scatter)
+		efx->type->filter_update_rx_scatter(efx);
+
+	/* We must keep at least one descriptor in a TX ring empty.
+	 * We could avoid this when the queue size does not exactly
+	 * match the hardware ring size, but it's not that important.
+	 * Therefore we stop the queue when one more skb might fill
+	 * the ring completely.  We wake it when half way back to
+	 * empty.
+	 */
+	efx->txq_stop_thresh = efx->txq_entries - ef4_tx_max_skb_descs(efx);
+	efx->txq_wake_thresh = efx->txq_stop_thresh / 2;
+
+	/* Initialise the channels */
+	ef4_for_each_channel(channel, efx) {
+		ef4_for_each_channel_tx_queue(tx_queue, channel) {
+			ef4_init_tx_queue(tx_queue);
+			atomic_inc(&efx->active_queues);
+		}
+
+		ef4_for_each_channel_rx_queue(rx_queue, channel) {
+			ef4_init_rx_queue(rx_queue);
+			atomic_inc(&efx->active_queues);
+			ef4_stop_eventq(channel);
+			ef4_fast_push_rx_descriptors(rx_queue, false);
+			ef4_start_eventq(channel);
+		}
+
+		WARN_ON(channel->rx_pkt_n_frags);
+	}
+
+	if (netif_device_present(efx->net_dev))
+		netif_tx_wake_all_queues(efx->net_dev);
+}
+
+static void ef4_stop_datapath(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+	struct ef4_tx_queue *tx_queue;
+	struct ef4_rx_queue *rx_queue;
+	int rc;
+
+	EF4_ASSERT_RESET_SERIALISED(efx);
+	BUG_ON(efx->port_enabled);
+
+	/* Stop RX refill */
+	ef4_for_each_channel(channel, efx) {
+		ef4_for_each_channel_rx_queue(rx_queue, channel)
+			rx_queue->refill_enabled = false;
+	}
+
+	ef4_for_each_channel(channel, efx) {
+		/* RX packet processing is pipelined, so wait for the
+		 * NAPI handler to complete.  At least event queue 0
+		 * might be kept active by non-data events, so don't
+		 * use napi_synchronize() but actually disable NAPI
+		 * temporarily.
+		 */
+		if (ef4_channel_has_rx_queue(channel)) {
+			ef4_stop_eventq(channel);
+			ef4_start_eventq(channel);
+		}
+	}
+
+	rc = efx->type->fini_dmaq(efx);
+	if (rc && EF4_WORKAROUND_7803(efx)) {
+		/* Schedule a reset to recover from the flush failure. The
+		 * descriptor caches reference memory we're about to free,
+		 * but falcon_reconfigure_mac_wrapper() won't reconnect
+		 * the MACs because of the pending reset.
+		 */
+		netif_err(efx, drv, efx->net_dev,
+			  "Resetting to recover from flush failure\n");
+		ef4_schedule_reset(efx, RESET_TYPE_ALL);
+	} else if (rc) {
+		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
+	} else {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "successfully flushed all queues\n");
+	}
+
+	ef4_for_each_channel(channel, efx) {
+		ef4_for_each_channel_rx_queue(rx_queue, channel)
+			ef4_fini_rx_queue(rx_queue);
+		ef4_for_each_possible_channel_tx_queue(tx_queue, channel)
+			ef4_fini_tx_queue(tx_queue);
+	}
+}
+
+static void ef4_remove_channel(struct ef4_channel *channel)
+{
+	struct ef4_tx_queue *tx_queue;
+	struct ef4_rx_queue *rx_queue;
+
+	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+		  "destroy chan %d\n", channel->channel);
+
+	ef4_for_each_channel_rx_queue(rx_queue, channel)
+		ef4_remove_rx_queue(rx_queue);
+	ef4_for_each_possible_channel_tx_queue(tx_queue, channel)
+		ef4_remove_tx_queue(tx_queue);
+	ef4_remove_eventq(channel);
+	channel->type->post_remove(channel);
+}
+
+static void ef4_remove_channels(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		ef4_remove_channel(channel);
+}
+
+int
+ef4_realloc_channels(struct ef4_nic *efx, u32 rxq_entries, u32 txq_entries)
+{
+	struct ef4_channel *other_channel[EF4_MAX_CHANNELS], *channel;
+	u32 old_rxq_entries, old_txq_entries;
+	unsigned i, next_buffer_table = 0;
+	int rc, rc2;
+
+	rc = ef4_check_disabled(efx);
+	if (rc)
+		return rc;
+
+	/* Not all channels should be reallocated. We must avoid
+	 * reallocating their buffer table entries.
+	 */
+	ef4_for_each_channel(channel, efx) {
+		struct ef4_rx_queue *rx_queue;
+		struct ef4_tx_queue *tx_queue;
+
+		if (channel->type->copy)
+			continue;
+		next_buffer_table = max(next_buffer_table,
+					channel->eventq.index +
+					channel->eventq.entries);
+		ef4_for_each_channel_rx_queue(rx_queue, channel)
+			next_buffer_table = max(next_buffer_table,
+						rx_queue->rxd.index +
+						rx_queue->rxd.entries);
+		ef4_for_each_channel_tx_queue(tx_queue, channel)
+			next_buffer_table = max(next_buffer_table,
+						tx_queue->txd.index +
+						tx_queue->txd.entries);
+	}
+
+	ef4_device_detach_sync(efx);
+	ef4_stop_all(efx);
+	ef4_soft_disable_interrupts(efx);
+
+	/* Clone channels (where possible) */
+	memset(other_channel, 0, sizeof(other_channel));
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = efx->channel[i];
+		if (channel->type->copy)
+			channel = channel->type->copy(channel);
+		if (!channel) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		other_channel[i] = channel;
+	}
+
+	/* Swap entry counts and channel pointers */
+	old_rxq_entries = efx->rxq_entries;
+	old_txq_entries = efx->txq_entries;
+	efx->rxq_entries = rxq_entries;
+	efx->txq_entries = txq_entries;
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = efx->channel[i];
+		efx->channel[i] = other_channel[i];
+		other_channel[i] = channel;
+	}
+
+	/* Restart buffer table allocation */
+	efx->next_buffer_table = next_buffer_table;
+
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = efx->channel[i];
+		if (!channel->type->copy)
+			continue;
+		rc = ef4_probe_channel(channel);
+		if (rc)
+			goto rollback;
+		ef4_init_napi_channel(efx->channel[i]);
+	}
+
+out:
+	/* Destroy unused channel structures */
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = other_channel[i];
+		if (channel && channel->type->copy) {
+			ef4_fini_napi_channel(channel);
+			ef4_remove_channel(channel);
+			kfree(channel);
+		}
+	}
+
+	rc2 = ef4_soft_enable_interrupts(efx);
+	if (rc2) {
+		rc = rc ? rc : rc2;
+		netif_err(efx, drv, efx->net_dev,
+			  "unable to restart interrupts on channel reallocation\n");
+		ef4_schedule_reset(efx, RESET_TYPE_DISABLE);
+	} else {
+		ef4_start_all(efx);
+		netif_device_attach(efx->net_dev);
+	}
+	return rc;
+
+rollback:
+	/* Swap back */
+	efx->rxq_entries = old_rxq_entries;
+	efx->txq_entries = old_txq_entries;
+	for (i = 0; i < efx->n_channels; i++) {
+		channel = efx->channel[i];
+		efx->channel[i] = other_channel[i];
+		other_channel[i] = channel;
+	}
+	goto out;
+}
+
+void ef4_schedule_slow_fill(struct ef4_rx_queue *rx_queue)
+{
+	mod_timer(&rx_queue->slow_fill, jiffies + msecs_to_jiffies(100));
+}
+
+static const struct ef4_channel_type ef4_default_channel_type = {
+	.pre_probe		= ef4_channel_dummy_op_int,
+	.post_remove		= ef4_channel_dummy_op_void,
+	.get_name		= ef4_get_channel_name,
+	.copy			= ef4_copy_channel,
+	.keep_eventq		= false,
+};
+
+int ef4_channel_dummy_op_int(struct ef4_channel *channel)
+{
+	return 0;
+}
+
+void ef4_channel_dummy_op_void(struct ef4_channel *channel)
+{
+}
+
+/**************************************************************************
+ *
+ * Port handling
+ *
+ **************************************************************************/
+
+/* This ensures that the kernel is kept informed (via
+ * netif_carrier_on/off) of the link status, and also maintains the
+ * link status's stop on the port's TX queue.
+ */
+void ef4_link_status_changed(struct ef4_nic *efx)
+{
+	struct ef4_link_state *link_state = &efx->link_state;
+
+	/* SFC Bug 5356: A net_dev notifier is registered, so we must ensure
+	 * that no events are triggered between unregister_netdev() and the
+	 * driver unloading. A more general condition is that NETDEV_CHANGE
+	 * can only be generated between NETDEV_UP and NETDEV_DOWN */
+	if (!netif_running(efx->net_dev))
+		return;
+
+	if (link_state->up != netif_carrier_ok(efx->net_dev)) {
+		efx->n_link_state_changes++;
+
+		if (link_state->up)
+			netif_carrier_on(efx->net_dev);
+		else
+			netif_carrier_off(efx->net_dev);
+	}
+
+	/* Status message for kernel log */
+	if (link_state->up)
+		netif_info(efx, link, efx->net_dev,
+			   "link up at %uMbps %s-duplex (MTU %d)\n",
+			   link_state->speed, link_state->fd ? "full" : "half",
+			   efx->net_dev->mtu);
+	else
+		netif_info(efx, link, efx->net_dev, "link down\n");
+}
+
+void ef4_link_set_advertising(struct ef4_nic *efx, u32 advertising)
+{
+	efx->link_advertising = advertising;
+	if (advertising) {
+		if (advertising & ADVERTISED_Pause)
+			efx->wanted_fc |= (EF4_FC_TX | EF4_FC_RX);
+		else
+			efx->wanted_fc &= ~(EF4_FC_TX | EF4_FC_RX);
+		if (advertising & ADVERTISED_Asym_Pause)
+			efx->wanted_fc ^= EF4_FC_TX;
+	}
+}
+
+void ef4_link_set_wanted_fc(struct ef4_nic *efx, u8 wanted_fc)
+{
+	efx->wanted_fc = wanted_fc;
+	if (efx->link_advertising) {
+		if (wanted_fc & EF4_FC_RX)
+			efx->link_advertising |= (ADVERTISED_Pause |
+						  ADVERTISED_Asym_Pause);
+		else
+			efx->link_advertising &= ~(ADVERTISED_Pause |
+						   ADVERTISED_Asym_Pause);
+		if (wanted_fc & EF4_FC_TX)
+			efx->link_advertising ^= ADVERTISED_Asym_Pause;
+	}
+}
+
+static void ef4_fini_port(struct ef4_nic *efx);
+
+/* We assume that efx->type->reconfigure_mac will always try to sync RX
+ * filters and therefore needs to read-lock the filter table against freeing
+ */
+void ef4_mac_reconfigure(struct ef4_nic *efx)
+{
+	down_read(&efx->filter_sem);
+	efx->type->reconfigure_mac(efx);
+	up_read(&efx->filter_sem);
+}
+
+/* Push loopback/power/transmit disable settings to the PHY, and reconfigure
+ * the MAC appropriately. All other PHY configuration changes are pushed
+ * through phy_op->set_settings(), and pushed asynchronously to the MAC
+ * through ef4_monitor().
+ *
+ * Callers must hold the mac_lock
+ */
+int __ef4_reconfigure_port(struct ef4_nic *efx)
+{
+	enum ef4_phy_mode phy_mode;
+	int rc;
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
+	/* Disable PHY transmit in mac level loopbacks */
+	phy_mode = efx->phy_mode;
+	if (LOOPBACK_INTERNAL(efx))
+		efx->phy_mode |= PHY_MODE_TX_DISABLED;
+	else
+		efx->phy_mode &= ~PHY_MODE_TX_DISABLED;
+
+	rc = efx->type->reconfigure_port(efx);
+
+	if (rc)
+		efx->phy_mode = phy_mode;
+
+	return rc;
+}
+
+/* Reinitialise the MAC to pick up new PHY settings, even if the port is
+ * disabled. */
+int ef4_reconfigure_port(struct ef4_nic *efx)
+{
+	int rc;
+
+	EF4_ASSERT_RESET_SERIALISED(efx);
+
+	mutex_lock(&efx->mac_lock);
+	rc = __ef4_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	return rc;
+}
+
+/* Asynchronous work item for changing MAC promiscuity and multicast
+ * hash.  Avoid a drain/rx_ingress enable by reconfiguring the current
+ * MAC directly. */
+static void ef4_mac_work(struct work_struct *data)
+{
+	struct ef4_nic *efx = container_of(data, struct ef4_nic, mac_work);
+
+	mutex_lock(&efx->mac_lock);
+	if (efx->port_enabled)
+		ef4_mac_reconfigure(efx);
+	mutex_unlock(&efx->mac_lock);
+}
+
+static int ef4_probe_port(struct ef4_nic *efx)
+{
+	int rc;
+
+	netif_dbg(efx, probe, efx->net_dev, "create port\n");
+
+	if (phy_flash_cfg)
+		efx->phy_mode = PHY_MODE_SPECIAL;
+
+	/* Connect up MAC/PHY operations table */
+	rc = efx->type->probe_port(efx);
+	if (rc)
+		return rc;
+
+	/* Initialise MAC address to permanent address */
+	ether_addr_copy(efx->net_dev->dev_addr, efx->net_dev->perm_addr);
+
+	return 0;
+}
+
+static int ef4_init_port(struct ef4_nic *efx)
+{
+	int rc;
+
+	netif_dbg(efx, drv, efx->net_dev, "init port\n");
+
+	mutex_lock(&efx->mac_lock);
+
+	rc = efx->phy_op->init(efx);
+	if (rc)
+		goto fail1;
+
+	efx->port_initialized = true;
+
+	/* Reconfigure the MAC before creating dma queues (required for
+	 * Falcon/A1 where RX_INGR_EN/TX_DRAIN_EN isn't supported) */
+	ef4_mac_reconfigure(efx);
+
+	/* Ensure the PHY advertises the correct flow control settings */
+	rc = efx->phy_op->reconfigure(efx);
+	if (rc && rc != -EPERM)
+		goto fail2;
+
+	mutex_unlock(&efx->mac_lock);
+	return 0;
+
+fail2:
+	efx->phy_op->fini(efx);
+fail1:
+	mutex_unlock(&efx->mac_lock);
+	return rc;
+}
+
+static void ef4_start_port(struct ef4_nic *efx)
+{
+	netif_dbg(efx, ifup, efx->net_dev, "start port\n");
+	BUG_ON(efx->port_enabled);
+
+	mutex_lock(&efx->mac_lock);
+	efx->port_enabled = true;
+
+	/* Ensure MAC ingress/egress is enabled */
+	ef4_mac_reconfigure(efx);
+
+	mutex_unlock(&efx->mac_lock);
+}
+
+/* Cancel work for MAC reconfiguration, periodic hardware monitoring
+ * and the async self-test, wait for them to finish and prevent them
+ * being scheduled again.  This doesn't cover online resets, which
+ * should only be cancelled when removing the device.
+ */
+static void ef4_stop_port(struct ef4_nic *efx)
+{
+	netif_dbg(efx, ifdown, efx->net_dev, "stop port\n");
+
+	EF4_ASSERT_RESET_SERIALISED(efx);
+
+	mutex_lock(&efx->mac_lock);
+	efx->port_enabled = false;
+	mutex_unlock(&efx->mac_lock);
+
+	/* Serialise against ef4_set_multicast_list() */
+	netif_addr_lock_bh(efx->net_dev);
+	netif_addr_unlock_bh(efx->net_dev);
+
+	cancel_delayed_work_sync(&efx->monitor_work);
+	ef4_selftest_async_cancel(efx);
+	cancel_work_sync(&efx->mac_work);
+}
+
+static void ef4_fini_port(struct ef4_nic *efx)
+{
+	netif_dbg(efx, drv, efx->net_dev, "shut down port\n");
+
+	if (!efx->port_initialized)
+		return;
+
+	efx->phy_op->fini(efx);
+	efx->port_initialized = false;
+
+	efx->link_state.up = false;
+	ef4_link_status_changed(efx);
+}
+
+static void ef4_remove_port(struct ef4_nic *efx)
+{
+	netif_dbg(efx, drv, efx->net_dev, "destroying port\n");
+
+	efx->type->remove_port(efx);
+}
+
+/**************************************************************************
+ *
+ * NIC handling
+ *
+ **************************************************************************/
+
+static LIST_HEAD(ef4_primary_list);
+static LIST_HEAD(ef4_unassociated_list);
+
+static bool ef4_same_controller(struct ef4_nic *left, struct ef4_nic *right)
+{
+	return left->type == right->type &&
+		left->vpd_sn && right->vpd_sn &&
+		!strcmp(left->vpd_sn, right->vpd_sn);
+}
+
+static void ef4_associate(struct ef4_nic *efx)
+{
+	struct ef4_nic *other, *next;
+
+	if (efx->primary == efx) {
+		/* Adding primary function; look for secondaries */
+
+		netif_dbg(efx, probe, efx->net_dev, "adding to primary list\n");
+		list_add_tail(&efx->node, &ef4_primary_list);
+
+		list_for_each_entry_safe(other, next, &ef4_unassociated_list,
+					 node) {
+			if (ef4_same_controller(efx, other)) {
+				list_del(&other->node);
+				netif_dbg(other, probe, other->net_dev,
+					  "moving to secondary list of %s %s\n",
+					  pci_name(efx->pci_dev),
+					  efx->net_dev->name);
+				list_add_tail(&other->node,
+					      &efx->secondary_list);
+				other->primary = efx;
+			}
+		}
+	} else {
+		/* Adding secondary function; look for primary */
+
+		list_for_each_entry(other, &ef4_primary_list, node) {
+			if (ef4_same_controller(efx, other)) {
+				netif_dbg(efx, probe, efx->net_dev,
+					  "adding to secondary list of %s %s\n",
+					  pci_name(other->pci_dev),
+					  other->net_dev->name);
+				list_add_tail(&efx->node,
+					      &other->secondary_list);
+				efx->primary = other;
+				return;
+			}
+		}
+
+		netif_dbg(efx, probe, efx->net_dev,
+			  "adding to unassociated list\n");
+		list_add_tail(&efx->node, &ef4_unassociated_list);
+	}
+}
+
+static void ef4_dissociate(struct ef4_nic *efx)
+{
+	struct ef4_nic *other, *next;
+
+	list_del(&efx->node);
+	efx->primary = NULL;
+
+	list_for_each_entry_safe(other, next, &efx->secondary_list, node) {
+		list_del(&other->node);
+		netif_dbg(other, probe, other->net_dev,
+			  "moving to unassociated list\n");
+		list_add_tail(&other->node, &ef4_unassociated_list);
+		other->primary = NULL;
+	}
+}
+
+/* This configures the PCI device to enable I/O and DMA. */
+static int ef4_init_io(struct ef4_nic *efx)
+{
+	struct pci_dev *pci_dev = efx->pci_dev;
+	dma_addr_t dma_mask = efx->type->max_dma_mask;
+	unsigned int mem_map_size = efx->type->mem_map_size(efx);
+	int rc, bar;
+
+	netif_dbg(efx, probe, efx->net_dev, "initialising I/O\n");
+
+	bar = efx->type->mem_bar;
+
+	rc = pci_enable_device(pci_dev);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to enable PCI device\n");
+		goto fail1;
+	}
+
+	pci_set_master(pci_dev);
+
+	/* Set the PCI DMA mask.  Try all possibilities from our
+	 * genuine mask down to 32 bits, because some architectures
+	 * (e.g. x86_64 with iommu_sac_force set) will allow 40 bit
+	 * masks event though they reject 46 bit masks.
+	 */
+	while (dma_mask > 0x7fffffffUL) {
+		rc = dma_set_mask_and_coherent(&pci_dev->dev, dma_mask);
+		if (rc == 0)
+			break;
+		dma_mask >>= 1;
+	}
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "could not find a suitable DMA mask\n");
+		goto fail2;
+	}
+	netif_dbg(efx, probe, efx->net_dev,
+		  "using DMA mask %llx\n", (unsigned long long) dma_mask);
+
+	efx->membase_phys = pci_resource_start(efx->pci_dev, bar);
+	rc = pci_request_region(pci_dev, bar, "sfc");
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "request for memory BAR failed\n");
+		rc = -EIO;
+		goto fail3;
+	}
+	efx->membase = ioremap_nocache(efx->membase_phys, mem_map_size);
+	if (!efx->membase) {
+		netif_err(efx, probe, efx->net_dev,
+			  "could not map memory BAR at %llx+%x\n",
+			  (unsigned long long)efx->membase_phys, mem_map_size);
+		rc = -ENOMEM;
+		goto fail4;
+	}
+	netif_dbg(efx, probe, efx->net_dev,
+		  "memory BAR at %llx+%x (virtual %p)\n",
+		  (unsigned long long)efx->membase_phys, mem_map_size,
+		  efx->membase);
+
+	return 0;
+
+ fail4:
+	pci_release_region(efx->pci_dev, bar);
+ fail3:
+	efx->membase_phys = 0;
+ fail2:
+	pci_disable_device(efx->pci_dev);
+ fail1:
+	return rc;
+}
+
+static void ef4_fini_io(struct ef4_nic *efx)
+{
+	int bar;
+
+	netif_dbg(efx, drv, efx->net_dev, "shutting down I/O\n");
+
+	if (efx->membase) {
+		iounmap(efx->membase);
+		efx->membase = NULL;
+	}
+
+	if (efx->membase_phys) {
+		bar = efx->type->mem_bar;
+		pci_release_region(efx->pci_dev, bar);
+		efx->membase_phys = 0;
+	}
+
+	/* Don't disable bus-mastering if VFs are assigned */
+	if (!pci_vfs_assigned(efx->pci_dev))
+		pci_disable_device(efx->pci_dev);
+}
+
+void ef4_set_default_rx_indir_table(struct ef4_nic *efx)
+{
+	size_t i;
+
+	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
+		efx->rx_indir_table[i] =
+			ethtool_rxfh_indir_default(i, efx->rss_spread);
+}
+
+static unsigned int ef4_wanted_parallelism(struct ef4_nic *efx)
+{
+	cpumask_var_t thread_mask;
+	unsigned int count;
+	int cpu;
+
+	if (rss_cpus) {
+		count = rss_cpus;
+	} else {
+		if (unlikely(!zalloc_cpumask_var(&thread_mask, GFP_KERNEL))) {
+			netif_warn(efx, probe, efx->net_dev,
+				   "RSS disabled due to allocation failure\n");
+			return 1;
+		}
+
+		count = 0;
+		for_each_online_cpu(cpu) {
+			if (!cpumask_test_cpu(cpu, thread_mask)) {
+				++count;
+				cpumask_or(thread_mask, thread_mask,
+					   topology_sibling_cpumask(cpu));
+			}
+		}
+
+		free_cpumask_var(thread_mask);
+	}
+
+	return count;
+}
+
+/* Probe the number and type of interrupts we are able to obtain, and
+ * the resulting numbers of channels and RX queues.
+ */
+static int ef4_probe_interrupts(struct ef4_nic *efx)
+{
+	unsigned int extra_channels = 0;
+	unsigned int i, j;
+	int rc;
+
+	for (i = 0; i < EF4_MAX_EXTRA_CHANNELS; i++)
+		if (efx->extra_channel_type[i])
+			++extra_channels;
+
+	if (efx->interrupt_mode == EF4_INT_MODE_MSIX) {
+		struct msix_entry xentries[EF4_MAX_CHANNELS];
+		unsigned int n_channels;
+
+		n_channels = ef4_wanted_parallelism(efx);
+		if (ef4_separate_tx_channels)
+			n_channels *= 2;
+		n_channels += extra_channels;
+		n_channels = min(n_channels, efx->max_channels);
+
+		for (i = 0; i < n_channels; i++)
+			xentries[i].entry = i;
+		rc = pci_enable_msix_range(efx->pci_dev,
+					   xentries, 1, n_channels);
+		if (rc < 0) {
+			/* Fall back to single channel MSI */
+			efx->interrupt_mode = EF4_INT_MODE_MSI;
+			netif_err(efx, drv, efx->net_dev,
+				  "could not enable MSI-X\n");
+		} else if (rc < n_channels) {
+			netif_err(efx, drv, efx->net_dev,
+				  "WARNING: Insufficient MSI-X vectors"
+				  " available (%d < %u).\n", rc, n_channels);
+			netif_err(efx, drv, efx->net_dev,
+				  "WARNING: Performance may be reduced.\n");
+			n_channels = rc;
+		}
+
+		if (rc > 0) {
+			efx->n_channels = n_channels;
+			if (n_channels > extra_channels)
+				n_channels -= extra_channels;
+			if (ef4_separate_tx_channels) {
+				efx->n_tx_channels = min(max(n_channels / 2,
+							     1U),
+							 efx->max_tx_channels);
+				efx->n_rx_channels = max(n_channels -
+							 efx->n_tx_channels,
+							 1U);
+			} else {
+				efx->n_tx_channels = min(n_channels,
+							 efx->max_tx_channels);
+				efx->n_rx_channels = n_channels;
+			}
+			for (i = 0; i < efx->n_channels; i++)
+				ef4_get_channel(efx, i)->irq =
+					xentries[i].vector;
+		}
+	}
+
+	/* Try single interrupt MSI */
+	if (efx->interrupt_mode == EF4_INT_MODE_MSI) {
+		efx->n_channels = 1;
+		efx->n_rx_channels = 1;
+		efx->n_tx_channels = 1;
+		rc = pci_enable_msi(efx->pci_dev);
+		if (rc == 0) {
+			ef4_get_channel(efx, 0)->irq = efx->pci_dev->irq;
+		} else {
+			netif_err(efx, drv, efx->net_dev,
+				  "could not enable MSI\n");
+			efx->interrupt_mode = EF4_INT_MODE_LEGACY;
+		}
+	}
+
+	/* Assume legacy interrupts */
+	if (efx->interrupt_mode == EF4_INT_MODE_LEGACY) {
+		efx->n_channels = 1 + (ef4_separate_tx_channels ? 1 : 0);
+		efx->n_rx_channels = 1;
+		efx->n_tx_channels = 1;
+		efx->legacy_irq = efx->pci_dev->irq;
+	}
+
+	/* Assign extra channels if possible */
+	j = efx->n_channels;
+	for (i = 0; i < EF4_MAX_EXTRA_CHANNELS; i++) {
+		if (!efx->extra_channel_type[i])
+			continue;
+		if (efx->interrupt_mode != EF4_INT_MODE_MSIX ||
+		    efx->n_channels <= extra_channels) {
+			efx->extra_channel_type[i]->handle_no_channel(efx);
+		} else {
+			--j;
+			ef4_get_channel(efx, j)->type =
+				efx->extra_channel_type[i];
+		}
+	}
+
+	efx->rss_spread = efx->n_rx_channels;
+
+	return 0;
+}
+
+static int ef4_soft_enable_interrupts(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel, *end_channel;
+	int rc;
+
+	BUG_ON(efx->state == STATE_DISABLED);
+
+	efx->irq_soft_enabled = true;
+	smp_wmb();
+
+	ef4_for_each_channel(channel, efx) {
+		if (!channel->type->keep_eventq) {
+			rc = ef4_init_eventq(channel);
+			if (rc)
+				goto fail;
+		}
+		ef4_start_eventq(channel);
+	}
+
+	return 0;
+fail:
+	end_channel = channel;
+	ef4_for_each_channel(channel, efx) {
+		if (channel == end_channel)
+			break;
+		ef4_stop_eventq(channel);
+		if (!channel->type->keep_eventq)
+			ef4_fini_eventq(channel);
+	}
+
+	return rc;
+}
+
+static void ef4_soft_disable_interrupts(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	if (efx->state == STATE_DISABLED)
+		return;
+
+	efx->irq_soft_enabled = false;
+	smp_wmb();
+
+	if (efx->legacy_irq)
+		synchronize_irq(efx->legacy_irq);
+
+	ef4_for_each_channel(channel, efx) {
+		if (channel->irq)
+			synchronize_irq(channel->irq);
+
+		ef4_stop_eventq(channel);
+		if (!channel->type->keep_eventq)
+			ef4_fini_eventq(channel);
+	}
+}
+
+static int ef4_enable_interrupts(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel, *end_channel;
+	int rc;
+
+	BUG_ON(efx->state == STATE_DISABLED);
+
+	if (efx->eeh_disabled_legacy_irq) {
+		enable_irq(efx->legacy_irq);
+		efx->eeh_disabled_legacy_irq = false;
+	}
+
+	efx->type->irq_enable_master(efx);
+
+	ef4_for_each_channel(channel, efx) {
+		if (channel->type->keep_eventq) {
+			rc = ef4_init_eventq(channel);
+			if (rc)
+				goto fail;
+		}
+	}
+
+	rc = ef4_soft_enable_interrupts(efx);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	end_channel = channel;
+	ef4_for_each_channel(channel, efx) {
+		if (channel == end_channel)
+			break;
+		if (channel->type->keep_eventq)
+			ef4_fini_eventq(channel);
+	}
+
+	efx->type->irq_disable_non_ev(efx);
+
+	return rc;
+}
+
+static void ef4_disable_interrupts(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	ef4_soft_disable_interrupts(efx);
+
+	ef4_for_each_channel(channel, efx) {
+		if (channel->type->keep_eventq)
+			ef4_fini_eventq(channel);
+	}
+
+	efx->type->irq_disable_non_ev(efx);
+}
+
+static void ef4_remove_interrupts(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	/* Remove MSI/MSI-X interrupts */
+	ef4_for_each_channel(channel, efx)
+		channel->irq = 0;
+	pci_disable_msi(efx->pci_dev);
+	pci_disable_msix(efx->pci_dev);
+
+	/* Remove legacy interrupt */
+	efx->legacy_irq = 0;
+}
+
+static void ef4_set_channels(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+	struct ef4_tx_queue *tx_queue;
+
+	efx->tx_channel_offset =
+		ef4_separate_tx_channels ?
+		efx->n_channels - efx->n_tx_channels : 0;
+
+	/* We need to mark which channels really have RX and TX
+	 * queues, and adjust the TX queue numbers if we have separate
+	 * RX-only and TX-only channels.
+	 */
+	ef4_for_each_channel(channel, efx) {
+		if (channel->channel < efx->n_rx_channels)
+			channel->rx_queue.core_index = channel->channel;
+		else
+			channel->rx_queue.core_index = -1;
+
+		ef4_for_each_channel_tx_queue(tx_queue, channel)
+			tx_queue->queue -= (efx->tx_channel_offset *
+					    EF4_TXQ_TYPES);
+	}
+}
+
+static int ef4_probe_nic(struct ef4_nic *efx)
+{
+	int rc;
+
+	netif_dbg(efx, probe, efx->net_dev, "creating NIC\n");
+
+	/* Carry out hardware-type specific initialisation */
+	rc = efx->type->probe(efx);
+	if (rc)
+		return rc;
+
+	do {
+		if (!efx->max_channels || !efx->max_tx_channels) {
+			netif_err(efx, drv, efx->net_dev,
+				  "Insufficient resources to allocate"
+				  " any channels\n");
+			rc = -ENOSPC;
+			goto fail1;
+		}
+
+		/* Determine the number of channels and queues by trying
+		 * to hook in MSI-X interrupts.
+		 */
+		rc = ef4_probe_interrupts(efx);
+		if (rc)
+			goto fail1;
+
+		ef4_set_channels(efx);
+
+		/* dimension_resources can fail with EAGAIN */
+		rc = efx->type->dimension_resources(efx);
+		if (rc != 0 && rc != -EAGAIN)
+			goto fail2;
+
+		if (rc == -EAGAIN)
+			/* try again with new max_channels */
+			ef4_remove_interrupts(efx);
+
+	} while (rc == -EAGAIN);
+
+	if (efx->n_channels > 1)
+		netdev_rss_key_fill(&efx->rx_hash_key,
+				    sizeof(efx->rx_hash_key));
+	ef4_set_default_rx_indir_table(efx);
+
+	netif_set_real_num_tx_queues(efx->net_dev, efx->n_tx_channels);
+	netif_set_real_num_rx_queues(efx->net_dev, efx->n_rx_channels);
+
+	/* Initialise the interrupt moderation settings */
+	efx->irq_mod_step_us = DIV_ROUND_UP(efx->timer_quantum_ns, 1000);
+	ef4_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true,
+				true);
+
+	return 0;
+
+fail2:
+	ef4_remove_interrupts(efx);
+fail1:
+	efx->type->remove(efx);
+	return rc;
+}
+
+static void ef4_remove_nic(struct ef4_nic *efx)
+{
+	netif_dbg(efx, drv, efx->net_dev, "destroying NIC\n");
+
+	ef4_remove_interrupts(efx);
+	efx->type->remove(efx);
+}
+
+static int ef4_probe_filters(struct ef4_nic *efx)
+{
+	int rc;
+
+	spin_lock_init(&efx->filter_lock);
+	init_rwsem(&efx->filter_sem);
+	mutex_lock(&efx->mac_lock);
+	down_write(&efx->filter_sem);
+	rc = efx->type->filter_table_probe(efx);
+	if (rc)
+		goto out_unlock;
+
+#ifdef CONFIG_RFS_ACCEL
+	if (efx->type->offload_features & NETIF_F_NTUPLE) {
+		struct ef4_channel *channel;
+		int i, success = 1;
+
+		ef4_for_each_channel(channel, efx) {
+			channel->rps_flow_id =
+				kcalloc(efx->type->max_rx_ip_filters,
+					sizeof(*channel->rps_flow_id),
+					GFP_KERNEL);
+			if (!channel->rps_flow_id)
+				success = 0;
+			else
+				for (i = 0;
+				     i < efx->type->max_rx_ip_filters;
+				     ++i)
+					channel->rps_flow_id[i] =
+						RPS_FLOW_ID_INVALID;
+		}
+
+		if (!success) {
+			ef4_for_each_channel(channel, efx)
+				kfree(channel->rps_flow_id);
+			efx->type->filter_table_remove(efx);
+			rc = -ENOMEM;
+			goto out_unlock;
+		}
+
+		efx->rps_expire_index = efx->rps_expire_channel = 0;
+	}
+#endif
+out_unlock:
+	up_write(&efx->filter_sem);
+	mutex_unlock(&efx->mac_lock);
+	return rc;
+}
+
+static void ef4_remove_filters(struct ef4_nic *efx)
+{
+#ifdef CONFIG_RFS_ACCEL
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		kfree(channel->rps_flow_id);
+#endif
+	down_write(&efx->filter_sem);
+	efx->type->filter_table_remove(efx);
+	up_write(&efx->filter_sem);
+}
+
+static void ef4_restore_filters(struct ef4_nic *efx)
+{
+	down_read(&efx->filter_sem);
+	efx->type->filter_table_restore(efx);
+	up_read(&efx->filter_sem);
+}
+
+/**************************************************************************
+ *
+ * NIC startup/shutdown
+ *
+ *************************************************************************/
+
+static int ef4_probe_all(struct ef4_nic *efx)
+{
+	int rc;
+
+	rc = ef4_probe_nic(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev, "failed to create NIC\n");
+		goto fail1;
+	}
+
+	rc = ef4_probe_port(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev, "failed to create port\n");
+		goto fail2;
+	}
+
+	BUILD_BUG_ON(EF4_DEFAULT_DMAQ_SIZE < EF4_RXQ_MIN_ENT);
+	if (WARN_ON(EF4_DEFAULT_DMAQ_SIZE < EF4_TXQ_MIN_ENT(efx))) {
+		rc = -EINVAL;
+		goto fail3;
+	}
+	efx->rxq_entries = efx->txq_entries = EF4_DEFAULT_DMAQ_SIZE;
+
+	rc = ef4_probe_filters(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to create filter tables\n");
+		goto fail4;
+	}
+
+	rc = ef4_probe_channels(efx);
+	if (rc)
+		goto fail5;
+
+	return 0;
+
+ fail5:
+	ef4_remove_filters(efx);
+ fail4:
+ fail3:
+	ef4_remove_port(efx);
+ fail2:
+	ef4_remove_nic(efx);
+ fail1:
+	return rc;
+}
+
+/* If the interface is supposed to be running but is not, start
+ * the hardware and software data path, regular activity for the port
+ * (MAC statistics, link polling, etc.) and schedule the port to be
+ * reconfigured.  Interrupts must already be enabled.  This function
+ * is safe to call multiple times, so long as the NIC is not disabled.
+ * Requires the RTNL lock.
+ */
+static void ef4_start_all(struct ef4_nic *efx)
+{
+	EF4_ASSERT_RESET_SERIALISED(efx);
+	BUG_ON(efx->state == STATE_DISABLED);
+
+	/* Check that it is appropriate to restart the interface. All
+	 * of these flags are safe to read under just the rtnl lock */
+	if (efx->port_enabled || !netif_running(efx->net_dev) ||
+	    efx->reset_pending)
+		return;
+
+	ef4_start_port(efx);
+	ef4_start_datapath(efx);
+
+	/* Start the hardware monitor if there is one */
+	if (efx->type->monitor != NULL)
+		queue_delayed_work(efx->workqueue, &efx->monitor_work,
+				   ef4_monitor_interval);
+
+	efx->type->start_stats(efx);
+	efx->type->pull_stats(efx);
+	spin_lock_bh(&efx->stats_lock);
+	efx->type->update_stats(efx, NULL, NULL);
+	spin_unlock_bh(&efx->stats_lock);
+}
+
+/* Quiesce the hardware and software data path, and regular activity
+ * for the port without bringing the link down.  Safe to call multiple
+ * times with the NIC in almost any state, but interrupts should be
+ * enabled.  Requires the RTNL lock.
+ */
+static void ef4_stop_all(struct ef4_nic *efx)
+{
+	EF4_ASSERT_RESET_SERIALISED(efx);
+
+	/* port_enabled can be read safely under the rtnl lock */
+	if (!efx->port_enabled)
+		return;
+
+	/* update stats before we go down so we can accurately count
+	 * rx_nodesc_drops
+	 */
+	efx->type->pull_stats(efx);
+	spin_lock_bh(&efx->stats_lock);
+	efx->type->update_stats(efx, NULL, NULL);
+	spin_unlock_bh(&efx->stats_lock);
+	efx->type->stop_stats(efx);
+	ef4_stop_port(efx);
+
+	/* Stop the kernel transmit interface.  This is only valid if
+	 * the device is stopped or detached; otherwise the watchdog
+	 * may fire immediately.
+	 */
+	WARN_ON(netif_running(efx->net_dev) &&
+		netif_device_present(efx->net_dev));
+	netif_tx_disable(efx->net_dev);
+
+	ef4_stop_datapath(efx);
+}
+
+static void ef4_remove_all(struct ef4_nic *efx)
+{
+	ef4_remove_channels(efx);
+	ef4_remove_filters(efx);
+	ef4_remove_port(efx);
+	ef4_remove_nic(efx);
+}
+
+/**************************************************************************
+ *
+ * Interrupt moderation
+ *
+ **************************************************************************/
+unsigned int ef4_usecs_to_ticks(struct ef4_nic *efx, unsigned int usecs)
+{
+	if (usecs == 0)
+		return 0;
+	if (usecs * 1000 < efx->timer_quantum_ns)
+		return 1; /* never round down to 0 */
+	return usecs * 1000 / efx->timer_quantum_ns;
+}
+
+unsigned int ef4_ticks_to_usecs(struct ef4_nic *efx, unsigned int ticks)
+{
+	/* We must round up when converting ticks to microseconds
+	 * because we round down when converting the other way.
+	 */
+	return DIV_ROUND_UP(ticks * efx->timer_quantum_ns, 1000);
+}
+
+/* Set interrupt moderation parameters */
+int ef4_init_irq_moderation(struct ef4_nic *efx, unsigned int tx_usecs,
+			    unsigned int rx_usecs, bool rx_adaptive,
+			    bool rx_may_override_tx)
+{
+	struct ef4_channel *channel;
+	unsigned int timer_max_us;
+
+	EF4_ASSERT_RESET_SERIALISED(efx);
+
+	timer_max_us = efx->timer_max_ns / 1000;
+
+	if (tx_usecs > timer_max_us || rx_usecs > timer_max_us)
+		return -EINVAL;
+
+	if (tx_usecs != rx_usecs && efx->tx_channel_offset == 0 &&
+	    !rx_may_override_tx) {
+		netif_err(efx, drv, efx->net_dev, "Channels are shared. "
+			  "RX and TX IRQ moderation must be equal\n");
+		return -EINVAL;
+	}
+
+	efx->irq_rx_adaptive = rx_adaptive;
+	efx->irq_rx_moderation_us = rx_usecs;
+	ef4_for_each_channel(channel, efx) {
+		if (ef4_channel_has_rx_queue(channel))
+			channel->irq_moderation_us = rx_usecs;
+		else if (ef4_channel_has_tx_queues(channel))
+			channel->irq_moderation_us = tx_usecs;
+	}
+
+	return 0;
+}
+
+void ef4_get_irq_moderation(struct ef4_nic *efx, unsigned int *tx_usecs,
+			    unsigned int *rx_usecs, bool *rx_adaptive)
+{
+	*rx_adaptive = efx->irq_rx_adaptive;
+	*rx_usecs = efx->irq_rx_moderation_us;
+
+	/* If channels are shared between RX and TX, so is IRQ
+	 * moderation.  Otherwise, IRQ moderation is the same for all
+	 * TX channels and is not adaptive.
+	 */
+	if (efx->tx_channel_offset == 0) {
+		*tx_usecs = *rx_usecs;
+	} else {
+		struct ef4_channel *tx_channel;
+
+		tx_channel = efx->channel[efx->tx_channel_offset];
+		*tx_usecs = tx_channel->irq_moderation_us;
+	}
+}
+
+/**************************************************************************
+ *
+ * Hardware monitor
+ *
+ **************************************************************************/
+
+/* Run periodically off the general workqueue */
+static void ef4_monitor(struct work_struct *data)
+{
+	struct ef4_nic *efx = container_of(data, struct ef4_nic,
+					   monitor_work.work);
+
+	netif_vdbg(efx, timer, efx->net_dev,
+		   "hardware monitor executing on CPU %d\n",
+		   raw_smp_processor_id());
+	BUG_ON(efx->type->monitor == NULL);
+
+	/* If the mac_lock is already held then it is likely a port
+	 * reconfiguration is already in place, which will likely do
+	 * most of the work of monitor() anyway. */
+	if (mutex_trylock(&efx->mac_lock)) {
+		if (efx->port_enabled)
+			efx->type->monitor(efx);
+		mutex_unlock(&efx->mac_lock);
+	}
+
+	queue_delayed_work(efx->workqueue, &efx->monitor_work,
+			   ef4_monitor_interval);
+}
+
+/**************************************************************************
+ *
+ * ioctls
+ *
+ *************************************************************************/
+
+/* Net device ioctl
+ * Context: process, rtnl_lock() held.
+ */
+static int ef4_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct mii_ioctl_data *data = if_mii(ifr);
+
+	/* Convert phy_id from older PRTAD/DEVAD format */
+	if ((cmd == SIOCGMIIREG || cmd == SIOCSMIIREG) &&
+	    (data->phy_id & 0xfc00) == 0x0400)
+		data->phy_id ^= MDIO_PHY_ID_C45 | 0x0400;
+
+	return mdio_mii_ioctl(&efx->mdio, data, cmd);
+}
+
+/**************************************************************************
+ *
+ * NAPI interface
+ *
+ **************************************************************************/
+
+static void ef4_init_napi_channel(struct ef4_channel *channel)
+{
+	struct ef4_nic *efx = channel->efx;
+
+	channel->napi_dev = efx->net_dev;
+	netif_napi_add(channel->napi_dev, &channel->napi_str,
+		       ef4_poll, napi_weight);
+	ef4_channel_busy_poll_init(channel);
+}
+
+static void ef4_init_napi(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		ef4_init_napi_channel(channel);
+}
+
+static void ef4_fini_napi_channel(struct ef4_channel *channel)
+{
+	if (channel->napi_dev)
+		netif_napi_del(&channel->napi_str);
+
+	channel->napi_dev = NULL;
+}
+
+static void ef4_fini_napi(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		ef4_fini_napi_channel(channel);
+}
+
+/**************************************************************************
+ *
+ * Kernel netpoll interface
+ *
+ *************************************************************************/
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+
+/* Although in the common case interrupts will be disabled, this is not
+ * guaranteed. However, all our work happens inside the NAPI callback,
+ * so no locking is required.
+ */
+static void ef4_netpoll(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		ef4_schedule_channel(channel);
+}
+
+#endif
+
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static int ef4_busy_poll(struct napi_struct *napi)
+{
+	struct ef4_channel *channel =
+		container_of(napi, struct ef4_channel, napi_str);
+	struct ef4_nic *efx = channel->efx;
+	int budget = 4;
+	int old_rx_packets, rx_packets;
+
+	if (!netif_running(efx->net_dev))
+		return LL_FLUSH_FAILED;
+
+	if (!ef4_channel_try_lock_poll(channel))
+		return LL_FLUSH_BUSY;
+
+	old_rx_packets = channel->rx_queue.rx_packets;
+	ef4_process_channel(channel, budget);
+
+	rx_packets = channel->rx_queue.rx_packets - old_rx_packets;
+
+	/* There is no race condition with NAPI here.
+	 * NAPI will automatically be rescheduled if it yielded during busy
+	 * polling, because it was not able to take the lock and thus returned
+	 * the full budget.
+	 */
+	ef4_channel_unlock_poll(channel);
+
+	return rx_packets;
+}
+#endif
+
+/**************************************************************************
+ *
+ * Kernel net device interface
+ *
+ *************************************************************************/
+
+/* Context: process, rtnl_lock() held. */
+int ef4_net_open(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int rc;
+
+	netif_dbg(efx, ifup, efx->net_dev, "opening device on CPU %d\n",
+		  raw_smp_processor_id());
+
+	rc = ef4_check_disabled(efx);
+	if (rc)
+		return rc;
+	if (efx->phy_mode & PHY_MODE_SPECIAL)
+		return -EBUSY;
+
+	/* Notify the kernel of the link state polled during driver load,
+	 * before the monitor starts running */
+	ef4_link_status_changed(efx);
+
+	ef4_start_all(efx);
+	ef4_selftest_async_start(efx);
+	return 0;
+}
+
+/* Context: process, rtnl_lock() held.
+ * Note that the kernel will ignore our return code; this method
+ * should really be a void.
+ */
+int ef4_net_stop(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	netif_dbg(efx, ifdown, efx->net_dev, "closing on CPU %d\n",
+		  raw_smp_processor_id());
+
+	/* Stop the device and flush all the channels */
+	ef4_stop_all(efx);
+
+	return 0;
+}
+
+/* Context: process, dev_base_lock or RTNL held, non-blocking. */
+static struct rtnl_link_stats64 *ef4_net_stats(struct net_device *net_dev,
+					       struct rtnl_link_stats64 *stats)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	spin_lock_bh(&efx->stats_lock);
+	efx->type->update_stats(efx, NULL, stats);
+	spin_unlock_bh(&efx->stats_lock);
+
+	return stats;
+}
+
+/* Context: netif_tx_lock held, BHs disabled. */
+static void ef4_watchdog(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	netif_err(efx, tx_err, efx->net_dev,
+		  "TX stuck with port_enabled=%d: resetting channels\n",
+		  efx->port_enabled);
+
+	ef4_schedule_reset(efx, RESET_TYPE_TX_WATCHDOG);
+}
+
+
+/* Context: process, rtnl_lock() held. */
+static int ef4_change_mtu(struct net_device *net_dev, int new_mtu)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int rc;
+
+	rc = ef4_check_disabled(efx);
+	if (rc)
+		return rc;
+
+	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
+
+	ef4_device_detach_sync(efx);
+	ef4_stop_all(efx);
+
+	mutex_lock(&efx->mac_lock);
+	net_dev->mtu = new_mtu;
+	ef4_mac_reconfigure(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	ef4_start_all(efx);
+	netif_device_attach(efx->net_dev);
+	return 0;
+}
+
+static int ef4_set_mac_address(struct net_device *net_dev, void *data)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct sockaddr *addr = data;
+	u8 *new_addr = addr->sa_data;
+	u8 old_addr[6];
+	int rc;
+
+	if (!is_valid_ether_addr(new_addr)) {
+		netif_err(efx, drv, efx->net_dev,
+			  "invalid ethernet MAC address requested: %pM\n",
+			  new_addr);
+		return -EADDRNOTAVAIL;
+	}
+
+	/* save old address */
+	ether_addr_copy(old_addr, net_dev->dev_addr);
+	ether_addr_copy(net_dev->dev_addr, new_addr);
+	if (efx->type->set_mac_address) {
+		rc = efx->type->set_mac_address(efx);
+		if (rc) {
+			ether_addr_copy(net_dev->dev_addr, old_addr);
+			return rc;
+		}
+	}
+
+	/* Reconfigure the MAC */
+	mutex_lock(&efx->mac_lock);
+	ef4_mac_reconfigure(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	return 0;
+}
+
+/* Context: netif_addr_lock held, BHs disabled. */
+static void ef4_set_rx_mode(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	if (efx->port_enabled)
+		queue_work(efx->workqueue, &efx->mac_work);
+	/* Otherwise ef4_start_port() will do this */
+}
+
+static int ef4_set_features(struct net_device *net_dev, netdev_features_t data)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int rc;
+
+	/* If disabling RX n-tuple filtering, clear existing filters */
+	if (net_dev->features & ~data & NETIF_F_NTUPLE) {
+		rc = efx->type->filter_clear_rx(efx, EF4_FILTER_PRI_MANUAL);
+		if (rc)
+			return rc;
+	}
+
+	/* If Rx VLAN filter is changed, update filters via mac_reconfigure */
+	if ((net_dev->features ^ data) & NETIF_F_HW_VLAN_CTAG_FILTER) {
+		/* ef4_set_rx_mode() will schedule MAC work to update filters
+		 * when a new features are finally set in net_dev.
+		 */
+		ef4_set_rx_mode(net_dev);
+	}
+
+	return 0;
+}
+
+static const struct net_device_ops ef4_netdev_ops = {
+	.ndo_open		= ef4_net_open,
+	.ndo_stop		= ef4_net_stop,
+	.ndo_get_stats64	= ef4_net_stats,
+	.ndo_tx_timeout		= ef4_watchdog,
+	.ndo_start_xmit		= ef4_hard_start_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= ef4_ioctl,
+	.ndo_change_mtu		= ef4_change_mtu,
+	.ndo_set_mac_address	= ef4_set_mac_address,
+	.ndo_set_rx_mode	= ef4_set_rx_mode,
+	.ndo_set_features	= ef4_set_features,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = ef4_netpoll,
+#endif
+	.ndo_setup_tc		= ef4_setup_tc,
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll		= ef4_busy_poll,
+#endif
+#ifdef CONFIG_RFS_ACCEL
+	.ndo_rx_flow_steer	= ef4_filter_rfs,
+#endif
+};
+
+static void ef4_update_name(struct ef4_nic *efx)
+{
+	strcpy(efx->name, efx->net_dev->name);
+	ef4_mtd_rename(efx);
+	ef4_set_channel_names(efx);
+}
+
+static int ef4_netdev_event(struct notifier_block *this,
+			    unsigned long event, void *ptr)
+{
+	struct net_device *net_dev = netdev_notifier_info_to_dev(ptr);
+
+	if ((net_dev->netdev_ops == &ef4_netdev_ops) &&
+	    event == NETDEV_CHANGENAME)
+		ef4_update_name(netdev_priv(net_dev));
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ef4_netdev_notifier = {
+	.notifier_call = ef4_netdev_event,
+};
+
+static ssize_t
+show_phy_type(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct ef4_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	return sprintf(buf, "%d\n", efx->phy_type);
+}
+static DEVICE_ATTR(phy_type, 0444, show_phy_type, NULL);
+
+static int ef4_register_netdev(struct ef4_nic *efx)
+{
+	struct net_device *net_dev = efx->net_dev;
+	struct ef4_channel *channel;
+	int rc;
+
+	net_dev->watchdog_timeo = 5 * HZ;
+	net_dev->irq = efx->pci_dev->irq;
+	net_dev->netdev_ops = &ef4_netdev_ops;
+	net_dev->ethtool_ops = &ef4_ethtool_ops;
+	net_dev->gso_max_segs = EF4_TSO_MAX_SEGS;
+	net_dev->min_mtu = EF4_MIN_MTU;
+	net_dev->max_mtu = EF4_MAX_MTU;
+
+	rtnl_lock();
+
+	/* Enable resets to be scheduled and check whether any were
+	 * already requested.  If so, the NIC is probably hosed so we
+	 * abort.
+	 */
+	efx->state = STATE_READY;
+	smp_mb(); /* ensure we change state before checking reset_pending */
+	if (efx->reset_pending) {
+		netif_err(efx, probe, efx->net_dev,
+			  "aborting probe due to scheduled reset\n");
+		rc = -EIO;
+		goto fail_locked;
+	}
+
+	rc = dev_alloc_name(net_dev, net_dev->name);
+	if (rc < 0)
+		goto fail_locked;
+	ef4_update_name(efx);
+
+	/* Always start with carrier off; PHY events will detect the link */
+	netif_carrier_off(net_dev);
+
+	rc = register_netdevice(net_dev);
+	if (rc)
+		goto fail_locked;
+
+	ef4_for_each_channel(channel, efx) {
+		struct ef4_tx_queue *tx_queue;
+		ef4_for_each_channel_tx_queue(tx_queue, channel)
+			ef4_init_tx_queue_core_txq(tx_queue);
+	}
+
+	ef4_associate(efx);
+
+	rtnl_unlock();
+
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_type);
+	if (rc) {
+		netif_err(efx, drv, efx->net_dev,
+			  "failed to init net dev attributes\n");
+		goto fail_registered;
+	}
+	return 0;
+
+fail_registered:
+	rtnl_lock();
+	ef4_dissociate(efx);
+	unregister_netdevice(net_dev);
+fail_locked:
+	efx->state = STATE_UNINIT;
+	rtnl_unlock();
+	netif_err(efx, drv, efx->net_dev, "could not register net dev\n");
+	return rc;
+}
+
+static void ef4_unregister_netdev(struct ef4_nic *efx)
+{
+	if (!efx->net_dev)
+		return;
+
+	BUG_ON(netdev_priv(efx->net_dev) != efx);
+
+	if (ef4_dev_registered(efx)) {
+		strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
+		device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
+		unregister_netdev(efx->net_dev);
+	}
+}
+
+/**************************************************************************
+ *
+ * Device reset and suspend
+ *
+ **************************************************************************/
+
+/* Tears down the entire software state and most of the hardware state
+ * before reset.  */
+void ef4_reset_down(struct ef4_nic *efx, enum reset_type method)
+{
+	EF4_ASSERT_RESET_SERIALISED(efx);
+
+	ef4_stop_all(efx);
+	ef4_disable_interrupts(efx);
+
+	mutex_lock(&efx->mac_lock);
+	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE &&
+	    method != RESET_TYPE_DATAPATH)
+		efx->phy_op->fini(efx);
+	efx->type->fini(efx);
+}
+
+/* This function will always ensure that the locks acquired in
+ * ef4_reset_down() are released. A failure return code indicates
+ * that we were unable to reinitialise the hardware, and the
+ * driver should be disabled. If ok is false, then the rx and tx
+ * engines are not restarted, pending a RESET_DISABLE. */
+int ef4_reset_up(struct ef4_nic *efx, enum reset_type method, bool ok)
+{
+	int rc;
+
+	EF4_ASSERT_RESET_SERIALISED(efx);
+
+	/* Ensure that SRAM is initialised even if we're disabling the device */
+	rc = efx->type->init(efx);
+	if (rc) {
+		netif_err(efx, drv, efx->net_dev, "failed to initialise NIC\n");
+		goto fail;
+	}
+
+	if (!ok)
+		goto fail;
+
+	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE &&
+	    method != RESET_TYPE_DATAPATH) {
+		rc = efx->phy_op->init(efx);
+		if (rc)
+			goto fail;
+		rc = efx->phy_op->reconfigure(efx);
+		if (rc && rc != -EPERM)
+			netif_err(efx, drv, efx->net_dev,
+				  "could not restore PHY settings\n");
+	}
+
+	rc = ef4_enable_interrupts(efx);
+	if (rc)
+		goto fail;
+
+	down_read(&efx->filter_sem);
+	ef4_restore_filters(efx);
+	up_read(&efx->filter_sem);
+
+	mutex_unlock(&efx->mac_lock);
+
+	ef4_start_all(efx);
+
+	return 0;
+
+fail:
+	efx->port_initialized = false;
+
+	mutex_unlock(&efx->mac_lock);
+
+	return rc;
+}
+
+/* Reset the NIC using the specified method.  Note that the reset may
+ * fail, in which case the card will be left in an unusable state.
+ *
+ * Caller must hold the rtnl_lock.
+ */
+int ef4_reset(struct ef4_nic *efx, enum reset_type method)
+{
+	int rc, rc2;
+	bool disabled;
+
+	netif_info(efx, drv, efx->net_dev, "resetting (%s)\n",
+		   RESET_TYPE(method));
+
+	ef4_device_detach_sync(efx);
+	ef4_reset_down(efx, method);
+
+	rc = efx->type->reset(efx, method);
+	if (rc) {
+		netif_err(efx, drv, efx->net_dev, "failed to reset hardware\n");
+		goto out;
+	}
+
+	/* Clear flags for the scopes we covered.  We assume the NIC and
+	 * driver are now quiescent so that there is no race here.
+	 */
+	if (method < RESET_TYPE_MAX_METHOD)
+		efx->reset_pending &= -(1 << (method + 1));
+	else /* it doesn't fit into the well-ordered scope hierarchy */
+		__clear_bit(method, &efx->reset_pending);
+
+	/* Reinitialise bus-mastering, which may have been turned off before
+	 * the reset was scheduled. This is still appropriate, even in the
+	 * RESET_TYPE_DISABLE since this driver generally assumes the hardware
+	 * can respond to requests. */
+	pci_set_master(efx->pci_dev);
+
+out:
+	/* Leave device stopped if necessary */
+	disabled = rc ||
+		method == RESET_TYPE_DISABLE ||
+		method == RESET_TYPE_RECOVER_OR_DISABLE;
+	rc2 = ef4_reset_up(efx, method, !disabled);
+	if (rc2) {
+		disabled = true;
+		if (!rc)
+			rc = rc2;
+	}
+
+	if (disabled) {
+		dev_close(efx->net_dev);
+		netif_err(efx, drv, efx->net_dev, "has been disabled\n");
+		efx->state = STATE_DISABLED;
+	} else {
+		netif_dbg(efx, drv, efx->net_dev, "reset complete\n");
+		netif_device_attach(efx->net_dev);
+	}
+	return rc;
+}
+
+/* Try recovery mechanisms.
+ * For now only EEH is supported.
+ * Returns 0 if the recovery mechanisms are unsuccessful.
+ * Returns a non-zero value otherwise.
+ */
+int ef4_try_recovery(struct ef4_nic *efx)
+{
+#ifdef CONFIG_EEH
+	/* A PCI error can occur and not be seen by EEH because nothing
+	 * happens on the PCI bus. In this case the driver may fail and
+	 * schedule a 'recover or reset', leading to this recovery handler.
+	 * Manually call the eeh failure check function.
+	 */
+	struct eeh_dev *eehdev = pci_dev_to_eeh_dev(efx->pci_dev);
+	if (eeh_dev_check_failure(eehdev)) {
+		/* The EEH mechanisms will handle the error and reset the
+		 * device if necessary.
+		 */
+		return 1;
+	}
+#endif
+	return 0;
+}
+
+/* The worker thread exists so that code that cannot sleep can
+ * schedule a reset for later.
+ */
+static void ef4_reset_work(struct work_struct *data)
+{
+	struct ef4_nic *efx = container_of(data, struct ef4_nic, reset_work);
+	unsigned long pending;
+	enum reset_type method;
+
+	pending = ACCESS_ONCE(efx->reset_pending);
+	method = fls(pending) - 1;
+
+	if ((method == RESET_TYPE_RECOVER_OR_DISABLE ||
+	     method == RESET_TYPE_RECOVER_OR_ALL) &&
+	    ef4_try_recovery(efx))
+		return;
+
+	if (!pending)
+		return;
+
+	rtnl_lock();
+
+	/* We checked the state in ef4_schedule_reset() but it may
+	 * have changed by now.  Now that we have the RTNL lock,
+	 * it cannot change again.
+	 */
+	if (efx->state == STATE_READY)
+		(void)ef4_reset(efx, method);
+
+	rtnl_unlock();
+}
+
+void ef4_schedule_reset(struct ef4_nic *efx, enum reset_type type)
+{
+	enum reset_type method;
+
+	if (efx->state == STATE_RECOVERY) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "recovering: skip scheduling %s reset\n",
+			  RESET_TYPE(type));
+		return;
+	}
+
+	switch (type) {
+	case RESET_TYPE_INVISIBLE:
+	case RESET_TYPE_ALL:
+	case RESET_TYPE_RECOVER_OR_ALL:
+	case RESET_TYPE_WORLD:
+	case RESET_TYPE_DISABLE:
+	case RESET_TYPE_RECOVER_OR_DISABLE:
+	case RESET_TYPE_DATAPATH:
+		method = type;
+		netif_dbg(efx, drv, efx->net_dev, "scheduling %s reset\n",
+			  RESET_TYPE(method));
+		break;
+	default:
+		method = efx->type->map_reset_reason(type);
+		netif_dbg(efx, drv, efx->net_dev,
+			  "scheduling %s reset for %s\n",
+			  RESET_TYPE(method), RESET_TYPE(type));
+		break;
+	}
+
+	set_bit(method, &efx->reset_pending);
+	smp_mb(); /* ensure we change reset_pending before checking state */
+
+	/* If we're not READY then just leave the flags set as the cue
+	 * to abort probing or reschedule the reset later.
+	 */
+	if (ACCESS_ONCE(efx->state) != STATE_READY)
+		return;
+
+	queue_work(reset_workqueue, &efx->reset_work);
+}
+
+/**************************************************************************
+ *
+ * List of NICs we support
+ *
+ **************************************************************************/
+
+/* PCI device ID table */
+static const struct pci_device_id ef4_pci_table[] = {
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
+		    PCI_DEVICE_ID_SOLARFLARE_SFC4000A_0),
+	 .driver_data = (unsigned long) &falcon_a1_nic_type},
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
+		    PCI_DEVICE_ID_SOLARFLARE_SFC4000B),
+	 .driver_data = (unsigned long) &falcon_b0_nic_type},
+	{0}			/* end of list */
+};
+
+/**************************************************************************
+ *
+ * Dummy PHY/MAC operations
+ *
+ * Can be used for some unimplemented operations
+ * Needed so all function pointers are valid and do not have to be tested
+ * before use
+ *
+ **************************************************************************/
+int ef4_port_dummy_op_int(struct ef4_nic *efx)
+{
+	return 0;
+}
+void ef4_port_dummy_op_void(struct ef4_nic *efx) {}
+
+static bool ef4_port_dummy_op_poll(struct ef4_nic *efx)
+{
+	return false;
+}
+
+static const struct ef4_phy_operations ef4_dummy_phy_operations = {
+	.init		 = ef4_port_dummy_op_int,
+	.reconfigure	 = ef4_port_dummy_op_int,
+	.poll		 = ef4_port_dummy_op_poll,
+	.fini		 = ef4_port_dummy_op_void,
+};
+
+/**************************************************************************
+ *
+ * Data housekeeping
+ *
+ **************************************************************************/
+
+/* This zeroes out and then fills in the invariants in a struct
+ * ef4_nic (including all sub-structures).
+ */
+static int ef4_init_struct(struct ef4_nic *efx,
+			   struct pci_dev *pci_dev, struct net_device *net_dev)
+{
+	int i;
+
+	/* Initialise common structures */
+	INIT_LIST_HEAD(&efx->node);
+	INIT_LIST_HEAD(&efx->secondary_list);
+	spin_lock_init(&efx->biu_lock);
+#ifdef CONFIG_SFC_FALCON_MTD
+	INIT_LIST_HEAD(&efx->mtd_list);
+#endif
+	INIT_WORK(&efx->reset_work, ef4_reset_work);
+	INIT_DELAYED_WORK(&efx->monitor_work, ef4_monitor);
+	INIT_DELAYED_WORK(&efx->selftest_work, ef4_selftest_async_work);
+	efx->pci_dev = pci_dev;
+	efx->msg_enable = debug;
+	efx->state = STATE_UNINIT;
+	strlcpy(efx->name, pci_name(pci_dev), sizeof(efx->name));
+
+	efx->net_dev = net_dev;
+	efx->rx_prefix_size = efx->type->rx_prefix_size;
+	efx->rx_ip_align =
+		NET_IP_ALIGN ? (efx->rx_prefix_size + NET_IP_ALIGN) % 4 : 0;
+	efx->rx_packet_hash_offset =
+		efx->type->rx_hash_offset - efx->type->rx_prefix_size;
+	efx->rx_packet_ts_offset =
+		efx->type->rx_ts_offset - efx->type->rx_prefix_size;
+	spin_lock_init(&efx->stats_lock);
+	mutex_init(&efx->mac_lock);
+	efx->phy_op = &ef4_dummy_phy_operations;
+	efx->mdio.dev = net_dev;
+	INIT_WORK(&efx->mac_work, ef4_mac_work);
+	init_waitqueue_head(&efx->flush_wq);
+
+	for (i = 0; i < EF4_MAX_CHANNELS; i++) {
+		efx->channel[i] = ef4_alloc_channel(efx, i, NULL);
+		if (!efx->channel[i])
+			goto fail;
+		efx->msi_context[i].efx = efx;
+		efx->msi_context[i].index = i;
+	}
+
+	/* Higher numbered interrupt modes are less capable! */
+	efx->interrupt_mode = max(efx->type->max_interrupt_mode,
+				  interrupt_mode);
+
+	/* Would be good to use the net_dev name, but we're too early */
+	snprintf(efx->workqueue_name, sizeof(efx->workqueue_name), "sfc%s",
+		 pci_name(pci_dev));
+	efx->workqueue = create_singlethread_workqueue(efx->workqueue_name);
+	if (!efx->workqueue)
+		goto fail;
+
+	return 0;
+
+fail:
+	ef4_fini_struct(efx);
+	return -ENOMEM;
+}
+
+static void ef4_fini_struct(struct ef4_nic *efx)
+{
+	int i;
+
+	for (i = 0; i < EF4_MAX_CHANNELS; i++)
+		kfree(efx->channel[i]);
+
+	kfree(efx->vpd_sn);
+
+	if (efx->workqueue) {
+		destroy_workqueue(efx->workqueue);
+		efx->workqueue = NULL;
+	}
+}
+
+void ef4_update_sw_stats(struct ef4_nic *efx, u64 *stats)
+{
+	u64 n_rx_nodesc_trunc = 0;
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		n_rx_nodesc_trunc += channel->n_rx_nodesc_trunc;
+	stats[GENERIC_STAT_rx_nodesc_trunc] = n_rx_nodesc_trunc;
+	stats[GENERIC_STAT_rx_noskb_drops] = atomic_read(&efx->n_rx_noskb_drops);
+}
+
+/**************************************************************************
+ *
+ * PCI interface
+ *
+ **************************************************************************/
+
+/* Main body of final NIC shutdown code
+ * This is called only at module unload (or hotplug removal).
+ */
+static void ef4_pci_remove_main(struct ef4_nic *efx)
+{
+	/* Flush reset_work. It can no longer be scheduled since we
+	 * are not READY.
+	 */
+	BUG_ON(efx->state == STATE_READY);
+	cancel_work_sync(&efx->reset_work);
+
+	ef4_disable_interrupts(efx);
+	ef4_nic_fini_interrupt(efx);
+	ef4_fini_port(efx);
+	efx->type->fini(efx);
+	ef4_fini_napi(efx);
+	ef4_remove_all(efx);
+}
+
+/* Final NIC shutdown
+ * This is called only at module unload (or hotplug removal).  A PF can call
+ * this on its VFs to ensure they are unbound first.
+ */
+static void ef4_pci_remove(struct pci_dev *pci_dev)
+{
+	struct ef4_nic *efx;
+
+	efx = pci_get_drvdata(pci_dev);
+	if (!efx)
+		return;
+
+	/* Mark the NIC as fini, then stop the interface */
+	rtnl_lock();
+	ef4_dissociate(efx);
+	dev_close(efx->net_dev);
+	ef4_disable_interrupts(efx);
+	efx->state = STATE_UNINIT;
+	rtnl_unlock();
+
+	ef4_unregister_netdev(efx);
+
+	ef4_mtd_remove(efx);
+
+	ef4_pci_remove_main(efx);
+
+	ef4_fini_io(efx);
+	netif_dbg(efx, drv, efx->net_dev, "shutdown successful\n");
+
+	ef4_fini_struct(efx);
+	free_netdev(efx->net_dev);
+
+	pci_disable_pcie_error_reporting(pci_dev);
+};
+
+/* NIC VPD information
+ * Called during probe to display the part number of the
+ * installed NIC.  VPD is potentially very large but this should
+ * always appear within the first 512 bytes.
+ */
+#define SFC_VPD_LEN 512
+static void ef4_probe_vpd_strings(struct ef4_nic *efx)
+{
+	struct pci_dev *dev = efx->pci_dev;
+	char vpd_data[SFC_VPD_LEN];
+	ssize_t vpd_size;
+	int ro_start, ro_size, i, j;
+
+	/* Get the vpd data from the device */
+	vpd_size = pci_read_vpd(dev, 0, sizeof(vpd_data), vpd_data);
+	if (vpd_size <= 0) {
+		netif_err(efx, drv, efx->net_dev, "Unable to read VPD\n");
+		return;
+	}
+
+	/* Get the Read only section */
+	ro_start = pci_vpd_find_tag(vpd_data, 0, vpd_size, PCI_VPD_LRDT_RO_DATA);
+	if (ro_start < 0) {
+		netif_err(efx, drv, efx->net_dev, "VPD Read-only not found\n");
+		return;
+	}
+
+	ro_size = pci_vpd_lrdt_size(&vpd_data[ro_start]);
+	j = ro_size;
+	i = ro_start + PCI_VPD_LRDT_TAG_SIZE;
+	if (i + j > vpd_size)
+		j = vpd_size - i;
+
+	/* Get the Part number */
+	i = pci_vpd_find_info_keyword(vpd_data, i, j, "PN");
+	if (i < 0) {
+		netif_err(efx, drv, efx->net_dev, "Part number not found\n");
+		return;
+	}
+
+	j = pci_vpd_info_field_size(&vpd_data[i]);
+	i += PCI_VPD_INFO_FLD_HDR_SIZE;
+	if (i + j > vpd_size) {
+		netif_err(efx, drv, efx->net_dev, "Incomplete part number\n");
+		return;
+	}
+
+	netif_info(efx, drv, efx->net_dev,
+		   "Part Number : %.*s\n", j, &vpd_data[i]);
+
+	i = ro_start + PCI_VPD_LRDT_TAG_SIZE;
+	j = ro_size;
+	i = pci_vpd_find_info_keyword(vpd_data, i, j, "SN");
+	if (i < 0) {
+		netif_err(efx, drv, efx->net_dev, "Serial number not found\n");
+		return;
+	}
+
+	j = pci_vpd_info_field_size(&vpd_data[i]);
+	i += PCI_VPD_INFO_FLD_HDR_SIZE;
+	if (i + j > vpd_size) {
+		netif_err(efx, drv, efx->net_dev, "Incomplete serial number\n");
+		return;
+	}
+
+	efx->vpd_sn = kmalloc(j + 1, GFP_KERNEL);
+	if (!efx->vpd_sn)
+		return;
+
+	snprintf(efx->vpd_sn, j + 1, "%s", &vpd_data[i]);
+}
+
+
+/* Main body of NIC initialisation
+ * This is called at module load (or hotplug insertion, theoretically).
+ */
+static int ef4_pci_probe_main(struct ef4_nic *efx)
+{
+	int rc;
+
+	/* Do start-of-day initialisation */
+	rc = ef4_probe_all(efx);
+	if (rc)
+		goto fail1;
+
+	ef4_init_napi(efx);
+
+	rc = efx->type->init(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to initialise NIC\n");
+		goto fail3;
+	}
+
+	rc = ef4_init_port(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to initialise port\n");
+		goto fail4;
+	}
+
+	rc = ef4_nic_init_interrupt(efx);
+	if (rc)
+		goto fail5;
+	rc = ef4_enable_interrupts(efx);
+	if (rc)
+		goto fail6;
+
+	return 0;
+
+ fail6:
+	ef4_nic_fini_interrupt(efx);
+ fail5:
+	ef4_fini_port(efx);
+ fail4:
+	efx->type->fini(efx);
+ fail3:
+	ef4_fini_napi(efx);
+	ef4_remove_all(efx);
+ fail1:
+	return rc;
+}
+
+/* NIC initialisation
+ *
+ * This is called at module load (or hotplug insertion,
+ * theoretically).  It sets up PCI mappings, resets the NIC,
+ * sets up and registers the network devices with the kernel and hooks
+ * the interrupt service routine.  It does not prepare the device for
+ * transmission; this is left to the first time one of the network
+ * interfaces is brought up (i.e. ef4_net_open).
+ */
+static int ef4_pci_probe(struct pci_dev *pci_dev,
+			 const struct pci_device_id *entry)
+{
+	struct net_device *net_dev;
+	struct ef4_nic *efx;
+	int rc;
+
+	/* Allocate and initialise a struct net_device and struct ef4_nic */
+	net_dev = alloc_etherdev_mqs(sizeof(*efx), EF4_MAX_CORE_TX_QUEUES,
+				     EF4_MAX_RX_QUEUES);
+	if (!net_dev)
+		return -ENOMEM;
+	efx = netdev_priv(net_dev);
+	efx->type = (const struct ef4_nic_type *) entry->driver_data;
+	efx->fixed_features |= NETIF_F_HIGHDMA;
+
+	pci_set_drvdata(pci_dev, efx);
+	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
+	rc = ef4_init_struct(efx, pci_dev, net_dev);
+	if (rc)
+		goto fail1;
+
+	netif_info(efx, probe, efx->net_dev,
+		   "Solarflare NIC detected\n");
+
+	ef4_probe_vpd_strings(efx);
+
+	/* Set up basic I/O (BAR mappings etc) */
+	rc = ef4_init_io(efx);
+	if (rc)
+		goto fail2;
+
+	rc = ef4_pci_probe_main(efx);
+	if (rc)
+		goto fail3;
+
+	net_dev->features |= (efx->type->offload_features | NETIF_F_SG |
+			      NETIF_F_RXCSUM);
+	/* Mask for features that also apply to VLAN devices */
+	net_dev->vlan_features |= (NETIF_F_HW_CSUM | NETIF_F_SG |
+				   NETIF_F_HIGHDMA | NETIF_F_RXCSUM);
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
+	rc = ef4_register_netdev(efx);
+	if (rc)
+		goto fail4;
+
+	netif_dbg(efx, probe, efx->net_dev, "initialisation successful\n");
+
+	/* Try to create MTDs, but allow this to fail */
+	rtnl_lock();
+	rc = ef4_mtd_probe(efx);
+	rtnl_unlock();
+	if (rc && rc != -EPERM)
+		netif_warn(efx, probe, efx->net_dev,
+			   "failed to create MTDs (%d)\n", rc);
+
+	rc = pci_enable_pcie_error_reporting(pci_dev);
+	if (rc && rc != -EINVAL)
+		netif_notice(efx, probe, efx->net_dev,
+			     "PCIE error reporting unavailable (%d).\n",
+			     rc);
+
+	return 0;
+
+ fail4:
+	ef4_pci_remove_main(efx);
+ fail3:
+	ef4_fini_io(efx);
+ fail2:
+	ef4_fini_struct(efx);
+ fail1:
+	WARN_ON(rc > 0);
+	netif_dbg(efx, drv, efx->net_dev, "initialisation failed. rc=%d\n", rc);
+	free_netdev(net_dev);
+	return rc;
+}
+
+static int ef4_pm_freeze(struct device *dev)
+{
+	struct ef4_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	rtnl_lock();
+
+	if (efx->state != STATE_DISABLED) {
+		efx->state = STATE_UNINIT;
+
+		ef4_device_detach_sync(efx);
+
+		ef4_stop_all(efx);
+		ef4_disable_interrupts(efx);
+	}
+
+	rtnl_unlock();
+
+	return 0;
+}
+
+static int ef4_pm_thaw(struct device *dev)
+{
+	int rc;
+	struct ef4_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	rtnl_lock();
+
+	if (efx->state != STATE_DISABLED) {
+		rc = ef4_enable_interrupts(efx);
+		if (rc)
+			goto fail;
+
+		mutex_lock(&efx->mac_lock);
+		efx->phy_op->reconfigure(efx);
+		mutex_unlock(&efx->mac_lock);
+
+		ef4_start_all(efx);
+
+		netif_device_attach(efx->net_dev);
+
+		efx->state = STATE_READY;
+
+		efx->type->resume_wol(efx);
+	}
+
+	rtnl_unlock();
+
+	/* Reschedule any quenched resets scheduled during ef4_pm_freeze() */
+	queue_work(reset_workqueue, &efx->reset_work);
+
+	return 0;
+
+fail:
+	rtnl_unlock();
+
+	return rc;
+}
+
+static int ef4_pm_poweroff(struct device *dev)
+{
+	struct pci_dev *pci_dev = to_pci_dev(dev);
+	struct ef4_nic *efx = pci_get_drvdata(pci_dev);
+
+	efx->type->fini(efx);
+
+	efx->reset_pending = 0;
+
+	pci_save_state(pci_dev);
+	return pci_set_power_state(pci_dev, PCI_D3hot);
+}
+
+/* Used for both resume and restore */
+static int ef4_pm_resume(struct device *dev)
+{
+	struct pci_dev *pci_dev = to_pci_dev(dev);
+	struct ef4_nic *efx = pci_get_drvdata(pci_dev);
+	int rc;
+
+	rc = pci_set_power_state(pci_dev, PCI_D0);
+	if (rc)
+		return rc;
+	pci_restore_state(pci_dev);
+	rc = pci_enable_device(pci_dev);
+	if (rc)
+		return rc;
+	pci_set_master(efx->pci_dev);
+	rc = efx->type->reset(efx, RESET_TYPE_ALL);
+	if (rc)
+		return rc;
+	rc = efx->type->init(efx);
+	if (rc)
+		return rc;
+	rc = ef4_pm_thaw(dev);
+	return rc;
+}
+
+static int ef4_pm_suspend(struct device *dev)
+{
+	int rc;
+
+	ef4_pm_freeze(dev);
+	rc = ef4_pm_poweroff(dev);
+	if (rc)
+		ef4_pm_resume(dev);
+	return rc;
+}
+
+static const struct dev_pm_ops ef4_pm_ops = {
+	.suspend	= ef4_pm_suspend,
+	.resume		= ef4_pm_resume,
+	.freeze		= ef4_pm_freeze,
+	.thaw		= ef4_pm_thaw,
+	.poweroff	= ef4_pm_poweroff,
+	.restore	= ef4_pm_resume,
+};
+
+/* A PCI error affecting this device was detected.
+ * At this point MMIO and DMA may be disabled.
+ * Stop the software path and request a slot reset.
+ */
+static pci_ers_result_t ef4_io_error_detected(struct pci_dev *pdev,
+					      enum pci_channel_state state)
+{
+	pci_ers_result_t status = PCI_ERS_RESULT_RECOVERED;
+	struct ef4_nic *efx = pci_get_drvdata(pdev);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	rtnl_lock();
+
+	if (efx->state != STATE_DISABLED) {
+		efx->state = STATE_RECOVERY;
+		efx->reset_pending = 0;
+
+		ef4_device_detach_sync(efx);
+
+		ef4_stop_all(efx);
+		ef4_disable_interrupts(efx);
+
+		status = PCI_ERS_RESULT_NEED_RESET;
+	} else {
+		/* If the interface is disabled we don't want to do anything
+		 * with it.
+		 */
+		status = PCI_ERS_RESULT_RECOVERED;
+	}
+
+	rtnl_unlock();
+
+	pci_disable_device(pdev);
+
+	return status;
+}
+
+/* Fake a successful reset, which will be performed later in ef4_io_resume. */
+static pci_ers_result_t ef4_io_slot_reset(struct pci_dev *pdev)
+{
+	struct ef4_nic *efx = pci_get_drvdata(pdev);
+	pci_ers_result_t status = PCI_ERS_RESULT_RECOVERED;
+	int rc;
+
+	if (pci_enable_device(pdev)) {
+		netif_err(efx, hw, efx->net_dev,
+			  "Cannot re-enable PCI device after reset.\n");
+		status =  PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	rc = pci_cleanup_aer_uncorrect_error_status(pdev);
+	if (rc) {
+		netif_err(efx, hw, efx->net_dev,
+		"pci_cleanup_aer_uncorrect_error_status failed (%d)\n", rc);
+		/* Non-fatal error. Continue. */
+	}
+
+	return status;
+}
+
+/* Perform the actual reset and resume I/O operations. */
+static void ef4_io_resume(struct pci_dev *pdev)
+{
+	struct ef4_nic *efx = pci_get_drvdata(pdev);
+	int rc;
+
+	rtnl_lock();
+
+	if (efx->state == STATE_DISABLED)
+		goto out;
+
+	rc = ef4_reset(efx, RESET_TYPE_ALL);
+	if (rc) {
+		netif_err(efx, hw, efx->net_dev,
+			  "ef4_reset failed after PCI error (%d)\n", rc);
+	} else {
+		efx->state = STATE_READY;
+		netif_dbg(efx, hw, efx->net_dev,
+			  "Done resetting and resuming IO after PCI error.\n");
+	}
+
+out:
+	rtnl_unlock();
+}
+
+/* For simplicity and reliability, we always require a slot reset and try to
+ * reset the hardware when a pci error affecting the device is detected.
+ * We leave both the link_reset and mmio_enabled callback unimplemented:
+ * with our request for slot reset the mmio_enabled callback will never be
+ * called, and the link_reset callback is not used by AER or EEH mechanisms.
+ */
+static const struct pci_error_handlers ef4_err_handlers = {
+	.error_detected = ef4_io_error_detected,
+	.slot_reset	= ef4_io_slot_reset,
+	.resume		= ef4_io_resume,
+};
+
+static struct pci_driver ef4_pci_driver = {
+	.name		= KBUILD_MODNAME,
+	.id_table	= ef4_pci_table,
+	.probe		= ef4_pci_probe,
+	.remove		= ef4_pci_remove,
+	.driver.pm	= &ef4_pm_ops,
+	.err_handler	= &ef4_err_handlers,
+};
+
+/**************************************************************************
+ *
+ * Kernel module interface
+ *
+ *************************************************************************/
+
+module_param(interrupt_mode, uint, 0444);
+MODULE_PARM_DESC(interrupt_mode,
+		 "Interrupt mode (0=>MSIX 1=>MSI 2=>legacy)");
+
+static int __init ef4_init_module(void)
+{
+	int rc;
+
+	printk(KERN_INFO "Solarflare Falcon driver v" EF4_DRIVER_VERSION "\n");
+
+	rc = register_netdevice_notifier(&ef4_netdev_notifier);
+	if (rc)
+		goto err_notifier;
+
+	reset_workqueue = create_singlethread_workqueue("sfc_reset");
+	if (!reset_workqueue) {
+		rc = -ENOMEM;
+		goto err_reset;
+	}
+
+	rc = pci_register_driver(&ef4_pci_driver);
+	if (rc < 0)
+		goto err_pci;
+
+	return 0;
+
+ err_pci:
+	destroy_workqueue(reset_workqueue);
+ err_reset:
+	unregister_netdevice_notifier(&ef4_netdev_notifier);
+ err_notifier:
+	return rc;
+}
+
+static void __exit ef4_exit_module(void)
+{
+	printk(KERN_INFO "Solarflare Falcon driver unloading\n");
+
+	pci_unregister_driver(&ef4_pci_driver);
+	destroy_workqueue(reset_workqueue);
+	unregister_netdevice_notifier(&ef4_netdev_notifier);
+
+}
+
+module_init(ef4_init_module);
+module_exit(ef4_exit_module);
+
+MODULE_AUTHOR("Solarflare Communications and "
+	      "Michael Brown <mbrown@fensystems.co.uk>");
+MODULE_DESCRIPTION("Solarflare Falcon network driver");
+MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(pci, ef4_pci_table);
diff --git a/drivers/net/ethernet/sfc/falcon/efx.h b/drivers/net/ethernet/sfc/falcon/efx.h
new file mode 100644
index 0000000..c89456f
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/efx.h
@@ -0,0 +1,277 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_EFX_H
+#define EF4_EFX_H
+
+#include "net_driver.h"
+#include "filter.h"
+
+/* All controllers use BAR 0 for I/O space and BAR 2(&3) for memory */
+/* All VFs use BAR 0/1 for memory */
+#define EF4_MEM_BAR 2
+#define EF4_MEM_VF_BAR 0
+
+int ef4_net_open(struct net_device *net_dev);
+int ef4_net_stop(struct net_device *net_dev);
+
+/* TX */
+int ef4_probe_tx_queue(struct ef4_tx_queue *tx_queue);
+void ef4_remove_tx_queue(struct ef4_tx_queue *tx_queue);
+void ef4_init_tx_queue(struct ef4_tx_queue *tx_queue);
+void ef4_init_tx_queue_core_txq(struct ef4_tx_queue *tx_queue);
+void ef4_fini_tx_queue(struct ef4_tx_queue *tx_queue);
+netdev_tx_t ef4_hard_start_xmit(struct sk_buff *skb,
+				struct net_device *net_dev);
+netdev_tx_t ef4_enqueue_skb(struct ef4_tx_queue *tx_queue, struct sk_buff *skb);
+void ef4_xmit_done(struct ef4_tx_queue *tx_queue, unsigned int index);
+int ef4_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
+		 struct tc_to_netdev *tc);
+unsigned int ef4_tx_max_skb_descs(struct ef4_nic *efx);
+extern bool ef4_separate_tx_channels;
+
+/* RX */
+void ef4_set_default_rx_indir_table(struct ef4_nic *efx);
+void ef4_rx_config_page_split(struct ef4_nic *efx);
+int ef4_probe_rx_queue(struct ef4_rx_queue *rx_queue);
+void ef4_remove_rx_queue(struct ef4_rx_queue *rx_queue);
+void ef4_init_rx_queue(struct ef4_rx_queue *rx_queue);
+void ef4_fini_rx_queue(struct ef4_rx_queue *rx_queue);
+void ef4_fast_push_rx_descriptors(struct ef4_rx_queue *rx_queue, bool atomic);
+void ef4_rx_slow_fill(unsigned long context);
+void __ef4_rx_packet(struct ef4_channel *channel);
+void ef4_rx_packet(struct ef4_rx_queue *rx_queue, unsigned int index,
+		   unsigned int n_frags, unsigned int len, u16 flags);
+static inline void ef4_rx_flush_packet(struct ef4_channel *channel)
+{
+	if (channel->rx_pkt_n_frags)
+		__ef4_rx_packet(channel);
+}
+void ef4_schedule_slow_fill(struct ef4_rx_queue *rx_queue);
+
+#define EF4_MAX_DMAQ_SIZE 4096UL
+#define EF4_DEFAULT_DMAQ_SIZE 1024UL
+#define EF4_MIN_DMAQ_SIZE 512UL
+
+#define EF4_MAX_EVQ_SIZE 16384UL
+#define EF4_MIN_EVQ_SIZE 512UL
+
+/* Maximum number of TCP segments we support for soft-TSO */
+#define EF4_TSO_MAX_SEGS	100
+
+/* The smallest [rt]xq_entries that the driver supports.  RX minimum
+ * is a bit arbitrary.  For TX, we must have space for at least 2
+ * TSO skbs.
+ */
+#define EF4_RXQ_MIN_ENT		128U
+#define EF4_TXQ_MIN_ENT(efx)	(2 * ef4_tx_max_skb_descs(efx))
+
+static inline bool ef4_rss_enabled(struct ef4_nic *efx)
+{
+	return efx->rss_spread > 1;
+}
+
+/* Filters */
+
+void ef4_mac_reconfigure(struct ef4_nic *efx);
+
+/**
+ * ef4_filter_insert_filter - add or replace a filter
+ * @efx: NIC in which to insert the filter
+ * @spec: Specification for the filter
+ * @replace_equal: Flag for whether the specified filter may replace an
+ *	existing filter with equal priority
+ *
+ * On success, return the filter ID.
+ * On failure, return a negative error code.
+ *
+ * If existing filters have equal match values to the new filter spec,
+ * then the new filter might replace them or the function might fail,
+ * as follows.
+ *
+ * 1. If the existing filters have lower priority, or @replace_equal
+ *    is set and they have equal priority, replace them.
+ *
+ * 2. If the existing filters have higher priority, return -%EPERM.
+ *
+ * 3. If !ef4_filter_is_mc_recipient(@spec), or the NIC does not
+ *    support delivery to multiple recipients, return -%EEXIST.
+ *
+ * This implies that filters for multiple multicast recipients must
+ * all be inserted with the same priority and @replace_equal = %false.
+ */
+static inline s32 ef4_filter_insert_filter(struct ef4_nic *efx,
+					   struct ef4_filter_spec *spec,
+					   bool replace_equal)
+{
+	return efx->type->filter_insert(efx, spec, replace_equal);
+}
+
+/**
+ * ef4_filter_remove_id_safe - remove a filter by ID, carefully
+ * @efx: NIC from which to remove the filter
+ * @priority: Priority of filter, as passed to @ef4_filter_insert_filter
+ * @filter_id: ID of filter, as returned by @ef4_filter_insert_filter
+ *
+ * This function will range-check @filter_id, so it is safe to call
+ * with a value passed from userland.
+ */
+static inline int ef4_filter_remove_id_safe(struct ef4_nic *efx,
+					    enum ef4_filter_priority priority,
+					    u32 filter_id)
+{
+	return efx->type->filter_remove_safe(efx, priority, filter_id);
+}
+
+/**
+ * ef4_filter_get_filter_safe - retrieve a filter by ID, carefully
+ * @efx: NIC from which to remove the filter
+ * @priority: Priority of filter, as passed to @ef4_filter_insert_filter
+ * @filter_id: ID of filter, as returned by @ef4_filter_insert_filter
+ * @spec: Buffer in which to store filter specification
+ *
+ * This function will range-check @filter_id, so it is safe to call
+ * with a value passed from userland.
+ */
+static inline int
+ef4_filter_get_filter_safe(struct ef4_nic *efx,
+			   enum ef4_filter_priority priority,
+			   u32 filter_id, struct ef4_filter_spec *spec)
+{
+	return efx->type->filter_get_safe(efx, priority, filter_id, spec);
+}
+
+static inline u32 ef4_filter_count_rx_used(struct ef4_nic *efx,
+					   enum ef4_filter_priority priority)
+{
+	return efx->type->filter_count_rx_used(efx, priority);
+}
+static inline u32 ef4_filter_get_rx_id_limit(struct ef4_nic *efx)
+{
+	return efx->type->filter_get_rx_id_limit(efx);
+}
+static inline s32 ef4_filter_get_rx_ids(struct ef4_nic *efx,
+					enum ef4_filter_priority priority,
+					u32 *buf, u32 size)
+{
+	return efx->type->filter_get_rx_ids(efx, priority, buf, size);
+}
+#ifdef CONFIG_RFS_ACCEL
+int ef4_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+		   u16 rxq_index, u32 flow_id);
+bool __ef4_filter_rfs_expire(struct ef4_nic *efx, unsigned quota);
+static inline void ef4_filter_rfs_expire(struct ef4_channel *channel)
+{
+	if (channel->rfs_filters_added >= 60 &&
+	    __ef4_filter_rfs_expire(channel->efx, 100))
+		channel->rfs_filters_added -= 60;
+}
+#define ef4_filter_rfs_enabled() 1
+#else
+static inline void ef4_filter_rfs_expire(struct ef4_channel *channel) {}
+#define ef4_filter_rfs_enabled() 0
+#endif
+bool ef4_filter_is_mc_recipient(const struct ef4_filter_spec *spec);
+
+/* Channels */
+int ef4_channel_dummy_op_int(struct ef4_channel *channel);
+void ef4_channel_dummy_op_void(struct ef4_channel *channel);
+int ef4_realloc_channels(struct ef4_nic *efx, u32 rxq_entries, u32 txq_entries);
+
+/* Ports */
+int ef4_reconfigure_port(struct ef4_nic *efx);
+int __ef4_reconfigure_port(struct ef4_nic *efx);
+
+/* Ethtool support */
+extern const struct ethtool_ops ef4_ethtool_ops;
+
+/* Reset handling */
+int ef4_reset(struct ef4_nic *efx, enum reset_type method);
+void ef4_reset_down(struct ef4_nic *efx, enum reset_type method);
+int ef4_reset_up(struct ef4_nic *efx, enum reset_type method, bool ok);
+int ef4_try_recovery(struct ef4_nic *efx);
+
+/* Global */
+void ef4_schedule_reset(struct ef4_nic *efx, enum reset_type type);
+unsigned int ef4_usecs_to_ticks(struct ef4_nic *efx, unsigned int usecs);
+unsigned int ef4_ticks_to_usecs(struct ef4_nic *efx, unsigned int ticks);
+int ef4_init_irq_moderation(struct ef4_nic *efx, unsigned int tx_usecs,
+			    unsigned int rx_usecs, bool rx_adaptive,
+			    bool rx_may_override_tx);
+void ef4_get_irq_moderation(struct ef4_nic *efx, unsigned int *tx_usecs,
+			    unsigned int *rx_usecs, bool *rx_adaptive);
+void ef4_stop_eventq(struct ef4_channel *channel);
+void ef4_start_eventq(struct ef4_channel *channel);
+
+/* Dummy PHY ops for PHY drivers */
+int ef4_port_dummy_op_int(struct ef4_nic *efx);
+void ef4_port_dummy_op_void(struct ef4_nic *efx);
+
+/* Update the generic software stats in the passed stats array */
+void ef4_update_sw_stats(struct ef4_nic *efx, u64 *stats);
+
+/* MTD */
+#ifdef CONFIG_SFC_FALCON_MTD
+int ef4_mtd_add(struct ef4_nic *efx, struct ef4_mtd_partition *parts,
+		size_t n_parts, size_t sizeof_part);
+static inline int ef4_mtd_probe(struct ef4_nic *efx)
+{
+	return efx->type->mtd_probe(efx);
+}
+void ef4_mtd_rename(struct ef4_nic *efx);
+void ef4_mtd_remove(struct ef4_nic *efx);
+#else
+static inline int ef4_mtd_probe(struct ef4_nic *efx) { return 0; }
+static inline void ef4_mtd_rename(struct ef4_nic *efx) {}
+static inline void ef4_mtd_remove(struct ef4_nic *efx) {}
+#endif
+
+static inline void ef4_schedule_channel(struct ef4_channel *channel)
+{
+	netif_vdbg(channel->efx, intr, channel->efx->net_dev,
+		   "channel %d scheduling NAPI poll on CPU%d\n",
+		   channel->channel, raw_smp_processor_id());
+
+	napi_schedule(&channel->napi_str);
+}
+
+static inline void ef4_schedule_channel_irq(struct ef4_channel *channel)
+{
+	channel->event_test_cpu = raw_smp_processor_id();
+	ef4_schedule_channel(channel);
+}
+
+void ef4_link_status_changed(struct ef4_nic *efx);
+void ef4_link_set_advertising(struct ef4_nic *efx, u32);
+void ef4_link_set_wanted_fc(struct ef4_nic *efx, u8);
+
+static inline void ef4_device_detach_sync(struct ef4_nic *efx)
+{
+	struct net_device *dev = efx->net_dev;
+
+	/* Lock/freeze all TX queues so that we can be sure the
+	 * TX scheduler is stopped when we're done and before
+	 * netif_device_present() becomes false.
+	 */
+	netif_tx_lock_bh(dev);
+	netif_device_detach(dev);
+	netif_tx_unlock_bh(dev);
+}
+
+static inline bool ef4_rwsem_assert_write_locked(struct rw_semaphore *sem)
+{
+	if (WARN_ON(down_read_trylock(sem))) {
+		up_read(sem);
+		return false;
+	}
+	return true;
+}
+
+#endif /* EF4_EFX_H */
diff --git a/drivers/net/ethernet/sfc/falcon/enum.h b/drivers/net/ethernet/sfc/falcon/enum.h
new file mode 100644
index 0000000..30a1136
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/enum.h
@@ -0,0 +1,171 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2007-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_ENUM_H
+#define EF4_ENUM_H
+
+/**
+ * enum ef4_loopback_mode - loopback modes
+ * @LOOPBACK_NONE: no loopback
+ * @LOOPBACK_DATA: data path loopback
+ * @LOOPBACK_GMAC: loopback within GMAC
+ * @LOOPBACK_XGMII: loopback after XMAC
+ * @LOOPBACK_XGXS: loopback within BPX after XGXS
+ * @LOOPBACK_XAUI: loopback within BPX before XAUI serdes
+ * @LOOPBACK_GMII: loopback within BPX after GMAC
+ * @LOOPBACK_SGMII: loopback within BPX within SGMII
+ * @LOOPBACK_XGBR: loopback within BPX within XGBR
+ * @LOOPBACK_XFI: loopback within BPX before XFI serdes
+ * @LOOPBACK_XAUI_FAR: loopback within BPX after XAUI serdes
+ * @LOOPBACK_GMII_FAR: loopback within BPX before SGMII
+ * @LOOPBACK_SGMII_FAR: loopback within BPX after SGMII
+ * @LOOPBACK_XFI_FAR: loopback after XFI serdes
+ * @LOOPBACK_GPHY: loopback within 1G PHY at unspecified level
+ * @LOOPBACK_PHYXS: loopback within 10G PHY at PHYXS level
+ * @LOOPBACK_PCS: loopback within 10G PHY at PCS level
+ * @LOOPBACK_PMAPMD: loopback within 10G PHY at PMAPMD level
+ * @LOOPBACK_XPORT: cross port loopback
+ * @LOOPBACK_XGMII_WS: wireside loopback excluding XMAC
+ * @LOOPBACK_XAUI_WS: wireside loopback within BPX within XAUI serdes
+ * @LOOPBACK_XAUI_WS_FAR: wireside loopback within BPX including XAUI serdes
+ * @LOOPBACK_XAUI_WS_NEAR: wireside loopback within BPX excluding XAUI serdes
+ * @LOOPBACK_GMII_WS: wireside loopback excluding GMAC
+ * @LOOPBACK_XFI_WS: wireside loopback excluding XFI serdes
+ * @LOOPBACK_XFI_WS_FAR: wireside loopback including XFI serdes
+ * @LOOPBACK_PHYXS_WS: wireside loopback within 10G PHY at PHYXS level
+ */
+/* Please keep up-to-date w.r.t the following two #defines */
+enum ef4_loopback_mode {
+	LOOPBACK_NONE = 0,
+	LOOPBACK_DATA = 1,
+	LOOPBACK_GMAC = 2,
+	LOOPBACK_XGMII = 3,
+	LOOPBACK_XGXS = 4,
+	LOOPBACK_XAUI = 5,
+	LOOPBACK_GMII = 6,
+	LOOPBACK_SGMII = 7,
+	LOOPBACK_XGBR = 8,
+	LOOPBACK_XFI = 9,
+	LOOPBACK_XAUI_FAR = 10,
+	LOOPBACK_GMII_FAR = 11,
+	LOOPBACK_SGMII_FAR = 12,
+	LOOPBACK_XFI_FAR = 13,
+	LOOPBACK_GPHY = 14,
+	LOOPBACK_PHYXS = 15,
+	LOOPBACK_PCS = 16,
+	LOOPBACK_PMAPMD = 17,
+	LOOPBACK_XPORT = 18,
+	LOOPBACK_XGMII_WS = 19,
+	LOOPBACK_XAUI_WS = 20,
+	LOOPBACK_XAUI_WS_FAR = 21,
+	LOOPBACK_XAUI_WS_NEAR = 22,
+	LOOPBACK_GMII_WS = 23,
+	LOOPBACK_XFI_WS = 24,
+	LOOPBACK_XFI_WS_FAR = 25,
+	LOOPBACK_PHYXS_WS = 26,
+	LOOPBACK_MAX
+};
+#define LOOPBACK_TEST_MAX LOOPBACK_PMAPMD
+
+/* These loopbacks occur within the controller */
+#define LOOPBACKS_INTERNAL ((1 << LOOPBACK_DATA) |		\
+			    (1 << LOOPBACK_GMAC) |		\
+			    (1 << LOOPBACK_XGMII)|		\
+			    (1 << LOOPBACK_XGXS) |		\
+			    (1 << LOOPBACK_XAUI) |		\
+			    (1 << LOOPBACK_GMII) |		\
+			    (1 << LOOPBACK_SGMII) |		\
+			    (1 << LOOPBACK_SGMII) |		\
+			    (1 << LOOPBACK_XGBR) |		\
+			    (1 << LOOPBACK_XFI) |		\
+			    (1 << LOOPBACK_XAUI_FAR) |		\
+			    (1 << LOOPBACK_GMII_FAR) |		\
+			    (1 << LOOPBACK_SGMII_FAR) |		\
+			    (1 << LOOPBACK_XFI_FAR) |		\
+			    (1 << LOOPBACK_XGMII_WS) |		\
+			    (1 << LOOPBACK_XAUI_WS) |		\
+			    (1 << LOOPBACK_XAUI_WS_FAR) |	\
+			    (1 << LOOPBACK_XAUI_WS_NEAR) |	\
+			    (1 << LOOPBACK_GMII_WS) |		\
+			    (1 << LOOPBACK_XFI_WS) |		\
+			    (1 << LOOPBACK_XFI_WS_FAR))
+
+#define LOOPBACKS_WS ((1 << LOOPBACK_XGMII_WS) |		\
+		      (1 << LOOPBACK_XAUI_WS) |			\
+		      (1 << LOOPBACK_XAUI_WS_FAR) |		\
+		      (1 << LOOPBACK_XAUI_WS_NEAR) |		\
+		      (1 << LOOPBACK_GMII_WS) |			\
+		      (1 << LOOPBACK_XFI_WS) |			\
+		      (1 << LOOPBACK_XFI_WS_FAR) |		\
+		      (1 << LOOPBACK_PHYXS_WS))
+
+#define LOOPBACKS_EXTERNAL(_efx)					\
+	((_efx)->loopback_modes & ~LOOPBACKS_INTERNAL &			\
+	 ~(1 << LOOPBACK_NONE))
+
+#define LOOPBACK_MASK(_efx)			\
+	(1 << (_efx)->loopback_mode)
+
+#define LOOPBACK_INTERNAL(_efx)				\
+	(!!(LOOPBACKS_INTERNAL & LOOPBACK_MASK(_efx)))
+
+#define LOOPBACK_EXTERNAL(_efx)				\
+	(!!(LOOPBACK_MASK(_efx) & LOOPBACKS_EXTERNAL(_efx)))
+
+#define LOOPBACK_CHANGED(_from, _to, _mask)				\
+	(!!((LOOPBACK_MASK(_from) ^ LOOPBACK_MASK(_to)) & (_mask)))
+
+#define LOOPBACK_OUT_OF(_from, _to, _mask)				\
+	((LOOPBACK_MASK(_from) & (_mask)) && !(LOOPBACK_MASK(_to) & (_mask)))
+
+/*****************************************************************************/
+
+/**
+ * enum reset_type - reset types
+ *
+ * %RESET_TYPE_INVSIBLE, %RESET_TYPE_ALL, %RESET_TYPE_WORLD and
+ * %RESET_TYPE_DISABLE specify the method/scope of the reset.  The
+ * other valuesspecify reasons, which ef4_schedule_reset() will choose
+ * a method for.
+ *
+ * Reset methods are numbered in order of increasing scope.
+ *
+ * @RESET_TYPE_INVISIBLE: Reset datapath and MAC
+ * @RESET_TYPE_RECOVER_OR_ALL: Try to recover. Apply RESET_TYPE_ALL
+ * if unsuccessful.
+ * @RESET_TYPE_ALL: Reset datapath, MAC and PHY
+ * @RESET_TYPE_WORLD: Reset as much as possible
+ * @RESET_TYPE_RECOVER_OR_DISABLE: Try to recover. Apply RESET_TYPE_DISABLE if
+ * unsuccessful.
+ * @RESET_TYPE_DATAPATH: Reset datapath only.
+ * @RESET_TYPE_DISABLE: Reset datapath, MAC and PHY; leave NIC disabled
+ * @RESET_TYPE_TX_WATCHDOG: reset due to TX watchdog
+ * @RESET_TYPE_INT_ERROR: reset due to internal error
+ * @RESET_TYPE_RX_RECOVERY: reset to recover from RX datapath errors
+ * @RESET_TYPE_DMA_ERROR: DMA error
+ * @RESET_TYPE_TX_SKIP: hardware completed empty tx descriptors
+ */
+enum reset_type {
+	RESET_TYPE_INVISIBLE,
+	RESET_TYPE_RECOVER_OR_ALL,
+	RESET_TYPE_ALL,
+	RESET_TYPE_WORLD,
+	RESET_TYPE_RECOVER_OR_DISABLE,
+	RESET_TYPE_DATAPATH,
+	RESET_TYPE_DISABLE,
+	RESET_TYPE_MAX_METHOD,
+	RESET_TYPE_TX_WATCHDOG,
+	RESET_TYPE_INT_ERROR,
+	RESET_TYPE_RX_RECOVERY,
+	RESET_TYPE_DMA_ERROR,
+	RESET_TYPE_TX_SKIP,
+	RESET_TYPE_MAX,
+};
+
+#endif /* EF4_ENUM_H */
diff --git a/drivers/net/ethernet/sfc/falcon/ethtool.c b/drivers/net/ethernet/sfc/falcon/ethtool.c
new file mode 100644
index 0000000..8e1929b
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/ethtool.c
@@ -0,0 +1,1343 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/rtnetlink.h>
+#include <linux/in.h>
+#include "net_driver.h"
+#include "workarounds.h"
+#include "selftest.h"
+#include "efx.h"
+#include "filter.h"
+#include "nic.h"
+
+struct ef4_sw_stat_desc {
+	const char *name;
+	enum {
+		EF4_ETHTOOL_STAT_SOURCE_nic,
+		EF4_ETHTOOL_STAT_SOURCE_channel,
+		EF4_ETHTOOL_STAT_SOURCE_tx_queue
+	} source;
+	unsigned offset;
+	u64(*get_stat) (void *field); /* Reader function */
+};
+
+/* Initialiser for a struct ef4_sw_stat_desc with type-checking */
+#define EF4_ETHTOOL_STAT(stat_name, source_name, field, field_type, \
+				get_stat_function) {			\
+	.name = #stat_name,						\
+	.source = EF4_ETHTOOL_STAT_SOURCE_##source_name,		\
+	.offset = ((((field_type *) 0) ==				\
+		      &((struct ef4_##source_name *)0)->field) ?	\
+		    offsetof(struct ef4_##source_name, field) :		\
+		    offsetof(struct ef4_##source_name, field)),		\
+	.get_stat = get_stat_function,					\
+}
+
+static u64 ef4_get_uint_stat(void *field)
+{
+	return *(unsigned int *)field;
+}
+
+static u64 ef4_get_atomic_stat(void *field)
+{
+	return atomic_read((atomic_t *) field);
+}
+
+#define EF4_ETHTOOL_ATOMIC_NIC_ERROR_STAT(field)		\
+	EF4_ETHTOOL_STAT(field, nic, field,			\
+			 atomic_t, ef4_get_atomic_stat)
+
+#define EF4_ETHTOOL_UINT_CHANNEL_STAT(field)			\
+	EF4_ETHTOOL_STAT(field, channel, n_##field,		\
+			 unsigned int, ef4_get_uint_stat)
+
+#define EF4_ETHTOOL_UINT_TXQ_STAT(field)			\
+	EF4_ETHTOOL_STAT(tx_##field, tx_queue, field,		\
+			 unsigned int, ef4_get_uint_stat)
+
+static const struct ef4_sw_stat_desc ef4_sw_stat_desc[] = {
+	EF4_ETHTOOL_UINT_TXQ_STAT(merge_events),
+	EF4_ETHTOOL_UINT_TXQ_STAT(pushes),
+	EF4_ETHTOOL_UINT_TXQ_STAT(cb_packets),
+	EF4_ETHTOOL_ATOMIC_NIC_ERROR_STAT(rx_reset),
+	EF4_ETHTOOL_UINT_CHANNEL_STAT(rx_tobe_disc),
+	EF4_ETHTOOL_UINT_CHANNEL_STAT(rx_ip_hdr_chksum_err),
+	EF4_ETHTOOL_UINT_CHANNEL_STAT(rx_tcp_udp_chksum_err),
+	EF4_ETHTOOL_UINT_CHANNEL_STAT(rx_mcast_mismatch),
+	EF4_ETHTOOL_UINT_CHANNEL_STAT(rx_frm_trunc),
+	EF4_ETHTOOL_UINT_CHANNEL_STAT(rx_merge_events),
+	EF4_ETHTOOL_UINT_CHANNEL_STAT(rx_merge_packets),
+};
+
+#define EF4_ETHTOOL_SW_STAT_COUNT ARRAY_SIZE(ef4_sw_stat_desc)
+
+#define EF4_ETHTOOL_EEPROM_MAGIC 0xEFAB
+
+/**************************************************************************
+ *
+ * Ethtool operations
+ *
+ **************************************************************************
+ */
+
+/* Identify device by flashing LEDs */
+static int ef4_ethtool_phys_id(struct net_device *net_dev,
+			       enum ethtool_phys_id_state state)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	enum ef4_led_mode mode = EF4_LED_DEFAULT;
+
+	switch (state) {
+	case ETHTOOL_ID_ON:
+		mode = EF4_LED_ON;
+		break;
+	case ETHTOOL_ID_OFF:
+		mode = EF4_LED_OFF;
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		mode = EF4_LED_DEFAULT;
+		break;
+	case ETHTOOL_ID_ACTIVE:
+		return 1;	/* cycle on/off once per second */
+	}
+
+	efx->type->set_id_led(efx, mode);
+	return 0;
+}
+
+/* This must be called with rtnl_lock held. */
+static int ef4_ethtool_get_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct ef4_link_state *link_state = &efx->link_state;
+
+	mutex_lock(&efx->mac_lock);
+	efx->phy_op->get_settings(efx, ecmd);
+	mutex_unlock(&efx->mac_lock);
+
+	/* Both MACs support pause frames (bidirectional and respond-only) */
+	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+
+	if (LOOPBACK_INTERNAL(efx)) {
+		ethtool_cmd_speed_set(ecmd, link_state->speed);
+		ecmd->duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
+	}
+
+	return 0;
+}
+
+/* This must be called with rtnl_lock held. */
+static int ef4_ethtool_set_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int rc;
+
+	/* GMAC does not support 1000Mbps HD */
+	if ((ethtool_cmd_speed(ecmd) == SPEED_1000) &&
+	    (ecmd->duplex != DUPLEX_FULL)) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "rejecting unsupported 1000Mbps HD setting\n");
+		return -EINVAL;
+	}
+
+	mutex_lock(&efx->mac_lock);
+	rc = efx->phy_op->set_settings(efx, ecmd);
+	mutex_unlock(&efx->mac_lock);
+	return rc;
+}
+
+static void ef4_ethtool_get_drvinfo(struct net_device *net_dev,
+				    struct ethtool_drvinfo *info)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
+	strlcpy(info->version, EF4_DRIVER_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
+}
+
+static int ef4_ethtool_get_regs_len(struct net_device *net_dev)
+{
+	return ef4_nic_get_regs_len(netdev_priv(net_dev));
+}
+
+static void ef4_ethtool_get_regs(struct net_device *net_dev,
+				 struct ethtool_regs *regs, void *buf)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	regs->version = efx->type->revision;
+	ef4_nic_get_regs(efx, buf);
+}
+
+static u32 ef4_ethtool_get_msglevel(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	return efx->msg_enable;
+}
+
+static void ef4_ethtool_set_msglevel(struct net_device *net_dev, u32 msg_enable)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	efx->msg_enable = msg_enable;
+}
+
+/**
+ * ef4_fill_test - fill in an individual self-test entry
+ * @test_index:		Index of the test
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ * @test:		Pointer to test result (used only if data != %NULL)
+ * @unit_format:	Unit name format (e.g. "chan\%d")
+ * @unit_id:		Unit id (e.g. 0 for "chan0")
+ * @test_format:	Test name format (e.g. "loopback.\%s.tx.sent")
+ * @test_id:		Test id (e.g. "PHYXS" for "loopback.PHYXS.tx_sent")
+ *
+ * Fill in an individual self-test entry.
+ */
+static void ef4_fill_test(unsigned int test_index, u8 *strings, u64 *data,
+			  int *test, const char *unit_format, int unit_id,
+			  const char *test_format, const char *test_id)
+{
+	char unit_str[ETH_GSTRING_LEN], test_str[ETH_GSTRING_LEN];
+
+	/* Fill data value, if applicable */
+	if (data)
+		data[test_index] = *test;
+
+	/* Fill string, if applicable */
+	if (strings) {
+		if (strchr(unit_format, '%'))
+			snprintf(unit_str, sizeof(unit_str),
+				 unit_format, unit_id);
+		else
+			strcpy(unit_str, unit_format);
+		snprintf(test_str, sizeof(test_str), test_format, test_id);
+		snprintf(strings + test_index * ETH_GSTRING_LEN,
+			 ETH_GSTRING_LEN,
+			 "%-6s %-24s", unit_str, test_str);
+	}
+}
+
+#define EF4_CHANNEL_NAME(_channel) "chan%d", _channel->channel
+#define EF4_TX_QUEUE_NAME(_tx_queue) "txq%d", _tx_queue->queue
+#define EF4_RX_QUEUE_NAME(_rx_queue) "rxq%d", _rx_queue->queue
+#define EF4_LOOPBACK_NAME(_mode, _counter)			\
+	"loopback.%s." _counter, STRING_TABLE_LOOKUP(_mode, ef4_loopback_mode)
+
+/**
+ * ef4_fill_loopback_test - fill in a block of loopback self-test entries
+ * @efx:		Efx NIC
+ * @lb_tests:		Efx loopback self-test results structure
+ * @mode:		Loopback test mode
+ * @test_index:		Starting index of the test
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ *
+ * Fill in a block of loopback self-test entries.  Return new test
+ * index.
+ */
+static int ef4_fill_loopback_test(struct ef4_nic *efx,
+				  struct ef4_loopback_self_tests *lb_tests,
+				  enum ef4_loopback_mode mode,
+				  unsigned int test_index,
+				  u8 *strings, u64 *data)
+{
+	struct ef4_channel *channel =
+		ef4_get_channel(efx, efx->tx_channel_offset);
+	struct ef4_tx_queue *tx_queue;
+
+	ef4_for_each_channel_tx_queue(tx_queue, channel) {
+		ef4_fill_test(test_index++, strings, data,
+			      &lb_tests->tx_sent[tx_queue->queue],
+			      EF4_TX_QUEUE_NAME(tx_queue),
+			      EF4_LOOPBACK_NAME(mode, "tx_sent"));
+		ef4_fill_test(test_index++, strings, data,
+			      &lb_tests->tx_done[tx_queue->queue],
+			      EF4_TX_QUEUE_NAME(tx_queue),
+			      EF4_LOOPBACK_NAME(mode, "tx_done"));
+	}
+	ef4_fill_test(test_index++, strings, data,
+		      &lb_tests->rx_good,
+		      "rx", 0,
+		      EF4_LOOPBACK_NAME(mode, "rx_good"));
+	ef4_fill_test(test_index++, strings, data,
+		      &lb_tests->rx_bad,
+		      "rx", 0,
+		      EF4_LOOPBACK_NAME(mode, "rx_bad"));
+
+	return test_index;
+}
+
+/**
+ * ef4_ethtool_fill_self_tests - get self-test details
+ * @efx:		Efx NIC
+ * @tests:		Efx self-test results structure, or %NULL
+ * @strings:		Ethtool strings, or %NULL
+ * @data:		Ethtool test results, or %NULL
+ *
+ * Get self-test number of strings, strings, and/or test results.
+ * Return number of strings (== number of test results).
+ *
+ * The reason for merging these three functions is to make sure that
+ * they can never be inconsistent.
+ */
+static int ef4_ethtool_fill_self_tests(struct ef4_nic *efx,
+				       struct ef4_self_tests *tests,
+				       u8 *strings, u64 *data)
+{
+	struct ef4_channel *channel;
+	unsigned int n = 0, i;
+	enum ef4_loopback_mode mode;
+
+	ef4_fill_test(n++, strings, data, &tests->phy_alive,
+		      "phy", 0, "alive", NULL);
+	ef4_fill_test(n++, strings, data, &tests->nvram,
+		      "core", 0, "nvram", NULL);
+	ef4_fill_test(n++, strings, data, &tests->interrupt,
+		      "core", 0, "interrupt", NULL);
+
+	/* Event queues */
+	ef4_for_each_channel(channel, efx) {
+		ef4_fill_test(n++, strings, data,
+			      &tests->eventq_dma[channel->channel],
+			      EF4_CHANNEL_NAME(channel),
+			      "eventq.dma", NULL);
+		ef4_fill_test(n++, strings, data,
+			      &tests->eventq_int[channel->channel],
+			      EF4_CHANNEL_NAME(channel),
+			      "eventq.int", NULL);
+	}
+
+	ef4_fill_test(n++, strings, data, &tests->memory,
+		      "core", 0, "memory", NULL);
+	ef4_fill_test(n++, strings, data, &tests->registers,
+		      "core", 0, "registers", NULL);
+
+	if (efx->phy_op->run_tests != NULL) {
+		EF4_BUG_ON_PARANOID(efx->phy_op->test_name == NULL);
+
+		for (i = 0; true; ++i) {
+			const char *name;
+
+			EF4_BUG_ON_PARANOID(i >= EF4_MAX_PHY_TESTS);
+			name = efx->phy_op->test_name(efx, i);
+			if (name == NULL)
+				break;
+
+			ef4_fill_test(n++, strings, data, &tests->phy_ext[i],
+				      "phy", 0, name, NULL);
+		}
+	}
+
+	/* Loopback tests */
+	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
+		if (!(efx->loopback_modes & (1 << mode)))
+			continue;
+		n = ef4_fill_loopback_test(efx,
+					   &tests->loopback[mode], mode, n,
+					   strings, data);
+	}
+
+	return n;
+}
+
+static size_t ef4_describe_per_queue_stats(struct ef4_nic *efx, u8 *strings)
+{
+	size_t n_stats = 0;
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx) {
+		if (ef4_channel_has_tx_queues(channel)) {
+			n_stats++;
+			if (strings != NULL) {
+				snprintf(strings, ETH_GSTRING_LEN,
+					 "tx-%u.tx_packets",
+					 channel->tx_queue[0].queue /
+					 EF4_TXQ_TYPES);
+
+				strings += ETH_GSTRING_LEN;
+			}
+		}
+	}
+	ef4_for_each_channel(channel, efx) {
+		if (ef4_channel_has_rx_queue(channel)) {
+			n_stats++;
+			if (strings != NULL) {
+				snprintf(strings, ETH_GSTRING_LEN,
+					 "rx-%d.rx_packets", channel->channel);
+				strings += ETH_GSTRING_LEN;
+			}
+		}
+	}
+	return n_stats;
+}
+
+static int ef4_ethtool_get_sset_count(struct net_device *net_dev,
+				      int string_set)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return efx->type->describe_stats(efx, NULL) +
+		       EF4_ETHTOOL_SW_STAT_COUNT +
+		       ef4_describe_per_queue_stats(efx, NULL);
+	case ETH_SS_TEST:
+		return ef4_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
+	default:
+		return -EINVAL;
+	}
+}
+
+static void ef4_ethtool_get_strings(struct net_device *net_dev,
+				    u32 string_set, u8 *strings)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int i;
+
+	switch (string_set) {
+	case ETH_SS_STATS:
+		strings += (efx->type->describe_stats(efx, strings) *
+			    ETH_GSTRING_LEN);
+		for (i = 0; i < EF4_ETHTOOL_SW_STAT_COUNT; i++)
+			strlcpy(strings + i * ETH_GSTRING_LEN,
+				ef4_sw_stat_desc[i].name, ETH_GSTRING_LEN);
+		strings += EF4_ETHTOOL_SW_STAT_COUNT * ETH_GSTRING_LEN;
+		strings += (ef4_describe_per_queue_stats(efx, strings) *
+			    ETH_GSTRING_LEN);
+		break;
+	case ETH_SS_TEST:
+		ef4_ethtool_fill_self_tests(efx, NULL, strings, NULL);
+		break;
+	default:
+		/* No other string sets */
+		break;
+	}
+}
+
+static void ef4_ethtool_get_stats(struct net_device *net_dev,
+				  struct ethtool_stats *stats,
+				  u64 *data)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	const struct ef4_sw_stat_desc *stat;
+	struct ef4_channel *channel;
+	struct ef4_tx_queue *tx_queue;
+	struct ef4_rx_queue *rx_queue;
+	int i;
+
+	spin_lock_bh(&efx->stats_lock);
+
+	/* Get NIC statistics */
+	data += efx->type->update_stats(efx, data, NULL);
+
+	/* Get software statistics */
+	for (i = 0; i < EF4_ETHTOOL_SW_STAT_COUNT; i++) {
+		stat = &ef4_sw_stat_desc[i];
+		switch (stat->source) {
+		case EF4_ETHTOOL_STAT_SOURCE_nic:
+			data[i] = stat->get_stat((void *)efx + stat->offset);
+			break;
+		case EF4_ETHTOOL_STAT_SOURCE_channel:
+			data[i] = 0;
+			ef4_for_each_channel(channel, efx)
+				data[i] += stat->get_stat((void *)channel +
+							  stat->offset);
+			break;
+		case EF4_ETHTOOL_STAT_SOURCE_tx_queue:
+			data[i] = 0;
+			ef4_for_each_channel(channel, efx) {
+				ef4_for_each_channel_tx_queue(tx_queue, channel)
+					data[i] +=
+						stat->get_stat((void *)tx_queue
+							       + stat->offset);
+			}
+			break;
+		}
+	}
+	data += EF4_ETHTOOL_SW_STAT_COUNT;
+
+	spin_unlock_bh(&efx->stats_lock);
+
+	ef4_for_each_channel(channel, efx) {
+		if (ef4_channel_has_tx_queues(channel)) {
+			*data = 0;
+			ef4_for_each_channel_tx_queue(tx_queue, channel) {
+				*data += tx_queue->tx_packets;
+			}
+			data++;
+		}
+	}
+	ef4_for_each_channel(channel, efx) {
+		if (ef4_channel_has_rx_queue(channel)) {
+			*data = 0;
+			ef4_for_each_channel_rx_queue(rx_queue, channel) {
+				*data += rx_queue->rx_packets;
+			}
+			data++;
+		}
+	}
+}
+
+static void ef4_ethtool_self_test(struct net_device *net_dev,
+				  struct ethtool_test *test, u64 *data)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct ef4_self_tests *ef4_tests;
+	bool already_up;
+	int rc = -ENOMEM;
+
+	ef4_tests = kzalloc(sizeof(*ef4_tests), GFP_KERNEL);
+	if (!ef4_tests)
+		goto fail;
+
+	if (efx->state != STATE_READY) {
+		rc = -EBUSY;
+		goto out;
+	}
+
+	netif_info(efx, drv, efx->net_dev, "starting %sline testing\n",
+		   (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
+
+	/* We need rx buffers and interrupts. */
+	already_up = (efx->net_dev->flags & IFF_UP);
+	if (!already_up) {
+		rc = dev_open(efx->net_dev);
+		if (rc) {
+			netif_err(efx, drv, efx->net_dev,
+				  "failed opening device.\n");
+			goto out;
+		}
+	}
+
+	rc = ef4_selftest(efx, ef4_tests, test->flags);
+
+	if (!already_up)
+		dev_close(efx->net_dev);
+
+	netif_info(efx, drv, efx->net_dev, "%s %sline self-tests\n",
+		   rc == 0 ? "passed" : "failed",
+		   (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
+
+out:
+	ef4_ethtool_fill_self_tests(efx, ef4_tests, NULL, data);
+	kfree(ef4_tests);
+fail:
+	if (rc)
+		test->flags |= ETH_TEST_FL_FAILED;
+}
+
+/* Restart autonegotiation */
+static int ef4_ethtool_nway_reset(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	return mdio45_nway_restart(&efx->mdio);
+}
+
+/*
+ * Each channel has a single IRQ and moderation timer, started by any
+ * completion (or other event).  Unless the module parameter
+ * separate_tx_channels is set, IRQs and moderation are therefore
+ * shared between RX and TX completions.  In this case, when RX IRQ
+ * moderation is explicitly changed then TX IRQ moderation is
+ * automatically changed too, but otherwise we fail if the two values
+ * are requested to be different.
+ *
+ * The hardware does not support a limit on the number of completions
+ * before an IRQ, so we do not use the max_frames fields.  We should
+ * report and require that max_frames == (usecs != 0), but this would
+ * invalidate existing user documentation.
+ *
+ * The hardware does not have distinct settings for interrupt
+ * moderation while the previous IRQ is being handled, so we should
+ * not use the 'irq' fields.  However, an earlier developer
+ * misunderstood the meaning of the 'irq' fields and the driver did
+ * not support the standard fields.  To avoid invalidating existing
+ * user documentation, we report and accept changes through either the
+ * standard or 'irq' fields.  If both are changed at the same time, we
+ * prefer the standard field.
+ *
+ * We implement adaptive IRQ moderation, but use a different algorithm
+ * from that assumed in the definition of struct ethtool_coalesce.
+ * Therefore we do not use any of the adaptive moderation parameters
+ * in it.
+ */
+
+static int ef4_ethtool_get_coalesce(struct net_device *net_dev,
+				    struct ethtool_coalesce *coalesce)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	unsigned int tx_usecs, rx_usecs;
+	bool rx_adaptive;
+
+	ef4_get_irq_moderation(efx, &tx_usecs, &rx_usecs, &rx_adaptive);
+
+	coalesce->tx_coalesce_usecs = tx_usecs;
+	coalesce->tx_coalesce_usecs_irq = tx_usecs;
+	coalesce->rx_coalesce_usecs = rx_usecs;
+	coalesce->rx_coalesce_usecs_irq = rx_usecs;
+	coalesce->use_adaptive_rx_coalesce = rx_adaptive;
+
+	return 0;
+}
+
+static int ef4_ethtool_set_coalesce(struct net_device *net_dev,
+				    struct ethtool_coalesce *coalesce)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct ef4_channel *channel;
+	unsigned int tx_usecs, rx_usecs;
+	bool adaptive, rx_may_override_tx;
+	int rc;
+
+	if (coalesce->use_adaptive_tx_coalesce)
+		return -EINVAL;
+
+	ef4_get_irq_moderation(efx, &tx_usecs, &rx_usecs, &adaptive);
+
+	if (coalesce->rx_coalesce_usecs != rx_usecs)
+		rx_usecs = coalesce->rx_coalesce_usecs;
+	else
+		rx_usecs = coalesce->rx_coalesce_usecs_irq;
+
+	adaptive = coalesce->use_adaptive_rx_coalesce;
+
+	/* If channels are shared, TX IRQ moderation can be quietly
+	 * overridden unless it is changed from its old value.
+	 */
+	rx_may_override_tx = (coalesce->tx_coalesce_usecs == tx_usecs &&
+			      coalesce->tx_coalesce_usecs_irq == tx_usecs);
+	if (coalesce->tx_coalesce_usecs != tx_usecs)
+		tx_usecs = coalesce->tx_coalesce_usecs;
+	else
+		tx_usecs = coalesce->tx_coalesce_usecs_irq;
+
+	rc = ef4_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive,
+				     rx_may_override_tx);
+	if (rc != 0)
+		return rc;
+
+	ef4_for_each_channel(channel, efx)
+		efx->type->push_irq_moderation(channel);
+
+	return 0;
+}
+
+static void ef4_ethtool_get_ringparam(struct net_device *net_dev,
+				      struct ethtool_ringparam *ring)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	ring->rx_max_pending = EF4_MAX_DMAQ_SIZE;
+	ring->tx_max_pending = EF4_MAX_DMAQ_SIZE;
+	ring->rx_pending = efx->rxq_entries;
+	ring->tx_pending = efx->txq_entries;
+}
+
+static int ef4_ethtool_set_ringparam(struct net_device *net_dev,
+				     struct ethtool_ringparam *ring)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	u32 txq_entries;
+
+	if (ring->rx_mini_pending || ring->rx_jumbo_pending ||
+	    ring->rx_pending > EF4_MAX_DMAQ_SIZE ||
+	    ring->tx_pending > EF4_MAX_DMAQ_SIZE)
+		return -EINVAL;
+
+	if (ring->rx_pending < EF4_RXQ_MIN_ENT) {
+		netif_err(efx, drv, efx->net_dev,
+			  "RX queues cannot be smaller than %u\n",
+			  EF4_RXQ_MIN_ENT);
+		return -EINVAL;
+	}
+
+	txq_entries = max(ring->tx_pending, EF4_TXQ_MIN_ENT(efx));
+	if (txq_entries != ring->tx_pending)
+		netif_warn(efx, drv, efx->net_dev,
+			   "increasing TX queue size to minimum of %u\n",
+			   txq_entries);
+
+	return ef4_realloc_channels(efx, ring->rx_pending, txq_entries);
+}
+
+static int ef4_ethtool_set_pauseparam(struct net_device *net_dev,
+				      struct ethtool_pauseparam *pause)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	u8 wanted_fc, old_fc;
+	u32 old_adv;
+	int rc = 0;
+
+	mutex_lock(&efx->mac_lock);
+
+	wanted_fc = ((pause->rx_pause ? EF4_FC_RX : 0) |
+		     (pause->tx_pause ? EF4_FC_TX : 0) |
+		     (pause->autoneg ? EF4_FC_AUTO : 0));
+
+	if ((wanted_fc & EF4_FC_TX) && !(wanted_fc & EF4_FC_RX)) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Flow control unsupported: tx ON rx OFF\n");
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if ((wanted_fc & EF4_FC_AUTO) && !efx->link_advertising) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Autonegotiation is disabled\n");
+		rc = -EINVAL;
+		goto out;
+	}
+
+	/* Hook for Falcon bug 11482 workaround */
+	if (efx->type->prepare_enable_fc_tx &&
+	    (wanted_fc & EF4_FC_TX) && !(efx->wanted_fc & EF4_FC_TX))
+		efx->type->prepare_enable_fc_tx(efx);
+
+	old_adv = efx->link_advertising;
+	old_fc = efx->wanted_fc;
+	ef4_link_set_wanted_fc(efx, wanted_fc);
+	if (efx->link_advertising != old_adv ||
+	    (efx->wanted_fc ^ old_fc) & EF4_FC_AUTO) {
+		rc = efx->phy_op->reconfigure(efx);
+		if (rc) {
+			netif_err(efx, drv, efx->net_dev,
+				  "Unable to advertise requested flow "
+				  "control setting\n");
+			goto out;
+		}
+	}
+
+	/* Reconfigure the MAC. The PHY *may* generate a link state change event
+	 * if the user just changed the advertised capabilities, but there's no
+	 * harm doing this twice */
+	ef4_mac_reconfigure(efx);
+
+out:
+	mutex_unlock(&efx->mac_lock);
+
+	return rc;
+}
+
+static void ef4_ethtool_get_pauseparam(struct net_device *net_dev,
+				       struct ethtool_pauseparam *pause)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	pause->rx_pause = !!(efx->wanted_fc & EF4_FC_RX);
+	pause->tx_pause = !!(efx->wanted_fc & EF4_FC_TX);
+	pause->autoneg = !!(efx->wanted_fc & EF4_FC_AUTO);
+}
+
+static void ef4_ethtool_get_wol(struct net_device *net_dev,
+				struct ethtool_wolinfo *wol)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	return efx->type->get_wol(efx, wol);
+}
+
+
+static int ef4_ethtool_set_wol(struct net_device *net_dev,
+			       struct ethtool_wolinfo *wol)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	return efx->type->set_wol(efx, wol->wolopts);
+}
+
+static int ef4_ethtool_reset(struct net_device *net_dev, u32 *flags)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int rc;
+
+	rc = efx->type->map_reset_flags(flags);
+	if (rc < 0)
+		return rc;
+
+	return ef4_reset(efx, rc);
+}
+
+/* MAC address mask including only I/G bit */
+static const u8 mac_addr_ig_mask[ETH_ALEN] __aligned(2) = {0x01, 0, 0, 0, 0, 0};
+
+#define IP4_ADDR_FULL_MASK	((__force __be32)~0)
+#define IP_PROTO_FULL_MASK	0xFF
+#define PORT_FULL_MASK		((__force __be16)~0)
+#define ETHER_TYPE_FULL_MASK	((__force __be16)~0)
+
+static inline void ip6_fill_mask(__be32 *mask)
+{
+	mask[0] = mask[1] = mask[2] = mask[3] = ~(__be32)0;
+}
+
+static int ef4_ethtool_get_class_rule(struct ef4_nic *efx,
+				      struct ethtool_rx_flow_spec *rule)
+{
+	struct ethtool_tcpip4_spec *ip_entry = &rule->h_u.tcp_ip4_spec;
+	struct ethtool_tcpip4_spec *ip_mask = &rule->m_u.tcp_ip4_spec;
+	struct ethtool_usrip4_spec *uip_entry = &rule->h_u.usr_ip4_spec;
+	struct ethtool_usrip4_spec *uip_mask = &rule->m_u.usr_ip4_spec;
+	struct ethtool_tcpip6_spec *ip6_entry = &rule->h_u.tcp_ip6_spec;
+	struct ethtool_tcpip6_spec *ip6_mask = &rule->m_u.tcp_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_entry = &rule->h_u.usr_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_mask = &rule->m_u.usr_ip6_spec;
+	struct ethhdr *mac_entry = &rule->h_u.ether_spec;
+	struct ethhdr *mac_mask = &rule->m_u.ether_spec;
+	struct ef4_filter_spec spec;
+	int rc;
+
+	rc = ef4_filter_get_filter_safe(efx, EF4_FILTER_PRI_MANUAL,
+					rule->location, &spec);
+	if (rc)
+		return rc;
+
+	if (spec.dmaq_id == EF4_FILTER_RX_DMAQ_ID_DROP)
+		rule->ring_cookie = RX_CLS_FLOW_DISC;
+	else
+		rule->ring_cookie = spec.dmaq_id;
+
+	if ((spec.match_flags & EF4_FILTER_MATCH_ETHER_TYPE) &&
+	    spec.ether_type == htons(ETH_P_IP) &&
+	    (spec.match_flags & EF4_FILTER_MATCH_IP_PROTO) &&
+	    (spec.ip_proto == IPPROTO_TCP || spec.ip_proto == IPPROTO_UDP) &&
+	    !(spec.match_flags &
+	      ~(EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_OUTER_VID |
+		EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_REM_HOST |
+		EF4_FILTER_MATCH_IP_PROTO |
+		EF4_FILTER_MATCH_LOC_PORT | EF4_FILTER_MATCH_REM_PORT))) {
+		rule->flow_type = ((spec.ip_proto == IPPROTO_TCP) ?
+				   TCP_V4_FLOW : UDP_V4_FLOW);
+		if (spec.match_flags & EF4_FILTER_MATCH_LOC_HOST) {
+			ip_entry->ip4dst = spec.loc_host[0];
+			ip_mask->ip4dst = IP4_ADDR_FULL_MASK;
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_REM_HOST) {
+			ip_entry->ip4src = spec.rem_host[0];
+			ip_mask->ip4src = IP4_ADDR_FULL_MASK;
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_LOC_PORT) {
+			ip_entry->pdst = spec.loc_port;
+			ip_mask->pdst = PORT_FULL_MASK;
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_REM_PORT) {
+			ip_entry->psrc = spec.rem_port;
+			ip_mask->psrc = PORT_FULL_MASK;
+		}
+	} else if ((spec.match_flags & EF4_FILTER_MATCH_ETHER_TYPE) &&
+	    spec.ether_type == htons(ETH_P_IPV6) &&
+	    (spec.match_flags & EF4_FILTER_MATCH_IP_PROTO) &&
+	    (spec.ip_proto == IPPROTO_TCP || spec.ip_proto == IPPROTO_UDP) &&
+	    !(spec.match_flags &
+	      ~(EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_OUTER_VID |
+		EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_REM_HOST |
+		EF4_FILTER_MATCH_IP_PROTO |
+		EF4_FILTER_MATCH_LOC_PORT | EF4_FILTER_MATCH_REM_PORT))) {
+		rule->flow_type = ((spec.ip_proto == IPPROTO_TCP) ?
+				   TCP_V6_FLOW : UDP_V6_FLOW);
+		if (spec.match_flags & EF4_FILTER_MATCH_LOC_HOST) {
+			memcpy(ip6_entry->ip6dst, spec.loc_host,
+			       sizeof(ip6_entry->ip6dst));
+			ip6_fill_mask(ip6_mask->ip6dst);
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_REM_HOST) {
+			memcpy(ip6_entry->ip6src, spec.rem_host,
+			       sizeof(ip6_entry->ip6src));
+			ip6_fill_mask(ip6_mask->ip6src);
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_LOC_PORT) {
+			ip6_entry->pdst = spec.loc_port;
+			ip6_mask->pdst = PORT_FULL_MASK;
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_REM_PORT) {
+			ip6_entry->psrc = spec.rem_port;
+			ip6_mask->psrc = PORT_FULL_MASK;
+		}
+	} else if (!(spec.match_flags &
+		     ~(EF4_FILTER_MATCH_LOC_MAC | EF4_FILTER_MATCH_LOC_MAC_IG |
+		       EF4_FILTER_MATCH_REM_MAC | EF4_FILTER_MATCH_ETHER_TYPE |
+		       EF4_FILTER_MATCH_OUTER_VID))) {
+		rule->flow_type = ETHER_FLOW;
+		if (spec.match_flags &
+		    (EF4_FILTER_MATCH_LOC_MAC | EF4_FILTER_MATCH_LOC_MAC_IG)) {
+			ether_addr_copy(mac_entry->h_dest, spec.loc_mac);
+			if (spec.match_flags & EF4_FILTER_MATCH_LOC_MAC)
+				eth_broadcast_addr(mac_mask->h_dest);
+			else
+				ether_addr_copy(mac_mask->h_dest,
+						mac_addr_ig_mask);
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_REM_MAC) {
+			ether_addr_copy(mac_entry->h_source, spec.rem_mac);
+			eth_broadcast_addr(mac_mask->h_source);
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_ETHER_TYPE) {
+			mac_entry->h_proto = spec.ether_type;
+			mac_mask->h_proto = ETHER_TYPE_FULL_MASK;
+		}
+	} else if (spec.match_flags & EF4_FILTER_MATCH_ETHER_TYPE &&
+		   spec.ether_type == htons(ETH_P_IP) &&
+		   !(spec.match_flags &
+		     ~(EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_OUTER_VID |
+		       EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_REM_HOST |
+		       EF4_FILTER_MATCH_IP_PROTO))) {
+		rule->flow_type = IPV4_USER_FLOW;
+		uip_entry->ip_ver = ETH_RX_NFC_IP4;
+		if (spec.match_flags & EF4_FILTER_MATCH_IP_PROTO) {
+			uip_mask->proto = IP_PROTO_FULL_MASK;
+			uip_entry->proto = spec.ip_proto;
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_LOC_HOST) {
+			uip_entry->ip4dst = spec.loc_host[0];
+			uip_mask->ip4dst = IP4_ADDR_FULL_MASK;
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_REM_HOST) {
+			uip_entry->ip4src = spec.rem_host[0];
+			uip_mask->ip4src = IP4_ADDR_FULL_MASK;
+		}
+	} else if (spec.match_flags & EF4_FILTER_MATCH_ETHER_TYPE &&
+		   spec.ether_type == htons(ETH_P_IPV6) &&
+		   !(spec.match_flags &
+		     ~(EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_OUTER_VID |
+		       EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_REM_HOST |
+		       EF4_FILTER_MATCH_IP_PROTO))) {
+		rule->flow_type = IPV6_USER_FLOW;
+		if (spec.match_flags & EF4_FILTER_MATCH_IP_PROTO) {
+			uip6_mask->l4_proto = IP_PROTO_FULL_MASK;
+			uip6_entry->l4_proto = spec.ip_proto;
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_LOC_HOST) {
+			memcpy(uip6_entry->ip6dst, spec.loc_host,
+			       sizeof(uip6_entry->ip6dst));
+			ip6_fill_mask(uip6_mask->ip6dst);
+		}
+		if (spec.match_flags & EF4_FILTER_MATCH_REM_HOST) {
+			memcpy(uip6_entry->ip6src, spec.rem_host,
+			       sizeof(uip6_entry->ip6src));
+			ip6_fill_mask(uip6_mask->ip6src);
+		}
+	} else {
+		/* The above should handle all filters that we insert */
+		WARN_ON(1);
+		return -EINVAL;
+	}
+
+	if (spec.match_flags & EF4_FILTER_MATCH_OUTER_VID) {
+		rule->flow_type |= FLOW_EXT;
+		rule->h_ext.vlan_tci = spec.outer_vid;
+		rule->m_ext.vlan_tci = htons(0xfff);
+	}
+
+	return rc;
+}
+
+static int
+ef4_ethtool_get_rxnfc(struct net_device *net_dev,
+		      struct ethtool_rxnfc *info, u32 *rule_locs)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = efx->n_rx_channels;
+		return 0;
+
+	case ETHTOOL_GRXFH: {
+		unsigned min_revision = 0;
+
+		info->data = 0;
+		switch (info->flow_type) {
+		case TCP_V4_FLOW:
+			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		case UDP_V4_FLOW:
+		case SCTP_V4_FLOW:
+		case AH_ESP_V4_FLOW:
+		case IPV4_FLOW:
+			info->data |= RXH_IP_SRC | RXH_IP_DST;
+			min_revision = EF4_REV_FALCON_B0;
+			break;
+		default:
+			break;
+		}
+		if (ef4_nic_rev(efx) < min_revision)
+			info->data = 0;
+		return 0;
+	}
+
+	case ETHTOOL_GRXCLSRLCNT:
+		info->data = ef4_filter_get_rx_id_limit(efx);
+		if (info->data == 0)
+			return -EOPNOTSUPP;
+		info->data |= RX_CLS_LOC_SPECIAL;
+		info->rule_cnt =
+			ef4_filter_count_rx_used(efx, EF4_FILTER_PRI_MANUAL);
+		return 0;
+
+	case ETHTOOL_GRXCLSRULE:
+		if (ef4_filter_get_rx_id_limit(efx) == 0)
+			return -EOPNOTSUPP;
+		return ef4_ethtool_get_class_rule(efx, &info->fs);
+
+	case ETHTOOL_GRXCLSRLALL: {
+		s32 rc;
+		info->data = ef4_filter_get_rx_id_limit(efx);
+		if (info->data == 0)
+			return -EOPNOTSUPP;
+		rc = ef4_filter_get_rx_ids(efx, EF4_FILTER_PRI_MANUAL,
+					   rule_locs, info->rule_cnt);
+		if (rc < 0)
+			return rc;
+		info->rule_cnt = rc;
+		return 0;
+	}
+
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static inline bool ip6_mask_is_full(__be32 mask[4])
+{
+	return !~(mask[0] & mask[1] & mask[2] & mask[3]);
+}
+
+static inline bool ip6_mask_is_empty(__be32 mask[4])
+{
+	return !(mask[0] | mask[1] | mask[2] | mask[3]);
+}
+
+static int ef4_ethtool_set_class_rule(struct ef4_nic *efx,
+				      struct ethtool_rx_flow_spec *rule)
+{
+	struct ethtool_tcpip4_spec *ip_entry = &rule->h_u.tcp_ip4_spec;
+	struct ethtool_tcpip4_spec *ip_mask = &rule->m_u.tcp_ip4_spec;
+	struct ethtool_usrip4_spec *uip_entry = &rule->h_u.usr_ip4_spec;
+	struct ethtool_usrip4_spec *uip_mask = &rule->m_u.usr_ip4_spec;
+	struct ethtool_tcpip6_spec *ip6_entry = &rule->h_u.tcp_ip6_spec;
+	struct ethtool_tcpip6_spec *ip6_mask = &rule->m_u.tcp_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_entry = &rule->h_u.usr_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_mask = &rule->m_u.usr_ip6_spec;
+	struct ethhdr *mac_entry = &rule->h_u.ether_spec;
+	struct ethhdr *mac_mask = &rule->m_u.ether_spec;
+	struct ef4_filter_spec spec;
+	int rc;
+
+	/* Check that user wants us to choose the location */
+	if (rule->location != RX_CLS_LOC_ANY)
+		return -EINVAL;
+
+	/* Range-check ring_cookie */
+	if (rule->ring_cookie >= efx->n_rx_channels &&
+	    rule->ring_cookie != RX_CLS_FLOW_DISC)
+		return -EINVAL;
+
+	/* Check for unsupported extensions */
+	if ((rule->flow_type & FLOW_EXT) &&
+	    (rule->m_ext.vlan_etype || rule->m_ext.data[0] ||
+	     rule->m_ext.data[1]))
+		return -EINVAL;
+
+	ef4_filter_init_rx(&spec, EF4_FILTER_PRI_MANUAL,
+			   efx->rx_scatter ? EF4_FILTER_FLAG_RX_SCATTER : 0,
+			   (rule->ring_cookie == RX_CLS_FLOW_DISC) ?
+			   EF4_FILTER_RX_DMAQ_ID_DROP : rule->ring_cookie);
+
+	switch (rule->flow_type & ~FLOW_EXT) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		spec.match_flags = (EF4_FILTER_MATCH_ETHER_TYPE |
+				    EF4_FILTER_MATCH_IP_PROTO);
+		spec.ether_type = htons(ETH_P_IP);
+		spec.ip_proto = ((rule->flow_type & ~FLOW_EXT) == TCP_V4_FLOW ?
+				 IPPROTO_TCP : IPPROTO_UDP);
+		if (ip_mask->ip4dst) {
+			if (ip_mask->ip4dst != IP4_ADDR_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_LOC_HOST;
+			spec.loc_host[0] = ip_entry->ip4dst;
+		}
+		if (ip_mask->ip4src) {
+			if (ip_mask->ip4src != IP4_ADDR_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_REM_HOST;
+			spec.rem_host[0] = ip_entry->ip4src;
+		}
+		if (ip_mask->pdst) {
+			if (ip_mask->pdst != PORT_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_LOC_PORT;
+			spec.loc_port = ip_entry->pdst;
+		}
+		if (ip_mask->psrc) {
+			if (ip_mask->psrc != PORT_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_REM_PORT;
+			spec.rem_port = ip_entry->psrc;
+		}
+		if (ip_mask->tos)
+			return -EINVAL;
+		break;
+
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+		spec.match_flags = (EF4_FILTER_MATCH_ETHER_TYPE |
+				    EF4_FILTER_MATCH_IP_PROTO);
+		spec.ether_type = htons(ETH_P_IPV6);
+		spec.ip_proto = ((rule->flow_type & ~FLOW_EXT) == TCP_V6_FLOW ?
+				 IPPROTO_TCP : IPPROTO_UDP);
+		if (!ip6_mask_is_empty(ip6_mask->ip6dst)) {
+			if (!ip6_mask_is_full(ip6_mask->ip6dst))
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_LOC_HOST;
+			memcpy(spec.loc_host, ip6_entry->ip6dst, sizeof(spec.loc_host));
+		}
+		if (!ip6_mask_is_empty(ip6_mask->ip6src)) {
+			if (!ip6_mask_is_full(ip6_mask->ip6src))
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_REM_HOST;
+			memcpy(spec.rem_host, ip6_entry->ip6src, sizeof(spec.rem_host));
+		}
+		if (ip6_mask->pdst) {
+			if (ip6_mask->pdst != PORT_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_LOC_PORT;
+			spec.loc_port = ip6_entry->pdst;
+		}
+		if (ip6_mask->psrc) {
+			if (ip6_mask->psrc != PORT_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_REM_PORT;
+			spec.rem_port = ip6_entry->psrc;
+		}
+		if (ip6_mask->tclass)
+			return -EINVAL;
+		break;
+
+	case IPV4_USER_FLOW:
+		if (uip_mask->l4_4_bytes || uip_mask->tos || uip_mask->ip_ver ||
+		    uip_entry->ip_ver != ETH_RX_NFC_IP4)
+			return -EINVAL;
+		spec.match_flags = EF4_FILTER_MATCH_ETHER_TYPE;
+		spec.ether_type = htons(ETH_P_IP);
+		if (uip_mask->ip4dst) {
+			if (uip_mask->ip4dst != IP4_ADDR_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_LOC_HOST;
+			spec.loc_host[0] = uip_entry->ip4dst;
+		}
+		if (uip_mask->ip4src) {
+			if (uip_mask->ip4src != IP4_ADDR_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_REM_HOST;
+			spec.rem_host[0] = uip_entry->ip4src;
+		}
+		if (uip_mask->proto) {
+			if (uip_mask->proto != IP_PROTO_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_IP_PROTO;
+			spec.ip_proto = uip_entry->proto;
+		}
+		break;
+
+	case IPV6_USER_FLOW:
+		if (uip6_mask->l4_4_bytes || uip6_mask->tclass)
+			return -EINVAL;
+		spec.match_flags = EF4_FILTER_MATCH_ETHER_TYPE;
+		spec.ether_type = htons(ETH_P_IPV6);
+		if (!ip6_mask_is_empty(uip6_mask->ip6dst)) {
+			if (!ip6_mask_is_full(uip6_mask->ip6dst))
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_LOC_HOST;
+			memcpy(spec.loc_host, uip6_entry->ip6dst, sizeof(spec.loc_host));
+		}
+		if (!ip6_mask_is_empty(uip6_mask->ip6src)) {
+			if (!ip6_mask_is_full(uip6_mask->ip6src))
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_REM_HOST;
+			memcpy(spec.rem_host, uip6_entry->ip6src, sizeof(spec.rem_host));
+		}
+		if (uip6_mask->l4_proto) {
+			if (uip6_mask->l4_proto != IP_PROTO_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_IP_PROTO;
+			spec.ip_proto = uip6_entry->l4_proto;
+		}
+		break;
+
+	case ETHER_FLOW:
+		if (!is_zero_ether_addr(mac_mask->h_dest)) {
+			if (ether_addr_equal(mac_mask->h_dest,
+					     mac_addr_ig_mask))
+				spec.match_flags |= EF4_FILTER_MATCH_LOC_MAC_IG;
+			else if (is_broadcast_ether_addr(mac_mask->h_dest))
+				spec.match_flags |= EF4_FILTER_MATCH_LOC_MAC;
+			else
+				return -EINVAL;
+			ether_addr_copy(spec.loc_mac, mac_entry->h_dest);
+		}
+		if (!is_zero_ether_addr(mac_mask->h_source)) {
+			if (!is_broadcast_ether_addr(mac_mask->h_source))
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_REM_MAC;
+			ether_addr_copy(spec.rem_mac, mac_entry->h_source);
+		}
+		if (mac_mask->h_proto) {
+			if (mac_mask->h_proto != ETHER_TYPE_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EF4_FILTER_MATCH_ETHER_TYPE;
+			spec.ether_type = mac_entry->h_proto;
+		}
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if ((rule->flow_type & FLOW_EXT) && rule->m_ext.vlan_tci) {
+		if (rule->m_ext.vlan_tci != htons(0xfff))
+			return -EINVAL;
+		spec.match_flags |= EF4_FILTER_MATCH_OUTER_VID;
+		spec.outer_vid = rule->h_ext.vlan_tci;
+	}
+
+	rc = ef4_filter_insert_filter(efx, &spec, true);
+	if (rc < 0)
+		return rc;
+
+	rule->location = rc;
+	return 0;
+}
+
+static int ef4_ethtool_set_rxnfc(struct net_device *net_dev,
+				 struct ethtool_rxnfc *info)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	if (ef4_filter_get_rx_id_limit(efx) == 0)
+		return -EOPNOTSUPP;
+
+	switch (info->cmd) {
+	case ETHTOOL_SRXCLSRLINS:
+		return ef4_ethtool_set_class_rule(efx, &info->fs);
+
+	case ETHTOOL_SRXCLSRLDEL:
+		return ef4_filter_remove_id_safe(efx, EF4_FILTER_PRI_MANUAL,
+						 info->fs.location);
+
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static u32 ef4_ethtool_get_rxfh_indir_size(struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	return ((ef4_nic_rev(efx) < EF4_REV_FALCON_B0 ||
+		 efx->n_rx_channels == 1) ?
+		0 : ARRAY_SIZE(efx->rx_indir_table));
+}
+
+static int ef4_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key,
+				u8 *hfunc)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+	if (indir)
+		memcpy(indir, efx->rx_indir_table, sizeof(efx->rx_indir_table));
+	return 0;
+}
+
+static int ef4_ethtool_set_rxfh(struct net_device *net_dev, const u32 *indir,
+				const u8 *key, const u8 hfunc)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+
+	/* We do not allow change in unsupported parameters */
+	if (key ||
+	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
+		return -EOPNOTSUPP;
+	if (!indir)
+		return 0;
+
+	return efx->type->rx_push_rss_config(efx, true, indir);
+}
+
+static int ef4_ethtool_get_module_eeprom(struct net_device *net_dev,
+					 struct ethtool_eeprom *ee,
+					 u8 *data)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int ret;
+
+	if (!efx->phy_op || !efx->phy_op->get_module_eeprom)
+		return -EOPNOTSUPP;
+
+	mutex_lock(&efx->mac_lock);
+	ret = efx->phy_op->get_module_eeprom(efx, ee, data);
+	mutex_unlock(&efx->mac_lock);
+
+	return ret;
+}
+
+static int ef4_ethtool_get_module_info(struct net_device *net_dev,
+				       struct ethtool_modinfo *modinfo)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	int ret;
+
+	if (!efx->phy_op || !efx->phy_op->get_module_info)
+		return -EOPNOTSUPP;
+
+	mutex_lock(&efx->mac_lock);
+	ret = efx->phy_op->get_module_info(efx, modinfo);
+	mutex_unlock(&efx->mac_lock);
+
+	return ret;
+}
+
+const struct ethtool_ops ef4_ethtool_ops = {
+	.get_settings		= ef4_ethtool_get_settings,
+	.set_settings		= ef4_ethtool_set_settings,
+	.get_drvinfo		= ef4_ethtool_get_drvinfo,
+	.get_regs_len		= ef4_ethtool_get_regs_len,
+	.get_regs		= ef4_ethtool_get_regs,
+	.get_msglevel		= ef4_ethtool_get_msglevel,
+	.set_msglevel		= ef4_ethtool_set_msglevel,
+	.nway_reset		= ef4_ethtool_nway_reset,
+	.get_link		= ethtool_op_get_link,
+	.get_coalesce		= ef4_ethtool_get_coalesce,
+	.set_coalesce		= ef4_ethtool_set_coalesce,
+	.get_ringparam		= ef4_ethtool_get_ringparam,
+	.set_ringparam		= ef4_ethtool_set_ringparam,
+	.get_pauseparam         = ef4_ethtool_get_pauseparam,
+	.set_pauseparam         = ef4_ethtool_set_pauseparam,
+	.get_sset_count		= ef4_ethtool_get_sset_count,
+	.self_test		= ef4_ethtool_self_test,
+	.get_strings		= ef4_ethtool_get_strings,
+	.set_phys_id		= ef4_ethtool_phys_id,
+	.get_ethtool_stats	= ef4_ethtool_get_stats,
+	.get_wol                = ef4_ethtool_get_wol,
+	.set_wol                = ef4_ethtool_set_wol,
+	.reset			= ef4_ethtool_reset,
+	.get_rxnfc		= ef4_ethtool_get_rxnfc,
+	.set_rxnfc		= ef4_ethtool_set_rxnfc,
+	.get_rxfh_indir_size	= ef4_ethtool_get_rxfh_indir_size,
+	.get_rxfh		= ef4_ethtool_get_rxfh,
+	.set_rxfh		= ef4_ethtool_set_rxfh,
+	.get_module_info	= ef4_ethtool_get_module_info,
+	.get_module_eeprom	= ef4_ethtool_get_module_eeprom,
+};
diff --git a/drivers/net/ethernet/sfc/falcon/falcon.c b/drivers/net/ethernet/sfc/falcon/falcon.c
new file mode 100644
index 0000000..c6ff0cc
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/falcon.c
@@ -0,0 +1,2903 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/module.h>
+#include <linux/seq_file.h>
+#include <linux/i2c.h>
+#include <linux/mii.h>
+#include <linux/slab.h>
+#include "net_driver.h"
+#include "bitfield.h"
+#include "efx.h"
+#include "nic.h"
+#include "farch_regs.h"
+#include "io.h"
+#include "phy.h"
+#include "workarounds.h"
+#include "selftest.h"
+#include "mdio_10g.h"
+
+/* Hardware control for SFC4000 (aka Falcon). */
+
+/**************************************************************************
+ *
+ * NIC stats
+ *
+ **************************************************************************
+ */
+
+#define FALCON_MAC_STATS_SIZE 0x100
+
+#define XgRxOctets_offset 0x0
+#define XgRxOctets_WIDTH 48
+#define XgRxOctetsOK_offset 0x8
+#define XgRxOctetsOK_WIDTH 48
+#define XgRxPkts_offset 0x10
+#define XgRxPkts_WIDTH 32
+#define XgRxPktsOK_offset 0x14
+#define XgRxPktsOK_WIDTH 32
+#define XgRxBroadcastPkts_offset 0x18
+#define XgRxBroadcastPkts_WIDTH 32
+#define XgRxMulticastPkts_offset 0x1C
+#define XgRxMulticastPkts_WIDTH 32
+#define XgRxUnicastPkts_offset 0x20
+#define XgRxUnicastPkts_WIDTH 32
+#define XgRxUndersizePkts_offset 0x24
+#define XgRxUndersizePkts_WIDTH 32
+#define XgRxOversizePkts_offset 0x28
+#define XgRxOversizePkts_WIDTH 32
+#define XgRxJabberPkts_offset 0x2C
+#define XgRxJabberPkts_WIDTH 32
+#define XgRxUndersizeFCSerrorPkts_offset 0x30
+#define XgRxUndersizeFCSerrorPkts_WIDTH 32
+#define XgRxDropEvents_offset 0x34
+#define XgRxDropEvents_WIDTH 32
+#define XgRxFCSerrorPkts_offset 0x38
+#define XgRxFCSerrorPkts_WIDTH 32
+#define XgRxAlignError_offset 0x3C
+#define XgRxAlignError_WIDTH 32
+#define XgRxSymbolError_offset 0x40
+#define XgRxSymbolError_WIDTH 32
+#define XgRxInternalMACError_offset 0x44
+#define XgRxInternalMACError_WIDTH 32
+#define XgRxControlPkts_offset 0x48
+#define XgRxControlPkts_WIDTH 32
+#define XgRxPausePkts_offset 0x4C
+#define XgRxPausePkts_WIDTH 32
+#define XgRxPkts64Octets_offset 0x50
+#define XgRxPkts64Octets_WIDTH 32
+#define XgRxPkts65to127Octets_offset 0x54
+#define XgRxPkts65to127Octets_WIDTH 32
+#define XgRxPkts128to255Octets_offset 0x58
+#define XgRxPkts128to255Octets_WIDTH 32
+#define XgRxPkts256to511Octets_offset 0x5C
+#define XgRxPkts256to511Octets_WIDTH 32
+#define XgRxPkts512to1023Octets_offset 0x60
+#define XgRxPkts512to1023Octets_WIDTH 32
+#define XgRxPkts1024to15xxOctets_offset 0x64
+#define XgRxPkts1024to15xxOctets_WIDTH 32
+#define XgRxPkts15xxtoMaxOctets_offset 0x68
+#define XgRxPkts15xxtoMaxOctets_WIDTH 32
+#define XgRxLengthError_offset 0x6C
+#define XgRxLengthError_WIDTH 32
+#define XgTxPkts_offset 0x80
+#define XgTxPkts_WIDTH 32
+#define XgTxOctets_offset 0x88
+#define XgTxOctets_WIDTH 48
+#define XgTxMulticastPkts_offset 0x90
+#define XgTxMulticastPkts_WIDTH 32
+#define XgTxBroadcastPkts_offset 0x94
+#define XgTxBroadcastPkts_WIDTH 32
+#define XgTxUnicastPkts_offset 0x98
+#define XgTxUnicastPkts_WIDTH 32
+#define XgTxControlPkts_offset 0x9C
+#define XgTxControlPkts_WIDTH 32
+#define XgTxPausePkts_offset 0xA0
+#define XgTxPausePkts_WIDTH 32
+#define XgTxPkts64Octets_offset 0xA4
+#define XgTxPkts64Octets_WIDTH 32
+#define XgTxPkts65to127Octets_offset 0xA8
+#define XgTxPkts65to127Octets_WIDTH 32
+#define XgTxPkts128to255Octets_offset 0xAC
+#define XgTxPkts128to255Octets_WIDTH 32
+#define XgTxPkts256to511Octets_offset 0xB0
+#define XgTxPkts256to511Octets_WIDTH 32
+#define XgTxPkts512to1023Octets_offset 0xB4
+#define XgTxPkts512to1023Octets_WIDTH 32
+#define XgTxPkts1024to15xxOctets_offset 0xB8
+#define XgTxPkts1024to15xxOctets_WIDTH 32
+#define XgTxPkts1519toMaxOctets_offset 0xBC
+#define XgTxPkts1519toMaxOctets_WIDTH 32
+#define XgTxUndersizePkts_offset 0xC0
+#define XgTxUndersizePkts_WIDTH 32
+#define XgTxOversizePkts_offset 0xC4
+#define XgTxOversizePkts_WIDTH 32
+#define XgTxNonTcpUdpPkt_offset 0xC8
+#define XgTxNonTcpUdpPkt_WIDTH 16
+#define XgTxMacSrcErrPkt_offset 0xCC
+#define XgTxMacSrcErrPkt_WIDTH 16
+#define XgTxIpSrcErrPkt_offset 0xD0
+#define XgTxIpSrcErrPkt_WIDTH 16
+#define XgDmaDone_offset 0xD4
+#define XgDmaDone_WIDTH 32
+
+#define FALCON_XMAC_STATS_DMA_FLAG(efx)				\
+	(*(u32 *)((efx)->stats_buffer.addr + XgDmaDone_offset))
+
+#define FALCON_DMA_STAT(ext_name, hw_name)				\
+	[FALCON_STAT_ ## ext_name] =					\
+	{ #ext_name,							\
+	  /* 48-bit stats are zero-padded to 64 on DMA */		\
+	  hw_name ## _ ## WIDTH == 48 ? 64 : hw_name ## _ ## WIDTH,	\
+	  hw_name ## _ ## offset }
+#define FALCON_OTHER_STAT(ext_name)					\
+	[FALCON_STAT_ ## ext_name] = { #ext_name, 0, 0 }
+#define GENERIC_SW_STAT(ext_name)				\
+	[GENERIC_STAT_ ## ext_name] = { #ext_name, 0, 0 }
+
+static const struct ef4_hw_stat_desc falcon_stat_desc[FALCON_STAT_COUNT] = {
+	FALCON_DMA_STAT(tx_bytes, XgTxOctets),
+	FALCON_DMA_STAT(tx_packets, XgTxPkts),
+	FALCON_DMA_STAT(tx_pause, XgTxPausePkts),
+	FALCON_DMA_STAT(tx_control, XgTxControlPkts),
+	FALCON_DMA_STAT(tx_unicast, XgTxUnicastPkts),
+	FALCON_DMA_STAT(tx_multicast, XgTxMulticastPkts),
+	FALCON_DMA_STAT(tx_broadcast, XgTxBroadcastPkts),
+	FALCON_DMA_STAT(tx_lt64, XgTxUndersizePkts),
+	FALCON_DMA_STAT(tx_64, XgTxPkts64Octets),
+	FALCON_DMA_STAT(tx_65_to_127, XgTxPkts65to127Octets),
+	FALCON_DMA_STAT(tx_128_to_255, XgTxPkts128to255Octets),
+	FALCON_DMA_STAT(tx_256_to_511, XgTxPkts256to511Octets),
+	FALCON_DMA_STAT(tx_512_to_1023, XgTxPkts512to1023Octets),
+	FALCON_DMA_STAT(tx_1024_to_15xx, XgTxPkts1024to15xxOctets),
+	FALCON_DMA_STAT(tx_15xx_to_jumbo, XgTxPkts1519toMaxOctets),
+	FALCON_DMA_STAT(tx_gtjumbo, XgTxOversizePkts),
+	FALCON_DMA_STAT(tx_non_tcpudp, XgTxNonTcpUdpPkt),
+	FALCON_DMA_STAT(tx_mac_src_error, XgTxMacSrcErrPkt),
+	FALCON_DMA_STAT(tx_ip_src_error, XgTxIpSrcErrPkt),
+	FALCON_DMA_STAT(rx_bytes, XgRxOctets),
+	FALCON_DMA_STAT(rx_good_bytes, XgRxOctetsOK),
+	FALCON_OTHER_STAT(rx_bad_bytes),
+	FALCON_DMA_STAT(rx_packets, XgRxPkts),
+	FALCON_DMA_STAT(rx_good, XgRxPktsOK),
+	FALCON_DMA_STAT(rx_bad, XgRxFCSerrorPkts),
+	FALCON_DMA_STAT(rx_pause, XgRxPausePkts),
+	FALCON_DMA_STAT(rx_control, XgRxControlPkts),
+	FALCON_DMA_STAT(rx_unicast, XgRxUnicastPkts),
+	FALCON_DMA_STAT(rx_multicast, XgRxMulticastPkts),
+	FALCON_DMA_STAT(rx_broadcast, XgRxBroadcastPkts),
+	FALCON_DMA_STAT(rx_lt64, XgRxUndersizePkts),
+	FALCON_DMA_STAT(rx_64, XgRxPkts64Octets),
+	FALCON_DMA_STAT(rx_65_to_127, XgRxPkts65to127Octets),
+	FALCON_DMA_STAT(rx_128_to_255, XgRxPkts128to255Octets),
+	FALCON_DMA_STAT(rx_256_to_511, XgRxPkts256to511Octets),
+	FALCON_DMA_STAT(rx_512_to_1023, XgRxPkts512to1023Octets),
+	FALCON_DMA_STAT(rx_1024_to_15xx, XgRxPkts1024to15xxOctets),
+	FALCON_DMA_STAT(rx_15xx_to_jumbo, XgRxPkts15xxtoMaxOctets),
+	FALCON_DMA_STAT(rx_gtjumbo, XgRxOversizePkts),
+	FALCON_DMA_STAT(rx_bad_lt64, XgRxUndersizeFCSerrorPkts),
+	FALCON_DMA_STAT(rx_bad_gtjumbo, XgRxJabberPkts),
+	FALCON_DMA_STAT(rx_overflow, XgRxDropEvents),
+	FALCON_DMA_STAT(rx_symbol_error, XgRxSymbolError),
+	FALCON_DMA_STAT(rx_align_error, XgRxAlignError),
+	FALCON_DMA_STAT(rx_length_error, XgRxLengthError),
+	FALCON_DMA_STAT(rx_internal_error, XgRxInternalMACError),
+	FALCON_OTHER_STAT(rx_nodesc_drop_cnt),
+	GENERIC_SW_STAT(rx_nodesc_trunc),
+	GENERIC_SW_STAT(rx_noskb_drops),
+};
+static const unsigned long falcon_stat_mask[] = {
+	[0 ... BITS_TO_LONGS(FALCON_STAT_COUNT) - 1] = ~0UL,
+};
+
+/**************************************************************************
+ *
+ * Basic SPI command set and bit definitions
+ *
+ *************************************************************************/
+
+#define SPI_WRSR 0x01		/* Write status register */
+#define SPI_WRITE 0x02		/* Write data to memory array */
+#define SPI_READ 0x03		/* Read data from memory array */
+#define SPI_WRDI 0x04		/* Reset write enable latch */
+#define SPI_RDSR 0x05		/* Read status register */
+#define SPI_WREN 0x06		/* Set write enable latch */
+#define SPI_SST_EWSR 0x50	/* SST: Enable write to status register */
+
+#define SPI_STATUS_WPEN 0x80	/* Write-protect pin enabled */
+#define SPI_STATUS_BP2 0x10	/* Block protection bit 2 */
+#define SPI_STATUS_BP1 0x08	/* Block protection bit 1 */
+#define SPI_STATUS_BP0 0x04	/* Block protection bit 0 */
+#define SPI_STATUS_WEN 0x02	/* State of the write enable latch */
+#define SPI_STATUS_NRDY 0x01	/* Device busy flag */
+
+/**************************************************************************
+ *
+ * Non-volatile memory layout
+ *
+ **************************************************************************
+ */
+
+/* SFC4000 flash is partitioned into:
+ *     0-0x400       chip and board config (see struct falcon_nvconfig)
+ *     0x400-0x8000  unused (or may contain VPD if EEPROM not present)
+ *     0x8000-end    boot code (mapped to PCI expansion ROM)
+ * SFC4000 small EEPROM (size < 0x400) is used for VPD only.
+ * SFC4000 large EEPROM (size >= 0x400) is partitioned into:
+ *     0-0x400       chip and board config
+ *     configurable  VPD
+ *     0x800-0x1800  boot config
+ * Aside from the chip and board config, all of these are optional and may
+ * be absent or truncated depending on the devices used.
+ */
+#define FALCON_NVCONFIG_END 0x400U
+#define FALCON_FLASH_BOOTCODE_START 0x8000U
+#define FALCON_EEPROM_BOOTCONFIG_START 0x800U
+#define FALCON_EEPROM_BOOTCONFIG_END 0x1800U
+
+/* Board configuration v2 (v1 is obsolete; later versions are compatible) */
+struct falcon_nvconfig_board_v2 {
+	__le16 nports;
+	u8 port0_phy_addr;
+	u8 port0_phy_type;
+	u8 port1_phy_addr;
+	u8 port1_phy_type;
+	__le16 asic_sub_revision;
+	__le16 board_revision;
+} __packed;
+
+/* Board configuration v3 extra information */
+struct falcon_nvconfig_board_v3 {
+	__le32 spi_device_type[2];
+} __packed;
+
+/* Bit numbers for spi_device_type */
+#define SPI_DEV_TYPE_SIZE_LBN 0
+#define SPI_DEV_TYPE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_ADDR_LEN_LBN 6
+#define SPI_DEV_TYPE_ADDR_LEN_WIDTH 2
+#define SPI_DEV_TYPE_ERASE_CMD_LBN 8
+#define SPI_DEV_TYPE_ERASE_CMD_WIDTH 8
+#define SPI_DEV_TYPE_ERASE_SIZE_LBN 16
+#define SPI_DEV_TYPE_ERASE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_BLOCK_SIZE_LBN 24
+#define SPI_DEV_TYPE_BLOCK_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_FIELD(type, field)					\
+	(((type) >> EF4_LOW_BIT(field)) & EF4_MASK32(EF4_WIDTH(field)))
+
+#define FALCON_NVCONFIG_OFFSET 0x300
+
+#define FALCON_NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
+struct falcon_nvconfig {
+	ef4_oword_t ee_vpd_cfg_reg;			/* 0x300 */
+	u8 mac_address[2][8];			/* 0x310 */
+	ef4_oword_t pcie_sd_ctl0123_reg;		/* 0x320 */
+	ef4_oword_t pcie_sd_ctl45_reg;			/* 0x330 */
+	ef4_oword_t pcie_pcs_ctl_stat_reg;		/* 0x340 */
+	ef4_oword_t hw_init_reg;			/* 0x350 */
+	ef4_oword_t nic_stat_reg;			/* 0x360 */
+	ef4_oword_t glb_ctl_reg;			/* 0x370 */
+	ef4_oword_t srm_cfg_reg;			/* 0x380 */
+	ef4_oword_t spare_reg;				/* 0x390 */
+	__le16 board_magic_num;			/* 0x3A0 */
+	__le16 board_struct_ver;
+	__le16 board_checksum;
+	struct falcon_nvconfig_board_v2 board_v2;
+	ef4_oword_t ee_base_page_reg;			/* 0x3B0 */
+	struct falcon_nvconfig_board_v3 board_v3;	/* 0x3C0 */
+} __packed;
+
+/*************************************************************************/
+
+static int falcon_reset_hw(struct ef4_nic *efx, enum reset_type method);
+static void falcon_reconfigure_mac_wrapper(struct ef4_nic *efx);
+
+static const unsigned int
+/* "Large" EEPROM device: Atmel AT25640 or similar
+ * 8 KB, 16-bit address, 32 B write block */
+large_eeprom_type = ((13 << SPI_DEV_TYPE_SIZE_LBN)
+		     | (2 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+		     | (5 << SPI_DEV_TYPE_BLOCK_SIZE_LBN)),
+/* Default flash device: Atmel AT25F1024
+ * 128 KB, 24-bit address, 32 KB erase block, 256 B write block */
+default_flash_type = ((17 << SPI_DEV_TYPE_SIZE_LBN)
+		      | (3 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+		      | (0x52 << SPI_DEV_TYPE_ERASE_CMD_LBN)
+		      | (15 << SPI_DEV_TYPE_ERASE_SIZE_LBN)
+		      | (8 << SPI_DEV_TYPE_BLOCK_SIZE_LBN));
+
+/**************************************************************************
+ *
+ * I2C bus - this is a bit-bashing interface using GPIO pins
+ * Note that it uses the output enables to tristate the outputs
+ * SDA is the data pin and SCL is the clock
+ *
+ **************************************************************************
+ */
+static void falcon_setsda(void *data, int state)
+{
+	struct ef4_nic *efx = (struct ef4_nic *)data;
+	ef4_oword_t reg;
+
+	ef4_reado(efx, &reg, FR_AB_GPIO_CTL);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_GPIO3_OEN, !state);
+	ef4_writeo(efx, &reg, FR_AB_GPIO_CTL);
+}
+
+static void falcon_setscl(void *data, int state)
+{
+	struct ef4_nic *efx = (struct ef4_nic *)data;
+	ef4_oword_t reg;
+
+	ef4_reado(efx, &reg, FR_AB_GPIO_CTL);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_GPIO0_OEN, !state);
+	ef4_writeo(efx, &reg, FR_AB_GPIO_CTL);
+}
+
+static int falcon_getsda(void *data)
+{
+	struct ef4_nic *efx = (struct ef4_nic *)data;
+	ef4_oword_t reg;
+
+	ef4_reado(efx, &reg, FR_AB_GPIO_CTL);
+	return EF4_OWORD_FIELD(reg, FRF_AB_GPIO3_IN);
+}
+
+static int falcon_getscl(void *data)
+{
+	struct ef4_nic *efx = (struct ef4_nic *)data;
+	ef4_oword_t reg;
+
+	ef4_reado(efx, &reg, FR_AB_GPIO_CTL);
+	return EF4_OWORD_FIELD(reg, FRF_AB_GPIO0_IN);
+}
+
+static const struct i2c_algo_bit_data falcon_i2c_bit_operations = {
+	.setsda		= falcon_setsda,
+	.setscl		= falcon_setscl,
+	.getsda		= falcon_getsda,
+	.getscl		= falcon_getscl,
+	.udelay		= 5,
+	/* Wait up to 50 ms for slave to let us pull SCL high */
+	.timeout	= DIV_ROUND_UP(HZ, 20),
+};
+
+static void falcon_push_irq_moderation(struct ef4_channel *channel)
+{
+	ef4_dword_t timer_cmd;
+	struct ef4_nic *efx = channel->efx;
+
+	/* Set timer register */
+	if (channel->irq_moderation_us) {
+		unsigned int ticks;
+
+		ticks = ef4_usecs_to_ticks(efx, channel->irq_moderation_us);
+		EF4_POPULATE_DWORD_2(timer_cmd,
+				     FRF_AB_TC_TIMER_MODE,
+				     FFE_BB_TIMER_MODE_INT_HLDOFF,
+				     FRF_AB_TC_TIMER_VAL,
+				     ticks - 1);
+	} else {
+		EF4_POPULATE_DWORD_2(timer_cmd,
+				     FRF_AB_TC_TIMER_MODE,
+				     FFE_BB_TIMER_MODE_DIS,
+				     FRF_AB_TC_TIMER_VAL, 0);
+	}
+	BUILD_BUG_ON(FR_AA_TIMER_COMMAND_KER != FR_BZ_TIMER_COMMAND_P0);
+	ef4_writed_page_locked(efx, &timer_cmd, FR_BZ_TIMER_COMMAND_P0,
+			       channel->channel);
+}
+
+static void falcon_deconfigure_mac_wrapper(struct ef4_nic *efx);
+
+static void falcon_prepare_flush(struct ef4_nic *efx)
+{
+	falcon_deconfigure_mac_wrapper(efx);
+
+	/* Wait for the tx and rx fifo's to get to the next packet boundary
+	 * (~1ms without back-pressure), then to drain the remainder of the
+	 * fifo's at data path speeds (negligible), with a healthy margin. */
+	msleep(10);
+}
+
+/* Acknowledge a legacy interrupt from Falcon
+ *
+ * This acknowledges a legacy (not MSI) interrupt via INT_ACK_KER_REG.
+ *
+ * Due to SFC bug 3706 (silicon revision <=A1) reads can be duplicated in the
+ * BIU. Interrupt acknowledge is read sensitive so must write instead
+ * (then read to ensure the BIU collector is flushed)
+ *
+ * NB most hardware supports MSI interrupts
+ */
+static inline void falcon_irq_ack_a1(struct ef4_nic *efx)
+{
+	ef4_dword_t reg;
+
+	EF4_POPULATE_DWORD_1(reg, FRF_AA_INT_ACK_KER_FIELD, 0xb7eb7e);
+	ef4_writed(efx, &reg, FR_AA_INT_ACK_KER);
+	ef4_readd(efx, &reg, FR_AA_WORK_AROUND_BROKEN_PCI_READS);
+}
+
+static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
+{
+	struct ef4_nic *efx = dev_id;
+	ef4_oword_t *int_ker = efx->irq_status.addr;
+	int syserr;
+	int queues;
+
+	/* Check to see if this is our interrupt.  If it isn't, we
+	 * exit without having touched the hardware.
+	 */
+	if (unlikely(EF4_OWORD_IS_ZERO(*int_ker))) {
+		netif_vdbg(efx, intr, efx->net_dev,
+			   "IRQ %d on CPU %d not for me\n", irq,
+			   raw_smp_processor_id());
+		return IRQ_NONE;
+	}
+	efx->last_irq_cpu = raw_smp_processor_id();
+	netif_vdbg(efx, intr, efx->net_dev,
+		   "IRQ %d on CPU %d status " EF4_OWORD_FMT "\n",
+		   irq, raw_smp_processor_id(), EF4_OWORD_VAL(*int_ker));
+
+	if (!likely(ACCESS_ONCE(efx->irq_soft_enabled)))
+		return IRQ_HANDLED;
+
+	/* Check to see if we have a serious error condition */
+	syserr = EF4_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
+	if (unlikely(syserr))
+		return ef4_farch_fatal_interrupt(efx);
+
+	/* Determine interrupting queues, clear interrupt status
+	 * register and acknowledge the device interrupt.
+	 */
+	BUILD_BUG_ON(FSF_AZ_NET_IVEC_INT_Q_WIDTH > EF4_MAX_CHANNELS);
+	queues = EF4_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_INT_Q);
+	EF4_ZERO_OWORD(*int_ker);
+	wmb(); /* Ensure the vector is cleared before interrupt ack */
+	falcon_irq_ack_a1(efx);
+
+	if (queues & 1)
+		ef4_schedule_channel_irq(ef4_get_channel(efx, 0));
+	if (queues & 2)
+		ef4_schedule_channel_irq(ef4_get_channel(efx, 1));
+	return IRQ_HANDLED;
+}
+
+/**************************************************************************
+ *
+ * RSS
+ *
+ **************************************************************************
+ */
+static int dummy_rx_push_rss_config(struct ef4_nic *efx, bool user,
+				    const u32 *rx_indir_table)
+{
+	(void) efx;
+	(void) user;
+	(void) rx_indir_table;
+	return -ENOSYS;
+}
+
+static int falcon_b0_rx_push_rss_config(struct ef4_nic *efx, bool user,
+					const u32 *rx_indir_table)
+{
+	ef4_oword_t temp;
+
+	(void) user;
+	/* Set hash key for IPv4 */
+	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
+	ef4_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
+
+	memcpy(efx->rx_indir_table, rx_indir_table,
+	       sizeof(efx->rx_indir_table));
+	ef4_farch_rx_push_indir_table(efx);
+	return 0;
+}
+
+/**************************************************************************
+ *
+ * EEPROM/flash
+ *
+ **************************************************************************
+ */
+
+#define FALCON_SPI_MAX_LEN sizeof(ef4_oword_t)
+
+static int falcon_spi_poll(struct ef4_nic *efx)
+{
+	ef4_oword_t reg;
+	ef4_reado(efx, &reg, FR_AB_EE_SPI_HCMD);
+	return EF4_OWORD_FIELD(reg, FRF_AB_EE_SPI_HCMD_CMD_EN) ? -EBUSY : 0;
+}
+
+/* Wait for SPI command completion */
+static int falcon_spi_wait(struct ef4_nic *efx)
+{
+	/* Most commands will finish quickly, so we start polling at
+	 * very short intervals.  Sometimes the command may have to
+	 * wait for VPD or expansion ROM access outside of our
+	 * control, so we allow up to 100 ms. */
+	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 10);
+	int i;
+
+	for (i = 0; i < 10; i++) {
+		if (!falcon_spi_poll(efx))
+			return 0;
+		udelay(10);
+	}
+
+	for (;;) {
+		if (!falcon_spi_poll(efx))
+			return 0;
+		if (time_after_eq(jiffies, timeout)) {
+			netif_err(efx, hw, efx->net_dev,
+				  "timed out waiting for SPI\n");
+			return -ETIMEDOUT;
+		}
+		schedule_timeout_uninterruptible(1);
+	}
+}
+
+static int
+falcon_spi_cmd(struct ef4_nic *efx, const struct falcon_spi_device *spi,
+	       unsigned int command, int address,
+	       const void *in, void *out, size_t len)
+{
+	bool addressed = (address >= 0);
+	bool reading = (out != NULL);
+	ef4_oword_t reg;
+	int rc;
+
+	/* Input validation */
+	if (len > FALCON_SPI_MAX_LEN)
+		return -EINVAL;
+
+	/* Check that previous command is not still running */
+	rc = falcon_spi_poll(efx);
+	if (rc)
+		return rc;
+
+	/* Program address register, if we have an address */
+	if (addressed) {
+		EF4_POPULATE_OWORD_1(reg, FRF_AB_EE_SPI_HADR_ADR, address);
+		ef4_writeo(efx, &reg, FR_AB_EE_SPI_HADR);
+	}
+
+	/* Program data register, if we have data */
+	if (in != NULL) {
+		memcpy(&reg, in, len);
+		ef4_writeo(efx, &reg, FR_AB_EE_SPI_HDATA);
+	}
+
+	/* Issue read/write command */
+	EF4_POPULATE_OWORD_7(reg,
+			     FRF_AB_EE_SPI_HCMD_CMD_EN, 1,
+			     FRF_AB_EE_SPI_HCMD_SF_SEL, spi->device_id,
+			     FRF_AB_EE_SPI_HCMD_DABCNT, len,
+			     FRF_AB_EE_SPI_HCMD_READ, reading,
+			     FRF_AB_EE_SPI_HCMD_DUBCNT, 0,
+			     FRF_AB_EE_SPI_HCMD_ADBCNT,
+			     (addressed ? spi->addr_len : 0),
+			     FRF_AB_EE_SPI_HCMD_ENC, command);
+	ef4_writeo(efx, &reg, FR_AB_EE_SPI_HCMD);
+
+	/* Wait for read/write to complete */
+	rc = falcon_spi_wait(efx);
+	if (rc)
+		return rc;
+
+	/* Read data */
+	if (out != NULL) {
+		ef4_reado(efx, &reg, FR_AB_EE_SPI_HDATA);
+		memcpy(out, &reg, len);
+	}
+
+	return 0;
+}
+
+static inline u8
+falcon_spi_munge_command(const struct falcon_spi_device *spi,
+			 const u8 command, const unsigned int address)
+{
+	return command | (((address >> 8) & spi->munge_address) << 3);
+}
+
+static int
+falcon_spi_read(struct ef4_nic *efx, const struct falcon_spi_device *spi,
+		loff_t start, size_t len, size_t *retlen, u8 *buffer)
+{
+	size_t block_len, pos = 0;
+	unsigned int command;
+	int rc = 0;
+
+	while (pos < len) {
+		block_len = min(len - pos, FALCON_SPI_MAX_LEN);
+
+		command = falcon_spi_munge_command(spi, SPI_READ, start + pos);
+		rc = falcon_spi_cmd(efx, spi, command, start + pos, NULL,
+				    buffer + pos, block_len);
+		if (rc)
+			break;
+		pos += block_len;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current)) {
+			rc = -EINTR;
+			break;
+		}
+	}
+
+	if (retlen)
+		*retlen = pos;
+	return rc;
+}
+
+#ifdef CONFIG_SFC_FALCON_MTD
+
+struct falcon_mtd_partition {
+	struct ef4_mtd_partition common;
+	const struct falcon_spi_device *spi;
+	size_t offset;
+};
+
+#define to_falcon_mtd_partition(mtd)				\
+	container_of(mtd, struct falcon_mtd_partition, common.mtd)
+
+static size_t
+falcon_spi_write_limit(const struct falcon_spi_device *spi, size_t start)
+{
+	return min(FALCON_SPI_MAX_LEN,
+		   (spi->block_size - (start & (spi->block_size - 1))));
+}
+
+/* Wait up to 10 ms for buffered write completion */
+static int
+falcon_spi_wait_write(struct ef4_nic *efx, const struct falcon_spi_device *spi)
+{
+	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 100);
+	u8 status;
+	int rc;
+
+	for (;;) {
+		rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
+				    &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+		if (time_after_eq(jiffies, timeout)) {
+			netif_err(efx, hw, efx->net_dev,
+				  "SPI write timeout on device %d"
+				  " last status=0x%02x\n",
+				  spi->device_id, status);
+			return -ETIMEDOUT;
+		}
+		schedule_timeout_uninterruptible(1);
+	}
+}
+
+static int
+falcon_spi_write(struct ef4_nic *efx, const struct falcon_spi_device *spi,
+		 loff_t start, size_t len, size_t *retlen, const u8 *buffer)
+{
+	u8 verify_buffer[FALCON_SPI_MAX_LEN];
+	size_t block_len, pos = 0;
+	unsigned int command;
+	int rc = 0;
+
+	while (pos < len) {
+		rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
+		if (rc)
+			break;
+
+		block_len = min(len - pos,
+				falcon_spi_write_limit(spi, start + pos));
+		command = falcon_spi_munge_command(spi, SPI_WRITE, start + pos);
+		rc = falcon_spi_cmd(efx, spi, command, start + pos,
+				    buffer + pos, NULL, block_len);
+		if (rc)
+			break;
+
+		rc = falcon_spi_wait_write(efx, spi);
+		if (rc)
+			break;
+
+		command = falcon_spi_munge_command(spi, SPI_READ, start + pos);
+		rc = falcon_spi_cmd(efx, spi, command, start + pos,
+				    NULL, verify_buffer, block_len);
+		if (memcmp(verify_buffer, buffer + pos, block_len)) {
+			rc = -EIO;
+			break;
+		}
+
+		pos += block_len;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current)) {
+			rc = -EINTR;
+			break;
+		}
+	}
+
+	if (retlen)
+		*retlen = pos;
+	return rc;
+}
+
+static int
+falcon_spi_slow_wait(struct falcon_mtd_partition *part, bool uninterruptible)
+{
+	const struct falcon_spi_device *spi = part->spi;
+	struct ef4_nic *efx = part->common.mtd.priv;
+	u8 status;
+	int rc, i;
+
+	/* Wait up to 4s for flash/EEPROM to finish a slow operation. */
+	for (i = 0; i < 40; i++) {
+		__set_current_state(uninterruptible ?
+				    TASK_UNINTERRUPTIBLE : TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ / 10);
+		rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
+				    &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+		if (signal_pending(current))
+			return -EINTR;
+	}
+	pr_err("%s: timed out waiting for %s\n",
+	       part->common.name, part->common.dev_type_name);
+	return -ETIMEDOUT;
+}
+
+static int
+falcon_spi_unlock(struct ef4_nic *efx, const struct falcon_spi_device *spi)
+{
+	const u8 unlock_mask = (SPI_STATUS_BP2 | SPI_STATUS_BP1 |
+				SPI_STATUS_BP0);
+	u8 status;
+	int rc;
+
+	rc = falcon_spi_cmd(efx, spi, SPI_RDSR, -1, NULL,
+			    &status, sizeof(status));
+	if (rc)
+		return rc;
+
+	if (!(status & unlock_mask))
+		return 0; /* already unlocked */
+
+	rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(efx, spi, SPI_SST_EWSR, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+
+	status &= ~unlock_mask;
+	rc = falcon_spi_cmd(efx, spi, SPI_WRSR, -1, &status,
+			    NULL, sizeof(status));
+	if (rc)
+		return rc;
+	rc = falcon_spi_wait_write(efx, spi);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+#define FALCON_SPI_VERIFY_BUF_LEN 16
+
+static int
+falcon_spi_erase(struct falcon_mtd_partition *part, loff_t start, size_t len)
+{
+	const struct falcon_spi_device *spi = part->spi;
+	struct ef4_nic *efx = part->common.mtd.priv;
+	unsigned pos, block_len;
+	u8 empty[FALCON_SPI_VERIFY_BUF_LEN];
+	u8 buffer[FALCON_SPI_VERIFY_BUF_LEN];
+	int rc;
+
+	if (len != spi->erase_size)
+		return -EINVAL;
+
+	if (spi->erase_command == 0)
+		return -EOPNOTSUPP;
+
+	rc = falcon_spi_unlock(efx, spi);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(efx, spi, SPI_WREN, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(efx, spi, spi->erase_command, start, NULL,
+			    NULL, 0);
+	if (rc)
+		return rc;
+	rc = falcon_spi_slow_wait(part, false);
+
+	/* Verify the entire region has been wiped */
+	memset(empty, 0xff, sizeof(empty));
+	for (pos = 0; pos < len; pos += block_len) {
+		block_len = min(len - pos, sizeof(buffer));
+		rc = falcon_spi_read(efx, spi, start + pos, block_len,
+				     NULL, buffer);
+		if (rc)
+			return rc;
+		if (memcmp(empty, buffer, block_len))
+			return -EIO;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current))
+			return -EINTR;
+	}
+
+	return rc;
+}
+
+static void falcon_mtd_rename(struct ef4_mtd_partition *part)
+{
+	struct ef4_nic *efx = part->mtd.priv;
+
+	snprintf(part->name, sizeof(part->name), "%s %s",
+		 efx->name, part->type_name);
+}
+
+static int falcon_mtd_read(struct mtd_info *mtd, loff_t start,
+			   size_t len, size_t *retlen, u8 *buffer)
+{
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
+	struct ef4_nic *efx = mtd->priv;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	rc = mutex_lock_interruptible(&nic_data->spi_lock);
+	if (rc)
+		return rc;
+	rc = falcon_spi_read(efx, part->spi, part->offset + start,
+			     len, retlen, buffer);
+	mutex_unlock(&nic_data->spi_lock);
+	return rc;
+}
+
+static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
+{
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
+	struct ef4_nic *efx = mtd->priv;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	rc = mutex_lock_interruptible(&nic_data->spi_lock);
+	if (rc)
+		return rc;
+	rc = falcon_spi_erase(part, part->offset + start, len);
+	mutex_unlock(&nic_data->spi_lock);
+	return rc;
+}
+
+static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
+			    size_t len, size_t *retlen, const u8 *buffer)
+{
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
+	struct ef4_nic *efx = mtd->priv;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	rc = mutex_lock_interruptible(&nic_data->spi_lock);
+	if (rc)
+		return rc;
+	rc = falcon_spi_write(efx, part->spi, part->offset + start,
+			      len, retlen, buffer);
+	mutex_unlock(&nic_data->spi_lock);
+	return rc;
+}
+
+static int falcon_mtd_sync(struct mtd_info *mtd)
+{
+	struct falcon_mtd_partition *part = to_falcon_mtd_partition(mtd);
+	struct ef4_nic *efx = mtd->priv;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	mutex_lock(&nic_data->spi_lock);
+	rc = falcon_spi_slow_wait(part, true);
+	mutex_unlock(&nic_data->spi_lock);
+	return rc;
+}
+
+static int falcon_mtd_probe(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct falcon_mtd_partition *parts;
+	struct falcon_spi_device *spi;
+	size_t n_parts;
+	int rc = -ENODEV;
+
+	ASSERT_RTNL();
+
+	/* Allocate space for maximum number of partitions */
+	parts = kcalloc(2, sizeof(*parts), GFP_KERNEL);
+	if (!parts)
+		return -ENOMEM;
+	n_parts = 0;
+
+	spi = &nic_data->spi_flash;
+	if (falcon_spi_present(spi) && spi->size > FALCON_FLASH_BOOTCODE_START) {
+		parts[n_parts].spi = spi;
+		parts[n_parts].offset = FALCON_FLASH_BOOTCODE_START;
+		parts[n_parts].common.dev_type_name = "flash";
+		parts[n_parts].common.type_name = "sfc_flash_bootrom";
+		parts[n_parts].common.mtd.type = MTD_NORFLASH;
+		parts[n_parts].common.mtd.flags = MTD_CAP_NORFLASH;
+		parts[n_parts].common.mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
+		parts[n_parts].common.mtd.erasesize = spi->erase_size;
+		n_parts++;
+	}
+
+	spi = &nic_data->spi_eeprom;
+	if (falcon_spi_present(spi) && spi->size > FALCON_EEPROM_BOOTCONFIG_START) {
+		parts[n_parts].spi = spi;
+		parts[n_parts].offset = FALCON_EEPROM_BOOTCONFIG_START;
+		parts[n_parts].common.dev_type_name = "EEPROM";
+		parts[n_parts].common.type_name = "sfc_bootconfig";
+		parts[n_parts].common.mtd.type = MTD_RAM;
+		parts[n_parts].common.mtd.flags = MTD_CAP_RAM;
+		parts[n_parts].common.mtd.size =
+			min(spi->size, FALCON_EEPROM_BOOTCONFIG_END) -
+			FALCON_EEPROM_BOOTCONFIG_START;
+		parts[n_parts].common.mtd.erasesize = spi->erase_size;
+		n_parts++;
+	}
+
+	rc = ef4_mtd_add(efx, &parts[0].common, n_parts, sizeof(*parts));
+	if (rc)
+		kfree(parts);
+	return rc;
+}
+
+#endif /* CONFIG_SFC_FALCON_MTD */
+
+/**************************************************************************
+ *
+ * XMAC operations
+ *
+ **************************************************************************
+ */
+
+/* Configure the XAUI driver that is an output from Falcon */
+static void falcon_setup_xaui(struct ef4_nic *efx)
+{
+	ef4_oword_t sdctl, txdrv;
+
+	/* Move the XAUI into low power, unless there is no PHY, in
+	 * which case the XAUI will have to drive a cable. */
+	if (efx->phy_type == PHY_TYPE_NONE)
+		return;
+
+	ef4_reado(efx, &sdctl, FR_AB_XX_SD_CTL);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVC, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVC, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVB, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVB, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EF4_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
+	ef4_writeo(efx, &sdctl, FR_AB_XX_SD_CTL);
+
+	EF4_POPULATE_OWORD_8(txdrv,
+			     FRF_AB_XX_DEQD, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DEQC, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DEQB, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DEQA, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DTXD, FFE_AB_XX_TXDRV_DTX_DEF,
+			     FRF_AB_XX_DTXC, FFE_AB_XX_TXDRV_DTX_DEF,
+			     FRF_AB_XX_DTXB, FFE_AB_XX_TXDRV_DTX_DEF,
+			     FRF_AB_XX_DTXA, FFE_AB_XX_TXDRV_DTX_DEF);
+	ef4_writeo(efx, &txdrv, FR_AB_XX_TXDRV_CTL);
+}
+
+int falcon_reset_xaui(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t reg;
+	int count;
+
+	/* Don't fetch MAC statistics over an XMAC reset */
+	WARN_ON(nic_data->stats_disable_count == 0);
+
+	/* Start reset sequence */
+	EF4_POPULATE_OWORD_1(reg, FRF_AB_XX_RST_XX_EN, 1);
+	ef4_writeo(efx, &reg, FR_AB_XX_PWR_RST);
+
+	/* Wait up to 10 ms for completion, then reinitialise */
+	for (count = 0; count < 1000; count++) {
+		ef4_reado(efx, &reg, FR_AB_XX_PWR_RST);
+		if (EF4_OWORD_FIELD(reg, FRF_AB_XX_RST_XX_EN) == 0 &&
+		    EF4_OWORD_FIELD(reg, FRF_AB_XX_SD_RST_ACT) == 0) {
+			falcon_setup_xaui(efx);
+			return 0;
+		}
+		udelay(10);
+	}
+	netif_err(efx, hw, efx->net_dev,
+		  "timed out waiting for XAUI/XGXS reset\n");
+	return -ETIMEDOUT;
+}
+
+static void falcon_ack_status_intr(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t reg;
+
+	if ((ef4_nic_rev(efx) != EF4_REV_FALCON_B0) || LOOPBACK_INTERNAL(efx))
+		return;
+
+	/* We expect xgmii faults if the wireside link is down */
+	if (!efx->link_state.up)
+		return;
+
+	/* We can only use this interrupt to signal the negative edge of
+	 * xaui_align [we have to poll the positive edge]. */
+	if (nic_data->xmac_poll_required)
+		return;
+
+	ef4_reado(efx, &reg, FR_AB_XM_MGT_INT_MSK);
+}
+
+static bool falcon_xgxs_link_ok(struct ef4_nic *efx)
+{
+	ef4_oword_t reg;
+	bool align_done, link_ok = false;
+	int sync_status;
+
+	/* Read link status */
+	ef4_reado(efx, &reg, FR_AB_XX_CORE_STAT);
+
+	align_done = EF4_OWORD_FIELD(reg, FRF_AB_XX_ALIGN_DONE);
+	sync_status = EF4_OWORD_FIELD(reg, FRF_AB_XX_SYNC_STAT);
+	if (align_done && (sync_status == FFE_AB_XX_STAT_ALL_LANES))
+		link_ok = true;
+
+	/* Clear link status ready for next read */
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_COMMA_DET, FFE_AB_XX_STAT_ALL_LANES);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_CHAR_ERR, FFE_AB_XX_STAT_ALL_LANES);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_DISPERR, FFE_AB_XX_STAT_ALL_LANES);
+	ef4_writeo(efx, &reg, FR_AB_XX_CORE_STAT);
+
+	return link_ok;
+}
+
+static bool falcon_xmac_link_ok(struct ef4_nic *efx)
+{
+	/*
+	 * Check MAC's XGXS link status except when using XGMII loopback
+	 * which bypasses the XGXS block.
+	 * If possible, check PHY's XGXS link status except when using
+	 * MAC loopback.
+	 */
+	return (efx->loopback_mode == LOOPBACK_XGMII ||
+		falcon_xgxs_link_ok(efx)) &&
+		(!(efx->mdio.mmds & (1 << MDIO_MMD_PHYXS)) ||
+		 LOOPBACK_INTERNAL(efx) ||
+		 ef4_mdio_phyxgxs_lane_sync(efx));
+}
+
+static void falcon_reconfigure_xmac_core(struct ef4_nic *efx)
+{
+	unsigned int max_frame_len;
+	ef4_oword_t reg;
+	bool rx_fc = !!(efx->link_state.fc & EF4_FC_RX);
+	bool tx_fc = !!(efx->link_state.fc & EF4_FC_TX);
+
+	/* Configure MAC  - cut-thru mode is hard wired on */
+	EF4_POPULATE_OWORD_3(reg,
+			     FRF_AB_XM_RX_JUMBO_MODE, 1,
+			     FRF_AB_XM_TX_STAT_EN, 1,
+			     FRF_AB_XM_RX_STAT_EN, 1);
+	ef4_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
+
+	/* Configure TX */
+	EF4_POPULATE_OWORD_6(reg,
+			     FRF_AB_XM_TXEN, 1,
+			     FRF_AB_XM_TX_PRMBL, 1,
+			     FRF_AB_XM_AUTO_PAD, 1,
+			     FRF_AB_XM_TXCRC, 1,
+			     FRF_AB_XM_FCNTL, tx_fc,
+			     FRF_AB_XM_IPG, 0x3);
+	ef4_writeo(efx, &reg, FR_AB_XM_TX_CFG);
+
+	/* Configure RX */
+	EF4_POPULATE_OWORD_5(reg,
+			     FRF_AB_XM_RXEN, 1,
+			     FRF_AB_XM_AUTO_DEPAD, 0,
+			     FRF_AB_XM_ACPT_ALL_MCAST, 1,
+			     FRF_AB_XM_ACPT_ALL_UCAST, !efx->unicast_filter,
+			     FRF_AB_XM_PASS_CRC_ERR, 1);
+	ef4_writeo(efx, &reg, FR_AB_XM_RX_CFG);
+
+	/* Set frame length */
+	max_frame_len = EF4_MAX_FRAME_LEN(efx->net_dev->mtu);
+	EF4_POPULATE_OWORD_1(reg, FRF_AB_XM_MAX_RX_FRM_SIZE, max_frame_len);
+	ef4_writeo(efx, &reg, FR_AB_XM_RX_PARAM);
+	EF4_POPULATE_OWORD_2(reg,
+			     FRF_AB_XM_MAX_TX_FRM_SIZE, max_frame_len,
+			     FRF_AB_XM_TX_JUMBO_MODE, 1);
+	ef4_writeo(efx, &reg, FR_AB_XM_TX_PARAM);
+
+	EF4_POPULATE_OWORD_2(reg,
+			     FRF_AB_XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
+			     FRF_AB_XM_DIS_FCNTL, !rx_fc);
+	ef4_writeo(efx, &reg, FR_AB_XM_FC);
+
+	/* Set MAC address */
+	memcpy(&reg, &efx->net_dev->dev_addr[0], 4);
+	ef4_writeo(efx, &reg, FR_AB_XM_ADR_LO);
+	memcpy(&reg, &efx->net_dev->dev_addr[4], 2);
+	ef4_writeo(efx, &reg, FR_AB_XM_ADR_HI);
+}
+
+static void falcon_reconfigure_xgxs_core(struct ef4_nic *efx)
+{
+	ef4_oword_t reg;
+	bool xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS);
+	bool xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI);
+	bool xgmii_loopback = (efx->loopback_mode == LOOPBACK_XGMII);
+	bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
+
+	/* XGXS block is flaky and will need to be reset if moving
+	 * into our out of XGMII, XGXS or XAUI loopbacks. */
+	ef4_reado(efx, &reg, FR_AB_XX_CORE_STAT);
+	old_xgxs_loopback = EF4_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN);
+	old_xgmii_loopback = EF4_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN);
+
+	ef4_reado(efx, &reg, FR_AB_XX_SD_CTL);
+	old_xaui_loopback = EF4_OWORD_FIELD(reg, FRF_AB_XX_LPBKA);
+
+	/* The PHY driver may have turned XAUI off */
+	if ((xgxs_loopback != old_xgxs_loopback) ||
+	    (xaui_loopback != old_xaui_loopback) ||
+	    (xgmii_loopback != old_xgmii_loopback))
+		falcon_reset_xaui(efx);
+
+	ef4_reado(efx, &reg, FR_AB_XX_CORE_STAT);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_FORCE_SIG,
+			    (xgxs_loopback || xaui_loopback) ?
+			    FFE_AB_XX_FORCE_SIG_ALL_LANES : 0);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN, xgxs_loopback);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN, xgmii_loopback);
+	ef4_writeo(efx, &reg, FR_AB_XX_CORE_STAT);
+
+	ef4_reado(efx, &reg, FR_AB_XX_SD_CTL);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKD, xaui_loopback);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKC, xaui_loopback);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKB, xaui_loopback);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKA, xaui_loopback);
+	ef4_writeo(efx, &reg, FR_AB_XX_SD_CTL);
+}
+
+
+/* Try to bring up the Falcon side of the Falcon-Phy XAUI link */
+static bool falcon_xmac_link_ok_retry(struct ef4_nic *efx, int tries)
+{
+	bool mac_up = falcon_xmac_link_ok(efx);
+
+	if (LOOPBACK_MASK(efx) & LOOPBACKS_EXTERNAL(efx) & LOOPBACKS_WS ||
+	    ef4_phy_mode_disabled(efx->phy_mode))
+		/* XAUI link is expected to be down */
+		return mac_up;
+
+	falcon_stop_nic_stats(efx);
+
+	while (!mac_up && tries) {
+		netif_dbg(efx, hw, efx->net_dev, "bashing xaui\n");
+		falcon_reset_xaui(efx);
+		udelay(200);
+
+		mac_up = falcon_xmac_link_ok(efx);
+		--tries;
+	}
+
+	falcon_start_nic_stats(efx);
+
+	return mac_up;
+}
+
+static bool falcon_xmac_check_fault(struct ef4_nic *efx)
+{
+	return !falcon_xmac_link_ok_retry(efx, 5);
+}
+
+static int falcon_reconfigure_xmac(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
+	ef4_farch_filter_sync_rx_mode(efx);
+
+	falcon_reconfigure_xgxs_core(efx);
+	falcon_reconfigure_xmac_core(efx);
+
+	falcon_reconfigure_mac_wrapper(efx);
+
+	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 5);
+	falcon_ack_status_intr(efx);
+
+	return 0;
+}
+
+static void falcon_poll_xmac(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
+	/* We expect xgmii faults if the wireside link is down */
+	if (!efx->link_state.up || !nic_data->xmac_poll_required)
+		return;
+
+	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 1);
+	falcon_ack_status_intr(efx);
+}
+
+/**************************************************************************
+ *
+ * MAC wrapper
+ *
+ **************************************************************************
+ */
+
+static void falcon_push_multicast_hash(struct ef4_nic *efx)
+{
+	union ef4_multicast_hash *mc_hash = &efx->multicast_hash;
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
+	ef4_writeo(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
+	ef4_writeo(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
+}
+
+static void falcon_reset_macs(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t reg, mac_ctrl;
+	int count;
+
+	if (ef4_nic_rev(efx) < EF4_REV_FALCON_B0) {
+		/* It's not safe to use GLB_CTL_REG to reset the
+		 * macs, so instead use the internal MAC resets
+		 */
+		EF4_POPULATE_OWORD_1(reg, FRF_AB_XM_CORE_RST, 1);
+		ef4_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
+
+		for (count = 0; count < 10000; count++) {
+			ef4_reado(efx, &reg, FR_AB_XM_GLB_CFG);
+			if (EF4_OWORD_FIELD(reg, FRF_AB_XM_CORE_RST) ==
+			    0)
+				return;
+			udelay(10);
+		}
+
+		netif_err(efx, hw, efx->net_dev,
+			  "timed out waiting for XMAC core reset\n");
+	}
+
+	/* Mac stats will fail whist the TX fifo is draining */
+	WARN_ON(nic_data->stats_disable_count == 0);
+
+	ef4_reado(efx, &mac_ctrl, FR_AB_MAC_CTRL);
+	EF4_SET_OWORD_FIELD(mac_ctrl, FRF_BB_TXFIFO_DRAIN_EN, 1);
+	ef4_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
+
+	ef4_reado(efx, &reg, FR_AB_GLB_CTL);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_RST_XGTX, 1);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_RST_XGRX, 1);
+	EF4_SET_OWORD_FIELD(reg, FRF_AB_RST_EM, 1);
+	ef4_writeo(efx, &reg, FR_AB_GLB_CTL);
+
+	count = 0;
+	while (1) {
+		ef4_reado(efx, &reg, FR_AB_GLB_CTL);
+		if (!EF4_OWORD_FIELD(reg, FRF_AB_RST_XGTX) &&
+		    !EF4_OWORD_FIELD(reg, FRF_AB_RST_XGRX) &&
+		    !EF4_OWORD_FIELD(reg, FRF_AB_RST_EM)) {
+			netif_dbg(efx, hw, efx->net_dev,
+				  "Completed MAC reset after %d loops\n",
+				  count);
+			break;
+		}
+		if (count > 20) {
+			netif_err(efx, hw, efx->net_dev, "MAC reset failed\n");
+			break;
+		}
+		count++;
+		udelay(10);
+	}
+
+	/* Ensure the correct MAC is selected before statistics
+	 * are re-enabled by the caller */
+	ef4_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
+
+	falcon_setup_xaui(efx);
+}
+
+static void falcon_drain_tx_fifo(struct ef4_nic *efx)
+{
+	ef4_oword_t reg;
+
+	if ((ef4_nic_rev(efx) < EF4_REV_FALCON_B0) ||
+	    (efx->loopback_mode != LOOPBACK_NONE))
+		return;
+
+	ef4_reado(efx, &reg, FR_AB_MAC_CTRL);
+	/* There is no point in draining more than once */
+	if (EF4_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN))
+		return;
+
+	falcon_reset_macs(efx);
+}
+
+static void falcon_deconfigure_mac_wrapper(struct ef4_nic *efx)
+{
+	ef4_oword_t reg;
+
+	if (ef4_nic_rev(efx) < EF4_REV_FALCON_B0)
+		return;
+
+	/* Isolate the MAC -> RX */
+	ef4_reado(efx, &reg, FR_AZ_RX_CFG);
+	EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 0);
+	ef4_writeo(efx, &reg, FR_AZ_RX_CFG);
+
+	/* Isolate TX -> MAC */
+	falcon_drain_tx_fifo(efx);
+}
+
+static void falcon_reconfigure_mac_wrapper(struct ef4_nic *efx)
+{
+	struct ef4_link_state *link_state = &efx->link_state;
+	ef4_oword_t reg;
+	int link_speed, isolate;
+
+	isolate = !!ACCESS_ONCE(efx->reset_pending);
+
+	switch (link_state->speed) {
+	case 10000: link_speed = 3; break;
+	case 1000:  link_speed = 2; break;
+	case 100:   link_speed = 1; break;
+	default:    link_speed = 0; break;
+	}
+
+	/* MAC_LINK_STATUS controls MAC backpressure but doesn't work
+	 * as advertised.  Disable to ensure packets are not
+	 * indefinitely held and TX queue can be flushed at any point
+	 * while the link is down. */
+	EF4_POPULATE_OWORD_5(reg,
+			     FRF_AB_MAC_XOFF_VAL, 0xffff /* max pause time */,
+			     FRF_AB_MAC_BCAD_ACPT, 1,
+			     FRF_AB_MAC_UC_PROM, !efx->unicast_filter,
+			     FRF_AB_MAC_LINK_STATUS, 1, /* always set */
+			     FRF_AB_MAC_SPEED, link_speed);
+	/* On B0, MAC backpressure can be disabled and packets get
+	 * discarded. */
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) {
+		EF4_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN,
+				    !link_state->up || isolate);
+	}
+
+	ef4_writeo(efx, &reg, FR_AB_MAC_CTRL);
+
+	/* Restore the multicast hash registers. */
+	falcon_push_multicast_hash(efx);
+
+	ef4_reado(efx, &reg, FR_AZ_RX_CFG);
+	/* Enable XOFF signal from RX FIFO (we enabled it during NIC
+	 * initialisation but it may read back as 0) */
+	EF4_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, 1);
+	/* Unisolate the MAC -> RX */
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0)
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, !isolate);
+	ef4_writeo(efx, &reg, FR_AZ_RX_CFG);
+}
+
+static void falcon_stats_request(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t reg;
+
+	WARN_ON(nic_data->stats_pending);
+	WARN_ON(nic_data->stats_disable_count);
+
+	FALCON_XMAC_STATS_DMA_FLAG(efx) = 0;
+	nic_data->stats_pending = true;
+	wmb(); /* ensure done flag is clear */
+
+	/* Initiate DMA transfer of stats */
+	EF4_POPULATE_OWORD_2(reg,
+			     FRF_AB_MAC_STAT_DMA_CMD, 1,
+			     FRF_AB_MAC_STAT_DMA_ADR,
+			     efx->stats_buffer.dma_addr);
+	ef4_writeo(efx, &reg, FR_AB_MAC_STAT_DMA);
+
+	mod_timer(&nic_data->stats_timer, round_jiffies_up(jiffies + HZ / 2));
+}
+
+static void falcon_stats_complete(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
+	if (!nic_data->stats_pending)
+		return;
+
+	nic_data->stats_pending = false;
+	if (FALCON_XMAC_STATS_DMA_FLAG(efx)) {
+		rmb(); /* read the done flag before the stats */
+		ef4_nic_update_stats(falcon_stat_desc, FALCON_STAT_COUNT,
+				     falcon_stat_mask, nic_data->stats,
+				     efx->stats_buffer.addr, true);
+	} else {
+		netif_err(efx, hw, efx->net_dev,
+			  "timed out waiting for statistics\n");
+	}
+}
+
+static void falcon_stats_timer_func(unsigned long context)
+{
+	struct ef4_nic *efx = (struct ef4_nic *)context;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
+	spin_lock(&efx->stats_lock);
+
+	falcon_stats_complete(efx);
+	if (nic_data->stats_disable_count == 0)
+		falcon_stats_request(efx);
+
+	spin_unlock(&efx->stats_lock);
+}
+
+static bool falcon_loopback_link_poll(struct ef4_nic *efx)
+{
+	struct ef4_link_state old_state = efx->link_state;
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+	WARN_ON(!LOOPBACK_INTERNAL(efx));
+
+	efx->link_state.fd = true;
+	efx->link_state.fc = efx->wanted_fc;
+	efx->link_state.up = true;
+	efx->link_state.speed = 10000;
+
+	return !ef4_link_state_equal(&efx->link_state, &old_state);
+}
+
+static int falcon_reconfigure_port(struct ef4_nic *efx)
+{
+	int rc;
+
+	WARN_ON(ef4_nic_rev(efx) > EF4_REV_FALCON_B0);
+
+	/* Poll the PHY link state *before* reconfiguring it. This means we
+	 * will pick up the correct speed (in loopback) to select the correct
+	 * MAC.
+	 */
+	if (LOOPBACK_INTERNAL(efx))
+		falcon_loopback_link_poll(efx);
+	else
+		efx->phy_op->poll(efx);
+
+	falcon_stop_nic_stats(efx);
+	falcon_deconfigure_mac_wrapper(efx);
+
+	falcon_reset_macs(efx);
+
+	efx->phy_op->reconfigure(efx);
+	rc = falcon_reconfigure_xmac(efx);
+	BUG_ON(rc);
+
+	falcon_start_nic_stats(efx);
+
+	/* Synchronise efx->link_state with the kernel */
+	ef4_link_status_changed(efx);
+
+	return 0;
+}
+
+/* TX flow control may automatically turn itself off if the link
+ * partner (intermittently) stops responding to pause frames. There
+ * isn't any indication that this has happened, so the best we do is
+ * leave it up to the user to spot this and fix it by cycling transmit
+ * flow control on this end.
+ */
+
+static void falcon_a1_prepare_enable_fc_tx(struct ef4_nic *efx)
+{
+	/* Schedule a reset to recover */
+	ef4_schedule_reset(efx, RESET_TYPE_INVISIBLE);
+}
+
+static void falcon_b0_prepare_enable_fc_tx(struct ef4_nic *efx)
+{
+	/* Recover by resetting the EM block */
+	falcon_stop_nic_stats(efx);
+	falcon_drain_tx_fifo(efx);
+	falcon_reconfigure_xmac(efx);
+	falcon_start_nic_stats(efx);
+}
+
+/**************************************************************************
+ *
+ * PHY access via GMII
+ *
+ **************************************************************************
+ */
+
+/* Wait for GMII access to complete */
+static int falcon_gmii_wait(struct ef4_nic *efx)
+{
+	ef4_oword_t md_stat;
+	int count;
+
+	/* wait up to 50ms - taken max from datasheet */
+	for (count = 0; count < 5000; count++) {
+		ef4_reado(efx, &md_stat, FR_AB_MD_STAT);
+		if (EF4_OWORD_FIELD(md_stat, FRF_AB_MD_BSY) == 0) {
+			if (EF4_OWORD_FIELD(md_stat, FRF_AB_MD_LNFL) != 0 ||
+			    EF4_OWORD_FIELD(md_stat, FRF_AB_MD_BSERR) != 0) {
+				netif_err(efx, hw, efx->net_dev,
+					  "error from GMII access "
+					  EF4_OWORD_FMT"\n",
+					  EF4_OWORD_VAL(md_stat));
+				return -EIO;
+			}
+			return 0;
+		}
+		udelay(10);
+	}
+	netif_err(efx, hw, efx->net_dev, "timed out waiting for GMII\n");
+	return -ETIMEDOUT;
+}
+
+/* Write an MDIO register of a PHY connected to Falcon. */
+static int falcon_mdio_write(struct net_device *net_dev,
+			     int prtad, int devad, u16 addr, u16 value)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t reg;
+	int rc;
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing MDIO %d register %d.%d with 0x%04x\n",
+		    prtad, devad, addr, value);
+
+	mutex_lock(&nic_data->mdio_lock);
+
+	/* Check MDIO not currently being accessed */
+	rc = falcon_gmii_wait(efx);
+	if (rc)
+		goto out;
+
+	/* Write the address/ID register */
+	EF4_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
+	ef4_writeo(efx, &reg, FR_AB_MD_PHY_ADR);
+
+	EF4_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
+			     FRF_AB_MD_DEV_ADR, devad);
+	ef4_writeo(efx, &reg, FR_AB_MD_ID);
+
+	/* Write data */
+	EF4_POPULATE_OWORD_1(reg, FRF_AB_MD_TXD, value);
+	ef4_writeo(efx, &reg, FR_AB_MD_TXD);
+
+	EF4_POPULATE_OWORD_2(reg,
+			     FRF_AB_MD_WRC, 1,
+			     FRF_AB_MD_GC, 0);
+	ef4_writeo(efx, &reg, FR_AB_MD_CS);
+
+	/* Wait for data to be written */
+	rc = falcon_gmii_wait(efx);
+	if (rc) {
+		/* Abort the write operation */
+		EF4_POPULATE_OWORD_2(reg,
+				     FRF_AB_MD_WRC, 0,
+				     FRF_AB_MD_GC, 1);
+		ef4_writeo(efx, &reg, FR_AB_MD_CS);
+		udelay(10);
+	}
+
+out:
+	mutex_unlock(&nic_data->mdio_lock);
+	return rc;
+}
+
+/* Read an MDIO register of a PHY connected to Falcon. */
+static int falcon_mdio_read(struct net_device *net_dev,
+			    int prtad, int devad, u16 addr)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t reg;
+	int rc;
+
+	mutex_lock(&nic_data->mdio_lock);
+
+	/* Check MDIO not currently being accessed */
+	rc = falcon_gmii_wait(efx);
+	if (rc)
+		goto out;
+
+	EF4_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
+	ef4_writeo(efx, &reg, FR_AB_MD_PHY_ADR);
+
+	EF4_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
+			     FRF_AB_MD_DEV_ADR, devad);
+	ef4_writeo(efx, &reg, FR_AB_MD_ID);
+
+	/* Request data to be read */
+	EF4_POPULATE_OWORD_2(reg, FRF_AB_MD_RDC, 1, FRF_AB_MD_GC, 0);
+	ef4_writeo(efx, &reg, FR_AB_MD_CS);
+
+	/* Wait for data to become available */
+	rc = falcon_gmii_wait(efx);
+	if (rc == 0) {
+		ef4_reado(efx, &reg, FR_AB_MD_RXD);
+		rc = EF4_OWORD_FIELD(reg, FRF_AB_MD_RXD);
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "read from MDIO %d register %d.%d, got %04x\n",
+			   prtad, devad, addr, rc);
+	} else {
+		/* Abort the read operation */
+		EF4_POPULATE_OWORD_2(reg,
+				     FRF_AB_MD_RIC, 0,
+				     FRF_AB_MD_GC, 1);
+		ef4_writeo(efx, &reg, FR_AB_MD_CS);
+
+		netif_dbg(efx, hw, efx->net_dev,
+			  "read from MDIO %d register %d.%d, got error %d\n",
+			  prtad, devad, addr, rc);
+	}
+
+out:
+	mutex_unlock(&nic_data->mdio_lock);
+	return rc;
+}
+
+/* This call is responsible for hooking in the MAC and PHY operations */
+static int falcon_probe_port(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	switch (efx->phy_type) {
+	case PHY_TYPE_SFX7101:
+		efx->phy_op = &falcon_sfx7101_phy_ops;
+		break;
+	case PHY_TYPE_QT2022C2:
+	case PHY_TYPE_QT2025C:
+		efx->phy_op = &falcon_qt202x_phy_ops;
+		break;
+	case PHY_TYPE_TXC43128:
+		efx->phy_op = &falcon_txc_phy_ops;
+		break;
+	default:
+		netif_err(efx, probe, efx->net_dev, "Unknown PHY type %d\n",
+			  efx->phy_type);
+		return -ENODEV;
+	}
+
+	/* Fill out MDIO structure and loopback modes */
+	mutex_init(&nic_data->mdio_lock);
+	efx->mdio.mdio_read = falcon_mdio_read;
+	efx->mdio.mdio_write = falcon_mdio_write;
+	rc = efx->phy_op->probe(efx);
+	if (rc != 0)
+		return rc;
+
+	/* Initial assumption */
+	efx->link_state.speed = 10000;
+	efx->link_state.fd = true;
+
+	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0)
+		efx->wanted_fc = EF4_FC_RX | EF4_FC_TX;
+	else
+		efx->wanted_fc = EF4_FC_RX;
+	if (efx->mdio.mmds & MDIO_DEVS_AN)
+		efx->wanted_fc |= EF4_FC_AUTO;
+
+	/* Allocate buffer for stats */
+	rc = ef4_nic_alloc_buffer(efx, &efx->stats_buffer,
+				  FALCON_MAC_STATS_SIZE, GFP_KERNEL);
+	if (rc)
+		return rc;
+	netif_dbg(efx, probe, efx->net_dev,
+		  "stats buffer at %llx (virt %p phys %llx)\n",
+		  (u64)efx->stats_buffer.dma_addr,
+		  efx->stats_buffer.addr,
+		  (u64)virt_to_phys(efx->stats_buffer.addr));
+
+	return 0;
+}
+
+static void falcon_remove_port(struct ef4_nic *efx)
+{
+	efx->phy_op->remove(efx);
+	ef4_nic_free_buffer(efx, &efx->stats_buffer);
+}
+
+/* Global events are basically PHY events */
+static bool
+falcon_handle_global_event(struct ef4_channel *channel, ef4_qword_t *event)
+{
+	struct ef4_nic *efx = channel->efx;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
+	if (EF4_QWORD_FIELD(*event, FSF_AB_GLB_EV_G_PHY0_INTR) ||
+	    EF4_QWORD_FIELD(*event, FSF_AB_GLB_EV_XG_PHY0_INTR) ||
+	    EF4_QWORD_FIELD(*event, FSF_AB_GLB_EV_XFP_PHY0_INTR))
+		/* Ignored */
+		return true;
+
+	if ((ef4_nic_rev(efx) == EF4_REV_FALCON_B0) &&
+	    EF4_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
+		nic_data->xmac_poll_required = true;
+		return true;
+	}
+
+	if (ef4_nic_rev(efx) <= EF4_REV_FALCON_A1 ?
+	    EF4_QWORD_FIELD(*event, FSF_AA_GLB_EV_RX_RECOVERY) :
+	    EF4_QWORD_FIELD(*event, FSF_BB_GLB_EV_RX_RECOVERY)) {
+		netif_err(efx, rx_err, efx->net_dev,
+			  "channel %d seen global RX_RESET event. Resetting.\n",
+			  channel->channel);
+
+		atomic_inc(&efx->rx_reset);
+		ef4_schedule_reset(efx, EF4_WORKAROUND_6555(efx) ?
+				   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
+		return true;
+	}
+
+	return false;
+}
+
+/**************************************************************************
+ *
+ * Falcon test code
+ *
+ **************************************************************************/
+
+static int
+falcon_read_nvram(struct ef4_nic *efx, struct falcon_nvconfig *nvconfig_out)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct falcon_nvconfig *nvconfig;
+	struct falcon_spi_device *spi;
+	void *region;
+	int rc, magic_num, struct_ver;
+	__le16 *word, *limit;
+	u32 csum;
+
+	if (falcon_spi_present(&nic_data->spi_flash))
+		spi = &nic_data->spi_flash;
+	else if (falcon_spi_present(&nic_data->spi_eeprom))
+		spi = &nic_data->spi_eeprom;
+	else
+		return -EINVAL;
+
+	region = kmalloc(FALCON_NVCONFIG_END, GFP_KERNEL);
+	if (!region)
+		return -ENOMEM;
+	nvconfig = region + FALCON_NVCONFIG_OFFSET;
+
+	mutex_lock(&nic_data->spi_lock);
+	rc = falcon_spi_read(efx, spi, 0, FALCON_NVCONFIG_END, NULL, region);
+	mutex_unlock(&nic_data->spi_lock);
+	if (rc) {
+		netif_err(efx, hw, efx->net_dev, "Failed to read %s\n",
+			  falcon_spi_present(&nic_data->spi_flash) ?
+			  "flash" : "EEPROM");
+		rc = -EIO;
+		goto out;
+	}
+
+	magic_num = le16_to_cpu(nvconfig->board_magic_num);
+	struct_ver = le16_to_cpu(nvconfig->board_struct_ver);
+
+	rc = -EINVAL;
+	if (magic_num != FALCON_NVCONFIG_BOARD_MAGIC_NUM) {
+		netif_err(efx, hw, efx->net_dev,
+			  "NVRAM bad magic 0x%x\n", magic_num);
+		goto out;
+	}
+	if (struct_ver < 2) {
+		netif_err(efx, hw, efx->net_dev,
+			  "NVRAM has ancient version 0x%x\n", struct_ver);
+		goto out;
+	} else if (struct_ver < 4) {
+		word = &nvconfig->board_magic_num;
+		limit = (__le16 *) (nvconfig + 1);
+	} else {
+		word = region;
+		limit = region + FALCON_NVCONFIG_END;
+	}
+	for (csum = 0; word < limit; ++word)
+		csum += le16_to_cpu(*word);
+
+	if (~csum & 0xffff) {
+		netif_err(efx, hw, efx->net_dev,
+			  "NVRAM has incorrect checksum\n");
+		goto out;
+	}
+
+	rc = 0;
+	if (nvconfig_out)
+		memcpy(nvconfig_out, nvconfig, sizeof(*nvconfig));
+
+ out:
+	kfree(region);
+	return rc;
+}
+
+static int falcon_test_nvram(struct ef4_nic *efx)
+{
+	return falcon_read_nvram(efx, NULL);
+}
+
+static const struct ef4_farch_register_test falcon_b0_register_tests[] = {
+	{ FR_AZ_ADR_REGION,
+	  EF4_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
+	{ FR_AZ_RX_CFG,
+	  EF4_OWORD32(0xFFFFFFFE, 0x00017FFF, 0x00000000, 0x00000000) },
+	{ FR_AZ_TX_CFG,
+	  EF4_OWORD32(0x7FFF0037, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AZ_TX_RESERVED,
+	  EF4_OWORD32(0xFFFEFE80, 0x1FFFFFFF, 0x020000FE, 0x007FFFFF) },
+	{ FR_AB_MAC_CTRL,
+	  EF4_OWORD32(0xFFFF0000, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AZ_SRM_TX_DC_CFG,
+	  EF4_OWORD32(0x001FFFFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AZ_RX_DC_CFG,
+	  EF4_OWORD32(0x0000000F, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AZ_RX_DC_PF_WM,
+	  EF4_OWORD32(0x000003FF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_BZ_DP_CTRL,
+	  EF4_OWORD32(0x00000FFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_GM_CFG2,
+	  EF4_OWORD32(0x00007337, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_GMF_CFG0,
+	  EF4_OWORD32(0x00001F1F, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_XM_GLB_CFG,
+	  EF4_OWORD32(0x00000C68, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_XM_TX_CFG,
+	  EF4_OWORD32(0x00080164, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_XM_RX_CFG,
+	  EF4_OWORD32(0x07100A0C, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_XM_RX_PARAM,
+	  EF4_OWORD32(0x00001FF8, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_XM_FC,
+	  EF4_OWORD32(0xFFFF0001, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_XM_ADR_LO,
+	  EF4_OWORD32(0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000) },
+	{ FR_AB_XX_SD_CTL,
+	  EF4_OWORD32(0x0003FF0F, 0x00000000, 0x00000000, 0x00000000) },
+};
+
+static int
+falcon_b0_test_chip(struct ef4_nic *efx, struct ef4_self_tests *tests)
+{
+	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
+	int rc, rc2;
+
+	mutex_lock(&efx->mac_lock);
+	if (efx->loopback_modes) {
+		/* We need the 312 clock from the PHY to test the XMAC
+		 * registers, so move into XGMII loopback if available */
+		if (efx->loopback_modes & (1 << LOOPBACK_XGMII))
+			efx->loopback_mode = LOOPBACK_XGMII;
+		else
+			efx->loopback_mode = __ffs(efx->loopback_modes);
+	}
+	__ef4_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	ef4_reset_down(efx, reset_method);
+
+	tests->registers =
+		ef4_farch_test_registers(efx, falcon_b0_register_tests,
+					 ARRAY_SIZE(falcon_b0_register_tests))
+		? -1 : 1;
+
+	rc = falcon_reset_hw(efx, reset_method);
+	rc2 = ef4_reset_up(efx, reset_method, rc == 0);
+	return rc ? rc : rc2;
+}
+
+/**************************************************************************
+ *
+ * Device reset
+ *
+ **************************************************************************
+ */
+
+static enum reset_type falcon_map_reset_reason(enum reset_type reason)
+{
+	switch (reason) {
+	case RESET_TYPE_RX_RECOVERY:
+	case RESET_TYPE_DMA_ERROR:
+	case RESET_TYPE_TX_SKIP:
+		/* These can occasionally occur due to hardware bugs.
+		 * We try to reset without disrupting the link.
+		 */
+		return RESET_TYPE_INVISIBLE;
+	default:
+		return RESET_TYPE_ALL;
+	}
+}
+
+static int falcon_map_reset_flags(u32 *flags)
+{
+	enum {
+		FALCON_RESET_INVISIBLE = (ETH_RESET_DMA | ETH_RESET_FILTER |
+					  ETH_RESET_OFFLOAD | ETH_RESET_MAC),
+		FALCON_RESET_ALL = FALCON_RESET_INVISIBLE | ETH_RESET_PHY,
+		FALCON_RESET_WORLD = FALCON_RESET_ALL | ETH_RESET_IRQ,
+	};
+
+	if ((*flags & FALCON_RESET_WORLD) == FALCON_RESET_WORLD) {
+		*flags &= ~FALCON_RESET_WORLD;
+		return RESET_TYPE_WORLD;
+	}
+
+	if ((*flags & FALCON_RESET_ALL) == FALCON_RESET_ALL) {
+		*flags &= ~FALCON_RESET_ALL;
+		return RESET_TYPE_ALL;
+	}
+
+	if ((*flags & FALCON_RESET_INVISIBLE) == FALCON_RESET_INVISIBLE) {
+		*flags &= ~FALCON_RESET_INVISIBLE;
+		return RESET_TYPE_INVISIBLE;
+	}
+
+	return -EINVAL;
+}
+
+/* Resets NIC to known state.  This routine must be called in process
+ * context and is allowed to sleep. */
+static int __falcon_reset_hw(struct ef4_nic *efx, enum reset_type method)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t glb_ctl_reg_ker;
+	int rc;
+
+	netif_dbg(efx, hw, efx->net_dev, "performing %s hardware reset\n",
+		  RESET_TYPE(method));
+
+	/* Initiate device reset */
+	if (method == RESET_TYPE_WORLD) {
+		rc = pci_save_state(efx->pci_dev);
+		if (rc) {
+			netif_err(efx, drv, efx->net_dev,
+				  "failed to backup PCI state of primary "
+				  "function prior to hardware reset\n");
+			goto fail1;
+		}
+		if (ef4_nic_is_dual_func(efx)) {
+			rc = pci_save_state(nic_data->pci_dev2);
+			if (rc) {
+				netif_err(efx, drv, efx->net_dev,
+					  "failed to backup PCI state of "
+					  "secondary function prior to "
+					  "hardware reset\n");
+				goto fail2;
+			}
+		}
+
+		EF4_POPULATE_OWORD_2(glb_ctl_reg_ker,
+				     FRF_AB_EXT_PHY_RST_DUR,
+				     FFE_AB_EXT_PHY_RST_DUR_10240US,
+				     FRF_AB_SWRST, 1);
+	} else {
+		EF4_POPULATE_OWORD_7(glb_ctl_reg_ker,
+				     /* exclude PHY from "invisible" reset */
+				     FRF_AB_EXT_PHY_RST_CTL,
+				     method == RESET_TYPE_INVISIBLE,
+				     /* exclude EEPROM/flash and PCIe */
+				     FRF_AB_PCIE_CORE_RST_CTL, 1,
+				     FRF_AB_PCIE_NSTKY_RST_CTL, 1,
+				     FRF_AB_PCIE_SD_RST_CTL, 1,
+				     FRF_AB_EE_RST_CTL, 1,
+				     FRF_AB_EXT_PHY_RST_DUR,
+				     FFE_AB_EXT_PHY_RST_DUR_10240US,
+				     FRF_AB_SWRST, 1);
+	}
+	ef4_writeo(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
+
+	netif_dbg(efx, hw, efx->net_dev, "waiting for hardware reset\n");
+	schedule_timeout_uninterruptible(HZ / 20);
+
+	/* Restore PCI configuration if needed */
+	if (method == RESET_TYPE_WORLD) {
+		if (ef4_nic_is_dual_func(efx))
+			pci_restore_state(nic_data->pci_dev2);
+		pci_restore_state(efx->pci_dev);
+		netif_dbg(efx, drv, efx->net_dev,
+			  "successfully restored PCI config\n");
+	}
+
+	/* Assert that reset complete */
+	ef4_reado(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
+	if (EF4_OWORD_FIELD(glb_ctl_reg_ker, FRF_AB_SWRST) != 0) {
+		rc = -ETIMEDOUT;
+		netif_err(efx, hw, efx->net_dev,
+			  "timed out waiting for hardware reset\n");
+		goto fail3;
+	}
+	netif_dbg(efx, hw, efx->net_dev, "hardware reset complete\n");
+
+	return 0;
+
+	/* pci_save_state() and pci_restore_state() MUST be called in pairs */
+fail2:
+	pci_restore_state(efx->pci_dev);
+fail1:
+fail3:
+	return rc;
+}
+
+static int falcon_reset_hw(struct ef4_nic *efx, enum reset_type method)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	mutex_lock(&nic_data->spi_lock);
+	rc = __falcon_reset_hw(efx, method);
+	mutex_unlock(&nic_data->spi_lock);
+
+	return rc;
+}
+
+static void falcon_monitor(struct ef4_nic *efx)
+{
+	bool link_changed;
+	int rc;
+
+	BUG_ON(!mutex_is_locked(&efx->mac_lock));
+
+	rc = falcon_board(efx)->type->monitor(efx);
+	if (rc) {
+		netif_err(efx, hw, efx->net_dev,
+			  "Board sensor %s; shutting down PHY\n",
+			  (rc == -ERANGE) ? "reported fault" : "failed");
+		efx->phy_mode |= PHY_MODE_LOW_POWER;
+		rc = __ef4_reconfigure_port(efx);
+		WARN_ON(rc);
+	}
+
+	if (LOOPBACK_INTERNAL(efx))
+		link_changed = falcon_loopback_link_poll(efx);
+	else
+		link_changed = efx->phy_op->poll(efx);
+
+	if (link_changed) {
+		falcon_stop_nic_stats(efx);
+		falcon_deconfigure_mac_wrapper(efx);
+
+		falcon_reset_macs(efx);
+		rc = falcon_reconfigure_xmac(efx);
+		BUG_ON(rc);
+
+		falcon_start_nic_stats(efx);
+
+		ef4_link_status_changed(efx);
+	}
+
+	falcon_poll_xmac(efx);
+}
+
+/* Zeroes out the SRAM contents.  This routine must be called in
+ * process context and is allowed to sleep.
+ */
+static int falcon_reset_sram(struct ef4_nic *efx)
+{
+	ef4_oword_t srm_cfg_reg_ker, gpio_cfg_reg_ker;
+	int count;
+
+	/* Set the SRAM wake/sleep GPIO appropriately. */
+	ef4_reado(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
+	EF4_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OEN, 1);
+	EF4_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OUT, 1);
+	ef4_writeo(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
+
+	/* Initiate SRAM reset */
+	EF4_POPULATE_OWORD_2(srm_cfg_reg_ker,
+			     FRF_AZ_SRM_INIT_EN, 1,
+			     FRF_AZ_SRM_NB_SZ, 0);
+	ef4_writeo(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
+
+	/* Wait for SRAM reset to complete */
+	count = 0;
+	do {
+		netif_dbg(efx, hw, efx->net_dev,
+			  "waiting for SRAM reset (attempt %d)...\n", count);
+
+		/* SRAM reset is slow; expect around 16ms */
+		schedule_timeout_uninterruptible(HZ / 50);
+
+		/* Check for reset complete */
+		ef4_reado(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
+		if (!EF4_OWORD_FIELD(srm_cfg_reg_ker, FRF_AZ_SRM_INIT_EN)) {
+			netif_dbg(efx, hw, efx->net_dev,
+				  "SRAM reset complete\n");
+
+			return 0;
+		}
+	} while (++count < 20);	/* wait up to 0.4 sec */
+
+	netif_err(efx, hw, efx->net_dev, "timed out waiting for SRAM reset\n");
+	return -ETIMEDOUT;
+}
+
+static void falcon_spi_device_init(struct ef4_nic *efx,
+				  struct falcon_spi_device *spi_device,
+				  unsigned int device_id, u32 device_type)
+{
+	if (device_type != 0) {
+		spi_device->device_id = device_id;
+		spi_device->size =
+			1 << SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_SIZE);
+		spi_device->addr_len =
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ADDR_LEN);
+		spi_device->munge_address = (spi_device->size == 1 << 9 &&
+					     spi_device->addr_len == 1);
+		spi_device->erase_command =
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ERASE_CMD);
+		spi_device->erase_size =
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_ERASE_SIZE);
+		spi_device->block_size =
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_BLOCK_SIZE);
+	} else {
+		spi_device->size = 0;
+	}
+}
+
+/* Extract non-volatile configuration */
+static int falcon_probe_nvconfig(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct falcon_nvconfig *nvconfig;
+	int rc;
+
+	nvconfig = kmalloc(sizeof(*nvconfig), GFP_KERNEL);
+	if (!nvconfig)
+		return -ENOMEM;
+
+	rc = falcon_read_nvram(efx, nvconfig);
+	if (rc)
+		goto out;
+
+	efx->phy_type = nvconfig->board_v2.port0_phy_type;
+	efx->mdio.prtad = nvconfig->board_v2.port0_phy_addr;
+
+	if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
+		falcon_spi_device_init(
+			efx, &nic_data->spi_flash, FFE_AB_SPI_DEVICE_FLASH,
+			le32_to_cpu(nvconfig->board_v3
+				    .spi_device_type[FFE_AB_SPI_DEVICE_FLASH]));
+		falcon_spi_device_init(
+			efx, &nic_data->spi_eeprom, FFE_AB_SPI_DEVICE_EEPROM,
+			le32_to_cpu(nvconfig->board_v3
+				    .spi_device_type[FFE_AB_SPI_DEVICE_EEPROM]));
+	}
+
+	/* Read the MAC addresses */
+	ether_addr_copy(efx->net_dev->perm_addr, nvconfig->mac_address[0]);
+
+	netif_dbg(efx, probe, efx->net_dev, "PHY is %d phy_id %d\n",
+		  efx->phy_type, efx->mdio.prtad);
+
+	rc = falcon_probe_board(efx,
+				le16_to_cpu(nvconfig->board_v2.board_revision));
+out:
+	kfree(nvconfig);
+	return rc;
+}
+
+static int falcon_dimension_resources(struct ef4_nic *efx)
+{
+	efx->rx_dc_base = 0x20000;
+	efx->tx_dc_base = 0x26000;
+	return 0;
+}
+
+/* Probe all SPI devices on the NIC */
+static void falcon_probe_spi_devices(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
+	int boot_dev;
+
+	ef4_reado(efx, &gpio_ctl, FR_AB_GPIO_CTL);
+	ef4_reado(efx, &nic_stat, FR_AB_NIC_STAT);
+	ef4_reado(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
+
+	if (EF4_OWORD_FIELD(gpio_ctl, FRF_AB_GPIO3_PWRUP_VALUE)) {
+		boot_dev = (EF4_OWORD_FIELD(nic_stat, FRF_AB_SF_PRST) ?
+			    FFE_AB_SPI_DEVICE_FLASH : FFE_AB_SPI_DEVICE_EEPROM);
+		netif_dbg(efx, probe, efx->net_dev, "Booted from %s\n",
+			  boot_dev == FFE_AB_SPI_DEVICE_FLASH ?
+			  "flash" : "EEPROM");
+	} else {
+		/* Disable VPD and set clock dividers to safe
+		 * values for initial programming. */
+		boot_dev = -1;
+		netif_dbg(efx, probe, efx->net_dev,
+			  "Booted from internal ASIC settings;"
+			  " setting SPI config\n");
+		EF4_POPULATE_OWORD_3(ee_vpd_cfg, FRF_AB_EE_VPD_EN, 0,
+				     /* 125 MHz / 7 ~= 20 MHz */
+				     FRF_AB_EE_SF_CLOCK_DIV, 7,
+				     /* 125 MHz / 63 ~= 2 MHz */
+				     FRF_AB_EE_EE_CLOCK_DIV, 63);
+		ef4_writeo(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
+	}
+
+	mutex_init(&nic_data->spi_lock);
+
+	if (boot_dev == FFE_AB_SPI_DEVICE_FLASH)
+		falcon_spi_device_init(efx, &nic_data->spi_flash,
+				       FFE_AB_SPI_DEVICE_FLASH,
+				       default_flash_type);
+	if (boot_dev == FFE_AB_SPI_DEVICE_EEPROM)
+		falcon_spi_device_init(efx, &nic_data->spi_eeprom,
+				       FFE_AB_SPI_DEVICE_EEPROM,
+				       large_eeprom_type);
+}
+
+static unsigned int falcon_a1_mem_map_size(struct ef4_nic *efx)
+{
+	return 0x20000;
+}
+
+static unsigned int falcon_b0_mem_map_size(struct ef4_nic *efx)
+{
+	/* Map everything up to and including the RSS indirection table.
+	 * The PCI core takes care of mapping the MSI-X tables.
+	 */
+	return FR_BZ_RX_INDIRECTION_TBL +
+		FR_BZ_RX_INDIRECTION_TBL_STEP * FR_BZ_RX_INDIRECTION_TBL_ROWS;
+}
+
+static int falcon_probe_nic(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data;
+	struct falcon_board *board;
+	int rc;
+
+	efx->primary = efx; /* only one usable function per controller */
+
+	/* Allocate storage for hardware specific data */
+	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
+	if (!nic_data)
+		return -ENOMEM;
+	efx->nic_data = nic_data;
+
+	rc = -ENODEV;
+
+	if (ef4_farch_fpga_ver(efx) != 0) {
+		netif_err(efx, probe, efx->net_dev,
+			  "Falcon FPGA not supported\n");
+		goto fail1;
+	}
+
+	if (ef4_nic_rev(efx) <= EF4_REV_FALCON_A1) {
+		ef4_oword_t nic_stat;
+		struct pci_dev *dev;
+		u8 pci_rev = efx->pci_dev->revision;
+
+		if ((pci_rev == 0xff) || (pci_rev == 0)) {
+			netif_err(efx, probe, efx->net_dev,
+				  "Falcon rev A0 not supported\n");
+			goto fail1;
+		}
+		ef4_reado(efx, &nic_stat, FR_AB_NIC_STAT);
+		if (EF4_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) == 0) {
+			netif_err(efx, probe, efx->net_dev,
+				  "Falcon rev A1 1G not supported\n");
+			goto fail1;
+		}
+		if (EF4_OWORD_FIELD(nic_stat, FRF_AA_STRAP_PCIE) == 0) {
+			netif_err(efx, probe, efx->net_dev,
+				  "Falcon rev A1 PCI-X not supported\n");
+			goto fail1;
+		}
+
+		dev = pci_dev_get(efx->pci_dev);
+		while ((dev = pci_get_device(PCI_VENDOR_ID_SOLARFLARE,
+					     PCI_DEVICE_ID_SOLARFLARE_SFC4000A_1,
+					     dev))) {
+			if (dev->bus == efx->pci_dev->bus &&
+			    dev->devfn == efx->pci_dev->devfn + 1) {
+				nic_data->pci_dev2 = dev;
+				break;
+			}
+		}
+		if (!nic_data->pci_dev2) {
+			netif_err(efx, probe, efx->net_dev,
+				  "failed to find secondary function\n");
+			rc = -ENODEV;
+			goto fail2;
+		}
+	}
+
+	/* Now we can reset the NIC */
+	rc = __falcon_reset_hw(efx, RESET_TYPE_ALL);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev, "failed to reset NIC\n");
+		goto fail3;
+	}
+
+	/* Allocate memory for INT_KER */
+	rc = ef4_nic_alloc_buffer(efx, &efx->irq_status, sizeof(ef4_oword_t),
+				  GFP_KERNEL);
+	if (rc)
+		goto fail4;
+	BUG_ON(efx->irq_status.dma_addr & 0x0f);
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "INT_KER at %llx (virt %p phys %llx)\n",
+		  (u64)efx->irq_status.dma_addr,
+		  efx->irq_status.addr,
+		  (u64)virt_to_phys(efx->irq_status.addr));
+
+	falcon_probe_spi_devices(efx);
+
+	/* Read in the non-volatile configuration */
+	rc = falcon_probe_nvconfig(efx);
+	if (rc) {
+		if (rc == -EINVAL)
+			netif_err(efx, probe, efx->net_dev, "NVRAM is invalid\n");
+		goto fail5;
+	}
+
+	efx->max_channels = (ef4_nic_rev(efx) <= EF4_REV_FALCON_A1 ? 4 :
+			     EF4_MAX_CHANNELS);
+	efx->max_tx_channels = efx->max_channels;
+	efx->timer_quantum_ns = 4968; /* 621 cycles */
+	efx->timer_max_ns = efx->type->timer_period_max *
+			    efx->timer_quantum_ns;
+
+	/* Initialise I2C adapter */
+	board = falcon_board(efx);
+	board->i2c_adap.owner = THIS_MODULE;
+	board->i2c_data = falcon_i2c_bit_operations;
+	board->i2c_data.data = efx;
+	board->i2c_adap.algo_data = &board->i2c_data;
+	board->i2c_adap.dev.parent = &efx->pci_dev->dev;
+	strlcpy(board->i2c_adap.name, "SFC4000 GPIO",
+		sizeof(board->i2c_adap.name));
+	rc = i2c_bit_add_bus(&board->i2c_adap);
+	if (rc)
+		goto fail5;
+
+	rc = falcon_board(efx)->type->init(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to initialise board\n");
+		goto fail6;
+	}
+
+	nic_data->stats_disable_count = 1;
+	setup_timer(&nic_data->stats_timer, &falcon_stats_timer_func,
+		    (unsigned long)efx);
+
+	return 0;
+
+ fail6:
+	i2c_del_adapter(&board->i2c_adap);
+	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
+ fail5:
+	ef4_nic_free_buffer(efx, &efx->irq_status);
+ fail4:
+ fail3:
+	if (nic_data->pci_dev2) {
+		pci_dev_put(nic_data->pci_dev2);
+		nic_data->pci_dev2 = NULL;
+	}
+ fail2:
+ fail1:
+	kfree(efx->nic_data);
+	return rc;
+}
+
+static void falcon_init_rx_cfg(struct ef4_nic *efx)
+{
+	/* RX control FIFO thresholds (32 entries) */
+	const unsigned ctrl_xon_thr = 20;
+	const unsigned ctrl_xoff_thr = 25;
+	ef4_oword_t reg;
+
+	ef4_reado(efx, &reg, FR_AZ_RX_CFG);
+	if (ef4_nic_rev(efx) <= EF4_REV_FALCON_A1) {
+		/* Data FIFO size is 5.5K.  The RX DMA engine only
+		 * supports scattering for user-mode queues, but will
+		 * split DMA writes at intervals of RX_USR_BUF_SIZE
+		 * (32-byte units) even for kernel-mode queues.  We
+		 * set it to be so large that that never happens.
+		 */
+		EF4_SET_OWORD_FIELD(reg, FRF_AA_RX_DESC_PUSH_EN, 0);
+		EF4_SET_OWORD_FIELD(reg, FRF_AA_RX_USR_BUF_SIZE,
+				    (3 * 4096) >> 5);
+		EF4_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_MAC_TH, 512 >> 8);
+		EF4_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_MAC_TH, 2048 >> 8);
+		EF4_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_TX_TH, ctrl_xon_thr);
+		EF4_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_TX_TH, ctrl_xoff_thr);
+	} else {
+		/* Data FIFO size is 80K; register fields moved */
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_DESC_PUSH_EN, 0);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_USR_BUF_SIZE,
+				    EF4_RX_USR_BUF_SIZE >> 5);
+		/* Send XON and XOFF at ~3 * max MTU away from empty/full */
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_MAC_TH, 27648 >> 8);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_MAC_TH, 54272 >> 8);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_TX_TH, ctrl_xon_thr);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
+
+		/* Enable hash insertion. This is broken for the
+		 * 'Falcon' hash so also select Toeplitz TCP/IPv4 and
+		 * IPv4 hashes. */
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_INSRT_HDR, 1);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_HASH_ALG, 1);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_RX_IP_HASH, 1);
+	}
+	/* Always enable XOFF signal from RX FIFO.  We enable
+	 * or disable transmission of pause frames at the MAC. */
+	EF4_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, 1);
+	ef4_writeo(efx, &reg, FR_AZ_RX_CFG);
+}
+
+/* This call performs hardware-specific global initialisation, such as
+ * defining the descriptor cache sizes and number of RSS channels.
+ * It does not set up any buffers, descriptor rings or event queues.
+ */
+static int falcon_init_nic(struct ef4_nic *efx)
+{
+	ef4_oword_t temp;
+	int rc;
+
+	/* Use on-chip SRAM */
+	ef4_reado(efx, &temp, FR_AB_NIC_STAT);
+	EF4_SET_OWORD_FIELD(temp, FRF_AB_ONCHIP_SRAM, 1);
+	ef4_writeo(efx, &temp, FR_AB_NIC_STAT);
+
+	rc = falcon_reset_sram(efx);
+	if (rc)
+		return rc;
+
+	/* Clear the parity enables on the TX data fifos as
+	 * they produce false parity errors because of timing issues
+	 */
+	if (EF4_WORKAROUND_5129(efx)) {
+		ef4_reado(efx, &temp, FR_AZ_CSR_SPARE);
+		EF4_SET_OWORD_FIELD(temp, FRF_AB_MEM_PERR_EN_TX_DATA, 0);
+		ef4_writeo(efx, &temp, FR_AZ_CSR_SPARE);
+	}
+
+	if (EF4_WORKAROUND_7244(efx)) {
+		ef4_reado(efx, &temp, FR_BZ_RX_FILTER_CTL);
+		EF4_SET_OWORD_FIELD(temp, FRF_BZ_UDP_FULL_SRCH_LIMIT, 8);
+		EF4_SET_OWORD_FIELD(temp, FRF_BZ_UDP_WILD_SRCH_LIMIT, 8);
+		EF4_SET_OWORD_FIELD(temp, FRF_BZ_TCP_FULL_SRCH_LIMIT, 8);
+		EF4_SET_OWORD_FIELD(temp, FRF_BZ_TCP_WILD_SRCH_LIMIT, 8);
+		ef4_writeo(efx, &temp, FR_BZ_RX_FILTER_CTL);
+	}
+
+	/* XXX This is documented only for Falcon A0/A1 */
+	/* Setup RX.  Wait for descriptor is broken and must
+	 * be disabled.  RXDP recovery shouldn't be needed, but is.
+	 */
+	ef4_reado(efx, &temp, FR_AA_RX_SELF_RST);
+	EF4_SET_OWORD_FIELD(temp, FRF_AA_RX_NODESC_WAIT_DIS, 1);
+	EF4_SET_OWORD_FIELD(temp, FRF_AA_RX_SELF_RST_EN, 1);
+	if (EF4_WORKAROUND_5583(efx))
+		EF4_SET_OWORD_FIELD(temp, FRF_AA_RX_ISCSI_DIS, 1);
+	ef4_writeo(efx, &temp, FR_AA_RX_SELF_RST);
+
+	/* Do not enable TX_NO_EOP_DISC_EN, since it limits packets to 16
+	 * descriptors (which is bad).
+	 */
+	ef4_reado(efx, &temp, FR_AZ_TX_CFG);
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_NO_EOP_DISC_EN, 0);
+	ef4_writeo(efx, &temp, FR_AZ_TX_CFG);
+
+	falcon_init_rx_cfg(efx);
+
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) {
+		falcon_b0_rx_push_rss_config(efx, false, efx->rx_indir_table);
+
+		/* Set destination of both TX and RX Flush events */
+		EF4_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
+		ef4_writeo(efx, &temp, FR_BZ_DP_CTRL);
+	}
+
+	ef4_farch_init_common(efx);
+
+	return 0;
+}
+
+static void falcon_remove_nic(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct falcon_board *board = falcon_board(efx);
+
+	board->type->fini(efx);
+
+	/* Remove I2C adapter and clear it in preparation for a retry */
+	i2c_del_adapter(&board->i2c_adap);
+	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
+
+	ef4_nic_free_buffer(efx, &efx->irq_status);
+
+	__falcon_reset_hw(efx, RESET_TYPE_ALL);
+
+	/* Release the second function after the reset */
+	if (nic_data->pci_dev2) {
+		pci_dev_put(nic_data->pci_dev2);
+		nic_data->pci_dev2 = NULL;
+	}
+
+	/* Tear down the private nic state */
+	kfree(efx->nic_data);
+	efx->nic_data = NULL;
+}
+
+static size_t falcon_describe_nic_stats(struct ef4_nic *efx, u8 *names)
+{
+	return ef4_nic_describe_stats(falcon_stat_desc, FALCON_STAT_COUNT,
+				      falcon_stat_mask, names);
+}
+
+static size_t falcon_update_nic_stats(struct ef4_nic *efx, u64 *full_stats,
+				      struct rtnl_link_stats64 *core_stats)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	u64 *stats = nic_data->stats;
+	ef4_oword_t cnt;
+
+	if (!nic_data->stats_disable_count) {
+		ef4_reado(efx, &cnt, FR_AZ_RX_NODESC_DROP);
+		stats[FALCON_STAT_rx_nodesc_drop_cnt] +=
+			EF4_OWORD_FIELD(cnt, FRF_AB_RX_NODESC_DROP_CNT);
+
+		if (nic_data->stats_pending &&
+		    FALCON_XMAC_STATS_DMA_FLAG(efx)) {
+			nic_data->stats_pending = false;
+			rmb(); /* read the done flag before the stats */
+			ef4_nic_update_stats(
+				falcon_stat_desc, FALCON_STAT_COUNT,
+				falcon_stat_mask,
+				stats, efx->stats_buffer.addr, true);
+		}
+
+		/* Update derived statistic */
+		ef4_update_diff_stat(&stats[FALCON_STAT_rx_bad_bytes],
+				     stats[FALCON_STAT_rx_bytes] -
+				     stats[FALCON_STAT_rx_good_bytes] -
+				     stats[FALCON_STAT_rx_control] * 64);
+		ef4_update_sw_stats(efx, stats);
+	}
+
+	if (full_stats)
+		memcpy(full_stats, stats, sizeof(u64) * FALCON_STAT_COUNT);
+
+	if (core_stats) {
+		core_stats->rx_packets = stats[FALCON_STAT_rx_packets];
+		core_stats->tx_packets = stats[FALCON_STAT_tx_packets];
+		core_stats->rx_bytes = stats[FALCON_STAT_rx_bytes];
+		core_stats->tx_bytes = stats[FALCON_STAT_tx_bytes];
+		core_stats->rx_dropped = stats[FALCON_STAT_rx_nodesc_drop_cnt] +
+					 stats[GENERIC_STAT_rx_nodesc_trunc] +
+					 stats[GENERIC_STAT_rx_noskb_drops];
+		core_stats->multicast = stats[FALCON_STAT_rx_multicast];
+		core_stats->rx_length_errors =
+			stats[FALCON_STAT_rx_gtjumbo] +
+			stats[FALCON_STAT_rx_length_error];
+		core_stats->rx_crc_errors = stats[FALCON_STAT_rx_bad];
+		core_stats->rx_frame_errors = stats[FALCON_STAT_rx_align_error];
+		core_stats->rx_fifo_errors = stats[FALCON_STAT_rx_overflow];
+
+		core_stats->rx_errors = (core_stats->rx_length_errors +
+					 core_stats->rx_crc_errors +
+					 core_stats->rx_frame_errors +
+					 stats[FALCON_STAT_rx_symbol_error]);
+	}
+
+	return FALCON_STAT_COUNT;
+}
+
+void falcon_start_nic_stats(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+
+	spin_lock_bh(&efx->stats_lock);
+	if (--nic_data->stats_disable_count == 0)
+		falcon_stats_request(efx);
+	spin_unlock_bh(&efx->stats_lock);
+}
+
+/* We don't acutally pull stats on falcon. Wait 10ms so that
+ * they arrive when we call this just after start_stats
+ */
+static void falcon_pull_nic_stats(struct ef4_nic *efx)
+{
+	msleep(10);
+}
+
+void falcon_stop_nic_stats(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	int i;
+
+	might_sleep();
+
+	spin_lock_bh(&efx->stats_lock);
+	++nic_data->stats_disable_count;
+	spin_unlock_bh(&efx->stats_lock);
+
+	del_timer_sync(&nic_data->stats_timer);
+
+	/* Wait enough time for the most recent transfer to
+	 * complete. */
+	for (i = 0; i < 4 && nic_data->stats_pending; i++) {
+		if (FALCON_XMAC_STATS_DMA_FLAG(efx))
+			break;
+		msleep(1);
+	}
+
+	spin_lock_bh(&efx->stats_lock);
+	falcon_stats_complete(efx);
+	spin_unlock_bh(&efx->stats_lock);
+}
+
+static void falcon_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode)
+{
+	falcon_board(efx)->type->set_id_led(efx, mode);
+}
+
+/**************************************************************************
+ *
+ * Wake on LAN
+ *
+ **************************************************************************
+ */
+
+static void falcon_get_wol(struct ef4_nic *efx, struct ethtool_wolinfo *wol)
+{
+	wol->supported = 0;
+	wol->wolopts = 0;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+}
+
+static int falcon_set_wol(struct ef4_nic *efx, u32 type)
+{
+	if (type != 0)
+		return -EINVAL;
+	return 0;
+}
+
+/**************************************************************************
+ *
+ * Revision-dependent attributes used by efx.c and nic.c
+ *
+ **************************************************************************
+ */
+
+const struct ef4_nic_type falcon_a1_nic_type = {
+	.mem_bar = EF4_MEM_BAR,
+	.mem_map_size = falcon_a1_mem_map_size,
+	.probe = falcon_probe_nic,
+	.remove = falcon_remove_nic,
+	.init = falcon_init_nic,
+	.dimension_resources = falcon_dimension_resources,
+	.fini = falcon_irq_ack_a1,
+	.monitor = falcon_monitor,
+	.map_reset_reason = falcon_map_reset_reason,
+	.map_reset_flags = falcon_map_reset_flags,
+	.reset = falcon_reset_hw,
+	.probe_port = falcon_probe_port,
+	.remove_port = falcon_remove_port,
+	.handle_global_event = falcon_handle_global_event,
+	.fini_dmaq = ef4_farch_fini_dmaq,
+	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = ef4_port_dummy_op_void,
+	.prepare_flr = ef4_port_dummy_op_void,
+	.finish_flr = ef4_farch_finish_flr,
+	.describe_stats = falcon_describe_nic_stats,
+	.update_stats = falcon_update_nic_stats,
+	.start_stats = falcon_start_nic_stats,
+	.pull_stats = falcon_pull_nic_stats,
+	.stop_stats = falcon_stop_nic_stats,
+	.set_id_led = falcon_set_id_led,
+	.push_irq_moderation = falcon_push_irq_moderation,
+	.reconfigure_port = falcon_reconfigure_port,
+	.prepare_enable_fc_tx = falcon_a1_prepare_enable_fc_tx,
+	.reconfigure_mac = falcon_reconfigure_xmac,
+	.check_mac_fault = falcon_xmac_check_fault,
+	.get_wol = falcon_get_wol,
+	.set_wol = falcon_set_wol,
+	.resume_wol = ef4_port_dummy_op_void,
+	.test_nvram = falcon_test_nvram,
+	.irq_enable_master = ef4_farch_irq_enable_master,
+	.irq_test_generate = ef4_farch_irq_test_generate,
+	.irq_disable_non_ev = ef4_farch_irq_disable_master,
+	.irq_handle_msi = ef4_farch_msi_interrupt,
+	.irq_handle_legacy = falcon_legacy_interrupt_a1,
+	.tx_probe = ef4_farch_tx_probe,
+	.tx_init = ef4_farch_tx_init,
+	.tx_remove = ef4_farch_tx_remove,
+	.tx_write = ef4_farch_tx_write,
+	.tx_limit_len = ef4_farch_tx_limit_len,
+	.rx_push_rss_config = dummy_rx_push_rss_config,
+	.rx_probe = ef4_farch_rx_probe,
+	.rx_init = ef4_farch_rx_init,
+	.rx_remove = ef4_farch_rx_remove,
+	.rx_write = ef4_farch_rx_write,
+	.rx_defer_refill = ef4_farch_rx_defer_refill,
+	.ev_probe = ef4_farch_ev_probe,
+	.ev_init = ef4_farch_ev_init,
+	.ev_fini = ef4_farch_ev_fini,
+	.ev_remove = ef4_farch_ev_remove,
+	.ev_process = ef4_farch_ev_process,
+	.ev_read_ack = ef4_farch_ev_read_ack,
+	.ev_test_generate = ef4_farch_ev_test_generate,
+
+	/* We don't expose the filter table on Falcon A1 as it is not
+	 * mapped into function 0, but these implementations still
+	 * work with a degenerate case of all tables set to size 0.
+	 */
+	.filter_table_probe = ef4_farch_filter_table_probe,
+	.filter_table_restore = ef4_farch_filter_table_restore,
+	.filter_table_remove = ef4_farch_filter_table_remove,
+	.filter_insert = ef4_farch_filter_insert,
+	.filter_remove_safe = ef4_farch_filter_remove_safe,
+	.filter_get_safe = ef4_farch_filter_get_safe,
+	.filter_clear_rx = ef4_farch_filter_clear_rx,
+	.filter_count_rx_used = ef4_farch_filter_count_rx_used,
+	.filter_get_rx_id_limit = ef4_farch_filter_get_rx_id_limit,
+	.filter_get_rx_ids = ef4_farch_filter_get_rx_ids,
+
+#ifdef CONFIG_SFC_FALCON_MTD
+	.mtd_probe = falcon_mtd_probe,
+	.mtd_rename = falcon_mtd_rename,
+	.mtd_read = falcon_mtd_read,
+	.mtd_erase = falcon_mtd_erase,
+	.mtd_write = falcon_mtd_write,
+	.mtd_sync = falcon_mtd_sync,
+#endif
+
+	.revision = EF4_REV_FALCON_A1,
+	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
+	.rxd_ptr_tbl_base = FR_AA_RX_DESC_PTR_TBL_KER,
+	.buf_tbl_base = FR_AA_BUF_FULL_TBL_KER,
+	.evq_ptr_tbl_base = FR_AA_EVQ_PTR_TBL_KER,
+	.evq_rptr_tbl_base = FR_AA_EVQ_RPTR_KER,
+	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
+	.rx_buffer_padding = 0x24,
+	.can_rx_scatter = false,
+	.max_interrupt_mode = EF4_INT_MODE_MSI,
+	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
+	.offload_features = NETIF_F_IP_CSUM,
+};
+
+const struct ef4_nic_type falcon_b0_nic_type = {
+	.mem_bar = EF4_MEM_BAR,
+	.mem_map_size = falcon_b0_mem_map_size,
+	.probe = falcon_probe_nic,
+	.remove = falcon_remove_nic,
+	.init = falcon_init_nic,
+	.dimension_resources = falcon_dimension_resources,
+	.fini = ef4_port_dummy_op_void,
+	.monitor = falcon_monitor,
+	.map_reset_reason = falcon_map_reset_reason,
+	.map_reset_flags = falcon_map_reset_flags,
+	.reset = falcon_reset_hw,
+	.probe_port = falcon_probe_port,
+	.remove_port = falcon_remove_port,
+	.handle_global_event = falcon_handle_global_event,
+	.fini_dmaq = ef4_farch_fini_dmaq,
+	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = ef4_port_dummy_op_void,
+	.prepare_flr = ef4_port_dummy_op_void,
+	.finish_flr = ef4_farch_finish_flr,
+	.describe_stats = falcon_describe_nic_stats,
+	.update_stats = falcon_update_nic_stats,
+	.start_stats = falcon_start_nic_stats,
+	.pull_stats = falcon_pull_nic_stats,
+	.stop_stats = falcon_stop_nic_stats,
+	.set_id_led = falcon_set_id_led,
+	.push_irq_moderation = falcon_push_irq_moderation,
+	.reconfigure_port = falcon_reconfigure_port,
+	.prepare_enable_fc_tx = falcon_b0_prepare_enable_fc_tx,
+	.reconfigure_mac = falcon_reconfigure_xmac,
+	.check_mac_fault = falcon_xmac_check_fault,
+	.get_wol = falcon_get_wol,
+	.set_wol = falcon_set_wol,
+	.resume_wol = ef4_port_dummy_op_void,
+	.test_chip = falcon_b0_test_chip,
+	.test_nvram = falcon_test_nvram,
+	.irq_enable_master = ef4_farch_irq_enable_master,
+	.irq_test_generate = ef4_farch_irq_test_generate,
+	.irq_disable_non_ev = ef4_farch_irq_disable_master,
+	.irq_handle_msi = ef4_farch_msi_interrupt,
+	.irq_handle_legacy = ef4_farch_legacy_interrupt,
+	.tx_probe = ef4_farch_tx_probe,
+	.tx_init = ef4_farch_tx_init,
+	.tx_remove = ef4_farch_tx_remove,
+	.tx_write = ef4_farch_tx_write,
+	.tx_limit_len = ef4_farch_tx_limit_len,
+	.rx_push_rss_config = falcon_b0_rx_push_rss_config,
+	.rx_probe = ef4_farch_rx_probe,
+	.rx_init = ef4_farch_rx_init,
+	.rx_remove = ef4_farch_rx_remove,
+	.rx_write = ef4_farch_rx_write,
+	.rx_defer_refill = ef4_farch_rx_defer_refill,
+	.ev_probe = ef4_farch_ev_probe,
+	.ev_init = ef4_farch_ev_init,
+	.ev_fini = ef4_farch_ev_fini,
+	.ev_remove = ef4_farch_ev_remove,
+	.ev_process = ef4_farch_ev_process,
+	.ev_read_ack = ef4_farch_ev_read_ack,
+	.ev_test_generate = ef4_farch_ev_test_generate,
+	.filter_table_probe = ef4_farch_filter_table_probe,
+	.filter_table_restore = ef4_farch_filter_table_restore,
+	.filter_table_remove = ef4_farch_filter_table_remove,
+	.filter_update_rx_scatter = ef4_farch_filter_update_rx_scatter,
+	.filter_insert = ef4_farch_filter_insert,
+	.filter_remove_safe = ef4_farch_filter_remove_safe,
+	.filter_get_safe = ef4_farch_filter_get_safe,
+	.filter_clear_rx = ef4_farch_filter_clear_rx,
+	.filter_count_rx_used = ef4_farch_filter_count_rx_used,
+	.filter_get_rx_id_limit = ef4_farch_filter_get_rx_id_limit,
+	.filter_get_rx_ids = ef4_farch_filter_get_rx_ids,
+#ifdef CONFIG_RFS_ACCEL
+	.filter_rfs_insert = ef4_farch_filter_rfs_insert,
+	.filter_rfs_expire_one = ef4_farch_filter_rfs_expire_one,
+#endif
+#ifdef CONFIG_SFC_FALCON_MTD
+	.mtd_probe = falcon_mtd_probe,
+	.mtd_rename = falcon_mtd_rename,
+	.mtd_read = falcon_mtd_read,
+	.mtd_erase = falcon_mtd_erase,
+	.mtd_write = falcon_mtd_write,
+	.mtd_sync = falcon_mtd_sync,
+#endif
+
+	.revision = EF4_REV_FALCON_B0,
+	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
+	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
+	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
+	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
+	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
+	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
+	.rx_prefix_size = FS_BZ_RX_PREFIX_SIZE,
+	.rx_hash_offset = FS_BZ_RX_PREFIX_HASH_OFST,
+	.rx_buffer_padding = 0,
+	.can_rx_scatter = true,
+	.max_interrupt_mode = EF4_INT_MODE_MSIX,
+	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
+	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH | NETIF_F_NTUPLE,
+	.max_rx_ip_filters = FR_BZ_RX_FILTER_TBL0_ROWS,
+};
diff --git a/drivers/net/ethernet/sfc/falcon/falcon_boards.c b/drivers/net/ethernet/sfc/falcon/falcon_boards.c
new file mode 100644
index 0000000..dec83a2
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/falcon_boards.c
@@ -0,0 +1,764 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2007-2012 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/rtnetlink.h>
+
+#include "net_driver.h"
+#include "phy.h"
+#include "efx.h"
+#include "nic.h"
+#include "workarounds.h"
+
+/* Macros for unpacking the board revision */
+/* The revision info is in host byte order. */
+#define FALCON_BOARD_TYPE(_rev) (_rev >> 8)
+#define FALCON_BOARD_MAJOR(_rev) ((_rev >> 4) & 0xf)
+#define FALCON_BOARD_MINOR(_rev) (_rev & 0xf)
+
+/* Board types */
+#define FALCON_BOARD_SFE4001 0x01
+#define FALCON_BOARD_SFE4002 0x02
+#define FALCON_BOARD_SFE4003 0x03
+#define FALCON_BOARD_SFN4112F 0x52
+
+/* Board temperature is about 15°C above ambient when air flow is
+ * limited.  The maximum acceptable ambient temperature varies
+ * depending on the PHY specifications but the critical temperature
+ * above which we should shut down to avoid damage is 80°C. */
+#define FALCON_BOARD_TEMP_BIAS	15
+#define FALCON_BOARD_TEMP_CRIT	(80 + FALCON_BOARD_TEMP_BIAS)
+
+/* SFC4000 datasheet says: 'The maximum permitted junction temperature
+ * is 125°C; the thermal design of the environment for the SFC4000
+ * should aim to keep this well below 100°C.' */
+#define FALCON_JUNC_TEMP_MIN	0
+#define FALCON_JUNC_TEMP_MAX	90
+#define FALCON_JUNC_TEMP_CRIT	125
+
+/*****************************************************************************
+ * Support for LM87 sensor chip used on several boards
+ */
+#define LM87_REG_TEMP_HW_INT_LOCK	0x13
+#define LM87_REG_TEMP_HW_EXT_LOCK	0x14
+#define LM87_REG_TEMP_HW_INT		0x17
+#define LM87_REG_TEMP_HW_EXT		0x18
+#define LM87_REG_TEMP_EXT1		0x26
+#define LM87_REG_TEMP_INT		0x27
+#define LM87_REG_ALARMS1		0x41
+#define LM87_REG_ALARMS2		0x42
+#define LM87_IN_LIMITS(nr, _min, _max)			\
+	0x2B + (nr) * 2, _max, 0x2C + (nr) * 2, _min
+#define LM87_AIN_LIMITS(nr, _min, _max)			\
+	0x3B + (nr), _max, 0x1A + (nr), _min
+#define LM87_TEMP_INT_LIMITS(_min, _max)		\
+	0x39, _max, 0x3A, _min
+#define LM87_TEMP_EXT1_LIMITS(_min, _max)		\
+	0x37, _max, 0x38, _min
+
+#define LM87_ALARM_TEMP_INT		0x10
+#define LM87_ALARM_TEMP_EXT1		0x20
+
+#if IS_ENABLED(CONFIG_SENSORS_LM87)
+
+static int ef4_poke_lm87(struct i2c_client *client, const u8 *reg_values)
+{
+	while (*reg_values) {
+		u8 reg = *reg_values++;
+		u8 value = *reg_values++;
+		int rc = i2c_smbus_write_byte_data(client, reg, value);
+		if (rc)
+			return rc;
+	}
+	return 0;
+}
+
+static const u8 falcon_lm87_common_regs[] = {
+	LM87_REG_TEMP_HW_INT_LOCK, FALCON_BOARD_TEMP_CRIT,
+	LM87_REG_TEMP_HW_INT, FALCON_BOARD_TEMP_CRIT,
+	LM87_TEMP_EXT1_LIMITS(FALCON_JUNC_TEMP_MIN, FALCON_JUNC_TEMP_MAX),
+	LM87_REG_TEMP_HW_EXT_LOCK, FALCON_JUNC_TEMP_CRIT,
+	LM87_REG_TEMP_HW_EXT, FALCON_JUNC_TEMP_CRIT,
+	0
+};
+
+static int ef4_init_lm87(struct ef4_nic *efx, const struct i2c_board_info *info,
+			 const u8 *reg_values)
+{
+	struct falcon_board *board = falcon_board(efx);
+	struct i2c_client *client = i2c_new_device(&board->i2c_adap, info);
+	int rc;
+
+	if (!client)
+		return -EIO;
+
+	/* Read-to-clear alarm/interrupt status */
+	i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
+	i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
+
+	rc = ef4_poke_lm87(client, reg_values);
+	if (rc)
+		goto err;
+	rc = ef4_poke_lm87(client, falcon_lm87_common_regs);
+	if (rc)
+		goto err;
+
+	board->hwmon_client = client;
+	return 0;
+
+err:
+	i2c_unregister_device(client);
+	return rc;
+}
+
+static void ef4_fini_lm87(struct ef4_nic *efx)
+{
+	i2c_unregister_device(falcon_board(efx)->hwmon_client);
+}
+
+static int ef4_check_lm87(struct ef4_nic *efx, unsigned mask)
+{
+	struct i2c_client *client = falcon_board(efx)->hwmon_client;
+	bool temp_crit, elec_fault, is_failure;
+	u16 alarms;
+	s32 reg;
+
+	/* If link is up then do not monitor temperature */
+	if (EF4_WORKAROUND_7884(efx) && efx->link_state.up)
+		return 0;
+
+	reg = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
+	if (reg < 0)
+		return reg;
+	alarms = reg;
+	reg = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
+	if (reg < 0)
+		return reg;
+	alarms |= reg << 8;
+	alarms &= mask;
+
+	temp_crit = false;
+	if (alarms & LM87_ALARM_TEMP_INT) {
+		reg = i2c_smbus_read_byte_data(client, LM87_REG_TEMP_INT);
+		if (reg < 0)
+			return reg;
+		if (reg > FALCON_BOARD_TEMP_CRIT)
+			temp_crit = true;
+	}
+	if (alarms & LM87_ALARM_TEMP_EXT1) {
+		reg = i2c_smbus_read_byte_data(client, LM87_REG_TEMP_EXT1);
+		if (reg < 0)
+			return reg;
+		if (reg > FALCON_JUNC_TEMP_CRIT)
+			temp_crit = true;
+	}
+	elec_fault = alarms & ~(LM87_ALARM_TEMP_INT | LM87_ALARM_TEMP_EXT1);
+	is_failure = temp_crit || elec_fault;
+
+	if (alarms)
+		netif_err(efx, hw, efx->net_dev,
+			  "LM87 detected a hardware %s (status %02x:%02x)"
+			  "%s%s%s%s\n",
+			  is_failure ? "failure" : "problem",
+			  alarms & 0xff, alarms >> 8,
+			  (alarms & LM87_ALARM_TEMP_INT) ?
+			  "; board is overheating" : "",
+			  (alarms & LM87_ALARM_TEMP_EXT1) ?
+			  "; controller is overheating" : "",
+			  temp_crit ? "; reached critical temperature" : "",
+			  elec_fault ? "; electrical fault" : "");
+
+	return is_failure ? -ERANGE : 0;
+}
+
+#else /* !CONFIG_SENSORS_LM87 */
+
+static inline int
+ef4_init_lm87(struct ef4_nic *efx, const struct i2c_board_info *info,
+	      const u8 *reg_values)
+{
+	return 0;
+}
+static inline void ef4_fini_lm87(struct ef4_nic *efx)
+{
+}
+static inline int ef4_check_lm87(struct ef4_nic *efx, unsigned mask)
+{
+	return 0;
+}
+
+#endif /* CONFIG_SENSORS_LM87 */
+
+/*****************************************************************************
+ * Support for the SFE4001 NIC.
+ *
+ * The SFE4001 does not power-up fully at reset due to its high power
+ * consumption.  We control its power via a PCA9539 I/O expander.
+ * It also has a MAX6647 temperature monitor which we expose to
+ * the lm90 driver.
+ *
+ * This also provides minimal support for reflashing the PHY, which is
+ * initiated by resetting it with the FLASH_CFG_1 pin pulled down.
+ * On SFE4001 rev A2 and later this is connected to the 3V3X output of
+ * the IO-expander.
+ * We represent reflash mode as PHY_MODE_SPECIAL and make it mutually
+ * exclusive with the network device being open.
+ */
+
+/**************************************************************************
+ * Support for I2C IO Expander device on SFE4001
+ */
+#define	PCA9539 0x74
+
+#define	P0_IN 0x00
+#define	P0_OUT 0x02
+#define	P0_INVERT 0x04
+#define	P0_CONFIG 0x06
+
+#define	P0_EN_1V0X_LBN 0
+#define	P0_EN_1V0X_WIDTH 1
+#define	P0_EN_1V2_LBN 1
+#define	P0_EN_1V2_WIDTH 1
+#define	P0_EN_2V5_LBN 2
+#define	P0_EN_2V5_WIDTH 1
+#define	P0_EN_3V3X_LBN 3
+#define	P0_EN_3V3X_WIDTH 1
+#define	P0_EN_5V_LBN 4
+#define	P0_EN_5V_WIDTH 1
+#define	P0_SHORTEN_JTAG_LBN 5
+#define	P0_SHORTEN_JTAG_WIDTH 1
+#define	P0_X_TRST_LBN 6
+#define	P0_X_TRST_WIDTH 1
+#define	P0_DSP_RESET_LBN 7
+#define	P0_DSP_RESET_WIDTH 1
+
+#define	P1_IN 0x01
+#define	P1_OUT 0x03
+#define	P1_INVERT 0x05
+#define	P1_CONFIG 0x07
+
+#define	P1_AFE_PWD_LBN 0
+#define	P1_AFE_PWD_WIDTH 1
+#define	P1_DSP_PWD25_LBN 1
+#define	P1_DSP_PWD25_WIDTH 1
+#define	P1_RESERVED_LBN 2
+#define	P1_RESERVED_WIDTH 2
+#define	P1_SPARE_LBN 4
+#define	P1_SPARE_WIDTH 4
+
+/* Temperature Sensor */
+#define MAX664X_REG_RSL		0x02
+#define MAX664X_REG_WLHO	0x0B
+
+static void sfe4001_poweroff(struct ef4_nic *efx)
+{
+	struct i2c_client *ioexp_client = falcon_board(efx)->ioexp_client;
+	struct i2c_client *hwmon_client = falcon_board(efx)->hwmon_client;
+
+	/* Turn off all power rails and disable outputs */
+	i2c_smbus_write_byte_data(ioexp_client, P0_OUT, 0xff);
+	i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG, 0xff);
+	i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0xff);
+
+	/* Clear any over-temperature alert */
+	i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
+}
+
+static int sfe4001_poweron(struct ef4_nic *efx)
+{
+	struct i2c_client *ioexp_client = falcon_board(efx)->ioexp_client;
+	struct i2c_client *hwmon_client = falcon_board(efx)->hwmon_client;
+	unsigned int i, j;
+	int rc;
+	u8 out;
+
+	/* Clear any previous over-temperature alert */
+	rc = i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
+	if (rc < 0)
+		return rc;
+
+	/* Enable port 0 and port 1 outputs on IO expander */
+	rc = i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0x00);
+	if (rc)
+		return rc;
+	rc = i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG,
+				       0xff & ~(1 << P1_SPARE_LBN));
+	if (rc)
+		goto fail_on;
+
+	/* If PHY power is on, turn it all off and wait 1 second to
+	 * ensure a full reset.
+	 */
+	rc = i2c_smbus_read_byte_data(ioexp_client, P0_OUT);
+	if (rc < 0)
+		goto fail_on;
+	out = 0xff & ~((0 << P0_EN_1V2_LBN) | (0 << P0_EN_2V5_LBN) |
+		       (0 << P0_EN_3V3X_LBN) | (0 << P0_EN_5V_LBN) |
+		       (0 << P0_EN_1V0X_LBN));
+	if (rc != out) {
+		netif_info(efx, hw, efx->net_dev, "power-cycling PHY\n");
+		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
+		if (rc)
+			goto fail_on;
+		schedule_timeout_uninterruptible(HZ);
+	}
+
+	for (i = 0; i < 20; ++i) {
+		/* Turn on 1.2V, 2.5V, 3.3V and 5V power rails */
+		out = 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
+			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
+			       (1 << P0_X_TRST_LBN));
+		if (efx->phy_mode & PHY_MODE_SPECIAL)
+			out |= 1 << P0_EN_3V3X_LBN;
+
+		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
+		if (rc)
+			goto fail_on;
+		msleep(10);
+
+		/* Turn on 1V power rail */
+		out &= ~(1 << P0_EN_1V0X_LBN);
+		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
+		if (rc)
+			goto fail_on;
+
+		netif_info(efx, hw, efx->net_dev,
+			   "waiting for DSP boot (attempt %d)...\n", i);
+
+		/* In flash config mode, DSP does not turn on AFE, so
+		 * just wait 1 second.
+		 */
+		if (efx->phy_mode & PHY_MODE_SPECIAL) {
+			schedule_timeout_uninterruptible(HZ);
+			return 0;
+		}
+
+		for (j = 0; j < 10; ++j) {
+			msleep(100);
+
+			/* Check DSP has asserted AFE power line */
+			rc = i2c_smbus_read_byte_data(ioexp_client, P1_IN);
+			if (rc < 0)
+				goto fail_on;
+			if (rc & (1 << P1_AFE_PWD_LBN))
+				return 0;
+		}
+	}
+
+	netif_info(efx, hw, efx->net_dev, "timed out waiting for DSP boot\n");
+	rc = -ETIMEDOUT;
+fail_on:
+	sfe4001_poweroff(efx);
+	return rc;
+}
+
+static ssize_t show_phy_flash_cfg(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct ef4_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	return sprintf(buf, "%d\n", !!(efx->phy_mode & PHY_MODE_SPECIAL));
+}
+
+static ssize_t set_phy_flash_cfg(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count)
+{
+	struct ef4_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	enum ef4_phy_mode old_mode, new_mode;
+	int err;
+
+	rtnl_lock();
+	old_mode = efx->phy_mode;
+	if (count == 0 || *buf == '0')
+		new_mode = old_mode & ~PHY_MODE_SPECIAL;
+	else
+		new_mode = PHY_MODE_SPECIAL;
+	if (!((old_mode ^ new_mode) & PHY_MODE_SPECIAL)) {
+		err = 0;
+	} else if (efx->state != STATE_READY || netif_running(efx->net_dev)) {
+		err = -EBUSY;
+	} else {
+		/* Reset the PHY, reconfigure the MAC and enable/disable
+		 * MAC stats accordingly. */
+		efx->phy_mode = new_mode;
+		if (new_mode & PHY_MODE_SPECIAL)
+			falcon_stop_nic_stats(efx);
+		err = sfe4001_poweron(efx);
+		if (!err)
+			err = ef4_reconfigure_port(efx);
+		if (!(new_mode & PHY_MODE_SPECIAL))
+			falcon_start_nic_stats(efx);
+	}
+	rtnl_unlock();
+
+	return err ? err : count;
+}
+
+static DEVICE_ATTR(phy_flash_cfg, 0644, show_phy_flash_cfg, set_phy_flash_cfg);
+
+static void sfe4001_fini(struct ef4_nic *efx)
+{
+	struct falcon_board *board = falcon_board(efx);
+
+	netif_info(efx, drv, efx->net_dev, "%s\n", __func__);
+
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
+	sfe4001_poweroff(efx);
+	i2c_unregister_device(board->ioexp_client);
+	i2c_unregister_device(board->hwmon_client);
+}
+
+static int sfe4001_check_hw(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	s32 status;
+
+	/* If XAUI link is up then do not monitor */
+	if (EF4_WORKAROUND_7884(efx) && !nic_data->xmac_poll_required)
+		return 0;
+
+	/* Check the powered status of the PHY. Lack of power implies that
+	 * the MAX6647 has shut down power to it, probably due to a temp.
+	 * alarm. Reading the power status rather than the MAX6647 status
+	 * directly because the later is read-to-clear and would thus
+	 * start to power up the PHY again when polled, causing us to blip
+	 * the power undesirably.
+	 * We know we can read from the IO expander because we did
+	 * it during power-on. Assume failure now is bad news. */
+	status = i2c_smbus_read_byte_data(falcon_board(efx)->ioexp_client, P1_IN);
+	if (status >= 0 &&
+	    (status & ((1 << P1_AFE_PWD_LBN) | (1 << P1_DSP_PWD25_LBN))) != 0)
+		return 0;
+
+	/* Use board power control, not PHY power control */
+	sfe4001_poweroff(efx);
+	efx->phy_mode = PHY_MODE_OFF;
+
+	return (status < 0) ? -EIO : -ERANGE;
+}
+
+static const struct i2c_board_info sfe4001_hwmon_info = {
+	I2C_BOARD_INFO("max6647", 0x4e),
+};
+
+/* This board uses an I2C expander to provider power to the PHY, which needs to
+ * be turned on before the PHY can be used.
+ * Context: Process context, rtnl lock held
+ */
+static int sfe4001_init(struct ef4_nic *efx)
+{
+	struct falcon_board *board = falcon_board(efx);
+	int rc;
+
+#if IS_ENABLED(CONFIG_SENSORS_LM90)
+	board->hwmon_client =
+		i2c_new_device(&board->i2c_adap, &sfe4001_hwmon_info);
+#else
+	board->hwmon_client =
+		i2c_new_dummy(&board->i2c_adap, sfe4001_hwmon_info.addr);
+#endif
+	if (!board->hwmon_client)
+		return -EIO;
+
+	/* Raise board/PHY high limit from 85 to 90 degrees Celsius */
+	rc = i2c_smbus_write_byte_data(board->hwmon_client,
+				       MAX664X_REG_WLHO, 90);
+	if (rc)
+		goto fail_hwmon;
+
+	board->ioexp_client = i2c_new_dummy(&board->i2c_adap, PCA9539);
+	if (!board->ioexp_client) {
+		rc = -EIO;
+		goto fail_hwmon;
+	}
+
+	if (efx->phy_mode & PHY_MODE_SPECIAL) {
+		/* PHY won't generate a 156.25 MHz clock and MAC stats fetch
+		 * will fail. */
+		falcon_stop_nic_stats(efx);
+	}
+	rc = sfe4001_poweron(efx);
+	if (rc)
+		goto fail_ioexp;
+
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
+	if (rc)
+		goto fail_on;
+
+	netif_info(efx, hw, efx->net_dev, "PHY is powered on\n");
+	return 0;
+
+fail_on:
+	sfe4001_poweroff(efx);
+fail_ioexp:
+	i2c_unregister_device(board->ioexp_client);
+fail_hwmon:
+	i2c_unregister_device(board->hwmon_client);
+	return rc;
+}
+
+/*****************************************************************************
+ * Support for the SFE4002
+ *
+ */
+static u8 sfe4002_lm87_channel = 0x03; /* use AIN not FAN inputs */
+
+static const u8 sfe4002_lm87_regs[] = {
+	LM87_IN_LIMITS(0, 0x7c, 0x99),		/* 2.5V:  1.8V +/- 10% */
+	LM87_IN_LIMITS(1, 0x4c, 0x5e),		/* Vccp1: 1.2V +/- 10% */
+	LM87_IN_LIMITS(2, 0xac, 0xd4),		/* 3.3V:  3.3V +/- 10% */
+	LM87_IN_LIMITS(3, 0xac, 0xd4),		/* 5V:    5.0V +/- 10% */
+	LM87_IN_LIMITS(4, 0xac, 0xe0),		/* 12V:   10.8-14V */
+	LM87_IN_LIMITS(5, 0x3f, 0x4f),		/* Vccp2: 1.0V +/- 10% */
+	LM87_AIN_LIMITS(0, 0x98, 0xbb),		/* AIN1:  1.66V +/- 10% */
+	LM87_AIN_LIMITS(1, 0x8a, 0xa9),		/* AIN2:  1.5V +/- 10% */
+	LM87_TEMP_INT_LIMITS(0, 80 + FALCON_BOARD_TEMP_BIAS),
+	LM87_TEMP_EXT1_LIMITS(0, FALCON_JUNC_TEMP_MAX),
+	0
+};
+
+static const struct i2c_board_info sfe4002_hwmon_info = {
+	I2C_BOARD_INFO("lm87", 0x2e),
+	.platform_data	= &sfe4002_lm87_channel,
+};
+
+/****************************************************************************/
+/* LED allocations. Note that on rev A0 boards the schematic and the reality
+ * differ: red and green are swapped. Below is the fixed (A1) layout (there
+ * are only 3 A0 boards in existence, so no real reason to make this
+ * conditional).
+ */
+#define SFE4002_FAULT_LED (2)	/* Red */
+#define SFE4002_RX_LED    (0)	/* Green */
+#define SFE4002_TX_LED    (1)	/* Amber */
+
+static void sfe4002_init_phy(struct ef4_nic *efx)
+{
+	/* Set the TX and RX LEDs to reflect status and activity, and the
+	 * fault LED off */
+	falcon_qt202x_set_led(efx, SFE4002_TX_LED,
+			      QUAKE_LED_TXLINK | QUAKE_LED_LINK_ACTSTAT);
+	falcon_qt202x_set_led(efx, SFE4002_RX_LED,
+			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACTSTAT);
+	falcon_qt202x_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
+}
+
+static void sfe4002_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode)
+{
+	falcon_qt202x_set_led(
+		efx, SFE4002_FAULT_LED,
+		(mode == EF4_LED_ON) ? QUAKE_LED_ON : QUAKE_LED_OFF);
+}
+
+static int sfe4002_check_hw(struct ef4_nic *efx)
+{
+	struct falcon_board *board = falcon_board(efx);
+
+	/* A0 board rev. 4002s report a temperature fault the whole time
+	 * (bad sensor) so we mask it out. */
+	unsigned alarm_mask =
+		(board->major == 0 && board->minor == 0) ?
+		~LM87_ALARM_TEMP_EXT1 : ~0;
+
+	return ef4_check_lm87(efx, alarm_mask);
+}
+
+static int sfe4002_init(struct ef4_nic *efx)
+{
+	return ef4_init_lm87(efx, &sfe4002_hwmon_info, sfe4002_lm87_regs);
+}
+
+/*****************************************************************************
+ * Support for the SFN4112F
+ *
+ */
+static u8 sfn4112f_lm87_channel = 0x03; /* use AIN not FAN inputs */
+
+static const u8 sfn4112f_lm87_regs[] = {
+	LM87_IN_LIMITS(0, 0x7c, 0x99),		/* 2.5V:  1.8V +/- 10% */
+	LM87_IN_LIMITS(1, 0x4c, 0x5e),		/* Vccp1: 1.2V +/- 10% */
+	LM87_IN_LIMITS(2, 0xac, 0xd4),		/* 3.3V:  3.3V +/- 10% */
+	LM87_IN_LIMITS(4, 0xac, 0xe0),		/* 12V:   10.8-14V */
+	LM87_IN_LIMITS(5, 0x3f, 0x4f),		/* Vccp2: 1.0V +/- 10% */
+	LM87_AIN_LIMITS(1, 0x8a, 0xa9),		/* AIN2:  1.5V +/- 10% */
+	LM87_TEMP_INT_LIMITS(0, 60 + FALCON_BOARD_TEMP_BIAS),
+	LM87_TEMP_EXT1_LIMITS(0, FALCON_JUNC_TEMP_MAX),
+	0
+};
+
+static const struct i2c_board_info sfn4112f_hwmon_info = {
+	I2C_BOARD_INFO("lm87", 0x2e),
+	.platform_data	= &sfn4112f_lm87_channel,
+};
+
+#define SFN4112F_ACT_LED	0
+#define SFN4112F_LINK_LED	1
+
+static void sfn4112f_init_phy(struct ef4_nic *efx)
+{
+	falcon_qt202x_set_led(efx, SFN4112F_ACT_LED,
+			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACT);
+	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED,
+			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT);
+}
+
+static void sfn4112f_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode)
+{
+	int reg;
+
+	switch (mode) {
+	case EF4_LED_OFF:
+		reg = QUAKE_LED_OFF;
+		break;
+	case EF4_LED_ON:
+		reg = QUAKE_LED_ON;
+		break;
+	default:
+		reg = QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT;
+		break;
+	}
+
+	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED, reg);
+}
+
+static int sfn4112f_check_hw(struct ef4_nic *efx)
+{
+	/* Mask out unused sensors */
+	return ef4_check_lm87(efx, ~0x48);
+}
+
+static int sfn4112f_init(struct ef4_nic *efx)
+{
+	return ef4_init_lm87(efx, &sfn4112f_hwmon_info, sfn4112f_lm87_regs);
+}
+
+/*****************************************************************************
+ * Support for the SFE4003
+ *
+ */
+static u8 sfe4003_lm87_channel = 0x03; /* use AIN not FAN inputs */
+
+static const u8 sfe4003_lm87_regs[] = {
+	LM87_IN_LIMITS(0, 0x67, 0x7f),		/* 2.5V:  1.5V +/- 10% */
+	LM87_IN_LIMITS(1, 0x4c, 0x5e),		/* Vccp1: 1.2V +/- 10% */
+	LM87_IN_LIMITS(2, 0xac, 0xd4),		/* 3.3V:  3.3V +/- 10% */
+	LM87_IN_LIMITS(4, 0xac, 0xe0),		/* 12V:   10.8-14V */
+	LM87_IN_LIMITS(5, 0x3f, 0x4f),		/* Vccp2: 1.0V +/- 10% */
+	LM87_TEMP_INT_LIMITS(0, 70 + FALCON_BOARD_TEMP_BIAS),
+	0
+};
+
+static const struct i2c_board_info sfe4003_hwmon_info = {
+	I2C_BOARD_INFO("lm87", 0x2e),
+	.platform_data	= &sfe4003_lm87_channel,
+};
+
+/* Board-specific LED info. */
+#define SFE4003_RED_LED_GPIO	11
+#define SFE4003_LED_ON		1
+#define SFE4003_LED_OFF		0
+
+static void sfe4003_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode)
+{
+	struct falcon_board *board = falcon_board(efx);
+
+	/* The LEDs were not wired to GPIOs before A3 */
+	if (board->minor < 3 && board->major == 0)
+		return;
+
+	falcon_txc_set_gpio_val(
+		efx, SFE4003_RED_LED_GPIO,
+		(mode == EF4_LED_ON) ? SFE4003_LED_ON : SFE4003_LED_OFF);
+}
+
+static void sfe4003_init_phy(struct ef4_nic *efx)
+{
+	struct falcon_board *board = falcon_board(efx);
+
+	/* The LEDs were not wired to GPIOs before A3 */
+	if (board->minor < 3 && board->major == 0)
+		return;
+
+	falcon_txc_set_gpio_dir(efx, SFE4003_RED_LED_GPIO, TXC_GPIO_DIR_OUTPUT);
+	falcon_txc_set_gpio_val(efx, SFE4003_RED_LED_GPIO, SFE4003_LED_OFF);
+}
+
+static int sfe4003_check_hw(struct ef4_nic *efx)
+{
+	struct falcon_board *board = falcon_board(efx);
+
+	/* A0/A1/A2 board rev. 4003s  report a temperature fault the whole time
+	 * (bad sensor) so we mask it out. */
+	unsigned alarm_mask =
+		(board->major == 0 && board->minor <= 2) ?
+		~LM87_ALARM_TEMP_EXT1 : ~0;
+
+	return ef4_check_lm87(efx, alarm_mask);
+}
+
+static int sfe4003_init(struct ef4_nic *efx)
+{
+	return ef4_init_lm87(efx, &sfe4003_hwmon_info, sfe4003_lm87_regs);
+}
+
+static const struct falcon_board_type board_types[] = {
+	{
+		.id		= FALCON_BOARD_SFE4001,
+		.init		= sfe4001_init,
+		.init_phy	= ef4_port_dummy_op_void,
+		.fini		= sfe4001_fini,
+		.set_id_led	= tenxpress_set_id_led,
+		.monitor	= sfe4001_check_hw,
+	},
+	{
+		.id		= FALCON_BOARD_SFE4002,
+		.init		= sfe4002_init,
+		.init_phy	= sfe4002_init_phy,
+		.fini		= ef4_fini_lm87,
+		.set_id_led	= sfe4002_set_id_led,
+		.monitor	= sfe4002_check_hw,
+	},
+	{
+		.id		= FALCON_BOARD_SFE4003,
+		.init		= sfe4003_init,
+		.init_phy	= sfe4003_init_phy,
+		.fini		= ef4_fini_lm87,
+		.set_id_led	= sfe4003_set_id_led,
+		.monitor	= sfe4003_check_hw,
+	},
+	{
+		.id		= FALCON_BOARD_SFN4112F,
+		.init		= sfn4112f_init,
+		.init_phy	= sfn4112f_init_phy,
+		.fini		= ef4_fini_lm87,
+		.set_id_led	= sfn4112f_set_id_led,
+		.monitor	= sfn4112f_check_hw,
+	},
+};
+
+int falcon_probe_board(struct ef4_nic *efx, u16 revision_info)
+{
+	struct falcon_board *board = falcon_board(efx);
+	u8 type_id = FALCON_BOARD_TYPE(revision_info);
+	int i;
+
+	board->major = FALCON_BOARD_MAJOR(revision_info);
+	board->minor = FALCON_BOARD_MINOR(revision_info);
+
+	for (i = 0; i < ARRAY_SIZE(board_types); i++)
+		if (board_types[i].id == type_id)
+			board->type = &board_types[i];
+
+	if (board->type) {
+		return 0;
+	} else {
+		netif_err(efx, probe, efx->net_dev, "unknown board type %d\n",
+			  type_id);
+		return -ENODEV;
+	}
+}
diff --git a/drivers/net/ethernet/sfc/falcon/farch.c b/drivers/net/ethernet/sfc/falcon/farch.c
new file mode 100644
index 0000000..05916c7
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/farch.c
@@ -0,0 +1,2892 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/module.h>
+#include <linux/seq_file.h>
+#include <linux/crc32.h>
+#include "net_driver.h"
+#include "bitfield.h"
+#include "efx.h"
+#include "nic.h"
+#include "farch_regs.h"
+#include "io.h"
+#include "workarounds.h"
+
+/* Falcon-architecture (SFC4000) support */
+
+/**************************************************************************
+ *
+ * Configurable values
+ *
+ **************************************************************************
+ */
+
+/* This is set to 16 for a good reason.  In summary, if larger than
+ * 16, the descriptor cache holds more than a default socket
+ * buffer's worth of packets (for UDP we can only have at most one
+ * socket buffer's worth outstanding).  This combined with the fact
+ * that we only get 1 TX event per descriptor cache means the NIC
+ * goes idle.
+ */
+#define TX_DC_ENTRIES 16
+#define TX_DC_ENTRIES_ORDER 1
+
+#define RX_DC_ENTRIES 64
+#define RX_DC_ENTRIES_ORDER 3
+
+/* If EF4_MAX_INT_ERRORS internal errors occur within
+ * EF4_INT_ERROR_EXPIRE seconds, we consider the NIC broken and
+ * disable it.
+ */
+#define EF4_INT_ERROR_EXPIRE 3600
+#define EF4_MAX_INT_ERRORS 5
+
+/* Depth of RX flush request fifo */
+#define EF4_RX_FLUSH_COUNT 4
+
+/* Driver generated events */
+#define _EF4_CHANNEL_MAGIC_TEST		0x000101
+#define _EF4_CHANNEL_MAGIC_FILL		0x000102
+#define _EF4_CHANNEL_MAGIC_RX_DRAIN	0x000103
+#define _EF4_CHANNEL_MAGIC_TX_DRAIN	0x000104
+
+#define _EF4_CHANNEL_MAGIC(_code, _data)	((_code) << 8 | (_data))
+#define _EF4_CHANNEL_MAGIC_CODE(_magic)		((_magic) >> 8)
+
+#define EF4_CHANNEL_MAGIC_TEST(_channel)				\
+	_EF4_CHANNEL_MAGIC(_EF4_CHANNEL_MAGIC_TEST, (_channel)->channel)
+#define EF4_CHANNEL_MAGIC_FILL(_rx_queue)				\
+	_EF4_CHANNEL_MAGIC(_EF4_CHANNEL_MAGIC_FILL,			\
+			   ef4_rx_queue_index(_rx_queue))
+#define EF4_CHANNEL_MAGIC_RX_DRAIN(_rx_queue)				\
+	_EF4_CHANNEL_MAGIC(_EF4_CHANNEL_MAGIC_RX_DRAIN,			\
+			   ef4_rx_queue_index(_rx_queue))
+#define EF4_CHANNEL_MAGIC_TX_DRAIN(_tx_queue)				\
+	_EF4_CHANNEL_MAGIC(_EF4_CHANNEL_MAGIC_TX_DRAIN,			\
+			   (_tx_queue)->queue)
+
+static void ef4_farch_magic_event(struct ef4_channel *channel, u32 magic);
+
+/**************************************************************************
+ *
+ * Hardware access
+ *
+ **************************************************************************/
+
+static inline void ef4_write_buf_tbl(struct ef4_nic *efx, ef4_qword_t *value,
+				     unsigned int index)
+{
+	ef4_sram_writeq(efx, efx->membase + efx->type->buf_tbl_base,
+			value, index);
+}
+
+static bool ef4_masked_compare_oword(const ef4_oword_t *a, const ef4_oword_t *b,
+				     const ef4_oword_t *mask)
+{
+	return ((a->u64[0] ^ b->u64[0]) & mask->u64[0]) ||
+		((a->u64[1] ^ b->u64[1]) & mask->u64[1]);
+}
+
+int ef4_farch_test_registers(struct ef4_nic *efx,
+			     const struct ef4_farch_register_test *regs,
+			     size_t n_regs)
+{
+	unsigned address = 0;
+	int i, j;
+	ef4_oword_t mask, imask, original, reg, buf;
+
+	for (i = 0; i < n_regs; ++i) {
+		address = regs[i].address;
+		mask = imask = regs[i].mask;
+		EF4_INVERT_OWORD(imask);
+
+		ef4_reado(efx, &original, address);
+
+		/* bit sweep on and off */
+		for (j = 0; j < 128; j++) {
+			if (!EF4_EXTRACT_OWORD32(mask, j, j))
+				continue;
+
+			/* Test this testable bit can be set in isolation */
+			EF4_AND_OWORD(reg, original, mask);
+			EF4_SET_OWORD32(reg, j, j, 1);
+
+			ef4_writeo(efx, &reg, address);
+			ef4_reado(efx, &buf, address);
+
+			if (ef4_masked_compare_oword(&reg, &buf, &mask))
+				goto fail;
+
+			/* Test this testable bit can be cleared in isolation */
+			EF4_OR_OWORD(reg, original, mask);
+			EF4_SET_OWORD32(reg, j, j, 0);
+
+			ef4_writeo(efx, &reg, address);
+			ef4_reado(efx, &buf, address);
+
+			if (ef4_masked_compare_oword(&reg, &buf, &mask))
+				goto fail;
+		}
+
+		ef4_writeo(efx, &original, address);
+	}
+
+	return 0;
+
+fail:
+	netif_err(efx, hw, efx->net_dev,
+		  "wrote "EF4_OWORD_FMT" read "EF4_OWORD_FMT
+		  " at address 0x%x mask "EF4_OWORD_FMT"\n", EF4_OWORD_VAL(reg),
+		  EF4_OWORD_VAL(buf), address, EF4_OWORD_VAL(mask));
+	return -EIO;
+}
+
+/**************************************************************************
+ *
+ * Special buffer handling
+ * Special buffers are used for event queues and the TX and RX
+ * descriptor rings.
+ *
+ *************************************************************************/
+
+/*
+ * Initialise a special buffer
+ *
+ * This will define a buffer (previously allocated via
+ * ef4_alloc_special_buffer()) in the buffer table, allowing
+ * it to be used for event queues, descriptor rings etc.
+ */
+static void
+ef4_init_special_buffer(struct ef4_nic *efx, struct ef4_special_buffer *buffer)
+{
+	ef4_qword_t buf_desc;
+	unsigned int index;
+	dma_addr_t dma_addr;
+	int i;
+
+	EF4_BUG_ON_PARANOID(!buffer->buf.addr);
+
+	/* Write buffer descriptors to NIC */
+	for (i = 0; i < buffer->entries; i++) {
+		index = buffer->index + i;
+		dma_addr = buffer->buf.dma_addr + (i * EF4_BUF_SIZE);
+		netif_dbg(efx, probe, efx->net_dev,
+			  "mapping special buffer %d at %llx\n",
+			  index, (unsigned long long)dma_addr);
+		EF4_POPULATE_QWORD_3(buf_desc,
+				     FRF_AZ_BUF_ADR_REGION, 0,
+				     FRF_AZ_BUF_ADR_FBUF, dma_addr >> 12,
+				     FRF_AZ_BUF_OWNER_ID_FBUF, 0);
+		ef4_write_buf_tbl(efx, &buf_desc, index);
+	}
+}
+
+/* Unmaps a buffer and clears the buffer table entries */
+static void
+ef4_fini_special_buffer(struct ef4_nic *efx, struct ef4_special_buffer *buffer)
+{
+	ef4_oword_t buf_tbl_upd;
+	unsigned int start = buffer->index;
+	unsigned int end = (buffer->index + buffer->entries - 1);
+
+	if (!buffer->entries)
+		return;
+
+	netif_dbg(efx, hw, efx->net_dev, "unmapping special buffers %d-%d\n",
+		  buffer->index, buffer->index + buffer->entries - 1);
+
+	EF4_POPULATE_OWORD_4(buf_tbl_upd,
+			     FRF_AZ_BUF_UPD_CMD, 0,
+			     FRF_AZ_BUF_CLR_CMD, 1,
+			     FRF_AZ_BUF_CLR_END_ID, end,
+			     FRF_AZ_BUF_CLR_START_ID, start);
+	ef4_writeo(efx, &buf_tbl_upd, FR_AZ_BUF_TBL_UPD);
+}
+
+/*
+ * Allocate a new special buffer
+ *
+ * This allocates memory for a new buffer, clears it and allocates a
+ * new buffer ID range.  It does not write into the buffer table.
+ *
+ * This call will allocate 4KB buffers, since 8KB buffers can't be
+ * used for event queues and descriptor rings.
+ */
+static int ef4_alloc_special_buffer(struct ef4_nic *efx,
+				    struct ef4_special_buffer *buffer,
+				    unsigned int len)
+{
+	len = ALIGN(len, EF4_BUF_SIZE);
+
+	if (ef4_nic_alloc_buffer(efx, &buffer->buf, len, GFP_KERNEL))
+		return -ENOMEM;
+	buffer->entries = len / EF4_BUF_SIZE;
+	BUG_ON(buffer->buf.dma_addr & (EF4_BUF_SIZE - 1));
+
+	/* Select new buffer ID */
+	buffer->index = efx->next_buffer_table;
+	efx->next_buffer_table += buffer->entries;
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "allocating special buffers %d-%d at %llx+%x "
+		  "(virt %p phys %llx)\n", buffer->index,
+		  buffer->index + buffer->entries - 1,
+		  (u64)buffer->buf.dma_addr, len,
+		  buffer->buf.addr, (u64)virt_to_phys(buffer->buf.addr));
+
+	return 0;
+}
+
+static void
+ef4_free_special_buffer(struct ef4_nic *efx, struct ef4_special_buffer *buffer)
+{
+	if (!buffer->buf.addr)
+		return;
+
+	netif_dbg(efx, hw, efx->net_dev,
+		  "deallocating special buffers %d-%d at %llx+%x "
+		  "(virt %p phys %llx)\n", buffer->index,
+		  buffer->index + buffer->entries - 1,
+		  (u64)buffer->buf.dma_addr, buffer->buf.len,
+		  buffer->buf.addr, (u64)virt_to_phys(buffer->buf.addr));
+
+	ef4_nic_free_buffer(efx, &buffer->buf);
+	buffer->entries = 0;
+}
+
+/**************************************************************************
+ *
+ * TX path
+ *
+ **************************************************************************/
+
+/* This writes to the TX_DESC_WPTR; write pointer for TX descriptor ring */
+static inline void ef4_farch_notify_tx_desc(struct ef4_tx_queue *tx_queue)
+{
+	unsigned write_ptr;
+	ef4_dword_t reg;
+
+	write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
+	EF4_POPULATE_DWORD_1(reg, FRF_AZ_TX_DESC_WPTR_DWORD, write_ptr);
+	ef4_writed_page(tx_queue->efx, &reg,
+			FR_AZ_TX_DESC_UPD_DWORD_P0, tx_queue->queue);
+}
+
+/* Write pointer and first descriptor for TX descriptor ring */
+static inline void ef4_farch_push_tx_desc(struct ef4_tx_queue *tx_queue,
+					  const ef4_qword_t *txd)
+{
+	unsigned write_ptr;
+	ef4_oword_t reg;
+
+	BUILD_BUG_ON(FRF_AZ_TX_DESC_LBN != 0);
+	BUILD_BUG_ON(FR_AA_TX_DESC_UPD_KER != FR_BZ_TX_DESC_UPD_P0);
+
+	write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
+	EF4_POPULATE_OWORD_2(reg, FRF_AZ_TX_DESC_PUSH_CMD, true,
+			     FRF_AZ_TX_DESC_WPTR, write_ptr);
+	reg.qword[0] = *txd;
+	ef4_writeo_page(tx_queue->efx, &reg,
+			FR_BZ_TX_DESC_UPD_P0, tx_queue->queue);
+}
+
+
+/* For each entry inserted into the software descriptor ring, create a
+ * descriptor in the hardware TX descriptor ring (in host memory), and
+ * write a doorbell.
+ */
+void ef4_farch_tx_write(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_tx_buffer *buffer;
+	ef4_qword_t *txd;
+	unsigned write_ptr;
+	unsigned old_write_count = tx_queue->write_count;
+
+	tx_queue->xmit_more_available = false;
+	if (unlikely(tx_queue->write_count == tx_queue->insert_count))
+		return;
+
+	do {
+		write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
+		buffer = &tx_queue->buffer[write_ptr];
+		txd = ef4_tx_desc(tx_queue, write_ptr);
+		++tx_queue->write_count;
+
+		EF4_BUG_ON_PARANOID(buffer->flags & EF4_TX_BUF_OPTION);
+
+		/* Create TX descriptor ring entry */
+		BUILD_BUG_ON(EF4_TX_BUF_CONT != 1);
+		EF4_POPULATE_QWORD_4(*txd,
+				     FSF_AZ_TX_KER_CONT,
+				     buffer->flags & EF4_TX_BUF_CONT,
+				     FSF_AZ_TX_KER_BYTE_COUNT, buffer->len,
+				     FSF_AZ_TX_KER_BUF_REGION, 0,
+				     FSF_AZ_TX_KER_BUF_ADDR, buffer->dma_addr);
+	} while (tx_queue->write_count != tx_queue->insert_count);
+
+	wmb(); /* Ensure descriptors are written before they are fetched */
+
+	if (ef4_nic_may_push_tx_desc(tx_queue, old_write_count)) {
+		txd = ef4_tx_desc(tx_queue,
+				  old_write_count & tx_queue->ptr_mask);
+		ef4_farch_push_tx_desc(tx_queue, txd);
+		++tx_queue->pushes;
+	} else {
+		ef4_farch_notify_tx_desc(tx_queue);
+	}
+}
+
+unsigned int ef4_farch_tx_limit_len(struct ef4_tx_queue *tx_queue,
+				    dma_addr_t dma_addr, unsigned int len)
+{
+	/* Don't cross 4K boundaries with descriptors. */
+	unsigned int limit = (~dma_addr & (EF4_PAGE_SIZE - 1)) + 1;
+
+	len = min(limit, len);
+
+	if (EF4_WORKAROUND_5391(tx_queue->efx) && (dma_addr & 0xf))
+		len = min_t(unsigned int, len, 512 - (dma_addr & 0xf));
+
+	return len;
+}
+
+
+/* Allocate hardware resources for a TX queue */
+int ef4_farch_tx_probe(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	unsigned entries;
+
+	entries = tx_queue->ptr_mask + 1;
+	return ef4_alloc_special_buffer(efx, &tx_queue->txd,
+					entries * sizeof(ef4_qword_t));
+}
+
+void ef4_farch_tx_init(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	ef4_oword_t reg;
+
+	/* Pin TX descriptor ring */
+	ef4_init_special_buffer(efx, &tx_queue->txd);
+
+	/* Push TX descriptor ring to card */
+	EF4_POPULATE_OWORD_10(reg,
+			      FRF_AZ_TX_DESCQ_EN, 1,
+			      FRF_AZ_TX_ISCSI_DDIG_EN, 0,
+			      FRF_AZ_TX_ISCSI_HDIG_EN, 0,
+			      FRF_AZ_TX_DESCQ_BUF_BASE_ID, tx_queue->txd.index,
+			      FRF_AZ_TX_DESCQ_EVQ_ID,
+			      tx_queue->channel->channel,
+			      FRF_AZ_TX_DESCQ_OWNER_ID, 0,
+			      FRF_AZ_TX_DESCQ_LABEL, tx_queue->queue,
+			      FRF_AZ_TX_DESCQ_SIZE,
+			      __ffs(tx_queue->txd.entries),
+			      FRF_AZ_TX_DESCQ_TYPE, 0,
+			      FRF_BZ_TX_NON_IP_DROP_DIS, 1);
+
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) {
+		int csum = tx_queue->queue & EF4_TXQ_TYPE_OFFLOAD;
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
+		EF4_SET_OWORD_FIELD(reg, FRF_BZ_TX_TCP_CHKSM_DIS,
+				    !csum);
+	}
+
+	ef4_writeo_table(efx, &reg, efx->type->txd_ptr_tbl_base,
+			 tx_queue->queue);
+
+	if (ef4_nic_rev(efx) < EF4_REV_FALCON_B0) {
+		/* Only 128 bits in this register */
+		BUILD_BUG_ON(EF4_MAX_TX_QUEUES > 128);
+
+		ef4_reado(efx, &reg, FR_AA_TX_CHKSM_CFG);
+		if (tx_queue->queue & EF4_TXQ_TYPE_OFFLOAD)
+			__clear_bit_le(tx_queue->queue, &reg);
+		else
+			__set_bit_le(tx_queue->queue, &reg);
+		ef4_writeo(efx, &reg, FR_AA_TX_CHKSM_CFG);
+	}
+
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) {
+		EF4_POPULATE_OWORD_1(reg,
+				     FRF_BZ_TX_PACE,
+				     (tx_queue->queue & EF4_TXQ_TYPE_HIGHPRI) ?
+				     FFE_BZ_TX_PACE_OFF :
+				     FFE_BZ_TX_PACE_RESERVED);
+		ef4_writeo_table(efx, &reg, FR_BZ_TX_PACE_TBL,
+				 tx_queue->queue);
+	}
+}
+
+static void ef4_farch_flush_tx_queue(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	ef4_oword_t tx_flush_descq;
+
+	WARN_ON(atomic_read(&tx_queue->flush_outstanding));
+	atomic_set(&tx_queue->flush_outstanding, 1);
+
+	EF4_POPULATE_OWORD_2(tx_flush_descq,
+			     FRF_AZ_TX_FLUSH_DESCQ_CMD, 1,
+			     FRF_AZ_TX_FLUSH_DESCQ, tx_queue->queue);
+	ef4_writeo(efx, &tx_flush_descq, FR_AZ_TX_FLUSH_DESCQ);
+}
+
+void ef4_farch_tx_fini(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	ef4_oword_t tx_desc_ptr;
+
+	/* Remove TX descriptor ring from card */
+	EF4_ZERO_OWORD(tx_desc_ptr);
+	ef4_writeo_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
+			 tx_queue->queue);
+
+	/* Unpin TX descriptor ring */
+	ef4_fini_special_buffer(efx, &tx_queue->txd);
+}
+
+/* Free buffers backing TX queue */
+void ef4_farch_tx_remove(struct ef4_tx_queue *tx_queue)
+{
+	ef4_free_special_buffer(tx_queue->efx, &tx_queue->txd);
+}
+
+/**************************************************************************
+ *
+ * RX path
+ *
+ **************************************************************************/
+
+/* This creates an entry in the RX descriptor queue */
+static inline void
+ef4_farch_build_rx_desc(struct ef4_rx_queue *rx_queue, unsigned index)
+{
+	struct ef4_rx_buffer *rx_buf;
+	ef4_qword_t *rxd;
+
+	rxd = ef4_rx_desc(rx_queue, index);
+	rx_buf = ef4_rx_buffer(rx_queue, index);
+	EF4_POPULATE_QWORD_3(*rxd,
+			     FSF_AZ_RX_KER_BUF_SIZE,
+			     rx_buf->len -
+			     rx_queue->efx->type->rx_buffer_padding,
+			     FSF_AZ_RX_KER_BUF_REGION, 0,
+			     FSF_AZ_RX_KER_BUF_ADDR, rx_buf->dma_addr);
+}
+
+/* This writes to the RX_DESC_WPTR register for the specified receive
+ * descriptor ring.
+ */
+void ef4_farch_rx_write(struct ef4_rx_queue *rx_queue)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	ef4_dword_t reg;
+	unsigned write_ptr;
+
+	while (rx_queue->notified_count != rx_queue->added_count) {
+		ef4_farch_build_rx_desc(
+			rx_queue,
+			rx_queue->notified_count & rx_queue->ptr_mask);
+		++rx_queue->notified_count;
+	}
+
+	wmb();
+	write_ptr = rx_queue->added_count & rx_queue->ptr_mask;
+	EF4_POPULATE_DWORD_1(reg, FRF_AZ_RX_DESC_WPTR_DWORD, write_ptr);
+	ef4_writed_page(efx, &reg, FR_AZ_RX_DESC_UPD_DWORD_P0,
+			ef4_rx_queue_index(rx_queue));
+}
+
+int ef4_farch_rx_probe(struct ef4_rx_queue *rx_queue)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	unsigned entries;
+
+	entries = rx_queue->ptr_mask + 1;
+	return ef4_alloc_special_buffer(efx, &rx_queue->rxd,
+					entries * sizeof(ef4_qword_t));
+}
+
+void ef4_farch_rx_init(struct ef4_rx_queue *rx_queue)
+{
+	ef4_oword_t rx_desc_ptr;
+	struct ef4_nic *efx = rx_queue->efx;
+	bool is_b0 = ef4_nic_rev(efx) >= EF4_REV_FALCON_B0;
+	bool iscsi_digest_en = is_b0;
+	bool jumbo_en;
+
+	/* For kernel-mode queues in Falcon A1, the JUMBO flag enables
+	 * DMA to continue after a PCIe page boundary (and scattering
+	 * is not possible).  In Falcon B0 and Siena, it enables
+	 * scatter.
+	 */
+	jumbo_en = !is_b0 || efx->rx_scatter;
+
+	netif_dbg(efx, hw, efx->net_dev,
+		  "RX queue %d ring in special buffers %d-%d\n",
+		  ef4_rx_queue_index(rx_queue), rx_queue->rxd.index,
+		  rx_queue->rxd.index + rx_queue->rxd.entries - 1);
+
+	rx_queue->scatter_n = 0;
+
+	/* Pin RX descriptor ring */
+	ef4_init_special_buffer(efx, &rx_queue->rxd);
+
+	/* Push RX descriptor ring to card */
+	EF4_POPULATE_OWORD_10(rx_desc_ptr,
+			      FRF_AZ_RX_ISCSI_DDIG_EN, iscsi_digest_en,
+			      FRF_AZ_RX_ISCSI_HDIG_EN, iscsi_digest_en,
+			      FRF_AZ_RX_DESCQ_BUF_BASE_ID, rx_queue->rxd.index,
+			      FRF_AZ_RX_DESCQ_EVQ_ID,
+			      ef4_rx_queue_channel(rx_queue)->channel,
+			      FRF_AZ_RX_DESCQ_OWNER_ID, 0,
+			      FRF_AZ_RX_DESCQ_LABEL,
+			      ef4_rx_queue_index(rx_queue),
+			      FRF_AZ_RX_DESCQ_SIZE,
+			      __ffs(rx_queue->rxd.entries),
+			      FRF_AZ_RX_DESCQ_TYPE, 0 /* kernel queue */ ,
+			      FRF_AZ_RX_DESCQ_JUMBO, jumbo_en,
+			      FRF_AZ_RX_DESCQ_EN, 1);
+	ef4_writeo_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
+			 ef4_rx_queue_index(rx_queue));
+}
+
+static void ef4_farch_flush_rx_queue(struct ef4_rx_queue *rx_queue)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	ef4_oword_t rx_flush_descq;
+
+	EF4_POPULATE_OWORD_2(rx_flush_descq,
+			     FRF_AZ_RX_FLUSH_DESCQ_CMD, 1,
+			     FRF_AZ_RX_FLUSH_DESCQ,
+			     ef4_rx_queue_index(rx_queue));
+	ef4_writeo(efx, &rx_flush_descq, FR_AZ_RX_FLUSH_DESCQ);
+}
+
+void ef4_farch_rx_fini(struct ef4_rx_queue *rx_queue)
+{
+	ef4_oword_t rx_desc_ptr;
+	struct ef4_nic *efx = rx_queue->efx;
+
+	/* Remove RX descriptor ring from card */
+	EF4_ZERO_OWORD(rx_desc_ptr);
+	ef4_writeo_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
+			 ef4_rx_queue_index(rx_queue));
+
+	/* Unpin RX descriptor ring */
+	ef4_fini_special_buffer(efx, &rx_queue->rxd);
+}
+
+/* Free buffers backing RX queue */
+void ef4_farch_rx_remove(struct ef4_rx_queue *rx_queue)
+{
+	ef4_free_special_buffer(rx_queue->efx, &rx_queue->rxd);
+}
+
+/**************************************************************************
+ *
+ * Flush handling
+ *
+ **************************************************************************/
+
+/* ef4_farch_flush_queues() must be woken up when all flushes are completed,
+ * or more RX flushes can be kicked off.
+ */
+static bool ef4_farch_flush_wake(struct ef4_nic *efx)
+{
+	/* Ensure that all updates are visible to ef4_farch_flush_queues() */
+	smp_mb();
+
+	return (atomic_read(&efx->active_queues) == 0 ||
+		(atomic_read(&efx->rxq_flush_outstanding) < EF4_RX_FLUSH_COUNT
+		 && atomic_read(&efx->rxq_flush_pending) > 0));
+}
+
+static bool ef4_check_tx_flush_complete(struct ef4_nic *efx)
+{
+	bool i = true;
+	ef4_oword_t txd_ptr_tbl;
+	struct ef4_channel *channel;
+	struct ef4_tx_queue *tx_queue;
+
+	ef4_for_each_channel(channel, efx) {
+		ef4_for_each_channel_tx_queue(tx_queue, channel) {
+			ef4_reado_table(efx, &txd_ptr_tbl,
+					FR_BZ_TX_DESC_PTR_TBL, tx_queue->queue);
+			if (EF4_OWORD_FIELD(txd_ptr_tbl,
+					    FRF_AZ_TX_DESCQ_FLUSH) ||
+			    EF4_OWORD_FIELD(txd_ptr_tbl,
+					    FRF_AZ_TX_DESCQ_EN)) {
+				netif_dbg(efx, hw, efx->net_dev,
+					  "flush did not complete on TXQ %d\n",
+					  tx_queue->queue);
+				i = false;
+			} else if (atomic_cmpxchg(&tx_queue->flush_outstanding,
+						  1, 0)) {
+				/* The flush is complete, but we didn't
+				 * receive a flush completion event
+				 */
+				netif_dbg(efx, hw, efx->net_dev,
+					  "flush complete on TXQ %d, so drain "
+					  "the queue\n", tx_queue->queue);
+				/* Don't need to increment active_queues as it
+				 * has already been incremented for the queues
+				 * which did not drain
+				 */
+				ef4_farch_magic_event(channel,
+						      EF4_CHANNEL_MAGIC_TX_DRAIN(
+							      tx_queue));
+			}
+		}
+	}
+
+	return i;
+}
+
+/* Flush all the transmit queues, and continue flushing receive queues until
+ * they're all flushed. Wait for the DRAIN events to be received so that there
+ * are no more RX and TX events left on any channel. */
+static int ef4_farch_do_flush(struct ef4_nic *efx)
+{
+	unsigned timeout = msecs_to_jiffies(5000); /* 5s for all flushes and drains */
+	struct ef4_channel *channel;
+	struct ef4_rx_queue *rx_queue;
+	struct ef4_tx_queue *tx_queue;
+	int rc = 0;
+
+	ef4_for_each_channel(channel, efx) {
+		ef4_for_each_channel_tx_queue(tx_queue, channel) {
+			ef4_farch_flush_tx_queue(tx_queue);
+		}
+		ef4_for_each_channel_rx_queue(rx_queue, channel) {
+			rx_queue->flush_pending = true;
+			atomic_inc(&efx->rxq_flush_pending);
+		}
+	}
+
+	while (timeout && atomic_read(&efx->active_queues) > 0) {
+		/* The hardware supports four concurrent rx flushes, each of
+		 * which may need to be retried if there is an outstanding
+		 * descriptor fetch
+		 */
+		ef4_for_each_channel(channel, efx) {
+			ef4_for_each_channel_rx_queue(rx_queue, channel) {
+				if (atomic_read(&efx->rxq_flush_outstanding) >=
+				    EF4_RX_FLUSH_COUNT)
+					break;
+
+				if (rx_queue->flush_pending) {
+					rx_queue->flush_pending = false;
+					atomic_dec(&efx->rxq_flush_pending);
+					atomic_inc(&efx->rxq_flush_outstanding);
+					ef4_farch_flush_rx_queue(rx_queue);
+				}
+			}
+		}
+
+		timeout = wait_event_timeout(efx->flush_wq,
+					     ef4_farch_flush_wake(efx),
+					     timeout);
+	}
+
+	if (atomic_read(&efx->active_queues) &&
+	    !ef4_check_tx_flush_complete(efx)) {
+		netif_err(efx, hw, efx->net_dev, "failed to flush %d queues "
+			  "(rx %d+%d)\n", atomic_read(&efx->active_queues),
+			  atomic_read(&efx->rxq_flush_outstanding),
+			  atomic_read(&efx->rxq_flush_pending));
+		rc = -ETIMEDOUT;
+
+		atomic_set(&efx->active_queues, 0);
+		atomic_set(&efx->rxq_flush_pending, 0);
+		atomic_set(&efx->rxq_flush_outstanding, 0);
+	}
+
+	return rc;
+}
+
+int ef4_farch_fini_dmaq(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+	struct ef4_tx_queue *tx_queue;
+	struct ef4_rx_queue *rx_queue;
+	int rc = 0;
+
+	/* Do not attempt to write to the NIC during EEH recovery */
+	if (efx->state != STATE_RECOVERY) {
+		/* Only perform flush if DMA is enabled */
+		if (efx->pci_dev->is_busmaster) {
+			efx->type->prepare_flush(efx);
+			rc = ef4_farch_do_flush(efx);
+			efx->type->finish_flush(efx);
+		}
+
+		ef4_for_each_channel(channel, efx) {
+			ef4_for_each_channel_rx_queue(rx_queue, channel)
+				ef4_farch_rx_fini(rx_queue);
+			ef4_for_each_channel_tx_queue(tx_queue, channel)
+				ef4_farch_tx_fini(tx_queue);
+		}
+	}
+
+	return rc;
+}
+
+/* Reset queue and flush accounting after FLR
+ *
+ * One possible cause of FLR recovery is that DMA may be failing (eg. if bus
+ * mastering was disabled), in which case we don't receive (RXQ) flush
+ * completion events.  This means that efx->rxq_flush_outstanding remained at 4
+ * after the FLR; also, efx->active_queues was non-zero (as no flush completion
+ * events were received, and we didn't go through ef4_check_tx_flush_complete())
+ * If we don't fix this up, on the next call to ef4_realloc_channels() we won't
+ * flush any RX queues because efx->rxq_flush_outstanding is at the limit of 4
+ * for batched flush requests; and the efx->active_queues gets messed up because
+ * we keep incrementing for the newly initialised queues, but it never went to
+ * zero previously.  Then we get a timeout every time we try to restart the
+ * queues, as it doesn't go back to zero when we should be flushing the queues.
+ */
+void ef4_farch_finish_flr(struct ef4_nic *efx)
+{
+	atomic_set(&efx->rxq_flush_pending, 0);
+	atomic_set(&efx->rxq_flush_outstanding, 0);
+	atomic_set(&efx->active_queues, 0);
+}
+
+
+/**************************************************************************
+ *
+ * Event queue processing
+ * Event queues are processed by per-channel tasklets.
+ *
+ **************************************************************************/
+
+/* Update a channel's event queue's read pointer (RPTR) register
+ *
+ * This writes the EVQ_RPTR_REG register for the specified channel's
+ * event queue.
+ */
+void ef4_farch_ev_read_ack(struct ef4_channel *channel)
+{
+	ef4_dword_t reg;
+	struct ef4_nic *efx = channel->efx;
+
+	EF4_POPULATE_DWORD_1(reg, FRF_AZ_EVQ_RPTR,
+			     channel->eventq_read_ptr & channel->eventq_mask);
+
+	/* For Falcon A1, EVQ_RPTR_KER is documented as having a step size
+	 * of 4 bytes, but it is really 16 bytes just like later revisions.
+	 */
+	ef4_writed(efx, &reg,
+		   efx->type->evq_rptr_tbl_base +
+		   FR_BZ_EVQ_RPTR_STEP * channel->channel);
+}
+
+/* Use HW to insert a SW defined event */
+void ef4_farch_generate_event(struct ef4_nic *efx, unsigned int evq,
+			      ef4_qword_t *event)
+{
+	ef4_oword_t drv_ev_reg;
+
+	BUILD_BUG_ON(FRF_AZ_DRV_EV_DATA_LBN != 0 ||
+		     FRF_AZ_DRV_EV_DATA_WIDTH != 64);
+	drv_ev_reg.u32[0] = event->u32[0];
+	drv_ev_reg.u32[1] = event->u32[1];
+	drv_ev_reg.u32[2] = 0;
+	drv_ev_reg.u32[3] = 0;
+	EF4_SET_OWORD_FIELD(drv_ev_reg, FRF_AZ_DRV_EV_QID, evq);
+	ef4_writeo(efx, &drv_ev_reg, FR_AZ_DRV_EV);
+}
+
+static void ef4_farch_magic_event(struct ef4_channel *channel, u32 magic)
+{
+	ef4_qword_t event;
+
+	EF4_POPULATE_QWORD_2(event, FSF_AZ_EV_CODE,
+			     FSE_AZ_EV_CODE_DRV_GEN_EV,
+			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
+	ef4_farch_generate_event(channel->efx, channel->channel, &event);
+}
+
+/* Handle a transmit completion event
+ *
+ * The NIC batches TX completion events; the message we receive is of
+ * the form "complete all TX events up to this index".
+ */
+static int
+ef4_farch_handle_tx_event(struct ef4_channel *channel, ef4_qword_t *event)
+{
+	unsigned int tx_ev_desc_ptr;
+	unsigned int tx_ev_q_label;
+	struct ef4_tx_queue *tx_queue;
+	struct ef4_nic *efx = channel->efx;
+	int tx_packets = 0;
+
+	if (unlikely(ACCESS_ONCE(efx->reset_pending)))
+		return 0;
+
+	if (likely(EF4_QWORD_FIELD(*event, FSF_AZ_TX_EV_COMP))) {
+		/* Transmit completion */
+		tx_ev_desc_ptr = EF4_QWORD_FIELD(*event, FSF_AZ_TX_EV_DESC_PTR);
+		tx_ev_q_label = EF4_QWORD_FIELD(*event, FSF_AZ_TX_EV_Q_LABEL);
+		tx_queue = ef4_channel_get_tx_queue(
+			channel, tx_ev_q_label % EF4_TXQ_TYPES);
+		tx_packets = ((tx_ev_desc_ptr - tx_queue->read_count) &
+			      tx_queue->ptr_mask);
+		ef4_xmit_done(tx_queue, tx_ev_desc_ptr);
+	} else if (EF4_QWORD_FIELD(*event, FSF_AZ_TX_EV_WQ_FF_FULL)) {
+		/* Rewrite the FIFO write pointer */
+		tx_ev_q_label = EF4_QWORD_FIELD(*event, FSF_AZ_TX_EV_Q_LABEL);
+		tx_queue = ef4_channel_get_tx_queue(
+			channel, tx_ev_q_label % EF4_TXQ_TYPES);
+
+		netif_tx_lock(efx->net_dev);
+		ef4_farch_notify_tx_desc(tx_queue);
+		netif_tx_unlock(efx->net_dev);
+	} else if (EF4_QWORD_FIELD(*event, FSF_AZ_TX_EV_PKT_ERR)) {
+		ef4_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
+	} else {
+		netif_err(efx, tx_err, efx->net_dev,
+			  "channel %d unexpected TX event "
+			  EF4_QWORD_FMT"\n", channel->channel,
+			  EF4_QWORD_VAL(*event));
+	}
+
+	return tx_packets;
+}
+
+/* Detect errors included in the rx_evt_pkt_ok bit. */
+static u16 ef4_farch_handle_rx_not_ok(struct ef4_rx_queue *rx_queue,
+				      const ef4_qword_t *event)
+{
+	struct ef4_channel *channel = ef4_rx_queue_channel(rx_queue);
+	struct ef4_nic *efx = rx_queue->efx;
+	bool rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
+	bool rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
+	bool rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
+	bool rx_ev_other_err, rx_ev_pause_frm;
+	bool rx_ev_hdr_type, rx_ev_mcast_pkt;
+	unsigned rx_ev_pkt_type;
+
+	rx_ev_hdr_type = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_HDR_TYPE);
+	rx_ev_mcast_pkt = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_MCAST_PKT);
+	rx_ev_tobe_disc = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_TOBE_DISC);
+	rx_ev_pkt_type = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_PKT_TYPE);
+	rx_ev_buf_owner_id_err = EF4_QWORD_FIELD(*event,
+						 FSF_AZ_RX_EV_BUF_OWNER_ID_ERR);
+	rx_ev_ip_hdr_chksum_err = EF4_QWORD_FIELD(*event,
+						  FSF_AZ_RX_EV_IP_HDR_CHKSUM_ERR);
+	rx_ev_tcp_udp_chksum_err = EF4_QWORD_FIELD(*event,
+						   FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR);
+	rx_ev_eth_crc_err = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_ETH_CRC_ERR);
+	rx_ev_frm_trunc = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_FRM_TRUNC);
+	rx_ev_drib_nib = ((ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) ?
+			  0 : EF4_QWORD_FIELD(*event, FSF_AA_RX_EV_DRIB_NIB));
+	rx_ev_pause_frm = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_PAUSE_FRM_ERR);
+
+	/* Every error apart from tobe_disc and pause_frm */
+	rx_ev_other_err = (rx_ev_drib_nib | rx_ev_tcp_udp_chksum_err |
+			   rx_ev_buf_owner_id_err | rx_ev_eth_crc_err |
+			   rx_ev_frm_trunc | rx_ev_ip_hdr_chksum_err);
+
+	/* Count errors that are not in MAC stats.  Ignore expected
+	 * checksum errors during self-test. */
+	if (rx_ev_frm_trunc)
+		++channel->n_rx_frm_trunc;
+	else if (rx_ev_tobe_disc)
+		++channel->n_rx_tobe_disc;
+	else if (!efx->loopback_selftest) {
+		if (rx_ev_ip_hdr_chksum_err)
+			++channel->n_rx_ip_hdr_chksum_err;
+		else if (rx_ev_tcp_udp_chksum_err)
+			++channel->n_rx_tcp_udp_chksum_err;
+	}
+
+	/* TOBE_DISC is expected on unicast mismatches; don't print out an
+	 * error message.  FRM_TRUNC indicates RXDP dropped the packet due
+	 * to a FIFO overflow.
+	 */
+#ifdef DEBUG
+	if (rx_ev_other_err && net_ratelimit()) {
+		netif_dbg(efx, rx_err, efx->net_dev,
+			  " RX queue %d unexpected RX event "
+			  EF4_QWORD_FMT "%s%s%s%s%s%s%s%s\n",
+			  ef4_rx_queue_index(rx_queue), EF4_QWORD_VAL(*event),
+			  rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
+			  rx_ev_ip_hdr_chksum_err ?
+			  " [IP_HDR_CHKSUM_ERR]" : "",
+			  rx_ev_tcp_udp_chksum_err ?
+			  " [TCP_UDP_CHKSUM_ERR]" : "",
+			  rx_ev_eth_crc_err ? " [ETH_CRC_ERR]" : "",
+			  rx_ev_frm_trunc ? " [FRM_TRUNC]" : "",
+			  rx_ev_drib_nib ? " [DRIB_NIB]" : "",
+			  rx_ev_tobe_disc ? " [TOBE_DISC]" : "",
+			  rx_ev_pause_frm ? " [PAUSE]" : "");
+	}
+#endif
+
+	/* The frame must be discarded if any of these are true. */
+	return (rx_ev_eth_crc_err | rx_ev_frm_trunc | rx_ev_drib_nib |
+		rx_ev_tobe_disc | rx_ev_pause_frm) ?
+		EF4_RX_PKT_DISCARD : 0;
+}
+
+/* Handle receive events that are not in-order. Return true if this
+ * can be handled as a partial packet discard, false if it's more
+ * serious.
+ */
+static bool
+ef4_farch_handle_rx_bad_index(struct ef4_rx_queue *rx_queue, unsigned index)
+{
+	struct ef4_channel *channel = ef4_rx_queue_channel(rx_queue);
+	struct ef4_nic *efx = rx_queue->efx;
+	unsigned expected, dropped;
+
+	if (rx_queue->scatter_n &&
+	    index == ((rx_queue->removed_count + rx_queue->scatter_n - 1) &
+		      rx_queue->ptr_mask)) {
+		++channel->n_rx_nodesc_trunc;
+		return true;
+	}
+
+	expected = rx_queue->removed_count & rx_queue->ptr_mask;
+	dropped = (index - expected) & rx_queue->ptr_mask;
+	netif_info(efx, rx_err, efx->net_dev,
+		   "dropped %d events (index=%d expected=%d)\n",
+		   dropped, index, expected);
+
+	ef4_schedule_reset(efx, EF4_WORKAROUND_5676(efx) ?
+			   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
+	return false;
+}
+
+/* Handle a packet received event
+ *
+ * The NIC gives a "discard" flag if it's a unicast packet with the
+ * wrong destination address
+ * Also "is multicast" and "matches multicast filter" flags can be used to
+ * discard non-matching multicast packets.
+ */
+static void
+ef4_farch_handle_rx_event(struct ef4_channel *channel, const ef4_qword_t *event)
+{
+	unsigned int rx_ev_desc_ptr, rx_ev_byte_cnt;
+	unsigned int rx_ev_hdr_type, rx_ev_mcast_pkt;
+	unsigned expected_ptr;
+	bool rx_ev_pkt_ok, rx_ev_sop, rx_ev_cont;
+	u16 flags;
+	struct ef4_rx_queue *rx_queue;
+	struct ef4_nic *efx = channel->efx;
+
+	if (unlikely(ACCESS_ONCE(efx->reset_pending)))
+		return;
+
+	rx_ev_cont = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_JUMBO_CONT);
+	rx_ev_sop = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_SOP);
+	WARN_ON(EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_Q_LABEL) !=
+		channel->channel);
+
+	rx_queue = ef4_channel_get_rx_queue(channel);
+
+	rx_ev_desc_ptr = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_DESC_PTR);
+	expected_ptr = ((rx_queue->removed_count + rx_queue->scatter_n) &
+			rx_queue->ptr_mask);
+
+	/* Check for partial drops and other errors */
+	if (unlikely(rx_ev_desc_ptr != expected_ptr) ||
+	    unlikely(rx_ev_sop != (rx_queue->scatter_n == 0))) {
+		if (rx_ev_desc_ptr != expected_ptr &&
+		    !ef4_farch_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr))
+			return;
+
+		/* Discard all pending fragments */
+		if (rx_queue->scatter_n) {
+			ef4_rx_packet(
+				rx_queue,
+				rx_queue->removed_count & rx_queue->ptr_mask,
+				rx_queue->scatter_n, 0, EF4_RX_PKT_DISCARD);
+			rx_queue->removed_count += rx_queue->scatter_n;
+			rx_queue->scatter_n = 0;
+		}
+
+		/* Return if there is no new fragment */
+		if (rx_ev_desc_ptr != expected_ptr)
+			return;
+
+		/* Discard new fragment if not SOP */
+		if (!rx_ev_sop) {
+			ef4_rx_packet(
+				rx_queue,
+				rx_queue->removed_count & rx_queue->ptr_mask,
+				1, 0, EF4_RX_PKT_DISCARD);
+			++rx_queue->removed_count;
+			return;
+		}
+	}
+
+	++rx_queue->scatter_n;
+	if (rx_ev_cont)
+		return;
+
+	rx_ev_byte_cnt = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_BYTE_CNT);
+	rx_ev_pkt_ok = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_PKT_OK);
+	rx_ev_hdr_type = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_HDR_TYPE);
+
+	if (likely(rx_ev_pkt_ok)) {
+		/* If packet is marked as OK then we can rely on the
+		 * hardware checksum and classification.
+		 */
+		flags = 0;
+		switch (rx_ev_hdr_type) {
+		case FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP:
+			flags |= EF4_RX_PKT_TCP;
+			/* fall through */
+		case FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP:
+			flags |= EF4_RX_PKT_CSUMMED;
+			/* fall through */
+		case FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_OTHER:
+		case FSE_AZ_RX_EV_HDR_TYPE_OTHER:
+			break;
+		}
+	} else {
+		flags = ef4_farch_handle_rx_not_ok(rx_queue, event);
+	}
+
+	/* Detect multicast packets that didn't match the filter */
+	rx_ev_mcast_pkt = EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_MCAST_PKT);
+	if (rx_ev_mcast_pkt) {
+		unsigned int rx_ev_mcast_hash_match =
+			EF4_QWORD_FIELD(*event, FSF_AZ_RX_EV_MCAST_HASH_MATCH);
+
+		if (unlikely(!rx_ev_mcast_hash_match)) {
+			++channel->n_rx_mcast_mismatch;
+			flags |= EF4_RX_PKT_DISCARD;
+		}
+	}
+
+	channel->irq_mod_score += 2;
+
+	/* Handle received packet */
+	ef4_rx_packet(rx_queue,
+		      rx_queue->removed_count & rx_queue->ptr_mask,
+		      rx_queue->scatter_n, rx_ev_byte_cnt, flags);
+	rx_queue->removed_count += rx_queue->scatter_n;
+	rx_queue->scatter_n = 0;
+}
+
+/* If this flush done event corresponds to a &struct ef4_tx_queue, then
+ * send an %EF4_CHANNEL_MAGIC_TX_DRAIN event to drain the event queue
+ * of all transmit completions.
+ */
+static void
+ef4_farch_handle_tx_flush_done(struct ef4_nic *efx, ef4_qword_t *event)
+{
+	struct ef4_tx_queue *tx_queue;
+	int qid;
+
+	qid = EF4_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_SUBDATA);
+	if (qid < EF4_TXQ_TYPES * efx->n_tx_channels) {
+		tx_queue = ef4_get_tx_queue(efx, qid / EF4_TXQ_TYPES,
+					    qid % EF4_TXQ_TYPES);
+		if (atomic_cmpxchg(&tx_queue->flush_outstanding, 1, 0)) {
+			ef4_farch_magic_event(tx_queue->channel,
+					      EF4_CHANNEL_MAGIC_TX_DRAIN(tx_queue));
+		}
+	}
+}
+
+/* If this flush done event corresponds to a &struct ef4_rx_queue: If the flush
+ * was successful then send an %EF4_CHANNEL_MAGIC_RX_DRAIN, otherwise add
+ * the RX queue back to the mask of RX queues in need of flushing.
+ */
+static void
+ef4_farch_handle_rx_flush_done(struct ef4_nic *efx, ef4_qword_t *event)
+{
+	struct ef4_channel *channel;
+	struct ef4_rx_queue *rx_queue;
+	int qid;
+	bool failed;
+
+	qid = EF4_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_RX_DESCQ_ID);
+	failed = EF4_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL);
+	if (qid >= efx->n_channels)
+		return;
+	channel = ef4_get_channel(efx, qid);
+	if (!ef4_channel_has_rx_queue(channel))
+		return;
+	rx_queue = ef4_channel_get_rx_queue(channel);
+
+	if (failed) {
+		netif_info(efx, hw, efx->net_dev,
+			   "RXQ %d flush retry\n", qid);
+		rx_queue->flush_pending = true;
+		atomic_inc(&efx->rxq_flush_pending);
+	} else {
+		ef4_farch_magic_event(ef4_rx_queue_channel(rx_queue),
+				      EF4_CHANNEL_MAGIC_RX_DRAIN(rx_queue));
+	}
+	atomic_dec(&efx->rxq_flush_outstanding);
+	if (ef4_farch_flush_wake(efx))
+		wake_up(&efx->flush_wq);
+}
+
+static void
+ef4_farch_handle_drain_event(struct ef4_channel *channel)
+{
+	struct ef4_nic *efx = channel->efx;
+
+	WARN_ON(atomic_read(&efx->active_queues) == 0);
+	atomic_dec(&efx->active_queues);
+	if (ef4_farch_flush_wake(efx))
+		wake_up(&efx->flush_wq);
+}
+
+static void ef4_farch_handle_generated_event(struct ef4_channel *channel,
+					     ef4_qword_t *event)
+{
+	struct ef4_nic *efx = channel->efx;
+	struct ef4_rx_queue *rx_queue =
+		ef4_channel_has_rx_queue(channel) ?
+		ef4_channel_get_rx_queue(channel) : NULL;
+	unsigned magic, code;
+
+	magic = EF4_QWORD_FIELD(*event, FSF_AZ_DRV_GEN_EV_MAGIC);
+	code = _EF4_CHANNEL_MAGIC_CODE(magic);
+
+	if (magic == EF4_CHANNEL_MAGIC_TEST(channel)) {
+		channel->event_test_cpu = raw_smp_processor_id();
+	} else if (rx_queue && magic == EF4_CHANNEL_MAGIC_FILL(rx_queue)) {
+		/* The queue must be empty, so we won't receive any rx
+		 * events, so ef4_process_channel() won't refill the
+		 * queue. Refill it here */
+		ef4_fast_push_rx_descriptors(rx_queue, true);
+	} else if (rx_queue && magic == EF4_CHANNEL_MAGIC_RX_DRAIN(rx_queue)) {
+		ef4_farch_handle_drain_event(channel);
+	} else if (code == _EF4_CHANNEL_MAGIC_TX_DRAIN) {
+		ef4_farch_handle_drain_event(channel);
+	} else {
+		netif_dbg(efx, hw, efx->net_dev, "channel %d received "
+			  "generated event "EF4_QWORD_FMT"\n",
+			  channel->channel, EF4_QWORD_VAL(*event));
+	}
+}
+
+static void
+ef4_farch_handle_driver_event(struct ef4_channel *channel, ef4_qword_t *event)
+{
+	struct ef4_nic *efx = channel->efx;
+	unsigned int ev_sub_code;
+	unsigned int ev_sub_data;
+
+	ev_sub_code = EF4_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_SUBCODE);
+	ev_sub_data = EF4_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_SUBDATA);
+
+	switch (ev_sub_code) {
+	case FSE_AZ_TX_DESCQ_FLS_DONE_EV:
+		netif_vdbg(efx, hw, efx->net_dev, "channel %d TXQ %d flushed\n",
+			   channel->channel, ev_sub_data);
+		ef4_farch_handle_tx_flush_done(efx, event);
+		break;
+	case FSE_AZ_RX_DESCQ_FLS_DONE_EV:
+		netif_vdbg(efx, hw, efx->net_dev, "channel %d RXQ %d flushed\n",
+			   channel->channel, ev_sub_data);
+		ef4_farch_handle_rx_flush_done(efx, event);
+		break;
+	case FSE_AZ_EVQ_INIT_DONE_EV:
+		netif_dbg(efx, hw, efx->net_dev,
+			  "channel %d EVQ %d initialised\n",
+			  channel->channel, ev_sub_data);
+		break;
+	case FSE_AZ_SRM_UPD_DONE_EV:
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d SRAM update done\n", channel->channel);
+		break;
+	case FSE_AZ_WAKE_UP_EV:
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d RXQ %d wakeup event\n",
+			   channel->channel, ev_sub_data);
+		break;
+	case FSE_AZ_TIMER_EV:
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d RX queue %d timer expired\n",
+			   channel->channel, ev_sub_data);
+		break;
+	case FSE_AA_RX_RECOVER_EV:
+		netif_err(efx, rx_err, efx->net_dev,
+			  "channel %d seen DRIVER RX_RESET event. "
+			"Resetting.\n", channel->channel);
+		atomic_inc(&efx->rx_reset);
+		ef4_schedule_reset(efx,
+				   EF4_WORKAROUND_6555(efx) ?
+				   RESET_TYPE_RX_RECOVERY :
+				   RESET_TYPE_DISABLE);
+		break;
+	case FSE_BZ_RX_DSC_ERROR_EV:
+		netif_err(efx, rx_err, efx->net_dev,
+			  "RX DMA Q %d reports descriptor fetch error."
+			  " RX Q %d is disabled.\n", ev_sub_data,
+			  ev_sub_data);
+		ef4_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
+		break;
+	case FSE_BZ_TX_DSC_ERROR_EV:
+		netif_err(efx, tx_err, efx->net_dev,
+			  "TX DMA Q %d reports descriptor fetch error."
+			  " TX Q %d is disabled.\n", ev_sub_data,
+			  ev_sub_data);
+		ef4_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
+		break;
+	default:
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d unknown driver event code %d "
+			   "data %04x\n", channel->channel, ev_sub_code,
+			   ev_sub_data);
+		break;
+	}
+}
+
+int ef4_farch_ev_process(struct ef4_channel *channel, int budget)
+{
+	struct ef4_nic *efx = channel->efx;
+	unsigned int read_ptr;
+	ef4_qword_t event, *p_event;
+	int ev_code;
+	int tx_packets = 0;
+	int spent = 0;
+
+	if (budget <= 0)
+		return spent;
+
+	read_ptr = channel->eventq_read_ptr;
+
+	for (;;) {
+		p_event = ef4_event(channel, read_ptr);
+		event = *p_event;
+
+		if (!ef4_event_present(&event))
+			/* End of events */
+			break;
+
+		netif_vdbg(channel->efx, intr, channel->efx->net_dev,
+			   "channel %d event is "EF4_QWORD_FMT"\n",
+			   channel->channel, EF4_QWORD_VAL(event));
+
+		/* Clear this event by marking it all ones */
+		EF4_SET_QWORD(*p_event);
+
+		++read_ptr;
+
+		ev_code = EF4_QWORD_FIELD(event, FSF_AZ_EV_CODE);
+
+		switch (ev_code) {
+		case FSE_AZ_EV_CODE_RX_EV:
+			ef4_farch_handle_rx_event(channel, &event);
+			if (++spent == budget)
+				goto out;
+			break;
+		case FSE_AZ_EV_CODE_TX_EV:
+			tx_packets += ef4_farch_handle_tx_event(channel,
+								&event);
+			if (tx_packets > efx->txq_entries) {
+				spent = budget;
+				goto out;
+			}
+			break;
+		case FSE_AZ_EV_CODE_DRV_GEN_EV:
+			ef4_farch_handle_generated_event(channel, &event);
+			break;
+		case FSE_AZ_EV_CODE_DRIVER_EV:
+			ef4_farch_handle_driver_event(channel, &event);
+			break;
+		case FSE_AZ_EV_CODE_GLOBAL_EV:
+			if (efx->type->handle_global_event &&
+			    efx->type->handle_global_event(channel, &event))
+				break;
+			/* else fall through */
+		default:
+			netif_err(channel->efx, hw, channel->efx->net_dev,
+				  "channel %d unknown event type %d (data "
+				  EF4_QWORD_FMT ")\n", channel->channel,
+				  ev_code, EF4_QWORD_VAL(event));
+		}
+	}
+
+out:
+	channel->eventq_read_ptr = read_ptr;
+	return spent;
+}
+
+/* Allocate buffer table entries for event queue */
+int ef4_farch_ev_probe(struct ef4_channel *channel)
+{
+	struct ef4_nic *efx = channel->efx;
+	unsigned entries;
+
+	entries = channel->eventq_mask + 1;
+	return ef4_alloc_special_buffer(efx, &channel->eventq,
+					entries * sizeof(ef4_qword_t));
+}
+
+int ef4_farch_ev_init(struct ef4_channel *channel)
+{
+	ef4_oword_t reg;
+	struct ef4_nic *efx = channel->efx;
+
+	netif_dbg(efx, hw, efx->net_dev,
+		  "channel %d event queue in special buffers %d-%d\n",
+		  channel->channel, channel->eventq.index,
+		  channel->eventq.index + channel->eventq.entries - 1);
+
+	/* Pin event queue buffer */
+	ef4_init_special_buffer(efx, &channel->eventq);
+
+	/* Fill event queue with all ones (i.e. empty events) */
+	memset(channel->eventq.buf.addr, 0xff, channel->eventq.buf.len);
+
+	/* Push event queue to card */
+	EF4_POPULATE_OWORD_3(reg,
+			     FRF_AZ_EVQ_EN, 1,
+			     FRF_AZ_EVQ_SIZE, __ffs(channel->eventq.entries),
+			     FRF_AZ_EVQ_BUF_BASE_ID, channel->eventq.index);
+	ef4_writeo_table(efx, &reg, efx->type->evq_ptr_tbl_base,
+			 channel->channel);
+
+	return 0;
+}
+
+void ef4_farch_ev_fini(struct ef4_channel *channel)
+{
+	ef4_oword_t reg;
+	struct ef4_nic *efx = channel->efx;
+
+	/* Remove event queue from card */
+	EF4_ZERO_OWORD(reg);
+	ef4_writeo_table(efx, &reg, efx->type->evq_ptr_tbl_base,
+			 channel->channel);
+
+	/* Unpin event queue */
+	ef4_fini_special_buffer(efx, &channel->eventq);
+}
+
+/* Free buffers backing event queue */
+void ef4_farch_ev_remove(struct ef4_channel *channel)
+{
+	ef4_free_special_buffer(channel->efx, &channel->eventq);
+}
+
+
+void ef4_farch_ev_test_generate(struct ef4_channel *channel)
+{
+	ef4_farch_magic_event(channel, EF4_CHANNEL_MAGIC_TEST(channel));
+}
+
+void ef4_farch_rx_defer_refill(struct ef4_rx_queue *rx_queue)
+{
+	ef4_farch_magic_event(ef4_rx_queue_channel(rx_queue),
+			      EF4_CHANNEL_MAGIC_FILL(rx_queue));
+}
+
+/**************************************************************************
+ *
+ * Hardware interrupts
+ * The hardware interrupt handler does very little work; all the event
+ * queue processing is carried out by per-channel tasklets.
+ *
+ **************************************************************************/
+
+/* Enable/disable/generate interrupts */
+static inline void ef4_farch_interrupts(struct ef4_nic *efx,
+				      bool enabled, bool force)
+{
+	ef4_oword_t int_en_reg_ker;
+
+	EF4_POPULATE_OWORD_3(int_en_reg_ker,
+			     FRF_AZ_KER_INT_LEVE_SEL, efx->irq_level,
+			     FRF_AZ_KER_INT_KER, force,
+			     FRF_AZ_DRV_INT_EN_KER, enabled);
+	ef4_writeo(efx, &int_en_reg_ker, FR_AZ_INT_EN_KER);
+}
+
+void ef4_farch_irq_enable_master(struct ef4_nic *efx)
+{
+	EF4_ZERO_OWORD(*((ef4_oword_t *) efx->irq_status.addr));
+	wmb(); /* Ensure interrupt vector is clear before interrupts enabled */
+
+	ef4_farch_interrupts(efx, true, false);
+}
+
+void ef4_farch_irq_disable_master(struct ef4_nic *efx)
+{
+	/* Disable interrupts */
+	ef4_farch_interrupts(efx, false, false);
+}
+
+/* Generate a test interrupt
+ * Interrupt must already have been enabled, otherwise nasty things
+ * may happen.
+ */
+int ef4_farch_irq_test_generate(struct ef4_nic *efx)
+{
+	ef4_farch_interrupts(efx, true, true);
+	return 0;
+}
+
+/* Process a fatal interrupt
+ * Disable bus mastering ASAP and schedule a reset
+ */
+irqreturn_t ef4_farch_fatal_interrupt(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	ef4_oword_t *int_ker = efx->irq_status.addr;
+	ef4_oword_t fatal_intr;
+	int error, mem_perr;
+
+	ef4_reado(efx, &fatal_intr, FR_AZ_FATAL_INTR_KER);
+	error = EF4_OWORD_FIELD(fatal_intr, FRF_AZ_FATAL_INTR);
+
+	netif_err(efx, hw, efx->net_dev, "SYSTEM ERROR "EF4_OWORD_FMT" status "
+		  EF4_OWORD_FMT ": %s\n", EF4_OWORD_VAL(*int_ker),
+		  EF4_OWORD_VAL(fatal_intr),
+		  error ? "disabling bus mastering" : "no recognised error");
+
+	/* If this is a memory parity error dump which blocks are offending */
+	mem_perr = (EF4_OWORD_FIELD(fatal_intr, FRF_AZ_MEM_PERR_INT_KER) ||
+		    EF4_OWORD_FIELD(fatal_intr, FRF_AZ_SRM_PERR_INT_KER));
+	if (mem_perr) {
+		ef4_oword_t reg;
+		ef4_reado(efx, &reg, FR_AZ_MEM_STAT);
+		netif_err(efx, hw, efx->net_dev,
+			  "SYSTEM ERROR: memory parity error "EF4_OWORD_FMT"\n",
+			  EF4_OWORD_VAL(reg));
+	}
+
+	/* Disable both devices */
+	pci_clear_master(efx->pci_dev);
+	if (ef4_nic_is_dual_func(efx))
+		pci_clear_master(nic_data->pci_dev2);
+	ef4_farch_irq_disable_master(efx);
+
+	/* Count errors and reset or disable the NIC accordingly */
+	if (efx->int_error_count == 0 ||
+	    time_after(jiffies, efx->int_error_expire)) {
+		efx->int_error_count = 0;
+		efx->int_error_expire =
+			jiffies + EF4_INT_ERROR_EXPIRE * HZ;
+	}
+	if (++efx->int_error_count < EF4_MAX_INT_ERRORS) {
+		netif_err(efx, hw, efx->net_dev,
+			  "SYSTEM ERROR - reset scheduled\n");
+		ef4_schedule_reset(efx, RESET_TYPE_INT_ERROR);
+	} else {
+		netif_err(efx, hw, efx->net_dev,
+			  "SYSTEM ERROR - max number of errors seen."
+			  "NIC will be disabled\n");
+		ef4_schedule_reset(efx, RESET_TYPE_DISABLE);
+	}
+
+	return IRQ_HANDLED;
+}
+
+/* Handle a legacy interrupt
+ * Acknowledges the interrupt and schedule event queue processing.
+ */
+irqreturn_t ef4_farch_legacy_interrupt(int irq, void *dev_id)
+{
+	struct ef4_nic *efx = dev_id;
+	bool soft_enabled = ACCESS_ONCE(efx->irq_soft_enabled);
+	ef4_oword_t *int_ker = efx->irq_status.addr;
+	irqreturn_t result = IRQ_NONE;
+	struct ef4_channel *channel;
+	ef4_dword_t reg;
+	u32 queues;
+	int syserr;
+
+	/* Read the ISR which also ACKs the interrupts */
+	ef4_readd(efx, &reg, FR_BZ_INT_ISR0);
+	queues = EF4_EXTRACT_DWORD(reg, 0, 31);
+
+	/* Legacy interrupts are disabled too late by the EEH kernel
+	 * code. Disable them earlier.
+	 * If an EEH error occurred, the read will have returned all ones.
+	 */
+	if (EF4_DWORD_IS_ALL_ONES(reg) && ef4_try_recovery(efx) &&
+	    !efx->eeh_disabled_legacy_irq) {
+		disable_irq_nosync(efx->legacy_irq);
+		efx->eeh_disabled_legacy_irq = true;
+	}
+
+	/* Handle non-event-queue sources */
+	if (queues & (1U << efx->irq_level) && soft_enabled) {
+		syserr = EF4_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
+		if (unlikely(syserr))
+			return ef4_farch_fatal_interrupt(efx);
+		efx->last_irq_cpu = raw_smp_processor_id();
+	}
+
+	if (queues != 0) {
+		efx->irq_zero_count = 0;
+
+		/* Schedule processing of any interrupting queues */
+		if (likely(soft_enabled)) {
+			ef4_for_each_channel(channel, efx) {
+				if (queues & 1)
+					ef4_schedule_channel_irq(channel);
+				queues >>= 1;
+			}
+		}
+		result = IRQ_HANDLED;
+
+	} else {
+		ef4_qword_t *event;
+
+		/* Legacy ISR read can return zero once (SF bug 15783) */
+
+		/* We can't return IRQ_HANDLED more than once on seeing ISR=0
+		 * because this might be a shared interrupt. */
+		if (efx->irq_zero_count++ == 0)
+			result = IRQ_HANDLED;
+
+		/* Ensure we schedule or rearm all event queues */
+		if (likely(soft_enabled)) {
+			ef4_for_each_channel(channel, efx) {
+				event = ef4_event(channel,
+						  channel->eventq_read_ptr);
+				if (ef4_event_present(event))
+					ef4_schedule_channel_irq(channel);
+				else
+					ef4_farch_ev_read_ack(channel);
+			}
+		}
+	}
+
+	if (result == IRQ_HANDLED)
+		netif_vdbg(efx, intr, efx->net_dev,
+			   "IRQ %d on CPU %d status " EF4_DWORD_FMT "\n",
+			   irq, raw_smp_processor_id(), EF4_DWORD_VAL(reg));
+
+	return result;
+}
+
+/* Handle an MSI interrupt
+ *
+ * Handle an MSI hardware interrupt.  This routine schedules event
+ * queue processing.  No interrupt acknowledgement cycle is necessary.
+ * Also, we never need to check that the interrupt is for us, since
+ * MSI interrupts cannot be shared.
+ */
+irqreturn_t ef4_farch_msi_interrupt(int irq, void *dev_id)
+{
+	struct ef4_msi_context *context = dev_id;
+	struct ef4_nic *efx = context->efx;
+	ef4_oword_t *int_ker = efx->irq_status.addr;
+	int syserr;
+
+	netif_vdbg(efx, intr, efx->net_dev,
+		   "IRQ %d on CPU %d status " EF4_OWORD_FMT "\n",
+		   irq, raw_smp_processor_id(), EF4_OWORD_VAL(*int_ker));
+
+	if (!likely(ACCESS_ONCE(efx->irq_soft_enabled)))
+		return IRQ_HANDLED;
+
+	/* Handle non-event-queue sources */
+	if (context->index == efx->irq_level) {
+		syserr = EF4_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
+		if (unlikely(syserr))
+			return ef4_farch_fatal_interrupt(efx);
+		efx->last_irq_cpu = raw_smp_processor_id();
+	}
+
+	/* Schedule processing of the channel */
+	ef4_schedule_channel_irq(efx->channel[context->index]);
+
+	return IRQ_HANDLED;
+}
+
+/* Setup RSS indirection table.
+ * This maps from the hash value of the packet to RXQ
+ */
+void ef4_farch_rx_push_indir_table(struct ef4_nic *efx)
+{
+	size_t i = 0;
+	ef4_dword_t dword;
+
+	BUG_ON(ef4_nic_rev(efx) < EF4_REV_FALCON_B0);
+
+	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_indir_table) !=
+		     FR_BZ_RX_INDIRECTION_TBL_ROWS);
+
+	for (i = 0; i < FR_BZ_RX_INDIRECTION_TBL_ROWS; i++) {
+		EF4_POPULATE_DWORD_1(dword, FRF_BZ_IT_QUEUE,
+				     efx->rx_indir_table[i]);
+		ef4_writed(efx, &dword,
+			   FR_BZ_RX_INDIRECTION_TBL +
+			   FR_BZ_RX_INDIRECTION_TBL_STEP * i);
+	}
+}
+
+/* Looks at available SRAM resources and works out how many queues we
+ * can support, and where things like descriptor caches should live.
+ *
+ * SRAM is split up as follows:
+ * 0                          buftbl entries for channels
+ * efx->vf_buftbl_base        buftbl entries for SR-IOV
+ * efx->rx_dc_base            RX descriptor caches
+ * efx->tx_dc_base            TX descriptor caches
+ */
+void ef4_farch_dimension_resources(struct ef4_nic *efx, unsigned sram_lim_qw)
+{
+	unsigned vi_count, buftbl_min;
+
+	/* Account for the buffer table entries backing the datapath channels
+	 * and the descriptor caches for those channels.
+	 */
+	buftbl_min = ((efx->n_rx_channels * EF4_MAX_DMAQ_SIZE +
+		       efx->n_tx_channels * EF4_TXQ_TYPES * EF4_MAX_DMAQ_SIZE +
+		       efx->n_channels * EF4_MAX_EVQ_SIZE)
+		      * sizeof(ef4_qword_t) / EF4_BUF_SIZE);
+	vi_count = max(efx->n_channels, efx->n_tx_channels * EF4_TXQ_TYPES);
+
+	efx->tx_dc_base = sram_lim_qw - vi_count * TX_DC_ENTRIES;
+	efx->rx_dc_base = efx->tx_dc_base - vi_count * RX_DC_ENTRIES;
+}
+
+u32 ef4_farch_fpga_ver(struct ef4_nic *efx)
+{
+	ef4_oword_t altera_build;
+	ef4_reado(efx, &altera_build, FR_AZ_ALTERA_BUILD);
+	return EF4_OWORD_FIELD(altera_build, FRF_AZ_ALTERA_BUILD_VER);
+}
+
+void ef4_farch_init_common(struct ef4_nic *efx)
+{
+	ef4_oword_t temp;
+
+	/* Set positions of descriptor caches in SRAM. */
+	EF4_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR, efx->tx_dc_base);
+	ef4_writeo(efx, &temp, FR_AZ_SRM_TX_DC_CFG);
+	EF4_POPULATE_OWORD_1(temp, FRF_AZ_SRM_RX_DC_BASE_ADR, efx->rx_dc_base);
+	ef4_writeo(efx, &temp, FR_AZ_SRM_RX_DC_CFG);
+
+	/* Set TX descriptor cache size. */
+	BUILD_BUG_ON(TX_DC_ENTRIES != (8 << TX_DC_ENTRIES_ORDER));
+	EF4_POPULATE_OWORD_1(temp, FRF_AZ_TX_DC_SIZE, TX_DC_ENTRIES_ORDER);
+	ef4_writeo(efx, &temp, FR_AZ_TX_DC_CFG);
+
+	/* Set RX descriptor cache size.  Set low watermark to size-8, as
+	 * this allows most efficient prefetching.
+	 */
+	BUILD_BUG_ON(RX_DC_ENTRIES != (8 << RX_DC_ENTRIES_ORDER));
+	EF4_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_SIZE, RX_DC_ENTRIES_ORDER);
+	ef4_writeo(efx, &temp, FR_AZ_RX_DC_CFG);
+	EF4_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_PF_LWM, RX_DC_ENTRIES - 8);
+	ef4_writeo(efx, &temp, FR_AZ_RX_DC_PF_WM);
+
+	/* Program INT_KER address */
+	EF4_POPULATE_OWORD_2(temp,
+			     FRF_AZ_NORM_INT_VEC_DIS_KER,
+			     EF4_INT_MODE_USE_MSI(efx),
+			     FRF_AZ_INT_ADR_KER, efx->irq_status.dma_addr);
+	ef4_writeo(efx, &temp, FR_AZ_INT_ADR_KER);
+
+	/* Use a valid MSI-X vector */
+	efx->irq_level = 0;
+
+	/* Enable all the genuinely fatal interrupts.  (They are still
+	 * masked by the overall interrupt mask, controlled by
+	 * falcon_interrupts()).
+	 *
+	 * Note: All other fatal interrupts are enabled
+	 */
+	EF4_POPULATE_OWORD_3(temp,
+			     FRF_AZ_ILL_ADR_INT_KER_EN, 1,
+			     FRF_AZ_RBUF_OWN_INT_KER_EN, 1,
+			     FRF_AZ_TBUF_OWN_INT_KER_EN, 1);
+	EF4_INVERT_OWORD(temp);
+	ef4_writeo(efx, &temp, FR_AZ_FATAL_INTR_KER);
+
+	/* Disable the ugly timer-based TX DMA backoff and allow TX DMA to be
+	 * controlled by the RX FIFO fill level. Set arbitration to one pkt/Q.
+	 */
+	ef4_reado(efx, &temp, FR_AZ_TX_RESERVED);
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER, 0xfe);
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER_EN, 1);
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_ONE_PKT_PER_Q, 1);
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_PUSH_EN, 1);
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_DIS_NON_IP_EV, 1);
+	/* Enable SW_EV to inherit in char driver - assume harmless here */
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_SOFT_EVT_EN, 1);
+	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_THRESHOLD, 2);
+	/* Disable hardware watchdog which can misfire */
+	EF4_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_WD_TMR, 0x3fffff);
+	/* Squash TX of packets of 16 bytes or less */
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0)
+		EF4_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
+	ef4_writeo(efx, &temp, FR_AZ_TX_RESERVED);
+
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) {
+		EF4_POPULATE_OWORD_4(temp,
+				     /* Default values */
+				     FRF_BZ_TX_PACE_SB_NOT_AF, 0x15,
+				     FRF_BZ_TX_PACE_SB_AF, 0xb,
+				     FRF_BZ_TX_PACE_FB_BASE, 0,
+				     /* Allow large pace values in the
+				      * fast bin. */
+				     FRF_BZ_TX_PACE_BIN_TH,
+				     FFE_BZ_TX_PACE_RESERVED);
+		ef4_writeo(efx, &temp, FR_BZ_TX_PACE);
+	}
+}
+
+/**************************************************************************
+ *
+ * Filter tables
+ *
+ **************************************************************************
+ */
+
+/* "Fudge factors" - difference between programmed value and actual depth.
+ * Due to pipelined implementation we need to program H/W with a value that
+ * is larger than the hop limit we want.
+ */
+#define EF4_FARCH_FILTER_CTL_SRCH_FUDGE_WILD 3
+#define EF4_FARCH_FILTER_CTL_SRCH_FUDGE_FULL 1
+
+/* Hard maximum search limit.  Hardware will time-out beyond 200-something.
+ * We also need to avoid infinite loops in ef4_farch_filter_search() when the
+ * table is full.
+ */
+#define EF4_FARCH_FILTER_CTL_SRCH_MAX 200
+
+/* Don't try very hard to find space for performance hints, as this is
+ * counter-productive. */
+#define EF4_FARCH_FILTER_CTL_SRCH_HINT_MAX 5
+
+enum ef4_farch_filter_type {
+	EF4_FARCH_FILTER_TCP_FULL = 0,
+	EF4_FARCH_FILTER_TCP_WILD,
+	EF4_FARCH_FILTER_UDP_FULL,
+	EF4_FARCH_FILTER_UDP_WILD,
+	EF4_FARCH_FILTER_MAC_FULL = 4,
+	EF4_FARCH_FILTER_MAC_WILD,
+	EF4_FARCH_FILTER_UC_DEF = 8,
+	EF4_FARCH_FILTER_MC_DEF,
+	EF4_FARCH_FILTER_TYPE_COUNT,		/* number of specific types */
+};
+
+enum ef4_farch_filter_table_id {
+	EF4_FARCH_FILTER_TABLE_RX_IP = 0,
+	EF4_FARCH_FILTER_TABLE_RX_MAC,
+	EF4_FARCH_FILTER_TABLE_RX_DEF,
+	EF4_FARCH_FILTER_TABLE_TX_MAC,
+	EF4_FARCH_FILTER_TABLE_COUNT,
+};
+
+enum ef4_farch_filter_index {
+	EF4_FARCH_FILTER_INDEX_UC_DEF,
+	EF4_FARCH_FILTER_INDEX_MC_DEF,
+	EF4_FARCH_FILTER_SIZE_RX_DEF,
+};
+
+struct ef4_farch_filter_spec {
+	u8	type:4;
+	u8	priority:4;
+	u8	flags;
+	u16	dmaq_id;
+	u32	data[3];
+};
+
+struct ef4_farch_filter_table {
+	enum ef4_farch_filter_table_id id;
+	u32		offset;		/* address of table relative to BAR */
+	unsigned	size;		/* number of entries */
+	unsigned	step;		/* step between entries */
+	unsigned	used;		/* number currently used */
+	unsigned long	*used_bitmap;
+	struct ef4_farch_filter_spec *spec;
+	unsigned	search_limit[EF4_FARCH_FILTER_TYPE_COUNT];
+};
+
+struct ef4_farch_filter_state {
+	struct ef4_farch_filter_table table[EF4_FARCH_FILTER_TABLE_COUNT];
+};
+
+static void
+ef4_farch_filter_table_clear_entry(struct ef4_nic *efx,
+				   struct ef4_farch_filter_table *table,
+				   unsigned int filter_idx);
+
+/* The filter hash function is LFSR polynomial x^16 + x^3 + 1 of a 32-bit
+ * key derived from the n-tuple.  The initial LFSR state is 0xffff. */
+static u16 ef4_farch_filter_hash(u32 key)
+{
+	u16 tmp;
+
+	/* First 16 rounds */
+	tmp = 0x1fff ^ key >> 16;
+	tmp = tmp ^ tmp >> 3 ^ tmp >> 6;
+	tmp = tmp ^ tmp >> 9;
+	/* Last 16 rounds */
+	tmp = tmp ^ tmp << 13 ^ key;
+	tmp = tmp ^ tmp >> 3 ^ tmp >> 6;
+	return tmp ^ tmp >> 9;
+}
+
+/* To allow for hash collisions, filter search continues at these
+ * increments from the first possible entry selected by the hash. */
+static u16 ef4_farch_filter_increment(u32 key)
+{
+	return key * 2 - 1;
+}
+
+static enum ef4_farch_filter_table_id
+ef4_farch_filter_spec_table_id(const struct ef4_farch_filter_spec *spec)
+{
+	BUILD_BUG_ON(EF4_FARCH_FILTER_TABLE_RX_IP !=
+		     (EF4_FARCH_FILTER_TCP_FULL >> 2));
+	BUILD_BUG_ON(EF4_FARCH_FILTER_TABLE_RX_IP !=
+		     (EF4_FARCH_FILTER_TCP_WILD >> 2));
+	BUILD_BUG_ON(EF4_FARCH_FILTER_TABLE_RX_IP !=
+		     (EF4_FARCH_FILTER_UDP_FULL >> 2));
+	BUILD_BUG_ON(EF4_FARCH_FILTER_TABLE_RX_IP !=
+		     (EF4_FARCH_FILTER_UDP_WILD >> 2));
+	BUILD_BUG_ON(EF4_FARCH_FILTER_TABLE_RX_MAC !=
+		     (EF4_FARCH_FILTER_MAC_FULL >> 2));
+	BUILD_BUG_ON(EF4_FARCH_FILTER_TABLE_RX_MAC !=
+		     (EF4_FARCH_FILTER_MAC_WILD >> 2));
+	BUILD_BUG_ON(EF4_FARCH_FILTER_TABLE_TX_MAC !=
+		     EF4_FARCH_FILTER_TABLE_RX_MAC + 2);
+	return (spec->type >> 2) + ((spec->flags & EF4_FILTER_FLAG_TX) ? 2 : 0);
+}
+
+static void ef4_farch_filter_push_rx_config(struct ef4_nic *efx)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	struct ef4_farch_filter_table *table;
+	ef4_oword_t filter_ctl;
+
+	ef4_reado(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
+
+	table = &state->table[EF4_FARCH_FILTER_TABLE_RX_IP];
+	EF4_SET_OWORD_FIELD(filter_ctl, FRF_BZ_TCP_FULL_SRCH_LIMIT,
+			    table->search_limit[EF4_FARCH_FILTER_TCP_FULL] +
+			    EF4_FARCH_FILTER_CTL_SRCH_FUDGE_FULL);
+	EF4_SET_OWORD_FIELD(filter_ctl, FRF_BZ_TCP_WILD_SRCH_LIMIT,
+			    table->search_limit[EF4_FARCH_FILTER_TCP_WILD] +
+			    EF4_FARCH_FILTER_CTL_SRCH_FUDGE_WILD);
+	EF4_SET_OWORD_FIELD(filter_ctl, FRF_BZ_UDP_FULL_SRCH_LIMIT,
+			    table->search_limit[EF4_FARCH_FILTER_UDP_FULL] +
+			    EF4_FARCH_FILTER_CTL_SRCH_FUDGE_FULL);
+	EF4_SET_OWORD_FIELD(filter_ctl, FRF_BZ_UDP_WILD_SRCH_LIMIT,
+			    table->search_limit[EF4_FARCH_FILTER_UDP_WILD] +
+			    EF4_FARCH_FILTER_CTL_SRCH_FUDGE_WILD);
+
+	table = &state->table[EF4_FARCH_FILTER_TABLE_RX_MAC];
+	if (table->size) {
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_ETHERNET_FULL_SEARCH_LIMIT,
+			table->search_limit[EF4_FARCH_FILTER_MAC_FULL] +
+			EF4_FARCH_FILTER_CTL_SRCH_FUDGE_FULL);
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_ETHERNET_WILDCARD_SEARCH_LIMIT,
+			table->search_limit[EF4_FARCH_FILTER_MAC_WILD] +
+			EF4_FARCH_FILTER_CTL_SRCH_FUDGE_WILD);
+	}
+
+	table = &state->table[EF4_FARCH_FILTER_TABLE_RX_DEF];
+	if (table->size) {
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_UNICAST_NOMATCH_Q_ID,
+			table->spec[EF4_FARCH_FILTER_INDEX_UC_DEF].dmaq_id);
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_UNICAST_NOMATCH_RSS_ENABLED,
+			!!(table->spec[EF4_FARCH_FILTER_INDEX_UC_DEF].flags &
+			   EF4_FILTER_FLAG_RX_RSS));
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_MULTICAST_NOMATCH_Q_ID,
+			table->spec[EF4_FARCH_FILTER_INDEX_MC_DEF].dmaq_id);
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_MULTICAST_NOMATCH_RSS_ENABLED,
+			!!(table->spec[EF4_FARCH_FILTER_INDEX_MC_DEF].flags &
+			   EF4_FILTER_FLAG_RX_RSS));
+
+		/* There is a single bit to enable RX scatter for all
+		 * unmatched packets.  Only set it if scatter is
+		 * enabled in both filter specs.
+		 */
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_BZ_SCATTER_ENBL_NO_MATCH_Q,
+			!!(table->spec[EF4_FARCH_FILTER_INDEX_UC_DEF].flags &
+			   table->spec[EF4_FARCH_FILTER_INDEX_MC_DEF].flags &
+			   EF4_FILTER_FLAG_RX_SCATTER));
+	} else if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) {
+		/* We don't expose 'default' filters because unmatched
+		 * packets always go to the queue number found in the
+		 * RSS table.  But we still need to set the RX scatter
+		 * bit here.
+		 */
+		EF4_SET_OWORD_FIELD(
+			filter_ctl, FRF_BZ_SCATTER_ENBL_NO_MATCH_Q,
+			efx->rx_scatter);
+	}
+
+	ef4_writeo(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
+}
+
+static void ef4_farch_filter_push_tx_limits(struct ef4_nic *efx)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	struct ef4_farch_filter_table *table;
+	ef4_oword_t tx_cfg;
+
+	ef4_reado(efx, &tx_cfg, FR_AZ_TX_CFG);
+
+	table = &state->table[EF4_FARCH_FILTER_TABLE_TX_MAC];
+	if (table->size) {
+		EF4_SET_OWORD_FIELD(
+			tx_cfg, FRF_CZ_TX_ETH_FILTER_FULL_SEARCH_RANGE,
+			table->search_limit[EF4_FARCH_FILTER_MAC_FULL] +
+			EF4_FARCH_FILTER_CTL_SRCH_FUDGE_FULL);
+		EF4_SET_OWORD_FIELD(
+			tx_cfg, FRF_CZ_TX_ETH_FILTER_WILD_SEARCH_RANGE,
+			table->search_limit[EF4_FARCH_FILTER_MAC_WILD] +
+			EF4_FARCH_FILTER_CTL_SRCH_FUDGE_WILD);
+	}
+
+	ef4_writeo(efx, &tx_cfg, FR_AZ_TX_CFG);
+}
+
+static int
+ef4_farch_filter_from_gen_spec(struct ef4_farch_filter_spec *spec,
+			       const struct ef4_filter_spec *gen_spec)
+{
+	bool is_full = false;
+
+	if ((gen_spec->flags & EF4_FILTER_FLAG_RX_RSS) &&
+	    gen_spec->rss_context != EF4_FILTER_RSS_CONTEXT_DEFAULT)
+		return -EINVAL;
+
+	spec->priority = gen_spec->priority;
+	spec->flags = gen_spec->flags;
+	spec->dmaq_id = gen_spec->dmaq_id;
+
+	switch (gen_spec->match_flags) {
+	case (EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_IP_PROTO |
+	      EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_LOC_PORT |
+	      EF4_FILTER_MATCH_REM_HOST | EF4_FILTER_MATCH_REM_PORT):
+		is_full = true;
+		/* fall through */
+	case (EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_IP_PROTO |
+	      EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_LOC_PORT): {
+		__be32 rhost, host1, host2;
+		__be16 rport, port1, port2;
+
+		EF4_BUG_ON_PARANOID(!(gen_spec->flags & EF4_FILTER_FLAG_RX));
+
+		if (gen_spec->ether_type != htons(ETH_P_IP))
+			return -EPROTONOSUPPORT;
+		if (gen_spec->loc_port == 0 ||
+		    (is_full && gen_spec->rem_port == 0))
+			return -EADDRNOTAVAIL;
+		switch (gen_spec->ip_proto) {
+		case IPPROTO_TCP:
+			spec->type = (is_full ? EF4_FARCH_FILTER_TCP_FULL :
+				      EF4_FARCH_FILTER_TCP_WILD);
+			break;
+		case IPPROTO_UDP:
+			spec->type = (is_full ? EF4_FARCH_FILTER_UDP_FULL :
+				      EF4_FARCH_FILTER_UDP_WILD);
+			break;
+		default:
+			return -EPROTONOSUPPORT;
+		}
+
+		/* Filter is constructed in terms of source and destination,
+		 * with the odd wrinkle that the ports are swapped in a UDP
+		 * wildcard filter.  We need to convert from local and remote
+		 * (= zero for wildcard) addresses.
+		 */
+		rhost = is_full ? gen_spec->rem_host[0] : 0;
+		rport = is_full ? gen_spec->rem_port : 0;
+		host1 = rhost;
+		host2 = gen_spec->loc_host[0];
+		if (!is_full && gen_spec->ip_proto == IPPROTO_UDP) {
+			port1 = gen_spec->loc_port;
+			port2 = rport;
+		} else {
+			port1 = rport;
+			port2 = gen_spec->loc_port;
+		}
+		spec->data[0] = ntohl(host1) << 16 | ntohs(port1);
+		spec->data[1] = ntohs(port2) << 16 | ntohl(host1) >> 16;
+		spec->data[2] = ntohl(host2);
+
+		break;
+	}
+
+	case EF4_FILTER_MATCH_LOC_MAC | EF4_FILTER_MATCH_OUTER_VID:
+		is_full = true;
+		/* fall through */
+	case EF4_FILTER_MATCH_LOC_MAC:
+		spec->type = (is_full ? EF4_FARCH_FILTER_MAC_FULL :
+			      EF4_FARCH_FILTER_MAC_WILD);
+		spec->data[0] = is_full ? ntohs(gen_spec->outer_vid) : 0;
+		spec->data[1] = (gen_spec->loc_mac[2] << 24 |
+				 gen_spec->loc_mac[3] << 16 |
+				 gen_spec->loc_mac[4] << 8 |
+				 gen_spec->loc_mac[5]);
+		spec->data[2] = (gen_spec->loc_mac[0] << 8 |
+				 gen_spec->loc_mac[1]);
+		break;
+
+	case EF4_FILTER_MATCH_LOC_MAC_IG:
+		spec->type = (is_multicast_ether_addr(gen_spec->loc_mac) ?
+			      EF4_FARCH_FILTER_MC_DEF :
+			      EF4_FARCH_FILTER_UC_DEF);
+		memset(spec->data, 0, sizeof(spec->data)); /* ensure equality */
+		break;
+
+	default:
+		return -EPROTONOSUPPORT;
+	}
+
+	return 0;
+}
+
+static void
+ef4_farch_filter_to_gen_spec(struct ef4_filter_spec *gen_spec,
+			     const struct ef4_farch_filter_spec *spec)
+{
+	bool is_full = false;
+
+	/* *gen_spec should be completely initialised, to be consistent
+	 * with ef4_filter_init_{rx,tx}() and in case we want to copy
+	 * it back to userland.
+	 */
+	memset(gen_spec, 0, sizeof(*gen_spec));
+
+	gen_spec->priority = spec->priority;
+	gen_spec->flags = spec->flags;
+	gen_spec->dmaq_id = spec->dmaq_id;
+
+	switch (spec->type) {
+	case EF4_FARCH_FILTER_TCP_FULL:
+	case EF4_FARCH_FILTER_UDP_FULL:
+		is_full = true;
+		/* fall through */
+	case EF4_FARCH_FILTER_TCP_WILD:
+	case EF4_FARCH_FILTER_UDP_WILD: {
+		__be32 host1, host2;
+		__be16 port1, port2;
+
+		gen_spec->match_flags =
+			EF4_FILTER_MATCH_ETHER_TYPE |
+			EF4_FILTER_MATCH_IP_PROTO |
+			EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_LOC_PORT;
+		if (is_full)
+			gen_spec->match_flags |= (EF4_FILTER_MATCH_REM_HOST |
+						  EF4_FILTER_MATCH_REM_PORT);
+		gen_spec->ether_type = htons(ETH_P_IP);
+		gen_spec->ip_proto =
+			(spec->type == EF4_FARCH_FILTER_TCP_FULL ||
+			 spec->type == EF4_FARCH_FILTER_TCP_WILD) ?
+			IPPROTO_TCP : IPPROTO_UDP;
+
+		host1 = htonl(spec->data[0] >> 16 | spec->data[1] << 16);
+		port1 = htons(spec->data[0]);
+		host2 = htonl(spec->data[2]);
+		port2 = htons(spec->data[1] >> 16);
+		if (spec->flags & EF4_FILTER_FLAG_TX) {
+			gen_spec->loc_host[0] = host1;
+			gen_spec->rem_host[0] = host2;
+		} else {
+			gen_spec->loc_host[0] = host2;
+			gen_spec->rem_host[0] = host1;
+		}
+		if (!!(gen_spec->flags & EF4_FILTER_FLAG_TX) ^
+		    (!is_full && gen_spec->ip_proto == IPPROTO_UDP)) {
+			gen_spec->loc_port = port1;
+			gen_spec->rem_port = port2;
+		} else {
+			gen_spec->loc_port = port2;
+			gen_spec->rem_port = port1;
+		}
+
+		break;
+	}
+
+	case EF4_FARCH_FILTER_MAC_FULL:
+		is_full = true;
+		/* fall through */
+	case EF4_FARCH_FILTER_MAC_WILD:
+		gen_spec->match_flags = EF4_FILTER_MATCH_LOC_MAC;
+		if (is_full)
+			gen_spec->match_flags |= EF4_FILTER_MATCH_OUTER_VID;
+		gen_spec->loc_mac[0] = spec->data[2] >> 8;
+		gen_spec->loc_mac[1] = spec->data[2];
+		gen_spec->loc_mac[2] = spec->data[1] >> 24;
+		gen_spec->loc_mac[3] = spec->data[1] >> 16;
+		gen_spec->loc_mac[4] = spec->data[1] >> 8;
+		gen_spec->loc_mac[5] = spec->data[1];
+		gen_spec->outer_vid = htons(spec->data[0]);
+		break;
+
+	case EF4_FARCH_FILTER_UC_DEF:
+	case EF4_FARCH_FILTER_MC_DEF:
+		gen_spec->match_flags = EF4_FILTER_MATCH_LOC_MAC_IG;
+		gen_spec->loc_mac[0] = spec->type == EF4_FARCH_FILTER_MC_DEF;
+		break;
+
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+
+static void
+ef4_farch_filter_init_rx_auto(struct ef4_nic *efx,
+			      struct ef4_farch_filter_spec *spec)
+{
+	/* If there's only one channel then disable RSS for non VF
+	 * traffic, thereby allowing VFs to use RSS when the PF can't.
+	 */
+	spec->priority = EF4_FILTER_PRI_AUTO;
+	spec->flags = (EF4_FILTER_FLAG_RX |
+		       (ef4_rss_enabled(efx) ? EF4_FILTER_FLAG_RX_RSS : 0) |
+		       (efx->rx_scatter ? EF4_FILTER_FLAG_RX_SCATTER : 0));
+	spec->dmaq_id = 0;
+}
+
+/* Build a filter entry and return its n-tuple key. */
+static u32 ef4_farch_filter_build(ef4_oword_t *filter,
+				  struct ef4_farch_filter_spec *spec)
+{
+	u32 data3;
+
+	switch (ef4_farch_filter_spec_table_id(spec)) {
+	case EF4_FARCH_FILTER_TABLE_RX_IP: {
+		bool is_udp = (spec->type == EF4_FARCH_FILTER_UDP_FULL ||
+			       spec->type == EF4_FARCH_FILTER_UDP_WILD);
+		EF4_POPULATE_OWORD_7(
+			*filter,
+			FRF_BZ_RSS_EN,
+			!!(spec->flags & EF4_FILTER_FLAG_RX_RSS),
+			FRF_BZ_SCATTER_EN,
+			!!(spec->flags & EF4_FILTER_FLAG_RX_SCATTER),
+			FRF_BZ_TCP_UDP, is_udp,
+			FRF_BZ_RXQ_ID, spec->dmaq_id,
+			EF4_DWORD_2, spec->data[2],
+			EF4_DWORD_1, spec->data[1],
+			EF4_DWORD_0, spec->data[0]);
+		data3 = is_udp;
+		break;
+	}
+
+	case EF4_FARCH_FILTER_TABLE_RX_MAC: {
+		bool is_wild = spec->type == EF4_FARCH_FILTER_MAC_WILD;
+		EF4_POPULATE_OWORD_7(
+			*filter,
+			FRF_CZ_RMFT_RSS_EN,
+			!!(spec->flags & EF4_FILTER_FLAG_RX_RSS),
+			FRF_CZ_RMFT_SCATTER_EN,
+			!!(spec->flags & EF4_FILTER_FLAG_RX_SCATTER),
+			FRF_CZ_RMFT_RXQ_ID, spec->dmaq_id,
+			FRF_CZ_RMFT_WILDCARD_MATCH, is_wild,
+			FRF_CZ_RMFT_DEST_MAC_HI, spec->data[2],
+			FRF_CZ_RMFT_DEST_MAC_LO, spec->data[1],
+			FRF_CZ_RMFT_VLAN_ID, spec->data[0]);
+		data3 = is_wild;
+		break;
+	}
+
+	case EF4_FARCH_FILTER_TABLE_TX_MAC: {
+		bool is_wild = spec->type == EF4_FARCH_FILTER_MAC_WILD;
+		EF4_POPULATE_OWORD_5(*filter,
+				     FRF_CZ_TMFT_TXQ_ID, spec->dmaq_id,
+				     FRF_CZ_TMFT_WILDCARD_MATCH, is_wild,
+				     FRF_CZ_TMFT_SRC_MAC_HI, spec->data[2],
+				     FRF_CZ_TMFT_SRC_MAC_LO, spec->data[1],
+				     FRF_CZ_TMFT_VLAN_ID, spec->data[0]);
+		data3 = is_wild | spec->dmaq_id << 1;
+		break;
+	}
+
+	default:
+		BUG();
+	}
+
+	return spec->data[0] ^ spec->data[1] ^ spec->data[2] ^ data3;
+}
+
+static bool ef4_farch_filter_equal(const struct ef4_farch_filter_spec *left,
+				   const struct ef4_farch_filter_spec *right)
+{
+	if (left->type != right->type ||
+	    memcmp(left->data, right->data, sizeof(left->data)))
+		return false;
+
+	if (left->flags & EF4_FILTER_FLAG_TX &&
+	    left->dmaq_id != right->dmaq_id)
+		return false;
+
+	return true;
+}
+
+/*
+ * Construct/deconstruct external filter IDs.  At least the RX filter
+ * IDs must be ordered by matching priority, for RX NFC semantics.
+ *
+ * Deconstruction needs to be robust against invalid IDs so that
+ * ef4_filter_remove_id_safe() and ef4_filter_get_filter_safe() can
+ * accept user-provided IDs.
+ */
+
+#define EF4_FARCH_FILTER_MATCH_PRI_COUNT	5
+
+static const u8 ef4_farch_filter_type_match_pri[EF4_FARCH_FILTER_TYPE_COUNT] = {
+	[EF4_FARCH_FILTER_TCP_FULL]	= 0,
+	[EF4_FARCH_FILTER_UDP_FULL]	= 0,
+	[EF4_FARCH_FILTER_TCP_WILD]	= 1,
+	[EF4_FARCH_FILTER_UDP_WILD]	= 1,
+	[EF4_FARCH_FILTER_MAC_FULL]	= 2,
+	[EF4_FARCH_FILTER_MAC_WILD]	= 3,
+	[EF4_FARCH_FILTER_UC_DEF]	= 4,
+	[EF4_FARCH_FILTER_MC_DEF]	= 4,
+};
+
+static const enum ef4_farch_filter_table_id ef4_farch_filter_range_table[] = {
+	EF4_FARCH_FILTER_TABLE_RX_IP,	/* RX match pri 0 */
+	EF4_FARCH_FILTER_TABLE_RX_IP,
+	EF4_FARCH_FILTER_TABLE_RX_MAC,
+	EF4_FARCH_FILTER_TABLE_RX_MAC,
+	EF4_FARCH_FILTER_TABLE_RX_DEF,	/* RX match pri 4 */
+	EF4_FARCH_FILTER_TABLE_TX_MAC,	/* TX match pri 0 */
+	EF4_FARCH_FILTER_TABLE_TX_MAC,	/* TX match pri 1 */
+};
+
+#define EF4_FARCH_FILTER_INDEX_WIDTH 13
+#define EF4_FARCH_FILTER_INDEX_MASK ((1 << EF4_FARCH_FILTER_INDEX_WIDTH) - 1)
+
+static inline u32
+ef4_farch_filter_make_id(const struct ef4_farch_filter_spec *spec,
+			 unsigned int index)
+{
+	unsigned int range;
+
+	range = ef4_farch_filter_type_match_pri[spec->type];
+	if (!(spec->flags & EF4_FILTER_FLAG_RX))
+		range += EF4_FARCH_FILTER_MATCH_PRI_COUNT;
+
+	return range << EF4_FARCH_FILTER_INDEX_WIDTH | index;
+}
+
+static inline enum ef4_farch_filter_table_id
+ef4_farch_filter_id_table_id(u32 id)
+{
+	unsigned int range = id >> EF4_FARCH_FILTER_INDEX_WIDTH;
+
+	if (range < ARRAY_SIZE(ef4_farch_filter_range_table))
+		return ef4_farch_filter_range_table[range];
+	else
+		return EF4_FARCH_FILTER_TABLE_COUNT; /* invalid */
+}
+
+static inline unsigned int ef4_farch_filter_id_index(u32 id)
+{
+	return id & EF4_FARCH_FILTER_INDEX_MASK;
+}
+
+u32 ef4_farch_filter_get_rx_id_limit(struct ef4_nic *efx)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	unsigned int range = EF4_FARCH_FILTER_MATCH_PRI_COUNT - 1;
+	enum ef4_farch_filter_table_id table_id;
+
+	do {
+		table_id = ef4_farch_filter_range_table[range];
+		if (state->table[table_id].size != 0)
+			return range << EF4_FARCH_FILTER_INDEX_WIDTH |
+				state->table[table_id].size;
+	} while (range--);
+
+	return 0;
+}
+
+s32 ef4_farch_filter_insert(struct ef4_nic *efx,
+			    struct ef4_filter_spec *gen_spec,
+			    bool replace_equal)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	struct ef4_farch_filter_table *table;
+	struct ef4_farch_filter_spec spec;
+	ef4_oword_t filter;
+	int rep_index, ins_index;
+	unsigned int depth = 0;
+	int rc;
+
+	rc = ef4_farch_filter_from_gen_spec(&spec, gen_spec);
+	if (rc)
+		return rc;
+
+	table = &state->table[ef4_farch_filter_spec_table_id(&spec)];
+	if (table->size == 0)
+		return -EINVAL;
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "%s: type %d search_limit=%d", __func__, spec.type,
+		   table->search_limit[spec.type]);
+
+	if (table->id == EF4_FARCH_FILTER_TABLE_RX_DEF) {
+		/* One filter spec per type */
+		BUILD_BUG_ON(EF4_FARCH_FILTER_INDEX_UC_DEF != 0);
+		BUILD_BUG_ON(EF4_FARCH_FILTER_INDEX_MC_DEF !=
+			     EF4_FARCH_FILTER_MC_DEF - EF4_FARCH_FILTER_UC_DEF);
+		rep_index = spec.type - EF4_FARCH_FILTER_UC_DEF;
+		ins_index = rep_index;
+
+		spin_lock_bh(&efx->filter_lock);
+	} else {
+		/* Search concurrently for
+		 * (1) a filter to be replaced (rep_index): any filter
+		 *     with the same match values, up to the current
+		 *     search depth for this type, and
+		 * (2) the insertion point (ins_index): (1) or any
+		 *     free slot before it or up to the maximum search
+		 *     depth for this priority
+		 * We fail if we cannot find (2).
+		 *
+		 * We can stop once either
+		 * (a) we find (1), in which case we have definitely
+		 *     found (2) as well; or
+		 * (b) we have searched exhaustively for (1), and have
+		 *     either found (2) or searched exhaustively for it
+		 */
+		u32 key = ef4_farch_filter_build(&filter, &spec);
+		unsigned int hash = ef4_farch_filter_hash(key);
+		unsigned int incr = ef4_farch_filter_increment(key);
+		unsigned int max_rep_depth = table->search_limit[spec.type];
+		unsigned int max_ins_depth =
+			spec.priority <= EF4_FILTER_PRI_HINT ?
+			EF4_FARCH_FILTER_CTL_SRCH_HINT_MAX :
+			EF4_FARCH_FILTER_CTL_SRCH_MAX;
+		unsigned int i = hash & (table->size - 1);
+
+		ins_index = -1;
+		depth = 1;
+
+		spin_lock_bh(&efx->filter_lock);
+
+		for (;;) {
+			if (!test_bit(i, table->used_bitmap)) {
+				if (ins_index < 0)
+					ins_index = i;
+			} else if (ef4_farch_filter_equal(&spec,
+							  &table->spec[i])) {
+				/* Case (a) */
+				if (ins_index < 0)
+					ins_index = i;
+				rep_index = i;
+				break;
+			}
+
+			if (depth >= max_rep_depth &&
+			    (ins_index >= 0 || depth >= max_ins_depth)) {
+				/* Case (b) */
+				if (ins_index < 0) {
+					rc = -EBUSY;
+					goto out;
+				}
+				rep_index = -1;
+				break;
+			}
+
+			i = (i + incr) & (table->size - 1);
+			++depth;
+		}
+	}
+
+	/* If we found a filter to be replaced, check whether we
+	 * should do so
+	 */
+	if (rep_index >= 0) {
+		struct ef4_farch_filter_spec *saved_spec =
+			&table->spec[rep_index];
+
+		if (spec.priority == saved_spec->priority && !replace_equal) {
+			rc = -EEXIST;
+			goto out;
+		}
+		if (spec.priority < saved_spec->priority) {
+			rc = -EPERM;
+			goto out;
+		}
+		if (saved_spec->priority == EF4_FILTER_PRI_AUTO ||
+		    saved_spec->flags & EF4_FILTER_FLAG_RX_OVER_AUTO)
+			spec.flags |= EF4_FILTER_FLAG_RX_OVER_AUTO;
+	}
+
+	/* Insert the filter */
+	if (ins_index != rep_index) {
+		__set_bit(ins_index, table->used_bitmap);
+		++table->used;
+	}
+	table->spec[ins_index] = spec;
+
+	if (table->id == EF4_FARCH_FILTER_TABLE_RX_DEF) {
+		ef4_farch_filter_push_rx_config(efx);
+	} else {
+		if (table->search_limit[spec.type] < depth) {
+			table->search_limit[spec.type] = depth;
+			if (spec.flags & EF4_FILTER_FLAG_TX)
+				ef4_farch_filter_push_tx_limits(efx);
+			else
+				ef4_farch_filter_push_rx_config(efx);
+		}
+
+		ef4_writeo(efx, &filter,
+			   table->offset + table->step * ins_index);
+
+		/* If we were able to replace a filter by inserting
+		 * at a lower depth, clear the replaced filter
+		 */
+		if (ins_index != rep_index && rep_index >= 0)
+			ef4_farch_filter_table_clear_entry(efx, table,
+							   rep_index);
+	}
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "%s: filter type %d index %d rxq %u set",
+		   __func__, spec.type, ins_index, spec.dmaq_id);
+	rc = ef4_farch_filter_make_id(&spec, ins_index);
+
+out:
+	spin_unlock_bh(&efx->filter_lock);
+	return rc;
+}
+
+static void
+ef4_farch_filter_table_clear_entry(struct ef4_nic *efx,
+				   struct ef4_farch_filter_table *table,
+				   unsigned int filter_idx)
+{
+	static ef4_oword_t filter;
+
+	EF4_WARN_ON_PARANOID(!test_bit(filter_idx, table->used_bitmap));
+	BUG_ON(table->offset == 0); /* can't clear MAC default filters */
+
+	__clear_bit(filter_idx, table->used_bitmap);
+	--table->used;
+	memset(&table->spec[filter_idx], 0, sizeof(table->spec[0]));
+
+	ef4_writeo(efx, &filter, table->offset + table->step * filter_idx);
+
+	/* If this filter required a greater search depth than
+	 * any other, the search limit for its type can now be
+	 * decreased.  However, it is hard to determine that
+	 * unless the table has become completely empty - in
+	 * which case, all its search limits can be set to 0.
+	 */
+	if (unlikely(table->used == 0)) {
+		memset(table->search_limit, 0, sizeof(table->search_limit));
+		if (table->id == EF4_FARCH_FILTER_TABLE_TX_MAC)
+			ef4_farch_filter_push_tx_limits(efx);
+		else
+			ef4_farch_filter_push_rx_config(efx);
+	}
+}
+
+static int ef4_farch_filter_remove(struct ef4_nic *efx,
+				   struct ef4_farch_filter_table *table,
+				   unsigned int filter_idx,
+				   enum ef4_filter_priority priority)
+{
+	struct ef4_farch_filter_spec *spec = &table->spec[filter_idx];
+
+	if (!test_bit(filter_idx, table->used_bitmap) ||
+	    spec->priority != priority)
+		return -ENOENT;
+
+	if (spec->flags & EF4_FILTER_FLAG_RX_OVER_AUTO) {
+		ef4_farch_filter_init_rx_auto(efx, spec);
+		ef4_farch_filter_push_rx_config(efx);
+	} else {
+		ef4_farch_filter_table_clear_entry(efx, table, filter_idx);
+	}
+
+	return 0;
+}
+
+int ef4_farch_filter_remove_safe(struct ef4_nic *efx,
+				 enum ef4_filter_priority priority,
+				 u32 filter_id)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	enum ef4_farch_filter_table_id table_id;
+	struct ef4_farch_filter_table *table;
+	unsigned int filter_idx;
+	struct ef4_farch_filter_spec *spec;
+	int rc;
+
+	table_id = ef4_farch_filter_id_table_id(filter_id);
+	if ((unsigned int)table_id >= EF4_FARCH_FILTER_TABLE_COUNT)
+		return -ENOENT;
+	table = &state->table[table_id];
+
+	filter_idx = ef4_farch_filter_id_index(filter_id);
+	if (filter_idx >= table->size)
+		return -ENOENT;
+	spec = &table->spec[filter_idx];
+
+	spin_lock_bh(&efx->filter_lock);
+	rc = ef4_farch_filter_remove(efx, table, filter_idx, priority);
+	spin_unlock_bh(&efx->filter_lock);
+
+	return rc;
+}
+
+int ef4_farch_filter_get_safe(struct ef4_nic *efx,
+			      enum ef4_filter_priority priority,
+			      u32 filter_id, struct ef4_filter_spec *spec_buf)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	enum ef4_farch_filter_table_id table_id;
+	struct ef4_farch_filter_table *table;
+	struct ef4_farch_filter_spec *spec;
+	unsigned int filter_idx;
+	int rc;
+
+	table_id = ef4_farch_filter_id_table_id(filter_id);
+	if ((unsigned int)table_id >= EF4_FARCH_FILTER_TABLE_COUNT)
+		return -ENOENT;
+	table = &state->table[table_id];
+
+	filter_idx = ef4_farch_filter_id_index(filter_id);
+	if (filter_idx >= table->size)
+		return -ENOENT;
+	spec = &table->spec[filter_idx];
+
+	spin_lock_bh(&efx->filter_lock);
+
+	if (test_bit(filter_idx, table->used_bitmap) &&
+	    spec->priority == priority) {
+		ef4_farch_filter_to_gen_spec(spec_buf, spec);
+		rc = 0;
+	} else {
+		rc = -ENOENT;
+	}
+
+	spin_unlock_bh(&efx->filter_lock);
+
+	return rc;
+}
+
+static void
+ef4_farch_filter_table_clear(struct ef4_nic *efx,
+			     enum ef4_farch_filter_table_id table_id,
+			     enum ef4_filter_priority priority)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	struct ef4_farch_filter_table *table = &state->table[table_id];
+	unsigned int filter_idx;
+
+	spin_lock_bh(&efx->filter_lock);
+	for (filter_idx = 0; filter_idx < table->size; ++filter_idx) {
+		if (table->spec[filter_idx].priority != EF4_FILTER_PRI_AUTO)
+			ef4_farch_filter_remove(efx, table,
+						filter_idx, priority);
+	}
+	spin_unlock_bh(&efx->filter_lock);
+}
+
+int ef4_farch_filter_clear_rx(struct ef4_nic *efx,
+			       enum ef4_filter_priority priority)
+{
+	ef4_farch_filter_table_clear(efx, EF4_FARCH_FILTER_TABLE_RX_IP,
+				     priority);
+	ef4_farch_filter_table_clear(efx, EF4_FARCH_FILTER_TABLE_RX_MAC,
+				     priority);
+	ef4_farch_filter_table_clear(efx, EF4_FARCH_FILTER_TABLE_RX_DEF,
+				     priority);
+	return 0;
+}
+
+u32 ef4_farch_filter_count_rx_used(struct ef4_nic *efx,
+				   enum ef4_filter_priority priority)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	enum ef4_farch_filter_table_id table_id;
+	struct ef4_farch_filter_table *table;
+	unsigned int filter_idx;
+	u32 count = 0;
+
+	spin_lock_bh(&efx->filter_lock);
+
+	for (table_id = EF4_FARCH_FILTER_TABLE_RX_IP;
+	     table_id <= EF4_FARCH_FILTER_TABLE_RX_DEF;
+	     table_id++) {
+		table = &state->table[table_id];
+		for (filter_idx = 0; filter_idx < table->size; filter_idx++) {
+			if (test_bit(filter_idx, table->used_bitmap) &&
+			    table->spec[filter_idx].priority == priority)
+				++count;
+		}
+	}
+
+	spin_unlock_bh(&efx->filter_lock);
+
+	return count;
+}
+
+s32 ef4_farch_filter_get_rx_ids(struct ef4_nic *efx,
+				enum ef4_filter_priority priority,
+				u32 *buf, u32 size)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	enum ef4_farch_filter_table_id table_id;
+	struct ef4_farch_filter_table *table;
+	unsigned int filter_idx;
+	s32 count = 0;
+
+	spin_lock_bh(&efx->filter_lock);
+
+	for (table_id = EF4_FARCH_FILTER_TABLE_RX_IP;
+	     table_id <= EF4_FARCH_FILTER_TABLE_RX_DEF;
+	     table_id++) {
+		table = &state->table[table_id];
+		for (filter_idx = 0; filter_idx < table->size; filter_idx++) {
+			if (test_bit(filter_idx, table->used_bitmap) &&
+			    table->spec[filter_idx].priority == priority) {
+				if (count == size) {
+					count = -EMSGSIZE;
+					goto out;
+				}
+				buf[count++] = ef4_farch_filter_make_id(
+					&table->spec[filter_idx], filter_idx);
+			}
+		}
+	}
+out:
+	spin_unlock_bh(&efx->filter_lock);
+
+	return count;
+}
+
+/* Restore filter stater after reset */
+void ef4_farch_filter_table_restore(struct ef4_nic *efx)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	enum ef4_farch_filter_table_id table_id;
+	struct ef4_farch_filter_table *table;
+	ef4_oword_t filter;
+	unsigned int filter_idx;
+
+	spin_lock_bh(&efx->filter_lock);
+
+	for (table_id = 0; table_id < EF4_FARCH_FILTER_TABLE_COUNT; table_id++) {
+		table = &state->table[table_id];
+
+		/* Check whether this is a regular register table */
+		if (table->step == 0)
+			continue;
+
+		for (filter_idx = 0; filter_idx < table->size; filter_idx++) {
+			if (!test_bit(filter_idx, table->used_bitmap))
+				continue;
+			ef4_farch_filter_build(&filter, &table->spec[filter_idx]);
+			ef4_writeo(efx, &filter,
+				   table->offset + table->step * filter_idx);
+		}
+	}
+
+	ef4_farch_filter_push_rx_config(efx);
+	ef4_farch_filter_push_tx_limits(efx);
+
+	spin_unlock_bh(&efx->filter_lock);
+}
+
+void ef4_farch_filter_table_remove(struct ef4_nic *efx)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	enum ef4_farch_filter_table_id table_id;
+
+	for (table_id = 0; table_id < EF4_FARCH_FILTER_TABLE_COUNT; table_id++) {
+		kfree(state->table[table_id].used_bitmap);
+		vfree(state->table[table_id].spec);
+	}
+	kfree(state);
+}
+
+int ef4_farch_filter_table_probe(struct ef4_nic *efx)
+{
+	struct ef4_farch_filter_state *state;
+	struct ef4_farch_filter_table *table;
+	unsigned table_id;
+
+	state = kzalloc(sizeof(struct ef4_farch_filter_state), GFP_KERNEL);
+	if (!state)
+		return -ENOMEM;
+	efx->filter_state = state;
+
+	if (ef4_nic_rev(efx) >= EF4_REV_FALCON_B0) {
+		table = &state->table[EF4_FARCH_FILTER_TABLE_RX_IP];
+		table->id = EF4_FARCH_FILTER_TABLE_RX_IP;
+		table->offset = FR_BZ_RX_FILTER_TBL0;
+		table->size = FR_BZ_RX_FILTER_TBL0_ROWS;
+		table->step = FR_BZ_RX_FILTER_TBL0_STEP;
+	}
+
+	for (table_id = 0; table_id < EF4_FARCH_FILTER_TABLE_COUNT; table_id++) {
+		table = &state->table[table_id];
+		if (table->size == 0)
+			continue;
+		table->used_bitmap = kcalloc(BITS_TO_LONGS(table->size),
+					     sizeof(unsigned long),
+					     GFP_KERNEL);
+		if (!table->used_bitmap)
+			goto fail;
+		table->spec = vzalloc(table->size * sizeof(*table->spec));
+		if (!table->spec)
+			goto fail;
+	}
+
+	table = &state->table[EF4_FARCH_FILTER_TABLE_RX_DEF];
+	if (table->size) {
+		/* RX default filters must always exist */
+		struct ef4_farch_filter_spec *spec;
+		unsigned i;
+
+		for (i = 0; i < EF4_FARCH_FILTER_SIZE_RX_DEF; i++) {
+			spec = &table->spec[i];
+			spec->type = EF4_FARCH_FILTER_UC_DEF + i;
+			ef4_farch_filter_init_rx_auto(efx, spec);
+			__set_bit(i, table->used_bitmap);
+		}
+	}
+
+	ef4_farch_filter_push_rx_config(efx);
+
+	return 0;
+
+fail:
+	ef4_farch_filter_table_remove(efx);
+	return -ENOMEM;
+}
+
+/* Update scatter enable flags for filters pointing to our own RX queues */
+void ef4_farch_filter_update_rx_scatter(struct ef4_nic *efx)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	enum ef4_farch_filter_table_id table_id;
+	struct ef4_farch_filter_table *table;
+	ef4_oword_t filter;
+	unsigned int filter_idx;
+
+	spin_lock_bh(&efx->filter_lock);
+
+	for (table_id = EF4_FARCH_FILTER_TABLE_RX_IP;
+	     table_id <= EF4_FARCH_FILTER_TABLE_RX_DEF;
+	     table_id++) {
+		table = &state->table[table_id];
+
+		for (filter_idx = 0; filter_idx < table->size; filter_idx++) {
+			if (!test_bit(filter_idx, table->used_bitmap) ||
+			    table->spec[filter_idx].dmaq_id >=
+			    efx->n_rx_channels)
+				continue;
+
+			if (efx->rx_scatter)
+				table->spec[filter_idx].flags |=
+					EF4_FILTER_FLAG_RX_SCATTER;
+			else
+				table->spec[filter_idx].flags &=
+					~EF4_FILTER_FLAG_RX_SCATTER;
+
+			if (table_id == EF4_FARCH_FILTER_TABLE_RX_DEF)
+				/* Pushed by ef4_farch_filter_push_rx_config() */
+				continue;
+
+			ef4_farch_filter_build(&filter, &table->spec[filter_idx]);
+			ef4_writeo(efx, &filter,
+				   table->offset + table->step * filter_idx);
+		}
+	}
+
+	ef4_farch_filter_push_rx_config(efx);
+
+	spin_unlock_bh(&efx->filter_lock);
+}
+
+#ifdef CONFIG_RFS_ACCEL
+
+s32 ef4_farch_filter_rfs_insert(struct ef4_nic *efx,
+				struct ef4_filter_spec *gen_spec)
+{
+	return ef4_farch_filter_insert(efx, gen_spec, true);
+}
+
+bool ef4_farch_filter_rfs_expire_one(struct ef4_nic *efx, u32 flow_id,
+				     unsigned int index)
+{
+	struct ef4_farch_filter_state *state = efx->filter_state;
+	struct ef4_farch_filter_table *table =
+		&state->table[EF4_FARCH_FILTER_TABLE_RX_IP];
+
+	if (test_bit(index, table->used_bitmap) &&
+	    table->spec[index].priority == EF4_FILTER_PRI_HINT &&
+	    rps_may_expire_flow(efx->net_dev, table->spec[index].dmaq_id,
+				flow_id, index)) {
+		ef4_farch_filter_table_clear_entry(efx, table, index);
+		return true;
+	}
+
+	return false;
+}
+
+#endif /* CONFIG_RFS_ACCEL */
+
+void ef4_farch_filter_sync_rx_mode(struct ef4_nic *efx)
+{
+	struct net_device *net_dev = efx->net_dev;
+	struct netdev_hw_addr *ha;
+	union ef4_multicast_hash *mc_hash = &efx->multicast_hash;
+	u32 crc;
+	int bit;
+
+	if (!ef4_dev_registered(efx))
+		return;
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
+			bit = crc & (EF4_MCAST_HASH_ENTRIES - 1);
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
diff --git a/drivers/net/ethernet/sfc/falcon/farch_regs.h b/drivers/net/ethernet/sfc/falcon/farch_regs.h
new file mode 100644
index 0000000..8095f27
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/farch_regs.h
@@ -0,0 +1,2932 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2012 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_FARCH_REGS_H
+#define EF4_FARCH_REGS_H
+
+/*
+ * Falcon hardware architecture definitions have a name prefix following
+ * the format:
+ *
+ *     F<type>_<min-rev><max-rev>_
+ *
+ * The following <type> strings are used:
+ *
+ *             MMIO register  MC register  Host memory structure
+ * -------------------------------------------------------------
+ * Address     R              MCR
+ * Bitfield    RF             MCRF         SF
+ * Enumerator  FE             MCFE         SE
+ *
+ * <min-rev> is the first revision to which the definition applies:
+ *
+ *     A: Falcon A1 (SFC4000AB)
+ *     B: Falcon B0 (SFC4000BA)
+ *     C: Siena A0 (SFL9021AA)
+ *
+ * If the definition has been changed or removed in later revisions
+ * then <max-rev> is the last revision to which the definition applies;
+ * otherwise it is "Z".
+ */
+
+/**************************************************************************
+ *
+ * Falcon/Siena registers and descriptors
+ *
+ **************************************************************************
+ */
+
+/* ADR_REGION_REG: Address region register */
+#define	FR_AZ_ADR_REGION 0x00000000
+#define	FRF_AZ_ADR_REGION3_LBN 96
+#define	FRF_AZ_ADR_REGION3_WIDTH 18
+#define	FRF_AZ_ADR_REGION2_LBN 64
+#define	FRF_AZ_ADR_REGION2_WIDTH 18
+#define	FRF_AZ_ADR_REGION1_LBN 32
+#define	FRF_AZ_ADR_REGION1_WIDTH 18
+#define	FRF_AZ_ADR_REGION0_LBN 0
+#define	FRF_AZ_ADR_REGION0_WIDTH 18
+
+/* INT_EN_REG_KER: Kernel driver Interrupt enable register */
+#define	FR_AZ_INT_EN_KER 0x00000010
+#define	FRF_AZ_KER_INT_LEVE_SEL_LBN 8
+#define	FRF_AZ_KER_INT_LEVE_SEL_WIDTH 6
+#define	FRF_AZ_KER_INT_CHAR_LBN 4
+#define	FRF_AZ_KER_INT_CHAR_WIDTH 1
+#define	FRF_AZ_KER_INT_KER_LBN 3
+#define	FRF_AZ_KER_INT_KER_WIDTH 1
+#define	FRF_AZ_DRV_INT_EN_KER_LBN 0
+#define	FRF_AZ_DRV_INT_EN_KER_WIDTH 1
+
+/* INT_EN_REG_CHAR: Char Driver interrupt enable register */
+#define	FR_BZ_INT_EN_CHAR 0x00000020
+#define	FRF_BZ_CHAR_INT_LEVE_SEL_LBN 8
+#define	FRF_BZ_CHAR_INT_LEVE_SEL_WIDTH 6
+#define	FRF_BZ_CHAR_INT_CHAR_LBN 4
+#define	FRF_BZ_CHAR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_CHAR_INT_KER_LBN 3
+#define	FRF_BZ_CHAR_INT_KER_WIDTH 1
+#define	FRF_BZ_DRV_INT_EN_CHAR_LBN 0
+#define	FRF_BZ_DRV_INT_EN_CHAR_WIDTH 1
+
+/* INT_ADR_REG_KER: Interrupt host address for Kernel driver */
+#define	FR_AZ_INT_ADR_KER 0x00000030
+#define	FRF_AZ_NORM_INT_VEC_DIS_KER_LBN 64
+#define	FRF_AZ_NORM_INT_VEC_DIS_KER_WIDTH 1
+#define	FRF_AZ_INT_ADR_KER_LBN 0
+#define	FRF_AZ_INT_ADR_KER_WIDTH 64
+
+/* INT_ADR_REG_CHAR: Interrupt host address for Char driver */
+#define	FR_BZ_INT_ADR_CHAR 0x00000040
+#define	FRF_BZ_NORM_INT_VEC_DIS_CHAR_LBN 64
+#define	FRF_BZ_NORM_INT_VEC_DIS_CHAR_WIDTH 1
+#define	FRF_BZ_INT_ADR_CHAR_LBN 0
+#define	FRF_BZ_INT_ADR_CHAR_WIDTH 64
+
+/* INT_ACK_KER: Kernel interrupt acknowledge register */
+#define	FR_AA_INT_ACK_KER 0x00000050
+#define	FRF_AA_INT_ACK_KER_FIELD_LBN 0
+#define	FRF_AA_INT_ACK_KER_FIELD_WIDTH 32
+
+/* INT_ISR0_REG: Function 0 Interrupt Acknowledge Status register */
+#define	FR_BZ_INT_ISR0 0x00000090
+#define	FRF_BZ_INT_ISR_REG_LBN 0
+#define	FRF_BZ_INT_ISR_REG_WIDTH 64
+
+/* HW_INIT_REG: Hardware initialization register */
+#define	FR_AZ_HW_INIT 0x000000c0
+#define	FRF_BB_BDMRD_CPLF_FULL_LBN 124
+#define	FRF_BB_BDMRD_CPLF_FULL_WIDTH 1
+#define	FRF_BB_PCIE_CPL_TIMEOUT_CTRL_LBN 121
+#define	FRF_BB_PCIE_CPL_TIMEOUT_CTRL_WIDTH 3
+#define	FRF_CZ_TX_MRG_TAGS_LBN 120
+#define	FRF_CZ_TX_MRG_TAGS_WIDTH 1
+#define	FRF_AB_TRGT_MASK_ALL_LBN 100
+#define	FRF_AB_TRGT_MASK_ALL_WIDTH 1
+#define	FRF_AZ_DOORBELL_DROP_LBN 92
+#define	FRF_AZ_DOORBELL_DROP_WIDTH 8
+#define	FRF_AB_TX_RREQ_MASK_EN_LBN 76
+#define	FRF_AB_TX_RREQ_MASK_EN_WIDTH 1
+#define	FRF_AB_PE_EIDLE_DIS_LBN 75
+#define	FRF_AB_PE_EIDLE_DIS_WIDTH 1
+#define	FRF_AA_FC_BLOCKING_EN_LBN 45
+#define	FRF_AA_FC_BLOCKING_EN_WIDTH 1
+#define	FRF_BZ_B2B_REQ_EN_LBN 45
+#define	FRF_BZ_B2B_REQ_EN_WIDTH 1
+#define	FRF_AA_B2B_REQ_EN_LBN 44
+#define	FRF_AA_B2B_REQ_EN_WIDTH 1
+#define	FRF_BB_FC_BLOCKING_EN_LBN 44
+#define	FRF_BB_FC_BLOCKING_EN_WIDTH 1
+#define	FRF_AZ_POST_WR_MASK_LBN 40
+#define	FRF_AZ_POST_WR_MASK_WIDTH 4
+#define	FRF_AZ_TLP_TC_LBN 34
+#define	FRF_AZ_TLP_TC_WIDTH 3
+#define	FRF_AZ_TLP_ATTR_LBN 32
+#define	FRF_AZ_TLP_ATTR_WIDTH 2
+#define	FRF_AB_INTB_VEC_LBN 24
+#define	FRF_AB_INTB_VEC_WIDTH 5
+#define	FRF_AB_INTA_VEC_LBN 16
+#define	FRF_AB_INTA_VEC_WIDTH 5
+#define	FRF_AZ_WD_TIMER_LBN 8
+#define	FRF_AZ_WD_TIMER_WIDTH 8
+#define	FRF_AZ_US_DISABLE_LBN 5
+#define	FRF_AZ_US_DISABLE_WIDTH 1
+#define	FRF_AZ_TLP_EP_LBN 4
+#define	FRF_AZ_TLP_EP_WIDTH 1
+#define	FRF_AZ_ATTR_SEL_LBN 3
+#define	FRF_AZ_ATTR_SEL_WIDTH 1
+#define	FRF_AZ_TD_SEL_LBN 1
+#define	FRF_AZ_TD_SEL_WIDTH 1
+#define	FRF_AZ_TLP_TD_LBN 0
+#define	FRF_AZ_TLP_TD_WIDTH 1
+
+/* EE_SPI_HCMD_REG: SPI host command register */
+#define	FR_AB_EE_SPI_HCMD 0x00000100
+#define	FRF_AB_EE_SPI_HCMD_CMD_EN_LBN 31
+#define	FRF_AB_EE_SPI_HCMD_CMD_EN_WIDTH 1
+#define	FRF_AB_EE_WR_TIMER_ACTIVE_LBN 28
+#define	FRF_AB_EE_WR_TIMER_ACTIVE_WIDTH 1
+#define	FRF_AB_EE_SPI_HCMD_SF_SEL_LBN 24
+#define	FRF_AB_EE_SPI_HCMD_SF_SEL_WIDTH 1
+#define	FRF_AB_EE_SPI_HCMD_DABCNT_LBN 16
+#define	FRF_AB_EE_SPI_HCMD_DABCNT_WIDTH 5
+#define	FRF_AB_EE_SPI_HCMD_READ_LBN 15
+#define	FRF_AB_EE_SPI_HCMD_READ_WIDTH 1
+#define	FRF_AB_EE_SPI_HCMD_DUBCNT_LBN 12
+#define	FRF_AB_EE_SPI_HCMD_DUBCNT_WIDTH 2
+#define	FRF_AB_EE_SPI_HCMD_ADBCNT_LBN 8
+#define	FRF_AB_EE_SPI_HCMD_ADBCNT_WIDTH 2
+#define	FRF_AB_EE_SPI_HCMD_ENC_LBN 0
+#define	FRF_AB_EE_SPI_HCMD_ENC_WIDTH 8
+
+/* USR_EV_CFG: User Level Event Configuration register */
+#define	FR_CZ_USR_EV_CFG 0x00000100
+#define	FRF_CZ_USREV_DIS_LBN 16
+#define	FRF_CZ_USREV_DIS_WIDTH 1
+#define	FRF_CZ_DFLT_EVQ_LBN 0
+#define	FRF_CZ_DFLT_EVQ_WIDTH 10
+
+/* EE_SPI_HADR_REG: SPI host address register */
+#define	FR_AB_EE_SPI_HADR 0x00000110
+#define	FRF_AB_EE_SPI_HADR_DUBYTE_LBN 24
+#define	FRF_AB_EE_SPI_HADR_DUBYTE_WIDTH 8
+#define	FRF_AB_EE_SPI_HADR_ADR_LBN 0
+#define	FRF_AB_EE_SPI_HADR_ADR_WIDTH 24
+
+/* EE_SPI_HDATA_REG: SPI host data register */
+#define	FR_AB_EE_SPI_HDATA 0x00000120
+#define	FRF_AB_EE_SPI_HDATA3_LBN 96
+#define	FRF_AB_EE_SPI_HDATA3_WIDTH 32
+#define	FRF_AB_EE_SPI_HDATA2_LBN 64
+#define	FRF_AB_EE_SPI_HDATA2_WIDTH 32
+#define	FRF_AB_EE_SPI_HDATA1_LBN 32
+#define	FRF_AB_EE_SPI_HDATA1_WIDTH 32
+#define	FRF_AB_EE_SPI_HDATA0_LBN 0
+#define	FRF_AB_EE_SPI_HDATA0_WIDTH 32
+
+/* EE_BASE_PAGE_REG: Expansion ROM base mirror register */
+#define	FR_AB_EE_BASE_PAGE 0x00000130
+#define	FRF_AB_EE_EXPROM_MASK_LBN 16
+#define	FRF_AB_EE_EXPROM_MASK_WIDTH 13
+#define	FRF_AB_EE_EXP_ROM_WINDOW_BASE_LBN 0
+#define	FRF_AB_EE_EXP_ROM_WINDOW_BASE_WIDTH 13
+
+/* EE_VPD_CFG0_REG: SPI/VPD configuration register 0 */
+#define	FR_AB_EE_VPD_CFG0 0x00000140
+#define	FRF_AB_EE_SF_FASTRD_EN_LBN 127
+#define	FRF_AB_EE_SF_FASTRD_EN_WIDTH 1
+#define	FRF_AB_EE_SF_CLOCK_DIV_LBN 120
+#define	FRF_AB_EE_SF_CLOCK_DIV_WIDTH 7
+#define	FRF_AB_EE_VPD_WIP_POLL_LBN 119
+#define	FRF_AB_EE_VPD_WIP_POLL_WIDTH 1
+#define	FRF_AB_EE_EE_CLOCK_DIV_LBN 112
+#define	FRF_AB_EE_EE_CLOCK_DIV_WIDTH 7
+#define	FRF_AB_EE_EE_WR_TMR_VALUE_LBN 96
+#define	FRF_AB_EE_EE_WR_TMR_VALUE_WIDTH 16
+#define	FRF_AB_EE_VPDW_LENGTH_LBN 80
+#define	FRF_AB_EE_VPDW_LENGTH_WIDTH 15
+#define	FRF_AB_EE_VPDW_BASE_LBN 64
+#define	FRF_AB_EE_VPDW_BASE_WIDTH 15
+#define	FRF_AB_EE_VPD_WR_CMD_EN_LBN 56
+#define	FRF_AB_EE_VPD_WR_CMD_EN_WIDTH 8
+#define	FRF_AB_EE_VPD_BASE_LBN 32
+#define	FRF_AB_EE_VPD_BASE_WIDTH 24
+#define	FRF_AB_EE_VPD_LENGTH_LBN 16
+#define	FRF_AB_EE_VPD_LENGTH_WIDTH 15
+#define	FRF_AB_EE_VPD_AD_SIZE_LBN 8
+#define	FRF_AB_EE_VPD_AD_SIZE_WIDTH 5
+#define	FRF_AB_EE_VPD_ACCESS_ON_LBN 5
+#define	FRF_AB_EE_VPD_ACCESS_ON_WIDTH 1
+#define	FRF_AB_EE_VPD_ACCESS_BLOCK_LBN 4
+#define	FRF_AB_EE_VPD_ACCESS_BLOCK_WIDTH 1
+#define	FRF_AB_EE_VPD_DEV_SF_SEL_LBN 2
+#define	FRF_AB_EE_VPD_DEV_SF_SEL_WIDTH 1
+#define	FRF_AB_EE_VPD_EN_AD9_MODE_LBN 1
+#define	FRF_AB_EE_VPD_EN_AD9_MODE_WIDTH 1
+#define	FRF_AB_EE_VPD_EN_LBN 0
+#define	FRF_AB_EE_VPD_EN_WIDTH 1
+
+/* EE_VPD_SW_CNTL_REG: VPD access SW control register */
+#define	FR_AB_EE_VPD_SW_CNTL 0x00000150
+#define	FRF_AB_EE_VPD_CYCLE_PENDING_LBN 31
+#define	FRF_AB_EE_VPD_CYCLE_PENDING_WIDTH 1
+#define	FRF_AB_EE_VPD_CYC_WRITE_LBN 28
+#define	FRF_AB_EE_VPD_CYC_WRITE_WIDTH 1
+#define	FRF_AB_EE_VPD_CYC_ADR_LBN 0
+#define	FRF_AB_EE_VPD_CYC_ADR_WIDTH 15
+
+/* EE_VPD_SW_DATA_REG: VPD access SW data register */
+#define	FR_AB_EE_VPD_SW_DATA 0x00000160
+#define	FRF_AB_EE_VPD_CYC_DAT_LBN 0
+#define	FRF_AB_EE_VPD_CYC_DAT_WIDTH 32
+
+/* PBMX_DBG_IADDR_REG: Capture Module address register */
+#define	FR_CZ_PBMX_DBG_IADDR 0x000001f0
+#define	FRF_CZ_PBMX_DBG_IADDR_LBN 0
+#define	FRF_CZ_PBMX_DBG_IADDR_WIDTH 32
+
+/* PCIE_CORE_INDIRECT_REG: Indirect Access to PCIE Core registers */
+#define	FR_BB_PCIE_CORE_INDIRECT 0x000001f0
+#define	FRF_BB_PCIE_CORE_TARGET_DATA_LBN 32
+#define	FRF_BB_PCIE_CORE_TARGET_DATA_WIDTH 32
+#define	FRF_BB_PCIE_CORE_INDIRECT_ACCESS_DIR_LBN 15
+#define	FRF_BB_PCIE_CORE_INDIRECT_ACCESS_DIR_WIDTH 1
+#define	FRF_BB_PCIE_CORE_TARGET_REG_ADRS_LBN 0
+#define	FRF_BB_PCIE_CORE_TARGET_REG_ADRS_WIDTH 12
+
+/* PBMX_DBG_IDATA_REG: Capture Module data register */
+#define	FR_CZ_PBMX_DBG_IDATA 0x000001f8
+#define	FRF_CZ_PBMX_DBG_IDATA_LBN 0
+#define	FRF_CZ_PBMX_DBG_IDATA_WIDTH 64
+
+/* NIC_STAT_REG: NIC status register */
+#define	FR_AB_NIC_STAT 0x00000200
+#define	FRF_BB_AER_DIS_LBN 34
+#define	FRF_BB_AER_DIS_WIDTH 1
+#define	FRF_BB_EE_STRAP_EN_LBN 31
+#define	FRF_BB_EE_STRAP_EN_WIDTH 1
+#define	FRF_BB_EE_STRAP_LBN 24
+#define	FRF_BB_EE_STRAP_WIDTH 4
+#define	FRF_BB_REVISION_ID_LBN 17
+#define	FRF_BB_REVISION_ID_WIDTH 7
+#define	FRF_AB_ONCHIP_SRAM_LBN 16
+#define	FRF_AB_ONCHIP_SRAM_WIDTH 1
+#define	FRF_AB_SF_PRST_LBN 9
+#define	FRF_AB_SF_PRST_WIDTH 1
+#define	FRF_AB_EE_PRST_LBN 8
+#define	FRF_AB_EE_PRST_WIDTH 1
+#define	FRF_AB_ATE_MODE_LBN 3
+#define	FRF_AB_ATE_MODE_WIDTH 1
+#define	FRF_AB_STRAP_PINS_LBN 0
+#define	FRF_AB_STRAP_PINS_WIDTH 3
+
+/* GPIO_CTL_REG: GPIO control register */
+#define	FR_AB_GPIO_CTL 0x00000210
+#define	FRF_AB_GPIO_OUT3_LBN 112
+#define	FRF_AB_GPIO_OUT3_WIDTH 16
+#define	FRF_AB_GPIO_IN3_LBN 104
+#define	FRF_AB_GPIO_IN3_WIDTH 8
+#define	FRF_AB_GPIO_PWRUP_VALUE3_LBN 96
+#define	FRF_AB_GPIO_PWRUP_VALUE3_WIDTH 8
+#define	FRF_AB_GPIO_OUT2_LBN 80
+#define	FRF_AB_GPIO_OUT2_WIDTH 16
+#define	FRF_AB_GPIO_IN2_LBN 72
+#define	FRF_AB_GPIO_IN2_WIDTH 8
+#define	FRF_AB_GPIO_PWRUP_VALUE2_LBN 64
+#define	FRF_AB_GPIO_PWRUP_VALUE2_WIDTH 8
+#define	FRF_AB_GPIO15_OEN_LBN 63
+#define	FRF_AB_GPIO15_OEN_WIDTH 1
+#define	FRF_AB_GPIO14_OEN_LBN 62
+#define	FRF_AB_GPIO14_OEN_WIDTH 1
+#define	FRF_AB_GPIO13_OEN_LBN 61
+#define	FRF_AB_GPIO13_OEN_WIDTH 1
+#define	FRF_AB_GPIO12_OEN_LBN 60
+#define	FRF_AB_GPIO12_OEN_WIDTH 1
+#define	FRF_AB_GPIO11_OEN_LBN 59
+#define	FRF_AB_GPIO11_OEN_WIDTH 1
+#define	FRF_AB_GPIO10_OEN_LBN 58
+#define	FRF_AB_GPIO10_OEN_WIDTH 1
+#define	FRF_AB_GPIO9_OEN_LBN 57
+#define	FRF_AB_GPIO9_OEN_WIDTH 1
+#define	FRF_AB_GPIO8_OEN_LBN 56
+#define	FRF_AB_GPIO8_OEN_WIDTH 1
+#define	FRF_AB_GPIO15_OUT_LBN 55
+#define	FRF_AB_GPIO15_OUT_WIDTH 1
+#define	FRF_AB_GPIO14_OUT_LBN 54
+#define	FRF_AB_GPIO14_OUT_WIDTH 1
+#define	FRF_AB_GPIO13_OUT_LBN 53
+#define	FRF_AB_GPIO13_OUT_WIDTH 1
+#define	FRF_AB_GPIO12_OUT_LBN 52
+#define	FRF_AB_GPIO12_OUT_WIDTH 1
+#define	FRF_AB_GPIO11_OUT_LBN 51
+#define	FRF_AB_GPIO11_OUT_WIDTH 1
+#define	FRF_AB_GPIO10_OUT_LBN 50
+#define	FRF_AB_GPIO10_OUT_WIDTH 1
+#define	FRF_AB_GPIO9_OUT_LBN 49
+#define	FRF_AB_GPIO9_OUT_WIDTH 1
+#define	FRF_AB_GPIO8_OUT_LBN 48
+#define	FRF_AB_GPIO8_OUT_WIDTH 1
+#define	FRF_AB_GPIO15_IN_LBN 47
+#define	FRF_AB_GPIO15_IN_WIDTH 1
+#define	FRF_AB_GPIO14_IN_LBN 46
+#define	FRF_AB_GPIO14_IN_WIDTH 1
+#define	FRF_AB_GPIO13_IN_LBN 45
+#define	FRF_AB_GPIO13_IN_WIDTH 1
+#define	FRF_AB_GPIO12_IN_LBN 44
+#define	FRF_AB_GPIO12_IN_WIDTH 1
+#define	FRF_AB_GPIO11_IN_LBN 43
+#define	FRF_AB_GPIO11_IN_WIDTH 1
+#define	FRF_AB_GPIO10_IN_LBN 42
+#define	FRF_AB_GPIO10_IN_WIDTH 1
+#define	FRF_AB_GPIO9_IN_LBN 41
+#define	FRF_AB_GPIO9_IN_WIDTH 1
+#define	FRF_AB_GPIO8_IN_LBN 40
+#define	FRF_AB_GPIO8_IN_WIDTH 1
+#define	FRF_AB_GPIO15_PWRUP_VALUE_LBN 39
+#define	FRF_AB_GPIO15_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO14_PWRUP_VALUE_LBN 38
+#define	FRF_AB_GPIO14_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO13_PWRUP_VALUE_LBN 37
+#define	FRF_AB_GPIO13_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO12_PWRUP_VALUE_LBN 36
+#define	FRF_AB_GPIO12_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO11_PWRUP_VALUE_LBN 35
+#define	FRF_AB_GPIO11_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO10_PWRUP_VALUE_LBN 34
+#define	FRF_AB_GPIO10_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO9_PWRUP_VALUE_LBN 33
+#define	FRF_AB_GPIO9_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO8_PWRUP_VALUE_LBN 32
+#define	FRF_AB_GPIO8_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_CLK156_OUT_EN_LBN 31
+#define	FRF_AB_CLK156_OUT_EN_WIDTH 1
+#define	FRF_AB_USE_NIC_CLK_LBN 30
+#define	FRF_AB_USE_NIC_CLK_WIDTH 1
+#define	FRF_AB_GPIO5_OEN_LBN 29
+#define	FRF_AB_GPIO5_OEN_WIDTH 1
+#define	FRF_AB_GPIO4_OEN_LBN 28
+#define	FRF_AB_GPIO4_OEN_WIDTH 1
+#define	FRF_AB_GPIO3_OEN_LBN 27
+#define	FRF_AB_GPIO3_OEN_WIDTH 1
+#define	FRF_AB_GPIO2_OEN_LBN 26
+#define	FRF_AB_GPIO2_OEN_WIDTH 1
+#define	FRF_AB_GPIO1_OEN_LBN 25
+#define	FRF_AB_GPIO1_OEN_WIDTH 1
+#define	FRF_AB_GPIO0_OEN_LBN 24
+#define	FRF_AB_GPIO0_OEN_WIDTH 1
+#define	FRF_AB_GPIO7_OUT_LBN 23
+#define	FRF_AB_GPIO7_OUT_WIDTH 1
+#define	FRF_AB_GPIO6_OUT_LBN 22
+#define	FRF_AB_GPIO6_OUT_WIDTH 1
+#define	FRF_AB_GPIO5_OUT_LBN 21
+#define	FRF_AB_GPIO5_OUT_WIDTH 1
+#define	FRF_AB_GPIO4_OUT_LBN 20
+#define	FRF_AB_GPIO4_OUT_WIDTH 1
+#define	FRF_AB_GPIO3_OUT_LBN 19
+#define	FRF_AB_GPIO3_OUT_WIDTH 1
+#define	FRF_AB_GPIO2_OUT_LBN 18
+#define	FRF_AB_GPIO2_OUT_WIDTH 1
+#define	FRF_AB_GPIO1_OUT_LBN 17
+#define	FRF_AB_GPIO1_OUT_WIDTH 1
+#define	FRF_AB_GPIO0_OUT_LBN 16
+#define	FRF_AB_GPIO0_OUT_WIDTH 1
+#define	FRF_AB_GPIO7_IN_LBN 15
+#define	FRF_AB_GPIO7_IN_WIDTH 1
+#define	FRF_AB_GPIO6_IN_LBN 14
+#define	FRF_AB_GPIO6_IN_WIDTH 1
+#define	FRF_AB_GPIO5_IN_LBN 13
+#define	FRF_AB_GPIO5_IN_WIDTH 1
+#define	FRF_AB_GPIO4_IN_LBN 12
+#define	FRF_AB_GPIO4_IN_WIDTH 1
+#define	FRF_AB_GPIO3_IN_LBN 11
+#define	FRF_AB_GPIO3_IN_WIDTH 1
+#define	FRF_AB_GPIO2_IN_LBN 10
+#define	FRF_AB_GPIO2_IN_WIDTH 1
+#define	FRF_AB_GPIO1_IN_LBN 9
+#define	FRF_AB_GPIO1_IN_WIDTH 1
+#define	FRF_AB_GPIO0_IN_LBN 8
+#define	FRF_AB_GPIO0_IN_WIDTH 1
+#define	FRF_AB_GPIO7_PWRUP_VALUE_LBN 7
+#define	FRF_AB_GPIO7_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO6_PWRUP_VALUE_LBN 6
+#define	FRF_AB_GPIO6_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO5_PWRUP_VALUE_LBN 5
+#define	FRF_AB_GPIO5_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO4_PWRUP_VALUE_LBN 4
+#define	FRF_AB_GPIO4_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO3_PWRUP_VALUE_LBN 3
+#define	FRF_AB_GPIO3_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO2_PWRUP_VALUE_LBN 2
+#define	FRF_AB_GPIO2_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO1_PWRUP_VALUE_LBN 1
+#define	FRF_AB_GPIO1_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO0_PWRUP_VALUE_LBN 0
+#define	FRF_AB_GPIO0_PWRUP_VALUE_WIDTH 1
+
+/* GLB_CTL_REG: Global control register */
+#define	FR_AB_GLB_CTL 0x00000220
+#define	FRF_AB_EXT_PHY_RST_CTL_LBN 63
+#define	FRF_AB_EXT_PHY_RST_CTL_WIDTH 1
+#define	FRF_AB_XAUI_SD_RST_CTL_LBN 62
+#define	FRF_AB_XAUI_SD_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_SD_RST_CTL_LBN 61
+#define	FRF_AB_PCIE_SD_RST_CTL_WIDTH 1
+#define	FRF_AA_PCIX_RST_CTL_LBN 60
+#define	FRF_AA_PCIX_RST_CTL_WIDTH 1
+#define	FRF_BB_BIU_RST_CTL_LBN 60
+#define	FRF_BB_BIU_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_STKY_RST_CTL_LBN 59
+#define	FRF_AB_PCIE_STKY_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_NSTKY_RST_CTL_LBN 58
+#define	FRF_AB_PCIE_NSTKY_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_CORE_RST_CTL_LBN 57
+#define	FRF_AB_PCIE_CORE_RST_CTL_WIDTH 1
+#define	FRF_AB_XGRX_RST_CTL_LBN 56
+#define	FRF_AB_XGRX_RST_CTL_WIDTH 1
+#define	FRF_AB_XGTX_RST_CTL_LBN 55
+#define	FRF_AB_XGTX_RST_CTL_WIDTH 1
+#define	FRF_AB_EM_RST_CTL_LBN 54
+#define	FRF_AB_EM_RST_CTL_WIDTH 1
+#define	FRF_AB_EV_RST_CTL_LBN 53
+#define	FRF_AB_EV_RST_CTL_WIDTH 1
+#define	FRF_AB_SR_RST_CTL_LBN 52
+#define	FRF_AB_SR_RST_CTL_WIDTH 1
+#define	FRF_AB_RX_RST_CTL_LBN 51
+#define	FRF_AB_RX_RST_CTL_WIDTH 1
+#define	FRF_AB_TX_RST_CTL_LBN 50
+#define	FRF_AB_TX_RST_CTL_WIDTH 1
+#define	FRF_AB_EE_RST_CTL_LBN 49
+#define	FRF_AB_EE_RST_CTL_WIDTH 1
+#define	FRF_AB_CS_RST_CTL_LBN 48
+#define	FRF_AB_CS_RST_CTL_WIDTH 1
+#define	FRF_AB_HOT_RST_CTL_LBN 40
+#define	FRF_AB_HOT_RST_CTL_WIDTH 2
+#define	FRF_AB_RST_EXT_PHY_LBN 31
+#define	FRF_AB_RST_EXT_PHY_WIDTH 1
+#define	FRF_AB_RST_XAUI_SD_LBN 30
+#define	FRF_AB_RST_XAUI_SD_WIDTH 1
+#define	FRF_AB_RST_PCIE_SD_LBN 29
+#define	FRF_AB_RST_PCIE_SD_WIDTH 1
+#define	FRF_AA_RST_PCIX_LBN 28
+#define	FRF_AA_RST_PCIX_WIDTH 1
+#define	FRF_BB_RST_BIU_LBN 28
+#define	FRF_BB_RST_BIU_WIDTH 1
+#define	FRF_AB_RST_PCIE_STKY_LBN 27
+#define	FRF_AB_RST_PCIE_STKY_WIDTH 1
+#define	FRF_AB_RST_PCIE_NSTKY_LBN 26
+#define	FRF_AB_RST_PCIE_NSTKY_WIDTH 1
+#define	FRF_AB_RST_PCIE_CORE_LBN 25
+#define	FRF_AB_RST_PCIE_CORE_WIDTH 1
+#define	FRF_AB_RST_XGRX_LBN 24
+#define	FRF_AB_RST_XGRX_WIDTH 1
+#define	FRF_AB_RST_XGTX_LBN 23
+#define	FRF_AB_RST_XGTX_WIDTH 1
+#define	FRF_AB_RST_EM_LBN 22
+#define	FRF_AB_RST_EM_WIDTH 1
+#define	FRF_AB_RST_EV_LBN 21
+#define	FRF_AB_RST_EV_WIDTH 1
+#define	FRF_AB_RST_SR_LBN 20
+#define	FRF_AB_RST_SR_WIDTH 1
+#define	FRF_AB_RST_RX_LBN 19
+#define	FRF_AB_RST_RX_WIDTH 1
+#define	FRF_AB_RST_TX_LBN 18
+#define	FRF_AB_RST_TX_WIDTH 1
+#define	FRF_AB_RST_SF_LBN 17
+#define	FRF_AB_RST_SF_WIDTH 1
+#define	FRF_AB_RST_CS_LBN 16
+#define	FRF_AB_RST_CS_WIDTH 1
+#define	FRF_AB_INT_RST_DUR_LBN 4
+#define	FRF_AB_INT_RST_DUR_WIDTH 3
+#define	FRF_AB_EXT_PHY_RST_DUR_LBN 1
+#define	FRF_AB_EXT_PHY_RST_DUR_WIDTH 3
+#define	FFE_AB_EXT_PHY_RST_DUR_10240US 7
+#define	FFE_AB_EXT_PHY_RST_DUR_5120US 6
+#define	FFE_AB_EXT_PHY_RST_DUR_2560US 5
+#define	FFE_AB_EXT_PHY_RST_DUR_1280US 4
+#define	FFE_AB_EXT_PHY_RST_DUR_640US 3
+#define	FFE_AB_EXT_PHY_RST_DUR_320US 2
+#define	FFE_AB_EXT_PHY_RST_DUR_160US 1
+#define	FFE_AB_EXT_PHY_RST_DUR_80US 0
+#define	FRF_AB_SWRST_LBN 0
+#define	FRF_AB_SWRST_WIDTH 1
+
+/* FATAL_INTR_REG_KER: Fatal interrupt register for Kernel */
+#define	FR_AZ_FATAL_INTR_KER 0x00000230
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_EN_LBN 44
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_EN_WIDTH 1
+#define	FRF_AB_PCI_BUSERR_INT_KER_EN_LBN 43
+#define	FRF_AB_PCI_BUSERR_INT_KER_EN_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_KER_EN_LBN 43
+#define	FRF_CZ_MBU_PERR_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_SRAM_OOB_INT_KER_EN_LBN 42
+#define	FRF_AZ_SRAM_OOB_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_BUFID_OOB_INT_KER_EN_LBN 41
+#define	FRF_AZ_BUFID_OOB_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_MEM_PERR_INT_KER_EN_LBN 40
+#define	FRF_AZ_MEM_PERR_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_RBUF_OWN_INT_KER_EN_LBN 39
+#define	FRF_AZ_RBUF_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_TBUF_OWN_INT_KER_EN_LBN 38
+#define	FRF_AZ_TBUF_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_EN_LBN 37
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_EN_LBN 36
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_EVQ_OWN_INT_KER_EN_LBN 35
+#define	FRF_AZ_EVQ_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_EVF_OFLO_INT_KER_EN_LBN 34
+#define	FRF_AZ_EVF_OFLO_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_ILL_ADR_INT_KER_EN_LBN 33
+#define	FRF_AZ_ILL_ADR_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_SRM_PERR_INT_KER_EN_LBN 32
+#define	FRF_AZ_SRM_PERR_INT_KER_EN_WIDTH 1
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_LBN 12
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_WIDTH 1
+#define	FRF_AB_PCI_BUSERR_INT_KER_LBN 11
+#define	FRF_AB_PCI_BUSERR_INT_KER_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_KER_LBN 11
+#define	FRF_CZ_MBU_PERR_INT_KER_WIDTH 1
+#define	FRF_AZ_SRAM_OOB_INT_KER_LBN 10
+#define	FRF_AZ_SRAM_OOB_INT_KER_WIDTH 1
+#define	FRF_AZ_BUFID_DC_OOB_INT_KER_LBN 9
+#define	FRF_AZ_BUFID_DC_OOB_INT_KER_WIDTH 1
+#define	FRF_AZ_MEM_PERR_INT_KER_LBN 8
+#define	FRF_AZ_MEM_PERR_INT_KER_WIDTH 1
+#define	FRF_AZ_RBUF_OWN_INT_KER_LBN 7
+#define	FRF_AZ_RBUF_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_TBUF_OWN_INT_KER_LBN 6
+#define	FRF_AZ_TBUF_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_LBN 5
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_LBN 4
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_EVQ_OWN_INT_KER_LBN 3
+#define	FRF_AZ_EVQ_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_EVF_OFLO_INT_KER_LBN 2
+#define	FRF_AZ_EVF_OFLO_INT_KER_WIDTH 1
+#define	FRF_AZ_ILL_ADR_INT_KER_LBN 1
+#define	FRF_AZ_ILL_ADR_INT_KER_WIDTH 1
+#define	FRF_AZ_SRM_PERR_INT_KER_LBN 0
+#define	FRF_AZ_SRM_PERR_INT_KER_WIDTH 1
+
+/* FATAL_INTR_REG_CHAR: Fatal interrupt register for Char */
+#define	FR_BZ_FATAL_INTR_CHAR 0x00000240
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_EN_LBN 44
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_EN_WIDTH 1
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_EN_LBN 43
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_CHAR_EN_LBN 43
+#define	FRF_CZ_MBU_PERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_EN_LBN 42
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_BUFID_OOB_INT_CHAR_EN_LBN 41
+#define	FRF_BZ_BUFID_OOB_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_MEM_PERR_INT_CHAR_EN_LBN 40
+#define	FRF_BZ_MEM_PERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_EN_LBN 39
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_EN_LBN 38
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_EN_LBN 37
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_EN_LBN 36
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_EN_LBN 35
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_EN_LBN 34
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_ILL_ADR_INT_CHAR_EN_LBN 33
+#define	FRF_BZ_ILL_ADR_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_SRM_PERR_INT_CHAR_EN_LBN 32
+#define	FRF_BZ_SRM_PERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_LBN 12
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_WIDTH 1
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_LBN 11
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_CHAR_LBN 11
+#define	FRF_CZ_MBU_PERR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_LBN 10
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_WIDTH 1
+#define	FRF_BZ_BUFID_DC_OOB_INT_CHAR_LBN 9
+#define	FRF_BZ_BUFID_DC_OOB_INT_CHAR_WIDTH 1
+#define	FRF_BZ_MEM_PERR_INT_CHAR_LBN 8
+#define	FRF_BZ_MEM_PERR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_LBN 7
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_LBN 6
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_LBN 5
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_LBN 4
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_LBN 3
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_LBN 2
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_WIDTH 1
+#define	FRF_BZ_ILL_ADR_INT_CHAR_LBN 1
+#define	FRF_BZ_ILL_ADR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_SRM_PERR_INT_CHAR_LBN 0
+#define	FRF_BZ_SRM_PERR_INT_CHAR_WIDTH 1
+
+/* DP_CTRL_REG: Datapath control register */
+#define	FR_BZ_DP_CTRL 0x00000250
+#define	FRF_BZ_FLS_EVQ_ID_LBN 0
+#define	FRF_BZ_FLS_EVQ_ID_WIDTH 12
+
+/* MEM_STAT_REG: Memory status register */
+#define	FR_AZ_MEM_STAT 0x00000260
+#define	FRF_AB_MEM_PERR_VEC_LBN 53
+#define	FRF_AB_MEM_PERR_VEC_WIDTH 38
+#define	FRF_AB_MBIST_CORR_LBN 38
+#define	FRF_AB_MBIST_CORR_WIDTH 15
+#define	FRF_AB_MBIST_ERR_LBN 0
+#define	FRF_AB_MBIST_ERR_WIDTH 40
+#define	FRF_CZ_MEM_PERR_VEC_LBN 0
+#define	FRF_CZ_MEM_PERR_VEC_WIDTH 35
+
+/* CS_DEBUG_REG: Debug register */
+#define	FR_AZ_CS_DEBUG 0x00000270
+#define	FRF_AB_GLB_DEBUG2_SEL_LBN 50
+#define	FRF_AB_GLB_DEBUG2_SEL_WIDTH 3
+#define	FRF_AB_DEBUG_BLK_SEL2_LBN 47
+#define	FRF_AB_DEBUG_BLK_SEL2_WIDTH 3
+#define	FRF_AB_DEBUG_BLK_SEL1_LBN 44
+#define	FRF_AB_DEBUG_BLK_SEL1_WIDTH 3
+#define	FRF_AB_DEBUG_BLK_SEL0_LBN 41
+#define	FRF_AB_DEBUG_BLK_SEL0_WIDTH 3
+#define	FRF_CZ_CS_PORT_NUM_LBN 40
+#define	FRF_CZ_CS_PORT_NUM_WIDTH 2
+#define	FRF_AB_MISC_DEBUG_ADDR_LBN 36
+#define	FRF_AB_MISC_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_SERDES_DEBUG_ADDR_LBN 31
+#define	FRF_AB_SERDES_DEBUG_ADDR_WIDTH 5
+#define	FRF_CZ_CS_PORT_FPE_LBN 1
+#define	FRF_CZ_CS_PORT_FPE_WIDTH 35
+#define	FRF_AB_EM_DEBUG_ADDR_LBN 26
+#define	FRF_AB_EM_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_SR_DEBUG_ADDR_LBN 21
+#define	FRF_AB_SR_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_EV_DEBUG_ADDR_LBN 16
+#define	FRF_AB_EV_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_RX_DEBUG_ADDR_LBN 11
+#define	FRF_AB_RX_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_TX_DEBUG_ADDR_LBN 6
+#define	FRF_AB_TX_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_CS_BIU_DEBUG_ADDR_LBN 1
+#define	FRF_AB_CS_BIU_DEBUG_ADDR_WIDTH 5
+#define	FRF_AZ_CS_DEBUG_EN_LBN 0
+#define	FRF_AZ_CS_DEBUG_EN_WIDTH 1
+
+/* DRIVER_REG: Driver scratch register [0-7] */
+#define	FR_AZ_DRIVER 0x00000280
+#define	FR_AZ_DRIVER_STEP 16
+#define	FR_AZ_DRIVER_ROWS 8
+#define	FRF_AZ_DRIVER_DW0_LBN 0
+#define	FRF_AZ_DRIVER_DW0_WIDTH 32
+
+/* ALTERA_BUILD_REG: Altera build register */
+#define	FR_AZ_ALTERA_BUILD 0x00000300
+#define	FRF_AZ_ALTERA_BUILD_VER_LBN 0
+#define	FRF_AZ_ALTERA_BUILD_VER_WIDTH 32
+
+/* CSR_SPARE_REG: Spare register */
+#define	FR_AZ_CSR_SPARE 0x00000310
+#define	FRF_AB_MEM_PERR_EN_LBN 64
+#define	FRF_AB_MEM_PERR_EN_WIDTH 38
+#define	FRF_CZ_MEM_PERR_EN_LBN 64
+#define	FRF_CZ_MEM_PERR_EN_WIDTH 35
+#define	FRF_AB_MEM_PERR_EN_TX_DATA_LBN 72
+#define	FRF_AB_MEM_PERR_EN_TX_DATA_WIDTH 2
+#define	FRF_AZ_CSR_SPARE_BITS_LBN 0
+#define	FRF_AZ_CSR_SPARE_BITS_WIDTH 32
+
+/* PCIE_SD_CTL0123_REG: PCIE SerDes control register 0 to 3 */
+#define	FR_AB_PCIE_SD_CTL0123 0x00000320
+#define	FRF_AB_PCIE_TESTSIG_H_LBN 96
+#define	FRF_AB_PCIE_TESTSIG_H_WIDTH 19
+#define	FRF_AB_PCIE_TESTSIG_L_LBN 64
+#define	FRF_AB_PCIE_TESTSIG_L_WIDTH 19
+#define	FRF_AB_PCIE_OFFSET_LBN 56
+#define	FRF_AB_PCIE_OFFSET_WIDTH 8
+#define	FRF_AB_PCIE_OFFSETEN_H_LBN 55
+#define	FRF_AB_PCIE_OFFSETEN_H_WIDTH 1
+#define	FRF_AB_PCIE_OFFSETEN_L_LBN 54
+#define	FRF_AB_PCIE_OFFSETEN_L_WIDTH 1
+#define	FRF_AB_PCIE_HIVMODE_H_LBN 53
+#define	FRF_AB_PCIE_HIVMODE_H_WIDTH 1
+#define	FRF_AB_PCIE_HIVMODE_L_LBN 52
+#define	FRF_AB_PCIE_HIVMODE_L_WIDTH 1
+#define	FRF_AB_PCIE_PARRESET_H_LBN 51
+#define	FRF_AB_PCIE_PARRESET_H_WIDTH 1
+#define	FRF_AB_PCIE_PARRESET_L_LBN 50
+#define	FRF_AB_PCIE_PARRESET_L_WIDTH 1
+#define	FRF_AB_PCIE_LPBKWDRV_H_LBN 49
+#define	FRF_AB_PCIE_LPBKWDRV_H_WIDTH 1
+#define	FRF_AB_PCIE_LPBKWDRV_L_LBN 48
+#define	FRF_AB_PCIE_LPBKWDRV_L_WIDTH 1
+#define	FRF_AB_PCIE_LPBK_LBN 40
+#define	FRF_AB_PCIE_LPBK_WIDTH 8
+#define	FRF_AB_PCIE_PARLPBK_LBN 32
+#define	FRF_AB_PCIE_PARLPBK_WIDTH 8
+#define	FRF_AB_PCIE_RXTERMADJ_H_LBN 30
+#define	FRF_AB_PCIE_RXTERMADJ_H_WIDTH 2
+#define	FRF_AB_PCIE_RXTERMADJ_L_LBN 28
+#define	FRF_AB_PCIE_RXTERMADJ_L_WIDTH 2
+#define	FFE_AB_PCIE_RXTERMADJ_MIN15PCNT 3
+#define	FFE_AB_PCIE_RXTERMADJ_PL10PCNT 2
+#define	FFE_AB_PCIE_RXTERMADJ_MIN17PCNT 1
+#define	FFE_AB_PCIE_RXTERMADJ_NOMNL 0
+#define	FRF_AB_PCIE_TXTERMADJ_H_LBN 26
+#define	FRF_AB_PCIE_TXTERMADJ_H_WIDTH 2
+#define	FRF_AB_PCIE_TXTERMADJ_L_LBN 24
+#define	FRF_AB_PCIE_TXTERMADJ_L_WIDTH 2
+#define	FFE_AB_PCIE_TXTERMADJ_MIN15PCNT 3
+#define	FFE_AB_PCIE_TXTERMADJ_PL10PCNT 2
+#define	FFE_AB_PCIE_TXTERMADJ_MIN17PCNT 1
+#define	FFE_AB_PCIE_TXTERMADJ_NOMNL 0
+#define	FRF_AB_PCIE_RXEQCTL_H_LBN 18
+#define	FRF_AB_PCIE_RXEQCTL_H_WIDTH 2
+#define	FRF_AB_PCIE_RXEQCTL_L_LBN 16
+#define	FRF_AB_PCIE_RXEQCTL_L_WIDTH 2
+#define	FFE_AB_PCIE_RXEQCTL_OFF_ALT 3
+#define	FFE_AB_PCIE_RXEQCTL_OFF 2
+#define	FFE_AB_PCIE_RXEQCTL_MIN 1
+#define	FFE_AB_PCIE_RXEQCTL_MAX 0
+#define	FRF_AB_PCIE_HIDRV_LBN 8
+#define	FRF_AB_PCIE_HIDRV_WIDTH 8
+#define	FRF_AB_PCIE_LODRV_LBN 0
+#define	FRF_AB_PCIE_LODRV_WIDTH 8
+
+/* PCIE_SD_CTL45_REG: PCIE SerDes control register 4 and 5 */
+#define	FR_AB_PCIE_SD_CTL45 0x00000330
+#define	FRF_AB_PCIE_DTX7_LBN 60
+#define	FRF_AB_PCIE_DTX7_WIDTH 4
+#define	FRF_AB_PCIE_DTX6_LBN 56
+#define	FRF_AB_PCIE_DTX6_WIDTH 4
+#define	FRF_AB_PCIE_DTX5_LBN 52
+#define	FRF_AB_PCIE_DTX5_WIDTH 4
+#define	FRF_AB_PCIE_DTX4_LBN 48
+#define	FRF_AB_PCIE_DTX4_WIDTH 4
+#define	FRF_AB_PCIE_DTX3_LBN 44
+#define	FRF_AB_PCIE_DTX3_WIDTH 4
+#define	FRF_AB_PCIE_DTX2_LBN 40
+#define	FRF_AB_PCIE_DTX2_WIDTH 4
+#define	FRF_AB_PCIE_DTX1_LBN 36
+#define	FRF_AB_PCIE_DTX1_WIDTH 4
+#define	FRF_AB_PCIE_DTX0_LBN 32
+#define	FRF_AB_PCIE_DTX0_WIDTH 4
+#define	FRF_AB_PCIE_DEQ7_LBN 28
+#define	FRF_AB_PCIE_DEQ7_WIDTH 4
+#define	FRF_AB_PCIE_DEQ6_LBN 24
+#define	FRF_AB_PCIE_DEQ6_WIDTH 4
+#define	FRF_AB_PCIE_DEQ5_LBN 20
+#define	FRF_AB_PCIE_DEQ5_WIDTH 4
+#define	FRF_AB_PCIE_DEQ4_LBN 16
+#define	FRF_AB_PCIE_DEQ4_WIDTH 4
+#define	FRF_AB_PCIE_DEQ3_LBN 12
+#define	FRF_AB_PCIE_DEQ3_WIDTH 4
+#define	FRF_AB_PCIE_DEQ2_LBN 8
+#define	FRF_AB_PCIE_DEQ2_WIDTH 4
+#define	FRF_AB_PCIE_DEQ1_LBN 4
+#define	FRF_AB_PCIE_DEQ1_WIDTH 4
+#define	FRF_AB_PCIE_DEQ0_LBN 0
+#define	FRF_AB_PCIE_DEQ0_WIDTH 4
+
+/* PCIE_PCS_CTL_STAT_REG: PCIE PCS control and status register */
+#define	FR_AB_PCIE_PCS_CTL_STAT 0x00000340
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_H_LBN 52
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_H_WIDTH 4
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_L_LBN 48
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_L_WIDTH 4
+#define	FRF_AB_PCIE_PRBSERR_LBN 40
+#define	FRF_AB_PCIE_PRBSERR_WIDTH 8
+#define	FRF_AB_PCIE_PRBSERRH0_LBN 32
+#define	FRF_AB_PCIE_PRBSERRH0_WIDTH 8
+#define	FRF_AB_PCIE_FASTINIT_H_LBN 15
+#define	FRF_AB_PCIE_FASTINIT_H_WIDTH 1
+#define	FRF_AB_PCIE_FASTINIT_L_LBN 14
+#define	FRF_AB_PCIE_FASTINIT_L_WIDTH 1
+#define	FRF_AB_PCIE_CTCDISABLE_H_LBN 13
+#define	FRF_AB_PCIE_CTCDISABLE_H_WIDTH 1
+#define	FRF_AB_PCIE_CTCDISABLE_L_LBN 12
+#define	FRF_AB_PCIE_CTCDISABLE_L_WIDTH 1
+#define	FRF_AB_PCIE_PRBSSYNC_H_LBN 11
+#define	FRF_AB_PCIE_PRBSSYNC_H_WIDTH 1
+#define	FRF_AB_PCIE_PRBSSYNC_L_LBN 10
+#define	FRF_AB_PCIE_PRBSSYNC_L_WIDTH 1
+#define	FRF_AB_PCIE_PRBSERRACK_H_LBN 9
+#define	FRF_AB_PCIE_PRBSERRACK_H_WIDTH 1
+#define	FRF_AB_PCIE_PRBSERRACK_L_LBN 8
+#define	FRF_AB_PCIE_PRBSERRACK_L_WIDTH 1
+#define	FRF_AB_PCIE_PRBSSEL_LBN 0
+#define	FRF_AB_PCIE_PRBSSEL_WIDTH 8
+
+/* DEBUG_DATA_OUT_REG: Live Debug and Debug 2 out ports */
+#define	FR_BB_DEBUG_DATA_OUT 0x00000350
+#define	FRF_BB_DEBUG2_PORT_LBN 25
+#define	FRF_BB_DEBUG2_PORT_WIDTH 15
+#define	FRF_BB_DEBUG1_PORT_LBN 0
+#define	FRF_BB_DEBUG1_PORT_WIDTH 25
+
+/* EVQ_RPTR_REGP0: Event queue read pointer register */
+#define	FR_BZ_EVQ_RPTR_P0 0x00000400
+#define	FR_BZ_EVQ_RPTR_P0_STEP 8192
+#define	FR_BZ_EVQ_RPTR_P0_ROWS 1024
+/* EVQ_RPTR_REG_KER: Event queue read pointer register */
+#define	FR_AA_EVQ_RPTR_KER 0x00011b00
+#define	FR_AA_EVQ_RPTR_KER_STEP 4
+#define	FR_AA_EVQ_RPTR_KER_ROWS 4
+/* EVQ_RPTR_REG: Event queue read pointer register */
+#define	FR_BZ_EVQ_RPTR 0x00fa0000
+#define	FR_BZ_EVQ_RPTR_STEP 16
+#define	FR_BB_EVQ_RPTR_ROWS 4096
+#define	FR_CZ_EVQ_RPTR_ROWS 1024
+/* EVQ_RPTR_REGP123: Event queue read pointer register */
+#define	FR_BB_EVQ_RPTR_P123 0x01000400
+#define	FR_BB_EVQ_RPTR_P123_STEP 8192
+#define	FR_BB_EVQ_RPTR_P123_ROWS 3072
+#define	FRF_AZ_EVQ_RPTR_VLD_LBN 15
+#define	FRF_AZ_EVQ_RPTR_VLD_WIDTH 1
+#define	FRF_AZ_EVQ_RPTR_LBN 0
+#define	FRF_AZ_EVQ_RPTR_WIDTH 15
+
+/* TIMER_COMMAND_REGP0: Timer Command Registers */
+#define	FR_BZ_TIMER_COMMAND_P0 0x00000420
+#define	FR_BZ_TIMER_COMMAND_P0_STEP 8192
+#define	FR_BZ_TIMER_COMMAND_P0_ROWS 1024
+/* TIMER_COMMAND_REG_KER: Timer Command Registers */
+#define	FR_AA_TIMER_COMMAND_KER 0x00000420
+#define	FR_AA_TIMER_COMMAND_KER_STEP 8192
+#define	FR_AA_TIMER_COMMAND_KER_ROWS 4
+/* TIMER_COMMAND_REGP123: Timer Command Registers */
+#define	FR_BB_TIMER_COMMAND_P123 0x01000420
+#define	FR_BB_TIMER_COMMAND_P123_STEP 8192
+#define	FR_BB_TIMER_COMMAND_P123_ROWS 3072
+#define	FRF_CZ_TC_TIMER_MODE_LBN 14
+#define	FRF_CZ_TC_TIMER_MODE_WIDTH 2
+#define	FRF_AB_TC_TIMER_MODE_LBN 12
+#define	FRF_AB_TC_TIMER_MODE_WIDTH 2
+#define	FRF_CZ_TC_TIMER_VAL_LBN 0
+#define	FRF_CZ_TC_TIMER_VAL_WIDTH 14
+#define	FRF_AB_TC_TIMER_VAL_LBN 0
+#define	FRF_AB_TC_TIMER_VAL_WIDTH 12
+
+/* DRV_EV_REG: Driver generated event register */
+#define	FR_AZ_DRV_EV 0x00000440
+#define	FRF_AZ_DRV_EV_QID_LBN 64
+#define	FRF_AZ_DRV_EV_QID_WIDTH 12
+#define	FRF_AZ_DRV_EV_DATA_LBN 0
+#define	FRF_AZ_DRV_EV_DATA_WIDTH 64
+
+/* EVQ_CTL_REG: Event queue control register */
+#define	FR_AZ_EVQ_CTL 0x00000450
+#define	FRF_CZ_RX_EVQ_WAKEUP_MASK_LBN 15
+#define	FRF_CZ_RX_EVQ_WAKEUP_MASK_WIDTH 10
+#define	FRF_BB_RX_EVQ_WAKEUP_MASK_LBN 15
+#define	FRF_BB_RX_EVQ_WAKEUP_MASK_WIDTH 6
+#define	FRF_AZ_EVQ_OWNERR_CTL_LBN 14
+#define	FRF_AZ_EVQ_OWNERR_CTL_WIDTH 1
+#define	FRF_AZ_EVQ_FIFO_AF_TH_LBN 7
+#define	FRF_AZ_EVQ_FIFO_AF_TH_WIDTH 7
+#define	FRF_AZ_EVQ_FIFO_NOTAF_TH_LBN 0
+#define	FRF_AZ_EVQ_FIFO_NOTAF_TH_WIDTH 7
+
+/* EVQ_CNT1_REG: Event counter 1 register */
+#define	FR_AZ_EVQ_CNT1 0x00000460
+#define	FRF_AZ_EVQ_CNT_PRE_FIFO_LBN 120
+#define	FRF_AZ_EVQ_CNT_PRE_FIFO_WIDTH 7
+#define	FRF_AZ_EVQ_CNT_TOBIU_LBN 100
+#define	FRF_AZ_EVQ_CNT_TOBIU_WIDTH 20
+#define	FRF_AZ_EVQ_TX_REQ_CNT_LBN 80
+#define	FRF_AZ_EVQ_TX_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_RX_REQ_CNT_LBN 60
+#define	FRF_AZ_EVQ_RX_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_EM_REQ_CNT_LBN 40
+#define	FRF_AZ_EVQ_EM_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_CSR_REQ_CNT_LBN 20
+#define	FRF_AZ_EVQ_CSR_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_ERR_REQ_CNT_LBN 0
+#define	FRF_AZ_EVQ_ERR_REQ_CNT_WIDTH 20
+
+/* EVQ_CNT2_REG: Event counter 2 register */
+#define	FR_AZ_EVQ_CNT2 0x00000470
+#define	FRF_AZ_EVQ_UPD_REQ_CNT_LBN 104
+#define	FRF_AZ_EVQ_UPD_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_CLR_REQ_CNT_LBN 84
+#define	FRF_AZ_EVQ_CLR_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_RDY_CNT_LBN 80
+#define	FRF_AZ_EVQ_RDY_CNT_WIDTH 4
+#define	FRF_AZ_EVQ_WU_REQ_CNT_LBN 60
+#define	FRF_AZ_EVQ_WU_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_WET_REQ_CNT_LBN 40
+#define	FRF_AZ_EVQ_WET_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_INIT_REQ_CNT_LBN 20
+#define	FRF_AZ_EVQ_INIT_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_TM_REQ_CNT_LBN 0
+#define	FRF_AZ_EVQ_TM_REQ_CNT_WIDTH 20
+
+/* USR_EV_REG: Event mailbox register */
+#define	FR_CZ_USR_EV 0x00000540
+#define	FR_CZ_USR_EV_STEP 8192
+#define	FR_CZ_USR_EV_ROWS 1024
+#define	FRF_CZ_USR_EV_DATA_LBN 0
+#define	FRF_CZ_USR_EV_DATA_WIDTH 32
+
+/* BUF_TBL_CFG_REG: Buffer table configuration register */
+#define	FR_AZ_BUF_TBL_CFG 0x00000600
+#define	FRF_AZ_BUF_TBL_MODE_LBN 3
+#define	FRF_AZ_BUF_TBL_MODE_WIDTH 1
+
+/* SRM_RX_DC_CFG_REG: SRAM receive descriptor cache configuration register */
+#define	FR_AZ_SRM_RX_DC_CFG 0x00000610
+#define	FRF_AZ_SRM_CLK_TMP_EN_LBN 21
+#define	FRF_AZ_SRM_CLK_TMP_EN_WIDTH 1
+#define	FRF_AZ_SRM_RX_DC_BASE_ADR_LBN 0
+#define	FRF_AZ_SRM_RX_DC_BASE_ADR_WIDTH 21
+
+/* SRM_TX_DC_CFG_REG: SRAM transmit descriptor cache configuration register */
+#define	FR_AZ_SRM_TX_DC_CFG 0x00000620
+#define	FRF_AZ_SRM_TX_DC_BASE_ADR_LBN 0
+#define	FRF_AZ_SRM_TX_DC_BASE_ADR_WIDTH 21
+
+/* SRM_CFG_REG: SRAM configuration register */
+#define	FR_AZ_SRM_CFG 0x00000630
+#define	FRF_AZ_SRM_OOB_ADR_INTEN_LBN 5
+#define	FRF_AZ_SRM_OOB_ADR_INTEN_WIDTH 1
+#define	FRF_AZ_SRM_OOB_BUF_INTEN_LBN 4
+#define	FRF_AZ_SRM_OOB_BUF_INTEN_WIDTH 1
+#define	FRF_AZ_SRM_INIT_EN_LBN 3
+#define	FRF_AZ_SRM_INIT_EN_WIDTH 1
+#define	FRF_AZ_SRM_NUM_BANK_LBN 2
+#define	FRF_AZ_SRM_NUM_BANK_WIDTH 1
+#define	FRF_AZ_SRM_BANK_SIZE_LBN 0
+#define	FRF_AZ_SRM_BANK_SIZE_WIDTH 2
+
+/* BUF_TBL_UPD_REG: Buffer table update register */
+#define	FR_AZ_BUF_TBL_UPD 0x00000650
+#define	FRF_AZ_BUF_UPD_CMD_LBN 63
+#define	FRF_AZ_BUF_UPD_CMD_WIDTH 1
+#define	FRF_AZ_BUF_CLR_CMD_LBN 62
+#define	FRF_AZ_BUF_CLR_CMD_WIDTH 1
+#define	FRF_AZ_BUF_CLR_END_ID_LBN 32
+#define	FRF_AZ_BUF_CLR_END_ID_WIDTH 20
+#define	FRF_AZ_BUF_CLR_START_ID_LBN 0
+#define	FRF_AZ_BUF_CLR_START_ID_WIDTH 20
+
+/* SRM_UPD_EVQ_REG: Buffer table update register */
+#define	FR_AZ_SRM_UPD_EVQ 0x00000660
+#define	FRF_AZ_SRM_UPD_EVQ_ID_LBN 0
+#define	FRF_AZ_SRM_UPD_EVQ_ID_WIDTH 12
+
+/* SRAM_PARITY_REG: SRAM parity register. */
+#define	FR_AZ_SRAM_PARITY 0x00000670
+#define	FRF_CZ_BYPASS_ECC_LBN 3
+#define	FRF_CZ_BYPASS_ECC_WIDTH 1
+#define	FRF_CZ_SEC_INT_LBN 2
+#define	FRF_CZ_SEC_INT_WIDTH 1
+#define	FRF_CZ_FORCE_SRAM_DOUBLE_ERR_LBN 1
+#define	FRF_CZ_FORCE_SRAM_DOUBLE_ERR_WIDTH 1
+#define	FRF_AB_FORCE_SRAM_PERR_LBN 0
+#define	FRF_AB_FORCE_SRAM_PERR_WIDTH 1
+#define	FRF_CZ_FORCE_SRAM_SINGLE_ERR_LBN 0
+#define	FRF_CZ_FORCE_SRAM_SINGLE_ERR_WIDTH 1
+
+/* RX_CFG_REG: Receive configuration register */
+#define	FR_AZ_RX_CFG 0x00000800
+#define	FRF_CZ_RX_MIN_KBUF_SIZE_LBN 72
+#define	FRF_CZ_RX_MIN_KBUF_SIZE_WIDTH 14
+#define	FRF_CZ_RX_HDR_SPLIT_EN_LBN 71
+#define	FRF_CZ_RX_HDR_SPLIT_EN_WIDTH 1
+#define	FRF_CZ_RX_HDR_SPLIT_PLD_BUF_SIZE_LBN 62
+#define	FRF_CZ_RX_HDR_SPLIT_PLD_BUF_SIZE_WIDTH 9
+#define	FRF_CZ_RX_HDR_SPLIT_HDR_BUF_SIZE_LBN 53
+#define	FRF_CZ_RX_HDR_SPLIT_HDR_BUF_SIZE_WIDTH 9
+#define	FRF_CZ_RX_PRE_RFF_IPG_LBN 49
+#define	FRF_CZ_RX_PRE_RFF_IPG_WIDTH 4
+#define	FRF_BZ_RX_TCP_SUP_LBN 48
+#define	FRF_BZ_RX_TCP_SUP_WIDTH 1
+#define	FRF_BZ_RX_INGR_EN_LBN 47
+#define	FRF_BZ_RX_INGR_EN_WIDTH 1
+#define	FRF_BZ_RX_IP_HASH_LBN 46
+#define	FRF_BZ_RX_IP_HASH_WIDTH 1
+#define	FRF_BZ_RX_HASH_ALG_LBN 45
+#define	FRF_BZ_RX_HASH_ALG_WIDTH 1
+#define	FRF_BZ_RX_HASH_INSRT_HDR_LBN 44
+#define	FRF_BZ_RX_HASH_INSRT_HDR_WIDTH 1
+#define	FRF_BZ_RX_DESC_PUSH_EN_LBN 43
+#define	FRF_BZ_RX_DESC_PUSH_EN_WIDTH 1
+#define	FRF_BZ_RX_RDW_PATCH_EN_LBN 42
+#define	FRF_BZ_RX_RDW_PATCH_EN_WIDTH 1
+#define	FRF_BB_RX_PCI_BURST_SIZE_LBN 39
+#define	FRF_BB_RX_PCI_BURST_SIZE_WIDTH 3
+#define	FRF_BZ_RX_OWNERR_CTL_LBN 38
+#define	FRF_BZ_RX_OWNERR_CTL_WIDTH 1
+#define	FRF_BZ_RX_XON_TX_TH_LBN 33
+#define	FRF_BZ_RX_XON_TX_TH_WIDTH 5
+#define	FRF_AA_RX_DESC_PUSH_EN_LBN 35
+#define	FRF_AA_RX_DESC_PUSH_EN_WIDTH 1
+#define	FRF_AA_RX_RDW_PATCH_EN_LBN 34
+#define	FRF_AA_RX_RDW_PATCH_EN_WIDTH 1
+#define	FRF_AA_RX_PCI_BURST_SIZE_LBN 31
+#define	FRF_AA_RX_PCI_BURST_SIZE_WIDTH 3
+#define	FRF_BZ_RX_XOFF_TX_TH_LBN 28
+#define	FRF_BZ_RX_XOFF_TX_TH_WIDTH 5
+#define	FRF_AA_RX_OWNERR_CTL_LBN 30
+#define	FRF_AA_RX_OWNERR_CTL_WIDTH 1
+#define	FRF_AA_RX_XON_TX_TH_LBN 25
+#define	FRF_AA_RX_XON_TX_TH_WIDTH 5
+#define	FRF_BZ_RX_USR_BUF_SIZE_LBN 19
+#define	FRF_BZ_RX_USR_BUF_SIZE_WIDTH 9
+#define	FRF_AA_RX_XOFF_TX_TH_LBN 20
+#define	FRF_AA_RX_XOFF_TX_TH_WIDTH 5
+#define	FRF_AA_RX_USR_BUF_SIZE_LBN 11
+#define	FRF_AA_RX_USR_BUF_SIZE_WIDTH 9
+#define	FRF_BZ_RX_XON_MAC_TH_LBN 10
+#define	FRF_BZ_RX_XON_MAC_TH_WIDTH 9
+#define	FRF_AA_RX_XON_MAC_TH_LBN 6
+#define	FRF_AA_RX_XON_MAC_TH_WIDTH 5
+#define	FRF_BZ_RX_XOFF_MAC_TH_LBN 1
+#define	FRF_BZ_RX_XOFF_MAC_TH_WIDTH 9
+#define	FRF_AA_RX_XOFF_MAC_TH_LBN 1
+#define	FRF_AA_RX_XOFF_MAC_TH_WIDTH 5
+#define	FRF_AZ_RX_XOFF_MAC_EN_LBN 0
+#define	FRF_AZ_RX_XOFF_MAC_EN_WIDTH 1
+
+/* RX_FILTER_CTL_REG: Receive filter control registers */
+#define	FR_BZ_RX_FILTER_CTL 0x00000810
+#define	FRF_CZ_ETHERNET_WILDCARD_SEARCH_LIMIT_LBN 94
+#define	FRF_CZ_ETHERNET_WILDCARD_SEARCH_LIMIT_WIDTH 8
+#define	FRF_CZ_ETHERNET_FULL_SEARCH_LIMIT_LBN 86
+#define	FRF_CZ_ETHERNET_FULL_SEARCH_LIMIT_WIDTH 8
+#define	FRF_CZ_RX_FILTER_ALL_VLAN_ETHERTYPES_LBN 85
+#define	FRF_CZ_RX_FILTER_ALL_VLAN_ETHERTYPES_WIDTH 1
+#define	FRF_CZ_RX_VLAN_MATCH_ETHERTYPE_LBN 69
+#define	FRF_CZ_RX_VLAN_MATCH_ETHERTYPE_WIDTH 16
+#define	FRF_CZ_MULTICAST_NOMATCH_Q_ID_LBN 57
+#define	FRF_CZ_MULTICAST_NOMATCH_Q_ID_WIDTH 12
+#define	FRF_CZ_MULTICAST_NOMATCH_RSS_ENABLED_LBN 56
+#define	FRF_CZ_MULTICAST_NOMATCH_RSS_ENABLED_WIDTH 1
+#define	FRF_CZ_MULTICAST_NOMATCH_IP_OVERRIDE_LBN 55
+#define	FRF_CZ_MULTICAST_NOMATCH_IP_OVERRIDE_WIDTH 1
+#define	FRF_CZ_UNICAST_NOMATCH_Q_ID_LBN 43
+#define	FRF_CZ_UNICAST_NOMATCH_Q_ID_WIDTH 12
+#define	FRF_CZ_UNICAST_NOMATCH_RSS_ENABLED_LBN 42
+#define	FRF_CZ_UNICAST_NOMATCH_RSS_ENABLED_WIDTH 1
+#define	FRF_CZ_UNICAST_NOMATCH_IP_OVERRIDE_LBN 41
+#define	FRF_CZ_UNICAST_NOMATCH_IP_OVERRIDE_WIDTH 1
+#define	FRF_BZ_SCATTER_ENBL_NO_MATCH_Q_LBN 40
+#define	FRF_BZ_SCATTER_ENBL_NO_MATCH_Q_WIDTH 1
+#define	FRF_BZ_UDP_FULL_SRCH_LIMIT_LBN 32
+#define	FRF_BZ_UDP_FULL_SRCH_LIMIT_WIDTH 8
+#define	FRF_BZ_NUM_KER_LBN 24
+#define	FRF_BZ_NUM_KER_WIDTH 2
+#define	FRF_BZ_UDP_WILD_SRCH_LIMIT_LBN 16
+#define	FRF_BZ_UDP_WILD_SRCH_LIMIT_WIDTH 8
+#define	FRF_BZ_TCP_WILD_SRCH_LIMIT_LBN 8
+#define	FRF_BZ_TCP_WILD_SRCH_LIMIT_WIDTH 8
+#define	FRF_BZ_TCP_FULL_SRCH_LIMIT_LBN 0
+#define	FRF_BZ_TCP_FULL_SRCH_LIMIT_WIDTH 8
+
+/* RX_FLUSH_DESCQ_REG: Receive flush descriptor queue register */
+#define	FR_AZ_RX_FLUSH_DESCQ 0x00000820
+#define	FRF_AZ_RX_FLUSH_DESCQ_CMD_LBN 24
+#define	FRF_AZ_RX_FLUSH_DESCQ_CMD_WIDTH 1
+#define	FRF_AZ_RX_FLUSH_DESCQ_LBN 0
+#define	FRF_AZ_RX_FLUSH_DESCQ_WIDTH 12
+
+/* RX_DESC_UPD_REGP0: Receive descriptor update register. */
+#define	FR_BZ_RX_DESC_UPD_P0 0x00000830
+#define	FR_BZ_RX_DESC_UPD_P0_STEP 8192
+#define	FR_BZ_RX_DESC_UPD_P0_ROWS 1024
+/* RX_DESC_UPD_REG_KER: Receive descriptor update register. */
+#define	FR_AA_RX_DESC_UPD_KER 0x00000830
+#define	FR_AA_RX_DESC_UPD_KER_STEP 8192
+#define	FR_AA_RX_DESC_UPD_KER_ROWS 4
+/* RX_DESC_UPD_REGP123: Receive descriptor update register. */
+#define	FR_BB_RX_DESC_UPD_P123 0x01000830
+#define	FR_BB_RX_DESC_UPD_P123_STEP 8192
+#define	FR_BB_RX_DESC_UPD_P123_ROWS 3072
+#define	FRF_AZ_RX_DESC_WPTR_LBN 96
+#define	FRF_AZ_RX_DESC_WPTR_WIDTH 12
+#define	FRF_AZ_RX_DESC_PUSH_CMD_LBN 95
+#define	FRF_AZ_RX_DESC_PUSH_CMD_WIDTH 1
+#define	FRF_AZ_RX_DESC_LBN 0
+#define	FRF_AZ_RX_DESC_WIDTH 64
+
+/* RX_DC_CFG_REG: Receive descriptor cache configuration register */
+#define	FR_AZ_RX_DC_CFG 0x00000840
+#define	FRF_AB_RX_MAX_PF_LBN 2
+#define	FRF_AB_RX_MAX_PF_WIDTH 2
+#define	FRF_AZ_RX_DC_SIZE_LBN 0
+#define	FRF_AZ_RX_DC_SIZE_WIDTH 2
+#define	FFE_AZ_RX_DC_SIZE_64 3
+#define	FFE_AZ_RX_DC_SIZE_32 2
+#define	FFE_AZ_RX_DC_SIZE_16 1
+#define	FFE_AZ_RX_DC_SIZE_8 0
+
+/* RX_DC_PF_WM_REG: Receive descriptor cache pre-fetch watermark register */
+#define	FR_AZ_RX_DC_PF_WM 0x00000850
+#define	FRF_AZ_RX_DC_PF_HWM_LBN 6
+#define	FRF_AZ_RX_DC_PF_HWM_WIDTH 6
+#define	FRF_AZ_RX_DC_PF_LWM_LBN 0
+#define	FRF_AZ_RX_DC_PF_LWM_WIDTH 6
+
+/* RX_RSS_TKEY_REG: RSS Toeplitz hash key */
+#define	FR_BZ_RX_RSS_TKEY 0x00000860
+#define	FRF_BZ_RX_RSS_TKEY_HI_LBN 64
+#define	FRF_BZ_RX_RSS_TKEY_HI_WIDTH 64
+#define	FRF_BZ_RX_RSS_TKEY_LO_LBN 0
+#define	FRF_BZ_RX_RSS_TKEY_LO_WIDTH 64
+
+/* RX_NODESC_DROP_REG: Receive dropped packet counter register */
+#define	FR_AZ_RX_NODESC_DROP 0x00000880
+#define	FRF_CZ_RX_NODESC_DROP_CNT_LBN 0
+#define	FRF_CZ_RX_NODESC_DROP_CNT_WIDTH 32
+#define	FRF_AB_RX_NODESC_DROP_CNT_LBN 0
+#define	FRF_AB_RX_NODESC_DROP_CNT_WIDTH 16
+
+/* RX_SELF_RST_REG: Receive self reset register */
+#define	FR_AA_RX_SELF_RST 0x00000890
+#define	FRF_AA_RX_ISCSI_DIS_LBN 17
+#define	FRF_AA_RX_ISCSI_DIS_WIDTH 1
+#define	FRF_AA_RX_SW_RST_REG_LBN 16
+#define	FRF_AA_RX_SW_RST_REG_WIDTH 1
+#define FRF_AA_RX_NODESC_WAIT_DIS_LBN 9
+#define FRF_AA_RX_NODESC_WAIT_DIS_WIDTH 1
+#define	FRF_AA_RX_SELF_RST_EN_LBN 8
+#define	FRF_AA_RX_SELF_RST_EN_WIDTH 1
+#define	FRF_AA_RX_MAX_PF_LAT_LBN 4
+#define	FRF_AA_RX_MAX_PF_LAT_WIDTH 4
+#define	FRF_AA_RX_MAX_LU_LAT_LBN 0
+#define	FRF_AA_RX_MAX_LU_LAT_WIDTH 4
+
+/* RX_DEBUG_REG: undocumented register */
+#define	FR_AZ_RX_DEBUG 0x000008a0
+#define	FRF_AZ_RX_DEBUG_LBN 0
+#define	FRF_AZ_RX_DEBUG_WIDTH 64
+
+/* RX_PUSH_DROP_REG: Receive descriptor push dropped counter register */
+#define	FR_AZ_RX_PUSH_DROP 0x000008b0
+#define	FRF_AZ_RX_PUSH_DROP_CNT_LBN 0
+#define	FRF_AZ_RX_PUSH_DROP_CNT_WIDTH 32
+
+/* RX_RSS_IPV6_REG1: IPv6 RSS Toeplitz hash key low bytes */
+#define	FR_CZ_RX_RSS_IPV6_REG1 0x000008d0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_LO_LBN 0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_LO_WIDTH 128
+
+/* RX_RSS_IPV6_REG2: IPv6 RSS Toeplitz hash key middle bytes */
+#define	FR_CZ_RX_RSS_IPV6_REG2 0x000008e0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_MID_LBN 0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_MID_WIDTH 128
+
+/* RX_RSS_IPV6_REG3: IPv6 RSS Toeplitz hash key upper bytes and IPv6 RSS settings */
+#define	FR_CZ_RX_RSS_IPV6_REG3 0x000008f0
+#define	FRF_CZ_RX_RSS_IPV6_THASH_ENABLE_LBN 66
+#define	FRF_CZ_RX_RSS_IPV6_THASH_ENABLE_WIDTH 1
+#define	FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE_LBN 65
+#define	FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE_WIDTH 1
+#define	FRF_CZ_RX_RSS_IPV6_TCP_SUPPRESS_LBN 64
+#define	FRF_CZ_RX_RSS_IPV6_TCP_SUPPRESS_WIDTH 1
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_HI_LBN 0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH 64
+
+/* TX_FLUSH_DESCQ_REG: Transmit flush descriptor queue register */
+#define	FR_AZ_TX_FLUSH_DESCQ 0x00000a00
+#define	FRF_AZ_TX_FLUSH_DESCQ_CMD_LBN 12
+#define	FRF_AZ_TX_FLUSH_DESCQ_CMD_WIDTH 1
+#define	FRF_AZ_TX_FLUSH_DESCQ_LBN 0
+#define	FRF_AZ_TX_FLUSH_DESCQ_WIDTH 12
+
+/* TX_DESC_UPD_REGP0: Transmit descriptor update register. */
+#define	FR_BZ_TX_DESC_UPD_P0 0x00000a10
+#define	FR_BZ_TX_DESC_UPD_P0_STEP 8192
+#define	FR_BZ_TX_DESC_UPD_P0_ROWS 1024
+/* TX_DESC_UPD_REG_KER: Transmit descriptor update register. */
+#define	FR_AA_TX_DESC_UPD_KER 0x00000a10
+#define	FR_AA_TX_DESC_UPD_KER_STEP 8192
+#define	FR_AA_TX_DESC_UPD_KER_ROWS 8
+/* TX_DESC_UPD_REGP123: Transmit descriptor update register. */
+#define	FR_BB_TX_DESC_UPD_P123 0x01000a10
+#define	FR_BB_TX_DESC_UPD_P123_STEP 8192
+#define	FR_BB_TX_DESC_UPD_P123_ROWS 3072
+#define	FRF_AZ_TX_DESC_WPTR_LBN 96
+#define	FRF_AZ_TX_DESC_WPTR_WIDTH 12
+#define	FRF_AZ_TX_DESC_PUSH_CMD_LBN 95
+#define	FRF_AZ_TX_DESC_PUSH_CMD_WIDTH 1
+#define	FRF_AZ_TX_DESC_LBN 0
+#define	FRF_AZ_TX_DESC_WIDTH 95
+
+/* TX_DC_CFG_REG: Transmit descriptor cache configuration register */
+#define	FR_AZ_TX_DC_CFG 0x00000a20
+#define	FRF_AZ_TX_DC_SIZE_LBN 0
+#define	FRF_AZ_TX_DC_SIZE_WIDTH 2
+#define	FFE_AZ_TX_DC_SIZE_32 2
+#define	FFE_AZ_TX_DC_SIZE_16 1
+#define	FFE_AZ_TX_DC_SIZE_8 0
+
+/* TX_CHKSM_CFG_REG: Transmit checksum configuration register */
+#define	FR_AA_TX_CHKSM_CFG 0x00000a30
+#define	FRF_AA_TX_Q_CHKSM_DIS_96_127_LBN 96
+#define	FRF_AA_TX_Q_CHKSM_DIS_96_127_WIDTH 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_64_95_LBN 64
+#define	FRF_AA_TX_Q_CHKSM_DIS_64_95_WIDTH 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_32_63_LBN 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_32_63_WIDTH 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_0_31_LBN 0
+#define	FRF_AA_TX_Q_CHKSM_DIS_0_31_WIDTH 32
+
+/* TX_CFG_REG: Transmit configuration register */
+#define	FR_AZ_TX_CFG 0x00000a50
+#define	FRF_CZ_TX_CONT_LOOKUP_THRESH_RANGE_LBN 114
+#define	FRF_CZ_TX_CONT_LOOKUP_THRESH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_FILTER_TEST_MODE_BIT_LBN 113
+#define	FRF_CZ_TX_FILTER_TEST_MODE_BIT_WIDTH 1
+#define	FRF_CZ_TX_ETH_FILTER_WILD_SEARCH_RANGE_LBN 105
+#define	FRF_CZ_TX_ETH_FILTER_WILD_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_ETH_FILTER_FULL_SEARCH_RANGE_LBN 97
+#define	FRF_CZ_TX_ETH_FILTER_FULL_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_UDPIP_FILTER_WILD_SEARCH_RANGE_LBN 89
+#define	FRF_CZ_TX_UDPIP_FILTER_WILD_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_UDPIP_FILTER_FULL_SEARCH_RANGE_LBN 81
+#define	FRF_CZ_TX_UDPIP_FILTER_FULL_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_TCPIP_FILTER_WILD_SEARCH_RANGE_LBN 73
+#define	FRF_CZ_TX_TCPIP_FILTER_WILD_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_TCPIP_FILTER_FULL_SEARCH_RANGE_LBN 65
+#define	FRF_CZ_TX_TCPIP_FILTER_FULL_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_FILTER_ALL_VLAN_ETHERTYPES_BIT_LBN 64
+#define	FRF_CZ_TX_FILTER_ALL_VLAN_ETHERTYPES_BIT_WIDTH 1
+#define	FRF_CZ_TX_VLAN_MATCH_ETHERTYPE_RANGE_LBN 48
+#define	FRF_CZ_TX_VLAN_MATCH_ETHERTYPE_RANGE_WIDTH 16
+#define	FRF_CZ_TX_FILTER_EN_BIT_LBN 47
+#define	FRF_CZ_TX_FILTER_EN_BIT_WIDTH 1
+#define	FRF_AZ_TX_IP_ID_P0_OFS_LBN 16
+#define	FRF_AZ_TX_IP_ID_P0_OFS_WIDTH 15
+#define	FRF_AZ_TX_NO_EOP_DISC_EN_LBN 5
+#define	FRF_AZ_TX_NO_EOP_DISC_EN_WIDTH 1
+#define	FRF_AZ_TX_P1_PRI_EN_LBN 4
+#define	FRF_AZ_TX_P1_PRI_EN_WIDTH 1
+#define	FRF_AZ_TX_OWNERR_CTL_LBN 2
+#define	FRF_AZ_TX_OWNERR_CTL_WIDTH 1
+#define	FRF_AA_TX_NON_IP_DROP_DIS_LBN 1
+#define	FRF_AA_TX_NON_IP_DROP_DIS_WIDTH 1
+#define	FRF_AZ_TX_IP_ID_REP_EN_LBN 0
+#define	FRF_AZ_TX_IP_ID_REP_EN_WIDTH 1
+
+/* TX_PUSH_DROP_REG: Transmit push dropped register */
+#define	FR_AZ_TX_PUSH_DROP 0x00000a60
+#define	FRF_AZ_TX_PUSH_DROP_CNT_LBN 0
+#define	FRF_AZ_TX_PUSH_DROP_CNT_WIDTH 32
+
+/* TX_RESERVED_REG: Transmit configuration register */
+#define	FR_AZ_TX_RESERVED 0x00000a80
+#define	FRF_AZ_TX_EVT_CNT_LBN 121
+#define	FRF_AZ_TX_EVT_CNT_WIDTH 7
+#define	FRF_AZ_TX_PREF_AGE_CNT_LBN 119
+#define	FRF_AZ_TX_PREF_AGE_CNT_WIDTH 2
+#define	FRF_AZ_TX_RD_COMP_TMR_LBN 96
+#define	FRF_AZ_TX_RD_COMP_TMR_WIDTH 23
+#define	FRF_AZ_TX_PUSH_EN_LBN 89
+#define	FRF_AZ_TX_PUSH_EN_WIDTH 1
+#define	FRF_AZ_TX_PUSH_CHK_DIS_LBN 88
+#define	FRF_AZ_TX_PUSH_CHK_DIS_WIDTH 1
+#define	FRF_AZ_TX_D_FF_FULL_P0_LBN 85
+#define	FRF_AZ_TX_D_FF_FULL_P0_WIDTH 1
+#define	FRF_AZ_TX_DMAR_ST_P0_LBN 81
+#define	FRF_AZ_TX_DMAR_ST_P0_WIDTH 1
+#define	FRF_AZ_TX_DMAQ_ST_LBN 78
+#define	FRF_AZ_TX_DMAQ_ST_WIDTH 1
+#define	FRF_AZ_TX_RX_SPACER_LBN 64
+#define	FRF_AZ_TX_RX_SPACER_WIDTH 8
+#define	FRF_AZ_TX_DROP_ABORT_EN_LBN 60
+#define	FRF_AZ_TX_DROP_ABORT_EN_WIDTH 1
+#define	FRF_AZ_TX_SOFT_EVT_EN_LBN 59
+#define	FRF_AZ_TX_SOFT_EVT_EN_WIDTH 1
+#define	FRF_AZ_TX_PS_EVT_DIS_LBN 58
+#define	FRF_AZ_TX_PS_EVT_DIS_WIDTH 1
+#define	FRF_AZ_TX_RX_SPACER_EN_LBN 57
+#define	FRF_AZ_TX_RX_SPACER_EN_WIDTH 1
+#define	FRF_AZ_TX_XP_TIMER_LBN 52
+#define	FRF_AZ_TX_XP_TIMER_WIDTH 5
+#define	FRF_AZ_TX_PREF_SPACER_LBN 44
+#define	FRF_AZ_TX_PREF_SPACER_WIDTH 8
+#define	FRF_AZ_TX_PREF_WD_TMR_LBN 22
+#define	FRF_AZ_TX_PREF_WD_TMR_WIDTH 22
+#define	FRF_AZ_TX_ONLY1TAG_LBN 21
+#define	FRF_AZ_TX_ONLY1TAG_WIDTH 1
+#define	FRF_AZ_TX_PREF_THRESHOLD_LBN 19
+#define	FRF_AZ_TX_PREF_THRESHOLD_WIDTH 2
+#define	FRF_AZ_TX_ONE_PKT_PER_Q_LBN 18
+#define	FRF_AZ_TX_ONE_PKT_PER_Q_WIDTH 1
+#define	FRF_AZ_TX_DIS_NON_IP_EV_LBN 17
+#define	FRF_AZ_TX_DIS_NON_IP_EV_WIDTH 1
+#define	FRF_AA_TX_DMA_FF_THR_LBN 16
+#define	FRF_AA_TX_DMA_FF_THR_WIDTH 1
+#define	FRF_AZ_TX_DMA_SPACER_LBN 8
+#define	FRF_AZ_TX_DMA_SPACER_WIDTH 8
+#define	FRF_AA_TX_TCP_DIS_LBN 7
+#define	FRF_AA_TX_TCP_DIS_WIDTH 1
+#define	FRF_BZ_TX_FLUSH_MIN_LEN_EN_LBN 7
+#define	FRF_BZ_TX_FLUSH_MIN_LEN_EN_WIDTH 1
+#define	FRF_AA_TX_IP_DIS_LBN 6
+#define	FRF_AA_TX_IP_DIS_WIDTH 1
+#define	FRF_AZ_TX_MAX_CPL_LBN 2
+#define	FRF_AZ_TX_MAX_CPL_WIDTH 2
+#define	FFE_AZ_TX_MAX_CPL_16 3
+#define	FFE_AZ_TX_MAX_CPL_8 2
+#define	FFE_AZ_TX_MAX_CPL_4 1
+#define	FFE_AZ_TX_MAX_CPL_NOLIMIT 0
+#define	FRF_AZ_TX_MAX_PREF_LBN 0
+#define	FRF_AZ_TX_MAX_PREF_WIDTH 2
+#define	FFE_AZ_TX_MAX_PREF_32 3
+#define	FFE_AZ_TX_MAX_PREF_16 2
+#define	FFE_AZ_TX_MAX_PREF_8 1
+#define	FFE_AZ_TX_MAX_PREF_OFF 0
+
+/* TX_PACE_REG: Transmit pace control register */
+#define	FR_BZ_TX_PACE 0x00000a90
+#define	FRF_BZ_TX_PACE_SB_NOT_AF_LBN 19
+#define	FRF_BZ_TX_PACE_SB_NOT_AF_WIDTH 10
+#define	FRF_BZ_TX_PACE_SB_AF_LBN 9
+#define	FRF_BZ_TX_PACE_SB_AF_WIDTH 10
+#define	FRF_BZ_TX_PACE_FB_BASE_LBN 5
+#define	FRF_BZ_TX_PACE_FB_BASE_WIDTH 4
+#define	FRF_BZ_TX_PACE_BIN_TH_LBN 0
+#define	FRF_BZ_TX_PACE_BIN_TH_WIDTH 5
+
+/* TX_PACE_DROP_QID_REG: PACE Drop QID Counter */
+#define	FR_BZ_TX_PACE_DROP_QID 0x00000aa0
+#define	FRF_BZ_TX_PACE_QID_DRP_CNT_LBN 0
+#define	FRF_BZ_TX_PACE_QID_DRP_CNT_WIDTH 16
+
+/* TX_VLAN_REG: Transmit VLAN tag register */
+#define	FR_BB_TX_VLAN 0x00000ae0
+#define	FRF_BB_TX_VLAN_EN_LBN 127
+#define	FRF_BB_TX_VLAN_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN7_PORT1_EN_LBN 125
+#define	FRF_BB_TX_VLAN7_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN7_PORT0_EN_LBN 124
+#define	FRF_BB_TX_VLAN7_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN7_LBN 112
+#define	FRF_BB_TX_VLAN7_WIDTH 12
+#define	FRF_BB_TX_VLAN6_PORT1_EN_LBN 109
+#define	FRF_BB_TX_VLAN6_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN6_PORT0_EN_LBN 108
+#define	FRF_BB_TX_VLAN6_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN6_LBN 96
+#define	FRF_BB_TX_VLAN6_WIDTH 12
+#define	FRF_BB_TX_VLAN5_PORT1_EN_LBN 93
+#define	FRF_BB_TX_VLAN5_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN5_PORT0_EN_LBN 92
+#define	FRF_BB_TX_VLAN5_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN5_LBN 80
+#define	FRF_BB_TX_VLAN5_WIDTH 12
+#define	FRF_BB_TX_VLAN4_PORT1_EN_LBN 77
+#define	FRF_BB_TX_VLAN4_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN4_PORT0_EN_LBN 76
+#define	FRF_BB_TX_VLAN4_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN4_LBN 64
+#define	FRF_BB_TX_VLAN4_WIDTH 12
+#define	FRF_BB_TX_VLAN3_PORT1_EN_LBN 61
+#define	FRF_BB_TX_VLAN3_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN3_PORT0_EN_LBN 60
+#define	FRF_BB_TX_VLAN3_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN3_LBN 48
+#define	FRF_BB_TX_VLAN3_WIDTH 12
+#define	FRF_BB_TX_VLAN2_PORT1_EN_LBN 45
+#define	FRF_BB_TX_VLAN2_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN2_PORT0_EN_LBN 44
+#define	FRF_BB_TX_VLAN2_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN2_LBN 32
+#define	FRF_BB_TX_VLAN2_WIDTH 12
+#define	FRF_BB_TX_VLAN1_PORT1_EN_LBN 29
+#define	FRF_BB_TX_VLAN1_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN1_PORT0_EN_LBN 28
+#define	FRF_BB_TX_VLAN1_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN1_LBN 16
+#define	FRF_BB_TX_VLAN1_WIDTH 12
+#define	FRF_BB_TX_VLAN0_PORT1_EN_LBN 13
+#define	FRF_BB_TX_VLAN0_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN0_PORT0_EN_LBN 12
+#define	FRF_BB_TX_VLAN0_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN0_LBN 0
+#define	FRF_BB_TX_VLAN0_WIDTH 12
+
+/* TX_IPFIL_PORTEN_REG: Transmit filter control register */
+#define	FR_BZ_TX_IPFIL_PORTEN 0x00000af0
+#define	FRF_BZ_TX_MADR0_FIL_EN_LBN 64
+#define	FRF_BZ_TX_MADR0_FIL_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL31_PORT_EN_LBN 62
+#define	FRF_BB_TX_IPFIL31_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL30_PORT_EN_LBN 60
+#define	FRF_BB_TX_IPFIL30_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL29_PORT_EN_LBN 58
+#define	FRF_BB_TX_IPFIL29_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL28_PORT_EN_LBN 56
+#define	FRF_BB_TX_IPFIL28_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL27_PORT_EN_LBN 54
+#define	FRF_BB_TX_IPFIL27_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL26_PORT_EN_LBN 52
+#define	FRF_BB_TX_IPFIL26_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL25_PORT_EN_LBN 50
+#define	FRF_BB_TX_IPFIL25_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL24_PORT_EN_LBN 48
+#define	FRF_BB_TX_IPFIL24_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL23_PORT_EN_LBN 46
+#define	FRF_BB_TX_IPFIL23_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL22_PORT_EN_LBN 44
+#define	FRF_BB_TX_IPFIL22_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL21_PORT_EN_LBN 42
+#define	FRF_BB_TX_IPFIL21_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL20_PORT_EN_LBN 40
+#define	FRF_BB_TX_IPFIL20_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL19_PORT_EN_LBN 38
+#define	FRF_BB_TX_IPFIL19_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL18_PORT_EN_LBN 36
+#define	FRF_BB_TX_IPFIL18_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL17_PORT_EN_LBN 34
+#define	FRF_BB_TX_IPFIL17_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL16_PORT_EN_LBN 32
+#define	FRF_BB_TX_IPFIL16_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL15_PORT_EN_LBN 30
+#define	FRF_BB_TX_IPFIL15_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL14_PORT_EN_LBN 28
+#define	FRF_BB_TX_IPFIL14_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL13_PORT_EN_LBN 26
+#define	FRF_BB_TX_IPFIL13_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL12_PORT_EN_LBN 24
+#define	FRF_BB_TX_IPFIL12_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL11_PORT_EN_LBN 22
+#define	FRF_BB_TX_IPFIL11_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL10_PORT_EN_LBN 20
+#define	FRF_BB_TX_IPFIL10_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL9_PORT_EN_LBN 18
+#define	FRF_BB_TX_IPFIL9_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL8_PORT_EN_LBN 16
+#define	FRF_BB_TX_IPFIL8_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL7_PORT_EN_LBN 14
+#define	FRF_BB_TX_IPFIL7_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL6_PORT_EN_LBN 12
+#define	FRF_BB_TX_IPFIL6_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL5_PORT_EN_LBN 10
+#define	FRF_BB_TX_IPFIL5_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL4_PORT_EN_LBN 8
+#define	FRF_BB_TX_IPFIL4_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL3_PORT_EN_LBN 6
+#define	FRF_BB_TX_IPFIL3_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL2_PORT_EN_LBN 4
+#define	FRF_BB_TX_IPFIL2_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL1_PORT_EN_LBN 2
+#define	FRF_BB_TX_IPFIL1_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL0_PORT_EN_LBN 0
+#define	FRF_BB_TX_IPFIL0_PORT_EN_WIDTH 1
+
+/* TX_IPFIL_TBL: Transmit IP source address filter table */
+#define	FR_BB_TX_IPFIL_TBL 0x00000b00
+#define	FR_BB_TX_IPFIL_TBL_STEP 16
+#define	FR_BB_TX_IPFIL_TBL_ROWS 16
+#define	FRF_BB_TX_IPFIL_MASK_1_LBN 96
+#define	FRF_BB_TX_IPFIL_MASK_1_WIDTH 32
+#define	FRF_BB_TX_IP_SRC_ADR_1_LBN 64
+#define	FRF_BB_TX_IP_SRC_ADR_1_WIDTH 32
+#define	FRF_BB_TX_IPFIL_MASK_0_LBN 32
+#define	FRF_BB_TX_IPFIL_MASK_0_WIDTH 32
+#define	FRF_BB_TX_IP_SRC_ADR_0_LBN 0
+#define	FRF_BB_TX_IP_SRC_ADR_0_WIDTH 32
+
+/* MD_TXD_REG: PHY management transmit data register */
+#define	FR_AB_MD_TXD 0x00000c00
+#define	FRF_AB_MD_TXD_LBN 0
+#define	FRF_AB_MD_TXD_WIDTH 16
+
+/* MD_RXD_REG: PHY management receive data register */
+#define	FR_AB_MD_RXD 0x00000c10
+#define	FRF_AB_MD_RXD_LBN 0
+#define	FRF_AB_MD_RXD_WIDTH 16
+
+/* MD_CS_REG: PHY management configuration & status register */
+#define	FR_AB_MD_CS 0x00000c20
+#define	FRF_AB_MD_RD_EN_CMD_LBN 15
+#define	FRF_AB_MD_RD_EN_CMD_WIDTH 1
+#define	FRF_AB_MD_WR_EN_CMD_LBN 14
+#define	FRF_AB_MD_WR_EN_CMD_WIDTH 1
+#define	FRF_AB_MD_ADDR_CMD_LBN 13
+#define	FRF_AB_MD_ADDR_CMD_WIDTH 1
+#define	FRF_AB_MD_PT_LBN 7
+#define	FRF_AB_MD_PT_WIDTH 3
+#define	FRF_AB_MD_PL_LBN 6
+#define	FRF_AB_MD_PL_WIDTH 1
+#define	FRF_AB_MD_INT_CLR_LBN 5
+#define	FRF_AB_MD_INT_CLR_WIDTH 1
+#define	FRF_AB_MD_GC_LBN 4
+#define	FRF_AB_MD_GC_WIDTH 1
+#define	FRF_AB_MD_PRSP_LBN 3
+#define	FRF_AB_MD_PRSP_WIDTH 1
+#define	FRF_AB_MD_RIC_LBN 2
+#define	FRF_AB_MD_RIC_WIDTH 1
+#define	FRF_AB_MD_RDC_LBN 1
+#define	FRF_AB_MD_RDC_WIDTH 1
+#define	FRF_AB_MD_WRC_LBN 0
+#define	FRF_AB_MD_WRC_WIDTH 1
+
+/* MD_PHY_ADR_REG: PHY management PHY address register */
+#define	FR_AB_MD_PHY_ADR 0x00000c30
+#define	FRF_AB_MD_PHY_ADR_LBN 0
+#define	FRF_AB_MD_PHY_ADR_WIDTH 16
+
+/* MD_ID_REG: PHY management ID register */
+#define	FR_AB_MD_ID 0x00000c40
+#define	FRF_AB_MD_PRT_ADR_LBN 11
+#define	FRF_AB_MD_PRT_ADR_WIDTH 5
+#define	FRF_AB_MD_DEV_ADR_LBN 6
+#define	FRF_AB_MD_DEV_ADR_WIDTH 5
+
+/* MD_STAT_REG: PHY management status & mask register */
+#define	FR_AB_MD_STAT 0x00000c50
+#define	FRF_AB_MD_PINT_LBN 4
+#define	FRF_AB_MD_PINT_WIDTH 1
+#define	FRF_AB_MD_DONE_LBN 3
+#define	FRF_AB_MD_DONE_WIDTH 1
+#define	FRF_AB_MD_BSERR_LBN 2
+#define	FRF_AB_MD_BSERR_WIDTH 1
+#define	FRF_AB_MD_LNFL_LBN 1
+#define	FRF_AB_MD_LNFL_WIDTH 1
+#define	FRF_AB_MD_BSY_LBN 0
+#define	FRF_AB_MD_BSY_WIDTH 1
+
+/* MAC_STAT_DMA_REG: Port MAC statistical counter DMA register */
+#define	FR_AB_MAC_STAT_DMA 0x00000c60
+#define	FRF_AB_MAC_STAT_DMA_CMD_LBN 48
+#define	FRF_AB_MAC_STAT_DMA_CMD_WIDTH 1
+#define	FRF_AB_MAC_STAT_DMA_ADR_LBN 0
+#define	FRF_AB_MAC_STAT_DMA_ADR_WIDTH 48
+
+/* MAC_CTRL_REG: Port MAC control register */
+#define	FR_AB_MAC_CTRL 0x00000c80
+#define	FRF_AB_MAC_XOFF_VAL_LBN 16
+#define	FRF_AB_MAC_XOFF_VAL_WIDTH 16
+#define	FRF_BB_TXFIFO_DRAIN_EN_LBN 7
+#define	FRF_BB_TXFIFO_DRAIN_EN_WIDTH 1
+#define	FRF_AB_MAC_XG_DISTXCRC_LBN 5
+#define	FRF_AB_MAC_XG_DISTXCRC_WIDTH 1
+#define	FRF_AB_MAC_BCAD_ACPT_LBN 4
+#define	FRF_AB_MAC_BCAD_ACPT_WIDTH 1
+#define	FRF_AB_MAC_UC_PROM_LBN 3
+#define	FRF_AB_MAC_UC_PROM_WIDTH 1
+#define	FRF_AB_MAC_LINK_STATUS_LBN 2
+#define	FRF_AB_MAC_LINK_STATUS_WIDTH 1
+#define	FRF_AB_MAC_SPEED_LBN 0
+#define	FRF_AB_MAC_SPEED_WIDTH 2
+#define	FFE_AB_MAC_SPEED_10G 3
+#define	FFE_AB_MAC_SPEED_1G 2
+#define	FFE_AB_MAC_SPEED_100M 1
+#define	FFE_AB_MAC_SPEED_10M 0
+
+/* GEN_MODE_REG: General Purpose mode register (external interrupt mask) */
+#define	FR_BB_GEN_MODE 0x00000c90
+#define	FRF_BB_XFP_PHY_INT_POL_SEL_LBN 3
+#define	FRF_BB_XFP_PHY_INT_POL_SEL_WIDTH 1
+#define	FRF_BB_XG_PHY_INT_POL_SEL_LBN 2
+#define	FRF_BB_XG_PHY_INT_POL_SEL_WIDTH 1
+#define	FRF_BB_XFP_PHY_INT_MASK_LBN 1
+#define	FRF_BB_XFP_PHY_INT_MASK_WIDTH 1
+#define	FRF_BB_XG_PHY_INT_MASK_LBN 0
+#define	FRF_BB_XG_PHY_INT_MASK_WIDTH 1
+
+/* MAC_MC_HASH_REG0: Multicast address hash table */
+#define	FR_AB_MAC_MC_HASH_REG0 0x00000ca0
+#define	FRF_AB_MAC_MCAST_HASH0_LBN 0
+#define	FRF_AB_MAC_MCAST_HASH0_WIDTH 128
+
+/* MAC_MC_HASH_REG1: Multicast address hash table */
+#define	FR_AB_MAC_MC_HASH_REG1 0x00000cb0
+#define	FRF_AB_MAC_MCAST_HASH1_LBN 0
+#define	FRF_AB_MAC_MCAST_HASH1_WIDTH 128
+
+/* GM_CFG1_REG: GMAC configuration register 1 */
+#define	FR_AB_GM_CFG1 0x00000e00
+#define	FRF_AB_GM_SW_RST_LBN 31
+#define	FRF_AB_GM_SW_RST_WIDTH 1
+#define	FRF_AB_GM_SIM_RST_LBN 30
+#define	FRF_AB_GM_SIM_RST_WIDTH 1
+#define	FRF_AB_GM_RST_RX_MAC_CTL_LBN 19
+#define	FRF_AB_GM_RST_RX_MAC_CTL_WIDTH 1
+#define	FRF_AB_GM_RST_TX_MAC_CTL_LBN 18
+#define	FRF_AB_GM_RST_TX_MAC_CTL_WIDTH 1
+#define	FRF_AB_GM_RST_RX_FUNC_LBN 17
+#define	FRF_AB_GM_RST_RX_FUNC_WIDTH 1
+#define	FRF_AB_GM_RST_TX_FUNC_LBN 16
+#define	FRF_AB_GM_RST_TX_FUNC_WIDTH 1
+#define	FRF_AB_GM_LOOP_LBN 8
+#define	FRF_AB_GM_LOOP_WIDTH 1
+#define	FRF_AB_GM_RX_FC_EN_LBN 5
+#define	FRF_AB_GM_RX_FC_EN_WIDTH 1
+#define	FRF_AB_GM_TX_FC_EN_LBN 4
+#define	FRF_AB_GM_TX_FC_EN_WIDTH 1
+#define	FRF_AB_GM_SYNC_RXEN_LBN 3
+#define	FRF_AB_GM_SYNC_RXEN_WIDTH 1
+#define	FRF_AB_GM_RX_EN_LBN 2
+#define	FRF_AB_GM_RX_EN_WIDTH 1
+#define	FRF_AB_GM_SYNC_TXEN_LBN 1
+#define	FRF_AB_GM_SYNC_TXEN_WIDTH 1
+#define	FRF_AB_GM_TX_EN_LBN 0
+#define	FRF_AB_GM_TX_EN_WIDTH 1
+
+/* GM_CFG2_REG: GMAC configuration register 2 */
+#define	FR_AB_GM_CFG2 0x00000e10
+#define	FRF_AB_GM_PAMBL_LEN_LBN 12
+#define	FRF_AB_GM_PAMBL_LEN_WIDTH 4
+#define	FRF_AB_GM_IF_MODE_LBN 8
+#define	FRF_AB_GM_IF_MODE_WIDTH 2
+#define	FFE_AB_IF_MODE_BYTE_MODE 2
+#define	FFE_AB_IF_MODE_NIBBLE_MODE 1
+#define	FRF_AB_GM_HUGE_FRM_EN_LBN 5
+#define	FRF_AB_GM_HUGE_FRM_EN_WIDTH 1
+#define	FRF_AB_GM_LEN_CHK_LBN 4
+#define	FRF_AB_GM_LEN_CHK_WIDTH 1
+#define	FRF_AB_GM_PAD_CRC_EN_LBN 2
+#define	FRF_AB_GM_PAD_CRC_EN_WIDTH 1
+#define	FRF_AB_GM_CRC_EN_LBN 1
+#define	FRF_AB_GM_CRC_EN_WIDTH 1
+#define	FRF_AB_GM_FD_LBN 0
+#define	FRF_AB_GM_FD_WIDTH 1
+
+/* GM_IPG_REG: GMAC IPG register */
+#define	FR_AB_GM_IPG 0x00000e20
+#define	FRF_AB_GM_NONB2B_IPG1_LBN 24
+#define	FRF_AB_GM_NONB2B_IPG1_WIDTH 7
+#define	FRF_AB_GM_NONB2B_IPG2_LBN 16
+#define	FRF_AB_GM_NONB2B_IPG2_WIDTH 7
+#define	FRF_AB_GM_MIN_IPG_ENF_LBN 8
+#define	FRF_AB_GM_MIN_IPG_ENF_WIDTH 8
+#define	FRF_AB_GM_B2B_IPG_LBN 0
+#define	FRF_AB_GM_B2B_IPG_WIDTH 7
+
+/* GM_HD_REG: GMAC half duplex register */
+#define	FR_AB_GM_HD 0x00000e30
+#define	FRF_AB_GM_ALT_BOFF_VAL_LBN 20
+#define	FRF_AB_GM_ALT_BOFF_VAL_WIDTH 4
+#define	FRF_AB_GM_ALT_BOFF_EN_LBN 19
+#define	FRF_AB_GM_ALT_BOFF_EN_WIDTH 1
+#define	FRF_AB_GM_BP_NO_BOFF_LBN 18
+#define	FRF_AB_GM_BP_NO_BOFF_WIDTH 1
+#define	FRF_AB_GM_DIS_BOFF_LBN 17
+#define	FRF_AB_GM_DIS_BOFF_WIDTH 1
+#define	FRF_AB_GM_EXDEF_TX_EN_LBN 16
+#define	FRF_AB_GM_EXDEF_TX_EN_WIDTH 1
+#define	FRF_AB_GM_RTRY_LIMIT_LBN 12
+#define	FRF_AB_GM_RTRY_LIMIT_WIDTH 4
+#define	FRF_AB_GM_COL_WIN_LBN 0
+#define	FRF_AB_GM_COL_WIN_WIDTH 10
+
+/* GM_MAX_FLEN_REG: GMAC maximum frame length register */
+#define	FR_AB_GM_MAX_FLEN 0x00000e40
+#define	FRF_AB_GM_MAX_FLEN_LBN 0
+#define	FRF_AB_GM_MAX_FLEN_WIDTH 16
+
+/* GM_TEST_REG: GMAC test register */
+#define	FR_AB_GM_TEST 0x00000e70
+#define	FRF_AB_GM_MAX_BOFF_LBN 3
+#define	FRF_AB_GM_MAX_BOFF_WIDTH 1
+#define	FRF_AB_GM_REG_TX_FLOW_EN_LBN 2
+#define	FRF_AB_GM_REG_TX_FLOW_EN_WIDTH 1
+#define	FRF_AB_GM_TEST_PAUSE_LBN 1
+#define	FRF_AB_GM_TEST_PAUSE_WIDTH 1
+#define	FRF_AB_GM_SHORT_SLOT_LBN 0
+#define	FRF_AB_GM_SHORT_SLOT_WIDTH 1
+
+/* GM_ADR1_REG: GMAC station address register 1 */
+#define	FR_AB_GM_ADR1 0x00000f00
+#define	FRF_AB_GM_ADR_B0_LBN 24
+#define	FRF_AB_GM_ADR_B0_WIDTH 8
+#define	FRF_AB_GM_ADR_B1_LBN 16
+#define	FRF_AB_GM_ADR_B1_WIDTH 8
+#define	FRF_AB_GM_ADR_B2_LBN 8
+#define	FRF_AB_GM_ADR_B2_WIDTH 8
+#define	FRF_AB_GM_ADR_B3_LBN 0
+#define	FRF_AB_GM_ADR_B3_WIDTH 8
+
+/* GM_ADR2_REG: GMAC station address register 2 */
+#define	FR_AB_GM_ADR2 0x00000f10
+#define	FRF_AB_GM_ADR_B4_LBN 24
+#define	FRF_AB_GM_ADR_B4_WIDTH 8
+#define	FRF_AB_GM_ADR_B5_LBN 16
+#define	FRF_AB_GM_ADR_B5_WIDTH 8
+
+/* GMF_CFG0_REG: GMAC FIFO configuration register 0 */
+#define	FR_AB_GMF_CFG0 0x00000f20
+#define	FRF_AB_GMF_FTFENRPLY_LBN 20
+#define	FRF_AB_GMF_FTFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_STFENRPLY_LBN 19
+#define	FRF_AB_GMF_STFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_FRFENRPLY_LBN 18
+#define	FRF_AB_GMF_FRFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_SRFENRPLY_LBN 17
+#define	FRF_AB_GMF_SRFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_WTMENRPLY_LBN 16
+#define	FRF_AB_GMF_WTMENRPLY_WIDTH 1
+#define	FRF_AB_GMF_FTFENREQ_LBN 12
+#define	FRF_AB_GMF_FTFENREQ_WIDTH 1
+#define	FRF_AB_GMF_STFENREQ_LBN 11
+#define	FRF_AB_GMF_STFENREQ_WIDTH 1
+#define	FRF_AB_GMF_FRFENREQ_LBN 10
+#define	FRF_AB_GMF_FRFENREQ_WIDTH 1
+#define	FRF_AB_GMF_SRFENREQ_LBN 9
+#define	FRF_AB_GMF_SRFENREQ_WIDTH 1
+#define	FRF_AB_GMF_WTMENREQ_LBN 8
+#define	FRF_AB_GMF_WTMENREQ_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTFT_LBN 4
+#define	FRF_AB_GMF_HSTRSTFT_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTST_LBN 3
+#define	FRF_AB_GMF_HSTRSTST_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTFR_LBN 2
+#define	FRF_AB_GMF_HSTRSTFR_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTSR_LBN 1
+#define	FRF_AB_GMF_HSTRSTSR_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTWT_LBN 0
+#define	FRF_AB_GMF_HSTRSTWT_WIDTH 1
+
+/* GMF_CFG1_REG: GMAC FIFO configuration register 1 */
+#define	FR_AB_GMF_CFG1 0x00000f30
+#define	FRF_AB_GMF_CFGFRTH_LBN 16
+#define	FRF_AB_GMF_CFGFRTH_WIDTH 5
+#define	FRF_AB_GMF_CFGXOFFRTX_LBN 0
+#define	FRF_AB_GMF_CFGXOFFRTX_WIDTH 16
+
+/* GMF_CFG2_REG: GMAC FIFO configuration register 2 */
+#define	FR_AB_GMF_CFG2 0x00000f40
+#define	FRF_AB_GMF_CFGHWM_LBN 16
+#define	FRF_AB_GMF_CFGHWM_WIDTH 6
+#define	FRF_AB_GMF_CFGLWM_LBN 0
+#define	FRF_AB_GMF_CFGLWM_WIDTH 6
+
+/* GMF_CFG3_REG: GMAC FIFO configuration register 3 */
+#define	FR_AB_GMF_CFG3 0x00000f50
+#define	FRF_AB_GMF_CFGHWMFT_LBN 16
+#define	FRF_AB_GMF_CFGHWMFT_WIDTH 6
+#define	FRF_AB_GMF_CFGFTTH_LBN 0
+#define	FRF_AB_GMF_CFGFTTH_WIDTH 6
+
+/* GMF_CFG4_REG: GMAC FIFO configuration register 4 */
+#define	FR_AB_GMF_CFG4 0x00000f60
+#define	FRF_AB_GMF_HSTFLTRFRM_LBN 0
+#define	FRF_AB_GMF_HSTFLTRFRM_WIDTH 18
+
+/* GMF_CFG5_REG: GMAC FIFO configuration register 5 */
+#define	FR_AB_GMF_CFG5 0x00000f70
+#define	FRF_AB_GMF_CFGHDPLX_LBN 22
+#define	FRF_AB_GMF_CFGHDPLX_WIDTH 1
+#define	FRF_AB_GMF_SRFULL_LBN 21
+#define	FRF_AB_GMF_SRFULL_WIDTH 1
+#define	FRF_AB_GMF_HSTSRFULLCLR_LBN 20
+#define	FRF_AB_GMF_HSTSRFULLCLR_WIDTH 1
+#define	FRF_AB_GMF_CFGBYTMODE_LBN 19
+#define	FRF_AB_GMF_CFGBYTMODE_WIDTH 1
+#define	FRF_AB_GMF_HSTDRPLT64_LBN 18
+#define	FRF_AB_GMF_HSTDRPLT64_WIDTH 1
+#define	FRF_AB_GMF_HSTFLTRFRMDC_LBN 0
+#define	FRF_AB_GMF_HSTFLTRFRMDC_WIDTH 18
+
+/* TX_SRC_MAC_TBL: Transmit IP source address filter table */
+#define	FR_BB_TX_SRC_MAC_TBL 0x00001000
+#define	FR_BB_TX_SRC_MAC_TBL_STEP 16
+#define	FR_BB_TX_SRC_MAC_TBL_ROWS 16
+#define	FRF_BB_TX_SRC_MAC_ADR_1_LBN 64
+#define	FRF_BB_TX_SRC_MAC_ADR_1_WIDTH 48
+#define	FRF_BB_TX_SRC_MAC_ADR_0_LBN 0
+#define	FRF_BB_TX_SRC_MAC_ADR_0_WIDTH 48
+
+/* TX_SRC_MAC_CTL_REG: Transmit MAC source address filter control */
+#define	FR_BB_TX_SRC_MAC_CTL 0x00001100
+#define	FRF_BB_TX_SRC_DROP_CTR_LBN 16
+#define	FRF_BB_TX_SRC_DROP_CTR_WIDTH 16
+#define	FRF_BB_TX_SRC_FLTR_EN_LBN 15
+#define	FRF_BB_TX_SRC_FLTR_EN_WIDTH 1
+#define	FRF_BB_TX_DROP_CTR_CLR_LBN 12
+#define	FRF_BB_TX_DROP_CTR_CLR_WIDTH 1
+#define	FRF_BB_TX_MAC_QID_SEL_LBN 0
+#define	FRF_BB_TX_MAC_QID_SEL_WIDTH 3
+
+/* XM_ADR_LO_REG: XGMAC address register low */
+#define	FR_AB_XM_ADR_LO 0x00001200
+#define	FRF_AB_XM_ADR_LO_LBN 0
+#define	FRF_AB_XM_ADR_LO_WIDTH 32
+
+/* XM_ADR_HI_REG: XGMAC address register high */
+#define	FR_AB_XM_ADR_HI 0x00001210
+#define	FRF_AB_XM_ADR_HI_LBN 0
+#define	FRF_AB_XM_ADR_HI_WIDTH 16
+
+/* XM_GLB_CFG_REG: XGMAC global configuration */
+#define	FR_AB_XM_GLB_CFG 0x00001220
+#define	FRF_AB_XM_RMTFLT_GEN_LBN 17
+#define	FRF_AB_XM_RMTFLT_GEN_WIDTH 1
+#define	FRF_AB_XM_DEBUG_MODE_LBN 16
+#define	FRF_AB_XM_DEBUG_MODE_WIDTH 1
+#define	FRF_AB_XM_RX_STAT_EN_LBN 11
+#define	FRF_AB_XM_RX_STAT_EN_WIDTH 1
+#define	FRF_AB_XM_TX_STAT_EN_LBN 10
+#define	FRF_AB_XM_TX_STAT_EN_WIDTH 1
+#define	FRF_AB_XM_RX_JUMBO_MODE_LBN 6
+#define	FRF_AB_XM_RX_JUMBO_MODE_WIDTH 1
+#define	FRF_AB_XM_WAN_MODE_LBN 5
+#define	FRF_AB_XM_WAN_MODE_WIDTH 1
+#define	FRF_AB_XM_INTCLR_MODE_LBN 3
+#define	FRF_AB_XM_INTCLR_MODE_WIDTH 1
+#define	FRF_AB_XM_CORE_RST_LBN 0
+#define	FRF_AB_XM_CORE_RST_WIDTH 1
+
+/* XM_TX_CFG_REG: XGMAC transmit configuration */
+#define	FR_AB_XM_TX_CFG 0x00001230
+#define	FRF_AB_XM_TX_PROG_LBN 24
+#define	FRF_AB_XM_TX_PROG_WIDTH 1
+#define	FRF_AB_XM_IPG_LBN 16
+#define	FRF_AB_XM_IPG_WIDTH 4
+#define	FRF_AB_XM_FCNTL_LBN 10
+#define	FRF_AB_XM_FCNTL_WIDTH 1
+#define	FRF_AB_XM_TXCRC_LBN 8
+#define	FRF_AB_XM_TXCRC_WIDTH 1
+#define	FRF_AB_XM_EDRC_LBN 6
+#define	FRF_AB_XM_EDRC_WIDTH 1
+#define	FRF_AB_XM_AUTO_PAD_LBN 5
+#define	FRF_AB_XM_AUTO_PAD_WIDTH 1
+#define	FRF_AB_XM_TX_PRMBL_LBN 2
+#define	FRF_AB_XM_TX_PRMBL_WIDTH 1
+#define	FRF_AB_XM_TXEN_LBN 1
+#define	FRF_AB_XM_TXEN_WIDTH 1
+#define	FRF_AB_XM_TX_RST_LBN 0
+#define	FRF_AB_XM_TX_RST_WIDTH 1
+
+/* XM_RX_CFG_REG: XGMAC receive configuration */
+#define	FR_AB_XM_RX_CFG 0x00001240
+#define	FRF_AB_XM_PASS_LENERR_LBN 26
+#define	FRF_AB_XM_PASS_LENERR_WIDTH 1
+#define	FRF_AB_XM_PASS_CRC_ERR_LBN 25
+#define	FRF_AB_XM_PASS_CRC_ERR_WIDTH 1
+#define	FRF_AB_XM_PASS_PRMBLE_ERR_LBN 24
+#define	FRF_AB_XM_PASS_PRMBLE_ERR_WIDTH 1
+#define	FRF_AB_XM_REJ_BCAST_LBN 20
+#define	FRF_AB_XM_REJ_BCAST_WIDTH 1
+#define	FRF_AB_XM_ACPT_ALL_MCAST_LBN 11
+#define	FRF_AB_XM_ACPT_ALL_MCAST_WIDTH 1
+#define	FRF_AB_XM_ACPT_ALL_UCAST_LBN 9
+#define	FRF_AB_XM_ACPT_ALL_UCAST_WIDTH 1
+#define	FRF_AB_XM_AUTO_DEPAD_LBN 8
+#define	FRF_AB_XM_AUTO_DEPAD_WIDTH 1
+#define	FRF_AB_XM_RXCRC_LBN 3
+#define	FRF_AB_XM_RXCRC_WIDTH 1
+#define	FRF_AB_XM_RX_PRMBL_LBN 2
+#define	FRF_AB_XM_RX_PRMBL_WIDTH 1
+#define	FRF_AB_XM_RXEN_LBN 1
+#define	FRF_AB_XM_RXEN_WIDTH 1
+#define	FRF_AB_XM_RX_RST_LBN 0
+#define	FRF_AB_XM_RX_RST_WIDTH 1
+
+/* XM_MGT_INT_MASK: documentation to be written for sum_XM_MGT_INT_MASK */
+#define	FR_AB_XM_MGT_INT_MASK 0x00001250
+#define	FRF_AB_XM_MSK_STA_INTR_LBN 16
+#define	FRF_AB_XM_MSK_STA_INTR_WIDTH 1
+#define	FRF_AB_XM_MSK_STAT_CNTR_HF_LBN 9
+#define	FRF_AB_XM_MSK_STAT_CNTR_HF_WIDTH 1
+#define	FRF_AB_XM_MSK_STAT_CNTR_OF_LBN 8
+#define	FRF_AB_XM_MSK_STAT_CNTR_OF_WIDTH 1
+#define	FRF_AB_XM_MSK_PRMBLE_ERR_LBN 2
+#define	FRF_AB_XM_MSK_PRMBLE_ERR_WIDTH 1
+#define	FRF_AB_XM_MSK_RMTFLT_LBN 1
+#define	FRF_AB_XM_MSK_RMTFLT_WIDTH 1
+#define	FRF_AB_XM_MSK_LCLFLT_LBN 0
+#define	FRF_AB_XM_MSK_LCLFLT_WIDTH 1
+
+/* XM_FC_REG: XGMAC flow control register */
+#define	FR_AB_XM_FC 0x00001270
+#define	FRF_AB_XM_PAUSE_TIME_LBN 16
+#define	FRF_AB_XM_PAUSE_TIME_WIDTH 16
+#define	FRF_AB_XM_RX_MAC_STAT_LBN 11
+#define	FRF_AB_XM_RX_MAC_STAT_WIDTH 1
+#define	FRF_AB_XM_TX_MAC_STAT_LBN 10
+#define	FRF_AB_XM_TX_MAC_STAT_WIDTH 1
+#define	FRF_AB_XM_MCNTL_PASS_LBN 8
+#define	FRF_AB_XM_MCNTL_PASS_WIDTH 2
+#define	FRF_AB_XM_REJ_CNTL_UCAST_LBN 6
+#define	FRF_AB_XM_REJ_CNTL_UCAST_WIDTH 1
+#define	FRF_AB_XM_REJ_CNTL_MCAST_LBN 5
+#define	FRF_AB_XM_REJ_CNTL_MCAST_WIDTH 1
+#define	FRF_AB_XM_ZPAUSE_LBN 2
+#define	FRF_AB_XM_ZPAUSE_WIDTH 1
+#define	FRF_AB_XM_XMIT_PAUSE_LBN 1
+#define	FRF_AB_XM_XMIT_PAUSE_WIDTH 1
+#define	FRF_AB_XM_DIS_FCNTL_LBN 0
+#define	FRF_AB_XM_DIS_FCNTL_WIDTH 1
+
+/* XM_PAUSE_TIME_REG: XGMAC pause time register */
+#define	FR_AB_XM_PAUSE_TIME 0x00001290
+#define	FRF_AB_XM_TX_PAUSE_CNT_LBN 16
+#define	FRF_AB_XM_TX_PAUSE_CNT_WIDTH 16
+#define	FRF_AB_XM_RX_PAUSE_CNT_LBN 0
+#define	FRF_AB_XM_RX_PAUSE_CNT_WIDTH 16
+
+/* XM_TX_PARAM_REG: XGMAC transmit parameter register */
+#define	FR_AB_XM_TX_PARAM 0x000012d0
+#define	FRF_AB_XM_TX_JUMBO_MODE_LBN 31
+#define	FRF_AB_XM_TX_JUMBO_MODE_WIDTH 1
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_HI_LBN 19
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_HI_WIDTH 11
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_LO_LBN 16
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_LO_WIDTH 3
+#define	FRF_AB_XM_PAD_CHAR_LBN 0
+#define	FRF_AB_XM_PAD_CHAR_WIDTH 8
+
+/* XM_RX_PARAM_REG: XGMAC receive parameter register */
+#define	FR_AB_XM_RX_PARAM 0x000012e0
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_HI_LBN 3
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_HI_WIDTH 11
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_LO_LBN 0
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_LO_WIDTH 3
+
+/* XM_MGT_INT_MSK_REG: XGMAC management interrupt mask register */
+#define	FR_AB_XM_MGT_INT_MSK 0x000012f0
+#define	FRF_AB_XM_STAT_CNTR_OF_LBN 9
+#define	FRF_AB_XM_STAT_CNTR_OF_WIDTH 1
+#define	FRF_AB_XM_STAT_CNTR_HF_LBN 8
+#define	FRF_AB_XM_STAT_CNTR_HF_WIDTH 1
+#define	FRF_AB_XM_PRMBLE_ERR_LBN 2
+#define	FRF_AB_XM_PRMBLE_ERR_WIDTH 1
+#define	FRF_AB_XM_RMTFLT_LBN 1
+#define	FRF_AB_XM_RMTFLT_WIDTH 1
+#define	FRF_AB_XM_LCLFLT_LBN 0
+#define	FRF_AB_XM_LCLFLT_WIDTH 1
+
+/* XX_PWR_RST_REG: XGXS/XAUI powerdown/reset register */
+#define	FR_AB_XX_PWR_RST 0x00001300
+#define	FRF_AB_XX_PWRDND_SIG_LBN 31
+#define	FRF_AB_XX_PWRDND_SIG_WIDTH 1
+#define	FRF_AB_XX_PWRDNC_SIG_LBN 30
+#define	FRF_AB_XX_PWRDNC_SIG_WIDTH 1
+#define	FRF_AB_XX_PWRDNB_SIG_LBN 29
+#define	FRF_AB_XX_PWRDNB_SIG_WIDTH 1
+#define	FRF_AB_XX_PWRDNA_SIG_LBN 28
+#define	FRF_AB_XX_PWRDNA_SIG_WIDTH 1
+#define	FRF_AB_XX_SIM_MODE_LBN 27
+#define	FRF_AB_XX_SIM_MODE_WIDTH 1
+#define	FRF_AB_XX_RSTPLLCD_SIG_LBN 25
+#define	FRF_AB_XX_RSTPLLCD_SIG_WIDTH 1
+#define	FRF_AB_XX_RSTPLLAB_SIG_LBN 24
+#define	FRF_AB_XX_RSTPLLAB_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETD_SIG_LBN 23
+#define	FRF_AB_XX_RESETD_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETC_SIG_LBN 22
+#define	FRF_AB_XX_RESETC_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETB_SIG_LBN 21
+#define	FRF_AB_XX_RESETB_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETA_SIG_LBN 20
+#define	FRF_AB_XX_RESETA_SIG_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSRX_SIG_LBN 18
+#define	FRF_AB_XX_RSTXGXSRX_SIG_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSTX_SIG_LBN 17
+#define	FRF_AB_XX_RSTXGXSTX_SIG_WIDTH 1
+#define	FRF_AB_XX_SD_RST_ACT_LBN 16
+#define	FRF_AB_XX_SD_RST_ACT_WIDTH 1
+#define	FRF_AB_XX_PWRDND_EN_LBN 15
+#define	FRF_AB_XX_PWRDND_EN_WIDTH 1
+#define	FRF_AB_XX_PWRDNC_EN_LBN 14
+#define	FRF_AB_XX_PWRDNC_EN_WIDTH 1
+#define	FRF_AB_XX_PWRDNB_EN_LBN 13
+#define	FRF_AB_XX_PWRDNB_EN_WIDTH 1
+#define	FRF_AB_XX_PWRDNA_EN_LBN 12
+#define	FRF_AB_XX_PWRDNA_EN_WIDTH 1
+#define	FRF_AB_XX_RSTPLLCD_EN_LBN 9
+#define	FRF_AB_XX_RSTPLLCD_EN_WIDTH 1
+#define	FRF_AB_XX_RSTPLLAB_EN_LBN 8
+#define	FRF_AB_XX_RSTPLLAB_EN_WIDTH 1
+#define	FRF_AB_XX_RESETD_EN_LBN 7
+#define	FRF_AB_XX_RESETD_EN_WIDTH 1
+#define	FRF_AB_XX_RESETC_EN_LBN 6
+#define	FRF_AB_XX_RESETC_EN_WIDTH 1
+#define	FRF_AB_XX_RESETB_EN_LBN 5
+#define	FRF_AB_XX_RESETB_EN_WIDTH 1
+#define	FRF_AB_XX_RESETA_EN_LBN 4
+#define	FRF_AB_XX_RESETA_EN_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSRX_EN_LBN 2
+#define	FRF_AB_XX_RSTXGXSRX_EN_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSTX_EN_LBN 1
+#define	FRF_AB_XX_RSTXGXSTX_EN_WIDTH 1
+#define	FRF_AB_XX_RST_XX_EN_LBN 0
+#define	FRF_AB_XX_RST_XX_EN_WIDTH 1
+
+/* XX_SD_CTL_REG: XGXS/XAUI powerdown/reset control register */
+#define	FR_AB_XX_SD_CTL 0x00001310
+#define	FRF_AB_XX_TERMADJ1_LBN 17
+#define	FRF_AB_XX_TERMADJ1_WIDTH 1
+#define	FRF_AB_XX_TERMADJ0_LBN 16
+#define	FRF_AB_XX_TERMADJ0_WIDTH 1
+#define	FRF_AB_XX_HIDRVD_LBN 15
+#define	FRF_AB_XX_HIDRVD_WIDTH 1
+#define	FRF_AB_XX_LODRVD_LBN 14
+#define	FRF_AB_XX_LODRVD_WIDTH 1
+#define	FRF_AB_XX_HIDRVC_LBN 13
+#define	FRF_AB_XX_HIDRVC_WIDTH 1
+#define	FRF_AB_XX_LODRVC_LBN 12
+#define	FRF_AB_XX_LODRVC_WIDTH 1
+#define	FRF_AB_XX_HIDRVB_LBN 11
+#define	FRF_AB_XX_HIDRVB_WIDTH 1
+#define	FRF_AB_XX_LODRVB_LBN 10
+#define	FRF_AB_XX_LODRVB_WIDTH 1
+#define	FRF_AB_XX_HIDRVA_LBN 9
+#define	FRF_AB_XX_HIDRVA_WIDTH 1
+#define	FRF_AB_XX_LODRVA_LBN 8
+#define	FRF_AB_XX_LODRVA_WIDTH 1
+#define	FRF_AB_XX_LPBKD_LBN 3
+#define	FRF_AB_XX_LPBKD_WIDTH 1
+#define	FRF_AB_XX_LPBKC_LBN 2
+#define	FRF_AB_XX_LPBKC_WIDTH 1
+#define	FRF_AB_XX_LPBKB_LBN 1
+#define	FRF_AB_XX_LPBKB_WIDTH 1
+#define	FRF_AB_XX_LPBKA_LBN 0
+#define	FRF_AB_XX_LPBKA_WIDTH 1
+
+/* XX_TXDRV_CTL_REG: XAUI SerDes transmit drive control register */
+#define	FR_AB_XX_TXDRV_CTL 0x00001320
+#define	FRF_AB_XX_DEQD_LBN 28
+#define	FRF_AB_XX_DEQD_WIDTH 4
+#define	FRF_AB_XX_DEQC_LBN 24
+#define	FRF_AB_XX_DEQC_WIDTH 4
+#define	FRF_AB_XX_DEQB_LBN 20
+#define	FRF_AB_XX_DEQB_WIDTH 4
+#define	FRF_AB_XX_DEQA_LBN 16
+#define	FRF_AB_XX_DEQA_WIDTH 4
+#define	FRF_AB_XX_DTXD_LBN 12
+#define	FRF_AB_XX_DTXD_WIDTH 4
+#define	FRF_AB_XX_DTXC_LBN 8
+#define	FRF_AB_XX_DTXC_WIDTH 4
+#define	FRF_AB_XX_DTXB_LBN 4
+#define	FRF_AB_XX_DTXB_WIDTH 4
+#define	FRF_AB_XX_DTXA_LBN 0
+#define	FRF_AB_XX_DTXA_WIDTH 4
+
+/* XX_PRBS_CTL_REG: documentation to be written for sum_XX_PRBS_CTL_REG */
+#define	FR_AB_XX_PRBS_CTL 0x00001330
+#define	FRF_AB_XX_CH3_RX_PRBS_SEL_LBN 30
+#define	FRF_AB_XX_CH3_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH3_RX_PRBS_INV_LBN 29
+#define	FRF_AB_XX_CH3_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH3_RX_PRBS_CHKEN_LBN 28
+#define	FRF_AB_XX_CH3_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH2_RX_PRBS_SEL_LBN 26
+#define	FRF_AB_XX_CH2_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH2_RX_PRBS_INV_LBN 25
+#define	FRF_AB_XX_CH2_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH2_RX_PRBS_CHKEN_LBN 24
+#define	FRF_AB_XX_CH2_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH1_RX_PRBS_SEL_LBN 22
+#define	FRF_AB_XX_CH1_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH1_RX_PRBS_INV_LBN 21
+#define	FRF_AB_XX_CH1_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH1_RX_PRBS_CHKEN_LBN 20
+#define	FRF_AB_XX_CH1_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH0_RX_PRBS_SEL_LBN 18
+#define	FRF_AB_XX_CH0_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH0_RX_PRBS_INV_LBN 17
+#define	FRF_AB_XX_CH0_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH0_RX_PRBS_CHKEN_LBN 16
+#define	FRF_AB_XX_CH0_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH3_TX_PRBS_SEL_LBN 14
+#define	FRF_AB_XX_CH3_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH3_TX_PRBS_INV_LBN 13
+#define	FRF_AB_XX_CH3_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH3_TX_PRBS_CHKEN_LBN 12
+#define	FRF_AB_XX_CH3_TX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH2_TX_PRBS_SEL_LBN 10
+#define	FRF_AB_XX_CH2_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH2_TX_PRBS_INV_LBN 9
+#define	FRF_AB_XX_CH2_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH2_TX_PRBS_CHKEN_LBN 8
+#define	FRF_AB_XX_CH2_TX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH1_TX_PRBS_SEL_LBN 6
+#define	FRF_AB_XX_CH1_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH1_TX_PRBS_INV_LBN 5
+#define	FRF_AB_XX_CH1_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH1_TX_PRBS_CHKEN_LBN 4
+#define	FRF_AB_XX_CH1_TX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH0_TX_PRBS_SEL_LBN 2
+#define	FRF_AB_XX_CH0_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH0_TX_PRBS_INV_LBN 1
+#define	FRF_AB_XX_CH0_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH0_TX_PRBS_CHKEN_LBN 0
+#define	FRF_AB_XX_CH0_TX_PRBS_CHKEN_WIDTH 1
+
+/* XX_PRBS_CHK_REG: documentation to be written for sum_XX_PRBS_CHK_REG */
+#define	FR_AB_XX_PRBS_CHK 0x00001340
+#define	FRF_AB_XX_REV_LB_EN_LBN 16
+#define	FRF_AB_XX_REV_LB_EN_WIDTH 1
+#define	FRF_AB_XX_CH3_DEG_DET_LBN 15
+#define	FRF_AB_XX_CH3_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH3_LFSR_LOCK_IND_LBN 14
+#define	FRF_AB_XX_CH3_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH3_PRBS_FRUN_LBN 13
+#define	FRF_AB_XX_CH3_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH3_ERR_CHK_LBN 12
+#define	FRF_AB_XX_CH3_ERR_CHK_WIDTH 1
+#define	FRF_AB_XX_CH2_DEG_DET_LBN 11
+#define	FRF_AB_XX_CH2_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH2_LFSR_LOCK_IND_LBN 10
+#define	FRF_AB_XX_CH2_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH2_PRBS_FRUN_LBN 9
+#define	FRF_AB_XX_CH2_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH2_ERR_CHK_LBN 8
+#define	FRF_AB_XX_CH2_ERR_CHK_WIDTH 1
+#define	FRF_AB_XX_CH1_DEG_DET_LBN 7
+#define	FRF_AB_XX_CH1_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH1_LFSR_LOCK_IND_LBN 6
+#define	FRF_AB_XX_CH1_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH1_PRBS_FRUN_LBN 5
+#define	FRF_AB_XX_CH1_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH1_ERR_CHK_LBN 4
+#define	FRF_AB_XX_CH1_ERR_CHK_WIDTH 1
+#define	FRF_AB_XX_CH0_DEG_DET_LBN 3
+#define	FRF_AB_XX_CH0_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH0_LFSR_LOCK_IND_LBN 2
+#define	FRF_AB_XX_CH0_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH0_PRBS_FRUN_LBN 1
+#define	FRF_AB_XX_CH0_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH0_ERR_CHK_LBN 0
+#define	FRF_AB_XX_CH0_ERR_CHK_WIDTH 1
+
+/* XX_PRBS_ERR_REG: documentation to be written for sum_XX_PRBS_ERR_REG */
+#define	FR_AB_XX_PRBS_ERR 0x00001350
+#define	FRF_AB_XX_CH3_PRBS_ERR_CNT_LBN 24
+#define	FRF_AB_XX_CH3_PRBS_ERR_CNT_WIDTH 8
+#define	FRF_AB_XX_CH2_PRBS_ERR_CNT_LBN 16
+#define	FRF_AB_XX_CH2_PRBS_ERR_CNT_WIDTH 8
+#define	FRF_AB_XX_CH1_PRBS_ERR_CNT_LBN 8
+#define	FRF_AB_XX_CH1_PRBS_ERR_CNT_WIDTH 8
+#define	FRF_AB_XX_CH0_PRBS_ERR_CNT_LBN 0
+#define	FRF_AB_XX_CH0_PRBS_ERR_CNT_WIDTH 8
+
+/* XX_CORE_STAT_REG: XAUI XGXS core status register */
+#define	FR_AB_XX_CORE_STAT 0x00001360
+#define	FRF_AB_XX_FORCE_SIG3_LBN 31
+#define	FRF_AB_XX_FORCE_SIG3_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG3_VAL_LBN 30
+#define	FRF_AB_XX_FORCE_SIG3_VAL_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG2_LBN 29
+#define	FRF_AB_XX_FORCE_SIG2_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG2_VAL_LBN 28
+#define	FRF_AB_XX_FORCE_SIG2_VAL_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG1_LBN 27
+#define	FRF_AB_XX_FORCE_SIG1_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG1_VAL_LBN 26
+#define	FRF_AB_XX_FORCE_SIG1_VAL_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG0_LBN 25
+#define	FRF_AB_XX_FORCE_SIG0_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG0_VAL_LBN 24
+#define	FRF_AB_XX_FORCE_SIG0_VAL_WIDTH 1
+#define	FRF_AB_XX_XGXS_LB_EN_LBN 23
+#define	FRF_AB_XX_XGXS_LB_EN_WIDTH 1
+#define	FRF_AB_XX_XGMII_LB_EN_LBN 22
+#define	FRF_AB_XX_XGMII_LB_EN_WIDTH 1
+#define	FRF_AB_XX_MATCH_FAULT_LBN 21
+#define	FRF_AB_XX_MATCH_FAULT_WIDTH 1
+#define	FRF_AB_XX_ALIGN_DONE_LBN 20
+#define	FRF_AB_XX_ALIGN_DONE_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT3_LBN 19
+#define	FRF_AB_XX_SYNC_STAT3_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT2_LBN 18
+#define	FRF_AB_XX_SYNC_STAT2_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT1_LBN 17
+#define	FRF_AB_XX_SYNC_STAT1_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT0_LBN 16
+#define	FRF_AB_XX_SYNC_STAT0_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH3_LBN 15
+#define	FRF_AB_XX_COMMA_DET_CH3_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH2_LBN 14
+#define	FRF_AB_XX_COMMA_DET_CH2_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH1_LBN 13
+#define	FRF_AB_XX_COMMA_DET_CH1_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH0_LBN 12
+#define	FRF_AB_XX_COMMA_DET_CH0_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH3_LBN 11
+#define	FRF_AB_XX_CGRP_ALIGN_CH3_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH2_LBN 10
+#define	FRF_AB_XX_CGRP_ALIGN_CH2_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH1_LBN 9
+#define	FRF_AB_XX_CGRP_ALIGN_CH1_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH0_LBN 8
+#define	FRF_AB_XX_CGRP_ALIGN_CH0_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH3_LBN 7
+#define	FRF_AB_XX_CHAR_ERR_CH3_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH2_LBN 6
+#define	FRF_AB_XX_CHAR_ERR_CH2_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH1_LBN 5
+#define	FRF_AB_XX_CHAR_ERR_CH1_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH0_LBN 4
+#define	FRF_AB_XX_CHAR_ERR_CH0_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH3_LBN 3
+#define	FRF_AB_XX_DISPERR_CH3_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH2_LBN 2
+#define	FRF_AB_XX_DISPERR_CH2_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH1_LBN 1
+#define	FRF_AB_XX_DISPERR_CH1_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH0_LBN 0
+#define	FRF_AB_XX_DISPERR_CH0_WIDTH 1
+
+/* RX_DESC_PTR_TBL_KER: Receive descriptor pointer table */
+#define	FR_AA_RX_DESC_PTR_TBL_KER 0x00011800
+#define	FR_AA_RX_DESC_PTR_TBL_KER_STEP 16
+#define	FR_AA_RX_DESC_PTR_TBL_KER_ROWS 4
+/* RX_DESC_PTR_TBL: Receive descriptor pointer table */
+#define	FR_BZ_RX_DESC_PTR_TBL 0x00f40000
+#define	FR_BZ_RX_DESC_PTR_TBL_STEP 16
+#define	FR_BB_RX_DESC_PTR_TBL_ROWS 4096
+#define	FR_CZ_RX_DESC_PTR_TBL_ROWS 1024
+#define	FRF_CZ_RX_HDR_SPLIT_LBN 90
+#define	FRF_CZ_RX_HDR_SPLIT_WIDTH 1
+#define	FRF_AA_RX_RESET_LBN 89
+#define	FRF_AA_RX_RESET_WIDTH 1
+#define	FRF_AZ_RX_ISCSI_DDIG_EN_LBN 88
+#define	FRF_AZ_RX_ISCSI_DDIG_EN_WIDTH 1
+#define	FRF_AZ_RX_ISCSI_HDIG_EN_LBN 87
+#define	FRF_AZ_RX_ISCSI_HDIG_EN_WIDTH 1
+#define	FRF_AZ_RX_DESC_PREF_ACT_LBN 86
+#define	FRF_AZ_RX_DESC_PREF_ACT_WIDTH 1
+#define	FRF_AZ_RX_DC_HW_RPTR_LBN 80
+#define	FRF_AZ_RX_DC_HW_RPTR_WIDTH 6
+#define	FRF_AZ_RX_DESCQ_HW_RPTR_LBN 68
+#define	FRF_AZ_RX_DESCQ_HW_RPTR_WIDTH 12
+#define	FRF_AZ_RX_DESCQ_SW_WPTR_LBN 56
+#define	FRF_AZ_RX_DESCQ_SW_WPTR_WIDTH 12
+#define	FRF_AZ_RX_DESCQ_BUF_BASE_ID_LBN 36
+#define	FRF_AZ_RX_DESCQ_BUF_BASE_ID_WIDTH 20
+#define	FRF_AZ_RX_DESCQ_EVQ_ID_LBN 24
+#define	FRF_AZ_RX_DESCQ_EVQ_ID_WIDTH 12
+#define	FRF_AZ_RX_DESCQ_OWNER_ID_LBN 10
+#define	FRF_AZ_RX_DESCQ_OWNER_ID_WIDTH 14
+#define	FRF_AZ_RX_DESCQ_LABEL_LBN 5
+#define	FRF_AZ_RX_DESCQ_LABEL_WIDTH 5
+#define	FRF_AZ_RX_DESCQ_SIZE_LBN 3
+#define	FRF_AZ_RX_DESCQ_SIZE_WIDTH 2
+#define	FFE_AZ_RX_DESCQ_SIZE_4K 3
+#define	FFE_AZ_RX_DESCQ_SIZE_2K 2
+#define	FFE_AZ_RX_DESCQ_SIZE_1K 1
+#define	FFE_AZ_RX_DESCQ_SIZE_512 0
+#define	FRF_AZ_RX_DESCQ_TYPE_LBN 2
+#define	FRF_AZ_RX_DESCQ_TYPE_WIDTH 1
+#define	FRF_AZ_RX_DESCQ_JUMBO_LBN 1
+#define	FRF_AZ_RX_DESCQ_JUMBO_WIDTH 1
+#define	FRF_AZ_RX_DESCQ_EN_LBN 0
+#define	FRF_AZ_RX_DESCQ_EN_WIDTH 1
+
+/* TX_DESC_PTR_TBL_KER: Transmit descriptor pointer */
+#define	FR_AA_TX_DESC_PTR_TBL_KER 0x00011900
+#define	FR_AA_TX_DESC_PTR_TBL_KER_STEP 16
+#define	FR_AA_TX_DESC_PTR_TBL_KER_ROWS 8
+/* TX_DESC_PTR_TBL: Transmit descriptor pointer */
+#define	FR_BZ_TX_DESC_PTR_TBL 0x00f50000
+#define	FR_BZ_TX_DESC_PTR_TBL_STEP 16
+#define	FR_BB_TX_DESC_PTR_TBL_ROWS 4096
+#define	FR_CZ_TX_DESC_PTR_TBL_ROWS 1024
+#define	FRF_CZ_TX_DPT_Q_MASK_WIDTH_LBN 94
+#define	FRF_CZ_TX_DPT_Q_MASK_WIDTH_WIDTH 2
+#define	FRF_CZ_TX_DPT_ETH_FILT_EN_LBN 93
+#define	FRF_CZ_TX_DPT_ETH_FILT_EN_WIDTH 1
+#define	FRF_CZ_TX_DPT_IP_FILT_EN_LBN 92
+#define	FRF_CZ_TX_DPT_IP_FILT_EN_WIDTH 1
+#define	FRF_BZ_TX_NON_IP_DROP_DIS_LBN 91
+#define	FRF_BZ_TX_NON_IP_DROP_DIS_WIDTH 1
+#define	FRF_BZ_TX_IP_CHKSM_DIS_LBN 90
+#define	FRF_BZ_TX_IP_CHKSM_DIS_WIDTH 1
+#define	FRF_BZ_TX_TCP_CHKSM_DIS_LBN 89
+#define	FRF_BZ_TX_TCP_CHKSM_DIS_WIDTH 1
+#define	FRF_AZ_TX_DESCQ_EN_LBN 88
+#define	FRF_AZ_TX_DESCQ_EN_WIDTH 1
+#define	FRF_AZ_TX_ISCSI_DDIG_EN_LBN 87
+#define	FRF_AZ_TX_ISCSI_DDIG_EN_WIDTH 1
+#define	FRF_AZ_TX_ISCSI_HDIG_EN_LBN 86
+#define	FRF_AZ_TX_ISCSI_HDIG_EN_WIDTH 1
+#define	FRF_AZ_TX_DC_HW_RPTR_LBN 80
+#define	FRF_AZ_TX_DC_HW_RPTR_WIDTH 6
+#define	FRF_AZ_TX_DESCQ_HW_RPTR_LBN 68
+#define	FRF_AZ_TX_DESCQ_HW_RPTR_WIDTH 12
+#define	FRF_AZ_TX_DESCQ_SW_WPTR_LBN 56
+#define	FRF_AZ_TX_DESCQ_SW_WPTR_WIDTH 12
+#define	FRF_AZ_TX_DESCQ_BUF_BASE_ID_LBN 36
+#define	FRF_AZ_TX_DESCQ_BUF_BASE_ID_WIDTH 20
+#define	FRF_AZ_TX_DESCQ_EVQ_ID_LBN 24
+#define	FRF_AZ_TX_DESCQ_EVQ_ID_WIDTH 12
+#define	FRF_AZ_TX_DESCQ_OWNER_ID_LBN 10
+#define	FRF_AZ_TX_DESCQ_OWNER_ID_WIDTH 14
+#define	FRF_AZ_TX_DESCQ_LABEL_LBN 5
+#define	FRF_AZ_TX_DESCQ_LABEL_WIDTH 5
+#define	FRF_AZ_TX_DESCQ_SIZE_LBN 3
+#define	FRF_AZ_TX_DESCQ_SIZE_WIDTH 2
+#define	FFE_AZ_TX_DESCQ_SIZE_4K 3
+#define	FFE_AZ_TX_DESCQ_SIZE_2K 2
+#define	FFE_AZ_TX_DESCQ_SIZE_1K 1
+#define	FFE_AZ_TX_DESCQ_SIZE_512 0
+#define	FRF_AZ_TX_DESCQ_TYPE_LBN 1
+#define	FRF_AZ_TX_DESCQ_TYPE_WIDTH 2
+#define	FRF_AZ_TX_DESCQ_FLUSH_LBN 0
+#define	FRF_AZ_TX_DESCQ_FLUSH_WIDTH 1
+
+/* EVQ_PTR_TBL_KER: Event queue pointer table */
+#define	FR_AA_EVQ_PTR_TBL_KER 0x00011a00
+#define	FR_AA_EVQ_PTR_TBL_KER_STEP 16
+#define	FR_AA_EVQ_PTR_TBL_KER_ROWS 4
+/* EVQ_PTR_TBL: Event queue pointer table */
+#define	FR_BZ_EVQ_PTR_TBL 0x00f60000
+#define	FR_BZ_EVQ_PTR_TBL_STEP 16
+#define	FR_CZ_EVQ_PTR_TBL_ROWS 1024
+#define	FR_BB_EVQ_PTR_TBL_ROWS 4096
+#define	FRF_BZ_EVQ_RPTR_IGN_LBN 40
+#define	FRF_BZ_EVQ_RPTR_IGN_WIDTH 1
+#define	FRF_AB_EVQ_WKUP_OR_INT_EN_LBN 39
+#define	FRF_AB_EVQ_WKUP_OR_INT_EN_WIDTH 1
+#define	FRF_CZ_EVQ_DOS_PROTECT_EN_LBN 39
+#define	FRF_CZ_EVQ_DOS_PROTECT_EN_WIDTH 1
+#define	FRF_AZ_EVQ_NXT_WPTR_LBN 24
+#define	FRF_AZ_EVQ_NXT_WPTR_WIDTH 15
+#define	FRF_AZ_EVQ_EN_LBN 23
+#define	FRF_AZ_EVQ_EN_WIDTH 1
+#define	FRF_AZ_EVQ_SIZE_LBN 20
+#define	FRF_AZ_EVQ_SIZE_WIDTH 3
+#define	FFE_AZ_EVQ_SIZE_32K 6
+#define	FFE_AZ_EVQ_SIZE_16K 5
+#define	FFE_AZ_EVQ_SIZE_8K 4
+#define	FFE_AZ_EVQ_SIZE_4K 3
+#define	FFE_AZ_EVQ_SIZE_2K 2
+#define	FFE_AZ_EVQ_SIZE_1K 1
+#define	FFE_AZ_EVQ_SIZE_512 0
+#define	FRF_AZ_EVQ_BUF_BASE_ID_LBN 0
+#define	FRF_AZ_EVQ_BUF_BASE_ID_WIDTH 20
+
+/* BUF_HALF_TBL_KER: Buffer table in half buffer table mode direct access by driver */
+#define	FR_AA_BUF_HALF_TBL_KER 0x00018000
+#define	FR_AA_BUF_HALF_TBL_KER_STEP 8
+#define	FR_AA_BUF_HALF_TBL_KER_ROWS 4096
+/* BUF_HALF_TBL: Buffer table in half buffer table mode direct access by driver */
+#define	FR_BZ_BUF_HALF_TBL 0x00800000
+#define	FR_BZ_BUF_HALF_TBL_STEP 8
+#define	FR_CZ_BUF_HALF_TBL_ROWS 147456
+#define	FR_BB_BUF_HALF_TBL_ROWS 524288
+#define	FRF_AZ_BUF_ADR_HBUF_ODD_LBN 44
+#define	FRF_AZ_BUF_ADR_HBUF_ODD_WIDTH 20
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_ODD_LBN 32
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_ODD_WIDTH 12
+#define	FRF_AZ_BUF_ADR_HBUF_EVEN_LBN 12
+#define	FRF_AZ_BUF_ADR_HBUF_EVEN_WIDTH 20
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_EVEN_LBN 0
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_EVEN_WIDTH 12
+
+/* BUF_FULL_TBL_KER: Buffer table in full buffer table mode direct access by driver */
+#define	FR_AA_BUF_FULL_TBL_KER 0x00018000
+#define	FR_AA_BUF_FULL_TBL_KER_STEP 8
+#define	FR_AA_BUF_FULL_TBL_KER_ROWS 4096
+/* BUF_FULL_TBL: Buffer table in full buffer table mode direct access by driver */
+#define	FR_BZ_BUF_FULL_TBL 0x00800000
+#define	FR_BZ_BUF_FULL_TBL_STEP 8
+#define	FR_CZ_BUF_FULL_TBL_ROWS 147456
+#define	FR_BB_BUF_FULL_TBL_ROWS 917504
+#define	FRF_AZ_BUF_FULL_UNUSED_LBN 51
+#define	FRF_AZ_BUF_FULL_UNUSED_WIDTH 13
+#define	FRF_AZ_IP_DAT_BUF_SIZE_LBN 50
+#define	FRF_AZ_IP_DAT_BUF_SIZE_WIDTH 1
+#define	FRF_AZ_BUF_ADR_REGION_LBN 48
+#define	FRF_AZ_BUF_ADR_REGION_WIDTH 2
+#define	FFE_AZ_BUF_ADR_REGN3 3
+#define	FFE_AZ_BUF_ADR_REGN2 2
+#define	FFE_AZ_BUF_ADR_REGN1 1
+#define	FFE_AZ_BUF_ADR_REGN0 0
+#define	FRF_AZ_BUF_ADR_FBUF_LBN 14
+#define	FRF_AZ_BUF_ADR_FBUF_WIDTH 34
+#define	FRF_AZ_BUF_OWNER_ID_FBUF_LBN 0
+#define	FRF_AZ_BUF_OWNER_ID_FBUF_WIDTH 14
+
+/* RX_FILTER_TBL0: TCP/IPv4 Receive filter table */
+#define	FR_BZ_RX_FILTER_TBL0 0x00f00000
+#define	FR_BZ_RX_FILTER_TBL0_STEP 32
+#define	FR_BZ_RX_FILTER_TBL0_ROWS 8192
+/* RX_FILTER_TBL1: TCP/IPv4 Receive filter table */
+#define	FR_BB_RX_FILTER_TBL1 0x00f00010
+#define	FR_BB_RX_FILTER_TBL1_STEP 32
+#define	FR_BB_RX_FILTER_TBL1_ROWS 8192
+#define	FRF_BZ_RSS_EN_LBN 110
+#define	FRF_BZ_RSS_EN_WIDTH 1
+#define	FRF_BZ_SCATTER_EN_LBN 109
+#define	FRF_BZ_SCATTER_EN_WIDTH 1
+#define	FRF_BZ_TCP_UDP_LBN 108
+#define	FRF_BZ_TCP_UDP_WIDTH 1
+#define	FRF_BZ_RXQ_ID_LBN 96
+#define	FRF_BZ_RXQ_ID_WIDTH 12
+#define	FRF_BZ_DEST_IP_LBN 64
+#define	FRF_BZ_DEST_IP_WIDTH 32
+#define	FRF_BZ_DEST_PORT_TCP_LBN 48
+#define	FRF_BZ_DEST_PORT_TCP_WIDTH 16
+#define	FRF_BZ_SRC_IP_LBN 16
+#define	FRF_BZ_SRC_IP_WIDTH 32
+#define	FRF_BZ_SRC_TCP_DEST_UDP_LBN 0
+#define	FRF_BZ_SRC_TCP_DEST_UDP_WIDTH 16
+
+/* RX_MAC_FILTER_TBL0: Receive Ethernet filter table */
+#define	FR_CZ_RX_MAC_FILTER_TBL0 0x00f00010
+#define	FR_CZ_RX_MAC_FILTER_TBL0_STEP 32
+#define	FR_CZ_RX_MAC_FILTER_TBL0_ROWS 512
+#define	FRF_CZ_RMFT_RSS_EN_LBN 75
+#define	FRF_CZ_RMFT_RSS_EN_WIDTH 1
+#define	FRF_CZ_RMFT_SCATTER_EN_LBN 74
+#define	FRF_CZ_RMFT_SCATTER_EN_WIDTH 1
+#define	FRF_CZ_RMFT_IP_OVERRIDE_LBN 73
+#define	FRF_CZ_RMFT_IP_OVERRIDE_WIDTH 1
+#define	FRF_CZ_RMFT_RXQ_ID_LBN 61
+#define	FRF_CZ_RMFT_RXQ_ID_WIDTH 12
+#define	FRF_CZ_RMFT_WILDCARD_MATCH_LBN 60
+#define	FRF_CZ_RMFT_WILDCARD_MATCH_WIDTH 1
+#define	FRF_CZ_RMFT_DEST_MAC_LBN 12
+#define	FRF_CZ_RMFT_DEST_MAC_WIDTH 48
+#define	FRF_CZ_RMFT_VLAN_ID_LBN 0
+#define	FRF_CZ_RMFT_VLAN_ID_WIDTH 12
+
+/* TIMER_TBL: Timer table */
+#define	FR_BZ_TIMER_TBL 0x00f70000
+#define	FR_BZ_TIMER_TBL_STEP 16
+#define	FR_CZ_TIMER_TBL_ROWS 1024
+#define	FR_BB_TIMER_TBL_ROWS 4096
+#define	FRF_CZ_TIMER_Q_EN_LBN 33
+#define	FRF_CZ_TIMER_Q_EN_WIDTH 1
+#define	FRF_CZ_INT_ARMD_LBN 32
+#define	FRF_CZ_INT_ARMD_WIDTH 1
+#define	FRF_CZ_INT_PEND_LBN 31
+#define	FRF_CZ_INT_PEND_WIDTH 1
+#define	FRF_CZ_HOST_NOTIFY_MODE_LBN 30
+#define	FRF_CZ_HOST_NOTIFY_MODE_WIDTH 1
+#define	FRF_CZ_RELOAD_TIMER_VAL_LBN 16
+#define	FRF_CZ_RELOAD_TIMER_VAL_WIDTH 14
+#define	FRF_CZ_TIMER_MODE_LBN 14
+#define	FRF_CZ_TIMER_MODE_WIDTH 2
+#define	FFE_CZ_TIMER_MODE_INT_HLDOFF 3
+#define	FFE_CZ_TIMER_MODE_TRIG_START 2
+#define	FFE_CZ_TIMER_MODE_IMMED_START 1
+#define	FFE_CZ_TIMER_MODE_DIS 0
+#define	FRF_BB_TIMER_MODE_LBN 12
+#define	FRF_BB_TIMER_MODE_WIDTH 2
+#define	FFE_BB_TIMER_MODE_INT_HLDOFF 2
+#define	FFE_BB_TIMER_MODE_TRIG_START 2
+#define	FFE_BB_TIMER_MODE_IMMED_START 1
+#define	FFE_BB_TIMER_MODE_DIS 0
+#define	FRF_CZ_TIMER_VAL_LBN 0
+#define	FRF_CZ_TIMER_VAL_WIDTH 14
+#define	FRF_BB_TIMER_VAL_LBN 0
+#define	FRF_BB_TIMER_VAL_WIDTH 12
+
+/* TX_PACE_TBL: Transmit pacing table */
+#define	FR_BZ_TX_PACE_TBL 0x00f80000
+#define	FR_BZ_TX_PACE_TBL_STEP 16
+#define	FR_CZ_TX_PACE_TBL_ROWS 1024
+#define	FR_BB_TX_PACE_TBL_ROWS 4096
+#define	FRF_BZ_TX_PACE_LBN 0
+#define	FRF_BZ_TX_PACE_WIDTH 5
+
+/* RX_INDIRECTION_TBL: RX Indirection Table */
+#define	FR_BZ_RX_INDIRECTION_TBL 0x00fb0000
+#define	FR_BZ_RX_INDIRECTION_TBL_STEP 16
+#define	FR_BZ_RX_INDIRECTION_TBL_ROWS 128
+#define	FRF_BZ_IT_QUEUE_LBN 0
+#define	FRF_BZ_IT_QUEUE_WIDTH 6
+
+/* TX_FILTER_TBL0: TCP/IPv4 Transmit filter table */
+#define	FR_CZ_TX_FILTER_TBL0 0x00fc0000
+#define	FR_CZ_TX_FILTER_TBL0_STEP 16
+#define	FR_CZ_TX_FILTER_TBL0_ROWS 8192
+#define	FRF_CZ_TIFT_TCP_UDP_LBN 108
+#define	FRF_CZ_TIFT_TCP_UDP_WIDTH 1
+#define	FRF_CZ_TIFT_TXQ_ID_LBN 96
+#define	FRF_CZ_TIFT_TXQ_ID_WIDTH 12
+#define	FRF_CZ_TIFT_DEST_IP_LBN 64
+#define	FRF_CZ_TIFT_DEST_IP_WIDTH 32
+#define	FRF_CZ_TIFT_DEST_PORT_TCP_LBN 48
+#define	FRF_CZ_TIFT_DEST_PORT_TCP_WIDTH 16
+#define	FRF_CZ_TIFT_SRC_IP_LBN 16
+#define	FRF_CZ_TIFT_SRC_IP_WIDTH 32
+#define	FRF_CZ_TIFT_SRC_TCP_DEST_UDP_LBN 0
+#define	FRF_CZ_TIFT_SRC_TCP_DEST_UDP_WIDTH 16
+
+/* TX_MAC_FILTER_TBL0: Transmit Ethernet filter table */
+#define	FR_CZ_TX_MAC_FILTER_TBL0 0x00fe0000
+#define	FR_CZ_TX_MAC_FILTER_TBL0_STEP 16
+#define	FR_CZ_TX_MAC_FILTER_TBL0_ROWS 512
+#define	FRF_CZ_TMFT_TXQ_ID_LBN 61
+#define	FRF_CZ_TMFT_TXQ_ID_WIDTH 12
+#define	FRF_CZ_TMFT_WILDCARD_MATCH_LBN 60
+#define	FRF_CZ_TMFT_WILDCARD_MATCH_WIDTH 1
+#define	FRF_CZ_TMFT_SRC_MAC_LBN 12
+#define	FRF_CZ_TMFT_SRC_MAC_WIDTH 48
+#define	FRF_CZ_TMFT_VLAN_ID_LBN 0
+#define	FRF_CZ_TMFT_VLAN_ID_WIDTH 12
+
+/* MC_TREG_SMEM: MC Shared Memory */
+#define	FR_CZ_MC_TREG_SMEM 0x00ff0000
+#define	FR_CZ_MC_TREG_SMEM_STEP 4
+#define	FR_CZ_MC_TREG_SMEM_ROWS 512
+#define	FRF_CZ_MC_TREG_SMEM_ROW_LBN 0
+#define	FRF_CZ_MC_TREG_SMEM_ROW_WIDTH 32
+
+/* MSIX_VECTOR_TABLE: MSIX Vector Table */
+#define	FR_BB_MSIX_VECTOR_TABLE 0x00ff0000
+#define	FR_BZ_MSIX_VECTOR_TABLE_STEP 16
+#define	FR_BB_MSIX_VECTOR_TABLE_ROWS 64
+/* MSIX_VECTOR_TABLE: MSIX Vector Table */
+#define	FR_CZ_MSIX_VECTOR_TABLE 0x00000000
+/* FR_BZ_MSIX_VECTOR_TABLE_STEP 16 */
+#define	FR_CZ_MSIX_VECTOR_TABLE_ROWS 1024
+#define	FRF_BZ_MSIX_VECTOR_RESERVED_LBN 97
+#define	FRF_BZ_MSIX_VECTOR_RESERVED_WIDTH 31
+#define	FRF_BZ_MSIX_VECTOR_MASK_LBN 96
+#define	FRF_BZ_MSIX_VECTOR_MASK_WIDTH 1
+#define	FRF_BZ_MSIX_MESSAGE_DATA_LBN 64
+#define	FRF_BZ_MSIX_MESSAGE_DATA_WIDTH 32
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_HI_LBN 32
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_HI_WIDTH 32
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_LO_LBN 0
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_LO_WIDTH 32
+
+/* MSIX_PBA_TABLE: MSIX Pending Bit Array */
+#define	FR_BB_MSIX_PBA_TABLE 0x00ff2000
+#define	FR_BZ_MSIX_PBA_TABLE_STEP 4
+#define	FR_BB_MSIX_PBA_TABLE_ROWS 2
+/* MSIX_PBA_TABLE: MSIX Pending Bit Array */
+#define	FR_CZ_MSIX_PBA_TABLE 0x00008000
+/* FR_BZ_MSIX_PBA_TABLE_STEP 4 */
+#define	FR_CZ_MSIX_PBA_TABLE_ROWS 32
+#define	FRF_BZ_MSIX_PBA_PEND_DWORD_LBN 0
+#define	FRF_BZ_MSIX_PBA_PEND_DWORD_WIDTH 32
+
+/* SRM_DBG_REG: SRAM debug access */
+#define	FR_BZ_SRM_DBG 0x03000000
+#define	FR_BZ_SRM_DBG_STEP 8
+#define	FR_CZ_SRM_DBG_ROWS 262144
+#define	FR_BB_SRM_DBG_ROWS 2097152
+#define	FRF_BZ_SRM_DBG_LBN 0
+#define	FRF_BZ_SRM_DBG_WIDTH 64
+
+/* TB_MSIX_PBA_TABLE: MSIX Pending Bit Array */
+#define	FR_CZ_TB_MSIX_PBA_TABLE 0x00008000
+#define	FR_CZ_TB_MSIX_PBA_TABLE_STEP 4
+#define	FR_CZ_TB_MSIX_PBA_TABLE_ROWS 1024
+#define	FRF_CZ_TB_MSIX_PBA_PEND_DWORD_LBN 0
+#define	FRF_CZ_TB_MSIX_PBA_PEND_DWORD_WIDTH 32
+
+/* DRIVER_EV */
+#define	FSF_AZ_DRIVER_EV_SUBCODE_LBN 56
+#define	FSF_AZ_DRIVER_EV_SUBCODE_WIDTH 4
+#define	FSE_BZ_TX_DSC_ERROR_EV 15
+#define	FSE_BZ_RX_DSC_ERROR_EV 14
+#define	FSE_AA_RX_RECOVER_EV 11
+#define	FSE_AZ_TIMER_EV 10
+#define	FSE_AZ_TX_PKT_NON_TCP_UDP 9
+#define	FSE_AZ_WAKE_UP_EV 6
+#define	FSE_AZ_SRM_UPD_DONE_EV 5
+#define	FSE_AB_EVQ_NOT_EN_EV 3
+#define	FSE_AZ_EVQ_INIT_DONE_EV 2
+#define	FSE_AZ_RX_DESCQ_FLS_DONE_EV 1
+#define	FSE_AZ_TX_DESCQ_FLS_DONE_EV 0
+#define	FSF_AZ_DRIVER_EV_SUBDATA_LBN 0
+#define	FSF_AZ_DRIVER_EV_SUBDATA_WIDTH 14
+
+/* EVENT_ENTRY */
+#define	FSF_AZ_EV_CODE_LBN 60
+#define	FSF_AZ_EV_CODE_WIDTH 4
+#define	FSE_CZ_EV_CODE_MCDI_EV 12
+#define	FSE_CZ_EV_CODE_USER_EV 8
+#define	FSE_AZ_EV_CODE_DRV_GEN_EV 7
+#define	FSE_AZ_EV_CODE_GLOBAL_EV 6
+#define	FSE_AZ_EV_CODE_DRIVER_EV 5
+#define	FSE_AZ_EV_CODE_TX_EV 2
+#define	FSE_AZ_EV_CODE_RX_EV 0
+#define	FSF_AZ_EV_DATA_LBN 0
+#define	FSF_AZ_EV_DATA_WIDTH 60
+
+/* GLOBAL_EV */
+#define	FSF_BB_GLB_EV_RX_RECOVERY_LBN 12
+#define	FSF_BB_GLB_EV_RX_RECOVERY_WIDTH 1
+#define	FSF_AA_GLB_EV_RX_RECOVERY_LBN 11
+#define	FSF_AA_GLB_EV_RX_RECOVERY_WIDTH 1
+#define	FSF_BB_GLB_EV_XG_MGT_INTR_LBN 11
+#define	FSF_BB_GLB_EV_XG_MGT_INTR_WIDTH 1
+#define	FSF_AB_GLB_EV_XFP_PHY0_INTR_LBN 10
+#define	FSF_AB_GLB_EV_XFP_PHY0_INTR_WIDTH 1
+#define	FSF_AB_GLB_EV_XG_PHY0_INTR_LBN 9
+#define	FSF_AB_GLB_EV_XG_PHY0_INTR_WIDTH 1
+#define	FSF_AB_GLB_EV_G_PHY0_INTR_LBN 7
+#define	FSF_AB_GLB_EV_G_PHY0_INTR_WIDTH 1
+
+/* LEGACY_INT_VEC */
+#define	FSF_AZ_NET_IVEC_FATAL_INT_LBN 64
+#define	FSF_AZ_NET_IVEC_FATAL_INT_WIDTH 1
+#define	FSF_AZ_NET_IVEC_INT_Q_LBN 40
+#define	FSF_AZ_NET_IVEC_INT_Q_WIDTH 4
+#define	FSF_AZ_NET_IVEC_INT_FLAG_LBN 32
+#define	FSF_AZ_NET_IVEC_INT_FLAG_WIDTH 1
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_HF_LBN 1
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_HF_WIDTH 1
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_AF_LBN 0
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_AF_WIDTH 1
+
+/* MC_XGMAC_FLTR_RULE_DEF */
+#define	FSF_CZ_MC_XFRC_MODE_LBN 416
+#define	FSF_CZ_MC_XFRC_MODE_WIDTH 1
+#define	FSE_CZ_MC_XFRC_MODE_LAYERED 1
+#define	FSE_CZ_MC_XFRC_MODE_SIMPLE 0
+#define	FSF_CZ_MC_XFRC_HASH_LBN 384
+#define	FSF_CZ_MC_XFRC_HASH_WIDTH 32
+#define	FSF_CZ_MC_XFRC_LAYER4_BYTE_MASK_LBN 256
+#define	FSF_CZ_MC_XFRC_LAYER4_BYTE_MASK_WIDTH 128
+#define	FSF_CZ_MC_XFRC_LAYER3_BYTE_MASK_LBN 128
+#define	FSF_CZ_MC_XFRC_LAYER3_BYTE_MASK_WIDTH 128
+#define	FSF_CZ_MC_XFRC_LAYER2_OR_SIMPLE_BYTE_MASK_LBN 0
+#define	FSF_CZ_MC_XFRC_LAYER2_OR_SIMPLE_BYTE_MASK_WIDTH 128
+
+/* RX_EV */
+#define	FSF_CZ_RX_EV_PKT_NOT_PARSED_LBN 58
+#define	FSF_CZ_RX_EV_PKT_NOT_PARSED_WIDTH 1
+#define	FSF_CZ_RX_EV_IPV6_PKT_LBN 57
+#define	FSF_CZ_RX_EV_IPV6_PKT_WIDTH 1
+#define	FSF_AZ_RX_EV_PKT_OK_LBN 56
+#define	FSF_AZ_RX_EV_PKT_OK_WIDTH 1
+#define	FSF_AZ_RX_EV_PAUSE_FRM_ERR_LBN 55
+#define	FSF_AZ_RX_EV_PAUSE_FRM_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_BUF_OWNER_ID_ERR_LBN 54
+#define	FSF_AZ_RX_EV_BUF_OWNER_ID_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_IP_FRAG_ERR_LBN 53
+#define	FSF_AZ_RX_EV_IP_FRAG_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_IP_HDR_CHKSUM_ERR_LBN 52
+#define	FSF_AZ_RX_EV_IP_HDR_CHKSUM_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR_LBN 51
+#define	FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_ETH_CRC_ERR_LBN 50
+#define	FSF_AZ_RX_EV_ETH_CRC_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_FRM_TRUNC_LBN 49
+#define	FSF_AZ_RX_EV_FRM_TRUNC_WIDTH 1
+#define	FSF_AA_RX_EV_DRIB_NIB_LBN 49
+#define	FSF_AA_RX_EV_DRIB_NIB_WIDTH 1
+#define	FSF_AZ_RX_EV_TOBE_DISC_LBN 47
+#define	FSF_AZ_RX_EV_TOBE_DISC_WIDTH 1
+#define	FSF_AZ_RX_EV_PKT_TYPE_LBN 44
+#define	FSF_AZ_RX_EV_PKT_TYPE_WIDTH 3
+#define	FSE_AZ_RX_EV_PKT_TYPE_VLAN_JUMBO 5
+#define	FSE_AZ_RX_EV_PKT_TYPE_VLAN_LLC 4
+#define	FSE_AZ_RX_EV_PKT_TYPE_VLAN 3
+#define	FSE_AZ_RX_EV_PKT_TYPE_JUMBO 2
+#define	FSE_AZ_RX_EV_PKT_TYPE_LLC 1
+#define	FSE_AZ_RX_EV_PKT_TYPE_ETH 0
+#define	FSF_AZ_RX_EV_HDR_TYPE_LBN 42
+#define	FSF_AZ_RX_EV_HDR_TYPE_WIDTH 2
+#define	FSE_AZ_RX_EV_HDR_TYPE_OTHER 3
+#define	FSE_AB_RX_EV_HDR_TYPE_IPV4_OTHER 2
+#define	FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_OTHER 2
+#define	FSE_AB_RX_EV_HDR_TYPE_IPV4_UDP 1
+#define	FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP 1
+#define	FSE_AB_RX_EV_HDR_TYPE_IPV4_TCP 0
+#define	FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP 0
+#define	FSF_AZ_RX_EV_DESC_Q_EMPTY_LBN 41
+#define	FSF_AZ_RX_EV_DESC_Q_EMPTY_WIDTH 1
+#define	FSF_AZ_RX_EV_MCAST_HASH_MATCH_LBN 40
+#define	FSF_AZ_RX_EV_MCAST_HASH_MATCH_WIDTH 1
+#define	FSF_AZ_RX_EV_MCAST_PKT_LBN 39
+#define	FSF_AZ_RX_EV_MCAST_PKT_WIDTH 1
+#define	FSF_AA_RX_EV_RECOVERY_FLAG_LBN 37
+#define	FSF_AA_RX_EV_RECOVERY_FLAG_WIDTH 1
+#define	FSF_AZ_RX_EV_Q_LABEL_LBN 32
+#define	FSF_AZ_RX_EV_Q_LABEL_WIDTH 5
+#define	FSF_AZ_RX_EV_JUMBO_CONT_LBN 31
+#define	FSF_AZ_RX_EV_JUMBO_CONT_WIDTH 1
+#define	FSF_AZ_RX_EV_PORT_LBN 30
+#define	FSF_AZ_RX_EV_PORT_WIDTH 1
+#define	FSF_AZ_RX_EV_BYTE_CNT_LBN 16
+#define	FSF_AZ_RX_EV_BYTE_CNT_WIDTH 14
+#define	FSF_AZ_RX_EV_SOP_LBN 15
+#define	FSF_AZ_RX_EV_SOP_WIDTH 1
+#define	FSF_AZ_RX_EV_ISCSI_PKT_OK_LBN 14
+#define	FSF_AZ_RX_EV_ISCSI_PKT_OK_WIDTH 1
+#define	FSF_AZ_RX_EV_ISCSI_DDIG_ERR_LBN 13
+#define	FSF_AZ_RX_EV_ISCSI_DDIG_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_ISCSI_HDIG_ERR_LBN 12
+#define	FSF_AZ_RX_EV_ISCSI_HDIG_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_DESC_PTR_LBN 0
+#define	FSF_AZ_RX_EV_DESC_PTR_WIDTH 12
+
+/* RX_KER_DESC */
+#define	FSF_AZ_RX_KER_BUF_SIZE_LBN 48
+#define	FSF_AZ_RX_KER_BUF_SIZE_WIDTH 14
+#define	FSF_AZ_RX_KER_BUF_REGION_LBN 46
+#define	FSF_AZ_RX_KER_BUF_REGION_WIDTH 2
+#define	FSF_AZ_RX_KER_BUF_ADDR_LBN 0
+#define	FSF_AZ_RX_KER_BUF_ADDR_WIDTH 46
+
+/* RX_USER_DESC */
+#define	FSF_AZ_RX_USER_2BYTE_OFFSET_LBN 20
+#define	FSF_AZ_RX_USER_2BYTE_OFFSET_WIDTH 12
+#define	FSF_AZ_RX_USER_BUF_ID_LBN 0
+#define	FSF_AZ_RX_USER_BUF_ID_WIDTH 20
+
+/* TX_EV */
+#define	FSF_AZ_TX_EV_PKT_ERR_LBN 38
+#define	FSF_AZ_TX_EV_PKT_ERR_WIDTH 1
+#define	FSF_AZ_TX_EV_PKT_TOO_BIG_LBN 37
+#define	FSF_AZ_TX_EV_PKT_TOO_BIG_WIDTH 1
+#define	FSF_AZ_TX_EV_Q_LABEL_LBN 32
+#define	FSF_AZ_TX_EV_Q_LABEL_WIDTH 5
+#define	FSF_AZ_TX_EV_PORT_LBN 16
+#define	FSF_AZ_TX_EV_PORT_WIDTH 1
+#define	FSF_AZ_TX_EV_WQ_FF_FULL_LBN 15
+#define	FSF_AZ_TX_EV_WQ_FF_FULL_WIDTH 1
+#define	FSF_AZ_TX_EV_BUF_OWNER_ID_ERR_LBN 14
+#define	FSF_AZ_TX_EV_BUF_OWNER_ID_ERR_WIDTH 1
+#define	FSF_AZ_TX_EV_COMP_LBN 12
+#define	FSF_AZ_TX_EV_COMP_WIDTH 1
+#define	FSF_AZ_TX_EV_DESC_PTR_LBN 0
+#define	FSF_AZ_TX_EV_DESC_PTR_WIDTH 12
+
+/* TX_KER_DESC */
+#define	FSF_AZ_TX_KER_CONT_LBN 62
+#define	FSF_AZ_TX_KER_CONT_WIDTH 1
+#define	FSF_AZ_TX_KER_BYTE_COUNT_LBN 48
+#define	FSF_AZ_TX_KER_BYTE_COUNT_WIDTH 14
+#define	FSF_AZ_TX_KER_BUF_REGION_LBN 46
+#define	FSF_AZ_TX_KER_BUF_REGION_WIDTH 2
+#define	FSF_AZ_TX_KER_BUF_ADDR_LBN 0
+#define	FSF_AZ_TX_KER_BUF_ADDR_WIDTH 46
+
+/* TX_USER_DESC */
+#define	FSF_AZ_TX_USER_SW_EV_EN_LBN 48
+#define	FSF_AZ_TX_USER_SW_EV_EN_WIDTH 1
+#define	FSF_AZ_TX_USER_CONT_LBN 46
+#define	FSF_AZ_TX_USER_CONT_WIDTH 1
+#define	FSF_AZ_TX_USER_BYTE_CNT_LBN 33
+#define	FSF_AZ_TX_USER_BYTE_CNT_WIDTH 13
+#define	FSF_AZ_TX_USER_BUF_ID_LBN 13
+#define	FSF_AZ_TX_USER_BUF_ID_WIDTH 20
+#define	FSF_AZ_TX_USER_BYTE_OFS_LBN 0
+#define	FSF_AZ_TX_USER_BYTE_OFS_WIDTH 13
+
+/* USER_EV */
+#define	FSF_CZ_USER_QID_LBN 32
+#define	FSF_CZ_USER_QID_WIDTH 10
+#define	FSF_CZ_USER_EV_REG_VALUE_LBN 0
+#define	FSF_CZ_USER_EV_REG_VALUE_WIDTH 32
+
+/**************************************************************************
+ *
+ * Falcon B0 PCIe core indirect registers
+ *
+ **************************************************************************
+ */
+
+#define FPCR_BB_PCIE_DEVICE_CTRL_STAT 0x68
+
+#define FPCR_BB_PCIE_LINK_CTRL_STAT 0x70
+
+#define FPCR_BB_ACK_RPL_TIMER 0x700
+#define FPCRF_BB_ACK_TL_LBN 0
+#define FPCRF_BB_ACK_TL_WIDTH 16
+#define FPCRF_BB_RPL_TL_LBN 16
+#define FPCRF_BB_RPL_TL_WIDTH 16
+
+#define FPCR_BB_ACK_FREQ 0x70C
+#define FPCRF_BB_ACK_FREQ_LBN 0
+#define FPCRF_BB_ACK_FREQ_WIDTH 7
+
+/**************************************************************************
+ *
+ * Pseudo-registers and fields
+ *
+ **************************************************************************
+ */
+
+/* Interrupt acknowledge work-around register (A0/A1 only) */
+#define FR_AA_WORK_AROUND_BROKEN_PCI_READS 0x0070
+
+/* EE_SPI_HCMD_REG: SPI host command register */
+/* Values for the EE_SPI_HCMD_SF_SEL register field */
+#define FFE_AB_SPI_DEVICE_EEPROM 0
+#define FFE_AB_SPI_DEVICE_FLASH 1
+
+/* NIC_STAT_REG: NIC status register */
+#define FRF_AB_STRAP_10G_LBN 2
+#define FRF_AB_STRAP_10G_WIDTH 1
+#define FRF_AA_STRAP_PCIE_LBN 0
+#define FRF_AA_STRAP_PCIE_WIDTH 1
+
+/* FATAL_INTR_REG_KER: Fatal interrupt register for Kernel */
+#define FRF_AZ_FATAL_INTR_LBN 0
+#define FRF_AZ_FATAL_INTR_WIDTH 12
+
+/* SRM_CFG_REG: SRAM configuration register */
+/* We treat the number of SRAM banks and bank size as a single field */
+#define	FRF_AZ_SRM_NB_SZ_LBN FRF_AZ_SRM_BANK_SIZE_LBN
+#define	FRF_AZ_SRM_NB_SZ_WIDTH \
+	(FRF_AZ_SRM_BANK_SIZE_WIDTH + FRF_AZ_SRM_NUM_BANK_WIDTH)
+#define FFE_AB_SRM_NB1_SZ2M 0
+#define FFE_AB_SRM_NB1_SZ4M 1
+#define FFE_AB_SRM_NB1_SZ8M 2
+#define FFE_AB_SRM_NB_SZ_DEF 3
+#define FFE_AB_SRM_NB2_SZ4M 4
+#define FFE_AB_SRM_NB2_SZ8M 5
+#define FFE_AB_SRM_NB2_SZ16M 6
+#define FFE_AB_SRM_NB_SZ_RES 7
+
+/* RX_DESC_UPD_REGP0: Receive descriptor update register. */
+/* We write just the last dword of these registers */
+#define	FR_AZ_RX_DESC_UPD_DWORD_P0 \
+	(BUILD_BUG_ON_ZERO(FR_AA_RX_DESC_UPD_KER != FR_BZ_RX_DESC_UPD_P0) + \
+	 FR_BZ_RX_DESC_UPD_P0 + 3 * 4)
+#define	FRF_AZ_RX_DESC_WPTR_DWORD_LBN (FRF_AZ_RX_DESC_WPTR_LBN - 3 * 32)
+#define	FRF_AZ_RX_DESC_WPTR_DWORD_WIDTH FRF_AZ_RX_DESC_WPTR_WIDTH
+
+/* TX_DESC_UPD_REGP0: Transmit descriptor update register. */
+#define FR_AZ_TX_DESC_UPD_DWORD_P0 \
+	(BUILD_BUG_ON_ZERO(FR_AA_TX_DESC_UPD_KER != FR_BZ_TX_DESC_UPD_P0) + \
+	 FR_BZ_TX_DESC_UPD_P0 + 3 * 4)
+#define	FRF_AZ_TX_DESC_WPTR_DWORD_LBN (FRF_AZ_TX_DESC_WPTR_LBN - 3 * 32)
+#define	FRF_AZ_TX_DESC_WPTR_DWORD_WIDTH FRF_AZ_TX_DESC_WPTR_WIDTH
+
+/* GMF_CFG4_REG: GMAC FIFO configuration register 4 */
+#define FRF_AB_GMF_HSTFLTRFRM_PAUSE_LBN 12
+#define FRF_AB_GMF_HSTFLTRFRM_PAUSE_WIDTH 1
+
+/* GMF_CFG5_REG: GMAC FIFO configuration register 5 */
+#define FRF_AB_GMF_HSTFLTRFRMDC_PAUSE_LBN 12
+#define FRF_AB_GMF_HSTFLTRFRMDC_PAUSE_WIDTH 1
+
+/* XM_TX_PARAM_REG: XGMAC transmit parameter register */
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_LBN FRF_AB_XM_MAX_TX_FRM_SIZE_LO_LBN
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_WIDTH (FRF_AB_XM_MAX_TX_FRM_SIZE_HI_WIDTH + \
+					 FRF_AB_XM_MAX_TX_FRM_SIZE_LO_WIDTH)
+
+/* XM_RX_PARAM_REG: XGMAC receive parameter register */
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_LBN FRF_AB_XM_MAX_RX_FRM_SIZE_LO_LBN
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_WIDTH (FRF_AB_XM_MAX_RX_FRM_SIZE_HI_WIDTH + \
+					 FRF_AB_XM_MAX_RX_FRM_SIZE_LO_WIDTH)
+
+/* XX_TXDRV_CTL_REG: XAUI SerDes transmit drive control register */
+/* Default values */
+#define FFE_AB_XX_TXDRV_DEQ_DEF 0xe /* deq=.6 */
+#define FFE_AB_XX_TXDRV_DTX_DEF 0x5 /* 1.25 */
+#define FFE_AB_XX_SD_CTL_DRV_DEF 0  /* 20mA */
+
+/* XX_CORE_STAT_REG: XAUI XGXS core status register */
+/* XGXS all-lanes status fields */
+#define	FRF_AB_XX_SYNC_STAT_LBN FRF_AB_XX_SYNC_STAT0_LBN
+#define	FRF_AB_XX_SYNC_STAT_WIDTH 4
+#define	FRF_AB_XX_COMMA_DET_LBN FRF_AB_XX_COMMA_DET_CH0_LBN
+#define	FRF_AB_XX_COMMA_DET_WIDTH 4
+#define	FRF_AB_XX_CHAR_ERR_LBN FRF_AB_XX_CHAR_ERR_CH0_LBN
+#define	FRF_AB_XX_CHAR_ERR_WIDTH 4
+#define	FRF_AB_XX_DISPERR_LBN FRF_AB_XX_DISPERR_CH0_LBN
+#define	FRF_AB_XX_DISPERR_WIDTH 4
+#define	FFE_AB_XX_STAT_ALL_LANES 0xf
+#define	FRF_AB_XX_FORCE_SIG_LBN FRF_AB_XX_FORCE_SIG0_VAL_LBN
+#define	FRF_AB_XX_FORCE_SIG_WIDTH 8
+#define	FFE_AB_XX_FORCE_SIG_ALL_LANES 0xff
+
+/* RX_MAC_FILTER_TBL0 */
+/* RMFT_DEST_MAC is wider than 32 bits */
+#define FRF_CZ_RMFT_DEST_MAC_LO_LBN FRF_CZ_RMFT_DEST_MAC_LBN
+#define FRF_CZ_RMFT_DEST_MAC_LO_WIDTH 32
+#define FRF_CZ_RMFT_DEST_MAC_HI_LBN (FRF_CZ_RMFT_DEST_MAC_LBN + 32)
+#define FRF_CZ_RMFT_DEST_MAC_HI_WIDTH (FRF_CZ_RMFT_DEST_MAC_WIDTH - 32)
+
+/* TX_MAC_FILTER_TBL0 */
+/* TMFT_SRC_MAC is wider than 32 bits */
+#define FRF_CZ_TMFT_SRC_MAC_LO_LBN FRF_CZ_TMFT_SRC_MAC_LBN
+#define FRF_CZ_TMFT_SRC_MAC_LO_WIDTH 32
+#define FRF_CZ_TMFT_SRC_MAC_HI_LBN (FRF_CZ_TMFT_SRC_MAC_LBN + 32)
+#define FRF_CZ_TMFT_SRC_MAC_HI_WIDTH (FRF_CZ_TMFT_SRC_MAC_WIDTH - 32)
+
+/* TX_PACE_TBL */
+/* Values >20 are documented as reserved, but will result in a queue going
+ * into the fast bin with a pace value of zero. */
+#define FFE_BZ_TX_PACE_OFF 0
+#define FFE_BZ_TX_PACE_RESERVED 21
+
+/* DRIVER_EV */
+/* Sub-fields of an RX flush completion event */
+#define FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL_LBN 12
+#define FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL_WIDTH 1
+#define FSF_AZ_DRIVER_EV_RX_DESCQ_ID_LBN 0
+#define FSF_AZ_DRIVER_EV_RX_DESCQ_ID_WIDTH 12
+
+/* EVENT_ENTRY */
+/* Magic number field for event test */
+#define FSF_AZ_DRV_GEN_EV_MAGIC_LBN 0
+#define FSF_AZ_DRV_GEN_EV_MAGIC_WIDTH 32
+
+/* RX packet prefix */
+#define FS_BZ_RX_PREFIX_HASH_OFST 12
+#define FS_BZ_RX_PREFIX_SIZE 16
+
+#endif /* EF4_FARCH_REGS_H */
diff --git a/drivers/net/ethernet/sfc/falcon/filter.h b/drivers/net/ethernet/sfc/falcon/filter.h
new file mode 100644
index 0000000..647f6b2
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/filter.h
@@ -0,0 +1,272 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_FILTER_H
+#define EF4_FILTER_H
+
+#include <linux/types.h>
+#include <linux/if_ether.h>
+#include <asm/byteorder.h>
+
+/**
+ * enum ef4_filter_match_flags - Flags for hardware filter match type
+ * @EF4_FILTER_MATCH_REM_HOST: Match by remote IP host address
+ * @EF4_FILTER_MATCH_LOC_HOST: Match by local IP host address
+ * @EF4_FILTER_MATCH_REM_MAC: Match by remote MAC address
+ * @EF4_FILTER_MATCH_REM_PORT: Match by remote TCP/UDP port
+ * @EF4_FILTER_MATCH_LOC_MAC: Match by local MAC address
+ * @EF4_FILTER_MATCH_LOC_PORT: Match by local TCP/UDP port
+ * @EF4_FILTER_MATCH_ETHER_TYPE: Match by Ether-type
+ * @EF4_FILTER_MATCH_INNER_VID: Match by inner VLAN ID
+ * @EF4_FILTER_MATCH_OUTER_VID: Match by outer VLAN ID
+ * @EF4_FILTER_MATCH_IP_PROTO: Match by IP transport protocol
+ * @EF4_FILTER_MATCH_LOC_MAC_IG: Match by local MAC address I/G bit.
+ *	Used for RX default unicast and multicast/broadcast filters.
+ *
+ * Only some combinations are supported, depending on NIC type:
+ *
+ * - Falcon supports RX filters matching by {TCP,UDP}/IPv4 4-tuple or
+ *   local 2-tuple (only implemented for Falcon B0)
+ *
+ * - Siena supports RX and TX filters matching by {TCP,UDP}/IPv4 4-tuple
+ *   or local 2-tuple, or local MAC with or without outer VID, and RX
+ *   default filters
+ *
+ * - Huntington supports filter matching controlled by firmware, potentially
+ *   using {TCP,UDP}/IPv{4,6} 4-tuple or local 2-tuple, local MAC or I/G bit,
+ *   with or without outer and inner VID
+ */
+enum ef4_filter_match_flags {
+	EF4_FILTER_MATCH_REM_HOST =	0x0001,
+	EF4_FILTER_MATCH_LOC_HOST =	0x0002,
+	EF4_FILTER_MATCH_REM_MAC =	0x0004,
+	EF4_FILTER_MATCH_REM_PORT =	0x0008,
+	EF4_FILTER_MATCH_LOC_MAC =	0x0010,
+	EF4_FILTER_MATCH_LOC_PORT =	0x0020,
+	EF4_FILTER_MATCH_ETHER_TYPE =	0x0040,
+	EF4_FILTER_MATCH_INNER_VID =	0x0080,
+	EF4_FILTER_MATCH_OUTER_VID =	0x0100,
+	EF4_FILTER_MATCH_IP_PROTO =	0x0200,
+	EF4_FILTER_MATCH_LOC_MAC_IG =	0x0400,
+};
+
+/**
+ * enum ef4_filter_priority - priority of a hardware filter specification
+ * @EF4_FILTER_PRI_HINT: Performance hint
+ * @EF4_FILTER_PRI_AUTO: Automatic filter based on device address list
+ *	or hardware requirements.  This may only be used by the filter
+ *	implementation for each NIC type.
+ * @EF4_FILTER_PRI_MANUAL: Manually configured filter
+ * @EF4_FILTER_PRI_REQUIRED: Required for correct behaviour (user-level
+ *	networking and SR-IOV)
+ */
+enum ef4_filter_priority {
+	EF4_FILTER_PRI_HINT = 0,
+	EF4_FILTER_PRI_AUTO,
+	EF4_FILTER_PRI_MANUAL,
+	EF4_FILTER_PRI_REQUIRED,
+};
+
+/**
+ * enum ef4_filter_flags - flags for hardware filter specifications
+ * @EF4_FILTER_FLAG_RX_RSS: Use RSS to spread across multiple queues.
+ *	By default, matching packets will be delivered only to the
+ *	specified queue. If this flag is set, they will be delivered
+ *	to a range of queues offset from the specified queue number
+ *	according to the indirection table.
+ * @EF4_FILTER_FLAG_RX_SCATTER: Enable DMA scatter on the receiving
+ *	queue.
+ * @EF4_FILTER_FLAG_RX_OVER_AUTO: Indicates a filter that is
+ *	overriding an automatic filter (priority
+ *	%EF4_FILTER_PRI_AUTO).  This may only be set by the filter
+ *	implementation for each type.  A removal request will restore
+ *	the automatic filter in its place.
+ * @EF4_FILTER_FLAG_RX: Filter is for RX
+ * @EF4_FILTER_FLAG_TX: Filter is for TX
+ */
+enum ef4_filter_flags {
+	EF4_FILTER_FLAG_RX_RSS = 0x01,
+	EF4_FILTER_FLAG_RX_SCATTER = 0x02,
+	EF4_FILTER_FLAG_RX_OVER_AUTO = 0x04,
+	EF4_FILTER_FLAG_RX = 0x08,
+	EF4_FILTER_FLAG_TX = 0x10,
+};
+
+/**
+ * struct ef4_filter_spec - specification for a hardware filter
+ * @match_flags: Match type flags, from &enum ef4_filter_match_flags
+ * @priority: Priority of the filter, from &enum ef4_filter_priority
+ * @flags: Miscellaneous flags, from &enum ef4_filter_flags
+ * @rss_context: RSS context to use, if %EF4_FILTER_FLAG_RX_RSS is set
+ * @dmaq_id: Source/target queue index, or %EF4_FILTER_RX_DMAQ_ID_DROP for
+ *	an RX drop filter
+ * @outer_vid: Outer VLAN ID to match, if %EF4_FILTER_MATCH_OUTER_VID is set
+ * @inner_vid: Inner VLAN ID to match, if %EF4_FILTER_MATCH_INNER_VID is set
+ * @loc_mac: Local MAC address to match, if %EF4_FILTER_MATCH_LOC_MAC or
+ *	%EF4_FILTER_MATCH_LOC_MAC_IG is set
+ * @rem_mac: Remote MAC address to match, if %EF4_FILTER_MATCH_REM_MAC is set
+ * @ether_type: Ether-type to match, if %EF4_FILTER_MATCH_ETHER_TYPE is set
+ * @ip_proto: IP transport protocol to match, if %EF4_FILTER_MATCH_IP_PROTO
+ *	is set
+ * @loc_host: Local IP host to match, if %EF4_FILTER_MATCH_LOC_HOST is set
+ * @rem_host: Remote IP host to match, if %EF4_FILTER_MATCH_REM_HOST is set
+ * @loc_port: Local TCP/UDP port to match, if %EF4_FILTER_MATCH_LOC_PORT is set
+ * @rem_port: Remote TCP/UDP port to match, if %EF4_FILTER_MATCH_REM_PORT is set
+ *
+ * The ef4_filter_init_rx() or ef4_filter_init_tx() function *must* be
+ * used to initialise the structure.  The ef4_filter_set_*() functions
+ * may then be used to set @rss_context, @match_flags and related
+ * fields.
+ *
+ * The @priority field is used by software to determine whether a new
+ * filter may replace an old one.  The hardware priority of a filter
+ * depends on which fields are matched.
+ */
+struct ef4_filter_spec {
+	u32	match_flags:12;
+	u32	priority:2;
+	u32	flags:6;
+	u32	dmaq_id:12;
+	u32	rss_context;
+	__be16	outer_vid __aligned(4); /* allow jhash2() of match values */
+	__be16	inner_vid;
+	u8	loc_mac[ETH_ALEN];
+	u8	rem_mac[ETH_ALEN];
+	__be16	ether_type;
+	u8	ip_proto;
+	__be32	loc_host[4];
+	__be32	rem_host[4];
+	__be16	loc_port;
+	__be16	rem_port;
+	/* total 64 bytes */
+};
+
+enum {
+	EF4_FILTER_RSS_CONTEXT_DEFAULT = 0xffffffff,
+	EF4_FILTER_RX_DMAQ_ID_DROP = 0xfff
+};
+
+static inline void ef4_filter_init_rx(struct ef4_filter_spec *spec,
+				      enum ef4_filter_priority priority,
+				      enum ef4_filter_flags flags,
+				      unsigned rxq_id)
+{
+	memset(spec, 0, sizeof(*spec));
+	spec->priority = priority;
+	spec->flags = EF4_FILTER_FLAG_RX | flags;
+	spec->rss_context = EF4_FILTER_RSS_CONTEXT_DEFAULT;
+	spec->dmaq_id = rxq_id;
+}
+
+static inline void ef4_filter_init_tx(struct ef4_filter_spec *spec,
+				      unsigned txq_id)
+{
+	memset(spec, 0, sizeof(*spec));
+	spec->priority = EF4_FILTER_PRI_REQUIRED;
+	spec->flags = EF4_FILTER_FLAG_TX;
+	spec->dmaq_id = txq_id;
+}
+
+/**
+ * ef4_filter_set_ipv4_local - specify IPv4 host, transport protocol and port
+ * @spec: Specification to initialise
+ * @proto: Transport layer protocol number
+ * @host: Local host address (network byte order)
+ * @port: Local port (network byte order)
+ */
+static inline int
+ef4_filter_set_ipv4_local(struct ef4_filter_spec *spec, u8 proto,
+			  __be32 host, __be16 port)
+{
+	spec->match_flags |=
+		EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_IP_PROTO |
+		EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_LOC_PORT;
+	spec->ether_type = htons(ETH_P_IP);
+	spec->ip_proto = proto;
+	spec->loc_host[0] = host;
+	spec->loc_port = port;
+	return 0;
+}
+
+/**
+ * ef4_filter_set_ipv4_full - specify IPv4 hosts, transport protocol and ports
+ * @spec: Specification to initialise
+ * @proto: Transport layer protocol number
+ * @lhost: Local host address (network byte order)
+ * @lport: Local port (network byte order)
+ * @rhost: Remote host address (network byte order)
+ * @rport: Remote port (network byte order)
+ */
+static inline int
+ef4_filter_set_ipv4_full(struct ef4_filter_spec *spec, u8 proto,
+			 __be32 lhost, __be16 lport,
+			 __be32 rhost, __be16 rport)
+{
+	spec->match_flags |=
+		EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_IP_PROTO |
+		EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_LOC_PORT |
+		EF4_FILTER_MATCH_REM_HOST | EF4_FILTER_MATCH_REM_PORT;
+	spec->ether_type = htons(ETH_P_IP);
+	spec->ip_proto = proto;
+	spec->loc_host[0] = lhost;
+	spec->loc_port = lport;
+	spec->rem_host[0] = rhost;
+	spec->rem_port = rport;
+	return 0;
+}
+
+enum {
+	EF4_FILTER_VID_UNSPEC = 0xffff,
+};
+
+/**
+ * ef4_filter_set_eth_local - specify local Ethernet address and/or VID
+ * @spec: Specification to initialise
+ * @vid: Outer VLAN ID to match, or %EF4_FILTER_VID_UNSPEC
+ * @addr: Local Ethernet MAC address, or %NULL
+ */
+static inline int ef4_filter_set_eth_local(struct ef4_filter_spec *spec,
+					   u16 vid, const u8 *addr)
+{
+	if (vid == EF4_FILTER_VID_UNSPEC && addr == NULL)
+		return -EINVAL;
+
+	if (vid != EF4_FILTER_VID_UNSPEC) {
+		spec->match_flags |= EF4_FILTER_MATCH_OUTER_VID;
+		spec->outer_vid = htons(vid);
+	}
+	if (addr != NULL) {
+		spec->match_flags |= EF4_FILTER_MATCH_LOC_MAC;
+		ether_addr_copy(spec->loc_mac, addr);
+	}
+	return 0;
+}
+
+/**
+ * ef4_filter_set_uc_def - specify matching otherwise-unmatched unicast
+ * @spec: Specification to initialise
+ */
+static inline int ef4_filter_set_uc_def(struct ef4_filter_spec *spec)
+{
+	spec->match_flags |= EF4_FILTER_MATCH_LOC_MAC_IG;
+	return 0;
+}
+
+/**
+ * ef4_filter_set_mc_def - specify matching otherwise-unmatched multicast
+ * @spec: Specification to initialise
+ */
+static inline int ef4_filter_set_mc_def(struct ef4_filter_spec *spec)
+{
+	spec->match_flags |= EF4_FILTER_MATCH_LOC_MAC_IG;
+	spec->loc_mac[0] = 1;
+	return 0;
+}
+
+#endif /* EF4_FILTER_H */
diff --git a/drivers/net/ethernet/sfc/falcon/io.h b/drivers/net/ethernet/sfc/falcon/io.h
new file mode 100644
index 0000000..7085ee1
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/io.h
@@ -0,0 +1,290 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_IO_H
+#define EF4_IO_H
+
+#include <linux/io.h>
+#include <linux/spinlock.h>
+
+/**************************************************************************
+ *
+ * NIC register I/O
+ *
+ **************************************************************************
+ *
+ * Notes on locking strategy for the Falcon architecture:
+ *
+ * Many CSRs are very wide and cannot be read or written atomically.
+ * Writes from the host are buffered by the Bus Interface Unit (BIU)
+ * up to 128 bits.  Whenever the host writes part of such a register,
+ * the BIU collects the written value and does not write to the
+ * underlying register until all 4 dwords have been written.  A
+ * similar buffering scheme applies to host access to the NIC's 64-bit
+ * SRAM.
+ *
+ * Writes to different CSRs and 64-bit SRAM words must be serialised,
+ * since interleaved access can result in lost writes.  We use
+ * ef4_nic::biu_lock for this.
+ *
+ * We also serialise reads from 128-bit CSRs and SRAM with the same
+ * spinlock.  This may not be necessary, but it doesn't really matter
+ * as there are no such reads on the fast path.
+ *
+ * The DMA descriptor pointers (RX_DESC_UPD and TX_DESC_UPD) are
+ * 128-bit but are special-cased in the BIU to avoid the need for
+ * locking in the host:
+ *
+ * - They are write-only.
+ * - The semantics of writing to these registers are such that
+ *   replacing the low 96 bits with zero does not affect functionality.
+ * - If the host writes to the last dword address of such a register
+ *   (i.e. the high 32 bits) the underlying register will always be
+ *   written.  If the collector and the current write together do not
+ *   provide values for all 128 bits of the register, the low 96 bits
+ *   will be written as zero.
+ * - If the host writes to the address of any other part of such a
+ *   register while the collector already holds values for some other
+ *   register, the write is discarded and the collector maintains its
+ *   current state.
+ *
+ * The EF10 architecture exposes very few registers to the host and
+ * most of them are only 32 bits wide.  The only exceptions are the MC
+ * doorbell register pair, which has its own latching, and
+ * TX_DESC_UPD, which works in a similar way to the Falcon
+ * architecture.
+ */
+
+#if BITS_PER_LONG == 64
+#define EF4_USE_QWORD_IO 1
+#endif
+
+#ifdef EF4_USE_QWORD_IO
+static inline void _ef4_writeq(struct ef4_nic *efx, __le64 value,
+				  unsigned int reg)
+{
+	__raw_writeq((__force u64)value, efx->membase + reg);
+}
+static inline __le64 _ef4_readq(struct ef4_nic *efx, unsigned int reg)
+{
+	return (__force __le64)__raw_readq(efx->membase + reg);
+}
+#endif
+
+static inline void _ef4_writed(struct ef4_nic *efx, __le32 value,
+				  unsigned int reg)
+{
+	__raw_writel((__force u32)value, efx->membase + reg);
+}
+static inline __le32 _ef4_readd(struct ef4_nic *efx, unsigned int reg)
+{
+	return (__force __le32)__raw_readl(efx->membase + reg);
+}
+
+/* Write a normal 128-bit CSR, locking as appropriate. */
+static inline void ef4_writeo(struct ef4_nic *efx, const ef4_oword_t *value,
+			      unsigned int reg)
+{
+	unsigned long flags __attribute__ ((unused));
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing register %x with " EF4_OWORD_FMT "\n", reg,
+		   EF4_OWORD_VAL(*value));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+#ifdef EF4_USE_QWORD_IO
+	_ef4_writeq(efx, value->u64[0], reg + 0);
+	_ef4_writeq(efx, value->u64[1], reg + 8);
+#else
+	_ef4_writed(efx, value->u32[0], reg + 0);
+	_ef4_writed(efx, value->u32[1], reg + 4);
+	_ef4_writed(efx, value->u32[2], reg + 8);
+	_ef4_writed(efx, value->u32[3], reg + 12);
+#endif
+	mmiowb();
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+}
+
+/* Write 64-bit SRAM through the supplied mapping, locking as appropriate. */
+static inline void ef4_sram_writeq(struct ef4_nic *efx, void __iomem *membase,
+				   const ef4_qword_t *value, unsigned int index)
+{
+	unsigned int addr = index * sizeof(*value);
+	unsigned long flags __attribute__ ((unused));
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing SRAM address %x with " EF4_QWORD_FMT "\n",
+		   addr, EF4_QWORD_VAL(*value));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+#ifdef EF4_USE_QWORD_IO
+	__raw_writeq((__force u64)value->u64[0], membase + addr);
+#else
+	__raw_writel((__force u32)value->u32[0], membase + addr);
+	__raw_writel((__force u32)value->u32[1], membase + addr + 4);
+#endif
+	mmiowb();
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+}
+
+/* Write a 32-bit CSR or the last dword of a special 128-bit CSR */
+static inline void ef4_writed(struct ef4_nic *efx, const ef4_dword_t *value,
+			      unsigned int reg)
+{
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing register %x with "EF4_DWORD_FMT"\n",
+		   reg, EF4_DWORD_VAL(*value));
+
+	/* No lock required */
+	_ef4_writed(efx, value->u32[0], reg);
+}
+
+/* Read a 128-bit CSR, locking as appropriate. */
+static inline void ef4_reado(struct ef4_nic *efx, ef4_oword_t *value,
+			     unsigned int reg)
+{
+	unsigned long flags __attribute__ ((unused));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+	value->u32[0] = _ef4_readd(efx, reg + 0);
+	value->u32[1] = _ef4_readd(efx, reg + 4);
+	value->u32[2] = _ef4_readd(efx, reg + 8);
+	value->u32[3] = _ef4_readd(efx, reg + 12);
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "read from register %x, got " EF4_OWORD_FMT "\n", reg,
+		   EF4_OWORD_VAL(*value));
+}
+
+/* Read 64-bit SRAM through the supplied mapping, locking as appropriate. */
+static inline void ef4_sram_readq(struct ef4_nic *efx, void __iomem *membase,
+				  ef4_qword_t *value, unsigned int index)
+{
+	unsigned int addr = index * sizeof(*value);
+	unsigned long flags __attribute__ ((unused));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+#ifdef EF4_USE_QWORD_IO
+	value->u64[0] = (__force __le64)__raw_readq(membase + addr);
+#else
+	value->u32[0] = (__force __le32)__raw_readl(membase + addr);
+	value->u32[1] = (__force __le32)__raw_readl(membase + addr + 4);
+#endif
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "read from SRAM address %x, got "EF4_QWORD_FMT"\n",
+		   addr, EF4_QWORD_VAL(*value));
+}
+
+/* Read a 32-bit CSR or SRAM */
+static inline void ef4_readd(struct ef4_nic *efx, ef4_dword_t *value,
+				unsigned int reg)
+{
+	value->u32[0] = _ef4_readd(efx, reg);
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "read from register %x, got "EF4_DWORD_FMT"\n",
+		   reg, EF4_DWORD_VAL(*value));
+}
+
+/* Write a 128-bit CSR forming part of a table */
+static inline void
+ef4_writeo_table(struct ef4_nic *efx, const ef4_oword_t *value,
+		 unsigned int reg, unsigned int index)
+{
+	ef4_writeo(efx, value, reg + index * sizeof(ef4_oword_t));
+}
+
+/* Read a 128-bit CSR forming part of a table */
+static inline void ef4_reado_table(struct ef4_nic *efx, ef4_oword_t *value,
+				     unsigned int reg, unsigned int index)
+{
+	ef4_reado(efx, value, reg + index * sizeof(ef4_oword_t));
+}
+
+/* Page size used as step between per-VI registers */
+#define EF4_VI_PAGE_SIZE 0x2000
+
+/* Calculate offset to page-mapped register */
+#define EF4_PAGED_REG(page, reg) \
+	((page) * EF4_VI_PAGE_SIZE + (reg))
+
+/* Write the whole of RX_DESC_UPD or TX_DESC_UPD */
+static inline void _ef4_writeo_page(struct ef4_nic *efx, ef4_oword_t *value,
+				    unsigned int reg, unsigned int page)
+{
+	reg = EF4_PAGED_REG(page, reg);
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing register %x with " EF4_OWORD_FMT "\n", reg,
+		   EF4_OWORD_VAL(*value));
+
+#ifdef EF4_USE_QWORD_IO
+	_ef4_writeq(efx, value->u64[0], reg + 0);
+	_ef4_writeq(efx, value->u64[1], reg + 8);
+#else
+	_ef4_writed(efx, value->u32[0], reg + 0);
+	_ef4_writed(efx, value->u32[1], reg + 4);
+	_ef4_writed(efx, value->u32[2], reg + 8);
+	_ef4_writed(efx, value->u32[3], reg + 12);
+#endif
+}
+#define ef4_writeo_page(efx, value, reg, page)				\
+	_ef4_writeo_page(efx, value,					\
+			 reg +						\
+			 BUILD_BUG_ON_ZERO((reg) != 0x830 && (reg) != 0xa10), \
+			 page)
+
+/* Write a page-mapped 32-bit CSR (EVQ_RPTR, EVQ_TMR (EF10), or the
+ * high bits of RX_DESC_UPD or TX_DESC_UPD)
+ */
+static inline void
+_ef4_writed_page(struct ef4_nic *efx, const ef4_dword_t *value,
+		 unsigned int reg, unsigned int page)
+{
+	ef4_writed(efx, value, EF4_PAGED_REG(page, reg));
+}
+#define ef4_writed_page(efx, value, reg, page)				\
+	_ef4_writed_page(efx, value,					\
+			 reg +						\
+			 BUILD_BUG_ON_ZERO((reg) != 0x400 &&		\
+					   (reg) != 0x420 &&		\
+					   (reg) != 0x830 &&		\
+					   (reg) != 0x83c &&		\
+					   (reg) != 0xa18 &&		\
+					   (reg) != 0xa1c),		\
+			 page)
+
+/* Write TIMER_COMMAND.  This is a page-mapped 32-bit CSR, but a bug
+ * in the BIU means that writes to TIMER_COMMAND[0] invalidate the
+ * collector register.
+ */
+static inline void _ef4_writed_page_locked(struct ef4_nic *efx,
+					   const ef4_dword_t *value,
+					   unsigned int reg,
+					   unsigned int page)
+{
+	unsigned long flags __attribute__ ((unused));
+
+	if (page == 0) {
+		spin_lock_irqsave(&efx->biu_lock, flags);
+		ef4_writed(efx, value, EF4_PAGED_REG(page, reg));
+		spin_unlock_irqrestore(&efx->biu_lock, flags);
+	} else {
+		ef4_writed(efx, value, EF4_PAGED_REG(page, reg));
+	}
+}
+#define ef4_writed_page_locked(efx, value, reg, page)			\
+	_ef4_writed_page_locked(efx, value,				\
+				reg + BUILD_BUG_ON_ZERO((reg) != 0x420), \
+				page)
+
+#endif /* EF4_IO_H */
diff --git a/drivers/net/ethernet/sfc/falcon/mdio_10g.c b/drivers/net/ethernet/sfc/falcon/mdio_10g.c
new file mode 100644
index 0000000..e7d7c09
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/mdio_10g.c
@@ -0,0 +1,323 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2006-2011 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+/*
+ * Useful functions for working with MDIO clause 45 PHYs
+ */
+#include <linux/types.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
+#include "net_driver.h"
+#include "mdio_10g.h"
+#include "workarounds.h"
+
+unsigned ef4_mdio_id_oui(u32 id)
+{
+	unsigned oui = 0;
+	int i;
+
+	/* The bits of the OUI are designated a..x, with a=0 and b variable.
+	 * In the id register c is the MSB but the OUI is conventionally
+	 * written as bytes h..a, p..i, x..q.  Reorder the bits accordingly. */
+	for (i = 0; i < 22; ++i)
+		if (id & (1 << (i + 10)))
+			oui |= 1 << (i ^ 7);
+
+	return oui;
+}
+
+int ef4_mdio_reset_mmd(struct ef4_nic *port, int mmd,
+			    int spins, int spintime)
+{
+	u32 ctrl;
+
+	/* Catch callers passing values in the wrong units (or just silly) */
+	EF4_BUG_ON_PARANOID(spins * spintime >= 5000);
+
+	ef4_mdio_write(port, mmd, MDIO_CTRL1, MDIO_CTRL1_RESET);
+	/* Wait for the reset bit to clear. */
+	do {
+		msleep(spintime);
+		ctrl = ef4_mdio_read(port, mmd, MDIO_CTRL1);
+		spins--;
+
+	} while (spins && (ctrl & MDIO_CTRL1_RESET));
+
+	return spins ? spins : -ETIMEDOUT;
+}
+
+static int ef4_mdio_check_mmd(struct ef4_nic *efx, int mmd)
+{
+	int status;
+
+	if (mmd != MDIO_MMD_AN) {
+		/* Read MMD STATUS2 to check it is responding. */
+		status = ef4_mdio_read(efx, mmd, MDIO_STAT2);
+		if ((status & MDIO_STAT2_DEVPRST) != MDIO_STAT2_DEVPRST_VAL) {
+			netif_err(efx, hw, efx->net_dev,
+				  "PHY MMD %d not responding.\n", mmd);
+			return -EIO;
+		}
+	}
+
+	return 0;
+}
+
+/* This ought to be ridiculous overkill. We expect it to fail rarely */
+#define MDIO45_RESET_TIME	1000 /* ms */
+#define MDIO45_RESET_ITERS	100
+
+int ef4_mdio_wait_reset_mmds(struct ef4_nic *efx, unsigned int mmd_mask)
+{
+	const int spintime = MDIO45_RESET_TIME / MDIO45_RESET_ITERS;
+	int tries = MDIO45_RESET_ITERS;
+	int rc = 0;
+	int in_reset;
+
+	while (tries) {
+		int mask = mmd_mask;
+		int mmd = 0;
+		int stat;
+		in_reset = 0;
+		while (mask) {
+			if (mask & 1) {
+				stat = ef4_mdio_read(efx, mmd, MDIO_CTRL1);
+				if (stat < 0) {
+					netif_err(efx, hw, efx->net_dev,
+						  "failed to read status of"
+						  " MMD %d\n", mmd);
+					return -EIO;
+				}
+				if (stat & MDIO_CTRL1_RESET)
+					in_reset |= (1 << mmd);
+			}
+			mask = mask >> 1;
+			mmd++;
+		}
+		if (!in_reset)
+			break;
+		tries--;
+		msleep(spintime);
+	}
+	if (in_reset != 0) {
+		netif_err(efx, hw, efx->net_dev,
+			  "not all MMDs came out of reset in time."
+			  " MMDs still in reset: %x\n", in_reset);
+		rc = -ETIMEDOUT;
+	}
+	return rc;
+}
+
+int ef4_mdio_check_mmds(struct ef4_nic *efx, unsigned int mmd_mask)
+{
+	int mmd = 0, probe_mmd, devs1, devs2;
+	u32 devices;
+
+	/* Historically we have probed the PHYXS to find out what devices are
+	 * present,but that doesn't work so well if the PHYXS isn't expected
+	 * to exist, if so just find the first item in the list supplied. */
+	probe_mmd = (mmd_mask & MDIO_DEVS_PHYXS) ? MDIO_MMD_PHYXS :
+	    __ffs(mmd_mask);
+
+	/* Check all the expected MMDs are present */
+	devs1 = ef4_mdio_read(efx, probe_mmd, MDIO_DEVS1);
+	devs2 = ef4_mdio_read(efx, probe_mmd, MDIO_DEVS2);
+	if (devs1 < 0 || devs2 < 0) {
+		netif_err(efx, hw, efx->net_dev,
+			  "failed to read devices present\n");
+		return -EIO;
+	}
+	devices = devs1 | (devs2 << 16);
+	if ((devices & mmd_mask) != mmd_mask) {
+		netif_err(efx, hw, efx->net_dev,
+			  "required MMDs not present: got %x, wanted %x\n",
+			  devices, mmd_mask);
+		return -ENODEV;
+	}
+	netif_vdbg(efx, hw, efx->net_dev, "Devices present: %x\n", devices);
+
+	/* Check all required MMDs are responding and happy. */
+	while (mmd_mask) {
+		if ((mmd_mask & 1) && ef4_mdio_check_mmd(efx, mmd))
+			return -EIO;
+		mmd_mask = mmd_mask >> 1;
+		mmd++;
+	}
+
+	return 0;
+}
+
+bool ef4_mdio_links_ok(struct ef4_nic *efx, unsigned int mmd_mask)
+{
+	/* If the port is in loopback, then we should only consider a subset
+	 * of mmd's */
+	if (LOOPBACK_INTERNAL(efx))
+		return true;
+	else if (LOOPBACK_MASK(efx) & LOOPBACKS_WS)
+		return false;
+	else if (ef4_phy_mode_disabled(efx->phy_mode))
+		return false;
+	else if (efx->loopback_mode == LOOPBACK_PHYXS)
+		mmd_mask &= ~(MDIO_DEVS_PHYXS |
+			      MDIO_DEVS_PCS |
+			      MDIO_DEVS_PMAPMD |
+			      MDIO_DEVS_AN);
+	else if (efx->loopback_mode == LOOPBACK_PCS)
+		mmd_mask &= ~(MDIO_DEVS_PCS |
+			      MDIO_DEVS_PMAPMD |
+			      MDIO_DEVS_AN);
+	else if (efx->loopback_mode == LOOPBACK_PMAPMD)
+		mmd_mask &= ~(MDIO_DEVS_PMAPMD |
+			      MDIO_DEVS_AN);
+
+	return mdio45_links_ok(&efx->mdio, mmd_mask);
+}
+
+void ef4_mdio_transmit_disable(struct ef4_nic *efx)
+{
+	ef4_mdio_set_flag(efx, MDIO_MMD_PMAPMD,
+			  MDIO_PMA_TXDIS, MDIO_PMD_TXDIS_GLOBAL,
+			  efx->phy_mode & PHY_MODE_TX_DISABLED);
+}
+
+void ef4_mdio_phy_reconfigure(struct ef4_nic *efx)
+{
+	ef4_mdio_set_flag(efx, MDIO_MMD_PMAPMD,
+			  MDIO_CTRL1, MDIO_PMA_CTRL1_LOOPBACK,
+			  efx->loopback_mode == LOOPBACK_PMAPMD);
+	ef4_mdio_set_flag(efx, MDIO_MMD_PCS,
+			  MDIO_CTRL1, MDIO_PCS_CTRL1_LOOPBACK,
+			  efx->loopback_mode == LOOPBACK_PCS);
+	ef4_mdio_set_flag(efx, MDIO_MMD_PHYXS,
+			  MDIO_CTRL1, MDIO_PHYXS_CTRL1_LOOPBACK,
+			  efx->loopback_mode == LOOPBACK_PHYXS_WS);
+}
+
+static void ef4_mdio_set_mmd_lpower(struct ef4_nic *efx,
+				    int lpower, int mmd)
+{
+	int stat = ef4_mdio_read(efx, mmd, MDIO_STAT1);
+
+	netif_vdbg(efx, drv, efx->net_dev, "Setting low power mode for MMD %d to %d\n",
+		  mmd, lpower);
+
+	if (stat & MDIO_STAT1_LPOWERABLE) {
+		ef4_mdio_set_flag(efx, mmd, MDIO_CTRL1,
+				  MDIO_CTRL1_LPOWER, lpower);
+	}
+}
+
+void ef4_mdio_set_mmds_lpower(struct ef4_nic *efx,
+			      int low_power, unsigned int mmd_mask)
+{
+	int mmd = 0;
+	mmd_mask &= ~MDIO_DEVS_AN;
+	while (mmd_mask) {
+		if (mmd_mask & 1)
+			ef4_mdio_set_mmd_lpower(efx, low_power, mmd);
+		mmd_mask = (mmd_mask >> 1);
+		mmd++;
+	}
+}
+
+/**
+ * ef4_mdio_set_settings - Set (some of) the PHY settings over MDIO.
+ * @efx:		Efx NIC
+ * @ecmd:		New settings
+ */
+int ef4_mdio_set_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+{
+	struct ethtool_cmd prev = { .cmd = ETHTOOL_GSET };
+
+	efx->phy_op->get_settings(efx, &prev);
+
+	if (ecmd->advertising == prev.advertising &&
+	    ethtool_cmd_speed(ecmd) == ethtool_cmd_speed(&prev) &&
+	    ecmd->duplex == prev.duplex &&
+	    ecmd->port == prev.port &&
+	    ecmd->autoneg == prev.autoneg)
+		return 0;
+
+	/* We can only change these settings for -T PHYs */
+	if (prev.port != PORT_TP || ecmd->port != PORT_TP)
+		return -EINVAL;
+
+	/* Check that PHY supports these settings */
+	if (!ecmd->autoneg ||
+	    (ecmd->advertising | SUPPORTED_Autoneg) & ~prev.supported)
+		return -EINVAL;
+
+	ef4_link_set_advertising(efx, ecmd->advertising | ADVERTISED_Autoneg);
+	ef4_mdio_an_reconfigure(efx);
+	return 0;
+}
+
+/**
+ * ef4_mdio_an_reconfigure - Push advertising flags and restart autonegotiation
+ * @efx:		Efx NIC
+ */
+void ef4_mdio_an_reconfigure(struct ef4_nic *efx)
+{
+	int reg;
+
+	WARN_ON(!(efx->mdio.mmds & MDIO_DEVS_AN));
+
+	/* Set up the base page */
+	reg = ADVERTISE_CSMA | ADVERTISE_RESV;
+	if (efx->link_advertising & ADVERTISED_Pause)
+		reg |= ADVERTISE_PAUSE_CAP;
+	if (efx->link_advertising & ADVERTISED_Asym_Pause)
+		reg |= ADVERTISE_PAUSE_ASYM;
+	ef4_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
+
+	/* Set up the (extended) next page */
+	efx->phy_op->set_npage_adv(efx, efx->link_advertising);
+
+	/* Enable and restart AN */
+	reg = ef4_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
+	reg |= MDIO_AN_CTRL1_ENABLE | MDIO_AN_CTRL1_RESTART | MDIO_AN_CTRL1_XNP;
+	ef4_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
+}
+
+u8 ef4_mdio_get_pause(struct ef4_nic *efx)
+{
+	BUILD_BUG_ON(EF4_FC_AUTO & (EF4_FC_RX | EF4_FC_TX));
+
+	if (!(efx->wanted_fc & EF4_FC_AUTO))
+		return efx->wanted_fc;
+
+	WARN_ON(!(efx->mdio.mmds & MDIO_DEVS_AN));
+
+	return mii_resolve_flowctrl_fdx(
+		mii_advertise_flowctrl(efx->wanted_fc),
+		ef4_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_LPA));
+}
+
+int ef4_mdio_test_alive(struct ef4_nic *efx)
+{
+	int rc;
+	int devad = __ffs(efx->mdio.mmds);
+	u16 physid1, physid2;
+
+	mutex_lock(&efx->mac_lock);
+
+	physid1 = ef4_mdio_read(efx, devad, MDIO_DEVID1);
+	physid2 = ef4_mdio_read(efx, devad, MDIO_DEVID2);
+
+	if ((physid1 == 0x0000) || (physid1 == 0xffff) ||
+	    (physid2 == 0x0000) || (physid2 == 0xffff)) {
+		netif_err(efx, hw, efx->net_dev,
+			  "no MDIO PHY present with ID %d\n", efx->mdio.prtad);
+		rc = -EINVAL;
+	} else {
+		rc = ef4_mdio_check_mmds(efx, efx->mdio.mmds);
+	}
+
+	mutex_unlock(&efx->mac_lock);
+	return rc;
+}
diff --git a/drivers/net/ethernet/sfc/falcon/mdio_10g.h b/drivers/net/ethernet/sfc/falcon/mdio_10g.h
new file mode 100644
index 0000000..885cf7a
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/mdio_10g.h
@@ -0,0 +1,110 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2006-2011 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_MDIO_10G_H
+#define EF4_MDIO_10G_H
+
+#include <linux/mdio.h>
+
+/*
+ * Helper functions for doing 10G MDIO as specified in IEEE 802.3 clause 45.
+ */
+
+#include "efx.h"
+
+static inline unsigned ef4_mdio_id_rev(u32 id) { return id & 0xf; }
+static inline unsigned ef4_mdio_id_model(u32 id) { return (id >> 4) & 0x3f; }
+unsigned ef4_mdio_id_oui(u32 id);
+
+static inline int ef4_mdio_read(struct ef4_nic *efx, int devad, int addr)
+{
+	return efx->mdio.mdio_read(efx->net_dev, efx->mdio.prtad, devad, addr);
+}
+
+static inline void
+ef4_mdio_write(struct ef4_nic *efx, int devad, int addr, int value)
+{
+	efx->mdio.mdio_write(efx->net_dev, efx->mdio.prtad, devad, addr, value);
+}
+
+static inline u32 ef4_mdio_read_id(struct ef4_nic *efx, int mmd)
+{
+	u16 id_low = ef4_mdio_read(efx, mmd, MDIO_DEVID2);
+	u16 id_hi = ef4_mdio_read(efx, mmd, MDIO_DEVID1);
+	return (id_hi << 16) | (id_low);
+}
+
+static inline bool ef4_mdio_phyxgxs_lane_sync(struct ef4_nic *efx)
+{
+	int i, lane_status;
+	bool sync;
+
+	for (i = 0; i < 2; ++i)
+		lane_status = ef4_mdio_read(efx, MDIO_MMD_PHYXS,
+					    MDIO_PHYXS_LNSTAT);
+
+	sync = !!(lane_status & MDIO_PHYXS_LNSTAT_ALIGN);
+	if (!sync)
+		netif_dbg(efx, hw, efx->net_dev, "XGXS lane status: %x\n",
+			  lane_status);
+	return sync;
+}
+
+const char *ef4_mdio_mmd_name(int mmd);
+
+/*
+ * Reset a specific MMD and wait for reset to clear.
+ * Return number of spins left (>0) on success, -%ETIMEDOUT on failure.
+ *
+ * This function will sleep
+ */
+int ef4_mdio_reset_mmd(struct ef4_nic *efx, int mmd, int spins, int spintime);
+
+/* As ef4_mdio_check_mmd but for multiple MMDs */
+int ef4_mdio_check_mmds(struct ef4_nic *efx, unsigned int mmd_mask);
+
+/* Check the link status of specified mmds in bit mask */
+bool ef4_mdio_links_ok(struct ef4_nic *efx, unsigned int mmd_mask);
+
+/* Generic transmit disable support though PMAPMD */
+void ef4_mdio_transmit_disable(struct ef4_nic *efx);
+
+/* Generic part of reconfigure: set/clear loopback bits */
+void ef4_mdio_phy_reconfigure(struct ef4_nic *efx);
+
+/* Set the power state of the specified MMDs */
+void ef4_mdio_set_mmds_lpower(struct ef4_nic *efx, int low_power,
+			      unsigned int mmd_mask);
+
+/* Set (some of) the PHY settings over MDIO */
+int ef4_mdio_set_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd);
+
+/* Push advertising flags and restart autonegotiation */
+void ef4_mdio_an_reconfigure(struct ef4_nic *efx);
+
+/* Get pause parameters from AN if available (otherwise return
+ * requested pause parameters)
+ */
+u8 ef4_mdio_get_pause(struct ef4_nic *efx);
+
+/* Wait for specified MMDs to exit reset within a timeout */
+int ef4_mdio_wait_reset_mmds(struct ef4_nic *efx, unsigned int mmd_mask);
+
+/* Set or clear flag, debouncing */
+static inline void
+ef4_mdio_set_flag(struct ef4_nic *efx, int devad, int addr,
+		  int mask, bool state)
+{
+	mdio_set_flag(&efx->mdio, efx->mdio.prtad, devad, addr, mask, state);
+}
+
+/* Liveness self-test for MDIO PHYs */
+int ef4_mdio_test_alive(struct ef4_nic *efx);
+
+#endif /* EF4_MDIO_10G_H */
diff --git a/drivers/net/ethernet/sfc/falcon/mtd.c b/drivers/net/ethernet/sfc/falcon/mtd.c
new file mode 100644
index 0000000..cde593c
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/mtd.c
@@ -0,0 +1,133 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/module.h>
+#include <linux/mtd/mtd.h>
+#include <linux/slab.h>
+#include <linux/rtnetlink.h>
+
+#include "net_driver.h"
+#include "efx.h"
+
+#define to_ef4_mtd_partition(mtd)				\
+	container_of(mtd, struct ef4_mtd_partition, mtd)
+
+/* MTD interface */
+
+static int ef4_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
+{
+	struct ef4_nic *efx = mtd->priv;
+	int rc;
+
+	rc = efx->type->mtd_erase(mtd, erase->addr, erase->len);
+	if (rc == 0) {
+		erase->state = MTD_ERASE_DONE;
+	} else {
+		erase->state = MTD_ERASE_FAILED;
+		erase->fail_addr = MTD_FAIL_ADDR_UNKNOWN;
+	}
+	mtd_erase_callback(erase);
+	return rc;
+}
+
+static void ef4_mtd_sync(struct mtd_info *mtd)
+{
+	struct ef4_mtd_partition *part = to_ef4_mtd_partition(mtd);
+	struct ef4_nic *efx = mtd->priv;
+	int rc;
+
+	rc = efx->type->mtd_sync(mtd);
+	if (rc)
+		pr_err("%s: %s sync failed (%d)\n",
+		       part->name, part->dev_type_name, rc);
+}
+
+static void ef4_mtd_remove_partition(struct ef4_mtd_partition *part)
+{
+	int rc;
+
+	for (;;) {
+		rc = mtd_device_unregister(&part->mtd);
+		if (rc != -EBUSY)
+			break;
+		ssleep(1);
+	}
+	WARN_ON(rc);
+	list_del(&part->node);
+}
+
+int ef4_mtd_add(struct ef4_nic *efx, struct ef4_mtd_partition *parts,
+		size_t n_parts, size_t sizeof_part)
+{
+	struct ef4_mtd_partition *part;
+	size_t i;
+
+	for (i = 0; i < n_parts; i++) {
+		part = (struct ef4_mtd_partition *)((char *)parts +
+						    i * sizeof_part);
+
+		part->mtd.writesize = 1;
+
+		part->mtd.owner = THIS_MODULE;
+		part->mtd.priv = efx;
+		part->mtd.name = part->name;
+		part->mtd._erase = ef4_mtd_erase;
+		part->mtd._read = efx->type->mtd_read;
+		part->mtd._write = efx->type->mtd_write;
+		part->mtd._sync = ef4_mtd_sync;
+
+		efx->type->mtd_rename(part);
+
+		if (mtd_device_register(&part->mtd, NULL, 0))
+			goto fail;
+
+		/* Add to list in order - ef4_mtd_remove() depends on this */
+		list_add_tail(&part->node, &efx->mtd_list);
+	}
+
+	return 0;
+
+fail:
+	while (i--) {
+		part = (struct ef4_mtd_partition *)((char *)parts +
+						    i * sizeof_part);
+		ef4_mtd_remove_partition(part);
+	}
+	/* Failure is unlikely here, but probably means we're out of memory */
+	return -ENOMEM;
+}
+
+void ef4_mtd_remove(struct ef4_nic *efx)
+{
+	struct ef4_mtd_partition *parts, *part, *next;
+
+	WARN_ON(ef4_dev_registered(efx));
+
+	if (list_empty(&efx->mtd_list))
+		return;
+
+	parts = list_first_entry(&efx->mtd_list, struct ef4_mtd_partition,
+				 node);
+
+	list_for_each_entry_safe(part, next, &efx->mtd_list, node)
+		ef4_mtd_remove_partition(part);
+
+	kfree(parts);
+}
+
+void ef4_mtd_rename(struct ef4_nic *efx)
+{
+	struct ef4_mtd_partition *part;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry(part, &efx->mtd_list, node)
+		efx->type->mtd_rename(part);
+}
diff --git a/drivers/net/ethernet/sfc/falcon/net_driver.h b/drivers/net/ethernet/sfc/falcon/net_driver.h
new file mode 100644
index 0000000..210b28f
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/net_driver.h
@@ -0,0 +1,1464 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+/* Common definitions for all Efx net driver code */
+
+#ifndef EF4_NET_DRIVER_H
+#define EF4_NET_DRIVER_H
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#include <linux/timer.h>
+#include <linux/mdio.h>
+#include <linux/list.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/mutex.h>
+#include <linux/rwsem.h>
+#include <linux/vmalloc.h>
+#include <linux/i2c.h>
+#include <linux/mtd/mtd.h>
+#include <net/busy_poll.h>
+
+#include "enum.h"
+#include "bitfield.h"
+#include "filter.h"
+
+/**************************************************************************
+ *
+ * Build definitions
+ *
+ **************************************************************************/
+
+#define EF4_DRIVER_VERSION	"4.1"
+
+#ifdef DEBUG
+#define EF4_BUG_ON_PARANOID(x) BUG_ON(x)
+#define EF4_WARN_ON_PARANOID(x) WARN_ON(x)
+#else
+#define EF4_BUG_ON_PARANOID(x) do {} while (0)
+#define EF4_WARN_ON_PARANOID(x) do {} while (0)
+#endif
+
+/**************************************************************************
+ *
+ * Efx data structures
+ *
+ **************************************************************************/
+
+#define EF4_MAX_CHANNELS 32U
+#define EF4_MAX_RX_QUEUES EF4_MAX_CHANNELS
+#define EF4_EXTRA_CHANNEL_IOV	0
+#define EF4_EXTRA_CHANNEL_PTP	1
+#define EF4_MAX_EXTRA_CHANNELS	2U
+
+/* Checksum generation is a per-queue option in hardware, so each
+ * queue visible to the networking core is backed by two hardware TX
+ * queues. */
+#define EF4_MAX_TX_TC		2
+#define EF4_MAX_CORE_TX_QUEUES	(EF4_MAX_TX_TC * EF4_MAX_CHANNELS)
+#define EF4_TXQ_TYPE_OFFLOAD	1	/* flag */
+#define EF4_TXQ_TYPE_HIGHPRI	2	/* flag */
+#define EF4_TXQ_TYPES		4
+#define EF4_MAX_TX_QUEUES	(EF4_TXQ_TYPES * EF4_MAX_CHANNELS)
+
+/* Maximum possible MTU the driver supports */
+#define EF4_MAX_MTU (9 * 1024)
+
+/* Minimum MTU, from RFC791 (IP) */
+#define EF4_MIN_MTU 68
+
+/* Size of an RX scatter buffer.  Small enough to pack 2 into a 4K page,
+ * and should be a multiple of the cache line size.
+ */
+#define EF4_RX_USR_BUF_SIZE	(2048 - 256)
+
+/* If possible, we should ensure cache line alignment at start and end
+ * of every buffer.  Otherwise, we just need to ensure 4-byte
+ * alignment of the network header.
+ */
+#if NET_IP_ALIGN == 0
+#define EF4_RX_BUF_ALIGNMENT	L1_CACHE_BYTES
+#else
+#define EF4_RX_BUF_ALIGNMENT	4
+#endif
+
+struct ef4_self_tests;
+
+/**
+ * struct ef4_buffer - A general-purpose DMA buffer
+ * @addr: host base address of the buffer
+ * @dma_addr: DMA base address of the buffer
+ * @len: Buffer length, in bytes
+ *
+ * The NIC uses these buffers for its interrupt status registers and
+ * MAC stats dumps.
+ */
+struct ef4_buffer {
+	void *addr;
+	dma_addr_t dma_addr;
+	unsigned int len;
+};
+
+/**
+ * struct ef4_special_buffer - DMA buffer entered into buffer table
+ * @buf: Standard &struct ef4_buffer
+ * @index: Buffer index within controller;s buffer table
+ * @entries: Number of buffer table entries
+ *
+ * The NIC has a buffer table that maps buffers of size %EF4_BUF_SIZE.
+ * Event and descriptor rings are addressed via one or more buffer
+ * table entries (and so can be physically non-contiguous, although we
+ * currently do not take advantage of that).  On Falcon and Siena we
+ * have to take care of allocating and initialising the entries
+ * ourselves.  On later hardware this is managed by the firmware and
+ * @index and @entries are left as 0.
+ */
+struct ef4_special_buffer {
+	struct ef4_buffer buf;
+	unsigned int index;
+	unsigned int entries;
+};
+
+/**
+ * struct ef4_tx_buffer - buffer state for a TX descriptor
+ * @skb: When @flags & %EF4_TX_BUF_SKB, the associated socket buffer to be
+ *	freed when descriptor completes
+ * @option: When @flags & %EF4_TX_BUF_OPTION, a NIC-specific option descriptor.
+ * @dma_addr: DMA address of the fragment.
+ * @flags: Flags for allocation and DMA mapping type
+ * @len: Length of this fragment.
+ *	This field is zero when the queue slot is empty.
+ * @unmap_len: Length of this fragment to unmap
+ * @dma_offset: Offset of @dma_addr from the address of the backing DMA mapping.
+ * Only valid if @unmap_len != 0.
+ */
+struct ef4_tx_buffer {
+	const struct sk_buff *skb;
+	union {
+		ef4_qword_t option;
+		dma_addr_t dma_addr;
+	};
+	unsigned short flags;
+	unsigned short len;
+	unsigned short unmap_len;
+	unsigned short dma_offset;
+};
+#define EF4_TX_BUF_CONT		1	/* not last descriptor of packet */
+#define EF4_TX_BUF_SKB		2	/* buffer is last part of skb */
+#define EF4_TX_BUF_MAP_SINGLE	8	/* buffer was mapped with dma_map_single() */
+#define EF4_TX_BUF_OPTION	0x10	/* empty buffer for option descriptor */
+
+/**
+ * struct ef4_tx_queue - An Efx TX queue
+ *
+ * This is a ring buffer of TX fragments.
+ * Since the TX completion path always executes on the same
+ * CPU and the xmit path can operate on different CPUs,
+ * performance is increased by ensuring that the completion
+ * path and the xmit path operate on different cache lines.
+ * This is particularly important if the xmit path is always
+ * executing on one CPU which is different from the completion
+ * path.  There is also a cache line for members which are
+ * read but not written on the fast path.
+ *
+ * @efx: The associated Efx NIC
+ * @queue: DMA queue number
+ * @channel: The associated channel
+ * @core_txq: The networking core TX queue structure
+ * @buffer: The software buffer ring
+ * @cb_page: Array of pages of copy buffers.  Carved up according to
+ *	%EF4_TX_CB_ORDER into %EF4_TX_CB_SIZE-sized chunks.
+ * @txd: The hardware descriptor ring
+ * @ptr_mask: The size of the ring minus 1.
+ * @initialised: Has hardware queue been initialised?
+ * @tx_min_size: Minimum transmit size for this queue. Depends on HW.
+ * @read_count: Current read pointer.
+ *	This is the number of buffers that have been removed from both rings.
+ * @old_write_count: The value of @write_count when last checked.
+ *	This is here for performance reasons.  The xmit path will
+ *	only get the up-to-date value of @write_count if this
+ *	variable indicates that the queue is empty.  This is to
+ *	avoid cache-line ping-pong between the xmit path and the
+ *	completion path.
+ * @merge_events: Number of TX merged completion events
+ * @insert_count: Current insert pointer
+ *	This is the number of buffers that have been added to the
+ *	software ring.
+ * @write_count: Current write pointer
+ *	This is the number of buffers that have been added to the
+ *	hardware ring.
+ * @old_read_count: The value of read_count when last checked.
+ *	This is here for performance reasons.  The xmit path will
+ *	only get the up-to-date value of read_count if this
+ *	variable indicates that the queue is full.  This is to
+ *	avoid cache-line ping-pong between the xmit path and the
+ *	completion path.
+ * @pushes: Number of times the TX push feature has been used
+ * @xmit_more_available: Are any packets waiting to be pushed to the NIC
+ * @cb_packets: Number of times the TX copybreak feature has been used
+ * @empty_read_count: If the completion path has seen the queue as empty
+ *	and the transmission path has not yet checked this, the value of
+ *	@read_count bitwise-added to %EF4_EMPTY_COUNT_VALID; otherwise 0.
+ */
+struct ef4_tx_queue {
+	/* Members which don't change on the fast path */
+	struct ef4_nic *efx ____cacheline_aligned_in_smp;
+	unsigned queue;
+	struct ef4_channel *channel;
+	struct netdev_queue *core_txq;
+	struct ef4_tx_buffer *buffer;
+	struct ef4_buffer *cb_page;
+	struct ef4_special_buffer txd;
+	unsigned int ptr_mask;
+	bool initialised;
+	unsigned int tx_min_size;
+
+	/* Function pointers used in the fast path. */
+	int (*handle_tso)(struct ef4_tx_queue*, struct sk_buff*, bool *);
+
+	/* Members used mainly on the completion path */
+	unsigned int read_count ____cacheline_aligned_in_smp;
+	unsigned int old_write_count;
+	unsigned int merge_events;
+	unsigned int bytes_compl;
+	unsigned int pkts_compl;
+
+	/* Members used only on the xmit path */
+	unsigned int insert_count ____cacheline_aligned_in_smp;
+	unsigned int write_count;
+	unsigned int old_read_count;
+	unsigned int pushes;
+	bool xmit_more_available;
+	unsigned int cb_packets;
+	/* Statistics to supplement MAC stats */
+	unsigned long tx_packets;
+
+	/* Members shared between paths and sometimes updated */
+	unsigned int empty_read_count ____cacheline_aligned_in_smp;
+#define EF4_EMPTY_COUNT_VALID 0x80000000
+	atomic_t flush_outstanding;
+};
+
+#define EF4_TX_CB_ORDER	7
+#define EF4_TX_CB_SIZE	(1 << EF4_TX_CB_ORDER) - NET_IP_ALIGN
+
+/**
+ * struct ef4_rx_buffer - An Efx RX data buffer
+ * @dma_addr: DMA base address of the buffer
+ * @page: The associated page buffer.
+ *	Will be %NULL if the buffer slot is currently free.
+ * @page_offset: If pending: offset in @page of DMA base address.
+ *	If completed: offset in @page of Ethernet header.
+ * @len: If pending: length for DMA descriptor.
+ *	If completed: received length, excluding hash prefix.
+ * @flags: Flags for buffer and packet state.  These are only set on the
+ *	first buffer of a scattered packet.
+ */
+struct ef4_rx_buffer {
+	dma_addr_t dma_addr;
+	struct page *page;
+	u16 page_offset;
+	u16 len;
+	u16 flags;
+};
+#define EF4_RX_BUF_LAST_IN_PAGE	0x0001
+#define EF4_RX_PKT_CSUMMED	0x0002
+#define EF4_RX_PKT_DISCARD	0x0004
+#define EF4_RX_PKT_TCP		0x0040
+#define EF4_RX_PKT_PREFIX_LEN	0x0080	/* length is in prefix only */
+
+/**
+ * struct ef4_rx_page_state - Page-based rx buffer state
+ *
+ * Inserted at the start of every page allocated for receive buffers.
+ * Used to facilitate sharing dma mappings between recycled rx buffers
+ * and those passed up to the kernel.
+ *
+ * @dma_addr: The dma address of this page.
+ */
+struct ef4_rx_page_state {
+	dma_addr_t dma_addr;
+
+	unsigned int __pad[0] ____cacheline_aligned;
+};
+
+/**
+ * struct ef4_rx_queue - An Efx RX queue
+ * @efx: The associated Efx NIC
+ * @core_index:  Index of network core RX queue.  Will be >= 0 iff this
+ *	is associated with a real RX queue.
+ * @buffer: The software buffer ring
+ * @rxd: The hardware descriptor ring
+ * @ptr_mask: The size of the ring minus 1.
+ * @refill_enabled: Enable refill whenever fill level is low
+ * @flush_pending: Set when a RX flush is pending. Has the same lifetime as
+ *	@rxq_flush_pending.
+ * @added_count: Number of buffers added to the receive queue.
+ * @notified_count: Number of buffers given to NIC (<= @added_count).
+ * @removed_count: Number of buffers removed from the receive queue.
+ * @scatter_n: Used by NIC specific receive code.
+ * @scatter_len: Used by NIC specific receive code.
+ * @page_ring: The ring to store DMA mapped pages for reuse.
+ * @page_add: Counter to calculate the write pointer for the recycle ring.
+ * @page_remove: Counter to calculate the read pointer for the recycle ring.
+ * @page_recycle_count: The number of pages that have been recycled.
+ * @page_recycle_failed: The number of pages that couldn't be recycled because
+ *      the kernel still held a reference to them.
+ * @page_recycle_full: The number of pages that were released because the
+ *      recycle ring was full.
+ * @page_ptr_mask: The number of pages in the RX recycle ring minus 1.
+ * @max_fill: RX descriptor maximum fill level (<= ring size)
+ * @fast_fill_trigger: RX descriptor fill level that will trigger a fast fill
+ *	(<= @max_fill)
+ * @min_fill: RX descriptor minimum non-zero fill level.
+ *	This records the minimum fill level observed when a ring
+ *	refill was triggered.
+ * @recycle_count: RX buffer recycle counter.
+ * @slow_fill: Timer used to defer ef4_nic_generate_fill_event().
+ */
+struct ef4_rx_queue {
+	struct ef4_nic *efx;
+	int core_index;
+	struct ef4_rx_buffer *buffer;
+	struct ef4_special_buffer rxd;
+	unsigned int ptr_mask;
+	bool refill_enabled;
+	bool flush_pending;
+
+	unsigned int added_count;
+	unsigned int notified_count;
+	unsigned int removed_count;
+	unsigned int scatter_n;
+	unsigned int scatter_len;
+	struct page **page_ring;
+	unsigned int page_add;
+	unsigned int page_remove;
+	unsigned int page_recycle_count;
+	unsigned int page_recycle_failed;
+	unsigned int page_recycle_full;
+	unsigned int page_ptr_mask;
+	unsigned int max_fill;
+	unsigned int fast_fill_trigger;
+	unsigned int min_fill;
+	unsigned int min_overfill;
+	unsigned int recycle_count;
+	struct timer_list slow_fill;
+	unsigned int slow_fill_count;
+	/* Statistics to supplement MAC stats */
+	unsigned long rx_packets;
+};
+
+/**
+ * struct ef4_channel - An Efx channel
+ *
+ * A channel comprises an event queue, at least one TX queue, at least
+ * one RX queue, and an associated tasklet for processing the event
+ * queue.
+ *
+ * @efx: Associated Efx NIC
+ * @channel: Channel instance number
+ * @type: Channel type definition
+ * @eventq_init: Event queue initialised flag
+ * @enabled: Channel enabled indicator
+ * @irq: IRQ number (MSI and MSI-X only)
+ * @irq_moderation_us: IRQ moderation value (in microseconds)
+ * @napi_dev: Net device used with NAPI
+ * @napi_str: NAPI control structure
+ * @state: state for NAPI vs busy polling
+ * @state_lock: lock protecting @state
+ * @eventq: Event queue buffer
+ * @eventq_mask: Event queue pointer mask
+ * @eventq_read_ptr: Event queue read pointer
+ * @event_test_cpu: Last CPU to handle interrupt or test event for this channel
+ * @irq_count: Number of IRQs since last adaptive moderation decision
+ * @irq_mod_score: IRQ moderation score
+ * @rps_flow_id: Flow IDs of filters allocated for accelerated RFS,
+ *      indexed by filter ID
+ * @n_rx_tobe_disc: Count of RX_TOBE_DISC errors
+ * @n_rx_ip_hdr_chksum_err: Count of RX IP header checksum errors
+ * @n_rx_tcp_udp_chksum_err: Count of RX TCP and UDP checksum errors
+ * @n_rx_mcast_mismatch: Count of unmatched multicast frames
+ * @n_rx_frm_trunc: Count of RX_FRM_TRUNC errors
+ * @n_rx_overlength: Count of RX_OVERLENGTH errors
+ * @n_skbuff_leaks: Count of skbuffs leaked due to RX overrun
+ * @n_rx_nodesc_trunc: Number of RX packets truncated and then dropped due to
+ *	lack of descriptors
+ * @n_rx_merge_events: Number of RX merged completion events
+ * @n_rx_merge_packets: Number of RX packets completed by merged events
+ * @rx_pkt_n_frags: Number of fragments in next packet to be delivered by
+ *	__ef4_rx_packet(), or zero if there is none
+ * @rx_pkt_index: Ring index of first buffer for next packet to be delivered
+ *	by __ef4_rx_packet(), if @rx_pkt_n_frags != 0
+ * @rx_queue: RX queue for this channel
+ * @tx_queue: TX queues for this channel
+ */
+struct ef4_channel {
+	struct ef4_nic *efx;
+	int channel;
+	const struct ef4_channel_type *type;
+	bool eventq_init;
+	bool enabled;
+	int irq;
+	unsigned int irq_moderation_us;
+	struct net_device *napi_dev;
+	struct napi_struct napi_str;
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	unsigned long busy_poll_state;
+#endif
+	struct ef4_special_buffer eventq;
+	unsigned int eventq_mask;
+	unsigned int eventq_read_ptr;
+	int event_test_cpu;
+
+	unsigned int irq_count;
+	unsigned int irq_mod_score;
+#ifdef CONFIG_RFS_ACCEL
+	unsigned int rfs_filters_added;
+#define RPS_FLOW_ID_INVALID 0xFFFFFFFF
+	u32 *rps_flow_id;
+#endif
+
+	unsigned n_rx_tobe_disc;
+	unsigned n_rx_ip_hdr_chksum_err;
+	unsigned n_rx_tcp_udp_chksum_err;
+	unsigned n_rx_mcast_mismatch;
+	unsigned n_rx_frm_trunc;
+	unsigned n_rx_overlength;
+	unsigned n_skbuff_leaks;
+	unsigned int n_rx_nodesc_trunc;
+	unsigned int n_rx_merge_events;
+	unsigned int n_rx_merge_packets;
+
+	unsigned int rx_pkt_n_frags;
+	unsigned int rx_pkt_index;
+
+	struct ef4_rx_queue rx_queue;
+	struct ef4_tx_queue tx_queue[EF4_TXQ_TYPES];
+};
+
+#ifdef CONFIG_NET_RX_BUSY_POLL
+enum ef4_channel_busy_poll_state {
+	EF4_CHANNEL_STATE_IDLE = 0,
+	EF4_CHANNEL_STATE_NAPI = BIT(0),
+	EF4_CHANNEL_STATE_NAPI_REQ_BIT = 1,
+	EF4_CHANNEL_STATE_NAPI_REQ = BIT(1),
+	EF4_CHANNEL_STATE_POLL_BIT = 2,
+	EF4_CHANNEL_STATE_POLL = BIT(2),
+	EF4_CHANNEL_STATE_DISABLE_BIT = 3,
+};
+
+static inline void ef4_channel_busy_poll_init(struct ef4_channel *channel)
+{
+	WRITE_ONCE(channel->busy_poll_state, EF4_CHANNEL_STATE_IDLE);
+}
+
+/* Called from the device poll routine to get ownership of a channel. */
+static inline bool ef4_channel_lock_napi(struct ef4_channel *channel)
+{
+	unsigned long prev, old = READ_ONCE(channel->busy_poll_state);
+
+	while (1) {
+		switch (old) {
+		case EF4_CHANNEL_STATE_POLL:
+			/* Ensure ef4_channel_try_lock_poll() wont starve us */
+			set_bit(EF4_CHANNEL_STATE_NAPI_REQ_BIT,
+				&channel->busy_poll_state);
+			/* fallthrough */
+		case EF4_CHANNEL_STATE_POLL | EF4_CHANNEL_STATE_NAPI_REQ:
+			return false;
+		default:
+			break;
+		}
+		prev = cmpxchg(&channel->busy_poll_state, old,
+			       EF4_CHANNEL_STATE_NAPI);
+		if (unlikely(prev != old)) {
+			/* This is likely to mean we've just entered polling
+			 * state. Go back round to set the REQ bit.
+			 */
+			old = prev;
+			continue;
+		}
+		return true;
+	}
+}
+
+static inline void ef4_channel_unlock_napi(struct ef4_channel *channel)
+{
+	/* Make sure write has completed from ef4_channel_lock_napi() */
+	smp_wmb();
+	WRITE_ONCE(channel->busy_poll_state, EF4_CHANNEL_STATE_IDLE);
+}
+
+/* Called from ef4_busy_poll(). */
+static inline bool ef4_channel_try_lock_poll(struct ef4_channel *channel)
+{
+	return cmpxchg(&channel->busy_poll_state, EF4_CHANNEL_STATE_IDLE,
+			EF4_CHANNEL_STATE_POLL) == EF4_CHANNEL_STATE_IDLE;
+}
+
+static inline void ef4_channel_unlock_poll(struct ef4_channel *channel)
+{
+	clear_bit_unlock(EF4_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
+}
+
+static inline bool ef4_channel_busy_polling(struct ef4_channel *channel)
+{
+	return test_bit(EF4_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
+}
+
+static inline void ef4_channel_enable(struct ef4_channel *channel)
+{
+	clear_bit_unlock(EF4_CHANNEL_STATE_DISABLE_BIT,
+			 &channel->busy_poll_state);
+}
+
+/* Stop further polling or napi access.
+ * Returns false if the channel is currently busy polling.
+ */
+static inline bool ef4_channel_disable(struct ef4_channel *channel)
+{
+	set_bit(EF4_CHANNEL_STATE_DISABLE_BIT, &channel->busy_poll_state);
+	/* Implicit barrier in ef4_channel_busy_polling() */
+	return !ef4_channel_busy_polling(channel);
+}
+
+#else /* CONFIG_NET_RX_BUSY_POLL */
+
+static inline void ef4_channel_busy_poll_init(struct ef4_channel *channel)
+{
+}
+
+static inline bool ef4_channel_lock_napi(struct ef4_channel *channel)
+{
+	return true;
+}
+
+static inline void ef4_channel_unlock_napi(struct ef4_channel *channel)
+{
+}
+
+static inline bool ef4_channel_try_lock_poll(struct ef4_channel *channel)
+{
+	return false;
+}
+
+static inline void ef4_channel_unlock_poll(struct ef4_channel *channel)
+{
+}
+
+static inline bool ef4_channel_busy_polling(struct ef4_channel *channel)
+{
+	return false;
+}
+
+static inline void ef4_channel_enable(struct ef4_channel *channel)
+{
+}
+
+static inline bool ef4_channel_disable(struct ef4_channel *channel)
+{
+	return true;
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
+/**
+ * struct ef4_msi_context - Context for each MSI
+ * @efx: The associated NIC
+ * @index: Index of the channel/IRQ
+ * @name: Name of the channel/IRQ
+ *
+ * Unlike &struct ef4_channel, this is never reallocated and is always
+ * safe for the IRQ handler to access.
+ */
+struct ef4_msi_context {
+	struct ef4_nic *efx;
+	unsigned int index;
+	char name[IFNAMSIZ + 6];
+};
+
+/**
+ * struct ef4_channel_type - distinguishes traffic and extra channels
+ * @handle_no_channel: Handle failure to allocate an extra channel
+ * @pre_probe: Set up extra state prior to initialisation
+ * @post_remove: Tear down extra state after finalisation, if allocated.
+ *	May be called on channels that have not been probed.
+ * @get_name: Generate the channel's name (used for its IRQ handler)
+ * @copy: Copy the channel state prior to reallocation.  May be %NULL if
+ *	reallocation is not supported.
+ * @receive_skb: Handle an skb ready to be passed to netif_receive_skb()
+ * @keep_eventq: Flag for whether event queue should be kept initialised
+ *	while the device is stopped
+ */
+struct ef4_channel_type {
+	void (*handle_no_channel)(struct ef4_nic *);
+	int (*pre_probe)(struct ef4_channel *);
+	void (*post_remove)(struct ef4_channel *);
+	void (*get_name)(struct ef4_channel *, char *buf, size_t len);
+	struct ef4_channel *(*copy)(const struct ef4_channel *);
+	bool (*receive_skb)(struct ef4_channel *, struct sk_buff *);
+	bool keep_eventq;
+};
+
+enum ef4_led_mode {
+	EF4_LED_OFF	= 0,
+	EF4_LED_ON	= 1,
+	EF4_LED_DEFAULT	= 2
+};
+
+#define STRING_TABLE_LOOKUP(val, member) \
+	((val) < member ## _max) ? member ## _names[val] : "(invalid)"
+
+extern const char *const ef4_loopback_mode_names[];
+extern const unsigned int ef4_loopback_mode_max;
+#define LOOPBACK_MODE(efx) \
+	STRING_TABLE_LOOKUP((efx)->loopback_mode, ef4_loopback_mode)
+
+extern const char *const ef4_reset_type_names[];
+extern const unsigned int ef4_reset_type_max;
+#define RESET_TYPE(type) \
+	STRING_TABLE_LOOKUP(type, ef4_reset_type)
+
+enum ef4_int_mode {
+	/* Be careful if altering to correct macro below */
+	EF4_INT_MODE_MSIX = 0,
+	EF4_INT_MODE_MSI = 1,
+	EF4_INT_MODE_LEGACY = 2,
+	EF4_INT_MODE_MAX	/* Insert any new items before this */
+};
+#define EF4_INT_MODE_USE_MSI(x) (((x)->interrupt_mode) <= EF4_INT_MODE_MSI)
+
+enum nic_state {
+	STATE_UNINIT = 0,	/* device being probed/removed or is frozen */
+	STATE_READY = 1,	/* hardware ready and netdev registered */
+	STATE_DISABLED = 2,	/* device disabled due to hardware errors */
+	STATE_RECOVERY = 3,	/* device recovering from PCI error */
+};
+
+/* Forward declaration */
+struct ef4_nic;
+
+/* Pseudo bit-mask flow control field */
+#define EF4_FC_RX	FLOW_CTRL_RX
+#define EF4_FC_TX	FLOW_CTRL_TX
+#define EF4_FC_AUTO	4
+
+/**
+ * struct ef4_link_state - Current state of the link
+ * @up: Link is up
+ * @fd: Link is full-duplex
+ * @fc: Actual flow control flags
+ * @speed: Link speed (Mbps)
+ */
+struct ef4_link_state {
+	bool up;
+	bool fd;
+	u8 fc;
+	unsigned int speed;
+};
+
+static inline bool ef4_link_state_equal(const struct ef4_link_state *left,
+					const struct ef4_link_state *right)
+{
+	return left->up == right->up && left->fd == right->fd &&
+		left->fc == right->fc && left->speed == right->speed;
+}
+
+/**
+ * struct ef4_phy_operations - Efx PHY operations table
+ * @probe: Probe PHY and initialise efx->mdio.mode_support, efx->mdio.mmds,
+ *	efx->loopback_modes.
+ * @init: Initialise PHY
+ * @fini: Shut down PHY
+ * @reconfigure: Reconfigure PHY (e.g. for new link parameters)
+ * @poll: Update @link_state and report whether it changed.
+ *	Serialised by the mac_lock.
+ * @get_settings: Get ethtool settings. Serialised by the mac_lock.
+ * @set_settings: Set ethtool settings. Serialised by the mac_lock.
+ * @set_npage_adv: Set abilities advertised in (Extended) Next Page
+ *	(only needed where AN bit is set in mmds)
+ * @test_alive: Test that PHY is 'alive' (online)
+ * @test_name: Get the name of a PHY-specific test/result
+ * @run_tests: Run tests and record results as appropriate (offline).
+ *	Flags are the ethtool tests flags.
+ */
+struct ef4_phy_operations {
+	int (*probe) (struct ef4_nic *efx);
+	int (*init) (struct ef4_nic *efx);
+	void (*fini) (struct ef4_nic *efx);
+	void (*remove) (struct ef4_nic *efx);
+	int (*reconfigure) (struct ef4_nic *efx);
+	bool (*poll) (struct ef4_nic *efx);
+	void (*get_settings) (struct ef4_nic *efx,
+			      struct ethtool_cmd *ecmd);
+	int (*set_settings) (struct ef4_nic *efx,
+			     struct ethtool_cmd *ecmd);
+	void (*set_npage_adv) (struct ef4_nic *efx, u32);
+	int (*test_alive) (struct ef4_nic *efx);
+	const char *(*test_name) (struct ef4_nic *efx, unsigned int index);
+	int (*run_tests) (struct ef4_nic *efx, int *results, unsigned flags);
+	int (*get_module_eeprom) (struct ef4_nic *efx,
+			       struct ethtool_eeprom *ee,
+			       u8 *data);
+	int (*get_module_info) (struct ef4_nic *efx,
+				struct ethtool_modinfo *modinfo);
+};
+
+/**
+ * enum ef4_phy_mode - PHY operating mode flags
+ * @PHY_MODE_NORMAL: on and should pass traffic
+ * @PHY_MODE_TX_DISABLED: on with TX disabled
+ * @PHY_MODE_LOW_POWER: set to low power through MDIO
+ * @PHY_MODE_OFF: switched off through external control
+ * @PHY_MODE_SPECIAL: on but will not pass traffic
+ */
+enum ef4_phy_mode {
+	PHY_MODE_NORMAL		= 0,
+	PHY_MODE_TX_DISABLED	= 1,
+	PHY_MODE_LOW_POWER	= 2,
+	PHY_MODE_OFF		= 4,
+	PHY_MODE_SPECIAL	= 8,
+};
+
+static inline bool ef4_phy_mode_disabled(enum ef4_phy_mode mode)
+{
+	return !!(mode & ~PHY_MODE_TX_DISABLED);
+}
+
+/**
+ * struct ef4_hw_stat_desc - Description of a hardware statistic
+ * @name: Name of the statistic as visible through ethtool, or %NULL if
+ *	it should not be exposed
+ * @dma_width: Width in bits (0 for non-DMA statistics)
+ * @offset: Offset within stats (ignored for non-DMA statistics)
+ */
+struct ef4_hw_stat_desc {
+	const char *name;
+	u16 dma_width;
+	u16 offset;
+};
+
+/* Number of bits used in a multicast filter hash address */
+#define EF4_MCAST_HASH_BITS 8
+
+/* Number of (single-bit) entries in a multicast filter hash */
+#define EF4_MCAST_HASH_ENTRIES (1 << EF4_MCAST_HASH_BITS)
+
+/* An Efx multicast filter hash */
+union ef4_multicast_hash {
+	u8 byte[EF4_MCAST_HASH_ENTRIES / 8];
+	ef4_oword_t oword[EF4_MCAST_HASH_ENTRIES / sizeof(ef4_oword_t) / 8];
+};
+
+/**
+ * struct ef4_nic - an Efx NIC
+ * @name: Device name (net device name or bus id before net device registered)
+ * @pci_dev: The PCI device
+ * @node: List node for maintaning primary/secondary function lists
+ * @primary: &struct ef4_nic instance for the primary function of this
+ *	controller.  May be the same structure, and may be %NULL if no
+ *	primary function is bound.  Serialised by rtnl_lock.
+ * @secondary_list: List of &struct ef4_nic instances for the secondary PCI
+ *	functions of the controller, if this is for the primary function.
+ *	Serialised by rtnl_lock.
+ * @type: Controller type attributes
+ * @legacy_irq: IRQ number
+ * @workqueue: Workqueue for port reconfigures and the HW monitor.
+ *	Work items do not hold and must not acquire RTNL.
+ * @workqueue_name: Name of workqueue
+ * @reset_work: Scheduled reset workitem
+ * @membase_phys: Memory BAR value as physical address
+ * @membase: Memory BAR value
+ * @interrupt_mode: Interrupt mode
+ * @timer_quantum_ns: Interrupt timer quantum, in nanoseconds
+ * @timer_max_ns: Interrupt timer maximum value, in nanoseconds
+ * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
+ * @irq_rx_mod_step_us: Step size for IRQ moderation for RX event queues
+ * @irq_rx_moderation_us: IRQ moderation time for RX event queues
+ * @msg_enable: Log message enable flags
+ * @state: Device state number (%STATE_*). Serialised by the rtnl_lock.
+ * @reset_pending: Bitmask for pending resets
+ * @tx_queue: TX DMA queues
+ * @rx_queue: RX DMA queues
+ * @channel: Channels
+ * @msi_context: Context for each MSI
+ * @extra_channel_types: Types of extra (non-traffic) channels that
+ *	should be allocated for this NIC
+ * @rxq_entries: Size of receive queues requested by user.
+ * @txq_entries: Size of transmit queues requested by user.
+ * @txq_stop_thresh: TX queue fill level at or above which we stop it.
+ * @txq_wake_thresh: TX queue fill level at or below which we wake it.
+ * @tx_dc_base: Base qword address in SRAM of TX queue descriptor caches
+ * @rx_dc_base: Base qword address in SRAM of RX queue descriptor caches
+ * @sram_lim_qw: Qword address limit of SRAM
+ * @next_buffer_table: First available buffer table id
+ * @n_channels: Number of channels in use
+ * @n_rx_channels: Number of channels used for RX (= number of RX queues)
+ * @n_tx_channels: Number of channels used for TX
+ * @rx_ip_align: RX DMA address offset to have IP header aligned in
+ *	in accordance with NET_IP_ALIGN
+ * @rx_dma_len: Current maximum RX DMA length
+ * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
+ * @rx_buffer_truesize: Amortised allocation size of an RX buffer,
+ *	for use in sk_buff::truesize
+ * @rx_prefix_size: Size of RX prefix before packet data
+ * @rx_packet_hash_offset: Offset of RX flow hash from start of packet data
+ *	(valid only if @rx_prefix_size != 0; always negative)
+ * @rx_packet_len_offset: Offset of RX packet length from start of packet data
+ *	(valid only for NICs that set %EF4_RX_PKT_PREFIX_LEN; always negative)
+ * @rx_packet_ts_offset: Offset of timestamp from start of packet data
+ *	(valid only if channel->sync_timestamps_enabled; always negative)
+ * @rx_hash_key: Toeplitz hash key for RSS
+ * @rx_indir_table: Indirection table for RSS
+ * @rx_scatter: Scatter mode enabled for receives
+ * @int_error_count: Number of internal errors seen recently
+ * @int_error_expire: Time at which error count will be expired
+ * @irq_soft_enabled: Are IRQs soft-enabled? If not, IRQ handler will
+ *	acknowledge but do nothing else.
+ * @irq_status: Interrupt status buffer
+ * @irq_zero_count: Number of legacy IRQs seen with queue flags == 0
+ * @irq_level: IRQ level/index for IRQs not triggered by an event queue
+ * @selftest_work: Work item for asynchronous self-test
+ * @mtd_list: List of MTDs attached to the NIC
+ * @nic_data: Hardware dependent state
+ * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
+ *	ef4_monitor() and ef4_reconfigure_port()
+ * @port_enabled: Port enabled indicator.
+ *	Serialises ef4_stop_all(), ef4_start_all(), ef4_monitor() and
+ *	ef4_mac_work() with kernel interfaces. Safe to read under any
+ *	one of the rtnl_lock, mac_lock, or netif_tx_lock, but all three must
+ *	be held to modify it.
+ * @port_initialized: Port initialized?
+ * @net_dev: Operating system network device. Consider holding the rtnl lock
+ * @fixed_features: Features which cannot be turned off
+ * @stats_buffer: DMA buffer for statistics
+ * @phy_type: PHY type
+ * @phy_op: PHY interface
+ * @phy_data: PHY private data (including PHY-specific stats)
+ * @mdio: PHY MDIO interface
+ * @phy_mode: PHY operating mode. Serialised by @mac_lock.
+ * @link_advertising: Autonegotiation advertising flags
+ * @link_state: Current state of the link
+ * @n_link_state_changes: Number of times the link has changed state
+ * @unicast_filter: Flag for Falcon-arch simple unicast filter.
+ *	Protected by @mac_lock.
+ * @multicast_hash: Multicast hash table for Falcon-arch.
+ *	Protected by @mac_lock.
+ * @wanted_fc: Wanted flow control flags
+ * @fc_disable: When non-zero flow control is disabled. Typically used to
+ *	ensure that network back pressure doesn't delay dma queue flushes.
+ *	Serialised by the rtnl lock.
+ * @mac_work: Work item for changing MAC promiscuity and multicast hash
+ * @loopback_mode: Loopback status
+ * @loopback_modes: Supported loopback mode bitmask
+ * @loopback_selftest: Offline self-test private state
+ * @filter_sem: Filter table rw_semaphore, for freeing the table
+ * @filter_lock: Filter table lock, for mere content changes
+ * @filter_state: Architecture-dependent filter table state
+ * @rps_expire_channel: Next channel to check for expiry
+ * @rps_expire_index: Next index to check for expiry in
+ *	@rps_expire_channel's @rps_flow_id
+ * @active_queues: Count of RX and TX queues that haven't been flushed and drained.
+ * @rxq_flush_pending: Count of number of receive queues that need to be flushed.
+ *	Decremented when the ef4_flush_rx_queue() is called.
+ * @rxq_flush_outstanding: Count of number of RX flushes started but not yet
+ *	completed (either success or failure). Not used when MCDI is used to
+ *	flush receive queues.
+ * @flush_wq: wait queue used by ef4_nic_flush_queues() to wait for flush completions.
+ * @vpd_sn: Serial number read from VPD
+ * @monitor_work: Hardware monitor workitem
+ * @biu_lock: BIU (bus interface unit) lock
+ * @last_irq_cpu: Last CPU to handle a possible test interrupt.  This
+ *	field is used by ef4_test_interrupts() to verify that an
+ *	interrupt has occurred.
+ * @stats_lock: Statistics update lock. Must be held when calling
+ *	ef4_nic_type::{update,start,stop}_stats.
+ * @n_rx_noskb_drops: Count of RX packets dropped due to failure to allocate an skb
+ *
+ * This is stored in the private area of the &struct net_device.
+ */
+struct ef4_nic {
+	/* The following fields should be written very rarely */
+
+	char name[IFNAMSIZ];
+	struct list_head node;
+	struct ef4_nic *primary;
+	struct list_head secondary_list;
+	struct pci_dev *pci_dev;
+	unsigned int port_num;
+	const struct ef4_nic_type *type;
+	int legacy_irq;
+	bool eeh_disabled_legacy_irq;
+	struct workqueue_struct *workqueue;
+	char workqueue_name[16];
+	struct work_struct reset_work;
+	resource_size_t membase_phys;
+	void __iomem *membase;
+
+	enum ef4_int_mode interrupt_mode;
+	unsigned int timer_quantum_ns;
+	unsigned int timer_max_ns;
+	bool irq_rx_adaptive;
+	unsigned int irq_mod_step_us;
+	unsigned int irq_rx_moderation_us;
+	u32 msg_enable;
+
+	enum nic_state state;
+	unsigned long reset_pending;
+
+	struct ef4_channel *channel[EF4_MAX_CHANNELS];
+	struct ef4_msi_context msi_context[EF4_MAX_CHANNELS];
+	const struct ef4_channel_type *
+	extra_channel_type[EF4_MAX_EXTRA_CHANNELS];
+
+	unsigned rxq_entries;
+	unsigned txq_entries;
+	unsigned int txq_stop_thresh;
+	unsigned int txq_wake_thresh;
+
+	unsigned tx_dc_base;
+	unsigned rx_dc_base;
+	unsigned sram_lim_qw;
+	unsigned next_buffer_table;
+
+	unsigned int max_channels;
+	unsigned int max_tx_channels;
+	unsigned n_channels;
+	unsigned n_rx_channels;
+	unsigned rss_spread;
+	unsigned tx_channel_offset;
+	unsigned n_tx_channels;
+	unsigned int rx_ip_align;
+	unsigned int rx_dma_len;
+	unsigned int rx_buffer_order;
+	unsigned int rx_buffer_truesize;
+	unsigned int rx_page_buf_step;
+	unsigned int rx_bufs_per_page;
+	unsigned int rx_pages_per_batch;
+	unsigned int rx_prefix_size;
+	int rx_packet_hash_offset;
+	int rx_packet_len_offset;
+	int rx_packet_ts_offset;
+	u8 rx_hash_key[40];
+	u32 rx_indir_table[128];
+	bool rx_scatter;
+
+	unsigned int_error_count;
+	unsigned long int_error_expire;
+
+	bool irq_soft_enabled;
+	struct ef4_buffer irq_status;
+	unsigned irq_zero_count;
+	unsigned irq_level;
+	struct delayed_work selftest_work;
+
+#ifdef CONFIG_SFC_FALCON_MTD
+	struct list_head mtd_list;
+#endif
+
+	void *nic_data;
+
+	struct mutex mac_lock;
+	struct work_struct mac_work;
+	bool port_enabled;
+
+	bool mc_bist_for_other_fn;
+	bool port_initialized;
+	struct net_device *net_dev;
+
+	netdev_features_t fixed_features;
+
+	struct ef4_buffer stats_buffer;
+	u64 rx_nodesc_drops_total;
+	u64 rx_nodesc_drops_while_down;
+	bool rx_nodesc_drops_prev_state;
+
+	unsigned int phy_type;
+	const struct ef4_phy_operations *phy_op;
+	void *phy_data;
+	struct mdio_if_info mdio;
+	enum ef4_phy_mode phy_mode;
+
+	u32 link_advertising;
+	struct ef4_link_state link_state;
+	unsigned int n_link_state_changes;
+
+	bool unicast_filter;
+	union ef4_multicast_hash multicast_hash;
+	u8 wanted_fc;
+	unsigned fc_disable;
+
+	atomic_t rx_reset;
+	enum ef4_loopback_mode loopback_mode;
+	u64 loopback_modes;
+
+	void *loopback_selftest;
+
+	struct rw_semaphore filter_sem;
+	spinlock_t filter_lock;
+	void *filter_state;
+#ifdef CONFIG_RFS_ACCEL
+	unsigned int rps_expire_channel;
+	unsigned int rps_expire_index;
+#endif
+
+	atomic_t active_queues;
+	atomic_t rxq_flush_pending;
+	atomic_t rxq_flush_outstanding;
+	wait_queue_head_t flush_wq;
+
+	char *vpd_sn;
+
+	/* The following fields may be written more often */
+
+	struct delayed_work monitor_work ____cacheline_aligned_in_smp;
+	spinlock_t biu_lock;
+	int last_irq_cpu;
+	spinlock_t stats_lock;
+	atomic_t n_rx_noskb_drops;
+};
+
+static inline int ef4_dev_registered(struct ef4_nic *efx)
+{
+	return efx->net_dev->reg_state == NETREG_REGISTERED;
+}
+
+static inline unsigned int ef4_port_num(struct ef4_nic *efx)
+{
+	return efx->port_num;
+}
+
+struct ef4_mtd_partition {
+	struct list_head node;
+	struct mtd_info mtd;
+	const char *dev_type_name;
+	const char *type_name;
+	char name[IFNAMSIZ + 20];
+};
+
+/**
+ * struct ef4_nic_type - Efx device type definition
+ * @mem_bar: Get the memory BAR
+ * @mem_map_size: Get memory BAR mapped size
+ * @probe: Probe the controller
+ * @remove: Free resources allocated by probe()
+ * @init: Initialise the controller
+ * @dimension_resources: Dimension controller resources (buffer table,
+ *	and VIs once the available interrupt resources are clear)
+ * @fini: Shut down the controller
+ * @monitor: Periodic function for polling link state and hardware monitor
+ * @map_reset_reason: Map ethtool reset reason to a reset method
+ * @map_reset_flags: Map ethtool reset flags to a reset method, if possible
+ * @reset: Reset the controller hardware and possibly the PHY.  This will
+ *	be called while the controller is uninitialised.
+ * @probe_port: Probe the MAC and PHY
+ * @remove_port: Free resources allocated by probe_port()
+ * @handle_global_event: Handle a "global" event (may be %NULL)
+ * @fini_dmaq: Flush and finalise DMA queues (RX and TX queues)
+ * @prepare_flush: Prepare the hardware for flushing the DMA queues
+ *	(for Falcon architecture)
+ * @finish_flush: Clean up after flushing the DMA queues (for Falcon
+ *	architecture)
+ * @prepare_flr: Prepare for an FLR
+ * @finish_flr: Clean up after an FLR
+ * @describe_stats: Describe statistics for ethtool
+ * @update_stats: Update statistics not provided by event handling.
+ *	Either argument may be %NULL.
+ * @start_stats: Start the regular fetching of statistics
+ * @pull_stats: Pull stats from the NIC and wait until they arrive.
+ * @stop_stats: Stop the regular fetching of statistics
+ * @set_id_led: Set state of identifying LED or revert to automatic function
+ * @push_irq_moderation: Apply interrupt moderation value
+ * @reconfigure_port: Push loopback/power/txdis changes to the MAC and PHY
+ * @prepare_enable_fc_tx: Prepare MAC to enable pause frame TX (may be %NULL)
+ * @reconfigure_mac: Push MAC address, MTU, flow control and filter settings
+ *	to the hardware.  Serialised by the mac_lock.
+ * @check_mac_fault: Check MAC fault state. True if fault present.
+ * @get_wol: Get WoL configuration from driver state
+ * @set_wol: Push WoL configuration to the NIC
+ * @resume_wol: Synchronise WoL state between driver and MC (e.g. after resume)
+ * @test_chip: Test registers.  May use ef4_farch_test_registers(), and is
+ *	expected to reset the NIC.
+ * @test_nvram: Test validity of NVRAM contents
+ * @irq_enable_master: Enable IRQs on the NIC.  Each event queue must
+ *	be separately enabled after this.
+ * @irq_test_generate: Generate a test IRQ
+ * @irq_disable_non_ev: Disable non-event IRQs on the NIC.  Each event
+ *	queue must be separately disabled before this.
+ * @irq_handle_msi: Handle MSI for a channel.  The @dev_id argument is
+ *	a pointer to the &struct ef4_msi_context for the channel.
+ * @irq_handle_legacy: Handle legacy interrupt.  The @dev_id argument
+ *	is a pointer to the &struct ef4_nic.
+ * @tx_probe: Allocate resources for TX queue
+ * @tx_init: Initialise TX queue on the NIC
+ * @tx_remove: Free resources for TX queue
+ * @tx_write: Write TX descriptors and doorbell
+ * @rx_push_rss_config: Write RSS hash key and indirection table to the NIC
+ * @rx_probe: Allocate resources for RX queue
+ * @rx_init: Initialise RX queue on the NIC
+ * @rx_remove: Free resources for RX queue
+ * @rx_write: Write RX descriptors and doorbell
+ * @rx_defer_refill: Generate a refill reminder event
+ * @ev_probe: Allocate resources for event queue
+ * @ev_init: Initialise event queue on the NIC
+ * @ev_fini: Deinitialise event queue on the NIC
+ * @ev_remove: Free resources for event queue
+ * @ev_process: Process events for a queue, up to the given NAPI quota
+ * @ev_read_ack: Acknowledge read events on a queue, rearming its IRQ
+ * @ev_test_generate: Generate a test event
+ * @filter_table_probe: Probe filter capabilities and set up filter software state
+ * @filter_table_restore: Restore filters removed from hardware
+ * @filter_table_remove: Remove filters from hardware and tear down software state
+ * @filter_update_rx_scatter: Update filters after change to rx scatter setting
+ * @filter_insert: add or replace a filter
+ * @filter_remove_safe: remove a filter by ID, carefully
+ * @filter_get_safe: retrieve a filter by ID, carefully
+ * @filter_clear_rx: Remove all RX filters whose priority is less than or
+ *	equal to the given priority and is not %EF4_FILTER_PRI_AUTO
+ * @filter_count_rx_used: Get the number of filters in use at a given priority
+ * @filter_get_rx_id_limit: Get maximum value of a filter id, plus 1
+ * @filter_get_rx_ids: Get list of RX filters at a given priority
+ * @filter_rfs_insert: Add or replace a filter for RFS.  This must be
+ *	atomic.  The hardware change may be asynchronous but should
+ *	not be delayed for long.  It may fail if this can't be done
+ *	atomically.
+ * @filter_rfs_expire_one: Consider expiring a filter inserted for RFS.
+ *	This must check whether the specified table entry is used by RFS
+ *	and that rps_may_expire_flow() returns true for it.
+ * @mtd_probe: Probe and add MTD partitions associated with this net device,
+ *	 using ef4_mtd_add()
+ * @mtd_rename: Set an MTD partition name using the net device name
+ * @mtd_read: Read from an MTD partition
+ * @mtd_erase: Erase part of an MTD partition
+ * @mtd_write: Write to an MTD partition
+ * @mtd_sync: Wait for write-back to complete on MTD partition.  This
+ *	also notifies the driver that a writer has finished using this
+ *	partition.
+ * @set_mac_address: Set the MAC address of the device
+ * @revision: Hardware architecture revision
+ * @txd_ptr_tbl_base: TX descriptor ring base address
+ * @rxd_ptr_tbl_base: RX descriptor ring base address
+ * @buf_tbl_base: Buffer table base address
+ * @evq_ptr_tbl_base: Event queue pointer table base address
+ * @evq_rptr_tbl_base: Event queue read-pointer table base address
+ * @max_dma_mask: Maximum possible DMA mask
+ * @rx_prefix_size: Size of RX prefix before packet data
+ * @rx_hash_offset: Offset of RX flow hash within prefix
+ * @rx_ts_offset: Offset of timestamp within prefix
+ * @rx_buffer_padding: Size of padding at end of RX packet
+ * @can_rx_scatter: NIC is able to scatter packets to multiple buffers
+ * @always_rx_scatter: NIC will always scatter packets to multiple buffers
+ * @max_interrupt_mode: Highest capability interrupt mode supported
+ *	from &enum ef4_init_mode.
+ * @timer_period_max: Maximum period of interrupt timer (in ticks)
+ * @offload_features: net_device feature flags for protocol offload
+ *	features implemented in hardware
+ */
+struct ef4_nic_type {
+	unsigned int mem_bar;
+	unsigned int (*mem_map_size)(struct ef4_nic *efx);
+	int (*probe)(struct ef4_nic *efx);
+	void (*remove)(struct ef4_nic *efx);
+	int (*init)(struct ef4_nic *efx);
+	int (*dimension_resources)(struct ef4_nic *efx);
+	void (*fini)(struct ef4_nic *efx);
+	void (*monitor)(struct ef4_nic *efx);
+	enum reset_type (*map_reset_reason)(enum reset_type reason);
+	int (*map_reset_flags)(u32 *flags);
+	int (*reset)(struct ef4_nic *efx, enum reset_type method);
+	int (*probe_port)(struct ef4_nic *efx);
+	void (*remove_port)(struct ef4_nic *efx);
+	bool (*handle_global_event)(struct ef4_channel *channel, ef4_qword_t *);
+	int (*fini_dmaq)(struct ef4_nic *efx);
+	void (*prepare_flush)(struct ef4_nic *efx);
+	void (*finish_flush)(struct ef4_nic *efx);
+	void (*prepare_flr)(struct ef4_nic *efx);
+	void (*finish_flr)(struct ef4_nic *efx);
+	size_t (*describe_stats)(struct ef4_nic *efx, u8 *names);
+	size_t (*update_stats)(struct ef4_nic *efx, u64 *full_stats,
+			       struct rtnl_link_stats64 *core_stats);
+	void (*start_stats)(struct ef4_nic *efx);
+	void (*pull_stats)(struct ef4_nic *efx);
+	void (*stop_stats)(struct ef4_nic *efx);
+	void (*set_id_led)(struct ef4_nic *efx, enum ef4_led_mode mode);
+	void (*push_irq_moderation)(struct ef4_channel *channel);
+	int (*reconfigure_port)(struct ef4_nic *efx);
+	void (*prepare_enable_fc_tx)(struct ef4_nic *efx);
+	int (*reconfigure_mac)(struct ef4_nic *efx);
+	bool (*check_mac_fault)(struct ef4_nic *efx);
+	void (*get_wol)(struct ef4_nic *efx, struct ethtool_wolinfo *wol);
+	int (*set_wol)(struct ef4_nic *efx, u32 type);
+	void (*resume_wol)(struct ef4_nic *efx);
+	int (*test_chip)(struct ef4_nic *efx, struct ef4_self_tests *tests);
+	int (*test_nvram)(struct ef4_nic *efx);
+	void (*irq_enable_master)(struct ef4_nic *efx);
+	int (*irq_test_generate)(struct ef4_nic *efx);
+	void (*irq_disable_non_ev)(struct ef4_nic *efx);
+	irqreturn_t (*irq_handle_msi)(int irq, void *dev_id);
+	irqreturn_t (*irq_handle_legacy)(int irq, void *dev_id);
+	int (*tx_probe)(struct ef4_tx_queue *tx_queue);
+	void (*tx_init)(struct ef4_tx_queue *tx_queue);
+	void (*tx_remove)(struct ef4_tx_queue *tx_queue);
+	void (*tx_write)(struct ef4_tx_queue *tx_queue);
+	unsigned int (*tx_limit_len)(struct ef4_tx_queue *tx_queue,
+				     dma_addr_t dma_addr, unsigned int len);
+	int (*rx_push_rss_config)(struct ef4_nic *efx, bool user,
+				  const u32 *rx_indir_table);
+	int (*rx_probe)(struct ef4_rx_queue *rx_queue);
+	void (*rx_init)(struct ef4_rx_queue *rx_queue);
+	void (*rx_remove)(struct ef4_rx_queue *rx_queue);
+	void (*rx_write)(struct ef4_rx_queue *rx_queue);
+	void (*rx_defer_refill)(struct ef4_rx_queue *rx_queue);
+	int (*ev_probe)(struct ef4_channel *channel);
+	int (*ev_init)(struct ef4_channel *channel);
+	void (*ev_fini)(struct ef4_channel *channel);
+	void (*ev_remove)(struct ef4_channel *channel);
+	int (*ev_process)(struct ef4_channel *channel, int quota);
+	void (*ev_read_ack)(struct ef4_channel *channel);
+	void (*ev_test_generate)(struct ef4_channel *channel);
+	int (*filter_table_probe)(struct ef4_nic *efx);
+	void (*filter_table_restore)(struct ef4_nic *efx);
+	void (*filter_table_remove)(struct ef4_nic *efx);
+	void (*filter_update_rx_scatter)(struct ef4_nic *efx);
+	s32 (*filter_insert)(struct ef4_nic *efx,
+			     struct ef4_filter_spec *spec, bool replace);
+	int (*filter_remove_safe)(struct ef4_nic *efx,
+				  enum ef4_filter_priority priority,
+				  u32 filter_id);
+	int (*filter_get_safe)(struct ef4_nic *efx,
+			       enum ef4_filter_priority priority,
+			       u32 filter_id, struct ef4_filter_spec *);
+	int (*filter_clear_rx)(struct ef4_nic *efx,
+			       enum ef4_filter_priority priority);
+	u32 (*filter_count_rx_used)(struct ef4_nic *efx,
+				    enum ef4_filter_priority priority);
+	u32 (*filter_get_rx_id_limit)(struct ef4_nic *efx);
+	s32 (*filter_get_rx_ids)(struct ef4_nic *efx,
+				 enum ef4_filter_priority priority,
+				 u32 *buf, u32 size);
+#ifdef CONFIG_RFS_ACCEL
+	s32 (*filter_rfs_insert)(struct ef4_nic *efx,
+				 struct ef4_filter_spec *spec);
+	bool (*filter_rfs_expire_one)(struct ef4_nic *efx, u32 flow_id,
+				      unsigned int index);
+#endif
+#ifdef CONFIG_SFC_FALCON_MTD
+	int (*mtd_probe)(struct ef4_nic *efx);
+	void (*mtd_rename)(struct ef4_mtd_partition *part);
+	int (*mtd_read)(struct mtd_info *mtd, loff_t start, size_t len,
+			size_t *retlen, u8 *buffer);
+	int (*mtd_erase)(struct mtd_info *mtd, loff_t start, size_t len);
+	int (*mtd_write)(struct mtd_info *mtd, loff_t start, size_t len,
+			 size_t *retlen, const u8 *buffer);
+	int (*mtd_sync)(struct mtd_info *mtd);
+#endif
+	int (*get_mac_address)(struct ef4_nic *efx, unsigned char *perm_addr);
+	int (*set_mac_address)(struct ef4_nic *efx);
+
+	int revision;
+	unsigned int txd_ptr_tbl_base;
+	unsigned int rxd_ptr_tbl_base;
+	unsigned int buf_tbl_base;
+	unsigned int evq_ptr_tbl_base;
+	unsigned int evq_rptr_tbl_base;
+	u64 max_dma_mask;
+	unsigned int rx_prefix_size;
+	unsigned int rx_hash_offset;
+	unsigned int rx_ts_offset;
+	unsigned int rx_buffer_padding;
+	bool can_rx_scatter;
+	bool always_rx_scatter;
+	unsigned int max_interrupt_mode;
+	unsigned int timer_period_max;
+	netdev_features_t offload_features;
+	unsigned int max_rx_ip_filters;
+};
+
+/**************************************************************************
+ *
+ * Prototypes and inline functions
+ *
+ *************************************************************************/
+
+static inline struct ef4_channel *
+ef4_get_channel(struct ef4_nic *efx, unsigned index)
+{
+	EF4_BUG_ON_PARANOID(index >= efx->n_channels);
+	return efx->channel[index];
+}
+
+/* Iterate over all used channels */
+#define ef4_for_each_channel(_channel, _efx)				\
+	for (_channel = (_efx)->channel[0];				\
+	     _channel;							\
+	     _channel = (_channel->channel + 1 < (_efx)->n_channels) ?	\
+		     (_efx)->channel[_channel->channel + 1] : NULL)
+
+/* Iterate over all used channels in reverse */
+#define ef4_for_each_channel_rev(_channel, _efx)			\
+	for (_channel = (_efx)->channel[(_efx)->n_channels - 1];	\
+	     _channel;							\
+	     _channel = _channel->channel ?				\
+		     (_efx)->channel[_channel->channel - 1] : NULL)
+
+static inline struct ef4_tx_queue *
+ef4_get_tx_queue(struct ef4_nic *efx, unsigned index, unsigned type)
+{
+	EF4_BUG_ON_PARANOID(index >= efx->n_tx_channels ||
+			    type >= EF4_TXQ_TYPES);
+	return &efx->channel[efx->tx_channel_offset + index]->tx_queue[type];
+}
+
+static inline bool ef4_channel_has_tx_queues(struct ef4_channel *channel)
+{
+	return channel->channel - channel->efx->tx_channel_offset <
+		channel->efx->n_tx_channels;
+}
+
+static inline struct ef4_tx_queue *
+ef4_channel_get_tx_queue(struct ef4_channel *channel, unsigned type)
+{
+	EF4_BUG_ON_PARANOID(!ef4_channel_has_tx_queues(channel) ||
+			    type >= EF4_TXQ_TYPES);
+	return &channel->tx_queue[type];
+}
+
+static inline bool ef4_tx_queue_used(struct ef4_tx_queue *tx_queue)
+{
+	return !(tx_queue->efx->net_dev->num_tc < 2 &&
+		 tx_queue->queue & EF4_TXQ_TYPE_HIGHPRI);
+}
+
+/* Iterate over all TX queues belonging to a channel */
+#define ef4_for_each_channel_tx_queue(_tx_queue, _channel)		\
+	if (!ef4_channel_has_tx_queues(_channel))			\
+		;							\
+	else								\
+		for (_tx_queue = (_channel)->tx_queue;			\
+		     _tx_queue < (_channel)->tx_queue + EF4_TXQ_TYPES && \
+			     ef4_tx_queue_used(_tx_queue);		\
+		     _tx_queue++)
+
+/* Iterate over all possible TX queues belonging to a channel */
+#define ef4_for_each_possible_channel_tx_queue(_tx_queue, _channel)	\
+	if (!ef4_channel_has_tx_queues(_channel))			\
+		;							\
+	else								\
+		for (_tx_queue = (_channel)->tx_queue;			\
+		     _tx_queue < (_channel)->tx_queue + EF4_TXQ_TYPES;	\
+		     _tx_queue++)
+
+static inline bool ef4_channel_has_rx_queue(struct ef4_channel *channel)
+{
+	return channel->rx_queue.core_index >= 0;
+}
+
+static inline struct ef4_rx_queue *
+ef4_channel_get_rx_queue(struct ef4_channel *channel)
+{
+	EF4_BUG_ON_PARANOID(!ef4_channel_has_rx_queue(channel));
+	return &channel->rx_queue;
+}
+
+/* Iterate over all RX queues belonging to a channel */
+#define ef4_for_each_channel_rx_queue(_rx_queue, _channel)		\
+	if (!ef4_channel_has_rx_queue(_channel))			\
+		;							\
+	else								\
+		for (_rx_queue = &(_channel)->rx_queue;			\
+		     _rx_queue;						\
+		     _rx_queue = NULL)
+
+static inline struct ef4_channel *
+ef4_rx_queue_channel(struct ef4_rx_queue *rx_queue)
+{
+	return container_of(rx_queue, struct ef4_channel, rx_queue);
+}
+
+static inline int ef4_rx_queue_index(struct ef4_rx_queue *rx_queue)
+{
+	return ef4_rx_queue_channel(rx_queue)->channel;
+}
+
+/* Returns a pointer to the specified receive buffer in the RX
+ * descriptor queue.
+ */
+static inline struct ef4_rx_buffer *ef4_rx_buffer(struct ef4_rx_queue *rx_queue,
+						  unsigned int index)
+{
+	return &rx_queue->buffer[index];
+}
+
+/**
+ * EF4_MAX_FRAME_LEN - calculate maximum frame length
+ *
+ * This calculates the maximum frame length that will be used for a
+ * given MTU.  The frame length will be equal to the MTU plus a
+ * constant amount of header space and padding.  This is the quantity
+ * that the net driver will program into the MAC as the maximum frame
+ * length.
+ *
+ * The 10G MAC requires 8-byte alignment on the frame
+ * length, so we round up to the nearest 8.
+ *
+ * Re-clocking by the XGXS on RX can reduce an IPG to 32 bits (half an
+ * XGMII cycle).  If the frame length reaches the maximum value in the
+ * same cycle, the XMAC can miss the IPG altogether.  We work around
+ * this by adding a further 16 bytes.
+ */
+#define EF4_FRAME_PAD	16
+#define EF4_MAX_FRAME_LEN(mtu) \
+	(ALIGN(((mtu) + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN + EF4_FRAME_PAD), 8))
+
+/* Get all supported features.
+ * If a feature is not fixed, it is present in hw_features.
+ * If a feature is fixed, it does not present in hw_features, but
+ * always in features.
+ */
+static inline netdev_features_t ef4_supported_features(const struct ef4_nic *efx)
+{
+	const struct net_device *net_dev = efx->net_dev;
+
+	return net_dev->features | net_dev->hw_features;
+}
+
+/* Get the current TX queue insert index. */
+static inline unsigned int
+ef4_tx_queue_get_insert_index(const struct ef4_tx_queue *tx_queue)
+{
+	return tx_queue->insert_count & tx_queue->ptr_mask;
+}
+
+/* Get a TX buffer. */
+static inline struct ef4_tx_buffer *
+__ef4_tx_queue_get_insert_buffer(const struct ef4_tx_queue *tx_queue)
+{
+	return &tx_queue->buffer[ef4_tx_queue_get_insert_index(tx_queue)];
+}
+
+/* Get a TX buffer, checking it's not currently in use. */
+static inline struct ef4_tx_buffer *
+ef4_tx_queue_get_insert_buffer(const struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_tx_buffer *buffer =
+		__ef4_tx_queue_get_insert_buffer(tx_queue);
+
+	EF4_BUG_ON_PARANOID(buffer->len);
+	EF4_BUG_ON_PARANOID(buffer->flags);
+	EF4_BUG_ON_PARANOID(buffer->unmap_len);
+
+	return buffer;
+}
+
+#endif /* EF4_NET_DRIVER_H */
diff --git a/drivers/net/ethernet/sfc/falcon/nic.c b/drivers/net/ethernet/sfc/falcon/nic.c
new file mode 100644
index 0000000..a8ecb33
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/nic.c
@@ -0,0 +1,527 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/module.h>
+#include <linux/seq_file.h>
+#include <linux/cpu_rmap.h>
+#include "net_driver.h"
+#include "bitfield.h"
+#include "efx.h"
+#include "nic.h"
+#include "farch_regs.h"
+#include "io.h"
+#include "workarounds.h"
+
+/**************************************************************************
+ *
+ * Generic buffer handling
+ * These buffers are used for interrupt status, MAC stats, etc.
+ *
+ **************************************************************************/
+
+int ef4_nic_alloc_buffer(struct ef4_nic *efx, struct ef4_buffer *buffer,
+			 unsigned int len, gfp_t gfp_flags)
+{
+	buffer->addr = dma_zalloc_coherent(&efx->pci_dev->dev, len,
+					   &buffer->dma_addr, gfp_flags);
+	if (!buffer->addr)
+		return -ENOMEM;
+	buffer->len = len;
+	return 0;
+}
+
+void ef4_nic_free_buffer(struct ef4_nic *efx, struct ef4_buffer *buffer)
+{
+	if (buffer->addr) {
+		dma_free_coherent(&efx->pci_dev->dev, buffer->len,
+				  buffer->addr, buffer->dma_addr);
+		buffer->addr = NULL;
+	}
+}
+
+/* Check whether an event is present in the eventq at the current
+ * read pointer.  Only useful for self-test.
+ */
+bool ef4_nic_event_present(struct ef4_channel *channel)
+{
+	return ef4_event_present(ef4_event(channel, channel->eventq_read_ptr));
+}
+
+void ef4_nic_event_test_start(struct ef4_channel *channel)
+{
+	channel->event_test_cpu = -1;
+	smp_wmb();
+	channel->efx->type->ev_test_generate(channel);
+}
+
+int ef4_nic_irq_test_start(struct ef4_nic *efx)
+{
+	efx->last_irq_cpu = -1;
+	smp_wmb();
+	return efx->type->irq_test_generate(efx);
+}
+
+/* Hook interrupt handler(s)
+ * Try MSI and then legacy interrupts.
+ */
+int ef4_nic_init_interrupt(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+	unsigned int n_irqs;
+	int rc;
+
+	if (!EF4_INT_MODE_USE_MSI(efx)) {
+		rc = request_irq(efx->legacy_irq,
+				 efx->type->irq_handle_legacy, IRQF_SHARED,
+				 efx->name, efx);
+		if (rc) {
+			netif_err(efx, drv, efx->net_dev,
+				  "failed to hook legacy IRQ %d\n",
+				  efx->pci_dev->irq);
+			goto fail1;
+		}
+		return 0;
+	}
+
+#ifdef CONFIG_RFS_ACCEL
+	if (efx->interrupt_mode == EF4_INT_MODE_MSIX) {
+		efx->net_dev->rx_cpu_rmap =
+			alloc_irq_cpu_rmap(efx->n_rx_channels);
+		if (!efx->net_dev->rx_cpu_rmap) {
+			rc = -ENOMEM;
+			goto fail1;
+		}
+	}
+#endif
+
+	/* Hook MSI or MSI-X interrupt */
+	n_irqs = 0;
+	ef4_for_each_channel(channel, efx) {
+		rc = request_irq(channel->irq, efx->type->irq_handle_msi,
+				 IRQF_PROBE_SHARED, /* Not shared */
+				 efx->msi_context[channel->channel].name,
+				 &efx->msi_context[channel->channel]);
+		if (rc) {
+			netif_err(efx, drv, efx->net_dev,
+				  "failed to hook IRQ %d\n", channel->irq);
+			goto fail2;
+		}
+		++n_irqs;
+
+#ifdef CONFIG_RFS_ACCEL
+		if (efx->interrupt_mode == EF4_INT_MODE_MSIX &&
+		    channel->channel < efx->n_rx_channels) {
+			rc = irq_cpu_rmap_add(efx->net_dev->rx_cpu_rmap,
+					      channel->irq);
+			if (rc)
+				goto fail2;
+		}
+#endif
+	}
+
+	return 0;
+
+ fail2:
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+	efx->net_dev->rx_cpu_rmap = NULL;
+#endif
+	ef4_for_each_channel(channel, efx) {
+		if (n_irqs-- == 0)
+			break;
+		free_irq(channel->irq, &efx->msi_context[channel->channel]);
+	}
+ fail1:
+	return rc;
+}
+
+void ef4_nic_fini_interrupt(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+	efx->net_dev->rx_cpu_rmap = NULL;
+#endif
+
+	if (EF4_INT_MODE_USE_MSI(efx)) {
+		/* Disable MSI/MSI-X interrupts */
+		ef4_for_each_channel(channel, efx)
+			free_irq(channel->irq,
+				 &efx->msi_context[channel->channel]);
+	} else {
+		/* Disable legacy interrupt */
+		free_irq(efx->legacy_irq, efx);
+	}
+}
+
+/* Register dump */
+
+#define REGISTER_REVISION_FA	1
+#define REGISTER_REVISION_FB	2
+#define REGISTER_REVISION_FC	3
+#define REGISTER_REVISION_FZ	3	/* last Falcon arch revision */
+#define REGISTER_REVISION_ED	4
+#define REGISTER_REVISION_EZ	4	/* latest EF10 revision */
+
+struct ef4_nic_reg {
+	u32 offset:24;
+	u32 min_revision:3, max_revision:3;
+};
+
+#define REGISTER(name, arch, min_rev, max_rev) {			\
+	arch ## R_ ## min_rev ## max_rev ## _ ## name,			\
+	REGISTER_REVISION_ ## arch ## min_rev,				\
+	REGISTER_REVISION_ ## arch ## max_rev				\
+}
+#define REGISTER_AA(name) REGISTER(name, F, A, A)
+#define REGISTER_AB(name) REGISTER(name, F, A, B)
+#define REGISTER_AZ(name) REGISTER(name, F, A, Z)
+#define REGISTER_BB(name) REGISTER(name, F, B, B)
+#define REGISTER_BZ(name) REGISTER(name, F, B, Z)
+#define REGISTER_CZ(name) REGISTER(name, F, C, Z)
+
+static const struct ef4_nic_reg ef4_nic_regs[] = {
+	REGISTER_AZ(ADR_REGION),
+	REGISTER_AZ(INT_EN_KER),
+	REGISTER_BZ(INT_EN_CHAR),
+	REGISTER_AZ(INT_ADR_KER),
+	REGISTER_BZ(INT_ADR_CHAR),
+	/* INT_ACK_KER is WO */
+	/* INT_ISR0 is RC */
+	REGISTER_AZ(HW_INIT),
+	REGISTER_CZ(USR_EV_CFG),
+	REGISTER_AB(EE_SPI_HCMD),
+	REGISTER_AB(EE_SPI_HADR),
+	REGISTER_AB(EE_SPI_HDATA),
+	REGISTER_AB(EE_BASE_PAGE),
+	REGISTER_AB(EE_VPD_CFG0),
+	/* EE_VPD_SW_CNTL and EE_VPD_SW_DATA are not used */
+	/* PMBX_DBG_IADDR and PBMX_DBG_IDATA are indirect */
+	/* PCIE_CORE_INDIRECT is indirect */
+	REGISTER_AB(NIC_STAT),
+	REGISTER_AB(GPIO_CTL),
+	REGISTER_AB(GLB_CTL),
+	/* FATAL_INTR_KER and FATAL_INTR_CHAR are partly RC */
+	REGISTER_BZ(DP_CTRL),
+	REGISTER_AZ(MEM_STAT),
+	REGISTER_AZ(CS_DEBUG),
+	REGISTER_AZ(ALTERA_BUILD),
+	REGISTER_AZ(CSR_SPARE),
+	REGISTER_AB(PCIE_SD_CTL0123),
+	REGISTER_AB(PCIE_SD_CTL45),
+	REGISTER_AB(PCIE_PCS_CTL_STAT),
+	/* DEBUG_DATA_OUT is not used */
+	/* DRV_EV is WO */
+	REGISTER_AZ(EVQ_CTL),
+	REGISTER_AZ(EVQ_CNT1),
+	REGISTER_AZ(EVQ_CNT2),
+	REGISTER_AZ(BUF_TBL_CFG),
+	REGISTER_AZ(SRM_RX_DC_CFG),
+	REGISTER_AZ(SRM_TX_DC_CFG),
+	REGISTER_AZ(SRM_CFG),
+	/* BUF_TBL_UPD is WO */
+	REGISTER_AZ(SRM_UPD_EVQ),
+	REGISTER_AZ(SRAM_PARITY),
+	REGISTER_AZ(RX_CFG),
+	REGISTER_BZ(RX_FILTER_CTL),
+	/* RX_FLUSH_DESCQ is WO */
+	REGISTER_AZ(RX_DC_CFG),
+	REGISTER_AZ(RX_DC_PF_WM),
+	REGISTER_BZ(RX_RSS_TKEY),
+	/* RX_NODESC_DROP is RC */
+	REGISTER_AA(RX_SELF_RST),
+	/* RX_DEBUG, RX_PUSH_DROP are not used */
+	REGISTER_CZ(RX_RSS_IPV6_REG1),
+	REGISTER_CZ(RX_RSS_IPV6_REG2),
+	REGISTER_CZ(RX_RSS_IPV6_REG3),
+	/* TX_FLUSH_DESCQ is WO */
+	REGISTER_AZ(TX_DC_CFG),
+	REGISTER_AA(TX_CHKSM_CFG),
+	REGISTER_AZ(TX_CFG),
+	/* TX_PUSH_DROP is not used */
+	REGISTER_AZ(TX_RESERVED),
+	REGISTER_BZ(TX_PACE),
+	/* TX_PACE_DROP_QID is RC */
+	REGISTER_BB(TX_VLAN),
+	REGISTER_BZ(TX_IPFIL_PORTEN),
+	REGISTER_AB(MD_TXD),
+	REGISTER_AB(MD_RXD),
+	REGISTER_AB(MD_CS),
+	REGISTER_AB(MD_PHY_ADR),
+	REGISTER_AB(MD_ID),
+	/* MD_STAT is RC */
+	REGISTER_AB(MAC_STAT_DMA),
+	REGISTER_AB(MAC_CTRL),
+	REGISTER_BB(GEN_MODE),
+	REGISTER_AB(MAC_MC_HASH_REG0),
+	REGISTER_AB(MAC_MC_HASH_REG1),
+	REGISTER_AB(GM_CFG1),
+	REGISTER_AB(GM_CFG2),
+	/* GM_IPG and GM_HD are not used */
+	REGISTER_AB(GM_MAX_FLEN),
+	/* GM_TEST is not used */
+	REGISTER_AB(GM_ADR1),
+	REGISTER_AB(GM_ADR2),
+	REGISTER_AB(GMF_CFG0),
+	REGISTER_AB(GMF_CFG1),
+	REGISTER_AB(GMF_CFG2),
+	REGISTER_AB(GMF_CFG3),
+	REGISTER_AB(GMF_CFG4),
+	REGISTER_AB(GMF_CFG5),
+	REGISTER_BB(TX_SRC_MAC_CTL),
+	REGISTER_AB(XM_ADR_LO),
+	REGISTER_AB(XM_ADR_HI),
+	REGISTER_AB(XM_GLB_CFG),
+	REGISTER_AB(XM_TX_CFG),
+	REGISTER_AB(XM_RX_CFG),
+	REGISTER_AB(XM_MGT_INT_MASK),
+	REGISTER_AB(XM_FC),
+	REGISTER_AB(XM_PAUSE_TIME),
+	REGISTER_AB(XM_TX_PARAM),
+	REGISTER_AB(XM_RX_PARAM),
+	/* XM_MGT_INT_MSK (note no 'A') is RC */
+	REGISTER_AB(XX_PWR_RST),
+	REGISTER_AB(XX_SD_CTL),
+	REGISTER_AB(XX_TXDRV_CTL),
+	/* XX_PRBS_CTL, XX_PRBS_CHK and XX_PRBS_ERR are not used */
+	/* XX_CORE_STAT is partly RC */
+};
+
+struct ef4_nic_reg_table {
+	u32 offset:24;
+	u32 min_revision:3, max_revision:3;
+	u32 step:6, rows:21;
+};
+
+#define REGISTER_TABLE_DIMENSIONS(_, offset, arch, min_rev, max_rev, step, rows) { \
+	offset,								\
+	REGISTER_REVISION_ ## arch ## min_rev,				\
+	REGISTER_REVISION_ ## arch ## max_rev,				\
+	step, rows							\
+}
+#define REGISTER_TABLE(name, arch, min_rev, max_rev)			\
+	REGISTER_TABLE_DIMENSIONS(					\
+		name, arch ## R_ ## min_rev ## max_rev ## _ ## name,	\
+		arch, min_rev, max_rev,					\
+		arch ## R_ ## min_rev ## max_rev ## _ ## name ## _STEP,	\
+		arch ## R_ ## min_rev ## max_rev ## _ ## name ## _ROWS)
+#define REGISTER_TABLE_AA(name) REGISTER_TABLE(name, F, A, A)
+#define REGISTER_TABLE_AZ(name) REGISTER_TABLE(name, F, A, Z)
+#define REGISTER_TABLE_BB(name) REGISTER_TABLE(name, F, B, B)
+#define REGISTER_TABLE_BZ(name) REGISTER_TABLE(name, F, B, Z)
+#define REGISTER_TABLE_BB_CZ(name)					\
+	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, F, B, B,	\
+				  FR_BZ_ ## name ## _STEP,		\
+				  FR_BB_ ## name ## _ROWS),		\
+	REGISTER_TABLE_DIMENSIONS(name, FR_BZ_ ## name, F, C, Z,	\
+				  FR_BZ_ ## name ## _STEP,		\
+				  FR_CZ_ ## name ## _ROWS)
+#define REGISTER_TABLE_CZ(name) REGISTER_TABLE(name, F, C, Z)
+
+static const struct ef4_nic_reg_table ef4_nic_reg_tables[] = {
+	/* DRIVER is not used */
+	/* EVQ_RPTR, TIMER_COMMAND, USR_EV and {RX,TX}_DESC_UPD are WO */
+	REGISTER_TABLE_BB(TX_IPFIL_TBL),
+	REGISTER_TABLE_BB(TX_SRC_MAC_TBL),
+	REGISTER_TABLE_AA(RX_DESC_PTR_TBL_KER),
+	REGISTER_TABLE_BB_CZ(RX_DESC_PTR_TBL),
+	REGISTER_TABLE_AA(TX_DESC_PTR_TBL_KER),
+	REGISTER_TABLE_BB_CZ(TX_DESC_PTR_TBL),
+	REGISTER_TABLE_AA(EVQ_PTR_TBL_KER),
+	REGISTER_TABLE_BB_CZ(EVQ_PTR_TBL),
+	/* We can't reasonably read all of the buffer table (up to 8MB!).
+	 * However this driver will only use a few entries.  Reading
+	 * 1K entries allows for some expansion of queue count and
+	 * size before we need to change the version. */
+	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL_KER, FR_AA_BUF_FULL_TBL_KER,
+				  F, A, A, 8, 1024),
+	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL, FR_BZ_BUF_FULL_TBL,
+				  F, B, Z, 8, 1024),
+	REGISTER_TABLE_CZ(RX_MAC_FILTER_TBL0),
+	REGISTER_TABLE_BB_CZ(TIMER_TBL),
+	REGISTER_TABLE_BB_CZ(TX_PACE_TBL),
+	REGISTER_TABLE_BZ(RX_INDIRECTION_TBL),
+	/* TX_FILTER_TBL0 is huge and not used by this driver */
+	REGISTER_TABLE_CZ(TX_MAC_FILTER_TBL0),
+	REGISTER_TABLE_CZ(MC_TREG_SMEM),
+	/* MSIX_PBA_TABLE is not mapped */
+	/* SRM_DBG is not mapped (and is redundant with BUF_FLL_TBL) */
+	REGISTER_TABLE_BZ(RX_FILTER_TBL0),
+};
+
+size_t ef4_nic_get_regs_len(struct ef4_nic *efx)
+{
+	const struct ef4_nic_reg *reg;
+	const struct ef4_nic_reg_table *table;
+	size_t len = 0;
+
+	for (reg = ef4_nic_regs;
+	     reg < ef4_nic_regs + ARRAY_SIZE(ef4_nic_regs);
+	     reg++)
+		if (efx->type->revision >= reg->min_revision &&
+		    efx->type->revision <= reg->max_revision)
+			len += sizeof(ef4_oword_t);
+
+	for (table = ef4_nic_reg_tables;
+	     table < ef4_nic_reg_tables + ARRAY_SIZE(ef4_nic_reg_tables);
+	     table++)
+		if (efx->type->revision >= table->min_revision &&
+		    efx->type->revision <= table->max_revision)
+			len += table->rows * min_t(size_t, table->step, 16);
+
+	return len;
+}
+
+void ef4_nic_get_regs(struct ef4_nic *efx, void *buf)
+{
+	const struct ef4_nic_reg *reg;
+	const struct ef4_nic_reg_table *table;
+
+	for (reg = ef4_nic_regs;
+	     reg < ef4_nic_regs + ARRAY_SIZE(ef4_nic_regs);
+	     reg++) {
+		if (efx->type->revision >= reg->min_revision &&
+		    efx->type->revision <= reg->max_revision) {
+			ef4_reado(efx, (ef4_oword_t *)buf, reg->offset);
+			buf += sizeof(ef4_oword_t);
+		}
+	}
+
+	for (table = ef4_nic_reg_tables;
+	     table < ef4_nic_reg_tables + ARRAY_SIZE(ef4_nic_reg_tables);
+	     table++) {
+		size_t size, i;
+
+		if (!(efx->type->revision >= table->min_revision &&
+		      efx->type->revision <= table->max_revision))
+			continue;
+
+		size = min_t(size_t, table->step, 16);
+
+		for (i = 0; i < table->rows; i++) {
+			switch (table->step) {
+			case 4: /* 32-bit SRAM */
+				ef4_readd(efx, buf, table->offset + 4 * i);
+				break;
+			case 8: /* 64-bit SRAM */
+				ef4_sram_readq(efx,
+					       efx->membase + table->offset,
+					       buf, i);
+				break;
+			case 16: /* 128-bit-readable register */
+				ef4_reado_table(efx, buf, table->offset, i);
+				break;
+			case 32: /* 128-bit register, interleaved */
+				ef4_reado_table(efx, buf, table->offset, 2 * i);
+				break;
+			default:
+				WARN_ON(1);
+				return;
+			}
+			buf += size;
+		}
+	}
+}
+
+/**
+ * ef4_nic_describe_stats - Describe supported statistics for ethtool
+ * @desc: Array of &struct ef4_hw_stat_desc describing the statistics
+ * @count: Length of the @desc array
+ * @mask: Bitmask of which elements of @desc are enabled
+ * @names: Buffer to copy names to, or %NULL.  The names are copied
+ *	starting at intervals of %ETH_GSTRING_LEN bytes.
+ *
+ * Returns the number of visible statistics, i.e. the number of set
+ * bits in the first @count bits of @mask for which a name is defined.
+ */
+size_t ef4_nic_describe_stats(const struct ef4_hw_stat_desc *desc, size_t count,
+			      const unsigned long *mask, u8 *names)
+{
+	size_t visible = 0;
+	size_t index;
+
+	for_each_set_bit(index, mask, count) {
+		if (desc[index].name) {
+			if (names) {
+				strlcpy(names, desc[index].name,
+					ETH_GSTRING_LEN);
+				names += ETH_GSTRING_LEN;
+			}
+			++visible;
+		}
+	}
+
+	return visible;
+}
+
+/**
+ * ef4_nic_update_stats - Convert statistics DMA buffer to array of u64
+ * @desc: Array of &struct ef4_hw_stat_desc describing the DMA buffer
+ *	layout.  DMA widths of 0, 16, 32 and 64 are supported; where
+ *	the width is specified as 0 the corresponding element of
+ *	@stats is not updated.
+ * @count: Length of the @desc array
+ * @mask: Bitmask of which elements of @desc are enabled
+ * @stats: Buffer to update with the converted statistics.  The length
+ *	of this array must be at least @count.
+ * @dma_buf: DMA buffer containing hardware statistics
+ * @accumulate: If set, the converted values will be added rather than
+ *	directly stored to the corresponding elements of @stats
+ */
+void ef4_nic_update_stats(const struct ef4_hw_stat_desc *desc, size_t count,
+			  const unsigned long *mask,
+			  u64 *stats, const void *dma_buf, bool accumulate)
+{
+	size_t index;
+
+	for_each_set_bit(index, mask, count) {
+		if (desc[index].dma_width) {
+			const void *addr = dma_buf + desc[index].offset;
+			u64 val;
+
+			switch (desc[index].dma_width) {
+			case 16:
+				val = le16_to_cpup((__le16 *)addr);
+				break;
+			case 32:
+				val = le32_to_cpup((__le32 *)addr);
+				break;
+			case 64:
+				val = le64_to_cpup((__le64 *)addr);
+				break;
+			default:
+				WARN_ON(1);
+				val = 0;
+				break;
+			}
+
+			if (accumulate)
+				stats[index] += val;
+			else
+				stats[index] = val;
+		}
+	}
+}
+
+void ef4_nic_fix_nodesc_drop_stat(struct ef4_nic *efx, u64 *rx_nodesc_drops)
+{
+	/* if down, or this is the first update after coming up */
+	if (!(efx->net_dev->flags & IFF_UP) || !efx->rx_nodesc_drops_prev_state)
+		efx->rx_nodesc_drops_while_down +=
+			*rx_nodesc_drops - efx->rx_nodesc_drops_total;
+	efx->rx_nodesc_drops_total = *rx_nodesc_drops;
+	efx->rx_nodesc_drops_prev_state = !!(efx->net_dev->flags & IFF_UP);
+	*rx_nodesc_drops -= efx->rx_nodesc_drops_while_down;
+}
diff --git a/drivers/net/ethernet/sfc/falcon/nic.h b/drivers/net/ethernet/sfc/falcon/nic.h
new file mode 100644
index 0000000..a4c4592
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/nic.h
@@ -0,0 +1,513 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_NIC_H
+#define EF4_NIC_H
+
+#include <linux/net_tstamp.h>
+#include <linux/i2c-algo-bit.h>
+#include "net_driver.h"
+#include "efx.h"
+
+enum {
+	EF4_REV_FALCON_A0 = 0,
+	EF4_REV_FALCON_A1 = 1,
+	EF4_REV_FALCON_B0 = 2,
+};
+
+static inline int ef4_nic_rev(struct ef4_nic *efx)
+{
+	return efx->type->revision;
+}
+
+u32 ef4_farch_fpga_ver(struct ef4_nic *efx);
+
+/* NIC has two interlinked PCI functions for the same port. */
+static inline bool ef4_nic_is_dual_func(struct ef4_nic *efx)
+{
+	return ef4_nic_rev(efx) < EF4_REV_FALCON_B0;
+}
+
+/* Read the current event from the event queue */
+static inline ef4_qword_t *ef4_event(struct ef4_channel *channel,
+				     unsigned int index)
+{
+	return ((ef4_qword_t *) (channel->eventq.buf.addr)) +
+		(index & channel->eventq_mask);
+}
+
+/* See if an event is present
+ *
+ * We check both the high and low dword of the event for all ones.  We
+ * wrote all ones when we cleared the event, and no valid event can
+ * have all ones in either its high or low dwords.  This approach is
+ * robust against reordering.
+ *
+ * Note that using a single 64-bit comparison is incorrect; even
+ * though the CPU read will be atomic, the DMA write may not be.
+ */
+static inline int ef4_event_present(ef4_qword_t *event)
+{
+	return !(EF4_DWORD_IS_ALL_ONES(event->dword[0]) |
+		  EF4_DWORD_IS_ALL_ONES(event->dword[1]));
+}
+
+/* Returns a pointer to the specified transmit descriptor in the TX
+ * descriptor queue belonging to the specified channel.
+ */
+static inline ef4_qword_t *
+ef4_tx_desc(struct ef4_tx_queue *tx_queue, unsigned int index)
+{
+	return ((ef4_qword_t *) (tx_queue->txd.buf.addr)) + index;
+}
+
+/* Get partner of a TX queue, seen as part of the same net core queue */
+static inline struct ef4_tx_queue *ef4_tx_queue_partner(struct ef4_tx_queue *tx_queue)
+{
+	if (tx_queue->queue & EF4_TXQ_TYPE_OFFLOAD)
+		return tx_queue - EF4_TXQ_TYPE_OFFLOAD;
+	else
+		return tx_queue + EF4_TXQ_TYPE_OFFLOAD;
+}
+
+/* Report whether this TX queue would be empty for the given write_count.
+ * May return false negative.
+ */
+static inline bool __ef4_nic_tx_is_empty(struct ef4_tx_queue *tx_queue,
+					 unsigned int write_count)
+{
+	unsigned int empty_read_count = ACCESS_ONCE(tx_queue->empty_read_count);
+
+	if (empty_read_count == 0)
+		return false;
+
+	return ((empty_read_count ^ write_count) & ~EF4_EMPTY_COUNT_VALID) == 0;
+}
+
+/* Decide whether to push a TX descriptor to the NIC vs merely writing
+ * the doorbell.  This can reduce latency when we are adding a single
+ * descriptor to an empty queue, but is otherwise pointless.  Further,
+ * Falcon and Siena have hardware bugs (SF bug 33851) that may be
+ * triggered if we don't check this.
+ * We use the write_count used for the last doorbell push, to get the
+ * NIC's view of the tx queue.
+ */
+static inline bool ef4_nic_may_push_tx_desc(struct ef4_tx_queue *tx_queue,
+					    unsigned int write_count)
+{
+	bool was_empty = __ef4_nic_tx_is_empty(tx_queue, write_count);
+
+	tx_queue->empty_read_count = 0;
+	return was_empty && tx_queue->write_count - write_count == 1;
+}
+
+/* Returns a pointer to the specified descriptor in the RX descriptor queue */
+static inline ef4_qword_t *
+ef4_rx_desc(struct ef4_rx_queue *rx_queue, unsigned int index)
+{
+	return ((ef4_qword_t *) (rx_queue->rxd.buf.addr)) + index;
+}
+
+enum {
+	PHY_TYPE_NONE = 0,
+	PHY_TYPE_TXC43128 = 1,
+	PHY_TYPE_88E1111 = 2,
+	PHY_TYPE_SFX7101 = 3,
+	PHY_TYPE_QT2022C2 = 4,
+	PHY_TYPE_PM8358 = 6,
+	PHY_TYPE_SFT9001A = 8,
+	PHY_TYPE_QT2025C = 9,
+	PHY_TYPE_SFT9001B = 10,
+};
+
+#define FALCON_XMAC_LOOPBACKS			\
+	((1 << LOOPBACK_XGMII) |		\
+	 (1 << LOOPBACK_XGXS) |			\
+	 (1 << LOOPBACK_XAUI))
+
+/* Alignment of PCIe DMA boundaries (4KB) */
+#define EF4_PAGE_SIZE	4096
+/* Size and alignment of buffer table entries (same) */
+#define EF4_BUF_SIZE	EF4_PAGE_SIZE
+
+/* NIC-generic software stats */
+enum {
+	GENERIC_STAT_rx_noskb_drops,
+	GENERIC_STAT_rx_nodesc_trunc,
+	GENERIC_STAT_COUNT
+};
+
+/**
+ * struct falcon_board_type - board operations and type information
+ * @id: Board type id, as found in NVRAM
+ * @init: Allocate resources and initialise peripheral hardware
+ * @init_phy: Do board-specific PHY initialisation
+ * @fini: Shut down hardware and free resources
+ * @set_id_led: Set state of identifying LED or revert to automatic function
+ * @monitor: Board-specific health check function
+ */
+struct falcon_board_type {
+	u8 id;
+	int (*init) (struct ef4_nic *nic);
+	void (*init_phy) (struct ef4_nic *efx);
+	void (*fini) (struct ef4_nic *nic);
+	void (*set_id_led) (struct ef4_nic *efx, enum ef4_led_mode mode);
+	int (*monitor) (struct ef4_nic *nic);
+};
+
+/**
+ * struct falcon_board - board information
+ * @type: Type of board
+ * @major: Major rev. ('A', 'B' ...)
+ * @minor: Minor rev. (0, 1, ...)
+ * @i2c_adap: I2C adapter for on-board peripherals
+ * @i2c_data: Data for bit-banging algorithm
+ * @hwmon_client: I2C client for hardware monitor
+ * @ioexp_client: I2C client for power/port control
+ */
+struct falcon_board {
+	const struct falcon_board_type *type;
+	int major;
+	int minor;
+	struct i2c_adapter i2c_adap;
+	struct i2c_algo_bit_data i2c_data;
+	struct i2c_client *hwmon_client, *ioexp_client;
+};
+
+/**
+ * struct falcon_spi_device - a Falcon SPI (Serial Peripheral Interface) device
+ * @device_id:		Controller's id for the device
+ * @size:		Size (in bytes)
+ * @addr_len:		Number of address bytes in read/write commands
+ * @munge_address:	Flag whether addresses should be munged.
+ *	Some devices with 9-bit addresses (e.g. AT25040A EEPROM)
+ *	use bit 3 of the command byte as address bit A8, rather
+ *	than having a two-byte address.  If this flag is set, then
+ *	commands should be munged in this way.
+ * @erase_command:	Erase command (or 0 if sector erase not needed).
+ * @erase_size:		Erase sector size (in bytes)
+ *	Erase commands affect sectors with this size and alignment.
+ *	This must be a power of two.
+ * @block_size:		Write block size (in bytes).
+ *	Write commands are limited to blocks with this size and alignment.
+ */
+struct falcon_spi_device {
+	int device_id;
+	unsigned int size;
+	unsigned int addr_len;
+	unsigned int munge_address:1;
+	u8 erase_command;
+	unsigned int erase_size;
+	unsigned int block_size;
+};
+
+static inline bool falcon_spi_present(const struct falcon_spi_device *spi)
+{
+	return spi->size != 0;
+}
+
+enum {
+	FALCON_STAT_tx_bytes = GENERIC_STAT_COUNT,
+	FALCON_STAT_tx_packets,
+	FALCON_STAT_tx_pause,
+	FALCON_STAT_tx_control,
+	FALCON_STAT_tx_unicast,
+	FALCON_STAT_tx_multicast,
+	FALCON_STAT_tx_broadcast,
+	FALCON_STAT_tx_lt64,
+	FALCON_STAT_tx_64,
+	FALCON_STAT_tx_65_to_127,
+	FALCON_STAT_tx_128_to_255,
+	FALCON_STAT_tx_256_to_511,
+	FALCON_STAT_tx_512_to_1023,
+	FALCON_STAT_tx_1024_to_15xx,
+	FALCON_STAT_tx_15xx_to_jumbo,
+	FALCON_STAT_tx_gtjumbo,
+	FALCON_STAT_tx_non_tcpudp,
+	FALCON_STAT_tx_mac_src_error,
+	FALCON_STAT_tx_ip_src_error,
+	FALCON_STAT_rx_bytes,
+	FALCON_STAT_rx_good_bytes,
+	FALCON_STAT_rx_bad_bytes,
+	FALCON_STAT_rx_packets,
+	FALCON_STAT_rx_good,
+	FALCON_STAT_rx_bad,
+	FALCON_STAT_rx_pause,
+	FALCON_STAT_rx_control,
+	FALCON_STAT_rx_unicast,
+	FALCON_STAT_rx_multicast,
+	FALCON_STAT_rx_broadcast,
+	FALCON_STAT_rx_lt64,
+	FALCON_STAT_rx_64,
+	FALCON_STAT_rx_65_to_127,
+	FALCON_STAT_rx_128_to_255,
+	FALCON_STAT_rx_256_to_511,
+	FALCON_STAT_rx_512_to_1023,
+	FALCON_STAT_rx_1024_to_15xx,
+	FALCON_STAT_rx_15xx_to_jumbo,
+	FALCON_STAT_rx_gtjumbo,
+	FALCON_STAT_rx_bad_lt64,
+	FALCON_STAT_rx_bad_gtjumbo,
+	FALCON_STAT_rx_overflow,
+	FALCON_STAT_rx_symbol_error,
+	FALCON_STAT_rx_align_error,
+	FALCON_STAT_rx_length_error,
+	FALCON_STAT_rx_internal_error,
+	FALCON_STAT_rx_nodesc_drop_cnt,
+	FALCON_STAT_COUNT
+};
+
+/**
+ * struct falcon_nic_data - Falcon NIC state
+ * @pci_dev2: Secondary function of Falcon A
+ * @board: Board state and functions
+ * @stats: Hardware statistics
+ * @stats_disable_count: Nest count for disabling statistics fetches
+ * @stats_pending: Is there a pending DMA of MAC statistics.
+ * @stats_timer: A timer for regularly fetching MAC statistics.
+ * @spi_flash: SPI flash device
+ * @spi_eeprom: SPI EEPROM device
+ * @spi_lock: SPI bus lock
+ * @mdio_lock: MDIO bus lock
+ * @xmac_poll_required: XMAC link state needs polling
+ */
+struct falcon_nic_data {
+	struct pci_dev *pci_dev2;
+	struct falcon_board board;
+	u64 stats[FALCON_STAT_COUNT];
+	unsigned int stats_disable_count;
+	bool stats_pending;
+	struct timer_list stats_timer;
+	struct falcon_spi_device spi_flash;
+	struct falcon_spi_device spi_eeprom;
+	struct mutex spi_lock;
+	struct mutex mdio_lock;
+	bool xmac_poll_required;
+};
+
+static inline struct falcon_board *falcon_board(struct ef4_nic *efx)
+{
+	struct falcon_nic_data *data = efx->nic_data;
+	return &data->board;
+}
+
+struct ethtool_ts_info;
+
+extern const struct ef4_nic_type falcon_a1_nic_type;
+extern const struct ef4_nic_type falcon_b0_nic_type;
+
+/**************************************************************************
+ *
+ * Externs
+ *
+ **************************************************************************
+ */
+
+int falcon_probe_board(struct ef4_nic *efx, u16 revision_info);
+
+/* TX data path */
+static inline int ef4_nic_probe_tx(struct ef4_tx_queue *tx_queue)
+{
+	return tx_queue->efx->type->tx_probe(tx_queue);
+}
+static inline void ef4_nic_init_tx(struct ef4_tx_queue *tx_queue)
+{
+	tx_queue->efx->type->tx_init(tx_queue);
+}
+static inline void ef4_nic_remove_tx(struct ef4_tx_queue *tx_queue)
+{
+	tx_queue->efx->type->tx_remove(tx_queue);
+}
+static inline void ef4_nic_push_buffers(struct ef4_tx_queue *tx_queue)
+{
+	tx_queue->efx->type->tx_write(tx_queue);
+}
+
+/* RX data path */
+static inline int ef4_nic_probe_rx(struct ef4_rx_queue *rx_queue)
+{
+	return rx_queue->efx->type->rx_probe(rx_queue);
+}
+static inline void ef4_nic_init_rx(struct ef4_rx_queue *rx_queue)
+{
+	rx_queue->efx->type->rx_init(rx_queue);
+}
+static inline void ef4_nic_remove_rx(struct ef4_rx_queue *rx_queue)
+{
+	rx_queue->efx->type->rx_remove(rx_queue);
+}
+static inline void ef4_nic_notify_rx_desc(struct ef4_rx_queue *rx_queue)
+{
+	rx_queue->efx->type->rx_write(rx_queue);
+}
+static inline void ef4_nic_generate_fill_event(struct ef4_rx_queue *rx_queue)
+{
+	rx_queue->efx->type->rx_defer_refill(rx_queue);
+}
+
+/* Event data path */
+static inline int ef4_nic_probe_eventq(struct ef4_channel *channel)
+{
+	return channel->efx->type->ev_probe(channel);
+}
+static inline int ef4_nic_init_eventq(struct ef4_channel *channel)
+{
+	return channel->efx->type->ev_init(channel);
+}
+static inline void ef4_nic_fini_eventq(struct ef4_channel *channel)
+{
+	channel->efx->type->ev_fini(channel);
+}
+static inline void ef4_nic_remove_eventq(struct ef4_channel *channel)
+{
+	channel->efx->type->ev_remove(channel);
+}
+static inline int
+ef4_nic_process_eventq(struct ef4_channel *channel, int quota)
+{
+	return channel->efx->type->ev_process(channel, quota);
+}
+static inline void ef4_nic_eventq_read_ack(struct ef4_channel *channel)
+{
+	channel->efx->type->ev_read_ack(channel);
+}
+void ef4_nic_event_test_start(struct ef4_channel *channel);
+
+/* queue operations */
+int ef4_farch_tx_probe(struct ef4_tx_queue *tx_queue);
+void ef4_farch_tx_init(struct ef4_tx_queue *tx_queue);
+void ef4_farch_tx_fini(struct ef4_tx_queue *tx_queue);
+void ef4_farch_tx_remove(struct ef4_tx_queue *tx_queue);
+void ef4_farch_tx_write(struct ef4_tx_queue *tx_queue);
+unsigned int ef4_farch_tx_limit_len(struct ef4_tx_queue *tx_queue,
+				    dma_addr_t dma_addr, unsigned int len);
+int ef4_farch_rx_probe(struct ef4_rx_queue *rx_queue);
+void ef4_farch_rx_init(struct ef4_rx_queue *rx_queue);
+void ef4_farch_rx_fini(struct ef4_rx_queue *rx_queue);
+void ef4_farch_rx_remove(struct ef4_rx_queue *rx_queue);
+void ef4_farch_rx_write(struct ef4_rx_queue *rx_queue);
+void ef4_farch_rx_defer_refill(struct ef4_rx_queue *rx_queue);
+int ef4_farch_ev_probe(struct ef4_channel *channel);
+int ef4_farch_ev_init(struct ef4_channel *channel);
+void ef4_farch_ev_fini(struct ef4_channel *channel);
+void ef4_farch_ev_remove(struct ef4_channel *channel);
+int ef4_farch_ev_process(struct ef4_channel *channel, int quota);
+void ef4_farch_ev_read_ack(struct ef4_channel *channel);
+void ef4_farch_ev_test_generate(struct ef4_channel *channel);
+
+/* filter operations */
+int ef4_farch_filter_table_probe(struct ef4_nic *efx);
+void ef4_farch_filter_table_restore(struct ef4_nic *efx);
+void ef4_farch_filter_table_remove(struct ef4_nic *efx);
+void ef4_farch_filter_update_rx_scatter(struct ef4_nic *efx);
+s32 ef4_farch_filter_insert(struct ef4_nic *efx, struct ef4_filter_spec *spec,
+			    bool replace);
+int ef4_farch_filter_remove_safe(struct ef4_nic *efx,
+				 enum ef4_filter_priority priority,
+				 u32 filter_id);
+int ef4_farch_filter_get_safe(struct ef4_nic *efx,
+			      enum ef4_filter_priority priority, u32 filter_id,
+			      struct ef4_filter_spec *);
+int ef4_farch_filter_clear_rx(struct ef4_nic *efx,
+			      enum ef4_filter_priority priority);
+u32 ef4_farch_filter_count_rx_used(struct ef4_nic *efx,
+				   enum ef4_filter_priority priority);
+u32 ef4_farch_filter_get_rx_id_limit(struct ef4_nic *efx);
+s32 ef4_farch_filter_get_rx_ids(struct ef4_nic *efx,
+				enum ef4_filter_priority priority, u32 *buf,
+				u32 size);
+#ifdef CONFIG_RFS_ACCEL
+s32 ef4_farch_filter_rfs_insert(struct ef4_nic *efx,
+				struct ef4_filter_spec *spec);
+bool ef4_farch_filter_rfs_expire_one(struct ef4_nic *efx, u32 flow_id,
+				     unsigned int index);
+#endif
+void ef4_farch_filter_sync_rx_mode(struct ef4_nic *efx);
+
+bool ef4_nic_event_present(struct ef4_channel *channel);
+
+/* Some statistics are computed as A - B where A and B each increase
+ * linearly with some hardware counter(s) and the counters are read
+ * asynchronously.  If the counters contributing to B are always read
+ * after those contributing to A, the computed value may be lower than
+ * the true value by some variable amount, and may decrease between
+ * subsequent computations.
+ *
+ * We should never allow statistics to decrease or to exceed the true
+ * value.  Since the computed value will never be greater than the
+ * true value, we can achieve this by only storing the computed value
+ * when it increases.
+ */
+static inline void ef4_update_diff_stat(u64 *stat, u64 diff)
+{
+	if ((s64)(diff - *stat) > 0)
+		*stat = diff;
+}
+
+/* Interrupts */
+int ef4_nic_init_interrupt(struct ef4_nic *efx);
+int ef4_nic_irq_test_start(struct ef4_nic *efx);
+void ef4_nic_fini_interrupt(struct ef4_nic *efx);
+void ef4_farch_irq_enable_master(struct ef4_nic *efx);
+int ef4_farch_irq_test_generate(struct ef4_nic *efx);
+void ef4_farch_irq_disable_master(struct ef4_nic *efx);
+irqreturn_t ef4_farch_msi_interrupt(int irq, void *dev_id);
+irqreturn_t ef4_farch_legacy_interrupt(int irq, void *dev_id);
+irqreturn_t ef4_farch_fatal_interrupt(struct ef4_nic *efx);
+
+static inline int ef4_nic_event_test_irq_cpu(struct ef4_channel *channel)
+{
+	return ACCESS_ONCE(channel->event_test_cpu);
+}
+static inline int ef4_nic_irq_test_irq_cpu(struct ef4_nic *efx)
+{
+	return ACCESS_ONCE(efx->last_irq_cpu);
+}
+
+/* Global Resources */
+int ef4_nic_flush_queues(struct ef4_nic *efx);
+int ef4_farch_fini_dmaq(struct ef4_nic *efx);
+void ef4_farch_finish_flr(struct ef4_nic *efx);
+void falcon_start_nic_stats(struct ef4_nic *efx);
+void falcon_stop_nic_stats(struct ef4_nic *efx);
+int falcon_reset_xaui(struct ef4_nic *efx);
+void ef4_farch_dimension_resources(struct ef4_nic *efx, unsigned sram_lim_qw);
+void ef4_farch_init_common(struct ef4_nic *efx);
+void ef4_farch_rx_push_indir_table(struct ef4_nic *efx);
+
+int ef4_nic_alloc_buffer(struct ef4_nic *efx, struct ef4_buffer *buffer,
+			 unsigned int len, gfp_t gfp_flags);
+void ef4_nic_free_buffer(struct ef4_nic *efx, struct ef4_buffer *buffer);
+
+/* Tests */
+struct ef4_farch_register_test {
+	unsigned address;
+	ef4_oword_t mask;
+};
+int ef4_farch_test_registers(struct ef4_nic *efx,
+			     const struct ef4_farch_register_test *regs,
+			     size_t n_regs);
+
+size_t ef4_nic_get_regs_len(struct ef4_nic *efx);
+void ef4_nic_get_regs(struct ef4_nic *efx, void *buf);
+
+size_t ef4_nic_describe_stats(const struct ef4_hw_stat_desc *desc, size_t count,
+			      const unsigned long *mask, u8 *names);
+void ef4_nic_update_stats(const struct ef4_hw_stat_desc *desc, size_t count,
+			  const unsigned long *mask, u64 *stats,
+			  const void *dma_buf, bool accumulate);
+void ef4_nic_fix_nodesc_drop_stat(struct ef4_nic *efx, u64 *stat);
+
+#define EF4_MAX_FLUSH_TIME 5000
+
+void ef4_farch_generate_event(struct ef4_nic *efx, unsigned int evq,
+			      ef4_qword_t *event);
+
+#endif /* EF4_NIC_H */
diff --git a/drivers/net/ethernet/sfc/falcon/phy.h b/drivers/net/ethernet/sfc/falcon/phy.h
new file mode 100644
index 0000000..362141c
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/phy.h
@@ -0,0 +1,50 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2007-2010 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_PHY_H
+#define EF4_PHY_H
+
+/****************************************************************************
+ * 10Xpress (SFX7101) PHY
+ */
+extern const struct ef4_phy_operations falcon_sfx7101_phy_ops;
+
+void tenxpress_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode);
+
+/****************************************************************************
+ * AMCC/Quake QT202x PHYs
+ */
+extern const struct ef4_phy_operations falcon_qt202x_phy_ops;
+
+/* These PHYs provide various H/W control states for LEDs */
+#define QUAKE_LED_LINK_INVAL	(0)
+#define QUAKE_LED_LINK_STAT	(1)
+#define QUAKE_LED_LINK_ACT	(2)
+#define QUAKE_LED_LINK_ACTSTAT	(3)
+#define QUAKE_LED_OFF		(4)
+#define QUAKE_LED_ON		(5)
+#define QUAKE_LED_LINK_INPUT	(6)	/* Pin is an input. */
+/* What link the LED tracks */
+#define QUAKE_LED_TXLINK	(0)
+#define QUAKE_LED_RXLINK	(8)
+
+void falcon_qt202x_set_led(struct ef4_nic *p, int led, int state);
+
+/****************************************************************************
+* Transwitch CX4 retimer
+*/
+extern const struct ef4_phy_operations falcon_txc_phy_ops;
+
+#define TXC_GPIO_DIR_INPUT	0
+#define TXC_GPIO_DIR_OUTPUT	1
+
+void falcon_txc_set_gpio_dir(struct ef4_nic *efx, int pin, int dir);
+void falcon_txc_set_gpio_val(struct ef4_nic *efx, int pin, int val);
+
+#endif
diff --git a/drivers/net/ethernet/sfc/falcon/qt202x_phy.c b/drivers/net/ethernet/sfc/falcon/qt202x_phy.c
new file mode 100644
index 0000000..ae73ee9
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/qt202x_phy.c
@@ -0,0 +1,495 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2006-2012 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+/*
+ * Driver for AMCC QT202x SFP+ and XFP adapters; see www.amcc.com for details
+ */
+
+#include <linux/slab.h>
+#include <linux/timer.h>
+#include <linux/delay.h>
+#include "efx.h"
+#include "mdio_10g.h"
+#include "phy.h"
+#include "nic.h"
+
+#define QT202X_REQUIRED_DEVS (MDIO_DEVS_PCS |		\
+			      MDIO_DEVS_PMAPMD |	\
+			      MDIO_DEVS_PHYXS)
+
+#define QT202X_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
+			  (1 << LOOPBACK_PMAPMD) |	\
+			  (1 << LOOPBACK_PHYXS_WS))
+
+/****************************************************************************/
+/* Quake-specific MDIO registers */
+#define MDIO_QUAKE_LED0_REG	(0xD006)
+
+/* QT2025C only */
+#define PCS_FW_HEARTBEAT_REG	0xd7ee
+#define PCS_FW_HEARTB_LBN	0
+#define PCS_FW_HEARTB_WIDTH	8
+#define PCS_FW_PRODUCT_CODE_1	0xd7f0
+#define PCS_FW_VERSION_1	0xd7f3
+#define PCS_FW_BUILD_1		0xd7f6
+#define PCS_UC8051_STATUS_REG	0xd7fd
+#define PCS_UC_STATUS_LBN	0
+#define PCS_UC_STATUS_WIDTH	8
+#define PCS_UC_STATUS_FW_SAVE	0x20
+#define PMA_PMD_MODE_REG	0xc301
+#define PMA_PMD_RXIN_SEL_LBN	6
+#define PMA_PMD_FTX_CTRL2_REG	0xc309
+#define PMA_PMD_FTX_STATIC_LBN	13
+#define PMA_PMD_VEND1_REG	0xc001
+#define PMA_PMD_VEND1_LBTXD_LBN	15
+#define PCS_VEND1_REG		0xc000
+#define PCS_VEND1_LBTXD_LBN	5
+
+void falcon_qt202x_set_led(struct ef4_nic *p, int led, int mode)
+{
+	int addr = MDIO_QUAKE_LED0_REG + led;
+	ef4_mdio_write(p, MDIO_MMD_PMAPMD, addr, mode);
+}
+
+struct qt202x_phy_data {
+	enum ef4_phy_mode phy_mode;
+	bool bug17190_in_bad_state;
+	unsigned long bug17190_timer;
+	u32 firmware_ver;
+};
+
+#define QT2022C2_MAX_RESET_TIME 500
+#define QT2022C2_RESET_WAIT 10
+
+#define QT2025C_MAX_HEARTB_TIME (5 * HZ)
+#define QT2025C_HEARTB_WAIT 100
+#define QT2025C_MAX_FWSTART_TIME (25 * HZ / 10)
+#define QT2025C_FWSTART_WAIT 100
+
+#define BUG17190_INTERVAL (2 * HZ)
+
+static int qt2025c_wait_heartbeat(struct ef4_nic *efx)
+{
+	unsigned long timeout = jiffies + QT2025C_MAX_HEARTB_TIME;
+	int reg, old_counter = 0;
+
+	/* Wait for firmware heartbeat to start */
+	for (;;) {
+		int counter;
+		reg = ef4_mdio_read(efx, MDIO_MMD_PCS, PCS_FW_HEARTBEAT_REG);
+		if (reg < 0)
+			return reg;
+		counter = ((reg >> PCS_FW_HEARTB_LBN) &
+			    ((1 << PCS_FW_HEARTB_WIDTH) - 1));
+		if (old_counter == 0)
+			old_counter = counter;
+		else if (counter != old_counter)
+			break;
+		if (time_after(jiffies, timeout)) {
+			/* Some cables have EEPROMs that conflict with the
+			 * PHY's on-board EEPROM so it cannot load firmware */
+			netif_err(efx, hw, efx->net_dev,
+				  "If an SFP+ direct attach cable is"
+				  " connected, please check that it complies"
+				  " with the SFP+ specification\n");
+			return -ETIMEDOUT;
+		}
+		msleep(QT2025C_HEARTB_WAIT);
+	}
+
+	return 0;
+}
+
+static int qt2025c_wait_fw_status_good(struct ef4_nic *efx)
+{
+	unsigned long timeout = jiffies + QT2025C_MAX_FWSTART_TIME;
+	int reg;
+
+	/* Wait for firmware status to look good */
+	for (;;) {
+		reg = ef4_mdio_read(efx, MDIO_MMD_PCS, PCS_UC8051_STATUS_REG);
+		if (reg < 0)
+			return reg;
+		if ((reg &
+		     ((1 << PCS_UC_STATUS_WIDTH) - 1) << PCS_UC_STATUS_LBN) >=
+		    PCS_UC_STATUS_FW_SAVE)
+			break;
+		if (time_after(jiffies, timeout))
+			return -ETIMEDOUT;
+		msleep(QT2025C_FWSTART_WAIT);
+	}
+
+	return 0;
+}
+
+static void qt2025c_restart_firmware(struct ef4_nic *efx)
+{
+	/* Restart microcontroller execution of firmware from RAM */
+	ef4_mdio_write(efx, 3, 0xe854, 0x00c0);
+	ef4_mdio_write(efx, 3, 0xe854, 0x0040);
+	msleep(50);
+}
+
+static int qt2025c_wait_reset(struct ef4_nic *efx)
+{
+	int rc;
+
+	rc = qt2025c_wait_heartbeat(efx);
+	if (rc != 0)
+		return rc;
+
+	rc = qt2025c_wait_fw_status_good(efx);
+	if (rc == -ETIMEDOUT) {
+		/* Bug 17689: occasionally heartbeat starts but firmware status
+		 * code never progresses beyond 0x00.  Try again, once, after
+		 * restarting execution of the firmware image. */
+		netif_dbg(efx, hw, efx->net_dev,
+			  "bashing QT2025C microcontroller\n");
+		qt2025c_restart_firmware(efx);
+		rc = qt2025c_wait_heartbeat(efx);
+		if (rc != 0)
+			return rc;
+		rc = qt2025c_wait_fw_status_good(efx);
+	}
+
+	return rc;
+}
+
+static void qt2025c_firmware_id(struct ef4_nic *efx)
+{
+	struct qt202x_phy_data *phy_data = efx->phy_data;
+	u8 firmware_id[9];
+	size_t i;
+
+	for (i = 0; i < sizeof(firmware_id); i++)
+		firmware_id[i] = ef4_mdio_read(efx, MDIO_MMD_PCS,
+					       PCS_FW_PRODUCT_CODE_1 + i);
+	netif_info(efx, probe, efx->net_dev,
+		   "QT2025C firmware %xr%d v%d.%d.%d.%d [20%02d-%02d-%02d]\n",
+		   (firmware_id[0] << 8) | firmware_id[1], firmware_id[2],
+		   firmware_id[3] >> 4, firmware_id[3] & 0xf,
+		   firmware_id[4], firmware_id[5],
+		   firmware_id[6], firmware_id[7], firmware_id[8]);
+	phy_data->firmware_ver = ((firmware_id[3] & 0xf0) << 20) |
+				 ((firmware_id[3] & 0x0f) << 16) |
+				 (firmware_id[4] << 8) | firmware_id[5];
+}
+
+static void qt2025c_bug17190_workaround(struct ef4_nic *efx)
+{
+	struct qt202x_phy_data *phy_data = efx->phy_data;
+
+	/* The PHY can get stuck in a state where it reports PHY_XS and PMA/PMD
+	 * layers up, but PCS down (no block_lock).  If we notice this state
+	 * persisting for a couple of seconds, we switch PMA/PMD loopback
+	 * briefly on and then off again, which is normally sufficient to
+	 * recover it.
+	 */
+	if (efx->link_state.up ||
+	    !ef4_mdio_links_ok(efx, MDIO_DEVS_PMAPMD | MDIO_DEVS_PHYXS)) {
+		phy_data->bug17190_in_bad_state = false;
+		return;
+	}
+
+	if (!phy_data->bug17190_in_bad_state) {
+		phy_data->bug17190_in_bad_state = true;
+		phy_data->bug17190_timer = jiffies + BUG17190_INTERVAL;
+		return;
+	}
+
+	if (time_after_eq(jiffies, phy_data->bug17190_timer)) {
+		netif_dbg(efx, hw, efx->net_dev, "bashing QT2025C PMA/PMD\n");
+		ef4_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1,
+				  MDIO_PMA_CTRL1_LOOPBACK, true);
+		msleep(100);
+		ef4_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1,
+				  MDIO_PMA_CTRL1_LOOPBACK, false);
+		phy_data->bug17190_timer = jiffies + BUG17190_INTERVAL;
+	}
+}
+
+static int qt2025c_select_phy_mode(struct ef4_nic *efx)
+{
+	struct qt202x_phy_data *phy_data = efx->phy_data;
+	struct falcon_board *board = falcon_board(efx);
+	int reg, rc, i;
+	uint16_t phy_op_mode;
+
+	/* Only 2.0.1.0+ PHY firmware supports the more optimal SFP+
+	 * Self-Configure mode.  Don't attempt any switching if we encounter
+	 * older firmware. */
+	if (phy_data->firmware_ver < 0x02000100)
+		return 0;
+
+	/* In general we will get optimal behaviour in "SFP+ Self-Configure"
+	 * mode; however, that powers down most of the PHY when no module is
+	 * present, so we must use a different mode (any fixed mode will do)
+	 * to be sure that loopbacks will work. */
+	phy_op_mode = (efx->loopback_mode == LOOPBACK_NONE) ? 0x0038 : 0x0020;
+
+	/* Only change mode if really necessary */
+	reg = ef4_mdio_read(efx, 1, 0xc319);
+	if ((reg & 0x0038) == phy_op_mode)
+		return 0;
+	netif_dbg(efx, hw, efx->net_dev, "Switching PHY to mode 0x%04x\n",
+		  phy_op_mode);
+
+	/* This sequence replicates the register writes configured in the boot
+	 * EEPROM (including the differences between board revisions), except
+	 * that the operating mode is changed, and the PHY is prevented from
+	 * unnecessarily reloading the main firmware image again. */
+	ef4_mdio_write(efx, 1, 0xc300, 0x0000);
+	/* (Note: this portion of the boot EEPROM sequence, which bit-bashes 9
+	 * STOPs onto the firmware/module I2C bus to reset it, varies across
+	 * board revisions, as the bus is connected to different GPIO/LED
+	 * outputs on the PHY.) */
+	if (board->major == 0 && board->minor < 2) {
+		ef4_mdio_write(efx, 1, 0xc303, 0x4498);
+		for (i = 0; i < 9; i++) {
+			ef4_mdio_write(efx, 1, 0xc303, 0x4488);
+			ef4_mdio_write(efx, 1, 0xc303, 0x4480);
+			ef4_mdio_write(efx, 1, 0xc303, 0x4490);
+			ef4_mdio_write(efx, 1, 0xc303, 0x4498);
+		}
+	} else {
+		ef4_mdio_write(efx, 1, 0xc303, 0x0920);
+		ef4_mdio_write(efx, 1, 0xd008, 0x0004);
+		for (i = 0; i < 9; i++) {
+			ef4_mdio_write(efx, 1, 0xc303, 0x0900);
+			ef4_mdio_write(efx, 1, 0xd008, 0x0005);
+			ef4_mdio_write(efx, 1, 0xc303, 0x0920);
+			ef4_mdio_write(efx, 1, 0xd008, 0x0004);
+		}
+		ef4_mdio_write(efx, 1, 0xc303, 0x4900);
+	}
+	ef4_mdio_write(efx, 1, 0xc303, 0x4900);
+	ef4_mdio_write(efx, 1, 0xc302, 0x0004);
+	ef4_mdio_write(efx, 1, 0xc316, 0x0013);
+	ef4_mdio_write(efx, 1, 0xc318, 0x0054);
+	ef4_mdio_write(efx, 1, 0xc319, phy_op_mode);
+	ef4_mdio_write(efx, 1, 0xc31a, 0x0098);
+	ef4_mdio_write(efx, 3, 0x0026, 0x0e00);
+	ef4_mdio_write(efx, 3, 0x0027, 0x0013);
+	ef4_mdio_write(efx, 3, 0x0028, 0xa528);
+	ef4_mdio_write(efx, 1, 0xd006, 0x000a);
+	ef4_mdio_write(efx, 1, 0xd007, 0x0009);
+	ef4_mdio_write(efx, 1, 0xd008, 0x0004);
+	/* This additional write is not present in the boot EEPROM.  It
+	 * prevents the PHY's internal boot ROM doing another pointless (and
+	 * slow) reload of the firmware image (the microcontroller's code
+	 * memory is not affected by the microcontroller reset). */
+	ef4_mdio_write(efx, 1, 0xc317, 0x00ff);
+	/* PMA/PMD loopback sets RXIN to inverse polarity and the firmware
+	 * restart doesn't reset it. We need to do that ourselves. */
+	ef4_mdio_set_flag(efx, 1, PMA_PMD_MODE_REG,
+			  1 << PMA_PMD_RXIN_SEL_LBN, false);
+	ef4_mdio_write(efx, 1, 0xc300, 0x0002);
+	msleep(20);
+
+	/* Restart microcontroller execution of firmware from RAM */
+	qt2025c_restart_firmware(efx);
+
+	/* Wait for the microcontroller to be ready again */
+	rc = qt2025c_wait_reset(efx);
+	if (rc < 0) {
+		netif_err(efx, hw, efx->net_dev,
+			  "PHY microcontroller reset during mode switch "
+			  "timed out\n");
+		return rc;
+	}
+
+	return 0;
+}
+
+static int qt202x_reset_phy(struct ef4_nic *efx)
+{
+	int rc;
+
+	if (efx->phy_type == PHY_TYPE_QT2025C) {
+		/* Wait for the reset triggered by falcon_reset_hw()
+		 * to complete */
+		rc = qt2025c_wait_reset(efx);
+		if (rc < 0)
+			goto fail;
+	} else {
+		/* Reset the PHYXS MMD. This is documented as doing
+		 * a complete soft reset. */
+		rc = ef4_mdio_reset_mmd(efx, MDIO_MMD_PHYXS,
+					QT2022C2_MAX_RESET_TIME /
+					QT2022C2_RESET_WAIT,
+					QT2022C2_RESET_WAIT);
+		if (rc < 0)
+			goto fail;
+	}
+
+	/* Wait 250ms for the PHY to complete bootup */
+	msleep(250);
+
+	falcon_board(efx)->type->init_phy(efx);
+
+	return 0;
+
+ fail:
+	netif_err(efx, hw, efx->net_dev, "PHY reset timed out\n");
+	return rc;
+}
+
+static int qt202x_phy_probe(struct ef4_nic *efx)
+{
+	struct qt202x_phy_data *phy_data;
+
+	phy_data = kzalloc(sizeof(struct qt202x_phy_data), GFP_KERNEL);
+	if (!phy_data)
+		return -ENOMEM;
+	efx->phy_data = phy_data;
+	phy_data->phy_mode = efx->phy_mode;
+	phy_data->bug17190_in_bad_state = false;
+	phy_data->bug17190_timer = 0;
+
+	efx->mdio.mmds = QT202X_REQUIRED_DEVS;
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->loopback_modes = QT202X_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
+	return 0;
+}
+
+static int qt202x_phy_init(struct ef4_nic *efx)
+{
+	u32 devid;
+	int rc;
+
+	rc = qt202x_reset_phy(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev, "PHY init failed\n");
+		return rc;
+	}
+
+	devid = ef4_mdio_read_id(efx, MDIO_MMD_PHYXS);
+	netif_info(efx, probe, efx->net_dev,
+		   "PHY ID reg %x (OUI %06x model %02x revision %x)\n",
+		   devid, ef4_mdio_id_oui(devid), ef4_mdio_id_model(devid),
+		   ef4_mdio_id_rev(devid));
+
+	if (efx->phy_type == PHY_TYPE_QT2025C)
+		qt2025c_firmware_id(efx);
+
+	return 0;
+}
+
+static int qt202x_link_ok(struct ef4_nic *efx)
+{
+	return ef4_mdio_links_ok(efx, QT202X_REQUIRED_DEVS);
+}
+
+static bool qt202x_phy_poll(struct ef4_nic *efx)
+{
+	bool was_up = efx->link_state.up;
+
+	efx->link_state.up = qt202x_link_ok(efx);
+	efx->link_state.speed = 10000;
+	efx->link_state.fd = true;
+	efx->link_state.fc = efx->wanted_fc;
+
+	if (efx->phy_type == PHY_TYPE_QT2025C)
+		qt2025c_bug17190_workaround(efx);
+
+	return efx->link_state.up != was_up;
+}
+
+static int qt202x_phy_reconfigure(struct ef4_nic *efx)
+{
+	struct qt202x_phy_data *phy_data = efx->phy_data;
+
+	if (efx->phy_type == PHY_TYPE_QT2025C) {
+		int rc = qt2025c_select_phy_mode(efx);
+		if (rc)
+			return rc;
+
+		/* There are several different register bits which can
+		 * disable TX (and save power) on direct-attach cables
+		 * or optical transceivers, varying somewhat between
+		 * firmware versions.  Only 'static mode' appears to
+		 * cover everything. */
+		mdio_set_flag(
+			&efx->mdio, efx->mdio.prtad, MDIO_MMD_PMAPMD,
+			PMA_PMD_FTX_CTRL2_REG, 1 << PMA_PMD_FTX_STATIC_LBN,
+			efx->phy_mode & PHY_MODE_TX_DISABLED ||
+			efx->phy_mode & PHY_MODE_LOW_POWER ||
+			efx->loopback_mode == LOOPBACK_PCS ||
+			efx->loopback_mode == LOOPBACK_PMAPMD);
+	} else {
+		/* Reset the PHY when moving from tx off to tx on */
+		if (!(efx->phy_mode & PHY_MODE_TX_DISABLED) &&
+		    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
+			qt202x_reset_phy(efx);
+
+		ef4_mdio_transmit_disable(efx);
+	}
+
+	ef4_mdio_phy_reconfigure(efx);
+
+	phy_data->phy_mode = efx->phy_mode;
+
+	return 0;
+}
+
+static void qt202x_phy_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+{
+	mdio45_ethtool_gset(&efx->mdio, ecmd);
+}
+
+static void qt202x_phy_remove(struct ef4_nic *efx)
+{
+	/* Free the context block */
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
+}
+
+static int qt202x_phy_get_module_info(struct ef4_nic *efx,
+				      struct ethtool_modinfo *modinfo)
+{
+	modinfo->type = ETH_MODULE_SFF_8079;
+	modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
+	return 0;
+}
+
+static int qt202x_phy_get_module_eeprom(struct ef4_nic *efx,
+					struct ethtool_eeprom *ee, u8 *data)
+{
+	int mmd, reg_base, rc, i;		
+
+	if (efx->phy_type == PHY_TYPE_QT2025C) {
+		mmd = MDIO_MMD_PCS;
+		reg_base = 0xd000;
+	} else {
+		mmd = MDIO_MMD_PMAPMD;
+		reg_base = 0x8007;
+	}
+
+	for (i = 0; i < ee->len; i++) {
+		rc = ef4_mdio_read(efx, mmd, reg_base + ee->offset + i);
+		if (rc < 0)
+			return rc;
+		data[i] = rc;
+	}
+
+	return 0;
+}
+
+const struct ef4_phy_operations falcon_qt202x_phy_ops = {
+	.probe		 = qt202x_phy_probe,
+	.init		 = qt202x_phy_init,
+	.reconfigure	 = qt202x_phy_reconfigure,
+	.poll		 = qt202x_phy_poll,
+	.fini		 = ef4_port_dummy_op_void,
+	.remove		 = qt202x_phy_remove,
+	.get_settings	 = qt202x_phy_get_settings,
+	.set_settings	 = ef4_mdio_set_settings,
+	.test_alive	 = ef4_mdio_test_alive,
+	.get_module_eeprom = qt202x_phy_get_module_eeprom,
+	.get_module_info = qt202x_phy_get_module_info,
+};
diff --git a/drivers/net/ethernet/sfc/falcon/rx.c b/drivers/net/ethernet/sfc/falcon/rx.c
new file mode 100644
index 0000000..250458c
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/rx.c
@@ -0,0 +1,974 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/slab.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/prefetch.h>
+#include <linux/moduleparam.h>
+#include <linux/iommu.h>
+#include <net/ip.h>
+#include <net/checksum.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "filter.h"
+#include "nic.h"
+#include "selftest.h"
+#include "workarounds.h"
+
+/* Preferred number of descriptors to fill at once */
+#define EF4_RX_PREFERRED_BATCH 8U
+
+/* Number of RX buffers to recycle pages for.  When creating the RX page recycle
+ * ring, this number is divided by the number of buffers per page to calculate
+ * the number of pages to store in the RX page recycle ring.
+ */
+#define EF4_RECYCLE_RING_SIZE_IOMMU 4096
+#define EF4_RECYCLE_RING_SIZE_NOIOMMU (2 * EF4_RX_PREFERRED_BATCH)
+
+/* Size of buffer allocated for skb header area. */
+#define EF4_SKB_HEADERS  128u
+
+/* This is the percentage fill level below which new RX descriptors
+ * will be added to the RX descriptor ring.
+ */
+static unsigned int rx_refill_threshold;
+
+/* Each packet can consume up to ceil(max_frame_len / buffer_size) buffers */
+#define EF4_RX_MAX_FRAGS DIV_ROUND_UP(EF4_MAX_FRAME_LEN(EF4_MAX_MTU), \
+				      EF4_RX_USR_BUF_SIZE)
+
+/*
+ * RX maximum head room required.
+ *
+ * This must be at least 1 to prevent overflow, plus one packet-worth
+ * to allow pipelined receives.
+ */
+#define EF4_RXD_HEAD_ROOM (1 + EF4_RX_MAX_FRAGS)
+
+static inline u8 *ef4_rx_buf_va(struct ef4_rx_buffer *buf)
+{
+	return page_address(buf->page) + buf->page_offset;
+}
+
+static inline u32 ef4_rx_buf_hash(struct ef4_nic *efx, const u8 *eh)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	return __le32_to_cpup((const __le32 *)(eh + efx->rx_packet_hash_offset));
+#else
+	const u8 *data = eh + efx->rx_packet_hash_offset;
+	return (u32)data[0]	  |
+	       (u32)data[1] << 8  |
+	       (u32)data[2] << 16 |
+	       (u32)data[3] << 24;
+#endif
+}
+
+static inline struct ef4_rx_buffer *
+ef4_rx_buf_next(struct ef4_rx_queue *rx_queue, struct ef4_rx_buffer *rx_buf)
+{
+	if (unlikely(rx_buf == ef4_rx_buffer(rx_queue, rx_queue->ptr_mask)))
+		return ef4_rx_buffer(rx_queue, 0);
+	else
+		return rx_buf + 1;
+}
+
+static inline void ef4_sync_rx_buffer(struct ef4_nic *efx,
+				      struct ef4_rx_buffer *rx_buf,
+				      unsigned int len)
+{
+	dma_sync_single_for_cpu(&efx->pci_dev->dev, rx_buf->dma_addr, len,
+				DMA_FROM_DEVICE);
+}
+
+void ef4_rx_config_page_split(struct ef4_nic *efx)
+{
+	efx->rx_page_buf_step = ALIGN(efx->rx_dma_len + efx->rx_ip_align,
+				      EF4_RX_BUF_ALIGNMENT);
+	efx->rx_bufs_per_page = efx->rx_buffer_order ? 1 :
+		((PAGE_SIZE - sizeof(struct ef4_rx_page_state)) /
+		 efx->rx_page_buf_step);
+	efx->rx_buffer_truesize = (PAGE_SIZE << efx->rx_buffer_order) /
+		efx->rx_bufs_per_page;
+	efx->rx_pages_per_batch = DIV_ROUND_UP(EF4_RX_PREFERRED_BATCH,
+					       efx->rx_bufs_per_page);
+}
+
+/* Check the RX page recycle ring for a page that can be reused. */
+static struct page *ef4_reuse_page(struct ef4_rx_queue *rx_queue)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	struct page *page;
+	struct ef4_rx_page_state *state;
+	unsigned index;
+
+	index = rx_queue->page_remove & rx_queue->page_ptr_mask;
+	page = rx_queue->page_ring[index];
+	if (page == NULL)
+		return NULL;
+
+	rx_queue->page_ring[index] = NULL;
+	/* page_remove cannot exceed page_add. */
+	if (rx_queue->page_remove != rx_queue->page_add)
+		++rx_queue->page_remove;
+
+	/* If page_count is 1 then we hold the only reference to this page. */
+	if (page_count(page) == 1) {
+		++rx_queue->page_recycle_count;
+		return page;
+	} else {
+		state = page_address(page);
+		dma_unmap_page(&efx->pci_dev->dev, state->dma_addr,
+			       PAGE_SIZE << efx->rx_buffer_order,
+			       DMA_FROM_DEVICE);
+		put_page(page);
+		++rx_queue->page_recycle_failed;
+	}
+
+	return NULL;
+}
+
+/**
+ * ef4_init_rx_buffers - create EF4_RX_BATCH page-based RX buffers
+ *
+ * @rx_queue:		Efx RX queue
+ *
+ * This allocates a batch of pages, maps them for DMA, and populates
+ * struct ef4_rx_buffers for each one. Return a negative error code or
+ * 0 on success. If a single page can be used for multiple buffers,
+ * then the page will either be inserted fully, or not at all.
+ */
+static int ef4_init_rx_buffers(struct ef4_rx_queue *rx_queue, bool atomic)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	struct ef4_rx_buffer *rx_buf;
+	struct page *page;
+	unsigned int page_offset;
+	struct ef4_rx_page_state *state;
+	dma_addr_t dma_addr;
+	unsigned index, count;
+
+	count = 0;
+	do {
+		page = ef4_reuse_page(rx_queue);
+		if (page == NULL) {
+			page = alloc_pages(__GFP_COLD | __GFP_COMP |
+					   (atomic ? GFP_ATOMIC : GFP_KERNEL),
+					   efx->rx_buffer_order);
+			if (unlikely(page == NULL))
+				return -ENOMEM;
+			dma_addr =
+				dma_map_page(&efx->pci_dev->dev, page, 0,
+					     PAGE_SIZE << efx->rx_buffer_order,
+					     DMA_FROM_DEVICE);
+			if (unlikely(dma_mapping_error(&efx->pci_dev->dev,
+						       dma_addr))) {
+				__free_pages(page, efx->rx_buffer_order);
+				return -EIO;
+			}
+			state = page_address(page);
+			state->dma_addr = dma_addr;
+		} else {
+			state = page_address(page);
+			dma_addr = state->dma_addr;
+		}
+
+		dma_addr += sizeof(struct ef4_rx_page_state);
+		page_offset = sizeof(struct ef4_rx_page_state);
+
+		do {
+			index = rx_queue->added_count & rx_queue->ptr_mask;
+			rx_buf = ef4_rx_buffer(rx_queue, index);
+			rx_buf->dma_addr = dma_addr + efx->rx_ip_align;
+			rx_buf->page = page;
+			rx_buf->page_offset = page_offset + efx->rx_ip_align;
+			rx_buf->len = efx->rx_dma_len;
+			rx_buf->flags = 0;
+			++rx_queue->added_count;
+			get_page(page);
+			dma_addr += efx->rx_page_buf_step;
+			page_offset += efx->rx_page_buf_step;
+		} while (page_offset + efx->rx_page_buf_step <= PAGE_SIZE);
+
+		rx_buf->flags = EF4_RX_BUF_LAST_IN_PAGE;
+	} while (++count < efx->rx_pages_per_batch);
+
+	return 0;
+}
+
+/* Unmap a DMA-mapped page.  This function is only called for the final RX
+ * buffer in a page.
+ */
+static void ef4_unmap_rx_buffer(struct ef4_nic *efx,
+				struct ef4_rx_buffer *rx_buf)
+{
+	struct page *page = rx_buf->page;
+
+	if (page) {
+		struct ef4_rx_page_state *state = page_address(page);
+		dma_unmap_page(&efx->pci_dev->dev,
+			       state->dma_addr,
+			       PAGE_SIZE << efx->rx_buffer_order,
+			       DMA_FROM_DEVICE);
+	}
+}
+
+static void ef4_free_rx_buffers(struct ef4_rx_queue *rx_queue,
+				struct ef4_rx_buffer *rx_buf,
+				unsigned int num_bufs)
+{
+	do {
+		if (rx_buf->page) {
+			put_page(rx_buf->page);
+			rx_buf->page = NULL;
+		}
+		rx_buf = ef4_rx_buf_next(rx_queue, rx_buf);
+	} while (--num_bufs);
+}
+
+/* Attempt to recycle the page if there is an RX recycle ring; the page can
+ * only be added if this is the final RX buffer, to prevent pages being used in
+ * the descriptor ring and appearing in the recycle ring simultaneously.
+ */
+static void ef4_recycle_rx_page(struct ef4_channel *channel,
+				struct ef4_rx_buffer *rx_buf)
+{
+	struct page *page = rx_buf->page;
+	struct ef4_rx_queue *rx_queue = ef4_channel_get_rx_queue(channel);
+	struct ef4_nic *efx = rx_queue->efx;
+	unsigned index;
+
+	/* Only recycle the page after processing the final buffer. */
+	if (!(rx_buf->flags & EF4_RX_BUF_LAST_IN_PAGE))
+		return;
+
+	index = rx_queue->page_add & rx_queue->page_ptr_mask;
+	if (rx_queue->page_ring[index] == NULL) {
+		unsigned read_index = rx_queue->page_remove &
+			rx_queue->page_ptr_mask;
+
+		/* The next slot in the recycle ring is available, but
+		 * increment page_remove if the read pointer currently
+		 * points here.
+		 */
+		if (read_index == index)
+			++rx_queue->page_remove;
+		rx_queue->page_ring[index] = page;
+		++rx_queue->page_add;
+		return;
+	}
+	++rx_queue->page_recycle_full;
+	ef4_unmap_rx_buffer(efx, rx_buf);
+	put_page(rx_buf->page);
+}
+
+static void ef4_fini_rx_buffer(struct ef4_rx_queue *rx_queue,
+			       struct ef4_rx_buffer *rx_buf)
+{
+	/* Release the page reference we hold for the buffer. */
+	if (rx_buf->page)
+		put_page(rx_buf->page);
+
+	/* If this is the last buffer in a page, unmap and free it. */
+	if (rx_buf->flags & EF4_RX_BUF_LAST_IN_PAGE) {
+		ef4_unmap_rx_buffer(rx_queue->efx, rx_buf);
+		ef4_free_rx_buffers(rx_queue, rx_buf, 1);
+	}
+	rx_buf->page = NULL;
+}
+
+/* Recycle the pages that are used by buffers that have just been received. */
+static void ef4_recycle_rx_pages(struct ef4_channel *channel,
+				 struct ef4_rx_buffer *rx_buf,
+				 unsigned int n_frags)
+{
+	struct ef4_rx_queue *rx_queue = ef4_channel_get_rx_queue(channel);
+
+	do {
+		ef4_recycle_rx_page(channel, rx_buf);
+		rx_buf = ef4_rx_buf_next(rx_queue, rx_buf);
+	} while (--n_frags);
+}
+
+static void ef4_discard_rx_packet(struct ef4_channel *channel,
+				  struct ef4_rx_buffer *rx_buf,
+				  unsigned int n_frags)
+{
+	struct ef4_rx_queue *rx_queue = ef4_channel_get_rx_queue(channel);
+
+	ef4_recycle_rx_pages(channel, rx_buf, n_frags);
+
+	ef4_free_rx_buffers(rx_queue, rx_buf, n_frags);
+}
+
+/**
+ * ef4_fast_push_rx_descriptors - push new RX descriptors quickly
+ * @rx_queue:		RX descriptor queue
+ *
+ * This will aim to fill the RX descriptor queue up to
+ * @rx_queue->@max_fill. If there is insufficient atomic
+ * memory to do so, a slow fill will be scheduled.
+ *
+ * The caller must provide serialisation (none is used here). In practise,
+ * this means this function must run from the NAPI handler, or be called
+ * when NAPI is disabled.
+ */
+void ef4_fast_push_rx_descriptors(struct ef4_rx_queue *rx_queue, bool atomic)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	unsigned int fill_level, batch_size;
+	int space, rc = 0;
+
+	if (!rx_queue->refill_enabled)
+		return;
+
+	/* Calculate current fill level, and exit if we don't need to fill */
+	fill_level = (rx_queue->added_count - rx_queue->removed_count);
+	EF4_BUG_ON_PARANOID(fill_level > rx_queue->efx->rxq_entries);
+	if (fill_level >= rx_queue->fast_fill_trigger)
+		goto out;
+
+	/* Record minimum fill level */
+	if (unlikely(fill_level < rx_queue->min_fill)) {
+		if (fill_level)
+			rx_queue->min_fill = fill_level;
+	}
+
+	batch_size = efx->rx_pages_per_batch * efx->rx_bufs_per_page;
+	space = rx_queue->max_fill - fill_level;
+	EF4_BUG_ON_PARANOID(space < batch_size);
+
+	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
+		   "RX queue %d fast-filling descriptor ring from"
+		   " level %d to level %d\n",
+		   ef4_rx_queue_index(rx_queue), fill_level,
+		   rx_queue->max_fill);
+
+
+	do {
+		rc = ef4_init_rx_buffers(rx_queue, atomic);
+		if (unlikely(rc)) {
+			/* Ensure that we don't leave the rx queue empty */
+			if (rx_queue->added_count == rx_queue->removed_count)
+				ef4_schedule_slow_fill(rx_queue);
+			goto out;
+		}
+	} while ((space -= batch_size) >= batch_size);
+
+	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
+		   "RX queue %d fast-filled descriptor ring "
+		   "to level %d\n", ef4_rx_queue_index(rx_queue),
+		   rx_queue->added_count - rx_queue->removed_count);
+
+ out:
+	if (rx_queue->notified_count != rx_queue->added_count)
+		ef4_nic_notify_rx_desc(rx_queue);
+}
+
+void ef4_rx_slow_fill(unsigned long context)
+{
+	struct ef4_rx_queue *rx_queue = (struct ef4_rx_queue *)context;
+
+	/* Post an event to cause NAPI to run and refill the queue */
+	ef4_nic_generate_fill_event(rx_queue);
+	++rx_queue->slow_fill_count;
+}
+
+static void ef4_rx_packet__check_len(struct ef4_rx_queue *rx_queue,
+				     struct ef4_rx_buffer *rx_buf,
+				     int len)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	unsigned max_len = rx_buf->len - efx->type->rx_buffer_padding;
+
+	if (likely(len <= max_len))
+		return;
+
+	/* The packet must be discarded, but this is only a fatal error
+	 * if the caller indicated it was
+	 */
+	rx_buf->flags |= EF4_RX_PKT_DISCARD;
+
+	if ((len > rx_buf->len) && EF4_WORKAROUND_8071(efx)) {
+		if (net_ratelimit())
+			netif_err(efx, rx_err, efx->net_dev,
+				  " RX queue %d seriously overlength "
+				  "RX event (0x%x > 0x%x+0x%x). Leaking\n",
+				  ef4_rx_queue_index(rx_queue), len, max_len,
+				  efx->type->rx_buffer_padding);
+		ef4_schedule_reset(efx, RESET_TYPE_RX_RECOVERY);
+	} else {
+		if (net_ratelimit())
+			netif_err(efx, rx_err, efx->net_dev,
+				  " RX queue %d overlength RX event "
+				  "(0x%x > 0x%x)\n",
+				  ef4_rx_queue_index(rx_queue), len, max_len);
+	}
+
+	ef4_rx_queue_channel(rx_queue)->n_rx_overlength++;
+}
+
+/* Pass a received packet up through GRO.  GRO can handle pages
+ * regardless of checksum state and skbs with a good checksum.
+ */
+static void
+ef4_rx_packet_gro(struct ef4_channel *channel, struct ef4_rx_buffer *rx_buf,
+		  unsigned int n_frags, u8 *eh)
+{
+	struct napi_struct *napi = &channel->napi_str;
+	gro_result_t gro_result;
+	struct ef4_nic *efx = channel->efx;
+	struct sk_buff *skb;
+
+	skb = napi_get_frags(napi);
+	if (unlikely(!skb)) {
+		struct ef4_rx_queue *rx_queue;
+
+		rx_queue = ef4_channel_get_rx_queue(channel);
+		ef4_free_rx_buffers(rx_queue, rx_buf, n_frags);
+		return;
+	}
+
+	if (efx->net_dev->features & NETIF_F_RXHASH)
+		skb_set_hash(skb, ef4_rx_buf_hash(efx, eh),
+			     PKT_HASH_TYPE_L3);
+	skb->ip_summed = ((rx_buf->flags & EF4_RX_PKT_CSUMMED) ?
+			  CHECKSUM_UNNECESSARY : CHECKSUM_NONE);
+
+	for (;;) {
+		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
+				   rx_buf->page, rx_buf->page_offset,
+				   rx_buf->len);
+		rx_buf->page = NULL;
+		skb->len += rx_buf->len;
+		if (skb_shinfo(skb)->nr_frags == n_frags)
+			break;
+
+		rx_buf = ef4_rx_buf_next(&channel->rx_queue, rx_buf);
+	}
+
+	skb->data_len = skb->len;
+	skb->truesize += n_frags * efx->rx_buffer_truesize;
+
+	skb_record_rx_queue(skb, channel->rx_queue.core_index);
+
+	gro_result = napi_gro_frags(napi);
+	if (gro_result != GRO_DROP)
+		channel->irq_mod_score += 2;
+}
+
+/* Allocate and construct an SKB around page fragments */
+static struct sk_buff *ef4_rx_mk_skb(struct ef4_channel *channel,
+				     struct ef4_rx_buffer *rx_buf,
+				     unsigned int n_frags,
+				     u8 *eh, int hdr_len)
+{
+	struct ef4_nic *efx = channel->efx;
+	struct sk_buff *skb;
+
+	/* Allocate an SKB to store the headers */
+	skb = netdev_alloc_skb(efx->net_dev,
+			       efx->rx_ip_align + efx->rx_prefix_size +
+			       hdr_len);
+	if (unlikely(skb == NULL)) {
+		atomic_inc(&efx->n_rx_noskb_drops);
+		return NULL;
+	}
+
+	EF4_BUG_ON_PARANOID(rx_buf->len < hdr_len);
+
+	memcpy(skb->data + efx->rx_ip_align, eh - efx->rx_prefix_size,
+	       efx->rx_prefix_size + hdr_len);
+	skb_reserve(skb, efx->rx_ip_align + efx->rx_prefix_size);
+	__skb_put(skb, hdr_len);
+
+	/* Append the remaining page(s) onto the frag list */
+	if (rx_buf->len > hdr_len) {
+		rx_buf->page_offset += hdr_len;
+		rx_buf->len -= hdr_len;
+
+		for (;;) {
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
+					   rx_buf->page, rx_buf->page_offset,
+					   rx_buf->len);
+			rx_buf->page = NULL;
+			skb->len += rx_buf->len;
+			skb->data_len += rx_buf->len;
+			if (skb_shinfo(skb)->nr_frags == n_frags)
+				break;
+
+			rx_buf = ef4_rx_buf_next(&channel->rx_queue, rx_buf);
+		}
+	} else {
+		__free_pages(rx_buf->page, efx->rx_buffer_order);
+		rx_buf->page = NULL;
+		n_frags = 0;
+	}
+
+	skb->truesize += n_frags * efx->rx_buffer_truesize;
+
+	/* Move past the ethernet header */
+	skb->protocol = eth_type_trans(skb, efx->net_dev);
+
+	skb_mark_napi_id(skb, &channel->napi_str);
+
+	return skb;
+}
+
+void ef4_rx_packet(struct ef4_rx_queue *rx_queue, unsigned int index,
+		   unsigned int n_frags, unsigned int len, u16 flags)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	struct ef4_channel *channel = ef4_rx_queue_channel(rx_queue);
+	struct ef4_rx_buffer *rx_buf;
+
+	rx_queue->rx_packets++;
+
+	rx_buf = ef4_rx_buffer(rx_queue, index);
+	rx_buf->flags |= flags;
+
+	/* Validate the number of fragments and completed length */
+	if (n_frags == 1) {
+		if (!(flags & EF4_RX_PKT_PREFIX_LEN))
+			ef4_rx_packet__check_len(rx_queue, rx_buf, len);
+	} else if (unlikely(n_frags > EF4_RX_MAX_FRAGS) ||
+		   unlikely(len <= (n_frags - 1) * efx->rx_dma_len) ||
+		   unlikely(len > n_frags * efx->rx_dma_len) ||
+		   unlikely(!efx->rx_scatter)) {
+		/* If this isn't an explicit discard request, either
+		 * the hardware or the driver is broken.
+		 */
+		WARN_ON(!(len == 0 && rx_buf->flags & EF4_RX_PKT_DISCARD));
+		rx_buf->flags |= EF4_RX_PKT_DISCARD;
+	}
+
+	netif_vdbg(efx, rx_status, efx->net_dev,
+		   "RX queue %d received ids %x-%x len %d %s%s\n",
+		   ef4_rx_queue_index(rx_queue), index,
+		   (index + n_frags - 1) & rx_queue->ptr_mask, len,
+		   (rx_buf->flags & EF4_RX_PKT_CSUMMED) ? " [SUMMED]" : "",
+		   (rx_buf->flags & EF4_RX_PKT_DISCARD) ? " [DISCARD]" : "");
+
+	/* Discard packet, if instructed to do so.  Process the
+	 * previous receive first.
+	 */
+	if (unlikely(rx_buf->flags & EF4_RX_PKT_DISCARD)) {
+		ef4_rx_flush_packet(channel);
+		ef4_discard_rx_packet(channel, rx_buf, n_frags);
+		return;
+	}
+
+	if (n_frags == 1 && !(flags & EF4_RX_PKT_PREFIX_LEN))
+		rx_buf->len = len;
+
+	/* Release and/or sync the DMA mapping - assumes all RX buffers
+	 * consumed in-order per RX queue.
+	 */
+	ef4_sync_rx_buffer(efx, rx_buf, rx_buf->len);
+
+	/* Prefetch nice and early so data will (hopefully) be in cache by
+	 * the time we look at it.
+	 */
+	prefetch(ef4_rx_buf_va(rx_buf));
+
+	rx_buf->page_offset += efx->rx_prefix_size;
+	rx_buf->len -= efx->rx_prefix_size;
+
+	if (n_frags > 1) {
+		/* Release/sync DMA mapping for additional fragments.
+		 * Fix length for last fragment.
+		 */
+		unsigned int tail_frags = n_frags - 1;
+
+		for (;;) {
+			rx_buf = ef4_rx_buf_next(rx_queue, rx_buf);
+			if (--tail_frags == 0)
+				break;
+			ef4_sync_rx_buffer(efx, rx_buf, efx->rx_dma_len);
+		}
+		rx_buf->len = len - (n_frags - 1) * efx->rx_dma_len;
+		ef4_sync_rx_buffer(efx, rx_buf, rx_buf->len);
+	}
+
+	/* All fragments have been DMA-synced, so recycle pages. */
+	rx_buf = ef4_rx_buffer(rx_queue, index);
+	ef4_recycle_rx_pages(channel, rx_buf, n_frags);
+
+	/* Pipeline receives so that we give time for packet headers to be
+	 * prefetched into cache.
+	 */
+	ef4_rx_flush_packet(channel);
+	channel->rx_pkt_n_frags = n_frags;
+	channel->rx_pkt_index = index;
+}
+
+static void ef4_rx_deliver(struct ef4_channel *channel, u8 *eh,
+			   struct ef4_rx_buffer *rx_buf,
+			   unsigned int n_frags)
+{
+	struct sk_buff *skb;
+	u16 hdr_len = min_t(u16, rx_buf->len, EF4_SKB_HEADERS);
+
+	skb = ef4_rx_mk_skb(channel, rx_buf, n_frags, eh, hdr_len);
+	if (unlikely(skb == NULL)) {
+		struct ef4_rx_queue *rx_queue;
+
+		rx_queue = ef4_channel_get_rx_queue(channel);
+		ef4_free_rx_buffers(rx_queue, rx_buf, n_frags);
+		return;
+	}
+	skb_record_rx_queue(skb, channel->rx_queue.core_index);
+
+	/* Set the SKB flags */
+	skb_checksum_none_assert(skb);
+	if (likely(rx_buf->flags & EF4_RX_PKT_CSUMMED))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (channel->type->receive_skb)
+		if (channel->type->receive_skb(channel, skb))
+			return;
+
+	/* Pass the packet up */
+	netif_receive_skb(skb);
+}
+
+/* Handle a received packet.  Second half: Touches packet payload. */
+void __ef4_rx_packet(struct ef4_channel *channel)
+{
+	struct ef4_nic *efx = channel->efx;
+	struct ef4_rx_buffer *rx_buf =
+		ef4_rx_buffer(&channel->rx_queue, channel->rx_pkt_index);
+	u8 *eh = ef4_rx_buf_va(rx_buf);
+
+	/* Read length from the prefix if necessary.  This already
+	 * excludes the length of the prefix itself.
+	 */
+	if (rx_buf->flags & EF4_RX_PKT_PREFIX_LEN)
+		rx_buf->len = le16_to_cpup((__le16 *)
+					   (eh + efx->rx_packet_len_offset));
+
+	/* If we're in loopback test, then pass the packet directly to the
+	 * loopback layer, and free the rx_buf here
+	 */
+	if (unlikely(efx->loopback_selftest)) {
+		struct ef4_rx_queue *rx_queue;
+
+		ef4_loopback_rx_packet(efx, eh, rx_buf->len);
+		rx_queue = ef4_channel_get_rx_queue(channel);
+		ef4_free_rx_buffers(rx_queue, rx_buf,
+				    channel->rx_pkt_n_frags);
+		goto out;
+	}
+
+	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
+		rx_buf->flags &= ~EF4_RX_PKT_CSUMMED;
+
+	if ((rx_buf->flags & EF4_RX_PKT_TCP) && !channel->type->receive_skb &&
+	    !ef4_channel_busy_polling(channel))
+		ef4_rx_packet_gro(channel, rx_buf, channel->rx_pkt_n_frags, eh);
+	else
+		ef4_rx_deliver(channel, eh, rx_buf, channel->rx_pkt_n_frags);
+out:
+	channel->rx_pkt_n_frags = 0;
+}
+
+int ef4_probe_rx_queue(struct ef4_rx_queue *rx_queue)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	unsigned int entries;
+	int rc;
+
+	/* Create the smallest power-of-two aligned ring */
+	entries = max(roundup_pow_of_two(efx->rxq_entries), EF4_MIN_DMAQ_SIZE);
+	EF4_BUG_ON_PARANOID(entries > EF4_MAX_DMAQ_SIZE);
+	rx_queue->ptr_mask = entries - 1;
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "creating RX queue %d size %#x mask %#x\n",
+		  ef4_rx_queue_index(rx_queue), efx->rxq_entries,
+		  rx_queue->ptr_mask);
+
+	/* Allocate RX buffers */
+	rx_queue->buffer = kcalloc(entries, sizeof(*rx_queue->buffer),
+				   GFP_KERNEL);
+	if (!rx_queue->buffer)
+		return -ENOMEM;
+
+	rc = ef4_nic_probe_rx(rx_queue);
+	if (rc) {
+		kfree(rx_queue->buffer);
+		rx_queue->buffer = NULL;
+	}
+
+	return rc;
+}
+
+static void ef4_init_rx_recycle_ring(struct ef4_nic *efx,
+				     struct ef4_rx_queue *rx_queue)
+{
+	unsigned int bufs_in_recycle_ring, page_ring_size;
+
+	/* Set the RX recycle ring size */
+#ifdef CONFIG_PPC64
+	bufs_in_recycle_ring = EF4_RECYCLE_RING_SIZE_IOMMU;
+#else
+	if (iommu_present(&pci_bus_type))
+		bufs_in_recycle_ring = EF4_RECYCLE_RING_SIZE_IOMMU;
+	else
+		bufs_in_recycle_ring = EF4_RECYCLE_RING_SIZE_NOIOMMU;
+#endif /* CONFIG_PPC64 */
+
+	page_ring_size = roundup_pow_of_two(bufs_in_recycle_ring /
+					    efx->rx_bufs_per_page);
+	rx_queue->page_ring = kcalloc(page_ring_size,
+				      sizeof(*rx_queue->page_ring), GFP_KERNEL);
+	rx_queue->page_ptr_mask = page_ring_size - 1;
+}
+
+void ef4_init_rx_queue(struct ef4_rx_queue *rx_queue)
+{
+	struct ef4_nic *efx = rx_queue->efx;
+	unsigned int max_fill, trigger, max_trigger;
+
+	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
+		  "initialising RX queue %d\n", ef4_rx_queue_index(rx_queue));
+
+	/* Initialise ptr fields */
+	rx_queue->added_count = 0;
+	rx_queue->notified_count = 0;
+	rx_queue->removed_count = 0;
+	rx_queue->min_fill = -1U;
+	ef4_init_rx_recycle_ring(efx, rx_queue);
+
+	rx_queue->page_remove = 0;
+	rx_queue->page_add = rx_queue->page_ptr_mask + 1;
+	rx_queue->page_recycle_count = 0;
+	rx_queue->page_recycle_failed = 0;
+	rx_queue->page_recycle_full = 0;
+
+	/* Initialise limit fields */
+	max_fill = efx->rxq_entries - EF4_RXD_HEAD_ROOM;
+	max_trigger =
+		max_fill - efx->rx_pages_per_batch * efx->rx_bufs_per_page;
+	if (rx_refill_threshold != 0) {
+		trigger = max_fill * min(rx_refill_threshold, 100U) / 100U;
+		if (trigger > max_trigger)
+			trigger = max_trigger;
+	} else {
+		trigger = max_trigger;
+	}
+
+	rx_queue->max_fill = max_fill;
+	rx_queue->fast_fill_trigger = trigger;
+	rx_queue->refill_enabled = true;
+
+	/* Set up RX descriptor ring */
+	ef4_nic_init_rx(rx_queue);
+}
+
+void ef4_fini_rx_queue(struct ef4_rx_queue *rx_queue)
+{
+	int i;
+	struct ef4_nic *efx = rx_queue->efx;
+	struct ef4_rx_buffer *rx_buf;
+
+	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
+		  "shutting down RX queue %d\n", ef4_rx_queue_index(rx_queue));
+
+	del_timer_sync(&rx_queue->slow_fill);
+
+	/* Release RX buffers from the current read ptr to the write ptr */
+	if (rx_queue->buffer) {
+		for (i = rx_queue->removed_count; i < rx_queue->added_count;
+		     i++) {
+			unsigned index = i & rx_queue->ptr_mask;
+			rx_buf = ef4_rx_buffer(rx_queue, index);
+			ef4_fini_rx_buffer(rx_queue, rx_buf);
+		}
+	}
+
+	/* Unmap and release the pages in the recycle ring. Remove the ring. */
+	for (i = 0; i <= rx_queue->page_ptr_mask; i++) {
+		struct page *page = rx_queue->page_ring[i];
+		struct ef4_rx_page_state *state;
+
+		if (page == NULL)
+			continue;
+
+		state = page_address(page);
+		dma_unmap_page(&efx->pci_dev->dev, state->dma_addr,
+			       PAGE_SIZE << efx->rx_buffer_order,
+			       DMA_FROM_DEVICE);
+		put_page(page);
+	}
+	kfree(rx_queue->page_ring);
+	rx_queue->page_ring = NULL;
+}
+
+void ef4_remove_rx_queue(struct ef4_rx_queue *rx_queue)
+{
+	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
+		  "destroying RX queue %d\n", ef4_rx_queue_index(rx_queue));
+
+	ef4_nic_remove_rx(rx_queue);
+
+	kfree(rx_queue->buffer);
+	rx_queue->buffer = NULL;
+}
+
+
+module_param(rx_refill_threshold, uint, 0444);
+MODULE_PARM_DESC(rx_refill_threshold,
+		 "RX descriptor ring refill threshold (%)");
+
+#ifdef CONFIG_RFS_ACCEL
+
+int ef4_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+		   u16 rxq_index, u32 flow_id)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct ef4_channel *channel;
+	struct ef4_filter_spec spec;
+	struct flow_keys fk;
+	int rc;
+
+	if (flow_id == RPS_FLOW_ID_INVALID)
+		return -EINVAL;
+
+	if (!skb_flow_dissect_flow_keys(skb, &fk, 0))
+		return -EPROTONOSUPPORT;
+
+	if (fk.basic.n_proto != htons(ETH_P_IP) && fk.basic.n_proto != htons(ETH_P_IPV6))
+		return -EPROTONOSUPPORT;
+	if (fk.control.flags & FLOW_DIS_IS_FRAGMENT)
+		return -EPROTONOSUPPORT;
+
+	ef4_filter_init_rx(&spec, EF4_FILTER_PRI_HINT,
+			   efx->rx_scatter ? EF4_FILTER_FLAG_RX_SCATTER : 0,
+			   rxq_index);
+	spec.match_flags =
+		EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_IP_PROTO |
+		EF4_FILTER_MATCH_LOC_HOST | EF4_FILTER_MATCH_LOC_PORT |
+		EF4_FILTER_MATCH_REM_HOST | EF4_FILTER_MATCH_REM_PORT;
+	spec.ether_type = fk.basic.n_proto;
+	spec.ip_proto = fk.basic.ip_proto;
+
+	if (fk.basic.n_proto == htons(ETH_P_IP)) {
+		spec.rem_host[0] = fk.addrs.v4addrs.src;
+		spec.loc_host[0] = fk.addrs.v4addrs.dst;
+	} else {
+		memcpy(spec.rem_host, &fk.addrs.v6addrs.src, sizeof(struct in6_addr));
+		memcpy(spec.loc_host, &fk.addrs.v6addrs.dst, sizeof(struct in6_addr));
+	}
+
+	spec.rem_port = fk.ports.src;
+	spec.loc_port = fk.ports.dst;
+
+	rc = efx->type->filter_rfs_insert(efx, &spec);
+	if (rc < 0)
+		return rc;
+
+	/* Remember this so we can check whether to expire the filter later */
+	channel = ef4_get_channel(efx, rxq_index);
+	channel->rps_flow_id[rc] = flow_id;
+	++channel->rfs_filters_added;
+
+	if (spec.ether_type == htons(ETH_P_IP))
+		netif_info(efx, rx_status, efx->net_dev,
+			   "steering %s %pI4:%u:%pI4:%u to queue %u [flow %u filter %d]\n",
+			   (spec.ip_proto == IPPROTO_TCP) ? "TCP" : "UDP",
+			   spec.rem_host, ntohs(spec.rem_port), spec.loc_host,
+			   ntohs(spec.loc_port), rxq_index, flow_id, rc);
+	else
+		netif_info(efx, rx_status, efx->net_dev,
+			   "steering %s [%pI6]:%u:[%pI6]:%u to queue %u [flow %u filter %d]\n",
+			   (spec.ip_proto == IPPROTO_TCP) ? "TCP" : "UDP",
+			   spec.rem_host, ntohs(spec.rem_port), spec.loc_host,
+			   ntohs(spec.loc_port), rxq_index, flow_id, rc);
+
+	return rc;
+}
+
+bool __ef4_filter_rfs_expire(struct ef4_nic *efx, unsigned int quota)
+{
+	bool (*expire_one)(struct ef4_nic *efx, u32 flow_id, unsigned int index);
+	unsigned int channel_idx, index, size;
+	u32 flow_id;
+
+	if (!spin_trylock_bh(&efx->filter_lock))
+		return false;
+
+	expire_one = efx->type->filter_rfs_expire_one;
+	channel_idx = efx->rps_expire_channel;
+	index = efx->rps_expire_index;
+	size = efx->type->max_rx_ip_filters;
+	while (quota--) {
+		struct ef4_channel *channel = ef4_get_channel(efx, channel_idx);
+		flow_id = channel->rps_flow_id[index];
+
+		if (flow_id != RPS_FLOW_ID_INVALID &&
+		    expire_one(efx, flow_id, index)) {
+			netif_info(efx, rx_status, efx->net_dev,
+				   "expired filter %d [queue %u flow %u]\n",
+				   index, channel_idx, flow_id);
+			channel->rps_flow_id[index] = RPS_FLOW_ID_INVALID;
+		}
+		if (++index == size) {
+			if (++channel_idx == efx->n_channels)
+				channel_idx = 0;
+			index = 0;
+		}
+	}
+	efx->rps_expire_channel = channel_idx;
+	efx->rps_expire_index = index;
+
+	spin_unlock_bh(&efx->filter_lock);
+	return true;
+}
+
+#endif /* CONFIG_RFS_ACCEL */
+
+/**
+ * ef4_filter_is_mc_recipient - test whether spec is a multicast recipient
+ * @spec: Specification to test
+ *
+ * Return: %true if the specification is a non-drop RX filter that
+ * matches a local MAC address I/G bit value of 1 or matches a local
+ * IPv4 or IPv6 address value in the respective multicast address
+ * range.  Otherwise %false.
+ */
+bool ef4_filter_is_mc_recipient(const struct ef4_filter_spec *spec)
+{
+	if (!(spec->flags & EF4_FILTER_FLAG_RX) ||
+	    spec->dmaq_id == EF4_FILTER_RX_DMAQ_ID_DROP)
+		return false;
+
+	if (spec->match_flags &
+	    (EF4_FILTER_MATCH_LOC_MAC | EF4_FILTER_MATCH_LOC_MAC_IG) &&
+	    is_multicast_ether_addr(spec->loc_mac))
+		return true;
+
+	if ((spec->match_flags &
+	     (EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_LOC_HOST)) ==
+	    (EF4_FILTER_MATCH_ETHER_TYPE | EF4_FILTER_MATCH_LOC_HOST)) {
+		if (spec->ether_type == htons(ETH_P_IP) &&
+		    ipv4_is_multicast(spec->loc_host[0]))
+			return true;
+		if (spec->ether_type == htons(ETH_P_IPV6) &&
+		    ((const u8 *)spec->loc_host)[0] == 0xff)
+			return true;
+	}
+
+	return false;
+}
diff --git a/drivers/net/ethernet/sfc/falcon/selftest.c b/drivers/net/ethernet/sfc/falcon/selftest.c
new file mode 100644
index 0000000..92bc34c
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/selftest.c
@@ -0,0 +1,808 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2012 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/kernel_stat.h>
+#include <linux/pci.h>
+#include <linux/ethtool.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/udp.h>
+#include <linux/rtnetlink.h>
+#include <linux/slab.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "nic.h"
+#include "selftest.h"
+#include "workarounds.h"
+
+/* IRQ latency can be enormous because:
+ * - All IRQs may be disabled on a CPU for a *long* time by e.g. a
+ *   slow serial console or an old IDE driver doing error recovery
+ * - The PREEMPT_RT patches mostly deal with this, but also allow a
+ *   tasklet or normal task to be given higher priority than our IRQ
+ *   threads
+ * Try to avoid blaming the hardware for this.
+ */
+#define IRQ_TIMEOUT HZ
+
+/*
+ * Loopback test packet structure
+ *
+ * The self-test should stress every RSS vector, and unfortunately
+ * Falcon only performs RSS on TCP/UDP packets.
+ */
+struct ef4_loopback_payload {
+	struct ethhdr header;
+	struct iphdr ip;
+	struct udphdr udp;
+	__be16 iteration;
+	char msg[64];
+} __packed;
+
+/* Loopback test source MAC address */
+static const u8 payload_source[ETH_ALEN] __aligned(2) = {
+	0x00, 0x0f, 0x53, 0x1b, 0x1b, 0x1b,
+};
+
+static const char payload_msg[] =
+	"Hello world! This is an Efx loopback test in progress!";
+
+/* Interrupt mode names */
+static const unsigned int ef4_interrupt_mode_max = EF4_INT_MODE_MAX;
+static const char *const ef4_interrupt_mode_names[] = {
+	[EF4_INT_MODE_MSIX]   = "MSI-X",
+	[EF4_INT_MODE_MSI]    = "MSI",
+	[EF4_INT_MODE_LEGACY] = "legacy",
+};
+#define INT_MODE(efx) \
+	STRING_TABLE_LOOKUP(efx->interrupt_mode, ef4_interrupt_mode)
+
+/**
+ * ef4_loopback_state - persistent state during a loopback selftest
+ * @flush:		Drop all packets in ef4_loopback_rx_packet
+ * @packet_count:	Number of packets being used in this test
+ * @skbs:		An array of skbs transmitted
+ * @offload_csum:	Checksums are being offloaded
+ * @rx_good:		RX good packet count
+ * @rx_bad:		RX bad packet count
+ * @payload:		Payload used in tests
+ */
+struct ef4_loopback_state {
+	bool flush;
+	int packet_count;
+	struct sk_buff **skbs;
+	bool offload_csum;
+	atomic_t rx_good;
+	atomic_t rx_bad;
+	struct ef4_loopback_payload payload;
+};
+
+/* How long to wait for all the packets to arrive (in ms) */
+#define LOOPBACK_TIMEOUT_MS 1000
+
+/**************************************************************************
+ *
+ * MII, NVRAM and register tests
+ *
+ **************************************************************************/
+
+static int ef4_test_phy_alive(struct ef4_nic *efx, struct ef4_self_tests *tests)
+{
+	int rc = 0;
+
+	if (efx->phy_op->test_alive) {
+		rc = efx->phy_op->test_alive(efx);
+		tests->phy_alive = rc ? -1 : 1;
+	}
+
+	return rc;
+}
+
+static int ef4_test_nvram(struct ef4_nic *efx, struct ef4_self_tests *tests)
+{
+	int rc = 0;
+
+	if (efx->type->test_nvram) {
+		rc = efx->type->test_nvram(efx);
+		if (rc == -EPERM)
+			rc = 0;
+		else
+			tests->nvram = rc ? -1 : 1;
+	}
+
+	return rc;
+}
+
+/**************************************************************************
+ *
+ * Interrupt and event queue testing
+ *
+ **************************************************************************/
+
+/* Test generation and receipt of interrupts */
+static int ef4_test_interrupts(struct ef4_nic *efx,
+			       struct ef4_self_tests *tests)
+{
+	unsigned long timeout, wait;
+	int cpu;
+	int rc;
+
+	netif_dbg(efx, drv, efx->net_dev, "testing interrupts\n");
+	tests->interrupt = -1;
+
+	rc = ef4_nic_irq_test_start(efx);
+	if (rc == -ENOTSUPP) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "direct interrupt testing not supported\n");
+		tests->interrupt = 0;
+		return 0;
+	}
+
+	timeout = jiffies + IRQ_TIMEOUT;
+	wait = 1;
+
+	/* Wait for arrival of test interrupt. */
+	netif_dbg(efx, drv, efx->net_dev, "waiting for test interrupt\n");
+	do {
+		schedule_timeout_uninterruptible(wait);
+		cpu = ef4_nic_irq_test_irq_cpu(efx);
+		if (cpu >= 0)
+			goto success;
+		wait *= 2;
+	} while (time_before(jiffies, timeout));
+
+	netif_err(efx, drv, efx->net_dev, "timed out waiting for interrupt\n");
+	return -ETIMEDOUT;
+
+ success:
+	netif_dbg(efx, drv, efx->net_dev, "%s test interrupt seen on CPU%d\n",
+		  INT_MODE(efx), cpu);
+	tests->interrupt = 1;
+	return 0;
+}
+
+/* Test generation and receipt of interrupting events */
+static int ef4_test_eventq_irq(struct ef4_nic *efx,
+			       struct ef4_self_tests *tests)
+{
+	struct ef4_channel *channel;
+	unsigned int read_ptr[EF4_MAX_CHANNELS];
+	unsigned long napi_ran = 0, dma_pend = 0, int_pend = 0;
+	unsigned long timeout, wait;
+
+	BUILD_BUG_ON(EF4_MAX_CHANNELS > BITS_PER_LONG);
+
+	ef4_for_each_channel(channel, efx) {
+		read_ptr[channel->channel] = channel->eventq_read_ptr;
+		set_bit(channel->channel, &dma_pend);
+		set_bit(channel->channel, &int_pend);
+		ef4_nic_event_test_start(channel);
+	}
+
+	timeout = jiffies + IRQ_TIMEOUT;
+	wait = 1;
+
+	/* Wait for arrival of interrupts.  NAPI processing may or may
+	 * not complete in time, but we can cope in any case.
+	 */
+	do {
+		schedule_timeout_uninterruptible(wait);
+
+		ef4_for_each_channel(channel, efx) {
+			ef4_stop_eventq(channel);
+			if (channel->eventq_read_ptr !=
+			    read_ptr[channel->channel]) {
+				set_bit(channel->channel, &napi_ran);
+				clear_bit(channel->channel, &dma_pend);
+				clear_bit(channel->channel, &int_pend);
+			} else {
+				if (ef4_nic_event_present(channel))
+					clear_bit(channel->channel, &dma_pend);
+				if (ef4_nic_event_test_irq_cpu(channel) >= 0)
+					clear_bit(channel->channel, &int_pend);
+			}
+			ef4_start_eventq(channel);
+		}
+
+		wait *= 2;
+	} while ((dma_pend || int_pend) && time_before(jiffies, timeout));
+
+	ef4_for_each_channel(channel, efx) {
+		bool dma_seen = !test_bit(channel->channel, &dma_pend);
+		bool int_seen = !test_bit(channel->channel, &int_pend);
+
+		tests->eventq_dma[channel->channel] = dma_seen ? 1 : -1;
+		tests->eventq_int[channel->channel] = int_seen ? 1 : -1;
+
+		if (dma_seen && int_seen) {
+			netif_dbg(efx, drv, efx->net_dev,
+				  "channel %d event queue passed (with%s NAPI)\n",
+				  channel->channel,
+				  test_bit(channel->channel, &napi_ran) ?
+				  "" : "out");
+		} else {
+			/* Report failure and whether either interrupt or DMA
+			 * worked
+			 */
+			netif_err(efx, drv, efx->net_dev,
+				  "channel %d timed out waiting for event queue\n",
+				  channel->channel);
+			if (int_seen)
+				netif_err(efx, drv, efx->net_dev,
+					  "channel %d saw interrupt "
+					  "during event queue test\n",
+					  channel->channel);
+			if (dma_seen)
+				netif_err(efx, drv, efx->net_dev,
+					  "channel %d event was generated, but "
+					  "failed to trigger an interrupt\n",
+					  channel->channel);
+		}
+	}
+
+	return (dma_pend || int_pend) ? -ETIMEDOUT : 0;
+}
+
+static int ef4_test_phy(struct ef4_nic *efx, struct ef4_self_tests *tests,
+			unsigned flags)
+{
+	int rc;
+
+	if (!efx->phy_op->run_tests)
+		return 0;
+
+	mutex_lock(&efx->mac_lock);
+	rc = efx->phy_op->run_tests(efx, tests->phy_ext, flags);
+	mutex_unlock(&efx->mac_lock);
+	if (rc == -EPERM)
+		rc = 0;
+	else
+		netif_info(efx, drv, efx->net_dev,
+			   "%s phy selftest\n", rc ? "Failed" : "Passed");
+
+	return rc;
+}
+
+/**************************************************************************
+ *
+ * Loopback testing
+ * NB Only one loopback test can be executing concurrently.
+ *
+ **************************************************************************/
+
+/* Loopback test RX callback
+ * This is called for each received packet during loopback testing.
+ */
+void ef4_loopback_rx_packet(struct ef4_nic *efx,
+			    const char *buf_ptr, int pkt_len)
+{
+	struct ef4_loopback_state *state = efx->loopback_selftest;
+	struct ef4_loopback_payload *received;
+	struct ef4_loopback_payload *payload;
+
+	BUG_ON(!buf_ptr);
+
+	/* If we are just flushing, then drop the packet */
+	if ((state == NULL) || state->flush)
+		return;
+
+	payload = &state->payload;
+
+	received = (struct ef4_loopback_payload *) buf_ptr;
+	received->ip.saddr = payload->ip.saddr;
+	if (state->offload_csum)
+		received->ip.check = payload->ip.check;
+
+	/* Check that header exists */
+	if (pkt_len < sizeof(received->header)) {
+		netif_err(efx, drv, efx->net_dev,
+			  "saw runt RX packet (length %d) in %s loopback "
+			  "test\n", pkt_len, LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that the ethernet header exists */
+	if (memcmp(&received->header, &payload->header, ETH_HLEN) != 0) {
+		netif_err(efx, drv, efx->net_dev,
+			  "saw non-loopback RX packet in %s loopback test\n",
+			  LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check packet length */
+	if (pkt_len != sizeof(*payload)) {
+		netif_err(efx, drv, efx->net_dev,
+			  "saw incorrect RX packet length %d (wanted %d) in "
+			  "%s loopback test\n", pkt_len, (int)sizeof(*payload),
+			  LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that IP header matches */
+	if (memcmp(&received->ip, &payload->ip, sizeof(payload->ip)) != 0) {
+		netif_err(efx, drv, efx->net_dev,
+			  "saw corrupted IP header in %s loopback test\n",
+			  LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that msg and padding matches */
+	if (memcmp(&received->msg, &payload->msg, sizeof(received->msg)) != 0) {
+		netif_err(efx, drv, efx->net_dev,
+			  "saw corrupted RX packet in %s loopback test\n",
+			  LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Check that iteration matches */
+	if (received->iteration != payload->iteration) {
+		netif_err(efx, drv, efx->net_dev,
+			  "saw RX packet from iteration %d (wanted %d) in "
+			  "%s loopback test\n", ntohs(received->iteration),
+			  ntohs(payload->iteration), LOOPBACK_MODE(efx));
+		goto err;
+	}
+
+	/* Increase correct RX count */
+	netif_vdbg(efx, drv, efx->net_dev,
+		   "got loopback RX in %s loopback test\n", LOOPBACK_MODE(efx));
+
+	atomic_inc(&state->rx_good);
+	return;
+
+ err:
+#ifdef DEBUG
+	if (atomic_read(&state->rx_bad) == 0) {
+		netif_err(efx, drv, efx->net_dev, "received packet:\n");
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
+			       buf_ptr, pkt_len, 0);
+		netif_err(efx, drv, efx->net_dev, "expected packet:\n");
+		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
+			       &state->payload, sizeof(state->payload), 0);
+	}
+#endif
+	atomic_inc(&state->rx_bad);
+}
+
+/* Initialise an ef4_selftest_state for a new iteration */
+static void ef4_iterate_state(struct ef4_nic *efx)
+{
+	struct ef4_loopback_state *state = efx->loopback_selftest;
+	struct net_device *net_dev = efx->net_dev;
+	struct ef4_loopback_payload *payload = &state->payload;
+
+	/* Initialise the layerII header */
+	ether_addr_copy((u8 *)&payload->header.h_dest, net_dev->dev_addr);
+	ether_addr_copy((u8 *)&payload->header.h_source, payload_source);
+	payload->header.h_proto = htons(ETH_P_IP);
+
+	/* saddr set later and used as incrementing count */
+	payload->ip.daddr = htonl(INADDR_LOOPBACK);
+	payload->ip.ihl = 5;
+	payload->ip.check = (__force __sum16) htons(0xdead);
+	payload->ip.tot_len = htons(sizeof(*payload) - sizeof(struct ethhdr));
+	payload->ip.version = IPVERSION;
+	payload->ip.protocol = IPPROTO_UDP;
+
+	/* Initialise udp header */
+	payload->udp.source = 0;
+	payload->udp.len = htons(sizeof(*payload) - sizeof(struct ethhdr) -
+				 sizeof(struct iphdr));
+	payload->udp.check = 0;	/* checksum ignored */
+
+	/* Fill out payload */
+	payload->iteration = htons(ntohs(payload->iteration) + 1);
+	memcpy(&payload->msg, payload_msg, sizeof(payload_msg));
+
+	/* Fill out remaining state members */
+	atomic_set(&state->rx_good, 0);
+	atomic_set(&state->rx_bad, 0);
+	smp_wmb();
+}
+
+static int ef4_begin_loopback(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	struct ef4_loopback_state *state = efx->loopback_selftest;
+	struct ef4_loopback_payload *payload;
+	struct sk_buff *skb;
+	int i;
+	netdev_tx_t rc;
+
+	/* Transmit N copies of buffer */
+	for (i = 0; i < state->packet_count; i++) {
+		/* Allocate an skb, holding an extra reference for
+		 * transmit completion counting */
+		skb = alloc_skb(sizeof(state->payload), GFP_KERNEL);
+		if (!skb)
+			return -ENOMEM;
+		state->skbs[i] = skb;
+		skb_get(skb);
+
+		/* Copy the payload in, incrementing the source address to
+		 * exercise the rss vectors */
+		payload = ((struct ef4_loopback_payload *)
+			   skb_put(skb, sizeof(state->payload)));
+		memcpy(payload, &state->payload, sizeof(state->payload));
+		payload->ip.saddr = htonl(INADDR_LOOPBACK | (i << 2));
+
+		/* Ensure everything we've written is visible to the
+		 * interrupt handler. */
+		smp_wmb();
+
+		netif_tx_lock_bh(efx->net_dev);
+		rc = ef4_enqueue_skb(tx_queue, skb);
+		netif_tx_unlock_bh(efx->net_dev);
+
+		if (rc != NETDEV_TX_OK) {
+			netif_err(efx, drv, efx->net_dev,
+				  "TX queue %d could not transmit packet %d of "
+				  "%d in %s loopback test\n", tx_queue->queue,
+				  i + 1, state->packet_count,
+				  LOOPBACK_MODE(efx));
+
+			/* Defer cleaning up the other skbs for the caller */
+			kfree_skb(skb);
+			return -EPIPE;
+		}
+	}
+
+	return 0;
+}
+
+static int ef4_poll_loopback(struct ef4_nic *efx)
+{
+	struct ef4_loopback_state *state = efx->loopback_selftest;
+
+	return atomic_read(&state->rx_good) == state->packet_count;
+}
+
+static int ef4_end_loopback(struct ef4_tx_queue *tx_queue,
+			    struct ef4_loopback_self_tests *lb_tests)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	struct ef4_loopback_state *state = efx->loopback_selftest;
+	struct sk_buff *skb;
+	int tx_done = 0, rx_good, rx_bad;
+	int i, rc = 0;
+
+	netif_tx_lock_bh(efx->net_dev);
+
+	/* Count the number of tx completions, and decrement the refcnt. Any
+	 * skbs not already completed will be free'd when the queue is flushed */
+	for (i = 0; i < state->packet_count; i++) {
+		skb = state->skbs[i];
+		if (skb && !skb_shared(skb))
+			++tx_done;
+		dev_kfree_skb(skb);
+	}
+
+	netif_tx_unlock_bh(efx->net_dev);
+
+	/* Check TX completion and received packet counts */
+	rx_good = atomic_read(&state->rx_good);
+	rx_bad = atomic_read(&state->rx_bad);
+	if (tx_done != state->packet_count) {
+		/* Don't free the skbs; they will be picked up on TX
+		 * overflow or channel teardown.
+		 */
+		netif_err(efx, drv, efx->net_dev,
+			  "TX queue %d saw only %d out of an expected %d "
+			  "TX completion events in %s loopback test\n",
+			  tx_queue->queue, tx_done, state->packet_count,
+			  LOOPBACK_MODE(efx));
+		rc = -ETIMEDOUT;
+		/* Allow to fall through so we see the RX errors as well */
+	}
+
+	/* We may always be up to a flush away from our desired packet total */
+	if (rx_good != state->packet_count) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "TX queue %d saw only %d out of an expected %d "
+			  "received packets in %s loopback test\n",
+			  tx_queue->queue, rx_good, state->packet_count,
+			  LOOPBACK_MODE(efx));
+		rc = -ETIMEDOUT;
+		/* Fall through */
+	}
+
+	/* Update loopback test structure */
+	lb_tests->tx_sent[tx_queue->queue] += state->packet_count;
+	lb_tests->tx_done[tx_queue->queue] += tx_done;
+	lb_tests->rx_good += rx_good;
+	lb_tests->rx_bad += rx_bad;
+
+	return rc;
+}
+
+static int
+ef4_test_loopback(struct ef4_tx_queue *tx_queue,
+		  struct ef4_loopback_self_tests *lb_tests)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	struct ef4_loopback_state *state = efx->loopback_selftest;
+	int i, begin_rc, end_rc;
+
+	for (i = 0; i < 3; i++) {
+		/* Determine how many packets to send */
+		state->packet_count = efx->txq_entries / 3;
+		state->packet_count = min(1 << (i << 2), state->packet_count);
+		state->skbs = kcalloc(state->packet_count,
+				      sizeof(state->skbs[0]), GFP_KERNEL);
+		if (!state->skbs)
+			return -ENOMEM;
+		state->flush = false;
+
+		netif_dbg(efx, drv, efx->net_dev,
+			  "TX queue %d testing %s loopback with %d packets\n",
+			  tx_queue->queue, LOOPBACK_MODE(efx),
+			  state->packet_count);
+
+		ef4_iterate_state(efx);
+		begin_rc = ef4_begin_loopback(tx_queue);
+
+		/* This will normally complete very quickly, but be
+		 * prepared to wait much longer. */
+		msleep(1);
+		if (!ef4_poll_loopback(efx)) {
+			msleep(LOOPBACK_TIMEOUT_MS);
+			ef4_poll_loopback(efx);
+		}
+
+		end_rc = ef4_end_loopback(tx_queue, lb_tests);
+		kfree(state->skbs);
+
+		if (begin_rc || end_rc) {
+			/* Wait a while to ensure there are no packets
+			 * floating around after a failure. */
+			schedule_timeout_uninterruptible(HZ / 10);
+			return begin_rc ? begin_rc : end_rc;
+		}
+	}
+
+	netif_dbg(efx, drv, efx->net_dev,
+		  "TX queue %d passed %s loopback test with a burst length "
+		  "of %d packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
+		  state->packet_count);
+
+	return 0;
+}
+
+/* Wait for link up. On Falcon, we would prefer to rely on ef4_monitor, but
+ * any contention on the mac lock (via e.g. ef4_mac_mcast_work) causes it
+ * to delay and retry. Therefore, it's safer to just poll directly. Wait
+ * for link up and any faults to dissipate. */
+static int ef4_wait_for_link(struct ef4_nic *efx)
+{
+	struct ef4_link_state *link_state = &efx->link_state;
+	int count, link_up_count = 0;
+	bool link_up;
+
+	for (count = 0; count < 40; count++) {
+		schedule_timeout_uninterruptible(HZ / 10);
+
+		if (efx->type->monitor != NULL) {
+			mutex_lock(&efx->mac_lock);
+			efx->type->monitor(efx);
+			mutex_unlock(&efx->mac_lock);
+		}
+
+		mutex_lock(&efx->mac_lock);
+		link_up = link_state->up;
+		if (link_up)
+			link_up = !efx->type->check_mac_fault(efx);
+		mutex_unlock(&efx->mac_lock);
+
+		if (link_up) {
+			if (++link_up_count == 2)
+				return 0;
+		} else {
+			link_up_count = 0;
+		}
+	}
+
+	return -ETIMEDOUT;
+}
+
+static int ef4_test_loopbacks(struct ef4_nic *efx, struct ef4_self_tests *tests,
+			      unsigned int loopback_modes)
+{
+	enum ef4_loopback_mode mode;
+	struct ef4_loopback_state *state;
+	struct ef4_channel *channel =
+		ef4_get_channel(efx, efx->tx_channel_offset);
+	struct ef4_tx_queue *tx_queue;
+	int rc = 0;
+
+	/* Set the port loopback_selftest member. From this point on
+	 * all received packets will be dropped. Mark the state as
+	 * "flushing" so all inflight packets are dropped */
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
+	if (state == NULL)
+		return -ENOMEM;
+	BUG_ON(efx->loopback_selftest);
+	state->flush = true;
+	efx->loopback_selftest = state;
+
+	/* Test all supported loopback modes */
+	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
+		if (!(loopback_modes & (1 << mode)))
+			continue;
+
+		/* Move the port into the specified loopback mode. */
+		state->flush = true;
+		mutex_lock(&efx->mac_lock);
+		efx->loopback_mode = mode;
+		rc = __ef4_reconfigure_port(efx);
+		mutex_unlock(&efx->mac_lock);
+		if (rc) {
+			netif_err(efx, drv, efx->net_dev,
+				  "unable to move into %s loopback\n",
+				  LOOPBACK_MODE(efx));
+			goto out;
+		}
+
+		rc = ef4_wait_for_link(efx);
+		if (rc) {
+			netif_err(efx, drv, efx->net_dev,
+				  "loopback %s never came up\n",
+				  LOOPBACK_MODE(efx));
+			goto out;
+		}
+
+		/* Test all enabled types of TX queue */
+		ef4_for_each_channel_tx_queue(tx_queue, channel) {
+			state->offload_csum = (tx_queue->queue &
+					       EF4_TXQ_TYPE_OFFLOAD);
+			rc = ef4_test_loopback(tx_queue,
+					       &tests->loopback[mode]);
+			if (rc)
+				goto out;
+		}
+	}
+
+ out:
+	/* Remove the flush. The caller will remove the loopback setting */
+	state->flush = true;
+	efx->loopback_selftest = NULL;
+	wmb();
+	kfree(state);
+
+	if (rc == -EPERM)
+		rc = 0;
+
+	return rc;
+}
+
+/**************************************************************************
+ *
+ * Entry point
+ *
+ *************************************************************************/
+
+int ef4_selftest(struct ef4_nic *efx, struct ef4_self_tests *tests,
+		 unsigned flags)
+{
+	enum ef4_loopback_mode loopback_mode = efx->loopback_mode;
+	int phy_mode = efx->phy_mode;
+	int rc_test = 0, rc_reset, rc;
+
+	ef4_selftest_async_cancel(efx);
+
+	/* Online (i.e. non-disruptive) testing
+	 * This checks interrupt generation, event delivery and PHY presence. */
+
+	rc = ef4_test_phy_alive(efx, tests);
+	if (rc && !rc_test)
+		rc_test = rc;
+
+	rc = ef4_test_nvram(efx, tests);
+	if (rc && !rc_test)
+		rc_test = rc;
+
+	rc = ef4_test_interrupts(efx, tests);
+	if (rc && !rc_test)
+		rc_test = rc;
+
+	rc = ef4_test_eventq_irq(efx, tests);
+	if (rc && !rc_test)
+		rc_test = rc;
+
+	if (rc_test)
+		return rc_test;
+
+	if (!(flags & ETH_TEST_FL_OFFLINE))
+		return ef4_test_phy(efx, tests, flags);
+
+	/* Offline (i.e. disruptive) testing
+	 * This checks MAC and PHY loopback on the specified port. */
+
+	/* Detach the device so the kernel doesn't transmit during the
+	 * loopback test and the watchdog timeout doesn't fire.
+	 */
+	ef4_device_detach_sync(efx);
+
+	if (efx->type->test_chip) {
+		rc_reset = efx->type->test_chip(efx, tests);
+		if (rc_reset) {
+			netif_err(efx, hw, efx->net_dev,
+				  "Unable to recover from chip test\n");
+			ef4_schedule_reset(efx, RESET_TYPE_DISABLE);
+			return rc_reset;
+		}
+
+		if ((tests->memory < 0 || tests->registers < 0) && !rc_test)
+			rc_test = -EIO;
+	}
+
+	/* Ensure that the phy is powered and out of loopback
+	 * for the bist and loopback tests */
+	mutex_lock(&efx->mac_lock);
+	efx->phy_mode &= ~PHY_MODE_LOW_POWER;
+	efx->loopback_mode = LOOPBACK_NONE;
+	__ef4_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	rc = ef4_test_phy(efx, tests, flags);
+	if (rc && !rc_test)
+		rc_test = rc;
+
+	rc = ef4_test_loopbacks(efx, tests, efx->loopback_modes);
+	if (rc && !rc_test)
+		rc_test = rc;
+
+	/* restore the PHY to the previous state */
+	mutex_lock(&efx->mac_lock);
+	efx->phy_mode = phy_mode;
+	efx->loopback_mode = loopback_mode;
+	__ef4_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	netif_device_attach(efx->net_dev);
+
+	return rc_test;
+}
+
+void ef4_selftest_async_start(struct ef4_nic *efx)
+{
+	struct ef4_channel *channel;
+
+	ef4_for_each_channel(channel, efx)
+		ef4_nic_event_test_start(channel);
+	schedule_delayed_work(&efx->selftest_work, IRQ_TIMEOUT);
+}
+
+void ef4_selftest_async_cancel(struct ef4_nic *efx)
+{
+	cancel_delayed_work_sync(&efx->selftest_work);
+}
+
+void ef4_selftest_async_work(struct work_struct *data)
+{
+	struct ef4_nic *efx = container_of(data, struct ef4_nic,
+					   selftest_work.work);
+	struct ef4_channel *channel;
+	int cpu;
+
+	ef4_for_each_channel(channel, efx) {
+		cpu = ef4_nic_event_test_irq_cpu(channel);
+		if (cpu < 0)
+			netif_err(efx, ifup, efx->net_dev,
+				  "channel %d failed to trigger an interrupt\n",
+				  channel->channel);
+		else
+			netif_dbg(efx, ifup, efx->net_dev,
+				  "channel %d triggered interrupt on CPU %d\n",
+				  channel->channel, cpu);
+	}
+}
diff --git a/drivers/net/ethernet/sfc/falcon/selftest.h b/drivers/net/ethernet/sfc/falcon/selftest.h
new file mode 100644
index 0000000..be52a49
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/selftest.h
@@ -0,0 +1,55 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2012 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_SELFTEST_H
+#define EF4_SELFTEST_H
+
+#include "net_driver.h"
+
+/*
+ * Self tests
+ */
+
+struct ef4_loopback_self_tests {
+	int tx_sent[EF4_TXQ_TYPES];
+	int tx_done[EF4_TXQ_TYPES];
+	int rx_good;
+	int rx_bad;
+};
+
+#define EF4_MAX_PHY_TESTS 20
+
+/* Efx self test results
+ * For fields which are not counters, 1 indicates success and -1
+ * indicates failure; 0 indicates test could not be run.
+ */
+struct ef4_self_tests {
+	/* online tests */
+	int phy_alive;
+	int nvram;
+	int interrupt;
+	int eventq_dma[EF4_MAX_CHANNELS];
+	int eventq_int[EF4_MAX_CHANNELS];
+	/* offline tests */
+	int memory;
+	int registers;
+	int phy_ext[EF4_MAX_PHY_TESTS];
+	struct ef4_loopback_self_tests loopback[LOOPBACK_TEST_MAX + 1];
+};
+
+void ef4_loopback_rx_packet(struct ef4_nic *efx, const char *buf_ptr,
+			    int pkt_len);
+int ef4_selftest(struct ef4_nic *efx, struct ef4_self_tests *tests,
+		 unsigned flags);
+void ef4_selftest_async_start(struct ef4_nic *efx);
+void ef4_selftest_async_cancel(struct ef4_nic *efx);
+void ef4_selftest_async_work(struct work_struct *data);
+
+#endif /* EF4_SELFTEST_H */
diff --git a/drivers/net/ethernet/sfc/falcon/tenxpress.c b/drivers/net/ethernet/sfc/falcon/tenxpress.c
new file mode 100644
index 0000000..acc548a
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/tenxpress.c
@@ -0,0 +1,494 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2007-2011 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/delay.h>
+#include <linux/rtnetlink.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include "efx.h"
+#include "mdio_10g.h"
+#include "nic.h"
+#include "phy.h"
+#include "workarounds.h"
+
+/* We expect these MMDs to be in the package. */
+#define TENXPRESS_REQUIRED_DEVS (MDIO_DEVS_PMAPMD	| \
+				 MDIO_DEVS_PCS		| \
+				 MDIO_DEVS_PHYXS	| \
+				 MDIO_DEVS_AN)
+
+#define SFX7101_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
+			   (1 << LOOPBACK_PCS) |	\
+			   (1 << LOOPBACK_PMAPMD) |	\
+			   (1 << LOOPBACK_PHYXS_WS))
+
+/* We complain if we fail to see the link partner as 10G capable this many
+ * times in a row (must be > 1 as sampling the autoneg. registers is racy)
+ */
+#define MAX_BAD_LP_TRIES	(5)
+
+/* Extended control register */
+#define PMA_PMD_XCONTROL_REG	49152
+#define PMA_PMD_EXT_GMII_EN_LBN	1
+#define PMA_PMD_EXT_GMII_EN_WIDTH 1
+#define PMA_PMD_EXT_CLK_OUT_LBN	2
+#define PMA_PMD_EXT_CLK_OUT_WIDTH 1
+#define PMA_PMD_LNPGA_POWERDOWN_LBN 8
+#define PMA_PMD_LNPGA_POWERDOWN_WIDTH 1
+#define PMA_PMD_EXT_CLK312_WIDTH 1
+#define PMA_PMD_EXT_LPOWER_LBN  12
+#define PMA_PMD_EXT_LPOWER_WIDTH 1
+#define PMA_PMD_EXT_ROBUST_LBN	14
+#define PMA_PMD_EXT_ROBUST_WIDTH 1
+#define PMA_PMD_EXT_SSR_LBN	15
+#define PMA_PMD_EXT_SSR_WIDTH	1
+
+/* extended status register */
+#define PMA_PMD_XSTATUS_REG	49153
+#define PMA_PMD_XSTAT_MDIX_LBN	14
+#define PMA_PMD_XSTAT_FLP_LBN   (12)
+
+/* LED control register */
+#define PMA_PMD_LED_CTRL_REG	49159
+#define PMA_PMA_LED_ACTIVITY_LBN	(3)
+
+/* LED function override register */
+#define PMA_PMD_LED_OVERR_REG	49161
+/* Bit positions for different LEDs (there are more but not wired on SFE4001)*/
+#define PMA_PMD_LED_LINK_LBN	(0)
+#define PMA_PMD_LED_SPEED_LBN	(2)
+#define PMA_PMD_LED_TX_LBN	(4)
+#define PMA_PMD_LED_RX_LBN	(6)
+/* Override settings */
+#define	PMA_PMD_LED_AUTO	(0)	/* H/W control */
+#define	PMA_PMD_LED_ON		(1)
+#define	PMA_PMD_LED_OFF		(2)
+#define PMA_PMD_LED_FLASH	(3)
+#define PMA_PMD_LED_MASK	3
+/* All LEDs under hardware control */
+/* Green and Amber under hardware control, Red off */
+#define SFX7101_PMA_PMD_LED_DEFAULT (PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
+
+#define PMA_PMD_SPEED_ENABLE_REG 49192
+#define PMA_PMD_100TX_ADV_LBN    1
+#define PMA_PMD_100TX_ADV_WIDTH  1
+#define PMA_PMD_1000T_ADV_LBN    2
+#define PMA_PMD_1000T_ADV_WIDTH  1
+#define PMA_PMD_10000T_ADV_LBN   3
+#define PMA_PMD_10000T_ADV_WIDTH 1
+#define PMA_PMD_SPEED_LBN        4
+#define PMA_PMD_SPEED_WIDTH      4
+
+/* Misc register defines */
+#define PCS_CLOCK_CTRL_REG	55297
+#define PLL312_RST_N_LBN 2
+
+#define PCS_SOFT_RST2_REG	55302
+#define SERDES_RST_N_LBN 13
+#define XGXS_RST_N_LBN 12
+
+#define	PCS_TEST_SELECT_REG	55303	/* PRM 10.5.8 */
+#define	CLK312_EN_LBN 3
+
+/* PHYXS registers */
+#define PHYXS_XCONTROL_REG	49152
+#define PHYXS_RESET_LBN		15
+#define PHYXS_RESET_WIDTH	1
+
+#define PHYXS_TEST1         (49162)
+#define LOOPBACK_NEAR_LBN   (8)
+#define LOOPBACK_NEAR_WIDTH (1)
+
+/* Boot status register */
+#define PCS_BOOT_STATUS_REG		53248
+#define PCS_BOOT_FATAL_ERROR_LBN	0
+#define PCS_BOOT_PROGRESS_LBN		1
+#define PCS_BOOT_PROGRESS_WIDTH		2
+#define PCS_BOOT_PROGRESS_INIT		0
+#define PCS_BOOT_PROGRESS_WAIT_MDIO	1
+#define PCS_BOOT_PROGRESS_CHECKSUM	2
+#define PCS_BOOT_PROGRESS_JUMP		3
+#define PCS_BOOT_DOWNLOAD_WAIT_LBN	3
+#define PCS_BOOT_CODE_STARTED_LBN	4
+
+/* 100M/1G PHY registers */
+#define GPHY_XCONTROL_REG	49152
+#define GPHY_ISOLATE_LBN	10
+#define GPHY_ISOLATE_WIDTH	1
+#define GPHY_DUPLEX_LBN		8
+#define GPHY_DUPLEX_WIDTH	1
+#define GPHY_LOOPBACK_NEAR_LBN	14
+#define GPHY_LOOPBACK_NEAR_WIDTH 1
+
+#define C22EXT_STATUS_REG       49153
+#define C22EXT_STATUS_LINK_LBN  2
+#define C22EXT_STATUS_LINK_WIDTH 1
+
+#define C22EXT_MSTSLV_CTRL			49161
+#define C22EXT_MSTSLV_CTRL_ADV_1000_HD_LBN	8
+#define C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN	9
+
+#define C22EXT_MSTSLV_STATUS			49162
+#define C22EXT_MSTSLV_STATUS_LP_1000_HD_LBN	10
+#define C22EXT_MSTSLV_STATUS_LP_1000_FD_LBN	11
+
+/* Time to wait between powering down the LNPGA and turning off the power
+ * rails */
+#define LNPGA_PDOWN_WAIT	(HZ / 5)
+
+struct tenxpress_phy_data {
+	enum ef4_loopback_mode loopback_mode;
+	enum ef4_phy_mode phy_mode;
+	int bad_lp_tries;
+};
+
+static int tenxpress_init(struct ef4_nic *efx)
+{
+	/* Enable 312.5 MHz clock */
+	ef4_mdio_write(efx, MDIO_MMD_PCS, PCS_TEST_SELECT_REG,
+		       1 << CLK312_EN_LBN);
+
+	/* Set the LEDs up as: Green = Link, Amber = Link/Act, Red = Off */
+	ef4_mdio_set_flag(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG,
+			  1 << PMA_PMA_LED_ACTIVITY_LBN, true);
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG,
+		       SFX7101_PMA_PMD_LED_DEFAULT);
+
+	return 0;
+}
+
+static int tenxpress_phy_probe(struct ef4_nic *efx)
+{
+	struct tenxpress_phy_data *phy_data;
+
+	/* Allocate phy private storage */
+	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
+	if (!phy_data)
+		return -ENOMEM;
+	efx->phy_data = phy_data;
+	phy_data->phy_mode = efx->phy_mode;
+
+	efx->mdio.mmds = TENXPRESS_REQUIRED_DEVS;
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45;
+
+	efx->loopback_modes = SFX7101_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
+
+	efx->link_advertising = (ADVERTISED_TP | ADVERTISED_Autoneg |
+				 ADVERTISED_10000baseT_Full);
+
+	return 0;
+}
+
+static int tenxpress_phy_init(struct ef4_nic *efx)
+{
+	int rc;
+
+	falcon_board(efx)->type->init_phy(efx);
+
+	if (!(efx->phy_mode & PHY_MODE_SPECIAL)) {
+		rc = ef4_mdio_wait_reset_mmds(efx, TENXPRESS_REQUIRED_DEVS);
+		if (rc < 0)
+			return rc;
+
+		rc = ef4_mdio_check_mmds(efx, TENXPRESS_REQUIRED_DEVS);
+		if (rc < 0)
+			return rc;
+	}
+
+	rc = tenxpress_init(efx);
+	if (rc < 0)
+		return rc;
+
+	/* Reinitialise flow control settings */
+	ef4_link_set_wanted_fc(efx, efx->wanted_fc);
+	ef4_mdio_an_reconfigure(efx);
+
+	schedule_timeout_uninterruptible(HZ / 5); /* 200ms */
+
+	/* Let XGXS and SerDes out of reset */
+	falcon_reset_xaui(efx);
+
+	return 0;
+}
+
+/* Perform a "special software reset" on the PHY. The caller is
+ * responsible for saving and restoring the PHY hardware registers
+ * properly, and masking/unmasking LASI */
+static int tenxpress_special_reset(struct ef4_nic *efx)
+{
+	int rc, reg;
+
+	/* The XGMAC clock is driven from the SFX7101 312MHz clock, so
+	 * a special software reset can glitch the XGMAC sufficiently for stats
+	 * requests to fail. */
+	falcon_stop_nic_stats(efx);
+
+	/* Initiate reset */
+	reg = ef4_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
+	reg |= (1 << PMA_PMD_EXT_SSR_LBN);
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
+
+	mdelay(200);
+
+	/* Wait for the blocks to come out of reset */
+	rc = ef4_mdio_wait_reset_mmds(efx, TENXPRESS_REQUIRED_DEVS);
+	if (rc < 0)
+		goto out;
+
+	/* Try and reconfigure the device */
+	rc = tenxpress_init(efx);
+	if (rc < 0)
+		goto out;
+
+	/* Wait for the XGXS state machine to churn */
+	mdelay(10);
+out:
+	falcon_start_nic_stats(efx);
+	return rc;
+}
+
+static void sfx7101_check_bad_lp(struct ef4_nic *efx, bool link_ok)
+{
+	struct tenxpress_phy_data *pd = efx->phy_data;
+	bool bad_lp;
+	int reg;
+
+	if (link_ok) {
+		bad_lp = false;
+	} else {
+		/* Check that AN has started but not completed. */
+		reg = ef4_mdio_read(efx, MDIO_MMD_AN, MDIO_STAT1);
+		if (!(reg & MDIO_AN_STAT1_LPABLE))
+			return; /* LP status is unknown */
+		bad_lp = !(reg & MDIO_AN_STAT1_COMPLETE);
+		if (bad_lp)
+			pd->bad_lp_tries++;
+	}
+
+	/* Nothing to do if all is well and was previously so. */
+	if (!pd->bad_lp_tries)
+		return;
+
+	/* Use the RX (red) LED as an error indicator once we've seen AN
+	 * failure several times in a row, and also log a message. */
+	if (!bad_lp || pd->bad_lp_tries == MAX_BAD_LP_TRIES) {
+		reg = ef4_mdio_read(efx, MDIO_MMD_PMAPMD,
+				    PMA_PMD_LED_OVERR_REG);
+		reg &= ~(PMA_PMD_LED_MASK << PMA_PMD_LED_RX_LBN);
+		if (!bad_lp) {
+			reg |= PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN;
+		} else {
+			reg |= PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN;
+			netif_err(efx, link, efx->net_dev,
+				  "appears to be plugged into a port"
+				  " that is not 10GBASE-T capable. The PHY"
+				  " supports 10GBASE-T ONLY, so no link can"
+				  " be established\n");
+		}
+		ef4_mdio_write(efx, MDIO_MMD_PMAPMD,
+			       PMA_PMD_LED_OVERR_REG, reg);
+		pd->bad_lp_tries = bad_lp;
+	}
+}
+
+static bool sfx7101_link_ok(struct ef4_nic *efx)
+{
+	return ef4_mdio_links_ok(efx,
+				 MDIO_DEVS_PMAPMD |
+				 MDIO_DEVS_PCS |
+				 MDIO_DEVS_PHYXS);
+}
+
+static void tenxpress_ext_loopback(struct ef4_nic *efx)
+{
+	ef4_mdio_set_flag(efx, MDIO_MMD_PHYXS, PHYXS_TEST1,
+			  1 << LOOPBACK_NEAR_LBN,
+			  efx->loopback_mode == LOOPBACK_PHYXS);
+}
+
+static void tenxpress_low_power(struct ef4_nic *efx)
+{
+	ef4_mdio_set_mmds_lpower(
+		efx, !!(efx->phy_mode & PHY_MODE_LOW_POWER),
+		TENXPRESS_REQUIRED_DEVS);
+}
+
+static int tenxpress_phy_reconfigure(struct ef4_nic *efx)
+{
+	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	bool phy_mode_change, loop_reset;
+
+	if (efx->phy_mode & (PHY_MODE_OFF | PHY_MODE_SPECIAL)) {
+		phy_data->phy_mode = efx->phy_mode;
+		return 0;
+	}
+
+	phy_mode_change = (efx->phy_mode == PHY_MODE_NORMAL &&
+			   phy_data->phy_mode != PHY_MODE_NORMAL);
+	loop_reset = (LOOPBACK_OUT_OF(phy_data, efx, LOOPBACKS_EXTERNAL(efx)) ||
+		      LOOPBACK_CHANGED(phy_data, efx, 1 << LOOPBACK_GPHY));
+
+	if (loop_reset || phy_mode_change) {
+		tenxpress_special_reset(efx);
+		falcon_reset_xaui(efx);
+	}
+
+	tenxpress_low_power(efx);
+	ef4_mdio_transmit_disable(efx);
+	ef4_mdio_phy_reconfigure(efx);
+	tenxpress_ext_loopback(efx);
+	ef4_mdio_an_reconfigure(efx);
+
+	phy_data->loopback_mode = efx->loopback_mode;
+	phy_data->phy_mode = efx->phy_mode;
+
+	return 0;
+}
+
+static void
+tenxpress_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd);
+
+/* Poll for link state changes */
+static bool tenxpress_phy_poll(struct ef4_nic *efx)
+{
+	struct ef4_link_state old_state = efx->link_state;
+
+	efx->link_state.up = sfx7101_link_ok(efx);
+	efx->link_state.speed = 10000;
+	efx->link_state.fd = true;
+	efx->link_state.fc = ef4_mdio_get_pause(efx);
+
+	sfx7101_check_bad_lp(efx, efx->link_state.up);
+
+	return !ef4_link_state_equal(&efx->link_state, &old_state);
+}
+
+static void sfx7101_phy_fini(struct ef4_nic *efx)
+{
+	int reg;
+
+	/* Power down the LNPGA */
+	reg = (1 << PMA_PMD_LNPGA_POWERDOWN_LBN);
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
+
+	/* Waiting here ensures that the board fini, which can turn
+	 * off the power to the PHY, won't get run until the LNPGA
+	 * powerdown has been given long enough to complete. */
+	schedule_timeout_uninterruptible(LNPGA_PDOWN_WAIT); /* 200 ms */
+}
+
+static void tenxpress_phy_remove(struct ef4_nic *efx)
+{
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
+}
+
+
+/* Override the RX, TX and link LEDs */
+void tenxpress_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode)
+{
+	int reg;
+
+	switch (mode) {
+	case EF4_LED_OFF:
+		reg = (PMA_PMD_LED_OFF << PMA_PMD_LED_TX_LBN) |
+			(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN) |
+			(PMA_PMD_LED_OFF << PMA_PMD_LED_LINK_LBN);
+		break;
+	case EF4_LED_ON:
+		reg = (PMA_PMD_LED_ON << PMA_PMD_LED_TX_LBN) |
+			(PMA_PMD_LED_ON << PMA_PMD_LED_RX_LBN) |
+			(PMA_PMD_LED_ON << PMA_PMD_LED_LINK_LBN);
+		break;
+	default:
+		reg = SFX7101_PMA_PMD_LED_DEFAULT;
+		break;
+	}
+
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG, reg);
+}
+
+static const char *const sfx7101_test_names[] = {
+	"bist"
+};
+
+static const char *sfx7101_test_name(struct ef4_nic *efx, unsigned int index)
+{
+	if (index < ARRAY_SIZE(sfx7101_test_names))
+		return sfx7101_test_names[index];
+	return NULL;
+}
+
+static int
+sfx7101_run_tests(struct ef4_nic *efx, int *results, unsigned flags)
+{
+	int rc;
+
+	if (!(flags & ETH_TEST_FL_OFFLINE))
+		return 0;
+
+	/* BIST is automatically run after a special software reset */
+	rc = tenxpress_special_reset(efx);
+	results[0] = rc ? -1 : 1;
+
+	ef4_mdio_an_reconfigure(efx);
+
+	return rc;
+}
+
+static void
+tenxpress_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+{
+	u32 adv = 0, lpa = 0;
+	int reg;
+
+	reg = ef4_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL);
+	if (reg & MDIO_AN_10GBT_CTRL_ADV10G)
+		adv |= ADVERTISED_10000baseT_Full;
+	reg = ef4_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_10GBT_STAT);
+	if (reg & MDIO_AN_10GBT_STAT_LP10G)
+		lpa |= ADVERTISED_10000baseT_Full;
+
+	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
+
+	/* In loopback, the PHY automatically brings up the correct interface,
+	 * but doesn't advertise the correct speed. So override it */
+	if (LOOPBACK_EXTERNAL(efx))
+		ethtool_cmd_speed_set(ecmd, SPEED_10000);
+}
+
+static int tenxpress_set_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+{
+	if (!ecmd->autoneg)
+		return -EINVAL;
+
+	return ef4_mdio_set_settings(efx, ecmd);
+}
+
+static void sfx7101_set_npage_adv(struct ef4_nic *efx, u32 advertising)
+{
+	ef4_mdio_set_flag(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL,
+			  MDIO_AN_10GBT_CTRL_ADV10G,
+			  advertising & ADVERTISED_10000baseT_Full);
+}
+
+const struct ef4_phy_operations falcon_sfx7101_phy_ops = {
+	.probe		  = tenxpress_phy_probe,
+	.init             = tenxpress_phy_init,
+	.reconfigure      = tenxpress_phy_reconfigure,
+	.poll             = tenxpress_phy_poll,
+	.fini             = sfx7101_phy_fini,
+	.remove		  = tenxpress_phy_remove,
+	.get_settings	  = tenxpress_get_settings,
+	.set_settings	  = tenxpress_set_settings,
+	.set_npage_adv    = sfx7101_set_npage_adv,
+	.test_alive	  = ef4_mdio_test_alive,
+	.test_name	  = sfx7101_test_name,
+	.run_tests	  = sfx7101_run_tests,
+};
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
new file mode 100644
index 0000000..104fb15
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -0,0 +1,649 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/pci.h>
+#include <linux/tcp.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/ipv6.h>
+#include <linux/slab.h>
+#include <net/ipv6.h>
+#include <linux/if_ether.h>
+#include <linux/highmem.h>
+#include <linux/cache.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "io.h"
+#include "nic.h"
+#include "tx.h"
+#include "workarounds.h"
+
+static inline u8 *ef4_tx_get_copy_buffer(struct ef4_tx_queue *tx_queue,
+					 struct ef4_tx_buffer *buffer)
+{
+	unsigned int index = ef4_tx_queue_get_insert_index(tx_queue);
+	struct ef4_buffer *page_buf =
+		&tx_queue->cb_page[index >> (PAGE_SHIFT - EF4_TX_CB_ORDER)];
+	unsigned int offset =
+		((index << EF4_TX_CB_ORDER) + NET_IP_ALIGN) & (PAGE_SIZE - 1);
+
+	if (unlikely(!page_buf->addr) &&
+	    ef4_nic_alloc_buffer(tx_queue->efx, page_buf, PAGE_SIZE,
+				 GFP_ATOMIC))
+		return NULL;
+	buffer->dma_addr = page_buf->dma_addr + offset;
+	buffer->unmap_len = 0;
+	return (u8 *)page_buf->addr + offset;
+}
+
+u8 *ef4_tx_get_copy_buffer_limited(struct ef4_tx_queue *tx_queue,
+				   struct ef4_tx_buffer *buffer, size_t len)
+{
+	if (len > EF4_TX_CB_SIZE)
+		return NULL;
+	return ef4_tx_get_copy_buffer(tx_queue, buffer);
+}
+
+static void ef4_dequeue_buffer(struct ef4_tx_queue *tx_queue,
+			       struct ef4_tx_buffer *buffer,
+			       unsigned int *pkts_compl,
+			       unsigned int *bytes_compl)
+{
+	if (buffer->unmap_len) {
+		struct device *dma_dev = &tx_queue->efx->pci_dev->dev;
+		dma_addr_t unmap_addr = buffer->dma_addr - buffer->dma_offset;
+		if (buffer->flags & EF4_TX_BUF_MAP_SINGLE)
+			dma_unmap_single(dma_dev, unmap_addr, buffer->unmap_len,
+					 DMA_TO_DEVICE);
+		else
+			dma_unmap_page(dma_dev, unmap_addr, buffer->unmap_len,
+				       DMA_TO_DEVICE);
+		buffer->unmap_len = 0;
+	}
+
+	if (buffer->flags & EF4_TX_BUF_SKB) {
+		(*pkts_compl)++;
+		(*bytes_compl) += buffer->skb->len;
+		dev_consume_skb_any((struct sk_buff *)buffer->skb);
+		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
+			   "TX queue %d transmission id %x complete\n",
+			   tx_queue->queue, tx_queue->read_count);
+	}
+
+	buffer->len = 0;
+	buffer->flags = 0;
+}
+
+unsigned int ef4_tx_max_skb_descs(struct ef4_nic *efx)
+{
+	/* This is probably too much since we don't have any TSO support;
+	 * it's a left-over from when we had Software TSO.  But it's safer
+	 * to leave it as-is than try to determine a new bound.
+	 */
+	/* Header and payload descriptor for each output segment, plus
+	 * one for every input fragment boundary within a segment
+	 */
+	unsigned int max_descs = EF4_TSO_MAX_SEGS * 2 + MAX_SKB_FRAGS;
+
+	/* Possibly one more per segment for the alignment workaround,
+	 * or for option descriptors
+	 */
+	if (EF4_WORKAROUND_5391(efx))
+		max_descs += EF4_TSO_MAX_SEGS;
+
+	/* Possibly more for PCIe page boundaries within input fragments */
+	if (PAGE_SIZE > EF4_PAGE_SIZE)
+		max_descs += max_t(unsigned int, MAX_SKB_FRAGS,
+				   DIV_ROUND_UP(GSO_MAX_SIZE, EF4_PAGE_SIZE));
+
+	return max_descs;
+}
+
+static void ef4_tx_maybe_stop_queue(struct ef4_tx_queue *txq1)
+{
+	/* We need to consider both queues that the net core sees as one */
+	struct ef4_tx_queue *txq2 = ef4_tx_queue_partner(txq1);
+	struct ef4_nic *efx = txq1->efx;
+	unsigned int fill_level;
+
+	fill_level = max(txq1->insert_count - txq1->old_read_count,
+			 txq2->insert_count - txq2->old_read_count);
+	if (likely(fill_level < efx->txq_stop_thresh))
+		return;
+
+	/* We used the stale old_read_count above, which gives us a
+	 * pessimistic estimate of the fill level (which may even
+	 * validly be >= efx->txq_entries).  Now try again using
+	 * read_count (more likely to be a cache miss).
+	 *
+	 * If we read read_count and then conditionally stop the
+	 * queue, it is possible for the completion path to race with
+	 * us and complete all outstanding descriptors in the middle,
+	 * after which there will be no more completions to wake it.
+	 * Therefore we stop the queue first, then read read_count
+	 * (with a memory barrier to ensure the ordering), then
+	 * restart the queue if the fill level turns out to be low
+	 * enough.
+	 */
+	netif_tx_stop_queue(txq1->core_txq);
+	smp_mb();
+	txq1->old_read_count = ACCESS_ONCE(txq1->read_count);
+	txq2->old_read_count = ACCESS_ONCE(txq2->read_count);
+
+	fill_level = max(txq1->insert_count - txq1->old_read_count,
+			 txq2->insert_count - txq2->old_read_count);
+	EF4_BUG_ON_PARANOID(fill_level >= efx->txq_entries);
+	if (likely(fill_level < efx->txq_stop_thresh)) {
+		smp_mb();
+		if (likely(!efx->loopback_selftest))
+			netif_tx_start_queue(txq1->core_txq);
+	}
+}
+
+static int ef4_enqueue_skb_copy(struct ef4_tx_queue *tx_queue,
+				struct sk_buff *skb)
+{
+	unsigned int min_len = tx_queue->tx_min_size;
+	unsigned int copy_len = skb->len;
+	struct ef4_tx_buffer *buffer;
+	u8 *copy_buffer;
+	int rc;
+
+	EF4_BUG_ON_PARANOID(copy_len > EF4_TX_CB_SIZE);
+
+	buffer = ef4_tx_queue_get_insert_buffer(tx_queue);
+
+	copy_buffer = ef4_tx_get_copy_buffer(tx_queue, buffer);
+	if (unlikely(!copy_buffer))
+		return -ENOMEM;
+
+	rc = skb_copy_bits(skb, 0, copy_buffer, copy_len);
+	EF4_WARN_ON_PARANOID(rc);
+	if (unlikely(copy_len < min_len)) {
+		memset(copy_buffer + copy_len, 0, min_len - copy_len);
+		buffer->len = min_len;
+	} else {
+		buffer->len = copy_len;
+	}
+
+	buffer->skb = skb;
+	buffer->flags = EF4_TX_BUF_SKB;
+
+	++tx_queue->insert_count;
+	return rc;
+}
+
+static struct ef4_tx_buffer *ef4_tx_map_chunk(struct ef4_tx_queue *tx_queue,
+					      dma_addr_t dma_addr,
+					      size_t len)
+{
+	const struct ef4_nic_type *nic_type = tx_queue->efx->type;
+	struct ef4_tx_buffer *buffer;
+	unsigned int dma_len;
+
+	/* Map the fragment taking account of NIC-dependent DMA limits. */
+	do {
+		buffer = ef4_tx_queue_get_insert_buffer(tx_queue);
+		dma_len = nic_type->tx_limit_len(tx_queue, dma_addr, len);
+
+		buffer->len = dma_len;
+		buffer->dma_addr = dma_addr;
+		buffer->flags = EF4_TX_BUF_CONT;
+		len -= dma_len;
+		dma_addr += dma_len;
+		++tx_queue->insert_count;
+	} while (len);
+
+	return buffer;
+}
+
+/* Map all data from an SKB for DMA and create descriptors on the queue.
+ */
+static int ef4_tx_map_data(struct ef4_tx_queue *tx_queue, struct sk_buff *skb)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	struct device *dma_dev = &efx->pci_dev->dev;
+	unsigned int frag_index, nr_frags;
+	dma_addr_t dma_addr, unmap_addr;
+	unsigned short dma_flags;
+	size_t len, unmap_len;
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	frag_index = 0;
+
+	/* Map header data. */
+	len = skb_headlen(skb);
+	dma_addr = dma_map_single(dma_dev, skb->data, len, DMA_TO_DEVICE);
+	dma_flags = EF4_TX_BUF_MAP_SINGLE;
+	unmap_len = len;
+	unmap_addr = dma_addr;
+
+	if (unlikely(dma_mapping_error(dma_dev, dma_addr)))
+		return -EIO;
+
+	/* Add descriptors for each fragment. */
+	do {
+		struct ef4_tx_buffer *buffer;
+		skb_frag_t *fragment;
+
+		buffer = ef4_tx_map_chunk(tx_queue, dma_addr, len);
+
+		/* The final descriptor for a fragment is responsible for
+		 * unmapping the whole fragment.
+		 */
+		buffer->flags = EF4_TX_BUF_CONT | dma_flags;
+		buffer->unmap_len = unmap_len;
+		buffer->dma_offset = buffer->dma_addr - unmap_addr;
+
+		if (frag_index >= nr_frags) {
+			/* Store SKB details with the final buffer for
+			 * the completion.
+			 */
+			buffer->skb = skb;
+			buffer->flags = EF4_TX_BUF_SKB | dma_flags;
+			return 0;
+		}
+
+		/* Move on to the next fragment. */
+		fragment = &skb_shinfo(skb)->frags[frag_index++];
+		len = skb_frag_size(fragment);
+		dma_addr = skb_frag_dma_map(dma_dev, fragment,
+				0, len, DMA_TO_DEVICE);
+		dma_flags = 0;
+		unmap_len = len;
+		unmap_addr = dma_addr;
+
+		if (unlikely(dma_mapping_error(dma_dev, dma_addr)))
+			return -EIO;
+	} while (1);
+}
+
+/* Remove buffers put into a tx_queue.  None of the buffers must have
+ * an skb attached.
+ */
+static void ef4_enqueue_unwind(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_tx_buffer *buffer;
+
+	/* Work backwards until we hit the original insert pointer value */
+	while (tx_queue->insert_count != tx_queue->write_count) {
+		--tx_queue->insert_count;
+		buffer = __ef4_tx_queue_get_insert_buffer(tx_queue);
+		ef4_dequeue_buffer(tx_queue, buffer, NULL, NULL);
+	}
+}
+
+/*
+ * Add a socket buffer to a TX queue
+ *
+ * This maps all fragments of a socket buffer for DMA and adds them to
+ * the TX queue.  The queue's insert pointer will be incremented by
+ * the number of fragments in the socket buffer.
+ *
+ * If any DMA mapping fails, any mapped fragments will be unmapped,
+ * the queue's insert pointer will be restored to its original value.
+ *
+ * This function is split out from ef4_hard_start_xmit to allow the
+ * loopback test to direct packets via specific TX queues.
+ *
+ * Returns NETDEV_TX_OK.
+ * You must hold netif_tx_lock() to call this function.
+ */
+netdev_tx_t ef4_enqueue_skb(struct ef4_tx_queue *tx_queue, struct sk_buff *skb)
+{
+	bool data_mapped = false;
+	unsigned int skb_len;
+
+	skb_len = skb->len;
+	EF4_WARN_ON_PARANOID(skb_is_gso(skb));
+
+	if (skb_len < tx_queue->tx_min_size ||
+			(skb->data_len && skb_len <= EF4_TX_CB_SIZE)) {
+		/* Pad short packets or coalesce short fragmented packets. */
+		if (ef4_enqueue_skb_copy(tx_queue, skb))
+			goto err;
+		tx_queue->cb_packets++;
+		data_mapped = true;
+	}
+
+	/* Map for DMA and create descriptors if we haven't done so already. */
+	if (!data_mapped && (ef4_tx_map_data(tx_queue, skb)))
+		goto err;
+
+	/* Update BQL */
+	netdev_tx_sent_queue(tx_queue->core_txq, skb_len);
+
+	/* Pass off to hardware */
+	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq)) {
+		struct ef4_tx_queue *txq2 = ef4_tx_queue_partner(tx_queue);
+
+		/* There could be packets left on the partner queue if those
+		 * SKBs had skb->xmit_more set. If we do not push those they
+		 * could be left for a long time and cause a netdev watchdog.
+		 */
+		if (txq2->xmit_more_available)
+			ef4_nic_push_buffers(txq2);
+
+		ef4_nic_push_buffers(tx_queue);
+	} else {
+		tx_queue->xmit_more_available = skb->xmit_more;
+	}
+
+	tx_queue->tx_packets++;
+
+	ef4_tx_maybe_stop_queue(tx_queue);
+
+	return NETDEV_TX_OK;
+
+
+err:
+	ef4_enqueue_unwind(tx_queue);
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+/* Remove packets from the TX queue
+ *
+ * This removes packets from the TX queue, up to and including the
+ * specified index.
+ */
+static void ef4_dequeue_buffers(struct ef4_tx_queue *tx_queue,
+				unsigned int index,
+				unsigned int *pkts_compl,
+				unsigned int *bytes_compl)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	unsigned int stop_index, read_ptr;
+
+	stop_index = (index + 1) & tx_queue->ptr_mask;
+	read_ptr = tx_queue->read_count & tx_queue->ptr_mask;
+
+	while (read_ptr != stop_index) {
+		struct ef4_tx_buffer *buffer = &tx_queue->buffer[read_ptr];
+
+		if (!(buffer->flags & EF4_TX_BUF_OPTION) &&
+		    unlikely(buffer->len == 0)) {
+			netif_err(efx, tx_err, efx->net_dev,
+				  "TX queue %d spurious TX completion id %x\n",
+				  tx_queue->queue, read_ptr);
+			ef4_schedule_reset(efx, RESET_TYPE_TX_SKIP);
+			return;
+		}
+
+		ef4_dequeue_buffer(tx_queue, buffer, pkts_compl, bytes_compl);
+
+		++tx_queue->read_count;
+		read_ptr = tx_queue->read_count & tx_queue->ptr_mask;
+	}
+}
+
+/* Initiate a packet transmission.  We use one channel per CPU
+ * (sharing when we have more CPUs than channels).  On Falcon, the TX
+ * completion events will be directed back to the CPU that transmitted
+ * the packet, which should be cache-efficient.
+ *
+ * Context: non-blocking.
+ * Note that returning anything other than NETDEV_TX_OK will cause the
+ * OS to free the skb.
+ */
+netdev_tx_t ef4_hard_start_xmit(struct sk_buff *skb,
+				struct net_device *net_dev)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct ef4_tx_queue *tx_queue;
+	unsigned index, type;
+
+	EF4_WARN_ON_PARANOID(!netif_device_present(net_dev));
+
+	index = skb_get_queue_mapping(skb);
+	type = skb->ip_summed == CHECKSUM_PARTIAL ? EF4_TXQ_TYPE_OFFLOAD : 0;
+	if (index >= efx->n_tx_channels) {
+		index -= efx->n_tx_channels;
+		type |= EF4_TXQ_TYPE_HIGHPRI;
+	}
+	tx_queue = ef4_get_tx_queue(efx, index, type);
+
+	return ef4_enqueue_skb(tx_queue, skb);
+}
+
+void ef4_init_tx_queue_core_txq(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+
+	/* Must be inverse of queue lookup in ef4_hard_start_xmit() */
+	tx_queue->core_txq =
+		netdev_get_tx_queue(efx->net_dev,
+				    tx_queue->queue / EF4_TXQ_TYPES +
+				    ((tx_queue->queue & EF4_TXQ_TYPE_HIGHPRI) ?
+				     efx->n_tx_channels : 0));
+}
+
+int ef4_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
+		 struct tc_to_netdev *ntc)
+{
+	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct ef4_channel *channel;
+	struct ef4_tx_queue *tx_queue;
+	unsigned tc, num_tc;
+	int rc;
+
+	if (ntc->type != TC_SETUP_MQPRIO)
+		return -EINVAL;
+
+	num_tc = ntc->tc;
+
+	if (ef4_nic_rev(efx) < EF4_REV_FALCON_B0 || num_tc > EF4_MAX_TX_TC)
+		return -EINVAL;
+
+	if (num_tc == net_dev->num_tc)
+		return 0;
+
+	for (tc = 0; tc < num_tc; tc++) {
+		net_dev->tc_to_txq[tc].offset = tc * efx->n_tx_channels;
+		net_dev->tc_to_txq[tc].count = efx->n_tx_channels;
+	}
+
+	if (num_tc > net_dev->num_tc) {
+		/* Initialise high-priority queues as necessary */
+		ef4_for_each_channel(channel, efx) {
+			ef4_for_each_possible_channel_tx_queue(tx_queue,
+							       channel) {
+				if (!(tx_queue->queue & EF4_TXQ_TYPE_HIGHPRI))
+					continue;
+				if (!tx_queue->buffer) {
+					rc = ef4_probe_tx_queue(tx_queue);
+					if (rc)
+						return rc;
+				}
+				if (!tx_queue->initialised)
+					ef4_init_tx_queue(tx_queue);
+				ef4_init_tx_queue_core_txq(tx_queue);
+			}
+		}
+	} else {
+		/* Reduce number of classes before number of queues */
+		net_dev->num_tc = num_tc;
+	}
+
+	rc = netif_set_real_num_tx_queues(net_dev,
+					  max_t(int, num_tc, 1) *
+					  efx->n_tx_channels);
+	if (rc)
+		return rc;
+
+	/* Do not destroy high-priority queues when they become
+	 * unused.  We would have to flush them first, and it is
+	 * fairly difficult to flush a subset of TX queues.  Leave
+	 * it to ef4_fini_channels().
+	 */
+
+	net_dev->num_tc = num_tc;
+	return 0;
+}
+
+void ef4_xmit_done(struct ef4_tx_queue *tx_queue, unsigned int index)
+{
+	unsigned fill_level;
+	struct ef4_nic *efx = tx_queue->efx;
+	struct ef4_tx_queue *txq2;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
+
+	EF4_BUG_ON_PARANOID(index > tx_queue->ptr_mask);
+
+	ef4_dequeue_buffers(tx_queue, index, &pkts_compl, &bytes_compl);
+	tx_queue->pkts_compl += pkts_compl;
+	tx_queue->bytes_compl += bytes_compl;
+
+	if (pkts_compl > 1)
+		++tx_queue->merge_events;
+
+	/* See if we need to restart the netif queue.  This memory
+	 * barrier ensures that we write read_count (inside
+	 * ef4_dequeue_buffers()) before reading the queue status.
+	 */
+	smp_mb();
+	if (unlikely(netif_tx_queue_stopped(tx_queue->core_txq)) &&
+	    likely(efx->port_enabled) &&
+	    likely(netif_device_present(efx->net_dev))) {
+		txq2 = ef4_tx_queue_partner(tx_queue);
+		fill_level = max(tx_queue->insert_count - tx_queue->read_count,
+				 txq2->insert_count - txq2->read_count);
+		if (fill_level <= efx->txq_wake_thresh)
+			netif_tx_wake_queue(tx_queue->core_txq);
+	}
+
+	/* Check whether the hardware queue is now empty */
+	if ((int)(tx_queue->read_count - tx_queue->old_write_count) >= 0) {
+		tx_queue->old_write_count = ACCESS_ONCE(tx_queue->write_count);
+		if (tx_queue->read_count == tx_queue->old_write_count) {
+			smp_mb();
+			tx_queue->empty_read_count =
+				tx_queue->read_count | EF4_EMPTY_COUNT_VALID;
+		}
+	}
+}
+
+static unsigned int ef4_tx_cb_page_count(struct ef4_tx_queue *tx_queue)
+{
+	return DIV_ROUND_UP(tx_queue->ptr_mask + 1, PAGE_SIZE >> EF4_TX_CB_ORDER);
+}
+
+int ef4_probe_tx_queue(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+	unsigned int entries;
+	int rc;
+
+	/* Create the smallest power-of-two aligned ring */
+	entries = max(roundup_pow_of_two(efx->txq_entries), EF4_MIN_DMAQ_SIZE);
+	EF4_BUG_ON_PARANOID(entries > EF4_MAX_DMAQ_SIZE);
+	tx_queue->ptr_mask = entries - 1;
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "creating TX queue %d size %#x mask %#x\n",
+		  tx_queue->queue, efx->txq_entries, tx_queue->ptr_mask);
+
+	/* Allocate software ring */
+	tx_queue->buffer = kcalloc(entries, sizeof(*tx_queue->buffer),
+				   GFP_KERNEL);
+	if (!tx_queue->buffer)
+		return -ENOMEM;
+
+	tx_queue->cb_page = kcalloc(ef4_tx_cb_page_count(tx_queue),
+				    sizeof(tx_queue->cb_page[0]), GFP_KERNEL);
+	if (!tx_queue->cb_page) {
+		rc = -ENOMEM;
+		goto fail1;
+	}
+
+	/* Allocate hardware ring */
+	rc = ef4_nic_probe_tx(tx_queue);
+	if (rc)
+		goto fail2;
+
+	return 0;
+
+fail2:
+	kfree(tx_queue->cb_page);
+	tx_queue->cb_page = NULL;
+fail1:
+	kfree(tx_queue->buffer);
+	tx_queue->buffer = NULL;
+	return rc;
+}
+
+void ef4_init_tx_queue(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_nic *efx = tx_queue->efx;
+
+	netif_dbg(efx, drv, efx->net_dev,
+		  "initialising TX queue %d\n", tx_queue->queue);
+
+	tx_queue->insert_count = 0;
+	tx_queue->write_count = 0;
+	tx_queue->old_write_count = 0;
+	tx_queue->read_count = 0;
+	tx_queue->old_read_count = 0;
+	tx_queue->empty_read_count = 0 | EF4_EMPTY_COUNT_VALID;
+	tx_queue->xmit_more_available = false;
+
+	/* Some older hardware requires Tx writes larger than 32. */
+	tx_queue->tx_min_size = EF4_WORKAROUND_15592(efx) ? 33 : 0;
+
+	/* Set up TX descriptor ring */
+	ef4_nic_init_tx(tx_queue);
+
+	tx_queue->initialised = true;
+}
+
+void ef4_fini_tx_queue(struct ef4_tx_queue *tx_queue)
+{
+	struct ef4_tx_buffer *buffer;
+
+	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
+		  "shutting down TX queue %d\n", tx_queue->queue);
+
+	if (!tx_queue->buffer)
+		return;
+
+	/* Free any buffers left in the ring */
+	while (tx_queue->read_count != tx_queue->write_count) {
+		unsigned int pkts_compl = 0, bytes_compl = 0;
+		buffer = &tx_queue->buffer[tx_queue->read_count & tx_queue->ptr_mask];
+		ef4_dequeue_buffer(tx_queue, buffer, &pkts_compl, &bytes_compl);
+
+		++tx_queue->read_count;
+	}
+	tx_queue->xmit_more_available = false;
+	netdev_tx_reset_queue(tx_queue->core_txq);
+}
+
+void ef4_remove_tx_queue(struct ef4_tx_queue *tx_queue)
+{
+	int i;
+
+	if (!tx_queue->buffer)
+		return;
+
+	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
+		  "destroying TX queue %d\n", tx_queue->queue);
+	ef4_nic_remove_tx(tx_queue);
+
+	if (tx_queue->cb_page) {
+		for (i = 0; i < ef4_tx_cb_page_count(tx_queue); i++)
+			ef4_nic_free_buffer(tx_queue->efx,
+					    &tx_queue->cb_page[i]);
+		kfree(tx_queue->cb_page);
+		tx_queue->cb_page = NULL;
+	}
+
+	kfree(tx_queue->buffer);
+	tx_queue->buffer = NULL;
+}
diff --git a/drivers/net/ethernet/sfc/falcon/tx.h b/drivers/net/ethernet/sfc/falcon/tx.h
new file mode 100644
index 0000000..a607eb0
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/tx.h
@@ -0,0 +1,27 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_TX_H
+#define EF4_TX_H
+
+#include <linux/types.h>
+
+/* Driver internal tx-path related declarations. */
+
+unsigned int ef4_tx_limit_len(struct ef4_tx_queue *tx_queue,
+			      dma_addr_t dma_addr, unsigned int len);
+
+u8 *ef4_tx_get_copy_buffer_limited(struct ef4_tx_queue *tx_queue,
+				   struct ef4_tx_buffer *buffer, size_t len);
+
+int ef4_enqueue_skb_tso(struct ef4_tx_queue *tx_queue, struct sk_buff *skb,
+			bool *data_mapped);
+
+#endif /* EF4_TX_H */
diff --git a/drivers/net/ethernet/sfc/falcon/txc43128_phy.c b/drivers/net/ethernet/sfc/falcon/txc43128_phy.c
new file mode 100644
index 0000000..18421f5
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/txc43128_phy.c
@@ -0,0 +1,560 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2006-2011 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+/*
+ * Driver for Transwitch/Mysticom CX4 retimer
+ * see www.transwitch.com, part is TXC-43128
+ */
+
+#include <linux/delay.h>
+#include <linux/slab.h>
+#include "efx.h"
+#include "mdio_10g.h"
+#include "phy.h"
+#include "nic.h"
+
+/* We expect these MMDs to be in the package */
+#define TXC_REQUIRED_DEVS (MDIO_DEVS_PCS |	\
+			   MDIO_DEVS_PMAPMD |	\
+			   MDIO_DEVS_PHYXS)
+
+#define TXC_LOOPBACKS ((1 << LOOPBACK_PCS) |	\
+		       (1 << LOOPBACK_PMAPMD) |	\
+		       (1 << LOOPBACK_PHYXS_WS))
+
+/**************************************************************************
+ *
+ * Compile-time config
+ *
+ **************************************************************************
+ */
+#define TXCNAME "TXC43128"
+/* Total length of time we'll wait for the PHY to come out of reset (ms) */
+#define TXC_MAX_RESET_TIME	500
+/* Interval between checks (ms) */
+#define TXC_RESET_WAIT		10
+/* How long to run BIST (us) */
+#define TXC_BIST_DURATION	50
+
+/**************************************************************************
+ *
+ * Register definitions
+ *
+ **************************************************************************
+ */
+
+/* Command register */
+#define TXC_GLRGS_GLCMD		0xc004
+/* Useful bits in command register */
+/* Lane power-down */
+#define TXC_GLCMD_L01PD_LBN	5
+#define TXC_GLCMD_L23PD_LBN	6
+/* Limited SW reset: preserves configuration but
+ * initiates a logic reset. Self-clearing */
+#define TXC_GLCMD_LMTSWRST_LBN	14
+
+/* Signal Quality Control */
+#define TXC_GLRGS_GSGQLCTL	0xc01a
+/* Enable bit */
+#define TXC_GSGQLCT_SGQLEN_LBN	15
+/* Lane selection */
+#define TXC_GSGQLCT_LNSL_LBN	13
+#define TXC_GSGQLCT_LNSL_WIDTH	2
+
+/* Analog TX control */
+#define TXC_ALRGS_ATXCTL	0xc040
+/* Lane power-down */
+#define TXC_ATXCTL_TXPD3_LBN	15
+#define TXC_ATXCTL_TXPD2_LBN	14
+#define TXC_ATXCTL_TXPD1_LBN	13
+#define TXC_ATXCTL_TXPD0_LBN	12
+
+/* Amplitude on lanes 0, 1 */
+#define TXC_ALRGS_ATXAMP0	0xc041
+/* Amplitude on lanes 2, 3 */
+#define TXC_ALRGS_ATXAMP1	0xc042
+/* Bit position of value for lane 0 (or 2) */
+#define TXC_ATXAMP_LANE02_LBN	3
+/* Bit position of value for lane 1 (or 3) */
+#define TXC_ATXAMP_LANE13_LBN	11
+
+#define TXC_ATXAMP_1280_mV	0
+#define TXC_ATXAMP_1200_mV	8
+#define TXC_ATXAMP_1120_mV	12
+#define TXC_ATXAMP_1060_mV	14
+#define TXC_ATXAMP_0820_mV	25
+#define TXC_ATXAMP_0720_mV	26
+#define TXC_ATXAMP_0580_mV	27
+#define TXC_ATXAMP_0440_mV	28
+
+#define TXC_ATXAMP_0820_BOTH					\
+	((TXC_ATXAMP_0820_mV << TXC_ATXAMP_LANE02_LBN)		\
+	 | (TXC_ATXAMP_0820_mV << TXC_ATXAMP_LANE13_LBN))
+
+#define TXC_ATXAMP_DEFAULT	0x6060 /* From databook */
+
+/* Preemphasis on lanes 0, 1 */
+#define TXC_ALRGS_ATXPRE0	0xc043
+/* Preemphasis on lanes 2, 3 */
+#define TXC_ALRGS_ATXPRE1	0xc044
+
+#define TXC_ATXPRE_NONE 0
+#define TXC_ATXPRE_DEFAULT	0x1010 /* From databook */
+
+#define TXC_ALRGS_ARXCTL	0xc045
+/* Lane power-down */
+#define TXC_ARXCTL_RXPD3_LBN	15
+#define TXC_ARXCTL_RXPD2_LBN	14
+#define TXC_ARXCTL_RXPD1_LBN	13
+#define TXC_ARXCTL_RXPD0_LBN	12
+
+/* Main control */
+#define TXC_MRGS_CTL		0xc340
+/* Bits in main control */
+#define TXC_MCTL_RESET_LBN	15	/* Self clear */
+#define TXC_MCTL_TXLED_LBN	14	/* 1 to show align status */
+#define TXC_MCTL_RXLED_LBN	13	/* 1 to show align status */
+
+/* GPIO output */
+#define TXC_GPIO_OUTPUT		0xc346
+#define TXC_GPIO_DIR		0xc348
+
+/* Vendor-specific BIST registers */
+#define TXC_BIST_CTL		0xc280
+#define TXC_BIST_TXFRMCNT	0xc281
+#define TXC_BIST_RX0FRMCNT	0xc282
+#define TXC_BIST_RX1FRMCNT	0xc283
+#define TXC_BIST_RX2FRMCNT	0xc284
+#define TXC_BIST_RX3FRMCNT	0xc285
+#define TXC_BIST_RX0ERRCNT	0xc286
+#define TXC_BIST_RX1ERRCNT	0xc287
+#define TXC_BIST_RX2ERRCNT	0xc288
+#define TXC_BIST_RX3ERRCNT	0xc289
+
+/* BIST type (controls bit patter in test) */
+#define TXC_BIST_CTRL_TYPE_LBN	10
+#define TXC_BIST_CTRL_TYPE_TSD	0	/* TranSwitch Deterministic */
+#define TXC_BIST_CTRL_TYPE_CRP	1	/* CRPAT standard */
+#define TXC_BIST_CTRL_TYPE_CJP	2	/* CJPAT standard */
+#define TXC_BIST_CTRL_TYPE_TSR	3	/* TranSwitch pseudo-random */
+/* Set this to 1 for 10 bit and 0 for 8 bit */
+#define TXC_BIST_CTRL_B10EN_LBN	12
+/* Enable BIST (write 0 to disable) */
+#define TXC_BIST_CTRL_ENAB_LBN	13
+/* Stop BIST (self-clears when stop complete) */
+#define TXC_BIST_CTRL_STOP_LBN	14
+/* Start BIST (cleared by writing 1 to STOP) */
+#define TXC_BIST_CTRL_STRT_LBN	15
+
+/* Mt. Diablo test configuration */
+#define TXC_MTDIABLO_CTRL	0xc34f
+#define TXC_MTDIABLO_CTRL_PMA_LOOP_LBN	10
+
+struct txc43128_data {
+	unsigned long bug10934_timer;
+	enum ef4_phy_mode phy_mode;
+	enum ef4_loopback_mode loopback_mode;
+};
+
+/* The PHY sometimes needs a reset to bring the link back up.  So long as
+ * it reports link down, we reset it every 5 seconds.
+ */
+#define BUG10934_RESET_INTERVAL (5 * HZ)
+
+/* Perform a reset that doesn't clear configuration changes */
+static void txc_reset_logic(struct ef4_nic *efx);
+
+/* Set the output value of a gpio */
+void falcon_txc_set_gpio_val(struct ef4_nic *efx, int pin, int on)
+{
+	ef4_mdio_set_flag(efx, MDIO_MMD_PHYXS, TXC_GPIO_OUTPUT, 1 << pin, on);
+}
+
+/* Set up the GPIO direction register */
+void falcon_txc_set_gpio_dir(struct ef4_nic *efx, int pin, int dir)
+{
+	ef4_mdio_set_flag(efx, MDIO_MMD_PHYXS, TXC_GPIO_DIR, 1 << pin, dir);
+}
+
+/* Reset the PMA/PMD MMD. The documentation is explicit that this does a
+ * global reset (it's less clear what reset of other MMDs does).*/
+static int txc_reset_phy(struct ef4_nic *efx)
+{
+	int rc = ef4_mdio_reset_mmd(efx, MDIO_MMD_PMAPMD,
+				    TXC_MAX_RESET_TIME / TXC_RESET_WAIT,
+				    TXC_RESET_WAIT);
+	if (rc < 0)
+		goto fail;
+
+	/* Check that all the MMDs we expect are present and responding. */
+	rc = ef4_mdio_check_mmds(efx, TXC_REQUIRED_DEVS);
+	if (rc < 0)
+		goto fail;
+
+	return 0;
+
+fail:
+	netif_err(efx, hw, efx->net_dev, TXCNAME ": reset timed out!\n");
+	return rc;
+}
+
+/* Run a single BIST on one MMD */
+static int txc_bist_one(struct ef4_nic *efx, int mmd, int test)
+{
+	int ctrl, bctl;
+	int lane;
+	int rc = 0;
+
+	/* Set PMA to test into loopback using Mt Diablo reg as per app note */
+	ctrl = ef4_mdio_read(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL);
+	ctrl |= (1 << TXC_MTDIABLO_CTRL_PMA_LOOP_LBN);
+	ef4_mdio_write(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL, ctrl);
+
+	/* The BIST app. note lists these  as 3 distinct steps. */
+	/* Set the BIST type */
+	bctl = (test << TXC_BIST_CTRL_TYPE_LBN);
+	ef4_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
+
+	/* Set the BSTEN bit in the BIST Control register to enable */
+	bctl |= (1 << TXC_BIST_CTRL_ENAB_LBN);
+	ef4_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
+
+	/* Set the BSTRT bit in the BIST Control register */
+	ef4_mdio_write(efx, mmd, TXC_BIST_CTL,
+		       bctl | (1 << TXC_BIST_CTRL_STRT_LBN));
+
+	/* Wait. */
+	udelay(TXC_BIST_DURATION);
+
+	/* Set the BSTOP bit in the BIST Control register */
+	bctl |= (1 << TXC_BIST_CTRL_STOP_LBN);
+	ef4_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
+
+	/* The STOP bit should go off when things have stopped */
+	while (bctl & (1 << TXC_BIST_CTRL_STOP_LBN))
+		bctl = ef4_mdio_read(efx, mmd, TXC_BIST_CTL);
+
+	/* Check all the error counts are 0 and all the frame counts are
+	   non-zero */
+	for (lane = 0; lane < 4; lane++) {
+		int count = ef4_mdio_read(efx, mmd, TXC_BIST_RX0ERRCNT + lane);
+		if (count != 0) {
+			netif_err(efx, hw, efx->net_dev, TXCNAME": BIST error. "
+				  "Lane %d had %d errs\n", lane, count);
+			rc = -EIO;
+		}
+		count = ef4_mdio_read(efx, mmd, TXC_BIST_RX0FRMCNT + lane);
+		if (count == 0) {
+			netif_err(efx, hw, efx->net_dev, TXCNAME": BIST error. "
+				  "Lane %d got 0 frames\n", lane);
+			rc = -EIO;
+		}
+	}
+
+	if (rc == 0)
+		netif_info(efx, hw, efx->net_dev, TXCNAME": BIST pass\n");
+
+	/* Disable BIST */
+	ef4_mdio_write(efx, mmd, TXC_BIST_CTL, 0);
+
+	/* Turn off loopback */
+	ctrl &= ~(1 << TXC_MTDIABLO_CTRL_PMA_LOOP_LBN);
+	ef4_mdio_write(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL, ctrl);
+
+	return rc;
+}
+
+static int txc_bist(struct ef4_nic *efx)
+{
+	return txc_bist_one(efx, MDIO_MMD_PCS, TXC_BIST_CTRL_TYPE_TSD);
+}
+
+/* Push the non-configurable defaults into the PHY. This must be
+ * done after every full reset */
+static void txc_apply_defaults(struct ef4_nic *efx)
+{
+	int mctrl;
+
+	/* Turn amplitude down and preemphasis off on the host side
+	 * (PHY<->MAC) as this is believed less likely to upset Falcon
+	 * and no adverse effects have been noted. It probably also
+	 * saves a picowatt or two */
+
+	/* Turn off preemphasis */
+	ef4_mdio_write(efx, MDIO_MMD_PHYXS, TXC_ALRGS_ATXPRE0, TXC_ATXPRE_NONE);
+	ef4_mdio_write(efx, MDIO_MMD_PHYXS, TXC_ALRGS_ATXPRE1, TXC_ATXPRE_NONE);
+
+	/* Turn down the amplitude */
+	ef4_mdio_write(efx, MDIO_MMD_PHYXS,
+		       TXC_ALRGS_ATXAMP0, TXC_ATXAMP_0820_BOTH);
+	ef4_mdio_write(efx, MDIO_MMD_PHYXS,
+		       TXC_ALRGS_ATXAMP1, TXC_ATXAMP_0820_BOTH);
+
+	/* Set the line side amplitude and preemphasis to the databook
+	 * defaults as an erratum causes them to be 0 on at least some
+	 * PHY rev.s */
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXPRE0, TXC_ATXPRE_DEFAULT);
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXPRE1, TXC_ATXPRE_DEFAULT);
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXAMP0, TXC_ATXAMP_DEFAULT);
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXAMP1, TXC_ATXAMP_DEFAULT);
+
+	/* Set up the LEDs  */
+	mctrl = ef4_mdio_read(efx, MDIO_MMD_PHYXS, TXC_MRGS_CTL);
+
+	/* Set the Green and Red LEDs to their default modes */
+	mctrl &= ~((1 << TXC_MCTL_TXLED_LBN) | (1 << TXC_MCTL_RXLED_LBN));
+	ef4_mdio_write(efx, MDIO_MMD_PHYXS, TXC_MRGS_CTL, mctrl);
+
+	/* Databook recommends doing this after configuration changes */
+	txc_reset_logic(efx);
+
+	falcon_board(efx)->type->init_phy(efx);
+}
+
+static int txc43128_phy_probe(struct ef4_nic *efx)
+{
+	struct txc43128_data *phy_data;
+
+	/* Allocate phy private storage */
+	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
+	if (!phy_data)
+		return -ENOMEM;
+	efx->phy_data = phy_data;
+	phy_data->phy_mode = efx->phy_mode;
+
+	efx->mdio.mmds = TXC_REQUIRED_DEVS;
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+
+	efx->loopback_modes = TXC_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
+
+	return 0;
+}
+
+/* Initialisation entry point for this PHY driver */
+static int txc43128_phy_init(struct ef4_nic *efx)
+{
+	int rc;
+
+	rc = txc_reset_phy(efx);
+	if (rc < 0)
+		return rc;
+
+	rc = txc_bist(efx);
+	if (rc < 0)
+		return rc;
+
+	txc_apply_defaults(efx);
+
+	return 0;
+}
+
+/* Set the lane power down state in the global registers */
+static void txc_glrgs_lane_power(struct ef4_nic *efx, int mmd)
+{
+	int pd = (1 << TXC_GLCMD_L01PD_LBN) | (1 << TXC_GLCMD_L23PD_LBN);
+	int ctl = ef4_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
+
+	if (!(efx->phy_mode & PHY_MODE_LOW_POWER))
+		ctl &= ~pd;
+	else
+		ctl |= pd;
+
+	ef4_mdio_write(efx, mmd, TXC_GLRGS_GLCMD, ctl);
+}
+
+/* Set the lane power down state in the analog control registers */
+static void txc_analog_lane_power(struct ef4_nic *efx, int mmd)
+{
+	int txpd = (1 << TXC_ATXCTL_TXPD3_LBN) | (1 << TXC_ATXCTL_TXPD2_LBN)
+		| (1 << TXC_ATXCTL_TXPD1_LBN) | (1 << TXC_ATXCTL_TXPD0_LBN);
+	int rxpd = (1 << TXC_ARXCTL_RXPD3_LBN) | (1 << TXC_ARXCTL_RXPD2_LBN)
+		| (1 << TXC_ARXCTL_RXPD1_LBN) | (1 << TXC_ARXCTL_RXPD0_LBN);
+	int txctl = ef4_mdio_read(efx, mmd, TXC_ALRGS_ATXCTL);
+	int rxctl = ef4_mdio_read(efx, mmd, TXC_ALRGS_ARXCTL);
+
+	if (!(efx->phy_mode & PHY_MODE_LOW_POWER)) {
+		txctl &= ~txpd;
+		rxctl &= ~rxpd;
+	} else {
+		txctl |= txpd;
+		rxctl |= rxpd;
+	}
+
+	ef4_mdio_write(efx, mmd, TXC_ALRGS_ATXCTL, txctl);
+	ef4_mdio_write(efx, mmd, TXC_ALRGS_ARXCTL, rxctl);
+}
+
+static void txc_set_power(struct ef4_nic *efx)
+{
+	/* According to the data book, all the MMDs can do low power */
+	ef4_mdio_set_mmds_lpower(efx,
+				 !!(efx->phy_mode & PHY_MODE_LOW_POWER),
+				 TXC_REQUIRED_DEVS);
+
+	/* Global register bank is in PCS, PHY XS. These control the host
+	 * side and line side settings respectively. */
+	txc_glrgs_lane_power(efx, MDIO_MMD_PCS);
+	txc_glrgs_lane_power(efx, MDIO_MMD_PHYXS);
+
+	/* Analog register bank in PMA/PMD, PHY XS */
+	txc_analog_lane_power(efx, MDIO_MMD_PMAPMD);
+	txc_analog_lane_power(efx, MDIO_MMD_PHYXS);
+}
+
+static void txc_reset_logic_mmd(struct ef4_nic *efx, int mmd)
+{
+	int val = ef4_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
+	int tries = 50;
+
+	val |= (1 << TXC_GLCMD_LMTSWRST_LBN);
+	ef4_mdio_write(efx, mmd, TXC_GLRGS_GLCMD, val);
+	while (--tries) {
+		val = ef4_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
+		if (!(val & (1 << TXC_GLCMD_LMTSWRST_LBN)))
+			break;
+		udelay(1);
+	}
+	if (!tries)
+		netif_info(efx, hw, efx->net_dev,
+			   TXCNAME " Logic reset timed out!\n");
+}
+
+/* Perform a logic reset. This preserves the configuration registers
+ * and is needed for some configuration changes to take effect */
+static void txc_reset_logic(struct ef4_nic *efx)
+{
+	/* The data sheet claims we can do the logic reset on either the
+	 * PCS or the PHYXS and the result is a reset of both host- and
+	 * line-side logic. */
+	txc_reset_logic_mmd(efx, MDIO_MMD_PCS);
+}
+
+static bool txc43128_phy_read_link(struct ef4_nic *efx)
+{
+	return ef4_mdio_links_ok(efx, TXC_REQUIRED_DEVS);
+}
+
+static int txc43128_phy_reconfigure(struct ef4_nic *efx)
+{
+	struct txc43128_data *phy_data = efx->phy_data;
+	enum ef4_phy_mode mode_change = efx->phy_mode ^ phy_data->phy_mode;
+	bool loop_change = LOOPBACK_CHANGED(phy_data, efx, TXC_LOOPBACKS);
+
+	if (efx->phy_mode & mode_change & PHY_MODE_TX_DISABLED) {
+		txc_reset_phy(efx);
+		txc_apply_defaults(efx);
+		falcon_reset_xaui(efx);
+		mode_change &= ~PHY_MODE_TX_DISABLED;
+	}
+
+	ef4_mdio_transmit_disable(efx);
+	ef4_mdio_phy_reconfigure(efx);
+	if (mode_change & PHY_MODE_LOW_POWER)
+		txc_set_power(efx);
+
+	/* The data sheet claims this is required after every reconfiguration
+	 * (note at end of 7.1), but we mustn't do it when nothing changes as
+	 * it glitches the link, and reconfigure gets called on link change,
+	 * so we get an IRQ storm on link up. */
+	if (loop_change || mode_change)
+		txc_reset_logic(efx);
+
+	phy_data->phy_mode = efx->phy_mode;
+	phy_data->loopback_mode = efx->loopback_mode;
+
+	return 0;
+}
+
+static void txc43128_phy_fini(struct ef4_nic *efx)
+{
+	/* Disable link events */
+	ef4_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL, 0);
+}
+
+static void txc43128_phy_remove(struct ef4_nic *efx)
+{
+	kfree(efx->phy_data);
+	efx->phy_data = NULL;
+}
+
+/* Periodic callback: this exists mainly to poll link status as we
+ * don't use LASI interrupts */
+static bool txc43128_phy_poll(struct ef4_nic *efx)
+{
+	struct txc43128_data *data = efx->phy_data;
+	bool was_up = efx->link_state.up;
+
+	efx->link_state.up = txc43128_phy_read_link(efx);
+	efx->link_state.speed = 10000;
+	efx->link_state.fd = true;
+	efx->link_state.fc = efx->wanted_fc;
+
+	if (efx->link_state.up || (efx->loopback_mode != LOOPBACK_NONE)) {
+		data->bug10934_timer = jiffies;
+	} else {
+		if (time_after_eq(jiffies, (data->bug10934_timer +
+					    BUG10934_RESET_INTERVAL))) {
+			data->bug10934_timer = jiffies;
+			txc_reset_logic(efx);
+		}
+	}
+
+	return efx->link_state.up != was_up;
+}
+
+static const char *const txc43128_test_names[] = {
+	"bist"
+};
+
+static const char *txc43128_test_name(struct ef4_nic *efx, unsigned int index)
+{
+	if (index < ARRAY_SIZE(txc43128_test_names))
+		return txc43128_test_names[index];
+	return NULL;
+}
+
+static int txc43128_run_tests(struct ef4_nic *efx, int *results, unsigned flags)
+{
+	int rc;
+
+	if (!(flags & ETH_TEST_FL_OFFLINE))
+		return 0;
+
+	rc = txc_reset_phy(efx);
+	if (rc < 0)
+		return rc;
+
+	rc = txc_bist(efx);
+	txc_apply_defaults(efx);
+	results[0] = rc ? -1 : 1;
+	return rc;
+}
+
+static void txc43128_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+{
+	mdio45_ethtool_gset(&efx->mdio, ecmd);
+}
+
+const struct ef4_phy_operations falcon_txc_phy_ops = {
+	.probe		= txc43128_phy_probe,
+	.init		= txc43128_phy_init,
+	.reconfigure	= txc43128_phy_reconfigure,
+	.poll		= txc43128_phy_poll,
+	.fini		= txc43128_phy_fini,
+	.remove		= txc43128_phy_remove,
+	.get_settings	= txc43128_get_settings,
+	.set_settings	= ef4_mdio_set_settings,
+	.test_alive	= ef4_mdio_test_alive,
+	.run_tests	= txc43128_run_tests,
+	.test_name	= txc43128_test_name,
+};
diff --git a/drivers/net/ethernet/sfc/falcon/workarounds.h b/drivers/net/ethernet/sfc/falcon/workarounds.h
new file mode 100644
index 0000000..6af800b
--- /dev/null
+++ b/drivers/net/ethernet/sfc/falcon/workarounds.h
@@ -0,0 +1,44 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2006-2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EF4_WORKAROUNDS_H
+#define EF4_WORKAROUNDS_H
+
+/*
+ * Hardware workarounds.
+ * Bug numbers are from Solarflare's Bugzilla.
+ */
+
+#define EF4_WORKAROUND_FALCON_A(efx) (ef4_nic_rev(efx) <= EF4_REV_FALCON_A1)
+#define EF4_WORKAROUND_FALCON_AB(efx) (ef4_nic_rev(efx) <= EF4_REV_FALCON_B0)
+#define EF4_WORKAROUND_10G(efx) 1
+
+/* Bit-bashed I2C reads cause performance drop */
+#define EF4_WORKAROUND_7884 EF4_WORKAROUND_10G
+/* Truncated IPv4 packets can confuse the TX packet parser */
+#define EF4_WORKAROUND_15592 EF4_WORKAROUND_FALCON_AB
+
+/* Spurious parity errors in TSORT buffers */
+#define EF4_WORKAROUND_5129 EF4_WORKAROUND_FALCON_A
+/* Unaligned read request >512 bytes after aligning may break TSORT */
+#define EF4_WORKAROUND_5391 EF4_WORKAROUND_FALCON_A
+/* iSCSI parsing errors */
+#define EF4_WORKAROUND_5583 EF4_WORKAROUND_FALCON_A
+/* RX events go missing */
+#define EF4_WORKAROUND_5676 EF4_WORKAROUND_FALCON_A
+/* RX_RESET on A1 */
+#define EF4_WORKAROUND_6555 EF4_WORKAROUND_FALCON_A
+/* Increase filter depth to avoid RX_RESET */
+#define EF4_WORKAROUND_7244 EF4_WORKAROUND_FALCON_A
+/* Flushes may never complete */
+#define EF4_WORKAROUND_7803 EF4_WORKAROUND_FALCON_AB
+/* Leak overlength packets rather than free */
+#define EF4_WORKAROUND_8071 EF4_WORKAROUND_FALCON_A
+
+#endif /* EF4_WORKAROUNDS_H */
diff --git a/drivers/net/ethernet/sfc/falcon_boards.c b/drivers/net/ethernet/sfc/falcon_boards.c
deleted file mode 100644
index f6883b2..0000000
--- a/drivers/net/ethernet/sfc/falcon_boards.c
+++ /dev/null
@@ -1,764 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2007-2012 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#include <linux/rtnetlink.h>
-
-#include "net_driver.h"
-#include "phy.h"
-#include "efx.h"
-#include "nic.h"
-#include "workarounds.h"
-
-/* Macros for unpacking the board revision */
-/* The revision info is in host byte order. */
-#define FALCON_BOARD_TYPE(_rev) (_rev >> 8)
-#define FALCON_BOARD_MAJOR(_rev) ((_rev >> 4) & 0xf)
-#define FALCON_BOARD_MINOR(_rev) (_rev & 0xf)
-
-/* Board types */
-#define FALCON_BOARD_SFE4001 0x01
-#define FALCON_BOARD_SFE4002 0x02
-#define FALCON_BOARD_SFE4003 0x03
-#define FALCON_BOARD_SFN4112F 0x52
-
-/* Board temperature is about 15°C above ambient when air flow is
- * limited.  The maximum acceptable ambient temperature varies
- * depending on the PHY specifications but the critical temperature
- * above which we should shut down to avoid damage is 80°C. */
-#define FALCON_BOARD_TEMP_BIAS	15
-#define FALCON_BOARD_TEMP_CRIT	(80 + FALCON_BOARD_TEMP_BIAS)
-
-/* SFC4000 datasheet says: 'The maximum permitted junction temperature
- * is 125°C; the thermal design of the environment for the SFC4000
- * should aim to keep this well below 100°C.' */
-#define FALCON_JUNC_TEMP_MIN	0
-#define FALCON_JUNC_TEMP_MAX	90
-#define FALCON_JUNC_TEMP_CRIT	125
-
-/*****************************************************************************
- * Support for LM87 sensor chip used on several boards
- */
-#define LM87_REG_TEMP_HW_INT_LOCK	0x13
-#define LM87_REG_TEMP_HW_EXT_LOCK	0x14
-#define LM87_REG_TEMP_HW_INT		0x17
-#define LM87_REG_TEMP_HW_EXT		0x18
-#define LM87_REG_TEMP_EXT1		0x26
-#define LM87_REG_TEMP_INT		0x27
-#define LM87_REG_ALARMS1		0x41
-#define LM87_REG_ALARMS2		0x42
-#define LM87_IN_LIMITS(nr, _min, _max)			\
-	0x2B + (nr) * 2, _max, 0x2C + (nr) * 2, _min
-#define LM87_AIN_LIMITS(nr, _min, _max)			\
-	0x3B + (nr), _max, 0x1A + (nr), _min
-#define LM87_TEMP_INT_LIMITS(_min, _max)		\
-	0x39, _max, 0x3A, _min
-#define LM87_TEMP_EXT1_LIMITS(_min, _max)		\
-	0x37, _max, 0x38, _min
-
-#define LM87_ALARM_TEMP_INT		0x10
-#define LM87_ALARM_TEMP_EXT1		0x20
-
-#if IS_ENABLED(CONFIG_SENSORS_LM87)
-
-static int efx_poke_lm87(struct i2c_client *client, const u8 *reg_values)
-{
-	while (*reg_values) {
-		u8 reg = *reg_values++;
-		u8 value = *reg_values++;
-		int rc = i2c_smbus_write_byte_data(client, reg, value);
-		if (rc)
-			return rc;
-	}
-	return 0;
-}
-
-static const u8 falcon_lm87_common_regs[] = {
-	LM87_REG_TEMP_HW_INT_LOCK, FALCON_BOARD_TEMP_CRIT,
-	LM87_REG_TEMP_HW_INT, FALCON_BOARD_TEMP_CRIT,
-	LM87_TEMP_EXT1_LIMITS(FALCON_JUNC_TEMP_MIN, FALCON_JUNC_TEMP_MAX),
-	LM87_REG_TEMP_HW_EXT_LOCK, FALCON_JUNC_TEMP_CRIT,
-	LM87_REG_TEMP_HW_EXT, FALCON_JUNC_TEMP_CRIT,
-	0
-};
-
-static int efx_init_lm87(struct efx_nic *efx, const struct i2c_board_info *info,
-			 const u8 *reg_values)
-{
-	struct falcon_board *board = falcon_board(efx);
-	struct i2c_client *client = i2c_new_device(&board->i2c_adap, info);
-	int rc;
-
-	if (!client)
-		return -EIO;
-
-	/* Read-to-clear alarm/interrupt status */
-	i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
-	i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
-
-	rc = efx_poke_lm87(client, reg_values);
-	if (rc)
-		goto err;
-	rc = efx_poke_lm87(client, falcon_lm87_common_regs);
-	if (rc)
-		goto err;
-
-	board->hwmon_client = client;
-	return 0;
-
-err:
-	i2c_unregister_device(client);
-	return rc;
-}
-
-static void efx_fini_lm87(struct efx_nic *efx)
-{
-	i2c_unregister_device(falcon_board(efx)->hwmon_client);
-}
-
-static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
-{
-	struct i2c_client *client = falcon_board(efx)->hwmon_client;
-	bool temp_crit, elec_fault, is_failure;
-	u16 alarms;
-	s32 reg;
-
-	/* If link is up then do not monitor temperature */
-	if (EFX_WORKAROUND_7884(efx) && efx->link_state.up)
-		return 0;
-
-	reg = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
-	if (reg < 0)
-		return reg;
-	alarms = reg;
-	reg = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
-	if (reg < 0)
-		return reg;
-	alarms |= reg << 8;
-	alarms &= mask;
-
-	temp_crit = false;
-	if (alarms & LM87_ALARM_TEMP_INT) {
-		reg = i2c_smbus_read_byte_data(client, LM87_REG_TEMP_INT);
-		if (reg < 0)
-			return reg;
-		if (reg > FALCON_BOARD_TEMP_CRIT)
-			temp_crit = true;
-	}
-	if (alarms & LM87_ALARM_TEMP_EXT1) {
-		reg = i2c_smbus_read_byte_data(client, LM87_REG_TEMP_EXT1);
-		if (reg < 0)
-			return reg;
-		if (reg > FALCON_JUNC_TEMP_CRIT)
-			temp_crit = true;
-	}
-	elec_fault = alarms & ~(LM87_ALARM_TEMP_INT | LM87_ALARM_TEMP_EXT1);
-	is_failure = temp_crit || elec_fault;
-
-	if (alarms)
-		netif_err(efx, hw, efx->net_dev,
-			  "LM87 detected a hardware %s (status %02x:%02x)"
-			  "%s%s%s%s\n",
-			  is_failure ? "failure" : "problem",
-			  alarms & 0xff, alarms >> 8,
-			  (alarms & LM87_ALARM_TEMP_INT) ?
-			  "; board is overheating" : "",
-			  (alarms & LM87_ALARM_TEMP_EXT1) ?
-			  "; controller is overheating" : "",
-			  temp_crit ? "; reached critical temperature" : "",
-			  elec_fault ? "; electrical fault" : "");
-
-	return is_failure ? -ERANGE : 0;
-}
-
-#else /* !CONFIG_SENSORS_LM87 */
-
-static inline int
-efx_init_lm87(struct efx_nic *efx, const struct i2c_board_info *info,
-	      const u8 *reg_values)
-{
-	return 0;
-}
-static inline void efx_fini_lm87(struct efx_nic *efx)
-{
-}
-static inline int efx_check_lm87(struct efx_nic *efx, unsigned mask)
-{
-	return 0;
-}
-
-#endif /* CONFIG_SENSORS_LM87 */
-
-/*****************************************************************************
- * Support for the SFE4001 NIC.
- *
- * The SFE4001 does not power-up fully at reset due to its high power
- * consumption.  We control its power via a PCA9539 I/O expander.
- * It also has a MAX6647 temperature monitor which we expose to
- * the lm90 driver.
- *
- * This also provides minimal support for reflashing the PHY, which is
- * initiated by resetting it with the FLASH_CFG_1 pin pulled down.
- * On SFE4001 rev A2 and later this is connected to the 3V3X output of
- * the IO-expander.
- * We represent reflash mode as PHY_MODE_SPECIAL and make it mutually
- * exclusive with the network device being open.
- */
-
-/**************************************************************************
- * Support for I2C IO Expander device on SFE4001
- */
-#define	PCA9539 0x74
-
-#define	P0_IN 0x00
-#define	P0_OUT 0x02
-#define	P0_INVERT 0x04
-#define	P0_CONFIG 0x06
-
-#define	P0_EN_1V0X_LBN 0
-#define	P0_EN_1V0X_WIDTH 1
-#define	P0_EN_1V2_LBN 1
-#define	P0_EN_1V2_WIDTH 1
-#define	P0_EN_2V5_LBN 2
-#define	P0_EN_2V5_WIDTH 1
-#define	P0_EN_3V3X_LBN 3
-#define	P0_EN_3V3X_WIDTH 1
-#define	P0_EN_5V_LBN 4
-#define	P0_EN_5V_WIDTH 1
-#define	P0_SHORTEN_JTAG_LBN 5
-#define	P0_SHORTEN_JTAG_WIDTH 1
-#define	P0_X_TRST_LBN 6
-#define	P0_X_TRST_WIDTH 1
-#define	P0_DSP_RESET_LBN 7
-#define	P0_DSP_RESET_WIDTH 1
-
-#define	P1_IN 0x01
-#define	P1_OUT 0x03
-#define	P1_INVERT 0x05
-#define	P1_CONFIG 0x07
-
-#define	P1_AFE_PWD_LBN 0
-#define	P1_AFE_PWD_WIDTH 1
-#define	P1_DSP_PWD25_LBN 1
-#define	P1_DSP_PWD25_WIDTH 1
-#define	P1_RESERVED_LBN 2
-#define	P1_RESERVED_WIDTH 2
-#define	P1_SPARE_LBN 4
-#define	P1_SPARE_WIDTH 4
-
-/* Temperature Sensor */
-#define MAX664X_REG_RSL		0x02
-#define MAX664X_REG_WLHO	0x0B
-
-static void sfe4001_poweroff(struct efx_nic *efx)
-{
-	struct i2c_client *ioexp_client = falcon_board(efx)->ioexp_client;
-	struct i2c_client *hwmon_client = falcon_board(efx)->hwmon_client;
-
-	/* Turn off all power rails and disable outputs */
-	i2c_smbus_write_byte_data(ioexp_client, P0_OUT, 0xff);
-	i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG, 0xff);
-	i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0xff);
-
-	/* Clear any over-temperature alert */
-	i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
-}
-
-static int sfe4001_poweron(struct efx_nic *efx)
-{
-	struct i2c_client *ioexp_client = falcon_board(efx)->ioexp_client;
-	struct i2c_client *hwmon_client = falcon_board(efx)->hwmon_client;
-	unsigned int i, j;
-	int rc;
-	u8 out;
-
-	/* Clear any previous over-temperature alert */
-	rc = i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
-	if (rc < 0)
-		return rc;
-
-	/* Enable port 0 and port 1 outputs on IO expander */
-	rc = i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0x00);
-	if (rc)
-		return rc;
-	rc = i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG,
-				       0xff & ~(1 << P1_SPARE_LBN));
-	if (rc)
-		goto fail_on;
-
-	/* If PHY power is on, turn it all off and wait 1 second to
-	 * ensure a full reset.
-	 */
-	rc = i2c_smbus_read_byte_data(ioexp_client, P0_OUT);
-	if (rc < 0)
-		goto fail_on;
-	out = 0xff & ~((0 << P0_EN_1V2_LBN) | (0 << P0_EN_2V5_LBN) |
-		       (0 << P0_EN_3V3X_LBN) | (0 << P0_EN_5V_LBN) |
-		       (0 << P0_EN_1V0X_LBN));
-	if (rc != out) {
-		netif_info(efx, hw, efx->net_dev, "power-cycling PHY\n");
-		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
-		if (rc)
-			goto fail_on;
-		schedule_timeout_uninterruptible(HZ);
-	}
-
-	for (i = 0; i < 20; ++i) {
-		/* Turn on 1.2V, 2.5V, 3.3V and 5V power rails */
-		out = 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
-			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
-			       (1 << P0_X_TRST_LBN));
-		if (efx->phy_mode & PHY_MODE_SPECIAL)
-			out |= 1 << P0_EN_3V3X_LBN;
-
-		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
-		if (rc)
-			goto fail_on;
-		msleep(10);
-
-		/* Turn on 1V power rail */
-		out &= ~(1 << P0_EN_1V0X_LBN);
-		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
-		if (rc)
-			goto fail_on;
-
-		netif_info(efx, hw, efx->net_dev,
-			   "waiting for DSP boot (attempt %d)...\n", i);
-
-		/* In flash config mode, DSP does not turn on AFE, so
-		 * just wait 1 second.
-		 */
-		if (efx->phy_mode & PHY_MODE_SPECIAL) {
-			schedule_timeout_uninterruptible(HZ);
-			return 0;
-		}
-
-		for (j = 0; j < 10; ++j) {
-			msleep(100);
-
-			/* Check DSP has asserted AFE power line */
-			rc = i2c_smbus_read_byte_data(ioexp_client, P1_IN);
-			if (rc < 0)
-				goto fail_on;
-			if (rc & (1 << P1_AFE_PWD_LBN))
-				return 0;
-		}
-	}
-
-	netif_info(efx, hw, efx->net_dev, "timed out waiting for DSP boot\n");
-	rc = -ETIMEDOUT;
-fail_on:
-	sfe4001_poweroff(efx);
-	return rc;
-}
-
-static ssize_t show_phy_flash_cfg(struct device *dev,
-				  struct device_attribute *attr, char *buf)
-{
-	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
-	return sprintf(buf, "%d\n", !!(efx->phy_mode & PHY_MODE_SPECIAL));
-}
-
-static ssize_t set_phy_flash_cfg(struct device *dev,
-				 struct device_attribute *attr,
-				 const char *buf, size_t count)
-{
-	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
-	enum efx_phy_mode old_mode, new_mode;
-	int err;
-
-	rtnl_lock();
-	old_mode = efx->phy_mode;
-	if (count == 0 || *buf == '0')
-		new_mode = old_mode & ~PHY_MODE_SPECIAL;
-	else
-		new_mode = PHY_MODE_SPECIAL;
-	if (!((old_mode ^ new_mode) & PHY_MODE_SPECIAL)) {
-		err = 0;
-	} else if (efx->state != STATE_READY || netif_running(efx->net_dev)) {
-		err = -EBUSY;
-	} else {
-		/* Reset the PHY, reconfigure the MAC and enable/disable
-		 * MAC stats accordingly. */
-		efx->phy_mode = new_mode;
-		if (new_mode & PHY_MODE_SPECIAL)
-			falcon_stop_nic_stats(efx);
-		err = sfe4001_poweron(efx);
-		if (!err)
-			err = efx_reconfigure_port(efx);
-		if (!(new_mode & PHY_MODE_SPECIAL))
-			falcon_start_nic_stats(efx);
-	}
-	rtnl_unlock();
-
-	return err ? err : count;
-}
-
-static DEVICE_ATTR(phy_flash_cfg, 0644, show_phy_flash_cfg, set_phy_flash_cfg);
-
-static void sfe4001_fini(struct efx_nic *efx)
-{
-	struct falcon_board *board = falcon_board(efx);
-
-	netif_info(efx, drv, efx->net_dev, "%s\n", __func__);
-
-	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
-	sfe4001_poweroff(efx);
-	i2c_unregister_device(board->ioexp_client);
-	i2c_unregister_device(board->hwmon_client);
-}
-
-static int sfe4001_check_hw(struct efx_nic *efx)
-{
-	struct falcon_nic_data *nic_data = efx->nic_data;
-	s32 status;
-
-	/* If XAUI link is up then do not monitor */
-	if (EFX_WORKAROUND_7884(efx) && !nic_data->xmac_poll_required)
-		return 0;
-
-	/* Check the powered status of the PHY. Lack of power implies that
-	 * the MAX6647 has shut down power to it, probably due to a temp.
-	 * alarm. Reading the power status rather than the MAX6647 status
-	 * directly because the later is read-to-clear and would thus
-	 * start to power up the PHY again when polled, causing us to blip
-	 * the power undesirably.
-	 * We know we can read from the IO expander because we did
-	 * it during power-on. Assume failure now is bad news. */
-	status = i2c_smbus_read_byte_data(falcon_board(efx)->ioexp_client, P1_IN);
-	if (status >= 0 &&
-	    (status & ((1 << P1_AFE_PWD_LBN) | (1 << P1_DSP_PWD25_LBN))) != 0)
-		return 0;
-
-	/* Use board power control, not PHY power control */
-	sfe4001_poweroff(efx);
-	efx->phy_mode = PHY_MODE_OFF;
-
-	return (status < 0) ? -EIO : -ERANGE;
-}
-
-static const struct i2c_board_info sfe4001_hwmon_info = {
-	I2C_BOARD_INFO("max6647", 0x4e),
-};
-
-/* This board uses an I2C expander to provider power to the PHY, which needs to
- * be turned on before the PHY can be used.
- * Context: Process context, rtnl lock held
- */
-static int sfe4001_init(struct efx_nic *efx)
-{
-	struct falcon_board *board = falcon_board(efx);
-	int rc;
-
-#if IS_ENABLED(CONFIG_SENSORS_LM90)
-	board->hwmon_client =
-		i2c_new_device(&board->i2c_adap, &sfe4001_hwmon_info);
-#else
-	board->hwmon_client =
-		i2c_new_dummy(&board->i2c_adap, sfe4001_hwmon_info.addr);
-#endif
-	if (!board->hwmon_client)
-		return -EIO;
-
-	/* Raise board/PHY high limit from 85 to 90 degrees Celsius */
-	rc = i2c_smbus_write_byte_data(board->hwmon_client,
-				       MAX664X_REG_WLHO, 90);
-	if (rc)
-		goto fail_hwmon;
-
-	board->ioexp_client = i2c_new_dummy(&board->i2c_adap, PCA9539);
-	if (!board->ioexp_client) {
-		rc = -EIO;
-		goto fail_hwmon;
-	}
-
-	if (efx->phy_mode & PHY_MODE_SPECIAL) {
-		/* PHY won't generate a 156.25 MHz clock and MAC stats fetch
-		 * will fail. */
-		falcon_stop_nic_stats(efx);
-	}
-	rc = sfe4001_poweron(efx);
-	if (rc)
-		goto fail_ioexp;
-
-	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
-	if (rc)
-		goto fail_on;
-
-	netif_info(efx, hw, efx->net_dev, "PHY is powered on\n");
-	return 0;
-
-fail_on:
-	sfe4001_poweroff(efx);
-fail_ioexp:
-	i2c_unregister_device(board->ioexp_client);
-fail_hwmon:
-	i2c_unregister_device(board->hwmon_client);
-	return rc;
-}
-
-/*****************************************************************************
- * Support for the SFE4002
- *
- */
-static u8 sfe4002_lm87_channel = 0x03; /* use AIN not FAN inputs */
-
-static const u8 sfe4002_lm87_regs[] = {
-	LM87_IN_LIMITS(0, 0x7c, 0x99),		/* 2.5V:  1.8V +/- 10% */
-	LM87_IN_LIMITS(1, 0x4c, 0x5e),		/* Vccp1: 1.2V +/- 10% */
-	LM87_IN_LIMITS(2, 0xac, 0xd4),		/* 3.3V:  3.3V +/- 10% */
-	LM87_IN_LIMITS(3, 0xac, 0xd4),		/* 5V:    5.0V +/- 10% */
-	LM87_IN_LIMITS(4, 0xac, 0xe0),		/* 12V:   10.8-14V */
-	LM87_IN_LIMITS(5, 0x3f, 0x4f),		/* Vccp2: 1.0V +/- 10% */
-	LM87_AIN_LIMITS(0, 0x98, 0xbb),		/* AIN1:  1.66V +/- 10% */
-	LM87_AIN_LIMITS(1, 0x8a, 0xa9),		/* AIN2:  1.5V +/- 10% */
-	LM87_TEMP_INT_LIMITS(0, 80 + FALCON_BOARD_TEMP_BIAS),
-	LM87_TEMP_EXT1_LIMITS(0, FALCON_JUNC_TEMP_MAX),
-	0
-};
-
-static const struct i2c_board_info sfe4002_hwmon_info = {
-	I2C_BOARD_INFO("lm87", 0x2e),
-	.platform_data	= &sfe4002_lm87_channel,
-};
-
-/****************************************************************************/
-/* LED allocations. Note that on rev A0 boards the schematic and the reality
- * differ: red and green are swapped. Below is the fixed (A1) layout (there
- * are only 3 A0 boards in existence, so no real reason to make this
- * conditional).
- */
-#define SFE4002_FAULT_LED (2)	/* Red */
-#define SFE4002_RX_LED    (0)	/* Green */
-#define SFE4002_TX_LED    (1)	/* Amber */
-
-static void sfe4002_init_phy(struct efx_nic *efx)
-{
-	/* Set the TX and RX LEDs to reflect status and activity, and the
-	 * fault LED off */
-	falcon_qt202x_set_led(efx, SFE4002_TX_LED,
-			      QUAKE_LED_TXLINK | QUAKE_LED_LINK_ACTSTAT);
-	falcon_qt202x_set_led(efx, SFE4002_RX_LED,
-			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACTSTAT);
-	falcon_qt202x_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
-}
-
-static void sfe4002_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
-{
-	falcon_qt202x_set_led(
-		efx, SFE4002_FAULT_LED,
-		(mode == EFX_LED_ON) ? QUAKE_LED_ON : QUAKE_LED_OFF);
-}
-
-static int sfe4002_check_hw(struct efx_nic *efx)
-{
-	struct falcon_board *board = falcon_board(efx);
-
-	/* A0 board rev. 4002s report a temperature fault the whole time
-	 * (bad sensor) so we mask it out. */
-	unsigned alarm_mask =
-		(board->major == 0 && board->minor == 0) ?
-		~LM87_ALARM_TEMP_EXT1 : ~0;
-
-	return efx_check_lm87(efx, alarm_mask);
-}
-
-static int sfe4002_init(struct efx_nic *efx)
-{
-	return efx_init_lm87(efx, &sfe4002_hwmon_info, sfe4002_lm87_regs);
-}
-
-/*****************************************************************************
- * Support for the SFN4112F
- *
- */
-static u8 sfn4112f_lm87_channel = 0x03; /* use AIN not FAN inputs */
-
-static const u8 sfn4112f_lm87_regs[] = {
-	LM87_IN_LIMITS(0, 0x7c, 0x99),		/* 2.5V:  1.8V +/- 10% */
-	LM87_IN_LIMITS(1, 0x4c, 0x5e),		/* Vccp1: 1.2V +/- 10% */
-	LM87_IN_LIMITS(2, 0xac, 0xd4),		/* 3.3V:  3.3V +/- 10% */
-	LM87_IN_LIMITS(4, 0xac, 0xe0),		/* 12V:   10.8-14V */
-	LM87_IN_LIMITS(5, 0x3f, 0x4f),		/* Vccp2: 1.0V +/- 10% */
-	LM87_AIN_LIMITS(1, 0x8a, 0xa9),		/* AIN2:  1.5V +/- 10% */
-	LM87_TEMP_INT_LIMITS(0, 60 + FALCON_BOARD_TEMP_BIAS),
-	LM87_TEMP_EXT1_LIMITS(0, FALCON_JUNC_TEMP_MAX),
-	0
-};
-
-static const struct i2c_board_info sfn4112f_hwmon_info = {
-	I2C_BOARD_INFO("lm87", 0x2e),
-	.platform_data	= &sfn4112f_lm87_channel,
-};
-
-#define SFN4112F_ACT_LED	0
-#define SFN4112F_LINK_LED	1
-
-static void sfn4112f_init_phy(struct efx_nic *efx)
-{
-	falcon_qt202x_set_led(efx, SFN4112F_ACT_LED,
-			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACT);
-	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED,
-			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT);
-}
-
-static void sfn4112f_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
-{
-	int reg;
-
-	switch (mode) {
-	case EFX_LED_OFF:
-		reg = QUAKE_LED_OFF;
-		break;
-	case EFX_LED_ON:
-		reg = QUAKE_LED_ON;
-		break;
-	default:
-		reg = QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT;
-		break;
-	}
-
-	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED, reg);
-}
-
-static int sfn4112f_check_hw(struct efx_nic *efx)
-{
-	/* Mask out unused sensors */
-	return efx_check_lm87(efx, ~0x48);
-}
-
-static int sfn4112f_init(struct efx_nic *efx)
-{
-	return efx_init_lm87(efx, &sfn4112f_hwmon_info, sfn4112f_lm87_regs);
-}
-
-/*****************************************************************************
- * Support for the SFE4003
- *
- */
-static u8 sfe4003_lm87_channel = 0x03; /* use AIN not FAN inputs */
-
-static const u8 sfe4003_lm87_regs[] = {
-	LM87_IN_LIMITS(0, 0x67, 0x7f),		/* 2.5V:  1.5V +/- 10% */
-	LM87_IN_LIMITS(1, 0x4c, 0x5e),		/* Vccp1: 1.2V +/- 10% */
-	LM87_IN_LIMITS(2, 0xac, 0xd4),		/* 3.3V:  3.3V +/- 10% */
-	LM87_IN_LIMITS(4, 0xac, 0xe0),		/* 12V:   10.8-14V */
-	LM87_IN_LIMITS(5, 0x3f, 0x4f),		/* Vccp2: 1.0V +/- 10% */
-	LM87_TEMP_INT_LIMITS(0, 70 + FALCON_BOARD_TEMP_BIAS),
-	0
-};
-
-static const struct i2c_board_info sfe4003_hwmon_info = {
-	I2C_BOARD_INFO("lm87", 0x2e),
-	.platform_data	= &sfe4003_lm87_channel,
-};
-
-/* Board-specific LED info. */
-#define SFE4003_RED_LED_GPIO	11
-#define SFE4003_LED_ON		1
-#define SFE4003_LED_OFF		0
-
-static void sfe4003_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
-{
-	struct falcon_board *board = falcon_board(efx);
-
-	/* The LEDs were not wired to GPIOs before A3 */
-	if (board->minor < 3 && board->major == 0)
-		return;
-
-	falcon_txc_set_gpio_val(
-		efx, SFE4003_RED_LED_GPIO,
-		(mode == EFX_LED_ON) ? SFE4003_LED_ON : SFE4003_LED_OFF);
-}
-
-static void sfe4003_init_phy(struct efx_nic *efx)
-{
-	struct falcon_board *board = falcon_board(efx);
-
-	/* The LEDs were not wired to GPIOs before A3 */
-	if (board->minor < 3 && board->major == 0)
-		return;
-
-	falcon_txc_set_gpio_dir(efx, SFE4003_RED_LED_GPIO, TXC_GPIO_DIR_OUTPUT);
-	falcon_txc_set_gpio_val(efx, SFE4003_RED_LED_GPIO, SFE4003_LED_OFF);
-}
-
-static int sfe4003_check_hw(struct efx_nic *efx)
-{
-	struct falcon_board *board = falcon_board(efx);
-
-	/* A0/A1/A2 board rev. 4003s  report a temperature fault the whole time
-	 * (bad sensor) so we mask it out. */
-	unsigned alarm_mask =
-		(board->major == 0 && board->minor <= 2) ?
-		~LM87_ALARM_TEMP_EXT1 : ~0;
-
-	return efx_check_lm87(efx, alarm_mask);
-}
-
-static int sfe4003_init(struct efx_nic *efx)
-{
-	return efx_init_lm87(efx, &sfe4003_hwmon_info, sfe4003_lm87_regs);
-}
-
-static const struct falcon_board_type board_types[] = {
-	{
-		.id		= FALCON_BOARD_SFE4001,
-		.init		= sfe4001_init,
-		.init_phy	= efx_port_dummy_op_void,
-		.fini		= sfe4001_fini,
-		.set_id_led	= tenxpress_set_id_led,
-		.monitor	= sfe4001_check_hw,
-	},
-	{
-		.id		= FALCON_BOARD_SFE4002,
-		.init		= sfe4002_init,
-		.init_phy	= sfe4002_init_phy,
-		.fini		= efx_fini_lm87,
-		.set_id_led	= sfe4002_set_id_led,
-		.monitor	= sfe4002_check_hw,
-	},
-	{
-		.id		= FALCON_BOARD_SFE4003,
-		.init		= sfe4003_init,
-		.init_phy	= sfe4003_init_phy,
-		.fini		= efx_fini_lm87,
-		.set_id_led	= sfe4003_set_id_led,
-		.monitor	= sfe4003_check_hw,
-	},
-	{
-		.id		= FALCON_BOARD_SFN4112F,
-		.init		= sfn4112f_init,
-		.init_phy	= sfn4112f_init_phy,
-		.fini		= efx_fini_lm87,
-		.set_id_led	= sfn4112f_set_id_led,
-		.monitor	= sfn4112f_check_hw,
-	},
-};
-
-int falcon_probe_board(struct efx_nic *efx, u16 revision_info)
-{
-	struct falcon_board *board = falcon_board(efx);
-	u8 type_id = FALCON_BOARD_TYPE(revision_info);
-	int i;
-
-	board->major = FALCON_BOARD_MAJOR(revision_info);
-	board->minor = FALCON_BOARD_MINOR(revision_info);
-
-	for (i = 0; i < ARRAY_SIZE(board_types); i++)
-		if (board_types[i].id == type_id)
-			board->type = &board_types[i];
-
-	if (board->type) {
-		return 0;
-	} else {
-		netif_err(efx, probe, efx->net_dev, "unknown board type %d\n",
-			  type_id);
-		return -ENODEV;
-	}
-}
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 3d5b91b..c282d66 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -25,7 +25,7 @@
 #include "io.h"
 #include "workarounds.h"
 
-/* Falcon-architecture (SFC4000 and SFC9000-family) support */
+/* Falcon-architecture (SFC9000-family) support */
 
 /**************************************************************************
  *
@@ -364,9 +364,6 @@ unsigned int efx_farch_tx_limit_len(struct efx_tx_queue *tx_queue,
 
 	len = min(limit, len);
 
-	if (EFX_WORKAROUND_5391(tx_queue->efx) && (dma_addr & 0xf))
-		len = min_t(unsigned int, len, 512 - (dma_addr & 0xf));
-
 	return len;
 }
 
@@ -384,6 +381,7 @@ int efx_farch_tx_probe(struct efx_tx_queue *tx_queue)
 
 void efx_farch_tx_init(struct efx_tx_queue *tx_queue)
 {
+	int csum = tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD;
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t reg;
 
@@ -405,37 +403,18 @@ void efx_farch_tx_init(struct efx_tx_queue *tx_queue)
 			      FRF_AZ_TX_DESCQ_TYPE, 0,
 			      FRF_BZ_TX_NON_IP_DROP_DIS, 1);
 
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		int csum = tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD;
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_TX_TCP_CHKSM_DIS,
-				    !csum);
-	}
+	EFX_SET_OWORD_FIELD(reg, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
+	EFX_SET_OWORD_FIELD(reg, FRF_BZ_TX_TCP_CHKSM_DIS, !csum);
 
 	efx_writeo_table(efx, &reg, efx->type->txd_ptr_tbl_base,
 			 tx_queue->queue);
 
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0) {
-		/* Only 128 bits in this register */
-		BUILD_BUG_ON(EFX_MAX_TX_QUEUES > 128);
-
-		efx_reado(efx, &reg, FR_AA_TX_CHKSM_CFG);
-		if (tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD)
-			__clear_bit_le(tx_queue->queue, &reg);
-		else
-			__set_bit_le(tx_queue->queue, &reg);
-		efx_writeo(efx, &reg, FR_AA_TX_CHKSM_CFG);
-	}
-
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		EFX_POPULATE_OWORD_1(reg,
-				     FRF_BZ_TX_PACE,
-				     (tx_queue->queue & EFX_TXQ_TYPE_HIGHPRI) ?
-				     FFE_BZ_TX_PACE_OFF :
-				     FFE_BZ_TX_PACE_RESERVED);
-		efx_writeo_table(efx, &reg, FR_BZ_TX_PACE_TBL,
-				 tx_queue->queue);
-	}
+	EFX_POPULATE_OWORD_1(reg,
+			     FRF_BZ_TX_PACE,
+			     (tx_queue->queue & EFX_TXQ_TYPE_HIGHPRI) ?
+			     FFE_BZ_TX_PACE_OFF :
+			     FFE_BZ_TX_PACE_RESERVED);
+	efx_writeo_table(efx, &reg, FR_BZ_TX_PACE_TBL, tx_queue->queue);
 }
 
 static void efx_farch_flush_tx_queue(struct efx_tx_queue *tx_queue)
@@ -532,16 +511,10 @@ void efx_farch_rx_init(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
-	bool is_b0 = efx_nic_rev(efx) >= EFX_REV_FALCON_B0;
-	bool iscsi_digest_en = is_b0;
 	bool jumbo_en;
 
-	/* For kernel-mode queues in Falcon A1, the JUMBO flag enables
-	 * DMA to continue after a PCIe page boundary (and scattering
-	 * is not possible).  In Falcon B0 and Siena, it enables
-	 * scatter.
-	 */
-	jumbo_en = !is_b0 || efx->rx_scatter;
+	/* For kernel-mode queues in Siena, the JUMBO flag enables scatter. */
+	jumbo_en = efx->rx_scatter;
 
 	netif_dbg(efx, hw, efx->net_dev,
 		  "RX queue %d ring in special buffers %d-%d\n",
@@ -555,8 +528,8 @@ void efx_farch_rx_init(struct efx_rx_queue *rx_queue)
 
 	/* Push RX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(rx_desc_ptr,
-			      FRF_AZ_RX_ISCSI_DDIG_EN, iscsi_digest_en,
-			      FRF_AZ_RX_ISCSI_HDIG_EN, iscsi_digest_en,
+			      FRF_AZ_RX_ISCSI_DDIG_EN, true,
+			      FRF_AZ_RX_ISCSI_HDIG_EN, true,
 			      FRF_AZ_RX_DESCQ_BUF_BASE_ID, rx_queue->rxd.index,
 			      FRF_AZ_RX_DESCQ_EVQ_ID,
 			      efx_rx_queue_channel(rx_queue)->channel,
@@ -895,7 +868,7 @@ static u16 efx_farch_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	struct efx_nic *efx = rx_queue->efx;
 	bool rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
 	bool rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
-	bool rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
+	bool rx_ev_frm_trunc, rx_ev_tobe_disc;
 	bool rx_ev_other_err, rx_ev_pause_frm;
 	bool rx_ev_hdr_type, rx_ev_mcast_pkt;
 	unsigned rx_ev_pkt_type;
@@ -912,12 +885,10 @@ static u16 efx_farch_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 						   FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR);
 	rx_ev_eth_crc_err = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_ETH_CRC_ERR);
 	rx_ev_frm_trunc = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_FRM_TRUNC);
-	rx_ev_drib_nib = ((efx_nic_rev(efx) >= EFX_REV_FALCON_B0) ?
-			  0 : EFX_QWORD_FIELD(*event, FSF_AA_RX_EV_DRIB_NIB));
 	rx_ev_pause_frm = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_PAUSE_FRM_ERR);
 
 	/* Every error apart from tobe_disc and pause_frm */
-	rx_ev_other_err = (rx_ev_drib_nib | rx_ev_tcp_udp_chksum_err |
+	rx_ev_other_err = (rx_ev_tcp_udp_chksum_err |
 			   rx_ev_buf_owner_id_err | rx_ev_eth_crc_err |
 			   rx_ev_frm_trunc | rx_ev_ip_hdr_chksum_err);
 
@@ -951,14 +922,13 @@ static u16 efx_farch_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 			  " [TCP_UDP_CHKSUM_ERR]" : "",
 			  rx_ev_eth_crc_err ? " [ETH_CRC_ERR]" : "",
 			  rx_ev_frm_trunc ? " [FRM_TRUNC]" : "",
-			  rx_ev_drib_nib ? " [DRIB_NIB]" : "",
 			  rx_ev_tobe_disc ? " [TOBE_DISC]" : "",
 			  rx_ev_pause_frm ? " [PAUSE]" : "");
 	}
 #endif
 
 	/* The frame must be discarded if any of these are true. */
-	return (rx_ev_eth_crc_err | rx_ev_frm_trunc | rx_ev_drib_nib |
+	return (rx_ev_eth_crc_err | rx_ev_frm_trunc |
 		rx_ev_tobe_disc | rx_ev_pause_frm) ?
 		EFX_RX_PKT_DISCARD : 0;
 }
@@ -987,8 +957,7 @@ efx_farch_handle_rx_bad_index(struct efx_rx_queue *rx_queue, unsigned index)
 		   "dropped %d events (index=%d expected=%d)\n",
 		   dropped, index, expected);
 
-	efx_schedule_reset(efx, EFX_WORKAROUND_5676(efx) ?
-			   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
+	efx_schedule_reset(efx, RESET_TYPE_DISABLE);
 	return false;
 }
 
@@ -1254,10 +1223,7 @@ efx_farch_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 			  "channel %d seen DRIVER RX_RESET event. "
 			"Resetting.\n", channel->channel);
 		atomic_inc(&efx->rx_reset);
-		efx_schedule_reset(efx,
-				   EFX_WORKAROUND_6555(efx) ?
-				   RESET_TYPE_RX_RECOVERY :
-				   RESET_TYPE_DISABLE);
+		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
 		break;
 	case FSE_BZ_RX_DSC_ERROR_EV:
 		if (ev_sub_data < EFX_VI_BASE) {
@@ -1394,13 +1360,11 @@ int efx_farch_ev_init(struct efx_channel *channel)
 		  channel->channel, channel->eventq.index,
 		  channel->eventq.index + channel->eventq.entries - 1);
 
-	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0) {
-		EFX_POPULATE_OWORD_3(reg,
-				     FRF_CZ_TIMER_Q_EN, 1,
-				     FRF_CZ_HOST_NOTIFY_MODE, 0,
-				     FRF_CZ_TIMER_MODE, FFE_CZ_TIMER_MODE_DIS);
-		efx_writeo_table(efx, &reg, FR_BZ_TIMER_TBL, channel->channel);
-	}
+	EFX_POPULATE_OWORD_3(reg,
+			     FRF_CZ_TIMER_Q_EN, 1,
+			     FRF_CZ_HOST_NOTIFY_MODE, 0,
+			     FRF_CZ_TIMER_MODE, FFE_CZ_TIMER_MODE_DIS);
+	efx_writeo_table(efx, &reg, FR_BZ_TIMER_TBL, channel->channel);
 
 	/* Pin event queue buffer */
 	efx_init_special_buffer(efx, &channel->eventq);
@@ -1428,8 +1392,7 @@ void efx_farch_ev_fini(struct efx_channel *channel)
 	EFX_ZERO_OWORD(reg);
 	efx_writeo_table(efx, &reg, efx->type->evq_ptr_tbl_base,
 			 channel->channel);
-	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
-		efx_writeo_table(efx, &reg, FR_BZ_TIMER_TBL, channel->channel);
+	efx_writeo_table(efx, &reg, FR_BZ_TIMER_TBL, channel->channel);
 
 	/* Unpin event queue */
 	efx_fini_special_buffer(efx, &channel->eventq);
@@ -1503,7 +1466,6 @@ int efx_farch_irq_test_generate(struct efx_nic *efx)
  */
 irqreturn_t efx_farch_fatal_interrupt(struct efx_nic *efx)
 {
-	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t *int_ker = efx->irq_status.addr;
 	efx_oword_t fatal_intr;
 	int error, mem_perr;
@@ -1529,8 +1491,6 @@ irqreturn_t efx_farch_fatal_interrupt(struct efx_nic *efx)
 
 	/* Disable both devices */
 	pci_clear_master(efx->pci_dev);
-	if (efx_nic_is_dual_func(efx))
-		pci_clear_master(nic_data->pci_dev2);
 	efx_farch_irq_disable_master(efx);
 
 	/* Count errors and reset or disable the NIC accordingly */
@@ -1677,8 +1637,6 @@ void efx_farch_rx_push_indir_table(struct efx_nic *efx)
 	size_t i = 0;
 	efx_dword_t dword;
 
-	BUG_ON(efx_nic_rev(efx) < EFX_REV_FALCON_B0);
-
 	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_indir_table) !=
 		     FR_BZ_RX_INDIRECTION_TBL_ROWS);
 
@@ -1806,8 +1764,7 @@ void efx_farch_init_common(struct efx_nic *efx)
 			     FRF_AZ_ILL_ADR_INT_KER_EN, 1,
 			     FRF_AZ_RBUF_OWN_INT_KER_EN, 1,
 			     FRF_AZ_TBUF_OWN_INT_KER_EN, 1);
-	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
-		EFX_SET_OWORD_FIELD(temp, FRF_CZ_SRAM_PERR_INT_P_KER_EN, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_CZ_SRAM_PERR_INT_P_KER_EN, 1);
 	EFX_INVERT_OWORD(temp);
 	efx_writeo(efx, &temp, FR_AZ_FATAL_INTR_KER);
 
@@ -1827,22 +1784,18 @@ void efx_farch_init_common(struct efx_nic *efx)
 	/* Disable hardware watchdog which can misfire */
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_WD_TMR, 0x3fffff);
 	/* Squash TX of packets of 16 bytes or less */
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
-		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
 	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
 
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		EFX_POPULATE_OWORD_4(temp,
-				     /* Default values */
-				     FRF_BZ_TX_PACE_SB_NOT_AF, 0x15,
-				     FRF_BZ_TX_PACE_SB_AF, 0xb,
-				     FRF_BZ_TX_PACE_FB_BASE, 0,
-				     /* Allow large pace values in the
-				      * fast bin. */
-				     FRF_BZ_TX_PACE_BIN_TH,
-				     FFE_BZ_TX_PACE_RESERVED);
-		efx_writeo(efx, &temp, FR_BZ_TX_PACE);
-	}
+	EFX_POPULATE_OWORD_4(temp,
+			     /* Default values */
+			     FRF_BZ_TX_PACE_SB_NOT_AF, 0x15,
+			     FRF_BZ_TX_PACE_SB_AF, 0xb,
+			     FRF_BZ_TX_PACE_FB_BASE, 0,
+			     /* Allow large pace values in the fast bin. */
+			     FRF_BZ_TX_PACE_BIN_TH,
+			     FFE_BZ_TX_PACE_RESERVED);
+	efx_writeo(efx, &temp, FR_BZ_TX_PACE);
 }
 
 /**************************************************************************
@@ -2026,7 +1979,7 @@ static void efx_farch_filter_push_rx_config(struct efx_nic *efx)
 			!!(table->spec[EFX_FARCH_FILTER_INDEX_UC_DEF].flags &
 			   table->spec[EFX_FARCH_FILTER_INDEX_MC_DEF].flags &
 			   EFX_FILTER_FLAG_RX_SCATTER));
-	} else if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
+	} else {
 		/* We don't expose 'default' filters because unmatched
 		 * packets always go to the queue number found in the
 		 * RSS table.  But we still need to set the RX scatter
@@ -2834,31 +2787,27 @@ int efx_farch_filter_table_probe(struct efx_nic *efx)
 		return -ENOMEM;
 	efx->filter_state = state;
 
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		table = &state->table[EFX_FARCH_FILTER_TABLE_RX_IP];
-		table->id = EFX_FARCH_FILTER_TABLE_RX_IP;
-		table->offset = FR_BZ_RX_FILTER_TBL0;
-		table->size = FR_BZ_RX_FILTER_TBL0_ROWS;
-		table->step = FR_BZ_RX_FILTER_TBL0_STEP;
-	}
+	table = &state->table[EFX_FARCH_FILTER_TABLE_RX_IP];
+	table->id = EFX_FARCH_FILTER_TABLE_RX_IP;
+	table->offset = FR_BZ_RX_FILTER_TBL0;
+	table->size = FR_BZ_RX_FILTER_TBL0_ROWS;
+	table->step = FR_BZ_RX_FILTER_TBL0_STEP;
 
-	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0) {
-		table = &state->table[EFX_FARCH_FILTER_TABLE_RX_MAC];
-		table->id = EFX_FARCH_FILTER_TABLE_RX_MAC;
-		table->offset = FR_CZ_RX_MAC_FILTER_TBL0;
-		table->size = FR_CZ_RX_MAC_FILTER_TBL0_ROWS;
-		table->step = FR_CZ_RX_MAC_FILTER_TBL0_STEP;
-
-		table = &state->table[EFX_FARCH_FILTER_TABLE_RX_DEF];
-		table->id = EFX_FARCH_FILTER_TABLE_RX_DEF;
-		table->size = EFX_FARCH_FILTER_SIZE_RX_DEF;
-
-		table = &state->table[EFX_FARCH_FILTER_TABLE_TX_MAC];
-		table->id = EFX_FARCH_FILTER_TABLE_TX_MAC;
-		table->offset = FR_CZ_TX_MAC_FILTER_TBL0;
-		table->size = FR_CZ_TX_MAC_FILTER_TBL0_ROWS;
-		table->step = FR_CZ_TX_MAC_FILTER_TBL0_STEP;
-	}
+	table = &state->table[EFX_FARCH_FILTER_TABLE_RX_MAC];
+	table->id = EFX_FARCH_FILTER_TABLE_RX_MAC;
+	table->offset = FR_CZ_RX_MAC_FILTER_TBL0;
+	table->size = FR_CZ_RX_MAC_FILTER_TBL0_ROWS;
+	table->step = FR_CZ_RX_MAC_FILTER_TBL0_STEP;
+
+	table = &state->table[EFX_FARCH_FILTER_TABLE_RX_DEF];
+	table->id = EFX_FARCH_FILTER_TABLE_RX_DEF;
+	table->size = EFX_FARCH_FILTER_SIZE_RX_DEF;
+
+	table = &state->table[EFX_FARCH_FILTER_TABLE_TX_MAC];
+	table->id = EFX_FARCH_FILTER_TABLE_TX_MAC;
+	table->offset = FR_CZ_TX_MAC_FILTER_TBL0;
+	table->size = FR_CZ_TX_MAC_FILTER_TBL0_ROWS;
+	table->step = FR_CZ_TX_MAC_FILTER_TBL0_STEP;
 
 	for (table_id = 0; table_id < EFX_FARCH_FILTER_TABLE_COUNT; table_id++) {
 		table = &state->table[table_id];
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 2415209..9956513 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -15,7 +15,6 @@
 #include "io.h"
 #include "farch_regs.h"
 #include "mcdi_pcol.h"
-#include "phy.h"
 
 /**************************************************************************
  *
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 2a9228a..0f0eb27 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -13,7 +13,6 @@
 
 #include <linux/slab.h>
 #include "efx.h"
-#include "phy.h"
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 #include "nic.h"
diff --git a/drivers/net/ethernet/sfc/mdio_10g.c b/drivers/net/ethernet/sfc/mdio_10g.c
deleted file mode 100644
index 8ff954c..0000000
--- a/drivers/net/ethernet/sfc/mdio_10g.c
+++ /dev/null
@@ -1,323 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2006-2011 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-/*
- * Useful functions for working with MDIO clause 45 PHYs
- */
-#include <linux/types.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
-#include "net_driver.h"
-#include "mdio_10g.h"
-#include "workarounds.h"
-
-unsigned efx_mdio_id_oui(u32 id)
-{
-	unsigned oui = 0;
-	int i;
-
-	/* The bits of the OUI are designated a..x, with a=0 and b variable.
-	 * In the id register c is the MSB but the OUI is conventionally
-	 * written as bytes h..a, p..i, x..q.  Reorder the bits accordingly. */
-	for (i = 0; i < 22; ++i)
-		if (id & (1 << (i + 10)))
-			oui |= 1 << (i ^ 7);
-
-	return oui;
-}
-
-int efx_mdio_reset_mmd(struct efx_nic *port, int mmd,
-			    int spins, int spintime)
-{
-	u32 ctrl;
-
-	/* Catch callers passing values in the wrong units (or just silly) */
-	EFX_BUG_ON_PARANOID(spins * spintime >= 5000);
-
-	efx_mdio_write(port, mmd, MDIO_CTRL1, MDIO_CTRL1_RESET);
-	/* Wait for the reset bit to clear. */
-	do {
-		msleep(spintime);
-		ctrl = efx_mdio_read(port, mmd, MDIO_CTRL1);
-		spins--;
-
-	} while (spins && (ctrl & MDIO_CTRL1_RESET));
-
-	return spins ? spins : -ETIMEDOUT;
-}
-
-static int efx_mdio_check_mmd(struct efx_nic *efx, int mmd)
-{
-	int status;
-
-	if (mmd != MDIO_MMD_AN) {
-		/* Read MMD STATUS2 to check it is responding. */
-		status = efx_mdio_read(efx, mmd, MDIO_STAT2);
-		if ((status & MDIO_STAT2_DEVPRST) != MDIO_STAT2_DEVPRST_VAL) {
-			netif_err(efx, hw, efx->net_dev,
-				  "PHY MMD %d not responding.\n", mmd);
-			return -EIO;
-		}
-	}
-
-	return 0;
-}
-
-/* This ought to be ridiculous overkill. We expect it to fail rarely */
-#define MDIO45_RESET_TIME	1000 /* ms */
-#define MDIO45_RESET_ITERS	100
-
-int efx_mdio_wait_reset_mmds(struct efx_nic *efx, unsigned int mmd_mask)
-{
-	const int spintime = MDIO45_RESET_TIME / MDIO45_RESET_ITERS;
-	int tries = MDIO45_RESET_ITERS;
-	int rc = 0;
-	int in_reset;
-
-	while (tries) {
-		int mask = mmd_mask;
-		int mmd = 0;
-		int stat;
-		in_reset = 0;
-		while (mask) {
-			if (mask & 1) {
-				stat = efx_mdio_read(efx, mmd, MDIO_CTRL1);
-				if (stat < 0) {
-					netif_err(efx, hw, efx->net_dev,
-						  "failed to read status of"
-						  " MMD %d\n", mmd);
-					return -EIO;
-				}
-				if (stat & MDIO_CTRL1_RESET)
-					in_reset |= (1 << mmd);
-			}
-			mask = mask >> 1;
-			mmd++;
-		}
-		if (!in_reset)
-			break;
-		tries--;
-		msleep(spintime);
-	}
-	if (in_reset != 0) {
-		netif_err(efx, hw, efx->net_dev,
-			  "not all MMDs came out of reset in time."
-			  " MMDs still in reset: %x\n", in_reset);
-		rc = -ETIMEDOUT;
-	}
-	return rc;
-}
-
-int efx_mdio_check_mmds(struct efx_nic *efx, unsigned int mmd_mask)
-{
-	int mmd = 0, probe_mmd, devs1, devs2;
-	u32 devices;
-
-	/* Historically we have probed the PHYXS to find out what devices are
-	 * present,but that doesn't work so well if the PHYXS isn't expected
-	 * to exist, if so just find the first item in the list supplied. */
-	probe_mmd = (mmd_mask & MDIO_DEVS_PHYXS) ? MDIO_MMD_PHYXS :
-	    __ffs(mmd_mask);
-
-	/* Check all the expected MMDs are present */
-	devs1 = efx_mdio_read(efx, probe_mmd, MDIO_DEVS1);
-	devs2 = efx_mdio_read(efx, probe_mmd, MDIO_DEVS2);
-	if (devs1 < 0 || devs2 < 0) {
-		netif_err(efx, hw, efx->net_dev,
-			  "failed to read devices present\n");
-		return -EIO;
-	}
-	devices = devs1 | (devs2 << 16);
-	if ((devices & mmd_mask) != mmd_mask) {
-		netif_err(efx, hw, efx->net_dev,
-			  "required MMDs not present: got %x, wanted %x\n",
-			  devices, mmd_mask);
-		return -ENODEV;
-	}
-	netif_vdbg(efx, hw, efx->net_dev, "Devices present: %x\n", devices);
-
-	/* Check all required MMDs are responding and happy. */
-	while (mmd_mask) {
-		if ((mmd_mask & 1) && efx_mdio_check_mmd(efx, mmd))
-			return -EIO;
-		mmd_mask = mmd_mask >> 1;
-		mmd++;
-	}
-
-	return 0;
-}
-
-bool efx_mdio_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
-{
-	/* If the port is in loopback, then we should only consider a subset
-	 * of mmd's */
-	if (LOOPBACK_INTERNAL(efx))
-		return true;
-	else if (LOOPBACK_MASK(efx) & LOOPBACKS_WS)
-		return false;
-	else if (efx_phy_mode_disabled(efx->phy_mode))
-		return false;
-	else if (efx->loopback_mode == LOOPBACK_PHYXS)
-		mmd_mask &= ~(MDIO_DEVS_PHYXS |
-			      MDIO_DEVS_PCS |
-			      MDIO_DEVS_PMAPMD |
-			      MDIO_DEVS_AN);
-	else if (efx->loopback_mode == LOOPBACK_PCS)
-		mmd_mask &= ~(MDIO_DEVS_PCS |
-			      MDIO_DEVS_PMAPMD |
-			      MDIO_DEVS_AN);
-	else if (efx->loopback_mode == LOOPBACK_PMAPMD)
-		mmd_mask &= ~(MDIO_DEVS_PMAPMD |
-			      MDIO_DEVS_AN);
-
-	return mdio45_links_ok(&efx->mdio, mmd_mask);
-}
-
-void efx_mdio_transmit_disable(struct efx_nic *efx)
-{
-	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD,
-			  MDIO_PMA_TXDIS, MDIO_PMD_TXDIS_GLOBAL,
-			  efx->phy_mode & PHY_MODE_TX_DISABLED);
-}
-
-void efx_mdio_phy_reconfigure(struct efx_nic *efx)
-{
-	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD,
-			  MDIO_CTRL1, MDIO_PMA_CTRL1_LOOPBACK,
-			  efx->loopback_mode == LOOPBACK_PMAPMD);
-	efx_mdio_set_flag(efx, MDIO_MMD_PCS,
-			  MDIO_CTRL1, MDIO_PCS_CTRL1_LOOPBACK,
-			  efx->loopback_mode == LOOPBACK_PCS);
-	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS,
-			  MDIO_CTRL1, MDIO_PHYXS_CTRL1_LOOPBACK,
-			  efx->loopback_mode == LOOPBACK_PHYXS_WS);
-}
-
-static void efx_mdio_set_mmd_lpower(struct efx_nic *efx,
-				    int lpower, int mmd)
-{
-	int stat = efx_mdio_read(efx, mmd, MDIO_STAT1);
-
-	netif_vdbg(efx, drv, efx->net_dev, "Setting low power mode for MMD %d to %d\n",
-		  mmd, lpower);
-
-	if (stat & MDIO_STAT1_LPOWERABLE) {
-		efx_mdio_set_flag(efx, mmd, MDIO_CTRL1,
-				  MDIO_CTRL1_LPOWER, lpower);
-	}
-}
-
-void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
-			      int low_power, unsigned int mmd_mask)
-{
-	int mmd = 0;
-	mmd_mask &= ~MDIO_DEVS_AN;
-	while (mmd_mask) {
-		if (mmd_mask & 1)
-			efx_mdio_set_mmd_lpower(efx, low_power, mmd);
-		mmd_mask = (mmd_mask >> 1);
-		mmd++;
-	}
-}
-
-/**
- * efx_mdio_set_settings - Set (some of) the PHY settings over MDIO.
- * @efx:		Efx NIC
- * @ecmd:		New settings
- */
-int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	struct ethtool_cmd prev = { .cmd = ETHTOOL_GSET };
-
-	efx->phy_op->get_settings(efx, &prev);
-
-	if (ecmd->advertising == prev.advertising &&
-	    ethtool_cmd_speed(ecmd) == ethtool_cmd_speed(&prev) &&
-	    ecmd->duplex == prev.duplex &&
-	    ecmd->port == prev.port &&
-	    ecmd->autoneg == prev.autoneg)
-		return 0;
-
-	/* We can only change these settings for -T PHYs */
-	if (prev.port != PORT_TP || ecmd->port != PORT_TP)
-		return -EINVAL;
-
-	/* Check that PHY supports these settings */
-	if (!ecmd->autoneg ||
-	    (ecmd->advertising | SUPPORTED_Autoneg) & ~prev.supported)
-		return -EINVAL;
-
-	efx_link_set_advertising(efx, ecmd->advertising | ADVERTISED_Autoneg);
-	efx_mdio_an_reconfigure(efx);
-	return 0;
-}
-
-/**
- * efx_mdio_an_reconfigure - Push advertising flags and restart autonegotiation
- * @efx:		Efx NIC
- */
-void efx_mdio_an_reconfigure(struct efx_nic *efx)
-{
-	int reg;
-
-	WARN_ON(!(efx->mdio.mmds & MDIO_DEVS_AN));
-
-	/* Set up the base page */
-	reg = ADVERTISE_CSMA | ADVERTISE_RESV;
-	if (efx->link_advertising & ADVERTISED_Pause)
-		reg |= ADVERTISE_PAUSE_CAP;
-	if (efx->link_advertising & ADVERTISED_Asym_Pause)
-		reg |= ADVERTISE_PAUSE_ASYM;
-	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
-
-	/* Set up the (extended) next page */
-	efx->phy_op->set_npage_adv(efx, efx->link_advertising);
-
-	/* Enable and restart AN */
-	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
-	reg |= MDIO_AN_CTRL1_ENABLE | MDIO_AN_CTRL1_RESTART | MDIO_AN_CTRL1_XNP;
-	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
-}
-
-u8 efx_mdio_get_pause(struct efx_nic *efx)
-{
-	BUILD_BUG_ON(EFX_FC_AUTO & (EFX_FC_RX | EFX_FC_TX));
-
-	if (!(efx->wanted_fc & EFX_FC_AUTO))
-		return efx->wanted_fc;
-
-	WARN_ON(!(efx->mdio.mmds & MDIO_DEVS_AN));
-
-	return mii_resolve_flowctrl_fdx(
-		mii_advertise_flowctrl(efx->wanted_fc),
-		efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_LPA));
-}
-
-int efx_mdio_test_alive(struct efx_nic *efx)
-{
-	int rc;
-	int devad = __ffs(efx->mdio.mmds);
-	u16 physid1, physid2;
-
-	mutex_lock(&efx->mac_lock);
-
-	physid1 = efx_mdio_read(efx, devad, MDIO_DEVID1);
-	physid2 = efx_mdio_read(efx, devad, MDIO_DEVID2);
-
-	if ((physid1 == 0x0000) || (physid1 == 0xffff) ||
-	    (physid2 == 0x0000) || (physid2 == 0xffff)) {
-		netif_err(efx, hw, efx->net_dev,
-			  "no MDIO PHY present with ID %d\n", efx->mdio.prtad);
-		rc = -EINVAL;
-	} else {
-		rc = efx_mdio_check_mmds(efx, efx->mdio.mmds);
-	}
-
-	mutex_unlock(&efx->mac_lock);
-	return rc;
-}
diff --git a/drivers/net/ethernet/sfc/mdio_10g.h b/drivers/net/ethernet/sfc/mdio_10g.h
deleted file mode 100644
index 4a2dc4c..0000000
--- a/drivers/net/ethernet/sfc/mdio_10g.h
+++ /dev/null
@@ -1,110 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2006-2011 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_MDIO_10G_H
-#define EFX_MDIO_10G_H
-
-#include <linux/mdio.h>
-
-/*
- * Helper functions for doing 10G MDIO as specified in IEEE 802.3 clause 45.
- */
-
-#include "efx.h"
-
-static inline unsigned efx_mdio_id_rev(u32 id) { return id & 0xf; }
-static inline unsigned efx_mdio_id_model(u32 id) { return (id >> 4) & 0x3f; }
-unsigned efx_mdio_id_oui(u32 id);
-
-static inline int efx_mdio_read(struct efx_nic *efx, int devad, int addr)
-{
-	return efx->mdio.mdio_read(efx->net_dev, efx->mdio.prtad, devad, addr);
-}
-
-static inline void
-efx_mdio_write(struct efx_nic *efx, int devad, int addr, int value)
-{
-	efx->mdio.mdio_write(efx->net_dev, efx->mdio.prtad, devad, addr, value);
-}
-
-static inline u32 efx_mdio_read_id(struct efx_nic *efx, int mmd)
-{
-	u16 id_low = efx_mdio_read(efx, mmd, MDIO_DEVID2);
-	u16 id_hi = efx_mdio_read(efx, mmd, MDIO_DEVID1);
-	return (id_hi << 16) | (id_low);
-}
-
-static inline bool efx_mdio_phyxgxs_lane_sync(struct efx_nic *efx)
-{
-	int i, lane_status;
-	bool sync;
-
-	for (i = 0; i < 2; ++i)
-		lane_status = efx_mdio_read(efx, MDIO_MMD_PHYXS,
-					    MDIO_PHYXS_LNSTAT);
-
-	sync = !!(lane_status & MDIO_PHYXS_LNSTAT_ALIGN);
-	if (!sync)
-		netif_dbg(efx, hw, efx->net_dev, "XGXS lane status: %x\n",
-			  lane_status);
-	return sync;
-}
-
-const char *efx_mdio_mmd_name(int mmd);
-
-/*
- * Reset a specific MMD and wait for reset to clear.
- * Return number of spins left (>0) on success, -%ETIMEDOUT on failure.
- *
- * This function will sleep
- */
-int efx_mdio_reset_mmd(struct efx_nic *efx, int mmd, int spins, int spintime);
-
-/* As efx_mdio_check_mmd but for multiple MMDs */
-int efx_mdio_check_mmds(struct efx_nic *efx, unsigned int mmd_mask);
-
-/* Check the link status of specified mmds in bit mask */
-bool efx_mdio_links_ok(struct efx_nic *efx, unsigned int mmd_mask);
-
-/* Generic transmit disable support though PMAPMD */
-void efx_mdio_transmit_disable(struct efx_nic *efx);
-
-/* Generic part of reconfigure: set/clear loopback bits */
-void efx_mdio_phy_reconfigure(struct efx_nic *efx);
-
-/* Set the power state of the specified MMDs */
-void efx_mdio_set_mmds_lpower(struct efx_nic *efx, int low_power,
-			      unsigned int mmd_mask);
-
-/* Set (some of) the PHY settings over MDIO */
-int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd);
-
-/* Push advertising flags and restart autonegotiation */
-void efx_mdio_an_reconfigure(struct efx_nic *efx);
-
-/* Get pause parameters from AN if available (otherwise return
- * requested pause parameters)
- */
-u8 efx_mdio_get_pause(struct efx_nic *efx);
-
-/* Wait for specified MMDs to exit reset within a timeout */
-int efx_mdio_wait_reset_mmds(struct efx_nic *efx, unsigned int mmd_mask);
-
-/* Set or clear flag, debouncing */
-static inline void
-efx_mdio_set_flag(struct efx_nic *efx, int devad, int addr,
-		  int mask, bool state)
-{
-	mdio_set_flag(&efx->mdio, efx->mdio.prtad, devad, addr, mask, state);
-}
-
-/* Liveness self-test for MDIO PHYs */
-int efx_mdio_test_alive(struct efx_nic *efx);
-
-#endif /* EFX_MDIO_10G_H */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 18aceb2..0bbd7e2 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -41,7 +41,7 @@
  *
  **************************************************************************/
 
-#define EFX_DRIVER_VERSION	"4.0"
+#define EFX_DRIVER_VERSION	"4.1"
 
 #ifdef DEBUG
 #define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
@@ -191,7 +191,6 @@ struct efx_tx_buffer {
  *	Size of the region is efx_piobuf_size.
  * @piobuf_offset: Buffer offset to be specified in PIO descriptors
  * @initialised: Has hardware queue been initialised?
- * @tx_min_size: Minimum transmit size for this queue. Depends on HW.
  * @handle_tso: TSO xmit preparation handler.  Sets up the TSO metadata and
  *	may also map tx data, depending on the nature of the TSO implementation.
  * @read_count: Current read pointer.
@@ -242,7 +241,6 @@ struct efx_tx_queue {
 	void __iomem *piobuf;
 	unsigned int piobuf_offset;
 	bool initialised;
-	unsigned int tx_min_size;
 
 	/* Function pointers used in the fast path. */
 	int (*handle_tso)(struct efx_tx_queue*, struct sk_buff*, bool *);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 06dd96e..2237746 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -18,11 +18,8 @@
 #include "mcdi.h"
 
 enum {
-	EFX_REV_FALCON_A0 = 0,
-	EFX_REV_FALCON_A1 = 1,
-	EFX_REV_FALCON_B0 = 2,
-	EFX_REV_SIENA_A0 = 3,
-	EFX_REV_HUNT_A0 = 4,
+	EFX_REV_SIENA_A0 = 0,
+	EFX_REV_HUNT_A0 = 1,
 };
 
 static inline int efx_nic_rev(struct efx_nic *efx)
@@ -32,12 +29,6 @@ static inline int efx_nic_rev(struct efx_nic *efx)
 
 u32 efx_farch_fpga_ver(struct efx_nic *efx);
 
-/* NIC has two interlinked PCI functions for the same port. */
-static inline bool efx_nic_is_dual_func(struct efx_nic *efx)
-{
-	return efx_nic_rev(efx) < EFX_REV_FALCON_B0;
-}
-
 /* Read the current event from the event queue */
 static inline efx_qword_t *efx_event(struct efx_channel *channel,
 				     unsigned int index)
@@ -144,11 +135,6 @@ enum {
 	PHY_TYPE_SFT9001B = 10,
 };
 
-#define FALCON_XMAC_LOOPBACKS			\
-	((1 << LOOPBACK_XGMII) |		\
-	 (1 << LOOPBACK_XGXS) |			\
-	 (1 << LOOPBACK_XAUI))
-
 /* Alignment of PCIe DMA boundaries (4KB) */
 #define EFX_PAGE_SIZE	4096
 /* Size and alignment of buffer table entries (same) */
@@ -161,160 +147,6 @@ enum {
 	GENERIC_STAT_COUNT
 };
 
-/**
- * struct falcon_board_type - board operations and type information
- * @id: Board type id, as found in NVRAM
- * @init: Allocate resources and initialise peripheral hardware
- * @init_phy: Do board-specific PHY initialisation
- * @fini: Shut down hardware and free resources
- * @set_id_led: Set state of identifying LED or revert to automatic function
- * @monitor: Board-specific health check function
- */
-struct falcon_board_type {
-	u8 id;
-	int (*init) (struct efx_nic *nic);
-	void (*init_phy) (struct efx_nic *efx);
-	void (*fini) (struct efx_nic *nic);
-	void (*set_id_led) (struct efx_nic *efx, enum efx_led_mode mode);
-	int (*monitor) (struct efx_nic *nic);
-};
-
-/**
- * struct falcon_board - board information
- * @type: Type of board
- * @major: Major rev. ('A', 'B' ...)
- * @minor: Minor rev. (0, 1, ...)
- * @i2c_adap: I2C adapter for on-board peripherals
- * @i2c_data: Data for bit-banging algorithm
- * @hwmon_client: I2C client for hardware monitor
- * @ioexp_client: I2C client for power/port control
- */
-struct falcon_board {
-	const struct falcon_board_type *type;
-	int major;
-	int minor;
-	struct i2c_adapter i2c_adap;
-	struct i2c_algo_bit_data i2c_data;
-	struct i2c_client *hwmon_client, *ioexp_client;
-};
-
-/**
- * struct falcon_spi_device - a Falcon SPI (Serial Peripheral Interface) device
- * @device_id:		Controller's id for the device
- * @size:		Size (in bytes)
- * @addr_len:		Number of address bytes in read/write commands
- * @munge_address:	Flag whether addresses should be munged.
- *	Some devices with 9-bit addresses (e.g. AT25040A EEPROM)
- *	use bit 3 of the command byte as address bit A8, rather
- *	than having a two-byte address.  If this flag is set, then
- *	commands should be munged in this way.
- * @erase_command:	Erase command (or 0 if sector erase not needed).
- * @erase_size:		Erase sector size (in bytes)
- *	Erase commands affect sectors with this size and alignment.
- *	This must be a power of two.
- * @block_size:		Write block size (in bytes).
- *	Write commands are limited to blocks with this size and alignment.
- */
-struct falcon_spi_device {
-	int device_id;
-	unsigned int size;
-	unsigned int addr_len;
-	unsigned int munge_address:1;
-	u8 erase_command;
-	unsigned int erase_size;
-	unsigned int block_size;
-};
-
-static inline bool falcon_spi_present(const struct falcon_spi_device *spi)
-{
-	return spi->size != 0;
-}
-
-enum {
-	FALCON_STAT_tx_bytes = GENERIC_STAT_COUNT,
-	FALCON_STAT_tx_packets,
-	FALCON_STAT_tx_pause,
-	FALCON_STAT_tx_control,
-	FALCON_STAT_tx_unicast,
-	FALCON_STAT_tx_multicast,
-	FALCON_STAT_tx_broadcast,
-	FALCON_STAT_tx_lt64,
-	FALCON_STAT_tx_64,
-	FALCON_STAT_tx_65_to_127,
-	FALCON_STAT_tx_128_to_255,
-	FALCON_STAT_tx_256_to_511,
-	FALCON_STAT_tx_512_to_1023,
-	FALCON_STAT_tx_1024_to_15xx,
-	FALCON_STAT_tx_15xx_to_jumbo,
-	FALCON_STAT_tx_gtjumbo,
-	FALCON_STAT_tx_non_tcpudp,
-	FALCON_STAT_tx_mac_src_error,
-	FALCON_STAT_tx_ip_src_error,
-	FALCON_STAT_rx_bytes,
-	FALCON_STAT_rx_good_bytes,
-	FALCON_STAT_rx_bad_bytes,
-	FALCON_STAT_rx_packets,
-	FALCON_STAT_rx_good,
-	FALCON_STAT_rx_bad,
-	FALCON_STAT_rx_pause,
-	FALCON_STAT_rx_control,
-	FALCON_STAT_rx_unicast,
-	FALCON_STAT_rx_multicast,
-	FALCON_STAT_rx_broadcast,
-	FALCON_STAT_rx_lt64,
-	FALCON_STAT_rx_64,
-	FALCON_STAT_rx_65_to_127,
-	FALCON_STAT_rx_128_to_255,
-	FALCON_STAT_rx_256_to_511,
-	FALCON_STAT_rx_512_to_1023,
-	FALCON_STAT_rx_1024_to_15xx,
-	FALCON_STAT_rx_15xx_to_jumbo,
-	FALCON_STAT_rx_gtjumbo,
-	FALCON_STAT_rx_bad_lt64,
-	FALCON_STAT_rx_bad_gtjumbo,
-	FALCON_STAT_rx_overflow,
-	FALCON_STAT_rx_symbol_error,
-	FALCON_STAT_rx_align_error,
-	FALCON_STAT_rx_length_error,
-	FALCON_STAT_rx_internal_error,
-	FALCON_STAT_rx_nodesc_drop_cnt,
-	FALCON_STAT_COUNT
-};
-
-/**
- * struct falcon_nic_data - Falcon NIC state
- * @pci_dev2: Secondary function of Falcon A
- * @board: Board state and functions
- * @stats: Hardware statistics
- * @stats_disable_count: Nest count for disabling statistics fetches
- * @stats_pending: Is there a pending DMA of MAC statistics.
- * @stats_timer: A timer for regularly fetching MAC statistics.
- * @spi_flash: SPI flash device
- * @spi_eeprom: SPI EEPROM device
- * @spi_lock: SPI bus lock
- * @mdio_lock: MDIO bus lock
- * @xmac_poll_required: XMAC link state needs polling
- */
-struct falcon_nic_data {
-	struct pci_dev *pci_dev2;
-	struct falcon_board board;
-	u64 stats[FALCON_STAT_COUNT];
-	unsigned int stats_disable_count;
-	bool stats_pending;
-	struct timer_list stats_timer;
-	struct falcon_spi_device spi_flash;
-	struct falcon_spi_device spi_eeprom;
-	struct mutex spi_lock;
-	struct mutex mdio_lock;
-	bool xmac_poll_required;
-};
-
-static inline struct falcon_board *falcon_board(struct efx_nic *efx)
-{
-	struct falcon_nic_data *data = efx->nic_data;
-	return &data->board;
-}
-
 enum {
 	SIENA_STAT_tx_bytes = GENERIC_STAT_COUNT,
 	SIENA_STAT_tx_good_bytes,
diff --git a/drivers/net/ethernet/sfc/phy.h b/drivers/net/ethernet/sfc/phy.h
deleted file mode 100644
index 803bf44..0000000
--- a/drivers/net/ethernet/sfc/phy.h
+++ /dev/null
@@ -1,50 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2007-2010 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_PHY_H
-#define EFX_PHY_H
-
-/****************************************************************************
- * 10Xpress (SFX7101) PHY
- */
-extern const struct efx_phy_operations falcon_sfx7101_phy_ops;
-
-void tenxpress_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
-
-/****************************************************************************
- * AMCC/Quake QT202x PHYs
- */
-extern const struct efx_phy_operations falcon_qt202x_phy_ops;
-
-/* These PHYs provide various H/W control states for LEDs */
-#define QUAKE_LED_LINK_INVAL	(0)
-#define QUAKE_LED_LINK_STAT	(1)
-#define QUAKE_LED_LINK_ACT	(2)
-#define QUAKE_LED_LINK_ACTSTAT	(3)
-#define QUAKE_LED_OFF		(4)
-#define QUAKE_LED_ON		(5)
-#define QUAKE_LED_LINK_INPUT	(6)	/* Pin is an input. */
-/* What link the LED tracks */
-#define QUAKE_LED_TXLINK	(0)
-#define QUAKE_LED_RXLINK	(8)
-
-void falcon_qt202x_set_led(struct efx_nic *p, int led, int state);
-
-/****************************************************************************
-* Transwitch CX4 retimer
-*/
-extern const struct efx_phy_operations falcon_txc_phy_ops;
-
-#define TXC_GPIO_DIR_INPUT	0
-#define TXC_GPIO_DIR_OUTPUT	1
-
-void falcon_txc_set_gpio_dir(struct efx_nic *efx, int pin, int dir);
-void falcon_txc_set_gpio_val(struct efx_nic *efx, int pin, int val);
-
-#endif
diff --git a/drivers/net/ethernet/sfc/qt202x_phy.c b/drivers/net/ethernet/sfc/qt202x_phy.c
deleted file mode 100644
index efa3612..0000000
--- a/drivers/net/ethernet/sfc/qt202x_phy.c
+++ /dev/null
@@ -1,495 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2006-2012 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-/*
- * Driver for AMCC QT202x SFP+ and XFP adapters; see www.amcc.com for details
- */
-
-#include <linux/slab.h>
-#include <linux/timer.h>
-#include <linux/delay.h>
-#include "efx.h"
-#include "mdio_10g.h"
-#include "phy.h"
-#include "nic.h"
-
-#define QT202X_REQUIRED_DEVS (MDIO_DEVS_PCS |		\
-			      MDIO_DEVS_PMAPMD |	\
-			      MDIO_DEVS_PHYXS)
-
-#define QT202X_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
-			  (1 << LOOPBACK_PMAPMD) |	\
-			  (1 << LOOPBACK_PHYXS_WS))
-
-/****************************************************************************/
-/* Quake-specific MDIO registers */
-#define MDIO_QUAKE_LED0_REG	(0xD006)
-
-/* QT2025C only */
-#define PCS_FW_HEARTBEAT_REG	0xd7ee
-#define PCS_FW_HEARTB_LBN	0
-#define PCS_FW_HEARTB_WIDTH	8
-#define PCS_FW_PRODUCT_CODE_1	0xd7f0
-#define PCS_FW_VERSION_1	0xd7f3
-#define PCS_FW_BUILD_1		0xd7f6
-#define PCS_UC8051_STATUS_REG	0xd7fd
-#define PCS_UC_STATUS_LBN	0
-#define PCS_UC_STATUS_WIDTH	8
-#define PCS_UC_STATUS_FW_SAVE	0x20
-#define PMA_PMD_MODE_REG	0xc301
-#define PMA_PMD_RXIN_SEL_LBN	6
-#define PMA_PMD_FTX_CTRL2_REG	0xc309
-#define PMA_PMD_FTX_STATIC_LBN	13
-#define PMA_PMD_VEND1_REG	0xc001
-#define PMA_PMD_VEND1_LBTXD_LBN	15
-#define PCS_VEND1_REG		0xc000
-#define PCS_VEND1_LBTXD_LBN	5
-
-void falcon_qt202x_set_led(struct efx_nic *p, int led, int mode)
-{
-	int addr = MDIO_QUAKE_LED0_REG + led;
-	efx_mdio_write(p, MDIO_MMD_PMAPMD, addr, mode);
-}
-
-struct qt202x_phy_data {
-	enum efx_phy_mode phy_mode;
-	bool bug17190_in_bad_state;
-	unsigned long bug17190_timer;
-	u32 firmware_ver;
-};
-
-#define QT2022C2_MAX_RESET_TIME 500
-#define QT2022C2_RESET_WAIT 10
-
-#define QT2025C_MAX_HEARTB_TIME (5 * HZ)
-#define QT2025C_HEARTB_WAIT 100
-#define QT2025C_MAX_FWSTART_TIME (25 * HZ / 10)
-#define QT2025C_FWSTART_WAIT 100
-
-#define BUG17190_INTERVAL (2 * HZ)
-
-static int qt2025c_wait_heartbeat(struct efx_nic *efx)
-{
-	unsigned long timeout = jiffies + QT2025C_MAX_HEARTB_TIME;
-	int reg, old_counter = 0;
-
-	/* Wait for firmware heartbeat to start */
-	for (;;) {
-		int counter;
-		reg = efx_mdio_read(efx, MDIO_MMD_PCS, PCS_FW_HEARTBEAT_REG);
-		if (reg < 0)
-			return reg;
-		counter = ((reg >> PCS_FW_HEARTB_LBN) &
-			    ((1 << PCS_FW_HEARTB_WIDTH) - 1));
-		if (old_counter == 0)
-			old_counter = counter;
-		else if (counter != old_counter)
-			break;
-		if (time_after(jiffies, timeout)) {
-			/* Some cables have EEPROMs that conflict with the
-			 * PHY's on-board EEPROM so it cannot load firmware */
-			netif_err(efx, hw, efx->net_dev,
-				  "If an SFP+ direct attach cable is"
-				  " connected, please check that it complies"
-				  " with the SFP+ specification\n");
-			return -ETIMEDOUT;
-		}
-		msleep(QT2025C_HEARTB_WAIT);
-	}
-
-	return 0;
-}
-
-static int qt2025c_wait_fw_status_good(struct efx_nic *efx)
-{
-	unsigned long timeout = jiffies + QT2025C_MAX_FWSTART_TIME;
-	int reg;
-
-	/* Wait for firmware status to look good */
-	for (;;) {
-		reg = efx_mdio_read(efx, MDIO_MMD_PCS, PCS_UC8051_STATUS_REG);
-		if (reg < 0)
-			return reg;
-		if ((reg &
-		     ((1 << PCS_UC_STATUS_WIDTH) - 1) << PCS_UC_STATUS_LBN) >=
-		    PCS_UC_STATUS_FW_SAVE)
-			break;
-		if (time_after(jiffies, timeout))
-			return -ETIMEDOUT;
-		msleep(QT2025C_FWSTART_WAIT);
-	}
-
-	return 0;
-}
-
-static void qt2025c_restart_firmware(struct efx_nic *efx)
-{
-	/* Restart microcontroller execution of firmware from RAM */
-	efx_mdio_write(efx, 3, 0xe854, 0x00c0);
-	efx_mdio_write(efx, 3, 0xe854, 0x0040);
-	msleep(50);
-}
-
-static int qt2025c_wait_reset(struct efx_nic *efx)
-{
-	int rc;
-
-	rc = qt2025c_wait_heartbeat(efx);
-	if (rc != 0)
-		return rc;
-
-	rc = qt2025c_wait_fw_status_good(efx);
-	if (rc == -ETIMEDOUT) {
-		/* Bug 17689: occasionally heartbeat starts but firmware status
-		 * code never progresses beyond 0x00.  Try again, once, after
-		 * restarting execution of the firmware image. */
-		netif_dbg(efx, hw, efx->net_dev,
-			  "bashing QT2025C microcontroller\n");
-		qt2025c_restart_firmware(efx);
-		rc = qt2025c_wait_heartbeat(efx);
-		if (rc != 0)
-			return rc;
-		rc = qt2025c_wait_fw_status_good(efx);
-	}
-
-	return rc;
-}
-
-static void qt2025c_firmware_id(struct efx_nic *efx)
-{
-	struct qt202x_phy_data *phy_data = efx->phy_data;
-	u8 firmware_id[9];
-	size_t i;
-
-	for (i = 0; i < sizeof(firmware_id); i++)
-		firmware_id[i] = efx_mdio_read(efx, MDIO_MMD_PCS,
-					       PCS_FW_PRODUCT_CODE_1 + i);
-	netif_info(efx, probe, efx->net_dev,
-		   "QT2025C firmware %xr%d v%d.%d.%d.%d [20%02d-%02d-%02d]\n",
-		   (firmware_id[0] << 8) | firmware_id[1], firmware_id[2],
-		   firmware_id[3] >> 4, firmware_id[3] & 0xf,
-		   firmware_id[4], firmware_id[5],
-		   firmware_id[6], firmware_id[7], firmware_id[8]);
-	phy_data->firmware_ver = ((firmware_id[3] & 0xf0) << 20) |
-				 ((firmware_id[3] & 0x0f) << 16) |
-				 (firmware_id[4] << 8) | firmware_id[5];
-}
-
-static void qt2025c_bug17190_workaround(struct efx_nic *efx)
-{
-	struct qt202x_phy_data *phy_data = efx->phy_data;
-
-	/* The PHY can get stuck in a state where it reports PHY_XS and PMA/PMD
-	 * layers up, but PCS down (no block_lock).  If we notice this state
-	 * persisting for a couple of seconds, we switch PMA/PMD loopback
-	 * briefly on and then off again, which is normally sufficient to
-	 * recover it.
-	 */
-	if (efx->link_state.up ||
-	    !efx_mdio_links_ok(efx, MDIO_DEVS_PMAPMD | MDIO_DEVS_PHYXS)) {
-		phy_data->bug17190_in_bad_state = false;
-		return;
-	}
-
-	if (!phy_data->bug17190_in_bad_state) {
-		phy_data->bug17190_in_bad_state = true;
-		phy_data->bug17190_timer = jiffies + BUG17190_INTERVAL;
-		return;
-	}
-
-	if (time_after_eq(jiffies, phy_data->bug17190_timer)) {
-		netif_dbg(efx, hw, efx->net_dev, "bashing QT2025C PMA/PMD\n");
-		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1,
-				  MDIO_PMA_CTRL1_LOOPBACK, true);
-		msleep(100);
-		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1,
-				  MDIO_PMA_CTRL1_LOOPBACK, false);
-		phy_data->bug17190_timer = jiffies + BUG17190_INTERVAL;
-	}
-}
-
-static int qt2025c_select_phy_mode(struct efx_nic *efx)
-{
-	struct qt202x_phy_data *phy_data = efx->phy_data;
-	struct falcon_board *board = falcon_board(efx);
-	int reg, rc, i;
-	uint16_t phy_op_mode;
-
-	/* Only 2.0.1.0+ PHY firmware supports the more optimal SFP+
-	 * Self-Configure mode.  Don't attempt any switching if we encounter
-	 * older firmware. */
-	if (phy_data->firmware_ver < 0x02000100)
-		return 0;
-
-	/* In general we will get optimal behaviour in "SFP+ Self-Configure"
-	 * mode; however, that powers down most of the PHY when no module is
-	 * present, so we must use a different mode (any fixed mode will do)
-	 * to be sure that loopbacks will work. */
-	phy_op_mode = (efx->loopback_mode == LOOPBACK_NONE) ? 0x0038 : 0x0020;
-
-	/* Only change mode if really necessary */
-	reg = efx_mdio_read(efx, 1, 0xc319);
-	if ((reg & 0x0038) == phy_op_mode)
-		return 0;
-	netif_dbg(efx, hw, efx->net_dev, "Switching PHY to mode 0x%04x\n",
-		  phy_op_mode);
-
-	/* This sequence replicates the register writes configured in the boot
-	 * EEPROM (including the differences between board revisions), except
-	 * that the operating mode is changed, and the PHY is prevented from
-	 * unnecessarily reloading the main firmware image again. */
-	efx_mdio_write(efx, 1, 0xc300, 0x0000);
-	/* (Note: this portion of the boot EEPROM sequence, which bit-bashes 9
-	 * STOPs onto the firmware/module I2C bus to reset it, varies across
-	 * board revisions, as the bus is connected to different GPIO/LED
-	 * outputs on the PHY.) */
-	if (board->major == 0 && board->minor < 2) {
-		efx_mdio_write(efx, 1, 0xc303, 0x4498);
-		for (i = 0; i < 9; i++) {
-			efx_mdio_write(efx, 1, 0xc303, 0x4488);
-			efx_mdio_write(efx, 1, 0xc303, 0x4480);
-			efx_mdio_write(efx, 1, 0xc303, 0x4490);
-			efx_mdio_write(efx, 1, 0xc303, 0x4498);
-		}
-	} else {
-		efx_mdio_write(efx, 1, 0xc303, 0x0920);
-		efx_mdio_write(efx, 1, 0xd008, 0x0004);
-		for (i = 0; i < 9; i++) {
-			efx_mdio_write(efx, 1, 0xc303, 0x0900);
-			efx_mdio_write(efx, 1, 0xd008, 0x0005);
-			efx_mdio_write(efx, 1, 0xc303, 0x0920);
-			efx_mdio_write(efx, 1, 0xd008, 0x0004);
-		}
-		efx_mdio_write(efx, 1, 0xc303, 0x4900);
-	}
-	efx_mdio_write(efx, 1, 0xc303, 0x4900);
-	efx_mdio_write(efx, 1, 0xc302, 0x0004);
-	efx_mdio_write(efx, 1, 0xc316, 0x0013);
-	efx_mdio_write(efx, 1, 0xc318, 0x0054);
-	efx_mdio_write(efx, 1, 0xc319, phy_op_mode);
-	efx_mdio_write(efx, 1, 0xc31a, 0x0098);
-	efx_mdio_write(efx, 3, 0x0026, 0x0e00);
-	efx_mdio_write(efx, 3, 0x0027, 0x0013);
-	efx_mdio_write(efx, 3, 0x0028, 0xa528);
-	efx_mdio_write(efx, 1, 0xd006, 0x000a);
-	efx_mdio_write(efx, 1, 0xd007, 0x0009);
-	efx_mdio_write(efx, 1, 0xd008, 0x0004);
-	/* This additional write is not present in the boot EEPROM.  It
-	 * prevents the PHY's internal boot ROM doing another pointless (and
-	 * slow) reload of the firmware image (the microcontroller's code
-	 * memory is not affected by the microcontroller reset). */
-	efx_mdio_write(efx, 1, 0xc317, 0x00ff);
-	/* PMA/PMD loopback sets RXIN to inverse polarity and the firmware
-	 * restart doesn't reset it. We need to do that ourselves. */
-	efx_mdio_set_flag(efx, 1, PMA_PMD_MODE_REG,
-			  1 << PMA_PMD_RXIN_SEL_LBN, false);
-	efx_mdio_write(efx, 1, 0xc300, 0x0002);
-	msleep(20);
-
-	/* Restart microcontroller execution of firmware from RAM */
-	qt2025c_restart_firmware(efx);
-
-	/* Wait for the microcontroller to be ready again */
-	rc = qt2025c_wait_reset(efx);
-	if (rc < 0) {
-		netif_err(efx, hw, efx->net_dev,
-			  "PHY microcontroller reset during mode switch "
-			  "timed out\n");
-		return rc;
-	}
-
-	return 0;
-}
-
-static int qt202x_reset_phy(struct efx_nic *efx)
-{
-	int rc;
-
-	if (efx->phy_type == PHY_TYPE_QT2025C) {
-		/* Wait for the reset triggered by falcon_reset_hw()
-		 * to complete */
-		rc = qt2025c_wait_reset(efx);
-		if (rc < 0)
-			goto fail;
-	} else {
-		/* Reset the PHYXS MMD. This is documented as doing
-		 * a complete soft reset. */
-		rc = efx_mdio_reset_mmd(efx, MDIO_MMD_PHYXS,
-					QT2022C2_MAX_RESET_TIME /
-					QT2022C2_RESET_WAIT,
-					QT2022C2_RESET_WAIT);
-		if (rc < 0)
-			goto fail;
-	}
-
-	/* Wait 250ms for the PHY to complete bootup */
-	msleep(250);
-
-	falcon_board(efx)->type->init_phy(efx);
-
-	return 0;
-
- fail:
-	netif_err(efx, hw, efx->net_dev, "PHY reset timed out\n");
-	return rc;
-}
-
-static int qt202x_phy_probe(struct efx_nic *efx)
-{
-	struct qt202x_phy_data *phy_data;
-
-	phy_data = kzalloc(sizeof(struct qt202x_phy_data), GFP_KERNEL);
-	if (!phy_data)
-		return -ENOMEM;
-	efx->phy_data = phy_data;
-	phy_data->phy_mode = efx->phy_mode;
-	phy_data->bug17190_in_bad_state = false;
-	phy_data->bug17190_timer = 0;
-
-	efx->mdio.mmds = QT202X_REQUIRED_DEVS;
-	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
-	efx->loopback_modes = QT202X_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
-	return 0;
-}
-
-static int qt202x_phy_init(struct efx_nic *efx)
-{
-	u32 devid;
-	int rc;
-
-	rc = qt202x_reset_phy(efx);
-	if (rc) {
-		netif_err(efx, probe, efx->net_dev, "PHY init failed\n");
-		return rc;
-	}
-
-	devid = efx_mdio_read_id(efx, MDIO_MMD_PHYXS);
-	netif_info(efx, probe, efx->net_dev,
-		   "PHY ID reg %x (OUI %06x model %02x revision %x)\n",
-		   devid, efx_mdio_id_oui(devid), efx_mdio_id_model(devid),
-		   efx_mdio_id_rev(devid));
-
-	if (efx->phy_type == PHY_TYPE_QT2025C)
-		qt2025c_firmware_id(efx);
-
-	return 0;
-}
-
-static int qt202x_link_ok(struct efx_nic *efx)
-{
-	return efx_mdio_links_ok(efx, QT202X_REQUIRED_DEVS);
-}
-
-static bool qt202x_phy_poll(struct efx_nic *efx)
-{
-	bool was_up = efx->link_state.up;
-
-	efx->link_state.up = qt202x_link_ok(efx);
-	efx->link_state.speed = 10000;
-	efx->link_state.fd = true;
-	efx->link_state.fc = efx->wanted_fc;
-
-	if (efx->phy_type == PHY_TYPE_QT2025C)
-		qt2025c_bug17190_workaround(efx);
-
-	return efx->link_state.up != was_up;
-}
-
-static int qt202x_phy_reconfigure(struct efx_nic *efx)
-{
-	struct qt202x_phy_data *phy_data = efx->phy_data;
-
-	if (efx->phy_type == PHY_TYPE_QT2025C) {
-		int rc = qt2025c_select_phy_mode(efx);
-		if (rc)
-			return rc;
-
-		/* There are several different register bits which can
-		 * disable TX (and save power) on direct-attach cables
-		 * or optical transceivers, varying somewhat between
-		 * firmware versions.  Only 'static mode' appears to
-		 * cover everything. */
-		mdio_set_flag(
-			&efx->mdio, efx->mdio.prtad, MDIO_MMD_PMAPMD,
-			PMA_PMD_FTX_CTRL2_REG, 1 << PMA_PMD_FTX_STATIC_LBN,
-			efx->phy_mode & PHY_MODE_TX_DISABLED ||
-			efx->phy_mode & PHY_MODE_LOW_POWER ||
-			efx->loopback_mode == LOOPBACK_PCS ||
-			efx->loopback_mode == LOOPBACK_PMAPMD);
-	} else {
-		/* Reset the PHY when moving from tx off to tx on */
-		if (!(efx->phy_mode & PHY_MODE_TX_DISABLED) &&
-		    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
-			qt202x_reset_phy(efx);
-
-		efx_mdio_transmit_disable(efx);
-	}
-
-	efx_mdio_phy_reconfigure(efx);
-
-	phy_data->phy_mode = efx->phy_mode;
-
-	return 0;
-}
-
-static void qt202x_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	mdio45_ethtool_gset(&efx->mdio, ecmd);
-}
-
-static void qt202x_phy_remove(struct efx_nic *efx)
-{
-	/* Free the context block */
-	kfree(efx->phy_data);
-	efx->phy_data = NULL;
-}
-
-static int qt202x_phy_get_module_info(struct efx_nic *efx,
-				      struct ethtool_modinfo *modinfo)
-{
-	modinfo->type = ETH_MODULE_SFF_8079;
-	modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
-	return 0;
-}
-
-static int qt202x_phy_get_module_eeprom(struct efx_nic *efx,
-					struct ethtool_eeprom *ee, u8 *data)
-{
-	int mmd, reg_base, rc, i;		
-
-	if (efx->phy_type == PHY_TYPE_QT2025C) {
-		mmd = MDIO_MMD_PCS;
-		reg_base = 0xd000;
-	} else {
-		mmd = MDIO_MMD_PMAPMD;
-		reg_base = 0x8007;
-	}
-
-	for (i = 0; i < ee->len; i++) {
-		rc = efx_mdio_read(efx, mmd, reg_base + ee->offset + i);
-		if (rc < 0)
-			return rc;
-		data[i] = rc;
-	}
-
-	return 0;
-}
-
-const struct efx_phy_operations falcon_qt202x_phy_ops = {
-	.probe		 = qt202x_phy_probe,
-	.init		 = qt202x_phy_init,
-	.reconfigure	 = qt202x_phy_reconfigure,
-	.poll		 = qt202x_phy_poll,
-	.fini		 = efx_port_dummy_op_void,
-	.remove		 = qt202x_phy_remove,
-	.get_settings	 = qt202x_phy_get_settings,
-	.set_settings	 = efx_mdio_set_settings,
-	.test_alive	 = efx_mdio_test_alive,
-	.get_module_eeprom = qt202x_phy_get_module_eeprom,
-	.get_module_info = qt202x_phy_get_module_info,
-};
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 02b0b527..7893a73 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -400,21 +400,10 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 	 */
 	rx_buf->flags |= EFX_RX_PKT_DISCARD;
 
-	if ((len > rx_buf->len) && EFX_WORKAROUND_8071(efx)) {
-		if (net_ratelimit())
-			netif_err(efx, rx_err, efx->net_dev,
-				  " RX queue %d seriously overlength "
-				  "RX event (0x%x > 0x%x+0x%x). Leaking\n",
-				  efx_rx_queue_index(rx_queue), len, max_len,
-				  efx->type->rx_buffer_padding);
-		efx_schedule_reset(efx, RESET_TYPE_RX_RECOVERY);
-	} else {
-		if (net_ratelimit())
-			netif_err(efx, rx_err, efx->net_dev,
-				  " RX queue %d overlength RX event "
-				  "(0x%x > 0x%x)\n",
-				  efx_rx_queue_index(rx_queue), len, max_len);
-	}
+	if (net_ratelimit())
+		netif_err(efx, rx_err, efx->net_dev,
+			  "RX queue %d overlength RX event (%#x > %#x)\n",
+			  efx_rx_queue_index(rx_queue), len, max_len);
 
 	efx_rx_queue_channel(rx_queue)->n_rx_overlength++;
 }
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 3975cad..0c4a8dd 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -20,7 +20,6 @@
 #include "nic.h"
 #include "farch_regs.h"
 #include "io.h"
-#include "phy.h"
 #include "workarounds.h"
 #include "mcdi.h"
 #include "mcdi_pcol.h"
diff --git a/drivers/net/ethernet/sfc/tenxpress.c b/drivers/net/ethernet/sfc/tenxpress.c
deleted file mode 100644
index 2c90e6b..0000000
--- a/drivers/net/ethernet/sfc/tenxpress.c
+++ /dev/null
@@ -1,494 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2007-2011 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#include <linux/delay.h>
-#include <linux/rtnetlink.h>
-#include <linux/seq_file.h>
-#include <linux/slab.h>
-#include "efx.h"
-#include "mdio_10g.h"
-#include "nic.h"
-#include "phy.h"
-#include "workarounds.h"
-
-/* We expect these MMDs to be in the package. */
-#define TENXPRESS_REQUIRED_DEVS (MDIO_DEVS_PMAPMD	| \
-				 MDIO_DEVS_PCS		| \
-				 MDIO_DEVS_PHYXS	| \
-				 MDIO_DEVS_AN)
-
-#define SFX7101_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
-			   (1 << LOOPBACK_PCS) |	\
-			   (1 << LOOPBACK_PMAPMD) |	\
-			   (1 << LOOPBACK_PHYXS_WS))
-
-/* We complain if we fail to see the link partner as 10G capable this many
- * times in a row (must be > 1 as sampling the autoneg. registers is racy)
- */
-#define MAX_BAD_LP_TRIES	(5)
-
-/* Extended control register */
-#define PMA_PMD_XCONTROL_REG	49152
-#define PMA_PMD_EXT_GMII_EN_LBN	1
-#define PMA_PMD_EXT_GMII_EN_WIDTH 1
-#define PMA_PMD_EXT_CLK_OUT_LBN	2
-#define PMA_PMD_EXT_CLK_OUT_WIDTH 1
-#define PMA_PMD_LNPGA_POWERDOWN_LBN 8
-#define PMA_PMD_LNPGA_POWERDOWN_WIDTH 1
-#define PMA_PMD_EXT_CLK312_WIDTH 1
-#define PMA_PMD_EXT_LPOWER_LBN  12
-#define PMA_PMD_EXT_LPOWER_WIDTH 1
-#define PMA_PMD_EXT_ROBUST_LBN	14
-#define PMA_PMD_EXT_ROBUST_WIDTH 1
-#define PMA_PMD_EXT_SSR_LBN	15
-#define PMA_PMD_EXT_SSR_WIDTH	1
-
-/* extended status register */
-#define PMA_PMD_XSTATUS_REG	49153
-#define PMA_PMD_XSTAT_MDIX_LBN	14
-#define PMA_PMD_XSTAT_FLP_LBN   (12)
-
-/* LED control register */
-#define PMA_PMD_LED_CTRL_REG	49159
-#define PMA_PMA_LED_ACTIVITY_LBN	(3)
-
-/* LED function override register */
-#define PMA_PMD_LED_OVERR_REG	49161
-/* Bit positions for different LEDs (there are more but not wired on SFE4001)*/
-#define PMA_PMD_LED_LINK_LBN	(0)
-#define PMA_PMD_LED_SPEED_LBN	(2)
-#define PMA_PMD_LED_TX_LBN	(4)
-#define PMA_PMD_LED_RX_LBN	(6)
-/* Override settings */
-#define	PMA_PMD_LED_AUTO	(0)	/* H/W control */
-#define	PMA_PMD_LED_ON		(1)
-#define	PMA_PMD_LED_OFF		(2)
-#define PMA_PMD_LED_FLASH	(3)
-#define PMA_PMD_LED_MASK	3
-/* All LEDs under hardware control */
-/* Green and Amber under hardware control, Red off */
-#define SFX7101_PMA_PMD_LED_DEFAULT (PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
-
-#define PMA_PMD_SPEED_ENABLE_REG 49192
-#define PMA_PMD_100TX_ADV_LBN    1
-#define PMA_PMD_100TX_ADV_WIDTH  1
-#define PMA_PMD_1000T_ADV_LBN    2
-#define PMA_PMD_1000T_ADV_WIDTH  1
-#define PMA_PMD_10000T_ADV_LBN   3
-#define PMA_PMD_10000T_ADV_WIDTH 1
-#define PMA_PMD_SPEED_LBN        4
-#define PMA_PMD_SPEED_WIDTH      4
-
-/* Misc register defines */
-#define PCS_CLOCK_CTRL_REG	55297
-#define PLL312_RST_N_LBN 2
-
-#define PCS_SOFT_RST2_REG	55302
-#define SERDES_RST_N_LBN 13
-#define XGXS_RST_N_LBN 12
-
-#define	PCS_TEST_SELECT_REG	55303	/* PRM 10.5.8 */
-#define	CLK312_EN_LBN 3
-
-/* PHYXS registers */
-#define PHYXS_XCONTROL_REG	49152
-#define PHYXS_RESET_LBN		15
-#define PHYXS_RESET_WIDTH	1
-
-#define PHYXS_TEST1         (49162)
-#define LOOPBACK_NEAR_LBN   (8)
-#define LOOPBACK_NEAR_WIDTH (1)
-
-/* Boot status register */
-#define PCS_BOOT_STATUS_REG		53248
-#define PCS_BOOT_FATAL_ERROR_LBN	0
-#define PCS_BOOT_PROGRESS_LBN		1
-#define PCS_BOOT_PROGRESS_WIDTH		2
-#define PCS_BOOT_PROGRESS_INIT		0
-#define PCS_BOOT_PROGRESS_WAIT_MDIO	1
-#define PCS_BOOT_PROGRESS_CHECKSUM	2
-#define PCS_BOOT_PROGRESS_JUMP		3
-#define PCS_BOOT_DOWNLOAD_WAIT_LBN	3
-#define PCS_BOOT_CODE_STARTED_LBN	4
-
-/* 100M/1G PHY registers */
-#define GPHY_XCONTROL_REG	49152
-#define GPHY_ISOLATE_LBN	10
-#define GPHY_ISOLATE_WIDTH	1
-#define GPHY_DUPLEX_LBN		8
-#define GPHY_DUPLEX_WIDTH	1
-#define GPHY_LOOPBACK_NEAR_LBN	14
-#define GPHY_LOOPBACK_NEAR_WIDTH 1
-
-#define C22EXT_STATUS_REG       49153
-#define C22EXT_STATUS_LINK_LBN  2
-#define C22EXT_STATUS_LINK_WIDTH 1
-
-#define C22EXT_MSTSLV_CTRL			49161
-#define C22EXT_MSTSLV_CTRL_ADV_1000_HD_LBN	8
-#define C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN	9
-
-#define C22EXT_MSTSLV_STATUS			49162
-#define C22EXT_MSTSLV_STATUS_LP_1000_HD_LBN	10
-#define C22EXT_MSTSLV_STATUS_LP_1000_FD_LBN	11
-
-/* Time to wait between powering down the LNPGA and turning off the power
- * rails */
-#define LNPGA_PDOWN_WAIT	(HZ / 5)
-
-struct tenxpress_phy_data {
-	enum efx_loopback_mode loopback_mode;
-	enum efx_phy_mode phy_mode;
-	int bad_lp_tries;
-};
-
-static int tenxpress_init(struct efx_nic *efx)
-{
-	/* Enable 312.5 MHz clock */
-	efx_mdio_write(efx, MDIO_MMD_PCS, PCS_TEST_SELECT_REG,
-		       1 << CLK312_EN_LBN);
-
-	/* Set the LEDs up as: Green = Link, Amber = Link/Act, Red = Off */
-	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG,
-			  1 << PMA_PMA_LED_ACTIVITY_LBN, true);
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG,
-		       SFX7101_PMA_PMD_LED_DEFAULT);
-
-	return 0;
-}
-
-static int tenxpress_phy_probe(struct efx_nic *efx)
-{
-	struct tenxpress_phy_data *phy_data;
-
-	/* Allocate phy private storage */
-	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
-	if (!phy_data)
-		return -ENOMEM;
-	efx->phy_data = phy_data;
-	phy_data->phy_mode = efx->phy_mode;
-
-	efx->mdio.mmds = TENXPRESS_REQUIRED_DEVS;
-	efx->mdio.mode_support = MDIO_SUPPORTS_C45;
-
-	efx->loopback_modes = SFX7101_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
-
-	efx->link_advertising = (ADVERTISED_TP | ADVERTISED_Autoneg |
-				 ADVERTISED_10000baseT_Full);
-
-	return 0;
-}
-
-static int tenxpress_phy_init(struct efx_nic *efx)
-{
-	int rc;
-
-	falcon_board(efx)->type->init_phy(efx);
-
-	if (!(efx->phy_mode & PHY_MODE_SPECIAL)) {
-		rc = efx_mdio_wait_reset_mmds(efx, TENXPRESS_REQUIRED_DEVS);
-		if (rc < 0)
-			return rc;
-
-		rc = efx_mdio_check_mmds(efx, TENXPRESS_REQUIRED_DEVS);
-		if (rc < 0)
-			return rc;
-	}
-
-	rc = tenxpress_init(efx);
-	if (rc < 0)
-		return rc;
-
-	/* Reinitialise flow control settings */
-	efx_link_set_wanted_fc(efx, efx->wanted_fc);
-	efx_mdio_an_reconfigure(efx);
-
-	schedule_timeout_uninterruptible(HZ / 5); /* 200ms */
-
-	/* Let XGXS and SerDes out of reset */
-	falcon_reset_xaui(efx);
-
-	return 0;
-}
-
-/* Perform a "special software reset" on the PHY. The caller is
- * responsible for saving and restoring the PHY hardware registers
- * properly, and masking/unmasking LASI */
-static int tenxpress_special_reset(struct efx_nic *efx)
-{
-	int rc, reg;
-
-	/* The XGMAC clock is driven from the SFX7101 312MHz clock, so
-	 * a special software reset can glitch the XGMAC sufficiently for stats
-	 * requests to fail. */
-	falcon_stop_nic_stats(efx);
-
-	/* Initiate reset */
-	reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
-	reg |= (1 << PMA_PMD_EXT_SSR_LBN);
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
-
-	mdelay(200);
-
-	/* Wait for the blocks to come out of reset */
-	rc = efx_mdio_wait_reset_mmds(efx, TENXPRESS_REQUIRED_DEVS);
-	if (rc < 0)
-		goto out;
-
-	/* Try and reconfigure the device */
-	rc = tenxpress_init(efx);
-	if (rc < 0)
-		goto out;
-
-	/* Wait for the XGXS state machine to churn */
-	mdelay(10);
-out:
-	falcon_start_nic_stats(efx);
-	return rc;
-}
-
-static void sfx7101_check_bad_lp(struct efx_nic *efx, bool link_ok)
-{
-	struct tenxpress_phy_data *pd = efx->phy_data;
-	bool bad_lp;
-	int reg;
-
-	if (link_ok) {
-		bad_lp = false;
-	} else {
-		/* Check that AN has started but not completed. */
-		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_STAT1);
-		if (!(reg & MDIO_AN_STAT1_LPABLE))
-			return; /* LP status is unknown */
-		bad_lp = !(reg & MDIO_AN_STAT1_COMPLETE);
-		if (bad_lp)
-			pd->bad_lp_tries++;
-	}
-
-	/* Nothing to do if all is well and was previously so. */
-	if (!pd->bad_lp_tries)
-		return;
-
-	/* Use the RX (red) LED as an error indicator once we've seen AN
-	 * failure several times in a row, and also log a message. */
-	if (!bad_lp || pd->bad_lp_tries == MAX_BAD_LP_TRIES) {
-		reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD,
-				    PMA_PMD_LED_OVERR_REG);
-		reg &= ~(PMA_PMD_LED_MASK << PMA_PMD_LED_RX_LBN);
-		if (!bad_lp) {
-			reg |= PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN;
-		} else {
-			reg |= PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN;
-			netif_err(efx, link, efx->net_dev,
-				  "appears to be plugged into a port"
-				  " that is not 10GBASE-T capable. The PHY"
-				  " supports 10GBASE-T ONLY, so no link can"
-				  " be established\n");
-		}
-		efx_mdio_write(efx, MDIO_MMD_PMAPMD,
-			       PMA_PMD_LED_OVERR_REG, reg);
-		pd->bad_lp_tries = bad_lp;
-	}
-}
-
-static bool sfx7101_link_ok(struct efx_nic *efx)
-{
-	return efx_mdio_links_ok(efx,
-				 MDIO_DEVS_PMAPMD |
-				 MDIO_DEVS_PCS |
-				 MDIO_DEVS_PHYXS);
-}
-
-static void tenxpress_ext_loopback(struct efx_nic *efx)
-{
-	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS, PHYXS_TEST1,
-			  1 << LOOPBACK_NEAR_LBN,
-			  efx->loopback_mode == LOOPBACK_PHYXS);
-}
-
-static void tenxpress_low_power(struct efx_nic *efx)
-{
-	efx_mdio_set_mmds_lpower(
-		efx, !!(efx->phy_mode & PHY_MODE_LOW_POWER),
-		TENXPRESS_REQUIRED_DEVS);
-}
-
-static int tenxpress_phy_reconfigure(struct efx_nic *efx)
-{
-	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	bool phy_mode_change, loop_reset;
-
-	if (efx->phy_mode & (PHY_MODE_OFF | PHY_MODE_SPECIAL)) {
-		phy_data->phy_mode = efx->phy_mode;
-		return 0;
-	}
-
-	phy_mode_change = (efx->phy_mode == PHY_MODE_NORMAL &&
-			   phy_data->phy_mode != PHY_MODE_NORMAL);
-	loop_reset = (LOOPBACK_OUT_OF(phy_data, efx, LOOPBACKS_EXTERNAL(efx)) ||
-		      LOOPBACK_CHANGED(phy_data, efx, 1 << LOOPBACK_GPHY));
-
-	if (loop_reset || phy_mode_change) {
-		tenxpress_special_reset(efx);
-		falcon_reset_xaui(efx);
-	}
-
-	tenxpress_low_power(efx);
-	efx_mdio_transmit_disable(efx);
-	efx_mdio_phy_reconfigure(efx);
-	tenxpress_ext_loopback(efx);
-	efx_mdio_an_reconfigure(efx);
-
-	phy_data->loopback_mode = efx->loopback_mode;
-	phy_data->phy_mode = efx->phy_mode;
-
-	return 0;
-}
-
-static void
-tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd);
-
-/* Poll for link state changes */
-static bool tenxpress_phy_poll(struct efx_nic *efx)
-{
-	struct efx_link_state old_state = efx->link_state;
-
-	efx->link_state.up = sfx7101_link_ok(efx);
-	efx->link_state.speed = 10000;
-	efx->link_state.fd = true;
-	efx->link_state.fc = efx_mdio_get_pause(efx);
-
-	sfx7101_check_bad_lp(efx, efx->link_state.up);
-
-	return !efx_link_state_equal(&efx->link_state, &old_state);
-}
-
-static void sfx7101_phy_fini(struct efx_nic *efx)
-{
-	int reg;
-
-	/* Power down the LNPGA */
-	reg = (1 << PMA_PMD_LNPGA_POWERDOWN_LBN);
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
-
-	/* Waiting here ensures that the board fini, which can turn
-	 * off the power to the PHY, won't get run until the LNPGA
-	 * powerdown has been given long enough to complete. */
-	schedule_timeout_uninterruptible(LNPGA_PDOWN_WAIT); /* 200 ms */
-}
-
-static void tenxpress_phy_remove(struct efx_nic *efx)
-{
-	kfree(efx->phy_data);
-	efx->phy_data = NULL;
-}
-
-
-/* Override the RX, TX and link LEDs */
-void tenxpress_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
-{
-	int reg;
-
-	switch (mode) {
-	case EFX_LED_OFF:
-		reg = (PMA_PMD_LED_OFF << PMA_PMD_LED_TX_LBN) |
-			(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN) |
-			(PMA_PMD_LED_OFF << PMA_PMD_LED_LINK_LBN);
-		break;
-	case EFX_LED_ON:
-		reg = (PMA_PMD_LED_ON << PMA_PMD_LED_TX_LBN) |
-			(PMA_PMD_LED_ON << PMA_PMD_LED_RX_LBN) |
-			(PMA_PMD_LED_ON << PMA_PMD_LED_LINK_LBN);
-		break;
-	default:
-		reg = SFX7101_PMA_PMD_LED_DEFAULT;
-		break;
-	}
-
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG, reg);
-}
-
-static const char *const sfx7101_test_names[] = {
-	"bist"
-};
-
-static const char *sfx7101_test_name(struct efx_nic *efx, unsigned int index)
-{
-	if (index < ARRAY_SIZE(sfx7101_test_names))
-		return sfx7101_test_names[index];
-	return NULL;
-}
-
-static int
-sfx7101_run_tests(struct efx_nic *efx, int *results, unsigned flags)
-{
-	int rc;
-
-	if (!(flags & ETH_TEST_FL_OFFLINE))
-		return 0;
-
-	/* BIST is automatically run after a special software reset */
-	rc = tenxpress_special_reset(efx);
-	results[0] = rc ? -1 : 1;
-
-	efx_mdio_an_reconfigure(efx);
-
-	return rc;
-}
-
-static void
-tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	u32 adv = 0, lpa = 0;
-	int reg;
-
-	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL);
-	if (reg & MDIO_AN_10GBT_CTRL_ADV10G)
-		adv |= ADVERTISED_10000baseT_Full;
-	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_10GBT_STAT);
-	if (reg & MDIO_AN_10GBT_STAT_LP10G)
-		lpa |= ADVERTISED_10000baseT_Full;
-
-	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
-
-	/* In loopback, the PHY automatically brings up the correct interface,
-	 * but doesn't advertise the correct speed. So override it */
-	if (LOOPBACK_EXTERNAL(efx))
-		ethtool_cmd_speed_set(ecmd, SPEED_10000);
-}
-
-static int tenxpress_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	if (!ecmd->autoneg)
-		return -EINVAL;
-
-	return efx_mdio_set_settings(efx, ecmd);
-}
-
-static void sfx7101_set_npage_adv(struct efx_nic *efx, u32 advertising)
-{
-	efx_mdio_set_flag(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL,
-			  MDIO_AN_10GBT_CTRL_ADV10G,
-			  advertising & ADVERTISED_10000baseT_Full);
-}
-
-const struct efx_phy_operations falcon_sfx7101_phy_ops = {
-	.probe		  = tenxpress_phy_probe,
-	.init             = tenxpress_phy_init,
-	.reconfigure      = tenxpress_phy_reconfigure,
-	.poll             = tenxpress_phy_poll,
-	.fini             = sfx7101_phy_fini,
-	.remove		  = tenxpress_phy_remove,
-	.get_settings	  = tenxpress_get_settings,
-	.set_settings	  = tenxpress_set_settings,
-	.set_npage_adv    = sfx7101_set_npage_adv,
-	.test_alive	  = efx_mdio_test_alive,
-	.test_name	  = sfx7101_test_name,
-	.run_tests	  = sfx7101_run_tests,
-};
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index bb07034..f11a36a 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -97,10 +97,8 @@ unsigned int efx_tx_max_skb_descs(struct efx_nic *efx)
 	 */
 	unsigned int max_descs = EFX_TSO_MAX_SEGS * 2 + MAX_SKB_FRAGS;
 
-	/* Possibly one more per segment for the alignment workaround,
-	 * or for option descriptors
-	 */
-	if (EFX_WORKAROUND_5391(efx) || efx_nic_rev(efx) >= EFX_REV_HUNT_A0)
+	/* Possibly one more per segment for option descriptors */
+	if (efx_nic_rev(efx) >= EFX_REV_HUNT_A0)
 		max_descs += EFX_TSO_MAX_SEGS;
 
 	/* Possibly more for PCIe page boundaries within input fragments */
@@ -155,7 +153,6 @@ static void efx_tx_maybe_stop_queue(struct efx_tx_queue *txq1)
 static int efx_enqueue_skb_copy(struct efx_tx_queue *tx_queue,
 				struct sk_buff *skb)
 {
-	unsigned int min_len = tx_queue->tx_min_size;
 	unsigned int copy_len = skb->len;
 	struct efx_tx_buffer *buffer;
 	u8 *copy_buffer;
@@ -171,12 +168,7 @@ static int efx_enqueue_skb_copy(struct efx_tx_queue *tx_queue,
 
 	rc = skb_copy_bits(skb, 0, copy_buffer, copy_len);
 	EFX_WARN_ON_PARANOID(rc);
-	if (unlikely(copy_len < min_len)) {
-		memset(copy_buffer + copy_len, 0, min_len - copy_len);
-		buffer->len = min_len;
-	} else {
-		buffer->len = copy_len;
-	}
+	buffer->len = copy_len;
 
 	buffer->skb = skb;
 	buffer->flags = EFX_TX_BUF_SKB;
@@ -530,8 +522,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 		tx_queue->pio_packets++;
 		data_mapped = true;
 #endif
-	} else if (skb_len < tx_queue->tx_min_size ||
-			(skb->data_len && skb_len <= EFX_TX_CB_SIZE)) {
+	} else if (skb->data_len && skb_len <= EFX_TX_CB_SIZE) {
 		/* Pad short packets or coalesce short fragmented packets. */
 		if (efx_enqueue_skb_copy(tx_queue, skb))
 			goto err;
@@ -677,7 +668,7 @@ int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
 
 	num_tc = ntc->tc;
 
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0 || num_tc > EFX_MAX_TX_TC)
+	if (num_tc > EFX_MAX_TX_TC)
 		return -EINVAL;
 
 	if (num_tc == net_dev->num_tc)
@@ -837,9 +828,6 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	 */
 	tx_queue->handle_tso = efx_enqueue_skb_tso;
 
-	/* Some older hardware requires Tx writes larger than 32. */
-	tx_queue->tx_min_size = EFX_WORKAROUND_15592(efx) ? 33 : 0;
-
 	/* Set up TX descriptor ring */
 	efx_nic_init_tx(tx_queue);
 
diff --git a/drivers/net/ethernet/sfc/txc43128_phy.c b/drivers/net/ethernet/sfc/txc43128_phy.c
deleted file mode 100644
index 194f67d..0000000
--- a/drivers/net/ethernet/sfc/txc43128_phy.c
+++ /dev/null
@@ -1,560 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare network controllers and boards
- * Copyright 2006-2011 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-/*
- * Driver for Transwitch/Mysticom CX4 retimer
- * see www.transwitch.com, part is TXC-43128
- */
-
-#include <linux/delay.h>
-#include <linux/slab.h>
-#include "efx.h"
-#include "mdio_10g.h"
-#include "phy.h"
-#include "nic.h"
-
-/* We expect these MMDs to be in the package */
-#define TXC_REQUIRED_DEVS (MDIO_DEVS_PCS |	\
-			   MDIO_DEVS_PMAPMD |	\
-			   MDIO_DEVS_PHYXS)
-
-#define TXC_LOOPBACKS ((1 << LOOPBACK_PCS) |	\
-		       (1 << LOOPBACK_PMAPMD) |	\
-		       (1 << LOOPBACK_PHYXS_WS))
-
-/**************************************************************************
- *
- * Compile-time config
- *
- **************************************************************************
- */
-#define TXCNAME "TXC43128"
-/* Total length of time we'll wait for the PHY to come out of reset (ms) */
-#define TXC_MAX_RESET_TIME	500
-/* Interval between checks (ms) */
-#define TXC_RESET_WAIT		10
-/* How long to run BIST (us) */
-#define TXC_BIST_DURATION	50
-
-/**************************************************************************
- *
- * Register definitions
- *
- **************************************************************************
- */
-
-/* Command register */
-#define TXC_GLRGS_GLCMD		0xc004
-/* Useful bits in command register */
-/* Lane power-down */
-#define TXC_GLCMD_L01PD_LBN	5
-#define TXC_GLCMD_L23PD_LBN	6
-/* Limited SW reset: preserves configuration but
- * initiates a logic reset. Self-clearing */
-#define TXC_GLCMD_LMTSWRST_LBN	14
-
-/* Signal Quality Control */
-#define TXC_GLRGS_GSGQLCTL	0xc01a
-/* Enable bit */
-#define TXC_GSGQLCT_SGQLEN_LBN	15
-/* Lane selection */
-#define TXC_GSGQLCT_LNSL_LBN	13
-#define TXC_GSGQLCT_LNSL_WIDTH	2
-
-/* Analog TX control */
-#define TXC_ALRGS_ATXCTL	0xc040
-/* Lane power-down */
-#define TXC_ATXCTL_TXPD3_LBN	15
-#define TXC_ATXCTL_TXPD2_LBN	14
-#define TXC_ATXCTL_TXPD1_LBN	13
-#define TXC_ATXCTL_TXPD0_LBN	12
-
-/* Amplitude on lanes 0, 1 */
-#define TXC_ALRGS_ATXAMP0	0xc041
-/* Amplitude on lanes 2, 3 */
-#define TXC_ALRGS_ATXAMP1	0xc042
-/* Bit position of value for lane 0 (or 2) */
-#define TXC_ATXAMP_LANE02_LBN	3
-/* Bit position of value for lane 1 (or 3) */
-#define TXC_ATXAMP_LANE13_LBN	11
-
-#define TXC_ATXAMP_1280_mV	0
-#define TXC_ATXAMP_1200_mV	8
-#define TXC_ATXAMP_1120_mV	12
-#define TXC_ATXAMP_1060_mV	14
-#define TXC_ATXAMP_0820_mV	25
-#define TXC_ATXAMP_0720_mV	26
-#define TXC_ATXAMP_0580_mV	27
-#define TXC_ATXAMP_0440_mV	28
-
-#define TXC_ATXAMP_0820_BOTH					\
-	((TXC_ATXAMP_0820_mV << TXC_ATXAMP_LANE02_LBN)		\
-	 | (TXC_ATXAMP_0820_mV << TXC_ATXAMP_LANE13_LBN))
-
-#define TXC_ATXAMP_DEFAULT	0x6060 /* From databook */
-
-/* Preemphasis on lanes 0, 1 */
-#define TXC_ALRGS_ATXPRE0	0xc043
-/* Preemphasis on lanes 2, 3 */
-#define TXC_ALRGS_ATXPRE1	0xc044
-
-#define TXC_ATXPRE_NONE 0
-#define TXC_ATXPRE_DEFAULT	0x1010 /* From databook */
-
-#define TXC_ALRGS_ARXCTL	0xc045
-/* Lane power-down */
-#define TXC_ARXCTL_RXPD3_LBN	15
-#define TXC_ARXCTL_RXPD2_LBN	14
-#define TXC_ARXCTL_RXPD1_LBN	13
-#define TXC_ARXCTL_RXPD0_LBN	12
-
-/* Main control */
-#define TXC_MRGS_CTL		0xc340
-/* Bits in main control */
-#define TXC_MCTL_RESET_LBN	15	/* Self clear */
-#define TXC_MCTL_TXLED_LBN	14	/* 1 to show align status */
-#define TXC_MCTL_RXLED_LBN	13	/* 1 to show align status */
-
-/* GPIO output */
-#define TXC_GPIO_OUTPUT		0xc346
-#define TXC_GPIO_DIR		0xc348
-
-/* Vendor-specific BIST registers */
-#define TXC_BIST_CTL		0xc280
-#define TXC_BIST_TXFRMCNT	0xc281
-#define TXC_BIST_RX0FRMCNT	0xc282
-#define TXC_BIST_RX1FRMCNT	0xc283
-#define TXC_BIST_RX2FRMCNT	0xc284
-#define TXC_BIST_RX3FRMCNT	0xc285
-#define TXC_BIST_RX0ERRCNT	0xc286
-#define TXC_BIST_RX1ERRCNT	0xc287
-#define TXC_BIST_RX2ERRCNT	0xc288
-#define TXC_BIST_RX3ERRCNT	0xc289
-
-/* BIST type (controls bit patter in test) */
-#define TXC_BIST_CTRL_TYPE_LBN	10
-#define TXC_BIST_CTRL_TYPE_TSD	0	/* TranSwitch Deterministic */
-#define TXC_BIST_CTRL_TYPE_CRP	1	/* CRPAT standard */
-#define TXC_BIST_CTRL_TYPE_CJP	2	/* CJPAT standard */
-#define TXC_BIST_CTRL_TYPE_TSR	3	/* TranSwitch pseudo-random */
-/* Set this to 1 for 10 bit and 0 for 8 bit */
-#define TXC_BIST_CTRL_B10EN_LBN	12
-/* Enable BIST (write 0 to disable) */
-#define TXC_BIST_CTRL_ENAB_LBN	13
-/* Stop BIST (self-clears when stop complete) */
-#define TXC_BIST_CTRL_STOP_LBN	14
-/* Start BIST (cleared by writing 1 to STOP) */
-#define TXC_BIST_CTRL_STRT_LBN	15
-
-/* Mt. Diablo test configuration */
-#define TXC_MTDIABLO_CTRL	0xc34f
-#define TXC_MTDIABLO_CTRL_PMA_LOOP_LBN	10
-
-struct txc43128_data {
-	unsigned long bug10934_timer;
-	enum efx_phy_mode phy_mode;
-	enum efx_loopback_mode loopback_mode;
-};
-
-/* The PHY sometimes needs a reset to bring the link back up.  So long as
- * it reports link down, we reset it every 5 seconds.
- */
-#define BUG10934_RESET_INTERVAL (5 * HZ)
-
-/* Perform a reset that doesn't clear configuration changes */
-static void txc_reset_logic(struct efx_nic *efx);
-
-/* Set the output value of a gpio */
-void falcon_txc_set_gpio_val(struct efx_nic *efx, int pin, int on)
-{
-	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS, TXC_GPIO_OUTPUT, 1 << pin, on);
-}
-
-/* Set up the GPIO direction register */
-void falcon_txc_set_gpio_dir(struct efx_nic *efx, int pin, int dir)
-{
-	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS, TXC_GPIO_DIR, 1 << pin, dir);
-}
-
-/* Reset the PMA/PMD MMD. The documentation is explicit that this does a
- * global reset (it's less clear what reset of other MMDs does).*/
-static int txc_reset_phy(struct efx_nic *efx)
-{
-	int rc = efx_mdio_reset_mmd(efx, MDIO_MMD_PMAPMD,
-				    TXC_MAX_RESET_TIME / TXC_RESET_WAIT,
-				    TXC_RESET_WAIT);
-	if (rc < 0)
-		goto fail;
-
-	/* Check that all the MMDs we expect are present and responding. */
-	rc = efx_mdio_check_mmds(efx, TXC_REQUIRED_DEVS);
-	if (rc < 0)
-		goto fail;
-
-	return 0;
-
-fail:
-	netif_err(efx, hw, efx->net_dev, TXCNAME ": reset timed out!\n");
-	return rc;
-}
-
-/* Run a single BIST on one MMD */
-static int txc_bist_one(struct efx_nic *efx, int mmd, int test)
-{
-	int ctrl, bctl;
-	int lane;
-	int rc = 0;
-
-	/* Set PMA to test into loopback using Mt Diablo reg as per app note */
-	ctrl = efx_mdio_read(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL);
-	ctrl |= (1 << TXC_MTDIABLO_CTRL_PMA_LOOP_LBN);
-	efx_mdio_write(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL, ctrl);
-
-	/* The BIST app. note lists these  as 3 distinct steps. */
-	/* Set the BIST type */
-	bctl = (test << TXC_BIST_CTRL_TYPE_LBN);
-	efx_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
-
-	/* Set the BSTEN bit in the BIST Control register to enable */
-	bctl |= (1 << TXC_BIST_CTRL_ENAB_LBN);
-	efx_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
-
-	/* Set the BSTRT bit in the BIST Control register */
-	efx_mdio_write(efx, mmd, TXC_BIST_CTL,
-		       bctl | (1 << TXC_BIST_CTRL_STRT_LBN));
-
-	/* Wait. */
-	udelay(TXC_BIST_DURATION);
-
-	/* Set the BSTOP bit in the BIST Control register */
-	bctl |= (1 << TXC_BIST_CTRL_STOP_LBN);
-	efx_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
-
-	/* The STOP bit should go off when things have stopped */
-	while (bctl & (1 << TXC_BIST_CTRL_STOP_LBN))
-		bctl = efx_mdio_read(efx, mmd, TXC_BIST_CTL);
-
-	/* Check all the error counts are 0 and all the frame counts are
-	   non-zero */
-	for (lane = 0; lane < 4; lane++) {
-		int count = efx_mdio_read(efx, mmd, TXC_BIST_RX0ERRCNT + lane);
-		if (count != 0) {
-			netif_err(efx, hw, efx->net_dev, TXCNAME": BIST error. "
-				  "Lane %d had %d errs\n", lane, count);
-			rc = -EIO;
-		}
-		count = efx_mdio_read(efx, mmd, TXC_BIST_RX0FRMCNT + lane);
-		if (count == 0) {
-			netif_err(efx, hw, efx->net_dev, TXCNAME": BIST error. "
-				  "Lane %d got 0 frames\n", lane);
-			rc = -EIO;
-		}
-	}
-
-	if (rc == 0)
-		netif_info(efx, hw, efx->net_dev, TXCNAME": BIST pass\n");
-
-	/* Disable BIST */
-	efx_mdio_write(efx, mmd, TXC_BIST_CTL, 0);
-
-	/* Turn off loopback */
-	ctrl &= ~(1 << TXC_MTDIABLO_CTRL_PMA_LOOP_LBN);
-	efx_mdio_write(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL, ctrl);
-
-	return rc;
-}
-
-static int txc_bist(struct efx_nic *efx)
-{
-	return txc_bist_one(efx, MDIO_MMD_PCS, TXC_BIST_CTRL_TYPE_TSD);
-}
-
-/* Push the non-configurable defaults into the PHY. This must be
- * done after every full reset */
-static void txc_apply_defaults(struct efx_nic *efx)
-{
-	int mctrl;
-
-	/* Turn amplitude down and preemphasis off on the host side
-	 * (PHY<->MAC) as this is believed less likely to upset Falcon
-	 * and no adverse effects have been noted. It probably also
-	 * saves a picowatt or two */
-
-	/* Turn off preemphasis */
-	efx_mdio_write(efx, MDIO_MMD_PHYXS, TXC_ALRGS_ATXPRE0, TXC_ATXPRE_NONE);
-	efx_mdio_write(efx, MDIO_MMD_PHYXS, TXC_ALRGS_ATXPRE1, TXC_ATXPRE_NONE);
-
-	/* Turn down the amplitude */
-	efx_mdio_write(efx, MDIO_MMD_PHYXS,
-		       TXC_ALRGS_ATXAMP0, TXC_ATXAMP_0820_BOTH);
-	efx_mdio_write(efx, MDIO_MMD_PHYXS,
-		       TXC_ALRGS_ATXAMP1, TXC_ATXAMP_0820_BOTH);
-
-	/* Set the line side amplitude and preemphasis to the databook
-	 * defaults as an erratum causes them to be 0 on at least some
-	 * PHY rev.s */
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
-		       TXC_ALRGS_ATXPRE0, TXC_ATXPRE_DEFAULT);
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
-		       TXC_ALRGS_ATXPRE1, TXC_ATXPRE_DEFAULT);
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
-		       TXC_ALRGS_ATXAMP0, TXC_ATXAMP_DEFAULT);
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
-		       TXC_ALRGS_ATXAMP1, TXC_ATXAMP_DEFAULT);
-
-	/* Set up the LEDs  */
-	mctrl = efx_mdio_read(efx, MDIO_MMD_PHYXS, TXC_MRGS_CTL);
-
-	/* Set the Green and Red LEDs to their default modes */
-	mctrl &= ~((1 << TXC_MCTL_TXLED_LBN) | (1 << TXC_MCTL_RXLED_LBN));
-	efx_mdio_write(efx, MDIO_MMD_PHYXS, TXC_MRGS_CTL, mctrl);
-
-	/* Databook recommends doing this after configuration changes */
-	txc_reset_logic(efx);
-
-	falcon_board(efx)->type->init_phy(efx);
-}
-
-static int txc43128_phy_probe(struct efx_nic *efx)
-{
-	struct txc43128_data *phy_data;
-
-	/* Allocate phy private storage */
-	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
-	if (!phy_data)
-		return -ENOMEM;
-	efx->phy_data = phy_data;
-	phy_data->phy_mode = efx->phy_mode;
-
-	efx->mdio.mmds = TXC_REQUIRED_DEVS;
-	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
-
-	efx->loopback_modes = TXC_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
-
-	return 0;
-}
-
-/* Initialisation entry point for this PHY driver */
-static int txc43128_phy_init(struct efx_nic *efx)
-{
-	int rc;
-
-	rc = txc_reset_phy(efx);
-	if (rc < 0)
-		return rc;
-
-	rc = txc_bist(efx);
-	if (rc < 0)
-		return rc;
-
-	txc_apply_defaults(efx);
-
-	return 0;
-}
-
-/* Set the lane power down state in the global registers */
-static void txc_glrgs_lane_power(struct efx_nic *efx, int mmd)
-{
-	int pd = (1 << TXC_GLCMD_L01PD_LBN) | (1 << TXC_GLCMD_L23PD_LBN);
-	int ctl = efx_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
-
-	if (!(efx->phy_mode & PHY_MODE_LOW_POWER))
-		ctl &= ~pd;
-	else
-		ctl |= pd;
-
-	efx_mdio_write(efx, mmd, TXC_GLRGS_GLCMD, ctl);
-}
-
-/* Set the lane power down state in the analog control registers */
-static void txc_analog_lane_power(struct efx_nic *efx, int mmd)
-{
-	int txpd = (1 << TXC_ATXCTL_TXPD3_LBN) | (1 << TXC_ATXCTL_TXPD2_LBN)
-		| (1 << TXC_ATXCTL_TXPD1_LBN) | (1 << TXC_ATXCTL_TXPD0_LBN);
-	int rxpd = (1 << TXC_ARXCTL_RXPD3_LBN) | (1 << TXC_ARXCTL_RXPD2_LBN)
-		| (1 << TXC_ARXCTL_RXPD1_LBN) | (1 << TXC_ARXCTL_RXPD0_LBN);
-	int txctl = efx_mdio_read(efx, mmd, TXC_ALRGS_ATXCTL);
-	int rxctl = efx_mdio_read(efx, mmd, TXC_ALRGS_ARXCTL);
-
-	if (!(efx->phy_mode & PHY_MODE_LOW_POWER)) {
-		txctl &= ~txpd;
-		rxctl &= ~rxpd;
-	} else {
-		txctl |= txpd;
-		rxctl |= rxpd;
-	}
-
-	efx_mdio_write(efx, mmd, TXC_ALRGS_ATXCTL, txctl);
-	efx_mdio_write(efx, mmd, TXC_ALRGS_ARXCTL, rxctl);
-}
-
-static void txc_set_power(struct efx_nic *efx)
-{
-	/* According to the data book, all the MMDs can do low power */
-	efx_mdio_set_mmds_lpower(efx,
-				 !!(efx->phy_mode & PHY_MODE_LOW_POWER),
-				 TXC_REQUIRED_DEVS);
-
-	/* Global register bank is in PCS, PHY XS. These control the host
-	 * side and line side settings respectively. */
-	txc_glrgs_lane_power(efx, MDIO_MMD_PCS);
-	txc_glrgs_lane_power(efx, MDIO_MMD_PHYXS);
-
-	/* Analog register bank in PMA/PMD, PHY XS */
-	txc_analog_lane_power(efx, MDIO_MMD_PMAPMD);
-	txc_analog_lane_power(efx, MDIO_MMD_PHYXS);
-}
-
-static void txc_reset_logic_mmd(struct efx_nic *efx, int mmd)
-{
-	int val = efx_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
-	int tries = 50;
-
-	val |= (1 << TXC_GLCMD_LMTSWRST_LBN);
-	efx_mdio_write(efx, mmd, TXC_GLRGS_GLCMD, val);
-	while (--tries) {
-		val = efx_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
-		if (!(val & (1 << TXC_GLCMD_LMTSWRST_LBN)))
-			break;
-		udelay(1);
-	}
-	if (!tries)
-		netif_info(efx, hw, efx->net_dev,
-			   TXCNAME " Logic reset timed out!\n");
-}
-
-/* Perform a logic reset. This preserves the configuration registers
- * and is needed for some configuration changes to take effect */
-static void txc_reset_logic(struct efx_nic *efx)
-{
-	/* The data sheet claims we can do the logic reset on either the
-	 * PCS or the PHYXS and the result is a reset of both host- and
-	 * line-side logic. */
-	txc_reset_logic_mmd(efx, MDIO_MMD_PCS);
-}
-
-static bool txc43128_phy_read_link(struct efx_nic *efx)
-{
-	return efx_mdio_links_ok(efx, TXC_REQUIRED_DEVS);
-}
-
-static int txc43128_phy_reconfigure(struct efx_nic *efx)
-{
-	struct txc43128_data *phy_data = efx->phy_data;
-	enum efx_phy_mode mode_change = efx->phy_mode ^ phy_data->phy_mode;
-	bool loop_change = LOOPBACK_CHANGED(phy_data, efx, TXC_LOOPBACKS);
-
-	if (efx->phy_mode & mode_change & PHY_MODE_TX_DISABLED) {
-		txc_reset_phy(efx);
-		txc_apply_defaults(efx);
-		falcon_reset_xaui(efx);
-		mode_change &= ~PHY_MODE_TX_DISABLED;
-	}
-
-	efx_mdio_transmit_disable(efx);
-	efx_mdio_phy_reconfigure(efx);
-	if (mode_change & PHY_MODE_LOW_POWER)
-		txc_set_power(efx);
-
-	/* The data sheet claims this is required after every reconfiguration
-	 * (note at end of 7.1), but we mustn't do it when nothing changes as
-	 * it glitches the link, and reconfigure gets called on link change,
-	 * so we get an IRQ storm on link up. */
-	if (loop_change || mode_change)
-		txc_reset_logic(efx);
-
-	phy_data->phy_mode = efx->phy_mode;
-	phy_data->loopback_mode = efx->loopback_mode;
-
-	return 0;
-}
-
-static void txc43128_phy_fini(struct efx_nic *efx)
-{
-	/* Disable link events */
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL, 0);
-}
-
-static void txc43128_phy_remove(struct efx_nic *efx)
-{
-	kfree(efx->phy_data);
-	efx->phy_data = NULL;
-}
-
-/* Periodic callback: this exists mainly to poll link status as we
- * don't use LASI interrupts */
-static bool txc43128_phy_poll(struct efx_nic *efx)
-{
-	struct txc43128_data *data = efx->phy_data;
-	bool was_up = efx->link_state.up;
-
-	efx->link_state.up = txc43128_phy_read_link(efx);
-	efx->link_state.speed = 10000;
-	efx->link_state.fd = true;
-	efx->link_state.fc = efx->wanted_fc;
-
-	if (efx->link_state.up || (efx->loopback_mode != LOOPBACK_NONE)) {
-		data->bug10934_timer = jiffies;
-	} else {
-		if (time_after_eq(jiffies, (data->bug10934_timer +
-					    BUG10934_RESET_INTERVAL))) {
-			data->bug10934_timer = jiffies;
-			txc_reset_logic(efx);
-		}
-	}
-
-	return efx->link_state.up != was_up;
-}
-
-static const char *const txc43128_test_names[] = {
-	"bist"
-};
-
-static const char *txc43128_test_name(struct efx_nic *efx, unsigned int index)
-{
-	if (index < ARRAY_SIZE(txc43128_test_names))
-		return txc43128_test_names[index];
-	return NULL;
-}
-
-static int txc43128_run_tests(struct efx_nic *efx, int *results, unsigned flags)
-{
-	int rc;
-
-	if (!(flags & ETH_TEST_FL_OFFLINE))
-		return 0;
-
-	rc = txc_reset_phy(efx);
-	if (rc < 0)
-		return rc;
-
-	rc = txc_bist(efx);
-	txc_apply_defaults(efx);
-	results[0] = rc ? -1 : 1;
-	return rc;
-}
-
-static void txc43128_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	mdio45_ethtool_gset(&efx->mdio, ecmd);
-}
-
-const struct efx_phy_operations falcon_txc_phy_ops = {
-	.probe		= txc43128_phy_probe,
-	.init		= txc43128_phy_init,
-	.reconfigure	= txc43128_phy_reconfigure,
-	.poll		= txc43128_phy_poll,
-	.fini		= txc43128_phy_fini,
-	.remove		= txc43128_phy_remove,
-	.get_settings	= txc43128_get_settings,
-	.set_settings	= efx_mdio_set_settings,
-	.test_alive	= efx_mdio_test_alive,
-	.run_tests	= txc43128_run_tests,
-	.test_name	= txc43128_test_name,
-};
diff --git a/drivers/net/ethernet/sfc/workarounds.h b/drivers/net/ethernet/sfc/workarounds.h
index 351cd14..103f827 100644
--- a/drivers/net/ethernet/sfc/workarounds.h
+++ b/drivers/net/ethernet/sfc/workarounds.h
@@ -15,35 +15,14 @@
  * Bug numbers are from Solarflare's Bugzilla.
  */
 
-#define EFX_WORKAROUND_FALCON_A(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_A1)
-#define EFX_WORKAROUND_FALCON_AB(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_B0)
 #define EFX_WORKAROUND_SIENA(efx) (efx_nic_rev(efx) == EFX_REV_SIENA_A0)
 #define EFX_WORKAROUND_10G(efx) 1
 
 /* Bit-bashed I2C reads cause performance drop */
 #define EFX_WORKAROUND_7884 EFX_WORKAROUND_10G
-/* Truncated IPv4 packets can confuse the TX packet parser */
-#define EFX_WORKAROUND_15592 EFX_WORKAROUND_FALCON_AB
 /* Legacy interrupt storm when interrupt fifo fills */
 #define EFX_WORKAROUND_17213 EFX_WORKAROUND_SIENA
 
-/* Spurious parity errors in TSORT buffers */
-#define EFX_WORKAROUND_5129 EFX_WORKAROUND_FALCON_A
-/* Unaligned read request >512 bytes after aligning may break TSORT */
-#define EFX_WORKAROUND_5391 EFX_WORKAROUND_FALCON_A
-/* iSCSI parsing errors */
-#define EFX_WORKAROUND_5583 EFX_WORKAROUND_FALCON_A
-/* RX events go missing */
-#define EFX_WORKAROUND_5676 EFX_WORKAROUND_FALCON_A
-/* RX_RESET on A1 */
-#define EFX_WORKAROUND_6555 EFX_WORKAROUND_FALCON_A
-/* Increase filter depth to avoid RX_RESET */
-#define EFX_WORKAROUND_7244 EFX_WORKAROUND_FALCON_A
-/* Flushes may never complete */
-#define EFX_WORKAROUND_7803 EFX_WORKAROUND_FALCON_AB
-/* Leak overlength packets rather than free */
-#define EFX_WORKAROUND_8071 EFX_WORKAROUND_FALCON_A
-
 /* Lockup when writing event block registers at gen2/gen3 */
 #define EFX_EF10_WORKAROUND_35388(efx)					\
 	(((struct efx_ef10_nic_data *)efx->nic_data)->workaround_35388)
