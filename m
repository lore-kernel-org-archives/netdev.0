From: Ben McKeegan <ben@netservers.co.uk>
Subject: [PATCH] ppp: fix lost fragments in ppp_mp_explode()
Date: Tue, 28 Jul 2009 14:35:48 +0100
Message-ID: <4A6EFEB4.2000500@netservers.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gabriele.paoloni@intel.com, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: davem@davemloft.net, paulus@samba.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch fixes the corner cases where the sum of MTU of the free 
channels (adjusted for fragmentation overheads) is less than the MTU of 
PPP link.  There are at least 3 situations where this case might arise:

- some of the channels are busy
- the multilink session is running in a degraded state (i.e. with less 
than its full complement of active channels)
- by design, where multilink protocol is being used to artificially 
increase the effective link MTU of a single link.

Without this patch, at most 1 fragment is ever sent per free channel for 
a given PPP frame and any remaining part of the PPP frame that does not 
fit into those fragments is silently discarded.

This patch restores the original behaviour which was broken by commit 
9c705260feea6ae329bc6b6d5f6d2ef0227eda0a 'ppp:ppp_mp_explode() 
redesign'.  Once all 'free' channels have been given a fragment, an 
additional fragment is queued to each available channel in turn, as many 
times as necessary, until the entire PPP frame has been consumed.

Signed-off-by: Ben McKeegan <ben@netservers.co.uk>
---
diff -uprN linux-2.6.31-rc4/drivers/net/ppp_generic.c 
linux-2.6.31-rc4-multilink-fix/drivers/net/ppp_generic.c
--- linux-2.6.31-rc4/drivers/net/ppp_generic.c	2009-07-23 
03:32:59.000000000 +0100
+++ linux-2.6.31-rc4-multilink-fix/drivers/net/ppp_generic.c	2009-07-28 
13:54:49.000000000 +0100
@@ -1384,7 +1384,7 @@ static int ppp_mp_explode(struct ppp *pp

  	/* create a	fragment for each channel */
  	bits = B;
-	while (nfree > 0 &&	len	> 0) {
+	while (len	> 0) {
  		list = list->next;
  		if (list ==	&ppp->channels)	{
  			i =	0;
@@ -1431,29 +1431,31 @@ static int ppp_mp_explode(struct ppp *pp
  		*otherwise divide it according to the speed
  		*of the channel we are going to transmit on
  		*/
-		if (pch->speed == 0) {
-			flen = totlen/nfree	;
-			if (nbigger > 0) {
-				flen++;
-				nbigger--;
-			}
-		} else {
-			flen = (((totfree - nzero)*(totlen + hdrlen*totfree)) /
-				((totspeed*totfree)/pch->speed)) - hdrlen;
-			if (nbigger > 0) {
-				flen += ((totfree - nzero)*pch->speed)/totspeed;
-				nbigger -= ((totfree - nzero)*pch->speed)/
+		if (nfree > 0) {
+			if (pch->speed == 0) {
+				flen = totlen/nfree	;
+				if (nbigger > 0) {
+					flen++;
+					nbigger--;
+				}
+			} else {
+				flen = (((totfree - nzero)*(totlen + hdrlen*totfree)) /
+					((totspeed*totfree)/pch->speed)) - hdrlen;
+				if (nbigger > 0) {
+					flen += ((totfree - nzero)*pch->speed)/totspeed;
+					nbigger -= ((totfree - nzero)*pch->speed)/
  							totspeed;
+				}
  			}
+			nfree--;
  		}
-		nfree--;

  		/*
  		 *check	if we are on the last channel or
  		 *we exceded the lenght	of the data	to
  		 *fragment
  		 */
-		if ((nfree == 0) || (flen > len))
+		if ((nfree <= 0) || (flen > len))
  			flen = len;
  		/*
  		 *it is not worth to tx on slow channels:
@@ -1467,7 +1469,7 @@ static int ppp_mp_explode(struct ppp *pp
  			continue;
  		}

-		mtu	= pch->chan->mtu + 2 - hdrlen;
+		mtu	= pch->chan->mtu - hdrlen;
  		if (mtu	< 4)
  			mtu	= 4;
  		if (flen > mtu)

