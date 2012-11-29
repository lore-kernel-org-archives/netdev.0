From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 9/9] net: increase frag queue hash size and
	cache-line
Date: Thu, 29 Nov 2012 17:16:39 +0100
Message-ID: <20121129161552.17754.86087.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:37812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754768Ab2K2QR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:17:58 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase frag queue hash size and assure cache-line alignment to
avoid false sharing.  Hash size is set to 256, because I have
observed 206 frag queues in use at 4x10G with packet size 4416 bytes
(three fragments).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h  |    5 ++---
 net/ipv4/inet_fragment.c |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 431f68e..c8ad7e4 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -47,13 +47,12 @@ struct inet_frag_queue {
 	u16			max_size;
 };
 
-#define INETFRAGS_HASHSZ		64
-
+#define INETFRAGS_HASHSZ	256
 
 struct inet_frag_bucket {
 	struct hlist_head	chain;
 	spinlock_t		chain_lock;
-};
+} ____cacheline_aligned_in_smp;
 
 struct inet_frags {
 	struct inet_frag_bucket	hash[INETFRAGS_HASHSZ];
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 59999e6..44c9c75 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -61,7 +61,7 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 
 				/* Relink to new hash chain. */
 				hb_dest = &f->hash[hval];
-				hlist_add_head(&q->list, &hb->chain);
+				hlist_add_head(&q->list, &hb_dest->chain);
 			}
 		}
 	}
