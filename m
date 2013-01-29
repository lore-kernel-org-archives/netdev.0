From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 2/6] net: cacheline adjust struct inet_frags for
	better frag performance
Date: Tue, 29 Jan 2013 10:44:37 +0100
Message-ID: <20130129094419.13513.82665.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:63700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129Ab3A2Jlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 04:41:32 -0500
In-Reply-To: <20130129094331.13513.28377.stgit@dragon>
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
V2:
 - Remove comment about cacheline boundary

 include/net/inet_frag.h |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 91e7797..54c1de7 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -40,18 +40,21 @@ struct inet_frag_queue {
 
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
 
