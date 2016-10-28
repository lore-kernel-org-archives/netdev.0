From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] Revert "usb: dwc3: gadget: use allocated/queued reqs for
 LST bit"
Date: Fri, 28 Oct 2016 19:33:32 +0300
Message-ID: <20161028163332.GL4617@intel.com>
References: <1475504282-13268-1-git-send-email-ville.syrjala@linux.intel.com>
 <87lgy5za7o.fsf@linux.intel.com>
 <20161004083855.GW4329@intel.com>
 <8760p8qp5b.fsf@linux.intel.com>
 <20161004132059.GX4329@intel.com>
 <87mvikp5wx.fsf@linux.intel.com>
 <87shsand3q.fsf@linux.intel.com>
 <20161006090826.GH4329@intel.com>
 <20161027154016.GD4617@intel.com>
 <87pomksrrm.fsf@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87pomksrrm.fsf-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2016 at 01:16:13PM +0300, Felipe Balbi wrote:
> 
> Hi,
> 
> Ville Syrjälä <ville.syrjala-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> writes:
> > On Thu, Oct 06, 2016 at 12:08:26PM +0300, Ville Syrjälä wrote:
> >> On Thu, Oct 06, 2016 at 10:36:09AM +0300, Felipe Balbi wrote:
> >> > 
> >> > Hi,
> >> > 
> >> > Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> writes:
> >> <snip>
> >> > Okay, I have found a regression on dwc3 and another patch follows:
> >> > 
> >> > commit 5e1a2af3e46248c55098cdae643c4141851b703e
> >> > Author: Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> >> > Date:   Wed Oct 5 14:24:37 2016 +0300
> >> > 
> >> >     usb: dwc3: gadget: properly account queued requests
> >> >     
> >> >     Some requests could be accounted for multiple
> >> >     times. Let's fix that so each and every requests is
> >> >     accounted for only once.
> >> >     
> >> >     Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v4.8
> >> >     Fixes: 55a0237f8f47 ("usb: dwc3: gadget: use allocated/queued reqs for LST bit")
> >> >     Signed-off-by: Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> >> > 
> >> > diff --git a/drivers/usb/dwc3/gadget.c b/drivers/usb/dwc3/gadget.c
> >> > index 07cc8929f271..3c3ced128c77 100644
> >> > --- a/drivers/usb/dwc3/gadget.c
> >> > +++ b/drivers/usb/dwc3/gadget.c
> >> > @@ -783,6 +783,7 @@ static void dwc3_prepare_one_trb(struct dwc3_ep *dep,
> >> >  		req->trb = trb;
> >> >  		req->trb_dma = dwc3_trb_dma_offset(dep, trb);
> >> >  		req->first_trb_index = dep->trb_enqueue;
> >> > +		dep->queued_requests++;
> >> >  	}
> >> >  
> >> >  	dwc3_ep_inc_enq(dep);
> >> > @@ -833,8 +834,6 @@ static void dwc3_prepare_one_trb(struct dwc3_ep *dep,
> >> >  
> >> >  	trb->ctrl |= DWC3_TRB_CTRL_HWO;
> >> >  
> >> > -	dep->queued_requests++;
> >> > -
> >> >  	trace_dwc3_prepare_trb(dep, trb);
> >> >  }
> >> >  
> >> > @@ -1861,8 +1860,11 @@ static int __dwc3_cleanup_done_trbs(struct dwc3 *dwc, struct dwc3_ep *dep,
> >> >  	unsigned int		s_pkt = 0;
> >> >  	unsigned int		trb_status;
> >> >  
> >> > -	dep->queued_requests--;
> >> >  	dwc3_ep_inc_deq(dep);
> >> > +
> >> > +	if (req->trb == trb)
> >> > +		dep->queued_requests--;
> >> > +
> >> >  	trace_dwc3_complete_trb(dep, trb);
> >> >  
> >> >  	/*
> >> > 
> >> > I have also built a branch which you can use for testing. Here's a pull
> >> > request, once you tell me it works for you, then I can send proper
> >> > patches out:
> >> > 
> >> > The following changes since commit c8d2bc9bc39ebea8437fd974fdbc21847bb897a3:
> >> > 
> >> >   Linux 4.8 (2016-10-02 16:24:33 -0700)
> >> > 
> >> > are available in the git repository at:
> >> > 
> >> >   git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb.git tmp-test-v4.8
> >> > 
> >> > for you to fetch changes up to c968b8d1effe64a7980802d1eef29f4e1922faca:
> >> > 
> >> >   usb: dwc3: gadget: properly account queued requests (2016-10-06 10:16:37 +0300)
> >> > 
> >> > ----------------------------------------------------------------
> >> > Felipe Balbi (2):
> >> >       usb: gadget: function: u_ether: don't starve tx request queue
> >> >       usb: dwc3: gadget: properly account queued requests
> >> > 
> >> >  drivers/usb/dwc3/gadget.c             | 7 ++++---
> >> >  drivers/usb/gadget/function/u_ether.c | 5 +++--
> >> >  2 files changed, 7 insertions(+), 5 deletions(-)
> >> 
> >> Tried your branch, but unfortunately I'm still seeing the lags. New trace
> >> attached.
> >
> > Just a reminder that the regressions is still there in 4.9-rc2.
> > Unfortunateyly with all the stuff already piled on top, getting USB
> > working on my device is no longer a simple matter of reverting the
> > one commit. I had to revert 10 patches to get even a clean revert, but
> > unfortunately that approach just lead to the transfer hanging immediately.
> >
> > So what I ended up doing is reverting all of this:
> > git log --no-merges --format=oneline 55a0237f8f47957163125e20ee9260538c5c341c^..HEAD -- drivers/usb/dwc3/ include/linux/ulpi/interface.h drivers/usb/Kconfig drivers/usb/core/Kconfig
> >
> > which comes out at whopping 70 commits. Having to carry that around
> > is going to be quite a pain especially as more stuff might be piled on
> > top.
> >
> > /me thinks a stable backport of any fix (assuming one is found
> > eventually) is going to be quite the challenge...
> 
> Yeah, I'm guessing we're gonna need some help from networking folks. The
> only thing we did since v4.7 was actually respect req->no_interrupt flag
> coming from u_ether itself. No idea why that causes so much trouble for
> u_ether.
> 
> BTW, Instead of reverting so many patches, you can just remove
> throttling:
> 
> diff --git a/drivers/usb/gadget/function/u_ether.c b/drivers/usb/gadget/function/u_ether.c
> index f4a640216913..119a2e5848e8 100644
> --- a/drivers/usb/gadget/function/u_ether.c
> +++ b/drivers/usb/gadget/function/u_ether.c
> @@ -589,14 +589,6 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
>  
>         req->length = length;
>  
> -       /* throttle high/super speed IRQ rate back slightly */
> -       if (gadget_is_dualspeed(dev->gadget))
> -               req->no_interrupt = (((dev->gadget->speed == USB_SPEED_HIGH ||
> -                                      dev->gadget->speed == USB_SPEED_SUPER)) &&
> -                                       !list_empty(&dev->tx_reqs))
> -                       ? ((atomic_read(&dev->tx_qlen) % dev->qmult) != 0)
> -                       : 0;
> -
>         retval = usb_ep_queue(in, req, GFP_ATOMIC);
>         switch (retval) {
>         default:

Ah cool. That indeed fixes the problem for me.

> 
> I'm adding netdev and couple other folks to the loop.
> 
> Just to summarize, USB peripheral controller now actually throttles
> interrupt when requested to do so and that causes lags for USB
> networking gadgets.
> 
> Without throttle we, potentially, call netif_wake_queue() more
> frequently than with throttling. I'm wondering if something changed in
> NET layer within the past few years but the USB networking gadgets ended
> up being forgotten.
> 
> Anyway, if anybody has any hints, I'd be glad to hear about them.
> 
> -- 
> balbi



-- 
Ville Syrjälä
Intel OTC
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
