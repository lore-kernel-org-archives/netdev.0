From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: refresh rt6i_genid in ip6_pol_route()
Date: Sun, 07 Sep 2014 21:59:43 -0700 (PDT)
Message-ID: <20140907.215943.213418445039957641.davem@davemloft.net>
References: <1410149905.11872.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140907.212742.893555292268057160.davem@davemloft.net>
	<1410151434.11872.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, therbert@google.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbaIHE7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 00:59:46 -0400
In-Reply-To: <1410151434.11872.82.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 07 Sep 2014 21:43:54 -0700

> On Sun, 2014-09-07 at 21:27 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Sun, 07 Sep 2014 21:18:25 -0700
>> 
>> > On Sun, 2014-09-07 at 15:54 -0700, David Miller wrote:
>> > 
>> >> This might be broken.
>> >> 
>> >> We are dealing here with persistent entries in the ipv6 routine trie.
>> >> 
>> >> If you just bump the genid on the next person to look it up, other
>> >> sockets and cached entities might not have validated the route yet,
>> >> and now will falsely see the route as valid.  We have to ensure that
>> >> they too drop this route and perform a relookup.
>> > 
>> > I am confused, I thought it was the role of the cookie.
>> > 
>> > (Ie socket has to store its own cookie to be able to validate a route)
>> > 
>> > Before 6f3118b571b8 patch, how was this done anyway ?
>> > 
>> > If persistent routes cannot refresh the genid, then they are useless ?
>> 
>> I just speak about the genid aspect.
>> 
>> I understand that cookie (via node->fn_sernum) invalidates the path
>> in the fib_trie, but the genid protects against other circumstances
>> (matching IPSEC rule, f.e.)
>> 
>> You have to make sure all other sockets did a full route lookup
>> (including IPSEC) before you can safely adjust the genid.
>> 
>> I could be wrong, recheck my analysis please :-)
> 
> So this whole genid protection can not work, unless we make sure a
> socket cannot share a route with another socket.
> 
> This means we have to clone all routes.

I'm willing to revert the change in question if you think that's the
sanest way forward.

The bug fix for more obscure use cases (IPSEC) if pointless if it
breaks more common things (TCP input route caching).
