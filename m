From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netlink: Replace rhash_portid with bound
Date: Mon, 21 Sep 2015 21:34:16 +0800
Message-ID: <20150921133415.GA1740@gondor.apana.org.au>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tj@kernel.org, cwang@twopensource.com, tom@herbertland.com,
	kafai@fb.com, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org,
	jiri@resnulli.us, nicolas.dichtel@6wind.com, tgraf@suug.ch,
	sfeldma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48281 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbbIUNen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 09:34:43 -0400
Content-Disposition: inline
In-Reply-To: <20150920.231104.525285577747035896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 20, 2015 at 11:11:04PM -0700, David Miller wrote:
>
> Yeah at this point incremental patches work the best.

OK here is the patch:

---8<---
The commit 1f770c0a09da855a2b51af6d19de97fb955eca85 ("netlink:
Fix autobind race condition that leads to zero port ID") created
some new races that can occur due to inconcsistencies between the
two port IDs.

Tejun is right that a barrier is unavoidable.  Therefore I am
reverting to the original patch that used a boolean to indicate
that a user netlink socket has been bound.

Barriers have been added where necessary to ensure that a valid
portid is used.

Fixes: 1f770c0a09da ("netlink: Fix autobind race condition that leads to zero port ID")
Reported-by: Tejun Heo <tj@kernel.org>
Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 303efb7..f5362aae 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -24,6 +24,7 @@
 
 #include <linux/module.h>
 
+#include <asm/barrier.h>
 #include <linux/capability.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -1015,7 +1016,7 @@ static inline int netlink_compare(struct rhashtable_compare_arg *arg,
 	const struct netlink_compare_arg *x = arg->key;
 	const struct netlink_sock *nlk = ptr;
 
-	return nlk->rhash_portid != x->portid ||
+	return nlk->portid != x->portid ||
 	       !net_eq(sock_net(&nlk->sk), read_pnet(&x->pnet));
 }
 
@@ -1041,7 +1042,7 @@ static int __netlink_insert(struct netlink_table *table, struct sock *sk)
 {
 	struct netlink_compare_arg arg;
 
-	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->rhash_portid);
+	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->portid);
 	return rhashtable_lookup_insert_key(&table->hash, &arg,
 					    &nlk_sk(sk)->node,
 					    netlink_rhashtable_params);
@@ -1095,7 +1096,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	lock_sock(sk);
 
 	err = -EBUSY;
-	if (nlk_sk(sk)->portid)
+	if (nlk_sk(sk)->bound)
 		goto err;
 
 	err = -ENOMEM;
@@ -1103,7 +1104,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
 		goto err;
 
-	nlk_sk(sk)->rhash_portid = portid;
+	nlk_sk(sk)->portid = portid;
 	sock_hold(sk);
 
 	err = __netlink_insert(table, sk);
@@ -1119,7 +1120,11 @@ static int netlink_insert(struct sock *sk, u32 portid)
 		goto err;
 	}
 
-	nlk_sk(sk)->portid = portid;
+	/* rhashtable_insert carries an implicit write memory barrier
+	 * so we don't need an smp_wmb here in order to ensure that
+	 * portid is set before bound.
+	 */
+	nlk_sk(sk)->bound = portid;
 
 err:
 	release_sock(sk);
@@ -1521,9 +1526,11 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return err;
 	}
 
-	if (nlk->portid)
+	/* Ensure nlk->portid is up-to-date. */
+	if (smp_load_acquire(&nlk->bound)) {
 		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
+	}
 
 	if (nlk->netlink_bind && groups) {
 		int group;
@@ -1539,7 +1546,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	if (!nlk->portid) {
+	if (!nlk->bound) {
 		err = nladdr->nl_pid ?
 			netlink_insert(sk, nladdr->nl_pid) :
 			netlink_autobind(sock);
@@ -1587,7 +1594,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
-	if (!nlk->portid)
+	if (!nlk->bound)
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
@@ -2428,7 +2435,8 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		dst_group = nlk->dst_group;
 	}
 
-	if (!nlk->portid) {
+	/* Ensure nlk->portid is up-to-date. */
+	if (!smp_load_acquire(&nlk->bound)) {
 		err = netlink_autobind(sock);
 		if (err)
 			goto out;
@@ -3257,7 +3265,7 @@ static inline u32 netlink_hash(const void *data, u32 len, u32 seed)
 	const struct netlink_sock *nlk = data;
 	struct netlink_compare_arg arg;
 
-	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->rhash_portid);
+	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
 	return jhash2((u32 *)&arg, netlink_compare_arg_len / sizeof(u32), seed);
 }
 
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index c96dfa3..e6aae40 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -25,7 +25,6 @@ struct netlink_ring {
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
 	struct sock		sk;
-	u32			rhash_portid;
 	u32			portid;
 	u32			dst_portid;
 	u32			dst_group;
@@ -36,6 +35,7 @@ struct netlink_sock {
 	unsigned long		state;
 	size_t			max_recvmsg_len;
 	wait_queue_head_t	wait;
+	bool			bound;
 	bool			cb_running;
 	struct netlink_callback	cb;
 	struct mutex		*cb_mutex;
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
