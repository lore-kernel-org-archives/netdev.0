From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Fri, 2 Dec 2016 16:20:16 -0800
Message-ID: <20161203002015.GB58522@ast-mbp>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
 <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
 <5841CE97.3050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34943 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756116AbcLCAUV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 19:20:21 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so4832402pfk.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 16:20:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5841CE97.3050302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 11:42:15AM -0800, John Fastabend wrote:
> >> As far as pattern search for DNS packets...
> >> it was requested by Cloudflare guys back in March:
> >> https://github.com/iovisor/bcc/issues/471
> >> and it is useful for several tracing use cases as well.
> >> Unfortunately no one had time to implement it yet.
> > 
> > The string operations you proposed on the other hand, which would count
> > as one eBPF instructions, would give a lot more flexibility and allow
> > more cycles to burn, but don't help parsing binary protocols like IPv6
> > extension headers.

these are two separate things. we need pattern search regardless
of bounded loops. bpf program shouldn't be doing any complicated
algorithms. The main reasons to have loops are:
- speed up execution (smaller I-cache footprint)
- avoid forcing compiler to unroll loops (easier for users)
- support loops where unroll is not possible (like example below)

> My rough thinking on this was the verifier had to start looking for loop
> invariants and to guarantee termination. Sounds scary in general but
> LLVM could put these in some normal form for us and the verifier could
> only accept decreasing loops, the invariants could be required to be
> integers, etc. By simplifying the loop enough the problem becomes
> tractable.

yep. I think what Hannes was proposing earlier is straighforward
to implement for a compiler guy. The following:
for (int i = 0; i < (var & 0xff); i++)
  sum += map->value[i];  /* map value_size >= 0xff */
is obviously bounded and dataflow analysis can easily prove
that all memory operations are valid.
Static analysis tools do way way more than this.

> I think this would be better than new instructions and/or multiple
> verifiers.

agree that it's better than new instructions that would have
required JIT changes. Though there are pros to new insns too :)
