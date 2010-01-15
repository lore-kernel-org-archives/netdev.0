From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 01:26:13 -0800 (PST)
Message-ID: <20100115.012613.223485835.davem@davemloft.net>
References: <4B5011F4.8010204@gmail.com>
	<20100115.004915.64525965.davem@davemloft.net>
	<412e6f7f1001150120r622450eem2d9f54da27c42fba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36905
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932111Ab0AOJ0G convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 04:26:06 -0500
In-Reply-To: <412e6f7f1001150120r622450eem2d9f54da27c42fba@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 15 Jan 2010 17:20:43 +0800

> On Fri, Jan 15, 2010 at 4:49 PM, David Miller <davem@davemloft.net> w=
rote:
>>
>> Actually, no thanks. =A0Have you actually taken a look at
>> ipv6_skip_exthdr()?
>>
>> Do that, then tell me that you want the extra function call, plus al=
l
>> of the processing and data touching that that function does, just to
>> handle the case that there "might" be ipv6 extension headers there.
>>
>=20
> I don't think ipv6_skip_exthdr() is too weight. If there isn't any
> extra header, only some compare and jump instruments are added, and n=
o
> more data references. If there are some headers, I think distributing
> packets among CPUs is more important than the extra cost introduced b=
y
> calling ipv6_skip_exthdr().

Calling a function is expensive.

What was now a leaf function deep in the call chain, will no longer
be, so GCC will need to push all live registers onto the stack,
then reload them back into registers when ipv6_skip_exthdr() returns.

And that function is expensive, it's a lot of code that %99 of the
time serves no purpose at all.

This will be executed for every single packet we process, and Linux
can process millions of packets per second, so every cycle and every
memory reference matters.

> Maybe they don't know it.If it was a performance regression, I think
> more people might pay attention on it.

And we can address such a problem at that time.

Can you show a real life setup that sees ipv6 packets with extension
headers and would be effected by this?

Really, I do not want to bloat up this path with useless code
execution when for all practical purposes it really doesn't matter.
