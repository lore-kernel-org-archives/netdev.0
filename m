From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/4] [NET]: Generalise TSO-specific bits from skb_setup_caps
Date: Fri, 30 Jun 2006 15:45:42 +1000
Message-ID: <20060630054542.GB30149@gondor.apana.org.au>
References: <20060630054209.GA28558@gondor.apana.org.au> <20060630054300.GA30149@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:1291 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751132AbWF3FrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 01:47:13 -0400
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060630054300.GA30149@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[NET]: Generalise TSO-specific bits from skb_setup_caps

This patch generalises the TSO-specific bits from sk_setup_caps by adding
the sk_gso_type member to struct sock.  This makes sk_setup_caps generic
so that it can be used by TCPv6 or UFO.

The only catch is that whoever uses this must provide a GSO implementation
for their protocol which I think is a fair deal :) For now UFO continues to
live without a GSO implementation which is OK since it doesn't use the sock
caps field at the moment.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -313,6 +313,7 @@ struct net_device
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
+#define NETIF_F_GSO_MASK	0xffff0000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
@@ -991,13 +992,18 @@ extern void dev_seq_stop(struct seq_file
 
 extern void linkwatch_run_queue(void);
 
-static inline int skb_gso_ok(struct sk_buff *skb, int features)
+static inline int net_gso_ok(int features, int gso_type)
 {
-	int feature = skb_shinfo(skb)->gso_size ?
-		      skb_shinfo(skb)->gso_type << NETIF_F_GSO_SHIFT : 0;
+	int feature = gso_type << NETIF_F_GSO_SHIFT;
 	return (features & feature) == feature;
 }
 
+static inline int skb_gso_ok(struct sk_buff *skb, int features)
+{
+	return net_gso_ok(features, skb_shinfo(skb)->gso_size ?
+				    skb_shinfo(skb)->gso_type : 0);
+}
+
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
 	return !skb_gso_ok(skb, dev->features);
diff --git a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -140,6 +140,7 @@ struct sock_common {
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE, %SO_OOBINLINE settings
   *	@sk_no_check: %SO_NO_CHECK setting, wether or not checkup packets
   *	@sk_route_caps: route capabilities (e.g. %NETIF_F_TSO)
+  *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
   *	@sk_lingertime: %SO_LINGER l_linger setting
   *	@sk_backlog: always used with the per-socket spinlock held
   *	@sk_callback_lock: used with the callbacks in the end of this struct
@@ -211,6 +212,7 @@ struct sock {
 	gfp_t			sk_allocation;
 	int			sk_sndbuf;
 	int			sk_route_caps;
+	int			sk_gso_type;
 	int			sk_rcvlowat;
 	unsigned long 		sk_flags;
 	unsigned long	        sk_lingertime;
@@ -1025,15 +1027,20 @@ extern struct dst_entry *__sk_dst_check(
 
 extern struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie);
 
+static inline int sk_can_gso(const struct sock *sk)
+{
+	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
+}
+
 static inline void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 {
 	__sk_dst_set(sk, dst);
 	sk->sk_route_caps = dst->dev->features;
 	if (sk->sk_route_caps & NETIF_F_GSO)
-		sk->sk_route_caps |= NETIF_F_TSO;
-	if (sk->sk_route_caps & NETIF_F_TSO) {
+		sk->sk_route_caps |= NETIF_F_GSO_MASK;
+	if (sk_can_gso(sk)) {
 		if (dst->header_len)
-			sk->sk_route_caps &= ~NETIF_F_TSO;
+			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		else 
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	}
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -751,7 +751,7 @@ static inline int tcp_is_cwnd_limited(co
 	if (in_flight >= tp->snd_cwnd)
 		return 1;
 
-	if (!(sk->sk_route_caps & NETIF_F_TSO))
+	if (!sk_can_gso(sk))
 		return 0;
 
 	left = tp->snd_cwnd - in_flight;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -643,7 +643,7 @@ static inline int select_size(struct soc
 	int tmp = tp->mss_cache;
 
 	if (sk->sk_route_caps & NETIF_F_SG) {
-		if (sk->sk_route_caps & NETIF_F_TSO)
+		if (sk_can_gso(sk))
 			tmp = 0;
 		else {
 			int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -242,6 +242,7 @@ int tcp_v4_connect(struct sock *sk, stru
 		goto failure;
 
 	/* OK, now commit destination to socket.  */
+	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->u.dst);
 
 	if (!tp->write_seq)
@@ -884,6 +885,7 @@ struct sock *tcp_v4_syn_recv_sock(struct
 	if (!newsk)
 		goto exit;
 
+	newsk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(newsk, dst);
 
 	newtp		      = tcp_sk(newsk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -510,8 +510,7 @@ static void tcp_queue_skb(struct sock *s
 
 static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb, unsigned int mss_now)
 {
-	if (skb->len <= mss_now ||
-	    !(sk->sk_route_caps & NETIF_F_TSO)) {
+	if (skb->len <= mss_now || !sk_can_gso(sk)) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
@@ -525,7 +524,7 @@ static void tcp_set_skb_tso_segs(struct 
 		factor /= mss_now;
 		skb_shinfo(skb)->gso_segs = factor;
 		skb_shinfo(skb)->gso_size = mss_now;
-		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
 	}
 }
 
@@ -824,9 +823,7 @@ unsigned int tcp_current_mss(struct sock
 
 	mss_now = tp->mss_cache;
 
-	if (large_allowed &&
-	    (sk->sk_route_caps & NETIF_F_TSO) &&
-	    !tp->urg_mode)
+	if (large_allowed && sk_can_gso(sk) && !tp->urg_mode)
 		doing_tso = 1;
 
 	if (dst) {
