From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/6] net: cacheline adjust struct inet_frags for
	better frag performance
Date: Thu, 24 Jan 2013 15:04:20 +0100
Message-ID: <20130124140417.14119.32738.stgit@dragon>
References: <20130124140343.14119.77712.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:11101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239Ab3AXOFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 09:05:15 -0500
In-Reply-To: <20130124140343.14119.77712.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The globally shared rwlock, of struct inet_frags, shares
cacheline with the 'rnd' number, which is used by the hash
calculations.  Fix this, as this obviously is a bad idea, as
unnecessary cache-misses will occur when accessing the 'rnd'
number.

Also small note that, moving function ptr (*match) up in struct,
is to avoid it lands on the next cacheline (on 64-bit).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 91e7797..99eb4e0 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -40,18 +40,22 @@ struct inet_frag_queue {
 
 struct inet_frags {
 	struct hlist_head	hash[INETFRAGS_HASHSZ];
-	rwlock_t		lock;
-	u32			rnd;
-	int			qsize;
+	/* This rwlock is a global lock (seperate per IPv4, IPv6 and
+	 * netfilter). Important to keep this on a seperate cacheline.
+	 */
+	rwlock_t		lock ____cacheline_aligned_in_smp;
 	int			secret_interval;
 	struct timer_list	secret_timer;
+	/* --- read-mostly cacheline boundary (was 24 bytes ago) --- */
+	u32			rnd;
+	int			qsize;
 
 	unsigned int		(*hashfn)(struct inet_frag_queue *);
+	bool			(*match)(struct inet_frag_queue *q, void *arg);
 	void			(*constructor)(struct inet_frag_queue *q,
 						void *arg);
 	void			(*destructor)(struct inet_frag_queue *);
 	void			(*skb_free)(struct sk_buff *);
-	bool			(*match)(struct inet_frag_queue *q, void *arg);
 	void			(*frag_expire)(unsigned long data);
 };
 
