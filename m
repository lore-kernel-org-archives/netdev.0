From: David Miller <davem@davemloft.net>
Subject: Re: llvm-objdump...
Date: Fri, 28 Apr 2017 12:17:10 -0400 (EDT)
Message-ID: <20170428.121710.1780087759147659481.davem@davemloft.net>
References: <20170425.131337.2175176102097155053.davem@davemloft.net>
        <612f0df6-711c-b6b1-4bd7-596a7f329737@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56028 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756176AbdD1QRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 12:17:11 -0400
In-Reply-To: <612f0df6-711c-b6b1-4bd7-596a7f329737@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 25 Apr 2017 20:48:52 -0700

> On 4/25/17 10:13 AM, David Miller wrote:
>>
>> I think there are some endianness issues ;-)
>>
>> davem@patience:~/src/GIT/net-next/tools/testing/selftests/bpf$
>> llvm-objdump -S x.o
> 
> nice host name ;)
> 
>> x.o:    file format ELF64-BPF
>>
>> Disassembly of section test1:
>> process:
>>        0:       b7 00 00 00 00 00 00 02         r0 = 33554432
>>        1:       61 21 00 50 00 00 00 00         r1 = *(u32 *)(r2 + 20480)
>>
>> That first instruction should be "r0 = 2"
> 
> hmm. I haven't tested it on big endian.
> When last time s390 folks tested samples/bpf with llvm we didn't even
> have automatic -march=bpf in llvm, so they used -march=bpfeb.
> There was no llvm-objdump support either.
> 
> llvm side does this:
> tatic Triple::ArchType parseBPFArch(StringRef ArchName) {
>   if (ArchName.equals("bpf")) {
>     if (sys::IsLittleEndianHost)
>       return Triple::bpfel;
>     else
>       return Triple::bpfeb;
>   } else if (ArchName.equals("bpf_be") || ArchName.equals("bpfeb")) {
>     return Triple::bpfeb;
>   } else if (ArchName.equals("bpf_le") || ArchName.equals("bpfel")) {
>     return Triple::bpfel;
> 
> It works for clang and for llvm.
> I thought llvm-objdump should infer triple from elf file
> and do the 'right thing'... hmm
> 
> could you please test it with -g and see whether dwarf is still
> correct in .o ?
> llvm-objdump -S should print original C code next to asm.
> Hope bpf dwarf is not broken on big-endian...

Even if I give it -triple=bpfeb it emits immediates incorrectly.

The bug is certainly in the insn field fetcher of the disassembler.
