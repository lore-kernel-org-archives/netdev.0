From: "Bryan Wu" <cooloney@kernel.org>
Subject: [BUG] rmmod bfin_mac netdev driver module will cause system crash.
Date: Tue, 4 Nov 2008 16:45:13 +0800
Message-ID: <386072610811040045w2944a856jd55809f0a7532dbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Andy Fleming" <afleming@freescale.com>,
	"Byron Bradley" <byron.bbradley@gmail.com>,
	"Tim Ellis" <tim.ellis@mac.com>, "Imre Kaloz" <kaloz@openwrt.org>,
	"Nicolas Pitre" <nico@cam.org>, "Dirk Teurlings" <dirk@upexia.nl>,
	"Peter van Valderen" <p.v.valderen@gmail.com>
To: "Lennert Buytenhek" <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:55272 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbYKDIpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 03:45:14 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1130417yxm.1
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2008 00:45:13 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lennert,

I got a regression since I update our blackfin kernel to the lastest
2.6.28-rc2 which includes your phylib patches.
Please find the tracker here:
https://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_id=141&tracker_item_id=4595

Briefly, the calling chain is:
in bfin_mac_remove(), mdiobus_unregister() ->
device_unregister(&bus->dev); -> put_device() -> kobject_put() ->
kref_put(&kobj->kref, kobject_release); -> kobject_release() ->
kobject_cleanup() -> mdiobus_release().
So in mdiobus_unregister() bus->state = MDIOBUS_UNREGISTERED; but in
mdiobus_release(), this BUG_ON will fire:
BUG_ON(bus->state != MDIOBUS_RELEASED);

How about this patch?

---
Index: drivers/net/phy/mdio_bus.c
===================================================================
--- drivers/net/phy/mdio_bus.c	(revision 5575)
+++ drivers/net/phy/mdio_bus.c	(working copy)
@@ -134,13 +134,16 @@
 	int i;

 	BUG_ON(bus->state != MDIOBUS_REGISTERED);
-	bus->state = MDIOBUS_UNREGISTERED;

+	bus->state = MDIOBUS_RELEASED;
+
 	device_unregister(&bus->dev);
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
 	}
+
+	bus->state = MDIOBUS_UNREGISTERED;
 }
 EXPORT_SYMBOL(mdiobus_unregister);
---

This regression is gone, but I'm not sure whether there is some side effect.
Please review.

Thanks a lot
-Bryan
