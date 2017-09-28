From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 9/9] net: dsa: mv88e6xxx: add workaround for 6341 timestamping
Date: Thu, 28 Sep 2017 10:25:41 -0500
Message-ID: <1506612341-18061-10-git-send-email-brandon.streiff@ni.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "Vivien Didelot" <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

88E6341 devices default to timestamping at the PHY, but due to a
hardware issue, timestamps via this component are unreliable. For
this family, configure the PTP hardware to force the timestamping
to occur at the MAC.

Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
---
 drivers/net/dsa/mv88e6xxx/hwtstamp.c | 13 +++++++++++++
 drivers/net/dsa/mv88e6xxx/hwtstamp.h |  9 +++++++++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/hwtstamp.c b/drivers/net/dsa/mv88e6xxx/hwtstamp.c
index 825d6f0..b6aee88 100644
--- a/drivers/net/dsa/mv88e6xxx/hwtstamp.c
+++ b/drivers/net/dsa/mv88e6xxx/hwtstamp.c
@@ -523,6 +523,19 @@ int mv88e6xxx_hwtstamp_setup(struct mv88e6xxx_chip *chip)
 			return err;
 	}
 
+	/* 88E6341 devices default to timestamping at the PHY, but this has
+	 * a hardware issue that results in unreliable timestamps. Force
+	 * these devices to timestamp at the MAC.
+	 */
+	if (chip->info->family == MV88E6XXX_FAMILY_6341) {
+		u16 val = MV88E6341_PTP_CFG_UPDATE |
+			  MV88E6341_PTP_CFG_MODE_IDX |
+			  MV88E6341_PTP_CFG_MODE_TS_AT_MAC;
+		err = mv88e6xxx_ptp_write(chip, MV88E6341_PTP_CFG, val);
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx/hwtstamp.h b/drivers/net/dsa/mv88e6xxx/hwtstamp.h
index 1d24220..550711a 100644
--- a/drivers/net/dsa/mv88e6xxx/hwtstamp.h
+++ b/drivers/net/dsa/mv88e6xxx/hwtstamp.h
@@ -34,6 +34,15 @@
 /* Offset 0x02: Timestamp Arrival Capture Pointers */
 #define MV88E6XXX_PTP_TS_ARRIVAL_PTR	0x02
 
+/* Offset 0x07: PTP Global Configuration */
+#define MV88E6341_PTP_CFG			0x07
+#define MV88E6341_PTP_CFG_UPDATE		0x8000
+#define MV88E6341_PTP_CFG_IDX_MASK		0x7f00
+#define MV88E6341_PTP_CFG_DATA_MASK		0x00ff
+#define MV88E6341_PTP_CFG_MODE_IDX		0x0
+#define MV88E6341_PTP_CFG_MODE_TS_AT_PHY	0x00
+#define MV88E6341_PTP_CFG_MODE_TS_AT_MAC	0x80
+
 /* Offset 0x08: PTP Interrupt Status */
 #define MV88E6XXX_PTP_IRQ_STATUS	0x08
 
-- 
2.1.4
