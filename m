From: Alexei Starovoitov <ast@fb.com>
Subject: Re: assembler mnenomics for call/tailcall plus maps...
Date: Thu, 27 Apr 2017 19:06:14 -0700
Message-ID: <398986a4-ef4b-6631-c6eb-96505e0a5849@fb.com>
References: <20170427.164245.1980485298195850482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xdp-newbies@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45672 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S965201AbdD1CGi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 22:06:38 -0400
In-Reply-To: <20170427.164245.1980485298195850482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/17 1:42 PM, David Miller wrote:
>
> Can you guys give me some kind of idea of how it might be nice to
> represent calls and tailcalls in assembler files?

llvm prints them as 'call 1' for bpf_map_lookup
and 'call 12' for bpf_tail_call.
In the instruction stream bpf_tail_call is no different
than regular call. Only after verifier it becomes special instruction.
This 'call 1234' is obviously not readable.
We probably should allow both 'call 123' to make sure that
we don't need to change assembler/compiler with every new
helper added and allow more sane
'call bpf_map_lookup_elem'
for helpers with known func_id.

> And also the emission of maps.
>
> Right now I just have the assembler looking for 32-bit immediate
> values for call and tailcall instructions.
>
> Looking at samples/bpf/sockex3_kern.c we have:
>
> struct bpf_map_def SEC("maps") jmp_table = {
> 	.type = BPF_MAP_TYPE_PROG_ARRAY,
> 	.key_size = sizeof(u32),
> 	.value_size = sizeof(u32),
> 	.max_entries = 8,
> };

yeah. this one is tricky.
Currently there is a protocol between C file section name
and user space bpf_loader.
The above 'struct bpf_map_def' is recognized by
samples/bpf/bpf_load.c
and by tools/lib/bpf/libbpf.c which is used by perf.
iproute2 allows extended format with two extra fields
for pinning.

So if we write the same stuff in assembler, the existing
loaders will understand it.
The tricky part is in relocations.
To do bpf_map_lookup_elem() the R1 needs to point to map,
so in assembler we need to be able to say something like:

ldimm64 r1, jmp_table

where jmp_table will be in data section named 'maps'.

So in asm the map lookup will look like:
	.section        maps,"aw",@progbits
         .globl  hashmap_def
hashmap_def:
         .long   1  # type
         .long   24 # key_size
         .long   40 # value_size
         .long   256 # max_entries

         .text
         .section        xdp_tx_iptunnel,"ax",@progbits
         .globl  _xdp_prog
_xdp_prog:
          ldimm64 r1, hashmap_def
          mov r2, r10
          add r2, -8
          call bpf_map_lookup_elem

this is 64-bit relo for ldimm64 insn

This is how it's defined in llvm:
ELF_RELOC(R_BPF_NONE,        0)
ELF_RELOC(R_BPF_64_64,       1)
ELF_RELOC(R_BPF_64_32,      10)

The R_BPF_64_64 is the only relocation against .text
The other one is used for relo into dwarf sections.
