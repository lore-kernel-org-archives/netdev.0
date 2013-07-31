From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local
 sockets if we don't cross address family
Date: Tue, 30 Jul 2013 17:01:12 -0700 (PDT)
Message-ID: <20130730.170112.144587526646564755.davem@davemloft.net>
References: <20130730083017.GA7068@order.stressinduktion.org>
	<20130730102611.GB25511@secunet.com>
	<20130730104038.GB7068@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	vi0oss@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758488Ab3GaABN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 20:01:13 -0400
In-Reply-To: <20130730104038.GB7068@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 30 Jul 2013 12:40:38 +0200

> On Tue, Jul 30, 2013 at 12:26:11PM +0200, Steffen Klassert wrote:
>> On Tue, Jul 30, 2013 at 10:30:17AM +0200, Hannes Frederic Sowa wrote:
>> > On Tue, Jul 30, 2013 at 10:21:18AM +0200, Steffen Klassert wrote:
>> > > On Mon, Jul 29, 2013 at 04:50:17PM +0200, Hannes Frederic Sowa wrote:
>> > > > xfrm6_local_error/xfrm4_tunnel_check_size report mtu errors back to a
>> > > > socket in case it is locally generated. If the packet first traversed
>> > > > a 6in4/4in6 tunnel before passing the xfrm layer, we could get a panic
>> > > > because of address family type mismatch in the error reporting functions.
>> > > > 
>> > > 
>> > > So the skb is still owned by a socket of the inner address family.
>> > > Is this intentional? Maybe the ndo_start_xmit() function of the
>> > > tunnel device should orphan the skb if we tunnel the packet
>> > > through a different address family.
>> > 
>> > I thought about this, too. But then we would stop accounting the data
>> > to the socket while it is travelling the stack. I don't know about the
>> > possible problems resulting from this.
>> > 
>> 
>> I'm also not absolutely sure, but we reinsert the packet to
>> the ipv4/ipv6 output path which is also used to output forwarded
>> packets. So the code should be prepared for handling a skb without
>> socket context.
>> 
>> There are already situations where we orphan the skb in some
>> tunnel xmit functions. For example if we tunnel through
>> another namespace.
> 
> Somehow this seems the way to go.

Agreed, I think we should just orphan the SKB.

There was talk about this when the skb_scrub_packet() interface was
added, maybe we should do it unconditionally after all.
