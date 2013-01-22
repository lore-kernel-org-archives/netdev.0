From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/5] ah6/esp6: set transport header correctly for IPsec tunnel mode.
Date: Tue, 22 Jan 2013 10:06:33 +0100
Message-ID: <1358845596-2066-3-git-send-email-steffen.klassert@secunet.com>
References: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33503 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754210Ab3AVJHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:07:08 -0500
In-Reply-To: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

IPsec tunnel does not set ECN field to CE in inner header when
the ECN field in the outer header is CE, and the ECN field in
the inner header is ECT(0) or ECT(1).

The cause is ipip6_hdr() does not return the correct address of
inner header since skb->transport-header is not the inner header
after esp6_input_done2(), or ah6_input().

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ah6.c  |   11 +++++++++--
 net/ipv6/esp6.c |    5 ++++-
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ecc35b9..3842331 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -472,7 +472,10 @@ static void ah6_input_done(struct crypto_async_request *base, int err)
 	skb->network_header += ah_hlen;
 	memcpy(skb_network_header(skb), work_iph, hdr_len);
 	__skb_pull(skb, ah_hlen + hdr_len);
-	skb_set_transport_header(skb, -hdr_len);
+	if (x->props.mode == XFRM_MODE_TUNNEL)
+		skb_reset_transport_header(skb);
+	else
+		skb_set_transport_header(skb, -hdr_len);
 out:
 	kfree(AH_SKB_CB(skb)->tmp);
 	xfrm_input_resume(skb, err);
@@ -593,9 +596,13 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->network_header += ah_hlen;
 	memcpy(skb_network_header(skb), work_iph, hdr_len);
-	skb->transport_header = skb->network_header;
 	__skb_pull(skb, ah_hlen + hdr_len);
 
+	if (x->props.mode == XFRM_MODE_TUNNEL)
+		skb_reset_transport_header(skb);
+	else
+		skb_set_transport_header(skb, -hdr_len);
+
 	err = nexthdr;
 
 out_free:
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 282f372..40ffd72 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -300,7 +300,10 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 
 	pskb_trim(skb, skb->len - alen - padlen - 2);
 	__skb_pull(skb, hlen);
-	skb_set_transport_header(skb, -hdr_len);
+	if (x->props.mode == XFRM_MODE_TUNNEL)
+		skb_reset_transport_header(skb);
+	else
+		skb_set_transport_header(skb, -hdr_len);
 
 	err = nexthdr[1];
 
-- 
1.7.9.5
