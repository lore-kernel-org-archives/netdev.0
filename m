From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] mpc836x: fix failed phy detection for ucc ethernet on MDS
Date: Mon, 27 Feb 2012 07:25:01 -0500
Message-ID: <1330345501-24949-1-git-send-email-paul.gortmaker@windriver.com>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: afleming@freescale.com, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52524 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab2B0MZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 07:25:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mpc836x_mds platform has been broken since the commit
6fe3264945ee63292cdfb27b6e95bc52c603bb09

  "netdev/phy: Use mdiobus_read() so that proper locks are taken"

which caused the fsl_pq_mdio TBI autoprobe to oops.  The oops
was "fixed" in commit 28d8ea2d568534026ccda3e8936f5ea1e04a86a1

  "fsl_pq_mdio: Clean up tbi address configuration"

by simply removing the the autoscan code, and making tbi nodes
mandatory.  Some of the newer reference platforms were updated
to have tbi nodes in 220669495bf8b68130a8218607147c7b74c28d2b

  "powerpc: Add TBI PHY node to first MDIO bus"

but the older mpc836x didn't get one and hence was just failing
with -EBUSY as follows:

 fsl-pq_mdio: probe of e0102120.mdio failed with error -16
   ...
 net eth0: Could not attach to PHY
 eth0: Cannot initialize PHY, aborting.

Add a TBI node and use the 1st free address for it.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[Andy: There may be other boards that could be having this problem
  git grep -l enet.*ucc arch/powerpc/boot/dts/|xargs grep -L tbi
 shows four possible candidates -- but I've only got the 8360MDS. ]
  

diff --git a/arch/powerpc/boot/dts/mpc836x_mds.dts b/arch/powerpc/boot/dts/mpc836x_mds.dts
index 45cfa1c5..1de33ce 100644
--- a/arch/powerpc/boot/dts/mpc836x_mds.dts
+++ b/arch/powerpc/boot/dts/mpc836x_mds.dts
@@ -405,6 +405,10 @@
 				reg = <0x1>;
 				device_type = "ethernet-phy";
 			};
+			tbi-phy@2 {
+				device_type = "tbi-phy";
+				reg = <0x2>;
+			};
 		};
 
 		qeic: interrupt-controller@80 {
-- 
1.7.9.1
