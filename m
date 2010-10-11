From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] net: introduce alloc_skb_order0
Date: Mon, 11 Oct 2010 17:55:57 +0200
Message-ID: <20101011155556.GA2431@redhat.com>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
 <20101008145256.GB10393@redhat.com>
 <1286550247.2959.444.camel@edumazet-laptop>
 <20101008160341.GC10393@redhat.com>
 <1286639996.2692.148.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754111Ab0JKPx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 11:53:58 -0400
Content-Disposition: inline
In-Reply-To: <1286639996.2692.148.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 09, 2010 at 05:59:56PM +0200, Eric Dumazet wrote:
> Le vendredi 08 octobre 2010 =E0 18:03 +0200, Stanislaw Gruszka a =E9c=
rit :
> > On Fri, Oct 08, 2010 at 05:04:07PM +0200, Eric Dumazet wrote:
>=20
> > > Switch to SLAB -> no more problem ;)
> >=20
> > yeh, I wish to, but fedora use SLUB because of some debugging
> > capabilities.=20
>=20
> Yes, of course, I was kidding :)
>=20
> echo 0 >/sys/kernel/slab/kmalloc-2048/order
> echo 0 >/sys/kernel/slab/kmalloc-1024/order
> echo 0 >/sys/kernel/slab/kmalloc-512/order
>=20
> Should do the trick : No more high order allocations for MTU=3D1500
> frames.

So the SLUB is great, but we need a patch to avoid using it :-)

> For MTU=3D9000 frames, we probably need something like this patch :
>
> Reception of big frames hit a memory allocation problem, because of h=
igh
> order pages allocations (order-3 sometimes for MTU=3D9000). This patc=
h
> introduces alloc_skb_order0(), to build skbs with order-0 pages only.

I had never seen allocation problems in rtl8169_try_rx_copy or in any
other driver rx path (except iwlwifi, but now this is solved by using
skb_add_rx_frag), so I'm not sure if need this patch.

However I see other benefit of that patch. We save memory. Allocating
for MTU 9000 gives something like skb->data =3D kmalloc(9000 + 32 + 2
+ 334). So we take data from kmalloc-16384 cache, we waste about 7kB on
every allocation. With patch wastage would be about 2k per allocation
(assuming 4kB and 8kB page size)

However I started this thread thinking about other memory wastage,
in rtl8169_alloc_rx_skb, skb->data =3D kmalloc(16383 + 32 + 2 + 334), t=
aken
from kmalloc-32768, almost 50% wastage.
=20
> +struct sk_buff *alloc_skb_order0(int pkt_size)
> +{
> +	int head =3D min_t(int, pkt_size, SKB_MAX_HEAD(NET_SKB_PAD + NET_IP=
_ALIGN));
> +	struct sk_buff *skb;
> +
> +	skb =3D alloc_skb(head + NET_SKB_PAD + NET_IP_ALIGN,
> +			GFP_ATOMIC | __GFP_NOWARN);
> +	if (!skb)
> +		return NULL;
> +	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
> +	skb_put(skb, head);
> +	pkt_size -=3D head;
> +
> +	skb->len +=3D pkt_size;
> +	skb->data_len +=3D pkt_size;
> +	skb->truesize +=3D pkt_size;
> +	while (pkt_size) {

if (skb_shinfo(skb)->nr_frags =3D=3D MAX_SKB_FRAGS - 1)
	goto error;

> +		int i =3D skb_shinfo(skb)->nr_frags++;
> +		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> +		int fragsize =3D min_t(int, pkt_size, PAGE_SIZE);
> +		struct page *page =3D alloc_page(GFP_NOWAIT | __GFP_NOWARN);
> +
> +		if (!page)
> +			goto error;
> +		frag->page =3D page;
> +		frag->size =3D fragsize;
> +		frag->page_offset =3D 0;
> +		pkt_size -=3D fragsize;
> +	}
> +	return skb;
> +
> +error:
> +	kfree_skb(skb);
> +	return NULL;=09
> +}
> +EXPORT_SYMBOL(alloc_skb_order0);
> +
>  /* Checksum skb data. */
> =20
>  __wsum skb_checksum(const struct sk_buff *skb, int offset,
