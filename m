From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/4] xfrm: remove extranous rcu_read_lock
Date: Mon, 24 Sep 2012 21:12:25 -0700
Message-ID: <20120925041259.268246153@vyatta.com>
References: <20120925041222.056704869@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:44183 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768Ab2IYEQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 00:16:27 -0400
Content-Disposition: inline; filename=ipip-no-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The handlers for xfrm_tunnel are always invoked with rcu read lock
already.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv4/ip_vti.c |    5 -----
 net/ipv4/ipip.c   |    9 +--------
 net/ipv6/sit.c    |    6 ------
 3 files changed, 1 insertion(+), 19 deletions(-)

--- a/net/ipv4/ip_vti.c	2012-08-15 08:59:22.958704223 -0700
+++ b/net/ipv4/ip_vti.c	2012-09-24 18:01:20.521904773 -0700
@@ -304,7 +304,6 @@ static int vti_err(struct sk_buff *skb,
 
 	err = -ENOENT;
 
-	rcu_read_lock();
 	t = vti_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
 	if (t == NULL)
 		goto out;
@@ -326,7 +325,6 @@ static int vti_err(struct sk_buff *skb,
 		t->err_count = 1;
 	t->err_time = jiffies;
 out:
-	rcu_read_unlock();
 	return err;
 }
 
@@ -336,7 +334,6 @@ static int vti_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph = ip_hdr(skb);
 
-	rcu_read_lock();
 	tunnel = vti_tunnel_lookup(dev_net(skb->dev), iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
 		struct pcpu_tstats *tstats;
@@ -348,10 +345,8 @@ static int vti_rcv(struct sk_buff *skb)
 		u64_stats_update_end(&tstats->syncp);
 
 		skb->dev = tunnel->dev;
-		rcu_read_unlock();
 		return 1;
 	}
-	rcu_read_unlock();
 
 	return -1;
 }
--- a/net/ipv4/ipip.c	2012-09-24 17:59:26.127058210 -0700
+++ b/net/ipv4/ipip.c	2012-09-24 18:00:28.410430210 -0700
@@ -365,8 +365,6 @@ static int ipip_err(struct sk_buff *skb,
 	}
 
 	err = -ENOENT;
-
-	rcu_read_lock();
 	t = ipip_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
 	if (t == NULL)
 		goto out;
@@ -398,7 +396,7 @@ static int ipip_err(struct sk_buff *skb,
 		t->err_count = 1;
 	t->err_time = jiffies;
 out:
-	rcu_read_unlock();
+
 	return err;
 }
 
@@ -416,13 +414,11 @@ static int ipip_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph = ip_hdr(skb);
 
-	rcu_read_lock();
 	tunnel = ipip_tunnel_lookup(dev_net(skb->dev), iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
 		struct pcpu_tstats *tstats;
 
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-			rcu_read_unlock();
 			kfree_skb(skb);
 			return 0;
 		}
@@ -445,11 +441,8 @@ static int ipip_rcv(struct sk_buff *skb)
 		ipip_ecn_decapsulate(iph, skb);
 
 		netif_rx(skb);
-
-		rcu_read_unlock();
 		return 0;
 	}
-	rcu_read_unlock();
 
 	return -1;
 }
--- a/net/ipv6/sit.c	2012-08-15 08:59:22.986703941 -0700
+++ b/net/ipv6/sit.c	2012-09-24 18:02:28.753216804 -0700
@@ -545,7 +545,6 @@ static int ipip6_err(struct sk_buff *skb
 
 	err = -ENOENT;
 
-	rcu_read_lock();
 	t = ipip6_tunnel_lookup(dev_net(skb->dev),
 				skb->dev,
 				iph->daddr,
@@ -579,7 +578,6 @@ static int ipip6_err(struct sk_buff *skb
 		t->err_count = 1;
 	t->err_time = jiffies;
 out:
-	rcu_read_unlock();
 	return err;
 }
 
@@ -599,7 +597,6 @@ static int ipip6_rcv(struct sk_buff *skb
 
 	iph = ip_hdr(skb);
 
-	rcu_read_lock();
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
@@ -615,7 +612,6 @@ static int ipip6_rcv(struct sk_buff *skb
 		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
 		    !isatap_chksrc(skb, iph, tunnel)) {
 			tunnel->dev->stats.rx_errors++;
-			rcu_read_unlock();
 			kfree_skb(skb);
 			return 0;
 		}
@@ -630,12 +626,10 @@ static int ipip6_rcv(struct sk_buff *skb
 
 		netif_rx(skb);
 
-		rcu_read_unlock();
 		return 0;
 	}
 
 	/* no tunnel matched,  let upstream know, ipsec may handle it */
-	rcu_read_unlock();
 	return 1;
 out:
 	kfree_skb(skb);
