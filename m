From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 6/6] Staging: octeon-ethernet: Convert to use PHY Abstraction Layer.
Date: Wed,  7 Oct 2009 16:10:15 -0700
Message-ID: <1254957015-7633-6-git-send-email-ddaney@caviumnetworks.com>
References: <4ACD1F4E.8090603@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4ACD1F4E.8090603@caviumnetworks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

The octeon-ethernet driver shares an mdio bus with the octeon-mgmt
driver.  Here we convert the octeon-ethernet driver to use the PHY
Abstraction Layer.  The allocation of MAC addresses is also fixed so
that there is not duplication with the MAC addresses used by
octeon-mgmt, and it is consistent with the bootloader.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/Kconfig           |    3 +-
 drivers/staging/octeon/ethernet-mdio.c   |  198 +++++++++++-------------------
 drivers/staging/octeon/ethernet-mdio.h   |    2 +-
 drivers/staging/octeon/ethernet-proc.c   |  112 -----------------
 drivers/staging/octeon/ethernet-rgmii.c  |   52 ++++----
 drivers/staging/octeon/ethernet-sgmii.c  |    2 +-
 drivers/staging/octeon/ethernet-xaui.c   |    2 +-
 drivers/staging/octeon/ethernet.c        |   68 +++++++----
 drivers/staging/octeon/octeon-ethernet.h |   15 ++-
 9 files changed, 161 insertions(+), 293 deletions(-)

diff --git a/drivers/staging/octeon/Kconfig b/drivers/staging/octeon/Kconfig
index 536e238..638ad6b 100644
--- a/drivers/staging/octeon/Kconfig
+++ b/drivers/staging/octeon/Kconfig
@@ -1,7 +1,8 @@
 config OCTEON_ETHERNET
 	tristate "Cavium Networks Octeon Ethernet support"
 	depends on CPU_CAVIUM_OCTEON
-	select MII
+	select PHYLIB
+	select MDIO_OCTEON
 	help
 	  This driver supports the builtin ethernet ports on Cavium
 	  Networks' products in the Octeon family. This driver supports the
diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index 31a58e5..507ca32 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -26,7 +26,8 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/ethtool.h>
-#include <linux/mii.h>
+#include <linux/phy.h>
+
 #include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
@@ -34,86 +35,12 @@
 #include "ethernet-defines.h"
 #include "octeon-ethernet.h"
 #include "ethernet-mdio.h"
+#include "ethernet-util.h"
 
 #include "cvmx-helper-board.h"
 
 #include "cvmx-smix-defs.h"
 
-DECLARE_MUTEX(mdio_sem);
-
-/**
- * Perform an MII read. Called by the generic MII routines
- *
- * @dev:      Device to perform read for
- * @phy_id:   The MII phy id
- * @location: Register location to read
- * Returns Result from the read or zero on failure
- */
-static int cvm_oct_mdio_read(struct net_device *dev, int phy_id, int location)
-{
-	union cvmx_smix_cmd smi_cmd;
-	union cvmx_smix_rd_dat smi_rd;
-
-	smi_cmd.u64 = 0;
-	smi_cmd.s.phy_op = 1;
-	smi_cmd.s.phy_adr = phy_id;
-	smi_cmd.s.reg_adr = location;
-	cvmx_write_csr(CVMX_SMIX_CMD(0), smi_cmd.u64);
-
-	do {
-		if (!in_interrupt())
-			yield();
-		smi_rd.u64 = cvmx_read_csr(CVMX_SMIX_RD_DAT(0));
-	} while (smi_rd.s.pending);
-
-	if (smi_rd.s.val)
-		return smi_rd.s.dat;
-	else
-		return 0;
-}
-
-static int cvm_oct_mdio_dummy_read(struct net_device *dev, int phy_id,
-				   int location)
-{
-	return 0xffff;
-}
-
-/**
- * Perform an MII write. Called by the generic MII routines
- *
- * @dev:      Device to perform write for
- * @phy_id:   The MII phy id
- * @location: Register location to write
- * @val:      Value to write
- */
-static void cvm_oct_mdio_write(struct net_device *dev, int phy_id, int location,
-			       int val)
-{
-	union cvmx_smix_cmd smi_cmd;
-	union cvmx_smix_wr_dat smi_wr;
-
-	smi_wr.u64 = 0;
-	smi_wr.s.dat = val;
-	cvmx_write_csr(CVMX_SMIX_WR_DAT(0), smi_wr.u64);
-
-	smi_cmd.u64 = 0;
-	smi_cmd.s.phy_op = 0;
-	smi_cmd.s.phy_adr = phy_id;
-	smi_cmd.s.reg_adr = location;
-	cvmx_write_csr(CVMX_SMIX_CMD(0), smi_cmd.u64);
-
-	do {
-		if (!in_interrupt())
-			yield();
-		smi_wr.u64 = cvmx_read_csr(CVMX_SMIX_WR_DAT(0));
-	} while (smi_wr.s.pending);
-}
-
-static void cvm_oct_mdio_dummy_write(struct net_device *dev, int phy_id,
-				     int location, int val)
-{
-}
-
 static void cvm_oct_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
