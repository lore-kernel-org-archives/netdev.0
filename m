From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net 2/4] inet: frag: change *_frag_mem_limit functions to take netns_frags as argument
Date: Thu, 23 Jul 2015 12:05:38 +0200
Message-ID: <1437645940-7895-3-git-send-email-fw@strlen.de>
References: <1437645940-7895-1-git-send-email-fw@strlen.de>
Cc: Johan Schuijt <johan@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41979 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753276AbbGWKjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 06:39:45 -0400
In-Reply-To: <1437645940-7895-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Followup patch will call it after inet_frag_queue was freed, so q->net
doesn't work anymore (but netf = q->net; free(q); mem_limit(netf) would).

Tested-by: Frank Schreuder <fschreuder@transip.nl>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h                 |  8 ++++----
 net/ieee802154/6lowpan/reassembly.c     |  6 +++---
 net/ipv4/inet_fragment.c                |  4 ++--
 net/ipv4/ip_fragment.c                  | 10 +++++-----
 net/ipv6/netfilter/nf_conntrack_reasm.c |  6 +++---
 net/ipv6/reassembly.c                   |  6 +++---
 6 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 56a3a56..e71ca17 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -141,14 +141,14 @@ static inline int frag_mem_limit(struct netns_frags *nf)
 	return percpu_counter_read(&nf->mem);
 }
 
-static inline void sub_frag_mem_limit(struct inet_frag_queue *q, int i)
+static inline void sub_frag_mem_limit(struct netns_frags *nf, int i)
 {
-	__percpu_counter_add(&q->net->mem, -i, frag_percpu_counter_batch);
+	__percpu_counter_add(&nf->mem, -i, frag_percpu_counter_batch);
 }
 
-static inline void add_frag_mem_limit(struct inet_frag_queue *q, int i)
+static inline void add_frag_mem_limit(struct netns_frags *nf, int i)
 {
-	__percpu_counter_add(&q->net->mem, i, frag_percpu_counter_batch);
+	__percpu_counter_add(&nf->mem, i, frag_percpu_counter_batch);
 }
 
 static inline void init_frag_mem_limit(struct netns_frags *nf)
diff --git a/net/ieee802154/6lowpan/reassembly.c b/net/ieee802154/6lowpan/reassembly.c
index f46e4d1..214d44a 100644
--- a/net/ieee802154/6lowpan/reassembly.c
+++ b/net/ieee802154/6lowpan/reassembly.c
@@ -207,7 +207,7 @@ found:
 	} else {
 		fq->q.meat += skb->len;
 	}
-	add_frag_mem_limit(&fq->q, skb->truesize);
+	add_frag_mem_limit(fq->q.net, skb->truesize);
 
 	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
@@ -287,7 +287,7 @@ static int lowpan_frag_reasm(struct lowpan_frag_queue *fq, struct sk_buff *prev,
 		clone->data_len = clone->len;
 		head->data_len -= clone->len;
 		head->len -= clone->len;
-		add_frag_mem_limit(&fq->q, clone->truesize);
+		add_frag_mem_limit(fq->q.net, clone->truesize);
 	}
 
 	WARN_ON(head == NULL);
@@ -310,7 +310,7 @@ static int lowpan_frag_reasm(struct lowpan_frag_queue *fq, struct sk_buff *prev,
 		}
 		fp = next;
 	}
-	sub_frag_mem_limit(&fq->q, sum_truesize);
+	sub_frag_mem_limit(fq->q.net, sum_truesize);
 
 	head->next = NULL;
 	head->dev = dev;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 1722348..4473232 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -328,7 +328,7 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 		fp = xp;
 	}
 	sum = sum_truesize + f->qsize;
-	sub_frag_mem_limit(q, sum);
+	sub_frag_mem_limit(q->net, sum);
 
 	if (f->destructor)
 		f->destructor(q);
@@ -388,7 +388,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 
 	q->net = nf;
 	f->constructor(q, arg);
