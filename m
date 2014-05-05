From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 10/24] net, diet: Make LPF filter optional
Date: Mon,  5 May 2014 15:25:59 -0700
Message-ID: <1399328773-6531-11-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Small systems don't need the LPF filter, so make it all
optional

Saves about 4K text

   text	   data	    bss	    dec	    hex	filename
 483545	  19371	  13480	 516396	  7e12c	net/built-in.o-wo-filter
 487675	  19275	  13480	 520430	  7f0ee	net/built-in.o-with-filter

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 drivers/net/team/Kconfig |  1 +
 include/linux/filter.h   | 28 +++++++++++++++++++++++++++-
 init/Kconfig             |  7 +++++++
 net/Kconfig              |  8 ++++++++
 net/core/Makefile        |  3 ++-
 net/netfilter/Kconfig    |  1 +
 net/sched/Kconfig        |  1 +
 7 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/Kconfig b/drivers/net/team/Kconfig
index c853d84..7c5a373 100644
--- a/drivers/net/team/Kconfig
+++ b/drivers/net/team/Kconfig
@@ -64,6 +64,7 @@ config NET_TEAM_MODE_ACTIVEBACKUP
 
 config NET_TEAM_MODE_LOADBALANCE
 	tristate "Load-balance mode support"
+	select LPF_FILTER
 	depends on NET_TEAM
 	---help---
 	  This mode provides load balancing functionality. Tx port selection
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 024fd03..ec1db56 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -97,9 +97,9 @@ static inline unsigned int sk_filter_size(unsigned int proglen)
 #define sk_filter_proglen(fprog)			\
 		(fprog->len * sizeof(fprog->filter[0]))
 
+#ifdef CONFIG_LPF_FILTER
 #define SK_RUN_FILTER(filter, ctx)			\
 		(*filter->bpf_func)(ctx, filter->insnsi)
-
 int sk_filter(struct sock *sk, struct sk_buff *skb);
 
 u32 sk_run_filter_int_seccomp(const struct seccomp_data *ctx,
@@ -124,6 +124,32 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
 
 void sk_filter_charge(struct sock *sk, struct sk_filter *fp);
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
+#else
+#define SK_RUN_FILTER(filter, ctx) 0
+static inline int
+sk_filter(struct sock *sk, struct sk_buff *skb) { return 0; }
+static inline u32 sk_run_filter_int_seccomp(const struct seccomp_data *ctx,
+			      const struct sock_filter_int *insni)
+{ return 0; }
+static inline u32 sk_run_filter_int_skb(const struct sk_buff *ctx,
+			  const struct sock_filter_int *insni)
+{ return 0; }
+static inline int sk_unattached_filter_create(struct sk_filter **pfp,
+				       struct sock_fprog *fprog)
+{ return -EINVAL; }
+static inline void sk_unattached_filter_destroy(struct sk_filter *fp) {}
+static inline int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
+{ return -EINVAL; }
+static inline int sk_detach_filter(struct sock *sk) { return -EINVAL; }
+static inline int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
+{ return 0; }
+static inline int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len)
+{ return -EINVAL; }
+static inline void
+sk_decode_filter(struct sock_filter *filt, struct sock_filter *to) {}
+static inline void sk_filter_charge(struct sock *sk, struct sk_filter *fp) {}
+static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp) {}
+#endif
 
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
diff --git a/init/Kconfig b/init/Kconfig
index 9d3585b..31eccd6 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1885,4 +1885,11 @@ config ASN1
 	  inform it as to what tags are to be expected in a stream and what
 	  functions to call on what tags.
 
+# Automatically enable LPF_FILTER when any architecture sets SECCOMP
+config SECCOMP_ENABLE_LPF
+	bool
+	depends on SECCOMP
+	default y
+	select LPF_FILTER
+
 source "kernel/Kconfig.locks"
diff --git a/net/Kconfig b/net/Kconfig
index 281d172..82a5764 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -88,6 +88,13 @@ config NET_ETHTOOL
 	help
 	  Support changing ethernet driver parameters from user tools.
 
+# XXX seccomp and other users should auto enable?
+config LPF_FILTER
+	bool "LPF filter"
+	default y
+	help
+	  Enable BPF/LPF (Linux Packet Filter) filtering on sockets.
+
 config NETWORK_SECMARK
 	bool "Security Marking"
 	help
@@ -275,6 +282,7 @@ config BQL
 config BPF_JIT
 	bool "enable BPF Just In Time compiler"
 	depends on HAVE_BPF_JIT
+	depends on LPF_FILTER
 	depends on MODULES
 	---help---
 	  Berkeley Packet Filter filtering capabilities are normally handled
diff --git a/net/core/Makefile b/net/core/Makefile
index bfd28b1..7db2fff 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -8,7 +8,7 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o dev_addr_lists.o dst.o netevent.o \
-			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
+			neighbour.o rtnetlink.o utils.o link_watch.o \
 			sock_diag.o dev_ioctl.o
 
 obj-$(CONFIG_XFRM) += flow.o
@@ -16,6 +16,7 @@ obj-y += net-sysfs.o
 obj-$(CONFIG_NET_ETHTOOL) += ethtool.o
 obj-$(CONFIG_PROC_FS) += net-procfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
+obj-$(CONFIG_LPF_FILTER) += filter.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e9410d1..5bc1ef2 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -921,6 +921,7 @@ config NETFILTER_XT_MATCH_ADDRTYPE
 config NETFILTER_XT_MATCH_BPF
 	tristate '"bpf" match support'
 	depends on NETFILTER_ADVANCED
+	select LPF_FILTER
 	help
 	  BPF matching applies a linux socket filter to each packet and
 	  accepts those for which the filter returns non-zero.
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index a1a8e29..a0a4f96 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -469,6 +469,7 @@ config NET_CLS_CGROUP
 config NET_CLS_BPF
 	tristate "BPF-based classifier"
 	select NET_CLS
+	select LPF_FILTER
 	---help---
 	  If you say Y here, you will be able to classify packets based on
 	  programmable BPF (JIT'ed) filters as an alternative to ematches.
-- 
1.9.0
