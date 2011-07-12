From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: allow multiple rx_handler registration
Date: Tue, 12 Jul 2011 17:01:22 +0200
Message-ID: <20110712150120.GB2300@minipsycho.brq.redhat.com>
References: <1310468761-2304-1-git-send-email-jpirko@redhat.com>
 <20110712115422.GD616804@jupiter.n2.diac24.net>
 <20110712132005.GA2300@minipsycho.brq.redhat.com>
 <20110712142937.GA909183@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net, greearb@candelatech.com, mirqus@gmail.com
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752651Ab1GLPCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 11:02:36 -0400
Content-Disposition: inline
In-Reply-To: <20110712142937.GA909183@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 12, 2011 at 04:29:38PM CEST, equinox@diac24.net wrote:
>On Tue, Jul 12, 2011 at 03:20:08PM +0200, Jiri Pirko wrote:
>> Tue, Jul 12, 2011 at 01:54:22PM CEST, equinox@diac24.net wrote:
>> >On Tue, Jul 12, 2011 at 01:06:01PM +0200, Jiri Pirko wrote:
>> >> For some net topos it is necessary to have multiple "soft-net-devices"
>> >> hooked on one netdev. For example very common is to have
>> >> eth<->(br+vlan). Vlan is not using rh_handler (yet) but it might be useful
>> >> for other setups.
>> >
>> >I disagree strongly, especially with the use cases you're enabling in
>> >this patch.
>> >
>> >> +	res = netdev_rx_handler_register(slave_dev, &new_slave->rx_handler,
>> >> +					 bond_handle_frame,
>> >> +					 RX_HANDLER_PRIO_BOND);
>> >
>> >> +	err = netdev_rx_handler_register(dev, &port->rx_handler,
>> >> +					 macvlan_handle_frame,
>> >> +					 RX_HANDLER_PRIO_MACVLAN);
>> >
>> >> +	err = netdev_rx_handler_register(dev, &p->rx_handler, br_handle_frame,
>> >> +					 RX_HANDLER_PRIO_BRIDGE);
>> >
>> >> +enum rx_handler_prio {
>> >> +	RX_HANDLER_PRIO_BRIDGE,
>> >> +	RX_HANDLER_PRIO_BOND,
>> >> +	RX_HANDLER_PRIO_MACVLAN,
>> >> +};
>> >
>> >These are all incompatible with each other to a varying degree and/or
>> >don't make much sense. Let's look at them:
>> >
>> >a) a device simultaneously being a bridge member and a bond slave
>> > -> Fully incompatible. Your bonding peer switch will start sending
>> >    the bridge's packets on other bond member devices.
>> 
>> Not possible. See netdev_set_master(). Anyway, before rx_handler was
>> introduced, this was possible and no one cared.
>
>I don't see how this is related. I'm talking about the other end of your
>bond. Like for example the 802.3ad capable switch you're bonding to.

Well it is related in way that you cannot have one device in br an bond
in same time....


>
>> >b) a device having macvlans and being a bond slave
>> > -> Fully incompatible. Same as above, packets to the macvlan will end
>> >    up on other bond member devices.
>> >
>> >c) bridge + macvlan
>> > -> Mostly useless. Add veth/tap devices to your bridge... as a bonus
>> >    you get a proper MAC table.
>> >
>> >This at least needs bonding support removed since bonding is essentially
>> >incompatible with anything else w/ the same reasoning as above. Bonds
>> >are as low-level as Pause frames. Never ever touch individual bond
>> >slaves.
>> >
>> >What does make sense is a device being member of multiple bridges, with
>> >ebtables as solicitor for which bridge gets the packet. But that's not
>> >possible with your patch...
>> >+       if (netdev_rx_handler_get_by_prio(dev, prio))
>> >                return -EBUSY;
>> >
>> >I think your idea is good, but it needs WAY more proper consideration.
>> 
>> This patch doen't introduce anything new which wasn't possible before
>> rx_handler times. Anyway removing bond from using rx_handler as you
>> suggested pushes us back.
>
>I would actually consider this a regression, if the clashing rx_handler
>is the only thing that gets bonding an 'exclusive' hold of the device.

No regression. Regression it would be if something wouldn't work on same
setup. But this is not the case!

>
>> The rationale of this patch is to have all in one place, clean
>> architecture. The rest of problems, like what can be
>> used with what in one time etc can be easily sorted out by follow-up
>> patches.
>
>Yes, I see what you're trying to do. But if your patch goes back to
>allowing broken combinations, I think we need to have those follow-up
>patches right here with this patch.
>
>> And to your idea about multi-bridge support, br co needs to be
>> adjusted as well. And in relation with PRIO, my idea (inspired from RFC
>> of this patch comments) is to allow users to change priorities
>> dynamically from userspace. Also then it could be a range of prios for
>> bridge for example.
>
>Hoping I can convey my point,
>
>
>-David
>
>
>P.S.: Could you please provide some sample usage cases for this feature?

Converting vlan to rx_handler needs this at least.

