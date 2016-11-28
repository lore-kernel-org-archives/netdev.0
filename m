From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: Aw: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Mon, 28 Nov 2016 23:02:36 +0100
Message-ID: <b58286a4-d97f-18dd-e5bd-0f69d3746b81@gmx.de>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0228849@AcuExch.aculab.com>
 <1480090590.8455.549.camel@edumazet-glaptop3.roam.corp.google.com>
 <trinity-a100658c-7fd5-47b3-ab3f-1f0a80774ccc-1480091457793@3capp-gmx-bs57>
 <1480101551.8455.557.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:52613 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754109AbcK1WCw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 17:02:52 -0500
In-Reply-To: <1480101551.8455.557.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 25.11.2016 20:19, Eric Dumazet wrote:
> On Fri, 2016-11-25 at 17:30 +0100, Lino Sanfilippo wrote:
>> Hi,
>> 
>> 
>> > 
>> > The READ_ONCE() are documenting the fact that no lock is taken to fetch
>> > the stats, while another cpus might being changing them.
>> > 
>> > I had no answer yet from https://patchwork.ozlabs.org/patch/698449/
>> > 
>> > So I thought it was not needed to explain this in the changelog, given
>> > that it apparently is one of the few things that can block someone to
>> > understand one of my changes :/
>> > 
>> > Apparently nobody really understands READ_ONCE() purpose, it is really a
>> > pity we have to explain this over and over.
>> > 
>> 
>> Even at the risk of showing once more a lack of understanding for
>> READ_ONCE():
>> Does not a READ_ONCE() have to e paired with some kind of
>> WRITE_ONCE()? 
> 
> You are right.
> 
> Although in this case, the producers are using a lock, and do
> 
> ring->packets++;
> 
> We hopefully have compilers/cpus that do not put intermediate garbage in
> ring->packets while doing the increment.
> 
> One problem with :
> 
> WRITE_ONCE(ring->packets, ring->packets + 1);
> 
> is that gcc no longer uses an INC instruction.

I see. So we would have to do something like

tmp = ring->packets;
tmp++;
WRITE_ONCE(ring->packets, tmp);

to use WRITE_ONCE in this case? If so, could it be worth doing something like this to 
have a balanced READ_ONCE, WRITE_ONCE usage?

> 
> Maybe we need some ADD_ONCE(ptr, val) macro doing the proper thing.
> 
>> Furthermore: there a quite some network drivers that ensure visibility
>> of 
>> the descriptor queue indices between xmit and xmit completion function
>> by means of
>> smp barriers. Could all these drivers theoretically be adjusted to use
>> READ_ONCE(),
>> WRITE_ONCE() for the indices instead?
>> 
> 
> Well, for this precise case we do need appropriate smp barriers.
> 
> READ_ONCE() can be better than poor barrier(), look at 
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=b668534c1d9b80f4cda4d761eb11d3a6c9f4ced8
> 
> 

Regards,
Lino
