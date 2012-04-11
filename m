From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: allow pskb_expand_head() to get maximum tailroom
Date: Wed, 11 Apr 2012 08:08:39 +0200
Message-ID: <1334124519.5300.2246.camel@edumazet-glaptop>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:39270 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab2DKGIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 02:08:45 -0400
In-Reply-To: <20120411052733.GA17352@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Merlin reported many order-1 allocations failures in TX path on its
wireless setup, that dont make any sense with MTU=1500 network, and non
SG capable hardware.

Turns out part of the problem comes from pskb_expand_head() not using
ksize() to get exact head size given by kmalloc(). Doing the same thing
than __alloc_skb() allows more tailroom in skb and can prevent future
reallocations.

As a bonus, struct skb_shared_info becomes cache line aligned.

Reported-by: Marc MERLIN <marc@merlins.org>
Tested-by: Marc MERLIN <marc@merlins.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index baf8d28..e598400 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -952,9 +952,11 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		goto adjust_others;
 	}
 
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	data = kmalloc(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
+		       gfp_mask);
 	if (!data)
 		goto nodata;
+	size = SKB_WITH_OVERHEAD(ksize(data));
 
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void.
