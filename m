From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v4 8/8] 6lowpan: handling 6lowpan fragmentation via inet_frag api
Date: Wed, 26 Feb 2014 17:05:12 +0100
Message-ID: <1393430712-11298-9-git-send-email-alex.aring@gmail.com>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:57306 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbaBZQFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 11:05:40 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so1057379ead.24
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:05:39 -0800 (PST)
In-Reply-To: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch drops the current way of 6lowpan fragmentation on receiving
side and replace it with a implementation which use the inet_frag api.
The old fragmentation handling has some race conditions and isn't
rfc4944 compatible. Also adding support to match fragments on
destination and source address which is missing in the current
implementation.

This patch add also a lookup function for uncompressed 6LoWPAN header
size. This is needed to estimate the real size of fragmented packet.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/netns/ieee802154_6lowpan.h |   9 +
 net/ieee802154/6lowpan_rtnl.c          | 256 +++------------
 net/ieee802154/Makefile                |   2 +-
 net/ieee802154/reassembly.c            | 565 +++++++++++++++++++++++++++++++++
 net/ieee802154/reassembly.h            |  66 ++++
 5 files changed, 690 insertions(+), 208 deletions(-)
 create mode 100644 net/ieee802154/reassembly.c
 create mode 100644 net/ieee802154/reassembly.h

diff --git a/include/net/netns/ieee802154_6lowpan.h b/include/net/netns/ieee802154_6lowpan.h
index 88110b7..079030c 100644
--- a/include/net/netns/ieee802154_6lowpan.h
+++ b/include/net/netns/ieee802154_6lowpan.h
@@ -7,7 +7,16 @@
 #ifndef __NETNS_IEEE802154_6LOWPAN_H__
 #define __NETNS_IEEE802154_6LOWPAN_H__
 
+struct netns_sysctl_lowpan {
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *frags_hdr;
+#endif
+};
+
 struct netns_ieee802154_lowpan {
+	struct netns_sysctl_lowpan sysctl;
+	struct netns_frags	frags;
+	u16			max_dsize;
 };
 
 #endif
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index f9c9548..c7bd8b5 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -54,6 +54,7 @@
 #include <net/ieee802154_netdev.h>
 #include <net/ipv6.h>
 
+#include "reassembly.h"
 #include "6lowpan.h"
 
 static LIST_HEAD(lowpan_devices);
@@ -70,18 +71,6 @@ struct lowpan_dev_record {
 	struct list_head list;
 };
 
