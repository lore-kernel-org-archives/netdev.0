From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: dsa: tag_brcm: Support extracting tags from HW
Date: Wed, 29 Jul 2015 15:32:39 -0700
Message-ID: <1438209160-6898-3-git-send-email-f.fainelli@gmail.com>
References: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33320 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbbG2WfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:35:25 -0400
In-Reply-To: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case an adapter advertises NETIF_F_HW_SWITCH_RX_TAG, proceed with
extracting the 4-bytes Broadcom tag directly from skb->cb[] and utilize
that instead of copying and memmoving() data around.

To establish a contract between the Ethernet MAC advertisign
NETIF_F_HW_SWITCH_RX_TAG and the Broadcom tag DSA parsing code,
introduce a helper function to copy such a tag into skb->cb[] at a
pre-defined offset which is checked against other parts of the kernel we
compete with: NAPI GRO cb.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h | 13 +++++++++++++
 include/net/dsa.h         |  5 +++++
 net/dsa/tag_brcm.c        | 38 +++++++++++++++++++++++---------------
 3 files changed, 41 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 607b5f41f46f..02790c6acdb8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2004,6 +2004,19 @@ struct napi_gro_cb {
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
 
+/* We compete with napi_gro_cb when an Ethernet adapter wants to put a 4-bytes
+ * Broadcom tag into skb->cb since this will typically be done before the call
+ * to napi_gro_receive, so assert a build time that we have enough room to make
+ * this possible
+ */
+#define DSA_BRCM_TAG_OFF	(sizeof(((struct sk_buff *)0)->cb) - BRCM_TAG_LEN)
+
+static inline void dsa_copy_brcm_tag(struct sk_buff *skb, const void *tag)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) - sizeof(struct napi_gro_cb) < BRCM_TAG_LEN);
+	memcpy(&skb->cb[DSA_BRCM_TAG_OFF], tag, BRCM_TAG_LEN);
+}
+
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
 	struct net_device	*dev;	/* NULL is wildcarded here	     */
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63ba8f73..d8bf698d5189 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -31,6 +31,11 @@ enum dsa_tag_protocol {
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
 
+/* This tag length is 4 bytes, older ones were 6 bytes, we do not
+ * handle them
+ */
+#define BRCM_TAG_LEN	4
+
 struct dsa_chip_data {
 	/*
 	 * How to access the switch configuration registers.
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 83d3572cdb20..6c006524540f 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -14,11 +14,6 @@
 #include <linux/slab.h>
 #include "dsa_priv.h"
 
-/* This tag length is 4 bytes, older ones were 6 bytes, we do not
- * handle them
- */
-#define BRCM_TAG_LEN	4
-
 /* Tag is constructed and desconstructed using byte by byte access
  * because the tag is placed after the MAC Source Address, which does
  * not make it 4-bytes aligned, so this might cause unaligned accesses
@@ -105,6 +100,7 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
+	bool hw_accel = false;
 	int source_port;
 	u8 *brcm_tag;
 
@@ -117,11 +113,17 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (skb == NULL)
 		goto out;
 
-	if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
-		goto out_drop;
+	/* Verify if the underlying device supports automatic tag extraction */
+	hw_accel = !!(orig_dev->features & NETIF_F_HW_SWITCH_TAG_RX);
+	if (hw_accel) {
+		brcm_tag = (u8 *)&skb->cb[DSA_BRCM_TAG_OFF];
+	} else {
+		if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
+			goto out_drop;
 
-	/* skb->data points to the EtherType, the tag is right before it */
-	brcm_tag = skb->data - 2;
+		/* skb->data points to the EtherType, the tag is right before it */
+		brcm_tag = skb->data - 2;
+	}
 
 	/* The opcode should never be different than 0b000 */
 	if (unlikely((brcm_tag[0] >> BRCM_OPCODE_SHIFT) & BRCM_OPCODE_MASK))
@@ -139,14 +141,20 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
 		goto out_drop;
 
-	/* Remove Broadcom tag and update checksum */
-	skb_pull_rcsum(skb, BRCM_TAG_LEN);
+	if (!hw_accel) {
+		/* Remove Broadcom tag and update checksum */
+		skb_pull_rcsum(skb, BRCM_TAG_LEN);
 
-	/* Move the Ethernet DA and SA */
-	memmove(skb->data - ETH_HLEN,
-		skb->data - ETH_HLEN - BRCM_TAG_LEN,
-		2 * ETH_ALEN);
+		/* Move the Ethernet DA and SA */
+		memmove(skb->data - ETH_HLEN,
+			skb->data - ETH_HLEN - BRCM_TAG_LEN,
+			2 * ETH_ALEN);
 
+	}
+
+	/* With or without hardware acceleration, the initial eth_type_trans
+	 * will have pulled the SKB by ETH_HLEN, reset that here
+	 */
 	skb_push(skb, ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
 	skb->dev = ds->ports[source_port];
-- 
2.1.0
