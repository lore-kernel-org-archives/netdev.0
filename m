From: David Miller <davem@davemloft.net>
Subject: status of bpf binutils
Date: Thu, 27 Apr 2017 12:39:23 -0400 (EDT)
Message-ID: <20170427.123923.1813737089652439023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42848 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938844AbdD0Qj1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:39:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As I hinted the other day I'm hacking on BPF support in binutils.

Here is what works right now:

1) disassembly of object files made by existing tools, I can build things
   with clang/llvm on my sparc and analyze the resulting object files
   using objdump and gdb

[davem@dhcp-10-15-49-210 build-bpf]$ ./binutils/objdump -d ./x.o

./x.o:     file format elf64-bpf


Disassembly of section test1:

0000000000000000 <process>:
   0:	b7 00 00 00 00 00 00 02 	mov	r0, 2
   8:	61 21 00 50 00 00 00 00 	ldw	r2, [r1+80]
 ...

[davem@dhcp-10-15-49-210 build-bpf]$ ./gdb/gdb ./x.o
GNU gdb (GDB) 8.0.50.20170427-git
Copyright (C) 2017 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=x86_64-pc-linux-gnu --target=bpf-elf".
 ...
(gdb) x/10i process
   0x0 <process>:	mov	r0, 2
   0x8 <process+8>:	ldw	r2, [r1+80]
   0x10 <process+16>:	ldw	r1, [r1+76]
   0x18 <process+24>:	mov	r4, r1
   0x20 <process+32>:	add	r4, 14
   0x28 <process+40>:	jgt	r4, r2, 0x148 <LBB0_11>
   0x30 <process+48>:	ldb	r5, [r1+13]
   0x38 <process+56>:	ldb	r3, [r1+12]
   0x40 <process+64>:	lsh	r3, 8
   0x48 <process+72>:	or	r3, r5
(gdb)

2) Simple assembler programs compile.

[davem@dhcp-10-15-49-210 build-bpf]$ cat gas/x.s
	.text
	.align	8
	.globl	foo
foo:	mov	r1, 2
	ja	1f
	mov	r1, 3
1:	exit
[davem@dhcp-10-15-49-210 build-bpf]$ gas/as-new -o gas/x.o gas/x.s
[davem@dhcp-10-15-49-210 build-bpf]$ ./binutils/objdump -d gas/x.o

gas/x.o:     file format elf64-bpf


Disassembly of section .text:

0000000000000000 <foo>:
   0:	b7 10 00 00 00 00 00 02 	mov	r1, 2
   8:	05 00 00 03 00 00 00 00 	ja	18 <foo+0x18>
  10:	b7 10 00 00 00 00 00 03 	mov	r1, 3
  18:	95 00 00 00 00 00 00 00 	exit	
[davem@dhcp-10-15-49-210 build-bpf]$

I've created a few ELF relocations for BPF, there are only really 3
main things to consider:

1) Immediate field, 32-bit
2) Offset field, 16-bit absolute
3) Offset field, 16-bit PC-relative displacement

and thus:

/* Relocation types.  */
START_RELOC_NUMBERS (elf_bpf_reloc_type)
  RELOC_NUMBER (R_BPF_NONE, 0)
  RELOC_NUMBER (R_BPF_16, 1)
  RELOC_NUMBER (R_BPF_32, 2)
  RELOC_NUMBER (R_BPF_WDISP16, 3)
END_RELOC_NUMBERS (R_BPF_max)

is what goes into include/elf/bpf.h

I just realized while writing this that I'll need to add an R_BPF_64
to handle ldimm64 instructions, but that's not a big deal.

I'm going to concentrate on the assembler for now, and start writing
test cases.

Another area I have not resolved completely is endianness.  Right now
just for my hacking and testing, I'm forcing everything to be big
endian which of course will not be the final default :-)

The current patch against:

	git://sourceware.org/git/binutils-gdb.git

is below.

If you want to play with this configure for "--target=bpf-elf".


>From 2e193eecf3eee1c0632f5c1932f76ff387c49ae2 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 26 Apr 2017 14:27:53 -0400
Subject: [PATCH] Start adding BPF support...

---
 bfd/Makefile.am            |   2 +
 bfd/Makefile.in            |   3 +
 bfd/archures.c             |   3 +
 bfd/bfd-in2.h              |   5 +
 bfd/config.bfd             |   5 +
 bfd/configure              |   1 +
 bfd/configure.ac           |   1 +
 bfd/cpu-bpf.c              |  41 +++++
 bfd/elf64-bpf.c            |  47 +++++
 bfd/libbfd.h               |   1 +
 bfd/reloc.c                |   5 +
 bfd/targets.c              |   3 +
 config.sub                 |   5 +-
 gas/Makefile.am            |   2 +
 gas/Makefile.in            |  17 ++
 gas/config/tc-bpf.c        | 447 +++++++++++++++++++++++++++++++++++++++++++++
 gas/config/tc-bpf.h        |  38 ++++
 gas/configure.tgt          |   3 +
 gdb/bpf-tdep.c             | 229 +++++++++++++++++++++++
 gdb/bpf-tdep.h             |  40 ++++
 gdb/configure.tgt          |   4 +
 include/dis-asm.h          |   1 +
 include/elf/bpf.h          |  34 ++++
 include/opcode/bpf.h       |  16 ++
 ld/Makefile.am             |   4 +
 ld/Makefile.in             |   5 +
 ld/configure.tgt           |   2 +
 ld/emulparams/elf64_bpf.sh |   8 +
 opcodes/Makefile.am        |   2 +
 opcodes/bpf-dis.c          | 152 +++++++++++++++
 opcodes/bpf-opc.c          | 147 +++++++++++++++
 opcodes/configure          |   1 +
 opcodes/configure.ac       |   1 +
 opcodes/disassemble.c      |   6 +
 34 files changed, 1279 insertions(+), 2 deletions(-)
 create mode 100644 bfd/cpu-bpf.c
 create mode 100644 bfd/elf64-bpf.c
 create mode 100644 gas/config/tc-bpf.c
 create mode 100644 gas/config/tc-bpf.h
 create mode 100644 gdb/bpf-tdep.c
 create mode 100644 gdb/bpf-tdep.h
 create mode 100644 include/elf/bpf.h
 create mode 100644 include/opcode/bpf.h
 create mode 100644 ld/emulparams/elf64_bpf.sh
 create mode 100644 opcodes/bpf-dis.c
 create mode 100644 opcodes/bpf-opc.c

diff --git a/bfd/Makefile.am b/bfd/Makefile.am
index 97b608c..911655a 100644
--- a/bfd/Makefile.am
+++ b/bfd/Makefile.am
@@ -95,6 +95,7 @@ ALL_MACHINES = \
 	cpu-arm.lo \
 	cpu-avr.lo \
 	cpu-bfin.lo \
+	cpu-bpf.lo \
 	cpu-cr16.lo \
 	cpu-cr16c.lo \
 	cpu-cris.lo \
@@ -185,6 +186,7 @@ ALL_MACHINES_CFILES = \
 	cpu-arm.c \
 	cpu-avr.c \
 	cpu-bfin.c \
+	cpu-bpf.c \
 	cpu-cr16.c \
 	cpu-cr16c.c \
 	cpu-cris.c \
diff --git a/bfd/Makefile.in b/bfd/Makefile.in
index e48abaf..930aa09 100644
--- a/bfd/Makefile.in
+++ b/bfd/Makefile.in
@@ -428,6 +428,7 @@ ALL_MACHINES = \
 	cpu-arm.lo \
 	cpu-avr.lo \
 	cpu-bfin.lo \
+	cpu-bpf.lo \
 	cpu-cr16.lo \
 	cpu-cr16c.lo \
 	cpu-cris.lo \
@@ -518,6 +519,7 @@ ALL_MACHINES_CFILES = \
 	cpu-arm.c \
 	cpu-avr.c \
 	cpu-bfin.c \
+	cpu-bpf.c \
 	cpu-cr16.c \
 	cpu-cr16c.c \
 	cpu-cris.c \
@@ -1380,6 +1382,7 @@ distclean-compile:
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cpu-arm.Plo@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cpu-avr.Plo@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cpu-bfin.Plo@am__quote@
+@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cpu-bpf.Plo@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cpu-cr16.Plo@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cpu-cr16c.Plo@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cpu-cris.Plo@am__quote@
diff --git a/bfd/archures.c b/bfd/archures.c
index c6e7152..f096d73 100644
--- a/bfd/archures.c
+++ b/bfd/archures.c
@@ -447,6 +447,8 @@ DESCRIPTION
 .#define bfd_mach_avrxmega7 107
 .  bfd_arch_bfin,        {* ADI Blackfin *}
 .#define bfd_mach_bfin          1
+.  bfd_arch_bpf,        {* eBPF *}
+.#define bfd_mach_bpf           1
 .  bfd_arch_cr16,       {* National Semiconductor CompactRISC (ie CR16). *}
 .#define bfd_mach_cr16		1
 .  bfd_arch_cr16c,       {* National Semiconductor CompactRISC. *}
@@ -582,6 +584,7 @@ extern const bfd_arch_info_type bfd_arc_arch;
 extern const bfd_arch_info_type bfd_arm_arch;
 extern const bfd_arch_info_type bfd_avr_arch;
 extern const bfd_arch_info_type bfd_bfin_arch;
+extern const bfd_arch_info_type bfd_bpf_arch;
 extern const bfd_arch_info_type bfd_cr16_arch;
 extern const bfd_arch_info_type bfd_cr16c_arch;
 extern const bfd_arch_info_type bfd_cris_arch;
diff --git a/bfd/bfd-in2.h b/bfd/bfd-in2.h
index 17a35c0..b4db6b2 100644
--- a/bfd/bfd-in2.h
+++ b/bfd/bfd-in2.h
@@ -2304,6 +2304,8 @@ enum bfd_architecture
 #define bfd_mach_avrxmega7 107
   bfd_arch_bfin,        /* ADI Blackfin */
 #define bfd_mach_bfin          1
