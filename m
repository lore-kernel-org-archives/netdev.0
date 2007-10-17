From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/11] [IPSEC]: Fix length check in xfrm_parse_spi
Date: Wed, 17 Oct 2007 22:34:13 +0800
Message-ID: <E1Ii9yP-0006HD-00@gondolin.me.apana.org.au>
References: <20071017142940.GA23879@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1108 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758521AbXJQOeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 10:34:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Fix length check in xfrm_parse_spi

Currently xfrm_parse_spi requires there to be 16 bytes for AH and ESP.
In contrived cases there may not actually be 16 bytes there since the
respective header sizes are less than that (8 and 12 currently).

This patch changes the test to use the actual header length instead of 16.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_input.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 113f444..cb97fda 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -49,13 +49,16 @@ EXPORT_SYMBOL(secpath_dup);
 int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 {
 	int offset, offset_seq;
+	int hlen;
 
 	switch (nexthdr) {
 	case IPPROTO_AH:
+		hlen = sizeof(struct ip_auth_hdr);
 		offset = offsetof(struct ip_auth_hdr, spi);
 		offset_seq = offsetof(struct ip_auth_hdr, seq_no);
 		break;
 	case IPPROTO_ESP:
+		hlen = sizeof(struct ip_esp_hdr);
 		offset = offsetof(struct ip_esp_hdr, spi);
 		offset_seq = offsetof(struct ip_esp_hdr, seq_no);
 		break;
@@ -69,7 +72,7 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 		return 1;
 	}
 
-	if (!pskb_may_pull(skb, 16))
+	if (!pskb_may_pull(skb, hlen))
 		return -EINVAL;
 
 	*spi = *(__be32*)(skb_transport_header(skb) + offset);
