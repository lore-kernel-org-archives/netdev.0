From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Sat, 12 Nov 2011 15:14:29 +0100
Message-ID: <20111112141429.GA41984@jupiter.n2.diac24.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
 <1320512055-1231037-2-git-send-email-equinox@diac24.net>
 <20111111.202235.1981500713669985784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: equinox@diac24.net, netdev@vger.kernel.org, kaber@trash.net,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:33049 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753530Ab1KLOOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Nov 2011 09:14:38 -0500
Content-Disposition: inline
In-Reply-To: <20111111.202235.1981500713669985784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2011 at 08:22:35PM -0500, David Miller wrote:
> > @@ -87,7 +97,8 @@ struct vlan_group {
> >  					    */
> >  	unsigned int		nr_vlans;
> >  	struct hlist_node	hlist;	/* linked list */
> > -	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
> > +	struct net_device **vlan_devices_arrays[VLAN_N_PROTOCOL]
> > +						[VLAN_GROUP_ARRAY_SPLIT_PARTS];
> >  	struct rcu_head		rcu;
> >  };
> 
> This is a terrible waste of memory.  You're now using 5 times as much space,
> the vast majority of which will be entirely unused.

VLAN_GROUP_ARRAY_SPLIT_PARTS is 8; so the memory consumption of this was
previously 8 * ptr = 64 bytes and is now 5 * 8 * ptr = 320 bytes. I thought
those extra 256 bytes per VLAN-carrying master device are worth the
simplicity, especially since this saves me impacts on 802.1Q C-VLAN
lookup performance elsewhere.

The individual VLAN_GROUP_ARRAY_SPLIT_PARTS are allocated on-demand in
vlan_group_prealloc_vid (net/8021q/vlan.c). They aren't freed if they
get empty, only when all VLANs disappear; that's an issue with the
existing code that could be fixed independently.

> I don't even think it's semantically correct, all these alias QinQ protocol
> values don't provide completely new VLAN_ID name spaces at all.  So this
> layout doesn't even make any sense, you're allowing for something that isn't
> even allowed.

The namespaces are separate. 802.1ad goes to quite some lengths to
replace all occurences of "VLAN ID" with "C-VLAN ID" and introduces the
separate "S-VLAN ID".

Nortel's 0x9?00 protocol values have no spec that i know of... oh, I
could save 192 bytes with an "[ ] Legacy Nortel protocol IDs" switch,
I guess.

> Rework these datastructures to eliminate the wastage please.

I could reverse the order of the id vs. protocol lookups, i.e. grab the
VLAN ID from the table as it was previously and then go hunt for the
device with the correct protocol. That'd require chain-linking or
tabling the devices and make 802.1Q normal/C-VLAN device lookups
slower, which I'd very much like to avoid.

The alternative would be a completely different structure for non-0x8100
VLANs, but that's an entirely different level of complexity there, which
I'm also trying to avoid...


Well, hmm... Suggestions?


-equi
