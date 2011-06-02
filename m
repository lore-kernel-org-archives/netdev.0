From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 21:13:24 +0100
Message-ID: <1307045604.2812.41.camel@bwh-desktop>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
	 <1307039753.2812.16.camel@bwh-desktop>
	 <20110602185659.GA2749@hmsreliant.think-freely.org>
	 <1307041789.2812.27.camel@bwh-desktop>
	 <20110602194621.GB2749@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32444 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab1FBUN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:13:27 -0400
In-Reply-To: <20110602194621.GB2749@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-02 at 15:46 -0400, Neil Horman wrote:
> On Thu, Jun 02, 2011 at 08:09:49PM +0100, Ben Hutchings wrote:
> > On Thu, 2011-06-02 at 14:56 -0400, Neil Horman wrote:
> > > On Thu, Jun 02, 2011 at 07:35:53PM +0100, Ben Hutchings wrote:
> > > > On Thu, 2011-06-02 at 14:03 -0400, Neil Horman wrote:
> > > > > The bonding driver is multiqueue enabled, in which each queue represents a slave
> > > > > to enable optional steering of output frames to given slaves against the default
> > > > > output policy.  However, it needs to reset the skb->queue_mapping prior to
> > > > > queuing to the physical device or the physical slave (if it is multiqueue) could
> > > > > wind up transmitting on an unintended tx queue (one that was reserved for
> > > > > specific traffic classes for instance)
> > [...]
> > > > So far as I can see, this has no effect, because dev_queue_xmit() always
> > > > sets queue_mapping (in dev_pick_tx()).
> > > > 
> > > it resets the queue mapping exactly as you would expect it to.  bonding is a
> > > multiqueue enabled device and selects a potentially non-zero queue based on the
> > > output of bond_select_queue.
> > > 
> > > > What is the problem you're seeing?
> > > > 
> > > The problem is exctly that.  dev_pick_tx() on the bond device sets the
> > > queue_mapping as per the result of bond_select_queue (the ndo_select_queue
> > > method for the bonding driver).  The implementation there is based on the use of
> > > tc with bonding, so that output slaves can be selected for certain types of
> > > traffic.  But when that mechanism is used, skb->queue_mapping is preserved when
> > > the bonding driver queues the frame to the underlying slave.  This denies the
> > > slave (if its also a multiqueue device) the opportunity to reselect the queue
> > > properly, because of this call path:
> > > 
> > > bond_queue_xmit
> > >  dev_queue_xmit(slave_dev)
> > >   dev_pick_tx()
> > >    skb_tx_hash()
> > >     __skb_tx_hash()
> > > 
> > > __skb_tx_hash sees that skb_queue_recorded returns true, and assigns a hardware queue mapping
> > > based on what the bonding driver chose using its own internal logic.  Since
> > > bonding uses the multiqueue infrastructure to do slave output selection without
> > > any regard for slave output queue selection, it seems to me we should really
> > > reset the queue mapping to zero so the slave device can pick its own tx queue.
> > 
> > So you're effectively clearing the *RX queue* number (as this is before
> > dev_pick_tx()) in order to influence TX queue selection.
> > 
> No, you're not seeing it properly.  In bonding (as with all stacked devices) we
> make two passes through dev_pick_tx.

Only if the stacked device has its own software queues and schedulers;
e.g. VLAN devices don't.

> 1) The first time we call dev_pick_tx is when the network stack calls
> dev_queue_xmit on the bond device.  here we call ndo_select_queue, which calls
> bond_select_queue.  This method tells the stack which queue to enqueue the skb
> on for the bond device.  We can use tc's skbedit action to select a particular
> queue on the bond device for various classes of traffic, and those queues
> correspond to individual slave devices.
> 
> 2) the second time we call dev_pick_tx is when the bonding bond_queue_xmit
> routine (which is the bonding drivers ndo_start_xmit method, called after the
> frist dev_pick_tx), calls dev_queue_xmit, passing the slave net_device pointer).
> In this case we do whatever the slave device has configured (either reset the
> queue to zero, or call the slaves ndo_select queue method).
> 
> What I'm fixing is the fact that the bonding drivers queue_mappnig value is
> 'leaking' down to the slave.

And this is because dev_queue_xmit() assumes that it's a record of the
RX queue number.

The differing interpretation of queue_mapping for RX and TX is annoying
and I think we should change the initial value of queue_mapping to -1.
But that's a separate issue.

> Lets say, for example we're bonding two multiqueue devices, and have the bonding
> driver configured to send all traffic to 192.168.1.1 over the first slave (which
> we can accomplish using an appropriate tc rule on the bond device, setting
> frames with that dest ip to have a skb->queue_mapping of 1).
> 
> In the above example, frames bound for 192.168.1.1 have skb->queue_mapping set
> to 1 when they enter bond_queue_xmit.  bond_queue_xmit, calls
> dev_queue_xmit(slave, skb), which calls dev_pick_tx(slave, skb).  If we (for
> simplicity's sake) assume the slave has no ndo_select_queue method, dev_pick_tx
> calls __skb_tx_hash to determine the output queue.  But the bonding driver
> already set skb->queue_mapping to 1 (because it wanted this frame output on the
> first slave, not because it wanted to transmit the frame on the slaves tx queue
> 1).  Nevertheless, __skb_tx_hash() sees that skb_rx_queue_recorded returns true
> here and as a result, calls skb_rx_get_queue, which returns 0.  Because of that
> we wind up transmitting on hardware queue 0 all the time, which is not at all
> what we want.  What we want is for the bonding driver to be able to use
> queue_mapping for its own purposes, and then allow the physical device to make
> its own output queue selection independently.
[...]

I think I understand - the bonding device is effectively single-queue
and shouldn't record an RX queue number.  But I think you should define
and use skb_clear_rx_queue() to set queue_mapping=0, rather than abusing
skb_set_queue_mapping() which is meant to take a TX queue number.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

