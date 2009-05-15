From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix link down handling in 802.3ad mode
Date: Fri, 15 May 2009 12:35:55 -0700
Message-ID: <12527.1242416155@death.nxdomain.ibm.com>
References: <20090515114432.4025a2d6@nehalam>
Cc: bonding-devel@lists.sf.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:50683 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbZEOTfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 15:35:51 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4FJWDGg022140
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:32:13 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4FJZp7E257692
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:35:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4FJZpSF006118
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:35:51 -0600
In-reply-to: <20090515114432.4025a2d6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>One of the purposes of bonding is to allow for redundant links, and failover 
>correctly if the cable is pulled. If all the members of a bonded device have
>no carrier present, the bonded device itself needs to report no carrier present
>to user space so management tools (like routing daemons) can respond.
>
>Bonding in 802.3ad mode does not work correctly for this because it incorrectly 
>chooses a link that is down as a possible aggregator.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

	Looks good.  I tested this after putting some printks in the agg
selection logic, and I don't see any undesirable side effects.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

>---	       
>This patch is a bug fix and should go into 2.6.30
>
>--- a/drivers/net/bonding/bond_3ad.c	2009-05-14 15:38:15.090363836 -0700
>+++ b/drivers/net/bonding/bond_3ad.c	2009-05-15 11:41:44.313559146 -0700
>@@ -1465,6 +1465,12 @@ static struct aggregator *ad_agg_selecti
> 	return best;
> }
>
>+static int agg_device_up(const struct aggregator *agg)
>+{
>+	return (netif_running(agg->slave->dev) &&
>+		netif_carrier_ok(agg->slave->dev));
>+}
>+
> /**
>  * ad_agg_selection_logic - select an aggregation group for a team
>  * @aggregator: the aggregator we're looking at
>@@ -1496,14 +1502,13 @@ static void ad_agg_selection_logic(struc
> 	struct port *port;
>
> 	origin = agg;
>-
> 	active = __get_active_agg(agg);
>-	best = active;
>+	best = (active && agg_device_up(active)) ? active : NULL;
>
> 	do {
> 		agg->is_active = 0;
>
>-		if (agg->num_of_ports)
>+		if (agg->num_of_ports && agg_device_up(agg))
> 			best = ad_agg_selection_test(best, agg);
>
> 	} while ((agg = __get_next_agg(agg)));
