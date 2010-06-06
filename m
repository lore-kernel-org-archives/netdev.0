From: mark gross <640e9920@gmail.com>
Subject: Re: [RFC] pm_qos: get rid of the allocation in pm_qos_add_request()
Date: Sun, 6 Jun 2010 14:32:24 -0700
Message-ID: <20100606213224.GC8610@gvim.org>
References: <1275765614.7227.42.camel@mulgrave.site>
Reply-To: markgross@thegnar.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pm list <linux-pm@lists.linux-foundation.org>,
	markgross@thegnar.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, Takashi Iwai <tiwai@suse.de>,
	Jaroslav Kysela <perex@perex.cz>
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:56953 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072Ab0FFVcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 17:32:09 -0400
Received: by pxi8 with SMTP id 8so887512pxi.19
        for <netdev@vger.kernel.org>; Sun, 06 Jun 2010 14:32:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1275765614.7227.42.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 05, 2010 at 02:20:14PM -0500, James Bottomley wrote:
> [alsa-devel says it's a moderated list, so feel free to drop before
> replying]
> 
> Since every caller has to squirrel away the returned pointer anyway,
> they might as well supply the memory area.  This fixes a bug in a few of
> the call sites where the returned pointer was dereferenced without
> checking it for NULL (which gets returned if the kzalloc failed).
> 
> I'd like to hear how sound and netdev feels about this: it will add
> about two more pointers worth of data to struct netdev and struct
> snd_pcm_substream .. but I think it's worth it.  If you're OK, I'll add
> your acks and send through the pm tree.
> 
> This also looks to me like an android independent clean up (even though
> it renders the request_add atomically callable).  I also added include
> guards to include/linux/pm_qos_params.h
> 
> James
> 
> ---
> 
>  drivers/net/e1000e/netdev.c            |   17 ++++------
>  drivers/net/igbvf/netdev.c             |    9 ++---
>  drivers/net/wireless/ipw2x00/ipw2100.c |   12 +++---
>  include/linux/netdevice.h              |    2 +-
>  include/linux/pm_qos_params.h          |   12 +++++--
>  include/sound/pcm.h                    |    2 +-
>  kernel/pm_qos_params.c                 |   55 ++++++++++++++++---------------
>  sound/core/pcm_native.c                |   12 ++-----
>  8 files changed, 60 insertions(+), 61 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 24507f3..47ea62f 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -2901,10 +2901,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
>  			 * dropped transactions.
>  			 */
>  			pm_qos_update_request(
> -				adapter->netdev->pm_qos_req, 55);
> +				&adapter->netdev->pm_qos_req, 55);
>  		} else {
>  			pm_qos_update_request(
> -				adapter->netdev->pm_qos_req,
> +				&adapter->netdev->pm_qos_req,
>  				PM_QOS_DEFAULT_VALUE);
>  		}
>  	}
> @@ -3196,9 +3196,9 @@ int e1000e_up(struct e1000_adapter *adapter)
>  
>  	/* DMA latency requirement to workaround early-receive/jumbo issue */
>  	if (adapter->flags & FLAG_HAS_ERT)
> -		adapter->netdev->pm_qos_req =
> -			pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
> -				       PM_QOS_DEFAULT_VALUE);
> +		pm_qos_add_request(&adapter->netdev->pm_qos_req,
> +				   PM_QOS_CPU_DMA_LATENCY,
> +				   PM_QOS_DEFAULT_VALUE);
>  
>  	/* hardware has been reset, we need to reload some things */
>  	e1000_configure(adapter);
> @@ -3263,11 +3263,8 @@ void e1000e_down(struct e1000_adapter *adapter)
>  	e1000_clean_tx_ring(adapter);
>  	e1000_clean_rx_ring(adapter);
>  
> -	if (adapter->flags & FLAG_HAS_ERT) {
> -		pm_qos_remove_request(
> -			      adapter->netdev->pm_qos_req);
> -		adapter->netdev->pm_qos_req = NULL;
> -	}
> +	if (adapter->flags & FLAG_HAS_ERT)
> +		pm_qos_remove_request(&adapter->netdev->pm_qos_req);
>  
>  	/*
>  	 * TODO: for power management, we could drop the link and
> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
> index 5e2b2a8..5da569f 100644
> --- a/drivers/net/igbvf/netdev.c
> +++ b/drivers/net/igbvf/netdev.c
> @@ -48,7 +48,7 @@
>  #define DRV_VERSION "1.0.0-k0"
>  char igbvf_driver_name[] = "igbvf";
>  const char igbvf_driver_version[] = DRV_VERSION;
> -struct pm_qos_request_list *igbvf_driver_pm_qos_req;
> +struct pm_qos_request_list igbvf_driver_pm_qos_req;
>  static const char igbvf_driver_string[] =
>  				"Intel(R) Virtual Function Network Driver";
>  static const char igbvf_copyright[] = "Copyright (c) 2009 Intel Corporation.";
> @@ -2902,8 +2902,8 @@ static int __init igbvf_init_module(void)
>  	printk(KERN_INFO "%s\n", igbvf_copyright);
>  
>  	ret = pci_register_driver(&igbvf_driver);
> -	igbvf_driver_pm_qos_req = pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
> -	                       PM_QOS_DEFAULT_VALUE);
> +	pm_qos_add_request(igbvf_driver_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
> +			   PM_QOS_DEFAULT_VALUE);
>  
>  	return ret;
>  }
> @@ -2918,8 +2918,7 @@ module_init(igbvf_init_module);
>  static void __exit igbvf_exit_module(void)
>  {
>  	pci_unregister_driver(&igbvf_driver);
> -	pm_qos_remove_request(igbvf_driver_pm_qos_req);
> -	igbvf_driver_pm_qos_req = NULL;
> +	pm_qos_remove_request(&igbvf_driver_pm_qos_req);
>  }
>  module_exit(igbvf_exit_module);
>  
> diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
> index 0bd4dfa..7f0d98b 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2100.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2100.c
> @@ -174,7 +174,7 @@ that only one external action is invoked at a time.
>  #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2100 Network Driver"
>  #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
>  
> -struct pm_qos_request_list *ipw2100_pm_qos_req;
> +struct pm_qos_request_list ipw2100_pm_qos_req;
>  
>  /* Debugging stuff */
>  #ifdef CONFIG_IPW2100_DEBUG
> @@ -1741,7 +1741,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
>  	/* the ipw2100 hardware really doesn't want power management delays
>  	 * longer than 175usec
>  	 */
> -	pm_qos_update_request(ipw2100_pm_qos_req, 175);
> +	pm_qos_update_request(&ipw2100_pm_qos_req, 175);
>  
>  	/* If the interrupt is enabled, turn it off... */
>  	spin_lock_irqsave(&priv->low_lock, flags);
> @@ -1889,7 +1889,7 @@ static void ipw2100_down(struct ipw2100_priv *priv)
>  	ipw2100_disable_interrupts(priv);
>  	spin_unlock_irqrestore(&priv->low_lock, flags);
>  
> -	pm_qos_update_request(ipw2100_pm_qos_req, PM_QOS_DEFAULT_VALUE);
> +	pm_qos_update_request(&ipw2100_pm_qos_req, PM_QOS_DEFAULT_VALUE);
>  
>  	/* We have to signal any supplicant if we are disassociating */
>  	if (associated)
> @@ -6669,8 +6669,8 @@ static int __init ipw2100_init(void)
>  	if (ret)
>  		goto out;
>  
> -	ipw2100_pm_qos_req = pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
> -			PM_QOS_DEFAULT_VALUE);
> +	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
> +			   PM_QOS_DEFAULT_VALUE);
>  #ifdef CONFIG_IPW2100_DEBUG
>  	ipw2100_debug_level = debug;
>  	ret = driver_create_file(&ipw2100_pci_driver.driver,
> @@ -6692,7 +6692,7 @@ static void __exit ipw2100_exit(void)
>  			   &driver_attr_debug_level);
>  #endif
>  	pci_unregister_driver(&ipw2100_pci_driver);
> -	pm_qos_remove_request(ipw2100_pm_qos_req);
> +	pm_qos_remove_request(&ipw2100_pm_qos_req);
>  }
>  
>  module_init(ipw2100_init);
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 40291f3..393555a 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -779,7 +779,7 @@ struct net_device {
>  	 */
>  	char			name[IFNAMSIZ];
>  
> -	struct pm_qos_request_list *pm_qos_req;
> +	struct pm_qos_request_list pm_qos_req;
>  
>  	/* device name hash chain */
>  	struct hlist_node	name_hlist;
> diff --git a/include/linux/pm_qos_params.h b/include/linux/pm_qos_params.h
> index 8ba440e..d823cc0 100644
> --- a/include/linux/pm_qos_params.h
> +++ b/include/linux/pm_qos_params.h
> @@ -1,8 +1,10 @@
> +#ifndef _LINUX_PM_QOS_PARAMS_H
> +#define _LINUX_PM_QOS_PARAMS_H
>  /* interface for the pm_qos_power infrastructure of the linux kernel.
>   *
>   * Mark Gross <mgross@linux.intel.com>
>   */
> -#include <linux/list.h>
> +#include <linux/plist.h>
>  #include <linux/notifier.h>
>  #include <linux/miscdevice.h>
>  
> @@ -14,9 +16,12 @@
>  #define PM_QOS_NUM_CLASSES 4
>  #define PM_QOS_DEFAULT_VALUE -1
>  
> -struct pm_qos_request_list;
> +struct pm_qos_request_list {
> +	struct plist_node list;
> +	int pm_qos_class;
> +};

so the test for an un-registerd or in-initialized request is if list == null.

>  
> -struct pm_qos_request_list *pm_qos_add_request(int pm_qos_class, s32 value);
> +void pm_qos_add_request(struct pm_qos_request_list *l, int pm_qos_class, s32 value);
>  void pm_qos_update_request(struct pm_qos_request_list *pm_qos_req,
>  		s32 new_value);
>  void pm_qos_remove_request(struct pm_qos_request_list *pm_qos_req);
> @@ -25,3 +30,4 @@ int pm_qos_request(int pm_qos_class);
>  int pm_qos_add_notifier(int pm_qos_class, struct notifier_block *notifier);
>  int pm_qos_remove_notifier(int pm_qos_class, struct notifier_block *notifier);
>  
> +#endif
> diff --git a/include/sound/pcm.h b/include/sound/pcm.h
> index dd76cde..6e3a297 100644
> --- a/include/sound/pcm.h
> +++ b/include/sound/pcm.h
> @@ -366,7 +366,7 @@ struct snd_pcm_substream {
>  	int number;
>  	char name[32];			/* substream name */
>  	int stream;			/* stream (direction) */
> -	struct pm_qos_request_list *latency_pm_qos_req; /* pm_qos request */
> +	struct pm_qos_request_list latency_pm_qos_req; /* pm_qos request */
>  	size_t buffer_bytes_max;	/* limit ring buffer size */
>  	struct snd_dma_buffer dma_buffer;
>  	unsigned int dma_buf_id;
> diff --git a/kernel/pm_qos_params.c b/kernel/pm_qos_params.c
> index 241fa79..f1d3d23 100644
> --- a/kernel/pm_qos_params.c
> +++ b/kernel/pm_qos_params.c
> @@ -30,7 +30,6 @@
>  /*#define DEBUG*/
>  
>  #include <linux/pm_qos_params.h>
> -#include <linux/plist.h>
? plist pm_qos isn't yet in the code base yet. ;)
Is this patch assumed after your RFC patch?
It must be....


>  #include <linux/sched.h>
>  #include <linux/spinlock.h>
>  #include <linux/slab.h>
> @@ -49,11 +48,6 @@
>   * or pm_qos_object list and pm_qos_objects need to happen with pm_qos_lock
>   * held, taken with _irqsave.  One lock to rule them all
>   */
> -struct pm_qos_request_list {
> -	struct plist_node list;
> -	int pm_qos_class;
> -};
> -
>  enum pm_qos_type {
>  	PM_QOS_MAX,		/* return the largest value */
>  	PM_QOS_MIN,		/* return the smallest value */
> @@ -195,6 +189,11 @@ int pm_qos_request(int pm_qos_class)
>  }
>  EXPORT_SYMBOL_GPL(pm_qos_request);
>  
> +static int pm_qos_request_active(struct pm_qos_request_list *req)
> +{
> +	return req->pm_qos_class != 0;
> +}
> +
>  /**
>   * pm_qos_add_request - inserts new qos request into the list
>   * @pm_qos_class: identifies which list of qos request to us
> @@ -206,25 +205,22 @@ EXPORT_SYMBOL_GPL(pm_qos_request);
>   * element as a handle for use in updating and removal.  Call needs to save
>   * this handle for later use.
>   */
> -struct pm_qos_request_list *pm_qos_add_request(int pm_qos_class, s32 value)
> +void pm_qos_add_request(struct pm_qos_request_list *dep,
> +			int pm_qos_class, s32 value)
>  {
> -	struct pm_qos_request_list *dep;
> -
> -	dep = kzalloc(sizeof(struct pm_qos_request_list), GFP_KERNEL);
> -	if (dep) {
> -		struct pm_qos_object *o =  pm_qos_array[pm_qos_class];
> -		int new_value;
> -
> -		if (value == PM_QOS_DEFAULT_VALUE)
> -			new_value = o->default_value;
> -		else
> -			new_value = value;
> -		plist_node_init(&dep->list, new_value);
> -		dep->pm_qos_class = pm_qos_class;
> -		update_target(o, &dep->list, 0);
> -	}
> +	struct pm_qos_object *o =  pm_qos_array[pm_qos_class];
> +	int new_value;
> +
> +	if (pm_qos_request_active(dep))
> +		return;
>  
> -	return dep;
> +	if (value == PM_QOS_DEFAULT_VALUE)
> +		new_value = o->default_value;
> +	else
> +		new_value = value;
> +	plist_node_init(&dep->list, new_value);
> +	dep->pm_qos_class = pm_qos_class;
> +	update_target(o, &dep->list, 0);
>  }
>  EXPORT_SYMBOL_GPL(pm_qos_add_request);
>  
> @@ -286,7 +282,7 @@ void pm_qos_remove_request(struct pm_qos_request_list *pm_qos_req)
>  
>  	o = pm_qos_array[pm_qos_req->pm_qos_class];
>  	update_target(o, &pm_qos_req->list, 1);
> -	kfree(pm_qos_req);
> +	memset(pm_qos_req, 0, sizeof(*pm_qos_req));

I was wondering how to tell if a pm_qos_request was un-initialized
un-registered request.

>  }
>  EXPORT_SYMBOL_GPL(pm_qos_remove_request);
>  
> @@ -334,8 +330,12 @@ static int pm_qos_power_open(struct inode *inode, struct file *filp)
>  
>  	pm_qos_class = find_pm_qos_object_by_minor(iminor(inode));
>  	if (pm_qos_class >= 0) {
> -		filp->private_data = (void *) pm_qos_add_request(pm_qos_class,
> -				PM_QOS_DEFAULT_VALUE);
> +		struct pm_qos_request_list *req = kzalloc(GFP_KERNEL, sizeof(*req));
> +		if (!req)
> +			return -ENOMEM;
> +
> +		pm_qos_add_request(req, pm_qos_class, PM_QOS_DEFAULT_VALUE);
> +		filp->private_data = req;
>  
>  		if (filp->private_data)
>  			return 0;
> @@ -347,8 +347,9 @@ static int pm_qos_power_release(struct inode *inode, struct file *filp)
>  {
>  	struct pm_qos_request_list *req;
>  
> -	req = (struct pm_qos_request_list *)filp->private_data;
> +	req = filp->private_data;
>  	pm_qos_remove_request(req);
> +	kfree(req);
>  
>  	return 0;
>  }
> diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
> index 303ac04..d3b8b51 100644
> --- a/sound/core/pcm_native.c
> +++ b/sound/core/pcm_native.c
> @@ -451,13 +451,10 @@ static int snd_pcm_hw_params(struct snd_pcm_substream *substream,
>  	snd_pcm_timer_resolution_change(substream);
>  	runtime->status->state = SNDRV_PCM_STATE_SETUP;
>  
> -	if (substream->latency_pm_qos_req) {
> -		pm_qos_remove_request(substream->latency_pm_qos_req);
> -		substream->latency_pm_qos_req = NULL;
> -	}
> +	pm_qos_remove_request(&substream->latency_pm_qos_req);
>  	if ((usecs = period_to_usecs(runtime)) >= 0)
> -		substream->latency_pm_qos_req = pm_qos_add_request(
> -					PM_QOS_CPU_DMA_LATENCY, usecs);
> +		pm_qos_add_request(&substream->latency_pm_qos_req,
> +				   PM_QOS_CPU_DMA_LATENCY, usecs);
How are we going to avoid re-adding the latency_pm_qos_request multiple
times to the list?  the last time I looked at this I really wanted to
change this to update_request.  But, I got pushback so I added the file
gard in pmqos_params.c instead. 

--mgross

>  	return 0;
>   _error:
>  	/* hardware might be unuseable from this time,
> @@ -512,8 +509,7 @@ static int snd_pcm_hw_free(struct snd_pcm_substream *substream)
>  	if (substream->ops->hw_free)
>  		result = substream->ops->hw_free(substream);
>  	runtime->status->state = SNDRV_PCM_STATE_OPEN;
> -	pm_qos_remove_request(substream->latency_pm_qos_req);
> -	substream->latency_pm_qos_req = NULL;
> +	pm_qos_remove_request(&substream->latency_pm_qos_req);
>  	return result;
>  }
>  
> 
> 
