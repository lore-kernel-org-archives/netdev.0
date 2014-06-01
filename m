From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/2] net: filter: split BPF out of core networking
Date: Sat, 31 May 2014 18:42:21 -0700
Message-ID: <1401586941-4274-3-git-send-email-ast@plumgrid.com>
References: <1401586941-4274-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401586941-4274-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

seccomp selects BPF only instead of whole NET
Other BPF users (like tracing filters) will select BPF only too

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/Kconfig   |    3 ++-
 net/Kconfig    |    4 ++++
 net/Makefile   |    2 +-
 net/bpf/core.c |   21 +++++++++++++++++++++
 4 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 97ff872c7acc..92f43a16eccc 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -324,7 +324,8 @@ config HAVE_ARCH_SECCOMP_FILTER
 
 config SECCOMP_FILTER
 	def_bool y
-	depends on HAVE_ARCH_SECCOMP_FILTER && SECCOMP && NET
+	depends on HAVE_ARCH_SECCOMP_FILTER && SECCOMP
+	select BPF
 	help
 	  Enable tasks to build secure computing environments defined
 	  in terms of Berkeley Packet Filter programs which implement
diff --git a/net/Kconfig b/net/Kconfig
index d92afe4204d9..e8dca9f836d9 100644
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
@@ -370,6 +371,9 @@ source "net/nfc/Kconfig"
 
 endif   # if NET
 
+config BPF
+	boolean
+
 # Used by archs to tell that they support BPF_JIT
 config HAVE_BPF_JIT
 	bool
diff --git a/net/Makefile b/net/Makefile
index d0e89323aee3..d56447bca1aa 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -8,7 +8,7 @@
 obj-y	:= nonet.o
 
 obj-$(CONFIG_NET)		:= socket.o core/
-obj-$(CONFIG_NET)		+= bpf/
+obj-$(CONFIG_BPF)		+= bpf/
 
 tmp-$(CONFIG_COMPAT) 		:= compat.o
 obj-$(CONFIG_NET)		+= $(tmp-y)
diff --git a/net/bpf/core.c b/net/bpf/core.c
index 22c2d99414c0..8ca1b37ddc28 100644
--- a/net/bpf/core.c
+++ b/net/bpf/core.c
@@ -1040,3 +1040,24 @@ void sk_filter_free(struct sk_filter *fp)
 	bpf_jit_free(fp);
 }
 EXPORT_SYMBOL_GPL(sk_filter_free);
+
+/* kernel configuration that do not enable NET are not using
+ * classic BPF extensions
+ */
+bool __weak sk_convert_bpf_extensions(struct sock_filter *fp,
+				      struct sock_filter_int **insnp)
+{
+	return false;
+}
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
-- 
1.7.9.5
