From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 06/15] net: move __skb_tx_hash to skbuff.c
Date: Fri, 24 Apr 2015 17:51:32 +0200
Message-ID: <1429890701-30052-7-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:32843 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031241AbbDXPvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:51:55 -0400
Received: by wgin8 with SMTP id n8so55192452wgi.0
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:51:54 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__skb_tx_hash function has no relation to flow_dissect so just muve it
to skbuff.c (it is declared in skbuff.h)

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/flow_dissector.c | 28 ----------------------------
 net/core/skbuff.c         | 28 ++++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 6a02b26..302a806 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -322,34 +322,6 @@ void __skb_get_hash(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
-/*
- * Returns a Tx hash based on the given packet descriptor a Tx queues' number
- * to be used as a distribution range.
- */
-u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
-		  unsigned int num_tx_queues)
-{
-	u32 hash;
-	u16 qoffset = 0;
-	u16 qcount = num_tx_queues;
-
-	if (skb_rx_queue_recorded(skb)) {
-		hash = skb_get_rx_queue(skb);
-		while (unlikely(hash >= num_tx_queues))
-			hash -= num_tx_queues;
-		return hash;
-	}
-
-	if (dev->num_tc) {
-		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
-		qoffset = dev->tc_to_txq[tc].offset;
-		qcount = dev->tc_to_txq[tc].count;
-	}
-
-	return (u16) reciprocal_scale(skb_get_hash(skb), qcount) + qoffset;
-}
-EXPORT_SYMBOL(__skb_tx_hash);
-
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d1967da..0e7053b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4410,3 +4410,31 @@ failure:
 	return NULL;
 }
 EXPORT_SYMBOL(alloc_skb_with_frags);
+
+/*
+ * Returns a Tx hash based on the given packet descriptor a Tx queues' number
+ * to be used as a distribution range.
+ */
+u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
+		  unsigned int num_tx_queues)
+{
+	u32 hash;
+	u16 qoffset = 0;
+	u16 qcount = num_tx_queues;
+
+	if (skb_rx_queue_recorded(skb)) {
+		hash = skb_get_rx_queue(skb);
+		while (unlikely(hash >= num_tx_queues))
+			hash -= num_tx_queues;
+		return hash;
+	}
+
+	if (dev->num_tc) {
+		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
+		qoffset = dev->tc_to_txq[tc].offset;
+		qcount = dev->tc_to_txq[tc].count;
+	}
+
+	return (u16) reciprocal_scale(skb_get_hash(skb), qcount) + qoffset;
+}
+EXPORT_SYMBOL(__skb_tx_hash);
-- 
1.9.3
