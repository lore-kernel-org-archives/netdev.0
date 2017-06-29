From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: prevent leaking pointer via xadd on
 unpriviledged
Date: Thu, 29 Jun 2017 15:45:10 -0400 (EDT)
Message-ID: <20170629.154510.1016576510128739964.davem@davemloft.net>
References: <1fe53aa29cf003f14acf4b490e5eff038718444a.1498697608.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, kafai@fb.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752111AbdF2TpM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:45:12 -0400
In-Reply-To: <1fe53aa29cf003f14acf4b490e5eff038718444a.1498697608.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 29 Jun 2017 03:04:59 +0200

> Leaking kernel addresses on unpriviledged is generally disallowed,
> for example, verifier rejects the following:
> 
>   0: (b7) r0 = 0
>   1: (18) r2 = 0xffff897e82304400
>   3: (7b) *(u64 *)(r1 +48) = r2
>   R2 leaks addr into ctx
> 
> Doing pointer arithmetic on them is also forbidden, so that they
> don't turn into unknown value and then get leaked out. However,
> there's xadd as a special case, where we don't check the src reg
> for being a pointer register, e.g. the following will pass:
> 
>   0: (b7) r0 = 0
>   1: (7b) *(u64 *)(r1 +48) = r0
>   2: (18) r2 = 0xffff897e82304400 ; map
>   4: (db) lock *(u64 *)(r1 +48) += r2
>   5: (95) exit
> 
> We could store the pointer into skb->cb, loose the type context,
> and then read it out from there again to leak it eventually out
> of a map value. Or more easily in a different variant, too:
> 
>    0: (bf) r6 = r1
>    1: (7a) *(u64 *)(r10 -8) = 0
>    2: (bf) r2 = r10
>    3: (07) r2 += -8
>    4: (18) r1 = 0x0
>    6: (85) call bpf_map_lookup_elem#1
>    7: (15) if r0 == 0x0 goto pc+3
>    R0=map_value(ks=8,vs=8,id=0),min_value=0,max_value=0 R6=ctx R10=fp
>    8: (b7) r3 = 0
>    9: (7b) *(u64 *)(r0 +0) = r3
>   10: (db) lock *(u64 *)(r0 +0) += r6
>   11: (b7) r0 = 0
>   12: (95) exit
> 
>   from 7 to 11: R0=inv,min_value=0,max_value=0 R6=ctx R10=fp
>   11: (b7) r0 = 0
>   12: (95) exit
> 
> Prevent this by checking xadd src reg for pointer types. Also
> add a couple of test cases related to this.
> 
> Fixes: 1be7f75d1668 ("bpf: enable non-root eBPF programs")
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
