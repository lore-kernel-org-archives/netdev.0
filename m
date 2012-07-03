From: David Miller <davem@davemloft.net>
Subject: [PATCH 04/19] net: Do delayed neigh confirmation.
Date: Tue, 03 Jul 2012 02:46:07 -0700 (PDT)
Message-ID: <20120703.024607.2073646438343524000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250Ab2GCJqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:11 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 504E058411C
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When a dst_confirm() happens, mark the confirmation as pending in the
dst.  Then on the next packet out, when we have the neigh in-hand, do
the update.

This removes the dependency in dst_confirm() of dst's having an
attached neigh.

While we're here, remove the explicit 'dst' NULL check, all except 2
or 3 call sites ensure it's not NULL.  So just fix those cases up.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h       |   29 +++++++++++++++++++++--------
 include/net/neighbour.h |   15 ---------------
 net/core/dst.c          |    3 ++-
 net/ipv4/ip_output.c    |    2 +-
 net/ipv4/tcp_input.c    |   19 +++++++++++++------
 net/ipv6/ip6_output.c   |    2 +-
 6 files changed, 38 insertions(+), 32 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index f0bf3b8..84e7a3f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -51,7 +51,7 @@ struct dst_entry {
 	int			(*input)(struct sk_buff *);
 	int			(*output)(struct sk_buff *);
 
-	int			flags;
+	unsigned short		flags;
 #define DST_HOST		0x0001
 #define DST_NOXFRM		0x0002
 #define DST_NOPOLICY		0x0004
@@ -62,6 +62,8 @@ struct dst_entry {
 #define DST_FAKE_RTABLE		0x0080
 #define DST_XFRM_TUNNEL		0x0100
 
+	unsigned short		pending_confirm;
+
 	short			error;
 	short			obsolete;
 	unsigned short		header_len;	/* more space at head required */
@@ -371,7 +373,8 @@ static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 
 extern int dst_discard(struct sk_buff *skb);
 extern void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
-		       int initial_ref, int initial_obsolete, int flags);
+		       int initial_ref, int initial_obsolete,
+		       unsigned short flags);
 extern void __dst_free(struct dst_entry *dst);
 extern struct dst_entry *dst_destroy(struct dst_entry *dst);
 
@@ -395,14 +398,24 @@ static inline void dst_rcu_free(struct rcu_head *head)
 
 static inline void dst_confirm(struct dst_entry *dst)
 {
-	if (dst) {
-		struct neighbour *n;
+	dst->pending_confirm = 1;
+}
 
-		rcu_read_lock();
-		n = dst_get_neighbour_noref(dst);
-		neigh_confirm(n);
-		rcu_read_unlock();
+static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
+				   struct sk_buff *skb)
+{
+	struct hh_cache *hh;
+
+	if (unlikely(dst->pending_confirm)) {
+		n->confirmed = jiffies;
+		dst->pending_confirm = 0;
 	}
+
+	hh = &n->hh;
+	if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
+		return neigh_hh_output(hh, skb);
+	else
+		return n->output(n, skb);
 }
 
 static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index e1d18bd..344d898 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -309,12 +309,6 @@ static inline struct neighbour * neigh_clone(struct neighbour *neigh)
 
 #define neigh_hold(n)	atomic_inc(&(n)->refcnt)
 
-static inline void neigh_confirm(struct neighbour *neigh)
-{
-	if (neigh)
-		neigh->confirmed = jiffies;
-}
-
 static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
 	unsigned long now = jiffies;
@@ -358,15 +352,6 @@ static inline int neigh_hh_output(struct hh_cache *hh, struct sk_buff *skb)
 	return dev_queue_xmit(skb);
 }
 
-static inline int neigh_output(struct neighbour *n, struct sk_buff *skb)
-{
-	struct hh_cache *hh = &n->hh;
-	if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
-		return neigh_hh_output(hh, skb);
-	else
-		return n->output(n, skb);
-}
-
 static inline struct neighbour *
 __neigh_lookup(struct neigh_table *tbl, const void *pkey, struct net_device *dev, int creat)
 {
diff --git a/net/core/dst.c b/net/core/dst.c
index 43d94ce..a6e19a2 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -152,7 +152,7 @@ EXPORT_SYMBOL(dst_discard);
 const u32 dst_default_metrics[RTAX_MAX];
 
 void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
-		int initial_ref, int initial_obsolete, int flags)
+		int initial_ref, int initial_obsolete, unsigned short flags)
 {
 	struct dst_entry *dst;
 
@@ -188,6 +188,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->__use = 0;
 	dst->lastuse = jiffies;
 	dst->flags = flags;
+	dst->pending_confirm = 0;
 	dst->next = NULL;
 	if (!(flags & DST_NOCOUNT))
 		dst_entries_add(ops, 1);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6e9a266..cc52679 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -198,7 +198,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
 	if (neigh) {
-		int res = neigh_output(neigh, skb);
+		int res = dst_neigh_output(dst, neigh, skb);
 
 		rcu_read_unlock_bh();
 		return res;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8416f8a..ca0d0e7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -740,13 +740,13 @@ void tcp_update_metrics(struct sock *sk)
 	if (sysctl_tcp_nometrics_save)
 		return;
 
-	dst_confirm(dst);
-
 	if (dst && (dst->flags & DST_HOST)) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		int m;
 		unsigned long rtt;
 
+		dst_confirm(dst);
+
 		if (icsk->icsk_backoff || !tp->srtt) {
 			/* This session failed to estimate rtt. Why?
 			 * Probably, no packets returned in time.
@@ -3869,9 +3869,11 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
 	}
 
-	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
-		dst_confirm(__sk_dst_get(sk));
-
+	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
+		struct dst_entry *dst = __sk_dst_get(sk);
+		if (dst)
+			dst_confirm(dst);
+	}
 	return 1;
 
 no_queue:
@@ -6140,9 +6142,14 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 		case TCP_FIN_WAIT1:
 			if (tp->snd_una == tp->write_seq) {
+				struct dst_entry *dst;
+
 				tcp_set_state(sk, TCP_FIN_WAIT2);
 				sk->sk_shutdown |= SEND_SHUTDOWN;
-				dst_confirm(__sk_dst_get(sk));
+
+				dst = __sk_dst_get(sk);
+				if (dst)
+					dst_confirm(dst);
 
 				if (!sock_flag(sk, SOCK_DEAD))
 					/* Wake up lingering close() */
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a233a7c..c94e4aa 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -125,7 +125,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	rcu_read_lock();
 	neigh = dst_get_neighbour_noref(dst);
 	if (neigh) {
-		int res = neigh_output(neigh, skb);
+		int res = dst_neigh_output(dst, neigh, skb);
 
 		rcu_read_unlock();
 		return res;
-- 
1.7.10
