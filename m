From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Aw: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Mon, 28 Nov 2016 16:19:19 -0800
Message-ID: <1480378759.18162.105.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0228849@AcuExch.aculab.com>
         <1480090590.8455.549.camel@edumazet-glaptop3.roam.corp.google.com>
         <trinity-a100658c-7fd5-47b3-ab3f-1f0a80774ccc-1480091457793@3capp-gmx-bs57>
         <1480101551.8455.557.camel@edumazet-glaptop3.roam.corp.google.com>
         <b58286a4-d97f-18dd-e5bd-0f69d3746b81@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34638 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbcK2AUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 19:20:22 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so14464881pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 16:20:22 -0800 (PST)
In-Reply-To: <b58286a4-d97f-18dd-e5bd-0f69d3746b81@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 23:02 +0100, Lino Sanfilippo wrote:
> Hi Eric,
> 
> On 25.11.2016 20:19, Eric Dumazet wrote:
> > On Fri, 2016-11-25 at 17:30 +0100, Lino Sanfilippo wrote:
> >> Hi,
> >> 
> >> 
> >> > 
> >> > The READ_ONCE() are documenting the fact that no lock is taken to fetch
> >> > the stats, while another cpus might being changing them.
> >> > 
> >> > I had no answer yet from https://patchwork.ozlabs.org/patch/698449/
> >> > 
> >> > So I thought it was not needed to explain this in the changelog, given
> >> > that it apparently is one of the few things that can block someone to
> >> > understand one of my changes :/
> >> > 
> >> > Apparently nobody really understands READ_ONCE() purpose, it is really a
> >> > pity we have to explain this over and over.
> >> > 
> >> 
> >> Even at the risk of showing once more a lack of understanding for
> >> READ_ONCE():
> >> Does not a READ_ONCE() have to e paired with some kind of
> >> WRITE_ONCE()? 
> > 
> > You are right.
> > 
> > Although in this case, the producers are using a lock, and do
> > 
> > ring->packets++;
> > 
> > We hopefully have compilers/cpus that do not put intermediate garbage in
> > ring->packets while doing the increment.
> > 
> > One problem with :
> > 
> > WRITE_ONCE(ring->packets, ring->packets + 1);
> > 
> > is that gcc no longer uses an INC instruction.
> 
> I see. So we would have to do something like
> 
> tmp = ring->packets;
> tmp++;
> WRITE_ONCE(ring->packets, tmp);


Well, gcc will generate a code with more instructions than a mere 

"inc  offset(%register)"


Which is kind of unfortunate, given it is the fast path.

Better add a comment, like :

/* We should use WRITE_ONCE() to pair with the READ_ONCE() found in xxxx()
 * But gcc would generate non optimal code.
 */
