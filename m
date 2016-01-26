From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on inactive
 slaves
Date: Tue, 26 Jan 2016 16:35:29 -0500
Message-ID: <20160126213529.GS59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453562589.1223.445.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160126211453.GQ59058@redhat.com>
 <CANn89iJeQKGD+iiU1iX7Ddib1w7EaU9jz0KCk1pajp7s9LXc7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbcAZVfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 16:35:30 -0500
Content-Disposition: inline
In-Reply-To: <CANn89iJeQKGD+iiU1iX7Ddib1w7EaU9jz0KCk1pajp7s9LXc7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2016 at 01:24:59PM -0800, Eric Dumazet wrote:
> On Tue, Jan 26, 2016 at 1:14 PM, Jarod Wilson <jarod@redhat.com> wrote:
> > On Sat, Jan 23, 2016 at 07:23:09AM -0800, Eric Dumazet wrote:
> >> On Fri, 2016-01-22 at 14:11 -0500, Jarod Wilson wrote:
> >>
> >> > ---
> >> >  net/core/dev.c | 3 +++
> >> >  1 file changed, 3 insertions(+)
> >> >
> >> > diff --git a/net/core/dev.c b/net/core/dev.c
> >> > index 8cba3d8..1354c7b 100644
> >> > --- a/net/core/dev.c
> >> > +++ b/net/core/dev.c
> >> > @@ -4153,8 +4153,11 @@ ncls:
> >> >             else
> >> >                     ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> >> >     } else {
> >> > +           if (deliver_exact)
> >> > +                   goto inactive; /* bond or team inactive slave */
> >> >  drop:
> >> >             atomic_long_inc(&skb->dev->rx_dropped);
> >> > +inactive:
> >> >             kfree_skb(skb);
> >> >             /* Jamal, now you will not able to escape explaining
> >> >              * me how you were going to use this. :-)
> >>
> >> Note that if you still have a kfree_skb() instead of consume_skb(),
> >> some tools will still give you a wrong signal (packet dropped ...).
> >>
> >> But then maybe the signal is telling some truth.
> >>
> >> We receive a packet, and decide to drop it because no one was willing to
> >> handle it.
> >>
> >> Maybe someone wants to know a particular slave receives 10,000 such
> >> frames per second and hurts performance with useless work.
> >>
> >> We should at least increment some counter and maybe dump it with
> >> "ethtool -S" or something.
> >
> > I've been digging into ethtool -S a little bit, and am somewhat at a loss
> > as to how I would wire into this. From what I've been able to figure out,
> > it's entirely device-specific-ish counters spit out. On my sfc cards, I
> > get rx_noskb_drops and rx_nodesc_drop_cnt output from ethtool -S, but for
> > the core network stack, these are actually added up and shoved into
> > rx_dropped, and no other network driver has those two individual counters.
> >
> > By itself, rx_dropped isn't output directly anywhere from ethtool,
> > so far as I can see. And ethtool -S bondX shows absolutely nothing.
> > *Should* ethtool -S be dumping all the network core stats? I have to say I
> > was more than a little surprised at this:
> 
> # ip -s -s link sh dev eth0
> 15: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc
> pfifo_fast state DOWN mode DEFAULT group default qlen 1000
>     link/ether 3c:97:0e:be:91:7b brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     0          0        0       0       0       0
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     0          0        0       0       0       0
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0
> 
> So start with the following patch :
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index a30b78090594..7c762cf1e4d5 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -68,6 +68,8 @@ struct rtnl_link_stats64 {
>         /* for cslip etc */
>         __u64   rx_compressed;
>         __u64   tx_compressed;
> +
> +       __u64   rx_nohandler;           /* packet was of no interest */
>  };
> 
>  /* The struct should be in sync with struct ifmap */

I'm already well past that point, using rx_dropped_inactive as the stat
name though, based on the prior discussion. I can certainly convert that
over to rx_nohandler easily enough. It looks like adding a column to ip's
output there would be as simple as fetching the stat over netlink and
spitting it out.

-- 
Jarod Wilson
jarod@redhat.com
