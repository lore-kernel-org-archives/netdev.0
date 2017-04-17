From: David Miller <davem@redhat.com>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Mon, 17 Apr 2017 16:12:50 -0400 (EDT)
Message-ID: <20170417.161250.104252645310622929.davem@redhat.com>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
        <58F50D13.3090001@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <58F50D13.3090001@iogearbox.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 17 Apr 2017 20:44:35 +0200

> On a quick initial glance, you also need to map BPF_REG_AX. If
> I understand the convention correctly, you could use L7 for that.
> 
> You can test for it through tools/testing/selftests/bpf/test_kmod.sh
> which exercises the test_bpf.ko under various sysctl combinations as
> part of the BPF selftest suite.

Ok, blinding works properly with this fix:

--- arch/sparc/net/bpf_jit.h~	2017-04-13 17:44:24.084936201 -0700
+++ arch/sparc/net/bpf_jit.h	2017-04-17 12:07:22.559029482 -0700
@@ -17,8 +17,10 @@
 #ifndef __ASSEMBLER__
 #define G0		0x00
 #define G1		0x01
+#define G2		0x02
 #define G3		0x03
 #define G6		0x06
+#define G7		0x07
 #define O0		0x08
 #define O1		0x09
 #define O2		0x0a
--- arch/sparc/net/bpf_jit_comp.c~	2017-04-16 20:24:49.060342700 -0700
+++ arch/sparc/net/bpf_jit_comp.c	2017-04-17 12:05:08.470048483 -0700
@@ -195,10 +195,12 @@ static const int bpf2sparc[] = {
 	/* read-only frame pointer to access stack */
 	[BPF_REG_FP] = FP,
 
+	[BPF_REG_AX] = G7,
+
 	/* temporary register for internal BPF JIT */
 	[TMP_REG_1] = G1,
-	[TMP_REG_2] = G3,
-	[TMP_REG_3] = L6,
+	[TMP_REG_2] = G2,
+	[TMP_REG_3] = G3,
 
 	[SKB_HLEN_REG] = L4,
 	[SKB_DATA_REG] = L5,
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -31,7 +31,8 @@ config SPARC
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select GENERIC_PCI_IOMAP
 	select HAVE_NMI_WATCHDOG if SPARC64
-	select HAVE_CBPF_JIT
+	select HAVE_CBPF_JIT if SPARC32
+	select HAVE_EBPF_JIT if SPARC64
 	select HAVE_DEBUG_BUGVERBOSE
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_CLOCKEVENTS
