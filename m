From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 4/6] net: tcp: add key management to congestion control
Date: Mon,  5 Jan 2015 23:57:46 +0100
Message-ID: <1420498668-4660-5-git-send-email-dborkman@redhat.com>
References: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbbAEW6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 17:58:03 -0500
In-Reply-To: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds necessary infrastructure to the congestion control
framework for later per route congestion control support.

For a per route congestion control possibility, our aim is to store
a unique u32 key identifier into dst metrics, which can then be
mapped into a tcp_congestion_ops struct. We argue that having a
RTAX key entry is the most simple, generic and easy way to manage,
and also keeps the memory footprint of dst entries lower on 64 bit
than with storing a pointer directly, for example. Having a unique
key id also allows for decoupling actual TCP congestion control
module management from the FIB layer, i.e. we don't have to care
about expensive module refcounting inside the FIB at this point.

We first thought of using an IDR store for the realization, which
takes over dynamic assignment of unused key space and also performs
the key to pointer mapping in RCU. While doing so, we stumbled upon
the issue that due to the nature of dynamic key distribution, it
just so happens, arguably in very rare occasions, that excessive
module loads and unloads can lead to a possible reuse of previously
used key space. Thus, previously stale keys in the dst metric are
now being reassigned to a different congestion control algorithm,
which might lead to unexpected behaviour. One way to resolve this
would have been to walk FIBs on the actually rare occasion of a
module unload and reset the metric keys for each FIB in each netns,
but that's just very costly.

Therefore, we argue a better solution is to reuse the unique
congestion control algorithm name member and map that into u32 key
space through jhash. For that, we split the flags attribute (as it
currently uses 2 bits only anyway) into two u32 attributes, flags
and key, so that we can keep the cacheline boundary of 2 cachelines
on x86_64 and cache the precalculated key at registration time for
the fast path. On average we might expect 2 - 4 modules being loaded
worst case perhaps 15, so a key collision possibility is extremely
low, and guaranteed collision-free on LE/BE for all in-tree modules.
Overall this results in much simpler code, and all without the
overhead of an IDR. Due to the deterministic nature, modules can
now be unloaded, the congestion control algorithm for a specific
but unloaded key will fall back to the default one, and on module
reload time it will switch back to the expected algorithm
transparently.

