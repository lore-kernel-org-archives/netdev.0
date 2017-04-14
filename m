From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: eBPF - little-endian load instructions?
Date: Fri, 14 Apr 2017 11:42:30 -0700
Message-ID: <20170414184228.GA41922@ast-mbp.thefacebook.com>
References: <1491907114.31620.18.camel@sipsolutions.net>
 <58ECB8CF.8040409@iogearbox.net>
 <1492002120.2855.3.camel@sipsolutions.net>
 <20170412165804.GA75807@ast-mbp.thefacebook.com>
 <1492025919.2855.20.camel@sipsolutions.net>
 <20170413030818.GA42879@ast-mbp.thefacebook.com>
 <1492063125.19193.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34624 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754467AbdDNSmt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 14:42:49 -0400
Received: by mail-pf0-f172.google.com with SMTP id c198so43589558pfc.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 11:42:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492063125.19193.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 07:58:45AM +0200, Johannes Berg wrote:
> On Wed, 2017-04-12 at 20:08 -0700, Alexei Starovoitov wrote:
> 
> > it's really llvm bug that i need fix. It's plain broken
> > to generate what effectively is nop insn for march=bpfeb
> > My only excuse that when that code was written llvm had only
> > march=bpfel.
> > bpfeb was added much later.
> 
> So I'm confused now. Is bpf intended to be endian-independent or not?
> It sounded at first like it was, even if I have a hard time imagining
> how that would even work.

bpf takes endianness of the cpu it runs on.
if we said that bpf 32-bit load insn is little endian, it would have screwed up
all big-endian archs and the other way around.
For both classic and extended the corresponding struct sock_filter and bpf_insn
are encoded in target cpu endianness.
The front-end (clang) needs to run in target endianness as well otherwise
the bcc tracing scripts will be accessing garbage.
In other words you cannot take either classic or extended bpf program
generated for x86 and run it on big-endian. Though you can compile on x86
and run on Arm. Hence two targets for llvm -march=bpfeb and -march=bpfel
If you compile for -march=bpfeb and try to load on x86, the instruction stream
will be rejected by the verifier in early stages, since branch insns and
all immediate values will be wrong.
