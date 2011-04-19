From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] bonding: 802.3ad - fix agg_device_up
Date: Tue, 19 Apr 2011 14:09:55 +0200
Message-ID: <20110419120955.GA14302@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59841 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325Ab1DSMJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 08:09:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The slave member of struct aggregator does not necessarily point
to a slave which is part of the aggregator. It points to the
slave structure containing the aggregator structure, while
completely different slaves (or no slaves at all) may be part of
the aggregator.

The agg_device_up() function wrongly uses agg->slave to find the state of the
aggregator.  Use agg->lag_ports->slave instead. The bug has been
introduced by commit 4cd6fe1c6483cde93e2ec91f58b7af9c9eea51ad.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 494bf96..31912f1 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1482,8 +1482,11 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 
 static int agg_device_up(const struct aggregator *agg)
 {
-	return (netif_running(agg->slave->dev) &&
-		netif_carrier_ok(agg->slave->dev));
+	struct port *port = agg->lag_ports;
+	if (!port)
+		return 0;
+	return (netif_running(port->slave->dev) &&
+		netif_carrier_ok(port->slave->dev));
 }
 
 /**
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

