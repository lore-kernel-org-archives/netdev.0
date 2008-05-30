From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10835] New: vanilla kernel 2.6.25.4 + TLAN NIC
 driver oops or so...
Date: Thu, 29 May 2008 23:44:37 -0700
Message-ID: <20080529234437.d624a07d.akpm@linux-foundation.org>
References: <bug-10835-10286@http.bugzilla.kernel.org/>
	<20080529224237.26c9d2e2.akpm@linux-foundation.org>
	<15aed8130805292332o6e2f939du416c362f6b448989@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: "Wizard Vandal" <wizard580@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35979 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbYE3Gok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 02:44:40 -0400
In-Reply-To: <15aed8130805292332o6e2f939du416c362f6b448989@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 May 2008 17:32:07 +1100 "Wizard Vandal" <wizard580@gmail.com> wrote:

> > I assume you meant 2.6.25.1 here.
> Maybe... as I said, I don't know is it my luck or something else...
> 
> >It could only have been
> >       "TLAN:  Couldn't allocate memory for received data.\n"
> Again maybe. I looked at sorce, but I'm too little programmer to see why it
> can print such error or fix that.

OK, thanks.

Can you please add the below patch and retest?  That at least will tell
us where it is failing.  I expect the driver has a memory leak.

> One more thing:
> now, I've tried to remove nf_conntrack_ftp module and kernel crashed.
> Screen not checked, just reset and go away. Keyboard leds again blinks, as
> always when it crashed.
> 
> Do I have to post new bug or you can do all checks or whatever without it?

Yes, please send a separate report.  Just an emailed one to

netdev@vger.kernel.org
Andrew Morton <akpm@linux-foundation.org>

will suffice.

Please try to ensure that this netfilter problem is not mixed up with
the tlan one.  For example, if tlan has used all the memory up then
perhaps netfilter did a memory allocation, then that failed and we hit
an untested error path.


--- a/drivers/net/tlan.c~a
+++ a/drivers/net/tlan.c
@@ -1580,9 +1580,12 @@ static u32 TLan_HandleRxEOF( struct net_
 
 		if (bbuf) {
 			skb = dev_alloc_skb(frameSize + 7);
-			if (skb == NULL)
-				printk(KERN_INFO "TLAN: Couldn't allocate memory for received data.\n");
-			else {
+			if (skb == NULL) {
+				printk(KERN_INFO "TLAN: Couldn't allocate "
+					"memory for received data: %d.\n",
+					__LINE__);
+				mdelay(1000);
+			} else {
 				head_buffer = priv->rxBuffer + (priv->rxHead * TLAN_MAX_FRAME_SIZE);
 				skb_reserve(skb, 2);
 				t = (void *) skb_put(skb, frameSize);
@@ -1619,8 +1622,12 @@ static u32 TLan_HandleRxEOF( struct net_
 				head_list->buffer[0].address = pci_map_single(priv->pciDev, new_skb->data, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
 				head_list->buffer[8].address = (u32) t;
 				TLan_StoreSKB(head_list, new_skb);
-			} else
-				printk(KERN_WARNING "TLAN:  Couldn't allocate memory for received data.\n" );
+			} else {
+				printk(KERN_INFO "TLAN: Couldn't allocate "
+					"memory for received data: %d.\n",
+					__LINE__);
+				mdelay(1000);
+			}
 		}
 
 		head_list->forward = 0;
@@ -2021,7 +2028,10 @@ static void TLan_ResetLists( struct net_
 		} else {
 			skb = dev_alloc_skb( TLAN_MAX_FRAME_SIZE + 7 );
 			if ( skb == NULL ) {
-				printk( "TLAN:  Couldn't allocate memory for received data.\n" );
+				printk(KERN_INFO "TLAN: Couldn't allocate "
+					"memory for received data: %d.\n",
+					__LINE__);
+				mdelay(1000);
 				/* If this ever happened it would be a problem */
 			} else {
 				skb->dev = dev;
_

