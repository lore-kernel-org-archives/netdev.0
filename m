From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCHv2 net-next 07/16] net: mvpp2: adapt the mvpp2_rxq_*_pool_set functions to PPv2.2
Date: Wed, 28 Dec 2016 17:46:23 +0100
Message-ID: <1482943592-12556-8-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Hanna Hawa <hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Yehuda Yitschak <yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482943592-12556-1-git-send-email-thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The MVPP2_RXQ_CONFIG_REG register has a slightly different layout
between PPv2.1 and PPv2.2, so this commit adapts the functions modifying
this register to accommodate for both the PPv2.1 and PPv2.2 cases.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
 drivers/net/ethernet/marvell/mvpp2.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 160b787..8fc818d 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -50,9 +50,11 @@
 #define     MVPP2_SNOOP_PKT_SIZE_MASK		0x1ff
 #define     MVPP2_SNOOP_BUF_HDR_MASK		BIT(9)
 #define     MVPP2_RXQ_POOL_SHORT_OFFS		20
-#define     MVPP2_RXQ_POOL_SHORT_MASK		0x700000
+#define     MVPP21_RXQ_POOL_SHORT_MASK		0x700000
+#define     MVPP22_RXQ_POOL_SHORT_MASK		0xf00000
 #define     MVPP2_RXQ_POOL_LONG_OFFS		24
-#define     MVPP2_RXQ_POOL_LONG_MASK		0x7000000
+#define     MVPP21_RXQ_POOL_LONG_MASK		0x7000000
+#define     MVPP22_RXQ_POOL_LONG_MASK		0xf000000
 #define     MVPP2_RXQ_PACKET_OFFSET_OFFS	28
 #define     MVPP2_RXQ_PACKET_OFFSET_MASK	0x70000000
 #define     MVPP2_RXQ_DISABLE_MASK		BIT(31)
@@ -3762,17 +3764,20 @@ static int mvpp2_bm_init(struct platform_device *pdev, struct mvpp2 *priv)
 static void mvpp2_rxq_long_pool_set(struct mvpp2_port *port,
 				    int lrxq, int long_pool)
 {
-	u32 val;
+	u32 val, mask;
 	int prxq;
 
 	/* Get queue physical ID */
 	prxq = port->rxqs[lrxq]->id;
 
-	val = mvpp2_read(port->priv, MVPP2_RXQ_CONFIG_REG(prxq));
-	val &= ~MVPP2_RXQ_POOL_LONG_MASK;
-	val |= ((long_pool << MVPP2_RXQ_POOL_LONG_OFFS) &
-		    MVPP2_RXQ_POOL_LONG_MASK);
+	if (port->priv->hw_version == MVPP21)
+		mask = MVPP21_RXQ_POOL_LONG_MASK;
+	else
+		mask = MVPP22_RXQ_POOL_LONG_MASK;
 
+	val = mvpp2_read(port->priv, MVPP2_RXQ_CONFIG_REG(prxq));
+	val &= ~mask;
+	val |= (long_pool << MVPP2_RXQ_POOL_LONG_OFFS) & mask;
 	mvpp2_write(port->priv, MVPP2_RXQ_CONFIG_REG(prxq), val);
 }
 
@@ -3780,17 +3785,20 @@ static void mvpp2_rxq_long_pool_set(struct mvpp2_port *port,
 static void mvpp2_rxq_short_pool_set(struct mvpp2_port *port,
 				     int lrxq, int short_pool)
 {
-	u32 val;
+	u32 val, mask;
 	int prxq;
 
 	/* Get queue physical ID */
 	prxq = port->rxqs[lrxq]->id;
 
-	val = mvpp2_read(port->priv, MVPP2_RXQ_CONFIG_REG(prxq));
-	val &= ~MVPP2_RXQ_POOL_SHORT_MASK;
-	val |= ((short_pool << MVPP2_RXQ_POOL_SHORT_OFFS) &
-		    MVPP2_RXQ_POOL_SHORT_MASK);
+	if (port->priv->hw_version == MVPP21)
+		mask = MVPP21_RXQ_POOL_SHORT_MASK;
+	else
+		mask = MVPP22_RXQ_POOL_SHORT_MASK;
 
+	val = mvpp2_read(port->priv, MVPP2_RXQ_CONFIG_REG(prxq));
+	val &= ~mask;
+	val |= (short_pool << MVPP2_RXQ_POOL_SHORT_OFFS) & mask;
 	mvpp2_write(port->priv, MVPP2_RXQ_CONFIG_REG(prxq), val);
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
