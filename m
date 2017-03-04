From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 1/2] net: fix socket refcounting in skb_complete_wifi_ack()
Date: Fri,  3 Mar 2017 21:01:02 -0800
Message-ID: <20170304050103.12226-2-edumazet@google.com>
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
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33403 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751820AbdCDFBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 00:01:30 -0500
Received: by mail-pf0-f176.google.com with SMTP id w189so39626278pfb.0
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 21:01:29 -0800 (PST)
In-Reply-To: <20170304050103.12226-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX skbs do not necessarily hold a reference on skb->sk->sk_refcnt
By the time TX completion happens, sk_refcnt might be already 0.

sock_hold()/sock_put() would then corrupt critical state, like
sk_wmem_alloc.

Fixes: bf7fa551e0ce ("mac80211: Resolve sk_refcnt/sk_wmem_alloc issue in wifi ack path")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f3557958e9bf147631a90b51fef0630920acd97b..e2f37a560ec43ccf60a71f190423bd265eccf594 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3893,7 +3893,7 @@ void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
 {
 	struct sock *sk = skb->sk;
 	struct sock_exterr_skb *serr;
-	int err;
+	int err = 1;
 
 	skb->wifi_acked_valid = 1;
 	skb->wifi_acked = acked;
@@ -3903,14 +3903,15 @@ void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TXSTATUS;
 
-	/* take a reference to prevent skb_orphan() from freeing the socket */
-	sock_hold(sk);
-
-	err = sock_queue_err_skb(sk, skb);
+	/* Take a reference to prevent skb_orphan() from freeing the socket,
+	 * but only if the socket refcount is not zero.
+	 */
+	if (likely(atomic_inc_not_zero(&sk->sk_refcnt))) {
+		err = sock_queue_err_skb(sk, skb);
+		sock_put(sk);
+	}
 	if (err)
 		kfree_skb(skb);
-
-	sock_put(sk);
 }
 EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
 
-- 
2.12.0.rc1.440.g5b76565f74-goog