-struct lowpan_fragment {
-	struct sk_buff		*skb;		/* skb to be assembled */
-	u16			length;		/* length to be assemled */
-	u32			bytes_rcv;	/* bytes received */
-	u16			tag;		/* current fragment tag */
-	struct timer_list	timer;		/* assembling timer */
-	struct list_head	list;		/* fragments list */
-};
-
-static LIST_HEAD(lowpan_fragments);
-static DEFINE_SPINLOCK(flist_lock);
-
 static inline struct
 lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
 {
@@ -179,69 +168,6 @@ static int lowpan_give_skb_to_devices(struct sk_buff *skb,
 	return stat;
 }
 
-static void lowpan_fragment_timer_expired(unsigned long entry_addr)
-{
-	struct lowpan_fragment *entry = (struct lowpan_fragment *)entry_addr;
-
-	pr_debug("timer expired for frame with tag %d\n", entry->tag);
-
-	list_del(&entry->list);
-	dev_kfree_skb(entry->skb);
-	kfree(entry);
-}
-
-static struct lowpan_fragment *
-lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
-{
-	struct lowpan_fragment *frame;
-
-	frame = kzalloc(sizeof(struct lowpan_fragment),
-			GFP_ATOMIC);
-	if (!frame)
-		goto frame_err;
-
-	INIT_LIST_HEAD(&frame->list);
-
-	frame->length = len;
-	frame->tag = tag;
-
-	/* allocate buffer for frame assembling */
-	frame->skb = netdev_alloc_skb_ip_align(skb->dev, frame->length +
-					       sizeof(struct ipv6hdr));
-
-	if (!frame->skb)
-		goto skb_err;
-
-	frame->skb->priority = skb->priority;
-
-	/* reserve headroom for uncompressed ipv6 header */
-	skb_reserve(frame->skb, sizeof(struct ipv6hdr));
-	skb_put(frame->skb, frame->length);
-
-	/* copy the first control block to keep a
-	 * trace of the link-layer addresses in case
-	 * of a link-local compressed address
-	 */
-	memcpy(frame->skb->cb, skb->cb, sizeof(skb->cb));
-
-	init_timer(&frame->timer);
-	/* time out is the same as for ipv6 - 60 sec */
-	frame->timer.expires = jiffies + LOWPAN_FRAG_TIMEOUT;
-	frame->timer.data = (unsigned long)frame;
-	frame->timer.function = lowpan_fragment_timer_expired;
-
-	add_timer(&frame->timer);
-
-	list_add_tail(&frame->list, &lowpan_fragments);
-
-	return frame;
-
-skb_err:
-	kfree(frame);
-frame_err:
-	return NULL;
-}
-
 static int process_data(struct sk_buff *skb)
 {
 	u8 iphc0, iphc1;
@@ -255,94 +181,6 @@ static int process_data(struct sk_buff *skb)
 	if (lowpan_fetch_skb_u8(skb, &iphc0))
 		goto drop;
 
-	/* fragments assembling */
-	switch (iphc0 & LOWPAN_DISPATCH_MASK) {
-	case LOWPAN_DISPATCH_FRAG1:
-	case LOWPAN_DISPATCH_FRAGN:
-	{
-		struct lowpan_fragment *frame;
-		/* slen stores the rightmost 8 bits of the 11 bits length */
-		u8 slen, offset = 0;
-		u16 len, tag;
-		bool found = false;
-
-		if (lowpan_fetch_skb_u8(skb, &slen) || /* frame length */
-		    lowpan_fetch_skb_u16(skb, &tag))  /* fragment tag */
-			goto drop;
-
-		/* adds the 3 MSB to the 8 LSB to retrieve the 11 bits length */
-		len = ((iphc0 & 7) << 8) | slen;
-
-		if ((iphc0 & LOWPAN_DISPATCH_MASK) == LOWPAN_DISPATCH_FRAG1) {
-			pr_debug("%s received a FRAG1 packet (tag: %d, "
-				 "size of the entire IP packet: %d)",
-				 __func__, tag, len);
-		} else { /* FRAGN */
-			if (lowpan_fetch_skb_u8(skb, &offset))
-				goto unlock_and_drop;
-			pr_debug("%s received a FRAGN packet (tag: %d, "
-				 "size of the entire IP packet: %d, "
-				 "offset: %d)", __func__, tag, len, offset * 8);
-		}
-
-		/*
-		 * check if frame assembling with the same tag is
-		 * already in progress
-		 */
-		spin_lock_bh(&flist_lock);
-
-		list_for_each_entry(frame, &lowpan_fragments, list)
-			if (frame->tag == tag) {
-				found = true;
-				break;
-			}
-
-		/* alloc new frame structure */
-		if (!found) {
-			pr_debug("%s first fragment received for tag %d, "
-				 "begin packet reassembly", __func__, tag);
-			frame = lowpan_alloc_new_frame(skb, len, tag);
-			if (!frame)
-				goto unlock_and_drop;
-		}
-
-		/* if payload fits buffer, copy it */
-		if (likely((offset * 8 + skb->len) <= frame->length))
-			skb_copy_to_linear_data_offset(frame->skb, offset * 8,
-							skb->data, skb->len);
-		else
-			goto unlock_and_drop;
-
-		frame->bytes_rcv += skb->len;
-
-		/* frame assembling complete */
-		if ((frame->bytes_rcv == frame->length) &&
-		     frame->timer.expires > jiffies) {
-			/* if timer haven't expired - first of all delete it */
-			del_timer_sync(&frame->timer);
-			list_del(&frame->list);
-			spin_unlock_bh(&flist_lock);
-
-			pr_debug("%s successfully reassembled fragment "
-				 "(tag %d)", __func__, tag);
-
-			dev_kfree_skb(skb);
-			skb = frame->skb;
-			kfree(frame);
-
-			if (lowpan_fetch_skb_u8(skb, &iphc0))
-				goto drop;
-
-			break;
-		}
-		spin_unlock_bh(&flist_lock);
-
-		return kfree_skb(skb), 0;
-	}
-	default:
-		break;
-	}
-
 	if (lowpan_fetch_skb_u8(skb, &iphc1))
 		goto drop;
 
@@ -355,8 +193,6 @@ static int process_data(struct sk_buff *skb)
 				IEEE802154_ADDR_LEN, iphc0, iphc1,
 				lowpan_give_skb_to_devices);
 
-unlock_and_drop:
-	spin_unlock_bh(&flist_lock);
 drop:
 	kfree_skb(skb);
 	return -EINVAL;
@@ -603,44 +439,53 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct sk_buff *local_skb;
+	int ret;
 
 	if (!netif_running(dev))
-		goto drop;
+		goto drop_skb;
 
 	if (dev->type != ARPHRD_IEEE802154)
-		goto drop;
+		goto drop_skb;
+
+	local_skb = skb_clone(skb, GFP_ATOMIC);
+	if (!local_skb)
+		goto drop_skb;
+
+	kfree_skb(skb);
 
 	/* check that it's our buffer */
 	if (skb->data[0] == LOWPAN_DISPATCH_IPV6) {
-		/* Copy the packet so that the IPv6 header is
-		 * properly aligned.
-		 */
-		local_skb = skb_copy_expand(skb, NET_SKB_PAD - 1,
-					    skb_tailroom(skb), GFP_ATOMIC);
-		if (!local_skb)
-			goto drop;
-
 		local_skb->protocol = htons(ETH_P_IPV6);
 		local_skb->pkt_type = PACKET_HOST;
 
 		/* Pull off the 1-byte of 6lowpan header. */
 		skb_pull(local_skb, 1);
 
-		lowpan_give_skb_to_devices(local_skb, NULL);
-
-		kfree_skb(local_skb);
-		kfree_skb(skb);
+		ret = lowpan_give_skb_to_devices(local_skb, NULL);
+		if (ret == NET_RX_DROP)
+			goto drop;
 	} else {
 		switch (skb->data[0] & 0xe0) {
 		case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
+			ret = process_data(local_skb);
+			if (ret == NET_RX_DROP)
+				goto drop;
+			break;
 		case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
+			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAG1);
+			if (ret == 1) {
+				ret = process_data(local_skb);
+				if (ret == NET_RX_DROP)
+					goto drop;
+			}
+			break;
 		case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
-			local_skb = skb_clone(skb, GFP_ATOMIC);
-			if (!local_skb)
-				goto drop;
-			process_data(local_skb);
-
-			kfree_skb(skb);
+			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAGN);
+			if (ret == 1) {
+				ret = process_data(local_skb);
+				if (ret == NET_RX_DROP)
+					goto drop;
+			}
 			break;
 		default:
 			break;
@@ -648,9 +493,9 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	return NET_RX_SUCCESS;
-
-drop:
+drop_skb:
 	kfree_skb(skb);
+drop:
 	return NET_RX_DROP;
 }
 
