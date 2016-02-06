From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] tcp/dccp: better use of ephemeral ports in connect()
Date: Fri,  5 Feb 2016 18:08:57 -0800
Message-ID: <1454724538-13556-2-git-send-email-edumazet@google.com>
References: <1454724538-13556-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36485 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcBFCJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 21:09:07 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so42990868pab.3
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 18:09:06 -0800 (PST)
In-Reply-To: <1454724538-13556-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 07f4c90062f8 ("tcp/dccp: try to not exhaust ip_local_port_range
in connect()"), I added a very simple heuristic, so that we got better
chances to use even ports, and allow bind() users to have more available
slots.

It gave nice results, but with more than 200,000 TCP sessions on a typical
server, the ~30,000 ephemeral ports are still a rare resource.

I chose to go a step further, by looking at all even ports, and if none
was available, fallback to odd ports.

The companion patch does the same in bind(), but in opposite way.

I've seen exec times of up to 30ms on busy servers, so I no longer
disable BH for the whole traversal, but only for each hash bucket.
I also call cond_resched() to be gentle to other tasks.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_hashtables.c | 170 ++++++++++++++++++++++-----------------------
 1 file changed, 85 insertions(+), 85 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ccc5980797fc..8a5dda9b1ce7 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -506,106 +506,106 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			struct sock *, __u16, struct inet_timewait_sock **))
 {
 	struct inet_hashinfo *hinfo = death_row->hashinfo;
-	const unsigned short snum = inet_sk(sk)->inet_num;
+	struct inet_timewait_sock *tw = NULL;
 	struct inet_bind_hashbucket *head;
-	struct inet_bind_bucket *tb;
-	int ret;
+	int port = inet_sk(sk)->inet_num;
 	struct net *net = sock_net(sk);
+	struct inet_bind_bucket *tb;
+	u32 remaining, offset;
+	int ret, i, low, high;
+	static u32 hint;
+
+	if (port) {
+		head = &hinfo->bhash[inet_bhashfn(net, port,
+						  hinfo->bhash_size)];
+		tb = inet_csk(sk)->icsk_bind_hash;
+		spin_lock_bh(&head->lock);
+		if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
+			inet_ehash_nolisten(sk, NULL);
+			spin_unlock_bh(&head->lock);
+			return 0;
+		}
+		spin_unlock(&head->lock);
+		/* No definite answer... Walk to established hash table */
+		ret = check_established(death_row, sk, port, NULL);
+		local_bh_enable();
+		return ret;
+	}
 