+  bfd_arch_bpf,        /* eBPF */
+#define bfd_mach_bpf           1
   bfd_arch_cr16,       /* National Semiconductor CompactRISC (ie CR16). */
 #define bfd_mach_cr16          1
   bfd_arch_cr16c,       /* National Semiconductor CompactRISC. */
@@ -3910,6 +3912,9 @@ pc-relative or some form of GOT-indirect relocation.  */
 /* ADI Blackfin arithmetic relocation.  */
   BFD_ARELOC_BFIN_ADDR,
 
+/* BPF relocations  */
+  BFD_RELOC_BPF_WDISP16,
+
 /* Mitsubishi D10V relocs.
 This is a 10-bit reloc with the right 2 bits
 assumed to be 0.  */
diff --git a/bfd/config.bfd b/bfd/config.bfd
index 151de95..0cbccae 100644
--- a/bfd/config.bfd
+++ b/bfd/config.bfd
@@ -161,6 +161,7 @@ am33_2.0*)	 targ_archs=bfd_mn10300_arch ;;
 arc*)		 targ_archs=bfd_arc_arch ;;
 arm*)		 targ_archs=bfd_arm_arch ;;
 bfin*)		 targ_archs=bfd_bfin_arch ;;
+bpf*)		 targ_archs=bfd_bpf_arch ;;
 c30*)		 targ_archs=bfd_tic30_arch ;;
 c4x*)		 targ_archs=bfd_tic4x_arch ;;
 c54x*)		 targ_archs=bfd_tic54x_arch ;;
@@ -471,6 +472,10 @@ case "${targ}" in
     targ_underscore=yes
     ;;
 
+  bpf-*-*)
+    targ_defvec=bpf_elf64_vec
+    ;;
+
   c30-*-*aout* | tic30-*-*aout*)
     targ_defvec=tic30_aout_vec
     ;;
diff --git a/bfd/configure b/bfd/configure
index 24e3e2f..d1a67bb 100755
--- a/bfd/configure
+++ b/bfd/configure
@@ -14298,6 +14298,7 @@ do
     avr_elf32_vec)		 tb="$tb elf32-avr.lo elf32.lo $elf" ;;
     bfin_elf32_vec)		 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
     bfin_elf32_fdpic_vec)	 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
+    bpf_elf64_vec)		 tb="$tb elf64-bpf.lo elf64.lo $elf" ;;
     bout_be_vec)		 tb="$tb bout.lo aout32.lo" ;;
     bout_le_vec)		 tb="$tb bout.lo aout32.lo" ;;
     cr16_elf32_vec)		 tb="$tb elf32-cr16.lo elf32.lo $elf" ;;
diff --git a/bfd/configure.ac b/bfd/configure.ac
index e568847..00c6690 100644
--- a/bfd/configure.ac
+++ b/bfd/configure.ac
@@ -429,6 +429,7 @@ do
     avr_elf32_vec)		 tb="$tb elf32-avr.lo elf32.lo $elf" ;;
     bfin_elf32_vec)		 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
     bfin_elf32_fdpic_vec)	 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
+    bpf_elf64_vec)		 tb="$tb elf64-bpf.lo elf64.lo $elf" ;;
     bout_be_vec)		 tb="$tb bout.lo aout32.lo" ;;
     bout_le_vec)		 tb="$tb bout.lo aout32.lo" ;;
     cr16_elf32_vec)		 tb="$tb elf32-cr16.lo elf32.lo $elf" ;;
diff --git a/bfd/cpu-bpf.c b/bfd/cpu-bpf.c
new file mode 100644
index 0000000..551e42e
--- /dev/null
+++ b/bfd/cpu-bpf.c
@@ -0,0 +1,41 @@
+/* BFD Support for the eBPF.
+
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+   This file is part of BFD, the Binary File Descriptor library.
+
+   This program is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as published by
+   the Free Software Foundation; either version 3 of the License, or
+   (at your option) any later version.
+
+   This program is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+   GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public License
+   along with this program; if not, write to the Free Software
+   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
+   MA 02110-1301, USA.  */
+
+#include "sysdep.h"
+#include "bfd.h"
+#include "libbfd.h"
+
+const bfd_arch_info_type bfd_bpf_arch =
+  {
+    64,     		/* Bits in a word.  */
+    64,  		/* Bits in an address.  */
+    8,     		/* Bits in a byte.  */
+    bfd_arch_bpf,
+    0,                	/* Only one machine.  */
+    "bpf",        	/* Arch name.  */
+    "bpf",        	/* Arch printable name.  */
+    3,                	/* Section align power.  */
+    TRUE,             	/* The one and only.  */
+    bfd_default_compatible,
+    bfd_default_scan,
+    bfd_arch_default_fill,
+    0,
+  };
diff --git a/bfd/elf64-bpf.c b/bfd/elf64-bpf.c
new file mode 100644
index 0000000..76f14e7
--- /dev/null
+++ b/bfd/elf64-bpf.c
@@ -0,0 +1,47 @@
+#include "sysdep.h"
+#include "bfd.h"
+#include "libbfd.h"
+#include "elf-bfd.h"
+#include "opcode/bpf.h"
+
+static void
+check_for_relocs (bfd * abfd, asection * o, void * failed)
+{
+  if ((o->flags & SEC_RELOC) != 0)
+    {
+      Elf_Internal_Ehdr *ehdrp;
+
+      ehdrp = elf_elfheader (abfd);
+      /* xgettext:c-format */
+      _bfd_error_handler (_("%B: Relocations in generic ELF (EM: %d)"),
+			  abfd, ehdrp->e_machine);
+
+      bfd_set_error (bfd_error_wrong_format);
+      * (bfd_boolean *) failed = TRUE;
+    }
+}
+
+static bfd_boolean
+elf64_generic_link_add_symbols (bfd *abfd, struct bfd_link_info *info)
+{
+  bfd_boolean failed = FALSE;
+
+  /* Check if there are any relocations.  */
+  bfd_map_over_sections (abfd, check_for_relocs, & failed);
+
+  if (failed)
+    return FALSE;
+  return bfd_elf_link_add_symbols (abfd, info);
+}
+
+#define TARGET_BIG_SYM		bpf_elf64_vec
+#define TARGET_BIG_NAME		"elf64-bpf"
+#define ELF_ARCH		bfd_arch_bpf
+#define ELF_MAXPAGESIZE		0x100000
+#define ELF_MACHINE_CODE	EM_BPF
+
+#define bfd_elf64_bfd_reloc_type_lookup bfd_default_reloc_type_lookup
+#define bfd_elf64_bfd_reloc_name_lookup _bfd_norelocs_bfd_reloc_name_lookup
+#define bfd_elf64_bfd_link_add_symbols	elf64_generic_link_add_symbols
+
+#include "elf64-target.h"
diff --git a/bfd/libbfd.h b/bfd/libbfd.h
index 8bac650..01c6d84 100644
--- a/bfd/libbfd.h
+++ b/bfd/libbfd.h
@@ -1794,6 +1794,7 @@ static const char *const bfd_reloc_code_real_names[] = { "@@uninitialized@@",
   "BFD_ARELOC_BFIN_PAGE",
   "BFD_ARELOC_BFIN_HWPAGE",
   "BFD_ARELOC_BFIN_ADDR",
+  "BFD_RELOC_BPF_WDISP16",
   "BFD_RELOC_D10V_10_PCREL_R",
   "BFD_RELOC_D10V_10_PCREL_L",
   "BFD_RELOC_D10V_18",
diff --git a/bfd/reloc.c b/bfd/reloc.c
index 9a04022..39dc3b2 100644
--- a/bfd/reloc.c
+++ b/bfd/reloc.c
@@ -3854,6 +3854,11 @@ ENUMDOC
   ADI Blackfin arithmetic relocation.
 
 ENUM
+  BFD_RELOC_BPF_WDISP16
+ENUMDOC
+  BPF relocations
+
+ENUM
   BFD_RELOC_D10V_10_PCREL_R
 ENUMDOC
   Mitsubishi D10V relocs.
diff --git a/bfd/targets.c b/bfd/targets.c
index 5841e8d..799e2bb 100644
--- a/bfd/targets.c
+++ b/bfd/targets.c
@@ -619,6 +619,7 @@ extern const bfd_target arm_pei_wince_le_vec;
 extern const bfd_target avr_elf32_vec;
 extern const bfd_target bfin_elf32_vec;
 extern const bfd_target bfin_elf32_fdpic_vec;
+extern const bfd_target bpf_elf64_vec;
 extern const bfd_target bout_be_vec;
 extern const bfd_target bout_le_vec;
 extern const bfd_target cr16_elf32_vec;
@@ -1029,6 +1030,8 @@ static const bfd_target * const _bfd_target_vector[] =
 	&bfin_elf32_vec,
 	&bfin_elf32_fdpic_vec,
 
+	&bpf_elf64_vec,
+
 	&bout_be_vec,
 	&bout_le_vec,
 
diff --git a/config.sub b/config.sub
index 40ea5df..942989e 100755
--- a/config.sub
+++ b/config.sub
@@ -2,7 +2,7 @@
 # Configuration validation subroutine script.
 #   Copyright 1992-2017 Free Software Foundation, Inc.
 
-timestamp='2017-04-02'
+timestamp='2017-04-25'
 
 # This file is free software; you can redistribute it and/or modify it
 # under the terms of the GNU General Public License as published by
@@ -257,6 +257,7 @@ case $basic_machine in
 	| ba \
 	| be32 | be64 \
 	| bfin \
+	| bpf \
 	| c4x | c8051 | clipper \
 	| d10v | d30v | dlx | dsp16xx \
 	| e2k | epiphany \
@@ -380,7 +381,7 @@ case $basic_machine in
 	| avr-* | avr32-* \
 	| ba-* \
 	| be32-* | be64-* \
-	| bfin-* | bs2000-* \
+	| bfin-* | bpf-* | bs2000-* \
 	| c[123]* | c30-* | [cjt]90-* | c4x-* \
 	| c8051-* | clipper-* | craynv-* | cydra-* \
 	| d10v-* | d30v-* | dlx-* \
diff --git a/gas/Makefile.am b/gas/Makefile.am
index c9f9de0..bfd6ed9 100644
--- a/gas/Makefile.am
+++ b/gas/Makefile.am
@@ -135,6 +135,7 @@ TARGET_CPU_CFILES = \
 	config/tc-arm.c \
 	config/tc-avr.c \
 	config/tc-bfin.c \
+	config/tc-bpf.c \
 	config/tc-cr16.c \
 	config/tc-cris.c \
 	config/tc-crx.c \
@@ -212,6 +213,7 @@ TARGET_CPU_HFILES = \
 	config/tc-arm.h \
 	config/tc-avr.h \
 	config/tc-bfin.h \
+	config/tc-bpf.h \
 	config/tc-cr16.h \
 	config/tc-cris.h \
 	config/tc-crx.h \
diff --git a/gas/Makefile.in b/gas/Makefile.in
index 1927de5..ee62f1a 100644
--- a/gas/Makefile.in
+++ b/gas/Makefile.in
@@ -431,6 +431,7 @@ TARGET_CPU_CFILES = \
 	config/tc-arm.c \
 	config/tc-avr.c \
 	config/tc-bfin.c \
+	config/tc-bpf.c \
 	config/tc-cr16.c \
 	config/tc-cris.c \
 	config/tc-crx.c \
@@ -508,6 +509,7 @@ TARGET_CPU_HFILES = \
 	config/tc-arm.h \
 	config/tc-avr.h \
 	config/tc-bfin.h \
+	config/tc-bpf.h \
 	config/tc-cr16.h \
 	config/tc-cris.h \
 	config/tc-crx.h \
@@ -868,6 +870,7 @@ distclean-compile:
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/tc-arm.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/tc-avr.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/tc-bfin.Po@am__quote@
+@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/tc-bpf.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/tc-cr16.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/tc-cris.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/tc-crx.Po@am__quote@
@@ -1045,6 +1048,20 @@ tc-bfin.obj: config/tc-bfin.c
 @AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CCDEPMODE) $(depcomp) @AMDEPBACKSLASH@
 @am__fastdepCC_FALSE@	$(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS) -c -o tc-bfin.obj `if test -f 'config/tc-bfin.c'; then $(CYGPATH_W) 'config/tc-bfin.c'; else $(CYGPATH_W) '$(srcdir)/config/tc-bfin.c'; fi`
 
