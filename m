From: David Miller <davem@davemloft.net>
Subject: [INFO PATCH]: Use list_head in sk_buff...
Date: Fri, 19 Sep 2008 15:50:37 -0700 (PDT)
Message-ID: <20080919.155037.37762423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751389AbYISWuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 18:50:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 82DDCC8C181
	for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 15:50:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just want folks to know I have this patch against net-next-2.6

It's been running on my workstation for the better part of the last
day so basic things work fine.  It also passes allmodconfig builds
on sparc64.

But I want to see if I can find some way to do this change in stages
so that the transition is less painful and can be bisected at least
partially.

The biggest pain areas are TIPC and SCTP.  Actually, TIPC gets special
marks for implementing it's own SKB queues in a thousand different
ways instead of using the standard skb_queue_head facilities.  I didn't
even try to do anything special for them in the patch below.

Most things were trivially converted or "just worked" because they used
the generic interfaces for SKB queue management.

You'll also notice that this patch doesn't try to handle the frag lists
specially yet.  That could get the same treatment, making the
skb_shinfo()->frag_list be a list_head too.

Finally, I want to mention that some other things we get from doing this
change:

1) Things that just need a list of SKBs without the lock and the dinky
   qlen thing, can just convert to using a list_head to manage their
   queues.  Just like any other piece of the kernel.

2) It's now easier to add the call_single_data member in that initial
   sk_buff anonymous union member, in order to minimize the space cost,
   in those networking remote softirq patches I posted the other day.


diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 3a504e9..dc6151d 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1115,10 +1115,8 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 	rpp = &vc->rcv.rx_pool;
 
 	rpp->len += skb->len;
-	if (!rpp->count++)
-		rpp->first = skb;
-	*rpp->last = skb;
-	rpp->last = &skb->next;
+	list_add_tail(&skb->list, &rpp->list);
+	rpp->count++;
 
 	if (stat & SAR_RSQE_EPDU) {
 		unsigned char *l1l2;
@@ -1161,12 +1159,9 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 				dev_kfree_skb(skb);
 				return;
 			}
-			sb = rpp->first;
-			for (i = 0; i < rpp->count; i++) {
+			list_for_each_entry(sb, &rpp->list, list)
 				memcpy(skb_put(skb, sb->len),
 				       sb->data, sb->len);
-				sb = sb->next;
-			}
 
 			recycle_rx_pool_skb(card, rpp);
 
@@ -1180,7 +1175,6 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 			return;
 		}
 
-		skb->next = NULL;
 		flush_rx_pool(card, rpp);
 
 		if (!atm_charge(vcc, skb->truesize)) {
@@ -1920,23 +1914,16 @@ flush_rx_pool(struct idt77252_dev *card, struct rx_pool *rpp)
 {
 	rpp->len = 0;
 	rpp->count = 0;
-	rpp->first = NULL;
-	rpp->last = &rpp->first;
+	INIT_LIST_HEAD(&rpp->list);
 }
 
 static void
 recycle_rx_pool_skb(struct idt77252_dev *card, struct rx_pool *rpp)
 {
 	struct sk_buff *skb, *next;
-	int i;
 
-	skb = rpp->first;
-	for (i = 0; i < rpp->count; i++) {
-		next = skb->next;
-		skb->next = NULL;
+	list_for_each_entry_safe(skb, next, &rpp->list, list)
 		recycle_rx_skb(card, skb);
-		skb = next;
-	}
 	flush_rx_pool(card, rpp);
 }
 
diff --git a/drivers/atm/idt77252.h b/drivers/atm/idt77252.h
index e83eaf1..93ee7a9 100644
--- a/drivers/atm/idt77252.h
+++ b/drivers/atm/idt77252.h
@@ -173,8 +173,7 @@ struct scq_info
 };
 
 struct rx_pool {
-	struct sk_buff		*first;
-	struct sk_buff		**last;
+	struct list_head	list;
 	unsigned int		len;
 	unsigned int		count;
 };
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 2f17462..fbda328 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -34,7 +34,6 @@ new_skb(ulong len)
 		skb_reset_network_header(skb);
 		skb->protocol = __constant_htons(ETH_P_AOE);
 		skb->priority = 0;
-		skb->next = skb->prev = NULL;
 
 		/* tell the network layer not to perform IP checksums
 		 * or to get the NIC to do it
@@ -117,7 +116,7 @@ skb_pool_put(struct aoedev *d, struct sk_buff *skb)
 	if (!d->skbpool_hd)
 		d->skbpool_hd = skb;
 	else
-		d->skbpool_tl->next = skb;
+		d->skbpool_tl->frag_next = skb;
 	d->skbpool_tl = skb;
 }
 
@@ -128,8 +127,8 @@ skb_pool_get(struct aoedev *d)
 
 	skb = d->skbpool_hd;
 	if (skb && atomic_read(&skb_shinfo(skb)->dataref) == 1) {
-		d->skbpool_hd = skb->next;
-		skb->next = NULL;
+		d->skbpool_hd = skb->frag_next;
+		skb->frag_next = NULL;
 		return skb;
 	}
 	if (d->nskbpool < NSKBPOOLMAX
@@ -295,7 +294,7 @@ aoecmd_ata_rw(struct aoedev *d)
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (skb) {
 		if (d->sendq_hd)
-			d->sendq_tl->next = skb;
+			d->sendq_tl->frag_next = skb;
 		else
 			d->sendq_hd = skb;
 		d->sendq_tl = skb;
@@ -342,7 +341,7 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigned char aoeminor, struct sk_buff **tail)
 		h->minor = aoeminor;
 		h->cmd = AOECMD_CFG;
 
-		skb->next = sl;
+		skb->frag_next = sl;
 		sl = skb;
 cont:
 		dev_put(ifp);
@@ -407,7 +406,7 @@ resend(struct aoedev *d, struct aoetgt *t, struct frame *f)
 	if (skb == NULL)
 		return;
 	if (d->sendq_hd)
-		d->sendq_tl->next = skb;
+		d->sendq_tl->frag_next = skb;
 	else
 		d->sendq_hd = skb;
 	d->sendq_tl = skb;
diff --git a/drivers/block/aoe/aoedev.c b/drivers/block/aoe/aoedev.c
index a1d813a..c75c4f9 100644
--- a/drivers/block/aoe/aoedev.c
+++ b/drivers/block/aoe/aoedev.c
@@ -191,8 +191,8 @@ skbpoolfree(struct aoedev *d)
 	struct sk_buff *skb;
 
 	while ((skb = d->skbpool_hd)) {
-		d->skbpool_hd = skb->next;
-		skb->next = NULL;
+		d->skbpool_hd = skb->frag_next;
+		skb->frag_next = NULL;
 		skbfree(skb);
 	}
 	d->skbpool_tl = NULL;
diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
index 0c81ca7..f774abf 100644
--- a/drivers/block/aoe/aoenet.c
+++ b/drivers/block/aoe/aoenet.c
@@ -100,8 +100,8 @@ aoenet_xmit(struct sk_buff *sl)
 	struct sk_buff *skb;
 
 	while ((skb = sl)) {
-		sl = sl->next;
-		skb->next = skb->prev = NULL;
+		sl = sl->frag_next;
+		skb->frag_next = NULL;
 		dev_queue_xmit(skb);
 	}
 }
diff --git a/drivers/bluetooth/hci_bcsp.c b/drivers/bluetooth/hci_bcsp.c
index 4d37bb3..575eebb 100644
--- a/drivers/bluetooth/hci_bcsp.c
+++ b/drivers/bluetooth/hci_bcsp.c
@@ -353,7 +353,7 @@ static int bcsp_flush(struct hci_uart *hu)
 static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 {
 	unsigned long flags;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
 	int i, pkts_to_be_removed;
 	u8 seqno;
 
@@ -375,14 +375,13 @@ static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 	BT_DBG("Removing %u pkts out of %u, up to seqno %u",
 		pkts_to_be_removed, bcsp->unack.qlen, (seqno - 1) & 0x07);
 
-	for (i = 0, skb = ((struct sk_buff *) &bcsp->unack)->next; i < pkts_to_be_removed
-			&& skb != (struct sk_buff *) &bcsp->unack; i++) {
-		struct sk_buff *nskb;
+	i = 0;
+	list_for_each_entry_safe(skb, n, &bcsp->unack.list, list) {
+		if (i++ >= pkts_to_be_removed)
+			break;
 
-		nskb = skb->next;
 		__skb_unlink(skb, &bcsp->unack);
 		kfree_skb(skb);
-		skb = nskb;
 	}
 
 	if (bcsp->unack.qlen == 0)
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 127cfda..501749d 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1533,8 +1533,10 @@ static int isdn_ppp_mp_bundle_array_init(void)
 	int sz = ISDN_MAX_CHANNELS*sizeof(ippp_bundle);
 	if( (isdn_ppp_bundle_arr = kzalloc(sz, GFP_KERNEL)) == NULL )
 		return -ENOMEM;
-	for( i = 0; i < ISDN_MAX_CHANNELS; i++ )
+	for( i = 0; i < ISDN_MAX_CHANNELS; i++ ) {
 		spin_lock_init(&isdn_ppp_bundle_arr[i].lock);
+		INIT_LIST_HEAD(&isdn_ppp_bundle_arr[i].frags);
+	}
 	return 0;
 }
 
@@ -1567,7 +1569,7 @@ static int isdn_ppp_mp_init( isdn_net_local * lp, ippp_bundle * add_to )
 		if ((lp->netdev->pb = isdn_ppp_mp_bundle_alloc()) == NULL)
 			return -ENOMEM;
 		lp->next = lp->last = lp;	/* nobody else in a queue */
-		lp->netdev->pb->frags = NULL;
+		INIT_LIST_HEAD(&lp->netdev->pb->frags);
 		lp->netdev->pb->frames = 0;
 		lp->netdev->pb->seq = UINT_MAX;
 	}
@@ -1579,8 +1581,7 @@ static int isdn_ppp_mp_init( isdn_net_local * lp, ippp_bundle * add_to )
 
 static u32 isdn_ppp_mp_get_seq( int short_seq, 
 					struct sk_buff * skb, u32 last_seq );
-static struct sk_buff * isdn_ppp_mp_discard( ippp_bundle * mp,
-			struct sk_buff * from, struct sk_buff * to );
+static void isdn_ppp_mp_discard(ippp_bundle *mp, struct sk_buff *from, struct sk_buff *to);
 static void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
 				struct sk_buff * from, struct sk_buff * to );
 static void isdn_ppp_mp_free_skb( ippp_bundle * mp, struct sk_buff * skb );
@@ -1656,10 +1657,13 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 	newfrag = skb;
 
   	/* if this new fragment is before the first one, then enqueue it now. */
-  	if ((frag = mp->frags) == NULL || MP_LT(newseq, MP_SEQ(frag))) {
-		newfrag->next = frag;
-    		mp->frags = frag = newfrag;
-    		newfrag = NULL;
+	frag = NULL;
+	if (!list_empty(&mp->frags))
+		frag = list_entry(mp->frags.next, struct sk_buff, list);
+  	if (!frag || MP_LT(newseq, MP_SEQ(frag))) {
+		list_add(&newfrag->list, &mp->frags);
+		frag = newfrag;
+		newfrag = NULL;
   	}
 
   	start = MP_FLAGS(frag) & MP_BEGIN_FRAG &&
@@ -1690,7 +1694,10 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
   	while (start != NULL || newfrag != NULL) {
 
     		thisseq = MP_SEQ(frag);
-    		nextf = frag->next;
+		nextf = NULL;
+		if (frag->list.next != &mp->frags)
+			nextf = list_entry(frag->list.next,
+					   struct sk_buff, list);
 
     		/* drop any duplicate fragments */
     		if (newfrag != NULL && thisseq == newseq) {
@@ -1701,8 +1708,8 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
     		/* insert new fragment before next element if possible. */
     		if (newfrag != NULL && (nextf == NULL || 
 						MP_LT(newseq, MP_SEQ(nextf)))) {
-      			newfrag->next = nextf;
-      			frag->next = nextf = newfrag;
+			list_add_tail(&newfrag->list, &nextf->list);
+			nextf = newfrag;
       			newfrag = NULL;
     		}
 
@@ -1713,8 +1720,13 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 				      "BEGIN flag with no prior END", thisseq);
 				stats->seqerrs++;
 				stats->frame_drops++;
-				start = isdn_ppp_mp_discard(mp, start,frag);
-				nextf = frag->next;
+				start = frag;
+				isdn_ppp_mp_discard(mp, start, frag);
+
+				nextf = NULL;
+				if (frag->list.next != &mp->frags)
+					nextf = list_entry(frag->list.next,
+							   struct sk_buff, list);
       			}
     		} else if (MP_LE(thisseq, minseq)) {		
       			if (MP_FLAGS(frag) & MP_BEGIN_FRAG)
@@ -1722,8 +1734,7 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
       			else {
 				if (MP_FLAGS(frag) & MP_END_FRAG)
 	  				stats->frame_drops++;
-				if( mp->frags == frag )
-					mp->frags = nextf;	
+				list_del(&frag->list);
 				isdn_ppp_mp_free_skb(mp, frag);
 				frag = nextf;
 				continue;
@@ -1741,8 +1752,6 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
       
       			start = NULL;
       			frag = NULL;
-
-      			mp->frags = nextf;
     		}
 
 		/* check if need to update start pointer: if we just
@@ -1782,7 +1791,7 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 			 	 * discard all the frames below low watermark 
 				 * and start over */
 				stats->frame_drops++;
-				mp->frags = isdn_ppp_mp_discard(mp,start,nextf);
+				isdn_ppp_mp_discard(mp, start, nextf);
 			}
 			/* break in the sequence, no reassembly */
       			start = NULL;
@@ -1791,32 +1800,29 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
     		frag = nextf;
   	}	/* while -- main loop */
 	
-  	if (mp->frags == NULL)
-    		mp->frags = frag;
+	if (list_empty(&mp->frags))
+		list_add(&frag->list, &mp->frags);
 		
 	/* rather straighforward way to deal with (not very) possible 
 	 * queue overflow */
 	if (mp->frames > MP_MAX_QUEUE_LEN) {
 		stats->overflows++;
 		while (mp->frames > MP_MAX_QUEUE_LEN) {
-			frag = mp->frags->next;
-			isdn_ppp_mp_free_skb(mp, mp->frags);
-			mp->frags = frag;
+			frag = list_entry(mp->frags.next,
+					  struct sk_buff, list);
+			isdn_ppp_mp_free_skb(mp, frag);
 		}
 	}
 	spin_unlock_irqrestore(&mp->lock, flags);
 }
 
