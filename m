From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/3] net: fix race bug in fragmentation create code
Date: Thu, 18 Apr 2013 23:37:27 +0200
Message-ID: <20130418213715.14296.43912.stgit@dragon>
References: <20130418213637.14296.43143.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823Ab3DRVe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 17:34:57 -0400
In-Reply-To: <20130418213637.14296.43143.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During creation of a new inet_frag_queue, the lru_list pointer is
updated after releasing the hash bucket lock, which can lead to a
race condition (and panic), if the inet_frag_queue is deleted
(very quickly) before the lru_list is valid.

This race condition is should not be able to occur with current
LRU based evictor.  For the planned direct hash based
evictor/clean strategy, this race condition is more likely to
occur.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/inet_fragment.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index e97d66a..beec05b 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -283,9 +283,9 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &hb->chain);
+	inet_frag_lru_add(nf, qp);
 	spin_unlock(&hb->chain_lock);
 	read_unlock(&f->lock);
-	inet_frag_lru_add(nf, qp);
 	return qp;
 }
 
