From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next v2 4/5] bonding: fix LACP PDU not sent on slave port sometimes
Date: Mon, 26 Jan 2015 01:17:00 -0500
Message-ID: <1422253021-3798-5-git-send-email-jtoppins@cumulusnetworks.com>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Satish Ashok <sashok@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:64401 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbbAZGUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 01:20:18 -0500
Received: by mail-qc0-f169.google.com with SMTP id b13so5678539qcw.0
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 22:20:18 -0800 (PST)
In-Reply-To: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

When a slave is added to a bond and it is not in full duplex mode,
AD_PORT_LACP_ENABLED flag is cleared, due to this LACP PDU is not sent
on slave. When the duplex is changed to full, the flag needs to be set
to send LACP PDU.

Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/bonding/bond_3ad.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index e3c96b2..cfc4a9c 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2219,8 +2219,10 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
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
@@ -2312,7 +2314,10 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
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
