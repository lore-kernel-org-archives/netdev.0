From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 binutils] Add BPF support to binutils...
Date: Fri, 28 Apr 2017 12:04:57 -0400 (EDT)
Message-ID: <20170428.120457.408834081300892396.davem@davemloft.net>
References: <20170427.170934.891283291562287326.davem@davemloft.net>
        <f7td1bwtthr.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426293AbdD1QE7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 12:04:59 -0400
In-Reply-To: <f7td1bwtthr.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Fri, 28 Apr 2017 11:57:36 -0400

> I'll get an arm board up and running to do some testing there.  As a
> teaser:

Great.

I started working on some more relocation stuff, so more of the
generic gas tests pass.

For example, stuff like this now works properly:

[davem@dhcp-10-15-49-210 build-bpf]$ cat gas/y.s
	.data
	.globl	foo
foo:	.xword	bar
[davem@dhcp-10-15-49-210 build-bpf]$ gas/as-new -o gas/y.o gas/y.s
[davem@dhcp-10-15-49-210 build-bpf]$ binutils/objdump -r gas/y.o

gas/y.o:     file format elf64-bpfle

RELOCATION RECORDS FOR [.data]:
OFFSET           TYPE              VALUE 
0000000000000000 R_BPF_DATA_64     bar


[davem@dhcp-10-15-49-210 build-bpf]$

It turned out that I needed to separate the R_BPF_* relocations into
data vs. insn ones.

Another idea I am thinking about pursuing is adding BPF simulator
support under sim/ so that people can use gdb to step through BPF
programs.

I hope we can make it work in a way that we can even step through
XDP programs and feed them simple test packets, stuff like that.

Anyways, quick relative live patch against v2 from my tree for the
reloc stuff:

diff --git a/bfd/elf64-bpf.c b/bfd/elf64-bpf.c
index 9944bb4..1be285d 100644
--- a/bfd/elf64-bpf.c
+++ b/bfd/elf64-bpf.c
@@ -1,8 +1,89 @@
 #include "sysdep.h"
 #include "bfd.h"
+#include "bfdlink.h"
 #include "libbfd.h"
+#include "libiberty.h"
 #include "elf-bfd.h"
+#include "elf/bpf.h"
 #include "opcode/bpf.h"
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
 
 static void
 check_for_relocs (bfd * abfd, asection * o, void * failed)
@@ -34,6 +115,30 @@ elf64_generic_link_add_symbols (bfd *abfd, struct bfd_link_info *info)
   return bfd_elf_link_add_symbols (abfd, info);
 }
 
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
 #define TARGET_LITTLE_SYM	bpf_elf64_le_vec
 #define TARGET_LITTLE_NAME	"elf64-bpfle"
 #define TARGET_BIG_SYM		bpf_elf64_be_vec
@@ -42,8 +147,10 @@ elf64_generic_link_add_symbols (bfd *abfd, struct bfd_link_info *info)
 #define ELF_MAXPAGESIZE		0x100000
 #define ELF_MACHINE_CODE	EM_BPF
 
-#define bfd_elf64_bfd_reloc_type_lookup bfd_default_reloc_type_lookup
-#define bfd_elf64_bfd_reloc_name_lookup _bfd_norelocs_bfd_reloc_name_lookup
+#define elf_info_to_howto		    elf_bpf_info_to_howto
+
+#define bfd_elf64_bfd_reloc_type_lookup _bfd_bpf_elf_reloc_type_lookup
+#define bfd_elf64_bfd_reloc_name_lookup _bfd_bpf_elf_reloc_name_lookup
 #define bfd_elf64_bfd_link_add_symbols	elf64_generic_link_add_symbols
 
 #include "elf64-target.h"
diff --git a/gas/config/tc-bpf.c b/gas/config/tc-bpf.c
index f5fb308..0ba2afa 100644
--- a/gas/config/tc-bpf.c
+++ b/gas/config/tc-bpf.c
@@ -546,12 +546,57 @@ md_apply_fix (fixS *fixP, valueT *valP ATTRIBUTE_UNUSED, segT segment ATTRIBUTE_
 	}
 
     }
+  if (fixP->fx_addsy == NULL)
+    fixP->fx_done = 1;
 }
 
 arelent *
 tc_gen_reloc (asection *section ATTRIBUTE_UNUSED, fixS *fixp ATTRIBUTE_UNUSED)
 {
-  return NULL;
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
 }
 
 symbolS *
diff --git a/include/elf/bpf.h b/include/elf/bpf.h
index 3a84d9a..5019b11 100644
--- a/include/elf/bpf.h
+++ b/include/elf/bpf.h
@@ -26,10 +26,14 @@
 /* Relocation types.  */
 START_RELOC_NUMBERS (elf_bpf_reloc_type)
   RELOC_NUMBER (R_BPF_NONE, 0)
-  RELOC_NUMBER (R_BPF_16, 1)
-  RELOC_NUMBER (R_BPF_32, 2)
-  RELOC_NUMBER (R_BPF_64, 3)
+  RELOC_NUMBER (R_BPF_INSN_16, 1)
+  RELOC_NUMBER (R_BPF_INSN_32, 2)
+  RELOC_NUMBER (R_BPF_INSN_64, 3)
   RELOC_NUMBER (R_BPF_WDISP16, 4)
+  RELOC_NUMBER (R_BPF_DATA_8,  5)
+  RELOC_NUMBER (R_BPF_DATA_16, 6)
+  RELOC_NUMBER (R_BPF_DATA_32, 7)
+  RELOC_NUMBER (R_BPF_DATA_64, 8)
 END_RELOC_NUMBERS (R_BPF_max)
 
 #endif /* _ELF_BPF_H */
