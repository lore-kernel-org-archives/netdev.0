From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [RFC/PATCH v3] sh_eth: use RNC mode for packet reception
Date: Tue,  3 Jun 2014 12:21:13 +0100
Message-ID: <1401794473-30050-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damm@opensource.se,
	horms@verge.net.au, yoshihiro.shimoda.uh@renesas.com,
	cm-hiep@jinso.co.jp
To: linux-kernel@codethink.co.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:42743 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751201AbaFCLYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 07:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current behaviour of the sh_eth driver is not to use the RNC bit
for the receive ring. This means that every packet recieved is not only
generating an IRQ but it also stops the receive ring DMA as well until
the driver re-enables it after unloading the packet.

This means that a number of the following errors are generated due to
the receive packet FIFO overflowing due to nowhere to put packets:

	net eth0: Receive FIFO Overflow

Since feedback from Yoshihiro Shimoda shows that every supported LSI
for this driver should have the bit enabled it seems the best way is
to remove the RMCR default value from the per-system data and just
write it when initialising the RMCR value. This is discussed in
the message (http://www.spinics.net/lists/netdev/msg284912.html).

I have tested the RMCR_RNC configuration with NFS root filesystem and
the driver has not failed yet.  There are further test reports from
Sergei Shtylov and others for both the R8A7790 and R8A7791.

There is also feedback fron Cao Minh Hiep[1] which reports the
same issue in (http://comments.gmane.org/gmane.linux.network/316285)
showing this fixes issues with losing UDP datagrams under iperf.

Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

---
Cc: nobuhiro.iwamatsu.yj@renesas.com
Cc: magnus.damm@opensource.se
Cc: horms@verge.net.au
Cc: yoshihiro.shimoda.uh@renesas.com
Cc: cm-hiep@jinso.co.jp

Changes since v1:
	- Fixed title and body to contain R8A7791
	- Updated list of CC:

Changes since v2:
	- Always write RMCR_RNC to RMCR
---
 drivers/net/ethernet/renesas/sh_eth.c | 11 ++---------
 drivers/net/ethernet/renesas/sh_eth.h |  2 --
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 6a9509c..e7d16ff 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -546,7 +546,6 @@ static struct sh_eth_cpu_data sh7757_data = {
 	.register_type	= SH_ETH_REG_FAST_SH4,
 
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
-	.rmcr_value	= RMCR_RNC,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
@@ -624,7 +623,6 @@ static struct sh_eth_cpu_data sh7757_data_giga = {
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 			  EESR_TDE | EESR_ECI,
 	.fdr_value	= 0x0000072f,
-	.rmcr_value	= RMCR_RNC,
 
 	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
@@ -752,7 +750,6 @@ static struct sh_eth_cpu_data r8a7740_data = {
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 			  EESR_TDE | EESR_ECI,
 	.fdr_value	= 0x0000070f,
-	.rmcr_value	= RMCR_RNC,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -784,7 +781,6 @@ static struct sh_eth_cpu_data r7s72100_data = {
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 			  EESR_TDE | EESR_ECI,
 	.fdr_value	= 0x0000070f,
-	.rmcr_value	= RMCR_RNC,
 
 	.no_psr		= 1,
 	.apr		= 1,
@@ -833,9 +829,6 @@ static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
 	if (!cd->fdr_value)
 		cd->fdr_value = DEFAULT_FDR_INIT;
 
-	if (!cd->rmcr_value)
-		cd->rmcr_value = DEFAULT_RMCR_VALUE;
-
 	if (!cd->tx_check)
 		cd->tx_check = DEFAULT_TX_CHECK;
 
@@ -1287,8 +1280,8 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	sh_eth_write(ndev, mdp->cd->fdr_value, FDR);
 	sh_eth_write(ndev, 0, TFTR);
 
-	/* Frame recv control */
-	sh_eth_write(ndev, mdp->cd->rmcr_value, RMCR);
+	/* Frame recv control (enable multiple-packets per rx irq) */
+	sh_eth_write(ndev, RMCR_RNC, RMCR);
 
 	sh_eth_write(ndev, DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2, TRSCER);
 
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index d55e37c..b37c427 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -319,7 +319,6 @@ enum TD_STS_BIT {
 enum RMCR_BIT {
 	RMCR_RNC = 0x00000001,
 };
-#define DEFAULT_RMCR_VALUE	0x00000000
 
 /* ECMR */
 enum FELIC_MODE_BIT {
@@ -466,7 +465,6 @@ struct sh_eth_cpu_data {
 	unsigned long fdr_value;
 	unsigned long fcftr_value;
 	unsigned long rpadir_value;
-	unsigned long rmcr_value;
 
 	/* interrupt checking mask */
 	unsigned long tx_check;
-- 
2.0.0.rc2
