From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v9 net-next 2/4] net: filter: split filter.h and expose eBPF to user space
Date: Tue,  2 Sep 2014 20:17:24 -0700
Message-ID: <1409714246-31054-3-git-send-email-ast@plumgrid.com>
References: <1409714246-31054-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63675 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257AbaICDRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 23:17:43 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so16299336pac.19
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 20:17:42 -0700 (PDT)
In-Reply-To: <1409714246-31054-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allow user space to generate eBPF programs

uapi/linux/bpf.h: eBPF instruction set definition

linux/filter.h: the rest

This patch only moves macro definitions, but practically it freezes existing
eBPF instruction set, though new instructions can still be added in the future.

These eBPF definitions cannot go into uapi/linux/filter.h, since the names
may conflict with existing applications.

Full eBPF ISA description is in Documentation/networking/filter.txt

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h    |   56 +-------------------------------------
 include/uapi/linux/Kbuild |    1 +
 include/uapi/linux/bpf.h  |   65 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 55 deletions(-)
 create mode 100644 include/uapi/linux/bpf.h

diff --git a/include/linux/filter.h b/include/linux/filter.h
index bf323da77950..8f82ef3f1cdd 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -10,58 +10,12 @@
 #include <linux/workqueue.h>
 #include <uapi/linux/filter.h>
 #include <asm/cacheflush.h>
+#include <uapi/linux/bpf.h>
 
 struct sk_buff;
 struct sock;
 struct seccomp_data;
 
-/* Internally used and optimized filter representation with extended
- * instruction set based on top of classic BPF.
- */
-
-/* instruction classes */
-#define BPF_ALU64	0x07	/* alu mode in double word width */
-
-/* ld/ldx fields */
-#define BPF_DW		0x18	/* double word */
-#define BPF_XADD	0xc0	/* exclusive add */
-
-/* alu/jmp fields */
-#define BPF_MOV		0xb0	/* mov reg to reg */
-#define BPF_ARSH	0xc0	/* sign extending arithmetic shift right */
-
-/* change endianness of a register */
-#define BPF_END		0xd0	/* flags for endianness conversion: */
-#define BPF_TO_LE	0x00	/* convert to little-endian */
-#define BPF_TO_BE	0x08	/* convert to big-endian */
-#define BPF_FROM_LE	BPF_TO_LE
-#define BPF_FROM_BE	BPF_TO_BE
-
-#define BPF_JNE		0x50	/* jump != */
-#define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
-#define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
-#define BPF_CALL	0x80	/* function call */
-#define BPF_EXIT	0x90	/* function return */
-
-/* Register numbers */
-enum {
-	BPF_REG_0 = 0,
-	BPF_REG_1,
-	BPF_REG_2,
-	BPF_REG_3,
-	BPF_REG_4,
-	BPF_REG_5,
-	BPF_REG_6,
-	BPF_REG_7,
-	BPF_REG_8,
-	BPF_REG_9,
-	BPF_REG_10,
-	__MAX_BPF_REG,
-};
-
-/* BPF has 10 general purpose 64-bit registers and stack frame. */
-#define MAX_BPF_REG	__MAX_BPF_REG
-
 /* ArgX, context and stack frame pointer register positions. Note,
  * Arg1, Arg2, Arg3, etc are used as argument mappings of function
  * calls in BPF_CALL instruction.
@@ -322,14 +276,6 @@ enum {
 #define SK_RUN_FILTER(filter, ctx) \
 	(*filter->prog->bpf_func)(ctx, filter->prog->insnsi)
 
-struct bpf_insn {
-	__u8	code;		/* opcode */
-	__u8	dst_reg:4;	/* dest register */
-	__u8	src_reg:4;	/* source register */
-	__s16	off;		/* signed offset */
-	__s32	imm;		/* signed immediate constant */
-};
-
 #ifdef CONFIG_COMPAT
 /* A struct sock_filter is architecture independent. */
 struct compat_sock_fprog {
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 24e9033f8b3f..fb3f7b675229 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -67,6 +67,7 @@ header-y += bfs_fs.h
 header-y += binfmts.h
 header-y += blkpg.h
 header-y += blktrace_api.h
+header-y += bpf.h
 header-y += bpqether.h
 header-y += bsg.h
 header-y += btrfs.h
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
new file mode 100644
index 000000000000..479ed0b6be16
--- /dev/null
+++ b/include/uapi/linux/bpf.h
@@ -0,0 +1,65 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _UAPI__LINUX_BPF_H__
+#define _UAPI__LINUX_BPF_H__
+
+#include <linux/types.h>
+
+/* Extended instruction set based on top of classic BPF */
+
+/* instruction classes */
+#define BPF_ALU64	0x07	/* alu mode in double word width */
+
+/* ld/ldx fields */
+#define BPF_DW		0x18	/* double word */
+#define BPF_XADD	0xc0	/* exclusive add */
+
+/* alu/jmp fields */
+#define BPF_MOV		0xb0	/* mov reg to reg */
+#define BPF_ARSH	0xc0	/* sign extending arithmetic shift right */
+
+/* change endianness of a register */
+#define BPF_END		0xd0	/* flags for endianness conversion: */
+#define BPF_TO_LE	0x00	/* convert to little-endian */
+#define BPF_TO_BE	0x08	/* convert to big-endian */
+#define BPF_FROM_LE	BPF_TO_LE
+#define BPF_FROM_BE	BPF_TO_BE
+
+#define BPF_JNE		0x50	/* jump != */
+#define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
+#define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
+#define BPF_CALL	0x80	/* function call */
+#define BPF_EXIT	0x90	/* function return */
+
+/* Register numbers */
+enum {
+	BPF_REG_0 = 0,
+	BPF_REG_1,
+	BPF_REG_2,
+	BPF_REG_3,
+	BPF_REG_4,
+	BPF_REG_5,
+	BPF_REG_6,
+	BPF_REG_7,
+	BPF_REG_8,
+	BPF_REG_9,
+	BPF_REG_10,
+	__MAX_BPF_REG,
+};
+
+/* BPF has 10 general purpose 64-bit registers and stack frame. */
+#define MAX_BPF_REG	__MAX_BPF_REG
+
+struct bpf_insn {
+	__u8	code;		/* opcode */
+	__u8	dst_reg:4;	/* dest register */
+	__u8	src_reg:4;	/* source register */
+	__s16	off;		/* signed offset */
+	__s32	imm;		/* signed immediate constant */
+};
+
+#endif /* _UAPI__LINUX_BPF_H__ */
-- 
1.7.9.5
