From: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v5] wlcore: spi: add wl18xx support
Date: Sun, 17 Jul 2016 06:36:11 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B3615D8AA@DFRE01.ent.ti.com>
References: <8665E2433BC68541A24DFFCA87B70F5B36156367@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B36156367-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for using with both wl12xx and wl18xx.

- all wilink family needs special init command for entering wspi mode.
  extra clock cycles should be sent after the spi init command while the
  cs pin is high.
- Use inverted chip select for sending a dummy 4 bytes command that
  completes the init stage.

Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
v1->v2:update device tree bindings configuration
v2->v3:revert from manual gpio manipulation. use inverted chip select 
instead for sending the extra init cycle which, achieves the same hardware 
purpose.
update device tree bindings docucmentation accordingly
v3->v4: Remove redundant data form binding documentation and fix chip 
select number mismatch in wl1271 example
v4->v5: Rebase on top of head of wireless-drivers-next

 .../bindings/net/wireless/ti,wlcore,spi.txt        |  41 +++++--
 drivers/net/wireless/ti/wlcore/spi.c               | 123 ++++++++++++++++++---
 2 files changed, 137 insertions(+), 27 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt b/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt
index 9180724..8f9ced0 100644
--- a/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt
+++ b/Documentation/devicetree/bindings/net/wireless/ti,wlcore,spi.txt
@@ -1,19 +1,30 @@
-* Texas Instruments wl1271 wireless lan controller
+* Texas Instruments wl12xx/wl18xx wireless lan controller

-The wl1271 chip can be connected via SPI or via SDIO. This
+The wl12xx/wl18xx chips can be connected via SPI or via SDIO. This
 document describes the binding for the SPI connected chip.

 Required properties:
-- compatible :          Should be "ti,wl1271"
+- compatible :          Should be one of the following:
+    * "ti,wl1271"
+    * "ti,wl1273"
+    * "ti,wl1281"
+    * "ti,wl1283"
+    * "ti,wl1801"
+    * "ti,wl1805"
+    * "ti,wl1807"
+    * "ti,wl1831"
+    * "ti,wl1835"
+    * "ti,wl1837"
 - reg :                 Chip select address of device
 - spi-max-frequency :   Maximum SPI clocking speed of device in Hz
-- ref-clock-frequency : Reference clock frequency
 - interrupt-parent, interrupts :
                         Should contain parameters for 1 interrupt line.
                         Interrupt parameters: parent, line number, type.
-- vwlan-supply :        Point the node of the regulator that powers/enable the wl1271 chip
+- vwlan-supply :        Point the node of the regulator that powers/enable the
+                        wl12xx/wl18xx chip

 Optional properties:
+- ref-clock-frequency : Reference clock frequency (should be set for 
+wl12xx)
 - clock-xtal :          boolean, clock is generated from XTAL

 - Please consult Documentation/devicetree/bindings/spi/spi-bus.txt
@@ -21,16 +32,28 @@ Optional properties:

 Examples:

