From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH RESEND net-next 15/16] sfc: Collect all MCDI port functions
 into mcdi_port.c
Date: Thu, 22 Aug 2013 20:29:45 +0100
Message-ID: <1377199785.1703.64.camel@bwh-desktop.uk.level5networks.com>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29924 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035Ab3HVT3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:29:49 -0400
In-Reply-To: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Collect together MCDI port functions from mcdi.c, mcdi_mac.c,
mcdi_phy.c and siena.c.  Rename the 'siena' functions accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/Makefile                  |   3 +-
 drivers/net/ethernet/sfc/mcdi.c                    |  30 ---
 drivers/net/ethernet/sfc/mcdi.h                    |   9 +-
 drivers/net/ethernet/sfc/mcdi_mac.c                | 114 ---------
 .../net/ethernet/sfc/{mcdi_phy.c => mcdi_port.c}   | 271 +++++++++++++++++----
 drivers/net/ethernet/sfc/phy.h                     |  17 --
 drivers/net/ethernet/sfc/siena.c                   | 104 +-------
 7 files changed, 242 insertions(+), 306 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/mcdi_mac.c
 rename drivers/net/ethernet/sfc/{mcdi_phy.c => mcdi_port.c} (79%)

diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
index 84f9c96..5b31d8a 100644
--- a/drivers/net/ethernet/sfc/Makefile
+++ b/drivers/net/ethernet/sfc/Makefile
@@ -1,8 +1,7 @@
 sfc-y			+= efx.o nic.o falcon.o siena.o tx.o rx.o filter.o \
-			   mcdi_mac.o \
 			   selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
 			   tenxpress.o txc43128_phy.o falcon_boards.o \
-			   mcdi.o mcdi_phy.o mcdi_mon.o ptp.o
+			   mcdi.o mcdi_port.o mcdi_mon.o ptp.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 sfc-$(CONFIG_SFC_SRIOV)	+= siena_sriov.o
 
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 4781e02..5132aba 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -514,36 +514,6 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 	spin_unlock(&mcdi->iface_lock);
 }
 
-static unsigned int efx_mcdi_event_link_speed[] = {
-	[MCDI_EVENT_LINKCHANGE_SPEED_100M] = 100,
-	[MCDI_EVENT_LINKCHANGE_SPEED_1G] = 1000,
-	[MCDI_EVENT_LINKCHANGE_SPEED_10G] = 10000,
-};
-
-
-static void efx_mcdi_process_link_change(struct efx_nic *efx, efx_qword_t *ev)
-{
-	u32 flags, fcntl, speed, lpa;
-
-	speed = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_SPEED);
-	EFX_BUG_ON_PARANOID(speed >= ARRAY_SIZE(efx_mcdi_event_link_speed));
-	speed = efx_mcdi_event_link_speed[speed];
-
-	flags = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_LINK_FLAGS);
-	fcntl = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_FCNTL);
-	lpa = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_LP_CAP);
-
-	/* efx->link_state is only modified by efx_mcdi_phy_get_link(),
-	 * which is only run after flushing the event queues. Therefore, it
-	 * is safe to modify the link state outside of the mac_lock here.
-	 */
-	efx_mcdi_phy_decode_link(efx, &efx->link_state, speed, flags, fcntl);
-
-	efx_mcdi_phy_check_fcntl(efx, lpa);
-
-	efx_link_status_changed(efx);
-}
-
 /* Called from  falcon_process_eventq for MCDI events */
 void efx_mcdi_process_event(struct efx_channel *channel,
 			    efx_qword_t *event)
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 73bc76e..c8f2cd5 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -196,9 +196,14 @@ extern int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out);
 extern int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id);
 extern int efx_mcdi_wol_filter_reset(struct efx_nic *efx);
 extern int efx_mcdi_flush_rxqs(struct efx_nic *efx);
+extern int efx_mcdi_port_probe(struct efx_nic *efx);
+extern void efx_mcdi_port_remove(struct efx_nic *efx);
+extern int efx_mcdi_port_reconfigure(struct efx_nic *efx);
+extern void efx_mcdi_process_link_change(struct efx_nic *efx, efx_qword_t *ev);
 extern int efx_mcdi_set_mac(struct efx_nic *efx);
-extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
-			      u32 dma_len, int enable, int clear);
+#define EFX_MC_STATS_GENERATION_INVALID ((__force __le64)(-1))
+extern void efx_mcdi_mac_start_stats(struct efx_nic *efx);
+extern void efx_mcdi_mac_stop_stats(struct efx_nic *efx);
 extern bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
 extern enum reset_type efx_mcdi_map_reset_reason(enum reset_type reason);
 extern int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method);
diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
deleted file mode 100644
index 1b84b90..0000000
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ /dev/null
@@ -1,114 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2009-2010 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#include "net_driver.h"
-#include "efx.h"
-#include "mcdi.h"
-#include "mcdi_pcol.h"
-
-int efx_mcdi_set_mac(struct efx_nic *efx)
-{
-	u32 reject, fcntl;
-	MCDI_DECLARE_BUF(cmdbytes, MC_CMD_SET_MAC_IN_LEN);
-
-	memcpy(MCDI_PTR(cmdbytes, SET_MAC_IN_ADDR),
-	       efx->net_dev->dev_addr, ETH_ALEN);
-
-	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_MTU,
-			EFX_MAX_FRAME_LEN(efx->net_dev->mtu));
-	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_DRAIN, 0);
-
-	/* The MCDI command provides for controlling accept/reject
-	 * of broadcast packets too, but the driver doesn't currently
-	 * expose this. */
-	reject = (efx->promiscuous) ? 0 :
-		(1 << MC_CMD_SET_MAC_IN_REJECT_UNCST_LBN);
-	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_REJECT, reject);
-
-	switch (efx->wanted_fc) {
-	case EFX_FC_RX | EFX_FC_TX:
-		fcntl = MC_CMD_FCNTL_BIDIR;
-		break;
-	case EFX_FC_RX:
-		fcntl = MC_CMD_FCNTL_RESPOND;
-		break;
-	default:
-		fcntl = MC_CMD_FCNTL_OFF;
-		break;
-	}
-	if (efx->wanted_fc & EFX_FC_AUTO)
-		fcntl = MC_CMD_FCNTL_AUTO;
-	if (efx->fc_disable)
-		fcntl = MC_CMD_FCNTL_OFF;
-
-	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_FCNTL, fcntl);
-
-	return efx_mcdi_rpc(efx, MC_CMD_SET_MAC, cmdbytes, sizeof(cmdbytes),
-			    NULL, 0, NULL);
-}
-
-bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
-{
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LINK_OUT_LEN);
-	size_t outlength;
-	int rc;
-
-	BUILD_BUG_ON(MC_CMD_GET_LINK_IN_LEN != 0);
-
-	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
-			  outbuf, sizeof(outbuf), &outlength);
-	if (rc) {
-		netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
-			  __func__, rc);
-		return true;
-	}
-
-	return MCDI_DWORD(outbuf, GET_LINK_OUT_MAC_FAULT) != 0;
-}
-
-int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
-		       u32 dma_len, int enable, int clear)
-{
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
-	int rc;
-	efx_dword_t *cmd_ptr;
-	int period = enable ? 1000 : 0;
-	u32 addr_hi;
-	u32 addr_lo;
-
-	BUILD_BUG_ON(MC_CMD_MAC_STATS_OUT_DMA_LEN != 0);
-
-	addr_lo = ((u64)dma_addr) >> 0;
-	addr_hi = ((u64)dma_addr) >> 32;
-
-	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_ADDR_LO, addr_lo);
-	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_ADDR_HI, addr_hi);
-	cmd_ptr = (efx_dword_t *)MCDI_PTR(inbuf, MAC_STATS_IN_CMD);
-	EFX_POPULATE_DWORD_7(*cmd_ptr,
-			     MC_CMD_MAC_STATS_IN_DMA, !!enable,
-			     MC_CMD_MAC_STATS_IN_CLEAR, clear,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_CHANGE, 1,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_ENABLE, !!enable,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_CLEAR, 0,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_NOEVENT, 1,
-			     MC_CMD_MAC_STATS_IN_PERIOD_MS, period);
-	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
-
-	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
-			  NULL, 0, NULL);
-	if (rc)
-		goto fail;
-
-	return 0;
-
-fail:
-	netif_err(efx, hw, efx->net_dev, "%s: %s failed rc=%d\n",
-		  __func__, enable ? "enable" : "disable", rc);
-	return rc;
-}
diff --git a/drivers/net/ethernet/sfc/mcdi_phy.c b/drivers/net/ethernet/sfc/mcdi_port.c
similarity index 79%
rename from drivers/net/ethernet/sfc/mcdi_phy.c
rename to drivers/net/ethernet/sfc/mcdi_port.c
index 86c0d21..8f31e3d 100644
--- a/drivers/net/ethernet/sfc/mcdi_phy.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -125,16 +125,16 @@ fail:
 	return rc;
 }
 
