From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 4/5] udpv6: Remove unused skb argument of
 ipv6_select_ident()
Date: Thu, 09 Jul 2009 11:10:01 -0700
Message-ID: <1247163001.8649.93.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:55418 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbZGISKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 14:10:08 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n69Hv5lw020870
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 13:57:05 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69IA7Gd254728
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:10:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n69IA62G002362
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:10:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6 4/5] udpv6: Remove unused skb argument of ipv6_select_ident()

- move ipv6_select_ident() inline function to ipv6.h and remove the unused
  skb argument

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/ipv6.h    |   12 ++++++++++++
 net/ipv6/ip6_output.c |   18 +++---------------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f27fd83..ad9a511 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -441,6 +441,18 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
+static __inline__ void ipv6_select_ident(struct frag_hdr *fhdr)
+{
+	static u32 ipv6_fragmentation_id = 1;
+	static DEFINE_SPINLOCK(ip6_id_lock);
+
+	spin_lock_bh(&ip6_id_lock);
+	fhdr->identification = htonl(ipv6_fragmentation_id);
+	if (++ipv6_fragmentation_id == 0)
+		ipv6_fragmentation_id = 1;
+	spin_unlock_bh(&ip6_id_lock);
+}
+
 /*
  *	Prototypes exported by ipv6
  */
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1c6f0fc..dd1a980 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -57,18 +57,6 @@
 
 static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
-static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *fhdr)
-{
-	static u32 ipv6_fragmentation_id = 1;
-	static DEFINE_SPINLOCK(ip6_id_lock);
-
-	spin_lock_bh(&ip6_id_lock);
-	fhdr->identification = htonl(ipv6_fragmentation_id);
-	if (++ipv6_fragmentation_id == 0)
-		ipv6_fragmentation_id = 1;
-	spin_unlock_bh(&ip6_id_lock);
-}
-
 int __ip6_local_out(struct sk_buff *skb)
 {
 	int len;
@@ -706,7 +694,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
 
-		ipv6_select_ident(skb, fh);
+		ipv6_select_ident(fh);
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
 		fh->frag_off = htons(IP6_MF);
@@ -844,7 +832,7 @@ slow_path:
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
 		if (!frag_id) {
-			ipv6_select_ident(skb, fh);
+			ipv6_select_ident(fh);
 			frag_id = fh->identification;
 		} else
 			fh->identification = frag_id;
@@ -1093,7 +1081,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
 					     sizeof(struct frag_hdr)) & ~7;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-		ipv6_select_ident(skb, &fhdr);
+		ipv6_select_ident(&fhdr);
 		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
 		__skb_queue_tail(&sk->sk_write_queue, skb);
 


