From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: speedup /proc/net/unix
Date: Fri, 08 Jun 2012 17:03:21 +0200
Message-ID: <1339167801.6001.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38636 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336Ab2FHPDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 11:03:25 -0400
Received: by eeit10 with SMTP id t10so1191281eei.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 08:03:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

/proc/net/unix has quadratic behavior, and can hold unix_table_lock for
a while if high number of unix sockets are alive. (90 ms for 200k
sockets...)

We already have a hash table, so its quite easy to use it.

Problem is unbound sockets are still hashed in a single hash slot
(unix_socket_table[UNIX_HASH_TABLE])

This patch also spreads unbound sockets to 256 hash slots, to speedup
both /proc/net/unix and unix_diag.

Time to read /proc/net/unix with 200k unix sockets :
(time dd if=/proc/net/unix of=/dev/null bs=4k)

before : 520 secs
after : 2 secs

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 include/net/af_unix.h |    3 -
 net/unix/af_unix.c    |  110 +++++++++++++++++++++++-----------------
 net/unix/diag.c       |    6 +-
 3 files changed, 70 insertions(+), 49 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 2ee33da..b5f8988 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -14,10 +14,11 @@ extern struct sock *unix_get_socket(struct file *filp);
 extern struct sock *unix_peer_get(struct sock *);
 
 #define UNIX_HASH_SIZE	256
+#define UNIX_HASH_BITS	8
 
 extern unsigned int unix_tot_inflight;
 extern spinlock_t unix_table_lock;
-extern struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
+extern struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE];
 
 struct unix_address {
 	atomic_t	refcnt;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 641f2e4..cf83f6b 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -115,15 +115,24 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 
-struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
+struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE];
 EXPORT_SYMBOL_GPL(unix_socket_table);
 DEFINE_SPINLOCK(unix_table_lock);
 EXPORT_SYMBOL_GPL(unix_table_lock);
 static atomic_long_t unix_nr_socks;
 
-#define unix_sockets_unbound	(&unix_socket_table[UNIX_HASH_SIZE])
 
-#define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
+static struct hlist_head *unix_sockets_unbound(void *addr)
+{
+	unsigned long hash = (unsigned long)addr;
+
+	hash ^= hash >> 16;
+	hash ^= hash >> 8;
+	hash %= UNIX_HASH_SIZE;
+	return &unix_socket_table[UNIX_HASH_SIZE + hash];
+}
+
+#define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash < UNIX_HASH_SIZE)
 
 #ifdef CONFIG_SECURITY_NETWORK
 static void unix_get_secdata(struct scm_cookie *scm, struct sk_buff *skb)
@@ -645,7 +654,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
-	unix_insert_socket(unix_sockets_unbound, sk);
+	unix_insert_socket(unix_sockets_unbound(sk), sk);
 out:
 	if (sk == NULL)
 		atomic_long_dec(&unix_nr_socks);
@@ -2239,47 +2248,58 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 }
 
 #ifdef CONFIG_PROC_FS
-static struct sock *first_unix_socket(int *i)
-{
-	for (*i = 0; *i <= UNIX_HASH_SIZE; (*i)++) {
-		if (!hlist_empty(&unix_socket_table[*i]))
-			return __sk_head(&unix_socket_table[*i]);
-	}
-	return NULL;
-}
 
-static struct sock *next_unix_socket(int *i, struct sock *s)
-{
-	struct sock *next = sk_next(s);
-	/* More in this chain? */
-	if (next)
-		return next;
-	/* Look for next non-empty chain. */
-	for ((*i)++; *i <= UNIX_HASH_SIZE; (*i)++) {
-		if (!hlist_empty(&unix_socket_table[*i]))
-			return __sk_head(&unix_socket_table[*i]);
-	}
-	return NULL;
-}
+#define BUCKET_SPACE (BITS_PER_LONG - (UNIX_HASH_BITS + 1) - 1)
+
+#define get_bucket(x) ((x) >> BUCKET_SPACE)
+#define get_offset(x) ((x) & ((1L << BUCKET_SPACE) - 1))
+#define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
 
 struct unix_iter_state {
 	struct seq_net_private p;
-	int i;
 };
 
