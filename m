From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 07/13] net: wl12xx: spi: add a context structure
Date: Sat, 14 May 2011 00:26:24 +0300
Message-ID: <1305321990-22041-8-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this will help re-structuring the driver so
that we avoid all duplications which are
currently on this driver.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/spi.c |  128 +++++++++++++++++++++++-------------
 1 files changed, 82 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/spi.c b/drivers/net/wireless/wl12xx/spi.c
index 382b79d..5dbd5b3 100644
--- a/drivers/net/wireless/wl12xx/spi.c
+++ b/drivers/net/wireless/wl12xx/spi.c
@@ -68,14 +68,19 @@
 
 #define WSPI_MAX_NUM_OF_CHUNKS (WL1271_AGGR_BUFFER_SIZE / WSPI_MAX_CHUNK_SIZE)
 
-static inline struct spi_device *wl_to_spi(struct wl1271 *wl)
+struct wl12xx_spi_glue {
+	struct device	*dev;
+	struct wl1271	*wl;
+};
+
+static inline struct wl12xx_spi_glue *wl_to_glue(struct wl1271 *wl)
 {
 	return wl->if_priv;
 }
 
 static struct device *wl1271_spi_wl_to_dev(struct wl1271 *wl)
 {
-	return &(wl_to_spi(wl)->dev);
+	return wl_to_glue(wl)->dev;
 }
 
 static void wl1271_spi_disable_interrupts(struct wl1271 *wl)