-int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
-			 unsigned int prtad, unsigned int devad, u16 addr,
-			 u16 *value_out, u32 *status_out)
+static int efx_mcdi_mdio_read(struct net_device *net_dev,
+			      int prtad, int devad, u16 addr)
 {
+	struct efx_nic *efx = netdev_priv(net_dev);
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_MDIO_READ_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_MDIO_READ_OUT_LEN);
 	size_t outlen;
 	int rc;
 
-	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_BUS, bus);
+	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_BUS, efx->mdio_bus);
 	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_PRTAD, prtad);
 	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_DEVAD, devad);
 	MCDI_SET_DWORD(inbuf, MDIO_READ_IN_ADDR, addr);
@@ -144,25 +144,27 @@ int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
 	if (rc)
 		goto fail;
 
-	*value_out = (u16)MCDI_DWORD(outbuf, MDIO_READ_OUT_VALUE);
-	*status_out = MCDI_DWORD(outbuf, MDIO_READ_OUT_STATUS);
-	return 0;
+	if (MCDI_DWORD(outbuf, MDIO_READ_OUT_STATUS) !=
+	    MC_CMD_MDIO_STATUS_GOOD)
+		return -EIO;
+
+	return (u16)MCDI_DWORD(outbuf, MDIO_READ_OUT_VALUE);
 
 fail:
 	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
-int efx_mcdi_mdio_write(struct efx_nic *efx, unsigned int bus,
-			  unsigned int prtad, unsigned int devad, u16 addr,
-			  u16 value, u32 *status_out)
+static int efx_mcdi_mdio_write(struct net_device *net_dev,
+			       int prtad, int devad, u16 addr, u16 value)
 {
+	struct efx_nic *efx = netdev_priv(net_dev);
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_MDIO_WRITE_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_MDIO_WRITE_OUT_LEN);
 	size_t outlen;
 	int rc;
 
-	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_BUS, bus);
+	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_BUS, efx->mdio_bus);
 	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_PRTAD, prtad);
 	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_DEVAD, devad);
 	MCDI_SET_DWORD(inbuf, MDIO_WRITE_IN_ADDR, addr);
@@ -173,7 +175,10 @@ int efx_mcdi_mdio_write(struct efx_nic *efx, unsigned int bus,
 	if (rc)
 		goto fail;
 
-	*status_out = MCDI_DWORD(outbuf, MDIO_WRITE_OUT_STATUS);
+	if (MCDI_DWORD(outbuf, MDIO_WRITE_OUT_STATUS) !=
+	    MC_CMD_MDIO_STATUS_GOOD)
+		return -EIO;
+
 	return 0;
 
 fail:
@@ -304,6 +309,33 @@ static u32 mcdi_to_ethtool_media(u32 media)
 	}
 }
 
+static void efx_mcdi_phy_decode_link(struct efx_nic *efx,
+			      struct efx_link_state *link_state,
+			      u32 speed, u32 flags, u32 fcntl)
+{
+	switch (fcntl) {
+	case MC_CMD_FCNTL_AUTO:
+		WARN_ON(1);	/* This is not a link mode */
+		link_state->fc = EFX_FC_AUTO | EFX_FC_TX | EFX_FC_RX;
+		break;
+	case MC_CMD_FCNTL_BIDIR:
+		link_state->fc = EFX_FC_TX | EFX_FC_RX;
+		break;
+	case MC_CMD_FCNTL_RESPOND:
+		link_state->fc = EFX_FC_RX;
+		break;
+	default:
+		WARN_ON(1);
+	case MC_CMD_FCNTL_OFF:
+		link_state->fc = 0;
+		break;
+	}
+
+	link_state->up = !!(flags & (1 << MC_CMD_GET_LINK_OUT_LINK_UP_LBN));
+	link_state->fd = !!(flags & (1 << MC_CMD_GET_LINK_OUT_FULL_DUPLEX_LBN));
+	link_state->speed = speed;
+}
+
 static int efx_mcdi_phy_probe(struct efx_nic *efx)
 {
 	struct efx_mcdi_phy_data *phy_data;
@@ -403,7 +435,7 @@ fail:
 	return rc;
 }
 
