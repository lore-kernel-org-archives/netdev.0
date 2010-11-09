From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v2)
Date: Tue, 9 Nov 2010 13:38:20 -0500
Message-ID: <20101109183820.GA8069@hmsreliant.think-freely.org>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
 <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
 <1289325753.2774.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, zenczykowski@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37352 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253Ab0KISke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 13:40:34 -0500
Content-Disposition: inline
In-Reply-To: <1289325753.2774.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 07:02:32PM +0100, Eric Dumazet wrote:
> Le mardi 09 novembre 2010 =E0 12:46 -0500, nhorman@tuxdriver.com a =E9=
crit :
> > From: Neil Horman <nhorman@tuxdriver.com>
> >=20
> > Version 2 of this patch.  Sorry its been awhile, but I've had other=
 issues come
> > up.  I've re-written this patch taking into account the change note=
s from the
> > last round
> >=20
> > Change notes:
> > 1) Rewrote the patch to not do all my previous stupid vmaps on sing=
le page
> > arrays.  Instead we just use vmalloc now.
> >=20
> > 2) Checked into the behavior of tcpdump on high order allocations i=
n the failing
> > case.  Tcpdump (more specifically I think libpcap) does attempt to =
minimize the
> > allocation order on the ring buffer, unfortunately the lowest it wi=
ll push the
> > ordrer too given a sufficiently large buffer is order 5, so its sti=
ll a very
> > large contiguous allocation, and that says nothing of other malicio=
us
> > applications that might try to do more.
> >=20
> > Summary:
> > It was shown to me recently that systems under high load were drive=
n very deep
> > into swap when tcpdump was run.  The reason this happened was becau=
se the
> > AF_PACKET protocol has a SET_RINGBUFFER socket option that allows t=
he user space
> > application to specify how many entries an AF_PACKET socket will ha=
ve and how
> > large each entry will be.  It seems the default setting for tcpdump=
 is to set
> > the ring buffer to 32 entries of 64 Kb each, which implies 32 order=
 5
> > allocation.  Thats difficult under good circumstances, and horrid u=
nder memory
> > pressure.
> >=20
> > I thought it would be good to make that a bit more usable.  I was g=
oing to do a
> > simple conversion of the ring buffer from contigous pages to iovecs=
, but
> > unfortunately, the metadata which AF_PACKET places in these buffers=
 can easily
> > span a page boundary, and given that these buffers get mapped into =
user space,
> > and the data layout doesn't easily allow for a change to padding be=
tween frames
> > to avoid that, a simple iovec change is just going to break user sp=
ace ABI
> > consistency.
> >=20
> > So I've done this, I've added a three tiered mechanism to the af_pa=
cket set_ring
> > socket option.  It attempts to allocate memory in the following ord=
er:
> >=20
> > 1) Using __get_free_pages with GFP_NORETRY set, so as to fail quick=
ly without
> > digging into swap
> >=20
> > 2) Using vmalloc
> >=20
> > 3) Using __get_free_pages with GFP_NORETRY clear, causing us to try=
 as hard as