-	if (!snum) {
-		int i, remaining, low, high, port;
-		static u32 hint;
-		u32 offset = hint + port_offset;
-		struct inet_timewait_sock *tw = NULL;
+	inet_get_local_port_range(net, &low, &high);
+	high++; /* [32768, 60999] -> [32768, 61000[ */
+	remaining = high - low;
+	if (likely(remaining > 1))
+		remaining &= ~1U;
 
-		inet_get_local_port_range(net, &low, &high);
-		remaining = (high - low) + 1;
+	offset = (hint + port_offset) % remaining;
+	/* In first pass we try ports of @low parity.
+	 * inet_csk_get_port() does the opposite choice.
+	 */
+	offset &= ~1U;
+other_parity_scan:
+	port = low + offset;
+	for (i = 0; i < remaining; i += 2, port += 2) {
+		if (unlikely(port >= high))
+			port -= remaining;
+		if (inet_is_local_reserved_port(net, port))
+			continue;
+		head = &hinfo->bhash[inet_bhashfn(net, port,
+						  hinfo->bhash_size)];
+		spin_lock_bh(&head->lock);
 
-		/* By starting with offset being an even number,
-		 * we tend to leave about 50% of ports for other uses,
-		 * like bind(0).
+		/* Does not bother with rcv_saddr checks, because
+		 * the established check is already unique enough.
 		 */
-		offset &= ~1;
-
-		local_bh_disable();
-		for (i = 0; i < remaining; i++) {
-			port = low + (i + offset) % remaining;
-			if (inet_is_local_reserved_port(net, port))
-				continue;
-			head = &hinfo->bhash[inet_bhashfn(net, port,
-					hinfo->bhash_size)];
-			spin_lock(&head->lock);
-
-			/* Does not bother with rcv_saddr checks,
-			 * because the established check is already
-			 * unique enough.
-			 */
-			inet_bind_bucket_for_each(tb, &head->chain) {
-				if (net_eq(ib_net(tb), net) &&
-				    tb->port == port) {
-					if (tb->fastreuse >= 0 ||
-					    tb->fastreuseport >= 0)
-						goto next_port;
-					WARN_ON(hlist_empty(&tb->owners));
-					if (!check_established(death_row, sk,
-								port, &tw))
-						goto ok;
+		inet_bind_bucket_for_each(tb, &head->chain) {
+			if (net_eq(ib_net(tb), net) && tb->port == port) {
+				if (tb->fastreuse >= 0 ||
+				    tb->fastreuseport >= 0)
 					goto next_port;
-				}
+				WARN_ON(hlist_empty(&tb->owners));
+				if (!check_established(death_row, sk,
+						       port, &tw))
+					goto ok;
+				goto next_port;
 			}
-
-			tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
-					net, head, port);
-			if (!tb) {
-				spin_unlock(&head->lock);
-				break;
-			}
-			tb->fastreuse = -1;
-			tb->fastreuseport = -1;
-			goto ok;
-
-		next_port:
-			spin_unlock(&head->lock);
 		}
-		local_bh_enable();
-
-		return -EADDRNOTAVAIL;
 
-ok:
-		hint += (i + 2) & ~1;
-
-		/* Head lock still held and bh's disabled */
-		inet_bind_hash(sk, tb, port);
-		if (sk_unhashed(sk)) {
-			inet_sk(sk)->inet_sport = htons(port);
-			inet_ehash_nolisten(sk, (struct sock *)tw);
+		tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
+					     net, head, port);
+		if (!tb) {
+			spin_unlock_bh(&head->lock);
+			return -ENOMEM;
 		}
-		if (tw)
-			inet_twsk_bind_unhash(tw, hinfo);
-		spin_unlock(&head->lock);
+		tb->fastreuse = -1;
+		tb->fastreuseport = -1;
+		goto ok;
+next_port:
+		spin_unlock_bh(&head->lock);
+		cond_resched();
+	}
 
-		if (tw)
-			inet_twsk_deschedule_put(tw);
+	offset++;
+	if ((offset & 1) && remaining > 1)
+		goto other_parity_scan;
 
-		ret = 0;
-		goto out;
-	}
+	return -EADDRNOTAVAIL;
 
-	head = &hinfo->bhash[inet_bhashfn(net, snum, hinfo->bhash_size)];
-	tb  = inet_csk(sk)->icsk_bind_hash;
-	spin_lock_bh(&head->lock);
-	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
-		inet_ehash_nolisten(sk, NULL);
-		spin_unlock_bh(&head->lock);
-		return 0;
-	} else {
-		spin_unlock(&head->lock);
-		/* No definite answer... Walk to established hash table */
-		ret = check_established(death_row, sk, snum, NULL);
-out:
-		local_bh_enable();
-		return ret;
+ok:
+	hint += i + 2;
+
+	/* Head lock still held and bh's disabled */
+	inet_bind_hash(sk, tb, port);
+	if (sk_unhashed(sk)) {
+		inet_sk(sk)->inet_sport = htons(port);
+		inet_ehash_nolisten(sk, (struct sock *)tw);
 	}
+	if (tw)
+		inet_twsk_bind_unhash(tw, hinfo);
+	spin_unlock(&head->lock);
+	if (tw)
+		inet_twsk_deschedule_put(tw);
+	local_bh_enable();
+	return 0;
 }
 
 /*
-- 
2.7.0.rc3.207.g0ac5344
