From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Mon, 22 Apr 2013 18:30:17 +0200
Message-ID: <1366648217.26911.302.camel@localhost>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
	 <20130419124528.GF27889@order.stressinduktion.org>
	 <1366381742.26911.166.camel@localhost>
	 <20130419194424.GI27889@order.stressinduktion.org>
	 <1366621834.26911.271.camel@localhost>
	 <20130422145431.GA26838@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753900Ab3DVRYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 13:24:06 -0400
In-Reply-To: <20130422145431.GA26838@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 16:54 +0200, Hannes Frederic Sowa wrote:
> On Mon, Apr 22, 2013 at 11:10:34AM +0200, Jesper Dangaard Brouer wrote:
[...]
> > Besides, after we have implemented per hash bucket locking (in my change
> > commit 19952cc4 "net: frag queue per hash bucket locking").
> > Then, I don't think it is a big problem that a single hash bucket is
> > being "attacked".
> 
> I don't know, I wouldn't say so. The contention point is now the per
> hash bucket lock but it should show the same symptoms as before.

No, the contention point is the LRU list lock, not the hash bucket lock.
If you perf record/profile the code, you can easily miss that its the
LRU lock, because its inlined.  Try to rerun your tests with noinline
e.g.:


diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 6f41b45..9963b87 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -138,14 +138,14 @@ static inline int sum_frag_mem_limit(struct
netns_frags *n
        return res;
 }
 
-static inline void inet_frag_lru_move(struct inet_frag_queue *q)
+static noinline void inet_frag_lru_move(struct inet_frag_queue *q)
 {
        spin_lock(&q->net->lru_lock);
        list_move_tail(&q->lru_list, &q->net->lru_list);
        spin_unlock(&q->net->lru_lock);
 }
 
-static inline void inet_frag_lru_del(struct inet_frag_queue *q)
+static noinline void inet_frag_lru_del(struct inet_frag_queue *q)
 {
        spin_lock(&q->net->lru_lock);
        list_del(&q->lru_list);
@@ -153,7 +153,7 @@ static inline void inet_frag_lru_del(struct
inet_frag_queue 
        spin_unlock(&q->net->lru_lock);
 }
 
-static inline void inet_frag_lru_add(struct netns_frags *nf,
+static noinline void inet_frag_lru_add(struct netns_frags *nf,
                                     struct inet_frag_queue *q)
 {
        spin_lock(&nf->lru_lock);
