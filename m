From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 1/2] bpf: add a longest prefix match trie map
 implementation
Date: Wed, 18 Jan 2017 14:29:10 -0800
Message-ID: <20170118222907.GA68490@ast-mbp.thefacebook.com>
References: <20170114121727.14784-1-daniel@zonque.org>
 <20170114121727.14784-2-daniel@zonque.org>
 <587A581A.6060304@fb.com>
 <CANq1E4TY1BZfa1da1DB6=M==+JJUuATxT5iCJAAn2_Bi=yuiJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>, Daniel Mack <daniel@zonque.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34092 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750892AbdARW7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 17:59:34 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so1926733pfb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 14:58:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CANq1E4TY1BZfa1da1DB6=M==+JJUuATxT5iCJAAn2_Bi=yuiJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 03:30:14PM +0100, David Herrmann wrote:
> Hi
> 
> On Sat, Jan 14, 2017 at 5:55 PM, Alexei Starovoitov <ast@fb.com> wrote:
> > Another alternative is to extend samples/bpf/map_perf_test
> > It has perf tests for most map types today (including lru)
> > and trie would be natural addition there.
> > I would prefer this latter option.
> 
> I hooked into gettid() and installed a simple kprobe bpf program that
> searches for an entry in an lpm trie. The bpf program does either 0,
> 1, 8, or 32 lookups in a row (always the same element). The trie has
> size 0, 1, or 8192. The data is below. The results vary by roughly 5%
> on every run.
> 
> A single gettid() syscall with an empty bpf program takes roughly
> 6.5us on my system. Lookups in empty tries take ~1.8us on first try,
> ~0.9us on retries. Lookups in tries with 8192 entries take ~7.1us (on
> the first _and_ any subsequent try).

thanks. please add them to commit log.

> https://gist.github.com/dvdhrm/4c90e61a1c39746d5c55ab9e0e29315e

looks good. please add it as an extra patch to this set.
and add
#pragma clang loop unroll(full)
before
+       for (i = 0; i < 8; ++i)
+               bpf_map_lookup_elem(&lpm_trie_map_alloc, &key);
to make sure it's unrolled regardless of the version of llvm.

> Trie-size: 0
> #Lookups: 0
>     0:lpm_perf kmalloc 9,230,321 events per sec
>     -> 6.5us / syscall
> 
> Trie-size: 1
> #Lookups: 1
>     0:lpm_perf kmalloc 7,224,508 events per sec
>     -> 8.3us / syscall
> 
> Trie-size: 1
> #Lookups: 8
>     0:lpm_perf kmalloc 4,152,740 events per sec
>     -> 14.4us / syscall
> 
> Trie-size: 1
> #Lookups: 32
>     0:lpm_perf kmalloc 1,713,415 events per sec
>     -> 35.0us / syscall
> 
> Trie-size: 8192
> #Lookups: 1
>     0:lpm_perf kmalloc 4,369,138 events per sec
>     -> 13.7us / syscall
> 
> Trie-size: 8192
> #Lookups: 8
>     0:lpm_perf kmalloc 943,849 events per sec
>     -> 63.6us / syscall
> 
> Trie-size: 8192
> #Lookups: 32
>     0:lpm_perf kmalloc 271,737 events per sec
>     -> 220.8us / syscall

so it's the same lookup done 32-times per each syscall.
Since the latency of single lookup in 8 vs 32 experiments
are pretty close, it means that the 32 lookup numbers
amortize the cost of syscall pretty well and no need to go higher.
So I would use 32 as a loop count in stress_lpm_trie_map_alloc()

Thanks!
