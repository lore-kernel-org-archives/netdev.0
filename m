From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 net-next 1/6] net: filter: add "load 64-bit immediate"
 eBPF instruction
Date: Mon, 25 Aug 2014 18:53:18 -0700
Message-ID: <CAMEtUuwz9MEei+tjWx4Fv8cK_zc9TKVbWxQEAE+yWvxRMa793g@mail.gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
	<1409014858-1410-2-git-send-email-ast@plumgrid.com>
	<20140825.180621.1003932711320755950.davem@davemloft.net>
	<CAMEtUuxdQpkX8t1_szde=Q1ALcp5t7rRyK+zEDafj27_J2LzVg@mail.gmail.com>
	<CALCETrVgSXuRG_ZPXQt55ze7pHOCezU4Ev1KFUww6Yqk4JACgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33454 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343AbaHZBxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 21:53:19 -0400
Received: by mail-wg0-f47.google.com with SMTP id b13so13610528wgh.6
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 18:53:18 -0700 (PDT)
In-Reply-To: <CALCETrVgSXuRG_ZPXQt55ze7pHOCezU4Ev1KFUww6Yqk4JACgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 6:38 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Aug 25, 2014 at 6:35 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Mon, Aug 25, 2014 at 6:06 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Alexei Starovoitov <ast@plumgrid.com>
>>> Date: Mon, 25 Aug 2014 18:00:53 -0700
>>>
>>>> add BPF_LD_IMM64 instruction to load 64-bit immediate value into a register.
>>>
>>> I think you need to rethink this.
>>>
>>> I understand that you want to be able to compile arbitrary C code into
>>> eBPF, but you have to restrict strongly what data the eBPF code can get
>>> to.
>>
>> I believe verifier already does restrict it. I don't see any holes in
>> the architecture. I'm probably not explaining it clearly though :(
>>
>>> Arbitrary pointer loads is asking for trouble.
>>
>> Of course.
>> There is no arbitrary pointer from user space.
>> Verifier checks all pointers.
>> I guess this commit log description is confusing.
>> It says:
>> BPF_LD_IMM64(R1, const_imm_map_ptr)
>> that's what appears in the program _after_ it goes through verifier.
>> User space cannot pass a pointer into the kernel.
>
> If you don't intend for userspace to load a program that contains this
> instruction, then why does it need to be an instruction that the
> verifier rewrites?  Why not have an instruction "load immediate

user space use _pseudo_ bpf_ld_imm64 instruction.
_pseudo_ stands for using 'map_fd' as imm instead of pointer.

> relocated pointer" that contains a reference to a relocation table and

Andy, I guess you missed explanation in:
https://lkml.org/lkml/2014/8/13/111
"
Obviously user space doesn't know what kernel map pointer is associated
with process-local map-FD.
So it's using pseudo BPF_LD_IMM64 instruction.
BPF_LD_IMM64 with src_reg == 0 -> generic move 64-bit immediate into dst_reg
BPF_LD_IMM64 with src_reg == BPF_PSEUDO_MAP_FD -> mov map_fd into dst_reg
Other values are reserved for now. (They will be used to implement
global variables, strings and other constants and per-cpu areas in the future)
So the programs look like:
  BPF_LD_MAP_FD(BPF_REG_1, process_local_map_fd),
  BPF_CALL(BPF_FUNC_map_lookup_elem),
eBPF verifier scans the program for such pseudo instructions, converts
process_local_map_fd -> in-kernel map pointer
and drops 'pseudo' flag of BPF_LD_IMM64 instruction.
"

To rephrase it differently.
  BPF_LD_MAP_FD(BPF_REG_1, process_local_map_fd),
is very much what you suggesting by "load immediate relocated pointer"
Right?

> have the JIT do it?  That might be easier to understand than having
> the verifier do it, and it'll avoid committing to ABIs before we need
> them.

that part I don't understand.
The patch that handles pseudo_with_map_fd ->
-> normal_with_kernel_pointer conversion is only 147 lines:
https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/commit/?id=d82d3daa20465dfdc6b2a0094ad27de9edbb328b
Cannot think of shorter version.
