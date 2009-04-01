From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] net: allow multiple dev per napi with GRO
Date: Wed, 1 Apr 2009 14:20:20 -0700
Message-ID: <20090401142020.395f51bb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41605 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934683AbZDAVkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 17:40:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO assumes that there is a one-to-one relationship between NAPI
structure and network device. Some devices like sky2 share multiple
devices on a single interrupt so only have one NAPI handler. Rather than
split GRO from NAPI, just have GRO assume if device changes that
it is a different flow.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2009-04-01 12:02:12.381316147 -0700
+++ b/net/core/dev.c	2009-04-01 12:07:29.718192280 -0700
@@ -2472,8 +2472,9 @@ static int __napi_gro_receive(struct nap
 		return GRO_NORMAL;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow = !compare_ether_header(
-			skb_mac_header(p), skb_gro_mac_header(skb));
+		NAPI_GRO_CB(p)->same_flow = (p->dev == skb->dev)
+			&& !compare_ether_header(skb_mac_header(p),
+						 skb_gro_mac_header(skb));
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
