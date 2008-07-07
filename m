From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan tag by hand
Date: Mon, 7 Jul 2008 22:56:46 +0200
Message-ID: <20080707205646.GB12997@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57543 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755AbYGGU4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 16:56:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When inserting a vlan tag into an skb by hand (in the case the
target network device hardware does not support inserting a vlan
tag by passing it in via the TX descriptor), making a copy of the
skb to be modified by calling skb_copy() is overkill, since
skb_copy() will needlessly linearize the skb, copying of all of
the fragmented data around, and checksumming the paket in software
even if the hardware is perfectly capable of doing that by itself.

For this case, pskb_copy() does exactly what is needed and no more,
so use that instead.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.26-rc9/net/8021q/vlan_dev.c
===================================================================
--- linux-2.6.26-rc9.orig/net/8021q/vlan_dev.c
+++ linux-2.6.26-rc9/net/8021q/vlan_dev.c
@@ -74,7 +74,7 @@ static inline struct sk_buff *vlan_check
 {
 	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		if (skb_shared(skb) || skb_cloned(skb)) {
-			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
+			struct sk_buff *nskb = pskb_copy(skb, GFP_ATOMIC);
 			kfree_skb(skb);
 			skb = nskb;
 		}
