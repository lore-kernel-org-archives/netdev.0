From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCHv8 3/3] net: velocity: Add platform device support to VIA
 velocity driver
Date: Sat, 18 May 2013 20:55:26 +0200
Message-ID: <20130518185526.GA25486@electric-eye.fr.zoreil.com>
References: <1368853187-17823-1-git-send-email-linux@prisktech.co.nz>
 <1368853187-17823-4-git-send-email-linux@prisktech.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Tony Prisk <linux@prisktech.co.nz>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1368853187-17823-4-git-send-email-linux@prisktech.co.nz>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Tony Prisk <linux@prisktech.co.nz> :
[...]
> diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
> index 5996cee..d8d5bc5 100644
> --- a/drivers/net/ethernet/via/via-velocity.c
> +++ b/drivers/net/ethernet/via/via-velocity.c
[...]
> @@ -84,6 +88,16 @@
>  static int velocity_nics;
>  static int msglevel = MSG_LEVEL_INFO;
>  
> +static void velocity_set_power_state(struct velocity_info *vptr, char state)
> +{
> +	void *addr = vptr->mac_regs;

Your choice but it's only used once.

[...]
> @@ -1353,9 +1366,12 @@ static void velocity_init_registers(struct velocity_info *vptr,
>  		velocity_soft_reset(vptr);
>  		mdelay(5);
>  
> -		mac_eeprom_reload(regs);
> -		for (i = 0; i < 6; i++)
> -			writeb(vptr->netdev->dev_addr[i], &(regs->PAR[i]));
> +		if (!vptr->no_eeprom) {
> +			mac_eeprom_reload(regs);
> +			for (i = 0; i < 6; i++)
> +				writeb(vptr->netdev->dev_addr[i],
> +							&(regs->PAR[i]));
> +		}

velocity_init_registers would not suffer from a local vptr->netdev variable.

If you change this code, you may replace &(regs->PAR[i]) with regs->PAR + i.

[...]
> @@ -2730,19 +2773,19 @@ static int velocity_found1(struct pci_dev *pdev,
>  	 * can support more than MAX_UNITS.
>  	 */
>  	if (velocity_nics >= MAX_UNITS) {
> -		dev_notice(&pdev->dev, "already found %d NICs.\n",
> -			   velocity_nics);
> +		dev_notice(dev, "already found %d NICs.\n", velocity_nics);
>  		return -ENODEV;
>  	}
>  
> -	dev = alloc_etherdev(sizeof(struct velocity_info));
> -	if (!dev)
> +	netdev = alloc_etherdev(sizeof(struct velocity_info));
> +	if (!netdev)
>  		goto out;
>  
>  	/* Chain it all together */
>  
> -	SET_NETDEV_DEV(dev, &pdev->dev);
> -	vptr = netdev_priv(dev);
> +	SET_NETDEV_DEV(netdev, dev);
> +	vptr = netdev_priv(netdev);
> +	memset(vptr, 0, sizeof(struct velocity_info));

memset is not needed (alloc_etherdev indirectly uses kzalloc).

[...]
> +static int velocity_pci_probe(struct pci_dev *pdev,
> +			   const struct pci_device_id *ent)

It does not seem to line up as it should.

> +{
> +	int ret;
> +	const struct velocity_info_tbl *info =
> +					&chip_info_table[ent->driver_data];

Long lines ought to come first.

> +
> +	ret = pci_enable_device(pdev);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = pci_request_regions(pdev, VELOCITY_NAME);
> +	if (ret < 0) {
> +		dev_err(&pdev->dev, "No PCI resources.\n");
> +		pci_disable_device(pdev);
> +		return ret;
> +	}
> +
> +	ret = velocity_probe(&pdev->dev, pdev->irq, info, BUS_PCI);
> +	if (ret < 0) {
> +		pci_release_regions(pdev);
> +		pci_disable_device(pdev);
> +	}

Please use gotos for the error paths.

[...]
> @@ -3270,7 +3409,11 @@ static void velocity_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo
>  	struct velocity_info *vptr = netdev_priv(dev);
>  	strlcpy(info->driver, VELOCITY_NAME, sizeof(info->driver));

You may sneak an empty line after the declaration.

>  	strlcpy(info->version, VELOCITY_VERSION, sizeof(info->version));
> -	strlcpy(info->bus_info, pci_name(vptr->pdev), sizeof(info->bus_info));
> +	if (vptr->bustype == BUS_PCI)
> +		strlcpy(info->bus_info, pci_name(vptr->pdev),
> +						sizeof(info->bus_info));
> +	else
> +		strlcpy(info->bus_info, "platform", sizeof(info->bus_info));

	strlcpy(info->bus_info, vptr->pdev ? pci_name(vptr->pdev) : "platform",
		sizeof(info->bus_info));

>  static void velocity_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> @@ -3563,9 +3706,15 @@ static int __init velocity_init_module(void)
>  	int ret;
>  
>  	velocity_register_notifier();
> -	ret = pci_register_driver(&velocity_driver);
> +
> +	ret = pci_register_driver(&velocity_pci_driver);
> +	if (ret < 0)
> +		velocity_unregister_notifier();
> +
> +	ret = platform_driver_register(&velocity_platform_driver);
>  	if (ret < 0)
>  		velocity_unregister_notifier();
> +

I'd rather velocity_unregister_notifier iif both driver registrations
failed.

[...]
> diff --git a/drivers/net/ethernet/via/via-velocity.h b/drivers/net/ethernet/via/via-velocity.h
> index c38bbae..1d94612 100644
> --- a/drivers/net/ethernet/via/via-velocity.h
> +++ b/drivers/net/ethernet/via/via-velocity.h
[...]
> @@ -1433,10 +1433,17 @@ struct velocity_opt {
>  
>  #define GET_RD_BY_IDX(vptr, idx)   (vptr->rd_ring[idx])
>  
> +enum velocity_bus_type {
> +	BUS_PCI,
> +	BUS_PLATFORM,
> +};
> +
>  struct velocity_info {
> -	struct device *dev;
>  	struct pci_dev *pdev;
> +	struct device *dev;

Please don't move the fields you added.

>  	struct net_device *netdev;
> +	enum velocity_bus_type bustype;

velocity_bus_type is not really needed since you always have pdev to
check against.

-- 
Ueimor
