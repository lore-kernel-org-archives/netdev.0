From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/6] [6LoWPAN] add fragmentation support
Date: Thu, 10 Nov 2011 20:38:38 +0300
Message-ID: <1320946718-7404-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111110173258.GA8056@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111110173258.GA8056-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for frame fragmentation.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/ieee802154.h |    6 +
 net/ieee802154/6lowpan.c |  260 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ieee802154/6lowpan.h |   18 +++
 3 files changed, 280 insertions(+), 4 deletions(-)

diff --git a/include/net/ieee802154.h b/include/net/ieee802154.h
index d52685d..ee59f8b 100644
--- a/include/net/ieee802154.h
+++ b/include/net/ieee802154.h
@@ -21,11 +21,14 @@
  * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
  * Maxim Osipov <maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
  * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
  */
 
 #ifndef NET_IEEE802154_H
 #define NET_IEEE802154_H
 
+#define IEEE802154_MTU			127
+
 #define IEEE802154_FC_TYPE_BEACON	0x0	/* Frame is beacon */
 #define	IEEE802154_FC_TYPE_DATA		0x1	/* Frame is data */
 #define IEEE802154_FC_TYPE_ACK		0x2	/* Frame is acknowledgment */
@@ -56,6 +59,9 @@
 	(((x) & IEEE802154_FC_DAMODE_MASK) >> IEEE802154_FC_DAMODE_SHIFT)
 
 
+/* MAC footer size */
+#define IEEE802154_MFR_SIZE	2 /* 2 octets */
+
 /* MAC's Command Frames Identifiers */
 #define IEEE802154_CMD_ASSOCIATION_REQ		0x01
 #define IEEE802154_CMD_ASSOCIATION_RESP		0x02
diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 19d6aef..7d4cb58 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -113,6 +113,20 @@ struct lowpan_dev_record {
 	struct list_head list;
 };
 
+struct lowpan_fragment {
+	struct sk_buff		*skb;		/* skb to be assembled */
+	spinlock_t		lock;		/* concurency lock */
+	u16			length;		/* length to be assemled */
+	u32			bytes_rcv;	/* bytes received */
+	u16			tag;		/* current fragment tag */
+	struct timer_list	timer;		/* assembling timer */
+	struct list_head	list;		/* fragments list */
+};
+
+static unsigned short fragment_tag;
+static LIST_HEAD(lowpan_fragments);
+spinlock_t flist_lock;
+
 static inline struct
 lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
 {
@@ -244,6 +258,17 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff *skb)
 	return ret;
 }
 
+static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
+{
+	u16 ret;
+
+	BUG_ON(!pskb_may_pull(skb, 2));
+
+	ret = skb->data[0] | (skb->data[1] << 8);
+	skb_pull(skb, 2);
+	return ret;
+}
+
 static int lowpan_header_create(struct sk_buff *skb,
 			   struct net_device *dev,
 			   unsigned short type, const void *_daddr,
@@ -467,6 +492,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 		memcpy(&(sa.hwaddr), saddr, 8);
 
 		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
+
 		return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
 				type, (void *)&da, (void *)&sa, skb->len);
 	}
@@ -511,6 +537,21 @@ static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr)
 	return stat;
 }
 
