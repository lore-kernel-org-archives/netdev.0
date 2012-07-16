From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 2/7] net-tcp: Fast Open client - cookie cache
Date: Mon, 16 Jul 2012 14:16:45 -0700
Message-ID: <1342473410-6265-3-git-send-email-ycheng@google.com>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
Cc: sivasankar@cs.ucsd.edu, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f202.google.com ([209.85.212.202]:46712 "EHLO
	mail-wi0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab2GPVRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 17:17:05 -0400
Received: by wibhr14 with SMTP id hr14so179197wib.1
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 14:17:03 -0700 (PDT)
In-Reply-To: <1342473410-6265-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Fast Open cookie cache is used by a TCP Fast Open client to store
remote servers' Fast Open cookies. It stores one Fast Open cookie
per IP (v4 or v6) and by default 1024 cookies total. The size is
tunable via /proc/sys/net/ipv4/tcp_fastopen_cookies. Setting it to 0
will flush the cache.

The inetpeer cache also caches remote peer's information but the
in-active cache entries are recycled on the scale of minutes. Therefore
a separate storage is required but the lookup is done via inetpeer.
Each inetpeer entry holds a cookie cache entry pointer (if TFO is used
on that IP). On cache write, the cookie cache entry is allocated and
stored in a list for LRU replacement. A spinlock protects any R/W
operation on the cookie cache entry and the list.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/inetpeer.h     |    2 +
 include/net/tcp.h          |    6 ++
 net/ipv4/inetpeer.c        |    2 +
 net/ipv4/sysctl_net_ipv4.c |   26 ++++++++
 net/ipv4/tcp_fastopen.c    |  140 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 176 insertions(+), 0 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 53f464d..0240709 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
+#include <linux/tcp.h>
 #include <linux/rtnetlink.h>
 #include <net/ipv6.h>
 #include <linux/atomic.h>
@@ -53,6 +54,7 @@ struct inet_peer {
 		struct rcu_head         rcu;
 		struct inet_peer	*gc_next;
 	};
+	struct fastopen_entry		*fastopen;
 
 	/* following fields might be frequently dirtied */
 	__u32			dtime;	/* the time of last use of not referenced entries */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 87f486f..4b29688 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -385,6 +385,12 @@ enum tcp_tw_status {
 	TCP_TW_SYN = 3
 };
 
+/* From tcp_fastopen.c */
+extern int tcp_fastopen_size_cache(int size);
+extern void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
+				   struct tcp_fastopen_cookie *cookie);
+extern void tcp_fastopen_cache_set(struct sock *sk, u16 *mss,
+				   struct tcp_fastopen_cookie *cookie);
 
 extern enum tcp_tw_status tcp_timewait_state_process(struct inet_timewait_sock *tw,
 						     struct sk_buff *skb,
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e1e0a4e..9151ddc 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -63,6 +63,7 @@
  *		   usually under some other lock to prevent node disappearing
  *		daddr: unchangeable
  *		ip_id_count: atomic value (no lock needed)
+ *		fastopen_entry: TCP Fast Open cookie cache. See tcp_fastopen.c
  */
 
 static struct kmem_cache *peer_cachep __read_mostly;
@@ -511,6 +512,7 @@ relookup:
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
 		p->rate_last = 0;
+		p->fastopen = NULL;
 		INIT_LIST_HEAD(&p->gc_list);
 
 		/* Link the node. */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2a946a19..8d4571a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -29,6 +29,7 @@
 static int zero;
 static int two = 2;
 static int tcp_retr1_max = 255;
+static int tcp_fastopen_cookies_max = 65536;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 static int tcp_adv_win_scale_min = -31;
@@ -220,6 +221,25 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
 	return 0;
 }
 
