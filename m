From: David Miller <davem@davemloft.net>
Subject: [PATCH v3 binutils] Add BPF support to binutils...
Date: Fri, 28 Apr 2017 16:33:55 -0400 (EDT)
Message-ID: <20170428.163355.2067951664875385680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59124 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035625AbdD1Ud6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 16:33:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


New in this version:

1) All the relocation work I posted earlier today.
2) Teach readelf about a few bpf relocs as needed
3) Add a 'nop' instruction which facilitates the gas
   testsuite.  I used "mov r0,r0"

The whole gas testsuite passes now. :-)  But that just
means we have to add more tests I guess....

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 bfd/Makefile.am                 |   2 +
 bfd/Makefile.in                 |   3 +
 bfd/archures.c                  |   3 +
 bfd/bfd-in2.h                   |   8 +
 bfd/config.bfd                  |   6 +
 bfd/configure                   |   2 +
 bfd/configure.ac                |   2 +
 bfd/cpu-bpf.c                   |  41 +++
 bfd/elf64-bpf.c                 | 156 ++++++++++
 bfd/elf64-bpf.h                 |  24 ++
 bfd/libbfd.h                    |   4 +
 bfd/reloc.c                     |  11 +
 bfd/targets.c                   |   5 +
 binutils/readelf.c              |   5 +
 config.sub                      |   5 +-
 gas/Makefile.am                 |   2 +
 gas/Makefile.in                 |  17 ++
 gas/config/tc-bpf.c             | 628 ++++++++++++++++++++++++++++++++++++++++
 gas/config/tc-bpf.h             |  45 +++
 gas/configure.tgt               |   3 +
 gas/testsuite/gas/bpf/arith.d   |  61 ++++
 gas/testsuite/gas/bpf/arith.s   |  53 ++++
 gas/testsuite/gas/bpf/atomics.d |  12 +
 gas/testsuite/gas/bpf/atomics.s |   4 +
 gas/testsuite/gas/bpf/bpf.exp   |  28 ++
 gas/testsuite/gas/bpf/call.d    |  18 ++
 gas/testsuite/gas/bpf/call.s    |  10 +
 gas/testsuite/gas/bpf/imm64.d   |  30 ++
 gas/testsuite/gas/bpf/imm64.s   |  12 +
 gas/testsuite/gas/bpf/jump.d    |  43 +++
 gas/testsuite/gas/bpf/jump.s    |  35 +++
 gas/testsuite/gas/bpf/loads.d   |  23 ++
 gas/testsuite/gas/bpf/loads.s   |  15 +
 gas/testsuite/gas/bpf/move.d    |  19 ++
 gas/testsuite/gas/bpf/move.s    |  11 +
 gas/testsuite/gas/bpf/stores.d  |  17 ++
 gas/testsuite/gas/bpf/stores.s  |   9 +
 gdb/bpf-tdep.c                  | 229 +++++++++++++++
 gdb/bpf-tdep.h                  |  40 +++
 gdb/configure.tgt               |   4 +
 include/dis-asm.h               |   1 +
 include/elf/bpf.h               |  39 +++
 include/opcode/bpf.h            |  16 +
 ld/Makefile.am                  |   4 +
 ld/Makefile.in                  |   5 +
 ld/configure.tgt                |   2 +
 ld/emulparams/elf64_bpf.sh      |   8 +
 opcodes/Makefile.am             |   2 +
 opcodes/bpf-dis.c               | 161 ++++++++++
 opcodes/bpf-opc.c               | 148 ++++++++++
 opcodes/configure               |   1 +
 opcodes/configure.ac            |   1 +
 opcodes/disassemble.c           |   6 +
 sim/configure.tgt               |   3 +
 54 files changed, 2040 insertions(+), 2 deletions(-)
 create mode 100644 bfd/cpu-bpf.c
 create mode 100644 bfd/elf64-bpf.c
 create mode 100644 bfd/elf64-bpf.h
 create mode 100644 gas/config/tc-bpf.c
 create mode 100644 gas/config/tc-bpf.h
 create mode 100644 gas/testsuite/gas/bpf/arith.d
 create mode 100644 gas/testsuite/gas/bpf/arith.s
 create mode 100644 gas/testsuite/gas/bpf/atomics.d
 create mode 100644 gas/testsuite/gas/bpf/atomics.s
 create mode 100644 gas/testsuite/gas/bpf/bpf.exp
 create mode 100644 gas/testsuite/gas/bpf/call.d
 create mode 100644 gas/testsuite/gas/bpf/call.s
 create mode 100644 gas/testsuite/gas/bpf/imm64.d
 create mode 100644 gas/testsuite/gas/bpf/imm64.s
 create mode 100644 gas/testsuite/gas/bpf/jump.d
 create mode 100644 gas/testsuite/gas/bpf/jump.s
 create mode 100644 gas/testsuite/gas/bpf/loads.d
 create mode 100644 gas/testsuite/gas/bpf/loads.s
 create mode 100644 gas/testsuite/gas/bpf/move.d
 create mode 100644 gas/testsuite/gas/bpf/move.s
 create mode 100644 gas/testsuite/gas/bpf/stores.d
 create mode 100644 gas/testsuite/gas/bpf/stores.s
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
index 17a35c0..6d44534 100644
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
@@ -3910,6 +3912,12 @@ pc-relative or some form of GOT-indirect relocation.  */
 /* ADI Blackfin arithmetic relocation.  */
   BFD_ARELOC_BFIN_ADDR,
 
+/* BPF relocations  */
+  BFD_RELOC_BPF_16,
+  BFD_RELOC_BPF_32,
+  BFD_RELOC_BPF_64,
+  BFD_RELOC_BPF_WDISP16,
+
 /* Mitsubishi D10V relocs.
 This is a 10-bit reloc with the right 2 bits
 assumed to be 0.  */
diff --git a/bfd/config.bfd b/bfd/config.bfd
index 151de95..f6d90cd 100644
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
@@ -471,6 +472,11 @@ case "${targ}" in
     targ_underscore=yes
     ;;
 
+  bpf-*-*)
+    targ_defvec=bpf_elf64_be_vec
+    targ_selvecs=bpf_elf64_le_vec
+    ;;
+
   c30-*-*aout* | tic30-*-*aout*)
     targ_defvec=tic30_aout_vec
     ;;
diff --git a/bfd/configure b/bfd/configure
index 24e3e2f..2a5ba40 100755
--- a/bfd/configure
+++ b/bfd/configure
@@ -14298,6 +14298,8 @@ do
     avr_elf32_vec)		 tb="$tb elf32-avr.lo elf32.lo $elf" ;;
     bfin_elf32_vec)		 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
     bfin_elf32_fdpic_vec)	 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
