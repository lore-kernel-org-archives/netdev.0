From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/16] sfc: Use generic MDIO functions and definitions
Date: Wed, 29 Apr 2009 19:05:08 +0100
Message-ID: <1241028308.3246.38.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:44613 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751843AbZD2SFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:05:11 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the newly-added generic MDIO clause 45 support and remove
redundant definitions.

Add an 'efx_' prefix to the remaining driver-specific MDIO functions
and remove arguments which are redundant with efx->mdio.prtad.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Kconfig         |    2 +-
 drivers/net/sfc/efx.c           |   10 +-
 drivers/net/sfc/ethtool.c       |   18 +--
 drivers/net/sfc/falcon.c        |  137 ++++----------
 drivers/net/sfc/falcon_hwdefs.h |    3 -
 drivers/net/sfc/falcon_xmac.c   |    2 +-
 drivers/net/sfc/mdio_10g.c      |  379 +++++++++------------------------------
 drivers/net/sfc/mdio_10g.h      |  281 ++++-------------------------
 drivers/net/sfc/net_driver.h    |    8 +-
 drivers/net/sfc/selftest.c      |   21 +--
 drivers/net/sfc/selftest.h      |    2 +-
 drivers/net/sfc/tenxpress.c     |  227 +++++++++--------------
 drivers/net/sfc/xenpack.h       |   15 +-
 drivers/net/sfc/xfp_phy.c       |   51 +++---
 14 files changed, 311 insertions(+), 845 deletions(-)

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index 12a8296..260aafa 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -1,7 +1,7 @@
 config SFC
 	tristate "Solarflare Solarstorm SFC4000 support"
 	depends on PCI && INET
-	select MII
+	select MDIO
 	select CRC32
 	select I2C
 	select I2C_ALGOBIT
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7269a42..d3e240b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1300,10 +1300,16 @@ out_requeue:
 static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	struct mii_ioctl_data *data = if_mii(ifr);
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
-	return generic_mii_ioctl(&efx->mii, if_mii(ifr), cmd, NULL);
+	/* Convert phy_id from older PRTAD/DEVAD format */
+	if ((cmd == SIOCGMIIREG || cmd == SIOCSMIIREG) &&
+	    (data->phy_id & 0xfc00) == 0x0400)
+		data->phy_id ^= MDIO_PHY_ID_C45 | 0x0400;
+
+	return mdio_mii_ioctl(&efx->mdio, data, cmd);
 }
 
 /**************************************************************************
@@ -1945,7 +1951,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	mutex_init(&efx->mac_lock);
 	efx->mac_op = &efx_dummy_mac_operations;
 	efx->phy_op = &efx_dummy_phy_operations;
-	efx->mii.dev = net_dev;
+	efx->mdio.dev = net_dev;
 	INIT_WORK(&efx->phy_work, efx_phy_work);
 	INIT_WORK(&efx->mac_work, efx_mac_work);
 	atomic_set(&efx->netif_stop_count, 1);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 64309f4..1c7b684 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -10,6 +10,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
+#include <linux/mdio.h>
 #include <linux/rtnetlink.h>
 #include "net_driver.h"
 #include "workarounds.h"
@@ -345,8 +346,8 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 	unsigned int n = 0, i;
 	enum efx_loopback_mode mode;
 
-	efx_fill_test(n++, strings, data, &tests->mii,
-		      "core", 0, "mii", NULL);
+	efx_fill_test(n++, strings, data, &tests->mdio,
+		      "core", 0, "mdio", NULL);
 	efx_fill_test(n++, strings, data, &tests->nvram,
 		      "core", 0, "nvram", NULL);
 	efx_fill_test(n++, strings, data, &tests->interrupt,
@@ -529,14 +530,7 @@ static int efx_ethtool_nway_reset(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	if (efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) {
-		mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_AN,
-				       MDIO_MMDREG_CTRL1,
-				       __ffs(BMCR_ANRESTART), true);
-		return 0;
-	}
-
-	return -EOPNOTSUPP;
+	return mdio45_nway_restart(&efx->mdio);
 }
 
 static u32 efx_ethtool_get_link(struct net_device *net_dev)
@@ -689,7 +683,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 		return -EINVAL;
 	}
 
-	if (!(efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) &&
+	if (!(efx->phy_op->mmds & MDIO_DEVS_AN) &&
 	    (wanted_fc & EFX_FC_AUTO)) {
 		EFX_LOG(efx, "PHY does not support flow control "
 			"autonegotiation\n");
@@ -717,7 +711,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	mutex_lock(&efx->mac_lock);
 
 	efx->wanted_fc = wanted_fc;
-	mdio_clause45_set_pause(efx);
+	efx_mdio_set_pause(efx);
 	__efx_reconfigure_port(efx);
 
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 466a8ab..c049364 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2063,26 +2063,6 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
  **************************************************************************
  */
 
-/* Use the top bit of the MII PHY id to indicate the PHY type
- * (1G/10G), with the remaining bits as the actual PHY id.
- *
- * This allows us to avoid leaking information from the mii_if_info
- * structure into other data structures.
- */
-#define FALCON_PHY_ID_ID_WIDTH  EFX_WIDTH(MD_PRT_DEV_ADR)
-#define FALCON_PHY_ID_ID_MASK   ((1 << FALCON_PHY_ID_ID_WIDTH) - 1)
-#define FALCON_PHY_ID_WIDTH     (FALCON_PHY_ID_ID_WIDTH + 1)
-#define FALCON_PHY_ID_MASK      ((1 << FALCON_PHY_ID_WIDTH) - 1)
-#define FALCON_PHY_ID_10G       (1 << (FALCON_PHY_ID_WIDTH - 1))
-
-
-/* Packing the clause 45 port and device fields into a single value */
-#define MD_PRT_ADR_COMP_LBN   (MD_PRT_ADR_LBN - MD_DEV_ADR_LBN)
-#define MD_PRT_ADR_COMP_WIDTH  MD_PRT_ADR_WIDTH
-#define MD_DEV_ADR_COMP_LBN    0
-#define MD_DEV_ADR_COMP_WIDTH  MD_DEV_ADR_WIDTH
-
-
 /* Wait for GMII access to complete */
 static int falcon_gmii_wait(struct efx_nic *efx)
 {
@@ -2108,49 +2088,29 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }
 
-/* Writes a GMII register of a PHY connected to Falcon using MDIO. */
-static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
-			      int addr, int value)
+/* Write an MDIO register of a PHY connected to Falcon. */
+static int falcon_mdio_write(struct net_device *net_dev,
+			     int prtad, int devad, u16 addr, u16 value)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	unsigned int phy_id2 = phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
+	int rc;
 
-	/* The 'generic' prt/dev packing in mdio_10g.h is conveniently
-	 * chosen so that the only current user, Falcon, can take the
-	 * packed value and use them directly.
-	 * Fail to build if this assumption is broken.
-	 */
-	BUILD_BUG_ON(FALCON_PHY_ID_10G != MDIO45_XPRT_ID_IS10G);
-	BUILD_BUG_ON(FALCON_PHY_ID_ID_WIDTH != MDIO45_PRT_DEV_WIDTH);
-	BUILD_BUG_ON(MD_PRT_ADR_COMP_LBN != MDIO45_PRT_ID_COMP_LBN);
-	BUILD_BUG_ON(MD_DEV_ADR_COMP_LBN != MDIO45_DEV_ID_COMP_LBN);
-
-	if (phy_id2 == PHY_ADDR_INVALID)
-		return;
-
-	/* See falcon_mdio_read for an explanation. */
-	if (!(phy_id & FALCON_PHY_ID_10G)) {
-		int mmd = ffs(efx->phy_op->mmds) - 1;
-		EFX_TRACE(efx, "Fixing erroneous clause22 write\n");
-		phy_id2 = mdio_clause45_pack(phy_id2, mmd)
-			& FALCON_PHY_ID_ID_MASK;
-	}
-
-	EFX_REGDUMP(efx, "writing GMII %d register %02x with %04x\n", phy_id,
-		    addr, value);
+	EFX_REGDUMP(efx, "writing MDIO %d register %d.%d with 0x%04x\n",
+		    prtad, devad, addr, value);
 
 	spin_lock_bh(&efx->phy_lock);
 
-	/* Check MII not currently being accessed */
-	if (falcon_gmii_wait(efx) != 0)
+	/* Check MDIO not currently being accessed */
+	rc = falcon_gmii_wait(efx);
+	if (rc)
 		goto out;
 
 	/* Write the address/ID register */
 	EFX_POPULATE_OWORD_1(reg, MD_PHY_ADR, addr);
 	falcon_write(efx, &reg, MD_PHY_ADR_REG_KER);
 
-	EFX_POPULATE_OWORD_1(reg, MD_PRT_DEV_ADR, phy_id2);
+	EFX_POPULATE_OWORD_2(reg, MD_PRT_ADR, prtad, MD_DEV_ADR, devad);
 	falcon_write(efx, &reg, MD_ID_REG_KER);
 
 	/* Write data */
@@ -2163,7 +2123,8 @@ static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
 	falcon_write(efx, &reg, MD_CS_REG_KER);
 
 	/* Wait for data to be written */
