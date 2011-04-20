From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Wed, 20 Apr 2011 21:27:32 +0200
Message-ID: <1303327652.2690.23.camel@edumazet-laptop>
References: <1302797147.3248.32.camel@edumazet-laptop>
	 <4DAE8E47.7040409@redhat.com> <1303286878.3186.17.camel@edumazet-laptop>
	 <20110420.011454.226757908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avi@redhat.com, hagen@jauu.net, netdev@vger.kernel.org,
	acme@infradead.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46973 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755665Ab1DTT1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:27:41 -0400
Received: by wya21 with SMTP id 21so878541wya.19
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 12:27:40 -0700 (PDT)
In-Reply-To: <20110420.011454.226757908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 01:14 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 20 Apr 2011 10:07:58 +0200
>=20
> > No problem, I'll wait your work on this then.
>=20
> Don't, please resubmit your BPF jit code so I can apply it.
>=20
> Waiting for some userspace pie-in-the-sky based solution, and blockin=
g
> this perfectly functional thing we have now meanwhile, is not
> reasonable.
>=20
> We're pragmatic, not perfectionists.
>=20
> Thanks Eric.

Thanks David, let see how it flies...

V3 is same than V2 with the missing arch/x86/net/Makefile, and a change
to keep kmemcheck flags2 in struct skbuff

I dont know yet how to address net/core/timestamping.c PTP filter, sinc=
e
we would need to compile it only if JIT enabled by the admin.

[PATCH v3] net: filter: Just In Time compiler

In order to speedup packet filtering, here is an implementation of a JI=
T
compiler for x86_64

It is disabled by default, and must be enabled by the admin.

echo 1 >/proc/sys/net/core/bpf_jit_enable

It uses module_alloc() and module_free() to get memory in the 2GB text
kernel range since we call helpers functions from the generated code.

EAX : BPF A accumulator
EBX : BPF X accumulator
RDI : pointer to skb   (first argument given to JIT function)
RBP : frame pointer (even if CONFIG_FRAME_POINTER=3Dn)
r9d : skb->len - skb->data_len (headlen)
r8  : skb->data

To get a trace of generated code, use :

echo 2 >/proc/sys/net/core/bpf_jit_enable

Example of generated code :

# tcpdump -p -n -s 0 -i eth1 host 192.168.20.0/24

flen=3D18 proglen=3D147 pass=3D3 image=3Dffffffffa00b5000
JIT code: ffffffffa00b5000: 55 48 89 e5 48 83 ec 60 48 89 5d f8 44 8b 4=
f 60
JIT code: ffffffffa00b5010: 44 2b 4f 64 4c 8b 87 b8 00 00 00 be 0c 00 0=
0 00
JIT code: ffffffffa00b5020: e8 24 7b f7 e0 3d 00 08 00 00 75 28 be 1a 0=
0 00
JIT code: ffffffffa00b5030: 00 e8 fe 7a f7 e0 24 00 3d 00 14 a8 c0 74 4=
9 be
JIT code: ffffffffa00b5040: 1e 00 00 00 e8 eb 7a f7 e0 24 00 3d 00 14 a=
8 c0
JIT code: ffffffffa00b5050: 74 36 eb 3b 3d 06 08 00 00 74 07 3d 35 80 0=
0 00
JIT code: ffffffffa00b5060: 75 2d be 1c 00 00 00 e8 c8 7a f7 e0 24 00 3=
d 00
JIT code: ffffffffa00b5070: 14 a8 c0 74 13 be 26 00 00 00 e8 b5 7a f7 e=
0 24
JIT code: ffffffffa00b5080: 00 3d 00 14 a8 c0 75 07 b8 ff ff 00 00 eb 0=
2 31
JIT code: ffffffffa00b5090: c0 c9 c3

BPF program is 144 bytes long, so native program is almost same size ;)

(000) ldh      [12]
(001) jeq      #0x800           jt 2    jf 8
(002) ld       [26]
(003) and      #0xffffff00
(004) jeq      #0xc0a81400      jt 16   jf 5
(005) ld       [30]
(006) and      #0xffffff00
(007) jeq      #0xc0a81400      jt 16   jf 17
(008) jeq      #0x806           jt 10   jf 9
(009) jeq      #0x8035          jt 10   jf 17
(010) ld       [28]
(011) and      #0xffffff00
(012) jeq      #0xc0a81400      jt 16   jf 13
(013) ld       [38]
(014) and      #0xffffff00
(015) jeq      #0xc0a81400      jt 16   jf 17
(016) ret      #65535
(017) ret      #0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
---
perf tool might need some changes to take into account JIT.
V3: missing arch/x86/net/makefile
V2: BPF_S_ALU_AND_K optimizations, BPF_S_ANC_QUEUE support
    Move x86 files to arch/x86/net

 Documentation/sysctl/net.txt |   11=20
 MAINTAINERS                  |    1=20
 arch/x86/Kbuild              |    1=20
 arch/x86/Kconfig             |    1=20
 arch/x86/net/Makefile        |    4=20
 arch/x86/net/bpf_jit.S       |  142 +++++++
 arch/x86/net/bpf_jit_comp.c  |  655 +++++++++++++++++++++++++++++++++
 include/linux/filter.h       |   76 +++
 include/linux/netdevice.h    |    1=20
 include/linux/skbuff.h       |    4=20
 net/Kconfig                  |   13=20
 net/core/filter.c            |   65 ---
 net/core/sysctl_net_core.c   |    9=20
 net/packet/af_packet.c       |    2=20
 14 files changed, 921 insertions(+), 64 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.tx=
t
index cbd05ff..3201a70 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -32,6 +32,17 @@ Table : Subdirectories in /proc/sys/net
 1. /proc/sys/net/core - Network core options
 -------------------------------------------------------
=20
+bpf_jit_enable
+--------------
+
+This enables Berkeley Packet Filter Just in Time compiler.
+Currently supported on x86_64 architecture, bpf_jit provides a framewo=
rk
+to speed packet filtering, the one used by tcpdump/libpcap for example=
=2E
+Values :
+	0 - disable the JIT (default value)
+	1 - enable the JIT
+	2 - enable the JIT and ask the compiler to emit traces on kernel log.
+
 rmem_default
 ------------
