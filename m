From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Allowing more than 64k bound to zero port connections.
Date: Tue, 23 Dec 2008 14:42:02 +0300
Message-ID: <20081223114202.GA14173@ioremap.net>
References: <20081218212549.GA20836@ioremap.net> <20081222.195116.10343492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:44793 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758AbYLWLmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2008 06:42:08 -0500
Content-Disposition: inline
In-Reply-To: <20081222.195116.10343492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2008 at 07:51:16PM -0800, David Miller (davem@davemloft.net) wrote:
> > Attached patch allows to remove this limit. Currently inet port
> > selection algorithm runs over the whole bind hash table and checks if
> > appropriate hash bucket does not use randomly selected port. When it
> > found given cell, system binds socket to the selected port. If sockets
> > are not freed, this will be finished after local port range is
> > exhausted, not even trying to check if bound sockets have reuse socket
> > option and thus could share the bucket.
> 
> I've reviewed this enough to believe that it is implemented
> properly.
> 
> However I want to do some research about socket semantics in
> this area before applying this.  I'm travelling and don't
> have my favorite books with me, so this will have to wait
> until later this week.

Ok, no problem, have a nice vacations.

I've attached updated patch (tested on .24 though), which fixes a race
when 'usual' socket can sneak into the bucket and thus it will stop
being fastreuse, but we will add there additional fastreuse socket,
which then may trigger warn_on.

Fix is to check if bucket changed its fastreuse to negative and start
agin in this case, otherwise socket can be safely added. Subsequent
bucket search will not scan the whole table, but will get the first
random port, which matches our fastreuse expectations, since we already
know that all buckets are non-empty. This small optimization affects
only the case, when all buckets are non-empty and we failed to insert
reuse socket because usual one sneaked in.

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
index bd1278a..67788e4 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -99,18 +99,31 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	local_bh_disable();
 	if (!snum) {
 		int remaining, rover, low, high;
+ 		int smallest_size, smallest_rover, get_random = 0;
 
+again:
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
-		rover = net_random() % remaining + low;
+ 		smallest_rover = rover = net_random() % remaining + low;
+ 		smallest_size = ~0;
 
 		do {
 			head = &hashinfo->bhash[inet_bhashfn(net, rover,
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (tb->ib_net == net && tb->port == rover)
+				if (tb->ib_net == net && tb->port == rover) {
+ 					if (tb->fastreuse > 0 &&
+ 					    sk->sk_reuse &&
+ 					    sk->sk_state != TCP_LISTEN &&
+ 					    tb->num_owners < smallest_size) {
+ 						smallest_size = tb->num_owners;
+ 						smallest_rover = rover;
+ 						if (get_random)
+ 							break;
+ 					}
 					goto next;
+				}
 			break;
 		next:
 			spin_unlock(&head->lock);
@@ -125,9 +138,19 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		 * the top level, not from the 'break;' statement.
 		 */
 		ret = 1;
-		if (remaining <= 0)
+		if (remaining <= 0) {
+			if (smallest_size != ~0) {
+				head = &hashinfo->bhash[inet_bhashfn(net, smallest_rover, hashinfo->bhash_size)];
+				spin_lock(&head->lock);
+				inet_bind_bucket_for_each(tb, node, &head->chain)
+					if (tb->port == smallest_rover && tb->fastreuse > 0)
+						goto tb_found;
+				spin_unlock(&head->lock);
+				get_random = 1;
+				goto again;
+			}
 			goto fail;
-
+		}
 		/* OK, here is the one we will use.  HEAD is
 		 * non-NULL and we hold it's mutex.
 		 */
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 4498190..4970a03 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -38,6 +38,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		tb->ib_net       = hold_net(net);
 		tb->port      = snum;
 		tb->fastreuse = 0;
+		tb->num_owners = 0;
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
 	}
@@ -61,6 +62,7 @@ void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 {
 	inet_sk(sk)->num = snum;
 	sk_add_bind_node(sk, &tb->owners);
+	tb->num_owners++;
 	inet_csk(sk)->icsk_bind_hash = tb;
 }
 
@@ -78,6 +80,7 @@ static void __inet_put_port(struct sock *sk)
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
 	__sk_del_bind_node(sk);
+	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->num = 0;
 	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
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
