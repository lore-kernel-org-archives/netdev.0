From: Thomas Graf <tgraf@suug.ch>
Subject: [NET]: Avoid duplicate netlink notification when changing link state
Date: Wed, 6 Jun 2007 00:54:53 +0200
Message-ID: <20070605225452.GV521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56652 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765749AbXFEWyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 18:54:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When changing the link state from userspace not affecting any other
flags. Two duplicate notification are being sent, once as action
in the NETDEV_UP/NETDEV_DOWN notification chain and a second time
when comparing old and new device flags after the change has been
completed. Although harmless, the duplicates should be avoided.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/core/dev.c
===================================================================
--- net-2.6.orig/net/core/dev.c	2007-06-05 17:50:13.000000000 +0200
+++ net-2.6/net/core/dev.c	2007-06-06 00:48:53.000000000 +0200
@@ -2577,7 +2577,7 @@ unsigned dev_get_flags(const struct net_
 
 int dev_change_flags(struct net_device *dev, unsigned flags)
 {
-	int ret;
+	int ret, changes;
 	int old_flags = dev->flags;
 
 	/*
@@ -2632,8 +2632,10 @@ int dev_change_flags(struct net_device *
 		dev_set_allmulti(dev, inc);
 	}
 
-	if (old_flags ^ dev->flags)
-		rtmsg_ifinfo(RTM_NEWLINK, dev, old_flags ^ dev->flags);
+	/* Exclude state transition flags, already notified */
+	changes = (old_flags ^ dev->flags) & ~(IFF_UP | IFF_RUNNING);
+	if (changes)
+		rtmsg_ifinfo(RTM_NEWLINK, dev, changes);
 
 	return ret;
 }