-	if (falcon_gmii_wait(efx) != 0) {
+	rc = falcon_gmii_wait(efx);
+	if (rc) {
 		/* Abort the write operation */
 		EFX_POPULATE_OWORD_2(reg,
 				     MD_WRC, 0,
@@ -2174,45 +2135,28 @@ static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
 
  out:
 	spin_unlock_bh(&efx->phy_lock);
+	return rc;
 }
 
-/* Reads a GMII register from a PHY connected to Falcon.  If no value
- * could be read, -1 will be returned. */
-static int falcon_mdio_read(struct net_device *net_dev, int phy_id, int addr)
+/* Read an MDIO register of a PHY connected to Falcon. */
+static int falcon_mdio_read(struct net_device *net_dev,
+			    int prtad, int devad, u16 addr)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	unsigned int phy_addr = phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
-	int value = -1;
-
-	if (phy_addr == PHY_ADDR_INVALID)
-		return -1;
-
-	/* Our PHY code knows whether it needs to talk clause 22(1G) or 45(10G)
-	 * but the generic Linux code does not make any distinction or have
-	 * any state for this.
-	 * We spot the case where someone tried to talk 22 to a 45 PHY and
-	 * redirect the request to the lowest numbered MMD as a clause45
-	 * request. This is enough to allow simple queries like id and link
-	 * state to succeed. TODO: We may need to do more in future.
-	 */
-	if (!(phy_id & FALCON_PHY_ID_10G)) {
-		int mmd = ffs(efx->phy_op->mmds) - 1;
-		EFX_TRACE(efx, "Fixing erroneous clause22 read\n");
-		phy_addr = mdio_clause45_pack(phy_addr, mmd)
-			& FALCON_PHY_ID_ID_MASK;
-	}
+	int rc;
 
 	spin_lock_bh(&efx->phy_lock);
 
-	/* Check MII not currently being accessed */
-	if (falcon_gmii_wait(efx) != 0)
+	/* Check MDIO not currently being accessed */
+	rc = falcon_gmii_wait(efx);
+	if (rc)
 		goto out;
 
 	EFX_POPULATE_OWORD_1(reg, MD_PHY_ADR, addr);
 	falcon_write(efx, &reg, MD_PHY_ADR_REG_KER);
 
-	EFX_POPULATE_OWORD_1(reg, MD_PRT_DEV_ADR, phy_addr);
+	EFX_POPULATE_OWORD_2(reg, MD_PRT_ADR, prtad, MD_DEV_ADR, devad);
 	falcon_write(efx, &reg, MD_ID_REG_KER);
 
 	/* Request data to be read */
@@ -2220,12 +2164,12 @@ static int falcon_mdio_read(struct net_device *net_dev, int phy_id, int addr)
 	falcon_write(efx, &reg, MD_CS_REG_KER);
 
 	/* Wait for data to become available */
-	value = falcon_gmii_wait(efx);
-	if (value == 0) {
+	rc = falcon_gmii_wait(efx);
+	if (rc == 0) {
 		falcon_read(efx, &reg, MD_RXD_REG_KER);
-		value = EFX_OWORD_FIELD(reg, MD_RXD);
-		EFX_REGDUMP(efx, "read from GMII %d register %02x, got %04x\n",
-			    phy_id, addr, value);
+		rc = EFX_OWORD_FIELD(reg, MD_RXD);
+		EFX_REGDUMP(efx, "read from MDIO %d register %d.%d, got %04x\n",
+			    prtad, devad, addr, rc);
 	} else {
 		/* Abort the read operation */
 		EFX_POPULATE_OWORD_2(reg,
@@ -2233,22 +2177,13 @@ static int falcon_mdio_read(struct net_device *net_dev, int phy_id, int addr)
 				     MD_GC, 1);
 		falcon_write(efx, &reg, MD_CS_REG_KER);
 
-		EFX_LOG(efx, "read from GMII 0x%x register %02x, got "
-			"error %d\n", phy_id, addr, value);
+		EFX_LOG(efx, "read from MDIO %d register %d.%d, got error %d\n",
+			prtad, devad, addr, rc);
 	}
 
  out:
 	spin_unlock_bh(&efx->phy_lock);
-
-	return value;
-}
-
-static void falcon_init_mdio(struct mii_if_info *gmii)
-{
-	gmii->mdio_read = falcon_mdio_read;
-	gmii->mdio_write = falcon_mdio_write;
-	gmii->phy_id_mask = FALCON_PHY_ID_MASK;
-	gmii->reg_num_mask = ((1 << EFX_WIDTH(MD_PHY_ADR)) - 1);
+	return rc;
 }
 
 static int falcon_probe_phy(struct efx_nic *efx)
@@ -2342,9 +2277,11 @@ int falcon_probe_port(struct efx_nic *efx)
 	if (rc)
 		return rc;
 
-	/* Set up GMII structure for PHY */
-	efx->mii.supports_gmii = true;
-	falcon_init_mdio(&efx->mii);
+	/* Set up MDIO structure for PHY */
+	efx->mdio.mmds = efx->phy_op->mmds;
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->mdio.mdio_read = falcon_mdio_read;
+	efx->mdio.mdio_write = falcon_mdio_write;
 
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
@@ -2761,7 +2698,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	if (rc == -EINVAL) {
 		EFX_ERR(efx, "NVRAM is invalid therefore using defaults\n");
 		efx->phy_type = PHY_TYPE_NONE;
-		efx->mii.phy_id = PHY_ADDR_INVALID;
+		efx->mdio.prtad = MDIO_PRTAD_NONE;
 		board_rev = 0;
 		rc = 0;
 	} else if (rc) {
@@ -2771,7 +2708,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 		struct falcon_nvconfig_board_v3 *v3 = &nvconfig->board_v3;
 
 		efx->phy_type = v2->port0_phy_type;
-		efx->mii.phy_id = v2->port0_phy_addr;
+		efx->mdio.prtad = v2->port0_phy_addr;
 		board_rev = le16_to_cpu(v2->board_revision);
 
 		if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
@@ -2793,7 +2730,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	/* Read the MAC addresses */
 	memcpy(efx->mac_address, nvconfig->mac_address[0], ETH_ALEN);
 
-	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mii.phy_id);
+	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mdio.prtad);
 
 	efx_set_board_info(efx, board_rev);
 
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index bda8d5b..375e2a5 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -456,9 +456,6 @@
 #define MD_PRT_ADR_WIDTH 5
 #define MD_DEV_ADR_LBN 6
 #define MD_DEV_ADR_WIDTH 5
-/* Used for writing both at once */
-#define MD_PRT_DEV_ADR_LBN 6
-#define MD_PRT_DEV_ADR_WIDTH 10
 
 /* PHY management status & mask register (DWORD read only) */
 #define MD_STAT_REG_KER 0xc50
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 5a03713..2b3269c 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -133,7 +133,7 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 	/* If the link is up, then check the phy side of the xaui link */
 	if (efx->link_up && link_ok)
 		if (efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS))
-			link_ok = mdio_clause45_phyxgxs_lane_sync(efx);
+			link_ok = efx_mdio_phyxgxs_lane_sync(efx);
 
 	return link_ok;
 }
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 9f5ec3e..11c231a 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -17,7 +17,7 @@
 #include "boards.h"
 #include "workarounds.h"
 
-unsigned mdio_id_oui(u32 id)
+unsigned efx_mdio_id_oui(u32 id)
 {
 	unsigned oui = 0;
 	int i;
@@ -32,52 +32,45 @@ unsigned mdio_id_oui(u32 id)
 	return oui;
 }
 
-int mdio_clause45_reset_mmd(struct efx_nic *port, int mmd,
+int efx_mdio_reset_mmd(struct efx_nic *port, int mmd,
 			    int spins, int spintime)
 {
 	u32 ctrl;
-	int phy_id = port->mii.phy_id;
 
 	/* Catch callers passing values in the wrong units (or just silly) */
 	EFX_BUG_ON_PARANOID(spins * spintime >= 5000);
 
-	mdio_clause45_write(port, phy_id, mmd, MDIO_MMDREG_CTRL1,
-			    (1 << MDIO_MMDREG_CTRL1_RESET_LBN));
+	efx_mdio_write(port, mmd, MDIO_CTRL1, MDIO_CTRL1_RESET);
 	/* Wait for the reset bit to clear. */
 	do {
 		msleep(spintime);
-		ctrl = mdio_clause45_read(port, phy_id, mmd, MDIO_MMDREG_CTRL1);
+		ctrl = efx_mdio_read(port, mmd, MDIO_CTRL1);
 		spins--;
 
-	} while (spins && (ctrl & (1 << MDIO_MMDREG_CTRL1_RESET_LBN)));
+	} while (spins && (ctrl & MDIO_CTRL1_RESET));
 
 	return spins ? spins : -ETIMEDOUT;
 }
 
-static int mdio_clause45_check_mmd(struct efx_nic *efx, int mmd,
-				   int fault_fatal)
+static int efx_mdio_check_mmd(struct efx_nic *efx, int mmd, int fault_fatal)
 {
 	int status;
-	int phy_id = efx->mii.phy_id;
 
 	if (LOOPBACK_INTERNAL(efx))
 		return 0;
 
 	if (mmd != MDIO_MMD_AN) {
 		/* Read MMD STATUS2 to check it is responding. */
-		status = mdio_clause45_read(efx, phy_id, mmd,
-					    MDIO_MMDREG_STAT2);
-		if (((status >> MDIO_MMDREG_STAT2_PRESENT_LBN) &
-		     ((1 << MDIO_MMDREG_STAT2_PRESENT_WIDTH) - 1)) !=
-		    MDIO_MMDREG_STAT2_PRESENT_VAL) {
+		status = efx_mdio_read(efx, mmd, MDIO_STAT2);
+		if ((status & MDIO_STAT2_DEVPRST) != MDIO_STAT2_DEVPRST_VAL) {
 			EFX_ERR(efx, "PHY MMD %d not responding.\n", mmd);
 			return -EIO;
 		}
 	}
 
 	/* Read MMD STATUS 1 to check for fault. */
-	status = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_STAT1);
-	if ((status & (1 << MDIO_MMDREG_STAT1_FAULT_LBN)) != 0) {
+	status = efx_mdio_read(efx, mmd, MDIO_STAT1);
+	if (status & MDIO_STAT1_FAULT) {
 		if (fault_fatal) {
 			EFX_ERR(efx, "PHY MMD %d reporting fatal"
 				" fault: status %x\n", mmd, status);
@@ -94,8 +87,7 @@ static int mdio_clause45_check_mmd(struct efx_nic *efx, int mmd,
 #define MDIO45_RESET_TIME	1000 /* ms */
 #define MDIO45_RESET_ITERS	100
 
-int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
-				  unsigned int mmd_mask)
+int efx_mdio_wait_reset_mmds(struct efx_nic *efx, unsigned int mmd_mask)
 {
 	const int spintime = MDIO45_RESET_TIME / MDIO45_RESET_ITERS;
 	int tries = MDIO45_RESET_ITERS;
@@ -109,16 +101,13 @@ int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
 		in_reset = 0;
 		while (mask) {
 			if (mask & 1) {
-				stat = mdio_clause45_read(efx,
-							  efx->mii.phy_id,
-							  mmd,
-							  MDIO_MMDREG_CTRL1);
+				stat = efx_mdio_read(efx, mmd, MDIO_CTRL1);
 				if (stat < 0) {
 					EFX_ERR(efx, "failed to read status of"
 						" MMD %d\n", mmd);
 					return -EIO;
 				}
-				if (stat & (1 << MDIO_MMDREG_CTRL1_RESET_LBN))
+				if (stat & MDIO_CTRL1_RESET)
 					in_reset |= (1 << mmd);
 			}
 			mask = mask >> 1;
@@ -137,28 +126,26 @@ int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
 	return rc;
 }
 
-int mdio_clause45_check_mmds(struct efx_nic *efx,
-			     unsigned int mmd_mask, unsigned int fatal_mask)
+int efx_mdio_check_mmds(struct efx_nic *efx,
+			unsigned int mmd_mask, unsigned int fatal_mask)
 {
-	int mmd = 0, probe_mmd, devs0, devs1;
+	int mmd = 0, probe_mmd, devs1, devs2;
 	u32 devices;
 
 	/* Historically we have probed the PHYXS to find out what devices are
 	 * present,but that doesn't work so well if the PHYXS isn't expected
 	 * to exist, if so just find the first item in the list supplied. */
-	probe_mmd = (mmd_mask & MDIO_MMDREG_DEVS_PHYXS) ? MDIO_MMD_PHYXS :
+	probe_mmd = (mmd_mask & MDIO_DEVS_PHYXS) ? MDIO_MMD_PHYXS :
 	    __ffs(mmd_mask);
 
 	/* Check all the expected MMDs are present */
-	devs0 = mdio_clause45_read(efx, efx->mii.phy_id,
-				   probe_mmd, MDIO_MMDREG_DEVS0);
-	devs1 = mdio_clause45_read(efx, efx->mii.phy_id,
-				   probe_mmd, MDIO_MMDREG_DEVS1);
-	if (devs0 < 0 || devs1 < 0) {
+	devs1 = efx_mdio_read(efx, probe_mmd, MDIO_DEVS1);
+	devs2 = efx_mdio_read(efx, probe_mmd, MDIO_DEVS2);
+	if (devs1 < 0 || devs2 < 0) {
 		EFX_ERR(efx, "failed to read devices present\n");
 		return -EIO;
 	}
-	devices = devs0 | (devs1 << 16);
+	devices = devs1 | (devs2 << 16);
 	if ((devices & mmd_mask) != mmd_mask) {
 		EFX_ERR(efx, "required MMDs not present: got %x, "
 			"wanted %x\n", devices, mmd_mask);
@@ -170,7 +157,7 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 	while (mmd_mask) {
 		if (mmd_mask & 1) {
 			int fault_fatal = fatal_mask & 1;
-			if (mdio_clause45_check_mmd(efx, mmd, fault_fatal))
+			if (efx_mdio_check_mmd(efx, mmd, fault_fatal))
 				return -EIO;
 		}
 		mmd_mask = mmd_mask >> 1;
@@ -181,13 +168,8 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 	return 0;
 }
 
-bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
+bool efx_mdio_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 {
-	int phy_id = efx->mii.phy_id;
-	u32 reg;
-	bool ok = true;
-	int mmd = 0;
-
 	/* If the port is in loopback, then we should only consider a subset
 	 * of mmd's */
 	if (LOOPBACK_INTERNAL(efx))
@@ -197,241 +179,75 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	else if (efx_phy_mode_disabled(efx->phy_mode))
 		return false;
 	else if (efx->loopback_mode == LOOPBACK_PHYXS)
-		mmd_mask &= ~(MDIO_MMDREG_DEVS_PHYXS |
-			      MDIO_MMDREG_DEVS_PCS |
-			      MDIO_MMDREG_DEVS_PMAPMD |
-			      MDIO_MMDREG_DEVS_AN);
+		mmd_mask &= ~(MDIO_DEVS_PHYXS |
+			      MDIO_DEVS_PCS |
+			      MDIO_DEVS_PMAPMD |
+			      MDIO_DEVS_AN);
 	else if (efx->loopback_mode == LOOPBACK_PCS)
-		mmd_mask &= ~(MDIO_MMDREG_DEVS_PCS |
-			      MDIO_MMDREG_DEVS_PMAPMD |
-			      MDIO_MMDREG_DEVS_AN);
+		mmd_mask &= ~(MDIO_DEVS_PCS |
+			      MDIO_DEVS_PMAPMD |
+			      MDIO_DEVS_AN);
 	else if (efx->loopback_mode == LOOPBACK_PMAPMD)
-		mmd_mask &= ~(MDIO_MMDREG_DEVS_PMAPMD |
-			      MDIO_MMDREG_DEVS_AN);
-
-	if (!mmd_mask) {
-		/* Use presence of XGMII faults in leui of link state */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
-					 MDIO_PHYXS_STATUS2);
-		return !(reg & (1 << MDIO_PHYXS_STATUS2_RX_FAULT_LBN));
-	}
+		mmd_mask &= ~(MDIO_DEVS_PMAPMD |
+			      MDIO_DEVS_AN);
 
-	while (mmd_mask) {
-		if (mmd_mask & 1) {
-			/* Double reads because link state is latched, and a
-			 * read moves the current state into the register */
-			reg = mdio_clause45_read(efx, phy_id,
-						 mmd, MDIO_MMDREG_STAT1);
-			reg = mdio_clause45_read(efx, phy_id,
-						 mmd, MDIO_MMDREG_STAT1);
-			ok = ok && (reg & (1 << MDIO_MMDREG_STAT1_LINK_LBN));
-		}
-		mmd_mask = (mmd_mask >> 1);
-		mmd++;
-	}
-	return ok;
+	return mdio45_links_ok(&efx->mdio, mmd_mask);
 }
 
-void mdio_clause45_transmit_disable(struct efx_nic *efx)
+void efx_mdio_transmit_disable(struct efx_nic *efx)
 {
-	mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			       MDIO_MMDREG_TXDIS, MDIO_MMDREG_TXDIS_GLOBAL_LBN,
-			       efx->phy_mode & PHY_MODE_TX_DISABLED);
+	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD,
+			  MDIO_PMA_TXDIS, MDIO_PMD_TXDIS_GLOBAL,
+			  efx->phy_mode & PHY_MODE_TX_DISABLED);
 }
 
-void mdio_clause45_phy_reconfigure(struct efx_nic *efx)
+void efx_mdio_phy_reconfigure(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
-
-	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PMAPMD,
-			       MDIO_MMDREG_CTRL1, MDIO_PMAPMD_CTRL1_LBACK_LBN,
-			       efx->loopback_mode == LOOPBACK_PMAPMD);
-	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PCS,
-			       MDIO_MMDREG_CTRL1, MDIO_MMDREG_CTRL1_LBACK_LBN,
-			       efx->loopback_mode == LOOPBACK_PCS);
-	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PHYXS,
-			       MDIO_MMDREG_CTRL1, MDIO_MMDREG_CTRL1_LBACK_LBN,
-			       efx->loopback_mode == LOOPBACK_NETWORK);
+	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD,
+			  MDIO_CTRL1, MDIO_PMA_CTRL1_LOOPBACK,
+			  efx->loopback_mode == LOOPBACK_PMAPMD);
+	efx_mdio_set_flag(efx, MDIO_MMD_PCS,
+			  MDIO_CTRL1, MDIO_PCS_CTRL1_LOOPBACK,
+			  efx->loopback_mode == LOOPBACK_PCS);
+	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS,
+			  MDIO_CTRL1, MDIO_PHYXS_CTRL1_LOOPBACK,
+			  efx->loopback_mode == LOOPBACK_NETWORK);
 }
 
