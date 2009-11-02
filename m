From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RFC: netdev: allow ethtool physical id to drop rtnl_lock
Date: Mon, 2 Nov 2009 08:51:21 -0800
Message-ID: <20091102085121.7416fa8f@nehalam>
References: <20091030104201.6bb03b23@nehalam>
	<1257007462.9706.9.camel@HP1>
	<20091102.001710.209808608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59095 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840AbZKBQvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 11:51:43 -0500
In-Reply-To: <20091102.001710.209808608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Nov 2009 00:17:10 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: "Michael Chan" <mchan@broadcom.com>
> Date: Sat, 31 Oct 2009 09:44:22 -0700
> 
> > 
> > On Fri, 2009-10-30 at 10:42 -0700, Stephen Hemminger wrote:
> >> The ethtool operation to blink LED can take an indeterminately long time,
> >> blocking out other operations (via rtnl_lock). This patch is an attempt
> >> to work around the problem.
> >> 
> >> It does need more discussion, because it will mean that drivers that formerly
> >> were protected from changes during blink aren't.  For example, user could
> >> start device blinking, and then plug in cable causing change netlink event
> >> to change state or pull cable and have device come down.
> > 
> > Yeah, the biggest concern is shutting down the device while it is still
> > blinking.  During shutdown, some devices are brought to low power state
> > and the chip will no longer respond to I/Os to blink the LEDs.  On some
> > systems, this can cause bus hang or NMI.
> 
> Right, and for this reason we'll either need find some way to stop
> the LED blinking when the device is brought down.
> 
> We can deal with this in a way such that we'll never need to bug
> the drivers again if we want to mess with the implementation again.
> 
> Create a "netif_phys_id_loop_iter()" that, along with a netdev
> pointer, takes a "u32 data" which is whatever was passed in to
> ethtool_ops->id().
> 
> The drivers then structure their loops like:
> 
> 	while (1) {
> 		blink_it_baby();
> 		data = netif_phys_id_loop_iter(dev, data);
> 		if (!data)
> 			break;
> 	}
> 
> Next, we take that:
> 
> 	if (data == 0)
> 		data = UINT_MAX / 2;
> 
> That every driver seems to do, and stick it in the ethtool op dispatch
> in net/core/ethtool.c so it doesn't need to be duplicated (and
> potentially forgotten) in every implementation.
> 
> Finally, in netif_phys_id_loop_iter() we put something like:
> 
> u32 netif_phys_id_loop_iter(struct netdev *dev, u32 data)
> {
> 	if (dev->reg_state == NETREG_UNREGISTERING)
> 		return 0;
> 	if (msleep_interruptible(500))
> 		return 0;
> 	return data - 2;
> }
> 
> Then, unregister somehow blocks on the ->phys_id() hitting that
> NETREG_UNREGISTERING check and returning.
> 
> Anyways, you get the idea.

For compatibility, I was thinking of adding a new ethtool hook that
moves the blinking loop into ethtool.


static int ethtool_phys_blink(struct net_device *dev, u32 secs)
{
	while (secs > 0) {
		dev->ethtool_ps->phys_led(dev, ETH_LED_ON);
...
		dev->ethtool_ps->phys_led(dev, ETH_LED_OFF);
	}
	dev->ethtool_ops->phys_led(dev, ETH_LED_NORMAL);
}


static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
{
	struct ethtool_value id;

	if (copy_from_user(&id, useraddr, sizeof(id)))
		return -EFAULT;

	if (dev->ethtool_ops->phys_led)
		return ethtool_phys_blink(dev, id.data);

	if (dev->ethtool_ops->phys_id)
		return dev->ethtool_ops->phys_id(dev, id.data);
	else
		return -EOPNOTSUPP;
}



-- 
