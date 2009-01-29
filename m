From: gabriele.paoloni@intel.com
Subject: PATCH
Date: Thu, 29 Jan 2009 10:11:45 +0000
Message-ID: <498180E1.mailF4J11OSHG@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gabriele.paoloni@intel.com, ken.reynolds@intel.com,
	arjan.van.de.ven@intel.com
To: netdev@vger.kernel.org, redesign@mailhost.ir.intel.com,
	ppp_mp_explode@mailhost.ir.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31620 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbZA2KLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 05:11:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
 
My name is Gabriele Paoloni, I am a Software Engineer working in the Intel
Research and Development Center in Shannon, Ireland.
I found the PPP subsystem to not work properly when connecting channels
with different speeds to the same bundle.

Problem Description:

As the "ppp_mp_explode" function fragments the sk_buff buffer evenly among
 the PPP channels that are connected to a certain PPP unit to make up a bundle,
 if we are transmitting using an upper layer protocol that requires an Ack 
before sending the next packet (like TCP/IP for example), we will have a 
bandwidth bottleneck on the slowest channel of the bundle. 
Let's clarify by an example. Let's consider a scenario where we have two PPP 
links making up a bundle: a slow link (10KB/sec) and a fast link (1000KB/sec) 
working at the best (full bandwidth). On the top we have a TCP/IP stack sending 
a 1000 Bytes sk_buff buffer down to the PPP subsystem. The  "ppp_mp_explode" 
function will divide the buffer in two fragments of 500B each (we are neglecting 
all the headers, crc, flags etc?.). Before the TCP/IP stack sends out the next 
buffer, it will have to wait for the ACK response from the remote peer, so it will 
have to wait for both fragments to have been sent over the two PPP links, received 
by the remote peer and reconstructed. The resulting behaviour is that, rather than 
having a bundle working @1010KB/sec (the sum of the channels bandwidths), we'll 
have a bundle working @20KB/sec (the double of the slowest channels bandwidth).


Problem Solution:

The problem has been solved by redesigning the "ppp_mp_explode" function in such 
a way to make it split the sk_buff buffer according to the speeds of the underlying 
PPP channels (the speeds of the serial interfaces respectively attached to the PPP 
channels). Referring to the above example, the redesigned "ppp_mp_explode" function 
will now divide the 1000 Bytes buffer into two fragments whose sizes are set 
according to the speeds of the channels where they are going to be sent on (e.g . 
10 Byets on 10KB/sec channel and 990 Bytes on 1000KB/sec channel). 
The reworked function grants the same performances of the original one in optimal 
working conditions (i.e. a bundle made up of PPP links all working at the same 
speed), while greatly improving performances on the bundles made up of channels 
working at different speeds.


Find inline a possible solution patch.

 
Note: the kernel patch has been generated against the last stable version
      2.6.28.2
 
Best Regards
 
Gabriele Paoloni
 
email: gabriele.paoloni@intel.com
phone: +353 6 147 7753
mobile1: 00353 8333 52390
mobile2: 0039 3937498940
 
 
*******************************************************************************
*******************************************************************************
*******************************************************************************





Signed-off-by: Gabriele Paoloni <paoloni.gabriele@gmail.com> <gabriele.paoloni@intel.com>

diff -urN ./linux-2.6.28.2/drivers/net/ppp_async.c ./linux-2.6.28.2.new/drivers/net/ppp_async.c
--- ./linux-2.6.28.2/drivers/net/ppp_async.c	2009-01-25 00:42:07.000000000 +0000
+++ ./linux-2.6.28.2.new/drivers/net/ppp_async.c	2009-01-28 16:54:37.000000000 +0000
@@ -157,6 +157,7 @@
 {
 	struct asyncppp *ap;
 	int err;
+	int speed;
 
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
@@ -187,6 +188,8 @@
 	ap->chan.private = ap;
 	ap->chan.ops = &async_ops;
 	ap->chan.mtu = PPP_MRU;
+	speed = tty_get_baud_rate(tty);
+	ap->chan.speed = speed;
 	err = ppp_register_channel(&ap->chan);
 	if (err)
 		goto out_free;
diff -urN ./linux-2.6.28.2/drivers/net/ppp_generic.c ./linux-2.6.28.2.new/drivers/net/ppp_generic.c
--- ./linux-2.6.28.2/drivers/net/ppp_generic.c	2009-01-25 00:42:07.000000000 +0000
+++ ./linux-2.6.28.2.new/drivers/net/ppp_generic.c	2009-01-28 16:53:06.000000000 +0000
@@ -160,6 +160,7 @@
 	u8		avail;		/* flag used in multilink stuff */
 	u8		had_frag;	/* >= 1 fragments have been sent */
 	u32		lastseq;	/* MP: last sequence # received */
+	int     speed;		/* speed of the corresponding ppp channel*/
 #endif /* CONFIG_PPP_MULTILINK */
 };
 
