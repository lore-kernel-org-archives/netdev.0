From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: Null dereference in uli526x_rx_packet()
Date: Fri, 27 Mar 2009 23:23:32 -0400
Message-ID: <20090328032332.GA22353@bombadil.infradead.org>
References: <Pine.LNX.4.64.0903270801020.5354@usbsys.site> <20090328024754.GA16554@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <error27@gmail.com>, grundler@parisc-linux.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33242 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbZC1DXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 23:23:34 -0400
Content-Disposition: inline
In-Reply-To: <20090328024754.GA16554@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2009 at 10:47:54PM -0400, Kyle McMartin wrote:
> > I don't know if the right fix is to return like this patch does or to set 
> > skb = rxptr->rx_skb_ptr again.
> > 
> 
> Ick... that's a good catch. I'll have to think about this.
> 

I think this is alright, it at least keeps the original intent of the
code. I don't pretend to have figured it out yet though.

I'll stare more at this Monday...

I guess the real question is does anyone still have one of these
cards. I don't think I do, just the proper tulips. :/

diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 030e02e..9264a58 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -840,13 +840,15 @@ static void uli526x_rx_packet(struct net_device *dev, struct uli526x_board_info
 
 			if ( !(rdes0 & 0x8000) ||
 				((db->cr6_data & CR6_PM) && (rxlen>6)) ) {
+				struct sk_buff *new_skb = NULL;
+
 				skb = rxptr->rx_skb_ptr;
 
 				/* Good packet, send to upper layer */
 				/* Shorst packet used new SKB */
-				if ( (rxlen < RX_COPY_SIZE) &&
-					( (skb = dev_alloc_skb(rxlen + 2) )
-					!= NULL) ) {
+				if ((rxlen < RX_COPY_SIZE) &&
+				    ((new_skb = dev_alloc_skb(rxlen + 2) != NULL))) {
+					skb = new_skb;
 					/* size less than COPY_SIZE, allocate a rxlen SKB */
 					skb_reserve(skb, 2); /* 16byte align */
 					memcpy(skb_put(skb, rxlen),