+static void lowpan_fragment_timer_expired(unsigned long entry_addr)
+{
+	struct lowpan_fragment *entry = (struct lowpan_fragment *)entry_addr;
+
+	pr_debug("%s: timer expired for frame with tag %d\n", __func__,
+								entry->tag);
+
+	spin_lock(&flist_lock);
+	list_del(&entry->list);
+	spin_unlock(&flist_lock);
+
+	dev_kfree_skb(entry->skb);
+	kfree(entry);
+}
+
 static int
 lowpan_process_data(struct sk_buff *skb)
 {
@@ -525,6 +566,107 @@ lowpan_process_data(struct sk_buff *skb)
 	if (skb->len < 2)
 		goto drop;
 	iphc0 = lowpan_fetch_skb_u8(skb);
+
+	/* fragments assembling */
+	switch (iphc0 & LOWPAN_DISPATCH_MASK) {
+	case LOWPAN_DISPATCH_FRAG1:
+	case LOWPAN_DISPATCH_FRAGN:
+	{
+		struct lowpan_fragment *frame;
+		u8 len, offset;
+		u16 tag;
+		bool found = false;
+
+		len = lowpan_fetch_skb_u8(skb); /* frame length */
+		tag = lowpan_fetch_skb_u16(skb);
+
+		/*
+		 * check if frame assembling with the same tag is
+		 * already in progress
+		 */
+		spin_lock(&flist_lock);
+
+		list_for_each_entry(frame, &lowpan_fragments, list)
+			if (frame->tag == tag) {
+				found = true;
+				break;
+			}
+
+		/* alloc new frame structure */
+		if (!found) {
+			frame = kzalloc(sizeof(struct lowpan_fragment),
+								GFP_ATOMIC);
+			if (!frame)
+				goto unlock_and_drop;
+
+			INIT_LIST_HEAD(&frame->list);
+
+			frame->length = (iphc0 & 7) | (len << 3);
+			frame->tag = tag;
+
+			/* allocate buffer for frame assembling */
+			frame->skb = alloc_skb(frame->length +
+					sizeof(struct ipv6hdr), GFP_ATOMIC);
+
+			if (!frame->skb) {
+				kfree(frame);
+				goto unlock_and_drop;
+			}
+
+			frame->skb->priority = skb->priority;
+			frame->skb->dev = skb->dev;
+
+			/* reserve headroom for uncompressed ipv6 header */
+			skb_reserve(frame->skb, sizeof(struct ipv6hdr));
+			skb_put(frame->skb, frame->length);
+
+			init_timer(&frame->timer);
+			/* time out is the same as for ipv6 - 60 sec */
+			frame->timer.expires = jiffies + LOWPAN_FRAG_TIMEOUT;
+			frame->timer.data = (unsigned long)frame;
+			frame->timer.function = lowpan_fragment_timer_expired;
+
+			add_timer(&frame->timer);
+
+			list_add_tail(&frame->list, &lowpan_fragments);
+		}
+
+		if ((iphc0 & LOWPAN_DISPATCH_MASK) == LOWPAN_DISPATCH_FRAG1)
+			goto unlock_and_drop;
+
+		offset = lowpan_fetch_skb_u8(skb); /* fetch offset */
+
+		/* if payload fits buffer, copy it */
+		if (likely((offset * 8 + skb->len) <= frame->length))
+			skb_copy_to_linear_data_offset(frame->skb, offset * 8,
+							skb->data, skb->len);
+		else
+			goto unlock_and_drop;
+
+		frame->bytes_rcv += skb->len;
+
+		/* frame assembling complete */
+		if ((frame->bytes_rcv == frame->length) &&
+		     frame->timer.expires > jiffies) {
+			/* if timer haven't expired - first of all delete it */
+			del_timer(&frame->timer);
+			list_del(&frame->list);
+			spin_unlock(&flist_lock);
+
+			dev_kfree_skb(skb);
+			skb = frame->skb;
+			kfree(frame);
+			iphc0 = lowpan_fetch_skb_u8(skb);
+			break;
+		}
+		spin_unlock(&flist_lock);
+
+		return kfree_skb(skb), 0;
+	}
+	default:
+		break;
+	}
+
 	iphc1 = lowpan_fetch_skb_u8(skb);
 
 	_saddr = mac_cb(skb)->sa.hwaddr;
@@ -674,6 +816,9 @@ lowpan_process_data(struct sk_buff *skb)
 	lowpan_raw_dump_table(__func__, "raw header dump", (u8 *)&hdr,
 							sizeof(hdr));
 	return lowpan_skb_deliver(skb, &hdr);
+
+unlock_and_drop:
+	spin_unlock(&flist_lock);
 drop:
 	kfree_skb(skb);
 	return -EINVAL;
@@ -692,18 +837,118 @@ static int lowpan_set_address(struct net_device *dev, void *p)
 	return 0;
 }
 
