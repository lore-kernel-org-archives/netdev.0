From: David Miller <davem@davemloft.net>
Subject: Re: Allowing more than 64k connections and heavily optimize
 bind(0) time.
Date: Sun, 11 Jan 2009 23:01:38 -0800 (PST)
Message-ID: <20090111.230138.237917213.davem@davemloft.net>
References: <20090110.232019.98466627.davem@davemloft.net>
	<20090111125206.GA24173@ioremap.net>
	<200901111503.10736.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750977AbZALHBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 02:01:38 -0500
In-Reply-To: <200901111503.10736.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryschenko <denys@visp.net.lb>
Date: Sun, 11 Jan 2009 15:03:10 +0200

> I did test on loaded squid.
> 
> 49878 connections established ,1421/sec
> It is not peak time yet, passed 24 hours testing.
> 
> I can't compare load, because it is real life load and always vary, but thing 
> i can say, it doesn't crash :-)

Ok, I applied Evegniy's patch, but it didn't even come WITHIN A MILE
of applying to the current tree.  Eric Dumazet's RCU hash table
changes and net namespace macro modifications destroyed all of the
context and content in these patches.  It was one huge reject, even
with dumb patch.

I fixed it up and applied it to what will become net-next-2.6, but
that's only because I'm in a good mood and I made Evgeniy wait a long
time already.

The zero compile time initializer of ->bsockets to zero was
superfluous, so I dropped it entirely.

Here is what I committed.

inet: Allowing more than 64k connections and heavily optimize bind(0) time.

With simple extension to the binding mechanism, which allows to bind more
than 64k sockets (or smaller amount, depending on sysctl parameters),
we have to traverse the whole bind hash table to find out empty bucket.
And while it is not a problem for example for 32k connections, bind()
completion time grows exponentially (since after each successful binding
we have to traverse one bucket more to find empty one) even if we start
each time from random offset inside the hash table.

So, when hash table is full, and we want to add another socket, we have
to traverse the whole table no matter what, so effectivelly this will be
the worst case performance and it will be constant.

Attached picture shows bind() time depending on number of already bound
sockets.

Green area corresponds to the usual binding to zero port process, which
turns on kernel port selection as described above. Red area is the bind
process, when number of reuse-bound sockets is not limited by 64k (or
sysctl parameters). The same exponential growth (hidden by the green
area) before number of ports reaches sysctl limit.

At this time bind hash table has exactly one reuse-enbaled socket in a
bucket, but it is possible that they have different addresses. Actually
kernel selects the first port to try randomly, so at the beginning bind
will take roughly constant time, but with time number of port to check
after random start will increase. And that will have exponential growth,
but because of above random selection, not every next port selection
will necessary take longer time than previous. So we have to consider
the area below in the graph (if you could zoom it, you could find, that
there are many different times placed there), so area can hide another.

Blue area corresponds to the port selection optimization.

This is rather simple design approach: hashtable now maintains (unprecise
and racely updated) number of currently bound sockets, and when number
of such sockets becomes greater than predefined value (I use maximum
port range defined by sysctls), we stop traversing the whole bind hash
table and just stop at first matching bucket after random start. Above
limit roughly corresponds to the case, when bind hash table is full and
we turned on mechanism of allowing to bind more reuse-enabled sockets,
so it does not change behaviour of other sockets.

As I just have been told, it results in this strange behaviour:
$ grep -n :60013 netstat.res
33101:tcp        0      0 local1:60013       remote:80       ESTABLISHED
33105:tcp        0      0 local1:60013       remote:80       ESTABLISHED
52084:tcp        0      0 local2:60013       remote:80       ESTABLISHED
52085:tcp        0      0 local2:60013       remote:80       ESTABLISHED
58249:tcp        0      0 local3:60013       remote:80       ESTABLISHED

it is yet to resolve what it is and how much harm it brings :)

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>
Tested-by: Denys Fedoryschenko <denys@visp.net.lb>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_hashtables.h   |    3 ++-
 net/ipv4/inet_connection_sock.c |   39 ++++++++++++++++++++++++++++++++-------
 net/ipv4/inet_hashtables.c      |   11 ++++++++++-
 3 files changed, 44 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index f44bb5c..cdc08c1 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -82,6 +82,7 @@ struct inet_bind_bucket {
 #endif
 	unsigned short		port;
 	signed short		fastreuse;
+	int			num_owners;
 	struct hlist_node	node;
 	struct hlist_head	owners;
 };
