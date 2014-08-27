From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v8 net-next 2/2] net: filter: split filter.h and expose eBPF to user space
Date: Wed, 27 Aug 2014 13:37:13 -0700
Message-ID: <1409171833-6979-3-git-send-email-ast@plumgrid.com>
References: <1409171833-6979-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409171833-6979-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

allow user space to generate eBPF programs

uapi/linux/bpf.h: eBPF instruction set definition

linux/filter.h: the rest

This patch only moves macro definitions, but practically it freezes existing
eBPF instruction set, though new instructions can still be added in the future.

These eBPF definitions cannot go into uapi/linux/filter.h, since the names
may conflict with existing applications.

Full eBPF ISA description is in Documentation/networking/filter.txt

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/filter.h    |   56 +-------------------------------------
 include/uapi/linux/Kbuild |    1 +
 include/uapi/linux/bpf.h  |   65 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 55 deletions(-)
 create mode 100644 include/uapi/linux/bpf.h

diff --git a/include/linux/filter.h b/include/linux/filter.h
index f3262b598262..3150666cd4b9 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -9,53 +9,7 @@
 #include <linux/skbuff.h>
 #include <linux/workqueue.h>
 #include <uapi/linux/filter.h>
-
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
+#include <uapi/linux/bpf.h>
 
 /* ArgX, context and stack frame pointer register positions. Note,
  * Arg1, Arg2, Arg3, etc are used as argument mappings of function
@@ -317,14 +271,6 @@ enum {
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
