From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/3] net: use the frag lru_lock to protect
	netns_frags.nqueues update
Date: Wed, 27 Mar 2013 16:55:56 +0100
Message-ID: <20130327155530.15203.45784.stgit@dragon>
References: <20130327155238.15203.6688.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58503 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348Ab3C0P4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 11:56:01 -0400
In-Reply-To: <20130327155238.15203.6688.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the protection of netns_frags.nqueues updates under the LRU_lock,
instead of the write lock.  As they are located on the same cacheline,
and this is also needed when transitioning to use per hash bucket locking.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h  |    2 ++
 net/ipv4/inet_fragment.c |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 64b4e7d..7cac9c5 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -143,6 +143,7 @@ static inline void inet_frag_lru_del(struct inet_frag_queue *q)
 {
 	spin_lock(&q->net->lru_lock);
 	list_del(&q->lru_list);
+	q->net->nqueues--;
 	spin_unlock(&q->net->lru_lock);
 }
 
@@ -151,6 +152,7 @@ static inline void inet_frag_lru_add(struct netns_frags *nf,
 {
 	spin_lock(&nf->lru_lock);
 	list_add_tail(&q->lru_list, &nf->lru_list);
+	q->net->nqueues++;
 	spin_unlock(&nf->lru_lock);
 }
 
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 8ba548a..1206ca6 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -124,7 +124,6 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 {
 	write_lock(&f->lock);
 	hlist_del(&fq->list);
-	fq->net->nqueues--;
 	write_unlock(&f->lock);
 	inet_frag_lru_del(fq);
 }
@@ -260,7 +259,6 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &f->hash[hash]);
-	nf->nqueues++;
 	write_unlock(&f->lock);
 	inet_frag_lru_add(nf, qp);
 	return qp;