=20
diff --git a/MAINTAINERS b/MAINTAINERS
index b5266ad..17c0917 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4372,6 +4372,7 @@ S:	Maintained
 F:	net/ipv4/
 F:	net/ipv6/
 F:	include/net/ip*
+F:	arch/x86/net/*
=20
 NETWORKING [LABELED] (NetLabel, CIPSO, Labeled IPsec, SECMARK)
 M:	Paul Moore <paul.moore@hp.com>
diff --git a/arch/x86/Kbuild b/arch/x86/Kbuild
index 0e10323..0e9dec6 100644
--- a/arch/x86/Kbuild
+++ b/arch/x86/Kbuild
@@ -15,3 +15,4 @@ obj-y +=3D vdso/
 obj-$(CONFIG_IA32_EMULATION) +=3D ia32/
=20
 obj-y +=3D platform/
+obj-y +=3D net/
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cc6c53a..855a1bd 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -72,6 +72,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select USE_GENERIC_SMP_HELPERS if SMP
 	select ARCH_NO_SYSDEV_OPS
+	select HAVE_BPF_JIT if X86_64
=20
 config INSTRUCTION_DECODER
 	def_bool (KPROBES || PERF_EVENTS)
diff --git a/arch/x86/net/Makefile b/arch/x86/net/Makefile
new file mode 100644
index 0000000..90568c3
--- /dev/null
+++ b/arch/x86/net/Makefile
@@ -0,0 +1,4 @@
+#
+# Arch-specific network modules
+#
+obj-$(CONFIG_BPF_JIT) +=3D bpf_jit.o bpf_jit_comp.o
diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
new file mode 100644
index 0000000..a0a9843
--- /dev/null
+++ b/arch/x86/net/bpf_jit.S
@@ -0,0 +1,142 @@
+/* bpf_jit.S : BPF JIT helper functions
+ *
+ * Copyright (C) 2011 Eric Dumazet (eric.dumazet@gmail.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+#include <linux/linkage.h>
+#include <asm/dwarf2.h>
+
+/*
+ * Calling convention :
+ * rdi : skb pointer
+ * esi : offset of byte(s) to fetch in skb (can be scratched)
+ * r8  : copy of skb->data
+ * r9d : hlen =3D skb->len - skb->data_len
+ */
+#define SKBDATA	%r8
+
+sk_load_word_ind:
+	.globl	sk_load_word_ind
+
+	add	%ebx,%esi	/* offset +=3D X */
+#	test    %esi,%esi	/* if (offset < 0) goto bpf_error; */
+	js	bpf_error
+
+sk_load_word:
+	.globl	sk_load_word
+
+	mov	%r9d,%eax		# hlen
+	sub	%esi,%eax		# hlen - offset
+	cmp	$3,%eax
+	jle	bpf_slow_path_word
+	mov     (SKBDATA,%rsi),%eax
+	bswap   %eax  			/* ntohl() */
+	ret
+
+
+sk_load_half_ind:
+	.globl sk_load_half_ind
+
+	add	%ebx,%esi	/* offset +=3D X */
+	js	bpf_error
+
+sk_load_half:
+	.globl	sk_load_half
+
+	mov	%r9d,%eax
+	sub	%esi,%eax		#	hlen - offset
+	cmp	$1,%eax
+	jle	bpf_slow_path_half
+	movzwl	(SKBDATA,%rsi),%eax
+	rol	$8,%ax			# ntohs()
+	ret
+
+sk_load_byte_ind:
+	.globl sk_load_byte_ind
+	add	%ebx,%esi	/* offset +=3D X */
+	js	bpf_error
+
+sk_load_byte:
+	.globl	sk_load_byte
+
+	cmp	%esi,%r9d   /* if (offset >=3D hlen) goto bpf_slow_path_byte */
+	jle	bpf_slow_path_byte
+	movzbl	(SKBDATA,%rsi),%eax
+	ret
+
+/**
+ * sk_load_byte_msh - BPF_S_LDX_B_MSH helper
+ *
+ * Implements BPF_S_LDX_B_MSH : ldxb  4*([offset]&0xf)
+ * Must preserve A accumulator (%eax)
+ * Inputs : %esi is the offset value, already known positive
+ */
+ENTRY(sk_load_byte_msh)
+	CFI_STARTPROC
+	cmp	%esi,%r9d      /* if (offset >=3D hlen) goto bpf_slow_path_byte_m=
sh */
+	jle	bpf_slow_path_byte_msh
+	movzbl	(SKBDATA,%rsi),%ebx
+	and	$15,%bl
+	shl	$2,%bl
+	ret
+	CFI_ENDPROC
+ENDPROC(sk_load_byte_msh)
+
+bpf_error:
+# force a return 0 from jit handler
+	xor		%eax,%eax
+	mov		-8(%rbp),%rbx
+	leaveq
+	ret
+
+/* rsi contains offset and can be scratched */
+#define bpf_slow_path_common(LEN)		\
+	push	%rdi;    /* save skb */		\
+	push	%r9;				\
+	push	SKBDATA;			\
+/* rsi already has offset */			\
+	mov	$LEN,%ecx;	/* len */	\
+	lea	-12(%rbp),%rdx;			\
+	call	skb_copy_bits;			\
+	test    %eax,%eax;			\
+	pop	SKBDATA;			\
+	pop	%r9;				\
+	pop	%rdi
+
+
+bpf_slow_path_word:
+	bpf_slow_path_common(4)
+	js	bpf_error
+	mov	-12(%rbp),%eax
+	bswap	%eax
+	ret
+
+bpf_slow_path_half:
+	bpf_slow_path_common(2)
+	js	bpf_error
+	mov	-12(%rbp),%ax
+	rol	$8,%ax
+	movzwl	%ax,%eax	=09
+	ret
+
+bpf_slow_path_byte:
+	bpf_slow_path_common(1)
+	js	bpf_error
+	movzbl	-12(%rbp),%eax
+	ret
+
+bpf_slow_path_byte_msh:
+	xchg	%eax,%ebx /* dont lose A , X is about to be scratched */
+	bpf_slow_path_common(1)
+	js	bpf_error
+	movzbl	-12(%rbp),%eax
+	and	$15,%al
+	shl	$2,%al
+	xchg	%eax,%ebx
+	ret
+
+
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
new file mode 100644
index 0000000..1a21d82
--- /dev/null
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -0,0 +1,655 @@
+/* bpf_jit_comp.c : BPF JIT compiler
+ *
+ * Copyright (C) 2011 Eric Dumazet (eric.dumazet@gmail.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+#include <linux/moduleloader.h>
+#include <asm/cacheflush.h>
+#include <linux/netdevice.h>
+#include <linux/filter.h>
+
+/*
+ * Conventions :
+ *  EAX : BPF A accumulator
+ *  EBX : BPF X accumulator
+ *  RDI : pointer to skb   (first argument given to JIT function)
+ *  RBP : frame pointer (even if CONFIG_FRAME_POINTER=3Dn)
+ *  ECX,EDX,ESI : scratch registers
+ *  r9d : skb->len - skb->data_len (headlen)
+ *  r8  : skb->data
+ * -8(RBP) : saved RBX value
+ * -16(RBP)..-80(RBP) : BPF_MEMWORDS values
+ */
+int bpf_jit_enable __read_mostly;
+
+/*
+ * assembly code in arch/x86/net/bpf_jit.S
+ */
+extern u8 sk_load_word[], sk_load_half[], sk_load_byte[], sk_load_byte=
_msh[];
+extern u8 sk_load_word_ind[], sk_load_half_ind[], sk_load_byte_ind[];
+
+static inline u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len)
+{
+	if (len =3D=3D 1)
+		*ptr =3D bytes;
+	else if (len =3D=3D 2)
+		*(u16 *)ptr =3D bytes;
+	else {
+		*(u32 *)ptr =3D bytes;
+		barrier();
+	}
+	return ptr + len;
+}
+
+#define EMIT(bytes, len)	do { prog =3D emit_code(prog, bytes, len); } =
while (0)
+
+#define EMIT1(b1)		EMIT(b1, 1)
+#define EMIT2(b1, b2)		EMIT((b1) + ((b2) << 8), 2)
+#define EMIT3(b1, b2, b3)	EMIT((b1) + ((b2) << 8) + ((b3) << 16), 3)
+#define EMIT4(b1, b2, b3, b4)   EMIT((b1) + ((b2) << 8) + ((b3) << 16)=
 + ((b4) << 24), 4)=20
