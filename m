From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [5/4] [NET]: Verify gso_type too in gso_segment
Date: Fri, 30 Jun 2006 16:13:50 +1000
Message-ID: <20060630061350.GA3660@gondor.apana.org.au>
References: <20060630054209.GA28558@gondor.apana.org.au> <20060630054300.GA30149@gondor.apana.org.au> <20060630054542.GB30149@gondor.apana.org.au> <20060630054702.GC30149@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:50955 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751140AbWF3GP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 02:15:26 -0400
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060630054702.GC30149@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[NET]: Verify gso_type too in gso_segment

We don't want nasty Xen guests to pass a TCPv6 packet in with gso_type set
to TCPv4 or even UDP (or a packet that's both TCP and UDP).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8d15715..318d467 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1106,7 +1106,15 @@ static struct sk_buff *inet_gso_segment(
 	int ihl;
 	int id;
 
-	if (!pskb_may_pull(skb, sizeof(*iph)))
+	if (unlikely(skb_shinfo(skb)->gso_type &
+		     ~(SKB_GSO_TCPV4 |
+		       SKB_GSO_UDP |
+		       SKB_GSO_DODGY |
+		       SKB_GSO_TCP_ECN |
+		       0)))
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
 		goto out;
 
 	iph = skb->nh.iph;
@@ -1114,7 +1122,7 @@ static struct sk_buff *inet_gso_segment(
 	if (ihl < sizeof(*iph))
 		goto out;
 
-	if (!pskb_may_pull(skb, ihl))
+	if (unlikely(!pskb_may_pull(skb, ihl)))
 		goto out;
 
 	skb->h.raw = __skb_pull(skb, ihl);
@@ -1125,7 +1133,7 @@ static struct sk_buff *inet_gso_segment(
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_protos[proto]);
-	if (ops && ops->gso_segment)
+	if (likely(ops && ops->gso_segment))
 		segs = ops->gso_segment(skb, features);
 	rcu_read_unlock();
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 59e30ba..2f81374 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2155,6 +2155,14 @@ struct sk_buff *tcp_tso_segment(struct s
 	unsigned int oldlen;
 	unsigned int len;
 
+	if (unlikely(skb_shinfo(skb)->gso_type &
+		     ~(SKB_GSO_TCPV4 |
+		       SKB_GSO_DODGY |
+		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_TCPV6 |
+		       0)))
+		goto out;
+
 	if (!pskb_may_pull(skb, sizeof(*th)))
 		goto out;
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 25f8bf8..03b65aa 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -65,6 +65,14 @@ static struct sk_buff *ipv6_gso_segment(
 	struct inet6_protocol *ops;
 	int proto;
 
+	if (unlikely(skb_shinfo(skb)->gso_type &
+		     ~(SKB_GSO_UDP |
+		       SKB_GSO_DODGY |
+		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_TCPV6 |
+		       0)))
+		goto out;
+
 	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
 		goto out;
 
