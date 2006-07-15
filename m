From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Sat, 15 Jul 2006 23:28:34 +1000
Message-ID: <E1G1kCA-000533-00@gondolin.me.apana.org.au>
References: <20060714.144855.62664893.davem@davemloft.net>
Cc: shemminger@osdl.org, guichaz@yahoo.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5380 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964792AbWGON2x
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 09:28:53 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060714.144855.62664893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> Thank goodness this thing is only 3-words in size, this is going to
> run on every single IPv4 packet received by the system. :-/

At least this lets us get rid of a few other memsets :)

[IPV4]: Get rid of redundant IPCB->opts initialisation

Now that we always zero the IPCB->opts in ip_rcv, it is no longer
necessary to do so before calling netif_rx for tunneled packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6ff9b10..0f9b3a3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -617,7 +617,6 @@ static int ipgre_rcv(struct sk_buff *skb
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = __pskb_pull(skb, offset);
 		skb_postpull_rcsum(skb, skb->h.raw, offset);
-		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 		skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (MULTICAST(iph->daddr)) {
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index cbcae65..406056e 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -256,7 +256,6 @@ int ip_options_compile(struct ip_options
 
 	if (!opt) {
 		opt = &(IPCB(skb)->opt);
-		memset(opt, 0, sizeof(struct ip_options));
 		iph = skb->nh.raw;
 		opt->optlen = ((struct iphdr *)iph)->ihl*4 - sizeof(struct iphdr);
 		optptr = iph + sizeof(struct iphdr);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 3291d51..76ab50b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -487,7 +487,6 @@ static int ipip_rcv(struct sk_buff *skb)
 
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = skb->data;
-		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 		skb->protocol = htons(ETH_P_IP);
 		skb->pkt_type = PACKET_HOST;
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ba33f86..9ccacf5 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1461,7 +1461,6 @@ int pim_rcv_v1(struct sk_buff * skb)
 	skb_pull(skb, (u8*)encap - skb->data);
 	skb->nh.iph = (struct iphdr *)skb->data;
 	skb->dev = reg_dev;
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
@@ -1517,7 +1516,6 @@ static int pim_rcv(struct sk_buff * skb)
 	skb_pull(skb, (u8*)encap - skb->data);
 	skb->nh.iph = (struct iphdr *)skb->data;
 	skb->dev = reg_dev;
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index f8d880b..13cafbe 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -92,7 +92,6 @@ static int xfrm4_tunnel_input(struct xfr
 	skb->mac.raw = memmove(skb->data - skb->mac_len,
 			       skb->mac.raw, skb->mac_len);
 	skb->nh.raw = skb->data;
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	err = 0;
 
 out:
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index c56aeec..836eecd 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -380,7 +380,6 @@ static int ipip6_rcv(struct sk_buff *skb
 		secpath_reset(skb);
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = skb->data;
-		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 		IPCB(skb)->flags = 0;
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
