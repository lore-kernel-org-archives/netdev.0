From: Yakov Lerner <iler.ml@gmail.com>
Subject: [PATCH] /proc/net/tcp, overhead removed
Date: Tue, 29 Sep 2009 01:01:46 +0200
Message-ID: <1254178906-5293-1-git-send-email-iler.ml@gmail.com>
Cc: Yakov Lerner <iler.ml@gmail.com>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:45927 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbZI1XCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 19:02:06 -0400
Received: by ewy7 with SMTP id 7so4915632ewy.17
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 16:02:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take 2. 

"Sharp improvement in performance of /proc/net/tcp when number of 
sockets is large and hashsize is large. 
O(numsock * hashsize) time becomes O(numsock + hashsize). On slow
processors, speed difference can be x100 and more."

I must say that I'm not fully satisfied with my choice of "st->sbucket" 
for the new preserved index. The better name would be "st->snum". 
Re-using "st->sbucket" saves 4 bytes, and keeps the patch to one sourcefile.
But "st->sbucket" has different meaning in OPENREQ and LISTEN states;
this can be confusing. 
Maybe better add "snum" member to struct tcp_iter_state ?

Shall I change subject when sending "take N+1", or keep the old subject ?

Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
---
 net/ipv4/tcp_ipv4.c |   35 +++++++++++++++++++++++++++++++++--
 1 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..e4c4f19 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1994,13 +1994,14 @@ static inline int empty_bucket(struct tcp_iter_state *st)
 		hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
 }
 
-static void *established_get_first(struct seq_file *seq)
+static void *established_get_first_after(struct seq_file *seq, int bucket)
 {
 	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 	void *rc = NULL;
 
-	for (st->bucket = 0; st->bucket < tcp_hashinfo.ehash_size; ++st->bucket) {
+	for (st->bucket = bucket; st->bucket < tcp_hashinfo.ehash_size;
+	     ++st->bucket) {
 		struct sock *sk;
 		struct hlist_nulls_node *node;
 		struct inet_timewait_sock *tw;
@@ -2010,6 +2011,8 @@ static void *established_get_first(struct seq_file *seq)
 		if (empty_bucket(st))
 			continue;
 
+		st->sbucket = st->num;
+
 		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family ||
@@ -2036,6 +2039,11 @@ out:
 	return rc;
 }
 
+static void *established_get_first(struct seq_file *seq)
+{
+	return established_get_first_after(seq, 0);
+}
+
 static void *established_get_next(struct seq_file *seq, void *cur)
 {
 	struct sock *sk = cur;
@@ -2064,6 +2072,9 @@ get_tw:
 		while (++st->bucket < tcp_hashinfo.ehash_size &&
 				empty_bucket(st))
 			;
+
+		st->sbucket = st->num;
+
 		if (st->bucket >= tcp_hashinfo.ehash_size)
 			return NULL;
 
@@ -2107,6 +2118,7 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 
 	if (!rc) {
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
+		st->sbucket = 0;
 		rc	  = established_get_idx(seq, pos);
 	}
 
@@ -2116,6 +2128,25 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct tcp_iter_state *st = seq->private;
+
+	if (*pos && *pos >= st->sbucket &&
+	    (st->state == TCP_SEQ_STATE_ESTABLISHED ||
+	     st->state == TCP_SEQ_STATE_TIME_WAIT)) {
+		void *cur;
+		int nskip;
+
+		/* for states estab and tw, st->sbucket is index (*pos) */
+		/* corresponding to the beginning of bucket st->bucket */
+
+		st->num = st->sbucket;
+		/* jump to st->bucket, then skip (*pos - st->sbucket) items */
+		st->state = TCP_SEQ_STATE_ESTABLISHED;
+		cur = established_get_first_after(seq, st->bucket);
+		for (nskip = *pos - st->num; cur && nskip > 0; --nskip)
+			cur = established_get_next(seq, cur);
+		return cur;
+	}
+
 	st->state = TCP_SEQ_STATE_LISTENING;
 	st->num = 0;
 	return *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
-- 
1.6.5.rc2