+static int lowpan_get_mac_header_length(struct sk_buff *skb)
+{
+	/*
+	 * Currently long addressing mode is supported only, so the overall
+	 * header size is 21:
+	 * FC SeqNum DPAN DA  SA  Sec
+	 * 2  +  1  +  2 + 8 + 8 + 0  = 21
+	 */
+	return 21;
+}
+
+static int
+lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
+			int mlen, int plen, int offset)
+{
+	struct sk_buff *frag;
+	int hlen, ret;
+
+	/* if payload length is zero, therefore it's a first fragment */
+	hlen = (plen == 0 ? LOWPAN_FRAG1_HEAD_SIZE :  LOWPAN_FRAGN_HEAD_SIZE);
+
+	lowpan_raw_dump_inline(__func__, "6lowpan fragment header", head, hlen);
+
+	frag = dev_alloc_skb(hlen + mlen + plen + IEEE802154_MFR_SIZE);
+	if (!frag)
+		return -ENOMEM;
+
+	frag->priority = skb->priority;
+	frag->dev = skb->dev;
+
+	/* copy header, MFR and payload */
+	memcpy(skb_put(frag, mlen), skb->data, mlen);
+	memcpy(skb_put(frag, hlen), head, hlen);
+
+	if (plen)
+		skb_copy_from_linear_data_offset(skb, offset + mlen,
+					skb_put(frag, plen), plen);
+
+	lowpan_raw_dump_table(__func__, " raw fragment dump", frag->data,
+								frag->len);
+
+	ret = dev_queue_xmit(frag);
+
+	if (ret < 0)
+		dev_kfree_skb(frag);
+
+	return ret;
+}
+
+static int
+lowpan_skb_fragmentation(struct sk_buff *skb)
+{
+	int  err, header_length, payload_length, tag, offset = 0;
+	u8 head[5];
+
+	header_length = lowpan_get_mac_header_length(skb);
+	payload_length = skb->len - header_length;
+	tag = fragment_tag++;
+
+	/* first fragment header */
+	head[0] = LOWPAN_DISPATCH_FRAG1 | (payload_length & 0x7);
+	head[1] = (payload_length >> 3) & 0xff;
+	head[2] = tag & 0xff;
+	head[3] = tag >> 8;
+
+	err = lowpan_fragment_xmit(skb, head, header_length, 0, 0);
+
+	/* next fragment header */
+	head[0] &= ~LOWPAN_DISPATCH_FRAG1;
+	head[0] |= LOWPAN_DISPATCH_FRAGN;
+
+	while ((payload_length - offset > 0) && (err >= 0)) {
+		int len = LOWPAN_FRAG_SIZE;
+
+		head[4] = offset / 8;
+
+		if (payload_length - offset < len)
+			len = payload_length - offset;
+
+		err = lowpan_fragment_xmit(skb, head, header_length,
+							len, offset);
+		offset += len;
+	}
+
+	return err;
+}
+
 static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int err = 0;
+	int err = -1;
 
 	pr_debug("(%s): package xmit\n", __func__);
 
 	skb->dev = lowpan_dev_info(dev)->real_dev;
 	if (skb->dev == NULL) {
 		pr_debug("(%s) ERROR: no real wpan device found\n", __func__);
-		dev_kfree_skb(skb);
-	} else
+		goto error;
+	}
+
+	if (skb->len <= IEEE802154_MTU) {
 		err = dev_queue_xmit(skb);
+		goto out;
+	}
+
+	pr_debug("(%s): frame is too big, fragmentation is needed\n",
+								__func__);
+	err = lowpan_skb_fragmentation(skb);
+error:
+	dev_kfree_skb(skb);
+out:
+	if (err < 0)
+		pr_debug("(%s): ERROR: xmit failed\n", __func__);
 
 	return (err < 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);
 }
@@ -765,8 +1010,15 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* check that it's our buffer */
-	if ((skb->data[0] & 0xe0) == 0x60)
+	switch (skb->data[0] & 0xe0) {
+	case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
+	case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
+	case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
 		lowpan_process_data(skb);
+		break;
+	default:
+		break;
+	}
 
 	return NET_RX_SUCCESS;
 
diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 5d8cf80..5d2e5a0 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -159,6 +159,24 @@
 #define LOWPAN_DISPATCH_FRAG1	0xc0 /* 11000xxx */
 #define LOWPAN_DISPATCH_FRAGN	0xe0 /* 11100xxx */
 
+#define LOWPAN_DISPATCH_MASK	0xf8 /* 11111000 */
+
+#define LOWPAN_FRAG_TIMEOUT	(HZ * 60)	/* time-out 60 sec */
+
+#define LOWPAN_FRAG1_HEAD_SIZE	0x4
+#define LOWPAN_FRAGN_HEAD_SIZE	0x5
+
+/*
+ * According IEEE802.15.4 standard:
+ *   - MTU is 127 octets
+ *   - maximum MHR size is 37 octets
+ *   - MFR size is 2 octets
+ *
+ * so minimal payload size that we may guarantee is:
+ *   MTU - MHR - MFR = 88 octets
+ */
+#define LOWPAN_FRAG_SIZE	88
+
 /*
  * Values of fields within the IPHC encoding first byte
  * (C stands for compressed and I for inline)
-- 
1.7.2.5


------------------------------------------------------------------------------
RSA(R) Conference 2012
Save $700 by Nov 18
Register now
http://p.sf.net/sfu/rsa-sfdev2dev1
