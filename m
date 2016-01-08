From: Rabin Vincent <rabin@rab.in>
Subject: Re: [PATCH] arm64: net: bpf: don't BUG() on large shifts
Date: Fri, 8 Jan 2016 16:58:37 +0100
Message-ID: <20160108155837.GA28291@debian>
References: <1452015543-6790-1-git-send-email-rabin@rab.in>
 <20160105175557.GC83548@ast-mbp.thefacebook.com>
 <20160106203127.GA16059@debian>
 <20160106221247.GA95332@ast-mbp.thefacebook.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCBF08E@AcuExch.aculab.com>
 <568E5EB0.8020102@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zlim.lnx@gmail.com" <zlim.lnx@gmail.com>,
	"yang.shi@linaro.org" <yang.shi@linaro.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"catalin.marinas@arm.com" <catalin.marinas@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36608 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755602AbcAHP66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 10:58:58 -0500
Received: by mail-wm0-f54.google.com with SMTP id l65so139980658wmf.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 07:58:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <568E5EB0.8020102@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 01:48:48PM +0100, Daniel Borkmann wrote:
> The question is what is less risky in terms of uabi. To reject such
> filters with such K shift vals upfront in verifier, or to just allow
> [0, reg_size - 1] values and handle outliers silently. I think both
> might be possible, the latter just needs to be clearly specified in
> the documentation somewhere. If we go for the latter, then probably
> just rewriting that K value as masked one might seem better. Broken
> programs might then still be loadable (and still be broken) ... afaik
> in case of register (case of shifts with X) with large shift vals
> ARM64 is doing 'modulo reg_size' implicitly.

The case of what happens with such shifts with X is also already
architecture-specific, even when using the interpreters.  For example, the
following program returns 1 on ARM64 but 0 on ARM.

	BPF_STMT(BPF_LD | BPF_IMM, 1),
	BPF_STMT(BPF_LDX | BPF_IMM, 32),
	BPF_STMT(BPF_ALU | BPF_LSH | BPF_X, 0),
	BPF_STMT(BPF_RET | BPF_A, 0)

To start rejecting large K shifts in the verifier because they are
architecture-specific while continuing to allow the equally
architecture-specific large X shifts (because we can't verify them
statically) would be rather inconsistent.

If it is desired to enforce uniformity across architectures despite the
risk for subtly changing the behaviour of existing programs, then the
desired uniform semantics of these shifts should really be implemented
both for the K and X shifts, which would mean modifiying the interpreter
and the various arch JITs too.
