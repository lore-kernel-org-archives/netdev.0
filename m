From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Mon, 28 Nov 2016 13:01:42 -0500 (EST)
Message-ID: <20161128.130142.1225482479870737422.davem@davemloft.net>
References: <20161128.114703.154301432767947066.davem@davemloft.net>
        <1480352023.18162.63.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480354467.18162.66.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, sfr@canb.auug.org.au, elicooper@gmx.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcK1SBt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 13:01:49 -0500
In-Reply-To: <1480354467.18162.66.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2016 09:34:27 -0800

> On Mon, 2016-11-28 at 08:53 -0800, Eric Dumazet wrote:
>> On Mon, 2016-11-28 at 11:47 -0500, David Miller wrote:
>> > From: Stephen Rothwell <sfr@canb.auug.org.au>
>> > Date: Sun, 27 Nov 2016 13:04:00 +1100
>> > 
>> > > [Just for Dave's information]
>> > > 
>> > > On Fri, 25 Nov 2016 13:50:17 +0800 Eli Cooper <elicooper@gmx.com> wrote:
>> > >>
>> > >> Similar to commit ae148b085876
>> > >> ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"),
>> > >> sit tunnels also need to update skb->protocol; otherwise, TSO/GSO packets
>> > >> might not be properly segmented, which causes the packets being dropped.
>> > >> 
>> > >> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> > >> Tested-by: Eli Cooper <elicooper@gmx.com>
>> > >> Cc: stable@vger.kernel.org
>> > >> Signed-off-by: Eli Cooper <elicooper@gmx.com>
>> > > 
>> > > I tested this patch and it does *not* solve my problem.
>> > 
>> > I'm torn on this patch, because it looked exactly like it would solve the
>> > kind of problem Stephen is running into.
>> > 
>> > Even though it doesn't fix his case, it seems correct to me.
>> > 
>> > I was wondering if it was also important to set the skb->protocol
>> > before the call to ip_tunnel_encap() but I couldn't find a dependency.
>> > 
>> > In any event I'd like to see some other people review this change
>> > before I apply it.
>> > 
>> > My only other guess for Stephen's problem is somehow the SKB headers
>> > aren't set up properly for what the GSO engine expects.
>> 
>> Well, mlx4 just works, and uses GSO engine just fine.
>> 
>> So my guess is this is a bug in Intel IGB driver.
> 
> About Eli patch : I do not believe it is needed.
> 
> Here is the path followed by SIT packet being GSO at the device layer :
> 
> We can see that ip_output() was called, and ip_output() already does :
> 
> skb->protocol = htons(ETH_P_IP);

Hmmm, ip6_finish_output2() also does a proper assignment of skb->protocol,
therefore why was commit ae148b085876fa771d9ef2c05f85d4b4bf09ce0d
("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()")
necessary at all?