-static void mdio_clause45_set_mmd_lpower(struct efx_nic *efx,
-					 int lpower, int mmd)
+static void efx_mdio_set_mmd_lpower(struct efx_nic *efx,
+				    int lpower, int mmd)
 {
-	int phy = efx->mii.phy_id;
-	int stat = mdio_clause45_read(efx, phy, mmd, MDIO_MMDREG_STAT1);
+	int stat = efx_mdio_read(efx, mmd, MDIO_STAT1);
 
 	EFX_TRACE(efx, "Setting low power mode for MMD %d to %d\n",
 		  mmd, lpower);
 
-	if (stat & (1 << MDIO_MMDREG_STAT1_LPABLE_LBN)) {
-		mdio_clause45_set_flag(efx, phy, mmd, MDIO_MMDREG_CTRL1,
-				       MDIO_MMDREG_CTRL1_LPOWER_LBN, lpower);
+	if (stat & MDIO_STAT1_LPOWERABLE) {
+		efx_mdio_set_flag(efx, mmd, MDIO_CTRL1,
+				  MDIO_CTRL1_LPOWER, lpower);
 	}
 }
 
-void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
-				   int low_power, unsigned int mmd_mask)
+void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
+			      int low_power, unsigned int mmd_mask)
 {
 	int mmd = 0;
-	mmd_mask &= ~MDIO_MMDREG_DEVS_AN;
+	mmd_mask &= ~MDIO_DEVS_AN;
 	while (mmd_mask) {
 		if (mmd_mask & 1)
-			mdio_clause45_set_mmd_lpower(efx, low_power, mmd);
+			efx_mdio_set_mmd_lpower(efx, low_power, mmd);
 		mmd_mask = (mmd_mask >> 1);
 		mmd++;
 	}
 }
 
-static u32 mdio_clause45_get_an(struct efx_nic *efx, u16 addr)
-{
-	int phy_id = efx->mii.phy_id;
-	u32 result = 0;
-	int reg;
-
-	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN, addr);
-	if (reg & ADVERTISE_10HALF)
-		result |= ADVERTISED_10baseT_Half;
-	if (reg & ADVERTISE_10FULL)
-		result |= ADVERTISED_10baseT_Full;
-	if (reg & ADVERTISE_100HALF)
-		result |= ADVERTISED_100baseT_Half;
-	if (reg & ADVERTISE_100FULL)
-		result |= ADVERTISED_100baseT_Full;
-	return result;
-}
-
-/**
- * mdio_clause45_get_settings - Read (some of) the PHY settings over MDIO.
- * @efx:		Efx NIC
- * @ecmd: 		Buffer for settings
- *
- * On return the 'port', 'speed', 'supported' and 'advertising' fields of
- * ecmd have been filled out.
- */
-void mdio_clause45_get_settings(struct efx_nic *efx,
-				struct ethtool_cmd *ecmd)
-{
-	mdio_clause45_get_settings_ext(efx, ecmd, 0, 0);
-}
-
 /**
- * mdio_clause45_get_settings_ext - Read (some of) the PHY settings over MDIO.
- * @efx:		Efx NIC
- * @ecmd: 		Buffer for settings
- * @xnp:		Advertised Extended Next Page state
- * @xnp_lpa:		Link Partner's advertised XNP state
- *
- * On return the 'port', 'speed', 'supported' and 'advertising' fields of
- * ecmd have been filled out.
- */
-void mdio_clause45_get_settings_ext(struct efx_nic *efx,
-				    struct ethtool_cmd *ecmd,
-				    u32 npage_adv, u32 npage_lpa)
-{
-	int phy_id = efx->mii.phy_id;
-	int reg;
-
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->phy_address = phy_id;
-
-	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-				 MDIO_MMDREG_CTRL2);
-	switch (reg & MDIO_PMAPMD_CTRL2_TYPE_MASK) {
-	case MDIO_PMAPMD_CTRL2_10G_BT:
-	case MDIO_PMAPMD_CTRL2_1G_BT:
-	case MDIO_PMAPMD_CTRL2_100_BT:
-	case MDIO_PMAPMD_CTRL2_10_BT:
-		ecmd->port = PORT_TP;
-		ecmd->supported = SUPPORTED_TP;
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-					 MDIO_MMDREG_SPEED);
-		if (reg & (1 << MDIO_MMDREG_SPEED_10G_LBN))
-			ecmd->supported |= SUPPORTED_10000baseT_Full;
-		if (reg & (1 << MDIO_MMDREG_SPEED_1000M_LBN))
-			ecmd->supported |= (SUPPORTED_1000baseT_Full |
-					    SUPPORTED_1000baseT_Half);
-		if (reg & (1 << MDIO_MMDREG_SPEED_100M_LBN))
-			ecmd->supported |= (SUPPORTED_100baseT_Full |
-					    SUPPORTED_100baseT_Half);
-		if (reg & (1 << MDIO_MMDREG_SPEED_10M_LBN))
-			ecmd->supported |= (SUPPORTED_10baseT_Full |
-					    SUPPORTED_10baseT_Half);
-		ecmd->advertising = ADVERTISED_TP;
-		break;
-
-	/* We represent CX4 as fibre in the absence of anything better */
-	case MDIO_PMAPMD_CTRL2_10G_CX4:
-	/* All the other defined modes are flavours of optical */
-	default:
-		ecmd->port = PORT_FIBRE;
-		ecmd->supported = SUPPORTED_FIBRE;
-		ecmd->advertising = ADVERTISED_FIBRE;
-		break;
-	}
-
-	if (efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) {
-		ecmd->supported |= SUPPORTED_Autoneg;
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-					 MDIO_MMDREG_CTRL1);
-		if (reg & BMCR_ANENABLE) {
-			ecmd->autoneg = AUTONEG_ENABLE;
-			ecmd->advertising |=
-				ADVERTISED_Autoneg |
-				mdio_clause45_get_an(efx, MDIO_AN_ADVERTISE) |
-				npage_adv;
-		} else
-			ecmd->autoneg = AUTONEG_DISABLE;
-	} else
-		ecmd->autoneg = AUTONEG_DISABLE;
-
-	if (ecmd->autoneg) {
-		/* If AN is complete, report best common mode,
-		 * otherwise report best advertised mode. */
-		u32 modes = 0;
-		if (mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-				       MDIO_MMDREG_STAT1) &
-		    (1 << MDIO_AN_STATUS_AN_DONE_LBN))
-			modes = (ecmd->advertising &
-				 (mdio_clause45_get_an(efx, MDIO_AN_LPA) |
-				  npage_lpa));
-		if (modes == 0)
-			modes = ecmd->advertising;
-
-		if (modes & ADVERTISED_10000baseT_Full) {
-			ecmd->speed = SPEED_10000;
-			ecmd->duplex = DUPLEX_FULL;
-		} else if (modes & (ADVERTISED_1000baseT_Full |
-				    ADVERTISED_1000baseT_Half)) {
-			ecmd->speed = SPEED_1000;
-			ecmd->duplex = !!(modes & ADVERTISED_1000baseT_Full);
-		} else if (modes & (ADVERTISED_100baseT_Full |
-				    ADVERTISED_100baseT_Half)) {
-			ecmd->speed = SPEED_100;
-			ecmd->duplex = !!(modes & ADVERTISED_100baseT_Full);
-		} else {
-			ecmd->speed = SPEED_10;
-			ecmd->duplex = !!(modes & ADVERTISED_10baseT_Full);
-		}
-	} else {
-		/* Report forced settings */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-					 MDIO_MMDREG_CTRL1);
-		ecmd->speed = (((reg & BMCR_SPEED1000) ? 100 : 1) *
-			       ((reg & BMCR_SPEED100) ? 100 : 10));
-		ecmd->duplex = (reg & BMCR_FULLDPLX ||
-				ecmd->speed == SPEED_10000);
-	}
-}
-
-/**
- * mdio_clause45_set_settings - Set (some of) the PHY settings over MDIO.
+ * efx_mdio_set_settings - Set (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
  * @ecmd: 		New settings
  */
