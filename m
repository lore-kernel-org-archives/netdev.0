From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 3/5] sock: ULP infrastructure
Date: Mon,  7 Aug 2017 10:28:16 -0700
Message-ID: <20170807172818.31855-4-tom@quantonium.net>
References: <20170807172818.31855-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com, john.fastabend@gmail.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:38270 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdHGR3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:29:05 -0400
Received: by mail-pg0-f47.google.com with SMTP id l64so4073049pge.5
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 10:29:05 -0700 (PDT)
In-Reply-To: <20170807172818.31855-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generalize the TCP ULP infrastructure recently introduced to support
kTLS. This adds a SO_ULP socket option and creates new fields in
sock structure for ULP ops and ULP data. Also, the interface allows
additional per ULP parameters to be set so that a ULP can be pushed
and operations started in one shot.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 arch/alpha/include/uapi/asm/socket.h   |   2 +
 arch/frv/include/uapi/asm/socket.h     |   2 +
 arch/ia64/include/uapi/asm/socket.h    |   2 +
 arch/m32r/include/uapi/asm/socket.h    |   2 +
 arch/mips/include/uapi/asm/socket.h    |   2 +
 arch/mn10300/include/uapi/asm/socket.h |   2 +
 arch/parisc/include/uapi/asm/socket.h  |   2 +
 arch/s390/include/uapi/asm/socket.h    |   2 +
 arch/sparc/include/uapi/asm/socket.h   |   2 +
 arch/xtensa/include/uapi/asm/socket.h  |   2 +
 include/linux/socket.h                 |   9 ++
 include/net/sock.h                     |   6 +
 include/net/ulp_sock.h                 |  76 +++++++++++++
 include/uapi/asm-generic/socket.h      |   2 +
 net/Kconfig                            |   4 +
 net/core/Makefile                      |   1 +
 net/core/sock.c                        |  12 ++
 net/core/sysctl_net_core.c             |  25 +++++
 net/core/ulp_sock.c                    | 196 +++++++++++++++++++++++++++++++++
 net/ipv4/inet_connection_sock.c        |   5 +
 20 files changed, 356 insertions(+)
 create mode 100644 include/net/ulp_sock.h
 create mode 100644 net/core/ulp_sock.c

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index c6133a045352..810e0dc8f394 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -111,4 +111,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 9abf02d6855a..c7bb41ae784b 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -104,5 +104,7 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 002eb85a6941..c4e94563c4ce 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -113,4 +113,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index e268e51a38d1..4359388a541d 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -104,4 +104,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 6c755bc07975..300eb1074611 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -122,4 +122,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index ac82a3f26dbf..c458c614afa6 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -104,4 +104,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 3b2bf7ae703b..fa25c1105faf 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 
 #define SO_ZEROCOPY		0x4035
 
+#define SO_ULP			0x4036
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index a56916c83565..d0bee5a5ac17 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -110,4 +110,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index b2f5c50d0947..46f5d04426e8 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -100,6 +100,8 @@
 
 #define SO_ZEROCOPY		0x003e
 
+#define SO_ULP			0x003f
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 220059999e74..f654e2507726 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -115,4 +115,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8ad963cdc88c..9ff7b1b2256f 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -156,6 +156,15 @@ struct ucred {
 	__u32	gid;
 };
 
+/* ULP configuration for socket */
+
+#define ULP_NAME_MAX	16
+
+struct ulp_config {
+	char ulp_name[ULP_NAME_MAX];
+	__u8 ulp_params[0];
+};
+
 /* Supported address families. */
 #define AF_UNSPEC	0
 #define AF_UNIX		1	/* Unix domain sockets 		*/
diff --git a/include/net/sock.h b/include/net/sock.h
index fe1a0bc25cd3..ea67ea91db87 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -72,6 +72,7 @@
 #include <net/tcp_states.h>
 #include <linux/net_tstamp.h>
 #include <net/smc.h>
+#include <net/ulp_sock.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -313,6 +314,8 @@ struct sock_common {
   *	@sk_destruct: called at sock freeing time, i.e. when all refcnt == 0
   *	@sk_reuseport_cb: reuseport group container
   *	@sk_rcu: used during RCU grace period
