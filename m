From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH UPDATED] bonding: Fix 802.3ad no carrier on "no partner found" instance
Date: Wed, 13 Jun 2007 22:11:34 -0700
Message-ID: <29862.1181797894@death>
References: <97949e3e0706011316n5d90bb04kf3a2c556af3fbe9d@mail.gmail.com> <466B28D9.6040806@garzik.org>
Cc: Laurent Chavey <chavey@google.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:48282 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbXFNFLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 01:11:38 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5E5ChmK008764
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 01:12:43 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5E5BbVV558474
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 01:11:37 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5E5BaM9026763
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 01:11:37 -0400
In-reply-to: <466B28D9.6040806@garzik.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Modify carrier state determination for 802.3ad mode to comply
with section 43.3.9 of IEEE 802.3, which requires that "Links that are
not successful candidates for aggregation (e.g., links that are attached
to other devices that cannot perform aggregation or links that have been
manually configured to be non-aggregatable) are enabled to operate as
individual IEEE 802.3 links."

	Bug reported by Laurent Chavey <chavey@google.com>.  This patch
is an updated version of his patch that changes the wording of
commentary and adds an update to the driver version.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Laurent Chavey <chavey@google.com>


diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7e03f41..f829e4a 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2303,19 +2303,18 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 }
 
 /*
- * set link state for bonding master: if we have an active partnered
+ * set link state for bonding master: if we have an active 
  * aggregator, we're up, if not, we're down.  Presumes that we cannot
  * have an active aggregator if there are no slaves with link up.
  *
+ * This behavior complies with IEEE 802.3 section 43.3.9.
+ *
  * Called by bond_set_carrier(). Return zero if carrier state does not
  * change, nonzero if it does.
  */
 int bond_3ad_set_carrier(struct bonding *bond)
 {
-	struct aggregator *agg;
-
-	agg = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
-	if (agg && MAC_ADDRESS_COMPARE(&agg->partner_system, &null_mac_addr)) {
+	if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
 		if (!netif_carrier_ok(bond->dev)) {
 			netif_carrier_on(bond->dev);
 			return 1;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 41aa78b..a891021 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.1.2"
-#define DRV_RELDATE	"January 20, 2007"
+#define DRV_VERSION	"3.1.3"
+#define DRV_RELDATE	"June 13, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