+For wl12xx family:
 &spi1 {
-       wl1271@1 {
+       wlcore: wlcore@1 {
                compatible = "ti,wl1271";
-
                reg = <1>;
                spi-max-frequency = <48000000>;
-               clock-xtal;
-               ref-clock-frequency = <38400000>;
                interrupt-parent = <&gpio3>;
                interrupts = <8 IRQ_TYPE_LEVEL_HIGH>;
                vwlan-supply = <&vwlan_fixed>;
+               clock-xtal;
+               ref-clock-frequency = <38400000>;
+       };
+};
+
+For wl18xx family:
+&spi0 {
+       wlcore: wlcore@0 {
+               compatible = "ti,wl1835";
+               reg = <0>;
+               spi-max-frequency = <48000000>;
+               interrupt-parent = <&gpio0>;
+               interrupts = <27 IRQ_TYPE_EDGE_RISING>;
+               vwlan-supply = <&vwlan_fixed>;
        };
 };
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index cea9443..73fbcf1 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -70,16 +70,30 @@
 #define WSPI_MAX_CHUNK_SIZE    4092

 /*
- * only support SPI for 12xx - this code should be reworked when 18xx
- * support is introduced
+ * wl18xx driver aggregation buffer size is (13 * PAGE_SIZE) compared 
+ to
+ * (4 * PAGE_SIZE) for wl12xx, so use the larger buffer needed for 
+ wl18xx
  */
-#define SPI_AGGR_BUFFER_SIZE (4 * PAGE_SIZE)
+#define SPI_AGGR_BUFFER_SIZE (13 * PAGE_SIZE)

 /* Maximum number of SPI write chunks */  #define WSPI_MAX_NUM_OF_CHUNKS \
        ((SPI_AGGR_BUFFER_SIZE / WSPI_MAX_CHUNK_SIZE) + 1)


+struct wilink_familiy_data {
+       char name[8];
+};
+
+const struct wilink_familiy_data *wilink_data;
+
+static const struct wilink_familiy_data wl18xx_data = {
+       .name = "wl18xx",
+};
+
+static const struct wilink_familiy_data wl12xx_data = {
+       .name = "wl12xx",
+};
+
 struct wl12xx_spi_glue {
        struct device *dev;
        struct platform_device *core;
@@ -119,6 +133,7 @@ static void wl12xx_spi_init(struct device *child)
        struct wl12xx_spi_glue *glue = dev_get_drvdata(child->parent);
        struct spi_transfer t;
        struct spi_message m;
+       struct spi_device *spi = to_spi_device(glue->dev);
        u8 *cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);

        if (!cmd) {
@@ -151,6 +166,7 @@ static void wl12xx_spi_init(struct device *child)
                cmd[6] |= WSPI_INIT_CMD_EN_FIXEDBUSY;

        cmd[7] = crc7_be(0, cmd+2, WSPI_INIT_CMD_CRC_LEN) | WSPI_INIT_CMD_END;
+
        /*
         * The above is the logical order; it must actually be stored
         * in the buffer byte-swapped.
@@ -163,6 +179,28 @@ static void wl12xx_spi_init(struct device *child)
        spi_message_add_tail(&t, &m);

        spi_sync(to_spi_device(glue->dev), &m);
+
+       /* Send extra clocks with inverted CS (high). this is required
+        * by the wilink family in order to successfully enter WSPI mode.
+        */
+       spi->mode ^= SPI_CS_HIGH;
+       memset(&m, 0, sizeof(m));
+       spi_message_init(&m);
+
+       cmd[0] = 0xff;
+       cmd[1] = 0xff;
+       cmd[2] = 0xff;
+       cmd[3] = 0xff;
+       __swab32s((u32 *)cmd);
+
+       t.tx_buf = cmd;
+       t.len = 4;
+       spi_message_add_tail(&t, &m);
+
+       spi_sync(to_spi_device(glue->dev), &m);
+
+       /* Restore chip select configration to normal */
+       spi->mode ^= SPI_CS_HIGH;
        kfree(cmd);
 }

@@ -270,22 +308,25 @@ static int __must_check wl12xx_spi_raw_read(struct device *child, int addr,
        return 0;
 }

-static int __must_check wl12xx_spi_raw_write(struct device *child, int addr,
-                                            void *buf, size_t len, bool fixed)
+static int __wl12xx_spi_raw_write(struct device *child, int addr,
+                                 void *buf, size_t len, bool fixed)
 {
        struct wl12xx_spi_glue *glue = dev_get_drvdata(child->parent);
-       /* SPI write buffers - 2 for each chunk */
-       struct spi_transfer t[2 * WSPI_MAX_NUM_OF_CHUNKS];
+       struct spi_transfer *t;
        struct spi_message m;
        u32 commands[WSPI_MAX_NUM_OF_CHUNKS]; /* 1 command per chunk */
        u32 *cmd;
        u32 chunk_len;
        int i;

+       /* SPI write buffers - 2 for each chunk */
+       t = kzalloc(sizeof(*t) * 2 * WSPI_MAX_NUM_OF_CHUNKS, GFP_KERNEL);
+       if (!t)
+               return -ENOMEM;
+
        WARN_ON(len > SPI_AGGR_BUFFER_SIZE);

        spi_message_init(&m);
-       memset(t, 0, sizeof(t));

        cmd = &commands[0];
        i = 0;
@@ -318,9 +359,26 @@ static int __must_check wl12xx_spi_raw_write(struct device *child, int addr,

        spi_sync(to_spi_device(glue->dev), &m);

+       kfree(t);
        return 0;
 }

+static int __must_check wl12xx_spi_raw_write(struct device *child, int addr,
+                                            void *buf, size_t len, bool 
+fixed) {
+       int ret;
+
+       /* The ELP wakeup write may fail the first time due to internal
+        * hardware latency. It is safer to send the wakeup command twice to
+        * avoid unexpected failures.
+        */
+       if (addr == HW_ACCESS_ELP_CTRL_REG)
+               ret = __wl12xx_spi_raw_write(child, addr, buf, len, fixed);
+       ret = __wl12xx_spi_raw_write(child, addr, buf, len, fixed);
+
+       return ret;
+}
+
 /**
  * wl12xx_spi_set_power - power on/off the wl12xx unit
  * @child: wl12xx device handle.
@@ -349,17 +407,38 @@ static int wl12xx_spi_set_power(struct device *child, bool enable)
        return ret;
 }

+/**
+ * wl12xx_spi_set_block_size
+ *
+ * This function is not needed for spi mode, but need to be present.
+ * Without it defined the wlcore fallback to use the wrong packet
+ * allignment on tx.
+ */
+static void wl12xx_spi_set_block_size(struct device *child,
+                                     unsigned int blksz) { }
+
 static struct wl1271_if_operations spi_ops = {
        .read           = wl12xx_spi_raw_read,
        .write          = wl12xx_spi_raw_write,
        .reset          = wl12xx_spi_reset,
        .init           = wl12xx_spi_init,
        .power          = wl12xx_spi_set_power,
-       .set_block_size = NULL,
+       .set_block_size = wl12xx_spi_set_block_size,
 };

 static const struct of_device_id wlcore_spi_of_match_table[] = {
-       { .compatible = "ti,wl1271" },
+       { .compatible = "ti,wl1271", .data = &wl12xx_data},
+       { .compatible = "ti,wl1273", .data = &wl12xx_data},
+       { .compatible = "ti,wl1281", .data = &wl12xx_data},
+       { .compatible = "ti,wl1283", .data = &wl12xx_data},
+       { .compatible = "ti,wl1801", .data = &wl18xx_data},
+       { .compatible = "ti,wl1805", .data = &wl18xx_data},
+       { .compatible = "ti,wl1807", .data = &wl18xx_data},
+       { .compatible = "ti,wl1831", .data = &wl18xx_data},
+       { .compatible = "ti,wl1835", .data = &wl18xx_data},
+       { .compatible = "ti,wl1837", .data = &wl18xx_data},
        { }
 };
 MODULE_DEVICE_TABLE(of, wlcore_spi_of_match_table); @@ -376,17 +455,24 @@ static int wlcore_probe_of(struct spi_device *spi, struct wl12xx_spi_glue *glue,  {
        struct device_node *dt_node = spi->dev.of_node;
        int ret;
+       const struct of_device_id *of_id;
+
+       of_id = of_match_node(wlcore_spi_of_match_table, dt_node);
+       if (!of_id)
+               return -ENODEV;
+
+       wilink_data = of_id->data;
+       dev_info(&spi->dev, "selected chip familiy is %s\n",
+                wilink_data->name);

        if (of_find_property(dt_node, "clock-xtal", NULL))
                pdev_data->ref_clock_xtal = true;

-       ret = of_property_read_u32(dt_node, "ref-clock-frequency",
-                                  &pdev_data->ref_clock_freq);
-       if (ret) {
-               dev_err(glue->dev,
-                       "can't get reference clock frequency (%d)\n", ret);
-               return ret;
-       }
+       /* optional clock frequency params */
+       of_property_read_u32(dt_node, "ref-clock-frequency",
+                            &pdev_data->ref_clock_freq);
+       of_property_read_u32(dt_node, "tcxo-clock-frequency",
+                            &pdev_data->tcxo_clock_freq);

        return 0;
 }
@@ -437,7 +523,8 @@ static int wl1271_probe(struct spi_device *spi)
                return ret;
        }

-       glue->core = platform_device_alloc("wl12xx", PLATFORM_DEVID_AUTO);
+       glue->core = platform_device_alloc(wilink_data->name,
+                                          PLATFORM_DEVID_AUTO);
        if (!glue->core) {
                dev_err(glue->dev, "can't allocate platform_device\n");
                return -ENOMEM;
--
2.7.4
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