+tc-bpf.o: config/tc-bpf.c
+@am__fastdepCC_TRUE@	$(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS) -MT tc-bpf.o -MD -MP -MF $(DEPDIR)/tc-bpf.Tpo -c -o tc-bpf.o `test -f 'config/tc-bpf.c' || echo '$(srcdir)/'`config/tc-bpf.c
+@am__fastdepCC_TRUE@	$(am__mv) $(DEPDIR)/tc-bpf.Tpo $(DEPDIR)/tc-bpf.Po
+@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='config/tc-bpf.c' object='tc-bpf.o' libtool=no @AMDEPBACKSLASH@
+@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CCDEPMODE) $(depcomp) @AMDEPBACKSLASH@
+@am__fastdepCC_FALSE@	$(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS) -c -o tc-bpf.o `test -f 'config/tc-bpf.c' || echo '$(srcdir)/'`config/tc-bpf.c
+
+tc-bpf.obj: config/tc-bpf.c
+@am__fastdepCC_TRUE@	$(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS) -MT tc-bpf.obj -MD -MP -MF $(DEPDIR)/tc-bpf.Tpo -c -o tc-bpf.obj `if test -f 'config/tc-bpf.c'; then $(CYGPATH_W) 'config/tc-bpf.c'; else $(CYGPATH_W) '$(srcdir)/config/tc-bpf.c'; fi`
+@am__fastdepCC_TRUE@	$(am__mv) $(DEPDIR)/tc-bpf.Tpo $(DEPDIR)/tc-bpf.Po
+@AMDEP_TRUE@@am__fastdepCC_FALSE@	source='config/tc-bpf.c' object='tc-bpf.obj' libtool=no @AMDEPBACKSLASH@
+@AMDEP_TRUE@@am__fastdepCC_FALSE@	DEPDIR=$(DEPDIR) $(CCDEPMODE) $(depcomp) @AMDEPBACKSLASH@
+@am__fastdepCC_FALSE@	$(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS) -c -o tc-bpf.obj `if test -f 'config/tc-bpf.c'; then $(CYGPATH_W) 'config/tc-bpf.c'; else $(CYGPATH_W) '$(srcdir)/config/tc-bpf.c'; fi`
+
 tc-cr16.o: config/tc-cr16.c
 @am__fastdepCC_TRUE@	$(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS) -MT tc-cr16.o -MD -MP -MF $(DEPDIR)/tc-cr16.Tpo -c -o tc-cr16.o `test -f 'config/tc-cr16.c' || echo '$(srcdir)/'`config/tc-cr16.c
 @am__fastdepCC_TRUE@	$(am__mv) $(DEPDIR)/tc-cr16.Tpo $(DEPDIR)/tc-cr16.Po
