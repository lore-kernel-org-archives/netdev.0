From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V3-evictor] net: frag evictor,
	avoid killing warm frag queues
Date: Tue, 04 Dec 2012 14:30:46 +0100
Message-ID: <20121204133007.20215.52566.stgit@dragon>
References: <1354319937.20109.285.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529Ab2LDNbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 08:31:23 -0500
In-Reply-To: <1354319937.20109.285.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fragmentation evictor system have a very unfortunate eviction
system for killing fragment, when the system is put under pressure.

If packets are coming in too fast, the evictor code kills "warm"
fragments too quickly.  Resulting in close to zero throughput, as
fragments are killed before they have a chance to complete

This is related to the bad interaction with the LRU (Least Recently
Used) list.  Under load the LRU list sort-of changes meaning/behavior.
When the LRU head is very new/warm, then the head is most likely the
one with most fragments and the tail (latest used or added element)
with least.

Solved by, introducing a creation "jiffie" timestamp (creation_ts).
If the element is tried evicted in same jiffie, then perform tail drop
on the LRU list instead.

Signed-off-by: Jesper Dangaard Brouer <jbrouer@redhat.com>

---
V2:
 - Drop the INET_FRAG_FIRST_IN idea for detecting dropped "head" packets

V3:
 - Move the tail drop, from inet_frag_alloc() to inet_frag_evictor()
   This will be close to the same semantics, but at a higher cost.


 include/net/inet_frag.h  |    1 +
 net/ipv4/inet_fragment.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 32786a0..7b897b2 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -24,6 +24,7 @@ struct inet_frag_queue {
 	ktime_t			stamp;
 	int			len;        /* total length of orig datagram */
 	int			meat;
+	u32			creation_ts;/* jiffies when queue was created*/
 	__u8			last_in;    /* first/last segment arrived? */
 
 #define INET_FRAG_COMPLETE	4
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 4750d2b..d8bf59b 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -178,6 +178,16 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 
 		q = list_first_entry(&nf->lru_list,
 				struct inet_frag_queue, lru_list);
+
+		/* When head of LRU is very new/warm, then the head is
+		 * most likely the one with most fragments and the
+		 * tail with least, thus drop tail
+		 */
+		if (!force && q->creation_ts == (u32) jiffies) {
+			q = list_entry(&nf->lru_list.prev,
+				struct inet_frag_queue, lru_list);
+		}
+
 		atomic_inc(&q->refcnt);
 		read_unlock(&f->lock);
 
@@ -243,11 +253,13 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 		struct inet_frags *f, void *arg)
 {
 	struct inet_frag_queue *q;
+	// Note: We could also perform the tail drop here
 
 	q = kzalloc(f->qsize, GFP_ATOMIC);
 	if (q == NULL)
 		return NULL;
 
+	q->creation_ts = (u32) jiffies;
 	q->net = nf;
 	f->constructor(q, arg);
 	atomic_add(f->qsize, &nf->mem);