-int efx_mcdi_phy_reconfigure(struct efx_nic *efx)
+int efx_mcdi_port_reconfigure(struct efx_nic *efx)
 {
 	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u32 caps = (efx->link_advertising ?
@@ -414,37 +446,10 @@ int efx_mcdi_phy_reconfigure(struct efx_nic *efx)
 				 efx->loopback_mode, 0);
 }
 
-void efx_mcdi_phy_decode_link(struct efx_nic *efx,
-			      struct efx_link_state *link_state,
-			      u32 speed, u32 flags, u32 fcntl)
-{
-	switch (fcntl) {
-	case MC_CMD_FCNTL_AUTO:
-		WARN_ON(1);	/* This is not a link mode */
-		link_state->fc = EFX_FC_AUTO | EFX_FC_TX | EFX_FC_RX;
-		break;
-	case MC_CMD_FCNTL_BIDIR:
-		link_state->fc = EFX_FC_TX | EFX_FC_RX;
-		break;
-	case MC_CMD_FCNTL_RESPOND:
-		link_state->fc = EFX_FC_RX;
-		break;
-	default:
-		WARN_ON(1);
-	case MC_CMD_FCNTL_OFF:
-		link_state->fc = 0;
-		break;
-	}
-
-	link_state->up = !!(flags & (1 << MC_CMD_GET_LINK_OUT_LINK_UP_LBN));
-	link_state->fd = !!(flags & (1 << MC_CMD_GET_LINK_OUT_FULL_DUPLEX_LBN));
-	link_state->speed = speed;
-}
-
 /* Verify that the forced flow control settings (!EFX_FC_AUTO) are
  * supported by the link partner. Warn the user if this isn't the case
  */
-void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa)
+static void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa)
 {
 	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u32 rmtadv;
@@ -808,10 +813,10 @@ static int efx_mcdi_phy_get_module_info(struct efx_nic *efx,
 	}
 }
 
