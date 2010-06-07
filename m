From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: [RFC] pm_qos: get rid of the allocation in pm_qos_add_request()
Date: Sun, 06 Jun 2010 22:50:19 -0400
Message-ID: <1275879019.7227.564.camel@mulgrave.site>
References: <1275765614.7227.42.camel@mulgrave.site>
	 <20100606231021.GA17031@gvim.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	Takashi Iwai <tiwai@suse.de>, Jaroslav Kysela <perex@perex.cz>
To: markgross@thegnar.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49731 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755271Ab0FGCuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jun 2010 22:50:25 -0400
In-Reply-To: <20100606231021.GA17031@gvim.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-06-06 at 16:10 -0700, mark gross wrote:
> On Sat, Jun 05, 2010 at 02:20:14PM -0500, James Bottomley wrote:
> > [alsa-devel says it's a moderated list, so feel free to drop before
> > replying]
> > 
> > Since every caller has to squirrel away the returned pointer anyway,
> > they might as well supply the memory area.  This fixes a bug in a few of
> > the call sites where the returned pointer was dereferenced without
> > checking it for NULL (which gets returned if the kzalloc failed).
> > 
> > I'd like to hear how sound and netdev feels about this: it will add
> > about two more pointers worth of data to struct netdev and struct
> > snd_pcm_substream .. but I think it's worth it.  If you're OK, I'll add
> > your acks and send through the pm tree.
> > 
> > This also looks to me like an android independent clean up (even though
> > it renders the request_add atomically callable).  I also added include
> > guards to include/linux/pm_qos_params.h
> > 
> > James
> > 
> > ---
> > 
> >  drivers/net/e1000e/netdev.c            |   17 ++++------
> >  drivers/net/igbvf/netdev.c             |    9 ++---
> >  drivers/net/wireless/ipw2x00/ipw2100.c |   12 +++---
> >  include/linux/netdevice.h              |    2 +-
> >  include/linux/pm_qos_params.h          |   12 +++++--
> >  include/sound/pcm.h                    |    2 +-
> >  kernel/pm_qos_params.c                 |   55 ++++++++++++++++---------------
> >  sound/core/pcm_native.c                |   12 ++-----
> >  8 files changed, 60 insertions(+), 61 deletions(-)
> > 
> > diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> > index 24507f3..47ea62f 100644
> > --- a/drivers/net/e1000e/netdev.c
> > +++ b/drivers/net/e1000e/netdev.c
> > @@ -2901,10 +2901,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
> >  			 * dropped transactions.
> >  			 */
> >  			pm_qos_update_request(
> > -				adapter->netdev->pm_qos_req, 55);
> > +				&adapter->netdev->pm_qos_req, 55);
> >  		} else {
> >  			pm_qos_update_request(
> > -				adapter->netdev->pm_qos_req,
> > +				&adapter->netdev->pm_qos_req,
> >  				PM_QOS_DEFAULT_VALUE);
> >  		}
> >  	}
> > @@ -3196,9 +3196,9 @@ int e1000e_up(struct e1000_adapter *adapter)
> >  
> >  	/* DMA latency requirement to workaround early-receive/jumbo issue */
> >  	if (adapter->flags & FLAG_HAS_ERT)
> > -		adapter->netdev->pm_qos_req =
> > -			pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
> > -				       PM_QOS_DEFAULT_VALUE);
> > +		pm_qos_add_request(&adapter->netdev->pm_qos_req,
> > +				   PM_QOS_CPU_DMA_LATENCY,
> > +				   PM_QOS_DEFAULT_VALUE);
> >  
> >  	/* hardware has been reset, we need to reload some things */
> >  	e1000_configure(adapter);
> > @@ -3263,11 +3263,8 @@ void e1000e_down(struct e1000_adapter *adapter)
> >  	e1000_clean_tx_ring(adapter);
> >  	e1000_clean_rx_ring(adapter);
> >  
> > -	if (adapter->flags & FLAG_HAS_ERT) {
> > -		pm_qos_remove_request(
> > -			      adapter->netdev->pm_qos_req);
> > -		adapter->netdev->pm_qos_req = NULL;
> > -	}
> > +	if (adapter->flags & FLAG_HAS_ERT)
> > +		pm_qos_remove_request(&adapter->netdev->pm_qos_req);
> >  
> >  	/*
> >  	 * TODO: for power management, we could drop the link and
> > diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
> > index 5e2b2a8..5da569f 100644
> > --- a/drivers/net/igbvf/netdev.c
> > +++ b/drivers/net/igbvf/netdev.c
> > @@ -48,7 +48,7 @@
> >  #define DRV_VERSION "1.0.0-k0"
> >  char igbvf_driver_name[] = "igbvf";
> >  const char igbvf_driver_version[] = DRV_VERSION;
> > -struct pm_qos_request_list *igbvf_driver_pm_qos_req;
> > +struct pm_qos_request_list igbvf_driver_pm_qos_req;
> >  static const char igbvf_driver_string[] =
> >  				"Intel(R) Virtual Function Network Driver";
> >  static const char igbvf_copyright[] = "Copyright (c) 2009 Intel Corporation.";
> > @@ -2902,8 +2902,8 @@ static int __init igbvf_init_module(void)
> >  	printk(KERN_INFO "%s\n", igbvf_copyright);
> >  
> >  	ret = pci_register_driver(&igbvf_driver);
> > -	igbvf_driver_pm_qos_req = pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
> > -	                       PM_QOS_DEFAULT_VALUE);
> > +	pm_qos_add_request(igbvf_driver_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
> should be:
> 
> +	pm_qos_add_request(&igbvf_driver_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,

Yes, thanks ... must be not compiling this driver for some reason in the
test case.

James


