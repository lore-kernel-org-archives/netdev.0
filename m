From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] niu: fix skb truesize underestimation
Date: Fri, 14 Oct 2011 20:27:04 +0200
Message-ID: <1318616824.2525.12.camel@edumazet-laptop>
References: <1318545567.2533.46.camel@edumazet-laptop>
	 <20111013.222659.12182837968152363.davem@davemloft.net>
	 <1318563231.2533.55.camel@edumazet-laptop>
	 <20111014.003427.1515514811425011051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49399 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab1JNS1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 14:27:08 -0400
Received: by wwf22 with SMTP id 22so3858666wwf.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 11:27:07 -0700 (PDT)
In-Reply-To: <20111014.003427.1515514811425011051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 00:34 -0400, David Miller a =C3=A9cr=
it :
>=20
> It would be pretty amazing for a leak of this magnitude to exist for
> so long. :-)
>=20
> A page can be split into multiple blocks, each block is some power
> of two in size.
>=20
> The chip splits up "blocks" into smaller (also power of two)
> fragments, and these fragments are what we en-tail to the SKBs.
>=20
> So at the top level we give the chip blocks.  We try to make this
> equal to PAGE_SIZE.  But if PAGE_SIZE is really large we limit the
> block size to 1 << 15.  Note that it is only when we enforce this
> block size limit that the compount_page(page)->_count atomic incremen=
t
> will occur.  As long as PAGE_SIZE <=3D 1 << 15, rbr_blocks_per_page
> will be 1.
>=20
> When the chip takes a block and starts using it, it decides which
> fragment size to use for that block.  Once a fragment size has been
> choosen for a block, it will not change.
>=20
> The fragment sizes the chip can use is stored in rp->rbr_sizes[].  We
> always configure the chip to use 256 byte and 1024 byte blocks, then
> depending upon the MTU and the PAGE_SIZE we'll optionally enable othe=
r
> sizes such as 2048, 4096, and 8192.
>=20
> When we get an RX packet the descriptor tells us the DMA address
> and the fragment size in use for the block that the memory at
> DMA address belongs to.
>=20
> So the two seperate page reference count grabs you see are handling
> references for memory being chopped up at two different levels.
>=20
> I can't see how we could optimize the intra-block refcounts any
> further.  Part of the problem is that we don't know apriori what
> fragment size the chip will use for a given block.
>=20

Thanks for taking the time to explain this David :)
