From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] sh_eth: get R8A7740 Rx descriptor word 0 shift out of #ifdef
Date: Thu, 13 Jun 2013 22:12:45 +0400
Message-ID: <201306132212.46361.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The only R8A7740 specific #ifdef hindering  ARM multiplatform build is  left in
sh_eth_rx(): it covers the code shifting Rx buffer descriptor word 0 by 16. Get
rid of the #ifdef by adding 'shift_rd0' field to the  'struct sh_eth_cpu_data',
making the shift dependent on it, and setting it to 1 for the R8A7740 case...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net-next.git' repository plus commit
dd019897358b815f7828dab90b51d51df4d3658d (net: sh_eth: fix incorrect RX length
error if R8A7740) from the 'net.git' reposirory, so please merge it into
'net-next.git' before applying this patch.

Changes in version 2:
- made a patch apply atop of Yoshihiro Shimoda's commit, updated the changelog;
- clarified the comment to the 'shift_rd0' field of 'struct sh_eth_cpu_data'.

 drivers/net/ethernet/renesas/sh_eth.c |    6 +++---
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -667,6 +667,7 @@ static struct sh_eth_cpu_data r8a7740_da
 	.no_ade		= 1,
 	.tsu		= 1,
 	.select_mii	= 1,
+	.shift_rd0	= 1,
 };
 
 static struct sh_eth_cpu_data sh7619_data = {
@@ -1266,7 +1267,6 @@ static int sh_eth_rx(struct net_device *
 		if (!(desc_status & RDFEND))
 			ndev->stats.rx_length_errors++;
 
-#if defined(CONFIG_ARCH_R8A7740)
 		/*
 		 * In case of almost all GETHER/ETHERs, the Receive Frame State
 		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
@@ -1274,8 +1274,8 @@ static int sh_eth_rx(struct net_device *
 		 * bits are from bit 25 to bit 16. So, the driver needs right
 		 * shifting by 16.
 		 */
-		desc_status >>= 16;
-#endif
+		if (mdp->cd->shift_rd0)
+			desc_status >>= 16;
 
 		if (desc_status & (RD_RFS1 | RD_RFS2 | RD_RFS3 | RD_RFS4 |
 				   RD_RFS5 | RD_RFS6 | RD_RFS10)) {
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -476,6 +476,7 @@ struct sh_eth_cpu_data {
 	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
 	unsigned hw_crc:1;	/* E-DMAC have CSMR */
 	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
+	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
 };
 
 struct sh_eth_private {