@@ -778,43 +623,40 @@ static int __init lowpan_init_module(void)
 {
 	int err = 0;
 
-	err = lowpan_netlink_init();
+	err = lowpan_net_frag_init();
 	if (err < 0)
 		goto out;
 
+	err = lowpan_netlink_init();
+	if (err < 0)
+		goto out_frag;
+
 	dev_add_pack(&lowpan_packet_type);
 
 	err = register_netdevice_notifier(&lowpan_dev_notifier);
-	if (err < 0) {
-		dev_remove_pack(&lowpan_packet_type);
-		lowpan_netlink_fini();
-	}
+	if (err < 0)
+		goto out_pack;
+
+	return 0;
+
+out_pack:
+	dev_remove_pack(&lowpan_packet_type);
+	lowpan_netlink_fini();
+out_frag:
+	lowpan_net_frag_exit();
 out:
 	return err;
 }
 
 static void __exit lowpan_cleanup_module(void)
 {
-	struct lowpan_fragment *frame, *tframe;
-
 	lowpan_netlink_fini();
 
 	dev_remove_pack(&lowpan_packet_type);
 
-	unregister_netdevice_notifier(&lowpan_dev_notifier);
+	lowpan_net_frag_exit();
 
-	/* Now 6lowpan packet_type is removed, so no new fragments are
-	 * expected on RX, therefore that's the time to clean incomplete
-	 * fragments.
-	 */
-	spin_lock_bh(&flist_lock);
-	list_for_each_entry_safe(frame, tframe, &lowpan_fragments, list) {
-		del_timer_sync(&frame->timer);
-		list_del(&frame->list);
-		dev_kfree_skb(frame->skb);
-		kfree(frame);
-	}
-	spin_unlock_bh(&flist_lock);
+	unregister_netdevice_notifier(&lowpan_dev_notifier);
 }
 
 module_init(lowpan_init_module);
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index 3d08adf..b113fc4 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -2,6 +2,6 @@ obj-$(CONFIG_IEEE802154) += ieee802154.o af_802154.o
 obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
 obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o
 
