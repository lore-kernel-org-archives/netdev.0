From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: Remove WOL get/set ethtool support
Date: Wed,  3 Jun 2015 21:04:42 +0530
Message-ID: <1433345682-5846-5-git-send-email-hariprasad@chelsio.com>
References: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10933 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932094AbbFCKVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 06:21:39 -0400
In-Reply-To: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove ethtool get/set support for wake on lan, adapter doesn't support
it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   2 -
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  33 -------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 100 ---------------------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   2 -
 4 files changed, 137 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 9aab32e..bf2b822 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -732,8 +732,6 @@ struct adapter {
 	struct cxgb4_virt_res vres;
 	unsigned int swintr;
 
-	unsigned int wol;
-
 	struct {
 		unsigned short vec;
 		char desc[IFNAMSIZ + 10];
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 36f6ff2..0194c91 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -947,37 +947,6 @@ static int set_flash(struct net_device *netdev, struct ethtool_flash *ef)
 	return ret;
 }
 
-#define WOL_SUPPORTED (WAKE_BCAST | WAKE_MAGIC)
-#define BCAST_CRC 0xa0ccc1a6
-
-static void get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	wol->supported = WAKE_BCAST | WAKE_MAGIC;
-	wol->wolopts = netdev2adap(dev)->wol;
-	memset(&wol->sopass, 0, sizeof(wol->sopass));
-}
-
-static int set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	int err = 0;
-	struct port_info *pi = netdev_priv(dev);
-
-	if (wol->wolopts & ~WOL_SUPPORTED)
-		return -EINVAL;
-	t4_wol_magic_enable(pi->adapter, pi->tx_chan,
-			    (wol->wolopts & WAKE_MAGIC) ? dev->dev_addr : NULL);
-	if (wol->wolopts & WAKE_BCAST) {
-		err = t4_wol_pat_enable(pi->adapter, pi->tx_chan, 0xfe, ~0ULL,
-					~0ULL, 0, false);
-		if (!err)
-			err = t4_wol_pat_enable(pi->adapter, pi->tx_chan, 1,
-						~6ULL, ~0ULL, BCAST_CRC, true);
-	} else {
-		t4_wol_pat_enable(pi->adapter, pi->tx_chan, 0, 0, 0, 0, false);
-	}
-	return err;
-}
-
 static u32 get_rss_table_size(struct net_device *dev)
 {
 	const struct port_info *pi = netdev_priv(dev);
@@ -1107,8 +1076,6 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_ethtool_stats = get_stats,
 	.get_regs_len      = get_regs_len,
 	.get_regs          = get_regs,
-	.get_wol           = get_wol,
-	.set_wol           = set_wol,
 	.get_rxnfc         = get_rxnfc,
 	.get_rxfh_indir_size = get_rss_table_size,
 	.get_rxfh	   = get_rss_table,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c95714e..c21ab26 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4311,106 +4311,6 @@ void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p)
 #undef GET_STAT_COM
 }
 
