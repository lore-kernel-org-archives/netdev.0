From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH 2/3] via-velocity: Take spinlock on set coalesce
Date: Fri, 5 Feb 2010 16:55:05 +0100
Message-ID: <20100205165505.30657e84@marrow.netinsight.se>
References: <20100205165253.3f316b98@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, ben@decadent.org.uk
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:39627 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753634Ab0BEPzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 10:55:10 -0500
In-Reply-To: <20100205165253.3f316b98@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

velocity_set_coalesce touches ISR and some other sensitive registers not
covered by the rtnl lock, so take the velocity spinlock.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 5c73673..5e213f7 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3341,6 +3341,7 @@ static int velocity_set_coalesce(struct net_device *dev,
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	int max_us = 0x3f * 64;
+	unsigned long flags;
 
 	/* 6 bits of  */
 	if (ecmd->tx_coalesce_usecs > max_us)
@@ -3362,6 +3363,7 @@ static int velocity_set_coalesce(struct net_device *dev,
 			ecmd->tx_coalesce_usecs);
 
 	/* Setup the interrupt suppression and queue timers */
+	spin_lock_irqsave(&vptr->lock, flags);
 	mac_disable_int(vptr->mac_regs);
 	setup_adaptive_interrupts(vptr);
 	setup_queue_timers(vptr);
@@ -3369,6 +3371,7 @@ static int velocity_set_coalesce(struct net_device *dev,
 	mac_write_int_mask(vptr->int_mask, vptr->mac_regs);
 	mac_clear_isr(vptr->mac_regs);
 	mac_enable_int(vptr->mac_regs);
+	spin_unlock_irqrestore(&vptr->lock, flags);
 
 	return 0;
 }
-- 
1.6.0.4