@@ -133,7 +134,7 @@ struct inet_hashinfo {
 	struct inet_bind_hashbucket	*bhash;
 
 	unsigned int			bhash_size;
-	/* Note : 4 bytes padding on 64 bit arches */
+	int				bsockets;
 
 	struct kmem_cache		*bind_bucket_cachep;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f26ab38..5061dbc 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -93,24 +93,40 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	struct inet_bind_hashbucket *head;
 	struct hlist_node *node;
 	struct inet_bind_bucket *tb;
-	int ret;
+	int ret, attempts = 5;
 	struct net *net = sock_net(sk);
+	int smallest_size = -1, smallest_rover;
 
 	local_bh_disable();
 	if (!snum) {
 		int remaining, rover, low, high;
 
+again:
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
-		rover = net_random() % remaining + low;
+		smallest_rover = rover = net_random() % remaining + low;
 
+		smallest_size = -1;
 		do {
 			head = &hashinfo->bhash[inet_bhashfn(net, rover,
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (ib_net(tb) == net && tb->port == rover)
+				if (ib_net(tb) == net && tb->port == rover) {
+					if (tb->fastreuse > 0 &&
+					    sk->sk_reuse &&
+					    sk->sk_state != TCP_LISTEN &&
+					    (tb->num_owners < smallest_size || smallest_size == -1)) {
+						smallest_size = tb->num_owners;
+						smallest_rover = rover;
+						if (hashinfo->bsockets > (high - low) + 1) {
+							spin_unlock(&head->lock);
+							snum = smallest_rover;
+							goto have_snum;
+						}
+					}
 					goto next;
+				}
 			break;
 		next:
 			spin_unlock(&head->lock);
@@ -125,14 +141,19 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		 * the top level, not from the 'break;' statement.
 		 */
 		ret = 1;
-		if (remaining <= 0)
+		if (remaining <= 0) {
+			if (smallest_size != -1) {
+				snum = smallest_rover;
+				goto have_snum;
+			}
 			goto fail;
-
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
@@ -145,12 +166,16 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 tb_found:
 	if (!hlist_empty(&tb->owners)) {
 		if (tb->fastreuse > 0 &&
-		    sk->sk_reuse && sk->sk_state != TCP_LISTEN) {
+		    sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
+		    smallest_size == -1) {
 			goto success;
 		} else {
 			ret = 1;
-			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb))
+			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0)
+					goto again;
 				goto fail_unlock;
+			}
 		}
 	}
 tb_not_found:
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 6a1045d..d7b6178 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -38,6 +38,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 		write_pnet(&tb->ib_net, hold_net(net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
+		tb->num_owners = 0;
 		INIT_HLIST_HEAD(&tb->owners);
 		hlist_add_head(&tb->node, &head->chain);
 	}
@@ -59,8 +60,13 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
 void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 		    const unsigned short snum)
 {
+	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
+
+	hashinfo->bsockets++;
+
 	inet_sk(sk)->num = snum;
 	sk_add_bind_node(sk, &tb->owners);
+	tb->num_owners++;
 	inet_csk(sk)->icsk_bind_hash = tb;
 }
 
@@ -75,9 +81,12 @@ static void __inet_put_port(struct sock *sk)
 	struct inet_bind_hashbucket *head = &hashinfo->bhash[bhash];
 	struct inet_bind_bucket *tb;
 
+	hashinfo->bsockets--;
+
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
 	__sk_del_bind_node(sk);
+	tb->num_owners--;
 	inet_csk(sk)->icsk_bind_hash = NULL;
 	inet_sk(sk)->num = 0;
 	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
@@ -444,9 +453,9 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			 */
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
 				if (ib_net(tb) == net && tb->port == port) {
-					WARN_ON(hlist_empty(&tb->owners));
 					if (tb->fastreuse >= 0)
 						goto next_port;
+					WARN_ON(hlist_empty(&tb->owners));
 					if (!check_established(death_row, sk,
 								port, &tw))
 						goto ok;
-- 
1.6.1.15.g159c88

