From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/4] inet: frags: use INET_FRAG_EVICTED to prevent icmp messages
Date: Thu, 31 Jul 2014 17:11:38 +0200
Message-ID: <1406819499-11198-4-git-send-email-nikolay@redhat.com>
References: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbaGaPOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 11:14:50 -0400
In-Reply-To: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have INET_FRAG_EVICTED we might as well use it to stop
sending icmp messages in the "frag_expire" functions instead of
stripping INET_FRAG_FIRST_IN from their flags when evicting.
Also fix the comment style in ip6_expire_frag_queue().

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 net/ipv4/inet_fragment.c |  2 --
 net/ipv4/ip_fragment.c   | 14 +++++++-------
 net/ipv6/reassembly.c    | 15 ++++++++-------
 3 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 01d9b268f863..1e9a9592a8ac 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -151,8 +151,6 @@ evict_again:
 			goto evict_again;
 		}
 
-		/* suppress xmit of (icmp) error packet */
-		fq->flags &= ~INET_FRAG_FIRST_IN;
 		fq->flags |= INET_FRAG_EVICTED;
 		hlist_del(&fq->list);
 		hlist_add_head(&fq->list, &expired);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 6fce1ecc5bca..cb56bcc1eee2 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -189,16 +189,18 @@ static void ip_expire(unsigned long arg)
 		goto out;
 
 	ipq_kill(qp);
-
-	if (!(qp->q.flags & INET_FRAG_EVICTED))
-		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 
-	if ((qp->q.flags & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
+	if (!(qp->q.flags & INET_FRAG_EVICTED)) {
 		struct sk_buff *head = qp->q.fragments;
 		const struct iphdr *iph;
 		int err;
 
+		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
+
+		if (!(qp->q.flags & INET_FRAG_FIRST_IN) || !qp->q.fragments)
+			goto out;
+
 		rcu_read_lock();
 		head->dev = dev_get_by_index_rcu(net, qp->iif);
 		if (!head->dev)
@@ -211,8 +213,7 @@ static void ip_expire(unsigned long arg)
 		if (err)
 			goto out_rcu_unlock;
 
-		/*
-		 * Only an end host needs to send an ICMP
+		/* Only an end host needs to send an ICMP
 		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
 		if (qp->user == IP_DEFRAG_AF_PACKET ||
@@ -221,7 +222,6 @@ static void ip_expire(unsigned long arg)
 		     (skb_rtable(head)->rt_type != RTN_LOCAL)))
 			goto out_rcu_unlock;
 
-
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
 out_rcu_unlock:
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index b4baceed0d0d..beb6872a8fa5 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -141,19 +141,20 @@ void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
 	if (!dev)
 		goto out_rcu_unlock;
 
-	if (!(fq->q.flags & INET_FRAG_EVICTED))
-		IP6_INC_STATS_BH(net, __in6_dev_get(dev),
-				 IPSTATS_MIB_REASMTIMEOUT);
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 
+	if (fq->q.flags & INET_FRAG_EVICTED)
+		goto out_rcu_unlock;
+
+	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
+
 	/* Don't send error if the first segment did not arrive. */
 	if (!(fq->q.flags & INET_FRAG_FIRST_IN) || !fq->q.fragments)
 		goto out_rcu_unlock;
 
-	/*
-	   But use as source device on which LAST ARRIVED
-	   segment was received. And do not use fq->dev
-	   pointer directly, device might already disappeared.
+	/* But use as source device on which LAST ARRIVED
+	 * segment was received. And do not use fq->dev
+	 * pointer directly, device might already disappeared.
 	 */
 	fq->q.fragments->dev = dev;
 	icmpv6_send(fq->q.fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0);
-- 
1.9.3
