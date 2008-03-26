From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code (v2).
Date: Wed, 26 Mar 2008 12:25:40 +0300
Message-ID: <47EA1694.1080208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Denis Lunev <den@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51850 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849AbYCZJZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 05:25:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8b7817f3a959ed99d7443afc12f78a7e1fcc2063 ([IPSEC]: Add ICMP host
relookup support) introduced some dst leaks on error paths: the rt
pointer can be forgotten to be put. Fix it bu going to a proper label.

Found after net namespace's lo refused to unregister :) Many thanks to 
Den for valuable help during debugging.

Herbert pointed out, that xfrm_lookup() will put the rtable in case
of error itself, so the first goto fix is redundant.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Denis V. Lunev <den@openvz.org>

---

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index a13c074..a944e80 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -591,7 +591,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		}
 
 		if (xfrm_decode_session_reverse(skb_in, &fl, AF_INET))
-			goto out_unlock;
+			goto ende;
 
 		if (inet_addr_type(net, fl.fl4_src) == RTN_LOCAL)
 			err = __ip_route_output_key(net, &rt2, &fl);
@@ -601,7 +601,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 
 			fl2.fl4_dst = fl.fl4_src;
 			if (ip_route_output_key(net, &rt2, &fl2))
-				goto out_unlock;
+				goto ende;
 
 			/* Ugh! */
 			odst = skb_in->dst;
@@ -614,7 +614,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		}
 
 		if (err)
-			goto out_unlock;
+			goto ende;
 
 		err = xfrm_lookup((struct dst_entry **)&rt2, &fl, NULL,
 				  XFRM_LOOKUP_ICMP);
