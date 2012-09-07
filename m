From: Chema Gonzalez <chema@google.com>
Subject: [PATCH] net: small bug on rxhash calculation
Date: Fri,  7 Sep 2012 16:40:50 -0700
Message-ID: <1347061251-2019-1-git-send-email-chema@google.com>
References: <20120907.125748.25526531079163699.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chema@berkeley.edu>,
	Chema Gonzalez <chema@google.com>
To: David Miller <davem@davemloft.net>, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f202.google.com ([209.85.212.202]:59013 "EHLO
	mail-wi0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab2IGXk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 19:40:58 -0400
Received: by wibhr14 with SMTP id hr14so2093wib.1
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 16:40:57 -0700 (PDT)
In-Reply-To: <20120907.125748.25526531079163699.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current rxhash calculation function, while the
sorting of the ports/addrs is coherent (you get the
same rxhash for packets sharing the same 4-tuple, in
both directions), ports and addrs are sorted
independently. This implies packets from a connection
between the same addresses but crossed ports hash to
the same rxhash.

For example, traffic between A=S:l and B=L:s is hashed
(in both directions) from {L, S, {s, l}}. The same
rxhash is obtained for packets between C=S:s and D=L:l.

This patch ensures that you either swap both addrs and ports,
or you swap none. Traffic between A and B, and traffic
between C and D, get their rxhash from different sources
({L, S, {l, s}} for A<->B, and {L, S, {s, l}} for C<->D)

The patch is co-written with Eric Dumazet <edumazet@google.com>

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 net/core/dev.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b1e6d63..dcc673d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2655,15 +2655,16 @@ void __skb_get_rxhash(struct sk_buff *skb)
 	if (!skb_flow_dissect(skb, &keys))
 		return;
 
-	if (keys.ports) {
-		if ((__force u16)keys.port16[1] < (__force u16)keys.port16[0])
-			swap(keys.port16[0], keys.port16[1]);
+	if (keys.ports)
 		skb->l4_rxhash = 1;
-	}
 
 	/* get a consistent hash (same value on both flow directions) */
-	if ((__force u32)keys.dst < (__force u32)keys.src)
+	if (((__force u32)keys.dst < (__force u32)keys.src) ||
+	    (((__force u32)keys.dst == (__force u32)keys.src) &&
+	     ((__force u16)keys.port16[1] < (__force u16)keys.port16[0]))) {
 		swap(keys.dst, keys.src);
+		swap(keys.port16[0], keys.port16[1]);
+	}
 
 	hash = jhash_3words((__force u32)keys.dst,
 			    (__force u32)keys.src,
-- 
1.7.7.3
