From: "Michael Chan" <mchan@broadcom.com>
Subject: [1/5][TG3]: Fix irq_sync race condition.
Date: Wed, 11 Jul 2007 16:31:45 -0700
Message-ID: <1184196705.5211.8.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: gaagaan@gmail.com
To: davem@davemloft.net, mcarlson@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1215 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753378AbXGKWje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 18:39:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix irq_sync race condition.

Gagan Arneja <gaagaan@gmail.com> pointed out that tg3_reset_task()
could potentially race with another thread calling tg3_full_lock()
such as the ethtool_set_xxx() functions.  This may trigger the
BUG_ON() in tg3_irq_quiesce() or cause the irq_sync flag to be out-
of-sync.

I think the easiest way to fix this is to get the tp->lock first
before setting the irq_sync flag.  This is safe to do because the
tp->lock is never grabbed by the irq handler.  This change will
guarantee that the irq_sync flag updates will be serialized.  We also
have to change one spot to call tg3_netif_start() (which clears the
irq_sync flag) before releasing the tp->lock.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3a43426..314f5cf 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3512,9 +3512,9 @@ static inline int tg3_irq_sync(struct tg3 *tp)
  */
 static inline void tg3_full_lock(struct tg3 *tp, int irq_sync)
 {
+	spin_lock_bh(&tp->lock);
 	if (irq_sync)
 		tg3_irq_quiesce(tp);
-	spin_lock_bh(&tp->lock);
 }
 
 static inline void tg3_full_unlock(struct tg3 *tp)
@@ -9116,10 +9116,10 @@ static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
 	__tg3_set_rx_mode(dev);
 
-	tg3_full_unlock(tp);
-
 	if (netif_running(dev))
 		tg3_netif_start(tp);
+
+	tg3_full_unlock(tp);
 }
 #endif
 


