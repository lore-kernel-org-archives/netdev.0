From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 3/6] net: cacheline adjust struct inet_frag_queue
Date: Tue, 29 Jan 2013 10:44:49 +0100
Message-ID: <20130129094442.13513.6103.stgit@dragon>
References: <20130129094331.13513.28377.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab3A2JlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 04:41:23 -0500
In-Reply-To: <20130129094331.13513.28377.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fragmentation code cacheline adjusting of struct inet_frag_queue.

Take advantage of the size of struct timer_list, and move all but
spinlock_t lock, below the timer struct.  On 64-bit 'lru_list',
'list' and 'refcnt', fits exactly into the next cacheline, and a
new cacheline starts at 'fragments'.

The netns_frags *net pointer is moved to the end of the struct,
because its used in a compare, with "next/close-by" elements of
which this struct is embedded into.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 54c1de7..8e4c425 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -16,12 +16,11 @@ struct netns_frags {
 };
 
 struct inet_frag_queue {
-	struct hlist_node	list;
-	struct netns_frags	*net;
-	struct list_head	lru_list;   /* lru list member */
 	spinlock_t		lock;
-	atomic_t		refcnt;
 	struct timer_list	timer;      /* when will this queue expire? */
+	struct list_head	lru_list;   /* lru list member */
+	struct hlist_node	list;
+	atomic_t		refcnt;
 	struct sk_buff		*fragments; /* list of received fragments */
 	struct sk_buff		*fragments_tail;
 	ktime_t			stamp;
@@ -34,6 +33,8 @@ struct inet_frag_queue {
 #define INET_FRAG_LAST_IN	1
 
 	u16			max_size;
+
+	struct netns_frags	*net;
 };
 
 #define INETFRAGS_HASHSZ		64
