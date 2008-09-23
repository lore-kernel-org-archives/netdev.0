From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/7]: isdn: isdn_ppp: Use SKB list facilities instead of
 home-grown implementation.
Date: Mon, 22 Sep 2008 19:12:43 -0700 (PDT)
Message-ID: <20080922.191243.177666844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754069AbYIWCMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AF5E2C8C181
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


isdn: isdn_ppp: Use SKB list facilities instead of home-grown implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/i4l/isdn_ppp.c |  352 +++++++++++++++++++++++--------------------
 include/linux/isdn_ppp.h    |    2 +-
 2 files changed, 190 insertions(+), 164 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 127cfda..77c280e 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1533,8 +1533,10 @@ static int isdn_ppp_mp_bundle_array_init(void)
 	int sz = ISDN_MAX_CHANNELS*sizeof(ippp_bundle);
 	if( (isdn_ppp_bundle_arr = kzalloc(sz, GFP_KERNEL)) == NULL )
 		return -ENOMEM;
-	for( i = 0; i < ISDN_MAX_CHANNELS; i++ )
+	for (i = 0; i < ISDN_MAX_CHANNELS; i++) {
 		spin_lock_init(&isdn_ppp_bundle_arr[i].lock);
+		skb_queue_head_init(&isdn_ppp_bundle_arr[i].frags);
+	}
 	return 0;
 }
 
@@ -1567,7 +1569,7 @@ static int isdn_ppp_mp_init( isdn_net_local * lp, ippp_bundle * add_to )
 		if ((lp->netdev->pb = isdn_ppp_mp_bundle_alloc()) == NULL)
 			return -ENOMEM;
 		lp->next = lp->last = lp;	/* nobody else in a queue */
-		lp->netdev->pb->frags = NULL;
+		skb_queue_head_init(&lp->netdev->pb->frags);
 		lp->netdev->pb->frames = 0;
 		lp->netdev->pb->seq = UINT_MAX;
 	}
@@ -1579,28 +1581,29 @@ static int isdn_ppp_mp_init( isdn_net_local * lp, ippp_bundle * add_to )
 
 static u32 isdn_ppp_mp_get_seq( int short_seq, 
 					struct sk_buff * skb, u32 last_seq );
-static struct sk_buff * isdn_ppp_mp_discard( ippp_bundle * mp,
-			struct sk_buff * from, struct sk_buff * to );
-static void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
-				struct sk_buff * from, struct sk_buff * to );
-static void isdn_ppp_mp_free_skb( ippp_bundle * mp, struct sk_buff * skb );
+static void isdn_ppp_mp_discard(ippp_bundle *mp, struct sk_buff *from,
+				struct sk_buff *to);
+static void isdn_ppp_mp_reassembly(isdn_net_dev *net_dev, isdn_net_local *lp,
+				   struct sk_buff *from, struct sk_buff *to,
+				   u32 lastseq);
+static void isdn_ppp_mp_free_skb(ippp_bundle *mp, struct sk_buff *skb);
 static void isdn_ppp_mp_print_recv_pkt( int slot, struct sk_buff * skb );
 
 static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp, 
