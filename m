From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next 3/4] tcp: Adjust TCP ULP to defer to sockets ULP
Date: Tue,  1 Aug 2017 20:18:45 -0700
Message-ID: <20170802031846.21993-4-tom@quantonium.net>
References: <20170802031846.21993-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:37181 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdHBDTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 23:19:19 -0400
Received: by mail-pg0-f42.google.com with SMTP id y129so15712852pgy.4
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 20:19:19 -0700 (PDT)
In-Reply-To: <20170802031846.21993-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix TCP and TLS to use the newer ULP infrastructure in sockets.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 Documentation/networking/tls.txt   |   6 +-
 include/net/inet_connection_sock.h |   4 --
 include/net/tcp.h                  |  25 -------
 include/net/tls.h                  |   4 +-
 net/ipv4/sysctl_net_ipv4.c         |   9 ++-
 net/ipv4/tcp.c                     |  40 ++++++-----
 net/ipv4/tcp_ipv4.c                |   2 -
 net/ipv4/tcp_ulp.c                 | 135 -------------------------------------
 net/tls/Kconfig                    |   1 +
 net/tls/tls_main.c                 |  21 +++---
 10 files changed, 47 insertions(+), 200 deletions(-)
 delete mode 100644 net/ipv4/tcp_ulp.c

diff --git a/Documentation/networking/tls.txt b/Documentation/networking/tls.txt
index 77ed00631c12..b70309df4709 100644
--- a/Documentation/networking/tls.txt
+++ b/Documentation/networking/tls.txt
@@ -12,8 +12,12 @@ Creating a TLS connection
 
 First create a new TCP socket and set the TLS ULP.
 
+    struct ulp_config ulpc = {
+	.ulp_name = "tls",
+    };
+
   sock = socket(AF_INET, SOCK_STREAM, 0);
