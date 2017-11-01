From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] xfrm: Fix GSO for IPsec with GRE tunnel.
Date: Wed, 1 Nov 2017 11:05:03 +0100
Message-ID: <1509530703-12707-4-git-send-email-steffen.klassert@secunet.com>
References: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:60018 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754358AbdKAKFP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:05:15 -0400
In-Reply-To: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We reset the encapsulation field of the skb too early
in xfrm_output. As a result, the GRE GSO handler does
not segment the packets. This leads to a performance
drop down. We fix this by resetting the encapsulation
field right before we do the transformation, when
the inner headers become invalid.

Fixes: f1bd7d659ef0 ("xfrm: Add encapsulation header offsets while SKB is not encrypted")
Reported-by: Vicente De Luca <vdeluca@zendesk.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_output.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 31a2e6d..73ad8c8 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -105,6 +105,9 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		if (xfrm_offload(skb)) {
 			x->type_offload->encap(x, skb);
 		} else {
+			/* Inner headers are invalid now. */
+			skb->encapsulation = 0;
+
 			err = x->type->output(x, skb);
 			if (err == -EINPROGRESS)
 				goto out;
@@ -208,7 +211,6 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 	int err;
 
 	secpath_reset(skb);
-	skb->encapsulation = 0;
 
 	if (xfrm_dev_offload_ok(skb, x)) {
 		struct sec_path *sp;
-- 
2.7.4
