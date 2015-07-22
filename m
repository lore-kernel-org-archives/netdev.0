From: Alexei Starovoitov <ast@kernel.org>
Subject: Re: [RFC PATCH net-next] ebpf: Allow dereferences of PTR_TO_STACK
 registers
Date: Tue, 21 Jul 2015 20:00:48 -0700
Message-ID: <20150722030047.GA14620@ast-dev1>
References: <1437530440-1474680-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37244 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754500AbbGVDAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2015 23:00:52 -0400
Content-Disposition: inline
In-Reply-To: <1437530440-1474680-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2015 at 07:00:40PM -0700, Alex Gartrell wrote:
>         mov %rsp, %r1           ; r1 = rsp
>         add $-8, %r1            ; r1 = rsp - 8
>         store_q $123, -8(%rsp)  ; *(u64*)r1 = 123  <- valid
>         store_q $123, (%r1)     ; *(u64*)r1 = 123  <- previously invalid
>         mov $0, %r0
>         exit                    ; Always need to exit

Is this your new eBPF assembler syntax? :)
imo gnu style looks ugly... ;)

It's great to see such in-depth understanding of verifier!!

> And we'd get the following error:
> 
> 	0: (bf) r1 = r10
> 	1: (07) r1 += -8
> 	2: (7a) *(u64 *)(r10 -8) = 999
> 	3: (7a) *(u64 *)(r1 +0) = 999
> 	R1 invalid mem access 'fp'
> 
> 	Unable to load program
> 
> We already know that a register is a stack address and the appropriate
> offset, so we should be able to validate those references as well.

yes, we can teach verifier to do that.
Though llvm doesn't generate such code. It's small enough change.

> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> ---
>  kernel/bpf/verifier.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 039d866..5dfbece 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -676,6 +676,15 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
>  			err = check_stack_write(state, off, size, value_regno);
>  		else
>  			err = check_stack_read(state, off, size, value_regno);
> +	} else if (state->regs[regno].type == PTR_TO_STACK) {
> +		int real_off = state->regs[regno].imm + off;

real_off is missing alignment and bounds checks.
something like:
if (state->regs[regno].type == PTR_TO_STACK)
	off += state->regs[regno].imm;
if (off % size != 0)
...
else if (state->regs[regno].type == FRAME_PTR || == PTR_TO_STACK)
.. as-is here ...

would fix it.

please add few accept and reject tests for this to test_verifier.c as well.
