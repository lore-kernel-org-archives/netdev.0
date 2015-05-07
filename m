From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [RFC,v3 12/12] fsl/fman: Add FMan MAC driver
Date: Thu, 7 May 2015 16:05:43 +0300
Message-ID: <1431003943-14906-12-git-send-email-madalin.bucur@freescale.com>
References: <1431003943-14906-1-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-2-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-3-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-4-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-5-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-6-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-7-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-8-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-9-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-10-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-11-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Igal Liberman <Igal.Liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0112.outbound.protection.outlook.com ([157.56.111.112]:4843
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751959AbbEGNGE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 09:06:04 -0400
In-Reply-To: <1431003943-14906-11-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <Igal.Liberman@freescale.com>

This patch adds the Ethernet MAC driver support.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/inc/mac.h     | 125 +++++
 drivers/net/ethernet/freescale/fman/mac/Makefile  |   3 +-
 drivers/net/ethernet/freescale/fman/mac/mac-api.c | 605 ++++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/mac/mac.c     | 527 +++++++++++++++++++
 4 files changed, 1259 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/mac.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/mac-api.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/mac.c

diff --git a/drivers/net/ethernet/freescale/fman/inc/mac.h b/drivers/net/ethernet/freescale/fman/inc/mac.h
new file mode 100644
index 0000000..2d27331
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/mac.h
@@ -0,0 +1,125 @@
+/* Copyright 2008-2015 Freescale Semiconductor, Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __MAC_H
+#define __MAC_H
+
+#include <linux/device.h>	/* struct device, BUS_ID_SIZE */
+#include <linux/if_ether.h>	/* ETH_ALEN */
+#include <linux/phy.h>		/* phy_interface_t, struct phy_device */
+#include <linux/list.h>
+
+#include "fsl_fman_drv.h"	/* struct port_device */
+#include "fm_mac_ext.h"		/* FM MAC API */
+#include "fm_port_ext.h"
+
+enum {DTSEC, XGMAC, MEMAC};
+
+struct mac_device {
+	struct device		*dev;
+	void			*priv;
+	u8			 cell_index;
+	struct resource		*res;
+	void __iomem		*vaddr;
+	u8			 addr[ETH_ALEN];
+	bool			 promisc;
+
+	struct fm		*fm_dev;
+	struct fm_port		*port_dev[2];
+
+	phy_interface_t		 phy_if;
+	u32			 if_support;
+	bool			 link;
+	u16		 speed;
+	u16		 max_speed;
+	struct device_node	*phy_node;
+	char			 fixed_bus_id[MII_BUS_ID_SIZE + 3];
+	struct device_node	*tbi_node;
+	struct phy_device	*phy_dev;
+	void			*fm;
+	/* List of multicast addresses */
+	struct list_head	 mc_addr_list;
+	struct platform_device	*eth_dev;
+
+	bool autoneg_pause;
+	bool rx_pause_req;
+	bool tx_pause_req;
+	bool rx_pause_active;
+	bool tx_pause_active;
+
+	struct fm_mac_dev * (*get_mac_handle)(struct mac_device *mac_dev);
+	int (*init_phy)(struct net_device *net_dev, struct mac_device *mac_dev);
+	int (*init)(struct mac_device *mac_dev);
+	int (*start)(struct mac_device *mac_dev);
+	int (*stop)(struct mac_device *mac_dev);
+	int (*set_promisc)(struct fm_mac_dev *fm_mac_dev, bool enable);
+	int (*change_addr)(struct fm_mac_dev *fm_mac_dev,
+			   enet_addr_t *p_enet_addr);
+	int (*set_multi)(struct net_device *net_dev,
+			 struct mac_device *mac_dev);
+	int (*uninit)(struct fm_mac_dev *fm_mac_dev);
+	int (*set_rx_pause)(struct fm_mac_dev *fm_mac_dev, bool en);
+	int (*set_tx_pause)(struct fm_mac_dev *fm_mac_dev, u8 priority,
+			    u16 pause_time, u16 thresh_time);
+};
+
+struct mac_address {
+	u8 addr[ETH_ALEN];
+	struct list_head list;
+};
+
+struct dpaa_eth_data {
+	struct device_node *mac_node;
+	struct mac_device *mac_dev;
+	int mac_hw_id;
+	int fman_hw_id;
+};
+
+#define get_fm_handle(net_dev) \
+	(((struct dpa_priv_s *)netdev_priv(net_dev))->mac_dev->fm_dev)
+
+#define for_each_port_device(i, port_dev)	\
+	for (i = 0; i < ARRAY_SIZE(port_dev); i++)
+
+static inline __attribute((nonnull)) void *macdev_priv(
+		const struct mac_device *mac_dev)
+{
+	return (void *)mac_dev + sizeof(*mac_dev);
+}
+
+extern const char	*mac_driver_description;
+extern const size_t	 mac_sizeof_priv[];
+extern void (*const mac_setup[])(struct mac_device *mac_dev);
+
+int set_mac_active_pause(struct mac_device *mac_dev, bool rx, bool tx);
+void get_pause_cfg(struct mac_device *mac_dev, bool *rx_pause, bool *tx_pause);
+
+#endif	/* __MAC_H */
diff --git a/drivers/net/ethernet/freescale/fman/mac/Makefile b/drivers/net/ethernet/freescale/fman/mac/Makefile
index 042a1f7..a422fbf 100644
--- a/drivers/net/ethernet/freescale/fman/mac/Makefile
+++ b/drivers/net/ethernet/freescale/fman/mac/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_FSL_FMAN_MAC)	+= fsl_fman_mac.o
+obj-y	+= fsl_fman_mac.o  fsl_mac.o
 
 fsl_fman_mac-objs		:= fman_dtsec.o fman_dtsec_mii_acc.o	\
 				    dtsec.o dtsec_mii_acc.o		\
@@ -6,3 +6,4 @@ fsl_fman_mac-objs		:= fman_dtsec.o fman_dtsec_mii_acc.o	\
 				   memac.o memac_mii_acc.o		\
 				   fman_tgec.o tgec.o			\
 				   fman_crc32.o fm_mac.o
