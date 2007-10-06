From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 17:08:49 -0700 (PDT)
Message-ID: <20071005.170849.78481094.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<200710051846.19965.netdev@axxeo.de>
	<200710051849.50091.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: netdev@axxeo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60381
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753197AbXJFAIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 20:08:50 -0400
In-Reply-To: <200710051849.50091.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <netdev@axxeo.de>
Date: Fri, 5 Oct 2007 18:49:49 +0200

> Ingo Oeser schrieb:
> > > +static void niu_init_xif(struct niu *);
> > > +
> > > +static int link_status_10g(struct niu *np, int *link_up_p)
> > > +{
> > > +	unsigned long flags;
> > > +	int err, link_up;
> > > +
> > > +	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
> > > +		return -EINVAL;
> > > +
> > > +	link_up = 0;
> > > +
> > > +	spin_lock_irqsave(&np->lock, flags);
> > > +
> > > +	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
> > > +			BCM8704_PMD_RCV_SIGDET);
> > > +	if (err < 0)
> > > +		return err;
> > 
> > missing spin_unlock_irqsave()?
> 
> I mean spin_unlock_irqrestore()

Definitely a locking error, fixed below, thanks for catching
this Ingo!

>From 586752eb74a7f303eb2e0693bba0f0a8111ef1e7 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 5 Oct 2007 17:07:15 -0700
Subject: [PATCH] [NIU]: Fix locking errors in link_status_10g().

When MDIO accesses give an error we forget to drop the
np->lock, noticed by Ingo Oeser.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 64b988b..1a38530 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -1100,21 +1100,21 @@ static int link_status_10g(struct niu *np, int *link_up_p)
 	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
 			BCM8704_PMD_RCV_SIGDET);
 	if (err < 0)
-		return err;
+		goto out_err;
 	if (!(err & PMD_RCV_SIGDET_GLOBAL))
 		goto out;
 
 	err = mdio_read(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
 			BCM8704_PCS_10G_R_STATUS);
 	if (err < 0)
-		return err;
+		goto out_err;
 	if (!(err & PCS_10G_R_STATUS_BLK_LOCK))
 		goto out;
 
 	err = mdio_read(np, np->phy_addr, BCM8704_PHYXS_DEV_ADDR,
 			BCM8704_PHYXS_XGXS_LANE_STAT);
 	if (err < 0)
-		return err;
+		goto out_err;
 
 	if (err != (PHYXS_XGXS_LANE_STAT_ALINGED |
 		    PHYXS_XGXS_LANE_STAT_MAGIC |
@@ -1133,6 +1133,10 @@ out:
 
 	*link_up_p = link_up;
 	return 0;
+
+out_err:
+	spin_unlock_irqrestore(&np->lock, flags);
+	return err;
 }
 
 static int link_status_1g(struct niu *np, int *link_up_p)
-- 
1.5.3.3

