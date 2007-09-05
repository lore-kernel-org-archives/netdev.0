From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: restore multicast list on resume and other ops
Date: Wed, 5 Sep 2007 16:56:19 +0100
Message-ID: <20070905165619.093513af@oldman>
References: <200708312010.38276.timo@tiwe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Timo =?UTF-8?B?V2VpbmfDpHJ0bmVy?= <timo@tiwe.de>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33447 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752844AbXIEP4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 11:56:39 -0400
In-Reply-To: <200708312010.38276.timo@tiwe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to restore multicast settings on resume and after 'ethtool -r'.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-05 13:57:22.000000000 +0100
+++ b/drivers/net/sky2.c	2007-09-05 13:57:24.000000000 +0100
@@ -149,6 +149,8 @@ static const char *yukon2_name[] = {
 	"FE",		/* 0xb7 */
 };
 
+static void sky2_set_multicast(struct net_device *dev);
+
 /* Access to external PHY */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
@@ -2900,8 +2902,10 @@ static int sky2_set_settings(struct net_
 	sky2->autoneg = ecmd->autoneg;
 	sky2->advertising = ecmd->advertising;
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
 		sky2_phy_reinit(sky2);
+		sky2_set_multicast(dev);
+	}
 
 	return 0;
 }
@@ -2994,6 +2998,7 @@ static int sky2_nway_reset(struct net_de
 		return -EINVAL;
 
 	sky2_phy_reinit(sky2);
+	sky2_set_multicast(dev);
 
 	return 0;
 }
@@ -4171,6 +4176,8 @@ static int sky2_resume(struct pci_dev *p
 				dev_close(dev);
 				goto out;
 			}
+
+			sky2_set_multicast(dev);
 		}
 	}
 
