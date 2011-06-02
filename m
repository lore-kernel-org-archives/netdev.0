From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 2 Jun 2011 14:56:59 -0400
Message-ID: <20110602185659.GA2749@hmsreliant.think-freely.org>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
 <1307039753.2812.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46145 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab1FBS5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 14:57:14 -0400
Content-Disposition: inline
In-Reply-To: <1307039753.2812.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 02, 2011 at 07:35:53PM +0100, Ben Hutchings wrote:
> On Thu, 2011-06-02 at 14:03 -0400, Neil Horman wrote:
> > The bonding driver is multiqueue enabled, in which each queue represents a slave
> > to enable optional steering of output frames to given slaves against the default
> > output policy.  However, it needs to reset the skb->queue_mapping prior to
> > queuing to the physical device or the physical slave (if it is multiqueue) could
> > wind up transmitting on an unintended tx queue (one that was reserved for
> > specific traffic classes for instance)
> >
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > CC: Jay Vosburgh <fubar@us.ibm.com>
> > CC: Andy Gospodarek <andy@greyhouse.net>
> > CC: "David S. Miller" <davem@davemloft.net>
> > ---
> >  drivers/net/bonding/bond_main.c |    5 +++++
> >  1 files changed, 5 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> > index 17b4dd9..812c70c 100644
> > --- a/drivers/net/bonding/bond_main.c
> > +++ b/drivers/net/bonding/bond_main.c
> > @@ -4200,6 +4200,11 @@ static inline int bond_slave_override(struct bonding *bond,
> >  	/* If the slave isn't UP, use default transmit policy. */
> >  	if (slave && slave->queue_id && IS_UP(slave->dev) &&
> >  	    (slave->link == BOND_LINK_UP)) {
> > +		/*
> > + 		 * Reset the queue mapping to allow the underlying slave	
> > + 		 * the chance to re-select an appropriate tx queue
> > + 		 */
> > +		skb_set_queue_mapping(skb, 0);
> >  		res = bond_dev_queue_xmit(bond, skb, slave->dev);
> >  	}
> >  
> 
> So far as I can see, this has no effect, because dev_queue_xmit() always
> sets queue_mapping (in dev_pick_tx()).
> 
it resets the queue mapping exactly as you would expect it to.  bonding is a
multiqueue enabled device and selects a potentially non-zero queue based on the
output of bond_select_queue.

> What is the problem you're seeing?
> 
The problem is exctly that.  dev_pick_tx() on the bond device sets the
queue_mapping as per the result of bond_select_queue (the ndo_select_queue
method for the bonding driver).  The implementation there is based on the use of
tc with bonding, so that output slaves can be selected for certain types of
traffic.  But when that mechanism is used, skb->queue_mapping is preserved when
the bonding driver queues the frame to the underlying slave.  This denies the
slave (if its also a multiqueue device) the opportunity to reselect the queue
properly, because of this call path:

bond_queue_xmit
 dev_queue_xmit(slave_dev)
  dev_pick_tx()
   skb_tx_hash()
    __skb_tx_hash()

__skb_tx_hash sees that skb_queue_recorded returns true, and assigns a hardware queue mapping
based on what the bonding driver chose using its own internal logic.  Since
bonding uses the multiqueue infrastructure to do slave output selection without
any regard for slave output queue selection, it seems to me we should really
reset the queue mapping to zero so the slave device can pick its own tx queue.

Neil

> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
