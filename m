From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH v2] gianfar: Create net device with carrier down
Date: Thu,  2 Oct 2008 14:12:24 -0700
Message-ID: <1222981944-17096-1-git-send-email-tpiepho@freescale.com>
References: <Pine.LNX.4.64.0809241534370.7680@t2.domain.actdsltmp>
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Trent Piepho <tpiepho@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:41810 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314AbYJBVU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 17:20:56 -0400
In-Reply-To: <Pine.LNX.4.64.0809241534370.7680@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device's carrier status is controlled via the functions
netif_carrier_on() and netif_carrier_off().  These set or clear a bit
indicating the carrier (aka lower level link) is down, and if the state
changed, they fire off a routing netlink event.

Add a call to netif_carrier_off() before register_netdev() so that the
newly created device will be set to carrier down.  Then when the carrier
comes up for the first time, a netlink event will be generated, as the
carrier changed from down to up.  Otherwise the initial carrier up will
appear to be changing the status from up to up, and so no event is
generated since that's not a change.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
CC: Andy Fleming <afleming@freescale.com>
---
This uses Stephen's suggestion, which works fine.  I had already tried this
in ->open(), but that creates bogus carrier up->carrier down->carrier up
netlink events when the device is opened.

 drivers/net/gianfar.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index a671270..484cf69 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -339,6 +339,9 @@ static int gfar_probe(struct platform_device *pdev)
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
 
+	/* Carrier starts down, phylib will bring it up */
+	netif_carrier_off(dev);
+
 	err = register_netdev(dev);
 
 	if (err) {
-- 
1.5.4.1

