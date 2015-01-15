From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/8] can: dev: fix crtlmode_supported check
Date: Thu, 15 Jan 2015 17:11:17 +0100
Message-ID: <1421338283-12417-3-git-send-email-mkl@pengutronix.de>
References: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56599 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbbAOQLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 11:11:32 -0500
In-Reply-To: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

When changing flags in the CAN drivers ctrlmode the provided new content has to
be checked whether the bits are allowed to be changed. The bits that are to be
changed are given as a bitfield in cm->mask. Therefore checking against
cm->flags is wrong as the content can hold any kind of values.

The iproute2 tool sets the bits in cm->mask and cm->flags depending on the
detected command line options. To be robust against bogus user space
applications additionally sanitize the provided flags with the provided mask.

Cc: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 3ec8f6f25e5f..847c1f813261 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -807,10 +807,14 @@ static int can_changelink(struct net_device *dev,
 		if (dev->flags & IFF_UP)
 			return -EBUSY;
 		cm = nla_data(data[IFLA_CAN_CTRLMODE]);
-		if (cm->flags & ~priv->ctrlmode_supported)
+
+		/* check whether changed bits are allowed to be modified */
+		if (cm->mask & ~priv->ctrlmode_supported)
 			return -EOPNOTSUPP;
+
+		/* clear bits to be modified and copy the flag values */
 		priv->ctrlmode &= ~cm->mask;
-		priv->ctrlmode |= cm->flags;
+		priv->ctrlmode |= (cm->flags & cm->mask);
 
 		/* CAN_CTRLMODE_FD can only be set when driver supports FD */
 		if (priv->ctrlmode & CAN_CTRLMODE_FD)
-- 
2.1.4
