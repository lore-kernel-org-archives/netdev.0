From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: 802.3ad - fix agg_device_up
Date: Tue, 19 Apr 2011 09:55:03 -0700
Message-ID: <21326.1303232103@death>
References: <20110419120955.GA14302@midget.suse.cz>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:34188 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752098Ab1DSQzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 12:55:08 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3JGTcWP020156
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 12:29:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3JGt7o2398596
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 12:55:07 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3JGt5gr013351
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 10:55:07 -0600
In-reply-to: <20110419120955.GA14302@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>The slave member of struct aggregator does not necessarily point
>to a slave which is part of the aggregator. It points to the
>slave structure containing the aggregator structure, while
>completely different slaves (or no slaves at all) may be part of
>the aggregator.
>
>The agg_device_up() function wrongly uses agg->slave to find the state of the
>aggregator.  Use agg->lag_ports->slave instead. The bug has been
>introduced by commit 4cd6fe1c6483cde93e2ec91f58b7af9c9eea51ad.
>
>Signed-off-by: Jiri Bohac <jbohac@suse.cz>

	One additional note: port->slave can be NULL when the slave is
transitioning in or out of the bond, but not when the port is part of an
aggregator, so this usage should be safe.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 494bf96..31912f1 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -1482,8 +1482,11 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
>
> static int agg_device_up(const struct aggregator *agg)
> {
>-	return (netif_running(agg->slave->dev) &&
>-		netif_carrier_ok(agg->slave->dev));
>+	struct port *port = agg->lag_ports;
>+	if (!port)
>+		return 0;
>+	return (netif_running(port->slave->dev) &&
>+		netif_carrier_ok(port->slave->dev));
> }
>
> /**
>-- 
>Jiri Bohac <jbohac@suse.cz>
>SUSE Labs, SUSE CZ
>
