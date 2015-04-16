From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 11:32:18 -0400 (EDT)
Message-ID: <20150416.113218.1551818529213866015.davem@davemloft.net>
References: <20150413.135348.461869719021663434.davem@davemloft.net>
	<20150416045622.GA12454@gondor.apana.org.au>
	<20150416052357.GA3285@acer.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, fw@strlen.de, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbbDPPcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 11:32:22 -0400
In-Reply-To: <20150416052357.GA3285@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 16 Apr 2015 06:24:00 +0100

> On 16.04, Herbert Xu wrote:
>> David Miller <davem@davemloft.net> wrote:
>> > 
>> > Because then there is no ambiguity at all, you preserve on output
>> > exactly what you had on input.  The same geometry, the same
>> > everything.  No special checks, no max frag len, none of this crap.
>> > Those are all hacks trying to work around the _fundamental_ issue
>> > which is that we potentially change the thing when we refrag.
>> 
>> Agreed.  Doing anything other than preserving the original geometry
>> is simply wrong.
>> 
>> However, this doesn't mean that netfilter has to process each
>> fragment.  What we could do is to preserve the original fragments
>> in frag_list and then process the overall skb as a unit in netfilter.
>> 
>> On output we simply fragment according to the original frag_list.
>> 
>> The only thing to watch out for is to eliminate anything in the
>> middle that tries to linearise the skb.
> 
> Netfilter may change the contents of the packet, even change its size.
> It is *really* hard to do this while keeping the original fragments
> intact.

I keep hearing a lot of "it's hard" as the only reason we shouldn't do
this properly, and that frankly sucks.  People aren't looking for a
solution and to be honest it's quite tiring.

The common case is that the rules processed are simple, the size of
the overall packet does _not_ change, and therefore the best thing
to do is pass the entire thing as a unit with the frags in tact.

That's the fundamental fact.  It's also the fastest way to process
these packets and avoids all of these stupid max frag garbage.

Only at the point where netfilter makes changes to the size of the
packet does it take "ownership" and get to take on the responsibility
of making sure the new resulting fragments are sane.

But only at that point.

It must not molest the geometry in any other set of circumstances,
and I absolutely will not relent on this.