@@ -125,49 +52,37 @@ static void cvm_oct_get_drvinfo(struct net_device *dev,
 static int cvm_oct_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
-	int ret;
 
-	down(&mdio_sem);
-	ret = mii_ethtool_gset(&priv->mii_info, cmd);
-	up(&mdio_sem);
+	if (priv->phydev)
+		return phy_ethtool_gset(priv->phydev, cmd);
 
-	return ret;
+	return -EINVAL;
 }
 
 static int cvm_oct_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
-	int ret;
 
-	down(&mdio_sem);
-	ret = mii_ethtool_sset(&priv->mii_info, cmd);
-	up(&mdio_sem);
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (priv->phydev)
+		return phy_ethtool_sset(priv->phydev, cmd);
 
-	return ret;
+	return -EINVAL;
 }
 
 static int cvm_oct_nway_reset(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
-	int ret;
-
-	down(&mdio_sem);
-	ret = mii_nway_restart(&priv->mii_info);
-	up(&mdio_sem);
-
-	return ret;
-}
 
-static u32 cvm_oct_get_link(struct net_device *dev)
-{
-	struct octeon_ethernet *priv = netdev_priv(dev);
-	u32 ret;
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
 
-	down(&mdio_sem);
-	ret = mii_link_ok(&priv->mii_info);
-	up(&mdio_sem);
+	if (priv->phydev)
+		return phy_start_aneg(priv->phydev);
 
-	return ret;
+	return -EINVAL;
 }
 
 const struct ethtool_ops cvm_oct_ethtool_ops = {
@@ -175,7 +90,7 @@ const struct ethtool_ops cvm_oct_ethtool_ops = {
 	.get_settings = cvm_oct_get_settings,
 	.set_settings = cvm_oct_set_settings,
 	.nway_reset = cvm_oct_nway_reset,
-	.get_link = cvm_oct_get_link,
+	.get_link = ethtool_op_get_link,
 	.get_sg = ethtool_op_get_sg,
 	.get_tx_csum = ethtool_op_get_tx_csum,
 };
@@ -191,41 +106,72 @@ const struct ethtool_ops cvm_oct_ethtool_ops = {
 int cvm_oct_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
-	struct mii_ioctl_data *data = if_mii(rq);
-	unsigned int duplex_chg;
-	int ret;
 
-	down(&mdio_sem);
-	ret = generic_mii_ioctl(&priv->mii_info, data, cmd, &duplex_chg);
-	up(&mdio_sem);
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!priv->phydev)
+		return -EINVAL;
 
-	return ret;
+	return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
 }
 
