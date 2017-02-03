From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_needs_check() accepts CHECKSUM_NONE for tx
Date: Fri, 03 Feb 2017 14:29:42 -0800
Message-ID: <1486160982.21871.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35411 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBCW3o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:29:44 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so3013065pge.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 14:29:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

My recent change missed fact that UFO would perform a complete
UDP checksum before segmenting in frags.

In this case skb->ip_summed is set to CHECKSUM_NONE.

We need to add this valid case to skb_needs_check()

Fixes: b2504a5dbef3 ("net: reduce skb_warn_bad_offload() noise")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 727b6fda0e8c6497ee42dc6d3065e326e9192c21..2ba5ef33e83909871fcf69a036062e00f0cf86c7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2637,9 +2637,10 @@ EXPORT_SYMBOL(skb_mac_gso_segment);
 static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
 {
 	if (tx_path)
-		return skb->ip_summed != CHECKSUM_PARTIAL;
-	else
-		return skb->ip_summed == CHECKSUM_NONE;
+		return skb->ip_summed != CHECKSUM_PARTIAL &&
+		       skb->ip_summed != CHECKSUM_NONE;
+
+	return skb->ip_summed == CHECKSUM_NONE;
 }
 
 /**
