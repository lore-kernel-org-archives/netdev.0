From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sun, 30 Apr 2017 14:21:04 -0400 (EDT)
Message-ID: <20170430.142104.1845572453793505873.davem@davemloft.net>
References: <20170429.222450.1300920007783667009.davem@davemloft.net>
        <20170429.223759.1262491011130998405.davem@davemloft.net>
        <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966958AbdD3SVI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 14:21:08 -0400
In-Reply-To: <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 23:44:59 -0700

> '-g' still doesn't seem to work:
> /w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
> /w/binutils-gdb/bld/binutils/objdump: BFD (GNU Binutils)
> 2.28.51.20170429 assertion fail ../../bfd/elf64-bpf.c:139
>    0:	18 01 00 00 39 47 98 83 	ldimm64	r0, 590618314553

Ok, I can look at the debug info in little endian objects created by
clang now, but something is up with the dwarf information in
big-endian objects.

Your test program:

int bpf_prog1(void *ign)
{
        volatile unsigned long t = 0x8983984739ull;
        return *(unsigned long *)((0xffffffff8fff0002ull) + t);
}

built with:

	clang -O2 -target bpfel -g -c x.c -o x.o

readelf can see it just fine:

[davem@localhost binutils]$ ./readelf --debug-dump=loc ./xel.o 
Contents of the .debug_loc section:

    Offset   Begin            End              Expression
    00000000 0000000000000000 0000000000000010 (DW_OP_reg1 (r1))
    00000013 <End of list>
    00000023 0000000000000010 0000000000000020 (DW_OP_constu: 590618314553; DW_OP_stack_value)
    0000003d 0000000000000020 0000000000000030 (DW_OP_reg1 (r1))
    00000050 <End of list>

But with big-endian:

[davem@localhost binutils]$ ./readelf --debug-dump=loc ./xeb.o 
readelf: Warning: Invalid pointer size (0) in compunit header, using 4 instead
readelf: Warning: Bogus end-of-siblings marker detected at offset 27 in .debug_info section
readelf: Warning: Bogus end-of-siblings marker detected at offset 28 in .debug_info section
readelf: Warning: DIE at offset 0x29 refers to abbreviation number 48 which does not exist
readelf: Warning: Unable to load/parse the .debug_info section, so cannot interpret the .debug_loc section.

GDB behaves similarly, xel.o works fine but for the big-endian object:

Reading symbols from ./xeb.o...../../binutils-gdb/gdb/dwarf2read.c:16933: internal-error: read_address: bad switch, unsigned [in module /home/davem/src/GIT/BINUTILS/build-bpf/binutils/xeb.o]

It is entirely possible that the problem is on the LLVM side.
Can you double check that the dwarf2 emission code in LLVM is
using the correct endianness?

Here is my working diff against v4:

diff --git a/bfd/elf64-bpf.c b/bfd/elf64-bpf.c
index a42f768..1d8085e 100644
--- a/bfd/elf64-bpf.c
+++ b/bfd/elf64-bpf.c
@@ -15,6 +15,7 @@
 static reloc_howto_type _bfd_bpf_elf_howto_table[] =
 {
   HOWTO(R_BPF_NONE,      0,3, 0,FALSE,0,complain_overflow_dont,    bfd_elf_generic_reloc,  "R_BPF_NONE",    FALSE,0,0x00000000,TRUE),
+  HOWTO(R_BPF_DATA_64,   0,4,64,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_64", FALSE,0,MINUS_ONE,TRUE),
 
   /* XXX these are wrong XXX */
   HOWTO(R_BPF_INSN_64,   0,4,64,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_INSN_64", FALSE,0,MINUS_ONE,TRUE),
@@ -22,13 +23,11 @@ static reloc_howto_type _bfd_bpf_elf_howto_table[] =
   HOWTO(R_BPF_INSN_16,   0,1,16,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_INSN_16", FALSE,0,0x0000ffff,TRUE),
   HOWTO(R_BPF_WDISP16,   0,1,16,TRUE, 0,complain_overflow_signed,  bfd_elf_generic_reloc,  "R_BPF_WDISP16", FALSE,0,0x0000ffff,TRUE),
 
-  EMPTY_HOWTO(5),
   EMPTY_HOWTO(6),
   EMPTY_HOWTO(7),
   HOWTO(R_BPF_DATA_8,    0,0, 8,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_8",  FALSE,0,0x000000ff,TRUE),
   HOWTO(R_BPF_DATA_16,   0,1,16,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_16", FALSE,0,0x0000ffff,TRUE),
   HOWTO(R_BPF_DATA_32,   0,2,32,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_32", FALSE,0,0xffffffff,TRUE),
-  HOWTO(R_BPF_DATA_64,   0,4,64,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_64", FALSE,0,MINUS_ONE,TRUE),
 };
 
 reloc_howto_type *
diff --git a/binutils/readelf.c b/binutils/readelf.c
index b4013fb..0e9716b 100644
--- a/binutils/readelf.c
+++ b/binutils/readelf.c
@@ -12254,7 +12254,7 @@ is_64bit_abs_reloc (unsigned int reloc_type)
     case EM_ALPHA:
       return reloc_type == 2; /* R_ALPHA_REFQUAD.  */
     case EM_BPF:
-      return reloc_type == 11; /* R_BPF_DATA_64 */
+      return reloc_type == 1; /* R_BPF_DATA_64 */
     case EM_IA_64:
       return reloc_type == 0x27; /* R_IA64_DIR64LSB.  */
     case EM_PARISC:
diff --git a/include/elf/bpf.h b/include/elf/bpf.h
index 4aa38cc..0d6fddc 100644
--- a/include/elf/bpf.h
+++ b/include/elf/bpf.h
@@ -26,14 +26,14 @@
 /* Relocation types.  */
 START_RELOC_NUMBERS (elf_bpf_reloc_type)
   RELOC_NUMBER (R_BPF_NONE, 0)
-  RELOC_NUMBER (R_BPF_INSN_64, 1)
-  RELOC_NUMBER (R_BPF_INSN_32, 2)
-  RELOC_NUMBER (R_BPF_INSN_16, 3)
-  RELOC_NUMBER (R_BPF_WDISP16, 4)
+  RELOC_NUMBER (R_BPF_DATA_64, 1)
+  RELOC_NUMBER (R_BPF_INSN_64, 2)
+  RELOC_NUMBER (R_BPF_INSN_32, 3)
+  RELOC_NUMBER (R_BPF_INSN_16, 4)
+  RELOC_NUMBER (R_BPF_WDISP16, 5)
   RELOC_NUMBER (R_BPF_DATA_8,  8)
   RELOC_NUMBER (R_BPF_DATA_16, 9)
   RELOC_NUMBER (R_BPF_DATA_32, 10)
-  RELOC_NUMBER (R_BPF_DATA_64, 11)
 END_RELOC_NUMBERS (R_BPF_max)
 
 #endif /* _ELF_BPF_H */