-const struct efx_phy_operations efx_mcdi_phy_ops = {
+static const struct efx_phy_operations efx_mcdi_phy_ops = {
 	.probe		= efx_mcdi_phy_probe,
 	.init		= efx_port_dummy_op_int,
-	.reconfigure	= efx_mcdi_phy_reconfigure,
+	.reconfigure	= efx_mcdi_port_reconfigure,
 	.poll		= efx_mcdi_phy_poll,
 	.fini		= efx_port_dummy_op_void,
 	.remove		= efx_mcdi_phy_remove,
@@ -823,3 +828,183 @@ const struct efx_phy_operations efx_mcdi_phy_ops = {
 	.get_module_eeprom = efx_mcdi_phy_get_module_eeprom,
 	.get_module_info = efx_mcdi_phy_get_module_info,
 };
+
+static unsigned int efx_mcdi_event_link_speed[] = {
+	[MCDI_EVENT_LINKCHANGE_SPEED_100M] = 100,
+	[MCDI_EVENT_LINKCHANGE_SPEED_1G] = 1000,
+	[MCDI_EVENT_LINKCHANGE_SPEED_10G] = 10000,
+};
+
+void efx_mcdi_process_link_change(struct efx_nic *efx, efx_qword_t *ev)
+{
+	u32 flags, fcntl, speed, lpa;
+
+	speed = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_SPEED);
+	EFX_BUG_ON_PARANOID(speed >= ARRAY_SIZE(efx_mcdi_event_link_speed));
+	speed = efx_mcdi_event_link_speed[speed];
+
+	flags = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_LINK_FLAGS);
+	fcntl = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_FCNTL);
+	lpa = EFX_QWORD_FIELD(*ev, MCDI_EVENT_LINKCHANGE_LP_CAP);
+
+	/* efx->link_state is only modified by efx_mcdi_phy_get_link(),
+	 * which is only run after flushing the event queues. Therefore, it
+	 * is safe to modify the link state outside of the mac_lock here.
+	 */
+	efx_mcdi_phy_decode_link(efx, &efx->link_state, speed, flags, fcntl);
+
+	efx_mcdi_phy_check_fcntl(efx, lpa);
+
+	efx_link_status_changed(efx);
+}
+
+int efx_mcdi_set_mac(struct efx_nic *efx)
+{
+	u32 reject, fcntl;
+	MCDI_DECLARE_BUF(cmdbytes, MC_CMD_SET_MAC_IN_LEN);
+
+	BUILD_BUG_ON(MC_CMD_SET_MAC_OUT_LEN != 0);
+
+	memcpy(MCDI_PTR(cmdbytes, SET_MAC_IN_ADDR),
+	       efx->net_dev->dev_addr, ETH_ALEN);
+
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_MTU,
+			EFX_MAX_FRAME_LEN(efx->net_dev->mtu));
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_DRAIN, 0);
+
+	/* The MCDI command provides for controlling accept/reject
+	 * of broadcast packets too, but the driver doesn't currently
+	 * expose this. */
+	reject = (efx->promiscuous) ? 0 :
+		(1 << MC_CMD_SET_MAC_IN_REJECT_UNCST_LBN);
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_REJECT, reject);
+
+	switch (efx->wanted_fc) {
+	case EFX_FC_RX | EFX_FC_TX:
+		fcntl = MC_CMD_FCNTL_BIDIR;
+		break;
+	case EFX_FC_RX:
+		fcntl = MC_CMD_FCNTL_RESPOND;
+		break;
+	default:
+		fcntl = MC_CMD_FCNTL_OFF;
+		break;
+	}
+	if (efx->wanted_fc & EFX_FC_AUTO)
+		fcntl = MC_CMD_FCNTL_AUTO;
+	if (efx->fc_disable)
+		fcntl = MC_CMD_FCNTL_OFF;
+
+	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_FCNTL, fcntl);
+
+	return efx_mcdi_rpc(efx, MC_CMD_SET_MAC, cmdbytes, sizeof(cmdbytes),
+			    NULL, 0, NULL);
+}
+
+bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
+{
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LINK_OUT_LEN);
+	size_t outlength;
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_GET_LINK_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlength);
+	if (rc) {
+		netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+			  __func__, rc);
+		return true;
+	}
+
+	return MCDI_DWORD(outbuf, GET_LINK_OUT_MAC_FAULT) != 0;
+}
+
+static int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
+			      u32 dma_len, int enable, int clear)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
+	int rc;
+	efx_dword_t *cmd_ptr;
+	int period = enable ? 1000 : 0;
+
+	BUILD_BUG_ON(MC_CMD_MAC_STATS_OUT_DMA_LEN != 0);
+
+	MCDI_SET_QWORD(inbuf, MAC_STATS_IN_DMA_ADDR, dma_addr);
+	cmd_ptr = (efx_dword_t *)MCDI_PTR(inbuf, MAC_STATS_IN_CMD);
+	EFX_POPULATE_DWORD_7(*cmd_ptr,
+			     MC_CMD_MAC_STATS_IN_DMA, !!enable,
+			     MC_CMD_MAC_STATS_IN_CLEAR, clear,
+			     MC_CMD_MAC_STATS_IN_PERIODIC_CHANGE, 1,
+			     MC_CMD_MAC_STATS_IN_PERIODIC_ENABLE, !!enable,
+			     MC_CMD_MAC_STATS_IN_PERIODIC_CLEAR, 0,
+			     MC_CMD_MAC_STATS_IN_PERIODIC_NOEVENT, 1,
+			     MC_CMD_MAC_STATS_IN_PERIOD_MS, period);
+	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
+			  NULL, 0, NULL);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	netif_err(efx, hw, efx->net_dev, "%s: %s failed rc=%d\n",
+		  __func__, enable ? "enable" : "disable", rc);
+	return rc;
+}
+
+void efx_mcdi_mac_start_stats(struct efx_nic *efx)
+{
+	__le64 *dma_stats = efx->stats_buffer.addr;
+
+	dma_stats[MC_CMD_MAC_GENERATION_END] = EFX_MC_STATS_GENERATION_INVALID;
+
+	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr,
+			   MC_CMD_MAC_NSTATS * sizeof(u64), 1, 0);
+}
+
+void efx_mcdi_mac_stop_stats(struct efx_nic *efx)
+{
+	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 0);
+}
+
+int efx_mcdi_port_probe(struct efx_nic *efx)
+{
+	int rc;
+
+	/* Hook in PHY operations table */
+	efx->phy_op = &efx_mcdi_phy_ops;
+
+	/* Set up MDIO structure for PHY */
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->mdio.mdio_read = efx_mcdi_mdio_read;
+	efx->mdio.mdio_write = efx_mcdi_mdio_write;
+
+	/* Fill out MDIO structure, loopback modes, and initial link state */
+	rc = efx->phy_op->probe(efx);
+	if (rc != 0)
+		return rc;
+
+	/* Allocate buffer for stats */
+	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
+				  MC_CMD_MAC_NSTATS * sizeof(u64));
+	if (rc)
+		return rc;
+	netif_dbg(efx, probe, efx->net_dev,
+		  "stats buffer at %llx (virt %p phys %llx)\n",
+		  (u64)efx->stats_buffer.dma_addr,
+		  efx->stats_buffer.addr,
+		  (u64)virt_to_phys(efx->stats_buffer.addr));
+
+	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 1);
+
+	return 0;
+}
+
+void efx_mcdi_port_remove(struct efx_nic *efx)
+{
+	efx->phy_op->remove(efx);
+	efx_nic_free_buffer(efx, &efx->stats_buffer);
+}
diff --git a/drivers/net/ethernet/sfc/phy.h b/drivers/net/ethernet/sfc/phy.h
index 11d148c..4f6eb81 100644
--- a/drivers/net/ethernet/sfc/phy.h
+++ b/drivers/net/ethernet/sfc/phy.h
@@ -47,21 +47,4 @@ extern const struct efx_phy_operations falcon_txc_phy_ops;
 extern void falcon_txc_set_gpio_dir(struct efx_nic *efx, int pin, int dir);
 extern void falcon_txc_set_gpio_val(struct efx_nic *efx, int pin, int val);
 