-6lowpan-y := 6lowpan_rtnl.o
+6lowpan-y := 6lowpan_rtnl.o reassembly.o
 ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
 af_802154-y := af_ieee802154.o raw.o dgram.o
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
new file mode 100644
index 0000000..e7825b6
--- /dev/null
+++ b/net/ieee802154/reassembly.c
@@ -0,0 +1,565 @@
+/*	6LoWPAN fragment reassembly
+ *
+ *
+ *	Authors:
+ *	Alexander Aring		<aar@pengutronix.de>
+ *
+ *	Based on: net/ipv6/reassembly.c
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) "6LoWPAN: " fmt
+
+#include <linux/net.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/random.h>
+#include <linux/jhash.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/export.h>
+
+#include <net/ieee802154_netdev.h>
+#include <net/ipv6.h>
+#include <net/inet_frag.h>
+
+#include "6lowpan.h"
+#include "reassembly.h"
+
+static struct inet_frags lowpan_frags;
+
+static int lowpan_frag_reasm(struct lowpan_frag_queue *fq,
+			     struct sk_buff *prev, struct net_device *dev);
+
+static unsigned int lowpan_hash_frag(__be16 tag, __be16 d_size,
+				     const struct ieee802154_addr *saddr,
+				     const struct ieee802154_addr *daddr)
+{
+	u32 c;
+
+	net_get_random_once(&lowpan_frags.rnd, sizeof(lowpan_frags.rnd));
+	c = jhash_3words(ieee802154_addr_hash(saddr),
+			 ieee802154_addr_hash(daddr),
+			 (__force u32)(tag + (d_size << 16)),
+			 lowpan_frags.rnd);
+
+	return c & (INETFRAGS_HASHSZ - 1);
+}
+
+static unsigned int lowpan_hashfn(struct inet_frag_queue *q)
+{
+	struct lowpan_frag_queue *fq;
+
+	fq = container_of(q, struct lowpan_frag_queue, q);
+	return lowpan_hash_frag(fq->tag, fq->d_size, &fq->saddr, &fq->daddr);
+}
+
+bool lowpan_frag_match(struct inet_frag_queue *q, void *a)
+{
+	struct lowpan_frag_queue *fq;
+	struct lowpan_create_arg *arg = a;
+
+	fq = container_of(q, struct lowpan_frag_queue, q);
+	return	fq->tag == arg->tag && fq->d_size == arg->d_size &&
+		ieee802154_addr_addr_equal(&fq->saddr, arg->src) &&
+		ieee802154_addr_addr_equal(&fq->daddr, arg->dst);
+}
+EXPORT_SYMBOL(lowpan_frag_match);
+
+void lowpan_frag_init(struct inet_frag_queue *q, void *a)
+{
+	struct lowpan_frag_queue *fq;
+	struct lowpan_create_arg *arg = a;
+
+	fq = container_of(q, struct lowpan_frag_queue, q);
+
+	fq->tag = arg->tag;
+	fq->d_size = arg->d_size;
+	fq->saddr = *arg->src;
+	fq->daddr = *arg->dst;
+}
+EXPORT_SYMBOL(lowpan_frag_init);
+
+void lowpan_expire_frag_queue(struct frag_queue *fq, struct inet_frags *frags)
+{
+	spin_lock(&fq->q.lock);
+
+	if (fq->q.last_in & INET_FRAG_COMPLETE)
+		goto out;
+
+	inet_frag_kill(&fq->q, frags);
+out:
+	spin_unlock(&fq->q.lock);
+	inet_frag_put(&fq->q, frags);
+}
+EXPORT_SYMBOL(lowpan_expire_frag_queue);
+
+static void lowpan_frag_expire(unsigned long data)
+{
+	struct frag_queue *fq;
+	struct net *net;
+
+	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
+	net = container_of(fq->q.net, struct net, ieee802154_lowpan.frags);
+
+	lowpan_expire_frag_queue(fq, &lowpan_frags);
+}
+
+static inline struct lowpan_frag_queue *
+fq_find(struct net *net, const struct ieee802154_frag_info *frag_info,
+	const struct ieee802154_addr *src, const struct ieee802154_addr *dst)
+{
+	struct inet_frag_queue *q;
+	struct lowpan_create_arg arg;
+	unsigned int hash;
+
+	arg.tag = frag_info->d_tag;
+	arg.d_size = frag_info->d_size;
+	arg.src = src;
+	arg.dst = dst;
+
+	read_lock(&lowpan_frags.lock);
+	hash = lowpan_hash_frag(frag_info->d_tag, frag_info->d_size, src, dst);
+
+	q = inet_frag_find(&net->ieee802154_lowpan.frags,
+			   &lowpan_frags, &arg, hash);
+	if (IS_ERR_OR_NULL(q)) {
+		inet_frag_maybe_warn_overflow(q, pr_fmt());
+		return NULL;
+	}
+	return container_of(q, struct lowpan_frag_queue, q);
+}
+
+static int lowpan_frag_queue(struct lowpan_frag_queue *fq,
+			     struct sk_buff *skb, const u8 frag_type,
+			     const struct ieee802154_frag_info *frag_info)
+{
+	struct sk_buff *prev, *next;
+	struct net_device *dev;
+	int end, offset;
+
+	if (fq->q.last_in & INET_FRAG_COMPLETE)
+		goto err;
+
+	offset = mac_cb(skb)->frag_info.d_offset << 3;
+	end = mac_cb(skb)->frag_info.d_size;
+
+	/* Is this the final fragment? */
+	if (offset + skb->len == end) {
+		/* If we already have some bits beyond end
+		 * or have different end, the segment is corrupted.
+		 */
+		if (end < fq->q.len ||
+		    ((fq->q.last_in & INET_FRAG_LAST_IN) && end != fq->q.len))
+			goto err;
+		fq->q.last_in |= INET_FRAG_LAST_IN;
+		fq->q.len = end;
+	} else {
+		if (end > fq->q.len) {
+			/* Some bits beyond end -> corruption. */
+			if (fq->q.last_in & INET_FRAG_LAST_IN)
+				goto err;
+			fq->q.len = end;
+		}
+	}
+
+	/* Find out which fragments are in front and at the back of us
+	 * in the chain of fragments so far.  We must know where to put
+	 * this fragment, right?
+	 */
+	prev = fq->q.fragments_tail;
+	if (!prev || mac_cb(prev)->frag_info.d_offset <
+		     mac_cb(skb)->frag_info.d_offset) {
+		next = NULL;
+		goto found;
+	}
+	prev = NULL;
+	for (next = fq->q.fragments; next != NULL; next = next->next) {
+		if (mac_cb(next)->frag_info.d_offset >=
+		    mac_cb(skb)->frag_info.d_offset)
+			break;	/* bingo! */
+		prev = next;
+	}
+
+found:
+	/* Insert this fragment in the chain of fragments. */
+	skb->next = next;
+	if (!next)
+		fq->q.fragments_tail = skb;
+	if (prev)
+		prev->next = skb;
+	else
+		fq->q.fragments = skb;
+
+	dev = skb->dev;
+	if (dev)
+		skb->dev = NULL;
+
+	fq->q.stamp = skb->tstamp;
+	if (frag_type == LOWPAN_DISPATCH_FRAG1) {
+		/* Calculate uncomp. 6lowpan header to estimate full size */
+		fq->q.meat += lowpan_uncompress_size(skb, NULL);
+		fq->q.last_in |= INET_FRAG_FIRST_IN;
+	} else {
+		fq->q.meat += skb->len;
+	}
+	add_frag_mem_limit(&fq->q, skb->truesize);
+
+	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	    fq->q.meat == fq->q.len) {
+		int res;
+		unsigned long orefdst = skb->_skb_refdst;
+
+		skb->_skb_refdst = 0UL;
+		res = lowpan_frag_reasm(fq, prev, dev);
+		skb->_skb_refdst = orefdst;
+		return res;
+	}
+
+	inet_frag_lru_move(&fq->q);
+	return -1;
+err:
+	kfree_skb(skb);
+	return -1;
+}
+
+/*	Check if this packet is complete.
+ *	Returns NULL on failure by any reason, and pointer
+ *	to current nexthdr field in reassembled frame.
+ *
+ *	It is called with locked fq, and caller must check that
+ *	queue is eligible for reassembly i.e. it is not COMPLETE,
+ *	the last and the first frames arrived and all the bits are here.
+ */
+static int lowpan_frag_reasm(struct lowpan_frag_queue *fq, struct sk_buff *prev,
+			     struct net_device *dev)
+{
+	struct sk_buff *fp, *head = fq->q.fragments;
+	int sum_truesize;
+
+	inet_frag_kill(&fq->q, &lowpan_frags);
+
+	/* Make the one we just received the head. */
+	if (prev) {
+		head = prev->next;
+		fp = skb_clone(head, GFP_ATOMIC);
+
+		if (!fp)
+			goto out_oom;
+
+		fp->next = head->next;
+		if (!fp->next)
+			fq->q.fragments_tail = fp;
+		prev->next = fp;
+
+		skb_morph(head, fq->q.fragments);
+		head->next = fq->q.fragments->next;
+
+		consume_skb(fq->q.fragments);
+		fq->q.fragments = head;
+	}
+
+	/* Head of list must not be cloned. */
+	if (skb_unclone(head, GFP_ATOMIC))
+		goto out_oom;
+
+	/* If the first fragment is fragmented itself, we split
+	 * it to two chunks: the first with data and paged part
+	 * and the second, holding only fragments.
+	 */
+	if (skb_has_frag_list(head)) {
+		struct sk_buff *clone;
+		int i, plen = 0;
+
+		clone = alloc_skb(0, GFP_ATOMIC);
+		if (!clone)
+			goto out_oom;
+		clone->next = head->next;
+		head->next = clone;
+		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
+		skb_frag_list_init(head);
+		for (i = 0; i < skb_shinfo(head)->nr_frags; i++)
+			plen += skb_frag_size(&skb_shinfo(head)->frags[i]);
+		clone->len = head->data_len - plen;
+		clone->data_len = clone->len;
+		head->data_len -= clone->len;
+		head->len -= clone->len;
+		add_frag_mem_limit(&fq->q, clone->truesize);
+	}
+
+	WARN_ON(head == NULL);
+
+	sum_truesize = head->truesize;
+	for (fp = head->next; fp;) {
+		bool headstolen;
+		int delta;
+		struct sk_buff *next = fp->next;
+
+		sum_truesize += fp->truesize;
+		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
+			kfree_skb_partial(fp, headstolen);
+		} else {
+			if (!skb_shinfo(head)->frag_list)
+				skb_shinfo(head)->frag_list = fp;
+			head->data_len += fp->len;
+			head->len += fp->len;
+			head->truesize += fp->truesize;
+		}
+		fp = next;
+	}
+	sub_frag_mem_limit(&fq->q, sum_truesize);
+
+	head->next = NULL;
+	head->dev = dev;
+	head->tstamp = fq->q.stamp;
+
+	fq->q.fragments = NULL;
+	fq->q.fragments_tail = NULL;
+
+	return 1;
+out_oom:
+	net_dbg_ratelimited("lowpan_frag_reasm: no memory for reassembly\n");
+	return -1;
+}
+
+static int lowpan_get_frag_info(struct sk_buff *skb, const u8 frag_type,
+				struct ieee802154_frag_info *frag_info)
+{
+	bool fail;
+	u8 pattern = 0, low = 0;
+
+	fail = lowpan_fetch_skb(skb, &pattern, 1);
+	fail |= lowpan_fetch_skb(skb, &low, 1);
+	frag_info->d_size = (pattern & 7) << 8 | low;
+	fail |= lowpan_fetch_skb(skb, &frag_info->d_tag, 2);
+
+	if (frag_type == LOWPAN_DISPATCH_FRAGN) {
+		fail |= lowpan_fetch_skb(skb, &frag_info->d_offset, 1);
+	} else {
+		skb_reset_network_header(skb);
+		frag_info->d_offset = 0;
+	}
+
+	if (unlikely(fail))
+		return -EIO;
+
+	return 0;
+}
+
+int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
+{
+	struct lowpan_frag_queue *fq;
+	struct net *net = dev_net(skb->dev);
+	struct ieee802154_frag_info *frag_info = &mac_cb(skb)->frag_info;
+	int err;
+
+	err = lowpan_get_frag_info(skb, frag_type, frag_info);
+	if (err < 0)
+		goto err;
+
+	if (frag_info->d_size > net->ieee802154_lowpan.max_dsize)
+		goto err;
+
+	inet_frag_evictor(&net->ieee802154_lowpan.frags, &lowpan_frags, false);
+
+	fq = fq_find(net, frag_info, &mac_cb(skb)->sa, &mac_cb(skb)->da);
+	if (fq != NULL) {
+		int ret;
+		spin_lock(&fq->q.lock);
+		ret = lowpan_frag_queue(fq, skb, frag_type, frag_info);
+		spin_unlock(&fq->q.lock);
+
+		inet_frag_put(&fq->q, &lowpan_frags);
+		return ret;
+	}
+
+err:
+	kfree_skb(skb);
+	return -1;
+}
+EXPORT_SYMBOL(lowpan_frag_rcv);
+
+#ifdef CONFIG_SYSCTL
+static struct ctl_table lowpan_frags_ns_ctl_table[] = {
+	{
+		.procname	= "6lowpanfrag_high_thresh",
+		.data		= &init_net.ieee802154_lowpan.frags.high_thresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "6lowpanfrag_low_thresh",
+		.data		= &init_net.ieee802154_lowpan.frags.low_thresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "6lowpanfrag_time",
+		.data		= &init_net.ieee802154_lowpan.frags.timeout,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "6lowpanfrag_max_datagram_size",
+		.data		= &init_net.ieee802154_lowpan.max_dsize,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{ }
+};
+
+static struct ctl_table lowpan_frags_ctl_table[] = {
+	{
+		.procname	= "6lowpanfrag_secret_interval",
+		.data		= &lowpan_frags.secret_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{ }
+};
+
+static int __net_init lowpan_frags_ns_sysctl_register(struct net *net)
+{
+	struct ctl_table *table;
+	struct ctl_table_header *hdr;
+
+	table = lowpan_frags_ns_ctl_table;
+	if (!net_eq(net, &init_net)) {
+		table = kmemdup(table, sizeof(lowpan_frags_ns_ctl_table),
+				GFP_KERNEL);
+		if (table == NULL)
+			goto err_alloc;
+
+		table[0].data = &net->ieee802154_lowpan.frags.high_thresh;
+		table[1].data = &net->ieee802154_lowpan.frags.low_thresh;
+		table[2].data = &net->ieee802154_lowpan.frags.timeout;
+		table[2].data = &net->ieee802154_lowpan.max_dsize;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			table[0].procname = NULL;
+	}
+
+	hdr = register_net_sysctl(net, "net/ieee802154/6lowpan", table);
+	if (hdr == NULL)
+		goto err_reg;
+
+	net->ieee802154_lowpan.sysctl.frags_hdr = hdr;
+	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(table);
+err_alloc:
+	return -ENOMEM;
+}
+
+static void __net_exit lowpan_frags_ns_sysctl_unregister(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->ieee802154_lowpan.sysctl.frags_hdr->ctl_table_arg;
+	unregister_net_sysctl_table(net->ieee802154_lowpan.sysctl.frags_hdr);
+	if (!net_eq(net, &init_net))
+		kfree(table);
+}
+
+static struct ctl_table_header *lowpan_ctl_header;
+
+static int lowpan_frags_sysctl_register(void)
+{
+	lowpan_ctl_header = register_net_sysctl(&init_net,
+						"net/ieee802154/6lowpan",
+						lowpan_frags_ctl_table);
+	return lowpan_ctl_header == NULL ? -ENOMEM : 0;
+}
+
+static void lowpan_frags_sysctl_unregister(void)
+{
+	unregister_net_sysctl_table(lowpan_ctl_header);
+}
+#else
+static inline int lowpan_frags_ns_sysctl_register(struct net *net)
+{
+	return 0;
+}
+
+static inline void lowpan_frags_ns_sysctl_unregister(struct net *net)
+{
+}
+
+static inline int lowpan_frags_sysctl_register(void)
+{
+	return 0;
+}
+
+static inline void lowpan_frags_sysctl_unregister(void)
+{
+}
+#endif
+
+static int __net_init lowpan_frags_init_net(struct net *net)
+{
+	net->ieee802154_lowpan.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
+	net->ieee802154_lowpan.frags.low_thresh = IPV6_FRAG_LOW_THRESH;
+	net->ieee802154_lowpan.frags.timeout = IPV6_FRAG_TIMEOUT;
+	net->ieee802154_lowpan.max_dsize = 0xFFFF;
+
+	inet_frags_init_net(&net->ieee802154_lowpan.frags);
+
+	return lowpan_frags_ns_sysctl_register(net);
+}
+
+static void __net_exit lowpan_frags_exit_net(struct net *net)
+{
+	lowpan_frags_ns_sysctl_unregister(net);
+	inet_frags_exit_net(&net->ieee802154_lowpan.frags, &lowpan_frags);
+}
+
+static struct pernet_operations lowpan_frags_ops = {
+	.init = lowpan_frags_init_net,
+	.exit = lowpan_frags_exit_net,
+};
+
+int __init lowpan_net_frag_init(void)
+{
+	int ret;
+
+	ret = lowpan_frags_sysctl_register();
+	if (ret)
+		goto out;
+
+	ret = register_pernet_subsys(&lowpan_frags_ops);
+	if (ret)
+		goto err_pernet;
+
+	lowpan_frags.hashfn = lowpan_hashfn;
+	lowpan_frags.constructor = lowpan_frag_init;
+	lowpan_frags.destructor = NULL;
+	lowpan_frags.skb_free = NULL;
+	lowpan_frags.qsize = sizeof(struct frag_queue);
+	lowpan_frags.match = lowpan_frag_match;
+	lowpan_frags.frag_expire = lowpan_frag_expire;
+	lowpan_frags.secret_interval = 10 * 60 * HZ;
+	inet_frags_init(&lowpan_frags);
+err_pernet:
+	lowpan_frags_sysctl_unregister();
+out:
+	return ret;
+}
+
+void lowpan_net_frag_exit(void)
+{
+	inet_frags_fini(&lowpan_frags);
+	lowpan_frags_sysctl_unregister();
+	unregister_pernet_subsys(&lowpan_frags_ops);
+}
diff --git a/net/ieee802154/reassembly.h b/net/ieee802154/reassembly.h
new file mode 100644
index 0000000..055518b
--- /dev/null
+++ b/net/ieee802154/reassembly.h
@@ -0,0 +1,66 @@
+#ifndef __IEEE802154_6LOWPAN_REASSEMBLY_H__
+#define __IEEE802154_6LOWPAN_REASSEMBLY_H__
+
+#include <net/inet_frag.h>
+
+struct lowpan_create_arg {
+	__be16 tag;
+	u16 d_size;
+	const struct ieee802154_addr *src;
+	const struct ieee802154_addr *dst;
+};
+
+/* Equivalent of ipv4 struct ip
+ */
+struct lowpan_frag_queue {
+	struct inet_frag_queue	q;
+
+	__be16			tag;
+	u16			d_size;
+	struct ieee802154_addr	saddr;
+	struct ieee802154_addr	daddr;
+};
+
+static inline u32 ieee802154_addr_hash(const struct ieee802154_addr *a)
+{
+	switch (a->addr_type) {
+	case IEEE802154_ADDR_LONG:
+		return (__force u32)((((u32 *)a->hwaddr))[0] ^
+				      ((u32 *)(a->hwaddr))[1]);
+	case IEEE802154_ADDR_SHORT:
+		return (__force u32)(a->short_addr);
+	default:
+		return 0;
+	}
+}
+
+static inline bool ieee802154_addr_addr_equal(const struct ieee802154_addr *a1,
+				   const struct ieee802154_addr *a2)
+{
+	if (a1->pan_id != a2->pan_id)
+		return false;
+
+	if (a1->addr_type != a2->addr_type)
+		return false;
+
+	switch (a1->addr_type) {
+	case IEEE802154_ADDR_LONG:
+		if (memcmp(a1->hwaddr, a2->hwaddr, IEEE802154_ADDR_LEN))
+			return false;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (a1->short_addr != a2->short_addr)
+			return false;
+		break;
+	default:
+		return false;
+	}
+
+	return true;
+}
+
+int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type);
+void lowpan_net_frag_exit(void);
+int lowpan_net_frag_init(void);
+
+#endif /* __IEEE802154_6LOWPAN_REASSEMBLY_H__ */
-- 
1.9.0
