From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sat, 29 Apr 2017 22:37:59 -0400 (EDT)
Message-ID: <20170429.223759.1262491011130998405.davem@davemloft.net>
References: <20170428.163355.2067951664875385680.davem@davemloft.net>
        <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
        <20170429.222450.1300920007783667009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43844 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969675AbdD3CiB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 22:38:01 -0400
In-Reply-To: <20170429.222450.1300920007783667009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 29 Apr 2017 22:24:50 -0400 (EDT)

> Some of your bugs should be fixed by this patch below, I'll add
> test cases soon:

Ok, here are all the local changes in my tree.  I made the relocs
match LLVM and I fixed some dwarf debugging stuff.

With this we are also down to one test case failure under binutils/
and it's something weird with merging 64-bit notes which I should be
able to fix soon.

I can fix these bugs fast, keep reporting.

BTW, should I just remove tailcall from the opcode table altogether?

diff --git a/binutils/readelf.c b/binutils/readelf.c
index 6c67d98..3931a3a 100644
--- a/binutils/readelf.c
+++ b/binutils/readelf.c
@@ -95,6 +95,7 @@
 #include "elf/arm.h"
 #include "elf/avr.h"
 #include "elf/bfin.h"
+#include "elf/bpf.h"
 #include "elf/cr16.h"
 #include "elf/cris.h"
 #include "elf/crx.h"
@@ -746,6 +747,7 @@ guess_is_rela (unsigned int e_machine)
     case EM_AVR:
     case EM_AVR_OLD:
     case EM_BLACKFIN:
+    case EM_BPF:
     case EM_CR16:
     case EM_CRIS:
     case EM_CRX:
@@ -1458,6 +1460,10 @@ dump_relocations (FILE * file,
 	  rtype = elf_bfin_reloc_type (type);
 	  break;
 
+	case EM_BPF:
+	  rtype = elf_bpf_reloc_type (type);
+	  break;
+
 	case EM_CYGNUS_MEP:
 	  rtype = elf_mep_reloc_type (type);
 	  break;
diff --git a/gas/config/tc-bpf.c b/gas/config/tc-bpf.c
index 0ba2afa..36393b7 100644
--- a/gas/config/tc-bpf.c
+++ b/gas/config/tc-bpf.c
@@ -288,6 +288,14 @@ md_assemble (char *str ATTRIBUTE_UNUSED)
 	  switch (*args)
 	    {
 	    case '+':
+	      if (*s == '+')
+		{
+		  ++s;
+		  continue;
+		}
+	      if (*s == '-')
+		continue;
+	      break;
 	    case ',':
 	    case '[':
 	    case ']':
@@ -494,6 +502,9 @@ md_apply_fix (fixS *fixP, valueT *valP ATTRIBUTE_UNUSED, segT segment ATTRIBUTE_
   offsetT val = * (offsetT *) valP;
 
   gas_assert (fixP->fx_r_type < BFD_RELOC_UNUSED);
+
+  fixP->fx_addnumber = val;	/* Remember value for emit_reloc.  */
+
   /* If this is a data relocation, just output VAL.  */
 
   if (fixP->fx_r_type == BFD_RELOC_8)
diff --git a/include/elf/bpf.h b/include/elf/bpf.h
index 5019b11..77463e3 100644
--- a/include/elf/bpf.h
+++ b/include/elf/bpf.h
@@ -26,14 +26,14 @@
 /* Relocation types.  */
 START_RELOC_NUMBERS (elf_bpf_reloc_type)
   RELOC_NUMBER (R_BPF_NONE, 0)
-  RELOC_NUMBER (R_BPF_INSN_16, 1)
-  RELOC_NUMBER (R_BPF_INSN_32, 2)
-  RELOC_NUMBER (R_BPF_INSN_64, 3)
-  RELOC_NUMBER (R_BPF_WDISP16, 4)
-  RELOC_NUMBER (R_BPF_DATA_8,  5)
-  RELOC_NUMBER (R_BPF_DATA_16, 6)
-  RELOC_NUMBER (R_BPF_DATA_32, 7)
-  RELOC_NUMBER (R_BPF_DATA_64, 8)
+  RELOC_NUMBER (R_BPF_DATA_64, 1)
+  RELOC_NUMBER (R_BPF_INSN_16, 2)
+  RELOC_NUMBER (R_BPF_INSN_32, 3)
+  RELOC_NUMBER (R_BPF_INSN_64, 4)
+  RELOC_NUMBER (R_BPF_WDISP16, 5)
+  RELOC_NUMBER (R_BPF_DATA_8,  6)
+  RELOC_NUMBER (R_BPF_DATA_16, 7)
+  RELOC_NUMBER (R_BPF_DATA_32, 10)
 END_RELOC_NUMBERS (R_BPF_max)
 
 #endif /* _ELF_BPF_H */
diff --git a/opcodes/bpf-dis.c b/opcodes/bpf-dis.c
index 92e29af..39656bf 100644
--- a/opcodes/bpf-dis.c
+++ b/opcodes/bpf-dis.c
@@ -49,7 +49,7 @@ print_insn_bpf (bfd_vma memaddr, disassemble_info *info)
   bpf_opcode_hash *op;
   int code, dest, src;
   bfd_byte buffer[8];
-  unsigned short off;
+  signed short off;
   int status, ret;
   signed int imm;
 
@@ -78,7 +78,7 @@ print_insn_bpf (bfd_vma memaddr, disassemble_info *info)
   else
     {
       getword = bfd_getl32;
-      gethalf = bfd_getl32;
+      gethalf = bfd_getl16;
     }  
 
   code = buffer[0];
@@ -128,7 +128,7 @@ print_insn_bpf (bfd_vma memaddr, disassemble_info *info)
 	      (*info->fprintf_func) (stream, "%d", imm);
 	      break;
 	    case 'O':
-	      (*info->fprintf_func) (stream, "%d", off);
+	      (*info->fprintf_func) (stream, "%d", (int) off);
 	      break;
 	    case 'L':
 	      info->target = memaddr + ((off - 1) * 8);
