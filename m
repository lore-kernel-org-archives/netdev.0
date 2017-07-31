From: Koichiro Den <den@klaipeden.com>
Subject: [PATCH net 2/2] gue: fix remcsum when GRO on and CHECKSUM_PARTIAL boundary is outer UDP
Date: Tue,  1 Aug 2017 01:05:39 +0900
Message-ID: <20170731160539.6013-1-den@klaipeden.com>
Cc: tom@herbertland.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21407 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752063AbdGaQGu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 12:06:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case that GRO is turned on and the original received packet is
CHECKSUM_PARTIAL, if the outer UDP header is exactly at the last
csum-unnecessary point, which for instance could occur if the packet
comes from another Linux guest on the same Linux host, we have to do
either remcsum_adjust or set up CHECKSUM_PARTIAL again with its
csum_start properly reset considering RCO.

However, since b7fe10e5ebac ("gro: Fix remcsum offload to deal with frags
in GRO") that barrier in such case could be skipped if GRO turned on,
hence we pass over it and the inner L4 validation mistakenly reckons
it as a bad csum.

This patch makes remcsum_offload being reset at the same time of GRO
remcsum cleanup, so as to make it work in such case as before.

Fixes: b7fe10e5ebac ("gro: Fix remcsum offload to deal with frags in GRO")
Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 net/ipv4/fou.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 8e0257d01200..1540db65241a 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -450,6 +450,7 @@ static struct sk_buff **gue_gro_receive(struct sock *sk,
 out:
 	NAPI_GRO_CB(skb)->flush |= flush;
 	skb_gro_remcsum_cleanup(skb, &grc);
+	skb->remcsum_offload = 0;
 
 	return pp;
 }
-- 
2.9.4