@@ -90,9 +95,10 @@ static void wl1271_spi_enable_interrupts(struct wl1271 *wl)
 
 static void wl1271_spi_reset(struct wl1271 *wl)
 {
-	u8 *cmd;
-	struct spi_transfer t;
-	struct spi_message m;
+	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct spi_transfer	t;
+	struct spi_message	m;
+	u8			*cmd;
 
 	cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
 	if (!cmd) {
@@ -109,7 +115,7 @@ static void wl1271_spi_reset(struct wl1271 *wl)
 	t.len = WSPI_INIT_CMD_LEN;
 	spi_message_add_tail(&t, &m);
 
-	spi_sync(wl_to_spi(wl), &m);
+	spi_sync(to_spi_device(glue->dev), &m);
 
 	wl1271_dump(DEBUG_SPI, "spi reset -> ", cmd, WSPI_INIT_CMD_LEN);
 	kfree(cmd);
@@ -117,9 +123,12 @@ static void wl1271_spi_reset(struct wl1271 *wl)
 
 static void wl1271_spi_init(struct wl1271 *wl)
 {
-	u8 crc[WSPI_INIT_CMD_CRC_LEN], *cmd;
-	struct spi_transfer t;
-	struct spi_message m;
+	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct spi_transfer	t;
+	struct spi_message	m;
+
+	u8			crc[WSPI_INIT_CMD_CRC_LEN];
+	u8			*cmd;
 
 	cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
 	if (!cmd) {
@@ -164,7 +173,7 @@ static void wl1271_spi_init(struct wl1271 *wl)
 	t.len = WSPI_INIT_CMD_LEN;
 	spi_message_add_tail(&t, &m);
 
-	spi_sync(wl_to_spi(wl), &m);
+	spi_sync(to_spi_device(glue->dev), &m);
 	wl1271_dump(DEBUG_SPI, "spi init -> ", cmd, WSPI_INIT_CMD_LEN);
 	kfree(cmd);
 }
@@ -173,10 +182,12 @@ static void wl1271_spi_init(struct wl1271 *wl)
 
 static int wl1271_spi_read_busy(struct wl1271 *wl)
 {
-	struct spi_transfer t[1];
-	struct spi_message m;
-	u32 *busy_buf;
-	int num_busy_bytes = 0;
+	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct spi_transfer	t[1];
+	struct spi_message	m;
+
+	int			num_busy_bytes = 0;
+	u32			*busy_buf;
 
 	/*
 	 * Read further busy words from SPI until a non-busy word is
@@ -193,7 +204,7 @@ static int wl1271_spi_read_busy(struct wl1271 *wl)
 		t[0].len = sizeof(u32);
 		t[0].cs_change = true;
 		spi_message_add_tail(&t[0], &m);
-		spi_sync(wl_to_spi(wl), &m);
+		spi_sync(to_spi_device(glue->dev), &m);
 
 		if (*busy_buf & 0x1)
 			return 0;
@@ -207,11 +218,13 @@ static int wl1271_spi_read_busy(struct wl1271 *wl)
 static void wl1271_spi_raw_read(struct wl1271 *wl, int addr, void *buf,
 				size_t len, bool fixed)
 {
-	struct spi_transfer t[2];
-	struct spi_message m;
-	u32 *busy_buf;
-	u32 *cmd;
-	u32 chunk_len;
+	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct spi_transfer	t[2];
+	struct spi_message	m;
+
+	u32			*busy_buf;
+	u32			*cmd;
+	u32			chunk_len;
 
 	while (len > 0) {
 		chunk_len = min((size_t)WSPI_MAX_CHUNK_SIZE, len);
@@ -242,7 +255,7 @@ static void wl1271_spi_raw_read(struct wl1271 *wl, int addr, void *buf,
 		t[1].cs_change = true;
 		spi_message_add_tail(&t[1], &m);
 
-		spi_sync(wl_to_spi(wl), &m);
+		spi_sync(to_spi_device(glue->dev), &m);
 
 		if (!(busy_buf[WL1271_BUSY_WORD_CNT - 1] & 0x1) &&
 		    wl1271_spi_read_busy(wl)) {
@@ -258,7 +271,7 @@ static void wl1271_spi_raw_read(struct wl1271 *wl, int addr, void *buf,
 		t[0].cs_change = true;
 		spi_message_add_tail(&t[0], &m);
 
-		spi_sync(wl_to_spi(wl), &m);
+		spi_sync(to_spi_device(glue->dev), &m);
 
 		wl1271_dump(DEBUG_SPI, "spi_read cmd -> ", cmd, sizeof(*cmd));
 		wl1271_dump(DEBUG_SPI, "spi_read buf <- ", buf, chunk_len);
@@ -273,12 +286,15 @@ static void wl1271_spi_raw_read(struct wl1271 *wl, int addr, void *buf,
 static void wl1271_spi_raw_write(struct wl1271 *wl, int addr, void *buf,
 			  size_t len, bool fixed)
 {
-	struct spi_transfer t[2 * WSPI_MAX_NUM_OF_CHUNKS];
-	struct spi_message m;
-	u32 commands[WSPI_MAX_NUM_OF_CHUNKS];
-	u32 *cmd;
-	u32 chunk_len;
-	int i;
+	struct wl12xx_spi_glue	*glue = wl_to_glue(wl);
+	struct spi_transfer	t[2 * WSPI_MAX_NUM_OF_CHUNKS];
+	struct spi_message	m;
+
+	u32			commands[WSPI_MAX_NUM_OF_CHUNKS];
+	u32			chunk_len;
+	u32			*cmd;
+
+	int			i;
 
 	WARN_ON(len > WL1271_AGGR_BUFFER_SIZE);
 
@@ -317,7 +333,7 @@ static void wl1271_spi_raw_write(struct wl1271 *wl, int addr, void *buf,
 		cmd++;
 	}
 
-	spi_sync(wl_to_spi(wl), &m);
+	spi_sync(to_spi_device(glue->dev), &m);
 }
 
 static irqreturn_t wl1271_hardirq(int irq, void *cookie)
@@ -360,10 +376,13 @@ static struct wl1271_if_operations spi_ops = {
 
 static int __devinit wl1271_probe(struct spi_device *spi)
 {
-	struct wl12xx_platform_data *pdata;
-	struct ieee80211_hw *hw;
-	struct wl1271 *wl;
-	int ret;
+	struct wl12xx_platform_data	*pdata;
+
+	struct wl12xx_spi_glue		*glue;
+	struct ieee80211_hw		*hw;
+	struct wl1271			*wl;
+
+	int				ret = -ENOMEM;
 
 	pdata = spi->dev.platform_data;
 	if (!pdata) {
@@ -371,14 +390,25 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 		return -ENODEV;
 	}
 
+	glue = kzalloc(sizeof(*glue), GFP_KERNEL);
+	if (!glue) {
+		dev_err(&spi->dev, "not enought memory\n");
+		goto err0;
+	}
+
 	hw = wl1271_alloc_hw();
-	if (IS_ERR(hw))
-		return PTR_ERR(hw);
+	if (IS_ERR(hw)) {
+		ret = PTR_ERR(hw);
+		goto err1;
+	}
 
 	wl = hw->priv;
 
-	dev_set_drvdata(&spi->dev, wl);
-	wl->if_priv = spi;
+	glue->dev = &spi->dev;
+	glue->wl = wl;
+
+	spi_set_drvdata(spi, glue);
+	wl->if_priv = glue;
 
 	wl->if_ops = &spi_ops;
 
@@ -389,14 +419,14 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 	ret = spi_setup(spi);
 	if (ret < 0) {
 		wl1271_error("spi_setup failed");
-		goto out_free;
+		goto err2;
 	}
 
 	wl->set_power = pdata->set_power;
 	if (!wl->set_power) {
 		wl1271_error("set power function missing in platform data");
 		ret = -ENODEV;
-		goto out_free;
+		goto err2;
 	}
 
 	wl->ref_clock = pdata->board_ref_clock;
@@ -405,7 +435,7 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 	if (wl->irq < 0) {
 		wl1271_error("irq missing in platform data");
 		ret = -ENODEV;
-		goto out_free;
+		goto err2;
 	}
 
 	ret = request_threaded_irq(wl->irq, wl1271_hardirq, wl1271_irq,
@@ -413,37 +443,43 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 				   DRIVER_NAME, wl);
 	if (ret < 0) {
 		wl1271_error("request_irq() failed: %d", ret);
-		goto out_free;
+		goto err2;
 	}
 
 	disable_irq(wl->irq);
 
 	ret = wl1271_init_ieee80211(wl);
 	if (ret)
-		goto out_irq;
+		goto err3;
 
 	ret = wl1271_register_hw(wl);
 	if (ret)
-		goto out_irq;
+		goto err3;
 
 	return 0;
 
- out_irq:
+err3:
 	free_irq(wl->irq, wl);
 
- out_free:
+err2:
 	wl1271_free_hw(wl);
 
+err1:
+	kfree(glue);
+
+err0:
 	return ret;
 }
 
 static int __devexit wl1271_remove(struct spi_device *spi)
 {
-	struct wl1271 *wl = dev_get_drvdata(&spi->dev);
+	struct wl12xx_spi_glue	*glue = spi_get_drvdata(spi);
+	struct wl1271		*wl = glue->wl;
 
 	wl1271_unregister_hw(wl);
 	free_irq(wl->irq, wl);
 	wl1271_free_hw(wl);
+	kfree(glue);
 
 	return 0;
 }
-- 
1.7.4.1.343.ga91df
