From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [netdrvr ixgb] massive update
Date: Fri, 28 May 2004 21:48:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040528214811.A8239@electric-eye.fr.zoreil.com>
References: <200405280814.i4S8EHcu027730@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ayyappan.Veeraiyan@intel.com
Content-Disposition: inline
In-Reply-To: <200405280814.i4S8EHcu027730@hera.kernel.org>; from linux-kernel@vger.kernel.org on Thu, May 27, 2004 at 08:22:20PM +0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List <linux-kernel@vger.kernel.org> :
> diff -Nru a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
> --- a/drivers/net/ixgb/ixgb.h	2004-05-28 01:14:26 -07:00
> +++ b/drivers/net/ixgb/ixgb.h	2004-05-28 01:14:26 -07:00
[...]
> @@ -33,9 +34,9 @@
>  #define IXGB_ETH_LENGTH_OF_ADDRESS   6
>  
>  /* EEPROM Commands */
> -#define EEPROM_READ_OPCODE  0x6		/* EERPOM read opcode */
> -#define EEPROM_WRITE_OPCODE 0x5		/* EERPOM write opcode */
> -#define EEPROM_ERASE_OPCODE 0x7		/* EERPOM erase opcode */
> +#define EEPROM_READ_OPCODE  0x6	/* EERPOM read opcode */
> +#define EEPROM_WRITE_OPCODE 0x5	/* EERPOM write opcode */
> +#define EEPROM_ERASE_OPCODE 0x7	/* EERPOM erase opcode */
>  #define EEPROM_EWEN_OPCODE  0x13	/* EERPOM erase/write enable */
>  #define EEPROM_EWDS_OPCODE  0x10	/* EERPOM erast/write disable */
                                           ^^^^^^ 
Oops. :o)

