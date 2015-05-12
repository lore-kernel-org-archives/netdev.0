From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 06/15] net: move __skb_tx_hash to dev.c
Date: Tue, 12 May 2015 14:56:12 +0200
Message-ID: <1431435381-7164-7-git-send-email-jiri@resnulli.us>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36799 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932892AbbELM45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:56:57 -0400
Received: by wizk4 with SMTP id k4so152367998wiz.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 05:56:56 -0700 (PDT)
In-Reply-To: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__skb_tx_hash function has no relation to flow_dissect so just move it
to dev.c

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  3 +++
 include/linux/skbuff.h    |  3 ---
 net/core/dev.c            | 28 ++++++++++++++++++++++++++++
 net/core/flow_dissector.c | 28 ----------------------------
 4 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a6d706b..662b55f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2847,6 +2847,9 @@ static inline int netif_set_xps_queue(struct net_device *dev,
 }
 #endif
 
+u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
+		  unsigned int num_tx_queues);
+
 /*
  * Returns a Tx hash for the given packet when dev->real_num_tx_queues is used
  * as a distribution range limit for the returned value.
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 55677e9..bc207d4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3298,9 +3298,6 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 	return skb->queue_mapping != 0;
 }
 
-u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
-		  unsigned int num_tx_queues);
-
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 {
 #ifdef CONFIG_XFRM
diff --git a/net/core/dev.c b/net/core/dev.c
index e5f77c4..3e7838f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2350,6 +2350,34 @@ void netif_device_attach(struct net_device *dev)
 }
 EXPORT_SYMBOL(netif_device_attach);
 
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
+
 static void skb_warn_bad_offload(const struct sk_buff *skb)
 {
 	static const netdev_features_t null_features = 0;
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
-- 
2.4.0
