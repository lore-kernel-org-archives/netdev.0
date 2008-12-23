From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 06/10] 802.3ad: generalize out mac address initializer
Date: Tue, 23 Dec 2008 23:01:07 +0100
Message-ID: <20081223220557.631160792@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49959 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbYLWWGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:03 -0500
Content-Disposition: inline; filename=bonding-3ad-mcast-addr-initializer.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generalize out mac address initializer for the LACPDU multicast
address and use in two places.  Remove the now unused
AD_MULTICAST_LACPDU_ADDR.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -95,6 +95,8 @@ static struct mac_addr null_mac_addr = {
 static u16 ad_ticks_per_sec;
 static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
 
+static const u8 lacpdu_mcast_addr[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
+
 // ================= main 802.3ad protocol functions ==================
 static int ad_lacpdu_send(struct port *port);
 static int ad_marker_send(struct port *port, struct bond_marker *marker);
@@ -824,7 +826,6 @@ static int ad_lacpdu_send(struct port *p
 	struct sk_buff *skb;
 	struct lacpdu_header *lacpdu_header;
 	int length = sizeof(struct lacpdu_header);
-	struct mac_addr lacpdu_multicast_address = AD_MULTICAST_LACPDU_ADDR;
 
 	skb = dev_alloc_skb(length);
 	if (!skb) {
@@ -839,10 +840,12 @@ static int ad_lacpdu_send(struct port *p
 
 	lacpdu_header = (struct lacpdu_header *)skb_put(skb, length);
 
-	lacpdu_header->ad_header.destination_address = lacpdu_multicast_address;
-	/* Note: source addres is set to be the member's PERMANENT address, because we use it
-	   to identify loopback lacpdus in receive. */
-	lacpdu_header->ad_header.source_address = *((struct mac_addr *)(slave->perm_hwaddr));
+	memcpy(lacpdu_header->ad_header.destination_address.mac_addr_value,
+		   lacpdu_mcast_addr, ETH_ALEN);
+	/* Note: source addres is set to be the member's PERMANENT address,
+	   because we use it to identify loopback lacpdus in receive. */
+	memcpy(lacpdu_header->ad_header.source_address.mac_addr_value,
+		   slave->perm_hwaddr, ETH_ALEN);
 	lacpdu_header->ad_header.length_type = PKT_TYPE_LACPDU;
 
 	lacpdu_header->lacpdu = port->lacpdu; // struct copy
@@ -866,7 +869,6 @@ static int ad_marker_send(struct port *p
 	struct sk_buff *skb;
 	struct bond_marker_header *marker_header;
 	int length = sizeof(struct bond_marker_header);
-	struct mac_addr lacpdu_multicast_address = AD_MULTICAST_LACPDU_ADDR;
 
 	skb = dev_alloc_skb(length + 16);
 	if (!skb) {
@@ -882,10 +884,12 @@ static int ad_marker_send(struct port *p
 
 	marker_header = (struct bond_marker_header *)skb_put(skb, length);
 
-	marker_header->ad_header.destination_address = lacpdu_multicast_address;
-	/* Note: source addres is set to be the member's PERMANENT address, because we use it
-	   to identify loopback MARKERs in receive. */
-	marker_header->ad_header.source_address = *((struct mac_addr *)(slave->perm_hwaddr));
+	memcpy(marker_header->ad_header.destination_address.mac_addr_value,
+		   lacpdu_mcast_addr, ETH_ALEN);
+	/* Note: source addres is set to be the member's PERMANENT address,
+	   because we use it to identify loopback MARKERs in receive. */
+	memcpy(marker_header->ad_header.source_address.mac_addr_value,
+		   slave->perm_hwaddr, ETH_ALEN);
 	marker_header->ad_header.length_type = PKT_TYPE_LACPDU;
 
 	marker_header->marker = *marker; // struct copy
Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -33,7 +33,6 @@
 #define AD_TIMER_INTERVAL       100 /*msec*/
 
 #define MULTICAST_LACPDU_ADDR    {0x01, 0x80, 0xC2, 0x00, 0x00, 0x02}
-#define AD_MULTICAST_LACPDU_ADDR    {MULTICAST_LACPDU_ADDR}
 
 #define AD_LACP_SLOW 0
 #define AD_LACP_FAST 1

-- 