-int mdio_clause45_set_settings(struct efx_nic *efx,
-			       struct ethtool_cmd *ecmd)
+int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	int phy_id = efx->mii.phy_id;
 	struct ethtool_cmd prev;
 	u32 required;
 	int reg;
@@ -489,94 +305,67 @@ int mdio_clause45_set_settings(struct efx_nic *efx,
 					      ADVERTISED_1000baseT_Full))
 			reg |= ADVERTISE_NPAGE;
 		reg |= efx_fc_advertise(efx->wanted_fc);
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
-				    MDIO_AN_ADVERTISE, reg);
+		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
 
 		/* Set up the (extended) next page if necessary */
 		if (efx->phy_op->set_npage_adv)
 			efx->phy_op->set_npage_adv(efx, ecmd->advertising);
 
 		/* Enable and restart AN */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-					 MDIO_MMDREG_CTRL1);
-		reg |= BMCR_ANENABLE;
+		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
+		reg |= MDIO_AN_CTRL1_ENABLE;
 		if (!(EFX_WORKAROUND_15195(efx) &&
 		      LOOPBACK_MASK(efx) & efx->phy_op->loopbacks))
-			reg |= BMCR_ANRESTART;
+			reg |= MDIO_AN_CTRL1_RESTART;
 		if (xnp)
-			reg |= 1 << MDIO_AN_CTRL_XNP_LBN;
+			reg |= MDIO_AN_CTRL1_XNP;
 		else
-			reg &= ~(1 << MDIO_AN_CTRL_XNP_LBN);
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
-				    MDIO_MMDREG_CTRL1, reg);
+			reg &= ~MDIO_AN_CTRL1_XNP;
+		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
 	} else {
 		/* Disable AN */
-		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_AN,
-				       MDIO_MMDREG_CTRL1,
-				       __ffs(BMCR_ANENABLE), false);
+		efx_mdio_set_flag(efx, MDIO_MMD_AN, MDIO_CTRL1,
+				  MDIO_AN_CTRL1_ENABLE, false);
 
 		/* Set the basic control bits */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-					 MDIO_MMDREG_CTRL1);
-		reg &= ~(BMCR_SPEED1000 | BMCR_SPEED100 | BMCR_FULLDPLX |
-			 0x003c);
+		reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1);
+		reg &= ~(MDIO_CTRL1_SPEEDSEL | MDIO_CTRL1_FULLDPLX);
 		if (ecmd->speed == SPEED_100)
-			reg |= BMCR_SPEED100;
+			reg |= MDIO_PMA_CTRL1_SPEED100;
 		if (ecmd->duplex)
-			reg |= BMCR_FULLDPLX;
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-				    MDIO_MMDREG_CTRL1, reg);
+			reg |= MDIO_CTRL1_FULLDPLX;
+		efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1, reg);
 	}
 
 	return 0;
 }
 
-void mdio_clause45_set_pause(struct efx_nic *efx)
+void efx_mdio_set_pause(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
 	int reg;
 
-	if (efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) {
+	if (efx->phy_op->mmds & MDIO_DEVS_AN) {
 		/* Set pause capability advertising */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-					 MDIO_AN_ADVERTISE);
+		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
 		reg &= ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
 		reg |= efx_fc_advertise(efx->wanted_fc);
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
-				    MDIO_AN_ADVERTISE, reg);
+		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
 
 		/* Restart auto-negotiation */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-					 MDIO_MMDREG_CTRL1);
-		if (reg & BMCR_ANENABLE) {
-			reg |= BMCR_ANRESTART;
-			mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
-					    MDIO_MMDREG_CTRL1, reg);
+		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
+		if (reg & MDIO_AN_CTRL1_ENABLE) {
+			reg |= MDIO_AN_CTRL1_RESTART;
+			efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
 		}
 	}
 }
 
-enum efx_fc_type mdio_clause45_get_pause(struct efx_nic *efx)
+enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
 	int lpa;
 
-	if (!(efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)))
+	if (!(efx->phy_op->mmds & MDIO_DEVS_AN))
 		return efx->wanted_fc;
-	lpa = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN, MDIO_AN_LPA);
+	lpa = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_LPA);
 	return efx_fc_resolve(efx->wanted_fc, lpa);
 }
-
-void mdio_clause45_set_flag(struct efx_nic *efx, u8 prt, u8 dev,
-			    u16 addr, int bit, bool sense)
-{
-	int old_val = mdio_clause45_read(efx, prt, dev, addr);
-	int new_val;
-
-	if (sense)
-		new_val = old_val | (1 << bit);
-	else
-		new_val = old_val & ~(1 << bit);
-	if (old_val != new_val)
-		mdio_clause45_write(efx, prt, dev, addr, new_val);
-}
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 7014d22..ea4587d 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -10,247 +10,53 @@
 #ifndef EFX_MDIO_10G_H
 #define EFX_MDIO_10G_H
 
+#include <linux/mdio.h>
+
 /*
- * Definitions needed for doing 10G MDIO as specified in clause 45
- * MDIO, which do not appear in Linux yet. Also some helper functions.
+ * Helper functions for doing 10G MDIO as specified in IEEE 802.3 clause 45.
  */
 
 #include "efx.h"
 #include "boards.h"
 
-/* Numbering of the MDIO Manageable Devices (MMDs) */
-/* Physical Medium Attachment/ Physical Medium Dependent sublayer */
-#define MDIO_MMD_PMAPMD	(1)
-/* WAN Interface Sublayer */
-#define MDIO_MMD_WIS	(2)
-/* Physical Coding Sublayer */
-#define MDIO_MMD_PCS	(3)
-/* PHY Extender Sublayer */
-#define MDIO_MMD_PHYXS	(4)
-/* Extender Sublayer */
-#define MDIO_MMD_DTEXS	(5)
-/* Transmission convergence */
-#define MDIO_MMD_TC	(6)
-/* Auto negotiation */
-#define MDIO_MMD_AN	(7)
-/* Clause 22 extension */
-#define MDIO_MMD_C22EXT	29
-
-/* Generic register locations */
-#define MDIO_MMDREG_CTRL1	(0)
-#define MDIO_MMDREG_STAT1	(1)
-#define MDIO_MMDREG_IDHI	(2)
-#define MDIO_MMDREG_IDLOW	(3)
-#define MDIO_MMDREG_SPEED	(4)
-#define MDIO_MMDREG_DEVS0	(5)
-#define MDIO_MMDREG_DEVS1	(6)
-#define MDIO_MMDREG_CTRL2	(7)
-#define MDIO_MMDREG_STAT2	(8)
-#define MDIO_MMDREG_TXDIS	(9)
-
-/* Bits in MMDREG_CTRL1 */
-/* Reset */
-#define MDIO_MMDREG_CTRL1_RESET_LBN	(15)
-#define MDIO_MMDREG_CTRL1_RESET_WIDTH	(1)
-/* Loopback */
-/* Loopback bit for WIS, PCS, PHYSX and DTEXS */
-#define MDIO_MMDREG_CTRL1_LBACK_LBN	(14)
-#define MDIO_MMDREG_CTRL1_LBACK_WIDTH	(1)
-/* Low power */
-#define MDIO_MMDREG_CTRL1_LPOWER_LBN	(11)
-#define MDIO_MMDREG_CTRL1_LPOWER_WIDTH	(1)
-
-/* Bits in MMDREG_STAT1 */
-#define MDIO_MMDREG_STAT1_FAULT_LBN	(7)
-#define MDIO_MMDREG_STAT1_FAULT_WIDTH	(1)
-/* Link state */
-#define MDIO_MMDREG_STAT1_LINK_LBN	(2)
-#define MDIO_MMDREG_STAT1_LINK_WIDTH	(1)
-/* Low power ability */
-#define MDIO_MMDREG_STAT1_LPABLE_LBN	(1)
-#define MDIO_MMDREG_STAT1_LPABLE_WIDTH	(1)
-
-/* Bits in combined ID regs */
-static inline unsigned mdio_id_rev(u32 id) { return id & 0xf; }
-static inline unsigned mdio_id_model(u32 id) { return (id >> 4) & 0x3f; }
-extern unsigned mdio_id_oui(u32 id);
-
-/* Bits in MMDREG_DEVS0/1. Someone thoughtfully layed things out
- * so the 'bit present' bit number of an MMD is the number of
- * that MMD */
-#define DEV_PRESENT_BIT(_b) (1 << _b)
-
-#define MDIO_MMDREG_DEVS_PHYXS	DEV_PRESENT_BIT(MDIO_MMD_PHYXS)
-#define MDIO_MMDREG_DEVS_PCS	DEV_PRESENT_BIT(MDIO_MMD_PCS)
-#define MDIO_MMDREG_DEVS_PMAPMD	DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)
-#define MDIO_MMDREG_DEVS_AN	DEV_PRESENT_BIT(MDIO_MMD_AN)
-#define MDIO_MMDREG_DEVS_C22EXT	DEV_PRESENT_BIT(MDIO_MMD_C22EXT)
-
-/* Bits in MMDREG_SPEED */
-#define MDIO_MMDREG_SPEED_10G_LBN	0
-#define MDIO_MMDREG_SPEED_10G_WIDTH	1
-#define MDIO_MMDREG_SPEED_1000M_LBN	4
-#define MDIO_MMDREG_SPEED_1000M_WIDTH	1
-#define MDIO_MMDREG_SPEED_100M_LBN	5
-#define MDIO_MMDREG_SPEED_100M_WIDTH	1
-#define MDIO_MMDREG_SPEED_10M_LBN	6
-#define MDIO_MMDREG_SPEED_10M_WIDTH	1
-
-/* Bits in MMDREG_STAT2 */
-#define MDIO_MMDREG_STAT2_PRESENT_VAL	(2)
-#define MDIO_MMDREG_STAT2_PRESENT_LBN	(14)
-#define MDIO_MMDREG_STAT2_PRESENT_WIDTH (2)
-
-/* Bits in MMDREG_TXDIS */
-#define MDIO_MMDREG_TXDIS_GLOBAL_LBN    (0)
-#define MDIO_MMDREG_TXDIS_GLOBAL_WIDTH  (1)
-
-/* MMD-specific bits, ordered by MMD, then register */
-#define MDIO_PMAPMD_CTRL1_LBACK_LBN	(0)
-#define MDIO_PMAPMD_CTRL1_LBACK_WIDTH	(1)
-
-/* PMA type (4 bits) */
-#define MDIO_PMAPMD_CTRL2_10G_CX4	(0x0)
-#define MDIO_PMAPMD_CTRL2_10G_EW	(0x1)
-#define MDIO_PMAPMD_CTRL2_10G_LW	(0x2)
-#define MDIO_PMAPMD_CTRL2_10G_SW	(0x3)
-#define MDIO_PMAPMD_CTRL2_10G_LX4	(0x4)
-#define MDIO_PMAPMD_CTRL2_10G_ER	(0x5)
-#define MDIO_PMAPMD_CTRL2_10G_LR	(0x6)
-#define MDIO_PMAPMD_CTRL2_10G_SR	(0x7)
-/* Reserved */
-#define MDIO_PMAPMD_CTRL2_10G_BT	(0x9)
-/* Reserved */
-/* Reserved */
-#define MDIO_PMAPMD_CTRL2_1G_BT		(0xc)
-/* Reserved */
-#define MDIO_PMAPMD_CTRL2_100_BT	(0xe)
-#define MDIO_PMAPMD_CTRL2_10_BT		(0xf)
-#define MDIO_PMAPMD_CTRL2_TYPE_MASK	(0xf)
-
-/* PMA 10GBT registers */
-#define MDIO_PMAPMD_10GBT_TXPWR		(131)
-#define MDIO_PMAPMD_10GBT_TXPWR_SHORT_LBN (0)
-#define MDIO_PMAPMD_10GBT_TXPWR_SHORT_WIDTH (1)
-
-/* PHY XGXS Status 2 */
-#define MDIO_PHYXS_STATUS2              (8)
-#define MDIO_PHYXS_STATUS2_RX_FAULT_LBN 10
-
-/* PHY XGXS lane state */
-#define MDIO_PHYXS_LANE_STATE		(0x18)
-#define MDIO_PHYXS_LANE_ALIGNED_LBN	(12)
-
-/* AN registers */
-#define MDIO_AN_CTRL_XNP_LBN		13
-#define MDIO_AN_STATUS			(1)
-#define MDIO_AN_STATUS_XNP_LBN		(7)
-#define MDIO_AN_STATUS_PAGE_LBN		(6)
-#define MDIO_AN_STATUS_AN_DONE_LBN	(5)
-#define MDIO_AN_STATUS_LP_AN_CAP_LBN	(0)
-
-#define MDIO_AN_ADVERTISE		16
-#define MDIO_AN_ADVERTISE_XNP_LBN	12
-#define MDIO_AN_LPA			19
-#define MDIO_AN_XNP			22
-#define MDIO_AN_LPA_XNP			25
-
-#define MDIO_AN_10GBT_CTRL		32
-#define MDIO_AN_10GBT_CTRL_ADV_10G_LBN	12
-#define MDIO_AN_10GBT_STATUS		(33)
-#define MDIO_AN_10GBT_STATUS_MS_FLT_LBN (15) /* MASTER/SLAVE config fault */
-#define MDIO_AN_10GBT_STATUS_MS_LBN     (14) /* MASTER/SLAVE config */
-#define MDIO_AN_10GBT_STATUS_LOC_OK_LBN (13) /* Local OK */
-#define MDIO_AN_10GBT_STATUS_REM_OK_LBN (12) /* Remote OK */
-#define MDIO_AN_10GBT_STATUS_LP_10G_LBN (11) /* Link partner is 10GBT capable */
-#define MDIO_AN_10GBT_STATUS_LP_LTA_LBN (10) /* LP loop timing ability */
-#define MDIO_AN_10GBT_STATUS_LP_TRR_LBN (9)  /* LP Training Reset Request */
+static inline unsigned efx_mdio_id_rev(u32 id) { return id & 0xf; }
+static inline unsigned efx_mdio_id_model(u32 id) { return (id >> 4) & 0x3f; }
+extern unsigned efx_mdio_id_oui(u32 id);
 
