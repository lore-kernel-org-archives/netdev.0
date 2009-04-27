From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Mon, 27 Apr 2009 16:07:35 +0800
Message-ID: <20090427080735.GA21493@gondor.apana.org.au>
References: <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42941 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752373AbZD0IHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 04:07:41 -0400
Content-Disposition: inline
In-Reply-To: <20090427080501.GA21433@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 04:05:01PM +0800, Herbert Xu wrote:
> 
> OK, I'd created a silly bug with the skb_gro_* optimisation.
> Here are two patches to fix them.
> 
> gro: Fix handling of headers that extend over the tail

gro: Fix COMPLETE checksum handling

On a brand new GRO skb, we cannot call ip_hdr since the header
may lie in the non-linear area.  This patch adds the helper
skb_gro_network_header to handle this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0396447..287bec9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1150,6 +1150,13 @@ static inline void *skb_gro_mac_header(struct sk_buff *skb)
 	       skb_shinfo(skb)->frags[0].page_offset;
 }
 
+static inline void *skb_gro_network_header(struct sk_buff *skb)
+{
+	return skb_headlen(skb) ? skb_network_header(skb) :
+	       page_address(skb_shinfo(skb)->frags[0].page) +
+	       skb_shinfo(skb)->frags[0].page_offset + skb_network_offset(skb);
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5d427f8..bda74e8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2343,7 +2343,7 @@ void tcp4_proc_exit(void)
 
 struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(skb);
+	struct iphdr *iph = skb_gro_network_header(skb);
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4b5aa18..d9dd94b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -943,7 +943,7 @@ static int tcp_v6_gso_send_check(struct sk_buff *skb)
 
 struct sk_buff **tcp6_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct ipv6hdr *iph = skb_gro_network_header(skb);
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
