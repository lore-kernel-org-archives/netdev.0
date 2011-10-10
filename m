From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] truesize lies
Date: Mon, 10 Oct 2011 08:54:57 +0200
Message-ID: <1318229697.21116.23.camel@edumazet-laptop>
References: <1318186948.5276.49.camel@edumazet-laptop>
	 <20111009.172739.2151675769111763947.davem@davemloft.net>
	 <1318197320.21116.11.camel@edumazet-laptop>
	 <20111009.181023.328192272226333109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42479 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab1JJGzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 02:55:05 -0400
Received: by wwf22 with SMTP id 22so8692674wwf.1
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 23:55:04 -0700 (PDT)
In-Reply-To: <20111009.181023.328192272226333109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 09 octobre 2011 =C3=A0 18:10 -0400, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 09 Oct 2011 23:55:20 +0200
>=20
> > Some drivers splits a page in two (or more) pieces, so we cant know=
 what
> > was really reserved by a driver for paged skbs.
> >=20
> > Only thing we could enforce at the moment is the proper accounting =
for
> > skb head :
> >=20
> > WARN_ON(skb->truesize < (skb_end_pointer(skb) - skb->head) + sizeof=
(sk_buff) + skb->data_len);
>=20
> This is partly true.
>=20
> Drivers that use page pools divide pages up into different pools, eac=
h
> with some specific block size.  At least this is how NIU works.
>=20
> So NIU knows exactly how much of the block is logically part of that
> SKB yet unused.
>=20
> And if we really wanted to we could add a frag[].reserved field that
> keeps track of this for debugging.

Hmm, this would still be possible for a driver to lie and consume lot o=
f
ram on 64bit arches.

How about using a "struct page" field then, since for a given page, we
can assume/enforce it was divided in equal units (kind of a negative
order) by a driver.

Instead of using alloc_page(order) a driver could use

alloc_page_truesize(gfp_t mask, int page_order, int subunit_order)

=46or example, an x86 driver using 4KB page splitted in two pieces woul=
d
use alloc_page_truesize(gfp, 0, 1)

To get frag[i].reserved (aka truesize), we then would do

static inline int frag_truesize(const skb_frag_t *frag)
{
	return compound_head(frag->page)->truesize;
}

(Not even sure compound_head() is even necessary here, but I see NIU
uses it in niu_rbr_add_page() ?)
