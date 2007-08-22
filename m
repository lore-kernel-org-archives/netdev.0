From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [10/10] pasemi_mac: Clean TX ring in poll
Date: Wed, 22 Aug 2007 09:13:35 -0500
Message-ID: <20070822141335.GK16830@lixom.net>
References: <20070817205413.548020000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:45805 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762723AbXHVPQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:16:45 -0400
Content-Disposition: inline; filename=pasemi_mac-clean-tx-in-poll
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unfortunately there's no timeout for how long a packet can sit on
the TX ring after completion before an interrupt is generated, and
we want to have a threshold that's larger than one packet per interrupt.

So we have to have a timer that occasionally cleans the TX ring even
though there hasn't been an interrupt. Instead of setting up a dedicated
timer for this, just clean it in the NAPI poll routine instead.


Signed-off-by: Olof Johansson <olof@lixom.net>

---

I know I got this rejected last time it was submitted, but no answers with
suggestions on how to handle it better. I'm all ears if there's a better
way.  (I noticed that Intel's new ixgbe driver does the same thing).

Index: mainline/drivers/net/pasemi_mac.c
===================================================================
--- mainline.orig/drivers/net/pasemi_mac.c
+++ mainline/drivers/net/pasemi_mac.c
@@ -1086,6 +1086,7 @@ static int pasemi_mac_poll(struct net_de
 	int pkts, limit = min(*budget, dev->quota);
 	struct pasemi_mac *mac = netdev_priv(dev);
 
+	pasemi_mac_clean_tx(mac);
 	pkts = pasemi_mac_clean_rx(mac, limit);
 
 	dev->quota -= pkts;

--
