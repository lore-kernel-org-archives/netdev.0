From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] sky2: FE+ vlan workaround
Date: Thu, 27 Sep 2007 12:32:44 -0700
Message-ID: <20070927123244.0257ab86@freepuppy.rosehill>
References: <20070926175847.706025d0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59265 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753800AbXI0Tdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:33:31 -0400
In-Reply-To: <20070926175847.706025d0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The FE+ workaround means the driver can no longer trust the status register
to indicate VLAN tagged frames.  The fix for this is to just disable VLAN
acceleration for that chip version. Tested and works fine.

This patch applies to 2.6.23-rc8 after yesterday's patch:
      sky2 FE+ receive status workaround

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-27 08:45:13.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-27 09:43:15.000000000 -0700
@@ -3970,8 +3970,12 @@ static __devinit struct net_device *sky2
 		dev->features |= NETIF_F_HIGHDMA;
 
 #ifdef SKY2_VLAN_TAG_USED
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = sky2_vlan_rx_register;
+	/* The workaround for FE+ status conflicts with VLAN tag detection. */
+	if (!(sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	      sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0)) {
+		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		dev->vlan_rx_register = sky2_vlan_rx_register;
+	}
 #endif
 
 	/* read the mac address */
