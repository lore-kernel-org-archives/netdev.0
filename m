From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling
 to mitigate SYN floods
Date: Thu, 31 May 2012 19:16:07 +0200
Message-ID: <1338484567.2760.1372.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <201205311045.03556.hans.schillstrom@ericsson.com>
	 <1338473361.2760.1361.camel@edumazet-glaptop>
	 <201205311731.57159.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Tom Herbert <therbert@google.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58982 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521Ab2EaRQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 13:16:13 -0400
Received: by bkcji2 with SMTP id ji2so1074100bkc.19
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 10:16:12 -0700 (PDT)
In-Reply-To: <201205311731.57159.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-31 at 17:31 +0200, Hans Schillstrom wrote:
> On Thursday 31 May 2012 16:09:21 Eric Dumazet wrote:
> > On Thu, 2012-05-31 at 10:45 +0200, Hans Schillstrom wrote:
> > 
> > > I can see plenty "IPv4: dst cache overflow"
> > > 
> > 
> > This is probably the most problematic problem in DDOS attacks.
> > 
> > I have a patch for this problem.
> > 
> > Idea is to not cache dst entries for following cases :
> > 
> > 1) Input dst, if listener queue is full (syncookies possibly engaged)
> > 
> > 2) Output dst of SYNACK messages.
> > 
> Sound like a good idea, 
> if you need some testing just the patches 
> 

Here is the patch, works pretty well for me

 include/net/dst.h   |    1 +
 net/ipv4/route.c    |   20 +++++++++++++++-----
 net/ipv4/tcp_ipv4.c |    6 ++++++
 3 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index bed833d..e0109c4 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -60,6 +60,7 @@ struct dst_entry {
 #define DST_NOCOUNT		0x0020
 #define DST_NOPEER		0x0040
 #define DST_FAKE_RTABLE		0x0080
+#define DST_EPHEMERAL		0x0100
 
 	short			error;
 	short			obsolete;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 98b30d0..51b3e78 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -754,6 +754,15 @@ static inline int rt_is_expired(struct rtable *rth)
 	return rth->rt_genid != rt_genid(dev_net(rth->dst.dev));
 }
 
+static bool rt_is_expired_or_ephemeral(struct rtable *rth)
+{
+	if (rt_is_expired(rth))
+		return true;
+
+	return (atomic_read(&rth->dst.__refcnt) == 0) && 
+	       (rth->dst.flags & DST_EPHEMERAL);
+}
+
 /*
  * Perform a full scan of hash table and free all entries.
  * Can be called by a softirq or a process.
@@ -873,7 +882,7 @@ static void rt_check_expire(void)
 		while ((rth = rcu_dereference_protected(*rthp,
 					lockdep_is_held(rt_hash_lock_addr(i)))) != NULL) {
 			prefetch(rth->dst.rt_next);
-			if (rt_is_expired(rth)) {
+			if (rt_is_expired_or_ephemeral(rth)) {
 				*rthp = rth->dst.rt_next;
 				rt_free(rth);
 				continue;
@@ -1040,7 +1049,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
 			spin_lock_bh(rt_hash_lock_addr(k));
 			while ((rth = rcu_dereference_protected(*rthp,
 					lockdep_is_held(rt_hash_lock_addr(k)))) != NULL) {
-				if (!rt_is_expired(rth) &&
+				if (!rt_is_expired_or_ephemeral(rth) &&
 					!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
 					rthp = &rth->dst.rt_next;
@@ -1159,7 +1168,8 @@ restart:
 	candp = NULL;
 	now = jiffies;
 
-	if (!rt_caching(dev_net(rt->dst.dev))) {
+	if (!rt_caching(dev_net(rt->dst.dev)) ||
+	    dst_entries_get_fast(&ipv4_dst_ops) > (ip_rt_max_size >> 1)) {
 		/*
 		 * If we're not caching, just tell the caller we
 		 * were successful and don't touch the route.  The
@@ -1194,7 +1204,7 @@ restart:
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = rcu_dereference_protected(*rthp,
 			lockdep_is_held(rt_hash_lock_addr(hash)))) != NULL) {
-		if (rt_is_expired(rth)) {
+		if (rt_is_expired_or_ephemeral(rth)) {
 			*rthp = rth->dst.rt_next;
 			rt_free(rth);
 			continue;
@@ -1390,7 +1400,7 @@ static void rt_del(unsigned int hash, struct rtable *rt)
 	ip_rt_put(rt);
 	while ((aux = rcu_dereference_protected(*rthp,
 			lockdep_is_held(rt_hash_lock_addr(hash)))) != NULL) {
-		if (aux == rt || rt_is_expired(aux)) {
+		if (aux == rt || rt_is_expired_or_ephemeral(aux)) {
 			*rthp = aux->dst.rt_next;
 			rt_free(aux);
 			continue;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a43b87d..30c5275 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -835,6 +835,9 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		return -1;
 
+	if (atomic_read(&dst->__refcnt) == 1)
+		dst->flags |= DST_EPHEMERAL;
+
 	skb = tcp_make_synack(sk, dst, req, rvp);
 
 	if (skb) {
@@ -1291,6 +1294,9 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * evidently real one.
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
+		/* under attack, free dst as soon as possible */
+		skb_dst(skb)->flags |= DST_EPHEMERAL;
+
 		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
 		if (!want_cookie)
 			goto drop;