+static void cvm_oct_adjust_link(struct net_device *dev)
+{
+	struct octeon_ethernet *priv = netdev_priv(dev);
+
+	if (priv->last_link != priv->phydev->link) {
+		priv->last_link = priv->phydev->link;
+		if (priv->last_link) {
+			netif_carrier_on(dev);
+			if (priv->queue != -1)
+				DEBUGPRINT("%s: %u Mbps %s duplex, "
+					   "port %2d, queue %2d\n",
+					   dev->name, priv->phydev->speed,
+					   priv->phydev->duplex ?
+						"Full" : "Half",
+					   priv->port, priv->queue);
+			else
+				DEBUGPRINT("%s: %u Mbps %s duplex, "
+					   "port %2d, POW\n",
+					   dev->name, priv->phydev->speed,
+					   priv->phydev->duplex ?
+						"Full" : "Half",
+					   priv->port);
+		} else {
+			netif_carrier_off(dev);
+			DEBUGPRINT("%s: Link down\n", dev->name);
+		}
+	}
+}
+
+
 /**
- * Setup the MDIO device structures
+ * Setup the PHY
  *
  * @dev:    Device to setup
  *
  * Returns Zero on success, negative on failure
  */
-int cvm_oct_mdio_setup_device(struct net_device *dev)
+int cvm_oct_phy_setup_device(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
-	int phy_id = cvmx_helper_board_get_mii_address(priv->port);
-	if (phy_id != -1) {
-		priv->mii_info.dev = dev;
-		priv->mii_info.phy_id = phy_id;
-		priv->mii_info.phy_id_mask = 0xff;
-		priv->mii_info.supports_gmii = 1;
-		priv->mii_info.reg_num_mask = 0x1f;
-		priv->mii_info.mdio_read = cvm_oct_mdio_read;
-		priv->mii_info.mdio_write = cvm_oct_mdio_write;
-	} else {
-		/* Supply dummy MDIO routines so the kernel won't crash
-		   if the user tries to read them */
-		priv->mii_info.mdio_read = cvm_oct_mdio_dummy_read;
-		priv->mii_info.mdio_write = cvm_oct_mdio_dummy_write;
+
+	int phy_addr = cvmx_helper_board_get_mii_address(priv->port);
+	if (phy_addr != -1) {
+		char phy_id[20];
+
+		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, "0", phy_addr);
+
+		priv->phydev = phy_connect(dev, phy_id, cvm_oct_adjust_link, 0,
+					PHY_INTERFACE_MODE_GMII);
+
+		if (IS_ERR(priv->phydev)) {
+			priv->phydev = NULL;
+			return -1;
+		}
+		priv->last_link = 0;
+		phy_start_aneg(priv->phydev);
 	}
 	return 0;
 }
diff --git a/drivers/staging/octeon/ethernet-mdio.h b/drivers/staging/octeon/ethernet-mdio.h
index b3328ae..55d0614 100644
--- a/drivers/staging/octeon/ethernet-mdio.h
+++ b/drivers/staging/octeon/ethernet-mdio.h
@@ -43,4 +43,4 @@
 
 extern const struct ethtool_ops cvm_oct_ethtool_ops;
 int cvm_oct_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-int cvm_oct_mdio_setup_device(struct net_device *dev);
+int cvm_oct_phy_setup_device(struct net_device *dev);
diff --git a/drivers/staging/octeon/ethernet-proc.c b/drivers/staging/octeon/ethernet-proc.c
index 8fa88fc..16308d4 100644
--- a/drivers/staging/octeon/ethernet-proc.c
+++ b/drivers/staging/octeon/ethernet-proc.c
@@ -25,7 +25,6 @@
  * Contact Cavium Networks for more information
 **********************************************************************/
 #include <linux/kernel.h>
-#include <linux/mii.h>
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <net/dst.h>
@@ -38,112 +37,6 @@
 #include "cvmx-helper.h"
 #include "cvmx-pip.h"
 
