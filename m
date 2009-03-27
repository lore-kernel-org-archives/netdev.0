From: Dan Carpenter <error27@gmail.com>
Subject: Null dereference in uli526x_rx_packet()
Date: Fri, 27 Mar 2009 13:31:36 +0300 (EAT)
Message-ID: <Pine.LNX.4.64.0903270801020.5354@usbsys.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: grundler@parisc-linux.org, kyle@mcmartin.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:11738 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911AbZC0KeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 06:34:20 -0400
Received: by fg-out-1718.google.com with SMTP id e12so350922fga.17
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 03:34:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch (http://repo.or.cz/w/smatch.git/) complains about the error 
handling in uli526x_rx_packet().

I don't know if the right fix is to return like this patch does or to set 
skb = rxptr->rx_skb_ptr again.

regards,
dan carpenter

--- orig/drivers/net/tulip/uli526x.c	2009-03-27 07:52:32.000000000 +0300
+++ devel/drivers/net/tulip/uli526x.c	2009-03-27 07:57:05.000000000 +0300
@@ -844,10 +844,13 @@
 
 				/* Good packet, send to upper layer */
 				/* Shorst packet used new SKB */
-				if ( (rxlen < RX_COPY_SIZE) &&
-					( (skb = dev_alloc_skb(rxlen + 2) )
-					!= NULL) ) {
-					/* size less than COPY_SIZE, allocate a rxlen SKB */
+				/* size less than COPY_SIZE, allocate a rxlen SKB */
+				if (rxlen < RX_COPY_SIZE) {
+					skb = dev_alloc_skb(rxlen + 2);
+					if (!skb)
+						return;
+				}
+				if (rxlen < RX_COPY_SIZE) {
 					skb_reserve(skb, 2); /* 16byte align */
 					memcpy(skb_put(skb, rxlen),
 					       skb_tail_pointer(rxptr->rx_skb_ptr),
