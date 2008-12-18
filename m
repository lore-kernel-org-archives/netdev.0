From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [PATCH] Allowing more than 64k bound to zero port connections.
Date: Fri, 19 Dec 2008 00:25:49 +0300
Message-ID: <20081218212549.GA20836@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:54875 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbYLRVZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 16:25:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Linux sockets have nice reuse-addr option, which allows to bind multiple
sockets to the same port if they use different local addresses and are
not listeining sockets. This works only if selecting port by hands and
if setting zero port in bind(), it will fail after local port range is
exhausted.

There are crazy people who want to have many tens of thousands of bound
connections, but having several interface aliases to be able to bing to
the different addresses and being able to have many connections, and
calling bind() with zero port ends up only with 32-64k connections
(depending on the local port range syscall).

Attached patch allows to remove this limit. Currently inet port
selection algorithm runs over the whole bind hash table and checks if
appropriate hash bucket does not use randomly selected port. When it
found given cell, system binds socket to the selected port. If sockets
are not freed, this will be finished after local port range is
exhausted, not even trying to check if bound sockets have reuse socket
option and thus could share the bucket.

My patch implements just that: when there are no buckets, which do not
have our random port, we will use that one, which contains sockets with
reuse option and has the smallest number of sockets in it. Its hot path
overhead (i.e. when there are empty buckets) corresponds to additional
three additional condition checks for the buckets which are not empty,
and in case of all positive, storing two values into the local
variables. When local port range is empty, we will quickly select given
port based on that stored values. It could be possible to add some
heuerisstics into the bucket selection, i.e. when overall number of
ports is more than 2/3 of the hash table, we could just randomly select
the bucket and work with it.

This only affects port selection path invoked via bind() call with port
fiels being equal to zero.

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5cc182f..757b6a9 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -80,6 +80,7 @@ struct inet_bind_bucket {
 	struct net		*ib_net;
 	unsigned short		port;
 	signed short		fastreuse;
+	int			num_owners;
 	struct hlist_node	node;
 	struct hlist_head	owners;
 };
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index bd1278a..6478328 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -99,18 +99,28 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	local_bh_disable();
 	if (!snum) {
 		int remaining, rover, low, high;
+		int smallest_size, smallest_rover;
 
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
-		rover = net_random() % remaining + low;
+		smallest_rover = rover = net_random() % remaining + low;
+		smallest_size = ~0;
 
 		do {
 			head = &hashinfo->bhash[inet_bhashfn(net, rover,
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (tb->ib_net == net && tb->port == rover)
+				if (tb->ib_net == net && tb->port == rover) {
+					if (tb->fastreuse > 0 &&
+					    sk->sk_reuse &&
+					    sk->sk_state != TCP_LISTEN &&
+					    tb->num_owners < smallest_size) {
+						smallest_size = tb->num_owners;
+						smallest_rover = rover;
+					}
 					goto next;
+				}
 			break;
 		next:
 			spin_unlock(&head->lock);
@@ -125,14 +135,20 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		 * the top level, not from the 'break;' statement.
 		 */
 		ret = 1;
-		if (remaining <= 0)
+		if (remaining <= 0) {
+			if (smallest_size != ~0) {
+				snum = smallest_rover;
+				goto have_snum;
+			}
 			goto fail;
+		}
 
 		/* OK, here is the one we will use.  HEAD is
 		 * non-NULL and we hold it's mutex.
 		 */
 		snum = rover;
 	} else {
+have_snum:
 		head = &hashinfo->bhash[inet_bhashfn(net, snum,
 				hashinfo->bhash_size)];
 		spin_lock(&head->lock);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 4498190..5b57303 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -61,6 +61,7 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 {
 	inet_sk(sk)->num = snum;
 	sk_add_bind_node(sk, &tb->owners);
+	tb->num_owners++;
 	inet_csk(sk)->icsk_bind_hash = tb;
 }
 
@@ -78,6 +79,7 @@ static void __inet_put_port(struct sock *sk)
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
 	__sk_del_bind_node(sk);
+	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->num = 0;
 	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
@@ -104,6 +106,7 @@ void __inet_inherit_port(struct sock *sk, struct sock *child)
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
 	sk_add_bind_node(child, &tb->owners);
+	tb->num_owners++;
 	inet_csk(child)->icsk_bind_hash = tb;
 	spin_unlock(&head->lock);
 }
@@ -450,9 +453,9 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			 */
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
 				if (tb->ib_net == net && tb->port == port) {
-					WARN_ON(hlist_empty(&tb->owners));
 					if (tb->fastreuse >= 0)
 						goto next_port;
+					WARN_ON(hlist_empty(&tb->owners));
 					if (!check_established(death_row, sk,
 								port, &tw))
 						goto ok;


-- 
	Evgeniy Polyakov
