From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH v2 net 6/6] bonding: disallow change of MAC if fail_over_mac enabled
Date: Fri, 31 May 2013 14:57:31 -0700
Message-ID: <1370037451-29466-7-git-send-email-fubar@us.ibm.com>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:37777 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757279Ab3EaV54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 17:57:56 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 31 May 2013 17:57:55 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id DAC596E8048
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:49 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VLvrtJ289838
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:53 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VLvq4f025845
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:57:53 -0300
In-Reply-To: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Currently, if fail_over_mac is set to active, then attempts to
change the MAC of the bond itself silently fail.  However, if fail_over_mac
is set to follow, changes are permitted.

	Permitting the bond's MAC to change with fail_over_mac=follow
will disrupt the follow functionality, which normally controls the
assignment of MAC address to the bond and its slaves, and can cause
multiple ports to be assigned the same MAC address. which will interfere
with the functioning of the device (where the device here is a
virtualization-aware card for s390, qeth).

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4953f66..bc1246f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3780,11 +3780,10 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	pr_debug("bond=%p, name=%s\n",
 		 bond, bond_dev ? bond_dev->name : "None");
 
-	/*
-	 * If fail_over_mac is set to active, do nothing and return
-	 * success.  Returning an error causes ifenslave to fail.
+	/* If fail_over_mac is enabled, do nothing and return success.
+	 * Returning an error causes ifenslave to fail.
 	 */
-	if (bond->params.fail_over_mac == BOND_FOM_ACTIVE)
+	if (bond->params.fail_over_mac)
 		return 0;
 
 	if (!is_valid_ether_addr(sa->sa_data))
-- 
1.7.1