-static struct sock *unix_seq_idx(struct seq_file *seq, loff_t pos)
+static struct sock *unix_from_bucket(struct seq_file *seq, loff_t *pos)
 {
-	struct unix_iter_state *iter = seq->private;
-	loff_t off = 0;
-	struct sock *s;
+	unsigned long offset = get_offset(*pos);
+	unsigned long bucket = get_bucket(*pos);
+	struct sock *sk;
+	unsigned long count = 0;
 
-	for (s = first_unix_socket(&iter->i); s; s = next_unix_socket(&iter->i, s)) {
-		if (sock_net(s) != seq_file_net(seq))
+	for (sk = sk_head(&unix_socket_table[bucket]); sk; sk = sk_next(sk)) {
+		if (sock_net(sk) != seq_file_net(seq))
 			continue;
-		if (off == pos)
-			return s;
-		++off;
+		if (++count == offset)
+			break;
 	}
+
+	return sk;
+}
+
+static struct sock *unix_next_socket(struct seq_file *seq,
+				     struct sock *sk,
+				     loff_t *pos)
+{
+	unsigned long bucket;
+
+	while (sk > (struct sock *)SEQ_START_TOKEN) {
+		sk = sk_next(sk);
+		if (!sk)
+			goto next_bucket;
+		if (sock_net(sk) == seq_file_net(seq))
+			return sk;
+	}
+
+	do {
+		sk = unix_from_bucket(seq, pos);
+		if (sk)
+			return sk;
+
+next_bucket:
+		bucket = get_bucket(*pos) + 1;
+		*pos = set_bucket_offset(bucket, 1);
+	} while (bucket < ARRAY_SIZE(unix_socket_table));
+
 	return NULL;
 }
 
@@ -2287,22 +2307,20 @@ static void *unix_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(unix_table_lock)
 {
 	spin_lock(&unix_table_lock);
-	return *pos ? unix_seq_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+
+	if (!*pos)
+		return SEQ_START_TOKEN;
+
+	if (get_bucket(*pos) >= ARRAY_SIZE(unix_socket_table))
+		return NULL;
+
+	return unix_next_socket(seq, NULL, pos);
 }
 
 static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct unix_iter_state *iter = seq->private;
-	struct sock *sk = v;
 	++*pos;
-
-	if (v == SEQ_START_TOKEN)
-		sk = first_unix_socket(&iter->i);
-	else
-		sk = next_unix_socket(&iter->i, sk);
-	while (sk && (sock_net(sk) != seq_file_net(seq)))
-		sk = next_unix_socket(&iter->i, sk);
-	return sk;
+	return unix_next_socket(seq, v, pos);
 }
 
 static void unix_seq_stop(struct seq_file *seq, void *v)
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 47d3002..7e8a24b 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -195,7 +195,9 @@ static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	num = s_num = cb->args[1];
 
 	spin_lock(&unix_table_lock);
-	for (slot = s_slot; slot <= UNIX_HASH_SIZE; s_num = 0, slot++) {
+	for (slot = s_slot;
+	     slot < ARRAY_SIZE(unix_socket_table);
+	     s_num = 0, slot++) {
 		struct sock *sk;
 		struct hlist_node *node;
 
@@ -228,7 +230,7 @@ static struct sock *unix_lookup_by_ino(int ino)
 	struct sock *sk;
 
 	spin_lock(&unix_table_lock);
-	for (i = 0; i <= UNIX_HASH_SIZE; i++) {
+	for (i = 0; i < ARRAY_SIZE(unix_socket_table); i++) {
 		struct hlist_node *node;
 
 		sk_for_each(sk, node, &unix_socket_table[i])
