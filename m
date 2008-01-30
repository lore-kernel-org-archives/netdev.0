From: Andi Kleen <ak@suse.de>
Subject: [PATCH] [1/2] Skip empty hash buckets faster in /proc/net/tcp
Date: Wed, 30 Jan 2008 09:01:09 +0100 (CET)
Message-ID: <20080130901.138686634@suse.de>
To: meissner@suse.de, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:51104 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753771AbYA3IRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:17:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On most systems most of the TCP established/time-wait hash buckets are empty.
When walking the hash table for /proc/net/tcp their read locks would
always be aquired just to find out they're empty. This patch changes the code
to check first if the buckets have any entries before taking the lock, which
is much cheaper than taking a lock. Since the hash tables are large
this makes a measurable difference on processing /proc/net/tcp, 
especially on architectures with slow read_lock (e.g. PPC) 

On a 2GB Core2 system here I see a time cat /proc/net/tcp > /dev/null
constently dropping from 0.44s to 0.4-0.8s system time with this change.
This is with mostly empty hash tables.

On systems with slower atomics (like P4 or POWER4) or larger hash tables
(more RAM) the difference is much higher.

This can be noticeable because there are some daemons around who regularly
scan /proc/net/tcp.

Original idea for this patch from Marcus Meissner, but redone by me.

Cc: meissner@suse.de
Signed-off-by: Andi Kleen <ak@suse.de>

---
 net/ipv4/tcp_ipv4.c |   30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

Index: linux/net/ipv4/tcp_ipv4.c
===================================================================
--- linux.orig/net/ipv4/tcp_ipv4.c
+++ linux/net/ipv4/tcp_ipv4.c
@@ -2039,6 +2039,12 @@ static void *listening_get_idx(struct se
 	return rc;
 }
 
+static inline int empty_bucket(struct tcp_iter_state *st)
+{
+	return hlist_empty(&tcp_hashinfo.ehash[st->bucket].chain) &&
+		hlist_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
+}
+
 static void *established_get_first(struct seq_file *seq)
 {
 	struct tcp_iter_state* st = seq->private;
@@ -2050,6 +2056,10 @@ static void *established_get_first(struc
 		struct inet_timewait_sock *tw;
 		rwlock_t *lock = inet_ehash_lockp(&tcp_hashinfo, st->bucket);
 
+		/* Lockless fast path for the common case of empty buckets */
+		if (empty_bucket(st))
+			continue;
+
 		read_lock_bh(lock);
 		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family) {
@@ -2097,13 +2107,15 @@ get_tw:
 		read_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
-		if (++st->bucket < tcp_hashinfo.ehash_size) {
-			read_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
-			sk = sk_head(&tcp_hashinfo.ehash[st->bucket].chain);
-		} else {
-			cur = NULL;
-			goto out;
-		}
+		/* Look for next non empty bucket */
+		while (++st->bucket < tcp_hashinfo.ehash_size &&
+				empty_bucket(st))
+			;
+		if (st->bucket >= tcp_hashinfo.ehash_size)
+			return NULL;
+
+		read_lock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
+		sk = sk_head(&tcp_hashinfo.ehash[st->bucket].chain);
 	} else
 		sk = sk_next(sk);
 