-  setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
+  setsockopt(sock, SOL_SOCKET, SO_ULP, &ulpc, sizeof(ulpc))
 
 Setting the TLS ULP allows us to set/get TLS socket options. Currently
 only the symmetric encryption is handled in the kernel.  After the TLS
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 13e4c89a8231..c7a577976bec 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -75,8 +75,6 @@ struct inet_connection_sock_af_ops {
  * @icsk_pmtu_cookie	   Last pmtu seen by socket
  * @icsk_ca_ops		   Pluggable congestion control hook
  * @icsk_af_ops		   Operations which are AF_INET{4,6} specific
- * @icsk_ulp_ops	   Pluggable ULP control hook
- * @icsk_ulp_data	   ULP private data
  * @icsk_ca_state:	   Congestion control state
  * @icsk_retransmits:	   Number of unrecovered [RTO] timeouts
  * @icsk_pending:	   Scheduled timer event
@@ -99,8 +97,6 @@ struct inet_connection_sock {
 	__u32			  icsk_pmtu_cookie;
 	const struct tcp_congestion_ops *icsk_ca_ops;
 	const struct inet_connection_sock_af_ops *icsk_af_ops;
-	const struct tcp_ulp_ops  *icsk_ulp_ops;
-	void			  *icsk_ulp_data;
 	unsigned int		  (*icsk_sync_mss)(struct sock *sk, u32 pmtu);
 	__u8			  icsk_ca_state:6,
 				  icsk_ca_setsockopt:1,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index bb1881b4ce48..65c462da3740 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1968,31 +1968,6 @@ static inline void tcp_listendrop(const struct sock *sk)
 
 enum hrtimer_restart tcp_pace_kick(struct hrtimer *timer);
 
-/*
- * Interface for adding Upper Level Protocols over TCP
- */
-
-#define TCP_ULP_NAME_MAX	16
-#define TCP_ULP_MAX		128
-#define TCP_ULP_BUF_MAX		(TCP_ULP_NAME_MAX*TCP_ULP_MAX)
-
-struct tcp_ulp_ops {
-	struct list_head	list;
-
-	/* initialize ulp */
-	int (*init)(struct sock *sk);
-	/* cleanup ulp */
-	void (*release)(struct sock *sk);
-
-	char		name[TCP_ULP_NAME_MAX];
-	struct module	*owner;
-};
-int tcp_register_ulp(struct tcp_ulp_ops *type);
-void tcp_unregister_ulp(struct tcp_ulp_ops *type);
-int tcp_set_ulp(struct sock *sk, const char *name);
-void tcp_get_available_ulp(char *buf, size_t len);
-void tcp_cleanup_ulp(struct sock *sk);
-
 /* Call BPF_SOCK_OPS program that returns an int. If the return value
  * is < 0, then the BPF op failed (for example if the loaded BPF
  * program does not support the chosen operation or there is no BPF
diff --git a/include/net/tls.h b/include/net/tls.h
index b89d397dd62f..7d88a6e2f5a7 100644
--- a/include/net/tls.h
+++ b/include/net/tls.h
@@ -214,9 +214,7 @@ static inline void tls_fill_prepend(struct tls_context *ctx,
 
 static inline struct tls_context *tls_get_ctx(const struct sock *sk)
 {
-	struct inet_connection_sock *icsk = inet_csk(sk);
-
-	return icsk->icsk_ulp_data;
+	return sk->sk_ulp_data;
 }
 
 static inline struct tls_sw_context *tls_sw_ctx(
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0d3c038d7b04..9ab0c278b7ba 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -21,6 +21,7 @@
 #include <net/route.h>
 #include <net/tcp.h>
 #include <net/udp.h>
+#include <net/ulp_sock.h>
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>
 #include <net/ping.h>
@@ -372,13 +373,15 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 				  void __user *buffer, size_t *lenp,
 				  loff_t *ppos)
 {
-	struct ctl_table tbl = { .maxlen = TCP_ULP_BUF_MAX, };
+	struct ctl_table tbl = { .maxlen = ULP_BUF_MAX, };
 	int ret;
 
 	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
 	if (!tbl.data)
 		return -ENOMEM;
-	tcp_get_available_ulp(tbl.data, TCP_ULP_BUF_MAX);
+
+	/* Just return all ULPs for compatibility */
+	ulp_get_available(tbl.data, ULP_BUF_MAX);
 	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
 	kfree(tbl.data);
 
@@ -709,7 +712,7 @@ static struct ctl_table ipv4_table[] = {
 	},
 	{
 		.procname	= "tcp_available_ulp",
-		.maxlen		= TCP_ULP_BUF_MAX,
+		.maxlen		= ULP_BUF_MAX,
 		.mode		= 0444,
 		.proc_handler   = proc_tcp_available_ulp,
 	},
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9dd6f4dba9b1..26f0d9821e6d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2404,24 +2404,24 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		release_sock(sk);
 		return err;
 	}
+
 	case TCP_ULP: {
-		char name[TCP_ULP_NAME_MAX];
+		struct ulp_config ulpc;
 
 		if (optlen < 1)
 			return -EINVAL;
 
-		val = strncpy_from_user(name, optval,
-					min_t(long, TCP_ULP_NAME_MAX - 1,
+		val = strncpy_from_user(ulpc.ulp_name, optval,
+					min_t(long, ULP_NAME_MAX - 1,
 					      optlen));
 		if (val < 0)
 			return -EFAULT;
-		name[val] = 0;
+		ulpc.ulp_name[val] = 0;
 
-		lock_sock(sk);
-		err = tcp_set_ulp(sk, name);
-		release_sock(sk);
-		return err;
+		return kernel_setsockopt(sk->sk_socket, SOL_SOCKET, SO_ULP,
+					 (char *)&ulpc, sizeof(ulpc));
 	}
+
 	default:
 		/* fallthru */
 		break;
@@ -2993,20 +2993,28 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			return -EFAULT;
 		return 0;
 
-	case TCP_ULP:
+	case TCP_ULP: {
+		struct ulp_config ulpc;
+		int ulen, ret;
+
 		if (get_user(len, optlen))
 			return -EFAULT;
-		len = min_t(unsigned int, len, TCP_ULP_NAME_MAX);
-		if (!icsk->icsk_ulp_ops) {
-			if (put_user(0, optlen))
-				return -EFAULT;
-			return 0;
-		}
+		len = min_t(unsigned int, len, ULP_NAME_MAX);
+
+		ulen = sizeof(ulpc);
+
+		/* Backwards compatbility */
+		ret = kernel_getsockopt(sk->sk_socket, SOL_SOCKET, SO_ULP,
+					(char *)&ulpc, &ulen);
+		if (ret)
+			return ret;
+
 		if (put_user(len, optlen))
 			return -EFAULT;
-		if (copy_to_user(optval, icsk->icsk_ulp_ops->name, len))
+		if (copy_to_user(optval, ulpc.ulp_name, len))
 			return -EFAULT;
 		return 0;
+	}
 
 	case TCP_THIN_LINEAR_TIMEOUTS:
 		val = tp->thin_lto;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9b51663cd5a4..89fafd2c5d36 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1858,8 +1858,6 @@ void tcp_v4_destroy_sock(struct sock *sk)
 
 	tcp_cleanup_congestion_control(sk);
 
-	tcp_cleanup_ulp(sk);
-
 	/* Cleanup up the write buffer. */
 	tcp_write_queue_purge(sk);
 
diff --git a/net/ipv4/tcp_ulp.c b/net/ipv4/tcp_ulp.c
deleted file mode 100644
index 2417f55374c5..000000000000
--- a/net/ipv4/tcp_ulp.c
+++ /dev/null
@@ -1,135 +0,0 @@
-/*
- * Pluggable TCP upper layer protocol support.
- *
- * Copyright (c) 2016-2017, Mellanox Technologies. All rights reserved.
- * Copyright (c) 2016-2017, Dave Watson <davejwatson@fb.com>. All rights reserved.
- *
- */
-
-#include<linux/module.h>
-#include <linux/mm.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/gfp.h>
-#include <net/tcp.h>
-
-static DEFINE_SPINLOCK(tcp_ulp_list_lock);
-static LIST_HEAD(tcp_ulp_list);
-
-/* Simple linear search, don't expect many entries! */
-static struct tcp_ulp_ops *tcp_ulp_find(const char *name)
-{
-	struct tcp_ulp_ops *e;
-
-	list_for_each_entry_rcu(e, &tcp_ulp_list, list) {
-		if (strcmp(e->name, name) == 0)
-			return e;
-	}
-
-	return NULL;
-}
-
-static const struct tcp_ulp_ops *__tcp_ulp_find_autoload(const char *name)
-{
-	const struct tcp_ulp_ops *ulp = NULL;
-
-	rcu_read_lock();
-	ulp = tcp_ulp_find(name);
-
-#ifdef CONFIG_MODULES
-	if (!ulp && capable(CAP_NET_ADMIN)) {
-		rcu_read_unlock();
-		request_module("%s", name);
-		rcu_read_lock();
-		ulp = tcp_ulp_find(name);
-	}
-#endif
-	if (!ulp || !try_module_get(ulp->owner))
-		ulp = NULL;
-
-	rcu_read_unlock();
-	return ulp;
-}
-
-/* Attach new upper layer protocol to the list
- * of available protocols.
- */
-int tcp_register_ulp(struct tcp_ulp_ops *ulp)
-{
-	int ret = 0;
-
-	spin_lock(&tcp_ulp_list_lock);
-	if (tcp_ulp_find(ulp->name)) {
-		pr_notice("%s already registered or non-unique name\n",
-			  ulp->name);
-		ret = -EEXIST;
-	} else {
-		list_add_tail_rcu(&ulp->list, &tcp_ulp_list);
-	}
-	spin_unlock(&tcp_ulp_list_lock);
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(tcp_register_ulp);
-
-void tcp_unregister_ulp(struct tcp_ulp_ops *ulp)
-{
-	spin_lock(&tcp_ulp_list_lock);
-	list_del_rcu(&ulp->list);
-	spin_unlock(&tcp_ulp_list_lock);
-
-	synchronize_rcu();
-}
-EXPORT_SYMBOL_GPL(tcp_unregister_ulp);
-
-/* Build string with list of available upper layer protocl values */
-void tcp_get_available_ulp(char *buf, size_t maxlen)
-{
-	struct tcp_ulp_ops *ulp_ops;
-	size_t offs = 0;
-
-	*buf = '\0';
-	rcu_read_lock();
-	list_for_each_entry_rcu(ulp_ops, &tcp_ulp_list, list) {
-		offs += snprintf(buf + offs, maxlen - offs,
-				 "%s%s",
-				 offs == 0 ? "" : " ", ulp_ops->name);
-	}
-	rcu_read_unlock();
-}
-
-void tcp_cleanup_ulp(struct sock *sk)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-
-	if (!icsk->icsk_ulp_ops)
-		return;
-
-	if (icsk->icsk_ulp_ops->release)
-		icsk->icsk_ulp_ops->release(sk);
-	module_put(icsk->icsk_ulp_ops->owner);
-}
-
-/* Change upper layer protocol for socket */
-int tcp_set_ulp(struct sock *sk, const char *name)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	const struct tcp_ulp_ops *ulp_ops;
-	int err = 0;
-
-	if (icsk->icsk_ulp_ops)
-		return -EEXIST;
-
-	ulp_ops = __tcp_ulp_find_autoload(name);
-	if (!ulp_ops)
-		err = -ENOENT;
-	else
-		err = ulp_ops->init(sk);
-
-	if (err)
-		goto out;
-
-	icsk->icsk_ulp_ops = ulp_ops;
- out:
-	return err;
-}
diff --git a/net/tls/Kconfig b/net/tls/Kconfig
index eb583038c67e..60ae4e9b257e 100644
--- a/net/tls/Kconfig
+++ b/net/tls/Kconfig
@@ -7,6 +7,7 @@ config TLS
 	select CRYPTO
 	select CRYPTO_AES
 	select CRYPTO_GCM
+	select ULP_SOCK
 	default n
 	---help---
 	Enable kernel support for TLS protocol. This allows symmetric
diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index 60aff60e30ad..00ccbec96820 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -31,15 +31,15 @@
  * SOFTWARE.
  */
 
-#include <linux/module.h>
-
-#include <net/tcp.h>
-#include <net/inet_common.h>
 #include <linux/highmem.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/sched/signal.h>
-
+#include <net/inet_common.h>
+#include <net/sock.h>
+#include <net/tcp.h>
 #include <net/tls.h>
+#include <net/ulp_sock.h>
 
 MODULE_AUTHOR("Mellanox Technologies");
 MODULE_DESCRIPTION("Transport Layer Security Support");
@@ -438,9 +438,8 @@ static int tls_setsockopt(struct sock *sk, int level, int optname,
 	return do_tls_setsockopt(sk, optname, optval, optlen);
 }
 
-static int tls_init(struct sock *sk)
+static int tls_init(struct sock *sk, char __user *optval, int len)
 {
-	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tls_context *ctx;
 	int rc = 0;
 
@@ -450,7 +449,7 @@ static int tls_init(struct sock *sk)
 		rc = -ENOMEM;
 		goto out;
 	}
-	icsk->icsk_ulp_data = ctx;
+	sk->sk_ulp_data = ctx;
 	ctx->setsockopt = sk->sk_prot->setsockopt;
 	ctx->getsockopt = sk->sk_prot->getsockopt;
 	sk->sk_prot = &tls_base_prot;
@@ -458,7 +457,7 @@ static int tls_init(struct sock *sk)
 	return rc;
 }
 
-static struct tcp_ulp_ops tcp_tls_ulp_ops __read_mostly = {
+static struct ulp_ops ulp_tls_ops __read_mostly = {
 	.name			= "tls",
 	.owner			= THIS_MODULE,
 	.init			= tls_init,
@@ -475,14 +474,14 @@ static int __init tls_register(void)
 	tls_sw_prot.sendpage            = tls_sw_sendpage;
 	tls_sw_prot.close               = tls_sk_proto_close;
 
-	tcp_register_ulp(&tcp_tls_ulp_ops);
+	ulp_register(&ulp_tls_ops);
 
 	return 0;
 }
 
 static void __exit tls_unregister(void)
 {
-	tcp_unregister_ulp(&tcp_tls_ulp_ops);
+	ulp_unregister(&ulp_tls_ops);
 }
 
 module_init(tls_register);
-- 
2.11.0
