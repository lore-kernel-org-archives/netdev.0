From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sat, 29 Apr 2017 23:44:59 -0700
Message-ID: <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
References: <20170428.163355.2067951664875385680.davem@davemloft.net>
 <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
 <20170429.222450.1300920007783667009.davem@davemloft.net>
 <20170429.223759.1262491011130998405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <aconole@bytheb.org>,
        <netdev@vger.kernel.org>, <xdp-newbies@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46185 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S2999052AbdD3Gpl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 02:45:41 -0400
In-Reply-To: <20170429.223759.1262491011130998405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/17 7:37 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 29 Apr 2017 22:24:50 -0400 (EDT)
>
>> Some of your bugs should be fixed by this patch below, I'll add
>> test cases soon:
>
> Ok, here are all the local changes in my tree.  I made the relocs
> match LLVM and I fixed some dwarf debugging stuff.
>
> With this we are also down to one test case failure under binutils/
> and it's something weird with merging 64-bit notes which I should be
> able to fix soon.
>
> I can fix these bugs fast, keep reporting.
>
> BTW, should I just remove tailcall from the opcode table altogether?

yeah. tailcall is not a special opcode from user space point of view.
Only after normal call with func_id=bpf_tail_call passes verifier
then verifier will change insn->code into CALL|X
It's done only to have two 'case' statement in the interpreter,
so that normal calls and tailcalls don't interfere.
 From user space pov CALL|X opcode is reserved and we can use it
for something in the future. Just need to change interpeter and JITs.

>  	    case 'O':
> -	      (*info->fprintf_func) (stream, "%d", off);
> +	      (*info->fprintf_func) (stream, "%d", (int) off);

tried this diff. It looks better
   10:	7b 1a f8 ff 00 00 00 00 	stdw	[r1+-8], r10
   18:	79 a1 f8 ff 00 00 00 00 	lddw	r10, [r1+-8]
I wonder if '+' can be removed as well.

'-g' still doesn't seem to work:
/w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
/w/binutils-gdb/bld/binutils/objdump: BFD (GNU Binutils) 
2.28.51.20170429 assertion fail ../../bfd/elf64-bpf.c:139
    0:	18 01 00 00 39 47 98 83 	ldimm64	r0, 590618314553
