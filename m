From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 13:22:05 +0100
Message-ID: <20090107122205.GA6051@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1201 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbZAGMZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 07:25:29 -0500
Content-Disposition: inline
In-Reply-To: <20090107093915.GA6899@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CCing Evgeniy and Herbert who also participate to the thread ]

On Wed, Jan 07, 2009 at 09:39:15AM +0000, Jarek Poplawski wrote:
> On Tue, Jan 06, 2009 at 04:57:15PM +0100, Willy Tarreau wrote:
> > On Tue, Jan 06, 2009 at 10:01:13AM +0000, Jarek Poplawski wrote:
> > > On Tue, Jan 06, 2009 at 10:41:38AM +0100, Willy Tarreau wrote:
> > > ...
> > > > > Great story! Alas I don't understand this fully either, but i=
t seems
> > > > > Changli Gao was concerned with sendpage sending this "as page=
s", so
> > > > > when NETIF_F_SG flag is available. Did you try this without S=
G btw?
> > > >=20
> > > > No I did not. I can try, it's not too hard. It would in part de=
feat the
> > > > purpose of the mechanism (especially at 10 Gbps) but at least i=
t will
> > > > help narrow the problem down.
> > >=20
> > > Yes, I meant it only as a proof of concept. BTW, delaying TCP ack=
s a
> > > bit for these sendpages should then make it more reproducible, I =
guess.
> >=20
> > OK here is an update. It does not change anything to turn off any a=
cceleration
> > feature on the interface (tg3) :
> >=20
> > root@wtap:~# ethtool -k eth0
> > Offload parameters for eth0:
> > rx-checksumming: off
> > tx-checksumming: off
> > scatter-gather: off
> > tcp segmentation offload: off
> >=20
> > It still forwards corrupted data like mad. I noticed that the corru=
ption rate
> > is 10-100 times higher when forwarding from eth0 to eth0 than from =
eth0 to lo.
> >=20
> > Maybe this can help find the culprit ?
>=20
> I hope it will, but I still don't get it. Anyway, here is an untested
> patch, which I guess partly tries Changli Gao's recommendation to giv=
e
> real pages to splice/pipe (but here it's always - not for sendpage
> only).
>
> BTW, I added Changli to Cc - great review!
>=20
> Thanks,
> Jarek P.

Well, I've just tested it. It did not fix the problem but made it worse=
=2E
Sending a few bytes at a time, the corruption is still there, from the
beginning. Here's what I fed :

willy@pcw:~$ nc -lp4001=20
azerazerazerazerazerazer
eiguhaeihgaeighaeighaeirghiareg
aeroigjaeorgjaeorgjaoeigjaeoig
ioejrgoiaerjgoiaerjgoiaerjgaoiejgoaiejg

Here's what I got :

willy@pcw:~$ telnet 10.0.3.2 4000
Trying 10.0.3.2...
Connected to 10.0.3.2.
Escape character is '^]'.
_J0s9=F1uMG1S9=D0t2D$E=F0L$T$

However, when feeding /dev/zero as in previous tests, the kernel panice=
d
in skb_release_data().

Regards,
Willy

> ---
>=20
>  net/core/skbuff.c |   41 +++++++++++++++++++++++++++--------------
>  1 files changed, 27 insertions(+), 14 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5110b35..4c080cd 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -73,17 +73,13 @@ static struct kmem_cache *skbuff_fclone_cache __r=
ead_mostly;
>  static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
>  				  struct pipe_buffer *buf)
>  {
> -	struct sk_buff *skb =3D (struct sk_buff *) buf->private;
> -
> -	kfree_skb(skb);
> +	put_page(buf->page);
>  }
> =20
>  static void sock_pipe_buf_get(struct pipe_inode_info *pipe,
>  				struct pipe_buffer *buf)
>  {
> -	struct sk_buff *skb =3D (struct sk_buff *) buf->private;
> -
> -	skb_get(skb);
> +	get_page(buf->page);
>  }
> =20
>  static int sock_pipe_buf_steal(struct pipe_inode_info *pipe,
> @@ -1334,9 +1330,19 @@ fault:
>   */
>  static void sock_spd_release(struct splice_pipe_desc *spd, unsigned =
int i)
>  {
> -	struct sk_buff *skb =3D (struct sk_buff *) spd->partial[i].private;
> +	put_page(spd->pages[i]);
> +}
> =20
> -	kfree_skb(skb);
> +static inline struct page *linear_to_page(struct page *page, unsigne=
d int len,
> +					  unsigned int offset)
> +{
> +	struct page *p =3D alloc_pages(GFP_KERNEL, 0);
> +
> +	if (!p)
> +		return NULL;
> +	memcpy(p + offset, page + offset, len);
> +
> +	return p;
>  }
> =20
>  /*
> @@ -1344,16 +1350,23 @@ static void sock_spd_release(struct splice_pi=
pe_desc *spd, unsigned int i)
>   */
>  static inline int spd_fill_page(struct splice_pipe_desc *spd, struct=
 page *page,
>  				unsigned int len, unsigned int offset,
> -				struct sk_buff *skb)
> +				struct sk_buff *skb, int linear)
>  {
>  	if (unlikely(spd->nr_pages =3D=3D PIPE_BUFFERS))
>  		return 1;
> =20
> +	if (linear) {
> +		page =3D linear_to_page(page, len, offset);
> +		if (!page)
> +			return 1;
> +	}
> +
>  	spd->pages[spd->nr_pages] =3D page;
>  	spd->partial[spd->nr_pages].len =3D len;
>  	spd->partial[spd->nr_pages].offset =3D offset;
> -	spd->partial[spd->nr_pages].private =3D (unsigned long) skb_get(skb=
);
>  	spd->nr_pages++;
> +	get_page(page);
> +
>  	return 0;
>  }
> =20
> @@ -1369,7 +1382,7 @@ static inline void __segment_seek(struct page *=
*page, unsigned int *poff,
>  static inline int __splice_segment(struct page *page, unsigned int p=
off,
>  				   unsigned int plen, unsigned int *off,
>  				   unsigned int *len, struct sk_buff *skb,
> -				   struct splice_pipe_desc *spd)
> +				   struct splice_pipe_desc *spd, int linear)
>  {
>  	if (!*len)
>  		return 1;
> @@ -1392,7 +1405,7 @@ static inline int __splice_segment(struct page =
*page, unsigned int poff,
>  		/* the linear region may spread across several pages  */
>  		flen =3D min_t(unsigned int, flen, PAGE_SIZE - poff);
> =20
> -		if (spd_fill_page(spd, page, flen, poff, skb))
> +		if (spd_fill_page(spd, page, flen, poff, skb, linear))
>  			return 1;
> =20
>  		__segment_seek(&page, &poff, &plen, flen);
> @@ -1419,7 +1432,7 @@ static int __skb_splice_bits(struct sk_buff *sk=
b, unsigned int *offset,
>  	if (__splice_segment(virt_to_page(skb->data),
>  			     (unsigned long) skb->data & (PAGE_SIZE - 1),
>  			     skb_headlen(skb),
> -			     offset, len, skb, spd))
> +			     offset, len, skb, spd, 1))
>  		return 1;
> =20
>  	/*
> @@ -1429,7 +1442,7 @@ static int __skb_splice_bits(struct sk_buff *sk=
b, unsigned int *offset,
>  		const skb_frag_t *f =3D &skb_shinfo(skb)->frags[seg];
> =20
>  		if (__splice_segment(f->page, f->page_offset, f->size,
> -				     offset, len, skb, spd))
> +				     offset, len, skb, spd, 0))
>  			return 1;
>  	}
> =20
