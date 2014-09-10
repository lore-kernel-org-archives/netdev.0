From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next 2/2] mac80211: Resolve sk_refcnt/sk_wmem_alloc
 issue in wifi ack path
Date: Wed, 10 Sep 2014 18:05:42 -0400
Message-ID: <20140910220536.23225.92956.stgit@ahduyck-bv4.jf.intel.com>
References: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	eric.dumazet@gmail.com, linville@tuxdriver.com
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50537 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126AbaIJWOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 18:14:19 -0400
In-Reply-To: <20140910215837.23225.39149.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a possible issue with the use, or lack thereof of sk_refcnt and
sk_wmem_alloc in the wifi ack status functionality.

Specifically if a socket were to request acknowledgements, and the socket
were to have sk_refcnt drop to 0 resulting in it waiting on sk_wmem_alloc
to reach 0 it would be possible to have sock_queue_err_skb orphan the last
buffer, resulting in __sk_free being called on the socket.  After this the
buffer is enqueued on sk_error_queue, however the queue has already been
flushed resulting in at least a memory leak, if not a data corruption.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/skbuff.c |    5 +++++
 net/mac80211/tx.c |   15 ++++-----------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c9da77a..c8259ac 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3628,9 +3628,14 @@ void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TXSTATUS;
 
+	/* take a reference to prevent skb_orphan() from freeing the socket */
+	sock_hold(sk);
+
 	err = sock_queue_err_skb(sk, skb);
 	if (err)
 		kfree_skb(skb);
+
+	sock_put(sk);
 }
 EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 925c39f..cf71414 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2072,30 +2072,23 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 
 	if (unlikely(!multicast && skb->sk &&
 		     skb_shinfo(skb)->tx_flags & SKBTX_WIFI_STATUS)) {
-		struct sk_buff *orig_skb = skb;
+		struct sk_buff *ack_skb = skb_clone_sk(skb);
 
-		skb = skb_clone(skb, GFP_ATOMIC);
-		if (skb) {
+		if (ack_skb) {
 			unsigned long flags;
 			int id;
 
 			spin_lock_irqsave(&local->ack_status_lock, flags);
-			id = idr_alloc(&local->ack_status_frames, orig_skb,
+			id = idr_alloc(&local->ack_status_frames, ack_skb,
 				       1, 0x10000, GFP_ATOMIC);
 			spin_unlock_irqrestore(&local->ack_status_lock, flags);
 
 			if (id >= 0) {
 				info_id = id;
 				info_flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
-			} else if (skb_shared(skb)) {
-				kfree_skb(orig_skb);
 			} else {
-				kfree_skb(skb);
-				skb = orig_skb;
+				kfree_skb(ack_skb);
 			}
-		} else {
-			/* couldn't clone -- lose tx status ... */
-			skb = orig_skb;
 		}
 	}
 
