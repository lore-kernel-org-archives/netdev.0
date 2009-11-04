From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip_frag:
Date: Wed, 04 Nov 2009 22:54:17 +0100
Message-ID: <4AF1F809.4090903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58414 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932912AbZKDVyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:54:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending fragmentation expiration ICMP V4/V6 messages,
we can avoid touching device refcount, thanks to RCU

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_fragment.c |    6 +++---
 net/ipv6/reassembly.c  |   13 ++++++-------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 575f9bd..93e50d0 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -206,10 +206,10 @@ static void ip_expire(unsigned long arg)
 		struct sk_buff *head = qp->q.fragments;
 
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
-		if ((head->dev = dev_get_by_index(net, qp->iif)) != NULL) {
+		rcu_read_lock();
+		if ((head->dev = dev_get_by_index_rcu(net, qp->iif)) != NULL)
 			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
-			dev_put(head->dev);
-		}
+		rcu_read_unlock();
 	}
 out:
 	spin_unlock(&qp->q.lock);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index da5bd0e..dce699f 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -208,18 +208,17 @@ static void ip6_frag_expire(unsigned long data)
 	fq_kill(fq);
 
 	net = container_of(fq->q.net, struct net, ipv6.frags);
-	dev = dev_get_by_index(net, fq->iif);
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, fq->iif);
 	if (!dev)
-		goto out;
+		goto out_rcu_unlock;
 
-	rcu_read_lock();
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
-	rcu_read_unlock();
 
 	/* Don't send error if the first segment did not arrive. */
 	if (!(fq->q.last_in & INET_FRAG_FIRST_IN) || !fq->q.fragments)
-		goto out;
+		goto out_rcu_unlock;
 
 	/*
 	   But use as source device on which LAST ARRIVED
@@ -228,9 +227,9 @@ static void ip6_frag_expire(unsigned long data)
 	 */
 	fq->q.fragments->dev = dev;
 	icmpv6_send(fq->q.fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0, dev);
+out_rcu_unlock:
+	rcu_read_unlock();
 out:
-	if (dev)
-		dev_put(dev);
 	spin_unlock(&fq->q.lock);
 	fq_put(fq);
 }
