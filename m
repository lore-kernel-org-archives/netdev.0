From: Alexei Starovoitov <ast@fb.com>
Subject: Re: llvm-objdump...
Date: Tue, 25 Apr 2017 20:48:52 -0700
Message-ID: <612f0df6-711c-b6b1-4bd7-596a7f329737@fb.com>
References: <20170425.131337.2175176102097155053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55815 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1434805AbdDZDtM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 23:49:12 -0400
In-Reply-To: <20170425.131337.2175176102097155053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/17 10:13 AM, David Miller wrote:
>
> I think there are some endianness issues ;-)
>
> davem@patience:~/src/GIT/net-next/tools/testing/selftests/bpf$ llvm-objdump -S x.o

nice host name ;)

> x.o:    file format ELF64-BPF
>
> Disassembly of section test1:
> process:
>        0:       b7 00 00 00 00 00 00 02         r0 = 33554432
>        1:       61 21 00 50 00 00 00 00         r1 = *(u32 *)(r2 + 20480)
>
> That first instruction should be "r0 = 2"

hmm. I haven't tested it on big endian.
When last time s390 folks tested samples/bpf with llvm we didn't even
have automatic -march=bpf in llvm, so they used -march=bpfeb.
There was no llvm-objdump support either.

llvm side does this:
tatic Triple::ArchType parseBPFArch(StringRef ArchName) {
   if (ArchName.equals("bpf")) {
     if (sys::IsLittleEndianHost)
       return Triple::bpfel;
     else
       return Triple::bpfeb;
   } else if (ArchName.equals("bpf_be") || ArchName.equals("bpfeb")) {
     return Triple::bpfeb;
   } else if (ArchName.equals("bpf_le") || ArchName.equals("bpfel")) {
     return Triple::bpfel;

It works for clang and for llvm.
I thought llvm-objdump should infer triple from elf file
and do the 'right thing'... hmm

could you please test it with -g and see whether dwarf is still
correct in .o ?
llvm-objdump -S should print original C code next to asm.
Hope bpf dwarf is not broken on big-endian...
