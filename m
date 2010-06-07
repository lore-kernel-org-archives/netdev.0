From: Tom Herbert <therbert@google.com>
Subject: [PATCH] tcp: Fix slowness in read /proc/net/tcp
Date: Sun, 6 Jun 2010 20:27:01 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1006062020180.24064@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:47947 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309Ab0FGD1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 23:27:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch address a serious performance issue in reading the
TCP sockets table (/proc/net/tcp).

Reading the full table is done by a number of sequential read
operations.  At each read operation, a seek is done to find the
last socket that was previously read.  This seek operation requires
that the sockets in the table need to be counted up to the current
file position, and to count each of these requires taking a lock for
each non-empty bucket.  The whole algorithm is O(n^2).

The fix is to cache the last bucket value, offset within the bucket,
and the file position returned by the last read operation.   On the
next sequential read, the bucket and offset are used to find the
last read socket immediately without needing ot scan the previous
buckets  the table.  This algorithm t read the whole table is O(n).

The improvement offered by this patch is easily show by performing
cat'ing /proc/net/tcp on a machine with a lot of connections.  With
about 182K connections in the table, I see the following:

- Without patch
time cat /proc/net/tcp > /dev/null

real	1m56.729s
user	0m0.214s
sys	1m56.344s

- With patch
time cat /proc/net/tcp > /dev/null

real	0m0.894s
user	0m0.290s
sys	0m0.594s

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a144914..5731664 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1413,7 +1413,8 @@ struct tcp_iter_state {
 	sa_family_t		family;
 	enum tcp_seq_states	state;
 	struct sock		*syn_wait_sk;
-	int			bucket, sbucket, num, uid;
+	int			bucket, offset, sbucket, num, uid;
+	loff_t			last_pos;
 };
 
 extern int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 202cf09..4af6f20 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1977,6 +1977,11 @@ static inline struct inet_timewait_sock *tw_next(struct inet_timewait_sock *tw)
 		hlist_nulls_entry(tw->tw_node.next, typeof(*tw), tw_node) : NULL;
 }
 
+/*
+ * Get next listener socket follow cur.  If cur is NULL, get first socket
+ * starting from bucket given in st->bucket; when st->bucket is zero the
+ * very first socket in the hash table is returned.
+ */
 static void *listening_get_next(struct seq_file *seq, void *cur)
 {
 	struct inet_connection_sock *icsk;
@@ -1987,14 +1992,15 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	struct net *net = seq_file_net(seq);
 
 	if (!sk) {
-		st->bucket = 0;
-		ilb = &tcp_hashinfo.listening_hash[0];
+		ilb = &tcp_hashinfo.listening_hash[st->bucket];
 		spin_lock_bh(&ilb->lock);
 		sk = sk_nulls_head(&ilb->head);
+		st->offset = 0;
 		goto get_sk;
 	}
 	ilb = &tcp_hashinfo.listening_hash[st->bucket];
 	++st->num;
+	++st->offset;
 
 	if (st->state == TCP_SEQ_STATE_OPENREQ) {
 		struct request_sock *req = cur;
@@ -2009,6 +2015,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 				}
 				req = req->dl_next;
 			}
+			st->offset = 0;
 			if (++st->sbucket >= icsk->icsk_accept_queue.listen_opt->nr_table_entries)
 				break;
 get_req:
@@ -2044,6 +2051,7 @@ start_req:
 		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 	}
 	spin_unlock_bh(&ilb->lock);
