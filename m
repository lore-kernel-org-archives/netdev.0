From: David Lamparter <equinox@diac24.net>
Subject: Re: [patch net-next-2.6] net: allow multiple rx_handler registration
Date: Tue, 12 Jul 2011 13:54:22 +0200
Message-ID: <20110712115422.GD616804@jupiter.n2.diac24.net>
References: <1310468761-2304-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net, greearb@candelatech.com, mirqus@gmail.com,
	equinox@diac24.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:50389 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964Ab1GLLye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 07:54:34 -0400
Content-Disposition: inline
In-Reply-To: <1310468761-2304-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 01:06:01PM +0200, Jiri Pirko wrote:
> For some net topos it is necessary to have multiple "soft-net-devices"
> hooked on one netdev. For example very common is to have
> eth<->(br+vlan). Vlan is not using rh_handler (yet) but it might be useful
> for other setups.

I disagree strongly, especially with the use cases you're enabling in
this patch.

> +	res = netdev_rx_handler_register(slave_dev, &new_slave->rx_handler,
> +					 bond_handle_frame,
> +					 RX_HANDLER_PRIO_BOND);

> +	err = netdev_rx_handler_register(dev, &port->rx_handler,
> +					 macvlan_handle_frame,
> +					 RX_HANDLER_PRIO_MACVLAN);

> +	err = netdev_rx_handler_register(dev, &p->rx_handler, br_handle_frame,
> +					 RX_HANDLER_PRIO_BRIDGE);

> +enum rx_handler_prio {
> +	RX_HANDLER_PRIO_BRIDGE,
> +	RX_HANDLER_PRIO_BOND,
> +	RX_HANDLER_PRIO_MACVLAN,
> +};

These are all incompatible with each other to a varying degree and/or
don't make much sense. Let's look at them:

a) a device simultaneously being a bridge member and a bond slave
 -> Fully incompatible. Your bonding peer switch will start sending
    the bridge's packets on other bond member devices.

b) a device having macvlans and being a bond slave
 -> Fully incompatible. Same as above, packets to the macvlan will end
    up on other bond member devices.

c) bridge + macvlan
 -> Mostly useless. Add veth/tap devices to your bridge... as a bonus
    you get a proper MAC table.

This at least needs bonding support removed since bonding is essentially
incompatible with anything else w/ the same reasoning as above. Bonds
are as low-level as Pause frames. Never ever touch individual bond
slaves.

What does make sense is a device being member of multiple bridges, with
ebtables as solicitor for which bridge gets the packet. But that's not
possible with your patch...
+       if (netdev_rx_handler_get_by_prio(dev, prio))
                return -EBUSY;

I think your idea is good, but it needs WAY more proper consideration.


-David

