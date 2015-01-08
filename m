From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Fri, 09 Jan 2015 00:35:41 +0100
Message-ID: <5550127.3sXOcCISZN@wuerfel>
References: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: jcliburn@gmail.com, grant.likely@linaro.org, robh+dt@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stephen Wang <wstephen@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 January 2015 14:03:46 Stephen Wang wrote:
> This driver adds support for the internal GMACs on IPQ806x SoCs.
> It supports the device-tree and will register up to 4 ethernet
> interfaces.
> 
> Signed-off-by: Stephen Wang <wstephen@codeaurora.org>

Just a very brief review here. The driver is far too long to be
reviewed in one piece, and hopefully is not needed at all if my
suspicion is correct that we already have a driver for the
hardware.

> diff --git a/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt b/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
> new file mode 100644
> index 0000000..806f2e6
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
> @@ -0,0 +1,14 @@
> +Linux Driver for 3504 DWC Ether MAC 10/100/1000 Universal
> +Linux Driver for 3507 DWC Ether MAC 10/100 Universal
> +
> +IMPORTANT: Synopsys Ethernet MAC Linux Software Drivers and documentation (hereinafter, "Software") are unsupported proprietary works of Synopsys, Inc. unless otherwise expressly agreed to in writing between Synopsys and you.
> +
> +The Software uses certain Linux kernel functionality and may therefore be subject to the GNU Public License which is available at:
> +http://www.gnu.org/licenses/gpl.html

It sounds like this one is related to the dwmac driver in
drivers/net/ethernet/stmicro/stmmac/. Please move the code into
the same directory and reuse as much as you can.

If this is a completely unrelated part, it should probably go
into drivers/net/ethernet/designware or drivers/net/ethernet/synopsys.

> +#ifdef CONFIG_OF
> +#include <msm_nss_gmac.h>
> +#else
> +#include <mach/msm_nss_gmac.h>
> +#endif

Drop the non-CONFIG_OF part here and elsewhere, we don't support
separate platform directories any more, and mach-qcom is already
DT-only.

