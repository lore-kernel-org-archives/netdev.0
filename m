From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] netlink: Replace rhash_portid with load_acquire protected
 boolean
Date: Mon, 21 Sep 2015 16:52:03 -0400
Message-ID: <20150921205203.GI13263@mtj.duckdns.org>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150921133415.GA1740@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Here's an updated version of Herbert's patch which always uses
load_acquire through a helper.

Thanks.
----- 8< -----
The commit 1f770c0a09da855a2b51af6d19de97fb955eca85 ("netlink: Fix
autobind race condition that leads to zero port ID") created some new
races that can occur due to inconsistencies between the two port IDs -
a reader may see zero nlk->portid after seeing non-zero
nlk->rhash_portid.

This patch reverts the original patch and instead uses a load_acquire
protected boolean to indicate that a user netlink socket has been
bound.  The boolean is set with store_release only after the portid is
assigned and the socket is hashed.  The readers test with load_acquire
so that the socket is guaranteed to be visible with a valid port
number and hashed on a true return.

As this sort of lockless tests can be broken in ways which are very
difficult to track down, the boolean field is prefixed with double
underscores and a dedicated test helper with load_acquire is always
used.  While a couple test sites might not strictly require
load_acquire, micro-optimization at this level doens't make sense
given the danger of subtle breakages.

tj: Took Herbert's patch and updated so that all readers test via a
    helper which does load_acquire.

Fixes: 1f770c0a09da ("netlink: Fix autobind race condition that leads to zero port ID")
Reported-by: Tejun Heo <tj@kernel.org>
Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Original-patch-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Tejun Heo <tj@kernel.org>
---
 net/netlink/af_netlink.c |   24 ++++++++++++++----------
 net/netlink/af_netlink.h |   20 +++++++++++++++++++-
 2 files changed, 33 insertions(+), 11 deletions(-)

--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1015,7 +1015,7 @@ static inline int netlink_compare(struct
 	const struct netlink_compare_arg *x = arg->key;
 	const struct netlink_sock *nlk = ptr;
 
-	return nlk->rhash_portid != x->portid ||
+	return nlk->portid != x->portid ||
 	       !net_eq(sock_net(&nlk->sk), read_pnet(&x->pnet));
 }
 
@@ -1041,7 +1041,7 @@ static int __netlink_insert(struct netli
 {
 	struct netlink_compare_arg arg;
 
-	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->rhash_portid);
+	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->portid);
 	return rhashtable_lookup_insert_key(&table->hash, &arg,
 					    &nlk_sk(sk)->node,
 					    netlink_rhashtable_params);
@@ -1095,7 +1095,7 @@ static int netlink_insert(struct sock *s
 	lock_sock(sk);
 
 	err = -EBUSY;
-	if (nlk_sk(sk)->portid)
+	if (nlk_bound(nlk_sk(sk)))
 		goto err;
 
 	err = -ENOMEM;
@@ -1103,7 +1103,7 @@ static int netlink_insert(struct sock *s
 	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
 		goto err;
 
-	nlk_sk(sk)->rhash_portid = portid;
+	nlk_sk(sk)->portid = portid;
 	sock_hold(sk);
 
 	err = __netlink_insert(table, sk);
@@ -1119,7 +1119,8 @@ static int netlink_insert(struct sock *s
 		goto err;
 	}
 
-	nlk_sk(sk)->portid = portid;
+	/* See nlk_bound(). */
+	smp_store_release(&nlk_sk(sk)->__bound, portid);
 
 err:
 	release_sock(sk);
@@ -1521,9 +1522,11 @@ static int netlink_bind(struct socket *s
 			return err;
 	}
 
-	if (nlk->portid)
+	/* Ensure nlk->portid is up-to-date. */
+	if (nlk_bound(nlk)) {
 		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
+	}
 
 	if (nlk->netlink_bind && groups) {
 		int group;
@@ -1539,7 +1542,7 @@ static int netlink_bind(struct socket *s
 		}
 	}
 
-	if (!nlk->portid) {
+	if (!nlk_bound(nlk)) {
 		err = nladdr->nl_pid ?
 			netlink_insert(sk, nladdr->nl_pid) :
 			netlink_autobind(sock);
@@ -1587,7 +1590,7 @@ static int netlink_connect(struct socket
 	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
-	if (!nlk->portid)
+	if (!nlk_bound(nlk))
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
@@ -2428,7 +2431,8 @@ static int netlink_sendmsg(struct socket
 		dst_group = nlk->dst_group;
 	}
 
-	if (!nlk->portid) {
+	/* Ensure nlk->portid is up-to-date. */
+	if (!nlk_bound(nlk)) {
 		err = netlink_autobind(sock);
 		if (err)
 			goto out;
@@ -3257,7 +3261,7 @@ static inline u32 netlink_hash(const voi
 	const struct netlink_sock *nlk = data;
 	struct netlink_compare_arg arg;
 
-	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->rhash_portid);
+	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
 	return jhash2((u32 *)&arg, netlink_compare_arg_len / sizeof(u32), seed);
 }
 
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -3,6 +3,7 @@
 
 #include <linux/rhashtable.h>
 #include <linux/atomic.h>
+#include <asm/barrier.h>
 #include <net/sock.h>
 
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
@@ -25,7 +26,6 @@ struct netlink_ring {
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
 	struct sock		sk;
-	u32			rhash_portid;
 	u32			portid;
 	u32			dst_portid;
 	u32			dst_group;
@@ -36,6 +36,7 @@ struct netlink_sock {
 	unsigned long		state;
 	size_t			max_recvmsg_len;
 	wait_queue_head_t	wait;
+	bool			__bound;	/* always use nlk_bound() */
 	bool			cb_running;
 	struct netlink_callback	cb;
 	struct mutex		*cb_mutex;
@@ -60,6 +61,23 @@ static inline struct netlink_sock *nlk_s
 	return container_of(sk, struct netlink_sock, sk);
 }
 
+/**
+ * nlk_bound - test whether a netlink_sock is bound to a port number
+ * @nlk: netlink_sock of interest
+ *
+ * Test whether @nlk is bound to a port number.  Can be called without any
+ * locks and guarantees no false positive - @nlk has a valid port number
+ * and is hashed on a true return.
+ */
+static inline bool nlk_bound(struct netlink_sock *nlk)
+{
+	/*
+	 * Paired with smp_store_release() in netlink_insert() to guarantee
+	 * the visibility of port number and hashing.
+	 */
+	return smp_load_acquire(&nlk->__bound);
+}
+
 struct netlink_table {
 	struct rhashtable	hash;
 	struct hlist_head	mc_list;