+  *	@sk_ulp_ops: pluggable ULP control hook
+  *	@sk_ulp_data: ULP private data
   */
 struct sock {
 	/*
@@ -480,6 +483,9 @@ struct sock {
 	void                    (*sk_destruct)(struct sock *sk);
 	struct sock_reuseport __rcu	*sk_reuseport_cb;
 	struct rcu_head		sk_rcu;
+
+	const struct ulp_ops	*sk_ulp_ops;
+	void			*sk_ulp_data;
 };
 
 enum sk_pacing {
diff --git a/include/net/ulp_sock.h b/include/net/ulp_sock.h
new file mode 100644
index 000000000000..b292831a5d75
--- /dev/null
+++ b/include/net/ulp_sock.h
@@ -0,0 +1,76 @@
+/*
+ * Pluggable upper layer protocol support in sockets.
+ *
+ * Copyright (c) 2016-2017, Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016-2017, Dave Watson <davejwatson@fb.com>. All rights reserved.
+ * Copyright (c) 2017, Tom Herbert <tom@quantonium.net>. All rights reserved.
+ *
+ */
+
+#ifndef __NET_ULP_SOCK_H
+#define __NET_ULP_SOCK_H
+
+#include <linux/socket.h>
+
+#define ULP_MAX             128
+#define ULP_BUF_MAX         (ULP_NAME_MAX * ULP_MAX)
+
+struct ulp_ops {
+	struct list_head list;
+
+	/* initialize ulp */
+	int (*init)(struct sock *sk, char __user *optval, int len);
+
+	/* cleanup ulp */
+	void (*release)(struct sock *sk);
+
+	/* Get ULP specific parameters in getsockopt */
+	int (*get_params)(struct sock *sk, char __user *optval, int *optlen);
+
+	char name[ULP_NAME_MAX];
+	struct module *owner;
+};
+
+#ifdef CONFIG_ULP_SOCK
+
+int ulp_register(struct ulp_ops *type);
+void ulp_unregister(struct ulp_ops *type);
+int ulp_set(struct sock *sk, char __user *optval, int len);
+int ulp_get_config(struct sock *sk, char __user *optval, int *optlen);
+void ulp_get_available(char *buf, size_t len);
+void ulp_cleanup(struct sock *sk);
+
+#else
+
+static inline int ulp_register(struct ulp_ops *type)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void ulp_unregister(struct ulp_ops *type)
+{
+}
+
+static inline int ulp_set(struct sock *sk, char __user *optval, int len)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int ulp_get_config(struct sock *sk, char __user *optval,
+				 int *optlen)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void ulp_get_available(char *buf, size_t len)
+{
+	 *buf = '\0';
+}
+
+static inline void ulp_cleanup(struct sock *sk)
+{
+}
+
+#endif
+
+#endif /* __NET_ULP_SOCK_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index e47c9e436221..41abbf7f6b66 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -106,4 +106,6 @@
 
 #define SO_ZEROCOPY		60
 
+#define SO_ULP			61
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/Kconfig b/net/Kconfig
index 7d57ef34b79c..2b8d2d88bc2b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -419,6 +419,10 @@ config GRO_CELLS
 	bool
 	default n
 
+config ULP_SOCK
+	bool
+	default n
+
 config NET_DEVLINK
 	tristate "Network physical/parent device Netlink interface"
 	help
diff --git a/net/core/Makefile b/net/core/Makefile
index 56d771a887b6..0d90c0ade1c8 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
 obj-$(CONFIG_NET_DEVLINK) += devlink.o
 obj-$(CONFIG_GRO_CELLS) += gro_cells.o
+obj-$(CONFIG_ULP_SOCK) += ulp_sock.o
diff --git a/net/core/sock.c b/net/core/sock.c
index 9ea988d25b0a..b2a6162cca9d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1069,6 +1069,10 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 			sock_valbool_flag(sk, SOCK_ZEROCOPY, valbool);
 		break;
 
+	case SO_ULP:
+		ret = ulp_set(sk, optval, optlen);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1401,6 +1405,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_ZEROCOPY);
 		break;
 
