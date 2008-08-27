From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 14:41:52 +0200
Message-ID: <87zlmyr5nz.fsf@basil.nowhere.org>
References: <bug-459782-176318@bugzilla.redhat.com>
	<200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com>
	<20080826163719.GA25066@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54206 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbYH0MmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 08:42:05 -0400
In-Reply-To: <20080826163719.GA25066@redhat.com> (Dave Jones's message of "Tue, 26 Aug 2008 12:37:19 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> writes:

> Just had this bug reported against our development tree..

SUSE had an old patch for this which unfortunately got rejected 
some time ago for some bogus reason.

The reason why it's so slow is because the hash table walk
takes a read lock for each bucket, which is just not fast.
On some architectures like POWER it is even slower than on x86.

The patch simply skipped that for empty buckets.

I append the old patch (haven't checked if it applies
to an recent kernel)

-Andi

Skip empty hash buckets faster in /proc/net/tcp

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
 