diff --git a/gas/config/tc-bpf.c b/gas/config/tc-bpf.c
new file mode 100644
index 0000000..334e228
--- /dev/null
+++ b/gas/config/tc-bpf.c
@@ -0,0 +1,447 @@
+/* tc-bpf.c -- Assemble for the SPARC
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of GAS, the GNU Assembler.
+
+   GAS is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as published by
+   the Free Software Foundation; either version 3, or (at your option)
+   any later version.
+
+   GAS is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+   GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public
+   License along with GAS; see the file COPYING.  If not, write
+   to the Free Software Foundation, 51 Franklin Street - Fifth Floor,
+   Boston, MA 02110-1301, USA.  */
+
+#include "as.h"
+#include "safe-ctype.h"
+#include "subsegs.h"
+#include "opcode/bpf.h"
+#ifdef OBJ_ELF
+#include "elf/bpf.h"
+#include "dwarf2dbg.h"
+#endif
+
+const pseudo_typeS md_pseudo_table[] =
+{
+  {"align", s_align_bytes, 0},	/* Defaulting is invalid (0).  */
+  {"global", s_globl, 0},
+  {"half", cons, 2},
+  {"skip", s_space, 0},
+  {"word", cons, 4},
+  {"xword", cons, 8},
+  {NULL, 0, 0},
+};
+
+const char comment_chars[] = "!";
+const char line_comment_chars[] = "#";
+const char line_separator_chars[] = ";";
+const char EXP_CHARS[] = "eE";
+const char FLT_CHARS[] = "rRsSfFdDxXpP";
+
+const char *md_shortopts = "";
+struct option md_longopts[] =
+{
+  { NULL,		no_argument,		NULL, 0                 },
+};
+size_t md_longopts_size = sizeof (md_longopts);
+
+int
+md_parse_option (int c ATTRIBUTE_UNUSED, const char *arg ATTRIBUTE_UNUSED)
+{
+  return 0;
+}
+
+void
+md_show_usage (FILE *stream)
+{
+  fprintf (stream, _("BPF options:\n"));
+}
+
+/* Handle of the OPCODE hash table.  */
+static struct hash_control *op_hash;
+
+void
+md_begin (void)
+{
+  const char *retval = NULL;
+  unsigned int i = 0;
+  int lose = 0;
+
+  op_hash = hash_new ();
+  while (i < (unsigned int) bpf_num_opcodes)
+    {
+      const char *name = bpf_opcodes[i].name;
+      retval = hash_insert (op_hash, name, (void *) &bpf_opcodes[i]);
+      if (retval != NULL)
+	{
+	  as_bad (_("Internal error: can't hash `%s': %s\n"),
+		  bpf_opcodes[i].name, retval);
+	  lose = 1;
+	}
+      do
+	{
+	  ++i;
+	}
+      while (i < (unsigned int) bpf_num_opcodes
+	     && !strcmp (bpf_opcodes[i].name, name));
+    }
+  if (lose)
+    as_fatal (_("Broken assembler.  No assembly attempted."));
+
+
+}
+
+struct bpf_it
+  {
+    const char *error;
+    valueT opcode;
+    expressionS exp;
+    int pcrel;
+    bfd_reloc_code_real_type reloc;
+  };
+
+/* Subroutine of md_assemble to output one insn.  */
+
+static void
+output_insn (struct bpf_it *theinsn)
+{
+  char *toP = frag_more (8);
+
+  /* Put out the opcode.  */
+  if (target_big_endian)
+    {
+      number_to_chars_bigendian (toP, theinsn->opcode, 8);
+    }
+  else
+    {
+      number_to_chars_littleendian (toP, theinsn->opcode, 8);
+    }
+
+  /* Put out the symbol-dependent stuff.  */
+  if (theinsn->reloc != BFD_RELOC_NONE)
+    {
+      fixS *fixP =  fix_new_exp (frag_now,	/* Which frag.  */
+				 (toP - frag_now->fr_literal),	/* Where.  */
+				 4,		/* Size.  */
+				 &theinsn->exp,
+				 theinsn->pcrel,
+				 theinsn->reloc);
+      /* Turn off overflow checking in fixup_segment.  We'll do our
+	 own overflow checking in md_apply_fix.  This is necessary because
+	 the insn size is 4 and fixup_segment will signal an overflow for
+	 large 8 byte quantities.  */
+      fixP->fx_no_overflow = 1;
+    }
+
+#ifdef OBJ_ELF
+  dwarf2_emit_insn (8);
+#endif
+}
+
+static struct bpf_it the_insn;
+static char *expr_end;
+
+static int
+get_expression (char *str, expressionS *exp)
+{
+  char *save_in;
+  segT seg;
+
+  save_in = input_line_pointer;
+  input_line_pointer = str;
+  seg = expression (exp);
+  if (seg != absolute_section
+      && seg != text_section
+      && seg != data_section
+      && seg != bss_section
+      && seg != undefined_section)
+    {
+      the_insn.error = _("bad segment");
+      expr_end = input_line_pointer;
+      input_line_pointer = save_in;
+      return 1;
+    }
+  expr_end = input_line_pointer;
+  input_line_pointer = save_in;
+  return 0;
+}
+
+void
+md_assemble (char *str ATTRIBUTE_UNUSED)
+{
+  const struct bpf_opcode *insn;
+  const char *args;
+  char *argsStart;
+  int match = 0;
+  valueT mask;
+  char *s, c;
+
+  s = str;
+  if (ISLOWER (*s))
+    {
+      do
+	++s;
+      while (ISLOWER (*s) || ISDIGIT (*s) || *s == '_');
+    }
+
+  switch (*s)
+    {
+    case '\0':
+      break;
+
+    case ' ':
+      *s++ = '\0';
+      break;
+
+    default:
+      as_bad (_("Unknown opcode: `%s'"), str);
+      return;
+    }
+  insn = (struct bpf_opcode *) hash_find (op_hash, str);
+
+  if (insn == NULL)
+    {
+      as_bad (_("Unknown opcode: `%s'"), str);
+      return;
+    }
+
+  argsStart = s;
+  for (;;)
+    {
+      memset (&the_insn, '\0', sizeof (the_insn));
+      the_insn.reloc = BFD_RELOC_NONE;
+      the_insn.opcode = ((valueT)insn->code << 56);
+
+      for (args = insn->args;; args++)
+	{
+	  switch (*args)
+	    {
+	    case '+':
+	    case ',':
+	    case '[':
+	    case ']':
+	      if (*s++ == *args)
+		continue;
+	      break;
+	    case '1':
+	      if (*s++ == 'r')
+		{
+		  if (!ISDIGIT ((c = *s++)))
+		    {
+		      goto error;
+		    }
+		  c -= '0';
+		  mask = c;
+		  the_insn.opcode |= (mask << 52);
+		  continue;
+		}
+	      break;
+	    case '2':
+	      if (*s++ == 'r')
+		{
+		  if (!ISDIGIT ((c = *s++)))
+		    {
+		      goto error;
+		    }
+		  c -= '0';
+		  mask = c;
+		  the_insn.opcode |= (mask << 48);
+		  continue;
+		}
+	      break;
+	    case 'i':
+	      the_insn.reloc = BFD_RELOC_32;
+	      if (*s == ' ')
+		s++;
+	      get_expression (s, &the_insn.exp);
+	      s = expr_end;
+	      if (the_insn.exp.X_op == O_constant
+		  && the_insn.exp.X_add_symbol == 0
+		  && the_insn.exp.X_op_symbol == 0)
+		{
+		  valueT val = the_insn.exp.X_add_number;
+
+		  the_insn.reloc = BFD_RELOC_NONE;
+		  val &= 0xffffffff;
+		  the_insn.opcode |= val;
+		}
+	      continue;
+	    case 'O':
+	      the_insn.reloc = BFD_RELOC_16;
+	      if (*s == ' ')
+		s++;
+	      get_expression (s, &the_insn.exp);
+	      s = expr_end;
+	      if (the_insn.exp.X_op == O_constant
+		  && the_insn.exp.X_add_symbol == 0
+		  && the_insn.exp.X_op_symbol == 0)
+		{
+		  valueT val = the_insn.exp.X_add_number;
+
+		  the_insn.reloc = BFD_RELOC_NONE;
+		  val &= 0xffff;
+		  the_insn.opcode |= val << 32;
+		}
+	      continue;
+	    case 'L':
+	      the_insn.reloc = BFD_RELOC_BPF_WDISP16;
+	      the_insn.pcrel = 1;
+	      if (*s == ' ')
+		s++;
+	      get_expression (s, &the_insn.exp);
+	      s = expr_end;
+	      if (the_insn.exp.X_op == O_constant
+		  && the_insn.exp.X_add_symbol == 0
+		  && the_insn.exp.X_op_symbol == 0)
+		{
+		  valueT val = the_insn.exp.X_add_number;
+
+		  the_insn.reloc = BFD_RELOC_NONE;
+		  val &= 0xffff;
+		  the_insn.opcode |= val << 32;
+		}
+	      continue;
+	    case 'C':
+	      break;
+	    case 'D':
+	      break;
+	    case '\0':		/* End of args.  */
+	      match = 1;
+	      break;
+	    default:
+	      as_fatal (_("failed sanity check."));
+	    }
+
+	  /* Break out of for() loop.  */
+	  break;
+	}
+    error:
+      if (match == 0)
+	{
+	  /* Args don't match.  */
+	  if (&insn[1] - bpf_opcodes < bpf_num_opcodes
+	      && (insn->name == insn[1].name
+		  || !strcmp (insn->name, insn[1].name)))
+	    {
+	      ++insn;
+	      s = argsStart;
+	      continue;
+	    }
+	  else
+	    {
+	      as_bad (_("Illegal operands%s"), "");
+	      return;
+	    }
+	}
+      break;
+    }
+
+  output_insn (&the_insn);
+}
+
+void
+md_number_to_chars (char *buf ATTRIBUTE_UNUSED, valueT val ATTRIBUTE_UNUSED, int n ATTRIBUTE_UNUSED)
+{
+}
+
+void
+md_apply_fix (fixS *fixP, valueT *valP ATTRIBUTE_UNUSED, segT segment ATTRIBUTE_UNUSED)
+{
+  char *buf = fixP->fx_where + fixP->fx_frag->fr_literal;
+  offsetT val = * (offsetT *) valP;
+
+  gas_assert (fixP->fx_r_type < BFD_RELOC_UNUSED);
+  /* If this is a data relocation, just output VAL.  */
+
+  if (fixP->fx_r_type == BFD_RELOC_8)
+    {
+      md_number_to_chars (buf, val, 1);
+    }
+  else if (fixP->fx_r_type == BFD_RELOC_16)
+    {
+      md_number_to_chars (buf, val, 2);
+    }
+  else if (fixP->fx_r_type == BFD_RELOC_32)
+    {
+      md_number_to_chars (buf, val, 4);
+    }
+  else if (fixP->fx_r_type == BFD_RELOC_64)
+    {
+      md_number_to_chars (buf, val, 8);
+    }
+  else if (fixP->fx_r_type == BFD_RELOC_VTABLE_INHERIT
+           || fixP->fx_r_type == BFD_RELOC_VTABLE_ENTRY)
+    {
+      fixP->fx_done = 0;
+      return;
+    }
+  else
+    {
+      long insn;
+
+      if (target_big_endian)
+	insn = bfd_getb32 ((unsigned char *) buf);
+      else
+	insn = bfd_getl32 ((unsigned char *) buf);
+
+      /* It's a relocation against an instruction.  */
+
+      switch (fixP->fx_r_type)
+	{
+	case BFD_RELOC_BPF_WDISP16:
+	  val = val  >> 3;
+	  insn |= (val + 1) & 0xffff;
+	  break;
+	case BFD_RELOC_NONE:
+	default:
+	  as_bad_where (fixP->fx_file, fixP->fx_line,
+			_("bad or unhandled relocation type: 0x%02x"),
+			fixP->fx_r_type);
+	  break;
+	}
+
+      if (target_big_endian)
+	bfd_putb32 (insn, (unsigned char *) buf);
+      else
+	bfd_putl32 (insn, (unsigned char *) buf);
+    }
+}
+
+arelent *
+tc_gen_reloc (asection *section ATTRIBUTE_UNUSED, fixS *fixp ATTRIBUTE_UNUSED)
+{
+  return NULL;
+}
+
+symbolS *
+md_undefined_symbol (char *name ATTRIBUTE_UNUSED)
+{
+  return 0;
+}
+
+valueT
+md_section_align (segT segment ATTRIBUTE_UNUSED, valueT size)
+{
+  return size;
+}
+
+long
+md_pcrel_from (fixS *fixP)
+{
+  long ret;
+
+  ret = fixP->fx_where + fixP->fx_frag->fr_address;
+  /* XXX */
+  return ret;
+}
+
+const char *
+md_atof (int type, char *litP, int *sizeP)
+{
+  return ieee_md_atof (type, litP, sizeP, target_big_endian);
+}
diff --git a/gas/config/tc-bpf.h b/gas/config/tc-bpf.h
new file mode 100644
index 0000000..013e5ed
--- /dev/null
+++ b/gas/config/tc-bpf.h
@@ -0,0 +1,38 @@
+/* tc-bpf.h - Macros and type defines for the bpf.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+   This file is part of GAS, the GNU Assembler.
+
+   GAS is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as
+   published by the Free Software Foundation; either version 3,
+   or (at your option) any later version.
+
+   GAS is distributed in the hope that it will be useful, but
+   WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+   the GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public
+   License along with GAS; see the file COPYING.  If not, write
+   to the Free Software Foundation, 51 Franklin Street - Fifth Floor,
+   Boston, MA 02110-1301, USA.  */
+
+#ifndef TC_BPF
+#define TC_BPF 1
+
+#define TARGET_ARCH			bfd_arch_bpf
+#define TARGET_FORMAT			"elf64-bpf"
+#define TARGET_BYTES_BIG_ENDIAN		1
+
+#define md_convert_frag(b,s,f) \
+  as_fatal (_("bpf convert_frag\n"))
+#define md_estimate_size_before_relax(f,s) \
+  (as_fatal (_("estimate_size_before_relax called")), 1)
+#define md_operand(x)
+
+#define LISTING_HEADER "BPF GAS "
+
+#define WORKING_DOT_WORD
+
+#endif
diff --git a/gas/configure.tgt b/gas/configure.tgt
index ca58b69..fa959c3 100644
--- a/gas/configure.tgt
+++ b/gas/configure.tgt
@@ -54,6 +54,7 @@ case ${cpu} in
   arm*be|arm*b)		cpu_type=arm endian=big ;;
   arm*)			cpu_type=arm endian=little ;;
   bfin*)		cpu_type=bfin endian=little ;;
