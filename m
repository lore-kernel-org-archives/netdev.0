From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net] bpf: prevent leaking pointer via xadd on
 unpriviledged
Date: Thu, 29 Jun 2017 17:53:23 +0100
Message-ID: <967f8b61-b38c-d352-1967-14d76255a687@solarflare.com>
References: <1fe53aa29cf003f14acf4b490e5eff038718444a.1498697608.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <kafai@fb.com>, <john.fastabend@gmail.com>,
        <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:60054 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751936AbdF2Qxe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:53:34 -0400
In-Reply-To: <1fe53aa29cf003f14acf4b490e5eff038718444a.1498697608.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/06/17 02:04, Daniel Borkmann wrote:
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
Acked-by: Edward Cree <ecree@solarflare.com>
