From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 5/5] sh_eth: Mitigate lost statistics updates
Date: Thu, 26 Feb 2015 20:35:05 +0000
Message-ID: <1424982905.4444.76.camel@xylophone.i.decadent.org.uk>
References: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:46891 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbbBZUfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:35:10 -0500
In-Reply-To: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistics registers have write-clear behaviour, which means we
will lose any increment between the read and write.  Mitigate this by
only clearing when we read a non-zero value, so we will never falsely
report a total of zero.  This also saves time as we only handle
error statistics here and they won't often be incremented.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |   37 ++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 38b9d87b2667..c3bc01ccad3e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2414,6 +2414,22 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return NETDEV_TX_OK;
 }
 
+/* The statistics registers have write-clear behaviour, which means we
+ * will lose any increment between the read and write.  We mitigate
+ * this by only clearing when we read a non-zero value, so we will
+ * never falsely report a total of zero.
+ */
+static void
+sh_eth_update_stat(struct net_device *ndev, unsigned long *stat, int reg)
+{
+	u32 delta = sh_eth_read(ndev, reg);
+
+	if (delta) {
+		*stat += delta;
+		sh_eth_write(ndev, 0, reg);
+	}
+}
+
 static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -2424,21 +2440,18 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 	if (!mdp->is_opened)
 		return &ndev->stats;
 
-	ndev->stats.tx_dropped += sh_eth_read(ndev, TROCR);
-	sh_eth_write(ndev, 0, TROCR);	/* (write clear) */
-	ndev->stats.collisions += sh_eth_read(ndev, CDCR);
-	sh_eth_write(ndev, 0, CDCR);	/* (write clear) */
-	ndev->stats.tx_carrier_errors += sh_eth_read(ndev, LCCR);
-	sh_eth_write(ndev, 0, LCCR);	/* (write clear) */
+	sh_eth_update_stat(ndev, &ndev->stats.tx_dropped, TROCR);
+	sh_eth_update_stat(ndev, &ndev->stats.collisions, CDCR);
+	sh_eth_update_stat(ndev, &ndev->stats.tx_carrier_errors, LCCR);
 
 	if (sh_eth_is_gether(mdp)) {
-		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);
-		sh_eth_write(ndev, 0, CERCR);	/* (write clear) */
-		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);
-		sh_eth_write(ndev, 0, CEECR);	/* (write clear) */
+		sh_eth_update_stat(ndev, &ndev->stats.tx_carrier_errors,
+				   CERCR);
+		sh_eth_update_stat(ndev, &ndev->stats.tx_carrier_errors,
+				   CEECR);
 	} else {
-		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
-		sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
+		sh_eth_update_stat(ndev, &ndev->stats.tx_carrier_errors,
+				   CNDCR);
 	}
 
 	return &ndev->stats;
-- 
1.7.10.4