+    bpf_elf64_le_vec)		 tb="$tb elf64-bpf.lo elf64.lo $elf" ;;
+    bpf_elf64_be_vec)		 tb="$tb elf64-bpf.lo elf64.lo $elf" ;;
     bout_be_vec)		 tb="$tb bout.lo aout32.lo" ;;
     bout_le_vec)		 tb="$tb bout.lo aout32.lo" ;;
     cr16_elf32_vec)		 tb="$tb elf32-cr16.lo elf32.lo $elf" ;;
diff --git a/bfd/configure.ac b/bfd/configure.ac
index e568847..0dd7139 100644
--- a/bfd/configure.ac
+++ b/bfd/configure.ac
@@ -429,6 +429,8 @@ do
     avr_elf32_vec)		 tb="$tb elf32-avr.lo elf32.lo $elf" ;;
     bfin_elf32_vec)		 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
     bfin_elf32_fdpic_vec)	 tb="$tb elf32-bfin.lo elf32.lo $elf" ;;
+    bpf_elf64_le_vec)		 tb="$tb elf64-bpf.lo elf64.lo $elf" ;;
+    bpf_elf64_be_vec)		 tb="$tb elf64-bpf.lo elf64.lo $elf" ;;
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
index 0000000..1be285d
--- /dev/null
+++ b/bfd/elf64-bpf.c
@@ -0,0 +1,156 @@
+#include "sysdep.h"
+#include "bfd.h"
+#include "bfdlink.h"
+#include "libbfd.h"
+#include "libiberty.h"
+#include "elf-bfd.h"
+#include "elf/bpf.h"
+#include "opcode/bpf.h"
+#include "objalloc.h"
+#include "elf64-bpf.h"
+
+/* In case we're on a 32-bit machine, construct a 64-bit "-1" value.  */
+#define MINUS_ONE (~ (bfd_vma) 0)
+
+static reloc_howto_type _bfd_bpf_elf_howto_table[] =
+{
+  HOWTO(R_BPF_NONE,      0,3, 0,FALSE,0,complain_overflow_dont,    bfd_elf_generic_reloc,  "R_BPF_NONE",    FALSE,0,0x00000000,TRUE),
+
+  /* XXX these are wrong XXX */
+  HOWTO(R_BPF_INSN_16,   0,1,16,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_INSN_16", FALSE,0,0x0000ffff,TRUE),
+  HOWTO(R_BPF_INSN_32,   0,2,32,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_INSN_32", FALSE,0,0xffffffff,TRUE),
+  HOWTO(R_BPF_INSN_64,   0,4,64,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_INSN_64", FALSE,0,MINUS_ONE,TRUE),
+  HOWTO(R_BPF_WDISP16,   0,1,16,TRUE, 0,complain_overflow_signed,  bfd_elf_generic_reloc,  "R_BPF_WDISP16", FALSE,0,0x0000ffff,TRUE),
+
+  HOWTO(R_BPF_DATA_8,    0,0, 8,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_8",  FALSE,0,0x000000ff,TRUE),
+  HOWTO(R_BPF_DATA_16,   0,1,16,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_16", FALSE,0,0x0000ffff,TRUE),
+  HOWTO(R_BPF_DATA_32,   0,2,32,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_32", FALSE,0,0xffffffff,TRUE),
+  HOWTO(R_BPF_DATA_64,   0,4,64,FALSE,0,complain_overflow_bitfield,bfd_elf_generic_reloc,  "R_BPF_DATA_64", FALSE,0,MINUS_ONE,TRUE),
+};
+
+reloc_howto_type *
+_bfd_bpf_elf_reloc_type_lookup (bfd *abfd ATTRIBUTE_UNUSED,
+				bfd_reloc_code_real_type code)
+{
+  switch (code)
+    {
+    case BFD_RELOC_NONE:
+      return &_bfd_bpf_elf_howto_table[R_BPF_NONE];
+     
+    case BFD_RELOC_BPF_WDISP16:
+      return &_bfd_bpf_elf_howto_table[R_BPF_WDISP16];
+
+    case BFD_RELOC_BPF_16:
+      return &_bfd_bpf_elf_howto_table[R_BPF_INSN_16];
+
+    case BFD_RELOC_BPF_32:
+      return &_bfd_bpf_elf_howto_table[R_BPF_INSN_32];
+
+    case BFD_RELOC_BPF_64:
+      return &_bfd_bpf_elf_howto_table[R_BPF_INSN_64];
+
+    case BFD_RELOC_8:
+      return &_bfd_bpf_elf_howto_table[R_BPF_DATA_8];
+
+    case BFD_RELOC_16:
+      return &_bfd_bpf_elf_howto_table[R_BPF_DATA_16];
+
+    case BFD_RELOC_32:
+      return &_bfd_bpf_elf_howto_table[R_BPF_DATA_32];
+
+    case BFD_RELOC_64:
+      return &_bfd_bpf_elf_howto_table[R_BPF_DATA_64];
+
+    default:
+      break;
+    }
+  bfd_set_error (bfd_error_bad_value);
+  return NULL;
+}
+
+reloc_howto_type *
+_bfd_bpf_elf_reloc_name_lookup (bfd *abfd ATTRIBUTE_UNUSED,
+				const char *r_name)
+{
+  unsigned int i;
+
+  for (i = 0;
+       i < (sizeof (_bfd_bpf_elf_howto_table)
+	    / sizeof (_bfd_bpf_elf_howto_table[0]));
+       i++)
+    if (_bfd_bpf_elf_howto_table[i].name != NULL
+	&& strcasecmp (_bfd_bpf_elf_howto_table[i].name, r_name) == 0)
+      return &_bfd_bpf_elf_howto_table[i];
+
+  return NULL;
+}
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
+static reloc_howto_type *
+elf_bpf_rtype_to_howto (unsigned int r_type)
+{
+  if (r_type >= (unsigned int) R_BPF_max)
+    {
+      _bfd_error_handler (_("invalid relocation type %d"), (int) r_type);
+      r_type = R_BPF_NONE;
+    }
+  return &_bfd_bpf_elf_howto_table[r_type];
+}
+
+/* Given a bpf ELF reloc type, fill in an arelent structure.  */
+
+static void
+elf_bpf_info_to_howto (bfd *abfd ATTRIBUTE_UNUSED, arelent *cache_ptr,
+		       Elf_Internal_Rela *dst)
+{
+  unsigned r_type;
+
+  r_type = ELF64_R_TYPE (dst->r_info);
+  cache_ptr->howto = elf_bpf_rtype_to_howto (r_type);
+  BFD_ASSERT (r_type == cache_ptr->howto->type);
+}
+
+#define TARGET_LITTLE_SYM	bpf_elf64_le_vec
+#define TARGET_LITTLE_NAME	"elf64-bpfle"
+#define TARGET_BIG_SYM		bpf_elf64_be_vec
+#define TARGET_BIG_NAME		"elf64-bpfbe"
+#define ELF_ARCH		bfd_arch_bpf
+#define ELF_MAXPAGESIZE		0x100000
+#define ELF_MACHINE_CODE	EM_BPF
+
+#define elf_info_to_howto		    elf_bpf_info_to_howto
+
+#define bfd_elf64_bfd_reloc_type_lookup _bfd_bpf_elf_reloc_type_lookup
+#define bfd_elf64_bfd_reloc_name_lookup _bfd_bpf_elf_reloc_name_lookup
+#define bfd_elf64_bfd_link_add_symbols	elf64_generic_link_add_symbols
+
+#include "elf64-target.h"
diff --git a/bfd/elf64-bpf.h b/bfd/elf64-bpf.h
new file mode 100644
index 0000000..f435e2e
--- /dev/null
+++ b/bfd/elf64-bpf.h
@@ -0,0 +1,24 @@
+/* BPF ELF specific backend routines.
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
+extern reloc_howto_type *_bfd_bpf_elf_reloc_type_lookup
+  (bfd *, bfd_reloc_code_real_type);
+extern reloc_howto_type *_bfd_bpf_elf_reloc_name_lookup
+  (bfd *, const char *);
diff --git a/bfd/libbfd.h b/bfd/libbfd.h
index 8bac650..1a3001d 100644
--- a/bfd/libbfd.h
+++ b/bfd/libbfd.h
@@ -1794,6 +1794,10 @@ static const char *const bfd_reloc_code_real_names[] = { "@@uninitialized@@",
   "BFD_ARELOC_BFIN_PAGE",
   "BFD_ARELOC_BFIN_HWPAGE",
   "BFD_ARELOC_BFIN_ADDR",
+  "BFD_RELOC_BPF_16",
+  "BFD_RELOC_BPF_32",
+  "BFD_RELOC_BPF_64",
+  "BFD_RELOC_BPF_WDISP16",
   "BFD_RELOC_D10V_10_PCREL_R",
   "BFD_RELOC_D10V_10_PCREL_L",
   "BFD_RELOC_D10V_18",
diff --git a/bfd/reloc.c b/bfd/reloc.c
index 9a04022..4100caf 100644
--- a/bfd/reloc.c
+++ b/bfd/reloc.c
@@ -3854,6 +3854,17 @@ ENUMDOC
   ADI Blackfin arithmetic relocation.
 
 ENUM
+  BFD_RELOC_BPF_16
+ENUMX
+  BFD_RELOC_BPF_32
+ENUMX
+  BFD_RELOC_BPF_64
+ENUMX
+  BFD_RELOC_BPF_WDISP16
+ENUMDOC
+  BPF relocations
+
+ENUM
   BFD_RELOC_D10V_10_PCREL_R
 ENUMDOC
   Mitsubishi D10V relocs.
diff --git a/bfd/targets.c b/bfd/targets.c
index 5841e8d..c38c4fb 100644
--- a/bfd/targets.c
+++ b/bfd/targets.c
@@ -619,6 +619,8 @@ extern const bfd_target arm_pei_wince_le_vec;
 extern const bfd_target avr_elf32_vec;
 extern const bfd_target bfin_elf32_vec;
 extern const bfd_target bfin_elf32_fdpic_vec;
+extern const bfd_target bpf_elf64_le_vec;
+extern const bfd_target bpf_elf64_be_vec;
 extern const bfd_target bout_be_vec;
 extern const bfd_target bout_le_vec;
 extern const bfd_target cr16_elf32_vec;
@@ -1029,6 +1031,9 @@ static const bfd_target * const _bfd_target_vector[] =
 	&bfin_elf32_vec,
 	&bfin_elf32_fdpic_vec,
 
+	&bpf_elf64_le_vec,
+	&bpf_elf64_be_vec,
+
 	&bout_be_vec,
 	&bout_le_vec,
 
diff --git a/binutils/readelf.c b/binutils/readelf.c
index b57e1e0..6c67d98 100644
--- a/binutils/readelf.c
+++ b/binutils/readelf.c
@@ -12006,6 +12006,8 @@ is_32bit_abs_reloc (unsigned int reloc_type)
       return reloc_type == 1;
     case EM_BLACKFIN:
       return reloc_type == 0x12; /* R_byte4_data.  */
+    case EM_BPF:
+      return reloc_type == 7; /* R_BPF_DATA_32 */
     case EM_CRIS:
       return reloc_type == 3; /* R_CRIS_32.  */
     case EM_CR16:
@@ -12245,6 +12247,8 @@ is_64bit_abs_reloc (unsigned int reloc_type)
       return reloc_type == 257;	/* R_AARCH64_ABS64.  */
     case EM_ALPHA:
       return reloc_type == 2; /* R_ALPHA_REFQUAD.  */
+    case EM_BPF:
+      return reloc_type == 8; /* R_BPF_DATA_64 */
     case EM_IA_64:
       return reloc_type == 0x27; /* R_IA64_DIR64LSB.  */
     case EM_PARISC:
@@ -12411,6 +12415,7 @@ is_none_reloc (unsigned int reloc_type)
     case EM_ARC_COMPACT2: /* R_ARC_NONE.  */
     case EM_ARC_COMPACT: /* R_ARC_NONE.  */
     case EM_ARM:     /* R_ARM_NONE.  */
+    case EM_BPF:     /* R_BPF_NONE.  */
     case EM_C166:    /* R_XC16X_NONE.  */
     case EM_CRIS:    /* R_CRIS_NONE.  */
     case EM_FT32:    /* R_FT32_NONE.  */
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
index 0000000..0ba2afa
--- /dev/null
+++ b/gas/config/tc-bpf.c
@@ -0,0 +1,628 @@
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
+const char *md_shortopts = "V";
+struct option md_longopts[] =
+{
+#define OPTION_LITTLE_ENDIAN (OPTION_MD_BASE + 8)
+  {"EL", no_argument, NULL, OPTION_LITTLE_ENDIAN},
+#define OPTION_BIG_ENDIAN (OPTION_MD_BASE + 9)
+  {"EB", no_argument, NULL, OPTION_BIG_ENDIAN},
+  { NULL, no_argument, NULL, 0 },
+};
+size_t md_longopts_size = sizeof (md_longopts);
+
+/* Whether or not, we've set target_big_endian.  */
+static int set_target_endian = 0;
+
+int
+md_parse_option (int c ATTRIBUTE_UNUSED, const char *arg ATTRIBUTE_UNUSED)
+{
+  switch (c)
+    {
+    case OPTION_LITTLE_ENDIAN:
+      target_big_endian = 0;
+      set_target_endian = 1;
+      break;
+    case OPTION_BIG_ENDIAN:
+      target_big_endian = 1;
+      set_target_endian = 1;
+      break;
+    case 'V':
+      print_version_id ();
+      break;
+    default:
+      return 0;
+    }
+  return 1;
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
+  if (!set_target_endian)
+    {
+      /* Default to host endianness. */
+#ifdef WORDS_BIGENDIAN
+      target_big_endian = 1;
+#else
+      target_big_endian = 0;
+#endif
+      set_target_endian = 1;
+    }
+}
+
+const char *
+bpf_target_format (void)
+{
+  return target_big_endian ? "elf64-bpfbe" : "elf64-bpfle";
+}
+
+struct bpf_it
+  {
+    const char *error;
+    valueT opcode;
+    valueT high64;
+    expressionS exp;
+    int pcrel;
+    int imm64;
+    bfd_reloc_code_real_type reloc;
+  };
+
+/* Subroutine of md_assemble to output one insn.  */
+
+static void
+output_insn (struct bpf_it *theinsn)
+{
+  valueT opc = theinsn->opcode;
+  char *toP = frag_more (theinsn->imm64 ? 16 : 8);
+  char code, regs;
+  
+  code = opc >> (64 - 8);
+  regs = opc >> (64 - (8 + 8));
+
+  toP[0] = code;
+  toP[1] = regs;
+
+  /* Put out the opcode.  */
+  if (target_big_endian)
+    {
+      number_to_chars_bigendian (toP + 2, opc >> 32, 2);
+      number_to_chars_bigendian (toP + 4, opc, 4);
+    }
+  else
+    {
+      number_to_chars_littleendian (toP + 2, opc >> 32, 2);
+      number_to_chars_littleendian (toP + 4, opc, 4);
+    }
+
+  if (theinsn->imm64)
+    {
+      toP[8] = 0;
+      toP[9] = 0;
+      toP[10] = 0;
+      toP[11] = 0;
+      if (target_big_endian)
+	{
+	  number_to_chars_bigendian (toP + 12, theinsn->high64, 4);
+	}
+      else
+	{
+	  number_to_chars_littleendian (toP + 12, theinsn->high64, 4);
+	}
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
+		  if (ISDIGIT (*s))
+		    {
+		      c = *s++;
+		      if (c != '0' || mask != 1)
+			goto error;
+		      mask = 10;
+		    }			  
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
+		  if (ISDIGIT (*s))
+		    {
+		      c = *s++;
+		      if (c != '0' || mask != 1)
+			goto error;
+		      mask = 10;
+		    }			  
+		  the_insn.opcode |= (mask << 48);
+		  continue;
+		}
+	      break;
+	    case 'i':
+	    case 'C':
+	      the_insn.reloc = BFD_RELOC_BPF_32;
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
+	      the_insn.reloc = BFD_RELOC_BPF_16;
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
+	    case 'D':
+	      the_insn.reloc = BFD_RELOC_BPF_64;
+	      the_insn.imm64 = 1;
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
+		  the_insn.opcode |= (val & 0xffffffff);
+		  the_insn.high64 = ((val >> 32) & 0xffffffff);
+		}
+	      continue;
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
+md_number_to_chars (char *buf, valueT val, int n)
+{
+  if (target_big_endian)
+    number_to_chars_bigendian (buf, val, n);
+  else
+    number_to_chars_littleendian (buf, val, n);
+}
+
+static void
+md_apply_u16 (offsetT val, char *buf)
+{
+  long off;
+
+  if (target_big_endian)
+    off = bfd_getb16 ((unsigned char *) buf + 2);
+  else
+    off = bfd_getl16 ((unsigned char *) buf + 2);
+  off |= val;
+  if (target_big_endian)
+    bfd_putb16 (off, (unsigned char *) buf + 2);
+  else
+    bfd_putl16 (off, (unsigned char *) buf + 2);
+}
+
+static void
+md_apply_u32 (offsetT val, char *buf)
+{
+  long imm;
+
+  if (target_big_endian)
+    imm = bfd_getb32 ((unsigned char *) buf + 4);
+  else
+    imm = bfd_getl32 ((unsigned char *) buf + 4);
+  imm |= val;
+  if (target_big_endian)
+    bfd_putb32 (imm, (unsigned char *) buf + 4);
+  else
+    bfd_putl32 (imm, (unsigned char *) buf + 4);
+}
+
+static void
+md_apply_u64 (offsetT val, char *buf)
+{
+  md_apply_u32(val & 0xffffffff, buf);
+  md_apply_u32((val >> 32) & 0xffffffff, buf + 12);
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
+      /* It's a relocation against an instruction.  */
+
+      switch (fixP->fx_r_type)
+	{
+	case BFD_RELOC_BPF_WDISP16:
+	  val = val  >> 3;
+	  md_apply_u16((val + 1) & 0xffff, buf);
+	  break;
+	case BFD_RELOC_BPF_16:
+	  md_apply_u16(val & 0xffff, buf);
+	  break;
+	case BFD_RELOC_BPF_32:
+	  md_apply_u32(val & 0xffffffff, buf);
+	  break;
+	case BFD_RELOC_BPF_64:
+	  md_apply_u64(val, buf);
+	  break;
+	case BFD_RELOC_NONE:
+	default:
+	  as_bad_where (fixP->fx_file, fixP->fx_line,
+			_("bad or unhandled relocation type: 0x%02x"),
+			fixP->fx_r_type);
+	  break;
+	}
+
+    }
+  if (fixP->fx_addsy == NULL)
+    fixP->fx_done = 1;
+}
+
+arelent *
+tc_gen_reloc (asection *section ATTRIBUTE_UNUSED, fixS *fixp ATTRIBUTE_UNUSED)
+{
+  bfd_reloc_code_real_type code;
+  arelent *reloc;
+
+  reloc = XNEW (arelent);
+  reloc->sym_ptr_ptr = XNEW (asymbol *);
+  *reloc->sym_ptr_ptr = symbol_get_bfdsym (fixp->fx_addsy);
+  reloc->address = fixp->fx_frag->fr_address + fixp->fx_where;
+
+  switch (fixp->fx_r_type)
+    {
+    case BFD_RELOC_BPF_WDISP16:
+    case BFD_RELOC_BPF_16:
+    case BFD_RELOC_BPF_32:
+    case BFD_RELOC_BPF_64:
+    case BFD_RELOC_8:
+    case BFD_RELOC_16:
+    case BFD_RELOC_32:
+    case BFD_RELOC_64:
+      code = fixp->fx_r_type;
+      break;
+    default:
+      abort ();
+      return NULL;
+    }
+
+  reloc->howto = bfd_reloc_type_lookup (stdoutput, code);
+  if (reloc->howto == 0)
+    {
+      as_bad_where (fixp->fx_file, fixp->fx_line,
+		    _("internal error: can't export reloc type %d (`%s')"),
+		    fixp->fx_r_type, bfd_get_reloc_code_name (code));
+      xfree (reloc);
+      return NULL;
+    }
+  if (code != BFD_RELOC_BPF_WDISP16)
+    reloc->addend = fixp->fx_addnumber;
+  else if (symbol_section_p (fixp->fx_addsy))
+    reloc->addend = (section->vma
+		     + fixp->fx_addnumber
+		     + md_pcrel_from (fixp));
+  else
+    reloc->addend = fixp->fx_offset;
+
+  return reloc;
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
index 0000000..45ab5d2
--- /dev/null
+++ b/gas/config/tc-bpf.h
@@ -0,0 +1,45 @@
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
+
+#ifdef WORDS_BIGENDIAN
+#define TARGET_BYTES_BIG_ENDIAN		1
+#else
+#define TARGET_BYTES_BIG_ENDIAN		0
+#endif
+
+#define TARGET_FORMAT (bpf_target_format ())
+extern const char *bpf_target_format (void);
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
diff --git a/gas/testsuite/gas/bpf/arith.d b/gas/testsuite/gas/bpf/arith.d
new file mode 100644
index 0000000..d63de38
--- /dev/null
+++ b/gas/testsuite/gas/bpf/arith.d
@@ -0,0 +1,61 @@
+#as: -EL
+#objdump: -dr
+#name: arith
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	0f 12 00 00 00 00 00 00 	add	r1, r2
+   8:	07 10 00 00 05 00 00 00 	add	r1, 5
+  10:	0c 12 00 00 00 00 00 00 	add32	r1, r2
+  18:	04 10 00 00 05 00 00 00 	add32	r1, 5
+  20:	1f 12 00 00 00 00 00 00 	sub	r1, r2
+  28:	17 10 00 00 05 00 00 00 	sub	r1, 5
+  30:	1c 12 00 00 00 00 00 00 	sub32	r1, r2
+  38:	14 10 00 00 05 00 00 00 	sub32	r1, 5
+  40:	5f 12 00 00 00 00 00 00 	and	r1, r2
+  48:	57 10 00 00 ff 00 00 00 	and	r1, 255
+  50:	5c 12 00 00 00 00 00 00 	and32	r1, r2
+  58:	54 10 00 00 ff 00 00 00 	and32	r1, 255
+  60:	4f 12 00 00 00 00 00 00 	or	r1, r2
+  68:	a7 10 00 00 80 00 00 00 	or	r1, 128
+  70:	4c 12 00 00 00 00 00 00 	or32	r1, r2
+  78:	a4 10 00 00 80 00 00 00 	or32	r1, 128
+  80:	af 12 00 00 00 00 00 00 	xor	r1, r2
+  88:	47 10 00 00 1f 00 00 00 	xor	r1, 31
+  90:	ac 12 00 00 00 00 00 00 	xor32	r1, r2
+  98:	44 10 00 00 1f 00 00 00 	xor32	r1, 31
+  a0:	2f 12 00 00 00 00 00 00 	mul	r1, r2
+  a8:	27 10 00 00 05 00 00 00 	mul	r1, 5
+  b0:	2c 12 00 00 00 00 00 00 	mul32	r1, r2
+  b8:	24 10 00 00 05 00 00 00 	mul32	r1, 5
+  c0:	3f 12 00 00 00 00 00 00 	div	r1, r2
+  c8:	37 10 00 00 02 00 00 00 	div	r1, 2
+  d0:	3c 12 00 00 00 00 00 00 	div32	r1, r2
+  d8:	34 10 00 00 02 00 00 00 	div32	r1, 2
+  e0:	9f 12 00 00 00 00 00 00 	mod	r1, r2
+  e8:	97 10 00 00 03 00 00 00 	mod	r1, 3
+  f0:	9c 12 00 00 00 00 00 00 	mod32	r1, r2
+  f8:	94 10 00 00 03 00 00 00 	mod32	r1, 3
+ 100:	6f 12 00 00 00 00 00 00 	lsh	r1, r2
+ 108:	67 10 00 00 01 00 00 00 	lsh	r1, 1
+ 110:	6c 12 00 00 00 00 00 00 	lsh32	r1, r2
+ 118:	64 10 00 00 01 00 00 00 	lsh32	r1, 1
+ 120:	7f 12 00 00 00 00 00 00 	rsh	r1, r2
+ 128:	77 10 00 00 01 00 00 00 	rsh	r1, 1
+ 130:	7c 12 00 00 00 00 00 00 	rsh32	r1, r2
+ 138:	74 10 00 00 01 00 00 00 	rsh32	r1, 1
+ 140:	cf 12 00 00 00 00 00 00 	arsh	r1, r2
+ 148:	c7 10 00 00 04 00 00 00 	arsh	r1, 4
+ 150:	cc 12 00 00 00 00 00 00 	arsh32	r1, r2
+ 158:	c4 10 00 00 04 00 00 00 	arsh32	r1, 4
+ 160:	8f 10 00 00 00 00 00 00 	neg	r1
+ 168:	8c 10 00 00 00 00 00 00 	neg32	r1
+ 170:	dc 10 00 00 10 00 00 00 	endbe	r1, 16
+ 178:	dc 10 00 00 20 00 00 00 	endbe	r1, 32
+ 180:	dc 10 00 00 40 00 00 00 	endbe	r1, 64
+ 188:	d4 10 00 00 10 00 00 00 	endle	r1, 16
+ 190:	d4 10 00 00 20 00 00 00 	endle	r1, 32
+ 198:	d4 10 00 00 40 00 00 00 	endle	r1, 64
diff --git a/gas/testsuite/gas/bpf/arith.s b/gas/testsuite/gas/bpf/arith.s
new file mode 100644
index 0000000..58bf2a5
--- /dev/null
+++ b/gas/testsuite/gas/bpf/arith.s
@@ -0,0 +1,53 @@
+	.text
+	add	r1, r2
+	add	r1, 5
+	add32	r1, r2
+	add32	r1, 5
+	sub	r1, r2
+	sub	r1, 5
+	sub32	r1, r2
+	sub32	r1, 5
+	and	r1, r2
+	and	r1, 0xff
+	and32	r1, r2
+	and32	r1, 0xff
+	or	r1, r2
+	or	r1, 0x80
+	or32	r1, r2
+	or32	r1, 0x80
+	xor	r1, r2
+	xor	r1, 0x1f
+	xor32	r1, r2
+	xor32	r1, 0x1f
+	mul	r1, r2
+	mul	r1, 5
+	mul32	r1, r2
+	mul32	r1, 5
+	div	r1, r2
+	div	r1, 2
+	div32	r1, r2
+	div32	r1, 2
+	mod	r1, r2
+	mod	r1, 3
+	mod32	r1, r2
+	mod32	r1, 3
+	lsh	r1, r2
+	lsh	r1, 1
+	lsh32	r1, r2
+	lsh32	r1, 1
+	rsh	r1, r2
+	rsh	r1, 1
+	rsh32	r1, r2
+	rsh32	r1, 1
+	arsh	r1, r2
+	arsh	r1, 4
+	arsh32	r1, r2
+	arsh32	r1, 4
+	neg	r1
+	neg32	r1
+	endbe	r1, 16
+	endbe	r1, 32
+	endbe	r1, 64
+	endle	r1, 16
+	endle	r1, 32
+	endle	r1, 64
diff --git a/gas/testsuite/gas/bpf/atomics.d b/gas/testsuite/gas/bpf/atomics.d
new file mode 100644
index 0000000..fc710d6
--- /dev/null
+++ b/gas/testsuite/gas/bpf/atomics.d
@@ -0,0 +1,12 @@
+#as: -EL
+#objdump: -dr
+#name: atomics
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	b7 20 00 00 06 00 00 00 	mov	r2, 6
+   8:	db 12 00 00 00 00 00 00 	xadddw	\[r1\+0\], r2
+  10:	c3 12 08 00 00 00 00 00 	xaddw	\[r1\+8\], r2
diff --git a/gas/testsuite/gas/bpf/atomics.s b/gas/testsuite/gas/bpf/atomics.s
new file mode 100644
index 0000000..6552ef3
--- /dev/null
+++ b/gas/testsuite/gas/bpf/atomics.s
@@ -0,0 +1,4 @@
+	.text
+	mov	r2, 6
+	xadddw	[r1+0], r2
+	xaddw	[r1+8], r2
diff --git a/gas/testsuite/gas/bpf/bpf.exp b/gas/testsuite/gas/bpf/bpf.exp
new file mode 100644
index 0000000..363fd2c
--- /dev/null
+++ b/gas/testsuite/gas/bpf/bpf.exp
@@ -0,0 +1,28 @@
+# Copyright (C) 2017 Free Software Foundation, Inc.
+
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License as published by
+# the Free Software Foundation; either version 3 of the License, or
+# (at your option) any later version.
+# 
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+# 
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software
+# Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1301, USA.  
+
+# BPF assembler testsuite
+
+if [istarget bpf*-*-*] {
+    run_dump_test "arith"
+    run_dump_test "jump"
+    run_dump_test "move"
+    run_dump_test "loads"
+    run_dump_test "stores"
+    run_dump_test "atomics"
+    run_dump_test "call"
+    run_dump_test "imm64"
+}
diff --git a/gas/testsuite/gas/bpf/call.d b/gas/testsuite/gas/bpf/call.d
new file mode 100644
index 0000000..e142050
--- /dev/null
+++ b/gas/testsuite/gas/bpf/call.d
@@ -0,0 +1,18 @@
+#as: -EL
+#objdump: -dr
+#name: call
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	85 00 00 00 01 00 00 00 	call	0x1
+   8:	85 00 00 00 02 00 00 00 	call	0x2
+  10:	85 00 00 00 03 00 00 00 	call	0x3
+  18:	85 00 00 00 04 00 00 00 	call	0x4
+  20:	8d 00 00 00 05 00 00 00 	tailcall	0x5
+  28:	8d 00 00 00 06 00 00 00 	tailcall	0x6
+  30:	8d 00 00 00 07 00 00 00 	tailcall	0x7
+  38:	8d 00 00 00 09 00 00 00 	tailcall	0x9
+  40:	95 00 00 00 00 00 00 00 	exit	
diff --git a/gas/testsuite/gas/bpf/call.s b/gas/testsuite/gas/bpf/call.s
new file mode 100644
index 0000000..6fdc4f2
--- /dev/null
+++ b/gas/testsuite/gas/bpf/call.s
@@ -0,0 +1,10 @@
+	.text
+	call	1
+	call	2
+	call	3
+	call	4
+	tailcall 5
+	tailcall 6
+	tailcall 7
+	tailcall 9
+	exit
diff --git a/gas/testsuite/gas/bpf/imm64.d b/gas/testsuite/gas/bpf/imm64.d
new file mode 100644
index 0000000..4dcaf7b
--- /dev/null
+++ b/gas/testsuite/gas/bpf/imm64.d
@@ -0,0 +1,30 @@
+#as: -EL
+#objdump: -dr
+#name: imm64a
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	18 10 00 00 01 00 00 00 	ldimm64	r1, 1
+   8:	00 00 00 00 00 00 00 00 
+  10:	18 10 00 00 02 00 00 00 	ldimm64	r1, 2
+  18:	00 00 00 00 00 00 00 00 
+  20:	18 10 00 00 00 00 01 00 	ldimm64	r1, 65536
+  28:	00 00 00 00 00 00 00 00 
+  30:	18 10 00 00 ff ff ff ff 	ldimm64	r1, 4294967295
+  38:	00 00 00 00 00 00 00 00 
+  40:	18 10 00 00 01 00 00 00 	ldimm64	r1, -4294967295
+  48:	00 00 00 00 ff ff ff ff 
+  50:	18 10 00 00 ff ff ff ff 	ldimm64	r1, -1
+  58:	00 00 00 00 ff ff ff ff 
+  60:	18 20 00 00 00 ff ff ff 	ldimm64	r2, -256
+  68:	00 00 00 00 ff ff ff ff 
+  70:	18 30 00 00 00 00 ff ff 	ldimm64	r3, -65536
+  78:	00 00 00 00 ff ff ff ff 
+  80:	18 40 00 00 00 00 00 00 	ldimm64	r4, 4294967296
+  88:	00 00 00 00 01 00 00 00 
+  90:	18 50 00 00 00 00 00 00 	ldimm64	r5, -9223372036854775808
+  98:	00 00 00 00 00 00 00 80 
+  a0:	95 00 00 00 00 00 00 00 	exit	
diff --git a/gas/testsuite/gas/bpf/imm64.s b/gas/testsuite/gas/bpf/imm64.s
new file mode 100644
index 0000000..929e357
--- /dev/null
+++ b/gas/testsuite/gas/bpf/imm64.s
@@ -0,0 +1,12 @@
+	.text
+	ldimm64	r1, 1
+	ldimm64	r1, 2
+	ldimm64	r1, 65536
+	ldimm64	r1, 4294967295
+	ldimm64	r1, -4294967295
+	ldimm64	r1, -1
+	ldimm64	r2, -256
+	ldimm64	r3, -65536
+	ldimm64	r4, 4294967296
+	ldimm64 r5, -9223372036854775808
+	exit
diff --git a/gas/testsuite/gas/bpf/jump.d b/gas/testsuite/gas/bpf/jump.d
new file mode 100644
index 0000000..fc1e6bd
--- /dev/null
+++ b/gas/testsuite/gas/bpf/jump.d
@@ -0,0 +1,43 @@
+#as: -EL
+#objdump: -dr
+#name: jump
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	05 00 03 00 00 00 00 00 	ja	0x10
+   8:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  10:	b7 20 00 00 03 00 00 00 	mov	r2, 3
+  18:	25 20 06 00 02 00 00 00 	jgt	r2, 2, 0x40
+  20:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  28:	b7 30 00 00 03 00 00 00 	mov	r3, 3
+  30:	15 30 03 00 03 00 00 00 	jeq	r3, 3, 0x40
+  38:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  40:	1d 32 03 00 00 00 00 00 	jeq	r3, r2, 0x50
+  48:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  50:	b7 40 00 00 04 00 00 00 	mov	r4, 4
+  58:	2d 43 03 00 00 00 00 00 	jgt	r4, r3, 0x68
+  60:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  68:	3d 43 03 00 00 00 00 00 	jge	r4, r3, 0x78
+  70:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  78:	35 30 03 00 03 00 00 00 	jge	r3, 3, 0x88
+  80:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  88:	5d 43 03 00 00 00 00 00 	jne	r4, r3, 0x98
+  90:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  98:	55 30 03 00 03 00 00 00 	jne	r3, 3, 0xa8
+  a0:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  a8:	6d 43 03 00 00 00 00 00 	jsgt	r4, r3, 0xb8
+  b0:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  b8:	65 30 03 00 03 00 00 00 	jsgt	r3, 3, 0xc8
+  c0:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  c8:	7d 43 03 00 00 00 00 00 	jsge	r4, r3, 0xd8
+  d0:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  d8:	75 30 03 00 03 00 00 00 	jsge	r3, 3, 0xe8
+  e0:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  e8:	4d 43 03 00 00 00 00 00 	jset	r4, r3, 0xf8
+  f0:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+  f8:	45 30 03 00 03 00 00 00 	jset	r3, 3, 0x108
+ 100:	bf 11 00 00 00 00 00 00 	mov	r1, r1
+ 108:	95 00 00 00 00 00 00 00 	exit	
diff --git a/gas/testsuite/gas/bpf/jump.s b/gas/testsuite/gas/bpf/jump.s
new file mode 100644
index 0000000..4e084b4
--- /dev/null
+++ b/gas/testsuite/gas/bpf/jump.s
@@ -0,0 +1,35 @@
+	.text
+	ja	1f
+	mov	r1, r1
+1:	mov	r2, 3
+	jgt	r2, 2, 1f
+	mov	r1, r1
+	mov	r3, 3
+	jeq	r3, 3, 1f
+	mov	r1, r1
+1:	jeq	r3, r2, 1f
+	mov	r1, r1
+1:	mov	r4, 4
+	jgt	r4, r3, 1f
+	mov	r1, r1
+1:	jge	r4, r3, 1f
+	mov	r1, r1
+1:	jge	r3, 3, 1f
+	mov	r1, r1
+1:	jne	r4, r3, 1f
+	mov	r1, r1
+1:	jne	r3, 3, 1f
+	mov	r1, r1
+1:	jsgt	r4, r3, 1f
+	mov	r1, r1
+1:	jsgt	r3, 3, 1f
+	mov	r1, r1
+1:	jsge	r4, r3, 1f
+	mov	r1, r1
+1:	jsge	r3, 3, 1f
+	mov	r1, r1
+1:	jset	r4, r3, 1f
+	mov	r1, r1
+1:	jset	r3, 3, 1f
+	mov	r1, r1
+1:	exit
diff --git a/gas/testsuite/gas/bpf/loads.d b/gas/testsuite/gas/bpf/loads.d
new file mode 100644
index 0000000..d981ef6
--- /dev/null
+++ b/gas/testsuite/gas/bpf/loads.d
@@ -0,0 +1,23 @@
+#as: -EL
+#objdump: -dr
+#name: loads
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	71 12 03 00 00 00 00 00 	ldb	r1, \[r2\+3\]
+   8:	69 12 02 00 00 00 00 00 	ldh	r1, \[r2\+2\]
+  10:	61 12 04 00 00 00 00 00 	ldw	r1, \[r2\+4\]
+  18:	79 12 08 00 00 00 00 00 	lddw	r1, \[r2\+8\]
+  20:	61 34 04 00 00 00 00 00 	ldw	r3, \[r4\+4\]
+  28:	61 44 08 00 00 00 00 00 	ldw	r4, \[r4\+8\]
+  30:	61 54 00 00 00 00 00 00 	ldw	r5, \[r4\+0\]
+  38:	69 33 02 00 00 00 00 00 	ldh	r3, \[r3\+2\]
+  40:	69 43 04 00 00 00 00 00 	ldh	r4, \[r3\+4\]
+  48:	69 53 00 00 00 00 00 00 	ldh	r5, \[r3\+0\]
+  50:	71 33 01 00 00 00 00 00 	ldb	r3, \[r3\+1\]
+  58:	71 43 02 00 00 00 00 00 	ldb	r4, \[r3\+2\]
+  60:	71 53 03 00 00 00 00 00 	ldb	r5, \[r3\+3\]
+  68:	71 63 00 00 00 00 00 00 	ldb	r6, \[r3\+0\]
diff --git a/gas/testsuite/gas/bpf/loads.s b/gas/testsuite/gas/bpf/loads.s
new file mode 100644
index 0000000..8602897
--- /dev/null
+++ b/gas/testsuite/gas/bpf/loads.s
@@ -0,0 +1,15 @@
+	.text
+	ldb	r1, [r2+3]
+	ldh	r1, [r2+2]
+	ldw	r1, [r2+4]
+	lddw	r1, [r2+8]
+	ldw	r3, [r4+4]
+	ldw	r4, [r4+8]
+	ldw	r5, [r4+0]
+	ldh	r3, [r3+2]
+	ldh	r4, [r3+4]
+	ldh	r5, [r3+0]
+	ldb	r3, [r3+1]
+	ldb	r4, [r3+2]
+	ldb	r5, [r3+3]
+	ldb	r6, [r3+0]
diff --git a/gas/testsuite/gas/bpf/move.d b/gas/testsuite/gas/bpf/move.d
new file mode 100644
index 0000000..f15ad23
--- /dev/null
+++ b/gas/testsuite/gas/bpf/move.d
@@ -0,0 +1,19 @@
+#as: -EL
+#objdump: -dr
+#name: move
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	bf 12 00 00 00 00 00 00 	mov	r1, r2
+   8:	b7 10 00 00 ef 00 00 00 	mov	r1, 239
+  10:	bc 12 00 00 00 00 00 00 	mov32	r1, r2
+  18:	b4 10 00 00 ef 00 00 00 	mov32	r1, 239
+  20:	bf 36 00 00 00 00 00 00 	mov	r3, r6
+  28:	bf 63 00 00 00 00 00 00 	mov	r6, r3
+  30:	bf 89 00 00 00 00 00 00 	mov	r8, r9
+  38:	bf a1 00 00 00 00 00 00 	mov	r10, r1
+  40:	bf 73 00 00 00 00 00 00 	mov	r7, r3
+  48:	b7 50 00 00 02 00 00 00 	mov	r5, 2
diff --git a/gas/testsuite/gas/bpf/move.s b/gas/testsuite/gas/bpf/move.s
new file mode 100644
index 0000000..36797b3
--- /dev/null
+++ b/gas/testsuite/gas/bpf/move.s
@@ -0,0 +1,11 @@
+	.text
+	mov	r1, r2
+	mov	r1, 0xef
+	mov32	r1, r2
+	mov32	r1, 0xef
+	mov	r3, r6
+	mov	r6, r3
+	mov	r8, r9
+	mov	r10, r1
+	mov	r7, r3
+	mov	r5, 2
diff --git a/gas/testsuite/gas/bpf/stores.d b/gas/testsuite/gas/bpf/stores.d
new file mode 100644
index 0000000..0f416e0
--- /dev/null
+++ b/gas/testsuite/gas/bpf/stores.d
@@ -0,0 +1,17 @@
+#as: -EL
+#objdump: -dr
+#name: stores
+
+.*: +file format elf64-bpfle
+
+Disassembly of section .text:
+
+0000000000000000 <.text>:
+   0:	63 12 00 00 00 00 00 00 	stw	\[r1\+0\], r2
+   8:	62 10 04 00 00 00 00 00 	stw	\[r1\+4\], 0
+  10:	6b 13 00 00 00 00 00 00 	sth	\[r1\+0\], r3
+  18:	6a 10 02 00 01 00 00 00 	sth	\[r1\+2\], 1
+  20:	73 14 00 00 00 00 00 00 	stb	\[r1\+0\], r4
+  28:	72 10 02 00 02 00 00 00 	stb	\[r1\+2\], 2
+  30:	7b 15 08 00 00 00 00 00 	stdw	\[r1\+8\], r5
+  38:	7a 10 10 00 10 00 00 00 	stdw	\[r1\+16\], 16
diff --git a/gas/testsuite/gas/bpf/stores.s b/gas/testsuite/gas/bpf/stores.s
new file mode 100644
index 0000000..d164f2a
--- /dev/null
+++ b/gas/testsuite/gas/bpf/stores.s
@@ -0,0 +1,9 @@
+	.text
+	stw	[r1+0], r2
+	stw	[r1+4], 0
+	sth	[r1+0], r3
+	sth	[r1+2], 1
+	stb	[r1+0], r4
+	stb	[r1+2], 2
+	stdw	[r1+8], r5
+	stdw	[r1+16], 16
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
index 0000000..5019b11
--- /dev/null
+++ b/include/elf/bpf.h
@@ -0,0 +1,39 @@
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
+  RELOC_NUMBER (R_BPF_INSN_16, 1)
+  RELOC_NUMBER (R_BPF_INSN_32, 2)
+  RELOC_NUMBER (R_BPF_INSN_64, 3)
+  RELOC_NUMBER (R_BPF_WDISP16, 4)
+  RELOC_NUMBER (R_BPF_DATA_8,  5)
+  RELOC_NUMBER (R_BPF_DATA_16, 6)
+  RELOC_NUMBER (R_BPF_DATA_32, 7)
+  RELOC_NUMBER (R_BPF_DATA_64, 8)
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
index 0000000..92e29af
--- /dev/null
+++ b/opcodes/bpf-dis.c
@@ -0,0 +1,161 @@
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
+      if (!strcmp (opcode->name, "mov")
+	  && !strcmp (opcode->args, "1,2")
+	  && src == 0 && dest == 0)
+	{
+	  (*info->fprintf_func) (stream, "%s\t", opcode->name);
+	  break;
+	}
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
+      break;
+    }
+
+  return ret;
+}
diff --git a/opcodes/bpf-opc.c b/opcodes/bpf-opc.c
new file mode 100644
index 0000000..ce4129b
--- /dev/null
+++ b/opcodes/bpf-opc.c
@@ -0,0 +1,148 @@
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
+  { "nop",     BPF_OPC_ALU64 | BPF_OPC_MOV  | BPF_OPC_X,     "" },
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
diff --git a/sim/configure.tgt b/sim/configure.tgt
index c958fb3..09eec72 100644
--- a/sim/configure.tgt
+++ b/sim/configure.tgt
@@ -26,6 +26,9 @@ case "${target}" in
    bfin-*-*)
        SIM_ARCH(bfin)
        ;;
+   bpf-*-*)
+       SIM_ARCH(bpf)
+       ;;
    cr16*-*-*)
        SIM_ARCH(cr16)
        ;;
-- 
2.4.11
