From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] atl1c:Atheros L1C Gigabit Ethernet driver
Date: Fri, 13 Feb 2009 10:50:38 +0100
Message-ID: <4995426E.5050202@gmail.com>
References: <12344253363870-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jcliburn@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:65509 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbZBMJut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 04:50:49 -0500
In-Reply-To: <12344253363870-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2009 08:55 AM, jie.yang@atheros.com wrote:
> From: Jie Yang <jie.yang@atheros.com>
> 
> Supporting AR8131, and AR8132.
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>
> ---
> Updated on David Miller's comments.
> 
> new file mode 100644
> index 0000000..979e802
> --- /dev/null
> +++ b/drivers/net/atl1c/atl1c.h
[...]
> +#define AT_TAG_TO_VLAN(_tag, _vlan) 	 \
> +	_vlan = ((((_tag) >> 8) & 0xF)  |\
> +		(((_tag) & 0xF0) << 8)  |\
> +		(((_tag) & 0xF) >> 8))

The last line is always 0, right?

> diff --git a/drivers/net/atl1c/atl1c_hw.c b/drivers/net/atl1c/atl1c_hw.c
> new file mode 100644
> index 0000000..bd47350
> --- /dev/null
> +++ b/drivers/net/atl1c/atl1c_hw.c
[...]
> +int atl1c_write_phy_reg(struct atl1c_hw *hw, u32 reg_addr, u16 phy_data)
> +{
> +	int i;
> +	u32 val;
> +
> +	val = ((u32)(phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT   |
> +	       (reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
> +	       MDIO_SUP_PREAMBLE | MDIO_START |
> +	       MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
> +
> +	AT_WRITE_REG(hw, REG_MDIO_CTRL, val);
> +	wmb();

Did you mean mmiowb()? Why it is needed? This doesn't cope with pci posting. The
read below does.

> +
> +	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
> +		udelay(2);
> +		AT_READ_REG(hw, REG_MDIO_CTRL, &val);
> +		if (!(val & (MDIO_START | MDIO_BUSY)))
> +			break;
> +		wmb();
> +	}
> +
> +	if (!(val & (MDIO_START | MDIO_BUSY)))
> +		return 0;
> +
> +	return -1;
> +}
[...]
> +int atl1c_phy_reset(struct atl1c_hw *hw)
> +{
> +	struct atl1c_adapter *adapter = hw->adapter;
> +	struct pci_dev *pdev = adapter->pdev;
> +	u32 phy_ctrl_data = GPHY_CTRL_DEFAULT;
> +	u32 mii_ier_data = IER_LINK_UP | IER_LINK_DOWN;
> +	int err;
> +
> +	if (hw->ctrl_flags & ATL1C_HIB_DISABLE)
> +		phy_ctrl_data &= ~GPHY_CTRL_HIB_EN;
> +
> +	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl_data);
> +	msleep(40);

Do you need the write to reach the device and wait 40ms? Then you need to
AT_WRITE_FLUSH, I suppose.

> +	phy_ctrl_data |= GPHY_CTRL_EXT_RESET;
> +	AT_WRITE_REG(hw, REG_GPHY_CTRL, phy_ctrl_data);
> +	msleep(10);

ditto

> +	/*Enable PHY LinkChange Interrupt */
> +	err = atl1c_write_phy_reg(hw, MII_IER, mii_ier_data);
> +	if (err) {
> +		dev_err(&pdev->dev, "Error enable PHY linkChange Interrupt\n");
> +		return err;
> +	}
> +	if (!(hw->ctrl_flags & ATL1C_FPGA_VERSION))
> +		atl1c_phy_magic_data(hw);
> +	return 0;
> +}
[...]
> diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
> new file mode 100644
> index 0000000..61bef3d
> --- /dev/null
> +++ b/drivers/net/atl1c/atl1c_main.c
[...]
> +static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
> +{
> +	u32 data;
> +	u32 pci_cmd;
> +	struct pci_dev *pdev = hw->adapter->pdev;
> +
> +	AT_READ_REG(hw, PCI_COMMAND, &pci_cmd);
> +	pci_cmd &= ~PCI_COMMAND_INTX_DISABLE;
> +	pci_cmd |= (PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER |
> +		PCI_COMMAND_IO);
> +	AT_WRITE_REG(hw, PCI_COMMAND, pci_cmd);
> +
> +	/*
> +	 * Clear any PowerSaveing Settings
> +	 */
> +	pci_enable_wake(pdev, PCI_D3hot, 0);
> +	pci_enable_wake(pdev, PCI_D3cold, 0);
> +
> +	/*
> +	 * Mask some pcie error bits
> +	 */
> +	AT_READ_REG(hw, REG_PCIE_UC_SEVERITY, &data);
> +	data &= ~PCIE_UC_SERVRITY_DLP;
> +	data &= ~PCIE_UC_SERVRITY_FCP;
> +	AT_WRITE_REG(hw, REG_PCIE_UC_SEVERITY, data);
> +
> +	if (flag & ATL1C_PCIE_L0S_L1_DISABLE)
> +		atl1c_disable_l0s_l1(hw);
> +	if (flag & ATL1C_PCIE_PHY_RESET)
> +		AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_DEFAULT);
> +	else
> +		AT_WRITE_REG(hw, REG_GPHY_CTRL,
> +			GPHY_CTRL_DEFAULT | GPHY_CTRL_EXT_RESET);
> +
> +	msleep(1);

again.

> +static void atl1c_configure_rss(struct atl1c_adapter *adapter)
> +{
> +	struct atl1c_hw *hw = (struct atl1c_hw *)&adapter->hw;

Why the cast?

> +
> +	AT_WRITE_REG(hw, REG_IDT_TABLE, hw->indirect_tab);
> +	AT_WRITE_REG(hw, REG_BASE_CPU_NUMBER, hw->base_cpu);
> +
> +	return;

Unneeded return.

> +static int atl1c_reset_mac(struct atl1c_hw *hw)
> +{
> +	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
> +	struct pci_dev *pdev = adapter->pdev;
> +	u32 idle_status_data = 0;
> +	int timeout = 0;
> +	int ret;
> +
> +	AT_WRITE_REG(hw, REG_IMR, 0);
> +	AT_WRITE_REG(hw, REG_ISR, ISR_DIS_INT);
> +
> +	ret = atl1c_stop_mac(hw);
> +	if (ret)
> +		return ret;
> +	/*
> +	 * Issue Soft Reset to the MAC.  This will reset the chip's
> +	 * transmit, receive, DMA.  It will not effect
> +	 * the current PCI configuration.  The global reset bit is self-
> +	 * clearing, and should clear within a microsecond.
> +	 */
> +	AT_WRITE_REGW(hw, REG_MASTER_CTRL, MASTER_CTRL_SOFT_RST);
> +	msleep(10);
> +	wmb();

again

> +static u16 atl1c_cal_tpd_req(const struct sk_buff *skb)
> +{
> +	int i = 0;
> +	u16 tpd_req = 1;
> +	u16 proto_hdr_len = 0;
> +
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> +		tpd_req++;

Is this
tpd_req = skb_shinfo(skb)->nr_frags + 1;
?

> +static void atl1c_tx_map(struct atl1c_adapter *adapter,
> +		      struct sk_buff *skb, struct atl1c_tpd_desc *tpd,
> +			enum atl1c_trans_queue type)
> +{
> +	struct atl1c_tpd_desc *use_tpd = NULL;
> +	struct atl1c_buffer *buffer_info = NULL;
> +	u16 buf_len = skb->len - skb->data_len;

skb_headlen()

> +	u16 map_len = 0;
> +	u16 mapped_len = 0;
> +	u16 hdr_len = 0;
> +	u16 nr_frags;
> +	u16 f;
> +	int tso;
> +
[...]
> +	for (f = 0; f < nr_frags; f++) {
> +		struct skb_frag_struct *frag;
> +
> +		frag = &skb_shinfo(skb)->frags[f];
> +
> +		use_tpd = atl1c_get_tpd(adapter, type);
> +		memcpy(use_tpd, tpd, sizeof(struct atl1c_tpd_desc));
> +
> +		buffer_info = atl1c_get_tx_buffer(adapter, use_tpd);
> +		buffer_info->length = frag->size;
> +		buffer_info->dma =
> +			pci_map_page(adapter->pdev, frag->page,
> +					frag->page_offset,
> +					buffer_info->length,
> +					PCI_DMA_TODEVICE);
> +		buffer_info->state = ATL1_BUFFER_BUSY;
> +		if (buffer_info->dma == 0) {
> +			printk(KERN_EMERG "buffer_info dma is 0\n");
> +			dump_stack();

So you don't rollback here, do you allow the device to overwrite memory at phys
addr 0?

> +		}
> +
> +		use_tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
> +		use_tpd->buffer_len  = cpu_to_le16(buffer_info->length);
> +	}
> +
> +	/* The last tpd */
> +	use_tpd->word1 |= 1 << TPD_EOP_SHIFT;
> +	/* The last buffer info contain the skb address,
> +	   so it will be free after unmap */
> +	buffer_info->skb = skb;
> +}

> +static int atl1c_request_irq(struct atl1c_adapter *adapter)
> +{
> +	struct pci_dev    *pdev   = adapter->pdev;
> +	struct net_device *netdev = adapter->netdev;
> +	int flags = 0;
> +	int err = 0;
> +
> +	adapter->have_msi = true;
> +	err = pci_enable_msi(adapter->pdev);
> +	if (err) {
> +		dev_dbg(&pdev->dev,
> +			"Unable to allocate MSI interrupt Error: %d\n", err);

Why not be verbose? Nobody will see this message unless DEBUG is defined (or set
on dynamic printks).

> +		adapter->have_msi = false;
> +	} else
> +		netdev->irq = pdev->irq;
> +
> +	if (!adapter->have_msi)
> +		flags |= IRQF_SHARED;
> +	err = request_irq(adapter->pdev->irq, &atl1c_intr, flags,
> +			netdev->name, netdev);
> +	if (err) {
> +		dev_dbg(&pdev->dev,
> +			"Unable to allocate interrupt Error: %d\n", err);

ditto

> +		if (adapter->have_msi)
> +			pci_disable_msi(adapter->pdev);
> +		return err;
> +	}
> +	dev_dbg(&pdev->dev, "atl1c_request_irq OK\n");
> +	return err;
> +}
[...]
> +#ifdef CONFIG_PM
> +static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct atl1c_adapter *adapter = netdev_priv(netdev);
> +	struct atl1c_hw *hw = &adapter->hw;
> +	u32 ctrl = 0;
> +	u32 mac_ctrl_data = 0;
> +	u32 master_ctrl_data = 0;
> +	u32 wol_ctrl_data = 0;
> +	u16 mii_bmsr_data = 0;
> +	u16 save_autoneg_advertised;
> +	u16 mii_intr_status_data = 0;
> +	u32 wufc = adapter->wol;
> +	u32 i;
> +#ifdef CONFIG_PM
> +	int retval = 0;
> +#endif
> +
> +	printk(KERN_EMERG "in atl1c_suspend!! wufc is %d\n", wufc);

Why is it EMERG? It looks like a sort of debug info.

> +	if (netif_running(netdev)) {
> +		WARN_ON(test_bit(__AT_RESETTING, &adapter->flags));
> +		atl1c_down(adapter);
> +	}
> +	netif_device_detach(netdev);
> +	atl1c_disable_l0s_l1(hw);
> +#ifdef CONFIG_PM
> +	retval = pci_save_state(pdev);
> +	if (retval)
> +		return retval;
> +#endif
> +	if (wufc) {
> +		AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
> +		master_ctrl_data &= ~MASTER_CTRL_CLK_SEL_DIS;
> +
> +		/* get link status */
> +		atl1c_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
> +		atl1c_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
> +		save_autoneg_advertised = hw->autoneg_advertised;
> +		hw->autoneg_advertised = ADVERTISED_10baseT_Half;
> +		if (atl1c_restart_autoneg(hw) != 0)
> +			dev_dbg(&pdev->dev, "phy autoneg failed\n");
> +		hw->phy_configured = false; /* re-init PHY when resume */
> +		hw->autoneg_advertised = save_autoneg_advertised;
> +		/* turn on magic packet wol */
> +		if (wufc & AT_WUFC_MAG)
> +			wol_ctrl_data |= WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
> +
> +		if (wufc & AT_WUFC_LNKC) {
> +			for (i = 0; i < AT_SUSPEND_LINK_TIMEOUT; i++) {
> +				msleep(100);
> +				atl1c_read_phy_reg(hw, MII_BMSR,
> +					(u16 *)&mii_bmsr_data);
> +				if (mii_bmsr_data & BMSR_LSTATUS)
> +					break;
> +			}
> +			if ((mii_bmsr_data & BMSR_LSTATUS) == 0)
> +				dev_dbg(&pdev->dev,
> +					"%s: Link may change"
> +					"when suspend\n",
> +					atl1c_driver_name);

too low verbosity

> +			wol_ctrl_data |=  WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN;
> +			/* only link up can wake up */
> +			if (atl1c_write_phy_reg(hw, MII_IER, IER_LINK_UP) != 0) {
> +				dev_dbg(&pdev->dev, "%s: read write phy "
> +						  "register failed.\n",
> +						  atl1c_driver_name);

again

> +static int __devinit atl1c_probe(struct pci_dev *pdev,
> +				 const struct pci_device_id *ent)
> +{
[...]
> +	adapter->hw.hw_addr = pci_iomap(pdev, 0, 0);

Ah, and you use readl, writel on it. Use ioremap instead. Or ioread/iowrite.

Hmm, what happened to Arjan's pci_ioremap? <Going to investigate...>

> +	init_timer(&adapter->phy_config_timer);
> +	adapter->phy_config_timer.function = &atl1c_phy_config;
> +	adapter->phy_config_timer.data = (unsigned long) adapter;

setup_timer() is more appropriate here.

