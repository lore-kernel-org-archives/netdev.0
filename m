From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH] arm64: net: bpf: don't BUG() on large shifts
Date: Tue, 12 Jan 2016 20:45:43 -0800
Message-ID: <CABg9mcsnNeXPk1ifFMsV7oy8E1ZjprXu1_7KwoMp=RQ29UEFFQ@mail.gmail.com>
References: <1452015543-6790-1-git-send-email-rabin@rab.in>
	<20160108154423.GC11228@arm.com>
	<20160108190943.GA11561@ast-mbp.thefacebook.com>
	<20160112171710.GK15737@arm.com>
	<20160112192302.GA34276@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rabin Vincent <rabin@rab.in>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Yang Shi <yang.shi@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35490 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbcAMEpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 23:45:43 -0500
Received: by mail-ig0-f171.google.com with SMTP id t15so137272005igr.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 20:45:43 -0800 (PST)
In-Reply-To: <20160112192302.GA34276@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 11:23 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Jan 12, 2016 at 05:17:10PM +0000, Will Deacon wrote:
>> On Fri, Jan 08, 2016 at 11:09:44AM -0800, Alexei Starovoitov wrote:
>> > On Fri, Jan 08, 2016 at 03:44:23PM +0000, Will Deacon wrote:
>> > > On Tue, Jan 05, 2016 at 06:39:03PM +0100, Rabin Vincent wrote:
>> > > > Attempting to generate UBFM/SBFM instructions with shifts that can't be
>> > > > encoded in the immediate fields of the opcodes leads to a trigger of a
>> > > > BUG() in the instruction generation code.  As the ARMv8 ARM says: "The
>> > > > shift amounts must be in the range 0 to one less than the register width
>> > > > of the instruction, inclusive."  Make the JIT reject unencodable shifts
>> > > > instead of crashing.
>> > >
>> > > I moaned about those BUG_ONs when they were introduced:
>> > >
>> > >   https://lkml.org/lkml/2014/7/17/438
>> > >
>> > > The response then was that the verifier would catch these issues so
>> > > there was nothing to worry about. Has something changed so that is no
>> > > longer the case? Do we need to consider a different way of rejecting
>> > > invalid instructions at the encoding stage rather than bringing down the
>> > > kernel?
>> >
>> > that discussion lead to replacement of all BUG_ONs in
>> > arch/arm64/net/bpf_jit_comp.c with pr_err_once(), but looks like
>> > arch/arm64/kernel/insn.c wasn't addressed.
>> > The amount of BUG_ONs there is indeed overkill regardless of what
>> > verifier and other JITs do. btw, x64 JIT doesn't have runtime BUG_ONs.
>>
>> Maybe, but insn.c is also used by the alternatives patching code, so we
>> really need a way to communicate failure back to the BPF JIT when passed
>> an invalid instruction description.
>
> agree. I think there are several options to achieve that after
> all BUG_ONs are removed:
> - change interface for all insn generating macros to check for
>   AARCH64_BREAK_FAULT opcode as error.
>   That will require all of emit*() functions in bpf_jit_comp.c to
>   be changed to accept/return error.
>   Overall that looks like massive change.
> - ignore AARCH64_BREAK_FAULT during emit and add another pass after
>   all code is generated. If such insn is found in a jited code,
>   discard the jit.
>   I think that's better option.
>
> Zi, any comments?
>

Alexei, agreed. Second approach is cleaner. Full disclosure: I did not
look at other callers beyond JIT.

Separately, sounds like there's now preference and consensus to
removing all BUGs and BUG_ONs in insn.c. Did a quick grep of insn.c
and noticed a legacy instance, followed by many introduced around the
same time as JIT, and new additions since.

Will, any thoughts on the following replacement scheme?

BUG_ON() for codegen ==> pr_err(); return AARCH64_BREAK_FAULT;
BUG() for decoding ==> leave as is.
remaining BUG_ON() ==> leave as is.
