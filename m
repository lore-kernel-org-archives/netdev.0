From: Paul Mackerras <paulus@samba.org>
Subject: [PATCH] PPP multilink fragmentation improvements
Date: Wed, 30 Mar 2005 14:56:40 +1000
Message-ID: <16970.12680.769155.708076@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, davem@davemloft.net, jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here's a patch for -mm for now.  Not sure whose territory this falls
in, so I'm sending it to everyone I can think of. :)

Some time ago I did some experiments with using PPP multilink over
largish numbers of channels (up to 32).  The TCP performance was
woeful due to wildly fluctuating packet latencies, which turned out to
be because we would sometimes split a packet across all 32 channels,
and sometimes we would send a whole packet down a single channel.

This patch fixes those problems by being a bit cleverer about how the
packets are split across the available channels, and in particular, it
waits until at least half of the channels can take another fragment
before starting to split up the next packet.

The patch also fixes a buglet in the multilink reconstruction code
where it would discard incoming packets that had just the multilink
header and no data.  Such packets are valid and shouldn't be
discarded.

Signed-off-by: Paul Mackerras <paulus@samba.org>

diff -urN linux-2.5/drivers/net/ppp_generic.c pmac-2.5/drivers/net/ppp_generic.c
--- linux-2.5/drivers/net/ppp_generic.c	2005-03-11 11:47:37.000000000 +1100
+++ pmac-2.5/drivers/net/ppp_generic.c	2005-03-30 14:37:14.000000000 +1000
@@ -1217,36 +1217,43 @@
  */
 static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 {
-	int nch, len, fragsize;
+	int len, fragsize;
 	int i, bits, hdrlen, mtu;
-	int flen, fnb;
+	int flen;
+	int navail, nfree;
+	int nbigger;
 	unsigned char *p, *q;
 	struct list_head *list;
 	struct channel *pch;
 	struct sk_buff *frag;
 	struct ppp_channel *chan;
 
-	nch = 0;
+	nfree = 0;	/* # channels which have no packet already queued */
+	navail = 0;	/* total # of usable channels (not deregistered) */
 	hdrlen = (ppp->flags & SC_MP_XSHORTSEQ)? MPHDRLEN_SSN: MPHDRLEN;
+	i = 0;
 	list = &ppp->channels;
 	while ((list = list->next) != &ppp->channels) {
 		pch = list_entry(list, struct channel, clist);
-		nch += pch->avail = (skb_queue_len(&pch->file.xq) == 0);
-		/*
-		 * If a channel hasn't had a fragment yet, it has to get
-		 * one before we send any fragments on later channels.
-		 * If it can't take a fragment now, don't give any
-		 * to subsequent channels.
-		 */
-		if (!pch->had_frag && !pch->avail) {
-			while ((list = list->next) != &ppp->channels) {
-				pch = list_entry(list, struct channel, clist);
-				pch->avail = 0;
+		navail += pch->avail = (pch->chan != NULL);
+		if (pch->avail) {
+			if (skb_queue_len(&pch->file.xq) == 0
+			    || !pch->had_frag) {
+				pch->avail = 2;
+				++nfree;
 			}
-			break;
+			if (!pch->had_frag && i < ppp->nxchan)
+				ppp->nxchan = i;
 		}
+		++i;
 	}
-	if (nch == 0)
+
+	/*
+	 * Don't start sending this packet unless at least half of
+	 * the channels are free.  This gives much better TCP
+	 * performance if we have a lot of channels.
+	 */
+	if (nfree == 0 || nfree < navail / 2)
 		return 0;	/* can't take now, leave it in xmit_pending */
 
 	/* Do protocol field compression (XXX this should be optional) */
@@ -1257,14 +1264,19 @@
 		--len;
 	}
 
-	/* decide on fragment size */
+	/*
+	 * Decide on fragment size.
+	 * We create a fragment for each free channel regardless of
+	 * how small they are (i.e. even 0 length) in order to minimize
+	 * the time that it will take to detect when a channel drops
+	 * a fragment.
+	 */
 	fragsize = len;
-	if (nch > 1) {
-		int maxch = ROUNDUP(len, MIN_FRAG_SIZE);
-		if (nch > maxch)
-			nch = maxch;
-		fragsize = ROUNDUP(fragsize, nch);
-	}
+	if (nfree > 1)
+		fragsize = ROUNDUP(fragsize, nfree);
+	/* nbigger channels get fragsize bytes, the rest get fragsize-1,
+	   except if nbigger==0, then they all get fragsize. */
+	nbigger = len % nfree;
 
 	/* skip to the channel after the one we last used
 	   and start at that one */
@@ -1278,7 +1290,7 @@
 
 	/* create a fragment for each channel */
 	bits = B;
-	do {
+	while (nfree > 0 || len > 0) {
 		list = list->next;
 		if (list == &ppp->channels) {
 			i = 0;
@@ -1289,61 +1301,92 @@
 		if (!pch->avail)
 			continue;
 
+		/*
+		 * Skip this channel if it has a fragment pending already and
+		 * we haven't given a fragment to all of the free channels.
+		 */
+		if (pch->avail == 1) {
+			if (nfree > 0)
+				continue;
+		} else {
+			--nfree;
+			pch->avail = 1;
+		}
+
 		/* check the channel's mtu and whether it is still attached. */
 		spin_lock_bh(&pch->downl);
-		if (pch->chan == 0 || (mtu = pch->chan->mtu) < hdrlen) {
-			/* can't use this channel */
+		if (pch->chan == NULL) {
+			/* can't use this channel, it's being deregistered */
 			spin_unlock_bh(&pch->downl);
 			pch->avail = 0;
-			if (--nch == 0)
+			if (--navail == 0)
 				break;
 			continue;
 		}
 
 		/*
-		 * We have to create multiple fragments for this channel
-		 * if fragsize is greater than the channel's mtu.
+		 * Create a fragment for this channel of
+		 * min(max(mtu+2-hdrlen, 4), fragsize, len) bytes.
+		 * If mtu+2-hdrlen < 4, that is a ridiculously small
+		 * MTU, so we use mtu = 2 + hdrlen.
 		 */
 		if (fragsize > len)
 			fragsize = len;
-		for (flen = fragsize; flen > 0; flen -= fnb) {
-			fnb = flen;
-			if (fnb > mtu + 2 - hdrlen)
-				fnb = mtu + 2 - hdrlen;
-			if (fnb >= len)
-				bits |= E;
-			frag = alloc_skb(fnb + hdrlen, GFP_ATOMIC);
-			if (frag == 0)
-				goto noskb;
-			q = skb_put(frag, fnb + hdrlen);
-			/* make the MP header */
-			q[0] = PPP_MP >> 8;
-			q[1] = PPP_MP;
-			if (ppp->flags & SC_MP_XSHORTSEQ) {
-				q[2] = bits + ((ppp->nxseq >> 8) & 0xf);
-				q[3] = ppp->nxseq;
-			} else {
-				q[2] = bits;
-				q[3] = ppp->nxseq >> 16;
-				q[4] = ppp->nxseq >> 8;
-				q[5] = ppp->nxseq;
-			}
+		flen = fragsize;
+		mtu = pch->chan->mtu + 2 - hdrlen;
+		if (mtu < 4)
+			mtu = 4;
+		if (flen > mtu)
+			flen = mtu;
+		if (flen == len && nfree == 0)
+			bits |= E;
+		frag = alloc_skb(flen + hdrlen + (flen == 0), GFP_ATOMIC);
+		if (frag == 0)
+			goto noskb;
+		q = skb_put(frag, flen + hdrlen);
+
+		/* make the MP header */
+		q[0] = PPP_MP >> 8;
+		q[1] = PPP_MP;
+		if (ppp->flags & SC_MP_XSHORTSEQ) {
+			q[2] = bits + ((ppp->nxseq >> 8) & 0xf);
+			q[3] = ppp->nxseq;
+		} else {
+			q[2] = bits;
+			q[3] = ppp->nxseq >> 16;
+			q[4] = ppp->nxseq >> 8;
+			q[5] = ppp->nxseq;
+		}
 
-			/* copy the data in */
-			memcpy(q + hdrlen, p, fnb);
+		/*
+		 * Copy the data in.
+		 * Unfortunately there is a bug in older versions of
+		 * the Linux PPP multilink reconstruction code where it
+		 * drops 0-length fragments.  Therefore we make sure the
+		 * fragment has at least one byte of data.  Any bytes
+		 * we add in this situation will end up as padding on the
+		 * end of the reconstructed packet.
+		 */
+		if (flen == 0)
+			*skb_put(frag, 1) = 0;
+		else
+			memcpy(q + hdrlen, p, flen);
 
-			/* try to send it down the channel */
-			chan = pch->chan;
-			if (!chan->ops->start_xmit(chan, frag))
-				skb_queue_tail(&pch->file.xq, frag);
-			pch->had_frag = 1;
-			p += fnb;
-			len -= fnb;
-			++ppp->nxseq;
-			bits = 0;
-		}
+		/* try to send it down the channel */
+		chan = pch->chan;
+		if (skb_queue_len(&pch->file.xq)
+		    || !chan->ops->start_xmit(chan, frag))
+			skb_queue_tail(&pch->file.xq, frag);
+		pch->had_frag = 1;
+		p += flen;
+		len -= flen;
+		++ppp->nxseq;
+		bits = 0;
 		spin_unlock_bh(&pch->downl);
-	} while (len > 0);
+
+		if (--nbigger == 0 && fragsize > 0)
+			--fragsize;
+	}
 	ppp->nxchan = i;
 
 	return 1;
@@ -1422,7 +1465,7 @@
 		kfree_skb(skb);
 		return;
 	}
-	
+
 	proto = PPP_PROTO(skb);
 	read_lock_bh(&pch->upl);
 	if (pch->ppp == 0 || proto >= 0xc000 || proto == PPP_CCPFRAG) {
@@ -1691,7 +1734,7 @@
 	struct list_head *l;
 	int mphdrlen = (ppp->flags & SC_MP_SHORTSEQ)? MPHDRLEN_SSN: MPHDRLEN;
 
-	if (!pskb_may_pull(skb, mphdrlen + 1) || ppp->mrru == 0)
+	if (!pskb_may_pull(skb, mphdrlen) || ppp->mrru == 0)
 		goto err;		/* no good, throw it away */
 
 	/* Decode sequence number and begin/end bits */
