From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 12:12:38 -0700
Message-ID: <1414005158.9031.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Crestez Dan Leonard <cdleonard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:57184 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbaJVTMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 15:12:40 -0400
Received: by mail-pd0-f174.google.com with SMTP id p10so2103640pdj.33
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 12:12:39 -0700 (PDT)
In-Reply-To: <5447FDB2.2010906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 21:55 +0300, Crestez Dan Leonard wrote:
> Hello,
> 
> It seems that the TCP MD5 feature allocates a percpu struct
> tcp_md5sig_pool and uses part of that memory for a scratch buffer to
> do crypto on. Here is the relevant code:
> 
> static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
>                                         __be32 daddr, __be32 saddr,
> int nbytes)
> {
>         struct tcp4_pseudohdr *bp;
>         struct scatterlist sg;
> 
>         bp = &hp->md5_blk.ip4;
> 
>         /*
>          * 1. the TCP pseudo-header (in the order: source IP address,
>          * destination IP address, zero-padded protocol number, and
>          * segment length)
>          */
>         bp->saddr = saddr;
>         bp->daddr = daddr;
>         bp->pad = 0;
>         bp->protocol = IPPROTO_TCP;
>         bp->len = cpu_to_be16(nbytes);
> 
>         sg_init_one(&sg, bp, sizeof(*bp));
>         return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
> }
> 
> sg_init_one does virt_addr on the pointer which assumes it is directly
> accessible. But the tcp_md5sig_pool pointer comes from alloc_percpu
> which can return memory from the vmalloc area after the
> pcpu_first_chunk is exhausted. This looks wrong to me. I'm am getting
> crashes on mips and I believe this to be the cause.



Then just remove the alloc_percpu() from __tcp_alloc_md5sig_pool() and
make this a static per cpu definition (not a dynamic allocation)



> 
> Allocating a scratch buffer this way is very peculiar. The
> tcp4_pseudohdr struct is only 12 bytes in length. Similar code in
> tcp_v6_md5_hash_pseudoheader uses a 40 byte tcp6_pseudohdr. I think it
> is perfectly reasonable to allocate this kind of stuff on the stack,
> right? These pseudohdr structs are not used at all outside these two
> static functions and it would simplify the code.
> 
Yep, but the sg stuff does not allow for stack variables. Because of
possible offloading and DMA, I dont know...

> The whole notion of struct tcp_md5sig_pool seems dubious. This is a
> very tiny struct already and after removing the pseudohdr it shrinks
> to a percpu hash_desc for md5 (8 or 16 bytes). Wouldn't DEFINE_PERCPU
> be more appropriate?

Sure. this would be the more appropriate fix IMO.

>  Before commit 71cea17ed39fdf1c0634f530ddc6a2c2fc601c2b the struct
> tcp_md5sig_pool structs were freed when all users were gone, but that
> functionality seems to have been dropped.
> 
> I'm not familiar with the linux crypto API. Isn't there an easier way
> to get a temporary md5 hasher?

You should CC crypto guys maybe ...

> 
> Here's what I mean by allocating tcp{4,6}_pseudohdr on the stack:

Your patch is quite invasive, you should so something simpler to ease
backports.

Thanks
