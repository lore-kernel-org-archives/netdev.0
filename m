From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2] tcp: Fix a connect() race with timewait sockets
Date: Fri, 04 Dec 2009 14:47:42 +0100
Message-ID: <4B1912FE.9020600@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: kapil dakhane <kdakhane@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53488 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520AbZLDNrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 08:47:40 -0500
In-Reply-To: <4B152F97.1090409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we find a timewait connection in __inet_hash_connect() and reuse
it for a new connection request, we have a race window, releasing bind
list lock and reacquiring it in __inet_twsk_kill() to remove timewait
socket from list.

Another thread might find the timewait socket we already chose, leading to
list corruption and crashes.

Fix is to remove timewait socket from bind list before releasing the bind lock.

Note: This problem happens if sysctl_tcp_tw_reuse is set.

Reported-by: kapil dakhane <kdakhane@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_timewait_sock.h |    3 +++
 net/ipv4/inet_hashtables.c       |    2 ++
 net/ipv4/inet_timewait_sock.c    |   29 +++++++++++++++++++++--------
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index b801ade..79f67ea 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -201,6 +201,9 @@ extern void inet_twsk_put(struct inet_timewait_sock *tw);
 
 extern int inet_twsk_unhash(struct inet_timewait_sock *tw);
 
+extern int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
+				 struct inet_hashinfo *hashinfo);
+
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 						  const int state);
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index c4201b7..2b79377 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -502,6 +502,8 @@ ok:
 			inet_sk(sk)->inet_sport = htons(port);
 			twrefcnt += hash(sk, tw);
 		}
+		if (tw)
+			twrefcnt += inet_twsk_bind_unhash(tw, hinfo);
 		spin_unlock(&head->lock);
 
 		if (tw) {
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 0a1c62b..1958cf5 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -29,12 +29,29 @@ int inet_twsk_unhash(struct inet_timewait_sock *tw)
 	return 1;
 }
 
+/*
+ * unhash a timewait socket from bind hash
+ * lock must be hold by caller
+ */
+int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
+			  struct inet_hashinfo *hashinfo)
+{
+	struct inet_bind_bucket *tb = tw->tw_tb;
+
+	if (!tb)
+		return 0;
+
+	__hlist_del(&tw->tw_bind_node);
+	tw->tw_tb = NULL;
+	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
+	return 1;
+}
+
 /* Must be called with locally disabled BHs. */
 static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 			     struct inet_hashinfo *hashinfo)
 {
 	struct inet_bind_hashbucket *bhead;
-	struct inet_bind_bucket *tb;
 	int refcnt;
 	/* Unlink from established hashes. */
 	spinlock_t *lock = inet_ehash_lockp(hashinfo, tw->tw_hash);
@@ -46,15 +63,11 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 	/* Disassociate with bind bucket. */
 	bhead = &hashinfo->bhash[inet_bhashfn(twsk_net(tw), tw->tw_num,
 			hashinfo->bhash_size)];
+
 	spin_lock(&bhead->lock);
-	tb = tw->tw_tb;
-	if (tb) {
-		__hlist_del(&tw->tw_bind_node);
-		tw->tw_tb = NULL;
-		inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
-		refcnt++;
-	}
+	refcnt += inet_twsk_bind_unhash(tw, hashinfo);
 	spin_unlock(&bhead->lock);
+
 #ifdef SOCK_REFCNT_DEBUG
 	if (atomic_read(&tw->tw_refcnt) != 1) {
 		printk(KERN_DEBUG "%s timewait_sock %p refcnt=%d\n",