@@ -1235,138 +1236,181 @@
  */
 static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 {
-	int len, fragsize;
-	int i, bits, hdrlen, mtu;
-	int flen;
-	int navail, nfree;
-	int nbigger;
+	int	len, totlen;
+	int	i, bits, hdrlen, mtu;
+	int	flen;
+	int	navail,	nfree, nzero;
+	int	nbigger;
+	int	totspeed;
+	int	totfree;
 	unsigned char *p, *q;
 	struct list_head *list;
 	struct channel *pch;
 	struct sk_buff *frag;
 	struct ppp_channel *chan;
 
-	nfree = 0;	/* # channels which have no packet already queued */
+	totspeed = 0; /*total bitrate of the bundle*/
+	nfree =	0;	/* # channels which	have no	packet already queued */
 	navail = 0;	/* total # of usable channels (not deregistered) */
+	nzero =	0; /* number of	channels with zero speed associated*/
+	totfree	= 0; /*total # of channels available and
+				  *having no queued packets before
+				  *starting the fragmentation*/
+
 	hdrlen = (ppp->flags & SC_MP_XSHORTSEQ)? MPHDRLEN_SSN: MPHDRLEN;
-	i = 0;
-	list_for_each_entry(pch, &ppp->channels, clist) {
+	i =	0;
+	list_for_each_entry(pch, &ppp->channels, clist)	{
 		navail += pch->avail = (pch->chan != NULL);
-		if (pch->avail) {
+		pch->speed = pch->chan->speed;
+		if (pch->avail)	{
 			if (skb_queue_empty(&pch->file.xq) ||
-			    !pch->had_frag) {
-				pch->avail = 2;
-				++nfree;
-			}
-			if (!pch->had_frag && i < ppp->nxchan)
-				ppp->nxchan = i;
+				!pch->had_frag)	{
+					if (pch->speed == 0)
+						nzero++;
+					else
+						totspeed += pch->speed;
+
+					pch->avail = 2;
+					++nfree;
+					++totfree;
+				}
+			if (!pch->had_frag && i	< ppp->nxchan)
+				ppp->nxchan	= i;
 		}
 		++i;
 	}
-
 	/*
-	 * Don't start sending this packet unless at least half of
-	 * the channels are free.  This gives much better TCP
-	 * performance if we have a lot of channels.
+	 * Don't start sending this	packet unless at least half	of
+	 * the channels	are	free.  This	gives much better TCP
+	 * performance if we have a	lot	of channels.
 	 */
-	if (nfree == 0 || nfree < navail / 2)
-		return 0;	/* can't take now, leave it in xmit_pending */
+	if (nfree == 0 || nfree	< navail / 2)
+		return 0; /* can't take now, leave it in xmit_pending	*/
 
 	/* Do protocol field compression (XXX this should be optional) */
-	p = skb->data;
-	len = skb->len;
+	p =	skb->data;
+	len	= skb->len;
 	if (*p == 0) {
 		++p;
 		--len;
 	}
 
-	/*
-	 * Decide on fragment size.
-	 * We create a fragment for each free channel regardless of
-	 * how small they are (i.e. even 0 length) in order to minimize
-	 * the time that it will take to detect when a channel drops
-	 * a fragment.
-	 */
-	fragsize = len;
-	if (nfree > 1)
-		fragsize = DIV_ROUND_UP(fragsize, nfree);
-	/* nbigger channels get fragsize bytes, the rest get fragsize-1,
-	   except if nbigger==0, then they all get fragsize. */
-	nbigger = len % nfree;
+	totlen = len;
+	nbigger	= len %	nfree;
 
-	/* skip to the channel after the one we last used
-	   and start at that one */
+	/* skip	to the channel after the one we	last used
+	   and start at	that one */
 	list = &ppp->channels;
-	for (i = 0; i < ppp->nxchan; ++i) {
+	for	(i = 0;	i <	ppp->nxchan; ++i) {
 		list = list->next;
-		if (list == &ppp->channels) {
-			i = 0;
+		if (list ==	&ppp->channels)	{
+			i =	0;
 			break;
 		}
 	}
 
-	/* create a fragment for each channel */
+	/* create a	fragment for each channel */
 	bits = B;
-	while (nfree > 0 || len > 0) {
+	while (nfree > 0 &&	len	> 0) {
 		list = list->next;
-		if (list == &ppp->channels) {
-			i = 0;
+		if (list ==	&ppp->channels)	{
+			i =	0;
 			continue;
 		}
-		pch = list_entry(list, struct channel, clist);
+		pch	= list_entry(list, struct channel, clist);
 		++i;
 		if (!pch->avail)
 			continue;
 
 		/*
-		 * Skip this channel if it has a fragment pending already and
-		 * we haven't given a fragment to all of the free channels.
+		 * Skip	this channel if	it has a fragment pending already and
+		 * we haven't given	a fragment to all of the free channels.
 		 */
 		if (pch->avail == 1) {
-			if (nfree > 0)
+			if (nfree >	0)
 				continue;
 		} else {
-			--nfree;
 			pch->avail = 1;
 		}
 
 		/* check the channel's mtu and whether it is still attached. */
 		spin_lock_bh(&pch->downl);
 		if (pch->chan == NULL) {
-			/* can't use this channel, it's being deregistered */
+			/* can't use this channel, it's	being deregistered */
+			if (pch->speed == 0)
+				nzero--;
+			else
+				totspeed -=	pch->speed;
+
 			spin_unlock_bh(&pch->downl);
 			pch->avail = 0;
-			if (--navail == 0)
+			totlen = len;
+			totfree--;
+			nfree--;
+			if (--navail ==	0)
 				break;
 			continue;
 		}
 
 		/*
-		 * Create a fragment for this channel of
-		 * min(max(mtu+2-hdrlen, 4), fragsize, len) bytes.
-		 * If mtu+2-hdrlen < 4, that is a ridiculously small
-		 * MTU, so we use mtu = 2 + hdrlen.
+		*if the channel speed is not set divide
+		*the packet	evenly among the free channels;
+		*otherwise divide it according to the speed
+		*of the channel we are going to transmit on
+		*/
+		if (pch->speed == 0) {
+			flen = totlen/nfree	;
+			if (nbigger > 0) {
+				flen++;
+				nbigger--;
+			}
+		} else {
+			flen = (((totfree - nzero)*(totlen + hdrlen*totfree)) /
+				((totspeed*totfree)/pch->speed)) - hdrlen;
+			if (nbigger > 0) {
+				flen += ((totfree - nzero)*pch->speed)/totspeed;
+				nbigger -= ((totfree - nzero)*pch->speed)/
+							totspeed;
+			}
+		}
+		nfree--;
+
+		/*
+		 *check	if we are on the last channel or
+		 *we exceded the lenght	of the data	to
+		 *fragment
+		 */
+		if ((nfree == 0) || (flen > len))
+			flen = len;
+		/*
+		 *it is not worth to tx on slow channels:
+		 *in that case from the resulting flen according to the
+		 *above formula will be equal or less than zero.
+		 *Skip the channel in this case
 		 */
-		if (fragsize > len)
-			fragsize = len;
-		flen = fragsize;
-		mtu = pch->chan->mtu + 2 - hdrlen;
-		if (mtu < 4)
-			mtu = 4;
+		if (flen <=	0) {
+			pch->avail = 2;
+			spin_unlock_bh(&pch->downl);
+			continue;
+		}
+
+		mtu	= pch->chan->mtu + 2 - hdrlen;
+		if (mtu	< 4)
+			mtu	= 4;
 		if (flen > mtu)
 			flen = mtu;
-		if (flen == len && nfree == 0)
-			bits |= E;
-		frag = alloc_skb(flen + hdrlen + (flen == 0), GFP_ATOMIC);
+		if (flen ==	len)
+			bits |=	E;
+		frag = alloc_skb(flen +	hdrlen + (flen == 0), GFP_ATOMIC);
 		if (!frag)
 			goto noskb;
-		q = skb_put(frag, flen + hdrlen);
+		q =	skb_put(frag, flen + hdrlen);
 
-		/* make the MP header */
+		/* make	the	MP header */
 		q[0] = PPP_MP >> 8;
 		q[1] = PPP_MP;
 		if (ppp->flags & SC_MP_XSHORTSEQ) {
-			q[2] = bits + ((ppp->nxseq >> 8) & 0xf);
+			q[2] = bits	+ ((ppp->nxseq >> 8) & 0xf);
 			q[3] = ppp->nxseq;
 		} else {
 			q[2] = bits;
@@ -1375,43 +1419,28 @@
 			q[5] = ppp->nxseq;
 		}
 
-		/*
-		 * Copy the data in.
-		 * Unfortunately there is a bug in older versions of
-		 * the Linux PPP multilink reconstruction code where it
-		 * drops 0-length fragments.  Therefore we make sure the
-		 * fragment has at least one byte of data.  Any bytes
-		 * we add in this situation will end up as padding on the
-		 * end of the reconstructed packet.
-		 */
-		if (flen == 0)
-			*skb_put(frag, 1) = 0;
-		else
-			memcpy(q + hdrlen, p, flen);
+		memcpy(q + hdrlen, p, flen);
 
 		/* try to send it down the channel */
 		chan = pch->chan;
-		if (!skb_queue_empty(&pch->file.xq) ||
-		    !chan->ops->start_xmit(chan, frag))
+		if (!skb_queue_empty(&pch->file.xq)	||
+			!chan->ops->start_xmit(chan, frag))
 			skb_queue_tail(&pch->file.xq, frag);
-		pch->had_frag = 1;
+		pch->had_frag =	1;
 		p += flen;
-		len -= flen;
+		len	-= flen;
 		++ppp->nxseq;
 		bits = 0;
 		spin_unlock_bh(&pch->downl);
-
-		if (--nbigger == 0 && fragsize > 0)
-			--fragsize;
 	}
-	ppp->nxchan = i;
+	ppp->nxchan	= i;
 
 	return 1;
 
  noskb:
 	spin_unlock_bh(&pch->downl);
 	if (ppp->debug & 1)
-		printk(KERN_ERR "PPP: no memory (fragment)\n");
+		printk(KERN_ERR	"PPP: no memory	(fragment)\n");
 	++ppp->dev->stats.tx_errors;
 	++ppp->nxseq;
 	return 1;	/* abandon the frame */
diff -urN ./linux-2.6.28.2/drivers/net/ppp_synctty.c ./linux-2.6.28.2.new/drivers/net/ppp_synctty.c
--- ./linux-2.6.28.2/drivers/net/ppp_synctty.c	2009-01-25 00:42:07.000000000 +0000
+++ ./linux-2.6.28.2.new/drivers/net/ppp_synctty.c	2009-01-28 16:55:16.000000000 +0000
@@ -206,6 +206,7 @@
 {
 	struct syncppp *ap;
 	int err;
+	int speed;
 
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
@@ -234,6 +235,8 @@
 	ap->chan.ops = &sync_ops;
 	ap->chan.mtu = PPP_MRU;
 	ap->chan.hdrlen = 2;	/* for A/C bytes */
+	speed = tty_get_baud_rate(tty);
+	ap->chan.speed = speed;
 	err = ppp_register_channel(&ap->chan);
 	if (err)
 		goto out_free;
diff -urN ./linux-2.6.28.2/include/linux/ppp_channel.h ./linux-2.6.28.2.new/include/linux/ppp_channel.h
--- ./linux-2.6.28.2/include/linux/ppp_channel.h	2009-01-25 00:42:07.000000000 +0000
+++ ./linux-2.6.28.2.new/include/linux/ppp_channel.h	2009-01-28 16:54:01.000000000 +0000
@@ -39,8 +39,8 @@
 	int		mtu;		/* max transmit packet size */
 	int		hdrlen;		/* amount of headroom channel needs */
 	void		*ppp;		/* opaque to channel */
-	/* the following are not used at present */
 	int		speed;		/* transfer rate (bytes/second) */
+	/* the following is not used at present */
 	int		latency;	/* overhead time in milliseconds */
 };
 
---------------------------------------------------------------------
Intel Shannon Limited
Registered in Ireland
Registered Office: One Spencer Dock, North Wall Quay, Dublin 1
Registered Number: 308263
Business address: Dromore House, East Park, Shannon, Co. Clare

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

