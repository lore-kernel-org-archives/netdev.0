From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/2] net: fix socket refcounting in skb_complete_tx_timestamp()
Date: Fri,  3 Mar 2017 21:01:03 -0800
Message-ID: <20170304050103.12226-3-edumazet@google.com>
References: <20170304050103.12226-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34001 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdCDFMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 00:12:41 -0500
Received: by mail-pf0-f171.google.com with SMTP id v190so2920636pfb.1
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 21:11:11 -0800 (PST)
In-Reply-To: <20170304050103.12226-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX skbs do not necessarily hold a reference on skb->sk->sk_refcnt
By the time TX completion happens, sk_refcnt might be already 0.

sock_hold()/sock_put() would then corrupt critical state, like
sk_wmem_alloc and lead to leaks or use after free.

Fixes: 62bccb8cdb69 ("net-timestamp: Make the clone operation stand-alone from phy timestamping")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e2f37a560ec43ccf60a71f190423bd265eccf594..cd4ba8c6b6091651403cf74de8c60ccf69aa3e7b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3828,13 +3828,14 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	if (!skb_may_tx_timestamp(sk, false))
 		return;
 
-	/* take a reference to prevent skb_orphan() from freeing the socket */
-	sock_hold(sk);
-
-	*skb_hwtstamps(skb) = *hwtstamps;
-	__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
-
-	sock_put(sk);
+	/* Take a reference to prevent skb_orphan() from freeing the socket,
+	 * but only if the socket refcount is not zero.
+	 */
+	if (likely(atomic_inc_not_zero(&sk->sk_refcnt))) {
+		*skb_hwtstamps(skb) = *hwtstamps;
+		__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
+		sock_put(sk);
+	}
 }
 EXPORT_SYMBOL_GPL(skb_complete_tx_timestamp);
 
-- 
2.12.0.rc1.440.g5b76565f74-goog
