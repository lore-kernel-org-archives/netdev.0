From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth boot delay fix
Date: Sun, 18 Nov 2007 14:13:41 -0500
Message-ID: <47408EE5.2040302@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040108080706070904020703"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:16664 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbXKSUKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 15:10:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040108080706070904020703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes a long boot delay in the forcedeth driver. During 
initialization, the timeout for the handshake between mgmt unit and 
driver can be very long. The patch reduces the timeout by eliminating a 
extra loop around the timeout logic.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040108080706070904020703
Content-Type: text/plain;
 name="patch-forcedeth-sema-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-sema-fix"

--- old/drivers/net/forcedeth.c	2007-11-08 17:33:00.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-11-08 17:34:25.000000000 -0500
@@ -5286,20 +5286,17 @@
 		if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) {
 			np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
 			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n", pci_name(pci_dev), np->mac_in_use);
-			for (i = 0; i < 5000; i++) {
-				msleep(1);
-				if (nv_mgmt_acquire_sema(dev)) {
-					/* management unit setup the phy already? */
-					if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
-					    NVREG_XMITCTL_SYNC_PHY_INIT) {
-						/* phy is inited by mgmt unit */
-						phyinitialized = 1;
-						dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
-					} else {
-						/* we need to init the phy */
-					}
-					break;
+			if (nv_mgmt_acquire_sema(dev)) {
+				/* management unit setup the phy already? */
+				if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
+				    NVREG_XMITCTL_SYNC_PHY_INIT) {
+					/* phy is inited by mgmt unit */
+					phyinitialized = 1;
+					dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
+				} else {
+					/* we need to init the phy */
 				}
+				break;
 			}
 		}
 	}

--------------040108080706070904020703--