-							struct sk_buff *skb)
+				struct sk_buff *skb)
 {
-	struct ippp_struct *is;
-	isdn_net_local * lpq;
-	ippp_bundle * mp;
-	isdn_mppp_stats * stats;
-	struct sk_buff * newfrag, * frag, * start, *nextf;
+	struct sk_buff *newfrag, *frag, *start, *nextf;
 	u32 newseq, minseq, thisseq;
+	isdn_mppp_stats *stats;
+	struct ippp_struct *is;
 	unsigned long flags;
+	isdn_net_local *lpq;
+	ippp_bundle *mp;
 	int slot;
 
 	spin_lock_irqsave(&net_dev->pb->lock, flags);
-    	mp = net_dev->pb;
-        stats = &mp->stats;
+	mp = net_dev->pb;
+	stats = &mp->stats;
 	slot = lp->ppp_slot;
 	if (slot < 0 || slot >= ISDN_MAX_CHANNELS) {
 		printk(KERN_ERR "%s: lp->ppp_slot(%d)\n",
@@ -1611,20 +1614,19 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 		return;
 	}
 	is = ippp_table[slot];
-    	if( ++mp->frames > stats->max_queue_len )
+	if (++mp->frames > stats->max_queue_len)
 		stats->max_queue_len = mp->frames;
-	
+
 	if (is->debug & 0x8)
 		isdn_ppp_mp_print_recv_pkt(lp->ppp_slot, skb);
 
-	newseq = isdn_ppp_mp_get_seq(is->mpppcfg & SC_IN_SHORT_SEQ, 
-						skb, is->last_link_seqno);
-
+	newseq = isdn_ppp_mp_get_seq(is->mpppcfg & SC_IN_SHORT_SEQ,
+				     skb, is->last_link_seqno);
 
 	/* if this packet seq # is less than last already processed one,
 	 * toss it right away, but check for sequence start case first 
 	 */
-	if( mp->seq > MP_LONGSEQ_MAX && (newseq & MP_LONGSEQ_MAXBIT) ) {
+	if (mp->seq > MP_LONGSEQ_MAX && (newseq & MP_LONGSEQ_MAXBIT)) {
 		mp->seq = newseq;	/* the first packet: required for
 					 * rfc1990 non-compliant clients --
 					 * prevents constant packet toss */
@@ -1634,7 +1636,7 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 		spin_unlock_irqrestore(&mp->lock, flags);
 		return;
 	}
-	
+
 	/* find the minimum received sequence number over all links */
 	is->last_link_seqno = minseq = newseq;
 	for (lpq = net_dev->queue;;) {
@@ -1655,22 +1657,31 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 					 * packets */
 	newfrag = skb;
 
-  	/* if this new fragment is before the first one, then enqueue it now. */
-  	if ((frag = mp->frags) == NULL || MP_LT(newseq, MP_SEQ(frag))) {
-		newfrag->next = frag;
-    		mp->frags = frag = newfrag;
-    		newfrag = NULL;
-  	}
+	/* Insert new fragment into the proper sequence slot.  */
+	skb_queue_walk(&mp->frags, frag) {
+		if (MP_SEQ(frag) == newseq) {
+			isdn_ppp_mp_free_skb(mp, newfrag);
+			newfrag = NULL;
+			break;
+		}
+		if (MP_LT(newseq, MP_SEQ(frag))) {
+			__skb_queue_before(&mp->frags, frag, newfrag);
+			newfrag = NULL;
+			break;
+		}
+	}
+	if (newfrag)
+		__skb_queue_tail(&mp->frags, newfrag);
 
-  	start = MP_FLAGS(frag) & MP_BEGIN_FRAG &&
-				MP_SEQ(frag) == mp->seq ? frag : NULL;
+	frag = skb_peek(&mp->frags);
+	start = ((MP_FLAGS(frag) & MP_BEGIN_FRAG) &&
+		 (MP_SEQ(frag) == mp->seq)) ? frag : NULL;
+	if (!start)
+		goto check_overflow;
 
-	/* 
-	 * main fragment traversing loop
+	/* main fragment traversing loop
 	 *
 	 * try to accomplish several tasks:
-	 * - insert new fragment into the proper sequence slot (once that's done
-	 *   newfrag will be set to NULL)
 	 * - reassemble any complete fragment sequence (non-null 'start'
 	 *   indicates there is a continguous sequence present)
 	 * - discard any incomplete sequences that are below minseq -- due
@@ -1679,71 +1690,46 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 	 *   come to complete such sequence and it should be discarded
 	 *
 	 * loop completes when we accomplished the following tasks:
-	 * - new fragment is inserted in the proper sequence ('newfrag' is 
-	 *   set to NULL)
 	 * - we hit a gap in the sequence, so no reassembly/processing is 
 	 *   possible ('start' would be set to NULL)
 	 *
 	 * algorithm for this code is derived from code in the book
 	 * 'PPP Design And Debugging' by James Carlson (Addison-Wesley)
 	 */
-  	while (start != NULL || newfrag != NULL) {
-
-    		thisseq = MP_SEQ(frag);
-    		nextf = frag->next;
-
-    		/* drop any duplicate fragments */
-    		if (newfrag != NULL && thisseq == newseq) {
-      			isdn_ppp_mp_free_skb(mp, newfrag);
-      			newfrag = NULL;
-    		}
-
-    		/* insert new fragment before next element if possible. */
-    		if (newfrag != NULL && (nextf == NULL || 
-						MP_LT(newseq, MP_SEQ(nextf)))) {
-      			newfrag->next = nextf;
-      			frag->next = nextf = newfrag;
-      			newfrag = NULL;
-    		}
-
-    		if (start != NULL) {
-	    		/* check for misplaced start */
-      			if (start != frag && (MP_FLAGS(frag) & MP_BEGIN_FRAG)) {
-				printk(KERN_WARNING"isdn_mppp(seq %d): new "
-				      "BEGIN flag with no prior END", thisseq);
-				stats->seqerrs++;
-				stats->frame_drops++;
-				start = isdn_ppp_mp_discard(mp, start,frag);
-				nextf = frag->next;
-      			}
-    		} else if (MP_LE(thisseq, minseq)) {		
-      			if (MP_FLAGS(frag) & MP_BEGIN_FRAG)
+	skb_queue_walk_safe(&mp->frags, frag, nextf) {
+		thisseq = MP_SEQ(frag);
+
+		/* check for misplaced start */
+		if (start != frag && (MP_FLAGS(frag) & MP_BEGIN_FRAG)) {
+			printk(KERN_WARNING"isdn_mppp(seq %d): new "
+			       "BEGIN flag with no prior END", thisseq);
+			stats->seqerrs++;
+			stats->frame_drops++;
+			isdn_ppp_mp_discard(mp, start, frag);
+			start = frag;
+		} else if (MP_LE(thisseq, minseq)) {		
+			if (MP_FLAGS(frag) & MP_BEGIN_FRAG)
 				start = frag;
-      			else {
+			else {
 				if (MP_FLAGS(frag) & MP_END_FRAG)
-	  				stats->frame_drops++;
-				if( mp->frags == frag )
-					mp->frags = nextf;	
+					stats->frame_drops++;
+				__skb_unlink(skb, &mp->frags);
 				isdn_ppp_mp_free_skb(mp, frag);
-				frag = nextf;
 				continue;
-      			}
+			}
 		}
-		
-		/* if start is non-null and we have end fragment, then
-		 * we have full reassembly sequence -- reassemble 
-		 * and process packet now
+
+		/* if we have end fragment, then we have full reassembly
+		 * sequence -- reassemble and process packet now
 		 */
-    		if (start != NULL && (MP_FLAGS(frag) & MP_END_FRAG)) {
-      			minseq = mp->seq = (thisseq+1) & MP_LONGSEQ_MASK;
-      			/* Reassemble the packet then dispatch it */
-			isdn_ppp_mp_reassembly(net_dev, lp, start, nextf);
-      
-      			start = NULL;
-      			frag = NULL;
+		if (MP_FLAGS(frag) & MP_END_FRAG) {
+			minseq = mp->seq = (thisseq+1) & MP_LONGSEQ_MASK;
+			/* Reassemble the packet then dispatch it */
+			isdn_ppp_mp_reassembly(net_dev, lp, start, frag, thisseq);
 
-      			mp->frags = nextf;
-    		}
+			start = NULL;
+			frag = NULL;
+		}
 
 		/* check if need to update start pointer: if we just
 		 * reassembled the packet and sequence is contiguous
@@ -1754,26 +1740,25 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 		 * below low watermark and set start to the next frag or
 		 * clear start ptr.
 		 */ 
-    		if (nextf != NULL && 
+		if (nextf != (struct sk_buff *)&mp->frags && 
 		    ((thisseq+1) & MP_LONGSEQ_MASK) == MP_SEQ(nextf)) {
-      			/* if we just reassembled and the next one is here, 
-			 * then start another reassembly. */
-
-      			if (frag == NULL) {
+			/* if we just reassembled and the next one is here, 
+			 * then start another reassembly.
+			 */
+			if (frag == NULL) {
 				if (MP_FLAGS(nextf) & MP_BEGIN_FRAG)
-	  				start = nextf;
-				else
-				{
-	  				printk(KERN_WARNING"isdn_mppp(seq %d):"
-						" END flag with no following "
-						"BEGIN", thisseq);
+					start = nextf;
+				else {
+					printk(KERN_WARNING"isdn_mppp(seq %d):"
+					       " END flag with no following "
+					       "BEGIN", thisseq);
 					stats->seqerrs++;
 				}
 			}
-
-    		} else {
-			if ( nextf != NULL && frag != NULL &&
-						MP_LT(thisseq, minseq)) {
+		} else {
+			if (nextf != (struct sk_buff *)&mp->frags &&
+			    frag != NULL &&
+			    MP_LT(thisseq, minseq)) {
 				/* we've got a break in the sequence
 				 * and we not at the end yet
 				 * and we did not just reassembled
@@ -1782,41 +1767,39 @@ static void isdn_ppp_mp_receive(isdn_net_dev * net_dev, isdn_net_local * lp,
 			 	 * discard all the frames below low watermark 
 				 * and start over */
 				stats->frame_drops++;
-				mp->frags = isdn_ppp_mp_discard(mp,start,nextf);
+				isdn_ppp_mp_discard(mp, start, nextf);
 			}
 			/* break in the sequence, no reassembly */
-      			start = NULL;
-    		}
-	  			
-    		frag = nextf;
-  	}	/* while -- main loop */
-	
-  	if (mp->frags == NULL)
-    		mp->frags = frag;
-		
+			start = NULL;
+		}
+		if (!start)
+			break;
+	}
+
+check_overflow:
 	/* rather straighforward way to deal with (not very) possible 
-	 * queue overflow */
+	 * queue overflow
+	 */
 	if (mp->frames > MP_MAX_QUEUE_LEN) {
 		stats->overflows++;
-		while (mp->frames > MP_MAX_QUEUE_LEN) {
-			frag = mp->frags->next;
-			isdn_ppp_mp_free_skb(mp, mp->frags);
-			mp->frags = frag;
+		skb_queue_walk_safe(&mp->frags, frag, nextf) {
+			if (mp->frames <= MP_MAX_QUEUE_LEN)
+				break;
+			__skb_unlink(frag, &mp->frags);
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
+	struct sk_buff *skb, *tmp;
+
+	skb_queue_walk_safe(&lp->netdev->pb->frags, skb, tmp) {
+		__skb_unlink(skb, &lp->netdev->pb->frags);
+		isdn_ppp_mp_free_skb(lp->netdev->pb, skb);
+	}
 }
 
 static u32 isdn_ppp_mp_get_seq( int short_seq, 
@@ -1853,72 +1836,115 @@ static u32 isdn_ppp_mp_get_seq( int short_seq,
 	return seq;
 }
 
-struct sk_buff * isdn_ppp_mp_discard( ippp_bundle * mp,
-			struct sk_buff * from, struct sk_buff * to )
+static void isdn_ppp_mp_discard(ippp_bundle *mp, struct sk_buff *from,
+				struct sk_buff *to)
 {
-	if( from )
-		while (from != to) {
-	  		struct sk_buff * next = from->next;
-			isdn_ppp_mp_free_skb(mp, from);
-	  		from = next;
+	if (from) {
+		struct sk_buff *skb, *tmp;
+		int freeing = 0;
+
+		skb_queue_walk_safe(&mp->frags, skb, tmp) {
+			if (skb == to)
+				break;
+			if (skb == from)
+				freeing = 1;
+			if (!freeing)
+				continue;
+			__skb_unlink(skb, &mp->frags);
+			isdn_ppp_mp_free_skb(mp, skb);
 		}
-	return from;
+	}
 }
 
-void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
-				struct sk_buff * from, struct sk_buff * to )
+static unsigned int calc_tot_len(struct sk_buff_head *queue,
+				 struct sk_buff *from, struct sk_buff *to)
 {
-	ippp_bundle * mp = net_dev->pb;
-	int proto;
-	struct sk_buff * skb;
+	unsigned int tot_len = 0;
+	struct sk_buff *skb;
+	int found_start = 0;
+
+	skb_queue_walk(queue, skb) {
+		if (skb == from)
+			found_start = 1;
+		if (!found_start)
+			continue;
+		tot_len += skb->len - MP_HEADER_LEN;
+		if (skb == to)
+			break;
+	}
+	return tot_len;
+}
+
+/* Reassemble packet using fragments in the reassembly queue from
+ * 'from' until 'to', inclusive.
+ */
+static void isdn_ppp_mp_reassembly(isdn_net_dev *net_dev, isdn_net_local *lp,
+				   struct sk_buff *from, struct sk_buff *to,
+				   u32 lastseq)
+{
+	ippp_bundle *mp = net_dev->pb;
 	unsigned int tot_len;
+	struct sk_buff *skb;
+	int proto;
 
 	if (lp->ppp_slot < 0 || lp->ppp_slot >= ISDN_MAX_CHANNELS) {
 		printk(KERN_ERR "%s: lp->ppp_slot(%d) out of range\n",
 			__func__, lp->ppp_slot);
 		return;
 	}
-	if( MP_FLAGS(from) == (MP_BEGIN_FRAG | MP_END_FRAG) ) {
-		if( ippp_table[lp->ppp_slot]->debug & 0x40 )
+
+	tot_len = calc_tot_len(&mp->frags, from, to);
+
+	if (MP_FLAGS(from) == (MP_BEGIN_FRAG | MP_END_FRAG)) {
+		if (ippp_table[lp->ppp_slot]->debug & 0x40)
 			printk(KERN_DEBUG "isdn_mppp: reassembly: frame %d, "
-					"len %d\n", MP_SEQ(from), from->len );
+			       "len %d\n", MP_SEQ(from), from->len);
 		skb = from;
 		skb_pull(skb, MP_HEADER_LEN);
+		__skb_unlink(skb, &mp->frags);
 		mp->frames--;	
 	} else {
-		struct sk_buff * frag;
-		int n;
+		struct sk_buff *walk, *tmp;
+		int found_start = 0;
 
-		for(tot_len=n=0, frag=from; frag != to; frag=frag->next, n++)
-			tot_len += frag->len - MP_HEADER_LEN;
-
-		if( ippp_table[lp->ppp_slot]->debug & 0x40 )
+		if (ippp_table[lp->ppp_slot]->debug & 0x40)
 			printk(KERN_DEBUG"isdn_mppp: reassembling frames %d "
-				"to %d, len %d\n", MP_SEQ(from), 
-				(MP_SEQ(from)+n-1) & MP_LONGSEQ_MASK, tot_len );
-		if( (skb = dev_alloc_skb(tot_len)) == NULL ) {
+			       "to %d, len %d\n", MP_SEQ(from), lastseq,
+			       tot_len);
+
+		skb = dev_alloc_skb(tot_len);
+		if (!skb)
 			printk(KERN_ERR "isdn_mppp: cannot allocate sk buff "
-					"of size %d\n", tot_len);
-			isdn_ppp_mp_discard(mp, from, to);
-			return;
-		}
+			       "of size %d\n", tot_len);
+
+		found_start = 0;
+		skb_queue_walk_safe(&mp->frags, walk, tmp) {
+			if (walk == from)
+				found_start = 1;
+			if (!found_start)
+				continue;
 
-		while( from != to ) {
-			unsigned int len = from->len - MP_HEADER_LEN;
+			if (skb) {
+				unsigned int len = walk->len - MP_HEADER_LEN;
+				skb_copy_from_linear_data_offset(walk, MP_HEADER_LEN,
+								 skb_put(skb, len),
+								 len);
+			}
+			__skb_unlink(walk, &mp->frags);
+			isdn_ppp_mp_free_skb(mp, walk);
 
-			skb_copy_from_linear_data_offset(from, MP_HEADER_LEN,
-							 skb_put(skb,len),
-							 len);
-			frag = from->next;
-			isdn_ppp_mp_free_skb(mp, from);
-			from = frag; 
+			if (walk == to)
+				break;
 		}
 	}
+	if (!skb)
+		return;
+
    	proto = isdn_ppp_strip_proto(skb);
 	isdn_ppp_push_higher(net_dev, lp, skb, proto);
 }
 
-static void isdn_ppp_mp_free_skb(ippp_bundle * mp, struct sk_buff * skb)
+static void isdn_ppp_mp_free_skb(ippp_bundle *mp, struct sk_buff *skb)
 {
 	dev_kfree_skb(skb);
 	mp->frames--;
diff --git a/include/linux/isdn_ppp.h b/include/linux/isdn_ppp.h
index 8687a7d..4c218ee 100644
--- a/include/linux/isdn_ppp.h
+++ b/include/linux/isdn_ppp.h
@@ -157,7 +157,7 @@ typedef struct {
 
 typedef struct {
   int mp_mrru;                        /* unused                             */
-  struct sk_buff * frags;	/* fragments sl list -- use skb->next */
+  struct sk_buff_head frags;	/* fragments sl list */
   long frames;			/* number of frames in the frame list */
   unsigned int seq;		/* last processed packet seq #: any packets
   				 * with smaller seq # will be dropped
-- 
1.5.6.5

