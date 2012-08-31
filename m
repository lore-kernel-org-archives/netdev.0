From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] net: add new QCA alx ethernet driver
Date: Sat, 1 Sep 2012 00:24:29 +0200
Message-ID: <20120831222429.GA12911@electric-eye.fr.zoreil.com>
References: <1346083963-17610-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, Xiong Huang <xiong@qca.qualcomm.com>,
	"Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1346083963-17610-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cjren@qca.qualcomm.com <cjren@qca.qualcomm.com> :
[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
> new file mode 100644
> index 0000000..2b4ecc1
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx.h
[...]
> +#define ALX_VLAN_TO_TAG(_vlan, _tag) \
> +	do { \
> +		_tag = ((((_vlan) >> 8) & 0xFF) | (((_vlan) & 0xFF) << 8)); \
> +	} while (0)
> +
> +#define ALX_TAG_TO_VLAN(_tag, _vlan) \
> +	do { \
> +		_vlan = ((((_tag) >> 8) & 0xFF) | (((_tag) & 0xFF) << 8)); \
> +	} while (0)

You can replace these macros with non caps static inline functions

[...]
> +/*
> + * RRD : definition
> + */
> +
> +/* general parameter format of rrd */
> +struct alx_sw_rrdes_general {
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> +	/* dword 0 */
> +	u32  xsum:16;
> +	u32  nor:4;  /* number of RFD */
> +	u32  si:12;  /* start index of rfd-ring */
> +	/* dword 1 */
> +	u32 hash;
> +	/* dword 2 */
> +	u32 vlan_tag:16; /* vlan-tag */
> +	u32 pid:8;       /* Header Length of Header-Data Split. WORD unit */
> +	u32 reserve0:1;

Please no bitfields nor endianness conditionals. The driver should use
cpu_to_leXY, leXY_to_cpu and plain bitmasks.

The extensive documentation is nice btw.

[...]
> +struct alx_adapter {
> +	struct net_device *netdev;
> +	struct pci_dev    *pdev;
> +	struct net_device_stats net_stats;
> +	bool netdev_registered;
> +	u16 bd_number;    /* board number;*/
> +
> +	struct alx_msix_param *msix[ALX_MAX_MSIX_INTRS];
> +	struct msix_entry     *msix_entries;
> +	int num_msix_rxques;
> +	int num_msix_txques;
> +	int num_msix_noques;    /* true count of msix_noques for device */
> +	int num_msix_intrs;
> +
> +	int min_msix_intrs;
> +	int max_msix_intrs;
> +
> +	/* All Descriptor memory */
> +	struct alx_ring_header ring_header;
> +
> +	/* TX */
> +	struct alx_tx_queue *tx_queue[ALX_MAX_TX_QUEUES];
> +	/* RX */
> +	struct alx_rx_queue *rx_queue[ALX_MAX_RX_QUEUES];
> +
> +	u16 num_txques;
> +	u16 num_rxques; /* equal max(num_hw_rxques, num_sw_rxques) */
> +	u16 num_hw_rxques;
> +	u16 num_sw_rxques;
> +	u16 max_rxques;
> +	u16 max_txques;
[...]
> +	spinlock_t tx_lock;
> +	spinlock_t rx_lock;

You may consider packing tx and rx data into similar struct and
save cache lines.

[...]
> +#ifdef ETHTOOL_OPS_COMPAT
> +extern int ethtool_ioctl(struct ifreq *ifr);
> +#endif

It belongs to compat-something, not mainline.

> diff --git a/drivers/net/ethernet/atheros/alx/alx_abs.c b/drivers/net/ethernet/atheros/alx/alx_abs.c
> new file mode 100644
> index 0000000..7f7efb4
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_abs.c
[...]
> +/* PHY */
> +int alf_read_phy_reg(struct alx_hw *hw, u16 reg_addr, u16 *phy_data)
> +{
> +	unsigned long  flags;
                     ^^
> +	int  retval = 0;
           ^^

Pattern: initializing retval (rc ?) is useless.

[...]
> +int alf_check_phy_link(struct alx_hw *hw, u8 *speed, bool *link_up)
> +{
> +	u16 bmsr, giga;
> +	int retval;
> +
> +	alf_read_phy_reg(hw, MII_BMSR, &bmsr);
> +	retval = alf_read_phy_reg(hw, MII_BMSR, &bmsr);
> +	if (retval)
> +		return retval;
> +
> +	if (!(bmsr & BMSR_LSTATUS)) {
> +		*link_up = false;
> +		*speed = 0;
> +		return retval;
> +	}
> +	*link_up = true;
> +
> +	/* Read PHY Specific Status Register (17) */
> +	retval = alf_read_phy_reg(hw, L1F_MII_GIGA_PSSR, &giga);
> +	if (retval)
> +		return retval;
> +
> +
> +	if (!(giga & L1F_GIGA_PSSR_SPD_DPLX_RESOLVED)) {
> +		alx_hw_err(hw, "error for speed duplex resolved\n");
> +		return -EINVAL;
> +	}
> +
> +	switch (giga & L1F_GIGA_PSSR_SPEED) {
> +	case L1F_GIGA_PSSR_1000MBS:
> +		if (giga & L1F_GIGA_PSSR_DPLX)
> +			*speed = LX_LC_1000F;
> +		else
> +			alx_hw_err(hw, "1000M half is invalid\n");

So it's possible to read an invalid half duplex status from a register ?

It could be worth to set retval adequately (and always have the caller
check alf_check_phy_link return status code).

[...]
> +int alf_init_mac(struct alx_hw *hw, u16 rxbuf_sz, u16 rx_qnum,
> +		 u16 rxring_sz, u16 tx_qnum,  u16 txring_sz)
> +{
> +	int retval = 0;
> +
> +	l1f_init_mac_misc(hw, hw->mac_addr, hw->smb_timer, hw->imt_mod, true);
> +
> +	retval = l1f_init_mac_rtx_ring_desc(hw, hw->dma.rfdmem_hi[0],
> +				   hw->dma.rfdmem_lo[0], hw->dma.rrdmem_lo[0],
> +				   rxring_sz, rxbuf_sz,
> +				   hw->dma.tpdmem_hi[0], hw->dma.tpdmem_lo,
> +				   tx_qnum, txring_sz);

The callee can infer &hw->dma from hw.

(...]
> +int alf_config_aspm(struct alx_hw *hw, bool l0s_en, bool l1_en)
> +{
> +	int retval = 0;
> +
> +	if (!CHK_HW_FLAG(L0S_CAP))
> +		l0s_en = false;
> +
> +	if (l0s_en)
> +		SET_HW_FLAG(L0S_EN);
> +	 else
	^ space after tab

[...]
> +int alf_config_msix(struct alx_hw *hw, u16 num_intrs, bool msix_en, bool msi_en)
> +{
> +	u32 map[2];
> +	u32 type;
> +	int msix_idx;
> +
> +	if (!msix_en)
> +		goto configure_legacy;
> +
> +	memset(map, 0, sizeof(map));
> +	for (msix_idx = 0; msix_idx < num_intrs; msix_idx++) {
> +		switch (msix_idx) {
> +		case ALF_MSIX_INDEX_RXQ0:
> +			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_RXQ0,
> +				   ALF_MSIX_INDEX_RXQ0);
> +			break;
> +		case ALF_MSIX_INDEX_RXQ1:
> +			FIELD_SETL(map[0], L1F_MSI_MAP_TBL1_RXQ1,
> +				   ALF_MSIX_INDEX_RXQ1);
> +			break;
[snip]
> +		case ALF_MSIX_INDEX_PHY:
> +			FIELD_SETL(map[1], L1F_MSI_MAP_TBL2_PHY,
> +				   ALF_MSIX_INDEX_PHY);

It could use an ALF_MSIX_XYZ indexed array.

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/alx_ethtool.c b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
> new file mode 100644
> index 0000000..92fb461
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx_ethtool.c
[...]
> +static int alx_set_pauseparam(struct net_device *netdev,
> +			      struct ethtool_pauseparam *pause)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +	struct alx_hw *hw = &adpt->hw;
> +	enum alx_fc_mode req_fc_mode;
> +	bool disable_fc_autoneg;
> +	int retval;
> +
> +	while (CHK_ADPT_FLAG(STATE_RESETTING))
> +		msleep(20);
> +	SET_ADPT_FLAG(STATE_RESETTING);
> +
> +	req_fc_mode        = hw->req_fc_mode;
> +	disable_fc_autoneg = hw->disable_fc_autoneg;
> +
> +
> +	if (pause->autoneg != AUTONEG_ENABLE)
> +		disable_fc_autoneg = true;
> +	else
> +		disable_fc_autoneg = false;
> +
> +	if ((pause->rx_pause && pause->tx_pause) || pause->autoneg)
> +		req_fc_mode = alx_fc_full;
> +	else if (pause->rx_pause && !pause->tx_pause)
> +		req_fc_mode = alx_fc_rx_pause;
> +	else if (!pause->rx_pause && pause->tx_pause)
> +		req_fc_mode = alx_fc_tx_pause;
> +	else if (!pause->rx_pause && !pause->tx_pause)
> +		req_fc_mode = alx_fc_none;
> +	else
> +		return -EINVAL;

return in the middle of a {SET/CLI}_ADPT_FLAG(STATE_RESETTING) section ?

> +
> +	if ((hw->req_fc_mode != req_fc_mode) ||
> +	    (hw->disable_fc_autoneg != disable_fc_autoneg)) {
> +		hw->req_fc_mode = req_fc_mode;
> +		hw->disable_fc_autoneg = disable_fc_autoneg;
> +		if (!hw->disable_fc_autoneg) {
> +			retval = alf_setup_phy_link(hw, hw->autoneg_advertised,
> +						    true, true);
> +		}
> +
> +		alf_config_fc(hw);
> +	}
> +
> +	CLI_ADPT_FLAG(STATE_RESETTING);
> +	return 0;
> +}
> +
> +
> +static u32 alx_get_msglevel(struct net_device *netdev)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +	return adpt->msg_enable;

Please insert an empty line after variables(s) declaration.

[...]
> +static void alx_get_drvinfo(struct net_device *netdev,
> +			    struct ethtool_drvinfo *drvinfo)
> +{
> +	struct alx_adapter *adpt = netdev_priv(netdev);
> +
> +	strlcpy(drvinfo->driver,  alx_drv_name, sizeof(drvinfo->driver));
                                ^^
> +	strlcpy(drvinfo->fw_version, "alx", 32);

It should be "N/A".

-- 
Ueimor
