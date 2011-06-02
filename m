From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 20:09:49 +0100
Message-ID: <1307041789.2812.27.camel@bwh-desktop>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
	 <1307039753.2812.16.camel@bwh-desktop>
	 <20110602185659.GA2749@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27819 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494Ab1FBTJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 15:09:52 -0400
In-Reply-To: <20110602185659.GA2749@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-02 at 14:56 -0400, Neil Horman wrote:
> On Thu, Jun 02, 2011 at 07:35:53PM +0100, Ben Hutchings wrote:
> > On Thu, 2011-06-02 at 14:03 -0400, Neil Horman wrote:
> > > The bonding driver is multiqueue enabled, in which each queue represents a slave
> > > to enable optional steering of output frames to given slaves against the default
> > > output policy.  However, it needs to reset the skb->queue_mapping prior to
> > > queuing to the physical device or the physical slave (if it is multiqueue) could
> > > wind up transmitting on an unintended tx queue (one that was reserved for
> > > specific traffic classes for instance)
[...]
> > So far as I can see, this has no effect, because dev_queue_xmit() always
> > sets queue_mapping (in dev_pick_tx()).
> > 
> it resets the queue mapping exactly as you would expect it to.  bonding is a
> multiqueue enabled device and selects a potentially non-zero queue based on the
> output of bond_select_queue.
> 
> > What is the problem you're seeing?
> > 
> The problem is exctly that.  dev_pick_tx() on the bond device sets the
> queue_mapping as per the result of bond_select_queue (the ndo_select_queue
> method for the bonding driver).  The implementation there is based on the use of
> tc with bonding, so that output slaves can be selected for certain types of
> traffic.  But when that mechanism is used, skb->queue_mapping is preserved when
> the bonding driver queues the frame to the underlying slave.  This denies the
> slave (if its also a multiqueue device) the opportunity to reselect the queue
> properly, because of this call path:
> 
> bond_queue_xmit
>  dev_queue_xmit(slave_dev)
>   dev_pick_tx()
>    skb_tx_hash()
>     __skb_tx_hash()
> 
> __skb_tx_hash sees that skb_queue_recorded returns true, and assigns a hardware queue mapping
> based on what the bonding driver chose using its own internal logic.  Since
> bonding uses the multiqueue infrastructure to do slave output selection without
> any regard for slave output queue selection, it seems to me we should really
> reset the queue mapping to zero so the slave device can pick its own tx queue.

So you're effectively clearing the *RX queue* number (as this is before
dev_pick_tx()) in order to influence TX queue selection.

Here, the bonding device seems to be behaving as a forwarding device.
If TX queue selection can go wrong for certain combinations of queue
configuration when forwarding, then this is a problem for IP forwarding
and bridging as well, isn't it?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