+static int proc_tcp_fastopen_cache_size(ctl_table *ctl, int write,
+					void __user *buffer, size_t *lenp,
+					loff_t *ppos)
+{
+	int ret;
+	int max_cookies = tcp_fastopen_size_cache(-1);
+	ctl_table tbl = {
+		.data = &max_cookies,
+		.maxlen = sizeof(max_cookies),
+		.extra1 = &zero,
+		.extra2 = &tcp_fastopen_cookies_max,
+	};
+
+	ret = proc_dointvec_minmax(&tbl, write, buffer, lenp, ppos);
+	if (write && ret == 0)
+		tcp_fastopen_size_cache(max_cookies);
+	return ret;
+}
+
 static struct ctl_table ipv4_table[] = {
 	{
 		.procname	= "tcp_timestamps",
@@ -374,6 +394,12 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "tcp_fastopen_cookies",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_tcp_fastopen_cache_size,
+	},
+	{
 		.procname	= "tcp_tw_recycle",
 		.data		= &tcp_death_row.sysctl_tw_recycle,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index a7f729c..40fdf21 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -1,10 +1,150 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/tcp.h>
+#include <net/inetpeer.h>
 
 int sysctl_tcp_fastopen;
 
+/* The Fast Open cookie cache is used by a TCP Fast Open client to store
+ * remote servers' Fast Open cookies. It stores one Fast Open cookie
+ * per IP and by default 1024 cookies total. The size is tunable via
+ * /proc/sys/net/ipv4/tcp_fastopen_cookies. Setting it to 0 will flush
+ * the cache.
+ *
+ * The inetpeer cache also caches remote peer's information but the
+ * in-active cache entries are recycled on the scale of minutes. Therefore
+ * a separate storage is required but the lookup is done via inetpeer.
+ * Each inetpeer entry holds a cookie cache entry pointer (if TFO is used
+ * on that IP). On cache write, the cookie cache entry is allocated and
+ * stored in a list for LRU replacement. A spinlock protects any R/W
+ * operation on the cookie cache entry and the list.
+ */
+struct fastopen_entry {
+	u16	mss;			/* TCP MSS value */
+	struct	tcp_fastopen_cookie	cookie;	/* TCP Fast Open cookie */
+	struct	list_head	lru_list;	/* cookie cache lru_list node */
+	struct	inet_peer	*peer;	/* inetpeer entry (for fast lookup) */
+};
+
+static struct tcp_fastopen_cookie_cache {
+	spinlock_t lock;		/* for lru_list, cnt, size, entries */
+	struct list_head lru_list;	/* head is the least recently used */
+	int cnt;			/* size of lru_list */
+	int size;			/* cache capacity */
+} cookie_cache;
+
+/* Evict the LRU entry if cache is full. Caller must hold cooke_cache.lock */
+static struct fastopen_entry *__tcp_fastopen_remove_lru(void)
+{
+	struct fastopen_entry *entry;
+
+	if (cookie_cache.cnt <= cookie_cache.size || cookie_cache.cnt <= 0)
+		return NULL;
+
+	entry = list_first_entry(&cookie_cache.lru_list,
+				 struct fastopen_entry, lru_list);
+	list_del_init(&entry->lru_list);
+	--cookie_cache.cnt;
+	entry->peer->fastopen = NULL;
+	return entry;
+}
+
+int tcp_fastopen_size_cache(int size)
+{
+	while (size >= 0) {
+		struct fastopen_entry *lru_entry;
+
+		spin_lock_bh(&cookie_cache.lock);
+		cookie_cache.size = size;
+		lru_entry = __tcp_fastopen_remove_lru();
+		spin_unlock_bh(&cookie_cache.lock);
+
+		if (lru_entry == NULL)
+			break;
+		inet_putpeer(lru_entry->peer);
+		kfree(lru_entry);
+	}
+	return cookie_cache.size;
+}
+
+static struct inet_peer *tcp_fastopen_inetpeer(struct sock *sk, int create)
+{
+	struct net *net = dev_net(__sk_dst_get(sk)->dev);
+
+	if (sk->sk_family == AF_INET)
+		return inet_getpeer_v4(net->ipv4.peers,
+				       inet_sk(sk)->inet_daddr, create);
+	else if (sk->sk_family == AF_INET6)
+		return inet_getpeer_v6(net->ipv6.peers,
+				       &inet6_sk(sk)->daddr, create);
+	return NULL;
+}
+
+void tcp_fastopen_cache_get(struct sock *sk, u32 *mss,
+			    struct tcp_fastopen_cookie *cookie)
+{
+	struct inet_peer *peer = tcp_fastopen_inetpeer(sk, 0);
+	struct fastopen_entry *entry;
+
+	if (peer == NULL)
+		return;
+
+	spin_lock_bh(&cookie_cache.lock);
+	entry = peer->fastopen;
+	if (entry != NULL) {
+		*mss = entry->mss;
+		*cookie = entry->cookie;
+		list_move_tail(&entry->lru_list, &cookie_cache.lru_list);
+	}
+	spin_unlock_bh(&cookie_cache.lock);
+
+	inet_putpeer(peer);
+}
+
+void tcp_fastopen_cache_set(struct sock *sk, u32 *mss,
+			    struct tcp_fastopen_cookie *cookie)
+{
+	struct inet_peer *peer = tcp_fastopen_inetpeer(sk, 1);
+	struct fastopen_entry *entry = NULL, *new_entry = NULL;
+
+	if (peer == NULL)
+		return;
+
+	spin_lock_bh(&cookie_cache.lock);
+	if (peer->fastopen == NULL) {
+		new_entry = kmalloc(sizeof(struct fastopen_entry), GFP_ATOMIC);
+		if (new_entry == NULL) {
+			spin_unlock_bh(&cookie_cache.lock);
+			goto out;
+		}
+		new_entry->peer = peer;
+		INIT_LIST_HEAD(&new_entry->lru_list);
+		peer->fastopen = new_entry;
+		++cookie_cache.cnt;
+	}
+	entry = peer->fastopen;
+	entry->mss = *mss;
+	if (cookie->len > 0)
+		entry->cookie = *cookie;
+	list_move_tail(&entry->lru_list, &cookie_cache.lru_list);
+	entry = __tcp_fastopen_remove_lru();
+	spin_unlock_bh(&cookie_cache.lock);
+
+	if (entry) {
+		inet_putpeer(entry->peer);
+		kfree(entry);
+	}
+out:
+	if (new_entry == NULL)
+		inet_putpeer(peer);
+}
+
 static int __init tcp_fastopen_init(void)
 {
+	INIT_LIST_HEAD(&cookie_cache.lru_list);
+	spin_lock_init(&cookie_cache.lock);
+	cookie_cache.size = 1024;
 	return 0;
 }
 
-- 
1.7.7.3
