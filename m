From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Mon, 03 Dec 2012 14:11:28 -0500 (EST)
Message-ID: <20121203.141128.206409637987621093.davem@davemloft.net>
References: <20121130.122243.710720011890818822.davem@davemloft.net>
	<1354538763-2678-1-git-send-email-dries.dewinter@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: dries.dewinter@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1354538763-2678-1-git-send-email-dries.dewinter@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dries De Winter <dries.dewinter@gmail.com>
Date: Mon,  3 Dec 2012 13:46:03 +0100

> The IPv6 mangle table may change the source/destination address and skb->mark
> of a packet. Therefore it may be necessary to "reroute" a packet after it
> traversed this table. But this should not happen for some special packets like
> neighbour solicitations and MLD reports: they have an explicit destination, not
> originating from the routing table. Rerouting these packets may cause them to
> go out on the wrong interface or not to go out at all depending on the routing
> table.
> 
> This patch allows to mark a dst_entry as "non-reroutable". icmp6_dst_alloc()
> (used by ndisc and MLD implementation) will always mark the allocated dst_entry
> as such. A check is added to netfilter (IPv6-only) so packets heading for a
> non-reroutable destination are never rerouted.
> 
> Remarks:
> 
> (1) dst entries allocated by addrconf_dst_alloc() are added to the routing
> table like normal routes and skbuffs get assigned such dst entries by normal
> rule lookup / route lookup. Therefore it's not needed to mark those dst
> entries as non-reroutable: if an skbuff got assigned such a dst entry by
> normal routing in the first place, and the changes done by the mangle table
> don't affect routing, rerouting the packet will get it there too.
> 
> (2) Similar logic exists in IPv4 so local multicast/broadcast messages are
> potentially transmitted on the wrong interface. However, it's a less likely
> corner case there because those packets are treated differently by local
> output routing: multicast/broadcast messages are by default routed to the
> interface with a matching source IP-address. But this logic is invalid because
> it is allowed to (1) send messages with a source IP-address different from
> your own and (2) to assign the same IP-address on multiple interfaces.
> So ideally in IPv4 some dsts should be marked as non-reroutable as well.
> 
> Signed-off-by: Dries De Winter <dries.dewinter@gmail.com>

Thinking about this some more I can't see how this is correct.

What if netfilter modified one of the keys that go into the route
lookup such as the source or destination address?

That's the whole point of this reroute call.

I'm not applying this, sorry.