+	case SO_ULP:
+		return ulp_get_config(sk, optval, optlen);
+
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
@@ -2990,6 +2997,11 @@ EXPORT_SYMBOL(compat_sock_common_setsockopt);
 
 void sk_common_release(struct sock *sk)
 {
+	/* Clean up ULP before destroying protocol socket since ULP might
+	 * be dependent on transport (and not the other way around).
+	 */
+	ulp_cleanup(sk);
+
 	if (sk->sk_prot->destroy)
 		sk->sk_prot->destroy(sk);
 
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index b7cd9aafe99e..9e14f91b57eb 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -21,6 +21,7 @@
 #include <net/net_ratelimit.h>
 #include <net/busy_poll.h>
 #include <net/pkt_sched.h>
+#include <net/ulp_sock.h>
 
 static int zero = 0;
 static int one = 1;
@@ -249,6 +250,24 @@ static int proc_do_rss_key(struct ctl_table *table, int write,
 	return proc_dostring(&fake_table, write, buffer, lenp, ppos);
 }
 
+static int proc_ulp_available(struct ctl_table *ctl,
+			      int write,
+			      void __user *buffer, size_t *lenp,
+			      loff_t *ppos)
+{
+	struct ctl_table tbl = { .maxlen = ULP_BUF_MAX, };
+	int ret;
+
+	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
+	if (!tbl.data)
+		return -ENOMEM;
+	ulp_get_available(tbl.data, ULP_BUF_MAX);
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
+	kfree(tbl.data);
+
+	return ret;
+}
+
 static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
 	{
@@ -460,6 +479,12 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
 	},
+	{
+		.procname	= "ulp_available",
+		.maxlen		= ULP_BUF_MAX,
+		.mode		= 0444,
+		.proc_handler	= proc_ulp_available,
+	},
 	{ }
 };
 
