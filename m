From: Shmuel Hen <shmulik.hen@intel.com>
Subject: [PATCH 2/6][8021q][2.4] Export VLAN tag get/set functionality
Date: Thu, 22 Jan 2004 17:56:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401221756.43872.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Enable intermediate network drivers like bonding to get or set a
VLAN tag in an skb without a need to know about how tagging is done
according to a network adapter's capabilities.


diff -Nuarp a/include/linux/if_vlan.h b/include/linux/if_vlan.h
--- a/include/linux/if_vlan.h	Wed Jan 21 16:54:57 2004
+++ b/include/linux/if_vlan.h	Wed Jan 21 16:54:59 2004
@@ -200,6 +200,148 @@ static inline int vlan_hwaccel_receive_s
 {
 	return __vlan_hwaccel_rx(skb, grp, vlan_tag, 1);
 }
+
+/**
+ * __vlan_put_tag - regular VLAN tag inserting
+ * @skb: skbuff to tag
+ * @tag: VLAN tag to insert
+ *
+ * Inserts the VLAN tag into @skb as part of the payload
+ * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
+ * 
+ * Following the skb_unshare() example, in case of error, the calling function
+ * doesn't have to worry about freeing the original skb.
+ */
+static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short tag)
+{
+	struct vlan_ethhdr *veth;
+
+	if (skb_headroom(skb) < VLAN_HLEN) {
+		struct sk_buff *sk_tmp = skb;
+		skb = skb_realloc_headroom(sk_tmp, VLAN_HLEN);
+		kfree_skb(sk_tmp);
+		if (!skb) {
+			printk(KERN_ERR "vlan: failed to realloc headroom\n");
+			return NULL;
+		}
+	} else {
+		skb = skb_unshare(skb, GFP_ATOMIC);
+		if (!skb) {
+			printk(KERN_ERR "vlan: failed to unshare skbuff\n");
+			return NULL;
+		}
+	}
+
+	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
+
+	/* Move the mac addresses to the beginning of the new header. */
+	memmove(skb->data, skb->data + VLAN_HLEN, 2 * VLAN_ETH_ALEN);
+
+	/* first, the ethernet type */
+	veth->h_vlan_proto = __constant_htons(ETH_P_8021Q);
+
+	/* now, the tag */
+	veth->h_vlan_TCI = htons(tag);
+
+	return skb;
+}
+
+/**
+ * __vlan_hwaccel_put_tag - hardware accelerated VLAN inserting
+ * @skb: skbuff to tag
+ * @tag: VLAN tag to insert
+ *
+ * Puts the VLAN tag in @skb->cb[] and lets the device do the rest
+ */
+static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb, unsigned short tag)
+{
+	struct vlan_skb_tx_cookie *cookie;
+
+	cookie = VLAN_TX_SKB_CB(skb);
+	cookie->magic = VLAN_TX_COOKIE_MAGIC;
+	cookie->vlan_tag = tag;
+
+	return skb;
+}
+
+#define HAVE_VLAN_PUT_TAG
+
+/**
+ * vlan_put_tag - inserts VLAN tag according to device features
+ * @skb: skbuff to tag
+ * @tag: VLAN tag to insert
+ *
+ * Assumes skb->dev is the target that will xmit this frame.
+ * Returns a VLAN tagged skb.
+ */
+static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, unsigned short tag)
+{
+	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+		return __vlan_hwaccel_put_tag(skb, tag);
+	} else {
+		return __vlan_put_tag(skb, tag);
+	}
+}
+
+/**
+ * __vlan_get_tag - get the VLAN ID that is part of the payload
+ * @skb: skbuff to query
+ * @tag: buffer to store vlaue
+ * 
+ * Returns error if the skb is not of VLAN type
+ */
+static inline int __vlan_get_tag(struct sk_buff *skb, unsigned short *tag)
+{
+	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb->data;
+
+	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
+		return -EINVAL;
+	}
+
+	*tag = ntohs(veth->h_vlan_TCI);
+
+	return 0;
+}
+
+/**
+ * __vlan_hwaccel_get_tag - get the VLAN ID that is in @skb->cb[]
+ * @skb: skbuff to query
+ * @tag: buffer to store vlaue
+ * 
+ * Returns error if @skb->cb[] is not set correctly
+ */
+static inline int __vlan_hwaccel_get_tag(struct sk_buff *skb, unsigned short *tag)
+{
+	struct vlan_skb_tx_cookie *cookie;
+
+	cookie = VLAN_TX_SKB_CB(skb);
+	if (cookie->magic == VLAN_TX_COOKIE_MAGIC) {
+		*tag = cookie->vlan_tag;
+		return 0;
+	} else {
+		*tag = 0;
+		return -EINVAL;
+	}
+}
+
+#define HAVE_VLAN_GET_TAG
+
+/**
+ * vlan_get_tag - get the VLAN ID from the skb
+ * @skb: skbuff to query
+ * @tag: buffer to store vlaue
+ * 
+ * Returns error if the skb is not VLAN tagged
+ */
+static inline int vlan_get_tag(struct sk_buff *skb, unsigned short *tag)
+{
+	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+		return __vlan_hwaccel_get_tag(skb, tag);
+	} else {
+		return __vlan_get_tag(skb, tag);
+	}
+}
+
 #endif /* __KERNEL__ */
 
 /* VLAN IOCTLs are found in sockios.h */