-
-/* Packing of the prt and dev arguments of clause 45 style MDIO into a
- * single int so they can be passed into the mdio_read/write functions
- * that currently exist. Note that as Falcon is the only current user,
- * the packed form is chosen to match what Falcon needs to write into
- * a register. This is checked at compile-time so do not change it. If
- * your target chip needs things layed out differently you will need
- * to unpack the arguments in your chip-specific mdio functions.
- */
- /* These are defined by the standard. */
-#define MDIO45_PRT_ID_WIDTH  (5)
-#define MDIO45_DEV_ID_WIDTH  (5)
-
-/* The prt ID is just packed in immediately to the left of the dev ID */
-#define MDIO45_PRT_DEV_WIDTH (MDIO45_PRT_ID_WIDTH + MDIO45_DEV_ID_WIDTH)
-
-#define MDIO45_PRT_ID_MASK   ((1 << MDIO45_PRT_DEV_WIDTH) - 1)
-/* This is the prt + dev extended by 1 bit to hold the 'is clause 45' flag. */
-#define MDIO45_XPRT_ID_WIDTH   (MDIO45_PRT_DEV_WIDTH + 1)
-#define MDIO45_XPRT_ID_MASK   ((1 << MDIO45_XPRT_ID_WIDTH) - 1)
-#define MDIO45_XPRT_ID_IS10G   (1 << (MDIO45_XPRT_ID_WIDTH - 1))
-
-
-#define MDIO45_PRT_ID_COMP_LBN   MDIO45_DEV_ID_WIDTH
-#define MDIO45_PRT_ID_COMP_WIDTH  MDIO45_PRT_ID_WIDTH
-#define MDIO45_DEV_ID_COMP_LBN    0
-#define MDIO45_DEV_ID_COMP_WIDTH  MDIO45_DEV_ID_WIDTH
-
-/* Compose port and device into a phy_id */
-static inline int mdio_clause45_pack(u8 prt, u8 dev)
-{
-	efx_dword_t phy_id;
-	EFX_POPULATE_DWORD_2(phy_id, MDIO45_PRT_ID_COMP, prt,
-			     MDIO45_DEV_ID_COMP, dev);
-	return MDIO45_XPRT_ID_IS10G | EFX_DWORD_VAL(phy_id);
-}
-
-static inline void mdio_clause45_unpack(u32 val, u8 *prt, u8 *dev)
+static inline int efx_mdio_read(struct efx_nic *efx, int devad, int addr)
 {
-	efx_dword_t phy_id;
-	EFX_POPULATE_DWORD_1(phy_id, EFX_DWORD_0, val);
-	*prt = EFX_DWORD_FIELD(phy_id, MDIO45_PRT_ID_COMP);
-	*dev = EFX_DWORD_FIELD(phy_id, MDIO45_DEV_ID_COMP);
+	return efx->mdio.mdio_read(efx->net_dev, efx->mdio.prtad, devad, addr);
 }
 
-static inline int mdio_clause45_read(struct efx_nic *efx,
-				     u8 prt, u8 dev, u16 addr)
+static inline void
+efx_mdio_write(struct efx_nic *efx, int devad, int addr, int value)
 {
-	return efx->mii.mdio_read(efx->net_dev,
-				  mdio_clause45_pack(prt, dev), addr);
+	efx->mdio.mdio_write(efx->net_dev, efx->mdio.prtad, devad, addr, value);
 }
 
-static inline void mdio_clause45_write(struct efx_nic *efx,
-				       u8 prt, u8 dev, u16 addr, int value)
-{
-	efx->mii.mdio_write(efx->net_dev,
-			    mdio_clause45_pack(prt, dev), addr, value);
-}
-
-
-static inline u32 mdio_clause45_read_id(struct efx_nic *efx, int mmd)
+static inline u32 efx_mdio_read_id(struct efx_nic *efx, int mmd)
 {
-	int phy_id = efx->mii.phy_id;
-	u16 id_low = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_IDLOW);
-	u16 id_hi = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_IDHI);
+	u16 id_low = efx_mdio_read(efx, mmd, MDIO_DEVID2);
+	u16 id_hi = efx_mdio_read(efx, mmd, MDIO_DEVID1);
 	return (id_hi << 16) | (id_low);
 }
 
-static inline bool mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx)
+static inline bool efx_mdio_phyxgxs_lane_sync(struct efx_nic *efx)
 {
 	int i, lane_status;
 	bool sync;
 
 	for (i = 0; i < 2; ++i)
-		lane_status = mdio_clause45_read(efx, efx->mii.phy_id,
-						 MDIO_MMD_PHYXS,
-						 MDIO_PHYXS_LANE_STATE);
+		lane_status = efx_mdio_read(efx, MDIO_MMD_PHYXS,
+					    MDIO_PHYXS_LNSTAT);
 
-	sync = !!(lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN));
+	sync = !!(lane_status & MDIO_PHYXS_LNSTAT_ALIGN);
 	if (!sync)
 		EFX_LOG(efx, "XGXS lane status: %x\n", lane_status);
 	return sync;
 }
 
-extern const char *mdio_clause45_mmd_name(int mmd);
+extern const char *efx_mdio_mmd_name(int mmd);
 
 /*
  * Reset a specific MMD and wait for reset to clear.
@@ -258,54 +64,47 @@ extern const char *mdio_clause45_mmd_name(int mmd);
  *
  * This function will sleep
  */
-extern int mdio_clause45_reset_mmd(struct efx_nic *efx, int mmd,
-				   int spins, int spintime);
+extern int efx_mdio_reset_mmd(struct efx_nic *efx, int mmd,
+			      int spins, int spintime);
 
-/* As mdio_clause45_check_mmd but for multiple MMDs */
-int mdio_clause45_check_mmds(struct efx_nic *efx,
-			     unsigned int mmd_mask, unsigned int fatal_mask);
+/* As efx_mdio_check_mmd but for multiple MMDs */
+int efx_mdio_check_mmds(struct efx_nic *efx,
+			unsigned int mmd_mask, unsigned int fatal_mask);
 
 /* Check the link status of specified mmds in bit mask */
-extern bool mdio_clause45_links_ok(struct efx_nic *efx,
-				   unsigned int mmd_mask);
+extern bool efx_mdio_links_ok(struct efx_nic *efx, unsigned int mmd_mask);
 
 /* Generic transmit disable support though PMAPMD */
-extern void mdio_clause45_transmit_disable(struct efx_nic *efx);
+extern void efx_mdio_transmit_disable(struct efx_nic *efx);
 
 /* Generic part of reconfigure: set/clear loopback bits */
-extern void mdio_clause45_phy_reconfigure(struct efx_nic *efx);
+extern void efx_mdio_phy_reconfigure(struct efx_nic *efx);
 
 /* Set the power state of the specified MMDs */
-extern void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
-					  int low_power, unsigned int mmd_mask);
-
-/* Read (some of) the PHY settings over MDIO */
-extern void mdio_clause45_get_settings(struct efx_nic *efx,
-				       struct ethtool_cmd *ecmd);
-
-/* Read (some of) the PHY settings over MDIO */
-extern void
-mdio_clause45_get_settings_ext(struct efx_nic *efx, struct ethtool_cmd *ecmd,
-			       u32 xnp, u32 xnp_lpa);
+extern void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
+				     int low_power, unsigned int mmd_mask);
 
 /* Set (some of) the PHY settings over MDIO */
-extern int mdio_clause45_set_settings(struct efx_nic *efx,
-				      struct ethtool_cmd *ecmd);
+extern int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd);
 
 /* Set pause parameters to be advertised through AN (if available) */
