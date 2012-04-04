From: Nuno Martins <nuno.martins@caixamagica.pt>
Subject: [RFC PATCH 1/2] Multiple filter function support for BPF filters
Date: Wed,  4 Apr 2012 10:16:16 +0100
Message-ID: <a9f81a4efa0505e2f6420c19c476682b6d3509cf.1333466900.git.nuno.martins@caixamagica.pt>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
Cc: Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: netdev <netdev@vger.kernel.org>, nuno.martins@caixamagica.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35689 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602Ab2DDJQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:16:29 -0400
Received: by mail-bk0-f46.google.com with SMTP id ik5so59839bkc.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:16:28 -0700 (PDT)
In-Reply-To: <cover.1333466900.git.nuno.martins@caixamagica.pt>
In-Reply-To: <cover.1333466900.git.nuno.martins@caixamagica.pt>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the possibility of attaching multiple filter functions to a PF socket, useful for custom packet filtering.
It maintains a list of registered functions, received through setsockopt from userspace.
The custom filtering functions are compatible with BPF/LSF filter in order to retain compatibility with sk_run_filter and the pcap library.

This mechanism was developed to support the network monitoring by process id on the kernel (second patch in this series).

Signed-off-by: Nuno Martins <nuno.martins@caixamagica.pt>
---
 include/asm-generic/socket.h |    4 ++
 include/linux/filter.h       |    3 +-
 include/linux/socket.h       |   28 +++++++++
 net/Kconfig                  |    8 +++
 net/core/Makefile            |    3 +-
 net/core/filter.c            |    3 +-
 net/core/filter_function.c   |  138 ++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c              |   23 ++++++-
 8 files changed, 206 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index b1bea03..89c45a9 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -72,4 +72,8 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#ifdef CONFIG_FILTER_FUNCTION
+#define SO_ATTACH_FILTER_FUNC	44
+#define SO_DETACH_FILTER_FUNC	45
+#endif
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8eeb205..8d2d9c2 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -90,6 +90,7 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define BPF_MISCOP(code) ((code) & 0xf8)
 #define         BPF_TAX         0x00
 #define         BPF_TXA         0x80
+#define         BPF_PROC        0xf0
 
 #ifndef BPF_MAXINSNS
 #define BPF_MAXINSNS 4096
@@ -168,7 +169,7 @@ static inline void bpf_jit_compile(struct sk_filter *fp)
 static inline void bpf_jit_free(struct sk_filter *fp)
 {
 }
