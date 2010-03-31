From: Ben McKeegan <ben@netservers.co.uk>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP multi-link
Date: Wed, 31 Mar 2010 11:03:44 +0100
Message-ID: <4BB31E00.8060204@netservers.co.uk>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>	<20100326160226.0159ac3b@lxorguk.ukuu.org.uk>	<4BACE827.4070006@gmail.com> <20100326170428.6c1ad66c@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090600080204040506070408"
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Alexander E. Patrakov" <patrakov@gmail.com>,
	Richard Hartmann <richih.mailinglist@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20100326170428.6c1ad66c@lxorguk.ukuu.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090600080204040506070408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

>>> Making it runtime per link selectable would be nicer but thats a bit more
>>> work.
>> Doesn't it work already via echoing values to 
>> /sys/module/ppp/generic/parameters/ml_explode in the above code?
> 
> Thats runtime (and why I set 0600 in the permissions for the example) but
> not per link.
> 

I needed to do something similar a while back and I took a very 
different approach, which I think is more flexible.   Rather than 
implement a new round-robin scheduler I simply introduced a target 
minimum fragment size into the fragment size calculation, as a per 
bundle parameter that can be configured via a new ioctl.  This modifies 
the algorithm so that it tries to limit the number of fragments such 
that each fragment is at least the minimum size.  If the minimum size is 
greater than the packet size it will not be fragmented all but will 
instead just get sent down the next available channel.

A pppd plugin generates the ioctl call allowing this to be tweaked per 
connection.  It is more flexible in that you can still have the larger 
packets fragmented if you wish.

We've used a variant of this patch on our ADSL LNS pool for a few years 
now with varying results.  We originally did it to save bandwidth as we 
have a per packet overhead and fragmenting tiny packets such as VoIP 
across a bundle of 4 lines made no sense at all.  We've experimented 
with higher minimum settings up to and above the link MTU, thus 
achieving the equivalent of Richard's patch.

In some cases this has improved performance, others it makes it worse. 
It depends a lot on the lines and traffic patterns, and it is certainly 
not a change we would wish to have on by default.  Any solution going 
into mainline kernel would need to be tunable per connection.  One of 
the issues seems to be with poor recovery from packet loss on low 
volume, highly delay sensitive traffic on large bundles of lines.  With 
Linux at both ends you are relying on received sequence numbers to 
detect loss.  When packets are being fragmented across all channels and 
a fragment is lost, the receiving system is able to spot the lost 
fragment fairly quickly.  Once you start sending some multilink frames 
down individual channels, it takes a lot longer for the receiver to 
notice the packet loss on an individual channel.  Until another fragment 
is successfully received on the lossy channel, the fragments of the 
incomplete frame sit in the queue clogging up the other channels (the 
receiver is attempting to preserve the original packet order and is 
still waiting for the lost fragment).

Original patch attached.   This almost certainly needs updating to take 
account of other more recent changes in multi link algorithm but it may 
provide some inspiration.

Regards,
Ben.


--------------090600080204040506070408
Content-Type: text/x-diff;
 name="mppp-min-frag-size.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mppp-min-frag-size.patch"

diff -ubdr linux-2.6.16.16-l2tp/drivers/net/ppp_generic.c linux-2.6.16.16-l2tp-mppp/drivers/net/ppp_generic.c
--- linux-2.6.16.16-l2tp/drivers/net/ppp_generic.c	2006-05-11 02:56:24.000000000 +0100
+++ linux-2.6.16.16-l2tp-mppp/drivers/net/ppp_generic.c	2007-07-03 18:23:35.000000000 +0100
@@ -64,7 +64,7 @@
 
 #define MPHDRLEN	6	/* multilink protocol header length */
 #define MPHDRLEN_SSN	4	/* ditto with short sequence numbers */
-#define MIN_FRAG_SIZE	64
+#define MIN_FRAG_SIZE	256
 
 /*
  * An instance of /dev/ppp can be associated with either a ppp
@@ -120,6 +120,7 @@
 	unsigned long	last_recv;	/* jiffies when last pkt rcvd a0 */
 	struct net_device *dev;		/* network interface device a4 */
 #ifdef CONFIG_PPP_MULTILINK
+        int             minfragsize;    /* minimum size for a fragment */
 	int		nxchan;		/* next channel to send something on */
 	u32		nxseq;		/* next sequence number to send */
 	int		mrru;		/* MP: max reconst. receive unit */
@@ -767,6 +768,15 @@
 		ppp_recv_unlock(ppp);
 		err = 0;
 		break;