-static unsigned long long cvm_oct_stats_read_switch(struct net_device *dev,
-						    int phy_id, int offset)
-{
-	struct octeon_ethernet *priv = netdev_priv(dev);
-
-	priv->mii_info.mdio_write(dev, phy_id, 0x1d, 0xcc00 | offset);
-	return ((uint64_t) priv->mii_info.
-		mdio_read(dev, phy_id,
-			  0x1e) << 16) | (uint64_t) priv->mii_info.
-	    mdio_read(dev, phy_id, 0x1f);
-}
-
-static int cvm_oct_stats_switch_show(struct seq_file *m, void *v)
-{
-	static const int ports[] = { 0, 1, 2, 3, 9, -1 };
-	struct net_device *dev = cvm_oct_device[0];
-	int index = 0;
-
-	while (ports[index] != -1) {
-
-		/* Latch port */
-		struct octeon_ethernet *priv = netdev_priv(dev);
-
-		priv->mii_info.mdio_write(dev, 0x1b, 0x1d,
-					  0xdc00 | ports[index]);
-		seq_printf(m, "\nSwitch Port %d\n", ports[index]);
-		seq_printf(m, "InGoodOctets:   %12llu\t"
-			   "OutOctets:      %12llu\t"
-			   "64 Octets:      %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b,
-						     0x00) |
-			   (cvm_oct_stats_read_switch(dev, 0x1b, 0x01) << 32),
-			   cvm_oct_stats_read_switch(dev, 0x1b,
-						     0x0E) |
-			   (cvm_oct_stats_read_switch(dev, 0x1b, 0x0F) << 32),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x08));
-
-		seq_printf(m, "InBadOctets:    %12llu\t"
-			   "OutUnicast:     %12llu\t"
-			   "65-127 Octets:  %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x02),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x10),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x09));
-
-		seq_printf(m, "InUnicast:      %12llu\t"
-			   "OutBroadcasts:  %12llu\t"
-			   "128-255 Octets: %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x04),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x13),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x0A));
-
-		seq_printf(m, "InBroadcasts:   %12llu\t"
-			   "OutMulticasts:  %12llu\t"
-			   "256-511 Octets: %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x06),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x12),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x0B));
-
-		seq_printf(m, "InMulticasts:   %12llu\t"
-			   "OutPause:       %12llu\t"
-			   "512-1023 Octets:%12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x07),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x15),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x0C));
-
-		seq_printf(m, "InPause:        %12llu\t"
-			   "Excessive:      %12llu\t"
-			   "1024-Max Octets:%12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x16),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x11),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x0D));
-
-		seq_printf(m, "InUndersize:    %12llu\t"
-			   "Collisions:     %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x18),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x1E));
-
-		seq_printf(m, "InFragments:    %12llu\t"
-			   "Deferred:       %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x19),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x05));
-
-		seq_printf(m, "InOversize:     %12llu\t"
-			   "Single:         %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x1A),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x14));
-
-		seq_printf(m, "InJabber:       %12llu\t"
-			   "Multiple:       %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x1B),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x17));
-
-		seq_printf(m, "In RxErr:       %12llu\t"
-			   "OutFCSErr:      %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x1C),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x03));
-
-		seq_printf(m, "InFCSErr:       %12llu\t"
-			   "Late:           %12llu\n",
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x1D),
-			   cvm_oct_stats_read_switch(dev, 0x1b, 0x1F));
-		index++;
-	}
-	return 0;
-}
-
 /**
  * User is reading /proc/octeon_ethernet_stats
  *
@@ -215,11 +108,6 @@ static int cvm_oct_stats_show(struct seq_file *m, void *v)
 		}
 	}
 
-	if (cvm_oct_device[0]) {
-		priv = netdev_priv(cvm_oct_device[0]);
-		if (priv->imode == CVMX_HELPER_INTERFACE_MODE_GMII)
-			cvm_oct_stats_switch_show(m, v);
-	}
 	return 0;
 }
 
diff --git a/drivers/staging/octeon/ethernet-rgmii.c b/drivers/staging/octeon/ethernet-rgmii.c
index 8704133..d238611 100644
--- a/drivers/staging/octeon/ethernet-rgmii.c
+++ b/drivers/staging/octeon/ethernet-rgmii.c
@@ -147,32 +147,36 @@ static void cvm_oct_rgmii_poll(struct net_device *dev)
 		cvmx_write_csr(CVMX_GMXX_RXX_INT_REG(index, interface),
 			       gmxx_rxx_int_reg.u64);
 	}
-
-	link_info = cvmx_helper_link_autoconf(priv->port);
-	priv->link_info = link_info.u64;
+	if (priv->phydev == NULL) {
+		link_info = cvmx_helper_link_autoconf(priv->port);
+		priv->link_info = link_info.u64;
+	}
 	spin_unlock_irqrestore(&global_register_lock, flags);
 
-	/* Tell Linux */
-	if (link_info.s.link_up) {
-
-		if (!netif_carrier_ok(dev))
-			netif_carrier_on(dev);
-		if (priv->queue != -1)
-			DEBUGPRINT
-			    ("%s: %u Mbps %s duplex, port %2d, queue %2d\n",
-			     dev->name, link_info.s.speed,
-			     (link_info.s.full_duplex) ? "Full" : "Half",
-			     priv->port, priv->queue);
-		else
-			DEBUGPRINT("%s: %u Mbps %s duplex, port %2d, POW\n",
-				   dev->name, link_info.s.speed,
-				   (link_info.s.full_duplex) ? "Full" : "Half",
-				   priv->port);
-	} else {
-
-		if (netif_carrier_ok(dev))
-			netif_carrier_off(dev);
-		DEBUGPRINT("%s: Link down\n", dev->name);
+	if (priv->phydev == NULL) {
+		/* Tell core. */
+		if (link_info.s.link_up) {
+			if (!netif_carrier_ok(dev))
+				netif_carrier_on(dev);
+			if (priv->queue != -1)
+				DEBUGPRINT("%s: %u Mbps %s duplex, "
+					   "port %2d, queue %2d\n",
+					   dev->name, link_info.s.speed,
+					   (link_info.s.full_duplex) ?
+						"Full" : "Half",
+					   priv->port, priv->queue);
+			else
+				DEBUGPRINT("%s: %u Mbps %s duplex, "
+					   "port %2d, POW\n",
+					   dev->name, link_info.s.speed,
+					   (link_info.s.full_duplex) ?
+						"Full" : "Half",
+					   priv->port);
+		} else {
+			if (netif_carrier_ok(dev))
+				netif_carrier_off(dev);
+			DEBUGPRINT("%s: Link down\n", dev->name);
+		}
 	}
 }
 
diff --git a/drivers/staging/octeon/ethernet-sgmii.c b/drivers/staging/octeon/ethernet-sgmii.c
index 2b54996..6061d01 100644
--- a/drivers/staging/octeon/ethernet-sgmii.c
+++ b/drivers/staging/octeon/ethernet-sgmii.c
@@ -113,7 +113,7 @@ int cvm_oct_sgmii_init(struct net_device *dev)
 	struct octeon_ethernet *priv = netdev_priv(dev);
 	cvm_oct_common_init(dev);
 	dev->netdev_ops->ndo_stop(dev);
-	if (!octeon_is_simulation())
+	if (!octeon_is_simulation() && priv->phydev == NULL)
 		priv->poll = cvm_oct_sgmii_poll;
 
 	/* FIXME: Need autoneg logic */
diff --git a/drivers/staging/octeon/ethernet-xaui.c b/drivers/staging/octeon/ethernet-xaui.c
index 0c2e7cc..ee3dc41 100644
--- a/drivers/staging/octeon/ethernet-xaui.c
+++ b/drivers/staging/octeon/ethernet-xaui.c
@@ -112,7 +112,7 @@ int cvm_oct_xaui_init(struct net_device *dev)
 	struct octeon_ethernet *priv = netdev_priv(dev);
 	cvm_oct_common_init(dev);
 	dev->netdev_ops->ndo_stop(dev);
-	if (!octeon_is_simulation())
+	if (!octeon_is_simulation() && priv->phydev == NULL)
 		priv->poll = cvm_oct_xaui_poll;
 
 	return 0;
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index b847951..d3dff8f 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -30,7 +30,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
-#include <linux/mii.h>
+#include <linux/phy.h>
 
 #include <net/dst.h>
 
@@ -122,8 +122,6 @@ static struct timer_list cvm_oct_poll_timer;
  */
 struct net_device *cvm_oct_device[TOTAL_NUMBER_OF_PORTS];
 
-extern struct semaphore mdio_sem;
-
 /**
  * Periodic timer tick for slow management operations
  *
@@ -150,13 +148,8 @@ static void cvm_do_timer(unsigned long arg)
 		goto out;
 
 	priv = netdev_priv(cvm_oct_device[port]);
-	if (priv->poll) {
-		/* skip polling if we don't get the lock */
-		if (!down_trylock(&mdio_sem)) {
-			priv->poll(cvm_oct_device[port]);
-			up(&mdio_sem);
-		}
-	}
+	if (priv->poll)
+		priv->poll(cvm_oct_device[port]);
 
 	queues_per_port = cvmx_pko_get_num_queues(port);
 	/* Drain any pending packets in the free list */
@@ -474,16 +467,30 @@ static int cvm_oct_common_set_mac_address(struct net_device *dev, void *addr)
  */
 int cvm_oct_common_init(struct net_device *dev)
 {
-	static int count;
-	char mac[8] = { 0x00, 0x00,
-		octeon_bootinfo->mac_addr_base[0],
-		octeon_bootinfo->mac_addr_base[1],
-		octeon_bootinfo->mac_addr_base[2],
-		octeon_bootinfo->mac_addr_base[3],
-		octeon_bootinfo->mac_addr_base[4],
-		octeon_bootinfo->mac_addr_base[5] + count
-	};
 	struct octeon_ethernet *priv = netdev_priv(dev);
+	struct sockaddr sa;
+	u64 mac = ((u64)(octeon_bootinfo->mac_addr_base[0] & 0xff) << 40) |
+		((u64)(octeon_bootinfo->mac_addr_base[1] & 0xff) << 32) |
+		((u64)(octeon_bootinfo->mac_addr_base[2] & 0xff) << 24) |
+		((u64)(octeon_bootinfo->mac_addr_base[3] & 0xff) << 16) |
+		((u64)(octeon_bootinfo->mac_addr_base[4] & 0xff) << 8) |
+		(u64)(octeon_bootinfo->mac_addr_base[5] & 0xff);
+
+	mac += cvm_oct_mac_addr_offset;
+	sa.sa_data[0] = (mac >> 40) & 0xff;
+	sa.sa_data[1] = (mac >> 32) & 0xff;
+	sa.sa_data[2] = (mac >> 24) & 0xff;
+	sa.sa_data[3] = (mac >> 16) & 0xff;
+	sa.sa_data[4] = (mac >> 8) & 0xff;
+	sa.sa_data[5] = mac & 0xff;
+
+	if (cvm_oct_mac_addr_offset >= octeon_bootinfo->mac_addr_count)
+		printk(KERN_DEBUG "%s: Using MAC outside of the assigned range:"
+			" %02x:%02x:%02x:%02x:%02x:%02x\n", dev->name,
+			sa.sa_data[0] & 0xff, sa.sa_data[1] & 0xff,
+			sa.sa_data[2] & 0xff, sa.sa_data[3] & 0xff,
+			sa.sa_data[4] & 0xff, sa.sa_data[5] & 0xff);
+	cvm_oct_mac_addr_offset++;
 
 	/*
 	 * Force the interface to use the POW send if always_use_pow
@@ -496,14 +503,12 @@ int cvm_oct_common_init(struct net_device *dev)
 	if (priv->queue != -1 && USE_HW_TCPUDP_CHECKSUM)
 		dev->features |= NETIF_F_IP_CSUM;
 
-	count++;
-
 	/* We do our own locking, Linux doesn't need to */
 	dev->features |= NETIF_F_LLTX;
 	SET_ETHTOOL_OPS(dev, &cvm_oct_ethtool_ops);
 
-	cvm_oct_mdio_setup_device(dev);
-	dev->netdev_ops->ndo_set_mac_address(dev, mac);
+	cvm_oct_phy_setup_device(dev);
+	dev->netdev_ops->ndo_set_mac_address(dev, &sa);
 	dev->netdev_ops->ndo_change_mtu(dev, dev->mtu);
 
 	/*
@@ -518,7 +523,10 @@ int cvm_oct_common_init(struct net_device *dev)
 
 void cvm_oct_common_uninit(struct net_device *dev)
 {
-	/* Currently nothing to do */
+	struct octeon_ethernet *priv = netdev_priv(dev);
+
+	if (priv->phydev)
+		phy_disconnect(priv->phydev);
 }
 
 static const struct net_device_ops cvm_oct_npi_netdev_ops = {
@@ -605,6 +613,10 @@ static const struct net_device_ops cvm_oct_pow_netdev_ops = {
 #endif
 };
 
+unsigned int cvm_oct_mac_addr_offset;
+
+extern void octeon_mdiobus_force_mod_depencency(void);
+
 /**
  * Module/ driver initialization. Creates the linux network
  * devices.
@@ -618,8 +630,16 @@ static int __init cvm_oct_init_module(void)
 	int fau = FAU_NUM_PACKET_BUFFERS_TO_FREE;
 	int qos;
 
+	octeon_mdiobus_force_mod_depencency();
 	pr_notice("cavium-ethernet %s\n", OCTEON_ETHERNET_VERSION);
 
+	if (OCTEON_IS_MODEL(OCTEON_CN52XX))
+		cvm_oct_mac_addr_offset = 2; /* First two are the mgmt ports. */
+	else if (OCTEON_IS_MODEL(OCTEON_CN56XX))
+		cvm_oct_mac_addr_offset = 1; /* First one is the mgmt port. */
+	else
+		cvm_oct_mac_addr_offset = 0;
+
 	cvm_oct_proc_initialize();
 	cvm_oct_rx_initialize();
 	cvm_oct_configure_common_hw();
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index 3aef987..9b0faeb 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -50,15 +50,24 @@ struct octeon_ethernet {
 	/* List of outstanding tx buffers per queue */
 	struct sk_buff_head tx_free_list[16];
 	/* Device statistics */
-	struct net_device_stats stats
-;	/* Generic MII info structure */
-	struct mii_if_info mii_info;
+	struct net_device_stats stats;
+	struct phy_device *phydev;
+	unsigned int last_link;
 	/* Last negotiated link state */
 	uint64_t link_info;
 	/* Called periodically to check link status */
 	void (*poll) (struct net_device *dev);
 };
 
+/*
+ * The offset from mac_addr_base that should be used for the next port
+ * that is configured.  By convention, if any mgmt ports exist on the
+ * chip, they get the first mac addresses, The ports controlled by
+ * this driver are numbered sequencially following any mgmt addresses
+ * that may exist.
+ */
+extern unsigned int cvm_oct_mac_addr_offset;
+
 /**
  * Free a work queue entry received in a intercept callback.
  *
-- 
1.6.0.6
