From: Stefan Rompf <stefan@loplof.de>
Subject: [PATCH] core: linkwatch should use jiffies64
Date: Sun, 7 May 2006 12:13:56 +0200
Message-ID: <200605071213.56877.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natfrord.rzone.de ([81.169.145.161]:49639 "EHLO
	natfrord.rzone.de") by vger.kernel.org with ESMTP id S932116AbWEGKNm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 06:13:42 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

the linkwatch code can overflow on a jiffies wrap, scheduling
work with a too large delay. If the delay is >0x80000000,
internal_add_timer() seems to overflow too, hiding the bug, so
this isn't triggered too easily.

Best solution is to use jiffies64 for calculation as these
events happen with any possible delay in between.

This should be 2.6.17 stuff.

Signed-off-by: Stefan Rompf <stefan@loplof.de>

--- linux-2.6.17-rc3/net/core/link_watch.c.orig	2006-04-27 20:37:09.000000000 +0200
+++ linux-2.6.17-rc3/net/core/link_watch.c	2006-04-27 21:49:00.000000000 +0200
@@ -32,8 +32,8 @@
 	LW_SE_USED
 };
 
+static u64 linkwatch_nextevent;
 static unsigned long linkwatch_flags;
-static unsigned long linkwatch_nextevent;
 
 static void linkwatch_event(void *dummy);
 static DECLARE_WORK(linkwatch_work, linkwatch_event, NULL);
@@ -136,7 +136,7 @@
 	 * cause a storm of messages on the netlink
 	 * socket
 	 */	
-	linkwatch_nextevent = jiffies + HZ;
+	linkwatch_nextevent = get_jiffies_64() + HZ;
 	clear_bit(LW_RUNNING, &linkwatch_flags);
 
 	rtnl_lock();
@@ -170,7 +170,7 @@
 		spin_unlock_irqrestore(&lweventlist_lock, flags);
 
 		if (!test_and_set_bit(LW_RUNNING, &linkwatch_flags)) {
-			unsigned long thisevent = jiffies;
+			u64 thisevent = get_jiffies_64();
 
 			if (thisevent >= linkwatch_nextevent) {
 				schedule_work(&linkwatch_work);