+#define EMIT1_off32(b1, off)	do { EMIT1(b1); EMIT(off, 4);} while (0)
+
+#define CLEAR_A() EMIT2(0x31, 0xc0) /* xor %eax,%eax */
+#define CLEAR_X() EMIT2(0x31, 0xdb) /* xor %ebx,%ebx */
+
+static inline bool is_imm8(int value)
+{
+	return value <=3D 127 && value >=3D -128;
+}
+
+static inline bool is_near(int offset)
+{
+	return offset <=3D 127 && offset >=3D -128;
+}
+
+#define EMIT_JMP(offset)						\
+do {									\
+	if (offset) {							\
+		if (is_near(offset))					\
+			EMIT2(0xeb, offset); /* jmp .+off8 */		\
+		else							\
+			EMIT1_off32(0xe9, offset); /* jmp .+off32 */	\
+	}								\
+} while (0)
+=09
+/* list of x86 cond jumps opcodes (. + s8)
+ * Add 0x10 (and an extra 0x0f) to generate far jumps (. + s32)
+ */
+#define X86_JB  0x72
+#define X86_JAE 0x73
+#define X86_JE  0x74
+#define X86_JNE 0x75
+#define X86_JBE 0x76
+#define X86_JA  0x77
+
+#define EMIT_COND_JMP(op, offset)				\
+do {								\
+	if (is_near(offset))					\
+		EMIT2(op, offset); /* jxx .+off8 */		\
+	else {							\
+		EMIT2(0x0f, op + 0x10);				\
+		EMIT(offset, 4); /* jxx .+off32 */		\
+	}							\
+} while (0)
+
+#define COND_SEL(CODE, TOP, FOP)	\
+	case CODE:			\
+		t_op =3D TOP;		\
+		f_op =3D FOP;		\
+		goto cond_branch
+
+
+#define SEEN_DATAREF 1 /* might call external helpers */
+#define SEEN_XREG    2 /* ebx is used */
+#define SEEN_MEM     4 /* use mem[] for temporary storage */
+
+static inline void bpf_flush_icache(void *start, void *end)
+{
+	mm_segment_t old_fs =3D get_fs();
+
+	set_fs(KERNEL_DS);
+	smp_wmb();
+	flush_icache_range((unsigned long)start, (unsigned long)end);
+	set_fs(old_fs);
+}
+
+
+void bpf_jit_compile(struct sk_filter *fp)
+{
+	u8 temp[64];
+	u8 *prog;
+	unsigned int proglen, oldproglen =3D 0;
+	int ilen, i;
+	int t_offset, f_offset;
+	u8 t_op, f_op, seen =3D 0, pass;
+	u8 *image =3D NULL;
+	u8 *func;
+	int pc_ret0 =3D -1; /* bpf index of first RET #0 instruction (if any)=
 */
+	unsigned int cleanup_addr; /* epilogue code offset */
+	unsigned int *addrs;
+	const struct sock_filter *filter =3D fp->insns;
+	int flen =3D fp->len;
+
+	if (!bpf_jit_enable)
+		return;
+
+	addrs =3D kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
+	if (addrs =3D=3D NULL)
+		return;
+
+	/* Before first pass, make a rough estimation of addrs[]
+	 * each bpf instruction is translated to less than 64 bytes
+	 */
+	for (proglen =3D 0, i =3D 0; i < flen; i++) {
+		proglen +=3D 64;
+		addrs[i] =3D proglen;
+	}
+	cleanup_addr =3D proglen; /* epilogue address */
+
+	for (pass =3D 0; pass < 10; pass++) {
+		/* no prologue/epilogue for trivial filters (RET something) */
+		proglen =3D 0;
+		prog =3D temp;
+
+		if (seen) {
+			EMIT4(0x55, 0x48, 0x89, 0xe5); /* push %rbp; mov %rsp,%rbp */
+			EMIT4(0x48, 0x83, 0xec, 96);	/* subq  $96,%rsp	*/
+			/* note : must save %rbx in case bpf_error is hit */
+			if (seen & (SEEN_XREG | SEEN_DATAREF))
+				EMIT4(0x48, 0x89, 0x5d, 0xf8); /* mov %rbx, -8(%rbp) */
+			if (seen & SEEN_XREG)
+				CLEAR_X(); /* make sure we dont leek kernel memory */
+
+			/*
+			 * If this filter needs to access skb data,
+			 * loads r9 and r8 with :
+			 *  r9 =3D skb->len - skb->data_len
+			 *  r8 =3D skb->data
+			 */
+			if (seen & SEEN_DATAREF) {
+				if (offsetof(struct sk_buff, len) <=3D 127)
+					/* mov    off8(%rdi),%r9d */
+					EMIT4(0x44, 0x8b, 0x4f, offsetof(struct sk_buff, len));
+				else {
+					/* mov    off32(%rdi),%r9d */
+					EMIT3(0x44, 0x8b, 0x8f);
+					EMIT(offsetof(struct sk_buff, len), 4);
+				}
+				if (is_imm8(offsetof(struct sk_buff, data_len)))
+					/* sub    off8(%rdi),%r9d */
+					EMIT4(0x44, 0x2b, 0x4f, offsetof(struct sk_buff, data_len));
+				else {
+					EMIT3(0x44, 0x2b, 0x8f);
+					EMIT(offsetof(struct sk_buff, data_len), 4);
+				}
+
+				if (is_imm8(offsetof(struct sk_buff, data)))
+					/* mov off8(%rdi),%r8 */
+					EMIT4(0x4c, 0x8b, 0x47, offsetof(struct sk_buff, data));
+				else {
+					/* mov off32(%rdi),%r8 */
+					EMIT3(0x4c, 0x8b, 0x87);
+					EMIT(offsetof(struct sk_buff, data), 4);
+				}
+			}
+		}
+
+		switch (filter[0].code) {
+		case BPF_S_RET_K:
+		case BPF_S_LD_W_LEN:
+		case BPF_S_ANC_PROTOCOL:
+		case BPF_S_ANC_IFINDEX:
+		case BPF_S_ANC_MARK:
+		case BPF_S_ANC_RXHASH:
+		case BPF_S_ANC_CPU:
+		case BPF_S_ANC_QUEUE:
+		case BPF_S_LD_W_ABS:
+		case BPF_S_LD_H_ABS:
+		case BPF_S_LD_B_ABS:
+			/* first instruction sets A register (or is RET 'constant') */
+			break;
+		default:
+			/* make sure we dont leak kernel information to user */
+			CLEAR_A(); /* A =3D 0 */
+		}
+
+		for (i =3D 0; i < flen; i++) {
+			unsigned int K =3D filter[i].k;
+
+			switch (filter[i].code) {
+			case BPF_S_ALU_ADD_X: /* A +=3D X; */
+				seen |=3D SEEN_XREG;
+				EMIT2(0x01, 0xd8);		/* add %ebx,%eax */
+				break;
+			case BPF_S_ALU_ADD_K: /* A +=3D K; */
+				if (!K)
+					break;
+				if (is_imm8(K))
+					EMIT3(0x83, 0xc0, K);	/* add imm8,%eax */
+				else
+					EMIT1_off32(0x05, K);	/* add imm32,%eax */
+				break;
+			case BPF_S_ALU_SUB_X: /* A -=3D X; */
+				seen |=3D SEEN_XREG;
+				EMIT2(0x29, 0xd8);		/* sub    %ebx,%eax */
+				break;
+			case BPF_S_ALU_SUB_K: /* A -=3D K */
+				if (!K)
+					break;
+				if (is_imm8(K))
+					EMIT3(0x83, 0xe8, K); /* sub imm8,%eax */
+				else
+					EMIT1_off32(0x2d, K); /* sub imm32,%eax */
+				break;
+			case BPF_S_ALU_MUL_X: /* A *=3D X; */
+				seen |=3D SEEN_XREG;
+				EMIT3(0x0f, 0xaf, 0xc3);	/* imul %ebx,%eax */
+				break;
+			case BPF_S_ALU_MUL_K: /* A *=3D K */
+				if (is_imm8(K))
+					EMIT3(0x6b, 0xc0, K); /* imul imm8,%eax,%eax */
+				else {
+					EMIT2(0x69, 0xc0);		/* imul imm32,%eax */
+					EMIT(K, 4);
+				}
+				break;
+			case BPF_S_ALU_DIV_X: /* A /=3D X; */
+				seen |=3D SEEN_XREG;
+				EMIT2(0x85, 0xdb);	/* test %ebx,%ebx */
+				if (pc_ret0 !=3D -1)
+					EMIT_COND_JMP(X86_JE, addrs[pc_ret0] - (addrs[i] - 4));
+				else {
+					EMIT_COND_JMP(X86_JNE, 2 + 5);
+					CLEAR_A();
+					EMIT1_off32(0xe9, cleanup_addr - (addrs[i] - 4)); /* jmp .+off32 =
*/
+				}
+				EMIT4(0x31, 0xd2, 0xf7, 0xf3); /* xor %edx,%edx; div %ebx */
+				break;
+			case BPF_S_ALU_DIV_K: /* A =3D reciprocal_divide(A, K); */
+				EMIT3(0x48, 0x69, 0xc0); /* imul imm32,%rax,%rax */
+				EMIT(K, 4);
+				EMIT4(0x48, 0xc1, 0xe8, 0x20); /* shr $0x20,%rax */
+				break;
+			case BPF_S_ALU_AND_X:
+				seen |=3D SEEN_XREG;
+				EMIT2(0x21, 0xd8);		/* and %ebx,%eax */
+				break;
+			case BPF_S_ALU_AND_K:
+				if (K >=3D 0xFFFFFF00) {
+					EMIT2(0x24, K & 0xFF); /* and imm8,%al */
+				} else if (K >=3D 0xFFFF0000) {
+					EMIT2(0x66, 0x25);	/* and imm16,%ax */
+					EMIT2(K, 2);
+				} else {
+					EMIT1_off32(0x25, K);	/* and imm32,%eax */
+				}
+				break;
+			case BPF_S_ALU_OR_X:
+				seen |=3D SEEN_XREG;
+				EMIT2(0x09, 0xd8);		/* or %ebx,%eax */
+				break;
+			case BPF_S_ALU_OR_K:
+				if (is_imm8(K))
+					EMIT3(0x83, 0xc8, K); /* or imm8,%eax */
+				else
+					EMIT1_off32(0x0d, K);	/* or imm32,%eax */
+				break;
+			case BPF_S_ALU_LSH_X: /* A <<=3D X; */
+				seen |=3D SEEN_XREG;
+				EMIT4(0x89, 0xd9, 0xd3, 0xe0);	/* mov %ebx,%ecx; shl %cl,%eax */
+				break;
+			case BPF_S_ALU_LSH_K:
+				if (K =3D=3D 0)
+					break;
+				else if (K =3D=3D 1)
+					EMIT2(0xd1, 0xe0); /* shl %eax */
+				else
+					EMIT3(0xc1, 0xe0, K);
+				break;
+			case BPF_S_ALU_RSH_X: /* A >>=3D X; */
+				seen |=3D SEEN_XREG;
+				EMIT4(0x89, 0xd9, 0xd3, 0xe8);	/* mov %ebx,%ecx; shr %cl,%eax */
+				break;
+			case BPF_S_ALU_RSH_K: /* A >>=3D K; */
+				if (K =3D=3D 0)
+					break;
+				else if (K =3D=3D 1)
+					EMIT2(0xd1, 0xe8); /* shr %eax */
+				else
+					EMIT3(0xc1, 0xe8, K);
+				break;
+			case BPF_S_ALU_NEG:
+				EMIT2(0xf7, 0xd8);		/* neg %eax */
+				break;
+			case BPF_S_RET_K:
+				if (!K) {
+					if (pc_ret0 =3D=3D -1)
+						pc_ret0 =3D i;
+					CLEAR_A();
+				} else {
+					EMIT1_off32(0xb8, K);	/* mov $imm32,%eax */
+				}
+				/* fallinto */
+			case BPF_S_RET_A:
+				if (seen) {
+					if (i !=3D flen - 1) {
+						EMIT_JMP(cleanup_addr - addrs[i]);
+						break;
+					}
+					if (seen & SEEN_XREG)
+						EMIT4(0x48, 0x8b, 0x5d, 0xf8);  /* mov  -8(%rbp),%rbx */
+					EMIT1(0xc9);		/* leaveq */
+				}
+				EMIT1(0xc3);		/* ret */
+				break;
+			case BPF_S_MISC_TAX: /* X =3D A */
+				seen |=3D SEEN_XREG;
+				EMIT2(0x89, 0xc3);	/* mov    %eax,%ebx */
+				break;
+			case BPF_S_MISC_TXA: /* A =3D X */
+				seen |=3D SEEN_XREG;
+				EMIT2(0x89, 0xd8);	/* mov    %ebx,%eax */
+				break;
+			case BPF_S_LD_IMM: /* A =3D K */
+				if (!K)
+					CLEAR_A();
+				else
+					EMIT1_off32(0xb8, K); /* mov $imm32,%eax */
+				break;
+			case BPF_S_LDX_IMM: /* X =3D K */
+				seen |=3D SEEN_XREG;
+				if (!K)
+					CLEAR_X();
+				else
+					EMIT1_off32(0xbb, K); /* mov $imm32,%ebx */
+				break;
+			case BPF_S_LD_MEM: /* A =3D mem[K] : mov off8(%rbp),%eax */
+				seen |=3D SEEN_MEM;
+				EMIT3(0x8b, 0x45, 0xf0 - K*4);
+				break;
+			case BPF_S_LDX_MEM: /* X =3D mem[K] : mov off8(%rbp),%ebx */
+				seen |=3D SEEN_XREG | SEEN_MEM;
+				EMIT3(0x8b, 0x5d, 0xf0 - K*4);
+				break;
+			case BPF_S_ST: /* mem[K] =3D A : mov %eax,off8(%rbp) */
+				seen |=3D SEEN_MEM;
+				EMIT3(0x89, 0x45, 0xf0 - K*4);
+				break;
+			case BPF_S_STX: /* mem[K] =3D X : mov %ebx,off8(%rbp) */
+				seen |=3D SEEN_XREG | SEEN_MEM;
+				EMIT3(0x89, 0x5d, 0xf0 - K*4);
+				break;
+			case BPF_S_LD_W_LEN: /*	A =3D skb->len; */
+				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) !=3D 4);
+				if (is_imm8(offsetof(struct sk_buff, len)))
+					/* mov    off8(%rdi),%eax */
+					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, len));
+				else {
+					EMIT2(0x8b, 0x87);
+					EMIT(offsetof(struct sk_buff, len), 4);
+				}
+				break;
+			case BPF_S_LDX_W_LEN: /* X =3D skb->len; */
+				seen |=3D SEEN_XREG;
+				if (is_imm8(offsetof(struct sk_buff, len)))
+					/* mov off8(%rdi),%ebx */
+					EMIT3(0x8b, 0x5f, offsetof(struct sk_buff, len));
+				else {
+					EMIT2(0x8b, 0x9f);
+					EMIT(offsetof(struct sk_buff, len), 4);
+				}
+				break;
+			case BPF_S_ANC_PROTOCOL: /* A =3D ntohs(skb->protocol); */
+				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) !=3D 2);
+				if (is_imm8(offsetof(struct sk_buff, protocol))) {
+					/* movzwl off8(%rdi),%eax */
+					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, protocol));
+				} else {
+					EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
+					EMIT(offsetof(struct sk_buff, protocol), 4);
+				}
+				EMIT2(0x86, 0xc4); /* ntohs() : xchg   %al,%ah */
+				break;
+			case BPF_S_ANC_IFINDEX:
+				if (is_imm8(offsetof(struct sk_buff, dev))) {
+					/* movq off8(%rdi),%rax */
+					EMIT4(0x48, 0x8b, 0x47, offsetof(struct sk_buff, dev));
+				} else {
+					EMIT3(0x48, 0x8b, 0x87); /* movq off32(%rdi),%rax */
+					EMIT(offsetof(struct sk_buff, dev), 4);
+				}
+				EMIT3(0x48, 0x85, 0xc0);	/* test %rax,%rax */
+				EMIT_COND_JMP(X86_JE, cleanup_addr - (addrs[i] - 6));
+				BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) !=3D 4);
+				EMIT2(0x8b, 0x80);	/* mov off32(%rax),%eax */
+				EMIT(offsetof(struct net_device, ifindex), 4);
+				break;
+			case BPF_S_ANC_MARK:
+				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) !=3D 4);
+				if (is_imm8(offsetof(struct sk_buff, mark))) {
+					/* mov off8(%rdi),%eax */
+					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, mark));
+				} else {
+					EMIT2(0x8b, 0x87);
+					EMIT(offsetof(struct sk_buff, mark), 4);
+				}
+				break;
+			case BPF_S_ANC_RXHASH:
+				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) !=3D 4);
+				if (is_imm8(offsetof(struct sk_buff, rxhash))) {
+					/* mov off8(%rdi),%eax */
+					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, rxhash));
+				} else {
+					EMIT2(0x8b, 0x87);
+					EMIT(offsetof(struct sk_buff, rxhash), 4);
+				}
+				break;
+			case BPF_S_ANC_QUEUE:
+				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) !=3D 2);
+				if (is_imm8(offsetof(struct sk_buff, queue_mapping))) {
+					/* movzwl off8(%rdi),%eax */
+					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, queue_mapping));
+				} else {
+					EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
+					EMIT(offsetof(struct sk_buff, queue_mapping), 4);
+				}
+				break;
+			case BPF_S_ANC_CPU:
+#ifdef CONFIG_SMP
+				EMIT4(0x65, 0x8b, 0x04, 0x25); /* mov %gs:off32,%eax */
+				EMIT((u32)(unsigned long)&cpu_number, 4); /* A =3D smp_processor_i=
d(); */
+#else
+				CLEAR_A();
+#endif
+				break;
+			case BPF_S_LD_W_ABS:
+				func =3D sk_load_word;
+common_load:			seen |=3D SEEN_DATAREF;
+				if ((int)K < 0)
+					goto out;
+				t_offset =3D func - (image + addrs[i]);
+				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
+				EMIT1_off32(0xe8, t_offset); /* call */
+				break;
+			case BPF_S_LD_H_ABS:
+				func =3D sk_load_half;
+				goto common_load;
+			case BPF_S_LD_B_ABS:
+				func =3D sk_load_byte;
+				goto common_load;
+			case BPF_S_LDX_B_MSH:
+				if ((int)K < 0) {
+					if (pc_ret0 !=3D -1) {
+						EMIT_JMP(addrs[pc_ret0] - addrs[i]);
+						break;
+					}
+					CLEAR_A();
+					EMIT_JMP(cleanup_addr - addrs[i]);
+					break;
+				}
+				seen |=3D SEEN_DATAREF | SEEN_XREG;
+				t_offset =3D sk_load_byte_msh - (image + addrs[i]);
+				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
+				EMIT1_off32(0xe8, t_offset); /* call sk_load_byte_msh */
+				break;
+			case BPF_S_LD_W_IND:
+				func =3D sk_load_word_ind;
+common_load_ind:		seen |=3D SEEN_DATAREF | SEEN_XREG;
+				t_offset =3D func - (image + addrs[i]);
+				EMIT1_off32(0xbe, K);	/* mov imm32,%esi   */
+				EMIT1_off32(0xe8, t_offset);	/* call sk_load_xxx_ind */
+				break;
+			case BPF_S_LD_H_IND:
+				func =3D sk_load_half_ind;
+				goto common_load_ind;
+			case BPF_S_LD_B_IND:
+				func =3D sk_load_byte_ind;
+				goto common_load_ind;
+			case BPF_S_JMP_JA:
+				t_offset =3D addrs[i + K] - addrs[i];
+				EMIT_JMP(t_offset);
+				break;
+			COND_SEL(BPF_S_JMP_JGT_K, X86_JA, X86_JBE);
+			COND_SEL(BPF_S_JMP_JGE_K, X86_JAE, X86_JB);
+			COND_SEL(BPF_S_JMP_JEQ_K, X86_JE, X86_JNE);
+			COND_SEL(BPF_S_JMP_JSET_K,X86_JNE, X86_JE);
+			COND_SEL(BPF_S_JMP_JGT_X, X86_JA, X86_JBE);
+			COND_SEL(BPF_S_JMP_JGE_X, X86_JAE, X86_JB);
+			COND_SEL(BPF_S_JMP_JEQ_X, X86_JE, X86_JNE);
+			COND_SEL(BPF_S_JMP_JSET_X,X86_JNE, X86_JE);
+
+cond_branch:			f_offset =3D addrs[i + filter[i].jf] - addrs[i];
+				t_offset =3D addrs[i + filter[i].jt] - addrs[i];
+
+				/* same targets, can avoid doing the test :) */
+				if (filter[i].jt =3D=3D filter[i].jf) {
+					EMIT_JMP(t_offset);
+					break;
+				}
+
+				switch (filter[i].code) {
+				case BPF_S_JMP_JGT_X:
+				case BPF_S_JMP_JGE_X:
+				case BPF_S_JMP_JEQ_X:
+					seen |=3D SEEN_XREG;
+					EMIT2(0x39, 0xd8); /* cmp %ebx,%eax */
+					break;
+				case BPF_S_JMP_JSET_X:
+					seen |=3D SEEN_XREG;
+					EMIT2(0x85, 0xd8); /* test %ebx,%eax */
+					break;
+				case BPF_S_JMP_JEQ_K:
+					if (K =3D=3D 0) {
+						EMIT2(0x85, 0xc0); /* test   %eax,%eax */
+						break;
+					}
+				case BPF_S_JMP_JGT_K:
+				case BPF_S_JMP_JGE_K:
+					if (K <=3D 127)
+						EMIT3(0x83, 0xf8, K); /* cmp imm8,%eax */
+					else
+						EMIT1_off32(0x3d, K); /* cmp imm32,%eax */
+					break;
+				case BPF_S_JMP_JSET_K:
+					if (K <=3D 0xFF)
+						EMIT2(0xa8, K); /* test imm8,%al */
+					else if (!(K & 0xFFFF00FF))
+						EMIT3(0xf6, 0xc4, K >> 8); /* test imm8,%ah */
+					else if (K <=3D 0xFFFF) {
+						EMIT2(0x66, 0xa9); /* test imm16,%ax */
+						EMIT(K, 2);
+					} else {
+						EMIT1_off32(0xa9, K); /* test imm32,%eax */
+					}
+					break;
+				}
+				if (filter[i].jt !=3D 0) {
+					if (filter[i].jf)
+						t_offset +=3D is_near(f_offset) ? 2 : 6;
+					EMIT_COND_JMP(t_op, t_offset);
+					if (filter[i].jf)
+						EMIT_JMP(f_offset);
+					break;
+				}
+				EMIT_COND_JMP(f_op, f_offset);
+				break;
+			default:
+				/* hmm, too complex filter, give up with jit compiler */
+				goto out;
+			}
+			ilen =3D prog - temp;
+			if (image) {
+				if (unlikely(proglen + ilen > oldproglen)) {
+					pr_err("bpb_jit_compile fatal error\n");
+					kfree(addrs);
+					module_free(NULL, image);
+					return;
+				}
+				memcpy(image + proglen, temp, ilen);
+			}
+			proglen +=3D ilen;
+			addrs[i] =3D proglen;
+			prog =3D temp;
+		}
+		/* last bpf instruction is always a RET :
+		 * use it to give the cleanup instruction(s) addr
+		 */
+		cleanup_addr =3D proglen - 1; /* ret */
+		if (seen)
+			cleanup_addr -=3D 1; /* leaveq */
+		if (seen & SEEN_XREG)
+			cleanup_addr -=3D 4; /* mov  -8(%rbp),%rbx */
+
+		if (image) {
+			WARN_ON(proglen !=3D oldproglen);
+			break;
+		}
+		if (proglen =3D=3D oldproglen) {
+			image =3D module_alloc(max_t(unsigned int,
+						   proglen,
+						   sizeof(struct work_struct)));
+			if (!image)
+				goto out;
+		}
+		oldproglen =3D proglen;
+	}
+	if (bpf_jit_enable > 1)
+		pr_err("flen=3D%d proglen=3D%u pass=3D%d image=3D%p\n",
+		       flen, proglen, pass, image);
+
+	if (image) {
+		if (bpf_jit_enable > 1)
+			print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
+				       16, 1, image, proglen, false);
+
+		bpf_flush_icache(image, image + proglen);
+
+		fp->bpf_func =3D (void *)image;
+	}
+out:
+	kfree(addrs);
+	return;
+}
+
+static void jit_free_defer(struct work_struct *arg)
+{
+	module_free(NULL, arg);
+}
+
+/* run from softirq, we must use a work_struct to call
+ * module_free() from process context
+ */
+void bpf_jit_free(struct sk_filter *fp)
+{
+	if (fp->bpf_func !=3D sk_run_filter) {
+		struct work_struct *work =3D (struct work_struct *)fp->bpf_func;
+
+		INIT_WORK(work, jit_free_defer);
+		schedule_work(work);
+	}
+}
+
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 45266b7..4609b85 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -135,6 +135,8 @@ struct sk_filter
 {
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
+	unsigned int		(*bpf_func)(const struct sk_buff *skb,
+					    const struct sock_filter *filter);
 	struct rcu_head		rcu;
 	struct sock_filter     	insns[0];
 };
