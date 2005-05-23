From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH linux-2.6.12-rc4-mm1] via-rhine: init clean-up
Date: Mon, 23 May 2005 15:50:32 -0500
Message-ID: <20050523205031.GA5910@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rl@hellgate.ch
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removed unnecessary IF checks and variable assignments, as pci_revs are
either < VTunknown0 or >= VT6102.  

dev->features is never populated.  So, there could be garbage in there
(then OR'ed with NETIF_F_SG | NETIF_F_HW_CSUM).  Also,
ethtool_op_get_tx_csum checks for NETIF_F_IP_CSUM not NETIF_F_HW_CSUM.
I am sending out a patch to fix that (in ethtool.c) shortly.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- drivers/net/via-rhine.c.orig	2005-05-21 10:52:01.000000000 -0500
+++ drivers/net/via-rhine.c	2005-05-21 15:07:29.000000000 -0500
@@ -710,21 +710,18 @@ static int __devinit rhine_init_one(stru
 
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &pci_rev);
 
-	io_size = 256;
 	phy_id = 0;
-	quirks = 0;
-	name = "Rhine";
 	if (pci_rev < VTunknown0) {
+		name = "Rhine";
 		quirks = rqRhineI;
 		io_size = 128;
-	}
-	else if (pci_rev >= VT6102) {
+	} else { 
+		io_size = 256;
 		quirks = rqWOL | rqForceReset;
 		if (pci_rev < VT6105) {
 			name = "Rhine II";
 			quirks |= rqStatusWBRace;	/* Rhine-II exclusive */
-		}
-		else {
+		} else {
 			phy_id = 1;	/* Integrated PHY, phy_id fixed to 1 */
 			if (pci_rev >= VT6105_B0)
 				quirks |= rq6patterns;
@@ -847,7 +844,7 @@ static int __devinit rhine_init_one(stru
 	dev->poll_controller = rhine_poll;
 #endif
 	if (rp->quirks & rqRhineI)
-		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
+		dev->features = NETIF_F_SG | NETIF_F_HW_CSUM;
 
 	/* dev->name not defined before register_netdev()! */
 	rc = register_netdev(dev);
