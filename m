From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 01/08]: vlan: Don't store VLAN tag in cb
Date: Wed,  9 Jul 2008 14:09:47 +0200 (MEST)
Message-ID: <20080709120946.11669.76704.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58611 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbYGIMJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:48 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: Don't store VLAN tag in cb

Use a real skb member to store the skb to avoid clashes with qdiscs,
which are allowed to use the cb area themselves. As currently only real
devices that consume the skb set the NETIF_F_HW_VLAN_TX flag, no explicit
invalidation is neccessary.

The new member fills a hole on 64 bit, the skb layout changes from:

        __u32                      mark;                 /*   172     4 */
        sk_buff_data_t             transport_header;     /*   176     4 */
        sk_buff_data_t             network_header;       /*   180     4 */
        sk_buff_data_t             mac_header;           /*   184     4 */
        sk_buff_data_t             tail;                 /*   188     4 */
        /* --- cacheline 3 boundary (192 bytes) --- */
        sk_buff_data_t             end;                  /*   192     4 */

        /* XXX 4 bytes hole, try to pack */

to

        __u32                      mark;                 /*   172     4 */
        __u16                      vlan_tci;             /*   176     2 */

        /* XXX 2 bytes hole, try to pack */

        sk_buff_data_t             transport_header;     /*   180     4 */
        sk_buff_data_t             network_header;       /*   184     4 */

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 5188944208232be946dbfa41e4e81cd13a5cc63f
tree c64a83b5852c11c1e970ca8d4955892a210138eb
parent 66f29353205907c92f202b6db8c143c7969cbedf
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 12:38:27 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 12:38:27 +0200

 include/linux/if_vlan.h |   31 +++++++------------------------
 include/linux/skbuff.h  |    3 +++
 net/core/skbuff.c       |    3 +++
 3 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 93f5d9b..9e7b49b 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -105,17 +105,8 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
 }
 
-/* VLAN tx hw acceleration helpers. */
-struct vlan_skb_tx_cookie {
-	u32	magic;
-	u32	vlan_tag;
-};
-
-#define VLAN_TX_COOKIE_MAGIC	0x564c414e	/* "VLAN" in ascii. */
-#define VLAN_TX_SKB_CB(__skb)	((struct vlan_skb_tx_cookie *)&((__skb)->cb[0]))
-#define vlan_tx_tag_present(__skb) \
-	(VLAN_TX_SKB_CB(__skb)->magic == VLAN_TX_COOKIE_MAGIC)
-#define vlan_tx_tag_get(__skb)	(VLAN_TX_SKB_CB(__skb)->vlan_tag)
+#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci)
+#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci)
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
@@ -210,17 +201,12 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
  * @skb: skbuff to tag
  * @vlan_tci: VLAN TCI to insert
  *
- * Puts the VLAN TCI in @skb->cb[] and lets the device do the rest
+ * Puts the VLAN TCI in @skb->vlan_tci and lets the device do the rest
  */
 static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
 						     u16 vlan_tci)
 {
-	struct vlan_skb_tx_cookie *cookie;
-
-	cookie = VLAN_TX_SKB_CB(skb);
-	cookie->magic = VLAN_TX_COOKIE_MAGIC;
-	cookie->vlan_tag = vlan_tci;
-
+	skb->vlan_tci = vlan_tci;
 	return skb;
 }
 
@@ -267,16 +253,13 @@ static inline int __vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
  * @skb: skbuff to query
  * @vlan_tci: buffer to store vlaue
  *
- * Returns error if @skb->cb[] is not set correctly
+ * Returns error if @skb->vlan_tci is not set correctly
  */
 static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
 					 u16 *vlan_tci)
 {
-	struct vlan_skb_tx_cookie *cookie;
-
-	cookie = VLAN_TX_SKB_CB(skb);
-	if (cookie->magic == VLAN_TX_COOKIE_MAGIC) {
-		*vlan_tci = cookie->vlan_tag;
+	if (vlan_tx_tag_present(skb)) {
+		*vlan_tci = skb->vlan_tci;
 		return 0;
 	} else {
 		*vlan_tci = 0;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8f10e3d..7ea44f6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -246,6 +246,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
+ *	@vlan_tci: vlan tag control information
  */
 
 struct sk_buff {
@@ -326,6 +327,8 @@ struct sk_buff {
 
 	__u32			mark;
 
+	__u16			vlan_tci;
+
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7c57156..50a853f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -459,6 +459,8 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->tc_verd		= old->tc_verd;
 #endif
 #endif
+	new->vlan_tci		= old->vlan_tci;
+
 	skb_copy_secmark(new, old);
 }
 
@@ -2286,6 +2288,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		skb_copy_queue_mapping(nskb, skb);
 		nskb->priority = skb->priority;
 		nskb->protocol = skb->protocol;
+		nskb->vlan_tci = skb->vlan_tci;
 		nskb->dst = dst_clone(skb->dst);
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
 		nskb->pkt_type = skb->pkt_type;
