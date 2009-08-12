From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 11/36] bnx2x: MDC/MDIO CL45 IOCTLs
Date: Wed, 12 Aug 2009 21:23:08 +0300
Message-ID: <1250101388.27379.163.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ben Hutchings" <bhutchings@solarflare.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbZHLSYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Ben Hutchings <bhutchings@solarflare.com>, using the MDC/MDIO
IOCTL

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/Kconfig      |    1 +
 drivers/net/bnx2x.h      |    3 +
 drivers/net/bnx2x_main.c |  121 ++++++++++++++++++++++++++++++++--------------
 3 files changed, 88 insertions(+), 37 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9948fa2..29935a9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2722,6 +2722,7 @@ config BNX2X
 	select FW_LOADER
 	select ZLIB_INFLATE
 	select LIBCRC32C
+	select MDIO
 	help
 	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
 	  To compile this driver as a module, choose M here: the module
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 5864ae2..903c89d 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -30,6 +30,8 @@
 #define BNX2X_NEW_NAPI
 
 
+
+#include <linux/mdio.h>
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
 #include "bnx2x_hsi.h"
@@ -895,6 +897,7 @@ struct bnx2x {
 
 	struct link_params	link_params;
 	struct link_vars	link_vars;
+	struct mdio_if_info	mdio;
 
 	struct bnx2x_common	common;
 	struct bnx2x_port	port;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 47b687b..1be2da4 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8330,6 +8330,7 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	u32 val, val2;
 	u32 config;
 	u16 i;
+	u32 ext_phy_type;
 
 	bp->link_params.bp = bp;
 	bp->link_params.port = port;
@@ -8389,6 +8390,21 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 
 	bnx2x_link_settings_requested(bp);
 
+	/*
+	 * If connected directly, work with the internal PHY, otherwise, work
+	 * with the external PHY
+	 */
+	ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
+	if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)
+		bp->mdio.prtad = bp->link_params.phy_addr;
+
+	else if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
+		 (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
+		bp->mdio.prtad =
+			(bp->link_params.ext_phy_config &
+			 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT;
+
 	val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
 	val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
 	bp->dev->dev_addr[0] = (u8)(val2 >> 8 & 0xff);
@@ -8613,7 +8629,7 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	} else
 		cmd->port = PORT_TP;
 
-	cmd->phy_address = bp->port.phy_addr;
+	cmd->phy_address = bp->mdio.prtad;
 	cmd->transceiver = XCVR_INTERNAL;
 
 	if (bp->link_params.req_line_speed == SPEED_AUTO_NEG)
@@ -11148,54 +11164,77 @@ static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 }
 
 /* called with rtnl_lock */
-static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static int bnx2x_mdio_read(struct net_device *netdev, int prtad,
+			   int devad, u16 addr)
 {
-	struct mii_ioctl_data *data = if_mii(ifr);
-	struct bnx2x *bp = netdev_priv(dev);
-	int port = BP_PORT(bp);
-	int err;
+	struct bnx2x *bp = netdev_priv(netdev);
+	u16 value;
+	int rc;
+	u32 phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 
-	switch (cmd) {
-	case SIOCGMIIPHY:
-		data->phy_id = bp->port.phy_addr;
+	DP(NETIF_MSG_LINK, "mdio_read: prtad 0x%x, devad 0x%x, addr 0x%x\n",
+	   prtad, devad, addr);
 
-		/* fallthrough */
+	if (prtad != bp->mdio.prtad) {
+		DP(NETIF_MSG_LINK, "prtad missmatch (cmd:0x%x != bp:0x%x)\n",
+		   prtad, bp->mdio.prtad);
+		return -EINVAL;
+	}
+
+	/* The HW expects different devad if CL22 is used */
+	devad = (devad == MDIO_DEVAD_NONE) ? DEFAULT_PHY_DEV_ADDR : devad;
 
-	case SIOCGMIIREG: {
-		u16 mii_regval;
+	bnx2x_acquire_phy_lock(bp);
+	rc = bnx2x_cl45_read(bp, BP_PORT(bp), phy_type, prtad,
+			     devad, addr, &value);
+	bnx2x_release_phy_lock(bp);
+	DP(NETIF_MSG_LINK, "mdio_read_val 0x%x rc = 0x%x\n", value, rc);
 
-		if (!netif_running(dev))
-			return -EAGAIN;
+	if (!rc)
+		rc = value;
+	return rc;
+}
 
-		mutex_lock(&bp->port.phy_mutex);
-		err = bnx2x_cl45_read(bp, port, 0, bp->port.phy_addr,
-				      DEFAULT_PHY_DEV_ADDR,
-				      (data->reg_num & 0x1f), &mii_regval);
-		data->val_out = mii_regval;
-		mutex_unlock(&bp->port.phy_mutex);
-		return err;
+/* called with rtnl_lock */
+static int bnx2x_mdio_write(struct net_device *netdev, int prtad, int devad,
+			    u16 addr, u16 value)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
+	int rc;
+
+	DP(NETIF_MSG_LINK, "mdio_write: prtad 0x%x, devad 0x%x, addr 0x%x,"
+			   " value 0x%x\n", prtad, devad, addr, value);
+
+	if (prtad != bp->mdio.prtad) {
+		DP(NETIF_MSG_LINK, "prtad missmatch (cmd:0x%x != bp:0x%x)\n",
+		   prtad, bp->mdio.prtad);
+		return -EINVAL;
 	}
 
-	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
+	/* The HW expects different devad if CL22 is used */
+	devad = (devad == MDIO_DEVAD_NONE) ? DEFAULT_PHY_DEV_ADDR : devad;
 
-		if (!netif_running(dev))
-			return -EAGAIN;
+	bnx2x_acquire_phy_lock(bp);
+	rc = bnx2x_cl45_write(bp, BP_PORT(bp), ext_phy_type, prtad,
+			      devad, addr, value);
+	bnx2x_release_phy_lock(bp);
+	return rc;
+}
 
-		mutex_lock(&bp->port.phy_mutex);
-		err = bnx2x_cl45_write(bp, port, 0, bp->port.phy_addr,
-				       DEFAULT_PHY_DEV_ADDR,
-				       (data->reg_num & 0x1f), data->val_in);
-		mutex_unlock(&bp->port.phy_mutex);
-		return err;
+/* called with rtnl_lock */
+static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	struct mii_ioctl_data *mdio = if_mii(ifr);
 
-	default:
-		/* do nothing */
-		break;
-	}
+	DP(NETIF_MSG_LINK, "ioctl: phy id 0x%x, reg 0x%x, val_in 0x%x\n",
+	   mdio->phy_id, mdio->reg_num, mdio->val_in);
 
-	return -EOPNOTSUPP;
+	if (!netif_running(dev))
+		return -EAGAIN;
+
+	return mdio_mii_ioctl(&bp->mdio, mdio, cmd);
 }
 
 /* called with rtnl_lock */
@@ -11419,6 +11458,14 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->vlan_features |= NETIF_F_TSO6;
 #endif
 
+	/* get_port_hwinfo() will set prtad and mmds properly */
+	bp->mdio.prtad = MDIO_PRTAD_NONE;
+	bp->mdio.mmds = 0;
+	bp->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	bp->mdio.dev = dev;
+	bp->mdio.mdio_read = bnx2x_mdio_read;
+	bp->mdio.mdio_write = bnx2x_mdio_write;
+
 	return 0;
 
 err_out_unmap:
-- 
1.5.4.3




