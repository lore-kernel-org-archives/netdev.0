From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] e1000: Real time packets and bytes statistics
Date: Thu, 12 Oct 2006 10:30:06 -0700
Message-ID: <20061012103006.1367693a@freekitty>
References: <20061011133557.8a404e24.khali@linux-fr.org>
	<4807377b0610111044u5eced127od8272797e63743a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jean Delvare" <khali@linux-fr.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13250 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750961AbWJLRaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 13:30:23 -0400
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0610111044u5eced127od8272797e63743a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Oct 2006 10:44:12 -0700
"Jesse Brandeburg" <jesse.brandeburg@gmail.com> wrote:

> On 10/11/06, Jean Delvare <khali@linux-fr.org> wrote:
> > Hi all,
> >
> > This patch is posted for review and comments.
> >
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
> 
> <snip
> > rx/tx_bytes will show slightly lower values than before, because the
> > hardware appears to include the 4-byte ethernet frame CRC into the
> > frame length, while the driver doesn't. It's probably OK as the
> > e100, 3c59x and 8139too drivers don't include it either.
> 
> this is okay.
> 
> > I additionally noted a difference of 6 bytes on some TX frames, which
> > I am not able to explain. It's probably small and rare enough not to
> > be considered a problem, but if someone can explain it, I would be
> > grateful.
> 
> now, that sounds odd, however, once again, see below.
> 
> > Signed-off-by: Jean Delvare <khali@linux-fr.org>
> > ---
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
> +       if (skb_shinfo(skb)->gso_segs)
> +              adapter->net_stats.tx_packets += skb_shinfo(skb)->gso_segs;
> +       else
> +              adapter->net_stats.tx_packets++;
> +       adapter->net_stats.tx_bytes += skb->len;
>         netdev->trans_start = jiffies;
> 
> skb len will still be off by some amount, because the skb->data
> (header) is replicated across each gso segment but only counted once
> this way, but hopefully someone will pipe up with a good way to
> compute that.
> 
> The rest of the patch seems fine, barring any other comments.
> 
> Jesse

You might want to put the tx values in a per-cpu structure and
sum later.  Incrementing statistics can actually be a performance
bottleneck on SMP tests, because it causes lots of cache thrashing.


-- 
Stephen Hemminger <shemminger@osdl.org>
