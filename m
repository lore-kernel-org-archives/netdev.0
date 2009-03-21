From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management (v2)
Date: Fri, 20 Mar 2009 21:45:15 -0700
Message-ID: <20090320214515.5af3a6f4@nehalam>
References: <20090319233404.6697768b@nehalam>
	<20090319233610.51fe4ee1@nehalam>
	<20090320091247.38326931@nehalam>
	<Pine.WNT.4.64.0903202033090.16644@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45914 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800AbZCUEp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 00:45:28 -0400
In-Reply-To: <Pine.WNT.4.64.0903202033090.16644@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2009 20:48:46 -0700 (Pacific Daylight Time)
"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote:

> On Fri, 20 Mar 2009, Stephen Hemminger wrote:
> 
> > Convert ixgbe to use net_device_ops properly.
> > Rather than changing the select_queue function pointer
> > just change number of available transmit queues.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > ---
> >  drivers/net/ixgbe/ixgbe_dcb_nl.c |   48 +++++++++++++++++----------------------
> >  1 file changed, 21 insertions(+), 27 deletions(-)
> > 
> > --- a/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-03-20 09:01:19.643651162 -0700
> > +++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-03-20 09:11:09.645652169 -0700
> > @@ -102,12 +102,6 @@ static u8 ixgbe_dcbnl_get_state(struct n
> >  	return !!(adapter->flags & IXGBE_FLAG_DCB_ENABLED);
> >  }
> >  
> > -static u16 ixgbe_dcb_select_queue(struct net_device *dev, struct sk_buff *skb)
> > -{
> > -	/* All traffic should default to class 0 */
> > -	return 0;
> > -}
> > -
> >  static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
> >  {
> >  	u8 err = 0;
> > @@ -135,7 +129,7 @@ static u8 ixgbe_dcbnl_set_state(struct n
> >  		kfree(adapter->rx_ring);
> >  		adapter->tx_ring = NULL;
> >  		adapter->rx_ring = NULL;
> > -		netdev->select_queue = &ixgbe_dcb_select_queue;
> > +		netdev->real_num_tx_queues = 1;
> 
> NAK.  The point of dcb_select_queue() isn't because DCB mode only uses 1 
> Tx queue.  DCB has 8 priorities, and allocates 8 Tx queues, one for each 
> priority.  The DCB spec says that any traffic not being filtered by some 
> kind of mechanism needs to go through priority 0, or queue 0.  So 
> select_queue is meant to tag all traffic to queue 0, then have the 
> attached qdisc and tc filters get the majority of the traffic into the 
> different priority queues.
> 
> If we did not push the unfiltered traffic into queue 0, then skb_tx_hash() 
> would put traffic randomly into queues with higher priority, which is not 
> what we want.
> 
> I'd prefer your original patch to fix this up, where you check if DCB is 
> enabled, and return 0.
> 
> -PJ Waskiewicz

The default select queue function in the kernel is:

static struct netdev_queue *dev_pick_tx(struct net_device *dev,
					struct sk_buff *skb)
{
	const struct net_device_ops *ops = dev->netdev_ops;
	u16 queue_index = 0;

	if (ops->ndo_select_queue)
		queue_index = ops->ndo_select_queue(dev, skb);
	else if (dev->real_num_tx_queues > 1)
		queue_index = skb_tx_hash(dev, skb);

	skb_set_queue_mapping(skb, queue_index);
	return netdev_get_tx_queue(dev, queue_index);
}

So if driver (re)sets real_num_tx_queues to 1 then queue_index will always
0 and all traffic will go to one queue. This is the same as having your
own select_queue function.

