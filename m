From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [IEEE802.15.4][6LoWPAN] draft for fragmentation support
Date: Thu, 20 Oct 2011 15:17:18 +0400
Message-ID: <20111020111718.GA32181@avtobot.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Cc: dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, kernel-janitors@vger.kernel.org,
	jonsmirl@gmail.com, alex.bluesman.smirnov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44601 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab1JTLSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 07:18:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello everybody,

below is the patch which adds support for fragmentation in 6LoWPAN
point to point networks. This activity needs because of difference
in MTU: 1280 ipv6 and 128 ieee802.15.4

This patch is just a draft. Could anyone please look at
it and let me know your opinion.

The most doubtful moments for me are:
1. Should the list 'frag_list' and the mutex 'flist_lock' be
included into dev private data?
2. Can I use 'dev_queue_xmit' to send fragments to queue?
3. Creating new 'skb' instead of copying and modifying main one.

With best regards,
Alexander


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-6LoWPAN-fragmentation-support.patch"

>From 48472bae269b7b1a4047967ec21eadb217c4fd6d Mon Sep 17 00:00:00 2001
From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Thu, 20 Oct 2011 15:02:36 +0400
Subject: [PATCH] 6LoWPAN fragmentation support

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |  286 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ieee802154/6lowpan.h |    3 +
 2 files changed, 288 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 96877bd..1923ec7 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -113,6 +113,24 @@ struct lowpan_dev_record {
 	struct list_head list;
 };
 
+struct lowpan_fragment {
+	u8 in_progress;			/* assembling is in progress */
+	struct sk_buff *skb;		/* skb to be assembled */
+	u8 *data;			/* data to be stored */
+	struct mutex lock;		/* concurency lock */
+	u16 length;			/* frame length to be assemled */
+	u32 bytes_rcv;			/* bytes received */
+	u16 tag;			/* current fragment tag */
+	struct timer_list timer;	/* assembling timer */
+	struct list_head list;		/* fragments list handler */	
+};
+
+static unsigned short fragment_tag;
+
+/* TODO: bind mutex and list to device */
+static LIST_HEAD(lowpan_fragments);
+struct mutex flist_lock;
+
 static inline struct
 lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
 {
@@ -244,6 +262,18 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff *skb)
 	return ret;
 }
 
+static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
+{
+	u16 ret;
+
+	BUG_ON(skb->len < 2);
+
+	ret = skb->data[0] | (skb->data[1] << 8);
+	skb_pull(skb, 2);
+	return ret;
+}
+
+static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lowpan_header_create(struct sk_buff *skb,
 			   struct net_device *dev,
 			   unsigned short type, const void *_daddr,
@@ -467,9 +497,102 @@ static int lowpan_header_create(struct sk_buff *skb,
 		memcpy(&(sa.hwaddr), saddr, 8);
 
 		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
+
+		/* frame fragmentation */
+
+		/*
+		 * if payload + mac header doesn't fit MTU-sized frame
+		 * we need to fragment it.
+		 */
+		if (skb->len > (127 - 24)) { /* MTU - MAC_HEADER_LENGTH */
+			struct sk_buff *fr_skb;
+			u16 b_sent = 0;
+			unsigned short payload_len = skb->len;
+			int stat = 0;
+
+			pr_debug("%s: the frame is too big (0x%x),"
+				 "fragmentation needed, using tag = 0x%x\n",
+				 __func__, payload_len, fragment_tag);
+
+			fr_skb = skb_copy(skb, GFP_KERNEL);
+			if (!fr_skb)
+				goto error;
+
+			/* 40-bit - fragment dispatch size */
+			head = kzalloc(5, GFP_KERNEL);
+			if (!head)
+				goto error;
+
+			/* first fagment header */
+			head[0] = LOWPAN_DISPATCH_FRAG1 | (payload_len & 0x7);
+			head[1] = (payload_len >> 3) & 0xff;
+			head[2] = fragment_tag & 0xff;
+			head[3] = fragment_tag >> 8;
+
+
+			lowpan_raw_dump_inline(__func__, "first header",
+							head, 4);
+
+			memcpy(skb_push(fr_skb, 4), head, 4);
+			skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
+
+			dev_hard_header(fr_skb, lowpan_dev_info(dev)->real_dev,
+				type, (void *)&da, (void *)&sa, fr_skb->len);
+
+			/* send fragment to dev queue */
+			dev_queue_xmit(fr_skb);
+
+			/* next fragments headers */
+			head[0] |= 0x20;
+
+			lowpan_raw_dump_inline(__func__, "next headers",
+							head, 5);
+
+			while (b_sent < payload_len) {
+				/* not the first fragment */
+				if (b_sent)
+					skb_pull(skb, LOWPAN_FRAG_SIZE);
+
+				pr_debug("%s: preparing fragment %d\n",
+				    __func__, b_sent / LOWPAN_FRAG_SIZE);
+
+				/*
+				 * create copy of current buffer and trim it
+				 * down to fragment size
+				 */
+				fr_skb = skb_copy(skb, GFP_KERNEL);
+				if (!fr_skb)
+					goto error;
+
+				skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
+
+				/* add fragment header */
+				head[4] = b_sent / 8;
+				memcpy(skb_push(fr_skb, 5), head, 5);
+
+				b_sent += LOWPAN_FRAG_SIZE;
+
+				lowpan_raw_dump_table(__func__,
+				   "fragment data", fr_skb->data, fr_skb->len);
+
+				stat = dev_hard_header(fr_skb,
+					lowpan_dev_info(dev)->real_dev, type,
+					(void *)&da, (void *)&sa, fr_skb->len);
+
+				dev_queue_xmit(fr_skb);
+			}
+
+			/* TODO: what's the correct way to skip default skb? */
+
+			fragment_tag++;
+			return stat;
+		} else
 		return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
 				type, (void *)&da, (void *)&sa, skb->len);
 	}
