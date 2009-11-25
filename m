From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [rfc 2/3 v2] [rfc 3/4] igb: Common error path in
 igb_init_vfs()
Date: Wed, 25 Nov 2009 14:35:24 -0800
Message-ID: <4B0DB12C.3030709@intel.com>
References: <20091125063213.203372240@vergenet.net>
	<20091125063531.218106764@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Bergmann <arndbergmann@googlemail.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20091125063531.218106764@vergenet.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> Drop out into an error path on error.
> 
> This is a bit superfluous as things stand, though arguably
> it already makes the code cleaner. But it should help things a lot
> if igb_init_vfs() has a several things to unwind on error.
> 
> This patch eliminates resetting adapter->vfs_allocated_count to 0
> in the case where CONFIG_PCI_IOV is not set, because in that
> case adapter->vfs_allocated_count can never be non-zero.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> Thu, 05 Nov 2009 11:58:50 +1100
> * Initial post
> 
> Wed, 25 Nov 2009 16:44:15 +1100
> * Merged with " Initialise adapter->vfs_allocated_count in igb_init_vf()",
>   however the initialisation of adapter->vfs_allocated_count is no
>   longer moved into igb_init_vf() as doing so results in a panic.
> 
> Index: net-next-2.6/drivers/net/igb/igb_main.c
> ===================================================================
> --- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-25 17:05:43.000000000 +1100
> +++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-25 17:05:44.000000000 +1100
> @@ -1753,38 +1753,37 @@ static void __devinit igb_init_vf(struct
>  {
>  #ifdef CONFIG_PCI_IOV
>  	struct pci_dev *pdev = adapter->pdev;
> +	unsigned char mac_addr[ETH_ALEN];
> +	int i;
>  
>  	if (adapter->vfs_allocated_count > 7)
>  		adapter->vfs_allocated_count = 7;
>  
> -	if (adapter->vfs_allocated_count) {
> -		adapter->vf_data = kcalloc(adapter->vfs_allocated_count,
> -		                           sizeof(struct vf_data_storage),
> -		                           GFP_KERNEL);
> -		/* if allocation failed then we do not support SR-IOV */
> -		if (!adapter->vf_data) {
> -			adapter->vfs_allocated_count = 0;
> -			dev_err(&pdev->dev, "Unable to allocate memory for VF "
> -			        "Data Storage\n");
> -		}
> +	adapter->vf_data = kcalloc(adapter->vfs_allocated_count,
> +				   sizeof(struct vf_data_storage), GFP_KERNEL);
> +	/* if allocation failed then we do not support SR-IOV */
> +	if (!adapter->vf_data) {
> +		dev_err(&pdev->dev, "Unable to allocate memory for VF "
> +		        "Data Storage\n");
> +		goto err_zero;
>  	}
>  
The only issue I see with the changes above is that if SR-IOV is not 
enabled via the max_vfs option you will end up returning an error even 
though there is nothing wrong.  You might want to go and keep the if 
statement near the start and do something like:
	if (!adapter->vfs_allocated_count)
		goto err_zero;

This way you can avoid the false error report.

> -	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count)) {
> -		kfree(adapter->vf_data);
> -		adapter->vf_data = NULL;
> -#endif /* CONFIG_PCI_IOV */
> -		adapter->vfs_allocated_count = 0;
> -#ifdef CONFIG_PCI_IOV
> -	} else {
> -		unsigned char mac_addr[ETH_ALEN];
> -		int i;
> -		dev_info(&pdev->dev, "%d vfs allocated\n",
> -		         adapter->vfs_allocated_count);
> -		for (i = 0; i < adapter->vfs_allocated_count; i++) {
> -			random_ether_addr(mac_addr);
> -			igb_set_vf_mac(adapter, i, mac_addr);
> -		}
> +	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count))
> +		goto err_free;
> +
> +	dev_info(&pdev->dev, "%d vfs allocated\n",
> +		 adapter->vfs_allocated_count);
> +	for (i = 0; i < adapter->vfs_allocated_count; i++) {
> +		random_ether_addr(mac_addr);
> +		igb_set_vf_mac(adapter, i, mac_addr);
>  	}
> +
> +	return;
> +err_free:
> +	kfree(adapter->vf_data);
> +err_zero:
> +	adapter->vf_data = NULL;
> +	adapter->vfs_allocated_count = 0;
>  #endif /* CONFIG_PCI_IOV */
>  }
>  
> 

My preference here would be to bump the #endif up two lines so that 
adapter->vf_data = NULL and adapter->vfs_allocated_count = 0 are ran in 
the non-iov case.  That way we know that SR-IOV is explicitly disabled.

Thanks,

Alex

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
