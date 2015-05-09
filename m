From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/15] net: move __skb_tx_hash to skbuff.c
Date: Sat,  9 May 2015 15:10:29 +0200
Message-ID: <1431177038-11555-7-git-send-email-jiri@resnulli.us>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36131 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbbEINLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:11:06 -0400
Received: by wizk4 with SMTP id k4so58416755wiz.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:11:05 -0700 (PDT)
In-Reply-To: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
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
index 0d9bc3a..07ca11d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -371,34 +371,6 @@ __u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb)
 }
 EXPORT_SYMBOL(skb_get_hash_perturb);
 
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
index b9eb90b..76d0aad 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4515,3 +4515,31 @@ failure:
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
