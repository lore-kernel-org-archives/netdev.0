From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH/RFC] e1000: Check for hw type before enabling ipv6 TSO
Date: Mon, 26 Mar 2007 16:19:49 -0700
Message-ID: <1174951189.3347.15.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:50246 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753089AbXCZXTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 19:19:52 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2QNJp1T025381
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 19:19:51 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2QNJpFo261432
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 19:19:51 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2QNJoBx001416
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2007 19:19:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think the check for hw type is missing in e1000_set_tso()
before enabling ipv6 TSO.

e1000_probe() makes sure that NETIF_F_TSO6 is set only if
hw.mac_type > e1000_82547_rev_2. But this is not done in
e1000_set_tso() that gets called when trying to enable TSO
using ethtool.

I noticed this problem when i tried to do an ipv6 netperf
test with TSO enabled on 82541 based e1000 card.

The following patch adds this check to e1000_set_tso()

Thanks
Sridhar

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -351,10 +351,12 @@ e1000_set_tso(struct net_device *netdev, uint32_t data)
 	else
 		netdev->features &= ~NETIF_F_TSO;
 
-	if (data)
-		netdev->features |= NETIF_F_TSO6;
-	else
-		netdev->features &= ~NETIF_F_TSO6;
+	if (adapter->hw.mac_type > e1000_82547_rev_2) {
+		if (data)
+			netdev->features |= NETIF_F_TSO6;
+		else
+			netdev->features &= ~NETIF_F_TSO6;
+	}
 
 	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->tso_force = TRUE;



