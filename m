From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: split eBPF out of NET
Date: Thu, 23 Oct 2014 18:41:08 -0700
Message-ID: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:64319 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbaJXBlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 21:41:17 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so521536pde.14
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 18:41:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce two configs:
- hidden CONFIG_BPF to select eBPF interpreter that classic socket filters
  depend on
- visible CONFIG_BPF_SYSCALL (default off) that tracing and sockets can use

that solves several problems:
- tracing and others that wish to use eBPF don't need to depend on NET.
  They can use BPF_SYSCALL to allow loading from userspace or select BPF
  to use it directly from kernel in NET-less configs.
- in 3.18 programs cannot be attached to events yet, so don't force it on
- when the rest of eBPF infra is there in 3.19+, it's still useful to
  switch it off to minimize kernel size

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

bloat-o-meter on x64 shows:
add/remove: 0/60 grow/shrink: 0/2 up/down: 0/-15601 (-15601)

tested with many different config combinations. Hopefully didn't miss anything.

 init/Kconfig        |   14 ++++++++++++++
 kernel/Makefile     |    2 +-
 kernel/bpf/Makefile |    6 +++---
 kernel/bpf/core.c   |    9 +++++++++
 net/Kconfig         |    2 +-
 5 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 3ee28ae..340fd92 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1341,6 +1341,10 @@ config SYSCTL_ARCH_UNALIGN_ALLOW
 config HAVE_PCSPKR_PLATFORM
 	bool
 
+# interpreter that classic socket filters depend on
+config BPF
+	boolean
+
 menuconfig EXPERT
 	bool "Configure standard kernel features (expert users)"
 	# Unhide debug options, to make the on-by-default options visible
@@ -1521,6 +1525,16 @@ config EVENTFD
 
 	  If unsure, say Y.
 
+# syscall, maps, verifier
+config BPF_SYSCALL
+	bool "Enable bpf() system call" if EXPERT
+	select ANON_INODES
+	select BPF
+	default n
+	help
+	  Enable the bpf() system call that allows to manipulate eBPF
+	  programs and maps via file descriptors.
+
 config SHMEM
 	bool "Use full shmem filesystem" if EXPERT
 	default y
diff --git a/kernel/Makefile b/kernel/Makefile
index dc5c775..17ea6d4 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -86,7 +86,7 @@ obj-$(CONFIG_RING_BUFFER) += trace/
 obj-$(CONFIG_TRACEPOINTS) += trace/
 obj-$(CONFIG_IRQ_WORK) += irq_work.o
 obj-$(CONFIG_CPU_PM) += cpu_pm.o
-obj-$(CONFIG_NET) += bpf/
+obj-$(CONFIG_BPF) += bpf/
 
 obj-$(CONFIG_PERF_EVENTS) += events/
 
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 4542723..0daf7f6 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,5 +1,5 @@
-obj-y := core.o syscall.o verifier.o
-
+obj-y := core.o
+obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o
 ifdef CONFIG_TEST_BPF
-obj-y += test_stub.o
+obj-$(CONFIG_BPF_SYSCALL) += test_stub.o
 endif
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index f0c30c5..d6594e4 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -655,3 +655,12 @@ void bpf_prog_free(struct bpf_prog *fp)
 	schedule_work(&aux->work);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_free);
+
+/* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
+ * skb_copy_bits(), so provide a weak definition of it for NET-less config.
+ */
+int __weak skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
+			 int len)
+{
+	return -EFAULT;
+}
diff --git a/net/Kconfig b/net/Kconfig
index 6272420..99815b5 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -6,7 +6,7 @@ menuconfig NET
 	bool "Networking support"
 	select NLATTR
 	select GENERIC_NET_UTILS
-	select ANON_INODES
+	select BPF
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
 	  The reason is that some programs need kernel networking support even
-- 
1.7.9.5