+error:
+	kfree_skb(skb);
+	return -ENOMEM;
 }
 
 static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr)
@@ -511,6 +634,23 @@ static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr)
 	return stat;
 }
 
+static void lowpan_fragment_timer_expired(unsigned long tag)
+{
+	struct lowpan_fragment *entry, *tmp;
+
+	pr_debug("%s: timer expired for frame with tag %lu\n", __func__, tag);
+
+	mutex_lock(&flist_lock);
+	list_for_each_entry_safe(entry, tmp, &lowpan_fragments, list)
+		if (entry->tag == tag) {
+			list_del(&entry->list);
+			kfree(entry->data);
+			kfree(entry);
+			break;
+		}
+	mutex_unlock(&flist_lock);
+}
+
 static int
 lowpan_process_data(struct sk_buff *skb)
 {
@@ -525,6 +665,139 @@ lowpan_process_data(struct sk_buff *skb)
 	if (skb->len < 2)
 		goto drop;
 	iphc0 = lowpan_fetch_skb_u8(skb);
+
+	/* fragments assmebling */
+	switch (iphc0 & 0xf8) {
+	/* first fragment of the frame */
+	case LOWPAN_DISPATCH_FRAG1:
+	{
+		struct lowpan_fragment *entry, *frame;
+		u16 tag;
+
+		lowpan_raw_dump_inline(__func__, "first frame fragment header",
+								skb->data, 3);
+
+		tmp = lowpan_fetch_skb_u8(skb);
+		tag = lowpan_fetch_skb_u16(skb);
+
+		/*
+		 * check if frame assembling with the same tag is
+		 * already in progress
+		 */
+		rcu_read_lock();
+		list_for_each_entry_rcu(entry, &lowpan_fragments, list)
+			if (entry->tag == tag) {
+				pr_debug("%s ERROR: frame with this tag is"
+					 "alredy in assembling", __func__);
+				goto drop_rcu;
+			}
+		rcu_read_unlock();
+
+		/* alloc new frame structure */
+		frame = kzalloc(sizeof(struct lowpan_fragment), GFP_KERNEL);
+		if (!frame)
+			goto drop;
+
+		INIT_LIST_HEAD(&frame->list);
+
+		frame->bytes_rcv = 0;
+		frame->length = (iphc0 & 7) | (tmp << 3);
+		frame->tag = tag;
+		/* allocate buffer for frame assembling */
+		frame->data = kzalloc(frame->length, GFP_KERNEL);
+		if (!frame->data) {
+			kfree(frame);
+			goto drop;
+		}
+
+		pr_debug("%s: frame to be assembled: length = 0x%x, "
+			 "tag = 0x%x\n", __func__, frame->length, frame->tag);
+
+		init_timer(&frame->timer);
+		/* (number of fragments) * (fragment processing time-out) */
+		frame->timer.expires = jiffies +
+		  (frame->length / LOWPAN_FRAG_SIZE + 1) * LOWPAN_FRAG_TIMEOUT;
+		frame->timer.data = tag;
+		frame->timer.function = lowpan_fragment_timer_expired;
+
+		add_timer(&frame->timer);
+
+		mutex_lock(&flist_lock);
+		list_add_tail(&frame->list, &lowpan_fragments);
+		mutex_unlock(&flist_lock);
+
+		return kfree_skb(skb), 0;
+	}
+	/* second and next fragment of the frame */
+	case LOWPAN_DISPATCH_FRAGN:
+	{
+		u16 tag;
+		struct lowpan_fragment *entry, *t;
+
+		lowpan_raw_dump_inline(__func__, "next fragment header",
+					skb->data, 4);
+
+		lowpan_fetch_skb_u8(skb); /* skip frame length byte */
+		tag = lowpan_fetch_skb_u16(skb);
+
+		rcu_read_lock();
+		list_for_each_entry_rcu(entry, &lowpan_fragments, list)
+			if (entry->tag == tag)
+				break;
+		rcu_read_unlock();
+
+		if (entry->tag != tag) {
+			pr_debug("%s ERROR: no frame structure found for this"
+				 "fragment", __func__);
+			goto drop;
+		}
+
+		tmp = lowpan_fetch_skb_u8(skb); /* fetch offset */
+
+		lowpan_raw_dump_table(__func__, "next fragment payload",
+					skb->data, skb->len);
+
+		/* if payload fits buffer, copy it */
+		if ((tmp * 8 + skb->len) <= entry->length) /* TODO: likely? */
+			memcpy(entry->data + tmp * 8, skb->data, skb->len);
+		else
+			goto drop;
+
+		entry->bytes_rcv += skb->len;
+
+		pr_debug("%s: frame length = 0x%x, bytes received = 0x%x\n",
+			 __func__, entry->length, entry->bytes_rcv);
+
+		/* frame assembling complete */
+		if (entry->bytes_rcv == entry->length) {
+			struct sk_buff *tmp = skb;
+
+			mutex_lock(&flist_lock);
+			list_for_each_entry_safe(entry, t, &lowpan_fragments, list)
+				if (entry->tag == tag) {
+					list_del(&entry->list);
+					/* copy and clear skb */
+					skb = skb_copy_expand(skb, entry->length, skb_tailroom(skb), GFP_KERNEL);
+					skb_pull(skb, skb->len);
+					/* copy new data to skb */
+					memcpy(skb_push(skb, entry->length), entry->data, entry->length);
+					kfree_skb(tmp);
+					del_timer(&entry->timer);
+					kfree(entry->data);
+					kfree(entry);
+
+					iphc0 = lowpan_fetch_skb_u8(skb);
+					break;
+				}
+			mutex_unlock(&flist_lock);
+			break;
+		}
+		return kfree_skb(skb), 0;
+	}
+	default:
+		break;
+	}
+
 	iphc1 = lowpan_fetch_skb_u8(skb);
 
 	_saddr = mac_cb(skb)->sa.hwaddr;
@@ -674,6 +947,8 @@ lowpan_process_data(struct sk_buff *skb)
 	lowpan_raw_dump_table(__func__, "raw header dump", (u8 *)&hdr,
 							sizeof(hdr));
 	return lowpan_skb_deliver(skb, &hdr);
+drop_rcu:
+	rcu_read_unlock();
 drop:
 	kfree(skb);
 	return -EINVAL;
@@ -765,8 +1040,15 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* check that it's our buffer */
-	if ((skb->data[0] & 0xe0) == 0x60)
+	switch (skb->data[0] & 0xe0) {
+	case 0x60:		/* ipv6 datagram */
+	case 0xc0:		/* first fragment header */
+	case 0xe0:		/* next fragments headers */
 		lowpan_process_data(skb);
+		break;
+	default:
+		break;
+	}
 
 	return NET_RX_SUCCESS;
 
@@ -793,6 +1075,8 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	lowpan_dev_info(dev)->real_dev = real_dev;
 	mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
 
+	mutex_init(&flist_lock);
+
 	entry = kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNEL);
 	if (!entry)
 		return -ENOMEM;
diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 5d8cf80..e8e57c4 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -159,6 +159,9 @@
 #define LOWPAN_DISPATCH_FRAG1	0xc0 /* 11000xxx */
 #define LOWPAN_DISPATCH_FRAGN	0xe0 /* 11100xxx */
 
+#define LOWPAN_FRAG_SIZE	40		/* fragment payload size */
+#define LOWPAN_FRAG_TIMEOUT	(HZ * 2)	/* processing time: 2 sec */
+
 /*
  * Values of fields within the IPHC encoding first byte
  * (C stands for compressed and I for inline)
-- 
1.7.2.5


--zYM0uCDKw75PZbzx--
