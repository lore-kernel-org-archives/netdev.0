From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] gianfar: Fix Wake-on-LAN support
Date: Wed, 28 Jan 2009 23:35:45 +0300
Message-ID: <20090128203545.GA13928__10147.0398404219$1233175083$gmane$org@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:29362 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754661AbZA1Ufs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 15:35:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0f0ca340e57bd7446855fefd07a64249acf81223 ("phy: power
management support") caused a regression in the gianfar driver.

Now phylib turns off PHY power during suspend, and thus WOL
doesn't work anymore.

This patch workarounds the issue by enabling wakeup in the MDIO
device, i.e. just restores the old behaviour for the gianfar
driver. Note that this way all PHYs on a given MDIO bus won't
be turned off during suspend, which isn't good from the power
saving point of view.

A proper, per netdevice wakeup management support will need
a bit reworked phylib suspend/resume logic.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar_mii.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index f3706e4..f49a426 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -234,6 +234,8 @@ static int gfar_mdio_probe(struct of_device *ofdev,
 	if (NULL == new_bus)
 		return -ENOMEM;
 
+	device_init_wakeup(&ofdev->dev, 1);
+
 	new_bus->name = "Gianfar MII Bus",
 	new_bus->read = &gfar_mdio_read,
 	new_bus->write = &gfar_mdio_write,
-- 
1.5.6.5