-#define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
+#define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
 #endif
 
 enum {
diff --git a/include/linux/socket.h b/include/linux/socket.h
index da2d3e2..12acea5 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -316,6 +316,34 @@ struct ucred {
 /* IPX options */
 #define IPX_TYPE	1
 
+#ifdef CONFIG_FILTER_FUNCTION
+#define FILTER_FUNCTION_NAME_LEN 25
+struct filter_function_struct {
+	char name[FILTER_FUNCTION_NAME_LEN];
+	int pid;
+};
+
+#include <linux/list.h>
+
+struct sk_buff;
+struct sock_filter;
+struct sock;
+struct sk_filter;
+
+struct filter_function {
+	struct list_head list;
+	char name[FILTER_FUNCTION_NAME_LEN];
+	int (*init_func)(struct filter_function_struct *ffs);
+	unsigned int (*func)(const struct sk_buff *skb, const struct sock_filter *filter);
+};
+
+extern int attach_filter_function(struct filter_function_struct *ffs, struct sock *sk);
+extern int detach_filter_function(struct filter_function_struct *ffs, struct sock *sk);
+extern int register_filter_function(struct filter_function *ff);
+extern int unregister_filter_function(struct filter_function *ff);
+extern int detect_filter_function(struct sk_filter *fp);
+#endif
+
 extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
 
 extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
diff --git a/net/Kconfig b/net/Kconfig
index e07272d..6bbce29 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -260,6 +260,14 @@ config BPF_JIT
 	  packet sniffing (libpcap/tcpdump). Note : Admin should enable
 	  this feature changing /proc/sys/net/core/bpf_jit_enable
 
+config FILTER_FUNCTION
+	bool "enable definition of a sniff function"
+	depends on MODULES
+	default y
+	---help---
+	  Dynamicaly define what sniffer function would be used to filter
+	  packets
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/Makefile b/net/core/Makefile
index 674641b..c3378c5 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -3,7 +3,8 @@
 #
 
 obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
-	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o
+	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o \
+	 filter_function.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 5dea452..0aa1ac6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -582,7 +582,8 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
-	bpf_jit_free(fp);
+	if (detect_filter_function(fp))
+		bpf_jit_free(fp);
 	kfree(fp);
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
diff --git a/net/core/filter_function.c b/net/core/filter_function.c
new file mode 100644
index 0000000..c9b62e3
--- /dev/null
+++ b/net/core/filter_function.c
@@ -0,0 +1,138 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+#ifdef CONFIG_FILTER_FUNCTION
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/skbuff.h>
+#include <linux/filter.h>
+#include <net/sock.h>
+
+LIST_HEAD(filter_list);
+/*EXPORT_SYMBOL(sniff_list);*/
+
+static DEFINE_MUTEX(filter_list_mutex);
+
+int register_filter_function(struct filter_function *ff)
+{
+	list_add(&(ff->list), &filter_list);
+
+	return 0;
+}
+EXPORT_SYMBOL(register_filter_function);
+
+static struct filter_function *find_filter_function_by_addr(void *addr)
+{
+	struct filter_function *ff;
+
+	if (addr == sk_run_filter)
+		return NULL;
+
+	list_for_each_entry(ff, &filter_list, list) {
+		if (ff->func == addr)
+			return ff;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(find_filter_function_by_addr);
+
+static struct filter_function *find_filter_function_by_name(const char *name)
+{
+	struct filter_function *ff;
+	list_for_each_entry(ff, &filter_list, list) {
+		if (strcmp(ff->name, name) == 0)
+			return ff;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(find_filter_function_by_name);
+
+int unregister_filter_function(struct filter_function *ff)
+{
+	list_del(&(ff->list));
+	return 0;
+}
+EXPORT_SYMBOL(unregister_filter_function);
+
+int attach_filter_function(struct filter_function_struct *ffs, struct sock *sk)
+{
+	struct filter_function *ff = NULL;
+	struct sk_filter *old_fp;
+
+	if (strcmp(ffs->name, "sk_run_filter") == 0) {
+		/*if (init_process_filter_function != NULL)
+			init_process_filter_function(ffs);*/
+	} else
+		ff = find_filter_function_by_name(ffs->name);
+
+	if (ff != NULL) {
+		int ret;
+		if (ff->init_func != NULL)
+			ret = ff->init_func(ffs);
+
+		if (ff->func != NULL) {
+			old_fp = rcu_dereference_protected(sk->sk_filter,
+					sock_owned_by_user(sk));
+			if (detect_filter_function(old_fp)) {
+				bpf_jit_free(old_fp);
+			}
+
+			old_fp->bpf_func = ff->func;
+			rcu_assign_pointer(sk->sk_filter, old_fp);
+		}
+	} else {
+		return -1;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(attach_filter_function);
+
+int detach_filter_function(struct filter_function_struct *ffs, struct sock *sk)
+{
+	struct sk_filter *old_fp;
+	struct filter_function *ff;
+
+	old_fp = rcu_dereference_protected(sk->sk_filter,
+			sock_owned_by_user(sk));
+
+	ff = find_filter_function_by_addr(old_fp->bpf_func);
+	if (ff) {
+		return 0;
+	}
+
+	return -1;
+}
+EXPORT_SYMBOL(detach_filter_function);
+
+int detect_filter_function(struct sk_filter *fp)
+{
+	return find_filter_function_by_addr(fp->bpf_func) ? 0 : -1;
+}
+EXPORT_SYMBOL(detect_filter_function);
+#endif
diff --git a/net/core/sock.c b/net/core/sock.c
index 9be6d0d..0583bf6d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -769,7 +769,28 @@ set_rcvbuf:
 	case SO_DETACH_FILTER:
 		ret = sk_detach_filter(sk);
 		break;
-
+#ifdef CONFIG_FILTER_FUNCTION
+	case SO_ATTACH_FILTER_FUNC:
+		ret = -EINVAL;
+		if (optlen == sizeof(struct filter_function_struct)) {
+			struct filter_function_struct ff;
+			ret = -EFAULT;
+			if (copy_from_user(&ff, optval, sizeof(ff)))
+				break;
+			ret = attach_filter_function(&ff, sk);
+		}
+		break;
+	case SO_DETACH_FILTER_FUNC:
+		ret = -EINVAL;
+		if (optlen == sizeof(struct filter_function_struct)) {
+			struct filter_function_struct ff;
+			ret = -EFAULT;
+			if (copy_from_user(&ff, optval, sizeof(ff)))
+				break;
+			ret = detach_filter_function(&ff, sk);
+		}
+		break;
+#endif
 	case SO_PASSSEC:
 		if (valbool)
 			set_bit(SOCK_PASSSEC, &sock->flags);
-- 
1.7.10.rc3.11.gd8282
