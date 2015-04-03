From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v1] bonding: LACP state machine variable "port-moved" is never set
Date: Fri,  3 Apr 2015 13:54:10 -0700
Message-ID: <1428094450-9308-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:32843 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbbDCUyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 16:54:13 -0400
Received: by iebtr6 with SMTP id tr6so12671332ieb.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 13:54:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The state-machine checks for the presence of this flag and attempts
to clear it but the value is never set. So why have it?

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 451d9dbd392f..cc37183f2a8a 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1018,8 +1018,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 		port->sm_rx_state = AD_RX_INITIALIZE;
 		port->sm_vars |= AD_PORT_CHURNED;
 	/* check if port is not enabled */
-	} else if (!(port->sm_vars & AD_PORT_BEGIN)
-		 && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
+	} else if (!(port->sm_vars & AD_PORT_BEGIN) && !port->is_enabled)
 		port->sm_rx_state = AD_RX_PORT_DISABLED;
 	/* check if new lacpdu arrived */
 	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) ||
@@ -1047,11 +1046,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
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
@@ -1081,7 +1077,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->sm_vars &= ~AD_PORT_SELECTED;
 			__record_default(port);
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
-			port->sm_vars &= ~AD_PORT_MOVED;
 			port->sm_rx_state = AD_RX_PORT_DISABLED;
 
 			/* Fall Through */
-- 
2.2.0.rc0.207.ga3a616c
