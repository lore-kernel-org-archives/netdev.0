From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/5] sch_mqprio: Always set num_tc to 0 in
 mqprio_destroy()
Date: Tue, 15 Feb 2011 20:14:11 +0000
Message-ID: <1297800851.2584.16.camel@bwh-desktop>
References: <1297800733.2584.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26460 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482Ab1BOUOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 15:14:14 -0500
In-Reply-To: <1297800733.2584.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the cleanup code in mqprio_destroy() is currently conditional on
priv->qdiscs being non-null, but that condition should only apply to
the per-queue qdisc cleanup.  We should always set the number of
traffic classes back to 0 here.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/sched/sch_mqprio.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index effd4ee..ace37f9 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -29,18 +29,18 @@ static void mqprio_destroy(struct Qdisc *sch)
 	struct mqprio_sched *priv = qdisc_priv(sch);
 	unsigned int ntx;
 
-	if (!priv->qdiscs)
-		return;
-
-	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
-		qdisc_destroy(priv->qdiscs[ntx]);
+	if (priv->qdiscs) {
+		for (ntx = 0;
+		     ntx < dev->num_tx_queues && priv->qdiscs[ntx];
+		     ntx++)
+			qdisc_destroy(priv->qdiscs[ntx]);
+		kfree(priv->qdiscs);
+	}
 
 	if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
 		dev->netdev_ops->ndo_setup_tc(dev, 0);
 	else
 		netdev_set_num_tc(dev, 0);
-
-	kfree(priv->qdiscs);
 }
 
 static int mqprio_parse_opt(struct net_device *dev, struct tc_mqprio_qopt *qopt)
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

