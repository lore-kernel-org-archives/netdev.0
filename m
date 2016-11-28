From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 2/6] net: ethernet: ti: cpts: add support for ext rftclk selection
Date: Mon, 28 Nov 2016 17:04:24 -0600
Message-ID: <20161128230428.6872-3-grygorii.strashko@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128230428.6872-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some CPTS instances, which can be found on KeyStone 2 1/10G Ethernet
Switch Subsystems, can control an external multiplexer that selects
one of up to 32 clocks for time sync reference (RFTCLK). This feature
can be configured through CPTS_RFTCLK_SEL register (offset: x08).

Hence, introduce optional DT cpts_rftclk_sel poperty wich, if present,
will specify CPTS reference clock. The cpts_rftclk_sel should be
omitted in DT if HW doesn't support this feature. The external fixed
rate clocks can be defined in board files as "fixed-clock".

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/keystone-netcp.txt |  2 ++
 drivers/net/ethernet/ti/cpts.c                           | 12 ++++++++++++
 drivers/net/ethernet/ti/cpts.h                           |  8 +++++++-
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index c37b54e..ec4a241 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -114,6 +114,8 @@ Optional properties:
 				driver to them if needed.
 
  Properties related to cpts configurations.
+	- cpts-rftclk-sel: selects one of up to 32 clocks for time sync
+		reference.  Default = 0.
 	- cpts_clock_mult/cpts_clock_shift:
 		used for converting time counter cycles to ns as in
 
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index c96a94a..9c5b835 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -459,6 +459,15 @@ static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 	    (!cpts->cc_mult && cpts->cc.shift))
 		goto of_error;
 
+	if (!of_property_read_u32(node, "cpts-rftclk-sel", &prop)) {
+		if (prop & ~CPTS_RFTCLK_SEL_MASK) {
+			dev_err(cpts->dev, "cpts: invalid cpts_rftclk_sel.\n");
+			goto of_error;
+		}
+		cpts->caps |= CPTS_CAP_RFTCLK_SEL;
+		cpts->rftclk_sel = prop & CPTS_RFTCLK_SEL_MASK;
+	}
+
 	return 0;
 
 of_error:
@@ -496,6 +505,9 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 
 	clk_prepare(cpts->refclk);
 
+	if (cpts->caps & CPTS_CAP_RFTCLK_SEL)
+		cpts_write32(cpts, cpts->rftclk_sel, rftclk_sel);
+
 	cpts->cc.read = cpts_systim_read;
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
 	cpts->info = cpts_info;
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index c96eca2..c934b61 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -35,7 +35,7 @@
 struct cpsw_cpts {
 	u32 idver;                /* Identification and version */
 	u32 control;              /* Time sync control */
-	u32 res1;
+	u32 rftclk_sel;		  /* Reference Clock Select Register */
 	u32 ts_push;              /* Time stamp event push */
 	u32 ts_load_val;          /* Time stamp load value */
 	u32 ts_load_en;           /* Time stamp load enable */
@@ -67,6 +67,8 @@ struct cpsw_cpts {
 #define INT_TEST             (1<<1)  /* Interrupt Test */
 #define CPTS_EN              (1<<0)  /* Time Sync Enable */
 
+#define CPTS_RFTCLK_SEL_MASK 0x1f
+
 /*
  * Definitions for the single bit resisters:
  * TS_PUSH TS_LOAD_EN  INTSTAT_RAW INTSTAT_MASKED INT_ENABLE EVENT_POP
@@ -107,6 +109,8 @@ struct cpts_event {
 	u32 low;
 };
 
+#define CPTS_CAP_RFTCLK_SEL BIT(0)
+
 struct cpts {
 	struct device *dev;
 	struct cpsw_cpts __iomem *reg;
@@ -125,6 +129,8 @@ struct cpts {
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
 	unsigned long ov_check_period;
+	u32 rftclk_sel;
+	u32 caps;
 };
 
 void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-- 
2.10.1
