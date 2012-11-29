From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 1/9] net: frag evictor,
	avoid killing warm frag queues
Date: Thu, 29 Nov 2012 17:11:09 +0100
Message-ID: <20121129161052.17754.85017.stgit@dragon>
References: <20121129161019.17754.29670.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754677Ab2K2QMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:12:45 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fragmentation evictor system have a very unfortunate eviction
system for killing fragment, when the system is put under pressure.
If packets are coming in too fast, the evictor code kills "warm"
fragments too quickly.  Resulting in a massive performance drop,
because we drop frag lists where we have already queue up a lot of
fragments/work, which gets killed before they have a chance to
complete.

This is perhaps amplified by the CPUs fighting for the same lru_list
element q in inet_frag_evictor(), and the atomic_dec_and_test(&q->refcnt)
which will cause another trip round the loop.

The solution idea (orig conceived by Florian Westphal) is to avoid
killing "warm" fragments, and rather block new incoming in case mem
limit is exceeded. This is solved by introducing a creation time-stamp
(creation_ts) in inet_frag_queue, which set to "jiffies" in
inet_frag_alloc().

In inet_frag_evictor() we don't kill "warm" queue elements. A "warm"
queue element is an element reaching inet_frag_evictor() within the
same "jiffie".

To maintain the queue limit (/proc/sys/net/ipv4/ipfrag_high_thresh) we
don't allow, new frag queue's to be allocated in inet_frag_alloc().
This will result in kernel log messages, which have been adjusted to
"ip_frag_create: mem limit reached".  We should consider dropping this
text, to avoid confusing end-users.

Notice, this is not the complete solution to fixing fragmentation
performance, but it allow us to see what is going on.

Original-idea-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Jesper Dangaard Brouer <jbrouer@redhat.com>

---
V2:
 - Drop the INET_FRAG_FIRST_IN idea for detecting dropped "head" packets

 include/net/inet_frag.h  |    1 +
 net/ipv4/inet_fragment.c |   19 +++++++++++++++++++
 net/ipv4/ip_fragment.c   |    6 +++---
 3 files changed, 23 insertions(+), 3 deletions(-)

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
index 4750d2b..9bb6237 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -178,6 +178,18 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 
 		q = list_first_entry(&nf->lru_list,
 				struct inet_frag_queue, lru_list);
+
+		/* queue entry is warm, i.e. new frags are arriving
+		 * too fast.  instead of evicting warm entry, give it
+		 * a chance to complete.  Instead, inet_frag_alloc()
+		 * will fail until more time has elapsed or queue
+		 * completes.
+		 */
+		if (!force && q->creation_ts == (u32) jiffies) {
+			read_unlock(&f->lock);
+			break;
+		}
+
 		atomic_inc(&q->refcnt);
 		read_unlock(&f->lock);
 
@@ -244,10 +256,17 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 {
 	struct inet_frag_queue *q;
 
+	/* Guard creations of new frag queues if mem limit reached, as
+	 * we allow warm/recent elements to survive in inet_frag_evictor()
+	 */
+	if (atomic_read(&nf->mem) > nf->high_thresh)
+		return NULL;
+
 	q = kzalloc(f->qsize, GFP_ATOMIC);
 	if (q == NULL)
 		return NULL;
 
+	q->creation_ts = (u32) jiffies;
 	q->net = nf;
 	f->constructor(q, arg);
 	atomic_add(f->qsize, &nf->mem);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1cf6a76..ef00d0a 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -300,12 +300,12 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
 	if (q == NULL)
-		goto out_nomem;
+		goto out_memlimit;
 
 	return container_of(q, struct ipq, q);
 
-out_nomem:
-	LIMIT_NETDEBUG(KERN_ERR pr_fmt("ip_frag_create: no memory left !\n"));
+out_memlimit:
+	LIMIT_NETDEBUG(KERN_ERR pr_fmt("ip_frag_create: mem limit reached!\n"));
 	return NULL;
 }
 
