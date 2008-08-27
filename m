From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 00:34:10 +0200
Message-ID: <20080827223410.GC26610@one.firstfloor.org>
References: <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com> <20080826163719.GA25066@redhat.com> <87zlmyr5nz.fsf@basil.nowhere.org> <20080827.142941.50104491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40641 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbYH0Wbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:31:37 -0400
Content-Disposition: inline
In-Reply-To: <20080827.142941.50104491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 02:29:41PM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Wed, 27 Aug 2008 14:41:52 +0200
> 
> > Dave Jones <davej@redhat.com> writes:
> > 
> > > Just had this bug reported against our development tree..
> > 
> > SUSE had an old patch for this which unfortunately got rejected 
> > some time ago for some bogus reason.
> 
> Really, your patch fixes this specific slowdown that got introduced
> recently? 

Trick question? 

It fixes an old performance problem at least. I'm not aware 
of any new ones in this area because the code in this 
function hasn't changed since I last looked.

> I really doubt it Andi, so please don't use this as an
> opportunity to toot your own horn, thanks.

First I'm not posting patches to "toot my horn" (whatever
you mean with that), but to improve Linux. Please do not
insinuate anything else. Thank you.

Then the patch is still useful and makes sense IMHO. I just
checked and it applies to 2.6.27-rc4 and boots and seems
to still work from a quick check. I expect it would
resolve the problem of the Fedora bug reporter.

Please reconsider. The patch is a straight 
forward optimization of a function that does something
dumb. Doing hundred thousands of atomic operations
unnecessarily (in most cases the hash table 
is mostly empty) just doesn't make much sense.

And no "use rtnetlink" is also not the answer, because
rtnetlink does nothing to fix the extreme cost of the 
full hash table walk if you just want to see all connections.

I'm appending the patch again. Only difference
is that it is rediffed to 2.6.27-rc4 to avoid fuzz
and I redid the benchmark numbers (this time hopefully
without missing zeroes)

-Andi

---

Skip empty hash buckets faster in /proc/net/tcp

On most systems most of the TCP established/time-wait hash buckets are empty.
When walking the hash table for /proc/net/tcp their read locks would
always be aquired just to find out they're empty. This patch changes the code
to check first if the buckets have any entries before taking the lock, which
is much cheaper than taking a lock. Since the hash tables are large
this makes a measurable difference on processing /proc/net/tcp, 
especially on architectures with slow read_lock (e.g. PPC) 

On a 2GB Core2 system time cat /proc/net/tcp > /dev/null (with a mostly
empty hash table) goes from 0.046s to 0.005s.

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

Index: linux-2.6.27-rc4-misc/net/ipv4/tcp_ipv4.c
===================================================================
--- linux-2.6.27-rc4-misc.orig/net/ipv4/tcp_ipv4.c
+++ linux-2.6.27-rc4-misc/net/ipv4/tcp_ipv4.c
@@ -1946,6 +1946,12 @@ static void *listening_get_idx(struct se
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
@@ -1958,6 +1964,10 @@ static void *established_get_first(struc
 		struct inet_timewait_sock *tw;
 		rwlock_t *lock = inet_ehash_lockp(&tcp_hashinfo, st->bucket);
 
+		/* Lockless fast path for the common case of empty buckets */
+		if (empty_bucket(st))
+			continue;
+
 		read_lock_bh(lock);
 		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family ||
@@ -2008,13 +2018,15 @@ get_tw:
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
 
