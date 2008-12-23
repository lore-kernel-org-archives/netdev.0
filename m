From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 09/10] 802.3ad: remove public bond_marker_header
Date: Tue, 23 Dec 2008 23:01:10 +0100
Message-ID: <20081223220601.771614232@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:64545 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbYLWWGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:07 -0500
Content-Disposition: inline; filename=bonding-3ad-remove-bond_marker_header.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's strictly not necessary to define bond_marker_header in an include
file because it's only used in ad_lacpdu_send().  Remove that definition
and use an unnamed structure instead just for our purpose.  Which also
gives a chance to use shorter names which are still descriptive.

As the port and marker are left unmodified I've made them const.

As that function is defined before used I've left out the forward
declaration.

Also cleanup that function a bit by removing useless braces around
one-liners and turn C++ style comments into C comments.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -152,11 +152,6 @@ typedef struct bond_marker {
 	u8 reserved_90[90];	     //  = 0
 } bond_marker_t;
 
-typedef struct bond_marker_header {
-	struct ethhdr hdr;
-	struct bond_marker marker;
-} bond_marker_header_t;
-
 #pragma pack()
 
 struct slave;
Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -98,7 +98,6 @@ static const int ad_delta_in_ticks = (AD
 static const u8 lacpdu_mcast_addr[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
 // ================= main 802.3ad protocol functions ==================
-static int ad_marker_send(struct port *port, struct bond_marker *marker);
 static void ad_mux_machine(struct port *port);
 static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port);
 static void ad_tx_machine(struct port *port);
@@ -862,17 +861,20 @@ static int ad_lacpdu_send(const struct p
  * Returns:   0 on success
  *          < 0 on error
  */
-static int ad_marker_send(struct port *port, struct bond_marker *marker)
+static int ad_marker_send(const struct port *port,
+			  const struct bond_marker *marker)
 {
 	struct slave *slave = port->slave;
 	struct sk_buff *skb;
-	struct bond_marker_header *marker_header;
-	int length = sizeof(struct bond_marker_header);
+	struct {
+		struct ethhdr hdr;
+		struct bond_marker marker;
+	} __packed *pdu;
+	int len = sizeof(*pdu);
 
-	skb = dev_alloc_skb(length + 16);
-	if (!skb) {
+	skb = dev_alloc_skb(len + 16);
+	if (skb == NULL)
 		return -ENOMEM;
-	}
 
 	skb_reserve(skb, 16);
 
@@ -881,15 +883,15 @@ static int ad_marker_send(struct port *p
 	skb->network_header = skb->mac_header + ETH_HLEN;
 	skb->protocol = PKT_TYPE_LACPDU;
 
-	marker_header = (struct bond_marker_header *)skb_put(skb, length);
+	pdu = (void *)skb_put(skb, len);
 
-	memcpy(marker_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
+	memcpy(pdu->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
 	/* Note: source addres is set to be the member's PERMANENT address,
 	   because we use it to identify loopback MARKERs in receive. */
-	memcpy(marker_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
-	marker_header->hdr.h_proto = PKT_TYPE_LACPDU;
+	memcpy(pdu->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
+	pdu->hdr.h_proto = PKT_TYPE_LACPDU;
 
-	marker_header->marker = *marker; // struct copy
+	memcpy(&pdu->marker, marker, sizeof(pdu->marker));
 
 	dev_queue_xmit(skb);
 

-- 
