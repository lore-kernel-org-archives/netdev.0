From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Wed, 13 Aug 2014 14:17:24 -0700
Message-ID: <CALCETrVDrbD3goYmZsUdmEhVfaNxovyghCz6y+_q5+G+rVwtWg@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
 <1407916658-8731-2-git-send-email-ast@plumgrid.com> <CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg@mail.gmail.com>
 <CAMEtUuxog0w-XkYMHM=Zto_gejy8x5agxohAWOs1zPEtXTr0Sw@mail.gmail.com>
 <CALCETrXfp+7FmEzAoLiqzqY73NBzt8JsD40hzvhT3=gr-Scp=g@mail.gmail.com> <CAMEtUuwx6Y4qxyz4TGK9=M2BH-dXnPsm+JrusqbyjzK20yUv6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuwx6Y4qxyz4TGK9=M2BH-dXnPsm+JrusqbyjzK20yUv6A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 2:02 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Wed, Aug 13, 2014 at 11:35 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>>
>> The compiler can still think of it as a single insn, though, but some
>> future compiler might not.
>
> I think that would be very dangerous.
> compiler (user space) and kernel interpreter must have the same
> understanding of ISA.
>
>> In any case, I think that, if you use the
>> same code for high and for low, you need logic in the JIT that's at
>> least as complicated.
>
> why do you think so? Handling of pseudo BPF_LD_IMM64 is done
> in single patch #11 which is one of the smallest...
>
>> For example, what happens if you have two
>> consecutive 64-bit immediate loads to the same register?  Now you have
>> four consecutive 8-byte insn words that differ only in their immediate
>> values, and you need to split them correctly.
>
> I don't need to do anything special in this case.
> Two 16-byte instructions back to back is not a problem.
> Interpreter or JIT don't care whether they move the same or different
> immediates into the same or different register. Interpreter and JITs
> are dumb on purpose.
> when verifier sees two back to back ld_imm64, the 2nd will simply
> override the value loaded by first one. It's not any different than
> two back to back 'mov dst_reg, imm32' instructions.

But this patch makes the JIT code (and any interpreter) weirdly
stateful.  You have:

+               case BPF_LD | BPF_IMM | BPF_DW:
+                       /* movabsq %rax, imm64 */
+                       EMIT2(add_1mod(0x48, dst_reg), add_1reg(0xB8, dst_reg));
+                       EMIT(insn->imm, 4);
+                       insn++;
+                       i++;
+                       EMIT(insn->imm, 4);
+                       break;

If you have more than two BPF_LD | BPF_IMM | BPF_DW instructions in a
row, then the way in which they pair up depends on where you start.

I think it would be a lot clearer if you made these be "load low" and
"load high", with JIT code like:

+               case BPF_LOAD_LOW:
+                       /* movabsq %rax, imm64 */
+                       if (next insn is BPF_LOAD_HIGH) {
+                           EMIT2(add_1mod(0x48, dst_reg),
add_1reg(0xB8, dst_reg));
+                           EMIT(insn->imm, 4);
+                           insn++;
+                           i++;
+                           EMIT(insn->imm, 4);
+                       } else {
+                           emit a real load low;
+                       }
+                       break;

(and you'd have to deal with whether load low by itself is illegal,
zero extends, sign extends, or preserves high bits).

Alternatively, and possibly better, you could have a real encoding for
multiword instructions.  Reserve a bit in the opcode to mark a
continuation of the previous instruction, and do:

+               case BPF_LD | BPF_IMM | BPF_DW:
+                       assert(insn[1] in bounds && insn[1].code == BPF_CONT);
+                       /* movabsq %rax, imm64 */
+                       EMIT2(add_1mod(0x48, dst_reg), add_1reg(0xB8, dst_reg));
+                       EMIT(insn->imm, 4);
+                       insn++;
+                       i++;
+                       EMIT(insn->imm, 4);
+                       break;

This has a nice benefit for future-proofing: it gives you 119 bits of
payload for 16-byte instructions.

On the other hand, a u8 for the opcode is kind of small, and killing
half of that space like this is probably bad.  Maybe reserve two high
bits, with:

0: normal opcode or start of a multiword sequence
1: continuation of a multiword sequence
2, 3: reserved for future longer opcode numbers (e.g. 2 could indicate
that "code" is actually 16 bits)

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
