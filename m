From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [RFC PATCH net-next] ebpf: Allow dereferences of PTR_TO_STACK registers
Date: Wed, 22 Jul 2015 00:18:06 -0700
Message-ID: <CALCkm3dPFuOTDW835+5hmtDUg-zfKRJmHVusp04nRpWoosUEpA@mail.gmail.com>
References: <1437530440-1474680-1-git-send-email-agartrell@fb.com> <20150722030047.GA14620@ast-dev1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Gartrell <agartrell@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33416 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083AbbGVHS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 03:18:27 -0400
Received: by qged69 with SMTP id d69so69688689qge.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 00:18:26 -0700 (PDT)
In-Reply-To: <20150722030047.GA14620@ast-dev1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2015 at 8:00 PM, Alexei Starovoitov <ast@kernel.org> wrote:
> On Tue, Jul 21, 2015 at 07:00:40PM -0700, Alex Gartrell wrote:
>>         mov %rsp, %r1           ; r1 = rsp
>>         add $-8, %r1            ; r1 = rsp - 8
>>         store_q $123, -8(%rsp)  ; *(u64*)r1 = 123  <- valid
>>         store_q $123, (%r1)     ; *(u64*)r1 = 123  <- previously invalid
>>         mov $0, %r0
>>         exit                    ; Always need to exit
>
> Is this your new eBPF assembler syntax? :)
> imo gnu style looks ugly... ;)

If you think this is ugly, you'll love the "instruction" I added to be
compatible with the map fd -> immediate conversion hack :)

> It's great to see such in-depth understanding of verifier!!
>
>> And we'd get the following error:
>>
>>       0: (bf) r1 = r10
>>       1: (07) r1 += -8
>>       2: (7a) *(u64 *)(r10 -8) = 999
>>       3: (7a) *(u64 *)(r1 +0) = 999
>>       R1 invalid mem access 'fp'
>>
>>       Unable to load program
>>
>> We already know that a register is a stack address and the appropriate
>> offset, so we should be able to validate those references as well.
>
> yes, we can teach verifier to do that.
> Though llvm doesn't generate such code. It's small enough change.

I happened upon this as I was playing around with the bytecode in our
4.0 kernels.  I believe that we can write general purpose utilities
without needing to write C code for each use case that do things like
filtering/counting packets or syscalls and outputting that data into
maps at low cost, but I'm still just prototyping so I'm not ready to
be an assertive jerk about it (yet)

> real_off is missing alignment and bounds checks.
> something like:
> if (state->regs[regno].type == PTR_TO_STACK)
>         off += state->regs[regno].imm;
> if (off % size != 0)
> ...

Yeah, I'm an idiot and assumed that a bounds check happened in the
check_stack_read function.  I'll find a way to do this without
copy-pasta'ing but I'm going to stick to my moral high ground and not
mutate a parameter (this lead to a bug in a job interview 6 years ago
and I've never forgiven myself because the interviewer was an OpenBSD
guy)

> else if (state->regs[regno].type == FRAME_PTR || == PTR_TO_STACK)
> .. as-is here ...
>
> would fix it.
>
> please add few accept and reject tests for this to test_verifier.c as well.

psh, tests...


I'll update this stuff and submit a patch.

-- 
Alex Gartrell <agartrell@fb.com>