Joint work with Florian Westphal.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/inet_connection_sock.h |  3 +-
 include/net/tcp.h                  |  9 +++-
 net/ipv4/tcp_cong.c                | 97 +++++++++++++++++++++++++++++++-------
 3 files changed, 91 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 848e85c..5976bde 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -98,7 +98,8 @@ struct inet_connection_sock {
 	const struct tcp_congestion_ops *icsk_ca_ops;
 	const struct inet_connection_sock_af_ops *icsk_af_ops;
 	unsigned int		  (*icsk_sync_mss)(struct sock *sk, u32 pmtu);
-	__u8			  icsk_ca_state;
+	__u8			  icsk_ca_state:7,
+				  icsk_ca_dst_locked:1;
 	__u8			  icsk_retransmits;
 	__u8			  icsk_pending;
 	__u8			  icsk_backoff;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f50f29faf..135b70c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -787,6 +787,8 @@ enum tcp_ca_ack_event_flags {
 #define TCP_CA_MAX	128
 #define TCP_CA_BUF_MAX	(TCP_CA_NAME_MAX*TCP_CA_MAX)
 
+#define TCP_CA_UNSPEC	0
+
 /* Algorithm can be set on socket without CAP_NET_ADMIN privileges */
 #define TCP_CONG_NON_RESTRICTED 0x1
 /* Requires ECN/ECT set on all packets */
@@ -794,7 +796,8 @@ enum tcp_ca_ack_event_flags {
 
 struct tcp_congestion_ops {
 	struct list_head	list;
-	unsigned long flags;
+	u32 key;
+	u32 flags;
 
 	/* initialize private data (optional) */
 	void (*init)(struct sock *sk);
@@ -841,6 +844,10 @@ u32 tcp_reno_ssthresh(struct sock *sk);
 void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
 extern struct tcp_congestion_ops tcp_reno;
 
+struct tcp_congestion_ops *tcp_ca_find_key(u32 key);
+u32 tcp_ca_get_key_by_name(const char *name);
+char *tcp_ca_get_name_by_key(u32 key, char *buffer);
+
 static inline bool tcp_ca_needs_ecn(const struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 38f2f8a..63c29db 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -13,6 +13,7 @@
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/gfp.h>
+#include <linux/jhash.h>
 #include <net/tcp.h>
 
 static DEFINE_SPINLOCK(tcp_cong_list_lock);
@@ -31,6 +32,34 @@ static struct tcp_congestion_ops *tcp_ca_find(const char *name)
 	return NULL;
 }
 
+/* Must be called with rcu lock held */
+static const struct tcp_congestion_ops *__tcp_ca_find_autoload(const char *name)
+{
+	const struct tcp_congestion_ops *ca = tcp_ca_find(name);
+#ifdef CONFIG_MODULES
+	if (!ca && capable(CAP_NET_ADMIN)) {
+		rcu_read_unlock();
+		request_module("tcp_%s", name);
+		rcu_read_lock();
+		ca = tcp_ca_find(name);
+	}
+#endif
+	return ca;
+}
+
+/* Simple linear search, not much in here. */
+struct tcp_congestion_ops *tcp_ca_find_key(u32 key)
+{
+	struct tcp_congestion_ops *e;
+
+	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
+		if (e->key == key)
+			return e;
+	}
+
+	return NULL;
+}
+
 /*
  * Attach new congestion control algorithm to the list
  * of available options.
@@ -45,9 +74,12 @@ int tcp_register_congestion_control(struct tcp_congestion_ops *ca)
 		return -EINVAL;
 	}
 
+	ca->key = jhash(ca->name, sizeof(ca->name), strlen(ca->name));
+
 	spin_lock(&tcp_cong_list_lock);
-	if (tcp_ca_find(ca->name)) {
-		pr_notice("%s already registered\n", ca->name);
+	if (ca->key == TCP_CA_UNSPEC || tcp_ca_find_key(ca->key)) {
+		pr_notice("%s already registered or non-unique key\n",
+			  ca->name);
 		ret = -EEXIST;
 	} else {
 		list_add_tail_rcu(&ca->list, &tcp_cong_list);
@@ -70,9 +102,50 @@ void tcp_unregister_congestion_control(struct tcp_congestion_ops *ca)
 	spin_lock(&tcp_cong_list_lock);
 	list_del_rcu(&ca->list);
 	spin_unlock(&tcp_cong_list_lock);
+
+	/* Wait for outstanding readers to complete before the
+	 * module gets removed entirely.
+	 *
+	 * A try_module_get() should fail by now as our module is
+	 * in "going" state since no refs are held anymore and
+	 * module_exit() handler being called.
+	 */
+	synchronize_rcu();
 }
 EXPORT_SYMBOL_GPL(tcp_unregister_congestion_control);
 
+u32 tcp_ca_get_key_by_name(const char *name)
+{
+	const struct tcp_congestion_ops *ca;
+	u32 key;
+
+	might_sleep();
+
+	rcu_read_lock();
+	ca = __tcp_ca_find_autoload(name);
+	key = ca ? ca->key : TCP_CA_UNSPEC;
+	rcu_read_unlock();
+
+	return key;
+}
+EXPORT_SYMBOL_GPL(tcp_ca_get_key_by_name);
+
+char *tcp_ca_get_name_by_key(u32 key, char *buffer)
+{
+	const struct tcp_congestion_ops *ca;
+	char *ret = NULL;
+
+	rcu_read_lock();
+	ca = tcp_ca_find_key(key);
+	if (ca)
+		ret = strncpy(buffer, ca->name,
+			      TCP_CA_NAME_MAX);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(tcp_ca_get_name_by_key);
+
 /* Assign choice of congestion control. */
 void tcp_assign_congestion_control(struct sock *sk)
 {
@@ -253,25 +326,17 @@ out:
 int tcp_set_congestion_control(struct sock *sk, const char *name)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_congestion_ops *ca;
+	const struct tcp_congestion_ops *ca;
 	int err = 0;
 
-	rcu_read_lock();
-	ca = tcp_ca_find(name);
+	if (icsk->icsk_ca_dst_locked)
+		return -EPERM;
 
-	/* no change asking for existing value */
+	rcu_read_lock();
+	ca = __tcp_ca_find_autoload(name);
+	/* No change asking for existing value */
 	if (ca == icsk->icsk_ca_ops)
 		goto out;
-
-#ifdef CONFIG_MODULES
-	/* not found attempt to autoload module */
-	if (!ca && capable(CAP_NET_ADMIN)) {
-		rcu_read_unlock();
-		request_module("tcp_%s", name);
-		rcu_read_lock();
-		ca = tcp_ca_find(name);
-	}
-#endif
 	if (!ca)
 		err = -ENOENT;
 	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) ||
-- 
1.7.11.7
