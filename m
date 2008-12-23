From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 08/10] 802.3ad: remove public lacpdu_header
Date: Tue, 23 Dec 2008 23:01:09 +0100
Message-ID: <20081223220600.479443201@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50274 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbYLWWGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:06 -0500
Content-Disposition: inline; filename=bonding-3ad-remove-lacpdu_header.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's strictly not necessary to define lacpdu_header in an include
file because it's only used in ad_lacpdu_send().  Remove that definition
and use an unnamed structure instead just for our purpose.  Which also
gives a chance to use shorter names which are still descriptive.

As the port is left unmodified it's now const.

Also cleanup that function a bit by removing useless braces around
one-liners and turn C++ style comments into C comments.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -98,7 +98,6 @@ static const int ad_delta_in_ticks = (AD
 static const u8 lacpdu_mcast_addr[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
 // ================= main 802.3ad protocol functions ==================
-static int ad_lacpdu_send(struct port *port);
 static int ad_marker_send(struct port *port, struct bond_marker *marker);
 static void ad_mux_machine(struct port *port);
 static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port);
@@ -820,17 +819,19 @@ static inline void __update_lacpdu_from_
  * Returns:   0 on success
  *          < 0 on error
  */
-static int ad_lacpdu_send(struct port *port)
+static int ad_lacpdu_send(const struct port *port)
 {
 	struct slave *slave = port->slave;
 	struct sk_buff *skb;
-	struct lacpdu_header *lacpdu_header;
-	int length = sizeof(struct lacpdu_header);
+	struct {
+		struct ethhdr hdr;
+		struct lacpdu lacpdu;
+	} __packed *pdu;
+	int len = sizeof(*pdu);
 
-	skb = dev_alloc_skb(length);
-	if (!skb) {
+	skb = dev_alloc_skb(len);
+	if (skb == NULL)
 		return -ENOMEM;
-	}
 
 	skb->dev = slave->dev;
 	skb_reset_mac_header(skb);
@@ -838,15 +839,15 @@ static int ad_lacpdu_send(struct port *p
 	skb->protocol = PKT_TYPE_LACPDU;
 	skb->priority = TC_PRIO_CONTROL;
 
-	lacpdu_header = (struct lacpdu_header *)skb_put(skb, length);
+	pdu = (void *)skb_put(skb, len);
 
-	memcpy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
+	memcpy(pdu->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
 	/* Note: source addres is set to be the member's PERMANENT address,
 	   because we use it to identify loopback lacpdus in receive. */
-	memcpy(lacpdu_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
-	lacpdu_header->hdr.h_proto = PKT_TYPE_LACPDU;
+	memcpy(pdu->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
+	pdu->hdr.h_proto = PKT_TYPE_LACPDU;
 
-	lacpdu_header->lacpdu = port->lacpdu; // struct copy
+	memcpy(&pdu->lacpdu, &port->lacpdu, sizeof(pdu->lacpdu));
 
 	dev_queue_xmit(skb);
 
Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -136,11 +136,6 @@ typedef struct lacpdu {
 	u8 reserved_50[50];	     // = 0
 } lacpdu_t;
 
-typedef struct lacpdu_header {
-	struct ethhdr hdr;
-	struct lacpdu lacpdu;
-} lacpdu_header_t;
-
 // Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard)
 typedef struct bond_marker {
 	u8 subtype;		 //  = 0x02  (marker PDU)

-- 
