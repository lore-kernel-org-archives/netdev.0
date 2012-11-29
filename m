From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 2/9] net: frag cache line adjust
	inet_frag_queue.net
Date: Thu, 29 Nov 2012 17:11:32 +0100
Message-ID: <20121129161114.17754.8372.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:29373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755089Ab2K2QM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:12:57 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In inet_frag_find() unfortunate cache-line bounces can occur with
struct inet_frag_queue.  As the net pointer (struct netns_frags)
is placed on the same write-often cache-line as e.g. refcnt and
lock. As the hash match check always check (q->net == nf).

This (of-cause) only happens on hash bucket collisions, but as current
hash size is only 64 this makes collisions more likely.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 7b897b2..1f75316 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -14,7 +14,6 @@ struct netns_frags {
 
 struct inet_frag_queue {
 	struct hlist_node	list;
-	struct netns_frags	*net;
 	struct list_head	lru_list;   /* lru list member */
 	spinlock_t		lock;
 	atomic_t		refcnt;
@@ -24,6 +23,7 @@ struct inet_frag_queue {
 	ktime_t			stamp;
 	int			len;        /* total length of orig datagram */
 	int			meat;
+	struct netns_frags	*net;
 	u32			creation_ts;/* jiffies when queue was created*/
 	__u8			last_in;    /* first/last segment arrived? */
 
