From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Let's do P4
Date: Tue, 1 Nov 2016 22:06:27 -0700
Message-ID: <CAHo-OoyFjsOxmjmsAA8FjiQf7DLbUHtW8z=JB1JRwJNaHsEWCg@mail.gmail.com>
References: <20161029075328.GB1692@nanopsycho.orion> <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com> <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain> <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion> <58194F83.9020205@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>,
        John Fastabend <john.fastabend@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>,
        Linux NetDev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, prem@barefootnetworks.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>,
        Tom Herbert <tom@herbertland.com>, mattyk@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Florian Fainelli <f.fainelli@gmail.co
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:36591 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbcKBFG3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 01:06:29 -0400
Received: by mail-yb0-f173.google.com with SMTP id v78so1518692ybe.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 22:06:29 -0700 (PDT)
In-Reply-To: <58194F83.9020205@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sorry for jumping into the middle and the delay (plumbers this week). My
> question would be, if the main target is for p4 *offloading* anyway, who
> would use this sw fallback path? Mostly for testing purposes?
>
> I'm not sure about compilerB here and the complexity that needs to be
> pushed into the kernel along with it. I would assume this would result
> in slower code than what the existing P4 -> eBPF front ends for LLVM
> would generate since it could perform all kind of optimizations there,
> that might not be feasible for doing inside the kernel. Thus, if I'd want
> to do that in sw, I'd just use the existing LLVM facilities instead and
> go via cls_bpf in that case.
>
> What is your compilerA? Is that part of tc in user space? Maybe linked
> against LLVM lib, for example? If you really want some sw path, can't tc
> do this transparently from user space instead when it gets a netlink error
> that it cannot get offloaded (and thus switch internally to f_bpf's loader)?

Since we're jumping in the middle ;-)

Ideally we'd have an interface where some generic like program is
loaded into the kernel,
and the kernel core fetches some sort of generic description of the
hardware capabilities,
translates the program and fits as much of it as it can into the hardware,
possibly all of it, and emulates/executes the rest in software.

ie. if hardware can only match on 5 different 10 byte headers, but we
need to match on 7 different 12 byte headers,
we can still use the hardware to help us dispatch straight into 'check
the last 2 bytes, then the last 2 headers' software emulation code.

or maybe hardware can match, but can't count packets... so we need to
implement counting in sw.

or it can't do all types of encap/decap, so we need to sw encap in
certain cases...

Doing this via extracting such information out of a bpf program seems
pretty hard.

Or maybe I'm overestimating the true difficulty of taking a bpf
program and extracting it into a TCAM...
Maybe if the bpf program has a more 'standard' layout
(ie. a tree doing packet parsing/matching, with 'actions' in the
leaves) then it's not so hard?...

Obviously real hardware has significantly more capabilities then just
a tcam at the front of the pipeline...

I'm afraid I lack the knowledge of what the real capabilities of
current (and future...) hardware are...

But maybe we could come up with some sufficiently generic description
of *what* we want accomplished
instead of the precise specifics of how.
