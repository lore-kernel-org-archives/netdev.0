From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Use of ENOTSUPP in drivers?
Date: Sun, 12 Jan 2014 19:57:15 +0100
Message-ID: <20140112185715.GB5405@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:60867 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaALS5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 13:57:37 -0500
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id 08CA7CA95EB
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 19:57:33 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thu, 2 Jan 2014 12:01:31 +0000, Ben Hutchings wrote:
> Never return error code ENOTSUPP; it's *not* the same thing as ENOTSUP
> in userland and is not part of the userland ABI.  I would use EINVAL
> here.


I've found a few ethernet drivers that return -ENOTSUPP in various
functions. In particular, some ethtool functions or ioctl's.
Ben's message makes me think that the ethtool functions and ioctl's
should be modified.

There are other occurences, mostly in functions related to device
initialization. I didn't manage to track down exactly from where some
of them are called, and I don't know if ENOTSUPP is okay in these.

I've included the complete list of occurences (based on net-next) from
drivers/net/ethernet in patch form at the end, if that's more
convenient than the file/function list. This is not meant to be
applied.


Do these (or part of them) need to be patched? Or is there something
I'm missing?


Thanks,
Sabrina


---

* called from ethtool

  drivers/net/ethernet/intel/igb/igb_ethtool.c
    static int igb_get_sset_count(struct net_device *netdev, int sset)

  drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
    static int i40evf_get_sset_count(struct net_device *netdev, ...)

  drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
    static int qlcnic_get_dump_flag(struct net_device *netdev, ...)
    static int qlcnic_get_dump_data(struct net_device *netdev, ...)

  drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
    /* called via .self_test in struct ethtool_ops */
    int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)

  drivers/net/ethernet/calxeda/xgmac.c
    static int xgmac_set_wol(struct net_device *dev, ...)


* called as ndo_do_ioctl

  drivers/net/ethernet/ti/cpsw.c
    static int cpsw_ndo_ioctl(struct net_device *dev, ...)

  drivers/net/ethernet/marvell/mvneta.c
    static int mvneta_ioctl(struct net_device *dev, ...)

  drivers/net/ethernet/marvell/mv643xx_eth.c
    static int mv643xx_eth_ioctl(struct net_device *dev, ...)

  drivers/net/ethernet/freescale/fec_mpc52xx.c
    static int mpc52xx_fec_ioctl(struct net_device *dev, ...)


* called as ndo_init

  drivers/net/ethernet/lantiq_etop.c
    static int ltq_etop_hw_init(struct net_device *dev)


* called from ndo_open (return value ignored)/ not called

  drivers/net/ethernet/ti/davinci_cpdma.c
    int cpdma_control_get(struct cpdma_ctlr *ctlr, ...)
    int cpdma_control_set(struct cpdma_ctlr *ctlr, ...)


* not sure, probably fine

  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
    /* stored as adapter->ptp_caps.enable, ie struct ptp_clock_info */
    static int ixgbe_ptp_enable(struct ptp_clock_info *ptp, ...)

  drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
    /* called from dcbnl_rtnl_ops.ieee_setets */
    static int mlx4_en_ets_validate(struct mlx4_en_priv *priv, ...)

  drivers/net/ethernet/mellanox/mlx5/core/cmd.c
    /* called from pci_driver.probe in drivers/infiniband/hw/mlx5/main.c */
    int mlx5_cmd_init(struct mlx5_core_dev *dev)

  drivers/net/ethernet/mellanox/mlx4/mr.c
    int mlx4_mw_alloc(struct mlx4_dev *dev, u32 pd, ...)

  drivers/net/ethernet/broadcom/bgmac.c
    static int bgmac_probe(struct bcma_device *core)
    /* called by bgmac_probe */
    static int bgmac_dma_alloc(struct bgmac *bgmac)

---

