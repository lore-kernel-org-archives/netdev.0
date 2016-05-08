From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ifb: support more features
Date: Sun, 08 May 2016 10:35:42 -0700
Message-ID: <1462728942.23934.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462686072.23934.4.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462723712.23934.18.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36724 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbcEHRfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:35:45 -0400
Received: by mail-pf0-f181.google.com with SMTP id c189so69302135pfb.3
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:35:44 -0700 (PDT)
In-Reply-To: <1462723712.23934.18.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-05-08 at 09:08 -0700, Eric Dumazet wrote:


> So we probably need to make sure the network header is properly set for
> the segments. Then skb_reset_mac_len(nskb); would work as intended.
> 
> Since skb_segment() is called from the deepest point in GSO path,
> it always see the inner network header.
> 
> Sounds like skb_reset_network_header() calls done in inet_gso_segment()
> and ipv6_gso_segment() should only be done for the outer header, (when
> SKB_GSO_CB(skb)->encap_level == 0), or even better, only done in 
> skb_mac_gso_segment()
> 
> Then we need to use the proper (inner) network header in
> tcp4_gso_segment() and tcp6_gso_segment(), as they currently use
> ip_hdr() and ipv6_hdr()
> 

Prototype patch works for me (but GRE/UDP offloads might need some
work), and would even save few cycles...

Unfortunately GSO for GRE/UDP is kind of mess.

 net/core/dev.c           |    1 +
 net/ipv4/af_inet.c       |    9 +++------
 net/ipv4/tcp_offload.c   |    2 +-
 net/ipv6/ip6_offload.c   |    9 +++------
 net/ipv6/tcpv6_offload.c |    2 +-
 5 files changed, 9 insertions(+), 14 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c925ac50b95..3a9035ec862b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2658,6 +2658,7 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 		return ERR_PTR(-EINVAL);
 
 	__skb_pull(skb, vlan_depth);
+	skb_reset_network_header(skb);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9e481992dbae..fef6335a75bc 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1220,12 +1220,12 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       0)))
 		goto out;
 
-	skb_reset_network_header(skb);
-	nhoff = skb_network_header(skb) - skb_mac_header(skb);
+	skb_reset_inner_network_header(skb);
+	nhoff = skb->data - skb_mac_header(skb);
 	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
 		goto out;
 
-	iph = ip_hdr(skb);
+	iph = inner_ip_hdr(skb);
 	ihl = iph->ihl * 4;
 	if (ihl < sizeof(*iph))
 		goto out;
@@ -1274,9 +1274,6 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		}
 		iph->tot_len = htons(skb->len - nhoff);
 		ip_send_check(iph);
-		if (encap)
-			skb_reset_inner_headers(skb);
-		skb->network_header = (u8 *)iph - skb->head;
 	} while ((skb = skb->next));
 
 out:
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 773083b7f1e9..f0650b50680e 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -36,7 +36,7 @@ static struct sk_buff *tcp4_gso_segment(struct sk_buff *skb,
 		return ERR_PTR(-EINVAL);
 
 	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
-		const struct iphdr *iph = ip_hdr(skb);
+		const struct iphdr *iph = inner_ip_hdr(skb);
 		struct tcphdr *th = tcp_hdr(skb);
 
 		/* Set up checksum pseudo header, usually expect stack to
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 82e9f3076028..8d27299f86e4 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -84,8 +84,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       0)))
 		goto out;
 
-	skb_reset_network_header(skb);
-	nhoff = skb_network_header(skb) - skb_mac_header(skb);
+	skb_reset_inner_network_header(skb);
+	nhoff = skb->data - skb_mac_header(skb);
 	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
 		goto out;
 
@@ -94,7 +94,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		features &= skb->dev->hw_enc_features;
 	SKB_GSO_CB(skb)->encap_level += sizeof(*ipv6h);
 
-	ipv6h = ipv6_hdr(skb);
+	ipv6h = inner_ipv6_hdr(skb);
 	__skb_pull(skb, sizeof(*ipv6h));
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
@@ -118,7 +118,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	for (skb = segs; skb; skb = skb->next) {
 		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
 		ipv6h->payload_len = htons(skb->len - nhoff - sizeof(*ipv6h));
-		skb->network_header = (u8 *)ipv6h - skb->head;
 
 		if (udpfrag) {
 			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
@@ -129,8 +128,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 			offset += (ntohs(ipv6h->payload_len) -
 				   sizeof(struct frag_hdr));
 		}
-		if (encap)
-			skb_reset_inner_headers(skb);
 	}
 
 out:
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index d883c9204c01..8e747a295bce 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -50,7 +50,7 @@ static struct sk_buff *tcp6_gso_segment(struct sk_buff *skb,
 		return ERR_PTR(-EINVAL);
 
 	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
-		const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+		const struct ipv6hdr *ipv6h = inner_ipv6_hdr(skb);
 		struct tcphdr *th = tcp_hdr(skb);
 
 		/* Set up pseudo header, usually expect stack to have done
