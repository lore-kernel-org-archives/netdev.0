From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sat, 26 Feb 2005 19:26:58 +0100
Message-ID: <20050226182658.GB13230@electric-eye.fr.zoreil.com>
References: <42208D83.80803@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>, netdev@oss.sgi.com, jgarzik@pobox.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <42208D83.80803@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> @@ -1531,6 +1620,11 @@ static int rtl8169_open(struct net_devic
>  	if (retval < 0)
>  		goto err_free_rx;
>  
> +	tp->nic_stats = pci_alloc_consistent(pdev, R8169_STATS_BYTES,
> +					     &tp->nic_stats_addr);
> +	if (!tp->nic_stats)
> +		goto err_free_nic_stats;
> +
>  	INIT_WORK(&tp->task, NULL, dev);
>  
>  	rtl8169_hw_start(dev);
> @@ -1541,6 +1635,10 @@ static int rtl8169_open(struct net_devic
>  out:
>  	return retval;
>  
> +err_free_nic_stats:
> +	pci_free_consistent(pdev, R8169_STATS_BYTES, tp->nic_stats,
> +			    tp->nic_stats_addr);
> +

You don't want to free it it was not allocated. Please undo the previous
step (init_ring probably) and:
1) use the form "goto err_descriptive_name_for_the_release_work";
2) if you feel it does not protect against wrong ordering as:
   if (...)
 	goto err_foo;
   if (...)
	goto err_bar;
   [...]
   err_foo:
	...
   err_bar:
	...
   then add extra numbering:
   if (...)
	goto err_foo_0;
   if (...)
	goto err_bar_1;
   [...]
   err_bar_1:
	...
   err_foo_0:
	...
   It is not perfect but it is error proof (something the "goto err_1"
   way alone can not claim btw).

--
Ueimor
