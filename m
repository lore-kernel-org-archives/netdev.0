From: David Miller <davem@davemloft.net>
Subject: Re: assembler mnenomics for call/tailcall plus maps...
Date: Sat, 29 Apr 2017 14:38:35 -0400 (EDT)
Message-ID: <20170429.143835.270339931242716768.davem@davemloft.net>
References: <20170427.164245.1980485298195850482.davem@davemloft.net>
        <398986a4-ef4b-6631-c6eb-96505e0a5849@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S376820AbdD2Sii (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 14:38:38 -0400
In-Reply-To: <398986a4-ef4b-6631-c6eb-96505e0a5849@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 27 Apr 2017 19:06:14 -0700

> So in asm the map lookup will look like:
> 	.section        maps,"aw",@progbits
>         .globl  hashmap_def
> hashmap_def:
>         .long   1  # type
>         .long   24 # key_size
>         .long   40 # value_size
>         .long   256 # max_entries
> 
>         .text
>         .section        xdp_tx_iptunnel,"ax",@progbits
>         .globl  _xdp_prog
> _xdp_prog:
>          ldimm64 r1, hashmap_def
>          mov r2, r10
>          add r2, -8
>          call bpf_map_lookup_elem
> 
> this is 64-bit relo for ldimm64 insn
> 
> This is how it's defined in llvm:
> ELF_RELOC(R_BPF_NONE,        0)
> ELF_RELOC(R_BPF_64_64,       1)
> ELF_RELOC(R_BPF_64_32,      10)
> 
> The R_BPF_64_64 is the only relocation against .text
> The other one is used for relo into dwarf sections.

There is another missing element here, we don't use the relocation to
write the actual address of "&hashmap_def" into the ldimm64
instruction.

Instead, we use the relocation to write the file descriptor number for
that map into the instruction.  The only parts of the relocation that
are used are the offset (to find the BPF instruction) and the symbol
reference (to find out which map we are referencing).

The BPF loader also doesn't even check the relocation number to make
sure it's of the correct type.  It just assumes that any relocation it
sees is exactly this kind used for maps.

My relocations in binutils currently look like this:

START_RELOC_NUMBERS (elf_bpf_reloc_type)
  RELOC_NUMBER (R_BPF_NONE, 0)
  RELOC_NUMBER (R_BPF_INSN_16, 1)
  RELOC_NUMBER (R_BPF_INSN_32, 2)
  RELOC_NUMBER (R_BPF_INSN_64, 3)
  RELOC_NUMBER (R_BPF_WDISP16, 4)
  RELOC_NUMBER (R_BPF_DATA_8,  5)
  RELOC_NUMBER (R_BPF_DATA_16, 6)
  RELOC_NUMBER (R_BPF_DATA_32, 7)
  RELOC_NUMBER (R_BPF_DATA_64, 8)
END_RELOC_NUMBERS (R_BPF_max)

There is of course R_BPF_NONE, and then we have 4 relocations for
instructions.  One for the 16-bit offset field (non-pc-relative), one
for the 32-bit immediate field (again, non-pc-relative), one for
ldimm64's immediate field, and finally R_BPF_WDISP16 for doing a
pc-relative relocation to the offset field of a jump instruction.

Then we have the usual data relocations, for 8, 16, 32, and 64-bit.

I guess LLVM's R_BPF_64_64 is the one used for the ldimm64 reference
to a map, and is equivalent to R_BPF_INSN_64 above.

We just need to sort out how we want this semantically to interconnect
etc.

In binutils we can make the MAP reference special and explicit, so we
would for example add:

	RELOC_NUMBER (R_BPF_MAP, 9)

or whatever.  And then for assembler syntax, use something like:

	%map(SYMBOL)

So you would go:

	ldimm64	r1, %map(hash_map)

or, taking it one step further, do the following since we know this
maps to a 32-bit FD:

	mov32	r1, %map(hash_map)

and this way avoid eating up a 16-byte opcode just for this.

In GCC it will be simple to get the backend to emit this, various
options exist.  We can make it a special "__attribute__((map))", or
use address spaces to annotate the map object.  And then when the
ldimm64 or whatever instruction is emitted, and it sees the symbol
referenced has this special type, it will emit "%%map(%s)" instead of
just "%s" for the symbol name in the asembler output.

That in turn will lead to the correct relocation.

But I guess for now what I could do is just make R_BPF_INSN_64 have
the same number as LLVM's R_BPF_64_64 and it should "just work" using
tooling.

I think we should spend serious time properly designing the
relocations and thinking ahead about people perhaps wanting to link
multiple objects together, call functions in other objects, and
perhaps even doing dynamic relocations.  Nothing fundamentally in
eBPF prevents this.
