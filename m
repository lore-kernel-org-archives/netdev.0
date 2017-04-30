From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sat, 29 Apr 2017 22:24:50 -0400 (EDT)
Message-ID: <20170429.222450.1300920007783667009.davem@davemloft.net>
References: <20170428.163355.2067951664875385680.davem@davemloft.net>
        <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S378422AbdD3CYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 22:24:53 -0400
In-Reply-To: <9d5e3a87-15d0-01d7-6272-fa8d2bf0d076@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 17:48:43 -0700

> $ bld/binutils/objdump -S test.o
> 
> test.o:     file format elf64-bpfbe
> 
> Disassembly of section .text:
> 
> 0000000000000000 <bpf_prog1>:
>    0:	18 10 00 00 83 98 47 39 	ldimm64	r1, 590618314553
>    8:	00 00 00 00 00 00 00 89
>   10:	7b a1 ff f8 00 00 00 00 	stdw	[r10+65528], r1
>   18:	79 1a ff f8 00 00 00 00 	lddw	r1, [r10+65528]
>   20:	07 10 00 00 8f ff 00 02 	add	r1, -1879113726
>   28:	79 01 00 00 00 00 00 00 	lddw	r0, [r1+0]
>   30:	95 00 00 00 00 00 00 00 	exit
> 
> looks good except negative offsets are reported as large positive.

Some of your bugs should be fixed by this patch below, I'll add
test cases soon:

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
