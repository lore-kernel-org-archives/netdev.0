From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: Active URB submitted twice in pegasus driver
Date: Tue, 26 Mar 2013 14:37:57 -0700
Message-ID: <20130326213757.GA19141@xanatos>
References: <20130325223834.GF6869@xanatos>
 <alpine.DEB.2.02.1303261655450.3724@fry.nucleusys.com>
 <20130326170140.GC10317@xanatos>
 <alpine.DEB.2.02.1303261909260.4226@fry.nucleusys.com>
 <20130326185218.GD10317@xanatos>
 <alpine.DEB.2.02.1303262247490.3959@fry>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
To: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303262247490.3959@fry>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 26, 2013 at 10:54:25PM +0200, Petko Manolov wrote:
> On Tue, 26 Mar 2013, Sarah Sharp wrote:
> 
> >But considering the multicast code is pretty old, I bet I'm running into
> >a different bug...
> 
> The fix is rather small.  Approximately one gigabyte was transferred
> while alternating in and out of promiscuous mode.  No issues.
> 
> I guess this should move the driver out of the equation.
> 
> 
> cheers,
> Petko

> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 73051d1..879da39 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -1220,8 +1220,6 @@ static void pegasus_set_multicast(struct net_device *net)
>  		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
>  	}
>  
> -	pegasus->ctrl_urb->status = 0;
> -
>  	pegasus->flags |= ETH_REGS_CHANGE;
>  	ctrl_callback(pegasus->ctrl_urb);
>  }

This patch does avoid writes to the URB, however...

static void ctrl_callback(struct urb *urb)
{
        pegasus_t *pegasus = urb->context;
        int status = urb->status;

        if (!pegasus)
                return;

        switch (status) {
        case 0:
                if (pegasus->flags & ETH_REGS_CHANGE) {
                        pegasus->flags &= ~ETH_REGS_CHANGE;
                        pegasus->flags |= ETH_REGS_CHANGED;
                        update_eth_regs_async(pegasus);
                        return;
                }
                break;

ctrl_callback is still reading the URB status, and using it in the
switch statement.  It's also using the urb->context as well, to dig out
a pointer (pegasus_t) that the pegasus_set_multicast already has access
to.  What happens if an URB to get the registers completes at the same
time pegasus_set_multicast calls ctrl_callback?  If the URB failed for
some reason (e.g. bad cable, stall), you'll miss that if statement.  I
don't think that's what you intended to do.

I think the fix should be to just to move the if block into a new
function, and call it both in ctrl_callback() and
pegasus_set_multicast().

Further, is it possible to call any of these functions asynchronously?
 - get_registers
 - set_registers
 - update_eth_regs_async

What happens if the upper layer calls get_registers and
update_eth_regs_async in rapid succession?  You'll attempt to use the
control URB in both places, which will trigger the original warning I
was reporting.  Or is there some locking somewhere I'm missing?

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
