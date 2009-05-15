From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bonding: fix link down handling in 802.3ad mode
Date: Fri, 15 May 2009 11:44:32 -0700
Message-ID: <20090515114432.4025a2d6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sf.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36658 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122AbZEOSoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 14:44:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the purposes of bonding is to allow for redundant links, and failover 
correctly if the cable is pulled. If all the members of a bonded device have
no carrier present, the bonded device itself needs to report no carrier present
to user space so management tools (like routing daemons) can respond.

Bonding in 802.3ad mode does not work correctly for this because it incorrectly 
chooses a link that is down as a possible aggregator.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---	       
This patch is a bug fix and should go into 2.6.30

--- a/drivers/net/bonding/bond_3ad.c	2009-05-14 15:38:15.090363836 -0700
+++ b/drivers/net/bonding/bond_3ad.c	2009-05-15 11:41:44.313559146 -0700
@@ -1465,6 +1465,12 @@ static struct aggregator *ad_agg_selecti
 	return best;
 }
 
+static int agg_device_up(const struct aggregator *agg)
+{
+	return (netif_running(agg->slave->dev) &&
+		netif_carrier_ok(agg->slave->dev));
+}
+
 /**
  * ad_agg_selection_logic - select an aggregation group for a team
  * @aggregator: the aggregator we're looking at
@@ -1496,14 +1502,13 @@ static void ad_agg_selection_logic(struc
 	struct port *port;
 
 	origin = agg;
-
 	active = __get_active_agg(agg);
-	best = active;
+	best = (active && agg_device_up(active)) ? active : NULL;
 
 	do {
 		agg->is_active = 0;
 
-		if (agg->num_of_ports)
+		if (agg->num_of_ports && agg_device_up(agg))
 			best = ad_agg_selection_test(best, agg);
 
 	} while ((agg = __get_next_agg(agg)));
