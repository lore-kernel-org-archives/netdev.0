From: akpm@linux-foundation.org
Subject: [patch 8/8] forcedeth boot delay fix
Date: Wed, 21 Nov 2007 15:02:58 -0800
Message-ID: <200711212302.lALN2ww0013673@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	aabdulla@nvidia.com, astinus@gentoo.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41086 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754104AbXKUXDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:03:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ayaz Abdulla <aabdulla@nvidia.com>

Fix a long boot delay in the forcedeth driver.  During initialization, the
timeout for the handshake between mgmt unit and driver can be very long. 
The patch reduces the timeout by eliminating a extra loop around the
timeout logic.

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=9308

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Alex Howells <astinus@gentoo.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-boot-delay-fix drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-boot-delay-fix
+++ a/drivers/net/forcedeth.c
@@ -5294,19 +5294,15 @@ static int __devinit nv_probe(struct pci
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
 			}
 		}
_