+
+	case PPPIOCSMINFRAG:
+	        if (get_user(val, p))
+	                break;
+	        ppp_recv_lock(ppp);
+	        ppp->minfragsize = val < 0 ? 0 : val;
+	        ppp_recv_unlock(ppp);
+	        err = 0;
+	        break;
 #endif /* CONFIG_PPP_MULTILINK */
 
 	default:
@@ -1254,7 +1264,7 @@
 	int len, fragsize;
 	int i, bits, hdrlen, mtu;
 	int flen;
-	int navail, nfree;
+	int navail, nfree, nfrag;
 	int nbigger;
 	unsigned char *p, *q;
 	struct list_head *list;
@@ -1285,7 +1295,7 @@
 	 * the channels are free.  This gives much better TCP
 	 * performance if we have a lot of channels.
 	 */
-	if (nfree == 0 || nfree < navail / 2)
+	if (nfree == 0 || (nfree < navail / 2 && ppp->minfragsize == 0))
 		return 0;	/* can't take now, leave it in xmit_pending */
 
 	/* Do protocol field compression (XXX this should be optional) */
@@ -1302,13 +1312,24 @@
 	 * how small they are (i.e. even 0 length) in order to minimize
 	 * the time that it will take to detect when a channel drops
 	 * a fragment.
+         * However, if ppp->minfragsize > 0 we try to avoid creating
+         * fragments smaller than ppp->minfragsize and thus do not
+         * always use all free channels
 	 */
+	if (ppp->minfragsize > 0) {
+	  nfrag= len / ppp->minfragsize;
+	  if (nfrag < 1)
+	        nfrag = 1;
+	  else if (nfrag > nfree)
+	        nfrag = nfree;
+	} else
+	        nfrag = nfree;
 	fragsize = len;
-	if (nfree > 1)
-		fragsize = DIV_ROUND_UP(fragsize, nfree);
+	if (nfrag > 1)
+	        fragsize = DIV_ROUND_UP(fragsize, nfrag);
 	/* nbigger channels get fragsize bytes, the rest get fragsize-1,
 	   except if nbigger==0, then they all get fragsize. */
-	nbigger = len % nfree;
+	nbigger = len % nfrag;
 
 	/* skip to the channel after the one we last used
 	   and start at that one */
@@ -1323,7 +1344,7 @@
 
 	/* create a fragment for each channel */
 	bits = B;
-	while (nfree > 0 || len > 0) {
+	while (len > 0 || (nfree > 0 && ppp->minfragsize == 0)) {
 		list = list->next;
 		if (list == &ppp->channels) {
 			i = 0;
@@ -1371,7 +1392,7 @@
 			mtu = 4;
 		if (flen > mtu)
 			flen = mtu;
-		if (flen == len && nfree == 0)
+		if (flen == len && (nfree == 0 || ppp->minfragsize != 0))
 			bits |= E;
 		frag = alloc_skb(flen + hdrlen + (flen == 0), GFP_ATOMIC);
 		if (frag == 0)
@@ -2435,6 +2456,7 @@
 	spin_lock_init(&ppp->rlock);
 	spin_lock_init(&ppp->wlock);
 #ifdef CONFIG_PPP_MULTILINK
+	ppp->minfragsize = MIN_FRAG_SIZE;
 	ppp->minseq = -1;
 	skb_queue_head_init(&ppp->mrq);
 #endif /* CONFIG_PPP_MULTILINK */
diff -ubdr linux-2.6.16.16-l2tp/include/linux/if_ppp.h linux-2.6.16.16-l2tp-mppp/include/linux/if_ppp.h
--- linux-2.6.16.16-l2tp/include/linux/if_ppp.h	2006-05-12 13:45:00.000000000 +0100
+++ linux-2.6.16.16-l2tp-mppp/include/linux/if_ppp.h	2007-07-03 18:15:27.000000000 +0100
@@ -162,6 +162,7 @@
 #define PPPIOCATTCHAN	_IOW('t', 56, int)	/* attach to ppp channel */
 #define PPPIOCGCHAN	_IOR('t', 55, int)	/* get ppp channel number */
 #define PPPIOCGL2TPSTATS _IOR('t', 54, struct pppol2tp_ioc_stats)
+#define PPPIOCSMINFRAG  _IOW('t', 53, int)  /* minimum fragment size */
 
 #define SIOCGPPPSTATS   (SIOCDEVPRIVATE + 0)
 #define SIOCGPPPVER     (SIOCDEVPRIVATE + 1)	/* NEVER change this!! */

--------------090600080204040506070408--
