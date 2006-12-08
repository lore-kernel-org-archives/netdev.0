From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] MACB: Use struct delayed_work instead of struct work_struct
Date: Fri, 8 Dec 2006 14:37:35 +0100
Message-ID: <20061208143735.7050553a@dhcp-252-105.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	Andrew Victor <andrew@sanpeople.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:51369 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758606AbWLHNiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 08:38:04 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The macb driver calls schedule_delayed_work() and friends, so we need
to use a struct delayed_work along with it. The conversion was
explained by David Howells on lkml Dec 5 2006:

http://lkml.org/lkml/2006/12/5/269

Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/macb.c |    6 +++---
 drivers/net/macb.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index bd0ce98..3496d19 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -267,9 +267,9 @@ static void macb_update_stats(struct mac
 		*p += readl(reg);
 }
 
-static void macb_periodic_task(void *arg)
+static void macb_periodic_task(struct work_struct *work)
 {
-	struct macb *bp = arg;
+	struct macb *bp = container_of(work, struct macb, periodic_task.work);
 
 	macb_update_stats(bp);
 	macb_check_media(bp, 1, 0);
@@ -1088,7 +1088,7 @@ static int __devinit macb_probe(struct p
 
 	dev->base_addr = regs->start;
 
-	INIT_WORK(&bp->periodic_task, macb_periodic_task, bp);
+	INIT_DELAYED_WORK(&bp->periodic_task, macb_periodic_task);
 	mutex_init(&bp->mdio_mutex);
 	init_completion(&bp->mdio_complete);
 
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 8c253db..e3fcb2e 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -377,7 +377,7 @@ struct macb {
 
 	unsigned int		rx_pending, tx_pending;
 
-	struct work_struct	periodic_task;
+	struct delayed_work	periodic_task;
 
 	struct mutex		mdio_mutex;
 	struct completion	mdio_complete;
-- 
1.4.3.3

