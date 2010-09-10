From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: af_packet: don't call tpacket_destruct_skb() until the skb is sent out
Date: Fri, 10 Sep 2010 21:22:40 +0800
Message-ID: <1284124960-3266-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62008 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab0IJNXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 09:23:13 -0400
Received: by pzk34 with SMTP id 34so963365pzk.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 06:23:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since skb->destructor() is used to account socket memory, and maybe called
before the skb is sent out, a corrupt skb maybe sent out finally.

A new destructor is added into structure skb_shared_info(), and it won't
be called until the last reference to the data of a skb is put. af_packet
uses this destructor instead.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/skbuff.h |    1 +
 net/core/skbuff.c      |   19 ++++++++++++++-----
 net/packet/af_packet.c |   38 +++++++++++++++++++++++++-------------
 3 files changed, 40 insertions(+), 18 deletions(-)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9e8085a..f874c13 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -191,6 +191,7 @@ struct skb_shared_info {
 	__u8		tx_flags;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
+	void		(*destructor)(struct sk_buff *skb);
 
 	/*
 	 * Warning : all fields before dataref are cleared in __alloc_skb()
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2d1bc76..ff37e54 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -332,10 +332,14 @@ static void skb_release_data(struct sk_buff *skb)
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
-		if (skb_shinfo(skb)->nr_frags) {
+		struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+		if (shinfo->destructor)
+			shinfo->destructor(skb);
+		if (shinfo->nr_frags) {
 			int i;
-			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+			for (i = 0; i < shinfo->nr_frags; i++)
+				put_page(shinfo->frags[i].page);
 		}
 
 		if (skb_has_frag_list(skb))
@@ -497,9 +501,12 @@ bool skb_recycle_check(struct sk_buff *skb, int skb_size)
 	if (skb_shared(skb) || skb_cloned(skb))
 		return false;
 
+	shinfo = skb_shinfo(skb);
+	if (shinfo->destructor)
+		return false;
+
 	skb_release_head_state(skb);
 
-	shinfo = skb_shinfo(skb);
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
 
@@ -799,7 +806,9 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	memcpy((struct skb_shared_info *)(data + size),
 	       skb_shinfo(skb),
-	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
+	       offsetof(struct skb_shared_info,
+			frags[skb_shinfo(skb)->nr_frags]));
+	skb_shinfo(skb)->destructor = NULL;
 
 	/* Check if we can avoid taking references on fragments if we own
 	 * the last reference on skb->head. (see skb_release_data())
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3616f27..7e16b55 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -823,22 +823,27 @@ ring_is_full:
 	goto drop_n_restore;
 }
 
+struct tpacket_destructor_arg {
+	struct sock	*sk;
+	void		*ph;
+};
+
 static void tpacket_destruct_skb(struct sk_buff *skb)
 {
-	struct packet_sock *po = pkt_sk(skb->sk);
-	void *ph;
-
-	BUG_ON(skb == NULL);
+	struct tpacket_destructor_arg *arg = skb_shinfo(skb)->destructor_arg;
+	struct packet_sock *po = pkt_sk(arg->sk);
+	void *ph = arg->ph;
 
 	if (likely(po->tx_ring.pg_vec)) {
-		ph = skb_shinfo(skb)->destructor_arg;
 		BUG_ON(__packet_get_status(po, ph) != TP_STATUS_SENDING);
 		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
 		atomic_dec(&po->tx_ring.pending);
 		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
 	}
 
+	skb->sk = arg->sk;
 	sock_wfree(skb);
+	kfree(arg);
 }
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
@@ -862,7 +867,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
-	skb_shinfo(skb)->destructor_arg = ph.raw;
 
 	switch (po->tp_version) {
 	case TPACKET_V2:
@@ -884,9 +888,8 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	to_write = tp_len;
 
 	if (sock->type == SOCK_DGRAM) {
-		err = dev_hard_header(skb, dev, ntohs(proto), addr,
-				NULL, tp_len);
-		if (unlikely(err < 0))
+		if (unlikely(dev_hard_header(skb, dev, ntohs(proto), addr,
+					     NULL, tp_len) < 0))
 			return -EINVAL;
 	} else if (dev->hard_header_len) {
 		/* net device doesn't like empty head */
@@ -897,8 +900,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		}
 
 		skb_push(skb, dev->hard_header_len);
-		err = skb_store_bits(skb, 0, data,
-				dev->hard_header_len);
+		err = skb_store_bits(skb, 0, data, dev->hard_header_len);
 		if (unlikely(err))
 			return err;
 
@@ -906,7 +908,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		to_write -= dev->hard_header_len;
 	}
 
-	err = -EFAULT;
 	page = virt_to_page(data);
 	offset = offset_in_page(data);
 	len_max = PAGE_SIZE - offset;
@@ -994,6 +995,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		size_max = dev->mtu + reserve;
 
 	do {
+		struct tpacket_destructor_arg *arg;
+
 		ph = packet_current_frame(po, &po->tx_ring,
 				TP_STATUS_SEND_REQUEST);
 
@@ -1028,7 +1031,16 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			}
 		}
 
-		skb->destructor = tpacket_destruct_skb;
+		arg = kmalloc(sizeof(*arg), GFP_KERNEL);
+		if (unlikely(arg == NULL)) {
+			err = -ENOBUFS;
+			goto out_status;
+		}
+		arg->sk = &po->sk;
+		arg->ph = ph;
+		skb_shinfo(skb)->destructor_arg = arg;
+		skb->destructor = NULL;
+		skb_shinfo(skb)->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		atomic_inc(&po->tx_ring.pending);
 
