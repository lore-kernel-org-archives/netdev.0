From: Tanli Chang <Tanli.Chang@Sun.COM>
Subject: NIU: Add support for C10NEM
Date: Tue, 26 May 2009 11:30:42 -0700
Message-ID: <4A1C3552.2040602@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_bZe6TAFIkqTM5GwPIZ8IZQ)"
Cc: Santwona.Behera@Sun.COM, Matheos.Worku@Sun.COM
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:39409 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbZEZSbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 14:31:01 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n4QIUmK4024904
	for <netdev@vger.kernel.org>; Tue, 26 May 2009 11:31:00 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.02 64bit (built Apr 16 2009))
 id <0KK900900KIE1H00@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Tue,
 26 May 2009 11:30:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_bZe6TAFIkqTM5GwPIZ8IZQ)
Content-type: text/plain; CHARSET=US-ASCII; format=flowed
Content-transfer-encoding: 7BIT

This patch is for supporting C10NEM. C10NEM is a switch module, which 
has back-to-back XAUI link connected to blades.

--Boundary_(ID_bZe6TAFIkqTM5GwPIZ8IZQ)
Content-type: text/x-patch; name=0001--NIU-Add-support-for-C10NEM.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=0001--NIU-Add-support-for-C10NEM.patch

Signed-off-by: Tanli Chang <tanli.chang@sun.com>
---
 drivers/net/niu.c |   57 +++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 47 insertions(+), 10 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..0d9de5a 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -1317,7 +1317,7 @@ static int bcm8704_reset(struct niu *np)
 
 	err = mdio_read(np, np->phy_addr,
 			BCM8704_PHYXS_DEV_ADDR, MII_BMCR);
-	if (err < 0)
+	if (err < 0 || err == 0xffff)
 		return err;
 	err |= BMCR_RESET;
 	err = mdio_write(np, np->phy_addr, BCM8704_PHYXS_DEV_ADDR,
@@ -2042,7 +2042,7 @@ static int link_status_10g_bcm8706(struct niu *np, int *link_up_p)
 
 	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
 			BCM8704_PMD_RCV_SIGDET);
-	if (err < 0)
+	if (err < 0 || err == 0xffff)
 		goto out;
 	if (!(err & PMD_RCV_SIGDET_GLOBAL)) {
 		err = 0;
@@ -2083,8 +2083,6 @@ static int link_status_10g_bcm8706(struct niu *np, int *link_up_p)
 
 out:
 	*link_up_p = link_up;
-	if (np->flags & NIU_FLAGS_HOTPLUG_PHY)
-		err = 0;
 	return err;
 }
 
@@ -2220,10 +2218,17 @@ static int link_status_10g_hotplug(struct niu *np, int *link_up_p)
 		if (phy_present != phy_present_prev) {
 			/* state change */
 			if (phy_present) {
+				/* A NEM was just plugged in */
 				np->flags |= NIU_FLAGS_HOTPLUG_PHY_PRESENT;
 				if (np->phy_ops->xcvr_init)
 					err = np->phy_ops->xcvr_init(np);
 				if (err) {
+					err = mdio_read(np, np->phy_addr,
+						BCM8704_PHYXS_DEV_ADDR, MII_BMCR);
+					if (err == 0xffff) {
+						/* No mdio, back-to-back XAUI */
+						goto out;
+					}
 					/* debounce */
 					np->flags &= ~NIU_FLAGS_HOTPLUG_PHY_PRESENT;
 				}
@@ -2234,13 +2239,21 @@ static int link_status_10g_hotplug(struct niu *np, int *link_up_p)
 					np->dev->name);
 			}
 		}
-		if (np->flags & NIU_FLAGS_HOTPLUG_PHY_PRESENT)
+out:
+		if (np->flags & NIU_FLAGS_HOTPLUG_PHY_PRESENT) {
 			err = link_status_10g_bcm8706(np, link_up_p);
+			if (err == 0xffff) {
+				/* No mdio, back-to-back XAUI: it is C10NEM */
+				*link_up_p = 1;
+				np->link_config.active_speed = SPEED_10000;
+				np->link_config.active_duplex = DUPLEX_FULL;
+			}
+		}
 	}
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	return err;
+	return 0;
 }
 
 static int niu_link_status(struct niu *np, int *link_up_p)
@@ -2312,6 +2325,12 @@ static const struct niu_phy_ops phy_ops_10g_fiber_hotplug = {
 	.link_status		= link_status_10g_hotplug,
 };
 
+static const struct niu_phy_ops phy_ops_niu_10g_hotplug = {
+	.serdes_init		= serdes_init_niu_10g_fiber,
+	.xcvr_init		= xcvr_init_10g_bcm8706,
+	.link_status		= link_status_10g_hotplug,
+};
+
 static const struct niu_phy_ops phy_ops_10g_copper = {
 	.serdes_init		= serdes_init_10g,
 	.link_status		= link_status_10g, /* XXX */
@@ -2358,6 +2377,11 @@ static const struct niu_phy_template phy_template_10g_fiber_hotplug = {
 	.phy_addr_base	= 8,
 };
 
+static const struct niu_phy_template phy_template_niu_10g_hotplug = {
+	.ops		= &phy_ops_niu_10g_hotplug,
+	.phy_addr_base	= 8,
+};
+
 static const struct niu_phy_template phy_template_10g_copper = {
 	.ops		= &phy_ops_10g_copper,
 	.phy_addr_base	= 10,
@@ -2542,8 +2566,16 @@ static int niu_determine_phy_disposition(struct niu *np)
 		case NIU_FLAGS_10G | NIU_FLAGS_FIBER:
 			/* 10G Fiber */
 		default:
-			tp = &phy_template_niu_10g_fiber;
-			phy_addr_off += np->port;
+			if (np->flags & NIU_FLAGS_HOTPLUG_PHY) {
+				tp = &phy_template_niu_10g_hotplug;
+				if (np->port == 0)
+					phy_addr_off = 8;
+				if (np->port == 1)
+					phy_addr_off = 12;
+			} else {
+				tp = &phy_template_niu_10g_fiber;
+				phy_addr_off += np->port;
+			}
 			break;
 		}
 	} else {
@@ -2630,11 +2662,11 @@ static int niu_init_link(struct niu *np)
 		msleep(200);
 	}
 	err = niu_serdes_init(np);
-	if (err)
+	if (err && !(np->flags & NIU_FLAGS_HOTPLUG_PHY))
 		return err;
 	msleep(200);
 	err = niu_xcvr_init(np);
-	if (!err)
+	if (!err || (np->flags & NIU_FLAGS_HOTPLUG_PHY))
 		niu_link_status(np, &ignore);
 	return 0;
 }
@@ -9346,6 +9378,11 @@ static int __devinit niu_get_of_props(struct niu *np)
 	if (model)
 		strcpy(np->vpd.model, model);
 
+	if (of_find_property(dp, "hot-swappable-phy", &prop_len)) {
+		np->flags |= (NIU_FLAGS_10G | NIU_FLAGS_FIBER |
+			NIU_FLAGS_HOTPLUG_PHY);
+	}
+
 	return 0;
 #else
 	return -EINVAL;
-- 
1.6.2.4


--Boundary_(ID_bZe6TAFIkqTM5GwPIZ8IZQ)--
