From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 4/4] bonding: remove "port-moved" state that was never implemented
Date: Tue, 21 Feb 2017 17:08:31 -0800
Message-ID: <20170222010831.9959-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36625 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753484AbdBVBIf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:08:35 -0500
Received: by mail-pg0-f67.google.com with SMTP id z128so2091683pgb.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 17:08:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

LACP state-machine defines "port-moved" state when the same ActorSystemID
and Port are seen in a LACPDU received on different port. The state is
never set since it's not implemented. However the state-machine attempts
to clear that state occasionally. LACP state machine is already complicated
and since this state is not implemented, removing it's checks makes the
state-machine little simpler.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index edc70ffad660..431926bba9f4 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1052,8 +1052,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 		port->sm_rx_state = AD_RX_INITIALIZE;
 		port->sm_vars |= AD_PORT_CHURNED;
 	/* check if port is not enabled */
-	} else if (!(port->sm_vars & AD_PORT_BEGIN)
-		 && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
+	} else if (!(port->sm_vars & AD_PORT_BEGIN) && !port->is_enabled)
 		port->sm_rx_state = AD_RX_PORT_DISABLED;
 	/* check if new lacpdu arrived */
 	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) ||
@@ -1081,11 +1080,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			/* if no lacpdu arrived and no timer is on */
 			switch (port->sm_rx_state) {
 			case AD_RX_PORT_DISABLED:
-				if (port->sm_vars & AD_PORT_MOVED)
-					port->sm_rx_state = AD_RX_INITIALIZE;
-				else if (port->is_enabled
-					 && (port->sm_vars
-					     & AD_PORT_LACP_ENABLED))
+				if (port->is_enabled &&
+				    (port->sm_vars & AD_PORT_LACP_ENABLED))
 					port->sm_rx_state = AD_RX_EXPIRED;
 				else if (port->is_enabled
 					 && ((port->sm_vars
@@ -1115,7 +1111,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->sm_vars &= ~AD_PORT_SELECTED;
 			__record_default(port);
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
-			port->sm_vars &= ~AD_PORT_MOVED;
 			port->sm_rx_state = AD_RX_PORT_DISABLED;
 
 			/* Fall Through */
-- 
2.11.0.483.g087da7b7c-goog