-extern void mdio_clause45_set_pause(struct efx_nic *efx);
+extern void efx_mdio_set_pause(struct efx_nic *efx);
 
 /* Get pause parameters from AN if available (otherwise return
  * requested pause parameters)
  */
-enum efx_fc_type mdio_clause45_get_pause(struct efx_nic *efx);
+enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx);
 
 /* Wait for specified MMDs to exit reset within a timeout */
-extern int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
-					 unsigned int mmd_mask);
+extern int efx_mdio_wait_reset_mmds(struct efx_nic *efx,
+				    unsigned int mmd_mask);
 
 /* Set or clear flag, debouncing */
-extern void mdio_clause45_set_flag(struct efx_nic *efx, u8 prt, u8 dev,
-				   u16 addr, int bit, bool sense);
+static inline void
+efx_mdio_set_flag(struct efx_nic *efx, int devad, int addr,
+		  int mask, bool state)
+{
+	mdio_set_flag(&efx->mdio, efx->mdio.prtad, devad, addr, mask, state);
+}
 
 #endif /* EFX_MDIO_10G_H */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e169e5d..457e2f1 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -19,7 +19,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/timer.h>
-#include <linux/mii.h>
+#include <linux/mdio.h>
 #include <linux/list.h>
 #include <linux/pci.h>
 #include <linux/device.h>
@@ -458,8 +458,6 @@ enum phy_type {
 	PHY_TYPE_MAX	/* Insert any new items before this */
 };
 
-#define PHY_ADDR_INVALID 0xff
-
 #define EFX_IS10G(efx) ((efx)->link_speed == 10000)
 
 enum nic_state {
@@ -758,7 +756,7 @@ union efx_multicast_hash {
  * @phy_lock: PHY access lock
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
- * @mii: PHY interface
+ * @mdio: PHY MDIO interface
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
  * @mac_up: MAC link state
  * @link_up: Link status
@@ -845,7 +843,7 @@ struct efx_nic {
 	struct work_struct phy_work;
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
-	struct mii_if_info mii;
+	struct mdio_if_info mdio;
 	enum efx_phy_mode phy_mode;
 
 	bool mac_up;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 0a59808..0437957 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -80,39 +80,38 @@ struct efx_loopback_state {
  *
  **************************************************************************/
 
-static int efx_test_mii(struct efx_nic *efx, struct efx_self_tests *tests)
+static int efx_test_mdio(struct efx_nic *efx, struct efx_self_tests *tests)
 {
 	int rc = 0;
+	int devad = __ffs(efx->mdio.mmds);
 	u16 physid1, physid2;
-	struct mii_if_info *mii = &efx->mii;
-	struct net_device *net_dev = efx->net_dev;
 
 	if (efx->phy_type == PHY_TYPE_NONE)
 		return 0;
 
 	mutex_lock(&efx->mac_lock);
-	tests->mii = -1;
+	tests->mdio = -1;
 
-	physid1 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID1);
-	physid2 = mii->mdio_read(net_dev, mii->phy_id, MII_PHYSID2);
+	physid1 = efx_mdio_read(efx, devad, MDIO_DEVID1);
+	physid2 = efx_mdio_read(efx, devad, MDIO_DEVID2);
 
 	if ((physid1 == 0x0000) || (physid1 == 0xffff) ||
 	    (physid2 == 0x0000) || (physid2 == 0xffff)) {
-		EFX_ERR(efx, "no MII PHY present with ID %d\n",
-			mii->phy_id);
+		EFX_ERR(efx, "no MDIO PHY present with ID %d\n",
+			efx->mdio.prtad);
 		rc = -EINVAL;
 		goto out;
 	}
 
 	if (EFX_IS10G(efx)) {
-		rc = mdio_clause45_check_mmds(efx, efx->phy_op->mmds, 0);
+		rc = efx_mdio_check_mmds(efx, efx->phy_op->mmds, 0);
 		if (rc)
 			goto out;
 	}
 
 out:
 	mutex_unlock(&efx->mac_lock);
-	tests->mii = rc ? -1 : 1;
+	tests->mdio = rc ? -1 : 1;
 	return rc;
 }
 
@@ -673,7 +672,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* Online (i.e. non-disruptive) testing
 	 * This checks interrupt generation, event delivery and PHY presence. */
 
-	rc = efx_test_mii(efx, tests);
+	rc = efx_test_mdio(efx, tests);
 	if (rc && !rc_test)
 		rc_test = rc;
 
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index 39451cf..f6feee0 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -32,7 +32,7 @@ struct efx_loopback_self_tests {
  */
 struct efx_self_tests {
 	/* online tests */
-	int mii;
+	int mdio;
 	int nvram;
 	int interrupt;
 	int eventq_dma[EFX_MAX_CHANNELS];
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index e61dc4d..403f7d7 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -23,10 +23,10 @@
  * clause 22 extension MMD, but since it doesn't have all the generic
  * MMD registers it is pointless to include it here.
  */
-#define TENXPRESS_REQUIRED_DEVS (MDIO_MMDREG_DEVS_PMAPMD	| \
-				 MDIO_MMDREG_DEVS_PCS		| \
-				 MDIO_MMDREG_DEVS_PHYXS		| \
-				 MDIO_MMDREG_DEVS_AN)
+#define TENXPRESS_REQUIRED_DEVS (MDIO_DEVS_PMAPMD	| \
+				 MDIO_DEVS_PCS		| \
+				 MDIO_DEVS_PHYXS	| \
+				 MDIO_DEVS_AN)
 
 #define SFX7101_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
 			   (1 << LOOPBACK_PCS) |	\
@@ -153,10 +153,6 @@
 #define LOOPBACK_NEAR_LBN   (8)
 #define LOOPBACK_NEAR_WIDTH (1)
 
-#define PCS_10GBASET_STAT1       32
-#define PCS_10GBASET_BLKLK_LBN   0
-#define PCS_10GBASET_BLKLK_WIDTH 1
-
 /* Boot status register */
 #define PCS_BOOT_STATUS_REG		53248
 #define PCS_BOOT_FATAL_ERROR_LBN	0
@@ -206,10 +202,8 @@ static ssize_t show_phy_short_reach(struct device *dev,
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 	int reg;
 
-	reg = mdio_clause45_read(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-				 MDIO_PMAPMD_10GBT_TXPWR);
-	return sprintf(buf, "%d\n",
-		       !!(reg & (1 << MDIO_PMAPMD_10GBT_TXPWR_SHORT_LBN)));
+	reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_PMA_10GBT_TXPWR);
+	return sprintf(buf, "%d\n", !!(reg & MDIO_PMA_10GBT_TXPWR_SHORT));
 }
 
 static ssize_t set_phy_short_reach(struct device *dev,
@@ -219,10 +213,9 @@ static ssize_t set_phy_short_reach(struct device *dev,
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 
 	rtnl_lock();
-	mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			       MDIO_PMAPMD_10GBT_TXPWR,
-			       MDIO_PMAPMD_10GBT_TXPWR_SHORT_LBN,
-			       count != 0 && *buf != '0');
+	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_PMA_10GBT_TXPWR,
+			  MDIO_PMA_10GBT_TXPWR_SHORT,
+			  count != 0 && *buf != '0');
 	efx_reconfigure_port(efx);
 	rtnl_unlock();
 
@@ -238,9 +231,8 @@ int sft9001_wait_boot(struct efx_nic *efx)
 	int boot_stat;
 
 	for (;;) {
-		boot_stat = mdio_clause45_read(efx, efx->mii.phy_id,
-					       MDIO_MMD_PCS,
-					       PCS_BOOT_STATUS_REG);
+		boot_stat = efx_mdio_read(efx, MDIO_MMD_PCS,
+					  PCS_BOOT_STATUS_REG);
 		if (boot_stat >= 0) {
 			EFX_LOG(efx, "PHY boot status = %#x\n", boot_stat);
 			switch (boot_stat &
@@ -286,38 +278,32 @@ int sft9001_wait_boot(struct efx_nic *efx)
 
 static int tenxpress_init(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
 	int reg;
 
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
 		/* Enable 312.5 MHz clock */
-		mdio_clause45_write(efx, phy_id,
-				    MDIO_MMD_PCS, PCS_TEST_SELECT_REG,
-				    1 << CLK312_EN_LBN);
+		efx_mdio_write(efx, MDIO_MMD_PCS, PCS_TEST_SELECT_REG,
+			       1 << CLK312_EN_LBN);
 	} else {
 		/* Enable 312.5 MHz clock and GMII */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-					 PMA_PMD_XCONTROL_REG);
+		reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
 		reg |= ((1 << PMA_PMD_EXT_GMII_EN_LBN) |
 			(1 << PMA_PMD_EXT_CLK_OUT_LBN) |
 			(1 << PMA_PMD_EXT_CLK312_LBN) |
 			(1 << PMA_PMD_EXT_ROBUST_LBN));
 
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-				    PMA_PMD_XCONTROL_REG, reg);
-		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
-				       GPHY_XCONTROL_REG, GPHY_ISOLATE_LBN,
-				       false);
+		efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
+		efx_mdio_set_flag(efx, MDIO_MMD_C22EXT,
+			      GPHY_XCONTROL_REG, 1 << GPHY_ISOLATE_LBN,
+			      false);
 	}
 
 	/* Set the LEDs up as: Green = Link, Amber = Link/Act, Red = Off */
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
-		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PMAPMD,
-				       PMA_PMD_LED_CTRL_REG,
-				       PMA_PMA_LED_ACTIVITY_LBN,
-				       true);
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-				    PMA_PMD_LED_OVERR_REG, PMA_PMD_LED_DEFAULT);
+		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG,
+				  1 << PMA_PMA_LED_ACTIVITY_LBN, true);
+		efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG,
+			       PMA_PMD_LED_DEFAULT);
 	}
 
 	return 0;
@@ -337,22 +323,19 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	if (!(efx->phy_mode & PHY_MODE_SPECIAL)) {
 		if (efx->phy_type == PHY_TYPE_SFT9001A) {
 			int reg;
-			reg = mdio_clause45_read(efx, efx->mii.phy_id,
-						 MDIO_MMD_PMAPMD,
-						 PMA_PMD_XCONTROL_REG);
+			reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD,
+					    PMA_PMD_XCONTROL_REG);
 			reg |= (1 << PMA_PMD_EXT_SSR_LBN);
-			mdio_clause45_write(efx, efx->mii.phy_id,
-					    MDIO_MMD_PMAPMD,
-					    PMA_PMD_XCONTROL_REG, reg);
+			efx_mdio_write(efx, MDIO_MMD_PMAPMD,
+				       PMA_PMD_XCONTROL_REG, reg);
 			mdelay(200);
 		}
 
-		rc = mdio_clause45_wait_reset_mmds(efx,
-						   TENXPRESS_REQUIRED_DEVS);
+		rc = efx_mdio_wait_reset_mmds(efx, TENXPRESS_REQUIRED_DEVS);
 		if (rc < 0)
 			goto fail;
 
-		rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
+		rc = efx_mdio_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
 		if (rc < 0)
 			goto fail;
 	}
@@ -360,7 +343,7 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	rc = tenxpress_init(efx);
 	if (rc < 0)
 		goto fail;
