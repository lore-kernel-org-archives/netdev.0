From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH RFC 07/11] dpaa_eth: add ethtool functionality
Date: Tue, 17 Mar 2015 20:58:25 +0200
Message-ID: <1426618709-19004-7-git-send-email-madalin.bucur@freescale.com>
References: <1426618709-19004-1-git-send-email-madalin.bucur@freescale.com>
 <1426618709-19004-2-git-send-email-madalin.bucur@freescale.com>
 <1426618709-19004-3-git-send-email-madalin.bucur@freescale.com>
 <1426618709-19004-4-git-send-email-madalin.bucur@freescale.com>
 <1426618709-19004-5-git-send-email-madalin.bucur@freescale.com>
 <1426618709-19004-6-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0106.outbound.protection.outlook.com ([157.56.111.106]:5216
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932241AbbCQTNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 15:13:22 -0400
In-Reply-To: <1426618709-19004-6-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for basic ethtool operations.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/Makefile       |   2 +-
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  |   2 +
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |   3 +
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c | 301 +++++++++++++++++++++
 4 files changed, 307 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c

diff --git a/drivers/net/ethernet/freescale/dpaa/Makefile b/drivers/net/ethernet/freescale/dpaa/Makefile
index bdeb04e..fe9ba65 100644
--- a/drivers/net/ethernet/freescale/dpaa/Makefile
+++ b/drivers/net/ethernet/freescale/dpaa/Makefile
@@ -11,4 +11,4 @@ ccflags-y += -I$(FMAN)/flib
 
 obj-$(CONFIG_FSL_DPAA_ETH) += fsl_dpa.o
 
-fsl_dpa-objs += dpaa_eth.o dpaa_eth_sg.o dpaa_eth_common.o
+fsl_dpa-objs += dpaa_eth.o dpaa_eth_sg.o dpaa_eth_common.o dpaa_ethtool.o
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
index eb7a4a0..acefc2b 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
@@ -81,6 +81,8 @@ int dpa_netdev_init(struct net_device *net_dev,
 	memcpy(net_dev->perm_addr, mac_addr, net_dev->addr_len);
 	memcpy(net_dev->dev_addr, mac_addr, net_dev->addr_len);
 
+	net_dev->ethtool_ops = &dpa_ethtool_ops;
+
 	net_dev->needed_headroom = priv->tx_headroom;
 	net_dev->watchdog_timeo = msecs_to_jiffies(tx_timeout);
 
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
index de5b68e..53da367 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
@@ -58,6 +58,9 @@
 /* used in napi related functions */
 extern u16 qman_portal_max;
 
+/* from dpa_ethtool.c */
+extern const struct ethtool_ops dpa_ethtool_ops;
+
 int dpa_netdev_init(struct net_device *net_dev,
 		    const u8 *mac_addr,
 		    u16 tx_timeout);
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
new file mode 100644
index 0000000..cf3ce96
--- /dev/null
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
@@ -0,0 +1,301 @@
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
+#define pr_fmt(fmt) \
+	KBUILD_MODNAME ": " fmt
+
+#include <linux/string.h>
+
+#include "dpaa_eth.h"
+#include "mac.h"                /* struct mac_device */
+#include "dpaa_eth_common.h"
+
+static int __cold dpa_get_settings(struct net_device *net_dev,
+				   struct ethtool_cmd *et_cmd)
+{
+	int			 _errno;
+	struct dpa_priv_s	*priv;
+
+	priv = netdev_priv(net_dev);
+
+	if (unlikely(!priv->mac_dev->phy_dev)) {
+		netdev_dbg(net_dev, "phy device not initialized\n");
+		return 0;
+	}
+
+	_errno = phy_ethtool_gset(priv->mac_dev->phy_dev, et_cmd);
+	if (unlikely(_errno < 0))
+		netdev_err(net_dev, "phy_ethtool_gset() = %d\n", _errno);
+
+	return _errno;
+}
+
+static int __cold dpa_set_settings(struct net_device *net_dev,
+				   struct ethtool_cmd *et_cmd)
+{
+	int			 _errno;
+	struct dpa_priv_s	*priv;
+
+	priv = netdev_priv(net_dev);
+
+	if (unlikely(!priv->mac_dev->phy_dev)) {
+		netdev_err(net_dev, "phy device not initialized\n");
+		return -ENODEV;
+	}
+
+	_errno = phy_ethtool_sset(priv->mac_dev->phy_dev, et_cmd);
+	if (unlikely(_errno < 0))
+		netdev_err(net_dev, "phy_ethtool_sset() = %d\n", _errno);
+
+	return _errno;
+}
+
+static void __cold dpa_get_drvinfo(struct net_device *net_dev,
+				   struct ethtool_drvinfo *drvinfo)
+{
+	int		 _errno;
+
+	strncpy(drvinfo->driver, KBUILD_MODNAME,
+		sizeof(drvinfo->driver) - 1)[sizeof(drvinfo->driver) - 1] = 0;
+	strncpy(drvinfo->version, VERSION,
+		sizeof(drvinfo->driver) - 1)[sizeof(drvinfo->version) - 1] = 0;
+	_errno = snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+			  "%X", 0);
+
+	if (unlikely(_errno >= sizeof(drvinfo->fw_version))) {
+		/* Truncated output */
+		netdev_notice(net_dev, "snprintf() = %d\n", _errno);
+	} else if (unlikely(_errno < 0)) {
+		netdev_warn(net_dev, "snprintf() = %d\n", _errno);
+		memset(drvinfo->fw_version, 0, sizeof(drvinfo->fw_version));
+	}
+	strncpy(drvinfo->bus_info, dev_name(net_dev->dev.parent->parent),
+		sizeof(drvinfo->bus_info) - 1)[sizeof(drvinfo->bus_info) - 1] =
+			0;
+}
+
+static u32 __cold dpa_get_msglevel(struct net_device *net_dev)
+{
+	return ((struct dpa_priv_s *)netdev_priv(net_dev))->msg_enable;
+}
+
+static void __cold dpa_set_msglevel(struct net_device *net_dev,
+				    u32 msg_enable)
+{
+	((struct dpa_priv_s *)netdev_priv(net_dev))->msg_enable = msg_enable;
+}
+
+static int __cold dpa_nway_reset(struct net_device *net_dev)
+{
+	int			 _errno;
+	struct dpa_priv_s	*priv;
+
+	priv = netdev_priv(net_dev);
+
+	if (unlikely(!priv->mac_dev->phy_dev)) {
+		netdev_err(net_dev, "phy device not initialized\n");
+		return -ENODEV;
+	}
+
+	_errno = 0;
+	if (priv->mac_dev->phy_dev->autoneg) {
+		_errno = phy_start_aneg(priv->mac_dev->phy_dev);
+		if (unlikely(_errno < 0))
+			netdev_err(net_dev, "phy_start_aneg() = %d\n",
+				   _errno);
+	}
+
+	return _errno;
+}
+
+static void __cold dpa_get_ringparam(struct net_device *net_dev,
+				     struct ethtool_ringparam *et_ringparam)
+{
+	et_ringparam->rx_max_pending	   = 0;
+	et_ringparam->rx_mini_max_pending  = 0;
+	et_ringparam->rx_jumbo_max_pending = 0;
+	et_ringparam->tx_max_pending	   = 0;
+
+	et_ringparam->rx_pending	   = 0;
+	et_ringparam->rx_mini_pending	   = 0;
+	et_ringparam->rx_jumbo_pending	   = 0;
+	et_ringparam->tx_pending	   = 0;
+}
+
+static void __cold dpa_get_pauseparam(struct net_device *net_dev,
+				      struct ethtool_pauseparam *epause)
+{
+	struct dpa_priv_s	*priv;
+	struct mac_device       *mac_dev;
+	struct phy_device       *phy_dev;
+
+	priv = netdev_priv(net_dev);
+	mac_dev = priv->mac_dev;
+
+	phy_dev = mac_dev->phy_dev;
+	if (unlikely(!phy_dev)) {
+		netdev_err(net_dev, "phy device not initialized\n");
+		return;
+	}
+
+	epause->autoneg = mac_dev->autoneg_pause;
+	epause->rx_pause = mac_dev->rx_pause_active;
+	epause->tx_pause = mac_dev->tx_pause_active;
+}
+
+static int __cold dpa_set_pauseparam(struct net_device *net_dev,
+				     struct ethtool_pauseparam *epause)
+{
+	struct dpa_priv_s	*priv;
+	struct mac_device       *mac_dev;
+	struct phy_device       *phy_dev;
+	int _errno;
+	u32 newadv, oldadv;
+	bool rx_pause, tx_pause;
+
+	priv = netdev_priv(net_dev);
+	mac_dev = priv->mac_dev;
+
+	phy_dev = mac_dev->phy_dev;
+	if (unlikely(!phy_dev)) {
+		netdev_err(net_dev, "phy device not initialized\n");
+		return -ENODEV;
+	}
+
+	if (!(phy_dev->supported & SUPPORTED_Pause) ||
+	    (!(phy_dev->supported & SUPPORTED_Asym_Pause) &&
+	    (epause->rx_pause != epause->tx_pause)))
+		return -EINVAL;
+
+	/* The MAC should know how to handle PAUSE frame autonegotiation before
+	 * adjust_link is triggered by a forced renegotiation of sym/asym PAUSE
+	 * settings.
+	 */
+	mac_dev->autoneg_pause = !!epause->autoneg;
+	mac_dev->rx_pause_req = !!epause->rx_pause;
+	mac_dev->tx_pause_req = !!epause->tx_pause;
+
+	/* Determine the sym/asym advertised PAUSE capabilities from the desired
+	 * rx/tx pause settings.
+	 */
+	newadv = 0;
+	if (epause->rx_pause)
+		newadv = ADVERTISED_Pause | ADVERTISED_Asym_Pause;
+	if (epause->tx_pause)
+		newadv |= ADVERTISED_Asym_Pause;
+
+	oldadv = phy_dev->advertising &
+			(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+
+	/* If there are differences between the old and the new advertised
+	 * values, restart PHY autonegotiation and advertise the new values.
+	 */
+	if (oldadv != newadv) {
+		phy_dev->advertising &= ~(ADVERTISED_Pause
+				| ADVERTISED_Asym_Pause);
+		phy_dev->advertising |= newadv;
+		if (phy_dev->autoneg) {
+			_errno = phy_start_aneg(phy_dev);
+			if (unlikely(_errno < 0))
+				netdev_err(net_dev, "phy_start_aneg() = %d\n",
+					   _errno);
+		}
+	}
+
+	get_pause_cfg(mac_dev, &rx_pause, &tx_pause);
+	_errno = set_mac_active_pause(mac_dev, rx_pause, tx_pause);
+	if (unlikely(_errno < 0))
+		netdev_err(net_dev, "set_mac_active_pause() = %d\n", _errno);
+
+	return _errno;
+}
+
+#ifdef CONFIG_PM
+static void dpa_get_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
+{
+	struct dpa_priv_s *priv = netdev_priv(net_dev);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (!priv->wol || !device_can_wakeup(net_dev->dev.parent))
+		return;
+
+	if (priv->wol & DPAA_WOL_MAGIC) {
+		wol->supported = WAKE_MAGIC;
+		wol->wolopts = WAKE_MAGIC;
+	}
+}
+
+static int dpa_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
+{
+	struct dpa_priv_s *priv = netdev_priv(net_dev);
+
+	if (unlikely(!priv->mac_dev->phy_dev)) {
+		netdev_dbg(net_dev, "phy device not initialized\n");
+		return -ENODEV;
+	}
+
+	if (!device_can_wakeup(net_dev->dev.parent) ||
+	    (wol->wolopts & ~WAKE_MAGIC))
+		return -EOPNOTSUPP;
+
+	priv->wol = 0;
+
+	if (wol->wolopts & WAKE_MAGIC) {
+		priv->wol = DPAA_WOL_MAGIC;
+		device_set_wakeup_enable(net_dev->dev.parent, 1);
+	} else {
+		device_set_wakeup_enable(net_dev->dev.parent, 0);
+	}
+
+	return 0;
+}
+#endif
+
+const struct ethtool_ops dpa_ethtool_ops = {
+	.get_settings = dpa_get_settings,
+	.set_settings = dpa_set_settings,
+	.get_drvinfo = dpa_get_drvinfo,
+	.get_msglevel = dpa_get_msglevel,
+	.set_msglevel = dpa_set_msglevel,
+	.nway_reset = dpa_nway_reset,
+	.get_ringparam = dpa_get_ringparam,
+	.get_pauseparam = dpa_get_pauseparam,
+	.set_pauseparam = dpa_set_pauseparam,
+	.self_test = NULL,
+	.get_ethtool_stats = NULL,
+	.get_link = ethtool_op_get_link,
+#ifdef CONFIG_PM
+	.get_wol = dpa_get_wol,
+	.set_wol = dpa_set_wol,
+#endif
+};
-- 
1.7.11.7
