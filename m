From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: [net-next-2.6 PATCH] Preserve queue mapping with bonding and VLAN devices
Date: Tue, 23 Feb 2010 18:17:19 +0300
Message-ID: <33081266938239@webmail48.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward13.mail.yandex.net ([95.108.130.120]:37013 "EHLO
	forward13.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab0BWPRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 10:17:21 -0500
Received: from webmail48.yandex.ru (webmail48.yandex.ru [77.88.46.31])
	by forward13.mail.yandex.net (Yandex) with ESMTP id E26D9A785CA
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 18:17:19 +0300 (MSK)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by webmail48.yandex.ru (Yandex) with ESMTP id ADAD8900002
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 18:17:19 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Must be applied with "[net-next-2.6 PATCH] Multiqueue support for bonding devices"

Forwarded packet goes more that once throught dev_queue_xmit() when
using bonding or 802.1q VLAN devices, so we've lost rx-tx queue mapping
index for real devices. This is because initial queue index value (as it recorded
by skb_record_tx_queue()) is overwritten by skb_set_queue_mapping(). We
need to store it somewhere else.

Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru>

---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ba0f8e3..cbc489d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -375,7 +375,8 @@ struct sk_buff {
 #endif

        kmemcheck_bitfield_begin(flags2);
-       __u16                   queue_mapping:16;
+       __u16                   queue_mapping:8,
+                               rx_queue_index:8;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
        __u8                    ndisc_nodetype:2;
 #endif
@@ -2011,7 +2012,7 @@ static inline void skb_init_secmark(struct sk_buff *skb)
 { }
 #endif

-static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
+static inline void skb_set_queue_mapping(struct sk_buff *skb, u8 queue_mapping)
 {
        skb->queue_mapping = queue_mapping;
 }
@@ -2026,22 +2027,27 @@ static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_bu
        to->queue_mapping = from->queue_mapping;
 }

-static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_queue)
+static inline void skb_copy_rx_queue_index(struct sk_buff *to, const struct sk_buff *from)
 {
-       skb->queue_mapping = rx_queue + 1;
+       to->rx_queue_index = from->rx_queue_index;
+}
+
+static inline void skb_record_rx_queue(struct sk_buff *skb, u8 rx_queue)
+{
+       skb->rx_queue_index = rx_queue + 1;
 }

 static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
 {
-       return skb->queue_mapping - 1;
+       return skb->rx_queue_index - 1;
 }

 static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 {
-       return (skb->queue_mapping != 0);
+       return (skb->rx_queue_index != 0);
 }

-extern u16 skb_tx_hash(const struct net_device *dev,
+extern u8 skb_tx_hash(const struct net_device *dev,
                       const struct sk_buff *skb);

 #ifdef CONFIG_XFRM
diff --git a/net/core/dev.c b/net/core/dev.c
index 1968980..0756b79 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1911,7 +1911,7 @@ out_kfree_skb:

 static u32 skb_tx_hashrnd;

-u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
+u8 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
        u32 hash;

@@ -1929,7 +1929,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)

        hash = jhash_1word(hash, skb_tx_hashrnd);

-       return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
+       return (u8) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
 EXPORT_SYMBOL(skb_tx_hash);

@@ -1950,7 +1950,7 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
                                        struct sk_buff *skb)
 {
-       u16 queue_index;
+       u8 queue_index;
        struct sock *sk = skb->sk;

        if (sk_tx_queue_recorded(sk)) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 93c4e06..f5ac9ee 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -543,6 +543,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
        new->pkt_type           = old->pkt_type;
        new->ip_summed          = old->ip_summed;
        skb_copy_queue_mapping(new, old);
+       skb_copy_rx_queue_index(new, old);
        new->priority           = old->priority;
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
        new->ipvs_property      = old->ipvs_property;
---

-- 
wbr, Oleg.