[...]
> diff -Nru a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
> --- a/drivers/net/ixgb/ixgb_ethtool.c	2004-05-28 01:14:26 -07:00
> +++ b/drivers/net/ixgb/ixgb_ethtool.c	2004-05-28 01:14:26 -07:00
[...]
> @@ -405,114 +453,121 @@
[...]
> -#if defined(ETHTOOL_GREGS) && defined(ETHTOOL_GEEPROM)
> +	case ETHTOOL_GSTRINGS:{
> +			struct ethtool_gstrings gstrings = { ETHTOOL_GSTRINGS };
> +			char *strings = NULL;
> +			int err = 0;

Indentation is wrong.

> +
> +			if (copy_from_user(&gstrings, addr, sizeof(gstrings)))
> +				return -EFAULT;
> +			switch (gstrings.string_set) {
> +			case ETH_SS_STATS:{
> +					int i;
> +					gstrings.len = IXGB_STATS_LEN;
> +					strings =
> +					    kmalloc(IXGB_STATS_LEN *
> +						    ETH_GSTRING_LEN,
> +						    GFP_KERNEL);
> +					if (!strings)
> +						return -ENOMEM;
> +					for (i = 0; i < IXGB_STATS_LEN; i++) {
> +						memcpy(&strings
> +						       [i * ETH_GSTRING_LEN],
> +						       ixgb_gstrings_stats[i].
> +						       stat_string,
> +						       ETH_GSTRING_LEN);

An helper function could improve a few things. Simply getting the indentation
right would be enough.

[...]
> @@ -533,13 +588,133 @@
>  	case ETHTOOL_SEEPROM:{
>  			struct ethtool_eeprom eeprom;
>  
> -			IXGB_DBG("ETHTOOL_SEEPROM\n");
> -			if (copy_from_user(&eeprom, addr, sizeof (eeprom)))
> +			if (copy_from_user(&eeprom, addr, sizeof(eeprom)))
>  				return -EFAULT;
>  
>  			addr += offsetof(struct ethtool_eeprom, data);
>  			return ixgb_ethtool_seeprom(adapter, &eeprom, addr);
>  		}
> +	case ETHTOOL_GPAUSEPARAM:{
> +			struct ethtool_pauseparam epause =
> +			    { ETHTOOL_GPAUSEPARAM };
> +			ixgb_ethtool_gpause(adapter, &epause);
> +			if (copy_to_user(addr, &epause, sizeof(epause)))
> +				return -EFAULT;
> +			return 0;
> +		}
> +	case ETHTOOL_SPAUSEPARAM:{
> +			struct ethtool_pauseparam epause;
> +			if (copy_from_user(&epause, addr, sizeof(epause)))
> +				return -EFAULT;
> +			return ixgb_ethtool_spause(adapter, &epause);
> +		}
> +	case ETHTOOL_GSTATS:{
> +			struct {
> +				struct ethtool_stats eth_stats;
> +				uint64_t data[IXGB_STATS_LEN];
> +			} stats = { {
> +			ETHTOOL_GSTATS, IXGB_STATS_LEN}};
> +			int i;
> +
> +			for (i = 0; i < IXGB_STATS_LEN; i++)
> +				stats.data[i] =
> +				    (ixgb_gstrings_stats[i].sizeof_stat ==
> +				     sizeof(uint64_t)) ? *(uint64_t *) ((char *)
> +									adapter
> +									+
> +									ixgb_gstrings_stats
> +									[i].
> +									stat_offset)
> +				    : *(uint32_t *) ((char *)adapter +
> +						     ixgb_gstrings_stats[i].
> +						     stat_offset);

Either someone spent too much time in the kernel CIFS code or this code
has never been reviewed.

[...]
> diff -Nru a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
> --- a/drivers/net/ixgb/ixgb_hw.c	2004-05-28 01:14:26 -07:00
> +++ b/drivers/net/ixgb/ixgb_hw.c	2004-05-28 01:14:26 -07:00
[...]
> @@ -134,27 +136,111 @@
>  }
>  
>  /******************************************************************************
> + * Identifies the vendor of the optics module on the adapter.  The SR adapters
> + * support two different types of XPAK optics, so it is necessary to determine
> + * which optics are present before applying any optics-specific workarounds.
> + *
> + * hw - Struct containing variables accessed by shared code.
> + *
> + * Returns: the vendor of the XPAK optics module.
> + *****************************************************************************/
> +static ixgb_xpak_vendor ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
> +{
> +	uint32_t i;
> +	uint16_t vendor_name[5];
> +	ixgb_xpak_vendor xpak_vendor;
> +
> +	DEBUGFUNC("ixgb_identify_xpak_vendor");
> +
> +	/* Read the first few bytes of the vendor string from the XPAK NVR
> +	 * registers.  These are standard XENPAK/XPAK registers, so all XPAK
> +	 * devices should implement them. */
> +	for (i = 0; i < 5; i++) {
> +		vendor_name[i] = ixgb_read_phy_reg(hw,
> +						   MDIO_PMA_PMD_XPAK_VENDOR_NAME
> +						   + i, IXGB_PHY_ADDRESS,
> +						   MDIO_PMA_PMD_DID);

:o/


[...]
> diff -Nru a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
> --- a/drivers/net/ixgb/ixgb_main.c	2004-05-28 01:14:26 -07:00
> +++ b/drivers/net/ixgb/ixgb_main.c	2004-05-28 01:14:26 -07:00
[...]
> @@ -300,35 +284,29 @@
>  	int mmio_len;
>  	int pci_using_dac;
>  	int i;
> +	int err;
>  
> -	IXGB_DBG("ixgb_probe\n");
> +	if ((err = pci_enable_device(pdev)))
> +		return err;

>  
> -	if ((i = pci_enable_device(pdev))) {
> -		IXGB_ERR("pci_enable_device failed\n");
> -		return i;
> -	}
> -
> -	if (!(i = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
> +	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
>  		pci_using_dac = 1;
>  	} else {
> -		if ((i = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
> +		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
>  			IXGB_ERR("No usable DMA configuration, aborting\n");
> -			return i;
> +			return err;

The previos block hould pci_disable_device() before returning. "gotos" are
used below. There is no reason to mix styles.

>  		}
>  		pci_using_dac = 0;
>  	}
>  
> -	if ((i = pci_request_regions(pdev, ixgb_driver_name))) {
> -		IXGB_ERR("Failed to reserve PCI I/O and Memory resources.\n");
> -		return i;
> -	}
> +	if ((err = pci_request_regions(pdev, ixgb_driver_name)))
> +		return err;

Same thing.

>  
>  	pci_set_master(pdev);
>  
> -	/* alloc_etherdev clears the memory for us */
> -	netdev = alloc_etherdev(sizeof (struct ixgb_adapter));
> +	netdev = alloc_etherdev(sizeof(struct ixgb_adapter));
>  	if (!netdev) {
> -		IXGB_ERR("Unable to allocate net_device struct\n");
> +		err = -ENOMEM;
>  		goto err_alloc_etherdev;
                     ^^^^^^^^^^^^^^^^^^
The label should say what the unroll code is supposed to do, not
where it comes from: please name it something like "err_release_regions".
This way, when one reads the previous lines, the branching label _seems_
to make sense and when one actually read the real unroll code (at a
completely different time), it is easy to check that the error exit code
really does what it is supposed to.

[...]
> @@ -370,25 +348,28 @@
>  	netdev->tx_timeout = &ixgb_tx_timeout;
>  	netdev->watchdog_timeo = HZ;
>  #ifdef CONFIG_IXGB_NAPI
> -	netdev->poll = &ixgb_poll;
> +	netdev->poll = &ixgb_clean;
>  	netdev->weight = 64;

...

[...]
> @@ -403,57 +384,59 @@
>  	/* make sure the EEPROM is good */
>  
>  	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
> -		IXGB_DBG("Invalid EEPROM checksum.\n");
> +		printk(KERN_ERR "The EEPROM Checksum Is Not Valid\n");
> 		err = -EIO;

What about :
	err = ixgb_validate_eeprom_checksum(..."
	if (err < 0) {
		yada, yada...


>  		goto err_eeprom;
>  	}
>  
>  	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
>  
>  	if (!is_valid_ether_addr(netdev->dev_addr)) {
> -		IXGB_DBG("Invalid MAC address in EEPROM.\n");
> +		err = -EIO;
>  		goto err_eeprom;
>  	}

Same remark.

>  
> -	adapter->max_data_per_txd = IXGB_MAX_JUMBO_FRAME_SIZE;
>  	adapter->part_num = ixgb_get_ee_pba_number(&adapter->hw);
>  
>  	init_timer(&adapter->watchdog_timer);
>  	adapter->watchdog_timer.function = &ixgb_watchdog;
> -	adapter->watchdog_timer.data = (unsigned long) adapter;
> +	adapter->watchdog_timer.data = (unsigned long)adapter;
>  
>  	INIT_WORK(&adapter->tx_timeout_task,
> -		  (void (*)(void *)) ixgb_tx_timeout_task, netdev);
> +		  (void (*)(void *))ixgb_tx_timeout_task, netdev);
>  
> -	register_netdev(netdev);
> -	memcpy(adapter->ifname, netdev->name, IFNAMSIZ);
> -	adapter->ifname[IFNAMSIZ - 1] = 0;
> +	if ((err = register_netdev(netdev)))
> +		goto err_register;

The following has already been suggested in a not too far past:
	err = ...
	if (err < 0) {

>  
>  	/* we're going to reset, so assume we have no link for now */
>  
>  	netif_carrier_off(netdev);
>  	netif_stop_queue(netdev);
>  
> -	printk(KERN_INFO "%s: %s\n", netdev->name, adapter->id_string);
> +	printk(KERN_INFO "%s: Intel(R) PRO/10GbE Network Connection\n",
> +	       netdev->name);
>  	ixgb_check_options(adapter);
> -
>  	/* reset the hardware with the new settings */
> +
>  	ixgb_reset(adapter);
>  
>  	cards_found++;
>  	return 0;
>  
> +      err_register:
> +      err_sw_init:
>        err_eeprom:

What's the point of the three different labels ?

>  	iounmap(adapter->hw.hw_addr);
>        err_ioremap:
> -	pci_release_regions(pdev);
>  	free_netdev(netdev);
>        err_alloc_etherdev:

Please put the label at the start of the line or anything of your choice
as long as it is easier to identify.

> -	return -ENOMEM;
> +	pci_release_regions(pdev);
> +	return err;

Missing pci_disable_device().

[...]
> @@ -461,49 +444,36 @@
>   * memory.
>   **/
>  
> -static void __devexit
> -ixgb_remove(struct pci_dev *pdev)
> +static void __devexit ixgb_remove(struct pci_dev *pdev)
>  {
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct ixgb_adapter *adapter = netdev->priv;
>  
> -	IXGB_DBG("ixgb_remove\n");
> -
>  	unregister_netdev(netdev);
>  
> -#ifdef ETHTOOL_IDENTIFY
> -	ixgb_identify_stop(adapter);
> -#endif
> -
> -	iounmap((void *) adapter->hw.hw_addr);
> +	iounmap(adapter->hw.hw_addr);
>  	pci_release_regions(pdev);

Missing pci_disable_device()...

Please Cc: the next patch(es) to netdev@oss.sgi.com for review. Giant
patches like this are a pain to review.

Thanks.

--
Ueimor
