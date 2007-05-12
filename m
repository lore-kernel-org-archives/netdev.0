From: olof@lixom.net
Subject: [patch 4/4] pasemi_mac: Fix local-mac-address parsing
Date: Sat, 12 May 2007 14:57:46 -0500
Message-ID: <20070512195746.GE15137@lixom.net>
References: <20070512193929.193104000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46386 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757318AbXELTzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2007 15:55:04 -0400
Content-Disposition: inline; filename=fix-mac-addr-parsing
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Turns out we have an old version of firmware that stores the mac address
in 'mac-address' as a string instead of a byte array. All versions that
use local-mac-address should have it as byte array, so no need to do
string parsing for that case.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -85,6 +85,7 @@ static int pasemi_get_mac_addr(struct pa
 {
 	struct pci_dev *pdev = mac->pdev;
 	struct device_node *dn = pci_device_to_OF_node(pdev);
+	int len;
 	const u8 *maddr;
 	u8 addr[6];
 
@@ -94,9 +95,17 @@ static int pasemi_get_mac_addr(struct pa
 		return -ENOENT;
 	}
 
-	maddr = of_get_property(dn, "local-mac-address", NULL);
+	maddr = of_get_property(dn, "local-mac-address", &len);
+
+	if (maddr && len == 6) {
+		memcpy(mac->mac_addr, maddr, 6);
+		return 0;
+	}
+
+	/* Some old versions of firmware mistakenly uses mac-address
+	 * (and as a string) instead of a byte array in local-mac-address.
+	 */
 
-	/* Fall back to mac-address for older firmware */
 	if (maddr == NULL)
 		maddr = of_get_property(dn, "mac-address", NULL);
 
@@ -106,6 +115,7 @@ static int pasemi_get_mac_addr(struct pa
 		return -ENOENT;
 	}
 
+
 	if (sscanf(maddr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &addr[0],
 		   &addr[1], &addr[2], &addr[3], &addr[4], &addr[5]) != 6) {
 		dev_warn(&pdev->dev,
@@ -113,7 +123,8 @@ static int pasemi_get_mac_addr(struct pa
 		return -EINVAL;
 	}
 
-	memcpy(mac->mac_addr, addr, sizeof(addr));
+	memcpy(mac->mac_addr, addr, 6);
+
 	return 0;
 }
 

--
