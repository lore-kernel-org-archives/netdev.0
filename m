From: Mark Brown <broonie@sirena.org.uk>
Subject: [PATCH] natsemi: Use round_jiffies() for slow timers
Date: Wed, 10 Oct 2007 11:05:44 +0100
Message-ID: <1192010744-12204-1-git-send-email-broonie@sirena.org.uk>
References: <470C210C.6030800@pobox.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@sirena.org.uk>
To: Jeff Garzik <jgarzik@pobox.com>, thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4638 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbXJJKFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 06:05:53 -0400
In-Reply-To: <470C210C.6030800@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unless we have failed to fill the RX ring the timer used by the natsemi
driver is not particularly urgent and can use round_jiffies() to allow
grouping with other timers.

Signed-off-by: Mark Brown <broonie@sirena.org.uk>
---
Rediffed against current netdev-2.6.git#upstream

 drivers/net/natsemi.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 527f9dc..b881786 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -1576,7 +1576,7 @@ static int netdev_open(struct net_device *dev)
 
 	/* Set the timer to check for link beat. */
 	init_timer(&np->timer);
-	np->timer.expires = jiffies + NATSEMI_TIMER_FREQ;
+	np->timer.expires = round_jiffies(jiffies + NATSEMI_TIMER_FREQ);
 	np->timer.data = (unsigned long)dev;
 	np->timer.function = &netdev_timer; /* timer handler */
 	add_timer(&np->timer);
@@ -1856,7 +1856,11 @@ static void netdev_timer(unsigned long data)
 			next_tick = 1;
 		}
 	}
-	mod_timer(&np->timer, jiffies + next_tick);
+
+	if (next_tick > 1)
+		mod_timer(&np->timer, round_jiffies(jiffies + next_tick));
+	else
+		mod_timer(&np->timer, jiffies + next_tick);
 }
 
 static void dump_ring(struct net_device *dev)
@@ -3331,7 +3335,7 @@ static int natsemi_resume (struct pci_dev *pdev)
 		spin_unlock_irq(&np->lock);
 		enable_irq(dev->irq);
 
-		mod_timer(&np->timer, jiffies + 1*HZ);
+		mod_timer(&np->timer, round_jiffies(jiffies + 1*HZ));
 	}
 	netif_device_attach(dev);
 out:
-- 
1.5.3.4