+  bpf*)			cpu_type=bpf ;;
   c4x*)			cpu_type=tic4x ;;
   cr16*)		cpu_type=cr16 endian=little ;;
   crisv32)		cpu_type=cris arch=crisv32 ;;
@@ -171,6 +172,8 @@ case ${generic_target} in
   bfin-*-uclinux*)			fmt=elf em=linux ;;
   bfin-*elf)				fmt=elf ;;
 
+  bpf-*elf)				fmt=elf ;;
+
   cr16-*-elf*)				fmt=elf ;;
 
   cris-*-linux-* | crisv32-*-linux-*)
diff --git a/gdb/bpf-tdep.c b/gdb/bpf-tdep.c
new file mode 100644
index 0000000..6629f73
--- /dev/null
+++ b/gdb/bpf-tdep.c
@@ -0,0 +1,229 @@
+/* Target-dependent code for eBPF, for GDB.
+
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+   This file is part of GDB.
+
+   This program is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as published by
+   the Free Software Foundation; either version 3 of the License, or
+   (at your option) any later version.
+
+   This program is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+   GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public License
+   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */
+
+#include "defs.h"
+#include "inferior.h"
+#include "gdbcore.h"
+#include "arch-utils.h"
+#include "regcache.h"
+#include "frame.h"
+#include "frame-unwind.h"
+#include "frame-base.h"
+#include "trad-frame.h"
+#include "dis-asm.h"
+#include "dwarf2-frame.h"
+#include "symtab.h"
+#include "elf-bfd.h"
+#include "osabi.h"
+#include "infcall.h"
+#include "bpf-tdep.h"
+
+static const char * const bpf_register_name_strings[] =
+{
+  "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
+  "r8", "r9", "r10", "pc",
+};
+
+#define NUM_BPF_REGNAMES ARRAY_SIZE (bpf_register_name_strings)
+
+/* Return the BPF register name corresponding to register I.  */
+
+static const char *
+bpf_register_name (struct gdbarch *gdbarch, int i)
+{
+  return bpf_register_name_strings[i];
+}
+
+/* Return the GDB type object for the "standard" data type of data in
+   register N.  */
+
+static struct type *
+bpf_register_type (struct gdbarch *gdbarch, int regnum)
+{
+  if (regnum == BPF_R10_REGNUM)
+    return builtin_type (gdbarch)->builtin_data_ptr;
+
+  if (regnum == BPF_PC_REGNUM)
+    return builtin_type (gdbarch)->builtin_func_ptr;
+
+  return builtin_type (gdbarch)->builtin_int32;
+}
+
+/* Convert DWARF2 register number REG to the appropriate register number
+   used by GDB.  */
+
+static int
+bpf_reg_to_regnum (struct gdbarch *gdbarch, int reg)
+{
+  if (reg < 0 || reg >= BPF_NUM_REGS)
+    return -1;
+
+  return reg;
+}
+
+static struct frame_id
+bpf_dummy_id (struct gdbarch *gdbarch, struct frame_info *this_frame)
+{
+  CORE_ADDR sp;
+
+  sp = get_frame_register_unsigned (this_frame, BPF_R10_REGNUM);
+
+  return frame_id_build (sp, get_frame_pc (this_frame));
+}
+
+static CORE_ADDR
+bpf_push_dummy_call (struct gdbarch *gdbarch,
+		      struct value *function,
+		      struct regcache *regcache,
+		      CORE_ADDR bp_addr,
+		      int nargs,
+		      struct value **args,
+		      CORE_ADDR sp,
+		      int struct_return,
+		      CORE_ADDR struct_addr)
+{
+  return sp; /* XXX */
+}
+
+/* Extract a function return value of TYPE from REGCACHE, and copy
+   that into VALBUF.  */
+
+static void
+bpf_extract_return_value (struct type *type, struct regcache *regcache,
+			  gdb_byte *valbuf)
+{
+  int len = TYPE_LENGTH (type);
+  gdb_byte buf[8];
+
+  regcache_cooked_read (regcache, BPF_R0_REGNUM, buf);
+  memcpy (valbuf, buf + 8 - len, len);
+}
+
+/* Store the function return value of type TYPE from VALBUF into
+   REGCACHE.  */
+
+static void
+bpf_store_return_value (struct type *type, struct regcache *regcache,
+			const gdb_byte *valbuf)
+{
+  int len = TYPE_LENGTH (type);
+  gdb_byte buf[8];
+
+  memcpy (buf + 8 - len, valbuf, len);
+  regcache_cooked_write (regcache, BPF_R0_REGNUM, buf);
+}
+
+/* Determine, for architecture GDBARCH, how a return value of TYPE
+   should be returned.  If it is supposed to be returned in registers,
+   and READBUF is nonzero, read the appropriate value from REGCACHE,
+   and copy it into READBUF.  If WRITEBUF is nonzero, write the value
+   from WRITEBUF into REGCACHE.  */
+
+static enum return_value_convention
+bpf_return_value (struct gdbarch *gdbarch,
+		   struct value *function,
+		   struct type *type,
+		   struct regcache *regcache,
+		   gdb_byte *readbuf,
+		   const gdb_byte *writebuf)
+{
+  if (TYPE_LENGTH (type) > 8)
+    return RETURN_VALUE_STRUCT_CONVENTION;
+
+  if (readbuf)
+    bpf_extract_return_value (type, regcache, readbuf);
+
+  if (writebuf)
+    bpf_store_return_value (type, regcache, writebuf);
+
+  return RETURN_VALUE_REGISTER_CONVENTION;
+}
+
+static CORE_ADDR
+bpf_unwind_pc (struct gdbarch *gdbarch, struct frame_info *next_frame)
+{
+  return frame_unwind_register_unsigned (next_frame, BPF_PC_REGNUM);
+}
+
+/* Skip all the insns that appear in generated function prologues.  */
+
+static CORE_ADDR
+bpf_skip_prologue (struct gdbarch *gdbarch, CORE_ADDR pc)
+{
+  return pc;
+}
+
+/* Implement the breakpoint_kind_from_pc gdbarch method.  */
+
+static int
+bpf_breakpoint_kind_from_pc (struct gdbarch *gdbarch, CORE_ADDR *pcptr)
+{
+  return 8;
+}
+
+/* Initialize the current architecture based on INFO.  If possible,
+   re-use an architecture from ARCHES, which is a list of
+   architectures already created during this debugging session.
+
+   Called e.g. at program startup, when reading a core file, and when
+   reading a binary file.  */
+
+static struct gdbarch *
+bpf_gdbarch_init (struct gdbarch_info info, struct gdbarch_list *arches)
+{
+  struct gdbarch_tdep *tdep;
+  struct gdbarch *gdbarch;
+
+  tdep = XNEW (struct gdbarch_tdep);
+  gdbarch = gdbarch_alloc (&info, tdep);
+  
+  tdep->xxx = 0;
+
+  set_gdbarch_num_regs (gdbarch, BPF_NUM_REGS);
+  set_gdbarch_sp_regnum (gdbarch, BPF_R10_REGNUM);
+  set_gdbarch_pc_regnum (gdbarch, BPF_PC_REGNUM);
+  set_gdbarch_dwarf2_reg_to_regnum (gdbarch, bpf_reg_to_regnum);
+  set_gdbarch_register_name (gdbarch, bpf_register_name);
+  set_gdbarch_register_type (gdbarch, bpf_register_type);
+  set_gdbarch_dummy_id (gdbarch, bpf_dummy_id);
+  set_gdbarch_push_dummy_call (gdbarch, bpf_push_dummy_call);
+  set_gdbarch_return_value (gdbarch, bpf_return_value);
+  set_gdbarch_inner_than (gdbarch, core_addr_lessthan);
+  set_gdbarch_frame_args_skip (gdbarch, 8);
+  set_gdbarch_unwind_pc (gdbarch, bpf_unwind_pc);
+  set_gdbarch_print_insn (gdbarch, print_insn_bpf);
+
+  set_gdbarch_skip_prologue (gdbarch, bpf_skip_prologue);
+  set_gdbarch_breakpoint_kind_from_pc (gdbarch, bpf_breakpoint_kind_from_pc);
+
+  /* Hook in ABI-specific overrides, if they have been registered.  */
+  gdbarch_init_osabi (info, gdbarch);
+
+  dwarf2_append_unwinders (gdbarch);
+  return gdbarch;
+}
+
+/* Provide a prototype to silence -Wmissing-prototypes.  */
+extern initialize_file_ftype _initialize_bpf_tdep;
+
+void
+_initialize_bpf_tdep (void)
+{
+  register_gdbarch_init (bfd_arch_bpf, bpf_gdbarch_init);
+}
diff --git a/gdb/bpf-tdep.h b/gdb/bpf-tdep.h
new file mode 100644
index 0000000..52cae6d
--- /dev/null
+++ b/gdb/bpf-tdep.h
@@ -0,0 +1,40 @@
+/* Target-dependent code for eBPF, for GDB.
+
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+   This file is part of GDB.
+
+   This program is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as published by
+   the Free Software Foundation; either version 3 of the License, or
+   (at your option) any later version.
+
+   This program is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+   GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public License
+   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */
+
+enum gdb_regnum {
+  BPF_R0_REGNUM = 0,
+  BPF_R1_REGNUM,
+  BPF_R2_REGNUM,
+  BPF_R3_REGNUM,
+  BPF_R4_REGNUM,
+  BPF_R5_REGNUM,
+  BPF_R6_REGNUM,
+  BPF_R7_REGNUM,
+  BPF_R8_REGNUM,
+  BPF_R9_REGNUM,
+  BPF_R10_REGNUM,
+  BPF_PC_REGNUM,
+};
+
+#define BPF_NUM_REGS	(BPF_PC_REGNUM + 1)
+
+struct gdbarch_tdep
+{
+  int xxx;
+};
diff --git a/gdb/configure.tgt b/gdb/configure.tgt
index fdcb7b1..e8d5fb4 100644
--- a/gdb/configure.tgt
+++ b/gdb/configure.tgt
@@ -142,6 +142,10 @@ bfin-*-*)
 	gdb_sim=../sim/bfin/libsim.a
 	;;
 
