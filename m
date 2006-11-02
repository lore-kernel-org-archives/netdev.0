From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 5/6] IPv6: Improve IPv6 tunnel error reporting
Date: Thu, 02 Nov 2006 13:37:29 +0200
Message-ID: <4549D879.6090402@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060500060901010007070004"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:57993 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1751254AbWKBLhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 06:37:37 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060500060901010007070004
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit



--------------060500060901010007070004
Content-Type: text/plain;
 name="0005-IPv6-Improve-IPv6-tunnel-error-reporting.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0005-IPv6-Improve-IPv6-tunnel-error-reporting.txt"

>From 6b9b468f1cf3f2897fbcda389e8c2514a69c4943 Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Thu, 2 Nov 2006 12:49:47 +0200
Subject: [PATCH 5/6] IPv6: Improve IPv6 tunnel error reporting

Log an error if the remote tunnel endpoint is unable to handle
tunneled packets.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ip6_tunnel.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a97eb52..4f64ed7 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -424,12 +424,9 @@ ip6ip6_err(struct sk_buff *skb, struct i
 		}
 		break;
 	case ICMPV6_PARAMPROB:
-		/* ignore if parameter problem not caused by a tunnel
-		   encapsulation limit sub-option */
-		if (code != ICMPV6_HDR_FIELD) {
-			break;
-		}
-		teli = parse_tlv_tnl_enc_lim(skb, skb->data);
+		teli = 0;
+		if (code == ICMPV6_HDR_FIELD)
+			teli = parse_tlv_tnl_enc_lim(skb, skb->data);
 
 		if (teli && teli == ntohl(info) - 2) {
 			tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->data[teli];
@@ -441,6 +438,10 @@ ip6ip6_err(struct sk_buff *skb, struct i
 					       "tunnel!\n", t->parms.name);
 				rel_msg = 1;
 			}
+		} else if (net_ratelimit()) {
+			printk(KERN_WARNING
+			       "%s: Recipient unable to parse tunneled "
+			       "packet!\n ", t->parms.name);
 		}
 		break;
 	case ICMPV6_PKT_TOOBIG:
-- 
1.4.3.2


--------------060500060901010007070004--