ethtool functions


 drivers/net/ethernet/calxeda/xgmac.c                | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c  | 2 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c        | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 4 ++--
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 4fc5c8e..3055a48 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1677,7 +1677,7 @@ static int xgmac_set_wol(struct net_device *dev,
 	u32 support = WAKE_MAGIC | WAKE_UCAST;
 
 	if (!device_can_wakeup(priv->device))
-		return -ENOTSUPP;
+		return -EINVAL;
 
 	if (wol->wolopts & ~support)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index b0b1f4b..604ffa0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -96,7 +96,7 @@ static int i40evf_get_sset_count(struct net_device *netdev, int sset)
 	if (sset == ETH_SS_STATS)
 		return I40EVF_STATS_LEN;
 	else
-		return -ENOTSUPP;
+		return -EINVAL;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 1df0237..c1cac5c 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2242,7 +2242,7 @@ static int igb_get_sset_count(struct net_device *netdev, int sset)
 	case ETH_SS_TEST:
 		return IGB_TEST_LEN;
 	default:
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 }
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 03eb2ad..bb9f4ec 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1641,7 +1641,7 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(netdev,
 			    "Loopback test not supported in non privileged mode\n");
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 
 	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 45fa6ef..727be4e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1681,7 +1681,7 @@ qlcnic_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 
 	if (!fw_dump->tmpl_hdr) {
 		netdev_err(adapter->netdev, "FW Dump not supported\n");
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 
 	if (fw_dump->clr)
@@ -1710,7 +1710,7 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 
 	if (!fw_dump->tmpl_hdr) {
 		netdev_err(netdev, "FW Dump not supported\n");
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 
 	if (!fw_dump->clr) {

---

ndo_do_ioctl functions


 drivers/net/ethernet/freescale/fec_mpc52xx.c | 2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c   | 2 +-
 drivers/net/ethernet/marvell/mvneta.c        | 2 +-
 drivers/net/ethernet/ti/cpsw.c               | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 9947765..224f8db 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -810,7 +810,7 @@ static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 
 	if (!priv->phydev)
-		return -ENOTSUPP;
+		return -EINVAL;
 
 	return phy_mii_ioctl(priv->phydev, rq, cmd);
 }
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index a2565ce..7ef4388 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2299,7 +2299,7 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	int ret;
 
 	if (mp->phy == NULL)
-		return -ENOTSUPP;
+		return -EINVAL;
 
 	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
 	if (!ret)
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index d5f0d72..9bd8be5 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2490,7 +2490,7 @@ static int mvneta_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	int ret;
 
 	if (!pp->phy_dev)
-		return -ENOTSUPP;
+		return -EINVAL;
 
 	ret = phy_mii_ioctl(pp->phy_dev, ifr, cmd);
 	if (!ret)
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e8bb77d..18395d1 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1432,7 +1432,7 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 		data->phy_id = priv->slaves[slave_no].phy->addr;
 		break;
 	default:
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 
 	return 0;


---

other ndo_* functions


 drivers/net/ethernet/lantiq_etop.c      | 2 +-
 drivers/net/ethernet/ti/davinci_cpdma.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 974a007..fe2521c 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -265,7 +265,7 @@ ltq_etop_hw_init(struct net_device *dev)
 	default:
 		netdev_err(dev, "unknown mii mode %d\n",
 			priv->pldata->mii_mode);
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 
 	/* enable crc generation */
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 364d0c7..99985db 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -993,7 +993,7 @@ int cpdma_control_get(struct cpdma_ctlr *ctlr, int control)
 
 	spin_lock_irqsave(&ctlr->lock, flags);
 
-	ret = -ENOTSUPP;
+	ret = -EINVAL;
 	if (!ctlr->params.has_ext_regs)
 		goto unlock_ret;
 
@@ -1025,7 +1025,7 @@ int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
 
 	spin_lock_irqsave(&ctlr->lock, flags);
 
-	ret = -ENOTSUPP;
+	ret = -EINVAL;
 	if (!ctlr->params.has_ext_regs)
 		goto unlock_ret;


---

other functions


 drivers/net/ethernet/broadcom/bgmac.c          | 10 +++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c        |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |  2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 7f968a9..649c99e 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -487,7 +487,7 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 
 	if (!(bcma_aread32(bgmac->core, BCMA_IOST) & BCMA_IOST_DMA64)) {
 		bgmac_err(bgmac, "Core does not report 64-bit DMA\n");
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 
 	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
@@ -1421,7 +1421,7 @@ static int bgmac_probe(struct bcma_device *core)
 	/* We don't support 2nd, 3rd, ... units, SPROM has to be adjusted */
 	if (core->core_unit > 1) {
 		pr_err("Unsupported core_unit %d\n", core->core_unit);
-		return -ENOTSUPP;
+		return -EINVAL;
 	}
 
 	if (!is_valid_ether_addr(mac)) {
@@ -1467,7 +1467,7 @@ static int bgmac_probe(struct bcma_device *core)
 
 	if (core->bus->hosttype == BCMA_HOSTTYPE_PCI) {
 		bgmac_err(bgmac, "PCI setup not implemented\n");
-		err = -ENOTSUPP;
+		err = -EINVAL;
 		goto err_netdev_free;
 	}
 
@@ -1518,14 +1518,14 @@ static int bgmac_probe(struct bcma_device *core)
 	err = bgmac_mii_register(bgmac);
 	if (err) {
 		bgmac_err(bgmac, "Cannot register MDIO\n");
-		err = -ENOTSUPP;
+		err = -EINVAL;
 		goto err_dma_free;
 	}
 
 	err = register_netdev(bgmac->net_dev);
 	if (err) {
 		bgmac_err(bgmac, "Cannot register net device\n");
-		err = -ENOTSUPP;
+		err = -EINVAL;
 		goto err_mii_unregister;
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 5184e2a..b26667e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -368,7 +368,7 @@ static int ixgbe_ptp_enable(struct ptp_clock_info *ptp,
 		}
 	}
 
-	return -ENOTSUPP;
+	return -EINVAL;
 }
 
 /**
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index b4881b6..17355ba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -78,7 +78,7 @@ static int mlx4_en_ets_validate(struct mlx4_en_priv *priv, struct ieee_ets *ets)
 		default:
 			en_err(priv, "TC[%d]: Not supported TSA: %d\n",
 					i, ets->tc_tsa[i]);
-			return -ENOTSUPP;
+			return -EINVAL;
 		}
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 0558ddd..a877a35 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -660,7 +660,7 @@ int mlx4_mw_alloc(struct mlx4_dev *dev, u32 pd, enum mlx4_mw_type type,
 	     !(dev->caps.flags & MLX4_DEV_CAP_FLAG_MEM_WINDOW)) ||
 	     (type == MLX4_MW_TYPE_2 &&
 	     !(dev->caps.bmme_flags & MLX4_BMME_FLAG_TYPE_2_WIN)))
-		return -ENOTSUPP;
+		return -EINVAL;
 
 	index = mlx4_mpt_reserve(dev);
 	if (index == -1)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 8675d26..5398fbb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1422,7 +1422,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	if (cmd->cmdif_rev > CMD_IF_REV) {
 		dev_err(&dev->pdev->dev, "driver does not support command interface version. driver %d, firmware %d\n",
 			CMD_IF_REV, cmd->cmdif_rev);
-		err = -ENOTSUPP;
+		err = -EINVAL;
 		goto err_map;
 	}
