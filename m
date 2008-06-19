From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/12] benet: header and initialization functions
Date: Thu, 19 Jun 2008 06:11:40 -0400
Message-ID: <20080619101140.GA17697@infradead.org>
References: <20080612103612.a20cb63d@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53296 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbYFSKLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 06:11:42 -0400
Content-Disposition: inline
In-Reply-To: <20080612103612.a20cb63d@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int
> +be_netdev_init(struct be_adapter *adapter, struct bni_net_object *pnob)
> +{
> +	struct net_device *netdev = OSM_NOB(pnob)->netdev;
> +
> +	bni_get_uc_mac_adrr(pnob, 0, 0, OSM_NOB(pnob)->devno,
> +		(u8 *)netdev->dev_addr, NULL, NULL);
> +
> +	netdev->init = &benet_init;
> +	netif_carrier_off(netdev);
> +	netif_stop_queue(netdev);
> +
> +	SET_NETDEV_DEV(netdev, &(adapter->pdev->dev));
> +	return register_netdev(netdev);
> +}

Please just inline this into the only caller.  That will also show
that the register_netdev is done far too early - it should only happen
when the device is fully setup.  As a little style nitpick the braces
in &(adapter->pdev->dev) are not needed.

> +/* Initialize the pci_info structure for this function */
> +static int
> +init_pci_be_function(struct be_adapter *adapter, struct pci_dev *pdev)
> +{
> +	adapter->num_bars = 3;
> +	/* CSR */
> +	adapter->pci_bars[0].base_pa = pci_resource_start(pdev, 2);
> +	adapter->pci_bars[0].base_va =
> +	    ioremap_nocache(adapter->pci_bars[0].base_pa,
> +			    pci_resource_len(pdev, 2));
> +	if (adapter->pci_bars[0].base_va == NULL)
> +		return -ENOMEM;

What do you need the pci_bars structure for?  The base_pa member
shouldn't be needed.

> +
> +	status = pci_request_regions(pdev, be_driver_name);
> +	if (status) {
> +		pci_disable_device(pdev);
> +		goto error;
> +	}
> +
> +	pci_set_master(pdev);
> +	adapter = kzalloc(sizeof(struct be_adapter), GFP_KERNEL);
> +	if (adapter == NULL) {
> +		pci_release_regions(pdev);
> +		pci_disable_device(pdev);
> +		status = -ENOMEM;
> +		goto error;

Please don't use a single goto error but one goto for each cleanup
step to make sure you don't miss any cleanup parts.  Take a look
at drivers/net/tg3.c:tg3_init_one() for an example.

> +	adapter->be_link_sts = (struct BE_LINK_STATUS *)
> +	    kmalloc(sizeof(struct BE_LINK_STATUS), GFP_KERNEL);

No need to cast kmalloc return values.   Btw, did you run these
patches through scripts/checkpatch.pl?  I'd be surprised if it doesn't
complain quite a bit..

> +static int __init be_init_module(void)
> +{
> +	int ret;
> +
> +	if ((rxbuf_size != 8192) && (rxbuf_size != 4096)
> +	    && (rxbuf_size != 2048)) {

Nipick:

	if (rxbuf_size != 8192 && rxbuf_size != 4096 && rxbuf_size != 2048) {

> + * linux_net_object is an extension to BNI's NetObject structure.
> + * NetObject has a pointer to this structure
> + */

So just merged it into the NetObject structure.

> +/* functions to update RX/TX rates */
> +static inline void
> +update_rx_rate(struct be_adapter *adapter)
> +{
> +	/* update the rate once in two seconds */
> +	if ((jiffies - adapter->eth_rx_jiffies) > 2*(HZ)) {
> +		u32 r;
> +		r = adapter->eth_rx_bytes /
> +			((jiffies-adapter->eth_rx_jiffies)/(HZ));
> +		r = (r / 1000000); /* MB/Sec */
> +		adapter->be_stat.bes_eth_rx_rate = (r * 8); /* Mega Bits/Sec */
> +		adapter->eth_rx_jiffies = jiffies;
> +		adapter->eth_rx_bytes = 0;
> +	}
> +}

This and the following inlines are far too large to be inlined, please
move them out of line.

> +/*
> +@brief
> +    This structure is used by the OSM driver to give BNI
> +    physical fragments to use for DMAing data from NIC.
> +*/

Please use proper kerneldoc comment to describe the data structures.

> +/*
> + * convenience macros to access some NetObject members
> + */
> +#define NET_FH(np)       (&(np)->fn_obj)

Just doing that derference would be a lot easier to read :)