+fsl_mac-objs += mac.o mac-api.o
diff --git a/drivers/net/ethernet/freescale/fman/mac/mac-api.c b/drivers/net/ethernet/freescale/fman/mac/mac-api.c
new file mode 100644
index 0000000..159aa15
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/mac-api.c
@@ -0,0 +1,605 @@
+/* Copyright 2008-2015 Freescale Semiconductor, Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUG
+#define pr_fmt(fmt) \
+	KBUILD_MODNAME ": %s:%hu:%s() " fmt, \
+	KBUILD_BASENAME ".c", __LINE__, __func__
+#else
+#define pr_fmt(fmt) \
+	KBUILD_MODNAME ": " fmt
+#endif
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/of_platform.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+
+#include "mac.h"
+#include "fsl_fman_drv.h"
+#include "fm_mac_ext.h"
+
+#include "../fman/flib/fsl_fman_dtsec.h"
+#include "../fman/flib/fsl_fman_tgec.h"
+#include "../fman/flib/fsl_fman_memac.h"
+
+#define MAC_DESCRIPTION "FSL FMan MAC API based driver"
+
+MODULE_LICENSE("Dual BSD/GPL");
+
+MODULE_AUTHOR("Emil Medve <Emilian.Medve@Freescale.com>");
+
+MODULE_DESCRIPTION(MAC_DESCRIPTION);
+
+struct mac_priv_s {
+	struct fm_mac_dev *fm_mac;
+};
+
+const char	*mac_driver_description __initconst = MAC_DESCRIPTION;
+const size_t	 mac_sizeof_priv[] = {
+	[DTSEC] = sizeof(struct mac_priv_s),
+	[XGMAC] = sizeof(struct mac_priv_s),
+	[MEMAC] = sizeof(struct mac_priv_s)
+};
+
+static const enet_mode_t _100[] = {
+	[PHY_INTERFACE_MODE_MII]	= ENET_MODE_MII_100,
+	[PHY_INTERFACE_MODE_RMII]	= ENET_MODE_RMII_100
+};
+
+static const enet_mode_t _1000[] = {
+	[PHY_INTERFACE_MODE_GMII]	= ENET_MODE_GMII_1000,
+	[PHY_INTERFACE_MODE_SGMII]	= ENET_MODE_SGMII_1000,
+	[PHY_INTERFACE_MODE_TBI]	= ENET_MODE_TBI_1000,
+	[PHY_INTERFACE_MODE_RGMII]	= ENET_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RGMII_ID]	= ENET_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RGMII_RXID]	= ENET_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RGMII_TXID]	= ENET_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RTBI]	= ENET_MODE_RTBI_1000
+};
+
+static enet_mode_t __cold __attribute__((nonnull))
+macdev2enetinterface(const struct mac_device *mac_dev)
+{
+	switch (mac_dev->max_speed) {
+	case SPEED_100:
+		return _100[mac_dev->phy_if];
+	case SPEED_1000:
+		return _1000[mac_dev->phy_if];
+	case SPEED_10000:
+		return ENET_MODE_XGMII_10000;
+	default:
+		return ENET_MODE_MII_100;
+	}
+}
+
+static void mac_exception(void *_mac_dev, enum fm_mac_exceptions ex)
+{
+	struct mac_device	*mac_dev;
+
+	mac_dev = (struct mac_device *)_mac_dev;
+
+	if (FM_MAC_EX_10G_RX_FIFO_OVFL == ex) {
+		/* don't flag RX FIFO after the first */
+		fm_mac_set_exception(mac_dev->get_mac_handle(mac_dev),
+				     FM_MAC_EX_10G_RX_FIFO_OVFL, false);
+		dev_err(mac_dev->dev, "10G MAC got RX FIFO Error = %x\n",
+			ex);
+	}
+
+	dev_dbg(mac_dev->dev, "%s:%s() -> %d\n", KBUILD_BASENAME ".c",
+		__func__, ex);
+}
+
+static int __cold init(struct mac_device *mac_dev)
+{
+	int					_errno;
+	struct mac_priv_s	*priv;
+	struct fm_mac_params_t		param;
+	u32			version;
+
+	priv = macdev_priv(mac_dev);
+
+	param.base_addr =  (typeof(param.base_addr))(uintptr_t)devm_ioremap(
+		mac_dev->dev, mac_dev->res->start, 0x2000);
+	param.enet_mode	= macdev2enetinterface(mac_dev);
+	memcpy(&param.addr, mac_dev->addr,
+	       min(sizeof(param.addr), sizeof(mac_dev->addr)));
+	param.mac_id		= mac_dev->cell_index;
+	param.h_fm		= (void *)mac_dev->fm;
+	param.mdio_irq		= NO_IRQ;
+	param.f_exception	= mac_exception;
+	param.f_event		= mac_exception;
+	param.h_app		= mac_dev;
+
+	priv->fm_mac = fm_mac_config(&param);
+	if (unlikely(!priv->fm_mac)) {
+		_errno = -EINVAL;
+		goto _return;
+	}
+
+	_errno = fm_mac_cfg_max_frame_len(priv->fm_mac, fm_get_max_frm());
+	if (unlikely(_errno < 0))
+		goto _return_fm_mac_free;
+
+	if (macdev2enetinterface(mac_dev) != ENET_MODE_XGMII_10000) {
+		/* 10G always works with pad and CRC */
+		_errno = fm_mac_cfg_pad_and_crc(priv->fm_mac, true);
+		if (unlikely(_errno < 0))
+			goto _return_fm_mac_free;
+
+		if (unlikely(_errno < 0))
+			goto _return_fm_mac_free;
+	} else {
+		_errno = fm_mac_cfg_reset_on_init(priv->fm_mac, true);
+		if (unlikely(_errno < 0))
+			goto _return_fm_mac_free;
+	}
+
+	_errno = fm_mac_init(priv->fm_mac);
+	if (unlikely(_errno < 0))
+		goto _return_fm_mac_free;
+
+	/* For 1G MAC, disable by default the MIB counters overflow interrupt */
+	if (macdev2enetinterface(mac_dev) != ENET_MODE_XGMII_10000) {
+		_errno = fm_mac_set_exception(mac_dev->get_mac_handle(mac_dev),
+					      FM_MAC_EX_1G_RX_MIB_CNT_OVFL,
+					      false);
+		if (unlikely(_errno < 0))
+			goto _return_fm_mac_free;
+	}
+
+	/* For 10G MAC, disable Tx ECC exception */
+	if (macdev2enetinterface(mac_dev) == ENET_MODE_XGMII_10000) {
+		_errno = fm_mac_set_exception(mac_dev->get_mac_handle(mac_dev),
+					      FM_MAC_EX_10G_1TX_ECC_ER, false);
+		if (unlikely(_errno < 0))
+			goto _return_fm_mac_free;
+	}
+
+	_errno = fm_mac_get_version(priv->fm_mac, &version);
+	if (unlikely(_errno < 0))
+		goto _return_fm_mac_free;
+
+	dev_info(mac_dev->dev, "FMan %s version: 0x%08x\n",
+		 ((macdev2enetinterface(mac_dev) != ENET_MODE_XGMII_10000) ?
+		  "dTSEC" : "XGEC"), version);
+
+	goto _return;
+
+_return_fm_mac_free:
+	fm_mac_free(mac_dev->get_mac_handle(mac_dev));
+
+_return:
+	return _errno;
+}
+
+static int __cold memac_init(struct mac_device *mac_dev)
+{
+	int			_errno;
+	struct mac_priv_s	*priv;
+	struct fm_mac_params_t		param;
+
+	priv = macdev_priv(mac_dev);
+
+	param.base_addr =  (typeof(param.base_addr))(uintptr_t)devm_ioremap(
+		mac_dev->dev, mac_dev->res->start, 0x2000);
+	param.enet_mode	= macdev2enetinterface(mac_dev);
+	memcpy(&param.addr, mac_dev->addr, sizeof(mac_dev->addr));
+	param.mac_id		= mac_dev->cell_index;
+	param.h_fm		= (void *)mac_dev->fm;
+	param.mdio_irq		= NO_IRQ;
+	param.f_exception	= mac_exception;
+	param.f_event		= mac_exception;
+	param.h_app		= mac_dev;
+
+	priv->fm_mac = fm_mac_config(&param);
+	if (unlikely(!priv->fm_mac)) {
+		_errno = -EINVAL;
+		goto _return;
+	}
+
+	_errno = fm_mac_cfg_max_frame_len(priv->fm_mac, fm_get_max_frm());
+	if (unlikely(_errno < 0))
+		goto _return_fm_mac_free;
+
+	_errno = fm_mac_cfg_reset_on_init(priv->fm_mac, true);
+	if (unlikely(_errno < 0))
+		goto _return_fm_mac_free;
+
+	_errno = fm_mac_init(priv->fm_mac);
+	if (unlikely(_errno < 0))
+		goto _return_fm_mac_free;
+
+	dev_info(mac_dev->dev, "FMan MEMAC\n");
+
+	goto _return;
+
+_return_fm_mac_free:
+	fm_mac_free(priv->fm_mac);
+
+_return:
+	return _errno;
+}
+
+static int __cold start(struct mac_device *mac_dev)
+{
+	int	 _errno;
+	struct phy_device *phy_dev = mac_dev->phy_dev;
+
+	_errno = fm_mac_enable(mac_dev->get_mac_handle(mac_dev),
+			       COMM_MODE_RX_AND_TX);
+
+	if (!_errno && phy_dev) {
+		if (macdev2enetinterface(mac_dev) != ENET_MODE_XGMII_10000)
+			phy_start(phy_dev);
+		else if (phy_dev->drv->read_status)
+			phy_dev->drv->read_status(phy_dev);
+	}
+
+	return _errno;
+}
+
+static int __cold stop(struct mac_device *mac_dev)
+{
+	if (mac_dev->phy_dev && (macdev2enetinterface(mac_dev) !=
+				 ENET_MODE_XGMII_10000))
+		phy_stop(mac_dev->phy_dev);
+
+	return fm_mac_disable(mac_dev->get_mac_handle(mac_dev),
+			      COMM_MODE_RX_AND_TX);
+}
+
+static int __cold set_multi(struct net_device *net_dev,
+			    struct mac_device *mac_dev)
+{
+	struct mac_priv_s	*mac_priv;
+	struct mac_address	*old_addr, *tmp;
+	struct netdev_hw_addr	*ha;
+	int			_errno;
+	enet_addr_t		*addr;
+
+	mac_priv = macdev_priv(mac_dev);
+
+	/* Clear previous address list */
+	list_for_each_entry_safe(old_addr, tmp, &mac_dev->mc_addr_list, list) {
+		addr = (enet_addr_t *)old_addr->addr;
+		_errno = fm_mac_remove_hash_mac_addr(mac_priv->fm_mac, addr);
+		if (_errno < 0)
+			return _errno;
+
+		list_del(&old_addr->list);
+		kfree(old_addr);
+	}
+
+	/* Add all the addresses from the new list */
+	netdev_for_each_mc_addr(ha, net_dev) {
+		addr = (enet_addr_t *)ha->addr;
+		_errno = fm_mac_add_hash_mac_addr(mac_priv->fm_mac, addr);
+		if (_errno < 0)
+			return _errno;
+
+		tmp = kmalloc(sizeof(*tmp), GFP_ATOMIC);
+		if (!tmp)
+			return -ENOMEM;
+
+		ether_addr_copy(tmp->addr, ha->addr);
+		list_add(&tmp->list, &mac_dev->mc_addr_list);
+	}
+	return 0;
+}
+
+/* Avoid redundant calls to FMD, if the MAC driver already contains the desired
+ * active PAUSE settings. Otherwise, the new active settings should be reflected
+ * in FMan.
+ */
+int set_mac_active_pause(struct mac_device *mac_dev, bool rx, bool tx)
+{
+	struct fm_mac_dev *fm_mac_dev = mac_dev->get_mac_handle(mac_dev);
+	int _errno = 0;
+
+	if (unlikely(rx != mac_dev->rx_pause_active)) {
+		_errno = fm_mac_set_rx_pause_frames(fm_mac_dev, rx);
+		if (likely(_errno == 0))
+			mac_dev->rx_pause_active = rx;
+	}
+
+	if (unlikely(tx != mac_dev->tx_pause_active)) {
+		u16 pause_time = (tx ? FSL_FM_PAUSE_TIME_ENABLE :
+					 FSL_FM_PAUSE_TIME_DISABLE);
+
+		_errno = fm_mac_set_tx_pause_frames(fm_mac_dev, 0,
+						    pause_time, 0);
+
+		if (likely(_errno == 0))
+			mac_dev->tx_pause_active = tx;
+	}
+
+	return _errno;
+}
+EXPORT_SYMBOL(set_mac_active_pause);
+
+/* Determine the MAC RX/TX PAUSE frames settings based on PHY
+ * autonegotiation or values set by eththool.
+ */
+void get_pause_cfg(struct mac_device *mac_dev, bool *rx_pause, bool *tx_pause)
+{
+	struct phy_device *phy_dev = mac_dev->phy_dev;
+	u16 lcl_adv, rmt_adv;
+	u8 flowctrl;
+
+	*rx_pause = *tx_pause = false;
+
+	if (!phy_dev->duplex)
+		return;
+
+	/* If PAUSE autonegotiation is disabled, the TX/RX PAUSE settings
+	 * are those set by ethtool.
+	 */
+	if (!mac_dev->autoneg_pause) {
+		*rx_pause = mac_dev->rx_pause_req;
+		*tx_pause = mac_dev->tx_pause_req;
+		return;
+	}
+
+	/* Else if PAUSE autonegotiation is enabled, the TX/RX PAUSE
+	 * settings depend on the result of the link negotiation.
+	 */
+
+	/* get local capabilities */
+	lcl_adv = 0;
+	if (phy_dev->advertising & ADVERTISED_Pause)
+		lcl_adv |= ADVERTISE_PAUSE_CAP;
+	if (phy_dev->advertising & ADVERTISED_Asym_Pause)
+		lcl_adv |= ADVERTISE_PAUSE_ASYM;
+
+	/* get link partner capabilities */
+	rmt_adv = 0;
+	if (phy_dev->pause)
+		rmt_adv |= LPA_PAUSE_CAP;
+	if (phy_dev->asym_pause)
+		rmt_adv |= LPA_PAUSE_ASYM;
+
+	/* Calculate TX/RX settings based on local and peer advertised
+	 * symmetric/asymmetric PAUSE capabilities.
+	 */
+	flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
+	if (flowctrl & FLOW_CTRL_RX)
+		*rx_pause = true;
+	if (flowctrl & FLOW_CTRL_TX)
+		*tx_pause = true;
+}
+EXPORT_SYMBOL(get_pause_cfg);
+
+static void adjust_link(struct net_device *net_dev)
+{
+	struct device *dev = net_dev->dev.parent;
+	struct dpaa_eth_data *eth_data = dev->platform_data;
+	struct mac_device *mac_dev = eth_data->mac_dev;
+	struct phy_device *phy_dev = mac_dev->phy_dev;
+	struct fm_mac_dev *fm_mac_dev;
+	bool rx_pause, tx_pause;
+	int _errno;
+
+	fm_mac_dev = mac_dev->get_mac_handle(mac_dev);
+	fm_mac_adjust_link(fm_mac_dev, phy_dev->link, phy_dev->speed);
+
+	get_pause_cfg(mac_dev, &rx_pause, &tx_pause);
+	_errno = set_mac_active_pause(mac_dev, rx_pause, tx_pause);
+	if (unlikely(_errno < 0))
+		netdev_err(net_dev, "set_mac_active_pause() = %d\n", _errno);
+}
+
+/* Initializes driver's PHY state, and attaches to the PHY.
+ * Returns 0 on success.
+ */
+static int dtsec_init_phy(struct net_device *net_dev,
+			  struct mac_device *mac_dev)
+{
+	struct phy_device	*phy_dev;
+
+	if (!mac_dev->phy_node)
+		phy_dev = phy_connect(net_dev, mac_dev->fixed_bus_id,
+				      &adjust_link, mac_dev->phy_if);
+	else
+		phy_dev = of_phy_connect(net_dev, mac_dev->phy_node,
+					 &adjust_link, 0, mac_dev->phy_if);
+	if (unlikely(!phy_dev) || IS_ERR(phy_dev)) {
+		netdev_err(net_dev, "Could not connect to PHY %s\n",
+			   mac_dev->phy_node ?
+				mac_dev->phy_node->full_name :
+				mac_dev->fixed_bus_id);
+		return (!phy_dev) ? -ENODEV : PTR_ERR(phy_dev);
+	}
+
+	/* Remove any features not supported by the controller */
+	phy_dev->supported &= mac_dev->if_support;
+	/* Enable the symmetric and asymmetric PAUSE frame advertisements,
+	 * as most of the PHY drivers do not enable them by default.
+	 */
+	phy_dev->supported |= (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+	phy_dev->advertising = phy_dev->supported;
+
+	mac_dev->phy_dev = phy_dev;
+
+	return 0;
+}
+
+static int xgmac_init_phy(struct net_device *net_dev,
+			  struct mac_device *mac_dev)
+{
+	struct phy_device *phy_dev;
+
+	if (!mac_dev->phy_node)
+		phy_dev = phy_attach(net_dev, mac_dev->fixed_bus_id,
+				     mac_dev->phy_if);
+	else
+		phy_dev = of_phy_attach(net_dev, mac_dev->phy_node, 0,
+					mac_dev->phy_if);
+	if (unlikely(!phy_dev) || IS_ERR(phy_dev)) {
+		netdev_err(net_dev, "Could not attach to PHY %s\n",
+			   mac_dev->phy_node ?
+				mac_dev->phy_node->full_name :
+				mac_dev->fixed_bus_id);
+		return (!phy_dev) ? -ENODEV : PTR_ERR(phy_dev);
+	}
+
+	phy_dev->supported &= mac_dev->if_support;
+	/* Enable the symmetric and asymmetric PAUSE frame advertisements,
+	 * as most of the PHY drivers do not enable them by default.
+	 */
+	phy_dev->supported |= (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+	phy_dev->advertising = phy_dev->supported;
+
+	mac_dev->phy_dev = phy_dev;
+
+	return 0;
+}
+
+static int memac_init_phy(struct net_device *net_dev,
+			  struct mac_device *mac_dev)
+{
+	struct phy_device       *phy_dev;
+
+	if (macdev2enetinterface(mac_dev) == ENET_MODE_XGMII_10000) {
+		if (!mac_dev->phy_node) {
+			mac_dev->phy_dev = NULL;
+			return 0;
+		}
+
+		phy_dev = of_phy_attach(net_dev, mac_dev->phy_node, 0,
+					mac_dev->phy_if);
+	} else {
+		if (!mac_dev->phy_node)
+			phy_dev = phy_connect(net_dev, mac_dev->fixed_bus_id,
+					      &adjust_link, mac_dev->phy_if);
+		else
+			phy_dev = of_phy_connect(net_dev, mac_dev->phy_node,
+						 &adjust_link, 0,
+						 mac_dev->phy_if);
+	}
+
+	if (unlikely(!phy_dev) || IS_ERR(phy_dev)) {
+		netdev_err(net_dev, "Could not connect to PHY %s\n",
+			   mac_dev->phy_node ?
+				mac_dev->phy_node->full_name :
+				mac_dev->fixed_bus_id);
+		return (!phy_dev) ? -ENODEV : PTR_ERR(phy_dev);
+	}
+
+	/* Remove any features not supported by the controller */
+	phy_dev->supported &= mac_dev->if_support;
+	/* Enable the symmetric and asymmetric PAUSE frame advertisements,
+	 * as most of the PHY drivers do not enable them by default.
+	 */
+	phy_dev->supported |= (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+	phy_dev->advertising = phy_dev->supported;
+
+	mac_dev->phy_dev = phy_dev;
+
+	return 0;
+}
+
+static int __cold uninit(struct fm_mac_dev *fm_mac_dev)
+{
+	int			 _errno, __errno;
+
+	_errno = fm_mac_disable(fm_mac_dev, COMM_MODE_RX_AND_TX);
+	__errno = fm_mac_free(fm_mac_dev);
+
+	if (unlikely(__errno < 0))
+		_errno = __errno;
+
+	return _errno;
+}
+
+static struct fm_mac_dev *get_mac_handle(struct mac_device *mac_dev)
+{
+	const struct mac_priv_s	*priv;
+
+	priv = macdev_priv(mac_dev);
+
+	return priv->fm_mac;
+}
+
+static void __cold setup_dtsec(struct mac_device *mac_dev)
+{
+	mac_dev->init_phy	= dtsec_init_phy;
+	mac_dev->init		= init;
+	mac_dev->start		= start;
+	mac_dev->stop		= stop;
+	mac_dev->set_promisc	= fm_mac_set_promiscuous;
+	mac_dev->change_addr    = fm_mac_modify_mac_addr;
+	mac_dev->set_multi      = set_multi;
+	mac_dev->uninit		= uninit;
+	mac_dev->get_mac_handle		= get_mac_handle;
+	mac_dev->set_tx_pause		= fm_mac_set_tx_pause_frames;
+	mac_dev->set_rx_pause		= fm_mac_set_rx_pause_frames;
+}
+
+static void __cold setup_xgmac(struct mac_device *mac_dev)
+{
+	mac_dev->init_phy	= xgmac_init_phy;
+	mac_dev->init		= init;
+	mac_dev->start		= start;
+	mac_dev->stop		= stop;
+	mac_dev->set_promisc	= fm_mac_set_promiscuous;
+	mac_dev->change_addr    = fm_mac_modify_mac_addr;
+	mac_dev->set_multi      = set_multi;
+	mac_dev->uninit		= uninit;
+	mac_dev->get_mac_handle	= get_mac_handle;
+	mac_dev->set_tx_pause	= fm_mac_set_tx_pause_frames;
+	mac_dev->set_rx_pause	= fm_mac_set_rx_pause_frames;
+}
+
+static void __cold setup_memac(struct mac_device *mac_dev)
+{
+	mac_dev->init_phy	= memac_init_phy;
+	mac_dev->init		= memac_init;
+	mac_dev->start		= start;
+	mac_dev->stop		= stop;
+	mac_dev->set_promisc	= fm_mac_set_promiscuous;
+	mac_dev->change_addr    = fm_mac_modify_mac_addr;
+	mac_dev->set_multi      = set_multi;
+	mac_dev->uninit		= uninit;
+	mac_dev->get_mac_handle		= get_mac_handle;
+	mac_dev->set_tx_pause		= fm_mac_set_tx_pause_frames;
+	mac_dev->set_rx_pause		= fm_mac_set_rx_pause_frames;
+}
+
+void (*const mac_setup[])(struct mac_device *mac_dev) = {
+	[DTSEC] = setup_dtsec,
+	[XGMAC] = setup_xgmac,
+	[MEMAC] = setup_memac
+};
diff --git a/drivers/net/ethernet/freescale/fman/mac/mac.c b/drivers/net/ethernet/freescale/fman/mac/mac.c
new file mode 100644
index 0000000..4eb8f7c
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/mac.c
@@ -0,0 +1,527 @@
+/* Copyright 2008-2015 Freescale Semiconductor, Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifdef CONFIG_FSL_DPAA_ETH_DEBUG
+#define pr_fmt(fmt) \
+	KBUILD_MODNAME ": %s:%hu:%s() " fmt, \
+	KBUILD_BASENAME ".c", __LINE__, __func__
+#else
+#define pr_fmt(fmt) \
+	KBUILD_MODNAME ": " fmt
+#endif
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+#include <linux/of_net.h>
+#include <linux/device.h>
+#include <linux/phy.h>
+
+#include "mac.h"
+
+#define DTSEC_SUPPORTED \
+	(SUPPORTED_10baseT_Half \
+	| SUPPORTED_10baseT_Full \
+	| SUPPORTED_100baseT_Half \
+	| SUPPORTED_100baseT_Full \
+	| SUPPORTED_Autoneg \
+	| SUPPORTED_Pause \
+	| SUPPORTED_Asym_Pause \
+	| SUPPORTED_MII)
+
+static DEFINE_MUTEX(eth_lock);
+
+static const char phy_str[][11] = {
+	[PHY_INTERFACE_MODE_MII]	= "mii",
+	[PHY_INTERFACE_MODE_GMII]	= "gmii",
+	[PHY_INTERFACE_MODE_SGMII]	= "sgmii",
+	[PHY_INTERFACE_MODE_TBI]	= "tbi",
+	[PHY_INTERFACE_MODE_RMII]	= "rmii",
+	[PHY_INTERFACE_MODE_RGMII]	= "rgmii",
+	[PHY_INTERFACE_MODE_RGMII_ID]	= "rgmii-id",
+	[PHY_INTERFACE_MODE_RGMII_RXID]	= "rgmii-rxid",
+	[PHY_INTERFACE_MODE_RGMII_TXID]	= "rgmii-txid",
+	[PHY_INTERFACE_MODE_RTBI]	= "rtbi",
+	[PHY_INTERFACE_MODE_XGMII]	= "xgmii"
+};
+
+static phy_interface_t __pure __attribute__((nonnull)) str2phy(const char *str)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(phy_str); i++)
+		if (strcmp(str, phy_str[i]) == 0)
+			return (phy_interface_t)i;
+
+	return PHY_INTERFACE_MODE_MII;
+}
+
+static const u16 phy2speed[] = {
+	[PHY_INTERFACE_MODE_MII]	= SPEED_100,
+	[PHY_INTERFACE_MODE_GMII]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_SGMII]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_TBI]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_RMII]	= SPEED_100,
+	[PHY_INTERFACE_MODE_RGMII]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_RGMII_ID]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_RGMII_RXID]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_RGMII_TXID]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_RTBI]	= SPEED_1000,
+	[PHY_INTERFACE_MODE_XGMII]	= SPEED_10000
+};
+
+static struct mac_device * __cold
+alloc_macdev(struct device *dev, size_t sizeof_priv,
+	     void (*setup)(struct mac_device *mac_dev))
+{
+	struct mac_device	*mac_dev;
+
+	mac_dev = devm_kzalloc(dev, sizeof(*mac_dev) + sizeof_priv, GFP_KERNEL);
+	if (unlikely(!mac_dev)) {
+		mac_dev = ERR_PTR(-ENOMEM);
+	} else {
+		mac_dev->dev = dev;
+		dev_set_drvdata(dev, mac_dev);
+		setup(mac_dev);
+	}
+
+	return mac_dev;
+}
+
+static int __cold free_macdev(struct mac_device *mac_dev)
+{
+	dev_set_drvdata(mac_dev->dev, NULL);
+
+	return mac_dev->uninit(mac_dev->get_mac_handle(mac_dev));
+}
+
+static struct platform_device *dpaa_eth_add_device(int fman_id,
+						   struct mac_device *mac_dev,
+						   struct device_node *node)
+{
+	struct platform_device *pdev;
+	struct dpaa_eth_data data;
+	static int dpaa_eth_dev_cnt;
+	int ret;
+
+	data.mac_dev = mac_dev;
+	data.mac_hw_id = mac_dev->cell_index;
+	data.fman_hw_id = fman_id;
+	data.mac_node = node;
+
+	mutex_lock(&eth_lock);
+
+	pdev = platform_device_alloc("dpaa-ethernet", dpaa_eth_dev_cnt);
+	if (!pdev) {
+		ret = -ENOMEM;
+		goto no_mem;
+	}
+
+	ret = platform_device_add_data(pdev, &data, sizeof(data));
+	if (ret)
+		goto err;
+
+	ret = platform_device_add(pdev);
+	if (ret)
+		goto err;
+
+	dpaa_eth_dev_cnt++;
+	mutex_unlock(&eth_lock);
+
+	return pdev;
+
+err:
+	platform_device_put(pdev);
+no_mem:
+	mutex_unlock(&eth_lock);
+
+	return ERR_PTR(ret);
+}
+
+static void dpaa_eth_remove_device(struct platform_device *pdev)
+{
+	platform_device_unregister(pdev);
+}
+
+static const struct of_device_id mac_match[] = {
+	[DTSEC] = {
+		.compatible	= "fsl,fman-dtsec"
+	},
+	[XGMAC] = {
+		.compatible	= "fsl,fman-xgec"
+	},
+	[MEMAC] = {
+		.compatible	= "fsl,fman-memac"
+	},
+	{}
+};
+MODULE_DEVICE_TABLE(of, mac_match);
+
+static int __cold mac_probe(struct platform_device *_of_dev)
+{
+	int			 _errno, i, lenp;
+	struct device		*dev;
+	struct device_node	*mac_node, *dev_node;
+	struct mac_device	*mac_dev;
+	struct platform_device	*of_dev;
+	struct resource		 res;
+	const u8		*mac_addr;
+	const char		*char_prop;
+	const u32		*uint32_prop;
+	const struct of_device_id *match;
+	u8			 fman_id;
+
+	const phandle           *phandle_prop;
+
+	dev = &_of_dev->dev;
+	mac_node = dev->of_node;
+
+	match = of_match_device(mac_match, dev);
+	if (!match)
+		return -EINVAL;
+
+	for (i = 0; i < ARRAY_SIZE(mac_match) - 1 && match != mac_match + i;
+			i++)
+		;
+	BUG_ON(i >= ARRAY_SIZE(mac_match) - 1);
+
+	mac_dev = alloc_macdev(dev, mac_sizeof_priv[i], mac_setup[i]);
+	if (IS_ERR(mac_dev)) {
+		_errno = PTR_ERR(mac_dev);
+		dev_err(dev, "alloc_macdev() = %d\n", _errno);
+		goto _return;
+	}
+
+	INIT_LIST_HEAD(&mac_dev->mc_addr_list);
+
+	/* Get the FM node */
+	dev_node = of_get_parent(mac_node);
+	if (unlikely(!dev_node)) {
+		dev_err(dev, "of_get_parent(%s) failed\n",
+			mac_node->full_name);
+		_errno = -EINVAL;
+		goto _return_dev_set_drvdata;
+	}
+
+	of_dev = of_find_device_by_node(dev_node);
+	if (unlikely(!of_dev)) {
+		dev_err(dev, "of_find_device_by_node(%s) failed\n",
+			dev_node->full_name);
+		_errno = -EINVAL;
+		goto _return_of_node_put;
+	}
+
+	/* Get the FMan cell-index */
+	uint32_prop = of_get_property(dev_node, "cell-index", &lenp);
+	if (unlikely(!uint32_prop)) {
+		dev_err(dev, "of_get_property(%s, cell-index) failed\n",
+			dev_node->full_name);
+		_errno = -EINVAL;
+		goto _return_of_node_put;
+	}
+	BUG_ON(lenp != sizeof(u32));
+	fman_id = (u8)*uint32_prop + 1; /* cell-index 0 => FMan id 1 */
+
+	mac_dev->fm_dev = fm_bind(&of_dev->dev);
+	if (unlikely(!mac_dev->fm_dev)) {
+		dev_err(dev, "fm_bind(%s) failed\n", dev_node->full_name);
+		_errno = -ENODEV;
+		goto _return_of_node_put;
+	}
+
+	mac_dev->fm = (void *)fm_get_handle(mac_dev->fm_dev);
+	of_node_put(dev_node);
+
+	/* Get the address of the memory mapped registers */
+	_errno = of_address_to_resource(mac_node, 0, &res);
+	if (unlikely(_errno < 0)) {
+		dev_err(dev, "of_address_to_resource(%s) = %d\n",
+			mac_node->full_name, _errno);
+		goto _return_dev_set_drvdata;
+	}
+
+	mac_dev->res =
+		__devm_request_region(dev, fm_get_mem_region(mac_dev->fm_dev),
+				      res.start, res.end + 1 - res.start,
+				      "mac");
+	if (unlikely(!mac_dev->res)) {
+		dev_err(dev, "__devm_request_mem_region(mac) failed\n");
+		_errno = -EBUSY;
+		goto _return_dev_set_drvdata;
+	}
+
+	mac_dev->vaddr = devm_ioremap(dev, mac_dev->res->start,
+				      mac_dev->res->end + 1
+				      - mac_dev->res->start);
+	if (unlikely(!mac_dev->vaddr)) {
+		dev_err(dev, "devm_ioremap() failed\n");
+		_errno = -EIO;
+		goto _return_dev_set_drvdata;
+	}
+
+#define TBIPA_OFFSET		0x1c
+#define TBIPA_DEFAULT_ADDR	5 /* override if used as external PHY addr. */
+	mac_dev->tbi_node = of_parse_phandle(mac_node, "tbi-handle", 0);
+	if (mac_dev->tbi_node) {
+		u32 tbiaddr = TBIPA_DEFAULT_ADDR;
+
+		uint32_prop = of_get_property(mac_dev->tbi_node, "reg", NULL);
+		if (uint32_prop)
+			tbiaddr = *uint32_prop;
+		out_be32(mac_dev->vaddr + TBIPA_OFFSET, tbiaddr);
+	}
+
+	if (!of_device_is_available(mac_node)) {
+		devm_iounmap(dev, mac_dev->vaddr);
+		__devm_release_region(dev, fm_get_mem_region(mac_dev->fm_dev),
+				      res.start, res.end + 1 - res.start);
+		fm_unbind(mac_dev->fm_dev);
+		devm_kfree(dev, mac_dev);
+		dev_set_drvdata(dev, NULL);
+		return -ENODEV;
+	}
+
+	/* Get the cell-index */
+	uint32_prop = of_get_property(mac_node, "cell-index", &lenp);
+	if (unlikely(!uint32_prop)) {
+		dev_err(dev, "of_get_property(%s, cell-index) failed\n",
+			mac_node->full_name);
+		_errno = -EINVAL;
+		goto _return_dev_set_drvdata;
+	}
+	BUG_ON(lenp != sizeof(u32));
+	mac_dev->cell_index = (u8)*uint32_prop;
+
+	/* Get the MAC address */
+	mac_addr = of_get_mac_address(mac_node);
+	if (unlikely(!mac_addr)) {
+		dev_err(dev, "of_get_mac_address(%s) failed\n",
+			mac_node->full_name);
+		_errno = -EINVAL;
+		goto _return_dev_set_drvdata;
+	}
+	memcpy(mac_dev->addr, mac_addr, sizeof(mac_dev->addr));
+
+	/* Get the port handles */
+	phandle_prop = of_get_property(mac_node, "fsl,fman-ports", &lenp);
+	if (unlikely(!phandle_prop)) {
+		dev_err(dev, "of_get_property(%s, fsl,fman-ports) failed\n",
+			mac_node->full_name);
+		_errno = -EINVAL;
+		goto _return_dev_set_drvdata;
+	}
+	BUG_ON(lenp != sizeof(phandle) * ARRAY_SIZE(mac_dev->port_dev));
+
+	for_each_port_device(i, mac_dev->port_dev) {
+		/* Find the port node */
+		dev_node = of_find_node_by_phandle(phandle_prop[i]);
+		if (unlikely(!dev_node)) {
+			dev_err(dev, "of_find_node_by_phandle() failed\n");
+			_errno = -EINVAL;
+			goto _return_of_node_put;
+		}
+
+		of_dev = of_find_device_by_node(dev_node);
+		if (unlikely(!of_dev)) {
+			dev_err(dev, "of_find_device_by_node(%s) failed\n",
+				dev_node->full_name);
+			_errno = -EINVAL;
+			goto _return_of_node_put;
+		}
+
+		mac_dev->port_dev[i] = fm_port_bind(&of_dev->dev);
+		if (unlikely(!mac_dev->port_dev[i])) {
+			dev_err(dev, "dev_get_drvdata(%s) failed\n",
+				dev_node->full_name);
+			_errno = -EINVAL;
+			goto _return_of_node_put;
+		}
+		of_node_put(dev_node);
+	}
+
+	/* Get the PHY connection type */
+	char_prop = (const char *)of_get_property(mac_node,
+						"phy-connection-type", NULL);
+	if (unlikely(!char_prop)) {
+		dev_warn(dev,
+			 "of_get_property(%s, phy-connection-type) failed. Defaulting to MII\n",
+			 mac_node->full_name);
+		mac_dev->phy_if = PHY_INTERFACE_MODE_MII;
+	} else {
+		mac_dev->phy_if = str2phy(char_prop);
+	}
+
+	mac_dev->link		= false;
+	mac_dev->speed		= phy2speed[mac_dev->phy_if];
+	mac_dev->max_speed	= mac_dev->speed;
+	mac_dev->if_support = DTSEC_SUPPORTED;
+	/* We don't support half-duplex in SGMII mode */
+	if (strstr(char_prop, "sgmii"))
+		mac_dev->if_support &= ~(SUPPORTED_10baseT_Half |
+					SUPPORTED_100baseT_Half);
+
+	/* Gigabit support (no half-duplex) */
+	if (mac_dev->max_speed == 1000)
+		mac_dev->if_support |= SUPPORTED_1000baseT_Full;
+
+	/* The 10G interface only supports one mode */
+	if (strstr(char_prop, "xgmii"))
+		mac_dev->if_support = SUPPORTED_10000baseT_Full;
+
+	/* Get the rest of the PHY information */
+	mac_dev->phy_node = of_parse_phandle(mac_node, "phy-handle", 0);
+	if (!mac_dev->phy_node) {
+		int sz;
+		const u32 *phy_id = of_get_property(mac_node, "fixed-link",
+							&sz);
+		if (!phy_id || sz < sizeof(*phy_id)) {
+			dev_err(dev, "No PHY (or fixed link) found\n");
+			_errno = -EINVAL;
+			goto _return_dev_set_drvdata;
+		}
+
+		sprintf(mac_dev->fixed_bus_id, PHY_ID_FMT, "fixed-0",
+			phy_id[0]);
+	}
+
+	_errno = mac_dev->init(mac_dev);
+	if (unlikely(_errno < 0)) {
+		dev_err(dev, "mac_dev->init() = %d\n", _errno);
+		goto _return_dev_set_drvdata;
+	}
+
+	/* pause frame autonegotiation enabled*/
+	mac_dev->autoneg_pause = true;
+
+	/* by intializing the values to false, force FMD to enable PAUSE frames
+	 * on RX and TX
+	 */
+	mac_dev->rx_pause_req = true;
+	mac_dev->tx_pause_req = true;
+	mac_dev->rx_pause_active = false;
+	mac_dev->tx_pause_active = false;
+	_errno = set_mac_active_pause(mac_dev, true, true);
+	if (unlikely(_errno < 0))
+		dev_err(dev, "set_mac_active_pause() = %d\n", _errno);
+
+	dev_info(dev,
+		 "FMan MAC address: %02hx:%02hx:%02hx:%02hx:%02hx:%02hx\n",
+		     mac_dev->addr[0], mac_dev->addr[1], mac_dev->addr[2],
+		     mac_dev->addr[3], mac_dev->addr[4], mac_dev->addr[5]);
+
+	mac_dev->eth_dev = dpaa_eth_add_device(fman_id, mac_dev,
+					       mac_node);
+	if (IS_ERR(mac_dev->eth_dev)) {
+		dev_err(dev, "failed to add Ethernet platform device for MAC %d\n",
+			mac_dev->cell_index);
+		mac_dev->eth_dev = NULL;
+	}
+
+	goto _return;
+
+_return_of_node_put:
+	of_node_put(dev_node);
+_return_dev_set_drvdata:
+	dev_set_drvdata(dev, NULL);
+_return:
+	return _errno;
+}
+
+static int __cold mac_remove(struct platform_device *of_dev)
+{
+	int			 i, _errno;
+	struct device		*dev;
+	struct mac_device	*mac_dev;
+
+	dev = &of_dev->dev;
+	mac_dev = (struct mac_device *)dev_get_drvdata(dev);
+
+	dpaa_eth_remove_device(mac_dev->eth_dev);
+
+	for_each_port_device(i, mac_dev->port_dev)
+		fm_port_unbind(mac_dev->port_dev[i]);
+
+	fm_unbind(mac_dev->fm_dev);
+
+	_errno = free_macdev(mac_dev);
+
+	return _errno;
+}
+
+static struct platform_driver mac_driver = {
+	.driver = {
+		.name		= KBUILD_MODNAME,
+		.of_match_table	= mac_match,
+		.owner		= THIS_MODULE,
+	},
+	.probe		= mac_probe,
+	.remove		= mac_remove
+};
+
+static int __init __cold mac_load(void)
+{
+	int	 _errno;
+
+	pr_debug(KBUILD_MODNAME ": -> %s:%s()\n",
+		 KBUILD_BASENAME ".c", __func__);
+
+	pr_info(KBUILD_MODNAME ": %s\n",
+		mac_driver_description);
+
+	_errno = platform_driver_register(&mac_driver);
+	if (unlikely(_errno < 0)) {
+		pr_err(KBUILD_MODNAME ": %s:%hu:%s(): platform_driver_register() = %d\n",
+		       KBUILD_BASENAME ".c", __LINE__, __func__, _errno);
+		goto _return;
+	}
+
+	goto _return;
+
+_return:
+	pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
+		 KBUILD_BASENAME ".c", __func__);
+
+	return _errno;
+}
+module_init(mac_load);
+
+static void __exit __cold mac_unload(void)
+{
+	pr_debug(KBUILD_MODNAME ": -> %s:%s()\n",
+		 KBUILD_BASENAME ".c", __func__);
+
+	platform_driver_unregister(&mac_driver);
+
+	pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
+		 KBUILD_BASENAME ".c", __func__);
+}
+module_exit(mac_unload);
-- 
1.7.11.7
