From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] tg3: Do not call device_set_wakeup_enable() under spin_lock_bh
Date: Tue, 26 Oct 2010 01:01:55 +0200
Message-ID: <201010260101.56128.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:51883 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751311Ab0JYXC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 19:02:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

The tg3 driver calls device_set_wakeup_enable() under spin_lock_bh,
which causes a problem to happen after the recent core power
management changes, because this function can sleep now.  Fix this
by moving the device_set_wakeup_enable() call out of the
spin_lock_bh-protected area.

Reported-by: Maxim Levitsky <maximlevitsky@gmail.com>
Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---

Hi,

This fixes a regression from 2.6.36, please apply.

Thanks,
Rafael

---
 drivers/net/tg3.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -9732,16 +9732,16 @@ static int tg3_set_wol(struct net_device
 	    !((tp->tg3_flags & TG3_FLAG_WOL_CAP) && device_can_wakeup(dp)))
 		return -EINVAL;
 
+	device_set_wakeup_enable(dp, wol->wolopts & WAKE_MAGIC);
+
 	spin_lock_bh(&tp->lock);
-	if (wol->wolopts & WAKE_MAGIC) {
+	if (device_may_wakeup(dp))
 		tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
-		device_set_wakeup_enable(dp, true);
-	} else {
+	else
 		tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
-		device_set_wakeup_enable(dp, false);
-	}
 	spin_unlock_bh(&tp->lock);
 
+
 	return 0;
 }
 
