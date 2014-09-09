From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v2 3/3] net: can: c_can: Add support for START pulse in RAMINIT sequence
Date: Tue, 9 Sep 2014 17:31:10 +0300
Message-ID: <1410273070-22485-4-git-send-email-rogerq@ti.com>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tony@atomide.com>, <tglx@linutronix.de>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<nm@ti.com>, <sergei.shtylyov@cogentembedded.com>,
	<linux-omap@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1410273070-22485-1-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some SoCs e.g. (TI DRA7xx) need a START pulse to start the
RAMINIT sequence i.e. START bit must be set and cleared before
checking for the DONE bit status. Add a new DT property "raminit-pulse"
to specify if this mechanism must be used for RAMINIT.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 Documentation/devicetree/bindings/net/can/c_can.txt | 3 +++
 drivers/net/can/c_can/c_can.h                       | 1 +
 drivers/net/can/c_can/c_can_platform.c              | 8 ++++++++
 3 files changed, 12 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index e12d1a1..705411f 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -19,6 +19,9 @@ Optional properties:
 			  register within the syscon region
 - ti,raminit-start-bit	: Bit posistion of START bit in the RAMINIT register
 - ti,raminit-done-bit	: Bit position of DONE bit in the RAMINIT register
+- ti,raminit-pulse	: Property must exist if START pulse is needed for RAMINIT
+			  sequence i.e. START bit will be set and cleared before
+			  checking for DONE bit.
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index bf68822..85b5ad0 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -175,6 +175,7 @@ struct c_can_raminit {
 	unsigned int reg;	/* register index within syscon */
 	u8 start_bit;	/* START bit position in raminit reg. */
 	u8 done_bit;	/* DONE bit position in raminit reg. */
+	bool needs_pulse;	/* If set, sets and clears START bit (pulse) */
 };
 
 /* c_can private data structure */
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index fb0c35b..5ae9eb3 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -120,6 +120,12 @@ static void c_can_hw_raminit_syscon(const struct c_can_priv *priv, bool enable)
 		ctrl |= 1 << raminit->start_bit;
 		regmap_write(raminit->syscon, raminit->reg, ctrl);
 
+		/* clear START bit if start pulse is needed */
+		if (raminit->needs_pulse) {
+			ctrl &= ~(1 << raminit->start_bit);
+			regmap_write(raminit->syscon, raminit->reg, ctrl);
+		}
+
 		ctrl |= 1 << raminit->done_bit;
 		c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
 	}
@@ -340,6 +346,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
 		}
 
 		priv->raminit_sys.done_bit = val;
+		priv->raminit_sys.needs_pulse = of_property_read_bool(np,
+								      "ti,raminit-pulse");
 		priv->raminit = c_can_hw_raminit_syscon;
 		break;
 	default:
-- 
1.8.3.2

