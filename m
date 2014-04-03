From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net-gro: reset skb->truesize in napi_reuse_skb()
Date: Thu, 03 Apr 2014 09:28:10 -0700
Message-ID: <1396542490.12330.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:52381 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbaDCQ2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 12:28:11 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so2108294pbc.27
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 09:28:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Recycling skb always had been very tough...

This time it appears GRO layer can accumulate skb->truesize
adjustments made by drivers when they attach a fragment to skb.

skb_gro_receive() can only subtract from skb->truesize the used part
of a fragment.

I spotted this problem seeing TcpExtPruneCalled and
TcpExtTCPRcvCollapsed that were unexpected with a recent kernel, where
TCP receive window should be sized properly to accept traffic coming
from a driver not overshooting skb->truesize.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 757063420ce0..8770984e1ddc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4043,6 +4043,7 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 	skb->vlan_tci = 0;
 	skb->dev = napi->dev;
 	skb->skb_iif = 0;
+	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
 
 	napi->skb = skb;
 }
