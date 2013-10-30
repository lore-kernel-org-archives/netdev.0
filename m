From: Joby Poriyath <joby.poriyath@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: allocate xenvif arrays using
 vzalloc.
Date: Wed, 30 Oct 2013 10:39:59 +0000
Message-ID: <20131030103958.GB3261@citrix.com>
References: <20131029152628.GA3065@citrix.com>
 <1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029184647.GA3261@citrix.com>
 <1383089055.4176.1.camel@edumazet-glaptop.roam.corp.google.com>
 <1383089532.4857.1.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<andrew.bennieston@citrix.com>, <david.vrabel@citrix.com>,
	<malcolm.crossley@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8142 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab3J3KkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 06:40:01 -0400
Content-Disposition: inline
In-Reply-To: <1383089532.4857.1.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 04:32:12PM -0700, Eric Dumazet wrote:
> On Tue, 2013-10-29 at 16:24 -0700, Eric Dumazet wrote:
> > On Tue, 2013-10-29 at 18:46 +0000, Joby Poriyath wrote:
> > > On Tue, Oct 29, 2013 at 08:43:50AM -0700, Eric Dumazet wrote:
> > > > On Tue, 2013-10-29 at 15:27 +0000, Joby Poriyath wrote:
> > > > > This will reduce memory pressure when allocating struct xenvif.
> > > > > 
> > > > > The size of xenvif struct has increased from 168 to 36632 bytes (on x86-32).
> > > > > See commit b3f980bd827e6e81a050c518d60ed7811a83061d. This resulted in
> > > > > occasional netdev allocation failure in dom0 with 752MiB RAM, due to
> > > > > fragmented memory.
> > > > 
> > > > This looks overkill. 
> > > > 
> > > > Replacing a single allocation of ~36 KB into 5 vmalloc() looks like you
> > > > did not really tried other things...
> > > > 
> > > > This should be done generically in alloc_netdev_mqs()
> > > 
> > > Sorry Eric, I didn't quite understand how this can be generically done.
> > > 
> > > The netback interfaces are tied to the Xen guests (VMs) and these are created 
> > > when guests are started and deleted when guest are halted.
> > 
> > They are created by alloc_netdev_mqs()
> 
> Something like the following should be fine.
> 
> 
> 

Thanks for the patch.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0054c8c..874a57a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6239,7 +6239,9 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
>  	/* ensure 32-byte alignment of whole construct */
>  	alloc_size += NETDEV_ALIGN - 1;
>  
> -	p = kzalloc(alloc_size, GFP_KERNEL);
> +	p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> +	if (!p)
> +		p = vzalloc(alloc_size);
>  	if (!p)
>  		return NULL;
>  

The net_device allocation rule {linux/Documentation/networking/netdevices.txt} states
that net_device struct must be allocated using kmalloc.

Is this safe to do?

> @@ -6302,7 +6304,10 @@ free_pcpu:
>  #endif
>  
>  free_p:
> -	kfree(p);
> +	if (is_vmalloc_addr(p))
> +		vfree(p);
> +	else
> +		kfree(p);
>  	return NULL;
>  }
>  EXPORT_SYMBOL(alloc_netdev_mqs);
> @@ -6339,7 +6344,12 @@ void free_netdev(struct net_device *dev)
>  
>  	/*  Compatibility with error handling in drivers */
>  	if (dev->reg_state == NETREG_UNINITIALIZED) {
> -		kfree((char *)dev - dev->padded);
> +		char *addr = (char *)dev - dev->padded;
> +
> +		if (is_vmalloc_addr(addr))
> +			vfree(addr);
> +		else
> +			kfree(addr);
>  		return;
>  	}
>  
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index d954b56..406c54b 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -1259,11 +1259,16 @@ exit:
>  static void netdev_release(struct device *d)
>  {
>  	struct net_device *dev = to_net_dev(d);
> +	char *addr;
>  
>  	BUG_ON(dev->reg_state != NETREG_RELEASED);
>  
>  	kfree(dev->ifalias);
> -	kfree((char *)dev - dev->padded);
> +	addr = (char *)dev - dev->padded;
> +	if (is_vmalloc_addr(addr))
> +		vfree(addr);
> +	else
> +		kfree(addr);
>  }
>  
>  static const void *net_namespace(struct device *d)
> 
> 

Thanks,
Joby