+bpf*)
+	# Target: eBPF
+	gdb_target_obs="bpf-tdep.o"
+	;;
 cris*)
 	# Target: CRIS
 	gdb_target_obs="cris-tdep.o cris-linux-tdep.o linux-tdep.o solib-svr4.o"
diff --git a/include/dis-asm.h b/include/dis-asm.h
index 6f1801d..cbfebc8 100644
--- a/include/dis-asm.h
+++ b/include/dis-asm.h
@@ -241,6 +241,7 @@ extern int print_insn_aarch64		(bfd_vma, disassemble_info *);
 extern int print_insn_alpha		(bfd_vma, disassemble_info *);
 extern int print_insn_avr		(bfd_vma, disassemble_info *);
 extern int print_insn_bfin		(bfd_vma, disassemble_info *);
+extern int print_insn_bpf		(bfd_vma, disassemble_info *);
 extern int print_insn_big_arm		(bfd_vma, disassemble_info *);
 extern int print_insn_big_mips		(bfd_vma, disassemble_info *);
 extern int print_insn_big_nios2		(bfd_vma, disassemble_info *);
diff --git a/include/elf/bpf.h b/include/elf/bpf.h
new file mode 100644
index 0000000..6360db8
--- /dev/null
+++ b/include/elf/bpf.h
@@ -0,0 +1,34 @@
+/* BPF ELF support for BFD.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+   This file is part of BFD, the Binary File Descriptor library.
+
+   This program is free software; you can redistribute it and/or modify
+   it under the terms of the GNU General Public License as published by
+   the Free Software Foundation; either version 3 of the License, or
+   (at your option) any later version.
+
+   This program is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+   GNU General Public License for more details.
+
+   You should have received a copy of the GNU General Public License
+   along with this program; if not, write to the Free Software
+   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
+   MA 02110-1301, USA.  */
+
+#ifndef _ELF_BPF_H
+#define _ELF_BPF_H
+
+#include "elf/reloc-macros.h"
+
+/* Relocation types.  */
+START_RELOC_NUMBERS (elf_bpf_reloc_type)
+  RELOC_NUMBER (R_BPF_NONE, 0)
+  RELOC_NUMBER (R_BPF_16, 1)
+  RELOC_NUMBER (R_BPF_32, 2)
+  RELOC_NUMBER (R_BPF_WDISP16, 3)
+END_RELOC_NUMBERS (R_BPF_max)
+
+#endif /* _ELF_BPF_H */
diff --git a/include/opcode/bpf.h b/include/opcode/bpf.h
new file mode 100644
index 0000000..298ed1b
--- /dev/null
+++ b/include/opcode/bpf.h
@@ -0,0 +1,16 @@
+#ifndef OPCODE_BPF_H
+#define OPCODE_BPF_H
+
+/* Structure of an opcode table entry.  */
+
+typedef struct bpf_opcode
+{
+  const char *name;
+  unsigned char code;
+  const char *args;
+} bpf_opcode;
+
+extern const struct bpf_opcode bpf_opcodes[];
+extern const int bpf_num_opcodes;
+
+#endif /* OPCODE_BPF_H */
diff --git a/ld/Makefile.am b/ld/Makefile.am
index 3aa7e80..d840bed 100644
--- a/ld/Makefile.am
+++ b/ld/Makefile.am
@@ -477,6 +477,7 @@ ALL_64_EMULATION_SOURCES = \
 	eelf32ltsmipn32_fbsd.c \
 	eelf32mipswindiss.c \
 	eelf64_aix.c \
+	eelf64_bpf.c \
 	eelf64_ia64.c \
 	eelf64_ia64_fbsd.c \
 	eelf64_ia64_vms.c \
@@ -1920,6 +1921,9 @@ eelf32_x86_64_nacl.c: $(srcdir)/emulparams/elf32_x86_64_nacl.sh \
 eelf64_aix.c: $(srcdir)/emulparams/elf64_aix.sh \
   $(ELF_DEPS) $(srcdir)/scripttempl/elf.sc ${GEN_DEPENDS}
 
+eelf64_bpf.c: $(srcdir)/emulparams/elf64_bpf.sh \
+  $(ELF_DEPS) $(srcdir)/scripttempl/elf.sc ${GEN_DEPENDS}
+
 eelf64_ia64.c: $(srcdir)/emulparams/elf64_ia64.sh \
   $(ELF_DEPS) $(srcdir)/emultempl/ia64elf.em \
   $(srcdir)/emultempl/needrelax.em \
diff --git a/ld/Makefile.in b/ld/Makefile.in
index f485f4f..706a889 100644
--- a/ld/Makefile.in
+++ b/ld/Makefile.in
@@ -845,6 +845,7 @@ ALL_64_EMULATION_SOURCES = \
 	eelf32ltsmipn32_fbsd.c \
 	eelf32mipswindiss.c \
 	eelf64_aix.c \
+	eelf64_bpf.c \
 	eelf64_ia64.c \
 	eelf64_ia64_fbsd.c \
 	eelf64_ia64_vms.c \
@@ -1292,6 +1293,7 @@ distclean-compile:
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/eelf32xstormy16.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/eelf32xtensa.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/eelf64_aix.Po@am__quote@
+@AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/eelf64_bpf.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/eelf64_ia64.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/eelf64_ia64_fbsd.Po@am__quote@
 @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/eelf64_ia64_vms.Po@am__quote@
@@ -3484,6 +3486,9 @@ eelf32_x86_64_nacl.c: $(srcdir)/emulparams/elf32_x86_64_nacl.sh \
 eelf64_aix.c: $(srcdir)/emulparams/elf64_aix.sh \
   $(ELF_DEPS) $(srcdir)/scripttempl/elf.sc ${GEN_DEPENDS}
 
+eelf64_bpf.c: $(srcdir)/emulparams/elf64_bpf.sh \
+  $(ELF_DEPS) $(srcdir)/scripttempl/elf.sc ${GEN_DEPENDS}
+
 eelf64_ia64.c: $(srcdir)/emulparams/elf64_ia64.sh \
   $(ELF_DEPS) $(srcdir)/emultempl/ia64elf.em \
   $(srcdir)/emultempl/needrelax.em \
diff --git a/ld/configure.tgt b/ld/configure.tgt
index 895f0fb..13645f5 100644
--- a/ld/configure.tgt
+++ b/ld/configure.tgt
@@ -177,6 +177,8 @@ bfin-*-linux-uclibc*)	targ_emul=elf32bfinfd;
 			targ_extra_emuls="elf32bfin"
 			targ_extra_libpath=$targ_extra_emuls
 			;;
+bpf-*-elf)		targ_emul=elf64_bpf
+			;;
 cr16-*-elf*)            targ_emul=elf32cr16 ;;
 cr16c-*-elf*)           targ_emul=elf32cr16c
 			;;
diff --git a/ld/emulparams/elf64_bpf.sh b/ld/emulparams/elf64_bpf.sh
new file mode 100644
index 0000000..0e1e549
--- /dev/null
+++ b/ld/emulparams/elf64_bpf.sh
@@ -0,0 +1,8 @@
+# See genscripts.sh and ../scripttempl/elf.sc for the meaning of these.
+SCRIPT_NAME=elf
+ELFSIZE=64
+TEMPLATE_NAME=elf32
+OUTPUT_FORMAT="elf64-bpf"
+TARGET_PAGE_SIZE=0x1000
+ARCH=bpf
+MACHINE=
diff --git a/opcodes/Makefile.am b/opcodes/Makefile.am
index 1ac6bb1..ccc9453 100644
--- a/opcodes/Makefile.am
+++ b/opcodes/Makefile.am
@@ -105,6 +105,8 @@ TARGET_LIBOPCODES_CFILES = \
 	arm-dis.c \
 	avr-dis.c \
 	bfin-dis.c \
+	bpf-dis.c \
+	bpf-opc.c \
 	cgen-asm.c \
 	cgen-bitset.c \
 	cgen-dis.c \