@@ -153,6 +155,80 @@ extern unsigned int sk_run_filter(const struct sk_=
buff *skb,
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)=
;
 extern int sk_detach_filter(struct sock *sk);
 extern int sk_chk_filter(struct sock_filter *filter, int flen);
+
+#ifdef CONFIG_BPF_JIT
+extern void bpf_jit_compile(struct sk_filter *fp);
+extern void bpf_jit_free(struct sk_filter *fp);
+#define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->in=
sns)
+#else
+static inline void bpf_jit_compile(struct sk_filter *fp)
+{
+}
+static inline void bpf_jit_free(struct sk_filter *fp)
+{
+}
+#define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
+#endif
+
+enum {
+	BPF_S_RET_K =3D 1,
+	BPF_S_RET_A,
+	BPF_S_ALU_ADD_K,
+	BPF_S_ALU_ADD_X,
+	BPF_S_ALU_SUB_K,
+	BPF_S_ALU_SUB_X,
+	BPF_S_ALU_MUL_K,
+	BPF_S_ALU_MUL_X,
+	BPF_S_ALU_DIV_X,
+	BPF_S_ALU_AND_K,
+	BPF_S_ALU_AND_X,
+	BPF_S_ALU_OR_K,
+	BPF_S_ALU_OR_X,
+	BPF_S_ALU_LSH_K,
+	BPF_S_ALU_LSH_X,
+	BPF_S_ALU_RSH_K,
+	BPF_S_ALU_RSH_X,
+	BPF_S_ALU_NEG,
+	BPF_S_LD_W_ABS,
+	BPF_S_LD_H_ABS,
+	BPF_S_LD_B_ABS,
+	BPF_S_LD_W_LEN,
+	BPF_S_LD_W_IND,
+	BPF_S_LD_H_IND,
+	BPF_S_LD_B_IND,
+	BPF_S_LD_IMM,
+	BPF_S_LDX_W_LEN,
+	BPF_S_LDX_B_MSH,
+	BPF_S_LDX_IMM,
+	BPF_S_MISC_TAX,
+	BPF_S_MISC_TXA,
+	BPF_S_ALU_DIV_K,
+	BPF_S_LD_MEM,
+	BPF_S_LDX_MEM,
+	BPF_S_ST,
+	BPF_S_STX,
+	BPF_S_JMP_JA,
+	BPF_S_JMP_JEQ_K,
+	BPF_S_JMP_JEQ_X,
+	BPF_S_JMP_JGE_K,
+	BPF_S_JMP_JGE_X,
+	BPF_S_JMP_JGT_K,
+	BPF_S_JMP_JGT_X,
+	BPF_S_JMP_JSET_K,
+	BPF_S_JMP_JSET_X,
+	/* Ancillary data */
+	BPF_S_ANC_PROTOCOL,
+	BPF_S_ANC_PKTTYPE,
+	BPF_S_ANC_IFINDEX,
+	BPF_S_ANC_NLATTR,
+	BPF_S_ANC_NLATTR_NEST,
+	BPF_S_ANC_MARK,
+	BPF_S_ANC_QUEUE,
+	BPF_S_ANC_HATYPE,
+	BPF_S_ANC_RXHASH,
+	BPF_S_ANC_CPU,
+};
+
 #endif /* __KERNEL__ */
