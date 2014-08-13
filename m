From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v4 net-next 00/26] BPF syscall, maps, verifier,
 samples, llvm
Date: Wed, 13 Aug 2014 10:30:54 -0700
Message-ID: <CAMEtUuyULyzVb1nkJn_Tj_aKjokcBQaw_EnWBdDvtvf9iV7uXA@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<063D6719AE5E284EB5DD2968C1650D6D174760F3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174760F3@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 1:52 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Of Alexei Starovoitov
>> one more RFC...
>>
>> Major difference vs previous set is a new 'load 64-bit immediate' eBPF insn.
>> Which is first 16-byte instruction. It shows how eBPF ISA can be extended
>> while maintaining backward compatibility, but mainly it cleans up eBPF
>> program access to maps and improves run-time performance.
>
> Wouldn't it be more sensible to follow the scheme used by a lot of cpus
> and add a 'load high' instruction (follow with 'add' or 'or').

that was what I used before in pred_tree_walker->ebpf patch
(4 existing instructions (2 movs, shift, or) to load 'pred' pointer)
It's slower in interpreter than single instruction.

> It still takes 16 bytes to load a 64bit immediate value, but the instruction
> size remains constant.

size of instruction is not important. 99% of instructions are 8 byte long
and one is 16 byte. Big deal. It doesn't affect interpreter performance,
easy for verifier and was straightforward to do in LLVM as well.

> There is nothing to stop any JIT software detecting the instruction pair.

well, it's actually very complicated to detect a sequence of
instructions that compute single 64-bit value.
Patch #11 detects and patches pseudo BPF_LD_IMM64 in
a single 'for' loop (see replace_map_fd_with_map_ptr), because
it's _single_ instruction. Any sequence of insns would require
building control and data flow graphs for verifier and JIT.
If you remember I resisted initially when Chema proposed
'load 64-bit immediate' equivalent, since back then the use cases
didn't require it. With maps done via FDs, the need has arisen.