-static void isdn_ppp_mp_cleanup( isdn_net_local * lp )
+static void isdn_ppp_mp_cleanup(isdn_net_local *lp)
 {
-	struct sk_buff * frag = lp->netdev->pb->frags;
-	struct sk_buff * nextfrag;
-    	while( frag ) {
-		nextfrag = frag->next;
-		isdn_ppp_mp_free_skb(lp->netdev->pb, frag);
-		frag = nextfrag;
-	}
-	lp->netdev->pb->frags = NULL;
+	ippp_bundle *mp = lp->netdev->pb;
+	struct sk_buff *skb, *n;
+
+	list_for_each_entry_safe(skb, n, &mp->frags, list)
+		isdn_ppp_mp_free_skb(lp->netdev->pb, skb);
 }
 
 static u32 isdn_ppp_mp_get_seq( int short_seq, 
@@ -1853,16 +1859,17 @@ static u32 isdn_ppp_mp_get_seq( int short_seq,
 	return seq;
 }
 
-struct sk_buff * isdn_ppp_mp_discard( ippp_bundle * mp,
-			struct sk_buff * from, struct sk_buff * to )
+void isdn_ppp_mp_discard(ippp_bundle * mp, struct sk_buff *from, struct sk_buff *to)
 {
-	if( from )
-		while (from != to) {
-	  		struct sk_buff * next = from->next;
+	if (!from) {
+		struct sk_buff *n;
+
+		list_for_each_entry_safe_from(from, n, &mp->frags, list) {
+			if (from == to)
+				break;
 			isdn_ppp_mp_free_skb(mp, from);
-	  		from = next;
 		}
-	return from;
+	}
 }
 
 void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
@@ -1889,9 +1896,13 @@ void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
 		struct sk_buff * frag;
 		int n;
 
-		for(tot_len=n=0, frag=from; frag != to; frag=frag->next, n++)
+		tot_len = n = 0;
+		frag = from;
+		list_for_each_entry_from(frag, &mp->frags, list) {
+			if (frag == to)
+				break;
 			tot_len += frag->len - MP_HEADER_LEN;
-
+		}
 		if( ippp_table[lp->ppp_slot]->debug & 0x40 )
 			printk(KERN_DEBUG"isdn_mppp: reassembling frames %d "
 				"to %d, len %d\n", MP_SEQ(from), 
@@ -1903,15 +1914,17 @@ void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
 			return;
 		}
 
-		while( from != to ) {
-			unsigned int len = from->len - MP_HEADER_LEN;
+		list_for_each_entry_safe_from(from, frag, &mp->frags, list) {
+			unsigned int len;
+
+			if (from == to)
+				break;
 
+			len = from->len - MP_HEADER_LEN;
 			skb_copy_from_linear_data_offset(from, MP_HEADER_LEN,
 							 skb_put(skb,len),
 							 len);
-			frag = from->next;
 			isdn_ppp_mp_free_skb(mp, from);
-			from = frag; 
 		}
 	}
    	proto = isdn_ppp_strip_proto(skb);
@@ -1920,6 +1933,7 @@ void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
 
 static void isdn_ppp_mp_free_skb(ippp_bundle * mp, struct sk_buff * skb)
 {
+	list_del(&skb->list);
 	dev_kfree_skb(skb);
 	mp->frames--;
 }
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index f1936d5..40ff6a9 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2182,7 +2182,7 @@ static inline void cas_rx_flow_pkt(struct cas *cp, const u64 *words,
 	 * do any additional locking here. stick the buffer
 	 * at the end.
 	 */
-	__skb_insert(skb, flow->prev, (struct sk_buff *) flow, flow);
+	__skb_queue_tail(flow, skb);
 	if (words[0] & RX_COMP1_RELEASE_FLOW) {
 		while ((skb = __skb_dequeue(flow))) {
 			cas_skb_release(skb);
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 2711404..06aabf4 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -124,8 +124,7 @@ struct sge_rspq {		/* state for an SGE response queue */
 	dma_addr_t phys_addr;	/* physical address of the ring */
 	unsigned int cntxt_id;	/* SGE context id for the response q */
 	spinlock_t lock;	/* guards response processing */
-	struct sk_buff *rx_head;	/* offload packet receive queue head */
-	struct sk_buff *rx_tail;	/* offload packet receive queue tail */
+	struct list_head rx_list;
 	struct sk_buff *pg_skb; /* used to build frag list in napi handler */
 
 	unsigned long offload_pkts;
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 825e510..b3498e8 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -86,6 +86,7 @@ static int setup_l2e_send_pending(struct t3cdev *dev, struct sk_buff *skb,
 				  struct l2t_entry *e)
 {
 	struct cpl_l2t_write_req *req;
+	struct sk_buff *n;
 
 	if (!skb) {
 		skb = alloc_skb(sizeof(*req), GFP_ATOMIC);
@@ -103,13 +104,10 @@ static int setup_l2e_send_pending(struct t3cdev *dev, struct sk_buff *skb,
 	memcpy(req->dst_mac, e->dmac, sizeof(req->dst_mac));
 	skb->priority = CPL_PRIORITY_CONTROL;
 	cxgb3_ofld_send(dev, skb);
-	while (e->arpq_head) {
-		skb = e->arpq_head;
-		e->arpq_head = skb->next;
-		skb->next = NULL;
+	list_for_each_entry_safe(skb, n, &e->arpq, list) {
+		list_del(&skb->list);
 		cxgb3_ofld_send(dev, skb);
 	}
-	e->arpq_tail = NULL;
 	e->state = L2T_STATE_VALID;
 
 	return 0;
@@ -121,12 +119,7 @@ static int setup_l2e_send_pending(struct t3cdev *dev, struct sk_buff *skb,
  */
 static inline void arpq_enqueue(struct l2t_entry *e, struct sk_buff *skb)
 {
-	skb->next = NULL;
-	if (e->arpq_head)
-		e->arpq_tail->next = skb;
-	else
-		e->arpq_head = skb;
-	e->arpq_tail = skb;
+	list_add_tail(&skb->list, &e->arpq);
 }
 
 int t3_l2t_send_slow(struct t3cdev *dev, struct sk_buff *skb,
@@ -167,7 +160,7 @@ again:
 				break;
 
 			spin_lock_bh(&e->lock);
-			if (e->arpq_head)
+			if (!list_empty(&e->arpq))
 				setup_l2e_send_pending(dev, skb, e);
 			else	/* we lost the race */
 				__kfree_skb(skb);
@@ -357,14 +350,13 @@ EXPORT_SYMBOL(t3_l2t_get);
  * XXX: maybe we should abandon the latter behavior and just require a failure
  * handler.
  */
-static void handle_failed_resolution(struct t3cdev *dev, struct sk_buff *arpq)
+static void handle_failed_resolution(struct t3cdev *dev, struct list_head *list)
 {
-	while (arpq) {
-		struct sk_buff *skb = arpq;
+	struct sk_buff *skb, *n;
+	list_for_each_entry_safe(skb, n, list, list) {
 		struct l2t_skb_cb *cb = L2T_SKB_CB(skb);
 
-		arpq = skb->next;
-		skb->next = NULL;
+		list_del(&skb->list);
 		if (cb->arp_failure_handler)
 			cb->arp_failure_handler(dev, skb);
 		else
@@ -379,7 +371,7 @@ static void handle_failed_resolution(struct t3cdev *dev, struct sk_buff *arpq)
 void t3_l2t_update(struct t3cdev *dev, struct neighbour *neigh)
 {
 	struct l2t_entry *e;
-	struct sk_buff *arpq = NULL;
+	LIST_HEAD(arpq);
 	struct l2t_data *d = L2DATA(dev);
 	u32 addr = *(u32 *) neigh->primary_key;
 	int ifidx = neigh->dev->ifindex;
@@ -402,8 +394,7 @@ found:
 
 		if (e->state == L2T_STATE_RESOLVING) {
 			if (neigh->nud_state & NUD_FAILED) {
-				arpq = e->arpq_head;
-				e->arpq_head = e->arpq_tail = NULL;
+				list_splice_init(&e->arpq, &arpq);
 			} else if (neigh->nud_state & (NUD_CONNECTED|NUD_STALE))
 				setup_l2e_send_pending(dev, NULL, e);
 		} else {
@@ -415,8 +406,8 @@ found:
 	}
 	spin_unlock_bh(&e->lock);
 
-	if (arpq)
-		handle_failed_resolution(dev, arpq);
+	if (!list_empty(&arpq))
+		handle_failed_resolution(dev, &arpq);
 }
 
 struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
@@ -436,6 +427,7 @@ struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
 	for (i = 0; i < l2t_capacity; ++i) {
 		d->l2tab[i].idx = i;
 		d->l2tab[i].state = L2T_STATE_UNUSED;
+		INIT_LIST_HEAD(&d->l2tab[i].arpq);
 		spin_lock_init(&d->l2tab[i].lock);
 		atomic_set(&d->l2tab[i].refcnt, 0);
 	}
diff --git a/drivers/net/cxgb3/l2t.h b/drivers/net/cxgb3/l2t.h
index d790013..1b4b390 100644
--- a/drivers/net/cxgb3/l2t.h
+++ b/drivers/net/cxgb3/l2t.h
@@ -64,8 +64,7 @@ struct l2t_entry {
 	struct neighbour *neigh;	/* associated neighbour */
 	struct l2t_entry *first;	/* start of hash chain */
 	struct l2t_entry *next;	/* next l2t_entry on chain */
-	struct sk_buff *arpq_head;	/* queue of packets awaiting resolution */
-	struct sk_buff *arpq_tail;
+	struct list_head arpq;	/* queue of packets awaiting resolution */
 	spinlock_t lock;
 	atomic_t refcnt;	/* entry reference count */
 	u8 dmac[6];		/* neighbour's MAC address */
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 1b0861d..bbd0be2 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1704,16 +1704,14 @@ int t3_offload_tx(struct t3cdev *tdev, struct sk_buff *skb)
  */
 static inline void offload_enqueue(struct sge_rspq *q, struct sk_buff *skb)
 {
-	skb->next = skb->prev = NULL;
-	if (q->rx_tail)
-		q->rx_tail->next = skb;
-	else {
+	int was_empty = list_empty(&q->rx_list);
+
+	list_add_tail(&skb->list, &q->rx_list);
+	if (was_empty) {
 		struct sge_qset *qs = rspq_to_qset(q);
 
 		napi_schedule(&qs->napi);
-		q->rx_head = skb;
 	}
-	q->rx_tail = skb;
 }
 
 /**
@@ -1754,39 +1752,40 @@ static int ofld_poll(struct napi_struct *napi, int budget)
 	int work_done = 0;
 
 	while (work_done < budget) {
-		struct sk_buff *head, *tail, *skbs[RX_BUNDLE_SIZE];
+		struct sk_buff *skb, *n, *skbs[RX_BUNDLE_SIZE];
+		LIST_HEAD(list);
 		int ngathered;
 
 		spin_lock_irq(&q->lock);
-		head = q->rx_head;
-		if (!head) {
+		list_splice_init(&q->rx_list, &list);
+		if (list_empty(&list)) {
 			napi_complete(napi);
 			spin_unlock_irq(&q->lock);
 			return work_done;
 		}
-
-		tail = q->rx_tail;
-		q->rx_head = q->rx_tail = NULL;
 		spin_unlock_irq(&q->lock);
 
-		for (ngathered = 0; work_done < budget && head; work_done++) {
-			prefetch(head->data);
-			skbs[ngathered] = head;
-			head = head->next;
-			skbs[ngathered]->next = NULL;
-			if (++ngathered == RX_BUNDLE_SIZE) {
+		ngathered = 0;
+		list_for_each_entry_safe(skb, n, &list, list) {
+			prefetch(skb->data);
+
+			if (work_done >= budget)
+				break;
+
+			work_done++;
+			list_del(&skb->list);
+			skbs[ngathered++] = skb;
+			if (ngathered == RX_BUNDLE_SIZE) {
 				q->offload_bundles++;
 				adapter->tdev.recv(&adapter->tdev, skbs,
 						   ngathered);
 				ngathered = 0;
 			}
 		}
-		if (head) {	/* splice remaining packets back onto Rx queue */
+
+		if (!list_empty(&list)) { /* splice remaining packets back onto Rx queue */
 			spin_lock_irq(&q->lock);
-			tail->next = q->rx_head;
-			if (!q->rx_head)
-				q->rx_tail = tail;
-			q->rx_head = head;
+			list_splice(&list, &q->rx_list);
 			spin_unlock_irq(&q->lock);
 		}
 		deliver_partial_bundle(&adapter->tdev, q, skbs, ngathered);
@@ -2934,6 +2933,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->rspq.gen = 1;
 	q->rspq.size = p->rspq_size;
 	spin_lock_init(&q->rspq.lock);
+	INIT_LIST_HEAD(&q->rspq.rx_list);
 
 	q->txq[TXQ_ETH].stop_thres = nports *
 	    flits_to_desc(sgl_len(MAX_SKB_FRAGS + 1) + 3);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index d6524db..7bf343e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2851,15 +2851,15 @@ static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
 
 	while (segs) {
 		curr = segs;
-		segs = segs->next;
-		curr->next = NULL;
+		segs = segs->frag_next;
+		curr->frag_next = NULL;
 		status = myri10ge_xmit(curr, dev);
 		if (status != 0) {
 			dev_kfree_skb_any(curr);
 			if (segs != NULL) {
 				curr = segs;
-				segs = segs->next;
-				curr->next = NULL;
+				segs = segs->frag_next;
+				curr->frag_next = NULL;
 				dev_kfree_skb_any(segs);
 			}
 			goto drop;
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index ddccc07..47a23d9 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1833,9 +1833,11 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 
 	/* If the queue is getting long, don't wait any longer for packets
 	   before the start of the queue. */
-	if (skb_queue_len(&ppp->mrq) >= PPP_MP_MAX_QLEN
-	    && seq_before(ppp->minseq, ppp->mrq.next->sequence))
-		ppp->minseq = ppp->mrq.next->sequence;
+	if (skb_queue_len(&ppp->mrq) >= PPP_MP_MAX_QLEN) {
+		struct sk_buff *skb = skb_peek(&ppp->mrq);
+		if (seq_before(ppp->minseq, skb->sequence))
+			ppp->minseq = skb->sequence;
+	}
 
 	/* Pull completed packets off the queue and receive them. */
 	while ((skb = ppp_mp_reconstruct(ppp)))
@@ -1861,10 +1863,11 @@ ppp_mp_insert(struct ppp *ppp, struct sk_buff *skb)
 
 	/* N.B. we don't need to lock the list lock because we have the
 	   ppp unit receive-side lock. */
-	for (p = list->next; p != (struct sk_buff *)list; p = p->next)
+	list_for_each_entry(p, &list->list, list) {
 		if (seq_before(seq, p->sequence))
 			break;
-	__skb_insert(skb, p->prev, p, list);
+	}
+	__skb_insert(skb, p, list);
 }
 
 /*
@@ -1886,10 +1889,10 @@ ppp_mp_reconstruct(struct ppp *ppp)
 
 	if (ppp->mrru == 0)	/* do nothing until mrru is set */
 		return NULL;
-	head = list->next;
+	head = list_entry(list->list.next, struct sk_buff, list);
 	tail = NULL;
-	for (p = head; p != (struct sk_buff *) list; p = next) {
-		next = p->next;
+	for (p = head; &p->list != &list->list; p = next) {
+		next = list_entry(p->list.next, struct sk_buff, list);
 		if (seq_before(p->sequence, seq)) {
 			/* this can't happen, anyway ignore the skb */
 			printk(KERN_ERR "ppp_mp_reconstruct bad seq %u < %u\n",
@@ -1974,15 +1977,16 @@ ppp_mp_reconstruct(struct ppp *ppp)
 
 		if (head != tail)
 			/* copy to a single skb */
-			for (p = head; p != tail->next; p = p->next)
+			for (p = head; &p->list != tail->list.next;
+			     p = list_entry(p->list.next, struct sk_buff, list))
 				skb_copy_bits(p, 0, skb_put(skb, p->len), p->len);
 		ppp->nextseq = tail->sequence + 1;
-		head = tail->next;
+		head = list_entry(tail->list.next, struct sk_buff, list);
 	}
 
 	/* Discard all the skbuffs that we have copied the data out of
 	   or that we can't use. */
-	while ((p = list->next) != head) {
+	while ((p = list_entry(list->list.next, struct sk_buff, list)) != head) {
 		__skb_unlink(p, list);
 		kfree_skb(p);
 	}
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index ff175e8..09dfb10 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -353,7 +353,7 @@ static void pppol2tp_recv_queue_skb(struct pppol2tp_session *session, struct sk_
 	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
 		if (PPPOL2TP_SKB_CB(skbp)->ns > ns) {
-			__skb_insert(skb, skbp->prev, skbp, &session->reorder_q);
+			__skb_insert(skb, skbp, &session->reorder_q);
 			PRINTK(session->debug, PPPOL2TP_MSG_SEQ, KERN_DEBUG,
 			       "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
 			       session->name, ns, PPPOL2TP_SKB_CB(skbp)->ns,
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 243db33..b410d62 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8616,7 +8616,7 @@ static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 	first->data_len = lro->frags_len;
 	skb_pull(skb, (skb->len - tcp_len));
 	if (skb_shinfo(first)->frag_list)
-		lro->last_frag->next = skb;
+		lro->last_frag->frag_next = skb;
 	else
 		skb_shinfo(first)->frag_list = skb;
 	first->truesize += skb->truesize;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1239207..909d962 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4829,8 +4829,8 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 
 	do {
 		nskb = segs;
-		segs = segs->next;
-		nskb->next = NULL;
+		segs = segs->frag_next;
+		nskb->frag_next = NULL;
 		tg3_start_xmit_dma_bug(nskb, tp->dev);
 	} while (segs);
 
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 617ef41..0b9c68d 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -3784,12 +3784,12 @@ de4x5_put_cache(struct net_device *dev, struct sk_buff *skb)
     struct sk_buff *p;
 
     if (lp->cache.skb) {
-	for (p=lp->cache.skb; p->next; p=p->next);
-	p->next = skb;
+	for (p=lp->cache.skb; p->frag_next; p=p->frag_next);
+	p->frag_next = skb;
     } else {
 	lp->cache.skb = skb;
     }
-    skb->next = NULL;
+    skb->frag_next = NULL;
 
     return;
 }
@@ -3801,7 +3801,7 @@ de4x5_putb_cache(struct net_device *dev, struct sk_buff *skb)
     struct sk_buff *p = lp->cache.skb;
 
     lp->cache.skb = skb;
-    skb->next = p;
+    skb->frag_next = p;
 
     return;
 }
@@ -3813,8 +3813,8 @@ de4x5_get_cache(struct net_device *dev)
     struct sk_buff *p = lp->cache.skb;
 
     if (p) {
-	lp->cache.skb = p->next;
-	p->next = NULL;
+	lp->cache.skb = p->frag_next;
+	p->frag_next = NULL;
     }
 
     return p;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8463efb..6d27f73 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -512,14 +512,13 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 	int			count = 0;
 
 	spin_lock_irqsave (&q->lock, flags);
-	for (skb = q->next; skb != (struct sk_buff *) q; skb = skbnext) {
+	list_for_each_entry_safe(skb, skbnext, &q->list, list) {
 		struct skb_data		*entry;
 		struct urb		*urb;
 		int			retval;
 
 		entry = (struct skb_data *) skb->cb;
 		urb = entry->urb;
-		skbnext = skb->next;
 
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index da51786..ea18adc 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -546,15 +546,15 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 	struct p54_common *priv = dev->priv;
 	struct p54_control_hdr *hdr = (struct p54_control_hdr *) skb->data;
 	struct p54_frame_sent_hdr *payload = (struct p54_frame_sent_hdr *) hdr->data;
-	struct sk_buff *entry = (struct sk_buff *) priv->tx_queue.next;
 	u32 addr = le32_to_cpu(hdr->req_id) - priv->headroom;
 	struct memrecord *range = NULL;
+	struct sk_buff *entry;
 	u32 freed = 0;
 	u32 last_addr = priv->rx_start;
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
-	while (entry != (struct sk_buff *)&priv->tx_queue) {
+	list_for_each_entry(entry, &priv->tx_queue.list, list) {
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(entry);
 		range = (void *)info->driver_data;
 		if (range->start_addr == addr) {
@@ -562,11 +562,14 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 			struct p54_tx_control_allocdata *entry_data;
 			int pad = 0;
 
-			if (entry->next != (struct sk_buff *)&priv->tx_queue) {
+			if (entry->list.next != &priv->tx_queue.list) {
 				struct ieee80211_tx_info *ni;
+				struct sk_buff *next;
 				struct memrecord *mr;
 
-				ni = IEEE80211_SKB_CB(entry->next);
+				next = list_entry(entry->list.next,
+						  struct sk_buff, list);
+				ni = IEEE80211_SKB_CB(next);
 				mr = (struct memrecord *)ni->driver_data;
 				freed = mr->start_addr - last_addr;
 			} else
@@ -597,7 +600,6 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 			goto out;
 		} else
 			last_addr = range->end_addr;
-		entry = entry->next;
 	}
 	spin_unlock_irqrestore(&priv->tx_queue.lock, flags);
 
@@ -692,34 +694,31 @@ EXPORT_SYMBOL_GPL(p54_rx);
 static void p54_assign_address(struct ieee80211_hw *dev, struct sk_buff *skb,
 			       struct p54_control_hdr *data, u32 len)
 {
+	struct sk_buff *target_skb = NULL, *entry;
 	struct p54_common *priv = dev->priv;
-	struct sk_buff *entry = priv->tx_queue.next;
-	struct sk_buff *target_skb = NULL;
 	u32 last_addr = priv->rx_start;
 	u32 largest_hole = 0;
 	u32 target_addr = priv->rx_start;
 	unsigned long flags;
-	unsigned int left;
 	len = (len + priv->headroom + priv->tailroom + 3) & ~0x3;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
-	left = skb_queue_len(&priv->tx_queue);
-	while (left--) {
+	list_for_each_entry(entry, &priv->tx_queue.list, list) {
 		u32 hole_size;
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(entry);
 		struct memrecord *range = (void *)info->driver_data;
 		hole_size = range->start_addr - last_addr;
 		if (!target_skb && hole_size >= len) {
-			target_skb = entry->prev;
+			target_skb = list_entry(entry->list.prev,
+						struct sk_buff, list);
 			hole_size -= len;
 			target_addr = last_addr;
 		}
 		largest_hole = max(largest_hole, hole_size);
 		last_addr = range->end_addr;
-		entry = entry->next;
 	}
 	if (!target_skb && priv->rx_end - last_addr >= len) {
-		target_skb = priv->tx_queue.prev;
+		target_skb = skb_peek_tail(&priv->tx_queue);
 		largest_hole = max(largest_hole, priv->rx_end - last_addr - len);
 		if (!skb_queue_empty(&priv->tx_queue)) {
 			struct ieee80211_tx_info *info = IEEE80211_SKB_CB(target_skb);
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index 8a42bfa..13a58c2 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -278,7 +278,7 @@ static void rtl8187_rx_cb(struct urb *urb)
 	u32 quality;
 
 	spin_lock(&priv->rx_queue.lock);
-	if (skb->next)
+	if (!list_empty(&skb->list))
 		__skb_unlink(skb, &priv->rx_queue);
 	else {
 		spin_unlock(&priv->rx_queue.lock);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index e019102..13fc601 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -579,12 +579,11 @@ static int filter_ack(struct ieee80211_hw *hw, struct ieee80211_hdr *rx_hdr,
 
 	q = &zd_hw_mac(hw)->ack_wait_queue;
 	spin_lock_irqsave(&q->lock, flags);
-	for (skb = q->next; skb != (struct sk_buff *)q; skb = skb->next) {
+	list_for_each_entry(skb, &q->list, list) {
 		struct ieee80211_hdr *tx_hdr;
 
 		tx_hdr = (struct ieee80211_hdr *)skb->data;
-		if (likely(!compare_ether_addr(tx_hdr->addr2, rx_hdr->addr1)))
-		{
+		if (likely(!compare_ether_addr(tx_hdr->addr2, rx_hdr->addr1))) {
 			__skb_unlink(skb, q);
 			tx_status(hw, skb, IEEE80211_TX_STAT_ACK, stats->signal, 1);
 			goto out;
diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index 0722872..1adafda 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -640,14 +640,13 @@ static void usbatm_cancel_send(struct usbatm_data *instance,
 
 	atm_dbg(instance, "%s entered\n", __func__);
 	spin_lock_irq(&instance->sndqueue.lock);
-	for (skb = instance->sndqueue.next, n = skb->next;
-	     skb != (struct sk_buff *)&instance->sndqueue;
-	     skb = n, n = skb->next)
+	list_for_each_entry_safe(skb, n, &instance->sndqueue.list, list) {
 		if (UDSL_SKB(skb)->atm.vcc == vcc) {
 			atm_dbg(instance, "%s: popping skb 0x%p\n", __func__, skb);
 			__skb_unlink(skb, &instance->sndqueue);
 			usbatm_pop(vcc, skb);
 		}
+	}
 	spin_unlock_irq(&instance->sndqueue.lock);
 
 	tasklet_disable(&instance->tx_channel.tasklet);
diff --git a/include/linux/isdn_ppp.h b/include/linux/isdn_ppp.h
index 8687a7d..06c9063 100644
--- a/include/linux/isdn_ppp.h
+++ b/include/linux/isdn_ppp.h
@@ -157,7 +157,7 @@ typedef struct {
 
 typedef struct {
   int mp_mrru;                        /* unused                             */
-  struct sk_buff * frags;	/* fragments sl list -- use skb->next */
+  struct list_head frags;	/* fragments sl list */
   long frames;			/* number of frames in the frame list */
   unsigned int seq;		/* last processed packet seq #: any packets
   				 * with smaller seq # will be dropped
diff --git a/include/linux/list.h b/include/linux/list.h
index 969f6e9..4e7b91b 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -471,6 +471,18 @@ static inline void list_splice_tail_init(struct list_head *list,
 	     pos = list_entry(pos->member.next, typeof(*pos), member))
 
 /**
+ * list_for_each_entry_from_reverse
+ * @pos:	the type * to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ *
+ * Iterate over list of given type, continuing from current position.
+ */
+#define list_for_each_entry_from_reverse(pos, head, member) 		\
+	for (; prefetch(pos->member.prev), &pos->member != (head);	\
+	     pos = list_entry(pos->member.prev, typeof(*pos), member))
+
+/**
  * list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
  * @pos:	the type * to use as a loop cursor.
  * @n:		another type * to use as temporary storage
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index aa80ad9..489140c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -114,12 +114,9 @@ struct nf_bridge_info {
 #endif
 
 struct sk_buff_head {
-	/* These two members must be first. */
-	struct sk_buff	*next;
-	struct sk_buff	*prev;
-
-	__u32		qlen;
-	spinlock_t	lock;
+	struct list_head	list;
+	__u32			qlen;
+	spinlock_t		lock;
 };
 
 struct sk_buff;
@@ -257,9 +254,10 @@ typedef unsigned char *sk_buff_data_t;
  */
 
 struct sk_buff {
-	/* These two members must be first. */
-	struct sk_buff		*next;
-	struct sk_buff		*prev;
+	union {
+		struct list_head	list;
+		struct sk_buff		*frag_next;
+	};
 
 	struct sock		*sk;
 	ktime_t			tstamp;
@@ -469,7 +467,7 @@ static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
  */
 static inline int skb_queue_empty(const struct sk_buff_head *list)
 {
-	return list->next == (struct sk_buff *)list;
+	return list_empty(&list->list);
 }
 
 /**
@@ -622,10 +620,10 @@ static inline struct sk_buff *skb_unshare(struct sk_buff *skb,
  */
 static inline struct sk_buff *skb_peek(struct sk_buff_head *list_)
 {
-	struct sk_buff *list = ((struct sk_buff *)list_)->next;
-	if (list == (struct sk_buff *)list_)
-		list = NULL;
-	return list;
+	struct list_head *list = &list_->list;
+	if (list_empty(list))
+		return NULL;
+	return list_entry(list->next, struct sk_buff, list);
 }
 
 /**
@@ -643,10 +641,10 @@ static inline struct sk_buff *skb_peek(struct sk_buff_head *list_)
  */
 static inline struct sk_buff *skb_peek_tail(struct sk_buff_head *list_)
 {
-	struct sk_buff *list = ((struct sk_buff *)list_)->prev;
-	if (list == (struct sk_buff *)list_)
-		list = NULL;
-	return list;
+	struct list_head *list = &list_->list;
+	if (list_empty(list))
+		return NULL;
+	return list_entry(list->prev, struct sk_buff, list);
 }
 
 /**
@@ -670,8 +668,8 @@ static inline __u32 skb_queue_len(const struct sk_buff_head *list_)
  */
 static inline void skb_queue_head_init(struct sk_buff_head *list)
 {
+	INIT_LIST_HEAD(&list->list);
 	spin_lock_init(&list->lock);
-	list->prev = list->next = (struct sk_buff *)list;
 	list->qlen = 0;
 }
 
@@ -689,13 +687,10 @@ static inline void skb_queue_head_init_class(struct sk_buff_head *list,
  *	can only be called with interrupts disabled.
  */
 extern void        skb_insert(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list);
-static inline void __skb_insert(struct sk_buff *newsk,
-				struct sk_buff *prev, struct sk_buff *next,
+static inline void __skb_insert(struct sk_buff *newsk, struct sk_buff *next,
 				struct sk_buff_head *list)
 {
-	newsk->next = next;
-	newsk->prev = prev;
-	next->prev  = prev->next = newsk;
+	list_add_tail(&newsk->list, &next->list);
 	list->qlen++;
 }
 
@@ -714,19 +709,13 @@ static inline void __skb_queue_after(struct sk_buff_head *list,
 				     struct sk_buff *prev,
 				     struct sk_buff *newsk)
 {
-	__skb_insert(newsk, prev, prev->next, list);
+	list_add(&newsk->list, &prev->list);
+	list->qlen++;
 }
 
 extern void skb_append(struct sk_buff *old, struct sk_buff *newsk,
 		       struct sk_buff_head *list);
 
-static inline void __skb_queue_before(struct sk_buff_head *list,
-				      struct sk_buff *next,
-				      struct sk_buff *newsk)
-{
-	__skb_insert(newsk, next->prev, next, list);
-}
-
 /**
  *	__skb_queue_head - queue a buffer at the list head
  *	@list: list to use
@@ -741,7 +730,8 @@ extern void skb_queue_head(struct sk_buff_head *list, struct sk_buff *newsk);
 static inline void __skb_queue_head(struct sk_buff_head *list,
 				    struct sk_buff *newsk)
 {
-	__skb_queue_after(list, (struct sk_buff *)list, newsk);
+	list_add(&newsk->list, &list->list);
+	list->qlen++;
 }
 
 /**
@@ -758,7 +748,8 @@ extern void skb_queue_tail(struct sk_buff_head *list, struct sk_buff *newsk);
 static inline void __skb_queue_tail(struct sk_buff_head *list,
 				   struct sk_buff *newsk)
 {
-	__skb_queue_before(list, (struct sk_buff *)list, newsk);
+	list_add_tail(&newsk->list, &list->list);
+	list->qlen++;
 }
 
 /*
@@ -768,14 +759,9 @@ static inline void __skb_queue_tail(struct sk_buff_head *list,
 extern void	   skb_unlink(struct sk_buff *skb, struct sk_buff_head *list);
 static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
 {
-	struct sk_buff *next, *prev;
-
 	list->qlen--;
-	next	   = skb->next;
-	prev	   = skb->prev;
-	skb->next  = skb->prev = NULL;
-	next->prev = prev;
-	prev->next = next;
+	list_del(&skb->list);
+	skb->list.next = skb->list.prev = NULL;
 }
 
 /**
@@ -1439,20 +1425,13 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 }
 
 #define skb_queue_walk(queue, skb) \
-		for (skb = (queue)->next;					\
-		     prefetch(skb->next), (skb != (struct sk_buff *)(queue));	\
-		     skb = skb->next)
+	list_for_each_entry(skb, &(queue)->list, list)
 
 #define skb_queue_walk_safe(queue, skb, tmp)					\
-		for (skb = (queue)->next, tmp = skb->next;			\
-		     skb != (struct sk_buff *)(queue);				\
-		     skb = tmp, tmp = skb->next)
+	list_for_each_entry_safe(skb, tmp, &(queue)->list, list)
 
 #define skb_queue_reverse_walk(queue, skb) \
-		for (skb = (queue)->prev;					\
-		     prefetch(skb->prev), (skb != (struct sk_buff *)(queue));	\
-		     skb = skb->prev)
-
+	list_for_each_entry_reverse(skb, &(queue)->list, list)
 
 extern struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 					   int *peeked, int *err);
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 6f8418b..d998517 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -164,7 +164,7 @@ static inline int skb_frags_no(struct sk_buff *skb)
 	register struct sk_buff *frag = skb_shinfo(skb)->frag_list;
 	register int n = 1;
 
-	for (; frag; frag=frag->next, n++);
+	for (; frag; frag=frag->frag_next, n++);
 	return n;
 }
 
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 17b932b..26ac109 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -406,10 +406,7 @@ struct sctp_association *sctp_id2assoc(struct sock *sk, sctp_assoc_t id);
 
 /* A macro to walk a list of skbs.  */
 #define sctp_skb_for_each(pos, head, tmp) \
-for (pos = (head)->next;\
-     tmp = (pos)->next, pos != ((struct sk_buff *)(head));\
-     pos = tmp)
-
+	list_for_each_entry_safe(pos, tmp, &(head)->list, list)
 
 /* A helper to append an entire skb list (list) to another (head). */
 static inline void sctp_skb_list_tail(struct sk_buff_head *list,
@@ -420,7 +417,7 @@ static inline void sctp_skb_list_tail(struct sk_buff_head *list,
 	sctp_spin_lock_irqsave(&head->lock, flags);
 	sctp_spin_lock(&list->lock);
 
-	list_splice((struct list_head *)list, (struct list_head *)head->prev);
+	list_splice_tail_init(&list->list, &head->list);
 
 	head->qlen += list->qlen;
 	list->qlen = 0;
diff --git a/include/net/sock.h b/include/net/sock.h
index 75a312d..c29b4bd 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -223,10 +223,7 @@ struct sock {
 	 * the per-socket spinlock held and requires low latency
 	 * access. Therefore we special case it's implementation.
 	 */
-	struct {
-		struct sk_buff *head;
-		struct sk_buff *tail;
-	} sk_backlog;
+	struct list_head	sk_backlog;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
 	struct xfrm_policy	*sk_policy[2];
@@ -473,13 +470,7 @@ static inline int sk_stream_memory_free(struct sock *sk)
 /* The per-socket spinlock must be held here. */
 static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
-	if (!sk->sk_backlog.tail) {
-		sk->sk_backlog.head = sk->sk_backlog.tail = skb;
-	} else {
-		sk->sk_backlog.tail->next = skb;
-		sk->sk_backlog.tail = skb;
-	}
-	skb->next = NULL;
+	list_add_tail(&skb->list, &sk->sk_backlog);
 }
 
 #define sk_wait_event(__sk, __timeo, __condition)			\
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8983386..23c9e99 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1180,38 +1180,27 @@ static inline void tcp_write_queue_purge(struct sock *sk)
 
 static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
 {
-	struct sk_buff *skb = sk->sk_write_queue.next;
-	if (skb == (struct sk_buff *) &sk->sk_write_queue)
-		return NULL;
-	return skb;
+	return skb_peek(&sk->sk_write_queue);
 }
 
 static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
 {
-	struct sk_buff *skb = sk->sk_write_queue.prev;
-	if (skb == (struct sk_buff *) &sk->sk_write_queue)
-		return NULL;
-	return skb;
+	return skb_peek_tail(&sk->sk_write_queue);
 }
 
 static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_buff *skb)
 {
-	return skb->next;
+	return list_entry(skb->list.next, struct sk_buff, list);
 }
 
 #define tcp_for_write_queue(skb, sk)					\
-		for (skb = (sk)->sk_write_queue.next;			\
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = skb->next)
+	list_for_each_entry(skb, &(sk)->sk_write_queue.list, list)
 
 #define tcp_for_write_queue_from(skb, sk)				\
-		for (; (skb != (struct sk_buff *)&(sk)->sk_write_queue);\
-		     skb = skb->next)
+	list_for_each_entry_from(skb, &(sk)->sk_write_queue.list, list)
 
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
-		for (tmp = skb->next;					\
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = tmp, tmp = skb->next)
+	list_for_each_entry_safe_from(skb, tmp, &(sk)->sk_write_queue.list, list)
 
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
@@ -1220,9 +1209,10 @@ static inline struct sk_buff *tcp_send_head(struct sock *sk)
 
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
-	sk->sk_send_head = skb->next;
-	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
+	if (skb->list.next == &sk->sk_write_queue.list)
 		sk->sk_send_head = NULL;
+	else
+		sk->sk_send_head = tcp_write_queue_next(sk, skb);
 }
 
 static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unlinked)
@@ -1272,7 +1262,7 @@ static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sk_buff *skb,
 						  struct sock *sk)
 {
-	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+	__skb_insert(new, skb, &sk->sk_write_queue);
 
 	if (sk->sk_send_head == skb)
 		sk->sk_send_head = new;
@@ -1286,7 +1276,7 @@ static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 static inline int tcp_skb_is_last(const struct sock *sk,
 				  const struct sk_buff *skb)
 {
-	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
+	return skb->list.next == &sk->sk_write_queue.list;
 }
 
 static inline int tcp_write_queue_empty(struct sock *sk)
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 0c85042..da43560 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -983,7 +983,7 @@ static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 8d9a6f1..4f25ef8 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -454,12 +454,13 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 {
 	int err;
 	struct br2684_vcc *brvcc;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
 	struct sk_buff_head *rq;
 	struct br2684_dev *brdev;
 	struct net_device *net_dev;
 	struct atm_backend_br2684 be;
 	unsigned long flags;
+	LIST_HEAD(list);
 
 	if (copy_from_user(&be, arg, sizeof be))
 		return -EFAULT;
@@ -515,26 +516,15 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
 
 	spin_lock_irqsave(&rq->lock, flags);
-	if (skb_queue_empty(rq)) {
-		skb = NULL;
-	} else {
-		/* NULL terminate the list.  */
-		rq->prev->next = NULL;
-		skb = rq->next;
-	}
-	rq->prev = rq->next = (struct sk_buff *)rq;
+	list_splice_init(&rq->list, &list);
 	rq->qlen = 0;
 	spin_unlock_irqrestore(&rq->lock, flags);
 
-	while (skb) {
-		struct sk_buff *next = skb->next;
-
-		skb->next = skb->prev = NULL;
+	list_for_each_entry_safe(skb, n, &list, list) {
+		list_del(&skb->list);
 		br2684_push(atmvcc, skb);
 		BRPRIV(skb->dev)->stats.rx_bytes -= skb->len;
 		BRPRIV(skb->dev)->stats.rx_packets--;
-
-		skb = next;
 	}
 	__module_get(THIS_MODULE);
 	return 0;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 5b5b963..916aba6 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -450,8 +450,9 @@ static struct net_device_stats *clip_get_stats(struct net_device *dev)
 
 static int clip_mkip(struct atm_vcc *vcc, int timeout)
 {
+	LIST_HEAD(rq_list);
 	struct clip_vcc *clip_vcc;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
 	struct sk_buff_head *rq;
 	unsigned long flags;
 
@@ -477,22 +478,12 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 	rq = &sk_atm(vcc)->sk_receive_queue;
 
 	spin_lock_irqsave(&rq->lock, flags);
-	if (skb_queue_empty(rq)) {
-		skb = NULL;
-	} else {
-		/* NULL terminate the list.  */
-		rq->prev->next = NULL;
-		skb = rq->next;
-	}
-	rq->prev = rq->next = (struct sk_buff *)rq;
+	list_splice_init(&rq->list, &rq_list);
 	rq->qlen = 0;
 	spin_unlock_irqrestore(&rq->lock, flags);
 
 	/* re-process everything received between connection setup and MKIP */
-	while (skb) {
-		struct sk_buff *next = skb->next;
-
-		skb->next = skb->prev = NULL;
+	list_for_each_entry_safe(skb, n, &rq_list, list) {
 		if (!clip_devs) {
 			atm_return(vcc, skb->truesize);
 			kfree_skb(skb);
@@ -505,8 +496,6 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 			PRIV(skb->dev)->stats.rx_bytes -= len;
 			kfree_skb(skb);
 		}
-
-		skb = next;
 	}
 	return 0;
 }
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index f5b21cb..109c48b 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1220,7 +1220,7 @@ int hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 flags)
 
 		__skb_queue_tail(&conn->data_q, skb);
 		do {
-			skb = list; list = list->next;
+			skb = list; list = list->frag_next;
 
 			skb->dev = (void *) hdev;
 			bt_cb(skb)->pkt_type = HCI_ACLDATA_PKT;
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 9610a9c..c079333 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1069,7 +1069,7 @@ static inline int l2cap_do_send(struct sock *sk, struct msghdr *msg, int len)
 		sent += count;
 		len  -= count;
 
-		frag = &(*frag)->next;
+		frag = &(*frag)->frag_next;
 	}
 
 	if ((err = hci_send_acl(conn->hcon, skb, 0)) < 0)
@@ -1358,7 +1358,7 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn,
 		len  -= count;
 		data += count;
 
-		frag = &(*frag)->next;
+		frag = &(*frag)->frag_next;
 	}
 
 	return skb;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 52f577a..0de47a6 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -312,7 +312,7 @@ int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
@@ -398,7 +398,7 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
@@ -486,7 +486,7 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list=list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
diff --git a/net/core/dev.c b/net/core/dev.c
index f48d1b2..d0d1375 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1367,7 +1367,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
 
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
-		skb->next = sd->completion_queue;
+		skb->frag_next = sd->completion_queue;
 		sd->completion_queue = skb;
 		raise_softirq_irqoff(NET_TX_SOFTIRQ);
 		local_irq_restore(flags);
@@ -1577,12 +1577,12 @@ static void dev_gso_skb_destructor(struct sk_buff *skb)
 	struct dev_gso_cb *cb;
 
 	do {
-		struct sk_buff *nskb = skb->next;
+		struct sk_buff *nskb = skb->frag_next;
 
-		skb->next = nskb->next;
-		nskb->next = NULL;
+		skb->frag_next = nskb->frag_next;
+		nskb->frag_next = NULL;
 		kfree_skb(nskb);
-	} while (skb->next);
+	} while (skb->frag_next);
 
 	cb = DEV_GSO_CB(skb);
 	if (cb->destructor)
@@ -1612,7 +1612,7 @@ static int dev_gso_segment(struct sk_buff *skb)
 	if (IS_ERR(segs))
 		return PTR_ERR(segs);
 
-	skb->next = segs;
+	skb->frag_next = segs;
 	DEV_GSO_CB(skb)->destructor = skb->destructor;
 	skb->destructor = dev_gso_skb_destructor;
 
@@ -1622,14 +1622,14 @@ static int dev_gso_segment(struct sk_buff *skb)
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
-	if (likely(!skb->next)) {
+	if (likely(!skb->frag_next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
 		if (netif_needs_gso(dev, skb)) {
 			if (unlikely(dev_gso_segment(skb)))
 				goto out_kfree_skb;
-			if (skb->next)
+			if (skb->frag_next)
 				goto gso;
 		}
 
@@ -1638,20 +1638,20 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 gso:
 	do {
-		struct sk_buff *nskb = skb->next;
+		struct sk_buff *nskb = skb->frag_next;
 		int rc;
 
-		skb->next = nskb->next;
-		nskb->next = NULL;
+		skb->frag_next = nskb->frag_next;
+		nskb->frag_next = NULL;
 		rc = dev->hard_start_xmit(nskb, dev);
 		if (unlikely(rc)) {
-			nskb->next = skb->next;
-			skb->next = nskb;
+			nskb->frag_next = skb->frag_next;
+			skb->frag_next = nskb;
 			return rc;
 		}
-		if (unlikely(netif_tx_queue_stopped(txq) && skb->next))
+		if (unlikely(netif_tx_queue_stopped(txq) && skb->frag_next))
 			return NETDEV_TX_BUSY;
-	} while (skb->next);
+	} while (skb->frag_next);
 
 	skb->destructor = DEV_GSO_CB(skb)->destructor;
 
@@ -1961,7 +1961,7 @@ static void net_tx_action(struct softirq_action *h)
 
 		while (clist) {
 			struct sk_buff *skb = clist;
-			clist = clist->next;
+			clist = clist->frag_next;
 
 			WARN_ON(atomic_read(&skb->users));
 			__kfree_skb(skb);
@@ -4504,7 +4504,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	/* Find end of our completion_queue. */
 	list_skb = &sd->completion_queue;
 	while (*list_skb)
-		list_skb = &(*list_skb)->next;
+		list_skb = &(*list_skb)->frag_next;
 	/* Append completion queue from offline CPU. */
 	*list_skb = oldsd->completion_queue;
 	oldsd->completion_queue = NULL;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 9d92e41..45bc7a6 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -927,8 +927,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 			if (skb_queue_len(&neigh->arp_queue) >=
 			    neigh->parms->queue_len) {
 				struct sk_buff *buff;
-				buff = neigh->arp_queue.next;
-				__skb_unlink(buff, &neigh->arp_queue);
+				buff = __skb_dequeue(&neigh->arp_queue);
 				kfree_skb(buff);
 				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
 			}
@@ -1259,24 +1258,20 @@ static void neigh_proxy_process(unsigned long arg)
 	struct neigh_table *tbl = (struct neigh_table *)arg;
 	long sched_next = 0;
 	unsigned long now = jiffies;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
 
 	spin_lock(&tbl->proxy_queue.lock);
 
-	skb = tbl->proxy_queue.next;
-
-	while (skb != (struct sk_buff *)&tbl->proxy_queue) {
-		struct sk_buff *back = skb;
-		long tdif = NEIGH_CB(back)->sched_next - now;
+	list_for_each_entry_safe(skb, n, &tbl->proxy_queue.list, list) {
+		long tdif = NEIGH_CB(skb)->sched_next - now;
 
-		skb = skb->next;
 		if (tdif <= 0) {
-			struct net_device *dev = back->dev;
-			__skb_unlink(back, &tbl->proxy_queue);
+			struct net_device *dev = skb->dev;
+			__skb_unlink(skb, &tbl->proxy_queue);
 			if (tbl->proxy_redo && netif_running(dev))
-				tbl->proxy_redo(back);
+				tbl->proxy_redo(skb);
 			else
-				kfree_skb(back);
+				kfree_skb(skb);
 
 			dev_put(dev);
 		} else if (!sched_next || tdif < sched_next)
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 6c7af39..74e9a1c 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -217,7 +217,7 @@ static void zap_completion_queue(void)
 
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
-			clist = clist->next;
+			clist = clist->frag_next;
 			if (skb->destructor) {
 				atomic_inc(&skb->users);
 				dev_kfree_skb_any(skb); /* put this one back */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ca1ccdf..0922c35 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -287,15 +287,13 @@ EXPORT_SYMBOL(dev_alloc_skb);
 
 static void skb_drop_list(struct sk_buff **listp)
 {
-	struct sk_buff *list = *listp;
+	struct sk_buff *skb = *listp;
 
-	*listp = NULL;
-
-	do {
-		struct sk_buff *this = list;
-		list = list->next;
-		kfree_skb(this);
-	} while (list);
+	while (skb) {
+		struct sk_buff *next = skb->frag_next;
+		kfree_skb(skb);
+		skb = next;
+	}
 }
 
 static inline void skb_drop_fraglist(struct sk_buff *skb)
@@ -305,10 +303,10 @@ static inline void skb_drop_fraglist(struct sk_buff *skb)
 
 static void skb_clone_fraglist(struct sk_buff *skb)
 {
-	struct sk_buff *list;
+	struct sk_buff *n;
 
-	for (list = skb_shinfo(skb)->frag_list; list; list = list->next)
-		skb_get(list);
+	for (n = skb_shinfo(skb)->frag_list; n; n = n->frag_next)
+		skb_get(n);
 }
 
 static void skb_release_data(struct sk_buff *skb)
@@ -468,7 +466,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 {
 #define C(x) n->x = skb->x
 
-	n->next = n->prev = NULL;
+	n->list.next = n->list.prev = NULL;
 	n->sk = NULL;
 	__copy_skb_header(n, skb);
 
@@ -998,7 +996,7 @@ drop_pages:
 	}
 
 	for (fragp = &skb_shinfo(skb)->frag_list; (frag = *fragp);
-	     fragp = &frag->next) {
+	     fragp = &frag->frag_next) {
 		int end = offset + frag->len;
 
 		if (skb_shared(frag)) {
@@ -1008,7 +1006,7 @@ drop_pages:
 			if (unlikely(!nfrag))
 				return -ENOMEM;
 
-			nfrag->next = frag->next;
+			nfrag->frag_next = frag->frag_next;
 			kfree_skb(frag);
 			frag = nfrag;
 			*fragp = frag;
@@ -1023,8 +1021,8 @@ drop_pages:
 		    unlikely((err = pskb_trim(frag, len - offset))))
 			return err;
 
-		if (frag->next)
-			skb_drop_list(&frag->next);
+		if (frag->frag_next)
+			skb_drop_list(&frag->frag_next);
 		break;
 	}
 
@@ -1115,7 +1113,7 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 			if (list->len <= eat) {
 				/* Eaten as whole. */
 				eat -= list->len;
-				list = list->next;
+				list = list->frag_next;
 				insp = list;
 			} else {
 				/* Eaten partially. */
@@ -1125,7 +1123,7 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 					clone = skb_clone(list, GFP_ATOMIC);
 					if (!clone)
 						return NULL;
-					insp = list->next;
+					insp = list->frag_next;
 					list = clone;
 				} else {
 					/* This may be pulled without
@@ -1143,12 +1141,12 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 
 		/* Free pulled out fragments. */
 		while ((list = skb_shinfo(skb)->frag_list) != insp) {
-			skb_shinfo(skb)->frag_list = list->next;
+			skb_shinfo(skb)->frag_list = list->frag_next;
 			kfree_skb(list);
 		}
 		/* And insert new clone at head. */
 		if (clone) {
-			clone->next = list;
+			clone->frag_next = list;
 			skb_shinfo(skb)->frag_list = clone;
 		}
 	}
@@ -1229,7 +1227,7 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
@@ -1409,7 +1407,7 @@ int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list && tlen; list = list->next) {
+		for (; list && tlen; list = list->frag_next) {
 			if (__skb_splice_bits(list, &offset, &tlen, &spd))
 				break;
 		}
@@ -1503,7 +1501,7 @@ int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len)
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
@@ -1581,7 +1579,7 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
@@ -1661,7 +1659,7 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			__wsum csum2;
 			int end;
 
@@ -1864,7 +1862,8 @@ void skb_insert(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head
 	unsigned long flags;
 
 	spin_lock_irqsave(&list->lock, flags);
-	__skb_insert(newsk, old->prev, old, list);
+	list_add_tail(&newsk->list, &old->list);
+	list->qlen++;
 	spin_unlock_irqrestore(&list->lock, flags);
 }
 
@@ -2039,8 +2038,8 @@ next_skb:
 		st->frag_data = NULL;
 	}
 
-	if (st->cur_skb->next) {
-		st->cur_skb = st->cur_skb->next;
+	if (st->cur_skb->frag_next) {
+		st->cur_skb = st->cur_skb->frag_next;
 		st->frag_idx = 0;
 		goto next_skb;
 	} else if (st->root_skb == st->cur_skb &&
@@ -2251,7 +2250,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 			goto err;
 
 		if (segs)
-			tail->next = nskb;
+			tail->frag_next = nskb;
 		else
 			segs = nskb;
 		tail = nskb;
@@ -2315,7 +2314,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 
 err:
 	while ((skb = segs)) {
-		segs = skb->next;
+		segs = skb->frag_next;
 		kfree_skb(skb);
 	}
 	return ERR_PTR(err);
@@ -2389,7 +2388,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
@@ -2485,7 +2484,7 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 
 		/* If the skb is the last, worry about trailer. */
 
-		if (skb1->next == NULL && tailbits) {
+		if (skb1->frag_next == NULL && tailbits) {
 			if (skb_shinfo(skb1)->nr_frags ||
 			    skb_shinfo(skb1)->frag_list ||
 			    skb_tailroom(skb1) < tailbits)
@@ -2516,14 +2515,14 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 			/* Looking around. Are we still alive?
 			 * OK, link new skb, drop old one */
 
-			skb2->next = skb1->next;
+			skb2->frag_next = skb1->frag_next;
 			*skb_p = skb2;
 			kfree_skb(skb1);
 			skb1 = skb2;
 		}
 		elt++;
 		*trailer = skb1;
-		skb_p = &skb1->next;
+		skb_p = &skb1->frag_next;
 	}
 
 	return elt;
diff --git a/net/core/sock.c b/net/core/sock.c
index 23b8b9d..3b856e2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -947,6 +947,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		 */
 		sk->sk_prot = sk->sk_prot_creator = prot;
 		sock_lock_init(sk);
+		INIT_LIST_HEAD(&sk->sk_backlog);
 		sock_net_set(sk, get_net(net));
 	}
 
@@ -1011,7 +1012,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
-		newsk->sk_backlog.head	= newsk->sk_backlog.tail = NULL;
+		INIT_LIST_HEAD(&newsk->sk_backlog);
 
 		atomic_set(&newsk->sk_rmem_alloc, 0);
 		atomic_set(&newsk->sk_wmem_alloc, 0);
@@ -1361,16 +1362,15 @@ static void __lock_sock(struct sock *sk)
 
 static void __release_sock(struct sock *sk)
 {
-	struct sk_buff *skb = sk->sk_backlog.head;
-
 	do {
-		sk->sk_backlog.head = sk->sk_backlog.tail = NULL;
-		bh_unlock_sock(sk);
+		LIST_HEAD(local_list);
+		struct sk_buff *skb, *n;
 
-		do {
-			struct sk_buff *next = skb->next;
+		list_splice_init(&sk->sk_backlog, &local_list);
+		bh_unlock_sock(sk);
 
-			skb->next = NULL;
+		list_for_each_entry_safe(skb, n, &local_list, list) {
+			INIT_LIST_HEAD(&skb->list);
 			sk->sk_backlog_rcv(sk, skb);
 
 			/*
@@ -1380,12 +1380,10 @@ static void __release_sock(struct sock *sk)
 			 * queue private:
 			 */
 			cond_resched_softirq();
-
-			skb = next;
-		} while (skb != NULL);
+		}
 
 		bh_lock_sock(sk);
-	} while ((skb = sk->sk_backlog.head) != NULL);
+	} while (!list_empty(&sk->sk_backlog));
 }
 
 /**
@@ -1767,7 +1765,7 @@ void release_sock(struct sock *sk)
 	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
 
 	spin_lock_bh(&sk->sk_lock.slock);
-	if (sk->sk_backlog.tail)
+	if (!list_empty(&sk->sk_backlog))
 		__release_sock(sk);
 	sk->sk_lock.owned = 0;
 	if (waitqueue_active(&sk->sk_lock.wq))
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 3c23ab3..6677cf5 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1249,14 +1249,8 @@ static int dn_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		if ((skb = skb_peek(&scp->other_receive_queue)) != NULL) {
 			amount = skb->len;
 		} else {
-			struct sk_buff *skb = sk->sk_receive_queue.next;
-			for(;;) {
-				if (skb ==
-				    (struct sk_buff *)&sk->sk_receive_queue)
-					break;
+			list_for_each_entry(skb, &sk->sk_receive_queue.list, list)
 				amount += skb->len;
-				skb = skb->next;
-			}
 		}
 		release_sock(sk);
 		err = put_user(amount, (int __user *)arg);
@@ -1643,13 +1637,13 @@ static int __dn_getsockopt(struct socket *sock, int level,int optname, char __us
 
 static int dn_data_ready(struct sock *sk, struct sk_buff_head *q, int flags, int target)
 {
-	struct sk_buff *skb = q->next;
+	struct sk_buff *skb;
 	int len = 0;
 
 	if (flags & MSG_OOB)
 		return !skb_queue_empty(q) ? 1 : 0;
 
-	while(skb != (struct sk_buff *)q) {
+	list_for_each_entry(skb, &q->list, list) {
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
 		len += skb->len;
 
@@ -1665,8 +1659,6 @@ static int dn_data_ready(struct sock *sk, struct sk_buff_head *q, int flags, int
 		/* minimum data length for read exceeded */
 		if (len >= target)
 			return 1;
-
-		skb = skb->next;
 	}
 
 	return 0;
@@ -1682,7 +1674,7 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 	size_t target = size > 1 ? 1 : 0;
 	size_t copied = 0;
 	int rv = 0;
-	struct sk_buff *skb, *nskb;
+	struct sk_buff *skb, *n;
 	struct dn_skb_cb *cb = NULL;
 	unsigned char eor = 0;
 	long timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
@@ -1757,7 +1749,7 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 		finish_wait(sk->sk_sleep, &wait);
 	}
 
-	for(skb = queue->next; skb != (struct sk_buff *)queue; skb = nskb) {
+	list_for_each_entry_safe(skb, n, &queue->list, list) {
 		unsigned int chunk = skb->len;
 		cb = DN_SKB_CB(skb);
 
@@ -1774,7 +1766,6 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 			skb_pull(skb, chunk);
 
 		eor = cb->nsp_flags & 0x40;
-		nskb = skb->next;
 
 		if (skb->len == 0) {
 			skb_unlink(skb, queue);
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 1964faf..2adc681 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -383,7 +383,7 @@ int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb, struct sk_buff
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 	struct dn_scp *scp = DN_SK(sk);
-	struct sk_buff *skb2, *list, *ack = NULL;
+	struct sk_buff *skb2, *n, *ack = NULL;
 	int wakeup = 0;
 	int try_retrans = 0;
 	unsigned long reftime = cb->stamp;
@@ -391,9 +391,7 @@ int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb, struct sk_buff
 	unsigned short xmit_count;
 	unsigned short segnum;
 
-	skb2 = q->next;
-	list = (struct sk_buff *)q;
-	while(list != skb2) {
+	list_for_each_entry_safe(skb2, n, &q->list, list) {
 		struct dn_skb_cb *cb2 = DN_SKB_CB(skb2);
 
 		if (dn_before_or_equal(cb2->segnum, acknum))
@@ -401,8 +399,6 @@ int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb, struct sk_buff
 
 		/* printk(KERN_DEBUG "ack: %s %04x %04x\n", ack ? "ACK" : "SKIP", (int)cb2->segnum, (int)acknum); */
 
-		skb2 = skb2->next;
-
 		if (ack == NULL)
 			continue;
 
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 8789d2b..7b7461d 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -901,15 +901,10 @@ static void aun_tx_ack(unsigned long seq, int result)
 	struct ec_cb *eb;
 
 	spin_lock_irqsave(&aun_queue_lock, flags);
-	skb = skb_peek(&aun_queue);
-	while (skb && skb != (struct sk_buff *)&aun_queue)
-	{
-		struct sk_buff *newskb = skb->next;
+	list_for_each_entry(skb, &aun_queue.list, list) {
 		eb = (struct ec_cb *)&skb->cb;
 		if (eb->seq == seq)
 			goto foundit;
-
-		skb = newskb;
 	}
 	spin_unlock_irqrestore(&aun_queue_lock, flags);
 	printk(KERN_DEBUG "AUN: unknown sequence %ld\n", seq);
@@ -982,23 +977,18 @@ static void aun_data_available(struct sock *sk, int slen)
 
 static void ab_cleanup(unsigned long h)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb, *n;
 	unsigned long flags;
 
 	spin_lock_irqsave(&aun_queue_lock, flags);
-	skb = skb_peek(&aun_queue);
-	while (skb && skb != (struct sk_buff *)&aun_queue)
-	{
-		struct sk_buff *newskb = skb->next;
+	list_for_each_entry_safe(skb, n, &aun_queue.list, list) {
 		struct ec_cb *eb = (struct ec_cb *)&skb->cb;
-		if ((jiffies - eb->start) > eb->timeout)
-		{
+		if ((jiffies - eb->start) > eb->timeout) {
 			tx_result(skb->sk, eb->cookie,
 				  ECTYPE_TRANSMIT_NOT_PRESENT);
 			skb_unlink(skb, &aun_queue);
 			kfree_skb(skb);
 		}
-		skb = newskb;
 	}
 	spin_unlock_irqrestore(&aun_queue_lock, flags);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8a3ac1f..794e79b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1238,7 +1238,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 		iph->tot_len = htons(skb->len - skb->mac_len);
 		iph->check = 0;
 		iph->check = ip_fast_csum(skb_network_header(skb), iph->ihl);
-	} while ((skb = skb->next));
+	} while ((skb = skb->frag_next));
 
 out:
 	return segs;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 6c52e08..f4d9ff5 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -141,7 +141,7 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 	fp = q->fragments;
 	nf = q->net;
 	while (fp) {
-		struct sk_buff *xp = fp->next;
+		struct sk_buff *xp = fp->frag_next;
 
 		frag_kfree_skb(nf, f, fp, work);
 		fp = xp;
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index cfd034a..e5732eb 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -227,7 +227,7 @@ static void lro_add_packet(struct net_lro_desc *lro_desc, struct sk_buff *skb,
 	parent->truesize += skb->truesize;
 
 	if (lro_desc->last_skb)
-		lro_desc->last_skb->next = skb;
+		lro_desc->last_skb->frag_next = skb;
 	else
 		skb_shinfo(parent)->frag_list = skb;
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 2152d22..b3b241e 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -281,7 +281,7 @@ static int ip_frag_reinit(struct ipq *qp)
 
 	fp = qp->q.fragments;
 	do {
-		struct sk_buff *xp = fp->next;
+		struct sk_buff *xp = fp->frag_next;
 		frag_kfree_skb(qp->q.net, fp, NULL);
 		fp = xp;
 	} while (fp);
@@ -363,7 +363,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	 * this fragment, right?
 	 */
 	prev = NULL;
-	for (next = qp->q.fragments; next != NULL; next = next->next) {
+	for (next = qp->q.fragments; next != NULL; next = next->frag_next) {
 		if (FRAG_CB(next)->offset >= offset)
 			break;	/* bingo! */
 		prev = next;
@@ -411,10 +411,10 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 			/* Old fragment is completely overridden with
 			 * new one drop it.
 			 */
-			next = next->next;
+			next = next->frag_next;
 
 			if (prev)
-				prev->next = next;
+				prev->frag_next = next;
 			else
 				qp->q.fragments = next;
 
@@ -426,9 +426,9 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	FRAG_CB(skb)->offset = offset;
 
 	/* Insert this fragment in the chain of fragments. */
-	skb->next = next;
+	skb->frag_next = next;
 	if (prev)
-		prev->next = skb;
+		prev->frag_next = skb;
 	else
 		qp->q.fragments = skb;
 
@@ -473,16 +473,16 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 
 	/* Make the one we just received the head. */
 	if (prev) {
-		head = prev->next;
+		head = prev->frag_next;
 		fp = skb_clone(head, GFP_ATOMIC);
 		if (!fp)
 			goto out_nomem;
 
-		fp->next = head->next;
-		prev->next = fp;
+		fp->frag_next = head->frag_next;
+		prev->frag_next = fp;
 
 		skb_morph(head, qp->q.fragments);
-		head->next = qp->q.fragments->next;
+		head->frag_next = qp->q.fragments->frag_next;
 
 		kfree_skb(qp->q.fragments);
 		qp->q.fragments = head;
@@ -512,8 +512,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 
 		if ((clone = alloc_skb(0, GFP_ATOMIC)) == NULL)
 			goto out_nomem;
-		clone->next = head->next;
-		head->next = clone;
+		clone->frag_next = head->frag_next;
+		head->frag_next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list = NULL;
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
@@ -526,11 +526,11 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		atomic_add(clone->truesize, &qp->q.net->mem);
 	}
 
-	skb_shinfo(head)->frag_list = head->next;
+	skb_shinfo(head)->frag_list = head->frag_next;
 	skb_push(head, head->data - skb_network_header(head));
 	atomic_sub(head->truesize, &qp->q.net->mem);
 
-	for (fp=head->next; fp; fp = fp->next) {
+	for (fp=head->frag_next; fp; fp = fp->frag_next) {
 		head->data_len += fp->len;
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
@@ -541,7 +541,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		atomic_sub(fp->truesize, &qp->q.net->mem);
 	}
 
-	head->next = NULL;
+	head->frag_next = NULL;
 	head->dev = dev;
 	head->tstamp = qp->q.stamp;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d533a89..0d2cd9a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -484,10 +484,10 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 		    skb_cloned(skb))
 			goto slow_path;
 
-		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->frag_next) {
 			/* Correct geometry. */
 			if (frag->len > mtu ||
-			    ((frag->len & 7) && frag->next) ||
+			    ((frag->len & 7) && frag->frag_next) ||
 			    skb_headroom(frag) < hlen)
 			    goto slow_path;
 
@@ -533,7 +533,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 					ip_options_fragment(frag);
 				offset += skb->len - hlen;
 				iph->frag_off = htons(offset>>3);
-				if (frag->next != NULL)
+				if (frag->frag_next != NULL)
 					iph->frag_off |= htons(IP_MF);
 				/* Ready, complete checksum */
 				ip_send_check(iph);
@@ -547,8 +547,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 				break;
 
 			skb = frag;
-			frag = skb->next;
-			skb->next = NULL;
+			frag = skb->frag_next;
+			skb->frag_next = NULL;
 		}
 
 		if (err == 0) {
@@ -557,7 +557,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 		}
 
 		while (frag) {
-			skb = frag->next;
+			skb = frag->frag_next;
 			kfree_skb(frag);
 			frag = skb;
 		}
@@ -1229,7 +1229,7 @@ int ip_push_pending_frames(struct sock *sk)
 	while ((tmp_skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
 		__skb_pull(tmp_skb, skb_network_header_len(skb));
 		*tail_skb = tmp_skb;
-		tail_skb = &(tmp_skb->next);
+		tail_skb = &(tmp_skb->frag_next);
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/ipv4/netfilter/nf_nat_proto_sctp.c
index 65e470b..9dc5a67 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
@@ -57,7 +57,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	}
 
 	crc32 = sctp_start_cksum((u8 *)hdr, skb_headlen(skb) - hdroff);
-	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->next)
+	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->frag_next)
 		crc32 = sctp_update_cksum((u8 *)skb->data, skb_headlen(skb),
 					  crc32);
 	crc32 = sctp_end_cksum(crc32);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ab341e..2310ee6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -433,12 +433,15 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 			 !tp->urg_data ||
 			 before(tp->urg_seq, tp->copied_seq) ||
 			 !before(tp->urg_seq, tp->rcv_nxt)) {
+			struct sk_buff *last;
+
 			answ = tp->rcv_nxt - tp->copied_seq;
 
 			/* Subtract 1, if FIN is in queue. */
+			last = list_entry(sk->sk_receive_queue.list.prev,
+					  struct sk_buff, list);
 			if (answ && !skb_queue_empty(&sk->sk_receive_queue))
-				answ -=
-		       tcp_hdr((struct sk_buff *)sk->sk_receive_queue.prev)->fin;
+				answ -= tcp_hdr(last)->fin;
 		} else
 			answ = tp->urg_seq - tp->copied_seq;
 		release_sock(sk);
@@ -1338,11 +1341,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 		/* Next get a buffer. */
 
-		skb = skb_peek(&sk->sk_receive_queue);
-		do {
-			if (!skb)
-				break;
-
+		list_for_each_entry(skb, &sk->sk_receive_queue.list, list) {
 			/* Now that we have two receive queues this
 			 * shouldn't happen.
 			 */
@@ -1359,12 +1358,11 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
 			WARN_ON(!(flags & MSG_PEEK));
-			skb = skb->next;
-		} while (skb != (struct sk_buff *)&sk->sk_receive_queue);
+		}
 
 		/* Well, if we have backlog, try to process it now yet. */
 
-		if (copied >= target && !sk->sk_backlog.tail)
+		if (copied >= target && list_empty(&sk->sk_backlog))
 			break;
 
 		if (copied) {
@@ -2440,12 +2438,12 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
 						    thlen, skb->csum));
 
 		seq += len;
-		skb = skb->next;
+		skb = skb->frag_next;
 		th = tcp_hdr(skb);
 
 		th->seq = htonl(seq);
 		th->cwr = 0;
-	} while (skb->next);
+	} while (skb->frag_next);
 
 	delta = htonl(oldlen + (skb->tail - skb->transport_header) +
 		      skb->data_len);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f79a516..aca677d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4106,7 +4106,7 @@ drop:
 		}
 		__skb_queue_head(&tp->out_of_order_queue, skb);
 	} else {
-		struct sk_buff *skb1 = tp->out_of_order_queue.prev;
+		struct sk_buff *skb1 = skb_peek_tail(&tp->out_of_order_queue);
 		u32 seq = TCP_SKB_CB(skb)->seq;
 		u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
@@ -4123,14 +4123,13 @@ drop:
 		}
 
 		/* Find place to insert this segment. */
-		do {
+		list_for_each_entry_from_reverse(skb1, &tp->out_of_order_queue.list, list) {
 			if (!after(TCP_SKB_CB(skb1)->seq, seq))
 				break;
-		} while ((skb1 = skb1->prev) !=
-			 (struct sk_buff *)&tp->out_of_order_queue);
+		}
 
 		/* Do skb overlap to previous one? */
-		if (skb1 != (struct sk_buff *)&tp->out_of_order_queue &&
+		if (&skb1->list != &tp->out_of_order_queue.list &&
 		    before(seq, TCP_SKB_CB(skb1)->end_seq)) {
 			if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 				/* All the bits are present. Drop. */
@@ -4143,24 +4142,27 @@ drop:
 				tcp_dsack_set(sk, seq,
 					      TCP_SKB_CB(skb1)->end_seq);
 			} else {
-				skb1 = skb1->prev;
+				skb1 = list_entry(skb1->list.prev,
+						  struct sk_buff,
+						  list);
 			}
 		}
-		__skb_insert(skb, skb1, skb1->next, &tp->out_of_order_queue);
+		list_add(&skb->list, &skb1->list);
+		tp->out_of_order_queue.qlen++;
 
 		/* And clean segments covered by new one as whole. */
-		while ((skb1 = skb->next) !=
-		       (struct sk_buff *)&tp->out_of_order_queue &&
-		       after(end_seq, TCP_SKB_CB(skb1)->seq)) {
-			if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
-				tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
+		list_for_each_entry_safe_continue(skb, skb1, &tp->out_of_order_queue.list, list) {
+			if (!after(end_seq, TCP_SKB_CB(skb)->seq))
+				break;
+			if (before(end_seq, TCP_SKB_CB(skb)->end_seq)) {
+				tcp_dsack_extend(sk, TCP_SKB_CB(skb)->seq,
 						 end_seq);
 				break;
 			}
-			__skb_unlink(skb1, &tp->out_of_order_queue);
-			tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
-					 TCP_SKB_CB(skb1)->end_seq);
-			__kfree_skb(skb1);
+			__skb_unlink(skb, &tp->out_of_order_queue);
+			tcp_dsack_extend(sk, TCP_SKB_CB(skb)->seq,
+					 TCP_SKB_CB(skb)->end_seq);
+			__kfree_skb(skb);
 		}
 
 add_sack:
@@ -4172,7 +4174,7 @@ add_sack:
 static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buff *skb,
 					struct sk_buff_head *list)
 {
-	struct sk_buff *next = skb->next;
+	struct sk_buff *next = list_entry(skb->list.next, struct sk_buff, list);
 
 	__skb_unlink(skb, list);
 	__kfree_skb(skb);
@@ -4196,12 +4198,16 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 	/* First, check that queue is collapsible and find
 	 * the point where collapsing can be useful. */
 	for (skb = head; skb != tail;) {
+		struct sk_buff *next;
+
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 			skb = tcp_collapse_one(sk, skb, list);
 			continue;
 		}
 
+		next = list_entry(skb->list.next, struct sk_buff, list);
+
 		/* The first skb to collapse is:
 		 * - not SYN/FIN and
 		 * - bloated or contains data before "start" or
@@ -4210,13 +4216,13 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 		if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
 		    (tcp_win_from_space(skb->truesize) > skb->len ||
 		     before(TCP_SKB_CB(skb)->seq, start) ||
-		     (skb->next != tail &&
-		      TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb->next)->seq)))
+		     (next != tail &&
+		      TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(next)->seq)))
 			break;
 
 		/* Decided to skip this, advance start seq. */
 		start = TCP_SKB_CB(skb)->end_seq;
-		skb = skb->next;
+		skb = next;
 	}
 	if (skb == tail || tcp_hdr(skb)->syn || tcp_hdr(skb)->fin)
 		return;
@@ -4244,7 +4250,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 		memcpy(nskb->head, skb->head, header);
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
 		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
-		__skb_insert(nskb, skb->prev, skb, list);
+		__skb_insert(nskb, skb, list);
 		skb_set_owner_r(nskb, sk);
 
 		/* Copy data, releasing collapsed skbs. */
@@ -4290,7 +4296,7 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
 	head = skb;
 
 	for (;;) {
-		skb = skb->next;
+		skb = list_entry(skb->list.next, struct sk_buff, list);
 
 		/* Segment is terminated when we see gap or when
 		 * we are at the end of all the queue. */
@@ -4362,8 +4368,10 @@ static int tcp_prune_queue(struct sock *sk)
 
 	tcp_collapse_ofo_queue(sk);
 	tcp_collapse(sk, &sk->sk_receive_queue,
-		     sk->sk_receive_queue.next,
-		     (struct sk_buff *)&sk->sk_receive_queue,
+		     list_entry(sk->sk_receive_queue.list.next,
+				struct sk_buff, list),
+		     list_entry(&sk->sk_receive_queue.list,
+				struct sk_buff, list),
 		     tp->copied_seq, tp->rcv_nxt);
 	sk_mem_reclaim(sk);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 95055f8..98884ab 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,7 +766,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 	if (unlikely(IS_ERR(segs)))
 		goto out;
 
-	for (skb = segs; skb; skb = skb->next) {
+	for (skb = segs; skb; skb = skb->frag_next) {
 		ipv6h = ipv6_hdr(skb);
 		ipv6h->payload_len = htons(skb->len - skb->mac_len -
 					   sizeof(*ipv6h));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3df2c44..b45eb1a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -657,10 +657,10 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		    skb_cloned(skb))
 			goto slow_path;
 
-		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+		for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->frag_next) {
 			/* Correct geometry. */
 			if (frag->len > mtu ||
-			    ((frag->len & 7) && frag->next) ||
+			    ((frag->len & 7) && frag->frag_next) ||
 			    skb_headroom(frag) < hlen)
 			    goto slow_path;
 
@@ -726,7 +726,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				fh->nexthdr = nexthdr;
 				fh->reserved = 0;
 				fh->frag_off = htons(offset);
-				if (frag->next != NULL)
+				if (frag->frag_next != NULL)
 					fh->frag_off |= htons(IP6_MF);
 				fh->identification = frag_id;
 				ipv6_hdr(frag)->payload_len =
@@ -743,8 +743,8 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				break;
 
 			skb = frag;
-			frag = skb->next;
-			skb->next = NULL;
+			frag = skb->frag_next;
+			skb->frag_next = NULL;
 		}
 
 		kfree(tmp_hdr);
@@ -756,7 +756,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		}
 
 		while (frag) {
-			skb = frag->next;
+			skb = frag->frag_next;
 			kfree_skb(frag);
 			frag = skb;
 		}
@@ -1428,7 +1428,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	while ((tmp_skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
 		__skb_pull(tmp_skb, skb_network_header_len(skb));
 		*tail_skb = tmp_skb;
-		tail_skb = &(tmp_skb->next);
+		tail_skb = &(tmp_skb->frag_next);
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 52d06dd..f7955eb 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -302,7 +302,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	 * this fragment, right?
 	 */
 	prev = NULL;
-	for (next = fq->q.fragments; next != NULL; next = next->next) {
+	for (next = fq->q.fragments; next != NULL; next = next->frag_next) {
 		if (NFCT_FRAG6_CB(next)->offset >= offset)
 			break;	/* bingo! */
 		prev = next;
@@ -357,10 +357,10 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 			/* Old fragmnet is completely overridden with
 			 * new one drop it.
 			 */
-			next = next->next;
+			next = next->frag_next;
 
 			if (prev)
-				prev->next = next;
+				prev->frag_next = next;
 			else
 				fq->q.fragments = next;
 
@@ -372,9 +372,9 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	NFCT_FRAG6_CB(skb)->offset = offset;
 
 	/* Insert this fragment in the chain of fragments. */
-	skb->next = next;
+	skb->frag_next = next;
 	if (prev)
-		prev->next = skb;
+		prev->frag_next = skb;
 	else
 		fq->q.fragments = skb;
 
@@ -445,8 +445,8 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 			pr_debug("Can't alloc skb\n");
 			goto out_oom;
 		}
-		clone->next = head->next;
-		head->next = clone;
+		clone->frag_next = head->frag_next;
+		head->frag_next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list = NULL;
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
@@ -469,12 +469,12 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	head->mac_header += sizeof(struct frag_hdr);
 	head->network_header += sizeof(struct frag_hdr);
 
-	skb_shinfo(head)->frag_list = head->next;
+	skb_shinfo(head)->frag_list = head->frag_next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
 	atomic_sub(head->truesize, &nf_init_frags.mem);
 
-	for (fp=head->next; fp; fp = fp->next) {
+	for (fp=head->frag_next; fp; fp = fp->frag_next) {
 		head->data_len += fp->len;
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
@@ -485,7 +485,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		atomic_sub(fp->truesize, &nf_init_frags.mem);
 	}
 
-	head->next = NULL;
+	head->frag_next = NULL;
 	head->dev = dev;
 	head->tstamp = fq->q.stamp;
 	ipv6_hdr(head)->payload_len = htons(payload_len);
@@ -502,13 +502,13 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	fp = skb_shinfo(head)->frag_list;
 	if (NFCT_FRAG6_CB(fp)->orig == NULL)
 		/* at above code, head skb is divided into two skbs. */
-		fp = fp->next;
+		fp = fp->frag_next;
 
 	op = NFCT_FRAG6_CB(head)->orig;
-	for (; fp; fp = fp->next) {
+	for (; fp; fp = fp->frag_next) {
 		struct sk_buff *orig = NFCT_FRAG6_CB(fp)->orig;
 
-		op->next = orig;
+		op->frag_next = orig;
 		op = orig;
 		NFCT_FRAG6_CB(fp)->orig = NULL;
 	}
@@ -677,8 +677,8 @@ void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
 		nf_conntrack_get_reasm(skb);
 		s->nfct_reasm = skb;
 
-		s2 = s->next;
-		s->next = NULL;
+		s2 = s->frag_next;
+		s->frag_next = NULL;
 
 		NF_HOOK_THRESH(PF_INET6, hooknum, s, in, out, okfn,
 			       NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 89184b5..8140afe 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -337,7 +337,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	 * this fragment, right?
 	 */
 	prev = NULL;
-	for(next = fq->q.fragments; next != NULL; next = next->next) {
+	for(next = fq->q.fragments; next != NULL; next = next->frag_next) {
 		if (FRAG6_CB(next)->offset >= offset)
 			break;	/* bingo! */
 		prev = next;
@@ -384,10 +384,10 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			/* Old fragment is completely overridden with
 			 * new one drop it.
 			 */
-			next = next->next;
+			next = next->frag_next;
 
 			if (prev)
-				prev->next = next;
+				prev->frag_next = next;
 			else
 				fq->q.fragments = next;
 
@@ -399,9 +399,9 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	FRAG6_CB(skb)->offset = offset;
 
 	/* Insert this fragment in the chain of fragments. */
-	skb->next = next;
+	skb->frag_next = next;
 	if (prev)
-		prev->next = skb;
+		prev->frag_next = skb;
 	else
 		fq->q.fragments = skb;
 
@@ -457,17 +457,17 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 
 	/* Make the one we just received the head. */
 	if (prev) {
-		head = prev->next;
+		head = prev->frag_next;
 		fp = skb_clone(head, GFP_ATOMIC);
 
 		if (!fp)
 			goto out_oom;
 
-		fp->next = head->next;
-		prev->next = fp;
+		fp->frag_next = head->frag_next;
+		prev->frag_next = fp;
 
 		skb_morph(head, fq->q.fragments);
-		head->next = fq->q.fragments->next;
+		head->frag_next = fq->q.fragments->frag_next;
 
 		kfree_skb(fq->q.fragments);
 		fq->q.fragments = head;
@@ -496,8 +496,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 
 		if ((clone = alloc_skb(0, GFP_ATOMIC)) == NULL)
 			goto out_oom;
-		clone->next = head->next;
-		head->next = clone;
+		clone->frag_next = head->frag_next;
+		head->frag_next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_shinfo(head)->frag_list = NULL;
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
@@ -519,12 +519,12 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	head->mac_header += sizeof(struct frag_hdr);
 	head->network_header += sizeof(struct frag_hdr);
 
-	skb_shinfo(head)->frag_list = head->next;
+	skb_shinfo(head)->frag_list = head->frag_next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
 	atomic_sub(head->truesize, &fq->q.net->mem);
 
-	for (fp=head->next; fp; fp = fp->next) {
+	for (fp=head->frag_next; fp; fp = fp->frag_next) {
 		head->data_len += fp->len;
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
@@ -535,7 +535,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		atomic_sub(fp->truesize, &fq->q.net->mem);
 	}
 
-	head->next = NULL;
+	head->frag_next = NULL;
 	head->dev = dev;
 	head->tstamp = fq->q.stamp;
 	ipv6_hdr(head)->payload_len = htons(payload_len);
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index f17b65a..4f86435 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -991,8 +991,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 	count = skb_queue_len(&self->wx_list);
 
 	/*  Resend unacknowledged frame(s) */
-	skb = skb_peek(&self->wx_list);
-	while (skb != NULL) {
+	list_for_each_entry(skb, &self->wx_list.list, list) {
 		irlap_wait_min_turn_around(self, &self->qos_tx);
 
 		/* We copy the skb to be retransmitted since we will have to
@@ -1023,9 +1022,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 		 *  we are finished, if not, move to the next sk-buffer
 		 */
 		if (skb == skb_peek_tail(&self->wx_list))
-			skb = NULL;
-		else
-			skb = skb->next;
+			break;
 	}
 #if 0 /* Not yet */
 	/*
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 5bcc452..261363a 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -715,7 +715,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 		}
 		/* Well, if we have backlog, try to process it now yet. */
 
-		if (copied >= target && !sk->sk_backlog.tail)
+		if (copied >= target && list_empty(&sk->sk_backlog))
 			break;
 
 		if (copied) {
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 5c6d89c..2b986a3 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -83,7 +83,7 @@ int llc_conn_state_process(struct sock *sk, struct sk_buff *skb)
 		 * XXX indicate/confirm-needed state in the llc_conn_state_ev
 		 * XXX control block of the SKB instead? -DaveM
 		 */
-		if (!skb->next)
+		if (list_empty(&skb->list))
 			goto out_kfree_skb;
 		goto out_skb_put;
 	}
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 48212c0..d3e2332 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -182,7 +182,7 @@ static int llc_seq_core_show(struct seq_file *seq, void *v)
 		   timer_pending(&llc->pf_cycle_timer.timer),
 		   timer_pending(&llc->rej_sent_timer.timer),
 		   timer_pending(&llc->busy_state_timer.timer),
-		   !!sk->sk_backlog.tail, !!sock_owned_by_user(sk));
+		   !list_empty(&sk->sk_backlog), !!sock_owned_by_user(sk));
 out:
 	return 0;
 }
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 210d6b8..536700f 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -808,10 +808,8 @@ int mesh_nexthop_lookup(struct sk_buff *skb,
 		}
 
 		if (skb_queue_len(&mpath->frame_queue) >=
-				MESH_FRAME_QUEUE_LEN) {
-			skb_to_free = mpath->frame_queue.next;
-			skb_unlink(skb_to_free, &mpath->frame_queue);
-		}
+				MESH_FRAME_QUEUE_LEN)
+			skb_to_free = skb_dequeue(&mpath->frame_queue);
 
 		skb_queue_tail(&mpath->frame_queue, skb);
 		if (skb_to_free)
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index d080379..04c1ccd 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -793,7 +793,7 @@ ieee80211_reassemble_add(struct ieee80211_sub_if_data *sdata,
 	if (!skb_queue_empty(&entry->skb_list)) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		struct ieee80211_hdr *hdr =
-			(struct ieee80211_hdr *) entry->skb_list.next->data;
+			(struct ieee80211_hdr *) skb_peek(&entry->skb_list)->data;
 		DECLARE_MAC_BUF(mac);
 		DECLARE_MAC_BUF(mac2);
 		printk(KERN_DEBUG "%s: RX reassembly removed oldest "
@@ -841,7 +841,7 @@ ieee80211_reassemble_find(struct ieee80211_sub_if_data *sdata,
 		    entry->last_frag + 1 != frag)
 			continue;
 
-		f_hdr = (struct ieee80211_hdr *)entry->skb_list.next->data;
+		f_hdr = (struct ieee80211_hdr *) skb_peek(&entry->skb_list)->data;
 
 		/*
 		 * Check ftype and addresses are equal, else check next fragment
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 582ec3e..a16d8bf 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -218,9 +218,9 @@ int nf_queue(struct sk_buff *skb,
 		return 1;
 
 	do {
-		struct sk_buff *nskb = segs->next;
+		struct sk_buff *nskb = segs->frag_next;
 
-		segs->next = NULL;
+		segs->frag_next = NULL;
 		if (!__nf_queue(segs, elem, pf, hook, indev, outdev, okfn,
 				queuenum))
 			kfree_skb(segs);
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index a39bf97..1d9dae3 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -235,9 +235,9 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (flags & MSG_PEEK) {
 			_debug("peek next");
-			skb = skb->next;
-			if (skb == (struct sk_buff *) &rx->sk.sk_receive_queue)
+			if (skb->list.next == &rx->sk.sk_receive_queue.list)
 				break;
+			skb = list_entry(skb->list.next, struct sk_buff, list);
 			goto peek_next_packet;
 		}
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ec0a083..1592a4e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,7 +44,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	if (unlikely(skb->next))
+	if (unlikely(skb->frag_next))
 		q->gso_skb = skb;
 	else
 		q->ops->requeue(skb, q);
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6e041d1..44e40b7 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -244,7 +244,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 
 	if (d > 1) {
 		sfq_index x = q->dep[d + SFQ_DEPTH].next;
-		skb = q->qs[x].prev;
+		skb = skb_peek_tail(&q->qs[x]);
 		len = qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[x]);
 		kfree_skb(skb);
@@ -260,7 +260,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		d = q->next[q->tail];
 		q->next[q->tail] = q->next[d];
 		q->allot[q->next[d]] += q->quantum;
-		skb = q->qs[d].prev;
+		skb = skb_peek_tail(&q->qs[d]);
 		len = qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[d]);
 		kfree_skb(skb);
@@ -360,7 +360,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	 * is dropped.
 	 */
 	if (q->qs[x].qlen > q->limit) {
-		skb = q->qs[x].prev;
+		skb = skb_peek_tail(&q->qs[x]);
 		__skb_unlink(skb, &q->qs[x]);
 		sch->qstats.drops++;
 		sch->qstats.backlog -= qdisc_pkt_len(skb);
diff --git a/net/sctp/input.c b/net/sctp/input.c
index a49fa80..bdfedae 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -86,7 +86,7 @@ static inline int sctp_rcv_checksum(struct sk_buff *skb)
 	__be32 cmp = sh->checksum;
 	__be32 val = sctp_start_cksum((__u8 *)sh, skb_headlen(skb));
 
-	for (; list; list = list->next)
+	for (; list; list = list->frag_next)
 		val = sctp_update_cksum((__u8 *)list->data, skb_headlen(list),
 					val);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5ffb9de..79fec46 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1844,7 +1844,7 @@ static int sctp_skb_pull(struct sk_buff *skb, int len)
 	len -= skb_len;
 	__skb_pull(skb, skb_len);
 
-	for (list = skb_shinfo(skb)->frag_list; list; list = list->next) {
+	for (list = skb_shinfo(skb)->frag_list; list; list = list->frag_next) {
 		rlen = sctp_skb_pull(list, len);
 		skb->len -= (len-rlen);
 		skb->data_len -= (len-rlen);
@@ -6538,7 +6538,7 @@ static void sctp_sock_rfree_frag(struct sk_buff *skb)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next)
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->frag_next)
 		sctp_sock_rfree_frag(frag);
 
 done:
@@ -6553,7 +6553,7 @@ static void sctp_skb_set_owner_r_frag(struct sk_buff *skb, struct sock *sk)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next)
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->frag_next)
 		sctp_skb_set_owner_r_frag(frag, sk);
 
 done:
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index a1f654a..8648342 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -60,6 +60,10 @@ SCTP_STATIC void sctp_ulpevent_init(struct sctp_ulpevent *event,
 				    int msg_flags,
 				    unsigned int len)
 {
+	struct sk_buff *skb = sctp_event2skb(event);
+
+	INIT_LIST_HEAD(&skb->list);
+
 	memset(event, 0, sizeof(struct sctp_ulpevent));
 	event->msg_flags = msg_flags;
 	event->rmem_len = len;
@@ -970,7 +974,7 @@ static void sctp_ulpevent_receive_data(struct sctp_ulpevent *event,
 	 * In general, the skb passed from IP can have only 1 level of
 	 * fragments. But we allow multiple levels of fragments.
 	 */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->frag_next) {
 		sctp_ulpevent_receive_data(sctp_skb2event(frag), asoc);
 	}
 }
@@ -997,7 +1001,7 @@ static void sctp_ulpevent_release_data(struct sctp_ulpevent *event)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->frag_next) {
 		/* NOTE:  skb_shinfos are recursive. Although IP returns
 		 * skb's with only 1 level of fragments, SCTP reassembly can
 		 * increase the levels.
@@ -1020,7 +1024,7 @@ static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->frag_next) {
 		/* NOTE:  skb_shinfos are recursive. Although IP returns
 		 * skb's with only 1 level of fragments, SCTP reassembly can
 		 * increase the levels.
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 5061a26..b765541 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -205,7 +205,11 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	struct sk_buff *skb = sctp_event2skb(event);
 	int clear_pd = 0;
 
-	skb_list = (struct sk_buff_head *) skb->prev;
+	skb_list = NULL;
+	if (!list_empty(&skb->list)) {
+		struct list_head *head = skb->list.prev;
+		skb_list = container_of(head, struct sk_buff_head, list);
+	}
 
 	/* If the socket is just going to throw this away, do not
 	 * even try to deliver it.
@@ -317,7 +321,7 @@ static void sctp_ulpq_store_reasm(struct sctp_ulpq *ulpq,
 	}
 
 	/* Insert before pos. */
-	__skb_insert(sctp_event2skb(event), pos->prev, pos, &ulpq->reasm);
+	__skb_insert(sctp_event2skb(event), pos, &ulpq->reasm);
 
 }
 
@@ -337,19 +341,20 @@ static struct sctp_ulpevent *sctp_make_reassembled_event(struct sk_buff_head *qu
 	struct sk_buff *list = skb_shinfo(f_frag)->frag_list;
 
 	/* Store the pointer to the 2nd skb */
-	if (f_frag == l_frag)
-		pos = NULL;
-	else
-		pos = f_frag->next;
+	pos = NULL;
+	if (f_frag != l_frag) {
+		if (f_frag->list.next != &queue->list)
+			pos = list_entry(f_frag->list.next, struct sk_buff, list);
+	}
 
 	/* Get the last skb in the f_frag's frag_list if present. */
-	for (last = list; list; last = list, list = list->next);
+	for (last = list; list; last = list, list = list->frag_next);
 
 	/* Add the list of remaining fragments to the first fragments
 	 * frag_list.
 	 */
 	if (last)
-		last->next = pos;
+		last->frag_next = pos;
 	else {
 		if (skb_cloned(f_frag)) {
 			/* This is a cloned skb, we can't just modify
@@ -378,8 +383,7 @@ static struct sctp_ulpevent *sctp_make_reassembled_event(struct sk_buff_head *qu
 	}
 
 	while (pos) {
-
-		pnext = pos->next;
+		pnext = pos->frag_next;
 
 		/* Update the len and data_len fields of the first fragment. */
 		f_frag->len += pos->len;
@@ -387,11 +391,12 @@ static struct sctp_ulpevent *sctp_make_reassembled_event(struct sk_buff_head *qu
 
 		/* Remove the fragment from the reassembly queue.  */
 		__skb_unlink(pos, queue);
+		pos->frag_next = NULL;
 
 		/* Break if we have reached the last fragment.  */
 		if (pos == l_frag)
 			break;
-		pos->next = pnext;
+		pos->frag_next = pnext;
 		pos = pnext;
 	}
 
@@ -447,7 +452,7 @@ static struct sctp_ulpevent *sctp_ulpq_retrieve_reassembled(struct sctp_ulpq *ul
 			 * element in the queue, then count it towards
 			 * possible PD.
 			 */
-			if (pos == ulpq->reasm.next) {
+			if (pos->list.prev == &ulpq->reasm.list) {
 			    pd_first = pos;
 			    pd_last = pos;
 			    pd_len = pos->len;
@@ -739,9 +744,10 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 					      struct sctp_ulpevent *event)
 {
 	struct sk_buff_head *event_list;
-	struct sk_buff *pos, *tmp;
+	struct sk_buff *pos, *tmp, *skb;
 	struct sctp_ulpevent *cevent;
 	struct sctp_stream *in;
+	struct list_head *prev;
 	__u16 sid, csid;
 	__u16 ssn, cssn;
 
@@ -749,7 +755,9 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 	ssn = event->ssn;
 	in  = &ulpq->asoc->ssnmap->in;
 
-	event_list = (struct sk_buff_head *) sctp_event2skb(event)->prev;
+	skb = sctp_event2skb(event);
+	prev = skb->list.prev;
+	event_list = container_of(prev, struct sk_buff_head, list);
 
 	/* We are holding the chunks by stream, by SSN.  */
 	sctp_skb_for_each(pos, &ulpq->lobby, tmp) {
@@ -825,7 +833,7 @@ static void sctp_ulpq_store_ordered(struct sctp_ulpq *ulpq,
 
 
 	/* Insert before pos. */
-	__skb_insert(sctp_event2skb(event), pos->prev, pos, &ulpq->lobby);
+	__skb_insert(sctp_event2skb(event), pos, &ulpq->lobby);
 
 }
 
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 3ddaff4..e19de8c 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -189,7 +189,7 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
 
 	buf = bcl->first_out;
 	while (buf && less_eq(buf_seqno(buf), after)) {
-		buf = buf->next;
+		buf = buf->frag_next;
 	}
 	tipc_link_retransmit(bcl, buf, mod(to - after));
 }
@@ -217,13 +217,13 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 
 	crs = bcl->first_out;
 	while (crs && less_eq(buf_seqno(crs), n_ptr->bclink.acked)) {
-		crs = crs->next;
+		crs = crs->frag_next;
 	}
 
 	/* Update packets that node is now acknowledging */
 
 	while (crs && less_eq(buf_seqno(crs), acked)) {
-		next = crs->next;
+		next = crs->frag_next;
 		bcbuf_decr_acks(crs);
 		if (bcbuf_acks(crs) == 0) {
 			bcl->first_out = next;
@@ -355,7 +355,7 @@ static void tipc_bclink_peek_nack(u32 dest, u32 sender_tag, u32 gap_after, u32 g
 		struct sk_buff *buf = n_ptr->bclink.deferred_head;
 		u32 prev = n_ptr->bclink.gap_to;
 
-		for (; buf; buf = buf->next) {
+		for (; buf; buf = buf->frag_next) {
 			u32 seqno = buf_seqno(buf);
 
 			if (mod(seqno - prev) != 1) {
@@ -499,7 +499,7 @@ receive:
 			tipc_node_lock(node);
 			buf = deferred;
 			msg = buf_msg(buf);
-			node->bclink.deferred_head = deferred->next;
+			node->bclink.deferred_head = deferred->frag_next;
 			goto receive;
 		}
 		return;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index a881f92..180d68c 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -343,7 +343,6 @@ static inline struct sk_buff *buf_acquire(u32 size)
 	if (skb) {
 		skb_reserve(skb, BUF_HEADROOM);
 		skb_put(skb, size);
-		skb->next = NULL;
 	}
 	return skb;
 }
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index fe43ef7..69e3fc2 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -111,7 +111,7 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 			size = msg_size((struct tipc_msg *)buf->data);
 			skb_trim(buf, size);
 			if (likely(buf->len == size)) {
-				buf->next = NULL;
+				buf->frag_next = NULL;
 				tipc_recv_msg(buf, eb_ptr->bearer);
 				return 0;
 			}
diff --git a/net/tipc/link.c b/net/tipc/link.c
index dd4c18b..8c4d418 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -188,7 +188,7 @@ static void dbg_print_buf_chain(struct sk_buff *root_buf)
 
 		while (buf) {
 			msg_dbg(buf_msg(buf), "In chain: ");
-			buf = buf->next;
+			buf = buf->frag_next;
 		}
 	}
 }
@@ -615,7 +615,7 @@ static void link_release_outqueue(struct link *l_ptr)
 	struct sk_buff *next;
 
 	while (buf) {
-		next = buf->next;
+		next = buf->frag_next;
 		buf_discard(buf);
 		buf = next;
 	}
@@ -634,7 +634,7 @@ void tipc_link_reset_fragments(struct link *l_ptr)
 	struct sk_buff *next;
 
 	while (buf) {
-		next = buf->next;
+		next = buf->frag_next;
 		buf_discard(buf);
 		buf = next;
 	}
@@ -653,14 +653,14 @@ void tipc_link_stop(struct link *l_ptr)
 
 	buf = l_ptr->oldest_deferred_in;
 	while (buf) {
-		next = buf->next;
+		next = buf->frag_next;
 		buf_discard(buf);
 		buf = next;
 	}
 
 	buf = l_ptr->first_out;
 	while (buf) {
-		next = buf->next;
+		next = buf->frag_next;
 		buf_discard(buf);
 		buf = next;
 	}
@@ -744,7 +744,7 @@ void tipc_link_reset(struct link *l_ptr)
 	l_ptr->proto_msg_queue = NULL;
 	buf = l_ptr->oldest_deferred_in;
 	while (buf) {
-		struct sk_buff *next = buf->next;
+		struct sk_buff *next = buf->frag_next;
 		buf_discard(buf);
 		buf = next;
 	}
@@ -1041,9 +1041,9 @@ static void link_add_to_outqueue(struct link *l_ptr,
 
 	msg_set_word(msg, 2, ((ack << 16) | seqno));
 	msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-	buf->next = NULL;
+	buf->frag_next = NULL;
 	if (l_ptr->first_out) {
-		l_ptr->last_out->next = buf;
+		l_ptr->last_out->frag_next = buf;
 		l_ptr->last_out = buf;
 	} else
 		l_ptr->first_out = l_ptr->last_out = buf;
@@ -1402,7 +1402,7 @@ again:
 	buf_chain = buf = buf_acquire(max_pkt);
 	if (!buf)
 		return -ENOMEM;
-	buf->next = NULL;
+	buf->frag_next = NULL;
 	skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
 	hsz = msg_hdr_sz(hdr);
 	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, hdr, hsz);
@@ -1430,7 +1430,7 @@ again:
 			if (copy_from_user(buf->data + fragm_crs, sect_crs, sz)) {
 error:
 				for (; buf_chain; buf_chain = buf) {
-					buf = buf_chain->next;
+					buf = buf_chain->frag_next;
 					buf_discard(buf_chain);
 				}
 				return -EFAULT;
@@ -1460,8 +1460,8 @@ error:
 			if (!buf)
 				goto error;
 
-			buf->next = NULL;
-			prev->next = buf;
+			buf->frag_next = NULL;
+			prev->frag_next = buf;
 			skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
 			fragm_crs = INT_H_SIZE;
 			fragm_rest = fragm_sz;
@@ -1486,7 +1486,7 @@ error:
 			sender->publ.max_pkt = link_max_pkt(l_ptr);
 			tipc_node_unlock(node);
 			for (; buf_chain; buf_chain = buf) {
-				buf = buf_chain->next;
+				buf = buf_chain->frag_next;
 				buf_discard(buf_chain);
 			}
 			goto again;
@@ -1494,7 +1494,7 @@ error:
 	} else {
 reject:
 		for (; buf_chain; buf_chain = buf) {
-			buf = buf_chain->next;
+			buf = buf_chain->frag_next;
 			buf_discard(buf_chain);
 		}
 		return tipc_port_reject_sections(sender, hdr, msg_sect, num_sect,
@@ -1509,7 +1509,7 @@ reject:
 		l_ptr->next_out = buf_chain;
 	l_ptr->stats.sent_fragmented++;
 	while (buf) {
-		struct sk_buff *next = buf->next;
+		struct sk_buff *next = buf->frag_next;
 		struct tipc_msg *msg = buf_msg(buf);
 
 		l_ptr->stats.sent_fragments++;
@@ -1545,7 +1545,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 
 		while (buf && less(first, r_q_head)) {
 			first = mod(first + 1);
-			buf = buf->next;
+			buf = buf->frag_next;
 		}
 		l_ptr->retransm_queue_head = r_q_head = first;
 		l_ptr->retransm_queue_size = r_q_size = mod(last - first);
@@ -1603,7 +1603,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 				if (msg_user(msg) == MSG_BUNDLER)
 					msg_set_type(msg, CLOSED_MSG);
 				msg_dbg(msg, ">PUSH-DATA>");
-				l_ptr->next_out = buf->next;
+				l_ptr->next_out = buf->frag_next;
 				return 0;
 			} else {
 				msg_dbg(msg, "|PUSH-DATA|");
@@ -1751,7 +1751,7 @@ void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
 			msg_dbg(buf_msg(buf), ">RETR>");
-			buf = buf->next;
+			buf = buf->frag_next;
 			retransmits--;
 			l_ptr->stats.retransmitted++;
 		} else {
@@ -1780,7 +1780,7 @@ static struct sk_buff *link_insert_deferred_queue(struct link *l_ptr,
 
 	seq_no = msg_seqno(buf_msg(l_ptr->oldest_deferred_in));
 	if (seq_no == mod(l_ptr->next_in_no)) {
-		l_ptr->newest_deferred_in->next = buf;
+		l_ptr->newest_deferred_in->frag_next = buf;
 		buf = l_ptr->oldest_deferred_in;
 		l_ptr->oldest_deferred_in = NULL;
 		l_ptr->deferred_inqueue_sz = 0;
@@ -1853,7 +1853,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 		u32 released = 0;
 		int type;
 
-		head = head->next;
+		head = head->frag_next;
 
 		/* Ensure message is well-formed */
 
@@ -1910,7 +1910,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 		crs = l_ptr->first_out;
 		while ((crs != l_ptr->next_out) &&
 		       less_eq(msg_seqno(buf_msg(crs)), ackd)) {
-			struct sk_buff *next = crs->next;
+			struct sk_buff *next = crs->frag_next;
 
 			buf_discard(crs);
 			crs = next;
@@ -2010,7 +2010,7 @@ deliver:
 		if (link_working_working(l_ptr)) {
 			/* Re-insert in front of queue */
 			msg_dbg(msg,"RECV-REINS:");
-			buf->next = head;
+			buf->frag_next = head;
 			head = buf;
 			tipc_node_unlock(n_ptr);
 			continue;
@@ -2036,7 +2036,7 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
 	struct sk_buff *crs = *head;
 	u32 seq_no = msg_seqno(buf_msg(buf));
 
-	buf->next = NULL;
+	buf->frag_next = NULL;
 
 	/* Empty queue ? */
 	if (*head == NULL) {
@@ -2046,7 +2046,7 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
 
 	/* Last ? */
 	if (less(msg_seqno(buf_msg(*tail)), seq_no)) {
-		(*tail)->next = buf;
+		(*tail)->frag_next = buf;
 		*tail = buf;
 		return 1;
 	}
@@ -2056,9 +2056,9 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
 		struct tipc_msg *msg = buf_msg(crs);
 
 		if (less(seq_no, msg_seqno(msg))) {
-			buf->next = crs;
+			buf->frag_next = crs;
 			if (prev)
-				prev->next = buf;
+				prev->frag_next = buf;
 			else
 				*head = buf;
 			return 1;
@@ -2067,7 +2067,7 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
 			break;
 		}
 		prev = crs;
-		crs = crs->next;
+		crs = crs->frag_next;
 	}
 	while (crs);
 
@@ -2471,7 +2471,7 @@ void tipc_link_changeover(struct link *l_ptr)
 			tipc_link_tunnel(l_ptr, &tunnel_hdr, msg,
 					 msg_link_selector(msg));
 		}
-		crs = crs->next;
+		crs = crs->frag_next;
 	}
 }
 
@@ -2510,7 +2510,7 @@ void tipc_link_send_duplicate(struct link *l_ptr, struct link *tunnel)
 		tipc_link_send_buf(tunnel, outbuf);
 		if (!tipc_link_is_up(l_ptr))
 			return;
-		iter = iter->next;
+		iter = iter->frag_next;
 	}
 }
 
@@ -2791,7 +2791,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 	while (pbuf && ((msg_seqno(buf_msg(pbuf)) != long_msg_seq_no)
 			|| (msg_orignode(fragm) != msg_orignode(buf_msg(pbuf))))) {
 		prev = pbuf;
-		pbuf = pbuf->next;
+		pbuf = pbuf->frag_next;
 	}
 
 	if (!pbuf && (msg_type(fragm) == FIRST_FRAGMENT)) {
@@ -2809,7 +2809,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		}
 		pbuf = buf_acquire(msg_size(imsg));
 		if (pbuf != NULL) {
-			pbuf->next = *pending;
+			pbuf->frag_next = *pending;
 			*pending = pbuf;
 			skb_copy_to_linear_data(pbuf, imsg,
 						msg_data_sz(fragm));
@@ -2836,9 +2836,9 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 
 		if (exp_frags == 0) {
 			if (prev)
-				prev->next = pbuf->next;
+				prev->frag_next = pbuf->frag_next;
 			else
-				*pending = pbuf->next;
+				*pending = pbuf->frag_next;
 			msg_reset_reroute_cnt(buf_msg(pbuf));
 			*fb = pbuf;
 			*m = buf_msg(pbuf);
@@ -2873,7 +2873,7 @@ static void link_check_defragm_bufs(struct link *l_ptr)
 	while (buf) {
 		u32 cnt = get_timer_cnt(buf);
 
-		next = buf->next;
+		next = buf->frag_next;
 		if (cnt < 4) {
 			incr_timer_cnt(buf);
 			prev = buf;
@@ -2884,9 +2884,9 @@ static void link_check_defragm_bufs(struct link *l_ptr)
 			dbg("Pending long buffers:\n");
 			dbg_print_buf_chain(l_ptr->defragm_buf);
 			if (prev)
-				prev->next = buf->next;
+				prev->frag_next = buf->frag_next;
 			else
-				l_ptr->defragm_buf = buf->next;
+				l_ptr->defragm_buf = buf->frag_next;
 			buf_discard(buf);
 		}
 		buf = next;
@@ -3286,7 +3286,7 @@ static void link_dump_rec_queue(struct link *l_ptr)
 			return;
 		}
 		msg_dbg(buf_msg(crs), "In rec queue: \n");
-		crs = crs->next;
+		crs = crs->frag_next;
 	}
 }
 #endif
@@ -3326,7 +3326,7 @@ static void link_print(struct link *l_ptr, struct print_buf *buf,
 		if ((mod(msg_seqno(buf_msg(l_ptr->last_out)) -
 			 msg_seqno(buf_msg(l_ptr->first_out)))
 		     != (l_ptr->out_queue_size - 1))
-		    || (l_ptr->last_out->next != NULL)) {
+		    || (l_ptr->last_out->frag_next != NULL)) {
 			tipc_printf(buf, "\nSend queue inconsistency\n");
 			tipc_printf(buf, "first_out= %x ", l_ptr->first_out);
 			tipc_printf(buf, "next_out= %x ", l_ptr->next_out);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 20d98c5..e91e036 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -395,7 +395,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	n_ptr->bclink.gap_after = n_ptr->bclink.gap_to = 0;
 	while (n_ptr->bclink.deferred_head) {
 		struct sk_buff* buf = n_ptr->bclink.deferred_head;
-		n_ptr->bclink.deferred_head = buf->next;
+		n_ptr->bclink.deferred_head = buf->frag_next;
 		buf_discard(buf);
 	}
 	if (n_ptr->bclink.defragm) {
diff --git a/net/tipc/port.c b/net/tipc/port.c
index e70d27e..a5e3209 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -805,7 +805,7 @@ static void port_dispatcher_sigh(void *dummy)
 		int published;
 		u32 message_type;
 
-		struct sk_buff *next = buf->next;
+		struct sk_buff *next = buf->frag_next;
 		struct tipc_msg *msg = buf_msg(buf);
 		u32 dref = msg_destport(msg);
 
@@ -953,10 +953,10 @@ reject:
 
 static u32 port_dispatcher(struct tipc_port *dummy, struct sk_buff *buf)
 {
-	buf->next = NULL;
+	buf->frag_next = NULL;
 	spin_lock_bh(&queue_lock);
 	if (msg_queue_head) {
-		msg_queue_tail->next = buf;
+		msg_queue_tail->frag_next = buf;
 		msg_queue_tail = buf;
 	} else {
 		msg_queue_tail = msg_queue_head = buf;
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 2a27b84..bc0289c 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -152,14 +152,8 @@ void unix_notinflight(struct file *fp)
 	}
 }
 
-static inline struct sk_buff *sock_queue_head(struct sock *sk)
-{
-	return (struct sk_buff *) &sk->sk_receive_queue;
-}
-
 #define receive_queue_for_each_skb(sk, next, skb) \
-	for (skb = sock_queue_head(sk)->next, next = skb->next; \
-	     skb != sock_queue_head(sk); skb = next, next = skb->next)
+	list_for_each_entry_safe(skb, next, &(sk)->sk_receive_queue.list, list)
 
 static void scan_inflight(struct sock *x, void (*func)(struct unix_sock *),
 			  struct sk_buff_head *hitlist)
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 96036cf..eaddbcc 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -745,7 +745,7 @@ int skb_icv_walk(const struct sk_buff *skb, struct hash_desc *desc,
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list; list = list->next) {
+		for (; list; list = list->frag_next) {
 			int end;
 
 			WARN_ON(start > offset + len);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index ac25b4c..d63bf6e 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -151,16 +151,16 @@ static int xfrm_output_gso(struct sk_buff *skb)
 		return PTR_ERR(segs);
 
 	do {
-		struct sk_buff *nskb = segs->next;
+		struct sk_buff *nskb = segs->frag_next;
 		int err;
 
-		segs->next = NULL;
+		segs->frag_next = NULL;
 		err = xfrm_output2(segs);
 
 		if (unlikely(err)) {
 			while ((segs = nskb)) {
-				nskb = segs->next;
-				segs->next = NULL;
+				nskb = segs->frag_next;
+				segs->frag_next = NULL;
 				kfree_skb(segs);
 			}
 			return err;
