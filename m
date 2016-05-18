From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 11:23:56 +0300
Message-ID: <20160518112225-mutt-send-email-mst@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
 <1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <57397C14.1080701@redhat.com>
 <20160518101359.37f5343b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160518101359.37f5343b@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 10:13:59AM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 16 May 2016 15:51:48 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>=20
> > On 2016=E5=B9=B405=E6=9C=8816=E6=97=A5 11:56, Eric Dumazet wrote:
> > > On Mon, 2016-05-16 at 09:17 +0800, Jason Wang wrote: =20
> > >> We used to queue tx packets in sk_receive_queue, this is less
> > >> efficient since it requires spinlocks to synchronize between pro=
ducer
> > >> and consumer. =20
> > > ...
> > > =20
> > >>   	struct tun_struct *detached;
> > >> +	/* reader lock */
> > >> +	spinlock_t rlock;
> > >> +	unsigned long tail;
> > >> +	struct tun_desc tx_descs[TUN_RING_SIZE];
> > >> +	/* writer lock */
> > >> +	spinlock_t wlock;
> > >> +	unsigned long head;
> > >>   };
> > >>    =20
> > > Ok, we had these kind of ideas floating around for many other cas=
es,
> > > like qdisc, UDP or af_packet sockets...
> > >
> > > I believe we should have a common set of helpers, not hidden in
> > > drivers/net/tun.c but in net/core/skb_ring.c or something, with m=
ore
> > > flexibility (like the number of slots)
> > > =20
> >=20
> > Yes, this sounds good.
>=20
> I agree. It is sad to see everybody is implementing the same thing,
> open coding an array/circular based ring buffer.  This kind of code i=
s
> hard to maintain and get right with barriers etc.  We can achieve the
> same performance with a generic implementation, by inlining the help
> function calls.
>=20
> I implemented an array based Lock-Free/cmpxchg based queue, that you
> could be inspired by, see:
>  https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/=
include/linux/alf_queue.h
>=20
> The main idea behind my implementation is bulking, to amortize the
> locked cmpxchg operation. You might not need it now, but I expect we
> need it in the future.
>=20
> You cannot use my alf_queue directly as your "struct tun_desc" is
> larger than one-pointer (which the alf_queue works with).  But it
> should be possible to extend to handle larger "objects".
>=20
>=20
> Maybe Steven Rostedt have an even better ring queue implementation
> already avail in the kernel?

BTW at least for tun, index based isn't really needed.
A simple array seems to be more readable, faster and use less memory.
I have implemented this and it seems to work OK, will
post shortly.



> --=20
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