=20
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb8178a..364bcf2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2514,6 +2514,7 @@ extern struct rtnl_link_stats64 *dev_get_stats(st=
ruct net_device *dev,
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
+extern int		bpf_jit_enable;
 extern int		netdev_set_master(struct net_device *dev, struct net_devic=
e *master);
 extern int netdev_set_bond_master(struct net_device *dev,
 				  struct net_device *master);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d0ae90a..79aafbb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -391,8 +391,8 @@ struct sk_buff {
=20
 	__u32			rxhash;
=20
+	__u16			queue_mapping;
 	kmemcheck_bitfield_begin(flags2);
-	__u16			queue_mapping:16;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
diff --git a/net/Kconfig b/net/Kconfig
index 79cabf1..745fb02 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -232,6 +232,19 @@ config XPS
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
=20
+config HAVE_BPF_JIT
+	bool
+
+config BPF_JIT
+	bool "enable BPF Just In Time compiler"
+	depends on HAVE_BPF_JIT
+	---help---
+	  Berkeley Packet Filter filtering capabilities are normally handled
+	  by an interpreter. This option allows kernel to generate a native
+	  code when filter is loaded in memory. This should speedup
+	  packet sniffing (libpcap/tcpdump). Note : Admin should enable
+	  this feature changing /proc/sys/net/core/bpf_jit_enable
+
 menu "Network testing"
=20
 config NET_PKTGEN
diff --git a/net/core/filter.c b/net/core/filter.c
index afb8afb..0eb8c44 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -39,65 +39,6 @@
 #include <linux/filter.h>
 #include <linux/reciprocal_div.h>
=20
-enum {
-	BPF_S_RET_K =3D 1,
-	BPF_S_RET_A,
-	BPF_S_ALU_ADD_K,
-	BPF_S_ALU_ADD_X,
-	BPF_S_ALU_SUB_K,
-	BPF_S_ALU_SUB_X,
-	BPF_S_ALU_MUL_K,
-	BPF_S_ALU_MUL_X,
-	BPF_S_ALU_DIV_X,
-	BPF_S_ALU_AND_K,
-	BPF_S_ALU_AND_X,
-	BPF_S_ALU_OR_K,
-	BPF_S_ALU_OR_X,
-	BPF_S_ALU_LSH_K,
-	BPF_S_ALU_LSH_X,
-	BPF_S_ALU_RSH_K,
-	BPF_S_ALU_RSH_X,
-	BPF_S_ALU_NEG,
-	BPF_S_LD_W_ABS,
-	BPF_S_LD_H_ABS,
-	BPF_S_LD_B_ABS,
-	BPF_S_LD_W_LEN,
-	BPF_S_LD_W_IND,
-	BPF_S_LD_H_IND,
-	BPF_S_LD_B_IND,
-	BPF_S_LD_IMM,
-	BPF_S_LDX_W_LEN,
-	BPF_S_LDX_B_MSH,
-	BPF_S_LDX_IMM,
-	BPF_S_MISC_TAX,
-	BPF_S_MISC_TXA,
-	BPF_S_ALU_DIV_K,
-	BPF_S_LD_MEM,
-	BPF_S_LDX_MEM,
-	BPF_S_ST,
-	BPF_S_STX,
-	BPF_S_JMP_JA,
-	BPF_S_JMP_JEQ_K,
-	BPF_S_JMP_JEQ_X,
-	BPF_S_JMP_JGE_K,
-	BPF_S_JMP_JGE_X,
-	BPF_S_JMP_JGT_K,
-	BPF_S_JMP_JGT_X,
-	BPF_S_JMP_JSET_K,
-	BPF_S_JMP_JSET_X,
-	/* Ancillary data */
-	BPF_S_ANC_PROTOCOL,
-	BPF_S_ANC_PKTTYPE,
-	BPF_S_ANC_IFINDEX,
-	BPF_S_ANC_NLATTR,
-	BPF_S_ANC_NLATTR_NEST,
-	BPF_S_ANC_MARK,
-	BPF_S_ANC_QUEUE,
-	BPF_S_ANC_HATYPE,
-	BPF_S_ANC_RXHASH,
-	BPF_S_ANC_CPU,
-};
-
 /* No hurry in this branch */
 static void *__load_pointer(const struct sk_buff *skb, int k, unsigned=
 int size)
 {
@@ -145,7 +86,7 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	rcu_read_lock();
 	filter =3D rcu_dereference(sk->sk_filter);
 	if (filter) {
-		unsigned int pkt_len =3D sk_run_filter(skb, filter->insns);
+		unsigned int pkt_len =3D SK_RUN_FILTER(filter, skb);
=20
 		err =3D pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
 	}
@@ -638,6 +579,7 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp =3D container_of(rcu, struct sk_filter, rcu);
=20
+	bpf_jit_free(fp);
 	kfree(fp);
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
@@ -672,6 +614,7 @@ int sk_attach_filter(struct sock_fprog *fprog, stru=
ct sock *sk)
=20
 	atomic_set(&fp->refcnt, 1);
 	fp->len =3D fprog->len;
+	fp->bpf_func =3D sk_run_filter;
=20
 	err =3D sk_chk_filter(fp->insns, fp->len);
 	if (err) {
@@ -679,6 +622,8 @@ int sk_attach_filter(struct sock_fprog *fprog, stru=
ct sock *sk)
 		return err;
 	}
=20
+	bpf_jit_compile(fp);
+
 	old_fp =3D rcu_dereference_protected(sk->sk_filter,
 					   sock_owned_by_user(sk));
 	rcu_assign_pointer(sk->sk_filter, fp);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 385b609..a829e3f 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -122,6 +122,15 @@ static struct ctl_table net_core_table[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec
 	},
+#ifdef CONFIG_BPF_JIT
+	{
+		.procname	=3D "bpf_jit_enable",
+		.data		=3D &bpf_jit_enable,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec
+	},
+#endif
 	{
 		.procname	=3D "netdev_tstamp_prequeue",
 		.data		=3D &netdev_tstamp_prequeue,
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5362e9..549527b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -538,7 +538,7 @@ static inline unsigned int run_filter(const struct =
sk_buff *skb,
 	rcu_read_lock();
 	filter =3D rcu_dereference(sk->sk_filter);
 	if (filter !=3D NULL)
-		res =3D sk_run_filter(skb, filter->insns);
+		res =3D SK_RUN_FILTER(filter, skb);
 	rcu_read_unlock();
=20
 	return res;


