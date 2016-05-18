From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 10:13:59 +0200
Message-ID: <20160518101359.37f5343b@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
	<1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
	<57397C14.1080701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brouer@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57397C14.1080701@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 May 2016 15:51:48 +0800
Jason Wang <jasowang@redhat.com> wrote:

> On 2016=E5=B9=B405=E6=9C=8816=E6=97=A5 11:56, Eric Dumazet wrote:
> > On Mon, 2016-05-16 at 09:17 +0800, Jason Wang wrote: =20
> >> We used to queue tx packets in sk_receive_queue, this is less
> >> efficient since it requires spinlocks to synchronize between produ=
cer
> >> and consumer. =20
> > ...
> > =20
> >>   	struct tun_struct *detached;
> >> +	/* reader lock */
> >> +	spinlock_t rlock;
> >> +	unsigned long tail;
> >> +	struct tun_desc tx_descs[TUN_RING_SIZE];
> >> +	/* writer lock */
> >> +	spinlock_t wlock;
> >> +	unsigned long head;
> >>   };
> >>    =20
> > Ok, we had these kind of ideas floating around for many other cases=
,
> > like qdisc, UDP or af_packet sockets...
> >
> > I believe we should have a common set of helpers, not hidden in
> > drivers/net/tun.c but in net/core/skb_ring.c or something, with mor=
e
> > flexibility (like the number of slots)
> > =20
>=20
> Yes, this sounds good.

I agree. It is sad to see everybody is implementing the same thing,
open coding an array/circular based ring buffer.  This kind of code is
hard to maintain and get right with barriers etc.  We can achieve the
same performance with a generic implementation, by inlining the help
function calls.

I implemented an array based Lock-Free/cmpxchg based queue, that you
could be inspired by, see:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/in=
clude/linux/alf_queue.h

The main idea behind my implementation is bulking, to amortize the
locked cmpxchg operation. You might not need it now, but I expect we
need it in the future.

You cannot use my alf_queue directly as your "struct tun_desc" is
larger than one-pointer (which the alf_queue works with).  But it
should be possible to extend to handle larger "objects".


Maybe Steven Rostedt have an even better ring queue implementation
already avail in the kernel?

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