+	st->offset = 0;
 	if (++st->bucket < INET_LHTABLE_SIZE) {
 		ilb = &tcp_hashinfo.listening_hash[st->bucket];
 		spin_lock_bh(&ilb->lock);
@@ -2057,7 +2065,12 @@ out:
 
 static void *listening_get_idx(struct seq_file *seq, loff_t *pos)
 {
-	void *rc = listening_get_next(seq, NULL);
+	struct tcp_iter_state *st = seq->private;
+	void *rc;
+
+	st->bucket = 0;
+	st->offset = 0;
+	rc = listening_get_next(seq, NULL);
 
 	while (rc && *pos) {
 		rc = listening_get_next(seq, rc);
@@ -2072,13 +2085,18 @@ static inline int empty_bucket(struct tcp_iter_state *st)
 		hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
 }
 
+/*
+ * Get first established socket starting from bucket given in st->bucket.
+ * If st->bucket is zero, the very first socket in the hash is returned.
+ */
 static void *established_get_first(struct seq_file *seq)
 {
 	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 	void *rc = NULL;
 
-	for (st->bucket = 0; st->bucket <= tcp_hashinfo.ehash_mask; ++st->bucket) {
+	st->offset = 0;
+	for (; st->bucket <= tcp_hashinfo.ehash_mask; ++st->bucket) {
 		struct sock *sk;
 		struct hlist_nulls_node *node;
 		struct inet_timewait_sock *tw;
@@ -2123,6 +2141,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	struct net *net = seq_file_net(seq);
 
 	++st->num;
+	++st->offset;
 
 	if (st->state == TCP_SEQ_STATE_TIME_WAIT) {
 		tw = cur;
@@ -2139,6 +2158,7 @@ get_tw:
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
 		/* Look for next non empty bucket */
+		st->offset = 0;
 		while (++st->bucket <= tcp_hashinfo.ehash_mask &&
 				empty_bucket(st))
 			;
@@ -2166,7 +2186,11 @@ out:
 
 static void *established_get_idx(struct seq_file *seq, loff_t pos)
 {
-	void *rc = established_get_first(seq);
+	struct tcp_iter_state *st = seq->private;
+	void *rc;
+
+	st->bucket = 0;
+	rc = established_get_first(seq);
 
 	while (rc && pos) {
 		rc = established_get_next(seq, rc);
@@ -2191,24 +2215,72 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 	return rc;
 }
 
+static void *tcp_seek_last_pos(struct seq_file *seq)
+{
+	struct tcp_iter_state *st = seq->private;
+	int offset = st->offset;
+	int orig_num = st->num;
+	void *rc = NULL;
+	
+	switch (st->state) {
+	case TCP_SEQ_STATE_OPENREQ:
+	case TCP_SEQ_STATE_LISTENING:
+		if (st->bucket >= INET_LHTABLE_SIZE)
+			break;
+		st->state = TCP_SEQ_STATE_LISTENING;
+		rc = listening_get_next(seq, NULL);
+		while (offset-- && rc)
+			rc = listening_get_next(seq, rc);
+		if (rc)
+			break;
+		st->bucket = 0;
+		/* Fallthrough */
+	case TCP_SEQ_STATE_ESTABLISHED:
+	case TCP_SEQ_STATE_TIME_WAIT:
+		st->state = TCP_SEQ_STATE_ESTABLISHED;
+		if (st->bucket > tcp_hashinfo.ehash_mask)
+			break;
+		rc = established_get_first(seq);
+		while (offset-- && rc)
+			rc = established_get_next(seq, rc);
+	}
+
+	st->num = orig_num;
+
+	return rc;
+}
+
 static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct tcp_iter_state *st = seq->private;
+	void *rc;
+
+	if (*pos && *pos == st->last_pos) {
+		rc = tcp_seek_last_pos(seq);
+		if (rc)
+			goto out;
+	}
+
 	st->state = TCP_SEQ_STATE_LISTENING;
 	st->num = 0;
-	return *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+	st->bucket = 0;
+	st->offset = 0;
+	rc = *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+
+out:
+	st->last_pos = *pos;
+	return rc;
 }
 
 static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct tcp_iter_state *st = seq->private;
 	void *rc = NULL;
-	struct tcp_iter_state *st;
 
 	if (v == SEQ_START_TOKEN) {
 		rc = tcp_get_idx(seq, 0);
 		goto out;
 	}
-	st = seq->private;
 
 	switch (st->state) {
 	case TCP_SEQ_STATE_OPENREQ:
@@ -2216,6 +2288,8 @@ static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		rc = listening_get_next(seq, v);
 		if (!rc) {
 			st->state = TCP_SEQ_STATE_ESTABLISHED;
+			st->bucket = 0;
+			st->offset = 0;
 			rc	  = established_get_first(seq);
 		}
 		break;
@@ -2226,6 +2300,7 @@ static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 out:
 	++*pos;
+	st->last_pos = *pos;
 	return rc;
 }
 
@@ -2264,6 +2339,7 @@ static int tcp_seq_open(struct inode *inode, struct file *file)
 
 	s = ((struct seq_file *)file->private_data)->private;
 	s->family		= afinfo->family;
+	s->last_pos 		= 0;
 	return 0;
 }
 