-/**
- *	t4_wol_magic_enable - enable/disable magic packet WoL
- *	@adap: the adapter
- *	@port: the physical port index
- *	@addr: MAC address expected in magic packets, %NULL to disable
- *
- *	Enables/disables magic packet wake-on-LAN for the selected port.
- */
-void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
-			 const u8 *addr)
-{
-	u32 mag_id_reg_l, mag_id_reg_h, port_cfg_reg;
-
-	if (is_t4(adap->params.chip)) {
-		mag_id_reg_l = PORT_REG(port, XGMAC_PORT_MAGIC_MACID_LO);
-		mag_id_reg_h = PORT_REG(port, XGMAC_PORT_MAGIC_MACID_HI);
-		port_cfg_reg = PORT_REG(port, XGMAC_PORT_CFG2_A);
-	} else {
-		mag_id_reg_l = T5_PORT_REG(port, MAC_PORT_MAGIC_MACID_LO);
-		mag_id_reg_h = T5_PORT_REG(port, MAC_PORT_MAGIC_MACID_HI);
-		port_cfg_reg = T5_PORT_REG(port, MAC_PORT_CFG2_A);
-	}
-
-	if (addr) {
-		t4_write_reg(adap, mag_id_reg_l,
-			     (addr[2] << 24) | (addr[3] << 16) |
-			     (addr[4] << 8) | addr[5]);
-		t4_write_reg(adap, mag_id_reg_h,
-			     (addr[0] << 8) | addr[1]);
-	}
-	t4_set_reg_field(adap, port_cfg_reg, MAGICEN_F,
-			 addr ? MAGICEN_F : 0);
-}
-
-/**
- *	t4_wol_pat_enable - enable/disable pattern-based WoL
- *	@adap: the adapter
- *	@port: the physical port index
- *	@map: bitmap of which HW pattern filters to set
- *	@mask0: byte mask for bytes 0-63 of a packet
- *	@mask1: byte mask for bytes 64-127 of a packet
- *	@crc: Ethernet CRC for selected bytes
- *	@enable: enable/disable switch
- *
- *	Sets the pattern filters indicated in @map to mask out the bytes
- *	specified in @mask0/@mask1 in received packets and compare the CRC of
- *	the resulting packet against @crc.  If @enable is %true pattern-based
- *	WoL is enabled, otherwise disabled.
- */
-int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
-		      u64 mask0, u64 mask1, unsigned int crc, bool enable)
-{
-	int i;
-	u32 port_cfg_reg;
-
-	if (is_t4(adap->params.chip))
-		port_cfg_reg = PORT_REG(port, XGMAC_PORT_CFG2_A);
-	else
-		port_cfg_reg = T5_PORT_REG(port, MAC_PORT_CFG2_A);
-
-	if (!enable) {
-		t4_set_reg_field(adap, port_cfg_reg, PATEN_F, 0);
-		return 0;
-	}
-	if (map > 0xff)
-		return -EINVAL;
-
-#define EPIO_REG(name) \
-	(is_t4(adap->params.chip) ? \
-	 PORT_REG(port, XGMAC_PORT_EPIO_##name##_A) : \
-	 T5_PORT_REG(port, MAC_PORT_EPIO_##name##_A))
-
-	t4_write_reg(adap, EPIO_REG(DATA1), mask0 >> 32);
-	t4_write_reg(adap, EPIO_REG(DATA2), mask1);
-	t4_write_reg(adap, EPIO_REG(DATA3), mask1 >> 32);
-
-	for (i = 0; i < NWOL_PAT; i++, map >>= 1) {
-		if (!(map & 1))
-			continue;
-
-		/* write byte masks */
-		t4_write_reg(adap, EPIO_REG(DATA0), mask0);
-		t4_write_reg(adap, EPIO_REG(OP), ADDRESS_V(i) | EPIOWR_F);
-		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
-		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY_F)
-			return -ETIMEDOUT;
-
-		/* write CRC */
-		t4_write_reg(adap, EPIO_REG(DATA0), crc);
-		t4_write_reg(adap, EPIO_REG(OP), ADDRESS_V(i + 32) | EPIOWR_F);
-		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
-		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY_F)
-			return -ETIMEDOUT;
-	}
-#undef EPIO_REG
-
-	t4_set_reg_field(adap, PORT_REG(port, XGMAC_PORT_CFG2_A), 0, PATEN_F);
-	return 0;
-}
-
 /*     t4_mk_filtdelwr - create a delete filter WR
  *     @ftid: the filter ID
  *     @wr: the filter work request to populate
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 88067d9..f9a2cb1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -52,8 +52,6 @@ enum {
 	MBOX_LEN       = 64,    /* mailbox size in bytes */
 	TRACE_LEN      = 112,   /* length of trace data and mask */
 	FILTER_OPT_LEN = 36,    /* filter tuple width for optional components */
-	NWOL_PAT       = 8,     /* # of WoL patterns */
-	WOL_PAT_LEN    = 128,   /* length of WoL patterns */
 };
 
 enum {
-- 
2.3.4
