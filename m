From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 07/10] 802.3ad: use standard ethhdr instead of ad_header
Date: Tue, 23 Dec 2008 23:01:08 +0100
Message-ID: <20081223220559.192000322@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:55899 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbYLWWGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:04 -0500
Content-Disposition: inline; filename=bonding-3ad-ad_header-is-ethhdr.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

802.3ad has its own ethhdr-like structure in the form of an ad_header,
which is at the start of both the LACPDU and marker PDU.  Both are
the same from the struct values, both are packed as well.

It's therefore perfectly fine to replace the ad_header by the ethhdr
and to remove its definition.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -105,12 +105,6 @@ typedef enum {
 
 #pragma pack(1)
 
-typedef struct ad_header {
-	struct mac_addr destination_address;
-	struct mac_addr source_address;
-	__be16 length_type;
-} ad_header_t;
-
 // Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 in the 802.3ad standard)
 typedef struct lacpdu {
 	u8 subtype;		     // = LACP(= 0x01)
@@ -143,7 +137,7 @@ typedef struct lacpdu {
 } lacpdu_t;
 
 typedef struct lacpdu_header {
-	struct ad_header ad_header;
+	struct ethhdr hdr;
 	struct lacpdu lacpdu;
 } lacpdu_header_t;
 
@@ -164,7 +158,7 @@ typedef struct bond_marker {
 } bond_marker_t;
 
 typedef struct bond_marker_header {
-	struct ad_header ad_header;
+	struct ethhdr hdr;
 	struct bond_marker marker;
 } bond_marker_header_t;
 
Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -840,13 +840,11 @@ static int ad_lacpdu_send(struct port *p
 
 	lacpdu_header = (struct lacpdu_header *)skb_put(skb, length);
 
-	memcpy(lacpdu_header->ad_header.destination_address.mac_addr_value,
-		   lacpdu_mcast_addr, ETH_ALEN);
+	memcpy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
 	/* Note: source addres is set to be the member's PERMANENT address,
 	   because we use it to identify loopback lacpdus in receive. */
-	memcpy(lacpdu_header->ad_header.source_address.mac_addr_value,
-		   slave->perm_hwaddr, ETH_ALEN);
-	lacpdu_header->ad_header.length_type = PKT_TYPE_LACPDU;
+	memcpy(lacpdu_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
+	lacpdu_header->hdr.h_proto = PKT_TYPE_LACPDU;
 
 	lacpdu_header->lacpdu = port->lacpdu; // struct copy
 
@@ -884,13 +882,11 @@ static int ad_marker_send(struct port *p
 
 	marker_header = (struct bond_marker_header *)skb_put(skb, length);
 
-	memcpy(marker_header->ad_header.destination_address.mac_addr_value,
-		   lacpdu_mcast_addr, ETH_ALEN);
+	memcpy(marker_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
 	/* Note: source addres is set to be the member's PERMANENT address,
 	   because we use it to identify loopback MARKERs in receive. */
-	memcpy(marker_header->ad_header.source_address.mac_addr_value,
-		   slave->perm_hwaddr, ETH_ALEN);
-	marker_header->ad_header.length_type = PKT_TYPE_LACPDU;
+	memcpy(marker_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
+	marker_header->hdr.h_proto = PKT_TYPE_LACPDU;
 
 	marker_header->marker = *marker; // struct copy
 

-- 
