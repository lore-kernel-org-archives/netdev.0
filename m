From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next 4/5] bonding: fix LACP PDU not sent on slave port sometimes
Date: Fri, 16 Jan 2015 10:57:27 -0500
Message-ID: <1421423848-414-5-git-send-email-jtoppins@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:54737 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289AbbAPP5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 10:57:45 -0500
Received: by mail-qg0-f50.google.com with SMTP id z60so16868449qgd.9
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 07:57:44 -0800 (PST)
In-Reply-To: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

When a slave is added to a bond and it is not in full duplex mode,
AD_PORT_LACP_ENABLED flag is cleared, due to this LACP PDU is not sent
on slave. When the duplex is changed to full, the flag needs to be set
to send LACP PDU.

Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/bonding/bond_3ad.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 52a8772..43bb0b0 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2224,8 +2224,10 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 		switch (lacpdu->subtype) {
 		case AD_TYPE_LACPDU:
 			ret = RX_HANDLER_CONSUMED;
-			netdev_dbg(slave->bond->dev, "Received LACPDU on port %d\n",
-				   port->actor_port_number);
+			netdev_dbg(slave->bond->dev,
+				   "Received LACPDU on port %d slave %s\n",
+				   port->actor_port_number,
+				   slave->dev->name);
 			/* Protect against concurrent state machines */
 			spin_lock(&slave->bond->mode_lock);
 			ad_rx_machine(lacpdu, port);
@@ -2317,7 +2319,10 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		__get_duplex(port);
-	netdev_dbg(slave->bond->dev, "Port %d changed duplex\n", port->actor_port_number);
+	netdev_dbg(slave->bond->dev, "Port %d slave %s changed duplex\n",
+		   port->actor_port_number, slave->dev->name);
+	if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
+		port->sm_vars |= AD_PORT_LACP_ENABLED;
 	/* there is no need to reselect a new aggregator, just signal the
 	 * state machines to reinitialize
 	 */
-- 
1.7.10.4
