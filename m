From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 13/21] wimax/i2400m: Allow bus-specific driver to specify retry count
Date: Thu, 11 Jun 2009 14:35:50 -0700
Message-ID: <ecddfd5ed73c070413f07a5251c16c10e69f35a2.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755576AbZFKVgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:39 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code that sets up the i2400m (firmware load and general driver
setup after it) includes a couple of retry loops.

The SDIO device sometimes can get in more complicated corners than the
USB one (due to its interaction with other SDIO functions), that
require trying a few more times.

To solve that, without having a failing USB device taking longer to be
considered dead, allow the retry counts to be specified by the
bus-specific driver, which the general driver takes as a parameter.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    2 +-
 drivers/net/wimax/i2400m/fw.c     |    2 +-
 drivers/net/wimax/i2400m/i2400m.h |   14 ++++++++++++++
 drivers/net/wimax/i2400m/sdio.c   |    3 +++
 drivers/net/wimax/i2400m/usb.c    |    1 +
 5 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index e8d022d..8d8628e 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -399,7 +399,7 @@ int __i2400m_dev_start(struct i2400m *i2400m, enum i2400m_bri flags)
 	struct wimax_dev *wimax_dev = &i2400m->wimax_dev;
 	struct net_device *net_dev = wimax_dev->net_dev;
 	struct device *dev = i2400m_dev(i2400m);
-	int times = 3;
+	int times = i2400m->bus_bm_retries;
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 retry:
diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 01c926e..c48fa24 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -980,7 +980,7 @@ int i2400m_fw_dnload(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf,
 {
 	int ret = 0;
 	struct device *dev = i2400m_dev(i2400m);
-	int count = I2400M_BOOT_RETRIES;
+	int count = i2400m->bus_bm_retries;
 
 	d_fnstart(5, dev, "(i2400m %p bcf %p size %zu)\n",
 		  i2400m, bcf, bcf_size);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 8dba246..59cd783 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -150,6 +150,7 @@
 enum {
 	/* Firmware uploading */
 	I2400M_BOOT_RETRIES = 3,
+	I3200_BOOT_RETRIES = 3,
 	/* Size of the Boot Mode Command buffer */
 	I2400M_BM_CMD_BUF_SIZE = 16 * 1024,
 	I2400M_BM_ACK_BUF_SIZE = 256,
@@ -224,6 +225,17 @@ struct i2400m_roq;
  *     process, so it cannot rely on common infrastructure being laid
  *     out.
  *
+ * @bus_bm_retries: [fill] How many times shall a firmware upload /
+ *     device initialization be retried? Different models of the same
+ *     device might need different values, hence it is set by the
+ *     bus-specific driver. Note this value is used in two places,
+ *     i2400m_fw_dnload() and __i2400m_dev_start(); they won't become
+ *     multiplicative (__i2400m_dev_start() calling N times
+ *     i2400m_fw_dnload() and this trying N times to download the
+ *     firmware), as if __i2400m_dev_start() only retries if the
+ *     firmware crashed while initializing the device (not in a
+ *     general case).
+ *
  * @bus_bm_cmd_send: [fill] Function called to send a boot-mode
  *     command. Flags are defined in 'enum i2400m_bm_cmd_flags'. This
  *     is synchronous and has to return 0 if ok or < 0 errno code in
@@ -399,6 +411,8 @@ struct i2400m {
 
 	size_t bus_tx_block_size;
 	size_t bus_pl_size_max;
+	unsigned bus_bm_retries;
+
 	int (*bus_dev_start)(struct i2400m *);
 	void (*bus_dev_stop)(struct i2400m *);
 	void (*bus_tx_kick)(struct i2400m *);
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index d6fac5c..afde897 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -418,6 +418,9 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_dev_stop = i2400ms_bus_dev_stop;
 	i2400m->bus_tx_kick = i2400ms_bus_tx_kick;
 	i2400m->bus_reset = i2400ms_bus_reset;
+	/* The iwmc3200-wimax sometimes requires the driver to try
+	 * hard when we paint it into a corner. */
+	i2400m->bus_bm_retries = I3200_BOOT_RETRIES;
 	i2400m->bus_bm_cmd_send = i2400ms_bus_bm_cmd_send;
 	i2400m->bus_bm_wait_for_ack = i2400ms_bus_bm_wait_for_ack;
 	i2400m->bus_fw_names = i2400ms_bus_fw_names;
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 1785132..ebc05da 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -399,6 +399,7 @@ int i2400mu_probe(struct usb_interface *iface,
 	i2400m->bus_dev_stop = i2400mu_bus_dev_stop;
 	i2400m->bus_tx_kick = i2400mu_bus_tx_kick;
 	i2400m->bus_reset = i2400mu_bus_reset;
+	i2400m->bus_bm_retries = I2400M_BOOT_RETRIES;
 	i2400m->bus_bm_cmd_send = i2400mu_bus_bm_cmd_send;
 	i2400m->bus_bm_wait_for_ack = i2400mu_bus_bm_wait_for_ack;
 	i2400m->bus_fw_names = i2400mu_bus_fw_names;
-- 
1.6.2.3

