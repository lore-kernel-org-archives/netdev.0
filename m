From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] netlink: use jhash as hashfn for rhashtable
Date: Mon, 08 Dec 2014 18:25:39 +0100
Message-ID: <1418059539.290986.200302913.180EA222@webmail.messagingengine.com>
References: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
 <1418057780.29477.12.camel@localhost>
 <CAA93jw5bAqxbpxyOHEHd6XSEn4-HK0a9qw3Cb_Vecb8Nz=xbfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:35395 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831AbaLHRZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 12:25:40 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 064FF20C53
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 12:25:39 -0500 (EST)
In-Reply-To: <CAA93jw5bAqxbpxyOHEHd6XSEn4-HK0a9qw3Cb_Vecb8Nz=xbfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, Dec 8, 2014, at 18:20, Dave Taht wrote:
> On Mon, Dec 8, 2014 at 8:56 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Mo, 2014-12-08 at 17:30 +0100, Daniel Borkmann wrote:
> >> For netlink, we shouldn't be using arch_fast_hash() as a hashing
> >> discipline, but rather jhash() instead.
> 
> I am not particularly happy with the amount of entropy in
> 
> static inline u32 ipv6_addr_hash(const struct in6_addr *a)
> {
> #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG ==
> 64
>         const unsigned long *ul = (const unsigned long *)a;
>         unsigned long x = ul[0] ^ ul[1];
> 
>         return (u32)(x ^ (x >> 32));
> #else
>         return (__force u32)(a->s6_addr32[0] ^ a->s6_addr32[1] ^
>                              a->s6_addr32[2] ^ a->s6_addr32[3]);
> #endif
> }
> 
> is this worth improving somehow?
> 

That's e.g. the reason why we have

commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Fri Mar 15 11:32:30 2013 +0000

    inet: limit length of fragment queue hash table bucket lists

Note, __ipv6_addr_jhash (xoring the upper 32 bit before jhashing them)
has the same problem. I currently cannot spot any problematic users in
the kernel, flow dissector hashes are insecure by nature, local
addresses normally don't have problems with hash collisions. But maybe I
should redo an audit. :)

Bye,
Hannes
