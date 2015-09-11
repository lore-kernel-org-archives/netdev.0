From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH] ebpf: emit correct src_reg for conditional jumps
Date: Fri, 11 Sep 2015 09:50:34 -0600
Message-ID: <20150911155034.GO27574@smitten>
References: <1441931107-17673-1-git-send-email-tycho.andersen@canonical.com>
 <55F294A9.9020005@iogearbox.net>
 <55F29EB8.50805@iogearbox.net>
 <20150911154041.GA5171@Alexeis-MBP-2.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34354 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846AbbIKPug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 11:50:36 -0400
Received: by iofb144 with SMTP id b144so103116253iof.1
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 08:50:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150911154041.GA5171@Alexeis-MBP-2.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 08:40:43AM -0700, Alexei Starovoitov wrote:
> On Fri, Sep 11, 2015 at 11:28:24AM +0200, Daniel Borkmann wrote:
> > [off topic for this patch]
> > 
> > ... this requirement also breaks down for cases where you have a single
> > classic BPF instruction that maps into 2 or more eBPF instructions, hitting
> > BPF_MAXINSNS early at the time when you try to call into bpf(2) again with
> > the dumped result. If I recall correctly, Chrome seems to use up quite a lot
> > of insns space on (classic) seccomp-BPF, so this could potentially be a real
> > issue, next to artificially crafted examples that would fail.
> > 
> > With regards to the latter, also classic programs that could have holes of
> > dead code where you jump over them (see lib/test_bpf.c for examples) are
> > unfortunately allowed on the ABI side, so while the classic -> eBPF converter
> > may translate this dead region 1:1, it will be rejected by the verifier when
> > you dump and try to reload that. ;) Anyway, it's perhaps a silly example, but
> > it shows that this use-case can only work on a 'best-effort' basis, and not
> > cover everything of the classic BPF ABI, as opposed to having an interface
> > that can dump/restore classic BPF instructions directly.
> > 
> > Do you need this for checkpoint/restore? Wouldn't this therefore be better
> > done as dump/restore classic<->classic and eBPF<->eBPF directly? In socket
> > filters we do this by keeping orig_prog around, I guess it's better to bite
> > the bullet of additional memory overhead in case of classic seccomp-BPF, too.
> 
> I don't think so.
> When I played with libseccomp and chrome I saw that browser installed
> several bpf programs for every new tab. The longest program was 275
> classic insns which translated to slightly more eBPF insns
> (because in eBPF we don't have < and <= instructions, so converter
> needs to emit extra jump insns)
> Also they don't produce unreachable code.
> So getting over 4k limit and unreachable are rather hypothetical
> problems. I wouldn't want to have two interfaces to criu seccomp.
> eBPF is going to be used by seccomp as well, so having two is extra
> burden for user space criu.

I think the burden is not so huge once we have eBPF c/r in place (we
could just check the classic flag first, then dump the eBPF version or
something). However, it doesn't seem ideal to have to support two
interfaces.

> If we start hitting 4k limit for eBPF, we can easily bump it
> and/or add < and <= insns to eBPF (which was on my todo list anyway).

I was hoping you might say this (assuming you mean add < BPF_MAXINSNS
to the converter).

The dead code is certainly a problem, but perhaps we can wait on this
until there become some critical application that has this issue. I
was hoping we could get away without extra memory usage on the kernel
side (indeed, this patchset is mostly to try and avoid that).

Tycho
