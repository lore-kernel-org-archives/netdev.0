From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Sat, 12 Jan 2008 13:08:24 -0800
Message-ID: <20080112130824.54cc1fc3@deepthought>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.659443238@linux-foundation.org>
	<4788A17D.5070903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48820 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757630AbYALVK6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 16:10:58 -0500
In-Reply-To: <4788A17D.5070903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Jan 2008 12:16:13 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Make FIB TRIE go through sparse checker without warnings.
> >=20
> > Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
>=20
> Hi Stephen
>=20
> While reviewing your patches (and fib code) I had some questions :
>=20
> 1) I was wondering isn't trie_collect_stats() a potential cpu hog
> (big latency) ?
>=20
> 2) struct tnode layout
>     If tnode->bits is large enough, we allocate a big area
>     of memory but roughly use only first half of it.
>     We could use a better scheme with an extra indirection. For small
>     nodes, we use space right after tnode, but for big nodes, we allo=
cate
>     a power of two set of pages, to exactly match the memory need.
>=20
> 3) 'pos' and 'bits' fields of 'struct tnode' might be converted to
>     plain uchar, instead of 5-bits fields, to reduce complexity for
>     generated code.
>=20
> 4) full_children & empty_children being 'unsigned short',
>     we probably are limited to 2^15 elements, but I could not
>     find this limit enforced somewhere.

Remember that the code should be optimized for lookup, not management
operations. We ran into this during testing (the test suite was looking
for number of routes), thats why I put in the size field.

The existing dump code is really slow:


1) FIB_TRIE   Under KVM:
     load 164393 routes		12.436 sec
     ip route | wc -l		12.569 sec
     grep /proc/net/route	25.357 sec

99% of the cpu time is spent in nextleaf() during these dump operations=
=2E


2) FIB_HASH 	Under KVM:
     load 164393 routes		10.833 sec
     ip route | wc -l		1.981 sec
     grep /proc/net/route	0.204 sec


--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