diff --git a/net/core/ulp_sock.c b/net/core/ulp_sock.c
new file mode 100644
index 000000000000..0bd9e8af18a4
--- /dev/null
+++ b/net/core/ulp_sock.c
@@ -0,0 +1,196 @@
+/*
+ * Pluggable upper layer protocol support in sockets.
+ *
+ * Copyright (c) 2016-2017, Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016-2017, Dave Watson <davejwatson@fb.com>. All rights reserved.
+ * Copyright (c) 2017, Tom Herbert <tom@quantonium.net>. All rights reserved.
+ *
+ */
+
+#include <linux/gfp.h>
+#include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <net/sock.h>
+#include <net/ulp_sock.h>
+
+static DEFINE_SPINLOCK(ulp_list_lock);
+static LIST_HEAD(ulp_list);
+
+/* Simple linear search, don't expect many entries! */
+static struct ulp_ops *ulp_find(const char *name)
+{
+	struct ulp_ops *e;
+
+	list_for_each_entry_rcu(e, &ulp_list, list) {
+		if (strcmp(e->name, name) == 0)
+			return e;
+	}
+
+	return NULL;
+}
+
+static const struct ulp_ops *__ulp_find_autoload(const char *name)
+{
+	const struct ulp_ops *ulp = NULL;
+
+	rcu_read_lock();
+	ulp = ulp_find(name);
+
+#ifdef CONFIG_MODULES
+	if (!ulp && capable(CAP_NET_ADMIN)) {
+		rcu_read_unlock();
+		request_module("%s", name);
+		rcu_read_lock();
+		ulp = ulp_find(name);
+	}
+#endif
+	if (!ulp || !try_module_get(ulp->owner))
+		ulp = NULL;
+
+	rcu_read_unlock();
+	return ulp;
+}
+
+/* Attach new upper layer protocol to the list
+ * of available protocols.
+ */
+int ulp_register(struct ulp_ops *ulp)
+{
+	int ret = 0;
+
+	spin_lock(&ulp_list_lock);
+	if (ulp_find(ulp->name)) {
+		pr_notice("%s already registered or non-unique name\n",
+			  ulp->name);
+		ret = -EEXIST;
+	} else {
+		list_add_tail_rcu(&ulp->list, &ulp_list);
+	}
+	spin_unlock(&ulp_list_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(ulp_register);
+
+void ulp_unregister(struct ulp_ops *ulp)
+{
+	spin_lock(&ulp_list_lock);
+	list_del_rcu(&ulp->list);
+	spin_unlock(&ulp_list_lock);
+
+	synchronize_rcu();
+}
+EXPORT_SYMBOL_GPL(ulp_unregister);
+
+/* Build string with list of available upper layer protocl values */
+void ulp_get_available(char *buf, size_t maxlen)
+{
+	struct ulp_ops *ulp_ops;
+	size_t offs = 0;
+
+	*buf = '\0';
+	rcu_read_lock();
+	list_for_each_entry_rcu(ulp_ops, &ulp_list, list) {
+		offs += snprintf(buf + offs, maxlen - offs,
+				 "%s%s",
+				 offs == 0 ? "" : " ", ulp_ops->name);
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(ulp_get_available);
+
+void ulp_cleanup(struct sock *sk)
+{
+	if (!sk->sk_ulp_ops)
+		return;
+
+	if (sk->sk_ulp_ops->release)
+		sk->sk_ulp_ops->release(sk);
+
+	module_put(sk->sk_ulp_ops->owner);
+
+	sk->sk_ulp_ops = NULL;
+}
+EXPORT_SYMBOL_GPL(ulp_cleanup);
+
+/* Change upper layer protocol for socket, Called from setsockopt. */
+int ulp_set(struct sock *sk, char __user *optval, int len)
+{
+	const struct ulp_ops *ulp_ops;
+	struct ulp_config ulpc;
+	int err = 0;
+
+	if (len < sizeof(ulpc))
+		return -EINVAL;
+
+	if (copy_from_user(&ulpc, optval, sizeof(ulpc)))
+		return -EFAULT;
+
+	if (sk->sk_ulp_ops)
+		return -EEXIST;
+
+	ulp_ops = __ulp_find_autoload(ulpc.ulp_name);
+	if (!ulp_ops)
+		return -ENOENT;
+
+	optval += sizeof(ulpc);
+	len -= sizeof(ulpc);
+
+	err = ulp_ops->init(sk, optval, len);
+	if (err)
+		return err;
+
+	sk->sk_ulp_ops = ulp_ops;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ulp_set);
+
+/* Get upper layer protocol for socket. Called from getsockopt. */
+int ulp_get_config(struct sock *sk, char __user *optval, int *optlen)
+{
+	struct ulp_config ulpc;
+	int len = *optlen;
+	int used_len;
+	int ret;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	if (len < sizeof(ulpc))
+		return -EINVAL;
+
+	if (!sk->sk_ulp_ops) {
+		if (put_user(0, optlen))
+			return -EFAULT;
+		return 0;
+	}
+
+	memcpy(ulpc.ulp_name, sk->sk_ulp_ops->name,
+	       sizeof(ulpc.ulp_name));
+
+	if (copy_to_user(optval, &ulpc, sizeof(ulpc)))
+		return -EFAULT;
+
+	used_len = sizeof(ulpc);
+
+	if (sk->sk_ulp_ops->get_params) {
+		len -= sizeof(ulpc);
+		optval += sizeof(ulpc);
+
+		ret = sk->sk_ulp_ops->get_params(sk, optval, &len);
+		if (ret)
+			return ret;
+
+		used_len += len;
+	}
+
+	if (put_user(used_len, optlen))
+		return -EFAULT;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ulp_get_config);
+
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 4089c013cb03..4e9e60f738a9 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -830,6 +830,11 @@ void inet_csk_destroy_sock(struct sock *sk)
 	/* If it has not 0 inet_sk(sk)->inet_num, it must be bound */
 	WARN_ON(inet_sk(sk)->inet_num && !inet_csk(sk)->icsk_bind_hash);
 
+	/* Clean up ULP before destroying protocol socket since ULP might
+	 * be dependent on transport (and not the other way around).
+	 */
+	ulp_cleanup(sk);
+
 	sk->sk_prot->destroy(sk);
 
 	sk_stream_kill_queues(sk);
-- 
2.11.0
