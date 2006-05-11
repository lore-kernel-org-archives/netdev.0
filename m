From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: prevent dual port receiver problems
Date: Thu, 11 May 2006 15:07:28 -0700
Message-ID: <20060511150728.473bb4bf@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56712 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750785AbWEKWH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 18:07:29 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k4BM7StH008563
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 11 May 2006 15:07:28 -0700
Received: from localhost.localdomain (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k4BM7SGG028349
	for <netdev@vger.kernel.org>; Thu, 11 May 2006 15:07:28 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When both ports are receiving simultaneously, the receive logic gets confused
and may pass up a packet before it is full. This causes hangs, and IP will see
lots of garbage packets. There is even the potential for data corruption if 
a later arriving packet DMA's into freed memory. 

It looks like a hardware bug because status arrives for a packet but no
data is there. Until this bug is worked out, block the user from bringing
up both ports at once.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -1020,8 +1020,19 @@ static int sky2_up(struct net_device *de
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u32 ramsize, rxspace, imask;
-	int err = -ENOMEM;
+	int err;
+	struct net_device *otherdev = hw->dev[sky2->port^1];
 
+	/* Block bringing up both ports at the same time on a dual port card.
+	 * There is an unfixed bug where receiver gets confused and picks up
+	 * packets out of order. Until this is fixed, prevent data corruption.
+	 */
+	if (otherdev && netif_running(otherdev)) {
+		printk(KERN_INFO PFX "dual port support is disabled.\n");
+		return -EBUSY;
+	}
+
+	err = -ENOMEM;
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
