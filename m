From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Wed, 13 Aug 2014 14:37:13 -0700
Message-ID: <CAMEtUuyFF3Qvd8BHkbEqkjGx+UEC8KcowUYyyuBW2J_NcGA96Q@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-2-git-send-email-ast@plumgrid.com>
	<CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg@mail.gmail.com>
	<CAMEtUuxog0w-XkYMHM=Zto_gejy8x5agxohAWOs1zPEtXTr0Sw@mail.gmail.com>
	<CALCETrXfp+7FmEzAoLiqzqY73NBzt8JsD40hzvhT3=gr-Scp=g@mail.gmail.com>
	<CAMEtUuwx6Y4qxyz4TGK9=M2BH-dXnPsm+JrusqbyjzK20yUv6A@mail.gmail.com>
	<CALCETrVDrbD3goYmZsUdmEhVfaNxovyghCz6y+_q5+G+rVwtWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrVDrbD3goYmZsUdmEhVfaNxovyghCz6y+_q5+G+rVwtWg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 2:17 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Wed, Aug 13, 2014 at 2:02 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> On Wed, Aug 13, 2014 at 11:35 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>
>>> The compiler can still think of it as a single insn, though, but some
>>> future compiler might not.
>>
>> I think that would be very dangerous.
>> compiler (user space) and kernel interpreter must have the same
>> understanding of ISA.
>>
>>> In any case, I think that, if you use the
>>> same code for high and for low, you need logic in the JIT that's at
>>> least as complicated.
>>
>> why do you think so? Handling of pseudo BPF_LD_IMM64 is done
>> in single patch #11 which is one of the smallest...
>>
>>> For example, what happens if you have two
>>> consecutive 64-bit immediate loads to the same register?  Now you have
>>> four consecutive 8-byte insn words that differ only in their immediate
>>> values, and you need to split them correctly.
>>
>> I don't need to do anything special in this case.
>> Two 16-byte instructions back to back is not a problem.
>> Interpreter or JIT don't care whether they move the same or different
>> immediates into the same or different register. Interpreter and JITs
>> are dumb on purpose.
>> when verifier sees two back to back ld_imm64, the 2nd will simply
>> override the value loaded by first one. It's not any different than
>> two back to back 'mov dst_reg, imm32' instructions.
>
> But this patch makes the JIT code (and any interpreter) weirdly
> stateful.  You have:
>
> +               case BPF_LD | BPF_IMM | BPF_DW:
> +                       /* movabsq %rax, imm64 */
> +                       EMIT2(add_1mod(0x48, dst_reg), add_1reg(0xB8, dst_reg));
> +                       EMIT(insn->imm, 4);
> +                       insn++;
> +                       i++;
> +                       EMIT(insn->imm, 4);
> +                       break;
>
> If you have more than two BPF_LD | BPF_IMM | BPF_DW instructions in a
> row, then the way in which they pair up depends on where you start.

For JIT it's not a problem, since it's doing a linear scan. So it always
starts at instruction boundary.
But thinking about it further you're right that it's a bug in verifier.
I've tried it and indeed depending on type of branch verifier doesn't
catch a case of two 16-byte instructions back to back and jump
goes into 2nd half of 1st insn. I need to fix that.

> I think it would be a lot clearer if you made these be "load low" and
> "load high", with JIT code like:
>
> +               case BPF_LOAD_LOW:
> +                       /* movabsq %rax, imm64 */
> +                       if (next insn is BPF_LOAD_HIGH) {

such 'if' will be costly in interpreter. I want to avoid it.

> (and you'd have to deal with whether load low by itself is illegal,
> zero extends, sign extends, or preserves high bits).

I don't need an instruction that loads low 32-bit. It already exists.
It's called 'mov'.
I'm going to try encoding:
insn[0].code = LD | IMM | DW
insn[1].code = 0
zero is invalid opcode, so it's your 'continuation'.
and it is still single 16-byte instructions without any interpreter overhead.

> This has a nice benefit for future-proofing: it gives you 119 bits of
> payload for 16-byte instructions.

It's already future proofed. We can add 24 byte instructions and so on
just as well. There is no point to reserve 119 bits when no one is using
them.

> On the other hand, a u8 for the opcode is kind of small, and killing
> half of that space like this is probably bad.  Maybe reserve two high
> bits, with:

That's an overkill. We use ~80 opcodes out of 256.
There is plenty of room. I see no reason to switch to 16-bit opcodes
until we get even close to half of u8 space.
It feels that we're starting to bikeshed.
