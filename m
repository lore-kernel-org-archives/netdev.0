From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Fri, 2 Dec 2016 15:34:32 -0800
Message-ID: <20161202233430.GA58522@ast-mbp>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
 <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
 <1480707761.3858425.806609417.2E2C5E07@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35380 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754936AbcLBXg7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 18:36:59 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so9186259pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 15:36:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480707761.3858425.806609417.2E2C5E07@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 08:42:41PM +0100, Hannes Frederic Sowa wrote:
> On Fri, Dec 2, 2016, at 20:25, Hannes Frederic Sowa wrote:
> > On 02.12.2016 19:39, Alexei Starovoitov wrote:
> > > On Thu, Dec 01, 2016 at 10:27:12PM +0100, Hannes Frederic Sowa wrote:
> > >> like") and the problematic of parsing DNS packets in XDP due to string
> > >> processing and looping inside eBPF.
> > > 
> > > Hannes,
> > > Not too long ago you proposed a very interesting idea to add
> > > support for bounded loops without adding any new bpf instructions and
> > > changing llvm (which was way better than my 'rep' like instructions
> > > I was experimenting with). I thought systemtap guys also wanted bounded
> > > loops and you were cooperating on the design, so I gave up on my work and
> > > was expecting an imminent patch from you. I guess it sounds like you know
> > > believe that bounded loops are impossible or I misunderstand your statement ?
> > 
> > Your argument was that it would need a new verifier as the current first
> > pass checks that we indeed can lay out the basic blocks as a DAG which
> > the second pass depends on. This would be violated.

yes. today the main part of verifier depends on cfg check that confirms DAG
property of the program. This was done as a simplification for the algorithm,
so any programmer that understands C can understand the verifier code.
It certainly was the case, since most of the people who hacked
verifier had zero compiler background.
Now I'm thinking to introduce proper compiler technologies to it.
On one side it will make the bar to understand higher and on the other
side it will cleanup the logic and reuse tens of years of data flow
analysis theory and will make verifier more robust and mathematically
solid.

> > Because eBPF is available by non privileged users this would need a lot
> > of effort to rewrite and verify (or indeed keep two verifiers in the
> > kernel for priv and non-priv). The verifier itself is exposed to
> > unprivileged users.

I certainly hear your concerns that people unfamiliar with it are simply
scared that more and more verification logic being added. So I don't mind
freezing current verifier for unpriv and let proper data flow analysis
to be done in root only component.

> > Also, by design, if we keep the current limits, this would not give you
> > more instructions to operate on compared to the flattened version of the
> > program, it would merely reduce the numbers of optimizations in LLVM
> > that let the verifier reject the program.

I think we most likely will keep 4k insn limit (since there were no
requests to increase it). The bounded loops will improve performance
and reduce I-cache misses.

> The only solution to protect the verifier, which I saw, would be to
> limit it by time and space, thus making loading of eBPF programs
> depending on how fast and hot (thermal throttling) one CPU thread is.

the verifier already has time and space limits.
See no reason to rely on physical cpu sensors.

> Those are the complexity problems I am talking and concerned about.

Do you have concerns when people implement encryption algorithm
that you're unfamiliar with?
Isn't it much bigger concern, since any bugs in the algorithm
are directly exploitable and when encryption is actually used
it's protecting sensitive data, whereas here the verifier
protects kernel from crashing.
