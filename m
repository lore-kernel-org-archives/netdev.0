From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sat, 29 Apr 2017 17:48:43 -0700
Message-ID: <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
References: <20170428.163355.2067951664875385680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <aconole@bytheb.org>,
        <netdev@vger.kernel.org>, <xdp-newbies@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41599 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S378364AbdD3AtY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 20:49:24 -0400
In-Reply-To: <20170428.163355.2067951664875385680.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 1:33 PM, David Miller wrote:
> New in this version:
>
> 1) All the relocation work I posted earlier today.
> 2) Teach readelf about a few bpf relocs as needed
> 3) Add a 'nop' instruction which facilitates the gas
>    testsuite.  I used "mov r0,r0"
>
> The whole gas testsuite passes now. :-)  But that just
> means we have to add more tests I guess....
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

it seems by default bpf target is not enabled,
so I tried to build it with:
../configure --enable-targets=bpf,x86
make -j40
but it failed to build :(

Then I did ../configure --target=bpf
and it went better. At least I could compile objdump,
but gas refused to be configured:
checking whether byte ordering is bigendian... no
This target is no longer supported in gas
make[1]: *** [configure-gas] Error 1

Not sure what I'm doing wrong.

At least i tested objdump:
$ clang -O2 -target bpfeb -c test.c
$ llvm-objdump -S test.o

test.o:	file format ELF64-BPF

Disassembly of section .text:
bpf_prog1:
        0:	18 10 00 00 83 98 47 39 00 00 00 00 00 00 00 89 	r1 = 
590618314553ll
        2:	7b a1 ff f8 00 00 00 00 	*(u64 *)(r10 - 8) = r1
        3:	79 1a ff f8 00 00 00 00 	r1 = *(u64 *)(r10 - 8)
        4:	07 10 00 00 8f ff 00 02 	r1 += -1879113726
        5:	79 01 00 00 00 00 00 00 	r0 = *(u64 *)(r1 + 0)
        6:	95 00 00 00 00 00 00 00 	exit

$ bld/binutils/objdump -S test.o

test.o:     file format elf64-bpfbe

Disassembly of section .text:

0000000000000000 <bpf_prog1>:
    0:	18 10 00 00 83 98 47 39 	ldimm64	r1, 590618314553
    8:	00 00 00 00 00 00 00 89
   10:	7b a1 ff f8 00 00 00 00 	stdw	[r10+65528], r1
   18:	79 1a ff f8 00 00 00 00 	lddw	r1, [r10+65528]
   20:	07 10 00 00 8f ff 00 02 	add	r1, -1879113726
   28:	79 01 00 00 00 00 00 00 	lddw	r0, [r1+0]
   30:	95 00 00 00 00 00 00 00 	exit

looks good except negative offsets are reported as large positive.

If compiled with clang -O2 -target bpfel and result is:
$ bld/binutils/objdump -S test.o

test.o:     file format elf64-bpfle

Disassembly of section .text:

0000000000000000 <bpf_prog1>:
    0:	18 01 00 00 39 47 98 83 	ldimm64	r0, 590618314553
    8:	00 00 00 00 89 00 00 00
   10:	7b 1a f8 ff 00 00 00 00 	stdw	[r1+65528], r10
   18:	79 a1 f8 ff 00 00 00 00 	lddw	r10, [r1+65528]

Now the src/dst registers are swapped :(
The bytes printed are correct though.

clang debug info is not recognized as well:
$ clang -O2 -g -target bpfel -c test.c
/w/binutils-gdb/bld/binutils/objdump -S test.o

test.o:     file format elf64-bpfle


Disassembly of section .text:

0000000000000000 <bpf_prog1>:
/w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
/w/binutils-gdb/bld/binutils/objdump: BFD (GNU Binutils) 
2.28.51.20170429 assertion fail ../../bfd/elf64-bpf.c:139
...
/w/binutils-gdb/bld/binutils/objdump: BFD (GNU Binutils) 
2.28.51.20170429 assertion fail ../../bfd/elf64-bpf.c:139
/w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
/w/binutils-gdb/bld/binutils/objdump: BFD (GNU Binutils) 
2.28.51.20170429 assertion fail ../../bfd/elf64-bpf.c:139
    0:	18 01 00 00 39 47 98 83 	ldimm64	r0, 590618314553
    8:	00 00 00 00 89 00 00 00
   10:	7b 1a f8 ff 00 00 00 00 	stdw	[r1+65528], r10

$ clang -O2 -g -target bpfeb -c test.c
$ /w/binutils-gdb/bld/binutils/objdump -S test.o

test.o:     file format elf64-bpfbe

Disassembly of section .text:

0000000000000000 <bpf_prog1>:
/w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
/w/binutils-gdb/bld/binutils/objdump: BFD (GNU Binutils) 
2.28.51.20170429 assertion fail ../../bfd/elf64-bpf.c:139
...
/w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
/w/binutils-gdb/bld/binutils/objdump: Dwarf Error: found address size 
'0', this reader can only handle address sizes '2', '4' and '8'.
    0:	18 10 00 00 83 98 47 39 	ldimm64	r1, 590618314553
    8:	00 00 00 00 00 00 00 89
   10:	7b a1 ff f8 00 00 00 00 	stdw	[r10+65528], r1
   18:	79 1a ff f8 00 00 00 00 	lddw	r1, [r10+65528]

With llvm it should be like this:
$ ./bin/clang -O2 -g -target bpfel -c test.c
$ ./bin/llvm-objdump -S test.o

test.o:	file format ELF64-BPF

Disassembly of section .text:
bpf_prog1:
; {
        0:	18 01 00 00 39 47 98 83 00 00 00 00 89 00 00 00 	r1 = 
590618314553ll
; volatile unsigned long t = 0x8983984739ull;
        2:	7b 1a f8 ff 00 00 00 00 	*(u64 *)(r10 - 8) = r1
; return *(unsigned long *)((0xffffffff8fff0002ull) + t);
        3:	79 a1 f8 ff 00 00 00 00 	r1 = *(u64 *)(r10 - 8)
        4:	07 01 00 00 02 00 ff 8f 	r1 += -1879113726
        5:	79 10 00 00 00 00 00 00 	r0 = *(u64 *)(r1 + 0)
        6:	95 00 00 00 00 00 00 00 	exit

The output of llvm with '-g -target bpfeb' is probably partially broken,
since 'llvm-objdump -S test.o' doesn't see any debug in there.
So gnu objdump's error:
  Dwarf Error: found address size '0'
is likely legit.
