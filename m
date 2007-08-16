From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [patch 4/4] Update e1000 driver to use devres.
Date: Thu, 16 Aug 2007 01:38:02 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329036D21B5@orsmsx414.amr.corp.intel.com>
References: <20070815190014.GE7294@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: teheo@suse.de
To: "Brandon Philips" <bphilips@suse.de>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20070815190014.GE7294@ifup.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -860,15 +860,14 @@ e1000_probe(struct pci_dev *pdev,  {
>  	struct net_device *netdev;
>  	struct e1000_adapter *adapter;
> -	unsigned long mmio_start, mmio_len;
> -	unsigned long flash_start, flash_len;
> +	unsigned long mmio_len, flash_len;
>  
>  	static int cards_found = 0;
>  	static int global_quad_port_a = 0; /* global ksp3 port 
> a indication */
>  	int i, err, pci_using_dac;
>  	uint16_t eeprom_data = 0;
>  	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
> -	if ((err = pci_enable_device(pdev)))
> +	if ((err = pcim_enable_device(pdev)))
>  		return err;
>  
>  	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) && 
> @@ -878,20 +877,19 @@ e1000_probe(struct pci_dev *pdev,
>  		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) &&
>  		    (err = pci_set_consistent_dma_mask(pdev, 
> DMA_32BIT_MASK))) {
>  			E1000_ERR("No usable DMA configuration, 
> aborting\n");
> -			goto err_dma;
> +			return err;
>  		}
>  		pci_using_dac = 0;
>  	}
>  
>  	if ((err = pci_request_regions(pdev, e1000_driver_name)))
> -		goto err_pci_reg;
> +		return err;
>  
>  	pci_set_master(pdev);
>  
> -	err = -ENOMEM;
> -	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
> +	netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct 
> +e1000_adapter));
>  	if (!netdev)
> -		goto err_alloc_etherdev;
> +		return -ENOMEM;

I'm a bit confused why you removed the goto's, and then removed all the
target unwinding code at the bottom of e1000_probe().   Those labels
clean up resources if something fails, like the err_sw_init label.  I
don't see anything in the devres code that jumps out at me that explains
why we can do away with these cleanup routines.  Thoughts?

Thanks,
-PJ Waskiewicz

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