-	mdio_clause45_set_pause(efx);
+	efx_mdio_set_pause(efx);
 
 	if (efx->phy_type == PHY_TYPE_SFT9001B) {
 		rc = device_create_file(&efx->pci_dev->dev,
@@ -395,17 +378,14 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 	efx_stats_disable(efx);
 
 	/* Initiate reset */
-	reg = mdio_clause45_read(efx, efx->mii.phy_id,
-				 MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
+	reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
 	reg |= (1 << PMA_PMD_EXT_SSR_LBN);
-	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_XCONTROL_REG, reg);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
 
 	mdelay(200);
 
 	/* Wait for the blocks to come out of reset */
-	rc = mdio_clause45_wait_reset_mmds(efx,
-					   TENXPRESS_REQUIRED_DEVS);
+	rc = efx_mdio_wait_reset_mmds(efx, TENXPRESS_REQUIRED_DEVS);
 	if (rc < 0)
 		goto out;
 
@@ -424,7 +404,6 @@ out:
 static void sfx7101_check_bad_lp(struct efx_nic *efx, bool link_ok)
 {
 	struct tenxpress_phy_data *pd = efx->phy_data;
-	int phy_id = efx->mii.phy_id;
 	bool bad_lp;
 	int reg;
 
@@ -432,11 +411,10 @@ static void sfx7101_check_bad_lp(struct efx_nic *efx, bool link_ok)
 		bad_lp = false;
 	} else {
 		/* Check that AN has started but not completed. */
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-					 MDIO_AN_STATUS);
-		if (!(reg & (1 << MDIO_AN_STATUS_LP_AN_CAP_LBN)))
+		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_STAT1);
+		if (!(reg & MDIO_AN_STAT1_LPABLE))
 			return; /* LP status is unknown */
-		bad_lp = !(reg & (1 << MDIO_AN_STATUS_AN_DONE_LBN));
+		bad_lp = !(reg & MDIO_AN_STAT1_COMPLETE);
 		if (bad_lp)
 			pd->bad_lp_tries++;
 	}
@@ -448,8 +426,8 @@ static void sfx7101_check_bad_lp(struct efx_nic *efx, bool link_ok)
 	/* Use the RX (red) LED as an error indicator once we've seen AN
 	 * failure several times in a row, and also log a message. */
 	if (!bad_lp || pd->bad_lp_tries == MAX_BAD_LP_TRIES) {
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-					 PMA_PMD_LED_OVERR_REG);
+		reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD,
+				    PMA_PMD_LED_OVERR_REG);
 		reg &= ~(PMA_PMD_LED_MASK << PMA_PMD_LED_RX_LBN);
 		if (!bad_lp) {
 			reg |= PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN;
@@ -460,23 +438,22 @@ static void sfx7101_check_bad_lp(struct efx_nic *efx, bool link_ok)
 				" supports 10GBASE-T ONLY, so no link can"
 				" be established\n");
 		}
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-				    PMA_PMD_LED_OVERR_REG, reg);
+		efx_mdio_write(efx, MDIO_MMD_PMAPMD,
+			       PMA_PMD_LED_OVERR_REG, reg);
 		pd->bad_lp_tries = bad_lp;
 	}
 }
 
 static bool sfx7101_link_ok(struct efx_nic *efx)
 {
-	return mdio_clause45_links_ok(efx,
-				      MDIO_MMDREG_DEVS_PMAPMD |
-				      MDIO_MMDREG_DEVS_PCS |
-				      MDIO_MMDREG_DEVS_PHYXS);
+	return efx_mdio_links_ok(efx,
+				 MDIO_DEVS_PMAPMD |
+				 MDIO_DEVS_PCS |
+				 MDIO_DEVS_PHYXS);
 }
 
 static bool sft9001_link_ok(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	int phy_id = efx->mii.phy_id;
 	u32 reg;
 
 	if (efx_phy_mode_disabled(efx->phy_mode))
@@ -484,50 +461,43 @@ static bool sft9001_link_ok(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	else if (efx->loopback_mode == LOOPBACK_GPHY)
 		return true;
 	else if (efx->loopback_mode)
-		return mdio_clause45_links_ok(efx,
-					      MDIO_MMDREG_DEVS_PMAPMD |
-					      MDIO_MMDREG_DEVS_PHYXS);
+		return efx_mdio_links_ok(efx,
+					 MDIO_DEVS_PMAPMD |
+					 MDIO_DEVS_PHYXS);
 
 	/* We must use the same definition of link state as LASI,
 	 * otherwise we can miss a link state transition
 	 */
 	if (ecmd->speed == 10000) {
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
-					 PCS_10GBASET_STAT1);
-		return reg & (1 << PCS_10GBASET_BLKLK_LBN);
+		reg = efx_mdio_read(efx, MDIO_MMD_PCS, MDIO_PCS_10GBRT_STAT1);
+		return reg & MDIO_PCS_10GBRT_STAT1_BLKLK;
 	} else {
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
-					 C22EXT_STATUS_REG);
+		reg = efx_mdio_read(efx, MDIO_MMD_C22EXT, C22EXT_STATUS_REG);
 		return reg & (1 << C22EXT_STATUS_LINK_LBN);
 	}
 }
 
 static void tenxpress_ext_loopback(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
-
-	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PHYXS,
-			       PHYXS_TEST1, LOOPBACK_NEAR_LBN,
-			       efx->loopback_mode == LOOPBACK_PHYXS);
+	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS, PHYXS_TEST1,
+			  1 << LOOPBACK_NEAR_LBN,
+			  efx->loopback_mode == LOOPBACK_PHYXS);
 	if (efx->phy_type != PHY_TYPE_SFX7101)
-		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
-				       GPHY_XCONTROL_REG,
-				       GPHY_LOOPBACK_NEAR_LBN,
-				       efx->loopback_mode == LOOPBACK_GPHY);
+		efx_mdio_set_flag(efx, MDIO_MMD_C22EXT, GPHY_XCONTROL_REG,
+				  1 << GPHY_LOOPBACK_NEAR_LBN,
+				  efx->loopback_mode == LOOPBACK_GPHY);
 }
 
 static void tenxpress_low_power(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
-
 	if (efx->phy_type == PHY_TYPE_SFX7101)
-		mdio_clause45_set_mmds_lpower(
+		efx_mdio_set_mmds_lpower(
 			efx, !!(efx->phy_mode & PHY_MODE_LOW_POWER),
 			TENXPRESS_REQUIRED_DEVS);
 	else
-		mdio_clause45_set_flag(
-			efx, phy_id, MDIO_MMD_PMAPMD,
-			PMA_PMD_XCONTROL_REG, PMA_PMD_EXT_LPOWER_LBN,
+		efx_mdio_set_flag(
+			efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG,
+			1 << PMA_PMD_EXT_LPOWER_LBN,
 			!!(efx->phy_mode & PHY_MODE_LOW_POWER));
 }
 
@@ -568,8 +538,8 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 		WARN_ON(rc);
 	}
 
-	mdio_clause45_transmit_disable(efx);
-	mdio_clause45_phy_reconfigure(efx);
+	efx_mdio_transmit_disable(efx);
+	efx_mdio_phy_reconfigure(efx);
 	tenxpress_ext_loopback(efx);
 
 	phy_data->loopback_mode = efx->loopback_mode;
@@ -585,7 +555,7 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 		efx->link_fd = ecmd.duplex == DUPLEX_FULL;
 		efx->link_up = sft9001_link_ok(efx, &ecmd);
 	}
-	efx->link_fc = mdio_clause45_get_pause(efx);
+	efx->link_fc = efx_mdio_get_pause(efx);
 }
 
 /* Poll PHY for interrupt */
@@ -599,7 +569,7 @@ static void tenxpress_phy_poll(struct efx_nic *efx)
 		if (link_ok != efx->link_up) {
 			change = true;
 		} else {
-			unsigned int link_fc = mdio_clause45_get_pause(efx);
+			unsigned int link_fc = efx_mdio_get_pause(efx);
 			if (link_fc != efx->link_fc)
 				change = true;
 		}
@@ -609,9 +579,8 @@ static void tenxpress_phy_poll(struct efx_nic *efx)
 		if (link_ok != efx->link_up)
 			change = true;
 	} else {
-		u32 status = mdio_clause45_read(efx, efx->mii.phy_id,
-						MDIO_MMD_PMAPMD,
-						PMA_PMD_LASI_STATUS);
+		int status = efx_mdio_read(efx, MDIO_MMD_PMAPMD,
+					   PMA_PMD_LASI_STATUS);
 		if (status & (1 << PMA_PMD_LS_ALARM_LBN))
 			change = true;
 	}
@@ -634,8 +603,7 @@ static void tenxpress_phy_fini(struct efx_nic *efx)
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
 		/* Power down the LNPGA */
 		reg = (1 << PMA_PMD_LNPGA_POWERDOWN_LBN);
-		mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-				    PMA_PMD_XCONTROL_REG, reg);
+		efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
 
 		/* Waiting here ensures that the board fini, which can turn
 		 * off the power to the PHY, won't get run until the LNPGA
@@ -661,8 +629,7 @@ void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 	else
 		reg = PMA_PMD_LED_DEFAULT;
 
-	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_LED_OVERR_REG, reg);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG, reg);
 }
 
 static const char *const sfx7101_test_names[] = {
@@ -698,7 +665,6 @@ static const char *const sft9001_test_names[] = {
 static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 {
 	struct ethtool_cmd ecmd;
-	int phy_id = efx->mii.phy_id;
 	int rc = 0, rc2, i, ctrl_reg, res_reg;
 
 	if (flags & ETH_TEST_FL_OFFLINE)
@@ -717,11 +683,10 @@ static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 		 * must reset the PHY to resume normal service. */
 		ctrl_reg |= (1 << CDIAG_CTRL_BRK_LINK_LBN);
 	}
-	mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_CDIAG_CTRL_REG, ctrl_reg);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_CDIAG_CTRL_REG,
+		       ctrl_reg);
 	i = 0;
-	while (mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-				  PMA_PMD_CDIAG_CTRL_REG) &
+	while (efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_CDIAG_CTRL_REG) &
 	       (1 << CDIAG_CTRL_IN_PROG_LBN)) {
 		if (++i == 50) {
 			rc = -ETIMEDOUT;
@@ -729,15 +694,13 @@ static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 		}
 		msleep(100);
 	}
-	res_reg = mdio_clause45_read(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-				     PMA_PMD_CDIAG_RES_REG);
+	res_reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_CDIAG_RES_REG);
 	for (i = 0; i < 4; i++) {
 		int pair_res =
 			(res_reg >> (CDIAG_RES_A_LBN - i * CDIAG_RES_WIDTH))
 			& ((1 << CDIAG_RES_WIDTH) - 1);
-		int len_reg = mdio_clause45_read(efx, efx->mii.phy_id,
-						 MDIO_MMD_PMAPMD,
-						 PMA_PMD_CDIAG_LEN_REG + i);
+		int len_reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD,
+					    PMA_PMD_CDIAG_LEN_REG + i);
 		if (pair_res == CDIAG_RES_OK)
 			results[1 + i] = 1;
 		else if (pair_res == CDIAG_RES_INVALID)
@@ -769,32 +732,27 @@ out:
 static void
 tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	int phy_id = efx->mii.phy_id;
 	u32 adv = 0, lpa = 0;
 	int reg;
 
 	if (efx->phy_type != PHY_TYPE_SFX7101) {
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
-					 C22EXT_MSTSLV_CTRL);
+		reg = efx_mdio_read(efx, MDIO_MMD_C22EXT, C22EXT_MSTSLV_CTRL);
 		if (reg & (1 << C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN))
 			adv |= ADVERTISED_1000baseT_Full;
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
-					 C22EXT_MSTSLV_STATUS);
+		reg = efx_mdio_read(efx, MDIO_MMD_C22EXT, C22EXT_MSTSLV_STATUS);
 		if (reg & (1 << C22EXT_MSTSLV_STATUS_LP_1000_HD_LBN))
 			lpa |= ADVERTISED_1000baseT_Half;
 		if (reg & (1 << C22EXT_MSTSLV_STATUS_LP_1000_FD_LBN))
 			lpa |= ADVERTISED_1000baseT_Full;
 	}
