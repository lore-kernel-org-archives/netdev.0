From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netfilter: nf_nat_sip: c= is optional for session
Date: Mon, 21 Jul 2008 21:25:13 +0800
Message-ID: <20080721132513.GA11162@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39427 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753488AbYGUNZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 09:25:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick:

My phone stopped working after my router was upgraded to 2.6.26.
This patch makes it work again.

netfilter: nf_nat_sip: c= is optional for session

According to RFC2327, the connection information is optional
in the session description since it can be specified in the
media description instead.

My provider does exactly that and does not provide any connection
information in the session description.  As a result the new
kernel drops all invite responses.

This patch makes it optional as documented.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 4334d5c..1454432 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -318,11 +318,11 @@ static int mangle_content_len(struct sk_buff *skb,
 			     buffer, buflen);
 }
 
-static unsigned mangle_sdp_packet(struct sk_buff *skb, const char **dptr,
-				  unsigned int dataoff, unsigned int *datalen,
-				  enum sdp_header_types type,
-				  enum sdp_header_types term,
-				  char *buffer, int buflen)
+static int mangle_sdp_packet(struct sk_buff *skb, const char **dptr,
+			     unsigned int dataoff, unsigned int *datalen,
+			     enum sdp_header_types type,
+			     enum sdp_header_types term,
+			     char *buffer, int buflen)
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
@@ -330,9 +330,9 @@ static unsigned mangle_sdp_packet(struct sk_buff *skb, const char **dptr,
 
 	if (ct_sip_get_sdp_header(ct, *dptr, dataoff, *datalen, type, term,
 				  &matchoff, &matchlen) <= 0)
-		return 0;
+		return -ENOENT;
 	return mangle_packet(skb, dptr, datalen, matchoff, matchlen,
-			     buffer, buflen);
+			     buffer, buflen) ? 0 : -EINVAL;
 }
 
 static unsigned int ip_nat_sdp_addr(struct sk_buff *skb, const char **dptr,
@@ -346,8 +346,8 @@ static unsigned int ip_nat_sdp_addr(struct sk_buff *skb, const char **dptr,
 	unsigned int buflen;
 
 	buflen = sprintf(buffer, NIPQUAD_FMT, NIPQUAD(addr->ip));
-	if (!mangle_sdp_packet(skb, dptr, dataoff, datalen, type, term,
-			       buffer, buflen))
+	if (mangle_sdp_packet(skb, dptr, dataoff, datalen, type, term,
+			      buffer, buflen))
 		return 0;
 
 	return mangle_content_len(skb, dptr, datalen);
@@ -381,15 +381,27 @@ static unsigned int ip_nat_sdp_session(struct sk_buff *skb, const char **dptr,
 
 	/* Mangle session description owner and contact addresses */
 	buflen = sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(addr->ip));
-	if (!mangle_sdp_packet(skb, dptr, dataoff, datalen,
+	if (mangle_sdp_packet(skb, dptr, dataoff, datalen,
 			       SDP_HDR_OWNER_IP4, SDP_HDR_MEDIA,
 			       buffer, buflen))
 		return 0;
 
-	if (!mangle_sdp_packet(skb, dptr, dataoff, datalen,
-			       SDP_HDR_CONNECTION_IP4, SDP_HDR_MEDIA,
-			       buffer, buflen))
+	switch (mangle_sdp_packet(skb, dptr, dataoff, datalen,
+				  SDP_HDR_CONNECTION_IP4, SDP_HDR_MEDIA,
+				  buffer, buflen)) {
+	case 0:
+	/*
+	 * RFC 2327:
+	 *
+	 * Session description
+	 *
+	 * c=* (connection information - not required if included in all media)
+	 */
+	case -ENOENT:
+		break;
+	default:
 		return 0;
+	}
 
 	return mangle_content_len(skb, dptr, datalen);
 }