> > needed to get the memory
> >=20
> > The effect is that we don't disturb the system as much when we're u=
nder load,
> > while still being able to conduct tcpdumps effectively.
> >=20
> > Tested successfully by me.
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > ---
> >  net/packet/af_packet.c |   84 ++++++++++++++++++++++++++++++++++++=
++---------
> >  1 files changed, 68 insertions(+), 16 deletions(-)
> >=20
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 3616f27..d1148ac 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -163,8 +163,14 @@ struct packet_mreq_max {
> >  static int packet_set_ring(struct sock *sk, struct tpacket_req *re=
q,
> >  		int closing, int tx_ring);
> > =20
> > +#define PGV_FROM_VMALLOC 1
> > +struct pgv {
> > +	char *buffer;
> > +	unsigned char flags;
> > +};
> > +
> >  struct packet_ring_buffer {
> > -	char			**pg_vec;
> > +	struct pgv		*pg_vec;
> >  	unsigned int		head;
> >  	unsigned int		frames_per_block;
> >  	unsigned int		frame_size;
> > @@ -283,7 +289,8 @@ static void *packet_lookup_frame(struct packet_=
sock *po,
> >  	pg_vec_pos =3D position / rb->frames_per_block;
> >  	frame_offset =3D position % rb->frames_per_block;
> > =20
> > -	h.raw =3D rb->pg_vec[pg_vec_pos] + (frame_offset * rb->frame_size=
);
> > +	h.raw =3D rb->pg_vec[pg_vec_pos].buffer +
> > +		(frame_offset * rb->frame_size);
> > =20
> >  	if (status !=3D __packet_get_status(po, h.raw))
> >  		return NULL;
> > @@ -2322,37 +2329,74 @@ static const struct vm_operations_struct pa=
cket_mmap_ops =3D {
> >  	.close	=3D	packet_mm_close,
> >  };
> > =20
> > -static void free_pg_vec(char **pg_vec, unsigned int order, unsigne=
d int len)
> > +static void free_pg_vec(struct pgv *pg_vec, unsigned int order,
> > +			unsigned int len)
> >  {
> >  	int i;
> > =20
> >  	for (i =3D 0; i < len; i++) {
> > -		if (likely(pg_vec[i]))
> > -			free_pages((unsigned long) pg_vec[i], order);
> > +		if (likely(pg_vec[i].buffer)) {
> > +			if (pg_vec[i].flags & PGV_FROM_VMALLOC)
> > +				vfree(pg_vec[i].buffer);
> > +			else
> > +				free_pages((unsigned long)pg_vec[i].buffer,
> > +					   order);
> > +			pg_vec[i].buffer =3D NULL;
> > +		}
> >  	}
> >  	kfree(pg_vec);
> >  }
> > =20
> > -static inline char *alloc_one_pg_vec_page(unsigned long order)
> > +static inline char *alloc_one_pg_vec_page(unsigned long order,
> > +					  unsigned char *flags)
> >  {
> > -	gfp_t gfp_flags =3D GFP_KERNEL | __GFP_COMP | __GFP_ZERO | __GFP_=
NOWARN;
> > +	char *buffer =3D NULL;
> > +	gfp_t gfp_flags =3D GFP_KERNEL | __GFP_COMP |
> > +			  __GFP_ZERO | __GFP_NOWARN | __GFP_NORETRY;
> > +
> > +	buffer =3D (char *) __get_free_pages(gfp_flags, order);
> > +
> > +	if (buffer)
> > +		return buffer;
> > +
> > +	/*
> > +	 * __get_free_pages failed, fall back to vmalloc
> > +	 */
> > +	*flags |=3D PGV_FROM_VMALLOC;
> > +	buffer =3D vmalloc((1 << order) * PAGE_SIZE);
> > =20
> > -	return (char *) __get_free_pages(gfp_flags, order);
> > +	if (buffer)
> > +		return buffer;
> > +
> > +	/*
> > +	 * vmalloc failed, lets dig into swap here
> > +	 */
> > +	*flags =3D 0;
> > +	gfp_flags &=3D ~__GFP_NORETRY;
> > +	buffer =3D (char *)__get_free_pages(gfp_flags, order);
> > +	if (buffer)
> > +		return buffer;
> > +
> > +	/*
> > +	 * complete and utter failure
> > +	 */
> > +	return NULL;
> >  }
> > =20
> > -static char **alloc_pg_vec(struct tpacket_req *req, int order)
> > +static struct pgv *alloc_pg_vec(struct tpacket_req *req, int order=
)
> >  {
> >  	unsigned int block_nr =3D req->tp_block_nr;
> > -	char **pg_vec;
> > +	struct pgv *pg_vec;
> >  	int i;
> > =20
> > -	pg_vec =3D kzalloc(block_nr * sizeof(char *), GFP_KERNEL);
> > +	pg_vec =3D kzalloc(block_nr * sizeof(struct pgv), GFP_KERNEL);
>=20
> While we are at it, we could check block_nr being a sane value here ;=
)
>=20
This is true.  What do you think a reasonable sane value is?  libpcap s=
eems to
limit itself to 32 order 5 entries in the ring, but that seems a bit ar=
bitrary.
Perhaps we could check and limit allocations to being no more than orde=
r 8
(1Mb), and a total allocation of no more than perhaps max(32Mb, 1% of a=
ll ram)?
Just throwing it out there, open to any suggestions here

> Nice stuff Neil !
>=20
Thanks!
Neil

>=20
>=20