diff --git a/opcodes/bpf-dis.c b/opcodes/bpf-dis.c
new file mode 100644
index 0000000..2a0b7da
--- /dev/null
+++ b/opcodes/bpf-dis.c
@@ -0,0 +1,152 @@
+#include "sysdep.h"
+#include <stdio.h>
+#include "opcode/bpf.h"
+#include "dis-asm.h"
+#include "libiberty.h"
+
+#define HASH_SIZE 256
+#define HASH_INSN(CODE)	(CODE)
+
+typedef struct bpf_opcode_hash
+{
+  struct bpf_opcode_hash *next;
+  const bpf_opcode *opcode;
+} bpf_opcode_hash;
+
+static bpf_opcode_hash *opcode_hash_table[HASH_SIZE];
+
+static void
+build_hash_table (const bpf_opcode *opcode_table,
+		  bpf_opcode_hash **hash_table,
+		  int num_opcodes)
+{
+  static bpf_opcode_hash *hash_buf = NULL;
+  int i;
+
+  memset (hash_table, 0, HASH_SIZE * sizeof (hash_table[0]));
+  if (hash_buf != NULL)
+    free (hash_buf);
+  hash_buf = xmalloc (sizeof (* hash_buf) * num_opcodes);
+  for (i = num_opcodes - 1; i >= 0; --i)
+    {
+      int hash = HASH_INSN (opcode_table[i].code);
+      bpf_opcode_hash *h = &hash_buf[i];
+
+      h->next = hash_table[hash];
+      h->opcode = &opcode_table[i];
+      hash_table[hash] = h;
+    }
+}
+
+int
+print_insn_bpf (bfd_vma memaddr, disassemble_info *info)
+{
+  static unsigned long current_mach = 0;
+  static int opcodes_initialized = 0;
+  bfd_vma (*getword) (const void *);
+  bfd_vma (*gethalf) (const void *);
+  FILE *stream = info->stream;
+  bpf_opcode_hash *op;
+  int code, dest, src;
+  bfd_byte buffer[8];
+  unsigned short off;
+  int status, ret;
+  signed int imm;
+
+  if (!opcodes_initialized
+      || info->mach != current_mach)
+    {
+      build_hash_table (bpf_opcodes, opcode_hash_table, bpf_num_opcodes);
+      current_mach = info->mach;
+      opcodes_initialized = 1;
+    }
+
+  info->bytes_per_line = 8;
+
+  status = (*info->read_memory_func) (memaddr, buffer, sizeof (buffer), info);
+  if (status != 0)
+    {
+      (*info->memory_error_func) (status, memaddr, info);
+      return -1;
+    }
+
+  if (info->endian == BFD_ENDIAN_BIG)
+    {
+      getword = bfd_getb32;
+      gethalf = bfd_getb16;
+    }
+  else
+    {
+      getword = bfd_getl32;
+      gethalf = bfd_getl32;
+    }  
+
+  code = buffer[0];
+  dest = (buffer[1] & 0xf0) >> 4;
+  src = buffer[1] & 0x0f;
+  off = gethalf(&buffer[2]);
+  imm = getword(&buffer[4]);
+
+  ret = sizeof (buffer);
+  for (op = opcode_hash_table[HASH_INSN (code)]; op; op = op->next)
+    {
+      const bpf_opcode *opcode = op->opcode;
+      BFD_HOST_U_64_BIT value;
+      signed int imm2;
+      const char *s;
+
+      if (opcode->code != code)
+	continue;
+
+      (*info->fprintf_func) (stream, "%s\t", opcode->name);
+      for (s = opcode->args; *s != '\0'; s++)
+	{
+	  switch (*s)
+	    {
+	    case '+':
+	    default:
+	      (*info->fprintf_func) (stream, "%c", *s);
+	      break;
+	    case ',':
+	      (*info->fprintf_func) (stream, ", ");
+	      break;
+	    case '1':
+	      (*info->fprintf_func) (stream, "r%d", dest);
+	      break;
+	    case '2':
+	      (*info->fprintf_func) (stream, "r%d", src);
+	      break;
+	    case 'i':
+	      (*info->fprintf_func) (stream, "%d", imm);
+	      break;
+	    case 'O':
+	      (*info->fprintf_func) (stream, "%d", off);
+	      break;
+	    case 'L':
+	      info->target = memaddr + ((off - 1) * 8);
+	      (*info->print_address_func) (info->target, info);
+	      break;
+	    case 'C':
+	      info->target = imm;
+	      (*info->print_address_func) (info->target, info);
+	      break;
+	    case 'D':
+	      status = (*info->read_memory_func) (memaddr + 8, buffer,
+						  sizeof (buffer), info);
+	      if (status != 0)
+		{
+		  (*info->memory_error_func) (status, memaddr, info);
+		  return -1;
+		}
+	      ret += sizeof (buffer);
+	      imm2 = getword(&buffer[4]);
+	      value = ((BFD_HOST_U_64_BIT) (unsigned) imm2) << 32;
+	      value |= (BFD_HOST_U_64_BIT) (unsigned) imm;
+	      (*info->fprintf_func) (stream, "%lld", (long long) value);
+	      break;
+	    }
+	}
+    }
+
+  return ret;
+}
diff --git a/opcodes/bpf-opc.c b/opcodes/bpf-opc.c
new file mode 100644
index 0000000..bca8e47
--- /dev/null
+++ b/opcodes/bpf-opc.c
@@ -0,0 +1,147 @@
+#include "sysdep.h"
+#include <stdio.h>
+#include "opcode/bpf.h"
+
+#define BPF_OPC_ALU64	0x07
+#define BPF_OPC_DW	0x18
+#define BPF_OPC_XADD	0xc0
+#define BPF_OPC_MOV	0xb0
+#define BPF_OPC_ARSH	0xc0
+#define BPF_OPC_END	0xd0
+#define BPF_OPC_TO_LE	0x00
+#define BPF_OPC_TO_BE	0x08
+#define BPF_OPC_JNE	0x50
+#define BPF_OPC_JSGT	0x60
+#define BPF_OPC_JSGE	0x70
+#define BPF_OPC_CALL	0x80
+#define BPF_OPC_EXIT	0x90
+
+#define BPF_OPC_LD	0x00
+#define BPF_OPC_LDX	0x01
+#define BPF_OPC_ST	0x02
+#define BPF_OPC_STX	0x03
+#define BPF_OPC_ALU	0x04
+#define BPF_OPC_JMP	0x05
+#define BPF_OPC_RET	0x06
+#define BPF_OPC_MISC	0x07
+
+#define BPF_OPC_W	0x00
+#define BPF_OPC_H	0x08
+#define BPF_OPC_B	0x10
+
+#define BPF_OPC_IMM	0x00
+#define BPF_OPC_ABS	0x20
+#define BPF_OPC_IND	0x40
+#define BPF_OPC_MEM	0x60
+#define BPF_OPC_LEL	0x80
+#define BPF_OPC_MSH	0xa0
+
+#define BPF_OPC_ADD	0x00
+#define BPF_OPC_SUB	0x10
+#define BPF_OPC_MUL	0x20
+#define BPF_OPC_DIV	0x30
+#define BPF_OPC_OR	0x40
+#define BPF_OPC_AND	0x50
+#define BPF_OPC_LSH	0x60
+#define BPF_OPC_RSH	0x70
+#define BPF_OPC_NEG	0x80
+#define BPF_OPC_MOD	0x90
+#define BPF_OPC_XOR	0xa0
+
+#define BPF_OPC_JA	0x00
+#define BPF_OPC_JEQ	0x10
+#define BPF_OPC_JGT	0x20
+#define BPF_OPC_JGE	0x30
+#define BPF_OPC_JSET	0x40
+
+#define BPF_OPC_K	0x00
+#define BPF_OPC_X	0x08
+
+const struct bpf_opcode bpf_opcodes[] = {
+  { "mov32",   BPF_OPC_ALU   | BPF_OPC_MOV  | BPF_OPC_X,     "1,2" },
+  { "mov32",   BPF_OPC_ALU   | BPF_OPC_MOV  | BPF_OPC_K,     "1,i" },
+  { "mov",     BPF_OPC_ALU64 | BPF_OPC_MOV  | BPF_OPC_X,     "1,2" },
+  { "mov",     BPF_OPC_ALU64 | BPF_OPC_MOV  | BPF_OPC_K,     "1,i" },
+  { "add32",   BPF_OPC_ALU   | BPF_OPC_ADD  | BPF_OPC_X,     "1,2" },
+  { "add32",   BPF_OPC_ALU   | BPF_OPC_ADD  | BPF_OPC_K,     "1,i" },
+  { "add",     BPF_OPC_ALU64 | BPF_OPC_ADD  | BPF_OPC_X,     "1,2" },
+  { "add",     BPF_OPC_ALU64 | BPF_OPC_ADD  | BPF_OPC_K,     "1,i" },
+  { "sub32",   BPF_OPC_ALU   | BPF_OPC_SUB  | BPF_OPC_X,     "1,2" },
+  { "sub32",   BPF_OPC_ALU   | BPF_OPC_SUB  | BPF_OPC_K,     "1,i" },
+  { "sub",     BPF_OPC_ALU64 | BPF_OPC_SUB  | BPF_OPC_X,     "1,2" },
+  { "sub",     BPF_OPC_ALU64 | BPF_OPC_SUB  | BPF_OPC_K,     "1,i" },
+  { "and32",   BPF_OPC_ALU   | BPF_OPC_AND  | BPF_OPC_X,     "1,2" },
+  { "and32",   BPF_OPC_ALU   | BPF_OPC_AND  | BPF_OPC_K,     "1,i" },
+  { "and",     BPF_OPC_ALU64 | BPF_OPC_AND  | BPF_OPC_X,     "1,2" },
+  { "and",     BPF_OPC_ALU64 | BPF_OPC_AND  | BPF_OPC_K,     "1,i" },
+  { "or32",    BPF_OPC_ALU   | BPF_OPC_OR   | BPF_OPC_X,     "1,2" },
+  { "or32",    BPF_OPC_ALU   | BPF_OPC_XOR  | BPF_OPC_K,     "1,i" },
+  { "or",      BPF_OPC_ALU64 | BPF_OPC_OR   | BPF_OPC_X,     "1,2" },
+  { "or",      BPF_OPC_ALU64 | BPF_OPC_XOR  | BPF_OPC_K,     "1,i" },
+  { "xor32",   BPF_OPC_ALU   | BPF_OPC_XOR  | BPF_OPC_X,     "1,2" },
+  { "xor32",   BPF_OPC_ALU   | BPF_OPC_OR   | BPF_OPC_K,     "1,i" },
+  { "xor",     BPF_OPC_ALU64 | BPF_OPC_XOR  | BPF_OPC_X,     "1,2" },
+  { "xor",     BPF_OPC_ALU64 | BPF_OPC_OR   | BPF_OPC_K,     "1,i" },
+  { "mul32",   BPF_OPC_ALU   | BPF_OPC_MUL  | BPF_OPC_X,     "1,2" },
+  { "mul32",   BPF_OPC_ALU   | BPF_OPC_MUL  | BPF_OPC_K,     "1,i" },
+  { "mul",     BPF_OPC_ALU64 | BPF_OPC_MUL  | BPF_OPC_X,     "1,2" },
+  { "mul",     BPF_OPC_ALU64 | BPF_OPC_MUL  | BPF_OPC_K,     "1,i" },
+  { "div32",   BPF_OPC_ALU   | BPF_OPC_DIV  | BPF_OPC_X,     "1,2" },
+  { "div32",   BPF_OPC_ALU   | BPF_OPC_DIV  | BPF_OPC_K,     "1,i" },
+  { "div",     BPF_OPC_ALU64 | BPF_OPC_DIV  | BPF_OPC_X,     "1,2" },
+  { "div",     BPF_OPC_ALU64 | BPF_OPC_DIV  | BPF_OPC_K,     "1,i" },
+  { "mod32",   BPF_OPC_ALU   | BPF_OPC_MOD  | BPF_OPC_X,     "1,2" },
+  { "mod32",   BPF_OPC_ALU   | BPF_OPC_MOD  | BPF_OPC_K,     "1,i" },
+  { "mod",     BPF_OPC_ALU64 | BPF_OPC_MOD  | BPF_OPC_X,     "1,2" },
+  { "mod",     BPF_OPC_ALU64 | BPF_OPC_MOD  | BPF_OPC_K,     "1,i" },
+  { "lsh32",   BPF_OPC_ALU   | BPF_OPC_LSH  | BPF_OPC_X,     "1,2" },
+  { "lsh32",   BPF_OPC_ALU   | BPF_OPC_LSH  | BPF_OPC_K,     "1,i" },
+  { "lsh",     BPF_OPC_ALU64 | BPF_OPC_LSH  | BPF_OPC_X,     "1,2" },
+  { "lsh",     BPF_OPC_ALU64 | BPF_OPC_LSH  | BPF_OPC_K,     "1,i" },
+  { "rsh32",   BPF_OPC_ALU   | BPF_OPC_RSH  | BPF_OPC_X,     "1,2" },
+  { "rsh32",   BPF_OPC_ALU   | BPF_OPC_RSH  | BPF_OPC_K,     "1,i" },
+  { "rsh",     BPF_OPC_ALU64 | BPF_OPC_RSH  | BPF_OPC_X,     "1,2" },
+  { "rsh",     BPF_OPC_ALU64 | BPF_OPC_RSH  | BPF_OPC_K,     "1,i" },
+  { "arsh32",  BPF_OPC_ALU   | BPF_OPC_ARSH | BPF_OPC_X,     "1,2" },
+  { "arsh32",  BPF_OPC_ALU   | BPF_OPC_ARSH | BPF_OPC_K,     "1,i" },
+  { "arsh",    BPF_OPC_ALU64 | BPF_OPC_ARSH | BPF_OPC_X,     "1,2" },
+  { "arsh",    BPF_OPC_ALU64 | BPF_OPC_ARSH | BPF_OPC_K,     "1,i" },
+  { "neg32",   BPF_OPC_ALU   | BPF_OPC_NEG  | BPF_OPC_X,     "1" },
+  { "neg",     BPF_OPC_ALU64 | BPF_OPC_NEG  | BPF_OPC_X,     "1" },
+  { "endbe",   BPF_OPC_ALU   | BPF_OPC_END  | BPF_OPC_TO_BE, "1,i" },
+  { "endle",   BPF_OPC_ALU   | BPF_OPC_END  | BPF_OPC_TO_LE, "1,i" },
+  { "ja",      BPF_OPC_JMP   | BPF_OPC_JA,                   "L" },
+  { "jeq",     BPF_OPC_JMP   | BPF_OPC_JEQ  | BPF_OPC_X,     "1,2,L" },
+  { "jeq",     BPF_OPC_JMP   | BPF_OPC_JEQ  | BPF_OPC_K,     "1,i,L" },
+  { "jgt",     BPF_OPC_JMP   | BPF_OPC_JGT  | BPF_OPC_X,     "1,2,L" },
+  { "jgt",     BPF_OPC_JMP   | BPF_OPC_JGT  | BPF_OPC_K,     "1,i,L" },
+  { "jge",     BPF_OPC_JMP   | BPF_OPC_JGE  | BPF_OPC_X,     "1,2,L" },
+  { "jge",     BPF_OPC_JMP   | BPF_OPC_JGE  | BPF_OPC_K,     "1,i,L" },
+  { "jne",     BPF_OPC_JMP   | BPF_OPC_JNE  | BPF_OPC_X,     "1,2,L" },
+  { "jne",     BPF_OPC_JMP   | BPF_OPC_JNE  | BPF_OPC_K,     "1,i,L" },
+  { "jsgt",    BPF_OPC_JMP   | BPF_OPC_JSGT | BPF_OPC_X,     "1,2,L" },
+  { "jsgt",    BPF_OPC_JMP   | BPF_OPC_JSGT | BPF_OPC_K,     "1,i,L" },
+  { "jsge",    BPF_OPC_JMP   | BPF_OPC_JSGE | BPF_OPC_X,     "1,2,L" },
+  { "jsge",    BPF_OPC_JMP   | BPF_OPC_JSGE | BPF_OPC_K,     "1,i,L" },
+  { "jset",    BPF_OPC_JMP   | BPF_OPC_JSET | BPF_OPC_X,     "1,2,L" },
+  { "jset",    BPF_OPC_JMP   | BPF_OPC_JSET | BPF_OPC_K,     "1,i,L" },
+  { "call",    BPF_OPC_JMP   | BPF_OPC_CALL,                 "C" },
+  { "tailcall",BPF_OPC_JMP   | BPF_OPC_CALL | BPF_OPC_X,     "C" },
+  { "exit",    BPF_OPC_JMP   | BPF_OPC_EXIT,                 "" },
+  { "ldimm64", BPF_OPC_LD    | BPF_OPC_IMM  | BPF_OPC_DW,    "1,D" },
+  { "ldw",     BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_W,     "1,[2+O]" },
+  { "ldh",     BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_H,     "1,[2+O]" },
+  { "ldb",     BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_B,     "1,[2+O]" },
+  { "lddw",    BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_DW,    "1,[2+O]" },
+  { "stw",     BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_W,     "[1+O],2" },
+  { "stw",     BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_W,     "[1+O],i" },
+  { "sth",     BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_H,     "[1+O],2" },
+  { "sth",     BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_H,     "[1+O],i" },
+  { "stb",     BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_B,     "[1+O],2" },
+  { "stb",     BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_B,     "[1+O],i" },
+  { "stdw",    BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_DW,    "[1+O],2" },
+  { "stdw",    BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_DW,    "[1+O],i" },
+  { "xaddw",   BPF_OPC_STX   | BPF_OPC_XADD | BPF_OPC_W,     "[1+O],2" },
+  { "xadddw",  BPF_OPC_STX   | BPF_OPC_XADD | BPF_OPC_DW,    "[1+O],2" },
+};
+const int bpf_num_opcodes = ((sizeof bpf_opcodes)/(sizeof bpf_opcodes[0]));
diff --git a/opcodes/configure b/opcodes/configure
index 27d1472..7583220 100755
--- a/opcodes/configure
+++ b/opcodes/configure
@@ -12634,6 +12634,7 @@ if test x${all_targets} = xfalse ; then
 	bfd_arm_arch)		ta="$ta arm-dis.lo" ;;
 	bfd_avr_arch)		ta="$ta avr-dis.lo" ;;
 	bfd_bfin_arch)		ta="$ta bfin-dis.lo" ;;
