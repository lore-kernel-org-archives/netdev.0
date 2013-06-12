From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Thu, 13 Jun 2013 01:02:57 +0200
Message-ID: <20130612230257.GB21234@electric-eye.fr.zoreil.com>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46602 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756837Ab3FLXDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 19:03:13 -0400
Content-Disposition: inline
In-Reply-To: <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> :
[...]
> diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
> new file mode 100644
> index 0000000..65e7274
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/ethtool.c
[...]
> +static void alx_get_drvinfo(struct net_device *netdev,
> +			    struct ethtool_drvinfo *drvinfo)
> +{
> +	struct alx_priv *alx = netdev_priv(netdev);
> +
> +	strlcpy(drvinfo->driver, alx_drv_name, sizeof(drvinfo->driver));
> +	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));

See 84b405011166e663fe9ef56c29b1d76f59b35568.

> +	strlcpy(drvinfo->bus_info, pci_name(alx->hw.pdev),
> +		sizeof(drvinfo->bus_info));
> +}
> +
> +const struct ethtool_ops alx_ethtool_ops = {
> +	.get_settings = alx_get_settings,
> +	.set_settings = alx_set_settings,
> +	.get_pauseparam = alx_get_pauseparam,
> +	.set_pauseparam = alx_set_pauseparam,
> +	.get_drvinfo = alx_get_drvinfo,
> +	.get_msglevel = alx_get_msglevel,
> +	.set_msglevel = alx_set_msglevel,
> +	.get_wol = alx_get_wol,
> +	.set_wol = alx_set_wol,
> +	.get_link = ethtool_op_get_link,

Please use tabs before =

> diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
> new file mode 100644
> index 0000000..a4c37df
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/hw.c
[...]
> +static int __alx_read_phy_dbg(struct alx_hw *hw, u16 reg, u16 *pdata)
> +{
> +	int err;
> +
> +	err = __alx_write_phy_reg(hw, ALX_MII_DBG_ADDR, reg);
> +	if (err)
> +		return err;
> +
> +	return __alx_read_phy_reg(hw, ALX_MII_DBG_DATA, pdata);

	return err ? err : __alx_read_phy_reg(hw, ALX_MII_DBG_DATA, pdata);

[...]
> +int alx_read_phy_reg(struct alx_hw *hw, u16 reg, u16 *phy_data)
> +{
> +	int err;
> +
> +	spin_lock(&hw->mdio_lock);
> +	err = __alx_read_phy_reg(hw, reg, phy_data);
> +	spin_unlock(&hw->mdio_lock);

Isn't it possible to remove the phy ops from any irq / napi / tasklet
context ?

If you only need it in user / workqueue context you'll be able to trade
the spinlock for a mutex (and push it in the common core methods ?).

[...]
> +read_mcadr:
> +	/* try to get it from register first */
> +	mac0 = alx_read_mem32(hw, ALX_STAD0);
> +	mac1 = alx_read_mem32(hw, ALX_STAD1);
> +
> +	/* addr should be big-endian */
> +	*(__be32 *)(addr + 2) = cpu_to_be32(mac0);
> +	*(__be16 *)addr = cpu_to_be16(mac1);
> +
> +	if (is_valid_ether_addr(addr))
> +		return 0;
> +
> +	if (!loaded_intn) {
> +		/* try to load from efuse */
> +		for (i = 0; i < ALX_SLD_MAX_TO; i++) {
> +			val = alx_read_mem32(hw, ALX_SLD);
> +			if ((val & (ALX_SLD_STAT | ALX_SLD_START)) == 0)
> +				break;
> +			mdelay(1);
> +		}
> +		if (i == ALX_SLD_MAX_TO)
> +			return -EIO;
> +		alx_write_mem32(hw, ALX_SLD, val | ALX_SLD_START);
> +		for (i = 0; i < ALX_SLD_MAX_TO; i++) {
> +			mdelay(1);
> +			val = alx_read_mem32(hw, ALX_SLD);
> +			if ((val & ALX_SLD_START) == 0)
> +				break;
> +		}

You may add an helper for the loops above.

> +		if (i == ALX_SLD_MAX_TO)
> +			return -EIO;
> +		loaded_intn = true;
> +		goto read_mcadr;

(I don't dislike it but it verges on goto fetishismi :o) )

[...]
> diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
> new file mode 100644
> index 0000000..434d3c0
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/main.c
[...]
> +static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
> +{
> +	struct alx_hw *hw = &alx->hw;
> +	bool write_int_mask = false;
> +
> +	spin_lock(&alx->irq_lock);

Do yourself a favor: avoid any work in the irq handler.

Forget the lock. Mask irqs, insert mmiowb and memory barrier, then
schedule napi if there is any event.

In the napi handler, enable napi polling then irq.

[...]
> +static DEFINE_PCI_DEVICE_TABLE(alx_pci_tbl) = {
> +	{ PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, ALX_DEV_ID_AR8161) },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, ALX_DEV_ID_AR8162) },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, ALX_DEV_ID_AR8171) },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, ALX_DEV_ID_AR8172) },

	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_...

-- 
Ueimor
