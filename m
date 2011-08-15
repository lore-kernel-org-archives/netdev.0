From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] ipv4: one more case for non-local saddr in ICMP
Date: Mon, 15 Aug 2011 19:21:23 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53288 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657Ab1HOQQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 12:16:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	May be there is one more case that we can avoid using
non-local source for ICMP errors: xfrm_lookup, num_xfrms = 0 when
reverse "Flow passes untransformed". Avoid using the input route
if xfrm_lookup returns same dst.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	In fact, should we use local IP in all cases when
sending ICMP? I'm asking it for the following case:

	Large packet is forwarded but is rejected with ICMP FRAG
NEEDED. We usually send ICMP with local saddr instead of the
original non-local destination. What is the role of
this reverse check? May be after xfrm_decode_session_reverse
we should use 'fl4_dec.saddr = fl4->saddr;' so that xfrm_lookup
works with ICMP from local IP? What is right thing to do here?
I don't see code that looks in the embedded header...

--- net-next/net/ipv4/icmp.c	2011-08-15 18:42:21.289899686 +0300
+++ linux/net/ipv4/icmp.c	2011-08-15 18:38:25.816244111 +0300
@@ -379,7 +379,7 @@ static struct rtable *icmp_route_lookup(
 					int type, int code,
 					struct icmp_bxm *param)
 {
-	struct rtable *rt, *rt2;
+	struct rtable *rt, *rt2, *rt3;
 	struct flowi4 fl4_dec;
 	int err;
 
@@ -440,13 +440,18 @@ static struct rtable *icmp_route_lookup(
 	if (err)
 		goto relookup_failed;
 
+	rt3 = rt2;
 	rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst,
 					    flowi4_to_flowi(&fl4_dec), NULL,
 					    XFRM_LOOKUP_ICMP);
 	if (!IS_ERR(rt2)) {
-		dst_release(&rt->dst);
-		memcpy(fl4, &fl4_dec, sizeof(*fl4));
-		rt = rt2;
+		if (rt2 == rt3 && rt) {
+			dst_release(&rt2->dst);
+		} else {
+			dst_release(&rt->dst);
+			memcpy(fl4, &fl4_dec, sizeof(*fl4));
+			rt = rt2;
+		}
 	} else if (PTR_ERR(rt2) == -EPERM) {
 		if (rt)
 			dst_release(&rt->dst);
