From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH] e1000: Real time packets and bytes statistics
Date: Thu, 12 Oct 2006 23:20:18 +0200
Message-ID: <20061012232018.22649cfd.khali@linux-fr.org>
References: <20061011133557.8a404e24.khali@linux-fr.org>
	<4807377b0610111044u5eced127od8272797e63743a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-104-thursday.nerim.net ([62.4.16.104]:28432 "EHLO
	kraid.nerim.net") by vger.kernel.org with ESMTP id S1750952AbWJLVUN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 17:20:13 -0400
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0610111044u5eced127od8272797e63743a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jesse,

On 10/11/06, Jesse Brandeburg wrote:
> On 10/11/06, Jean Delvare wrote:
> > Let the e1000 driver report the most important statistics (rx/tx_bytes
> > and rx/tx_packets) in real time, rather than every other second. This
> > is similar to what the e100 driver is doing.
> >
> > The current asynchronous statistics refresh model makes it impossible
> > to monitor the network traffic with an interval which isn't a multiple
> > of 2 seconds. For example, an interval of 5 seconds would result in a
> > sawtooth diagram (+20%, -20%) for a constant transfer rate. With a 1
> > second interval it's even worse (0, 200%) of course. This has been
> > annoying users for years, but was never actually fixed:
> 
> I think the idea is good, however, see below.

Good news :)

> > I additionally noted a difference of 6 bytes on some TX frames, which
> > I am not able to explain. It's probably small and rare enough not to
> > be considered a problem, but if someone can explain it, I would be
> > grateful.
> 
> now, that sounds odd, however, once again, see below.

What you say below about TSO can't possibly explain this difference, as
your fix is about tx_packets while the difference I observed was on
tx_bytes only, the packet count was always correct. I'll investigate
tomorrow, if I can find a pattern for these differences I might discover
what these bytes are. For now the only idea I have is that 6 bytes is
ETH_ALEN, the size of an ethernet MAC address - but that doesn't
explain anything per se.

> >  drivers/net/e1000/e1000_main.c |   14 ++++++++++----
> >  1 file changed, 10 insertions(+), 4 deletions(-)
> >
> > --- linux-2.6.19-rc1.orig/drivers/net/e1000/e1000_main.c        2006-10-11 10:53:49.000000000 +0200
> > +++ linux-2.6.19-rc1/drivers/net/e1000/e1000_main.c     2006-10-11 11:34:41.000000000 +0200
> > @@ -3118,6 +3118,8 @@
> >                        e1000_tx_map(adapter, tx_ring, skb, first,
> >                                     max_per_txd, nr_frags, mss));
> >
> > +       adapter->net_stats.tx_packets++;
> > +       adapter->net_stats.tx_bytes += skb->len;
> >         netdev->trans_start = jiffies;
> 
> this is the part I'm most worried about.  as I believe it to be
> incorrect for TSO packets.  Maybe something like?

I have to admit I have very little experience with network drivers and
I didn't have the slightest idea what TSO was until I looked into
wikipedia two minutes ago. So I seem to understand that the skb
structure in the code above could correspond to several packets sent on
the wire by the ethernet adapter when TSO is used? Seems to be very
recent, 2.6.16 didn't have that.

> +       if (skb_shinfo(skb)->gso_segs)
> +              adapter->net_stats.tx_packets += skb_shinfo(skb)->gso_segs;
> +       else
> +              adapter->net_stats.tx_packets++;
> +       adapter->net_stats.tx_bytes += skb->len;
>         netdev->trans_start = jiffies;

My comparisons between hardware and software-computed statistics did
not reveal any difference with regards to tx_packets, while there
should have been one if the change above is needed. This suggests that
my tests (run on 2.6.18) did not trigger any TSO packet? Can you
suggest a way to generate such packets so that I am sure I exercise
this code path?

I found an inline function in include/net/tcp.h, tcp_skb_pcount(),
which evaluates to skb_shinfo(skb)->gso_segs. I guess I should use that
instead of the above?

> skb len will still be off by some amount, because the skb->data
> (header) is replicated across each gso segment but only counted once
> this way, but hopefully someone will pipe up with a good way to
> compute that.

And nearby there is another inline function, tcp_skb_mss(), which
evaluates to skb_shinfo(skb)->gso_size... I can't experiment with that
until I know a way to trigger TSO packets, but could it be the size
we're after?

Thanks a lot for your guidance.

-- 
Jean Delvare
