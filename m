From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC v7 net-next 16/28] bpf: split eBPF out of NET
Date: Tue, 26 Aug 2014 19:29:30 -0700
Message-ID: <1409106582-10095-17-git-send-email-ast@plumgrid.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
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
In-Reply-To: <1409106582-10095-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

let eBPF have its own CONFIG_BPF, so that tracing and other subsystems don't
need to depend on all of NET

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 arch/Kconfig      |    3 +++
 kernel/Makefile   |    2 +-
 kernel/bpf/core.c |   12 ++++++++++++
 net/Kconfig       |    1 +
 4 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 0eae9df35b88..80a72f6f6b60 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -333,6 +333,9 @@ config SECCOMP_FILTER
 
 	  See Documentation/prctl/seccomp_filter.txt for details.
 
+config BPF
+	boolean
+
 config HAVE_CC_STACKPROTECTOR
 	bool
 	help
diff --git a/kernel/Makefile b/kernel/Makefile
index dc5c77544fd6..17ea6d4a9a24 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -86,7 +86,7 @@ obj-$(CONFIG_RING_BUFFER) += trace/
 obj-$(CONFIG_TRACEPOINTS) += trace/
 obj-$(CONFIG_IRQ_WORK) += irq_work.o
 obj-$(CONFIG_CPU_PM) += cpu_pm.o
-obj-$(CONFIG_NET) += bpf/
+obj-$(CONFIG_BPF) += bpf/
 
 obj-$(CONFIG_PERF_EVENTS) += events/
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 0434c2170f2b..c17ba0ef3dcf 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -537,3 +537,15 @@ void bpf_prog_free(struct bpf_prog *fp)
 	bpf_jit_free(fp);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_free);
+
+/* To emulate LD_ABS/LD_IND instructions __sk_run_filter() may call
+ * skb_copy_bits(), so provide a weak definition for it in NET-less config.
+ * seccomp_check_filter() verifies that seccomp filters are not using
+ * LD_ABS/LD_IND instructions. Other BPF users (like tracing filters)
+ * must not use these instructions unless ctx==skb
+ */
+int __weak skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
+			 int len)
+{
+	return -EFAULT;
+}
diff --git a/net/Kconfig b/net/Kconfig
index 4051fdfa4367..9a99e16d6f28 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -6,6 +6,7 @@ menuconfig NET
 	bool "Networking support"
 	select NLATTR
 	select GENERIC_NET_UTILS
+	select BPF
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
 	  The reason is that some programs need kernel networking support even
-- 
1.7.9.5
