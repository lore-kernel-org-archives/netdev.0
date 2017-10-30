From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 3/6] net: mvpp2: initialize the RSS tables
Date: Mon, 30 Oct 2017 11:23:30 +0100
Message-ID: <20171030102333.30781-4-antoine.tenart@free-electrons.com>
References: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch initialize the RSS tables to evenly (depending on the packets
RSS hashes) distribute the packets across port Rx queues. This helps to
handle packets on different CPUs to improve performances, as more queues
will be used in parallel.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 50 ++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index f15e5ffde9cb..1f7d4ea60da0 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -83,6 +83,16 @@
 #define MVPP2_PRS_TCAM_CTRL_REG			0x1230
 #define     MVPP2_PRS_TCAM_EN_MASK		BIT(0)
 
+/* RSS Registers */
+#define MVPP22_RSS_INDEX			0x1500
+#define     MVPP22_RSS_INDEX_TABLE_ENTRY(idx)	((idx) << 8)
+#define     MVPP22_RSS_INDEX_TABLE(idx)		((idx) << 8)
+#define     MVPP22_RSS_INDEX_QUEUE(idx)		((idx) << 16)
+#define MVPP22_RSS_TABLE_ENTRY			0x1508
+#define MVPP22_RSS_TABLE			0x1510
+#define     MVPP22_RSS_TABLE_POINTER(p)		(p)
+#define MVPP22_RSS_WIDTH			0x150c
+
 /* Classifier Registers */
 #define MVPP2_CLS_MODE_REG			0x1800
 #define     MVPP2_CLS_MODE_ACTIVE_MASK		BIT(0)
@@ -746,6 +756,10 @@ enum mvpp2_prs_l3_cast {
 #define MVPP2_CLS_FLOWS_TBL_SIZE	512
 #define MVPP2_CLS_FLOWS_TBL_DATA_WORDS	3
 #define MVPP2_CLS_LKP_TBL_SIZE		64
+#define MVPP2_CLS_RX_QUEUES		256
+
+/* RSS constants */
+#define MVPP22_RSS_TABLE_ENTRIES	32
 
 /* BM constants */
 #define MVPP2_BM_POOLS_NUM		8
@@ -6788,6 +6802,39 @@ static void mvpp2_irqs_deinit(struct mvpp2_port *port)
 	}
 }
 
+static void mvpp22_init_rss(struct mvpp2_port *port)
+{
+	struct mvpp2 *priv = port->priv;
+	int i;
+
+	/* Set the table width: replace the whole classifier Rx queue number
+	 * with the ones configured in RSS table entries.
+	 */
+	mvpp2_write(priv, MVPP22_RSS_INDEX, MVPP22_RSS_INDEX_TABLE(0));
+	mvpp2_write(priv, MVPP22_RSS_WIDTH, 8);
+
+	/* Loop through the classifier Rx Queues and map them to a RSS table.
+	 * Map them all to the first table (0) by default.
+	 */
+	for (i = 0; i < MVPP2_CLS_RX_QUEUES; i++) {
+		mvpp2_write(priv, MVPP22_RSS_INDEX, MVPP22_RSS_INDEX_QUEUE(i));
+		mvpp2_write(priv, MVPP22_RSS_TABLE,
+			    MVPP22_RSS_TABLE_POINTER(0));
+	}
+
+	/* Configure the first table to evenly distribute the packets across
+	 * real Rx Queues. The table entries map a hash to an port Rx Queue.
+	 */
+	for (i = 0; i < MVPP22_RSS_TABLE_ENTRIES; i++) {
+		u32 sel = MVPP22_RSS_INDEX_TABLE(0) |
+			  MVPP22_RSS_INDEX_TABLE_ENTRY(i);
+		mvpp2_write(priv, MVPP22_RSS_INDEX, sel);
+
+		mvpp2_write(priv, MVPP22_RSS_TABLE_ENTRY, i % port->nrxqs);
+	}
+
+}
+
 static int mvpp2_open(struct net_device *dev)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
@@ -6862,6 +6909,9 @@ static int mvpp2_open(struct net_device *dev)
 
 	mvpp2_start_dev(port);
 
+	if (priv->hw_version == MVPP22)
+		mvpp22_init_rss(port);
+
 	return 0;
 
 err_free_link_irq:
-- 
2.14.3
