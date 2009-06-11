From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 14/21] wimax/i2400m: move boot time poke table out of common driver
Date: Thu, 11 Jun 2009 14:35:51 -0700
Message-ID: <7308a0c23901f2a295265bb71d8521ef7d47bf4c.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756544AbZFKVgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:51 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

This change moves the table of "pokes" performed on the device at boot
time to the bus specific portion of the driver.

Different models of the i2400m device supported by this driver require
different poke tables, thus having a single table that works for all
is impossible. For that, the table is moved to the bus-specific
driver, who can decide which table to use based on the specifics of
the device and point the generic driver to it.

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
---
 drivers/net/wimax/i2400m/fw.c     |   45 ++++++++++--------------------------
 drivers/net/wimax/i2400m/i2400m.h |   28 +++++++++++++++++++++++
 2 files changed, 41 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index c48fa24..349344a 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -770,40 +770,21 @@ error_read_mac:
 static
 int i2400m_dnload_init_nonsigned(struct i2400m *i2400m)
 {
-#define POKE(a, d) {					\
-	.address = cpu_to_le32(a),		\
-	.data = cpu_to_le32(d)		\
-}
-	static const struct {
-		__le32 address;
-		__le32 data;
-	} i2400m_pokes[] = {
-		POKE(0x081A58, 0xA7810230),
-		POKE(0x080040, 0x00000000),
-		POKE(0x080048, 0x00000082),
-		POKE(0x08004C, 0x0000081F),
-		POKE(0x080054, 0x00000085),
-		POKE(0x080058, 0x00000180),
-		POKE(0x08005C, 0x00000018),
-		POKE(0x080060, 0x00000010),
-		POKE(0x080574, 0x00000001),
-		POKE(0x080550, 0x00000005),
-		POKE(0xAE0000, 0x00000000),
-	};
-#undef POKE
-	unsigned i;
-	int ret;
+	unsigned i = 0;
+	int ret = 0;
 	struct device *dev = i2400m_dev(i2400m);
-
-	dev_warn(dev, "WARNING!!! non-signed boot UNTESTED PATH!\n");
-
 	d_fnstart(5, dev, "(i2400m %p)\n", i2400m);
-	for (i = 0; i < ARRAY_SIZE(i2400m_pokes); i++) {
-		ret = i2400m_download_chunk(i2400m, &i2400m_pokes[i].data,
-					    sizeof(i2400m_pokes[i].data),
-					    i2400m_pokes[i].address, 1, 1);
-		if (ret < 0)
-			break;
+	if (i2400m->bus_bm_pokes_table) {
+		while (i2400m->bus_bm_pokes_table[i].address) {
+			ret = i2400m_download_chunk(
+				i2400m,
+				&i2400m->bus_bm_pokes_table[i].data,
+				sizeof(i2400m->bus_bm_pokes_table[i].data),
+				i2400m->bus_bm_pokes_table[i].address, 1, 1);
+			if (ret < 0)
+				break;
+			i++;
+		}
 	}
 	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
 	return ret;
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 59cd783..1fe5da4 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -156,6 +156,27 @@ enum {
 	I2400M_BM_ACK_BUF_SIZE = 256,
 };
 
+/**
+ * struct i2400m_poke_table - Hardware poke table for the Intel 2400m
+ *
+ * This structure will be used to create a device specific poke table
+ * to put the device in a consistant state at boot time.
+ *
+ * @address: The device address to poke
+ *
+ * @data: The data value to poke to the device address
+ *
+ */
+struct i2400m_poke_table{
+	__le32 address;
+	__le32 data;
+};
+
+#define I2400M_FW_POKE(a, d) {		\
+	.address = cpu_to_le32(a),	\
+	.data = cpu_to_le32(d)		\
+}
+
 
 /**
  * i2400m_reset_type - methods to reset a device
@@ -264,6 +285,12 @@ struct i2400m_roq;
  *     address provided in boot mode is kind of broken and needs to
  *     be re-read later on.
  *
+ * @bus_bm_pokes_table: [fill/optional] A table of device addresses
+ *     and values that will be poked at device init time to move the
+ *     device to the correct state for the type of boot/firmware being
+ *     used.  This table MUST be terminated with (0x000000,
+ *     0x00000000) or bad things will happen.
+ *
  *
  * @wimax_dev: WiMAX generic device for linkage into the kernel WiMAX
  *     stack. Due to the way a net_device is allocated, we need to
@@ -424,6 +451,7 @@ struct i2400m {
 				       struct i2400m_bootrom_header *, size_t);
 	const char **bus_fw_names;
 	unsigned bus_bm_mac_addr_impaired:1;
+	const struct i2400m_poke_table *bus_bm_pokes_table;
 
 	spinlock_t tx_lock;		/* protect TX state */
 	void *tx_buf;
-- 
1.6.2.3

