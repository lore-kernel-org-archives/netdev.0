From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: Force a dst refcount before entering the xfrm
 type handlers
Date: Wed, 16 Mar 2011 08:08:28 +0100
Message-ID: <20110316070828.GQ31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50330 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710Ab1CPHIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 03:08:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Crypto requests might return asynchronous. In this case we leave
the rcu protected region, so force a refcount on the skb's
destination entry before we enter the xfrm type input/output
handlers.

This fixes a crash when a route is deleted whilst sending IPsec
data that is transformed by an asynchronous algorithm.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c  |    2 ++
 net/xfrm/xfrm_output.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 872065c..341cd11 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -190,6 +190,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		XFRM_SKB_CB(skb)->seq.input.low = seq;
 		XFRM_SKB_CB(skb)->seq.input.hi = seq_hi;
 
+		skb_dst_force(skb);
+
 		nexthdr = x->type->input(x, skb);
 
 		if (nexthdr == -EINPROGRESS)
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 1aba03f..8f3f0ee 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -78,6 +78,8 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		spin_unlock_bh(&x->lock);
 
+		skb_dst_force(skb);
+
 		err = x->type->output(x, skb);
 		if (err == -EINPROGRESS)
 			goto out_exit;
-- 
1.7.0.4