> +/**********************************************************
> + * GMAC registers Map
> + * For Pci based system address is BARx + gmac_register_base
> + * For any other system translation is done accordingly
> + **********************************************************/
> +enum gmac_registers {
> +	gmac_config = 0x0000,		/* Mac config Register                */
> +	gmac_frame_filter = 0x0004,	/* Mac frame filtering controls       */
> +	gmac_hash_high = 0x0008,	/* Multi-cast hash table high         */
> +	gmac_hash_low = 0x000c,		/* Multi-cast hash table low          */
> +	gmac_gmii_addr = 0x0010,	/* GMII address Register(ext. Phy)    */
> +	gmac_gmii_data = 0x0014,	/* GMII data Register(ext. Phy)       */
> +	gmac_flow_control = 0x0018,	/* Flow control Register              */
> +	gmac_vlan = 0x001c,		/* VLAN tag Register (IEEE 802.1Q)    */
> +	gmac_version = 0x0020,		/* GMAC Core Version Register         */
> +	gmac_wakeup_addr = 0x0028,	/* GMAC wake-up frame filter adrress
> +					   reg				      */

This looks a lot like dwmac1000 as well.

> +	if (of_property_read_u32(np, "qcom,id", &gmacdev->macid)
> +		|| of_property_read_u32(np, "qcom,emulation", &gmaccfg->emulation)
> +		|| of_property_read_u32(np, "qcom,phy_mii_type", &gmaccfg->phy_mii_type)
> +		|| of_property_read_u32(np, "qcom,phy_mdio_addr", &gmaccfg->phy_mdio_addr)
> +		|| of_property_read_u32(np, "qcom,rgmii_delay", &gmaccfg->rgmii_delay)
> +		|| of_property_read_u32(np, "qcom,poll_required", &gmaccfg->poll_required)
> +		|| of_property_read_u32(np, "qcom,forced_speed", &gmaccfg->forced_speed)
> +		|| of_property_read_u32(np, "qcom,forced_duplex", &gmaccfg->forced_duplex)
> +		|| of_property_read_u32(np, "qcom,irq", &netdev->irq)
> +		|| of_property_read_u32(np, "qcom,socver", &gmaccfg->socver)) {

This is not an acceptable way to pass data from DT, please use the standard properties.

> +	if (test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
> +#if (LINUX_VERSION_CODE <= KERNEL_VERSION(3, 8, 0))
> +		gmacdev->phydev = phy_connect(netdev, (const char *)phy_id,
> +					      &nss_gmac_adjust_link, 0, phyif);
> +#else
> +		gmacdev->phydev = phy_connect(netdev, (const char *)phy_id,
> +					      &nss_gmac_adjust_link, phyif);
> +#endif

Drop all LINUX_VERSION_CODE checks

> +		if (IS_ERR_OR_NULL(gmacdev->phydev)) {
> +			netdev_dbg(netdev, "PHY %s attach FAIL", phy_id);
> +			ret = -EIO;
> +			goto nss_gmac_phy_attach_fail;
> +		}

Also any IS_ERR_OR_NULL checks, you are using the API incorrectly.

> +static struct of_device_id nss_gmac_dt_ids[] = {
> +	{ .compatible =  "qcom,nss-gmac0" },
> +	{ .compatible =  "qcom,nss-gmac1" },
> +	{ .compatible =  "qcom,nss-gmac2" },
> +	{ .compatible =  "qcom,nss-gmac3" },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, nss_gmac_dt_ids);

Are all four versions supported by this driver?

Each one of these needs its own devicetree binding that documents which
hardware it is for and what the supported DT properties are.

> +static struct platform_driver nss_gmac_drv = {
> +	.probe = nss_gmac_probe,
> +	.remove = nss_gmac_remove,
> +	.driver = {
> +		   .name = "nss-gmac",
> +		   .owner = THIS_MODULE,
> +#ifdef CONFIG_OF
> +		   .of_match_table = of_match_ptr(nss_gmac_dt_ids),
> +#endif

The redundancy here is redundant and unnecessary.

> +
> +/**
> + * @brief IOCTL interface.
> + * This function is mainly for debugging purpose.
> + * This provides hooks for Register read write, Retrieve descriptor status
> + * and Retreiving Device structure information.
> + * @param[in] pointer to net_device structure.
> + * @param[in] pointer to ifreq structure.
> + * @param[in] ioctl command.
> + * @return Returns 0 on success Error code on failure.
> + */
> +static int32_t nss_gmac_linux_do_ioctl(struct net_device *netdev,
> +                                      struct ifreq *ifr, int32_t cmd)
> +{

Remove the private ioctls.

> +/**
> + * @brief Stats Callback to receive statistics from NSS
> + * @param[in] pointer to gmac context
> + * @param[in] pointer to gmac statistics
> + * @return Returns void.
> + */
> +static void nss_gmac_stats_receive(struct nss_gmac_dev *gmacdev,
> +					struct nss_gmac_stats *gstat)
> +{
...
> +}
> +EXPORT_SYMBOL(nss_gmac_receive);

Why multiple modules instead of linking everything together?

> +
> +/**
> + * NSS Driver interface APIs
> + */

What is an NSS driver?

> +/*
> + * nss_gmac_open_work()
> + *	Schedule delayed work to open the netdev again
> + */
> +void nss_gmac_open_work(struct work_struct *work)
> +{
> +	struct nss_gmac_dev *gmacdev = container_of(to_delayed_work(work),
> +						struct nss_gmac_dev, gmacwork);
> +
> +	netdev_dbg(gmacdev->netdev, "Do the network up in delayed queue %s\n",
> +							gmacdev->netdev->name);
> +	nss_gmac_linux_open(gmacdev->netdev);
> +}

You seem to have an operating system abstraction layer in here. We know
which OS we are running on, so please remove the abstraction.

	Arnd