-	add_frag_mem_limit(q, f->qsize);
+	add_frag_mem_limit(nf, f->qsize);
 
 	setup_timer(&q->timer, f->frag_expire, (unsigned long)q);
 	spin_lock_init(&q->lock);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 31f71b1..b4a77d02 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -309,7 +309,7 @@ static int ip_frag_reinit(struct ipq *qp)
 		kfree_skb(fp);
 		fp = xp;
 	} while (fp);
-	sub_frag_mem_limit(&qp->q, sum_truesize);
+	sub_frag_mem_limit(qp->q.net, sum_truesize);
 
 	qp->q.flags = 0;
 	qp->q.len = 0;
@@ -455,7 +455,7 @@ found:
 				qp->q.fragments = next;
 
 			qp->q.meat -= free_it->len;
-			sub_frag_mem_limit(&qp->q, free_it->truesize);
+			sub_frag_mem_limit(qp->q.net, free_it->truesize);
 			kfree_skb(free_it);
 		}
 	}
@@ -479,7 +479,7 @@ found:
 	qp->q.stamp = skb->tstamp;
 	qp->q.meat += skb->len;
 	qp->ecn |= ecn;
-	add_frag_mem_limit(&qp->q, skb->truesize);
+	add_frag_mem_limit(qp->q.net, skb->truesize);
 	if (offset == 0)
 		qp->q.flags |= INET_FRAG_FIRST_IN;
 
@@ -587,7 +587,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		head->len -= clone->len;
 		clone->csum = 0;
 		clone->ip_summed = head->ip_summed;
-		add_frag_mem_limit(&qp->q, clone->truesize);
+		add_frag_mem_limit(qp->q.net, clone->truesize);
 	}
 
 	skb_push(head, head->data - skb_network_header(head));
@@ -615,7 +615,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		}
 		fp = next;
 	}
-	sub_frag_mem_limit(&qp->q, sum_truesize);
+	sub_frag_mem_limit(qp->q.net, sum_truesize);
 
 	head->next = NULL;
 	head->dev = dev;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6f187c8..6d02498 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -348,7 +348,7 @@ found:
 	fq->ecn |= ecn;
 	if (payload_len > fq->q.max_size)
 		fq->q.max_size = payload_len;
-	add_frag_mem_limit(&fq->q, skb->truesize);
+	add_frag_mem_limit(fq->q.net, skb->truesize);
 
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
@@ -430,7 +430,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 		clone->ip_summed = head->ip_summed;
 
 		NFCT_FRAG6_CB(clone)->orig = NULL;
-		add_frag_mem_limit(&fq->q, clone->truesize);
+		add_frag_mem_limit(fq->q.net, clone->truesize);
 	}
 
 	/* We have to remove fragment header from datagram and to relocate
@@ -454,7 +454,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 	}
-	sub_frag_mem_limit(&fq->q, head->truesize);
+	sub_frag_mem_limit(fq->q.net, head->truesize);
 
 	head->ignore_df = 1;
 	head->next = NULL;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 8ffa2c8..5c3bbca 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -330,7 +330,7 @@ found:
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
 	fq->ecn |= ecn;
-	add_frag_mem_limit(&fq->q, skb->truesize);
+	add_frag_mem_limit(fq->q.net, skb->truesize);
 
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
@@ -443,7 +443,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		head->len -= clone->len;
 		clone->csum = 0;
 		clone->ip_summed = head->ip_summed;
-		add_frag_mem_limit(&fq->q, clone->truesize);
+		add_frag_mem_limit(fq->q.net, clone->truesize);
 	}
 
 	/* We have to remove fragment header from datagram and to relocate
@@ -481,7 +481,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		}
 		fp = next;
 	}
-	sub_frag_mem_limit(&fq->q, sum_truesize);
+	sub_frag_mem_limit(fq->q.net, sum_truesize);
 
 	head->next = NULL;
 	head->dev = dev;
-- 
2.0.5
