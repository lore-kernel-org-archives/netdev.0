From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] netxen: only half timeout waited
Date: Mon, 16 Feb 2009 14:55:22 +0100
Message-ID: <4999704A.9030004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:35648 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196AbZBPNzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 08:55:25 -0500
Received: by fxm13 with SMTP id 13so5834024fxm.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 05:55:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only half the timeout was waited, due to the double increment, and an error
occurred one too early.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index c3b9c83..df3aa08 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -147,12 +147,11 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
 					  &status, 4))
 			return -EIO;
-		timeout++;
 	} while ((netxen_get_gb_mii_mgmt_busy(status)
 		  || netxen_get_gb_mii_mgmt_notvalid(status))
 		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
 
-	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
+	if (timeout <= NETXEN_NIU_PHY_WAITMAX) {
 		if (adapter->hw_read_wx(adapter,
 					  NETXEN_NIU_GB_MII_MGMT_STATUS(0),
 					  readval, 4))
@@ -240,11 +239,10 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
 					  &status, 4))
 			return -EIO;
-		timeout++;
 	} while ((netxen_get_gb_mii_mgmt_busy(status))
 		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
 
-	if (timeout < NETXEN_NIU_PHY_WAITMAX)
+	if (timeout <= NETXEN_NIU_PHY_WAITMAX)
 		result = 0;
 	else
 		result = -EIO;
