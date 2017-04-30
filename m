From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sat, 29 Apr 2017 19:24:07 -0700
Message-ID: <eecee68f-c273-804a-ce85-bad19f51fd66@fb.com>
References: <20170428.163355.2067951664875385680.davem@davemloft.net>
 <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
 <20170429.221315.1605574480939856975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <aconole@bytheb.org>,
        <netdev@vger.kernel.org>, <xdp-newbies@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33470 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1162894AbdD3CYt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 22:24:49 -0400
In-Reply-To: <20170429.221315.1605574480939856975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/17 7:13 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Sat, 29 Apr 2017 17:48:43 -0700
>
>> /w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
>> /w/binutils-gdb/bld/binutils/objdump: Dwarf Error: found address size
>
> I discussed this in another email, the relocation numbers I used in
> binutils do not match what is in LLVM currently.
>
> In fact, I thought you guys weren't using relocations in any capacity
> at all so just picked things from scratch :-)

yeah :) will reply in the other thread.
Too many public and internal discussions in the last week.
Weekend is the only time to reduce the backlog :)

 > Please use "--target=bpf-elf"

Thanks. That worked. Built the whole thing :)

objdump behaves the same way.
When compiled by clang with '-g'
(gdb) x/10i bpf_prog1
    0x0 <clang version 5.0.0 (trunk 301652) (llvm/trunk 301662)>: 
ldimm64	r0, 590618314553
    0x10 <clang version 5.0.0 (trunk 301652) (llvm/trunk 301662)+16>: 
stdw	[r1+65528], r10
    0x18 <clang version 5.0.0 (trunk 301652) (llvm/trunk 301662)+24>: 
lddw	r10, [r1+65528]
    0x20 <clang version 5.0.0 (trunk 301652) (llvm/trunk 301662)+32>: 
add	r0, -1879113726
    0x28 <clang version 5.0.0 (trunk 301652) (llvm/trunk 301662)+40>: 
lddw	r1, [r0+0]
    0x30 <clang version 5.0.0 (trunk 301652) (llvm/trunk 301662)+48>:	exit
    0x38:	Cannot access memory at address 0x38

Even without -g the last line 'Cannot access' is printed.
It seems gdb miscalculates the total func size?
The printing of 'clang version...' is due to '-g'.
Without -g it looks good:
(gdb) x/10i bpf_prog1
    0x0 <bpf_prog1>:	ldimm64	r1, 590618314553
    0x10 <bpf_prog1+16>:	stdw	[r10+65528], r1

Btw, I'm using this C file for testing:
int bpf_prog1(void *ign)
{
   volatile unsigned long t = 0x8983984739ull;
   return *(unsigned long *)((0xffffffff8fff0002ull) + t);
}

There was a bug in llvm backend with imm overflow which
was recently fixed.
