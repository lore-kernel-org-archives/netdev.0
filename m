From: Alexei Starovoitov <ast@fb.com>
Subject: Re: assembler mnenomics for call/tailcall plus maps...
Date: Sat, 29 Apr 2017 23:35:30 -0700
Message-ID: <c9ff0d0c-b91b-c3dc-654e-8b1c1a4c92f0@fb.com>
References: <20170427.164245.1980485298195850482.davem@davemloft.net>
 <398986a4-ef4b-6631-c6eb-96505e0a5849@fb.com>
 <20170429.143835.270339931242716768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <xdp-newbies@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36411 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S2999016AbdD3GhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 02:37:07 -0400
In-Reply-To: <20170429.143835.270339931242716768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/17 11:38 AM, David Miller wrote:
> or whatever.  And then for assembler syntax, use something like:
>
> 	%map(SYMBOL)
>
> So you would go:
>
> 	ldimm64	r1, %map(hash_map)

sure. that works.
The elf loaders should have checked relo code, of course.
I guess the above ldimm64 should probably be a special one with
insn->src_reg == BPF_PSEUDO_MAP_FD == 1
This is how kernel knows that ldimm64 carries map_fd and not
just arbitrary 64-bit constant.
The idea was to use constants in src_reg field to mark
different address spaces.
In particular tracing needs per-task storage space to
associate multiple events.
Right now the programs do it like:
u32 pid = (u32)bpf_get_current_pid_tgid();
struct scratch_space *value = bpf_map_lookup_elem(&hashmap, &pid);
// access value->var1, value->var2
The C code could have been much simpler if we could use normal global
variables var1 and var2 marked as 'per-task' address space.
I can imagine such per-task variables would be code=2,
per-cpu variables code=3 and so on.
That was never implemented, unfortunately.

Currently llvm doesn't do any special markings.
It generates normal ldimm64 with relocation into 'maps' section
then elf loader recognizes that, it creates a map, stores FD into
insn->imm = map_fd and marks it insn->src_reg = BPF_PSEUDO_MAP_FD
before sending the whole program into the kernel.

> or, taking it one step further, do the following since we know this
> maps to a 32-bit FD:
>
> 	mov32	r1, %map(hash_map)

hence this approach won't work without serious elf loader hacks.
The kernel needs to see ldimm64 because after it validated map_fd,
it will store real 'struct bpf_map *' pointer into this ldimm64
instruction and it will clear 'src_reg' markings.
So from interpreter and from JITs point of view there are no
special ldimm64 instructions. All ldimm64 are moving 64-bit
constant into a register. It's only verifier that knows that
some of these constants are real pointers.

> In GCC it will be simple to get the backend to emit this, various
> options exist.  We can make it a special "__attribute__((map))", or
> use address spaces to annotate the map object.  And then when the
> ldimm64 or whatever instruction is emitted, and it sees the symbol
> referenced has this special type, it will emit "%%map(%s)" instead of
> just "%s" for the symbol name in the asembler output.

I like the %map(symbol) idea.
I think it fits the whole thing quite well.
Not sure though how gcc will know that it needs to emit %map(..)

> But I guess for now what I could do is just make R_BPF_INSN_64 have
> the same number as LLVM's R_BPF_64_64 and it should "just work" using
> tooling.

yeah. I don't even remember why current llvm relo codes are 1 and 10.
Probably had something else in between, but then removed, because
it wasn't used, but the numbers stuck.

> I think we should spend serious time properly designing the
> relocations and thinking ahead about people perhaps wanting to link
> multiple objects together, call functions in other objects, and
> perhaps even doing dynamic relocations.  Nothing fundamentally in
> eBPF prevents this.

Yes! Completely agree.

I think we need to treat kernel<->user encoding of address space
for ldimm64 insn and elf relo codes differently.
Today BPF_PSEUDO_MAP_FD == 1 and relo code for ldimm64 into map
section is also == 1. These two are probably very confusing.
The former is user->kernel protocol and the latter is compiler->loader
convention.

The relo 10 thingy is never seen by elf loader. It's only there
because generated dwarf data need to convey info about the program,
so llvm emits .relo section into dwarf data with code=1 and code=10.
It's only there because this is how dwarf works.
The only relocation that elf loader cares about is code=1
and the only src_reg mark that kernel cares about is BPF_PSEUDO_MAP_FD.

I take all the blame for not documenting this thing properly.
The elf loader in samples/bpf/bpf_load.c should have been temporary.
Its only purpose was to have minimal demo to parse elf and load it.
I didn't expect the .o approach to come that far.
My bet was on iovisor/bcc approach where elf file is never generated.
C->bpf is compiled in memory and loaded into the kernel completely
without elf and without relocations.