-	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-				 MDIO_AN_10GBT_CTRL);
-	if (reg & (1 << MDIO_AN_10GBT_CTRL_ADV_10G_LBN))
+	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL);
+	if (reg & MDIO_AN_10GBT_CTRL_ADV10G)
 		adv |= ADVERTISED_10000baseT_Full;
-	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-				 MDIO_AN_10GBT_STATUS);
-	if (reg & (1 << MDIO_AN_10GBT_STATUS_LP_10G_LBN))
+	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_10GBT_STAT);
+	if (reg & MDIO_AN_10GBT_STAT_LP10G)
 		lpa |= ADVERTISED_10000baseT_Full;
 
-	mdio_clause45_get_settings_ext(efx, ecmd, adv, lpa);
+	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
 
 	if (efx->phy_type != PHY_TYPE_SFX7101)
 		ecmd->supported |= (SUPPORTED_100baseT_Full |
@@ -813,29 +771,24 @@ static int tenxpress_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	if (!ecmd->autoneg)
 		return -EINVAL;
 
-	return mdio_clause45_set_settings(efx, ecmd);
+	return efx_mdio_set_settings(efx, ecmd);
 }
 
 static void sfx7101_set_npage_adv(struct efx_nic *efx, u32 advertising)
 {
-	mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_AN,
-			       MDIO_AN_10GBT_CTRL,
-			       MDIO_AN_10GBT_CTRL_ADV_10G_LBN,
-			       advertising & ADVERTISED_10000baseT_Full);
+	efx_mdio_set_flag(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL,
+			  MDIO_AN_10GBT_CTRL_ADV10G,
+			  advertising & ADVERTISED_10000baseT_Full);
 }
 
 static void sft9001_set_npage_adv(struct efx_nic *efx, u32 advertising)
 {
-	int phy_id = efx->mii.phy_id;
-
-	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
-			       C22EXT_MSTSLV_CTRL,
-			       C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN,
-			       advertising & ADVERTISED_1000baseT_Full);
-	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_AN,
-			       MDIO_AN_10GBT_CTRL,
-			       MDIO_AN_10GBT_CTRL_ADV_10G_LBN,
-			       advertising & ADVERTISED_10000baseT_Full);
+	efx_mdio_set_flag(efx, MDIO_MMD_C22EXT, C22EXT_MSTSLV_CTRL,
+			  1 << C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN,
+			  advertising & ADVERTISED_1000baseT_Full);
+	efx_mdio_set_flag(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL,
+			  MDIO_AN_10GBT_CTRL_ADV10G,
+			  advertising & ADVERTISED_10000baseT_Full);
 }
 
 struct efx_phy_operations falcon_sfx7101_phy_ops = {
diff --git a/drivers/net/sfc/xenpack.h b/drivers/net/sfc/xenpack.h
index b0d1f22..4e52286 100644
--- a/drivers/net/sfc/xenpack.h
+++ b/drivers/net/sfc/xenpack.h
@@ -34,29 +34,24 @@
 /* Enable LASI interrupts for PHY */
 static inline void xenpack_enable_lasi_irqs(struct efx_nic *efx)
 {
-	int reg;
-	int phy_id = efx->mii.phy_id;
 	/* Read to clear LASI status register */
-	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-				 MDIO_XP_LASI_STAT);
+	efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_STAT);
 
-	mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-			    MDIO_XP_LASI_CTRL, XP_LASI_LS_ALARM);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_CTRL,
+		       XP_LASI_LS_ALARM);
 }
 
 /* Read the LASI interrupt status to clear the interrupt. */
 static inline int xenpack_clear_lasi_irqs(struct efx_nic *efx)
 {
 	/* Read to clear link status alarm */
-	return mdio_clause45_read(efx, efx->mii.phy_id,
-				  MDIO_MMD_PMAPMD, MDIO_XP_LASI_STAT);
+	return efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_STAT);
 }
 
 /* Turn off LASI interrupts */
 static inline void xenpack_disable_lasi_irqs(struct efx_nic *efx)
 {
-	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    MDIO_XP_LASI_CTRL, 0);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_XP_LASI_CTRL, 0);
 }
 
 #endif /* EFX_XENPACK_H */
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index bb1ef77..aad2dca 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -19,9 +19,9 @@
 #include "phy.h"
 #include "falcon.h"
 
-#define XFP_REQUIRED_DEVS (MDIO_MMDREG_DEVS_PCS |	\
-			   MDIO_MMDREG_DEVS_PMAPMD |	\
-			   MDIO_MMDREG_DEVS_PHYXS)
+#define XFP_REQUIRED_DEVS (MDIO_DEVS_PCS |	\
+			   MDIO_DEVS_PMAPMD |	\
+			   MDIO_DEVS_PHYXS)
 
 #define XFP_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
 		       (1 << LOOPBACK_PMAPMD) |		\
@@ -49,8 +49,7 @@
 void xfp_set_led(struct efx_nic *p, int led, int mode)
 {
 	int addr = MDIO_QUAKE_LED0_REG + led;
-	mdio_clause45_write(p, p->mii.phy_id, MDIO_MMD_PMAPMD, addr,
-			    mode);
+	efx_mdio_write(p, MDIO_MMD_PMAPMD, addr, mode);
 }
 
 struct xfp_phy_data {
@@ -63,14 +62,12 @@ struct xfp_phy_data {
 static int qt2025c_wait_reset(struct efx_nic *efx)
 {
 	unsigned long timeout = jiffies + 10 * HZ;
-	int phy_id = efx->mii.phy_id;
 	int reg, old_counter = 0;
 
 	/* Wait for firmware heartbeat to start */
 	for (;;) {
 		int counter;
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
-					 PCS_FW_HEARTBEAT_REG);
+		reg = efx_mdio_read(efx, MDIO_MMD_PCS, PCS_FW_HEARTBEAT_REG);
 		if (reg < 0)
 			return reg;
 		counter = ((reg >> PCS_FW_HEARTB_LBN) &
@@ -86,8 +83,7 @@ static int qt2025c_wait_reset(struct efx_nic *efx)
 
 	/* Wait for firmware status to look good */
 	for (;;) {
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
-					 PCS_UC8051_STATUS_REG);
+		reg = efx_mdio_read(efx, MDIO_MMD_PCS, PCS_UC8051_STATUS_REG);
 		if (reg < 0)
 			return reg;
 		if ((reg &
@@ -109,9 +105,9 @@ static int xfp_reset_phy(struct efx_nic *efx)
 {
 	int rc;
 
-	rc = mdio_clause45_reset_mmd(efx, MDIO_MMD_PHYXS,
-				     XFP_MAX_RESET_TIME / XFP_RESET_WAIT,
-				     XFP_RESET_WAIT);
+	rc = efx_mdio_reset_mmd(efx, MDIO_MMD_PHYXS,
+				XFP_MAX_RESET_TIME / XFP_RESET_WAIT,
+				XFP_RESET_WAIT);
 	if (rc < 0)
 		goto fail;
 
@@ -126,8 +122,7 @@ static int xfp_reset_phy(struct efx_nic *efx)
 
 	/* Check that all the MMDs we expect are present and responding. We
 	 * expect faults on some if the link is down, but not on the PHY XS */
-	rc = mdio_clause45_check_mmds(efx, XFP_REQUIRED_DEVS,
-				      MDIO_MMDREG_DEVS_PHYXS);
+	rc = efx_mdio_check_mmds(efx, XFP_REQUIRED_DEVS, MDIO_DEVS_PHYXS);
 	if (rc < 0)
 		goto fail;
 
@@ -143,7 +138,7 @@ static int xfp_reset_phy(struct efx_nic *efx)
 static int xfp_phy_init(struct efx_nic *efx)
 {
 	struct xfp_phy_data *phy_data;
-	u32 devid = mdio_clause45_read_id(efx, MDIO_MMD_PHYXS);
+	u32 devid = efx_mdio_read_id(efx, MDIO_MMD_PHYXS);
 	int rc;
 
 	phy_data = kzalloc(sizeof(struct xfp_phy_data), GFP_KERNEL);
@@ -152,8 +147,8 @@ static int xfp_phy_init(struct efx_nic *efx)
 	efx->phy_data = phy_data;
 
 	EFX_INFO(efx, "PHY ID reg %x (OUI %06x model %02x revision %x)\n",
-		 devid, mdio_id_oui(devid), mdio_id_model(devid),
-		 mdio_id_rev(devid));
+		 devid, efx_mdio_id_oui(devid), efx_mdio_id_model(devid),
+		 efx_mdio_id_rev(devid));
 
 	phy_data->phy_mode = efx->phy_mode;
 
@@ -179,7 +174,7 @@ static void xfp_phy_clear_interrupt(struct efx_nic *efx)
 
 static int xfp_link_ok(struct efx_nic *efx)
 {
-	return mdio_clause45_links_ok(efx, XFP_REQUIRED_DEVS);
+	return efx_mdio_links_ok(efx, XFP_REQUIRED_DEVS);
 }
 
 static void xfp_phy_poll(struct efx_nic *efx)
@@ -200,9 +195,9 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 		 * or optical transceivers, varying somewhat between
 		 * firmware versions.  Only 'static mode' appears to
 		 * cover everything. */
-		mdio_clause45_set_flag(
-			efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			PMA_PMD_FTX_CTRL2_REG, PMA_PMD_FTX_STATIC_LBN,
+		mdio_set_flag(
+			&efx->mdio, efx->mdio.prtad, MDIO_MMD_PMAPMD,
+			PMA_PMD_FTX_CTRL2_REG, 1 << PMA_PMD_FTX_STATIC_LBN,
 			efx->phy_mode & PHY_MODE_TX_DISABLED ||
 			efx->phy_mode & PHY_MODE_LOW_POWER ||
 			efx->loopback_mode == LOOPBACK_PCS ||
@@ -213,10 +208,10 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 		    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
 			xfp_reset_phy(efx);
 
-		mdio_clause45_transmit_disable(efx);
+		efx_mdio_transmit_disable(efx);
 	}
 
-	mdio_clause45_phy_reconfigure(efx);
+	efx_mdio_phy_reconfigure(efx);
 
 	phy_data->phy_mode = efx->phy_mode;
 	efx->link_up = xfp_link_ok(efx);
@@ -225,6 +220,10 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 	efx->link_fc = efx->wanted_fc;
 }
 
+static void xfp_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	mdio45_ethtool_gset(&efx->mdio, ecmd);
+}
 
 static void xfp_phy_fini(struct efx_nic *efx)
 {
@@ -243,8 +242,8 @@ struct efx_phy_operations falcon_xfp_phy_ops = {
 	.poll            = xfp_phy_poll,
 	.fini            = xfp_phy_fini,
 	.clear_interrupt = xfp_phy_clear_interrupt,
-	.get_settings    = mdio_clause45_get_settings,
-	.set_settings	 = mdio_clause45_set_settings,
+	.get_settings    = xfp_phy_get_settings,
+	.set_settings	 = efx_mdio_set_settings,
 	.mmds            = XFP_REQUIRED_DEVS,
 	.loopbacks       = XFP_LOOPBACKS,
 };

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

