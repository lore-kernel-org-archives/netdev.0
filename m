From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Mon, 08 Oct 2007 16:08:35 -0700 (PDT)
Message-ID: <20071008.160835.121874561.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<470A5450.70403@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752265AbXJHXIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 19:08:36 -0400
In-Reply-To: <470A5450.70403@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Mon, 08 Oct 2007 18:01:20 +0200

> David Miller wrote:
> > +
> > +static int link_status_1g(struct niu *np, int *link_up_p)
 ...
> Should *link_up_p be set to any value before returning?
 ...
> > +out:
> > +	spin_unlock_irqrestore(&np->lock, flags);
> > +
> > +	*link_up_p = link_up;
> > +	return 0;
> > +}
> > +
> >   
> Although you added a proper return value in link_status_10g() while 
> fixing the locking issue, you should think about providing a similar 
> return value for link_status_1g() to be constistent here.

Thanks for finding these two issues.  I've fixed it in the patch
below.

Luckily, this case was harmless.  When we enable a loopback mode,
niu_open() forces the link up by calling netif_carrier_on().
Then, niu_timer() always sees -EINVAL coming back from
niu_link_status() because of these loopback checks, and in such
cases never uses the link_up value because niu_link_status_common()
will not be invoked.

Anyways, thanks again!

commit ec3ec3566a8ee3c8c262606e06299c8212ebd53f
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Oct 8 16:08:17 2007 -0700

    [NIU]: Make sure link_up status is set to something in link_status_{1,10}g().
    
    Noticed by Oliver Hartkopp.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2a69cee..7c09243 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -1082,13 +1082,14 @@ static int link_status_10g(struct niu *np, int *link_up_p)
 	unsigned long flags;
 	int err, link_up;
 
-	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
-		return -EINVAL;
-
 	link_up = 0;
 
 	spin_lock_irqsave(&np->lock, flags);
 
+	err = -EINVAL;
+	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
+		return out;
+
 	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
 			BCM8704_PMD_RCV_SIGDET);
 	if (err < 0)
@@ -1119,15 +1120,12 @@ static int link_status_10g(struct niu *np, int *link_up_p)
 	link_up = 1;
 	np->link_config.active_speed = SPEED_10000;
 	np->link_config.active_duplex = DUPLEX_FULL;
+	err = 0;
 
 out:
 	spin_unlock_irqrestore(&np->lock, flags);
 
 	*link_up_p = link_up;
-	return 0;
-
-out_err:
-	spin_unlock_irqrestore(&np->lock, flags);
 	return err;
 }
 
@@ -1138,15 +1136,16 @@ static int link_status_1g(struct niu *np, int *link_up_p)
 	u8 current_duplex;
 	int err, link_up;
 
-	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
-		return -EINVAL;
-
 	link_up = 0;
 	current_speed = SPEED_INVALID;
 	current_duplex = DUPLEX_INVALID;
 
 	spin_lock_irqsave(&np->lock, flags);
 
+	err = -EINVAL;
+	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
+		goto out;
+
 	err = mii_read(np, np->phy_addr, MII_BMSR);
 	if (err < 0)
 		goto out;
@@ -1172,6 +1171,7 @@ static int link_status_1g(struct niu *np, int *link_up_p)
 			goto out;
 		estat = err;
 
+		link_up = 1;
 		if (estat & (ESTATUS_1000_TFULL | ESTATUS_1000_THALF)) {
 			current_speed = SPEED_1000;
 			if (estat & ESTATUS_1000_TFULL)
@@ -1195,16 +1195,16 @@ static int link_status_1g(struct niu *np, int *link_up_p)
 				current_speed = SPEED_10;
 				current_duplex = DUPLEX_HALF;
 			} else
-				goto out;
+				link_up = 0;
 		}
-		link_up = 1;
 	}
+	err = 0;
 
 out:
 	spin_unlock_irqrestore(&np->lock, flags);
 
 	*link_up_p = link_up;
-	return 0;
+	return err;
 }
 
 static int niu_link_status(struct niu *np, int *link_up_p)
