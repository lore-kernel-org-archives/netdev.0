From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v4 binutils] Add BPF support to binutils...
Date: Mon, 1 May 2017 20:49:21 -0700
Message-ID: <33505cff-f730-ebac-c2d7-38f1793062b7@fb.com>
References: <20170430.120750.651845251226226775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <xdp-newbies@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49368 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750847AbdEBDtr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:49:47 -0400
In-Reply-To: <20170430.120750.651845251226226775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/30/17 9:07 AM, David Miller wrote:
> This is mainly a synchronization point, I still need to look
> more deeply into Alexei's -g issue.
>
> New in this version from v3:
>  - Remove tailcall from opcode table
>  - Rearrange relocations so that numbers match with LLVM ones
>  - Emit relocs properly so that dwarf2 debug info tests pass
>  - Handle negative load/store offsets properly, add tests
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

dwarf on little endian works now :)

$ /w/binutils-gdb/bld/binutils/objdump -S test.o

test.o:     file format elf64-bpfle

Disassembly of section .text:

0000000000000000 <bpf_prog1>:
int bpf_prog1(void *ign)
{
   volatile unsigned long t = 0x8983984739ull;
    0:	18 01 00 00 39 47 98 83 	ldimm64	r0, 590618314553
    8:	00 00 00 00 89 00 00 00
   10:	7b 1a f8 ff 00 00 00 00 	stdw	[r1+-8], r10
   return *(unsigned long *)((0xffffffff8fff0002ull) + t);
   18:	79 a1 f8 ff 00 00 00 00 	lddw	r10, [r1+-8]

This is great milestone.

Also I finally figured out how to enable native+bpf:
../configure --enable-targets=bpf-elf,x86_64-elf

having support for both in one binary is a big deal :)

Only 'gdb' warns with dual arch support:
"
warning: A handler for the OS ABI "GNU/Linux" is not built into this 
configuration
of GDB.  Attempting to continue with the default bpf settings.
"

(gdb) x/10i bpf_prog1
    0x0 <bpf_prog1>:	ldimm64	r0, 590618314553
    0x10 <bpf_prog1+16>:	stdw	[r1+-8], r10
    0x18 <bpf_prog1+24>:	lddw	r10, [r1+-8]
    0x20 <bpf_prog1+32>:	add	r0, -1879113726
    0x28 <bpf_prog1+40>:	lddw	r1, [r0+0]
    0x30 <bpf_prog1+48>:	exit
    0x38:	Cannot access memory at address 0x38

the last line also seems wrong. Off by 1 error?
