From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v2)
Date: Tue, 09 Nov 2010 19:02:32 +0100
Message-ID: <1289325753.2774.20.camel@edumazet-laptop>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
	 <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, zenczykowski@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59059 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228Ab0KISCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 13:02:39 -0500
Received: by ewy7 with SMTP id 7so3752507ewy.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 10:02:38 -0800 (PST)
In-Reply-To: <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 12:46 -0500, nhorman@tuxdriver.com a =C3=
=A9crit :
> From: Neil Horman <nhorman@tuxdriver.com>
>=20
> Version 2 of this patch.  Sorry its been awhile, but I've had other i=
ssues come
> up.  I've re-written this patch taking into account the change notes =
from the
> last round
>=20
> Change notes:
> 1) Rewrote the patch to not do all my previous stupid vmaps on single=
 page
> arrays.  Instead we just use vmalloc now.
>=20
> 2) Checked into the behavior of tcpdump on high order allocations in =
the failing
> case.  Tcpdump (more specifically I think libpcap) does attempt to mi=
nimize the
> allocation order on the ring buffer, unfortunately the lowest it will=
 push the
> ordrer too given a sufficiently large buffer is order 5, so its still=
 a very
> large contiguous allocation, and that says nothing of other malicious
> applications that might try to do more.
>=20
> Summary:
> It was shown to me recently that systems under high load were driven =
very deep
> into swap when tcpdump was run.  The reason this happened was because=
 the
> AF_PACKET protocol has a SET_RINGBUFFER socket option that allows the=
 user space
> application to specify how many entries an AF_PACKET socket will have=
 and how
> large each entry will be.  It seems the default setting for tcpdump i=
s to set
> the ring buffer to 32 entries of 64 Kb each, which implies 32 order 5
> allocation.  Thats difficult under good circumstances, and horrid und=
er memory
> pressure.
>=20
> I thought it would be good to make that a bit more usable.  I was goi=
ng to do a
> simple conversion of the ring buffer from contigous pages to iovecs, =
but
> unfortunately, the metadata which AF_PACKET places in these buffers c=
an easily
> span a page boundary, and given that these buffers get mapped into us=
er space,
> and the data layout doesn't easily allow for a change to padding betw=
een frames
> to avoid that, a simple iovec change is just going to break user spac=
e ABI
> consistency.
>=20
> So I've done this, I've added a three tiered mechanism to the af_pack=
et set_ring
> socket option.  It attempts to allocate memory in the following order=
:
>=20
> 1) Using __get_free_pages with GFP_NORETRY set, so as to fail quickly=
 without
> digging into swap
>=20
> 2) Using vmalloc
>=20
> 3) Using __get_free_pages with GFP_NORETRY clear, causing us to try a=
s hard as
> needed to get the memory
>=20
> The effect is that we don't disturb the system as much when we're und=
er load,
> while still being able to conduct tcpdumps effectively.
>=20
> Tested successfully by me.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> ---
>  net/packet/af_packet.c |   84 ++++++++++++++++++++++++++++++++++++++=
---------
>  1 files changed, 68 insertions(+), 16 deletions(-)
>=20
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 3616f27..d1148ac 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -163,8 +163,14 @@ struct packet_mreq_max {
>  static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
>  		int closing, int tx_ring);
> =20
> +#define PGV_FROM_VMALLOC 1
> +struct pgv {
> +	char *buffer;
> +	unsigned char flags;
> +};
> +
>  struct packet_ring_buffer {
> -	char			**pg_vec;
> +	struct pgv		*pg_vec;
>  	unsigned int		head;
>  	unsigned int		frames_per_block;
>  	unsigned int		frame_size;
> @@ -283,7 +289,8 @@ static void *packet_lookup_frame(struct packet_so=
ck *po,
>  	pg_vec_pos =3D position / rb->frames_per_block;
>  	frame_offset =3D position % rb->frames_per_block;
> =20
> -	h.raw =3D rb->pg_vec[pg_vec_pos] + (frame_offset * rb->frame_size);
> +	h.raw =3D rb->pg_vec[pg_vec_pos].buffer +
> +		(frame_offset * rb->frame_size);
> =20
>  	if (status !=3D __packet_get_status(po, h.raw))
>  		return NULL;
> @@ -2322,37 +2329,74 @@ static const struct vm_operations_struct pack=
et_mmap_ops =3D {
>  	.close	=3D	packet_mm_close,
>  };
> =20
> -static void free_pg_vec(char **pg_vec, unsigned int order, unsigned =
int len)
> +static void free_pg_vec(struct pgv *pg_vec, unsigned int order,
> +			unsigned int len)
>  {
>  	int i;
> =20
>  	for (i =3D 0; i < len; i++) {
> -		if (likely(pg_vec[i]))
> -			free_pages((unsigned long) pg_vec[i], order);
> +		if (likely(pg_vec[i].buffer)) {
> +			if (pg_vec[i].flags & PGV_FROM_VMALLOC)
> +				vfree(pg_vec[i].buffer);
> +			else
> +				free_pages((unsigned long)pg_vec[i].buffer,
> +					   order);
> +			pg_vec[i].buffer =3D NULL;
> +		}
>  	}
>  	kfree(pg_vec);
>  }
> =20
> -static inline char *alloc_one_pg_vec_page(unsigned long order)
> +static inline char *alloc_one_pg_vec_page(unsigned long order,
> +					  unsigned char *flags)
>  {
> -	gfp_t gfp_flags =3D GFP_KERNEL | __GFP_COMP | __GFP_ZERO | __GFP_NO=
WARN;
> +	char *buffer =3D NULL;
> +	gfp_t gfp_flags =3D GFP_KERNEL | __GFP_COMP |
> +			  __GFP_ZERO | __GFP_NOWARN | __GFP_NORETRY;
> +
> +	buffer =3D (char *) __get_free_pages(gfp_flags, order);
> +
> +	if (buffer)
> +		return buffer;
> +
> +	/*
> +	 * __get_free_pages failed, fall back to vmalloc
> +	 */
> +	*flags |=3D PGV_FROM_VMALLOC;
> +	buffer =3D vmalloc((1 << order) * PAGE_SIZE);
> =20
> -	return (char *) __get_free_pages(gfp_flags, order);
> +	if (buffer)
> +		return buffer;
> +
> +	/*
> +	 * vmalloc failed, lets dig into swap here
> +	 */
> +	*flags =3D 0;
> +	gfp_flags &=3D ~__GFP_NORETRY;
> +	buffer =3D (char *)__get_free_pages(gfp_flags, order);
> +	if (buffer)
> +		return buffer;
> +
> +	/*
> +	 * complete and utter failure
> +	 */
> +	return NULL;
>  }
> =20
> -static char **alloc_pg_vec(struct tpacket_req *req, int order)
> +static struct pgv *alloc_pg_vec(struct tpacket_req *req, int order)
>  {
>  	unsigned int block_nr =3D req->tp_block_nr;
> -	char **pg_vec;
> +	struct pgv *pg_vec;
>  	int i;
> =20
> -	pg_vec =3D kzalloc(block_nr * sizeof(char *), GFP_KERNEL);
> +	pg_vec =3D kzalloc(block_nr * sizeof(struct pgv), GFP_KERNEL);

While we are at it, we could check block_nr being a sane value here ;)

Nice stuff Neil !