-/****************************************************************************
- * Siena managed PHYs
- */
-extern const struct efx_phy_operations efx_mcdi_phy_ops;
-
-extern int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
-			      unsigned int prtad, unsigned int devad,
-			      u16 addr, u16 *value_out, u32 *status_out);
-extern int efx_mcdi_mdio_write(struct efx_nic *efx, unsigned int bus,
-			       unsigned int prtad, unsigned int devad,
-			       u16 addr, u16 value, u32 *status_out);
-extern void efx_mcdi_phy_decode_link(struct efx_nic *efx,
-				     struct efx_link_state *link_state,
-				     u32 speed, u32 flags, u32 fcntl);
-extern int efx_mcdi_phy_reconfigure(struct efx_nic *efx);
-extern void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa);
-
 #endif
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 1febedb..b5d5568 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -51,81 +51,6 @@ static void siena_push_irq_moderation(struct efx_channel *channel)
 			       channel->channel);
 }
 
-static int siena_mdio_write(struct net_device *net_dev,
-			    int prtad, int devad, u16 addr, u16 value)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	uint32_t status;
-	int rc;
-
-	rc = efx_mcdi_mdio_write(efx, efx->mdio_bus, prtad, devad,
-				 addr, value, &status);
-	if (rc)
-		return rc;
-	if (status != MC_CMD_MDIO_STATUS_GOOD)
-		return -EIO;
-
-	return 0;
-}
-
-static int siena_mdio_read(struct net_device *net_dev,
-			   int prtad, int devad, u16 addr)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	uint16_t value;
-	uint32_t status;
-	int rc;
-
-	rc = efx_mcdi_mdio_read(efx, efx->mdio_bus, prtad, devad,
-				addr, &value, &status);
-	if (rc)
-		return rc;
-	if (status != MC_CMD_MDIO_STATUS_GOOD)
-		return -EIO;
-
-	return (int)value;
-}
-
-/* This call is responsible for hooking in the MAC and PHY operations */
-static int siena_probe_port(struct efx_nic *efx)
-{
-	int rc;
-
-	/* Hook in PHY operations table */
-	efx->phy_op = &efx_mcdi_phy_ops;
-
-	/* Set up MDIO structure for PHY */
-	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
-	efx->mdio.mdio_read = siena_mdio_read;
-	efx->mdio.mdio_write = siena_mdio_write;
-
-	/* Fill out MDIO structure, loopback modes, and initial link state */
-	rc = efx->phy_op->probe(efx);
-	if (rc != 0)
-		return rc;
-
-	/* Allocate buffer for stats */
-	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
-				  MC_CMD_MAC_NSTATS * sizeof(u64));
-	if (rc)
-		return rc;
-	netif_dbg(efx, probe, efx->net_dev,
-		  "stats buffer at %llx (virt %p phys %llx)\n",
-		  (u64)efx->stats_buffer.dma_addr,
-		  efx->stats_buffer.addr,
-		  (u64)virt_to_phys(efx->stats_buffer.addr));
-
-	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 1);
-
-	return 0;
-}
-
-static void siena_remove_port(struct efx_nic *efx)
-{
-	efx->phy_op->remove(efx);
-	efx_nic_free_buffer(efx, &efx->stats_buffer);
-}
-
 void siena_prepare_flush(struct efx_nic *efx)
 {
 	if (efx->fc_disable++ == 0)
@@ -447,8 +372,6 @@ static void siena_remove_nic(struct efx_nic *efx)
 	efx->nic_data = NULL;
 }
 
