From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 1/3] 8139: safer spin loop for get_statistics
Date: Wed, 16 Mar 2005 15:04:29 -0800
Message-ID: <20050316150429.375845f1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The spin loop in 8139cp is limited to 100 iterations when pulling hardware
stats. There is no allowance for processor speed so on a fast machine, the
stats may not be available that fast. Also, if the board doesn't return
soon enough make sure turn the address back off to prevent later updates
when memory has gone away.

This has not been tested on real 8139 hardware, but is based on the code
for 8169, so could someone who has this hardware please check it.

 
diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	2005-03-16 14:54:48 -08:00
+++ b/drivers/net/8139cp.c	2005-03-16 14:54:48 -08:00
@@ -1486,22 +1486,22 @@
 				  struct ethtool_stats *estats, u64 *tmp_stats)
 {
 	struct cp_private *cp = netdev_priv(dev);
-	unsigned int work = 100;
 	int i;
 
+	memset(cp->nic_stats, 0, sizeof(struct cp_dma_stats));
+
 	/* begin NIC statistics dump */
 	cpw32(StatsAddr + 4, (cp->nic_stats_dma >> 16) >> 16);
 	cpw32(StatsAddr, (cp->nic_stats_dma & 0xffffffff) | DumpStats);
 	cpr32(StatsAddr);
 
-	while (work-- > 0) {
+	for (i = 0; i < 1000; i++) {
 		if ((cpr32(StatsAddr) & DumpStats) == 0)
 			break;
-		cpu_relax();
+		udelay(10);
 	}
-
-	if (cpr32(StatsAddr) & DumpStats)
-		return /* -EIO */;
+	cpw32(StatsAddr, 0);
+	cpw32(StatsAddr + 4, 0);
 
 	i = 0;
 	tmp_stats[i++] = le64_to_cpu(cp->nic_stats->tx_ok);
