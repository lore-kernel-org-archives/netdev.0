From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 05/10] 802.3ad: initialize ports LACPDU from const initializer
Date: Tue, 23 Dec 2008 23:01:06 +0100
Message-ID: <20081223220556.302688266@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:62809 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbYLWWGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:01 -0500
Content-Disposition: inline; filename=bonding-3ad-initialize_lacpdu-initializer.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save some text by initializing ports LACPDU from const initializer,
then get rid of ad_initialize_lacpdu().

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -107,7 +107,6 @@ static void ad_agg_selection_logic(struc
 static void ad_clear_agg(struct aggregator *aggregator);
 static void ad_initialize_agg(struct aggregator *aggregator);
 static void ad_initialize_port(struct port *port, int lacp_fast);
-static void ad_initialize_lacpdu(struct lacpdu *Lacpdu);
 static void ad_enable_collecting_distributing(struct port *port);
 static void ad_disable_collecting_distributing(struct port *port);
 static void ad_marker_info_received(struct bond_marker *marker_info, struct port *port);
@@ -1659,6 +1658,17 @@ static void ad_initialize_port(struct po
 		.port_priority   = 0xff,
 		.port_state      = 1,
 	};
+	static const struct lacpdu lacpdu = {
+		.subtype		= 0x01,
+		.version_number = 0x01,
+		.tlv_type_actor_info = 0x01,
+		.actor_information_length = 0x14,
+		.tlv_type_partner_info = 0x02,
+		.partner_information_length = 0x14,
+		.tlv_type_collector_info = 0x03,
+		.collector_information_length = 0x10,
+		.collector_max_delay = htons(AD_COLLECTOR_MAX_DELAY),
+	};
 
 	if (port) {
 		port->actor_port_number = 1;
@@ -1695,7 +1705,7 @@ static void ad_initialize_port(struct po
 		port->next_port_in_aggregator = NULL;
 		port->transaction_id = 0;
 
-		ad_initialize_lacpdu(&(port->lacpdu));
+		memcpy(&port->lacpdu, &lacpdu, sizeof(lacpdu));
 	}
 }
 
@@ -1804,53 +1814,6 @@ static void ad_marker_response_received(
 	// DO NOTHING, SINCE WE DECIDED NOT TO IMPLEMENT THIS FEATURE FOR NOW
 }
 
-/**
- * ad_initialize_lacpdu - initialize a given lacpdu structure
- * @lacpdu: lacpdu structure to initialize
- *
- */
-static void ad_initialize_lacpdu(struct lacpdu *lacpdu)
-{
-	u16 index;
-
-	// initialize lacpdu data
-	lacpdu->subtype = 0x01;
-	lacpdu->version_number = 0x01;
-	lacpdu->tlv_type_actor_info = 0x01;
-	lacpdu->actor_information_length = 0x14;
-	// lacpdu->actor_system_priority    updated on send
-	// lacpdu->actor_system             updated on send
-	// lacpdu->actor_key                updated on send
-	// lacpdu->actor_port_priority      updated on send
-	// lacpdu->actor_port               updated on send
-	// lacpdu->actor_state              updated on send
-	lacpdu->tlv_type_partner_info = 0x02;
-	lacpdu->partner_information_length = 0x14;
-	for (index=0; index<=2; index++) {
-		lacpdu->reserved_3_1[index]=0;
-	}
-	// lacpdu->partner_system_priority  updated on send
-	// lacpdu->partner_system           updated on send
-	// lacpdu->partner_key              updated on send
-	// lacpdu->partner_port_priority    updated on send
-	// lacpdu->partner_port             updated on send
-	// lacpdu->partner_state            updated on send
-	for (index=0; index<=2; index++) {
-		lacpdu->reserved_3_2[index]=0;
-	}
-	lacpdu->tlv_type_collector_info = 0x03;
-	lacpdu->collector_information_length= 0x10;
-	lacpdu->collector_max_delay = htons(AD_COLLECTOR_MAX_DELAY);
-	for (index=0; index<=11; index++) {
-		lacpdu->reserved_12[index]=0;
-	}
-	lacpdu->tlv_type_terminator = 0x00;
-	lacpdu->terminator_length = 0;
-	for (index=0; index<=49; index++) {
-		lacpdu->reserved_50[index]=0;
-	}
-}
-
 //////////////////////////////////////////////////////////////////////////////////////
 // ================= AD exported functions to the main bonding code ==================
 //////////////////////////////////////////////////////////////////////////////////////

-- 