-#define STATS_GENERATION_INVALID ((__force __le64)(-1))
-
 static int siena_try_update_nic_stats(struct efx_nic *efx)
 {
 	__le64 *dma_stats;
@@ -459,7 +382,7 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 	dma_stats = efx->stats_buffer.addr;
 
 	generation_end = dma_stats[MC_CMD_MAC_GENERATION_END];
-	if (generation_end == STATS_GENERATION_INVALID)
+	if (generation_end == EFX_MC_STATS_GENERATION_INVALID)
 		return 0;
 	rmb();
 
@@ -562,21 +485,6 @@ static void siena_update_nic_stats(struct efx_nic *efx)
 	/* Use the old values instead */
 }
 
-static void siena_start_nic_stats(struct efx_nic *efx)
-{
-	__le64 *dma_stats = efx->stats_buffer.addr;
-
-	dma_stats[MC_CMD_MAC_GENERATION_END] = STATS_GENERATION_INVALID;
-
-	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr,
-			   MC_CMD_MAC_NSTATS * sizeof(u64), 1, 0);
-}
-
-static void siena_stop_nic_stats(struct efx_nic *efx)
-{
-	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 0);
-}
-
 static int siena_mac_reconfigure(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_MCAST_HASH_IN_LEN);
@@ -691,18 +599,18 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.map_reset_reason = efx_mcdi_map_reset_reason,
 	.map_reset_flags = siena_map_reset_flags,
 	.reset = efx_mcdi_reset,
-	.probe_port = siena_probe_port,
-	.remove_port = siena_remove_port,
+	.probe_port = efx_mcdi_port_probe,
+	.remove_port = efx_mcdi_port_remove,
 	.prepare_flush = siena_prepare_flush,
 	.finish_flush = siena_finish_flush,
 	.update_stats = siena_update_nic_stats,
-	.start_stats = siena_start_nic_stats,
-	.stop_stats = siena_stop_nic_stats,
+	.start_stats = efx_mcdi_mac_start_stats,
+	.stop_stats = efx_mcdi_mac_stop_stats,
 	.set_id_led = efx_mcdi_set_id_led,
 	.push_irq_moderation = siena_push_irq_moderation,
 	.reconfigure_mac = siena_mac_reconfigure,
 	.check_mac_fault = efx_mcdi_mac_check_fault,
-	.reconfigure_port = efx_mcdi_phy_reconfigure,
+	.reconfigure_port = efx_mcdi_port_reconfigure,
 	.get_wol = siena_get_wol,
 	.set_wol = siena_set_wol,
 	.resume_wol = siena_init_wol,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