+	bfd_bpf_arch)		ta="$ta bpf-dis.lo bpf-opc.lo" ;;
 	bfd_cr16_arch)		ta="$ta cr16-dis.lo cr16-opc.lo" ;;
 	bfd_cris_arch)		ta="$ta cris-dis.lo cris-opc.lo cgen-bitset.lo" ;;
 	bfd_crx_arch)		ta="$ta crx-dis.lo crx-opc.lo" ;;
diff --git a/opcodes/configure.ac b/opcodes/configure.ac
index a9fbfd6..7dc6a92 100644
--- a/opcodes/configure.ac
+++ b/opcodes/configure.ac
@@ -258,6 +258,7 @@ if test x${all_targets} = xfalse ; then
 	bfd_arm_arch)		ta="$ta arm-dis.lo" ;;
 	bfd_avr_arch)		ta="$ta avr-dis.lo" ;;
 	bfd_bfin_arch)		ta="$ta bfin-dis.lo" ;;
+	bfd_bpf_arch)		ta="$ta bpf-dis.lo bpf-opc.lo" ;;
 	bfd_cr16_arch)		ta="$ta cr16-dis.lo cr16-opc.lo" ;;
 	bfd_cris_arch)		ta="$ta cris-dis.lo cris-opc.lo cgen-bitset.lo" ;;
 	bfd_crx_arch)		ta="$ta crx-dis.lo crx-opc.lo" ;;
diff --git a/opcodes/disassemble.c b/opcodes/disassemble.c
index dd7d3a3..e594f86 100644
--- a/opcodes/disassemble.c
+++ b/opcodes/disassemble.c
@@ -29,6 +29,7 @@
 #define ARCH_arm
 #define ARCH_avr
 #define ARCH_bfin
+#define ARCH_bpf
 #define ARCH_cr16
 #define ARCH_cris
 #define ARCH_crx
@@ -151,6 +152,11 @@ disassembler (bfd *abfd)
       disassemble = print_insn_bfin;
       break;
 #endif
+#ifdef ARCH_bpf
+    case bfd_arch_bpf:
+      disassemble = print_insn_bpf;
+      break;
+#endif
 #ifdef ARCH_cr16
     case bfd_arch_cr16:
       disassemble = print_insn_cr16;
-- 
2.7.4
