From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 20/26] [media] em28xx: split up em28xx_dvb_init to reduce stack size
Date: Thu,  2 Mar 2017 17:38:28 +0100
Message-ID: <20170302163834.2273519-21-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_KASAN, the init function uses a large amount of kernel stack:

drivers/media/usb/em28xx/em28xx-dvb.c: In function 'em28xx_dvb_init':
drivers/media/usb/em28xx/em28xx-dvb.c:2069:1: error: the frame size of 4280 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

By splitting out each part of the switch/case statement that has its own local
variables into a separate function, no single one of them uses more than 500 bytes,
and with a noinline_for_kasan annotation we can ensure that they are not merged
back together.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/usb/em28xx/em28xx-dvb.c | 947 ++++++++++++++++++----------------
 1 file changed, 508 insertions(+), 439 deletions(-)

diff --git a/drivers/media/usb/em28xx/em28xx-dvb.c b/drivers/media/usb/em28xx/em28xx-dvb.c
index 82edd37f0d73..83125a05918a 100644
--- a/drivers/media/usb/em28xx/em28xx-dvb.c
+++ b/drivers/media/usb/em28xx/em28xx-dvb.c
@@ -934,7 +934,7 @@ static struct lgdt3306a_config hauppauge_01595_lgdt3306a_config = {
 
 /* ------------------------------------------------------------------ */
 
-static int em28xx_attach_xc3028(u8 addr, struct em28xx *dev)
+static noinline_for_kasan int em28xx_attach_xc3028(u8 addr, struct em28xx *dev)
 {
 	struct dvb_frontend *fe;
 	struct xc2028_config cfg;
@@ -1126,6 +1126,492 @@ static void em28xx_unregister_dvb(struct em28xx_dvb *dvb)
 	dvb_unregister_adapter(&dvb->adapter);
 }
 
+static noinline_for_kasan int em28174_dvb_init_pctv_460e(struct em28xx *dev)
+{
+	struct em28xx_dvb *dvb = dev->dvb;
+	struct i2c_client *client;
+	struct i2c_board_info board_info;
+	struct tda10071_platform_data tda10071_pdata = {};
+	struct a8293_platform_data a8293_pdata = {};
+	int result;
+
+	/* attach demod + tuner combo */
+	tda10071_pdata.clk = 40444000, /* 40.444 MHz */
+	tda10071_pdata.i2c_wr_max = 64,
+	tda10071_pdata.ts_mode = TDA10071_TS_SERIAL,
+	tda10071_pdata.pll_multiplier = 20,
+	tda10071_pdata.tuner_i2c_addr = 0x14,
+	memset(&board_info, 0, sizeof(board_info));
+	strlcpy(board_info.type, "tda10071_cx24118", I2C_NAME_SIZE);
+	board_info.addr = 0x55;
+	board_info.platform_data = &tda10071_pdata;
+	request_module("tda10071");
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
+	if (client == NULL || client->dev.driver == NULL) {
+		result = -ENODEV;
+		goto out_free;
+	}
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->fe[0] = tda10071_pdata.get_dvb_frontend(client);
+	dvb->i2c_client_demod = client;
+
+	/* attach SEC */
+	a8293_pdata.dvb_frontend = dvb->fe[0];
+	memset(&board_info, 0, sizeof(board_info));
+	strlcpy(board_info.type, "a8293", I2C_NAME_SIZE);
+	board_info.addr = 0x08;
+	board_info.platform_data = &a8293_pdata;
+	request_module("a8293");
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->i2c_client_sec = client;
+	result = 0;
+out_free:
+	return result;
+}
+
+static noinline_for_kasan int em28178_dvb_init_pctv_461e(struct em28xx *dev)
+{
+	struct em28xx_dvb *dvb = dev->dvb;
+	struct i2c_client *client;
+	struct i2c_adapter *i2c_adapter;
+	struct i2c_board_info board_info;
+	struct m88ds3103_platform_data m88ds3103_pdata = {};
+	struct ts2020_config ts2020_config = {};
+	struct a8293_platform_data a8293_pdata = {};
+	int result;
+
+	/* attach demod */
+	m88ds3103_pdata.clk = 27000000;
+	m88ds3103_pdata.i2c_wr_max = 33;
+	m88ds3103_pdata.ts_mode = M88DS3103_TS_PARALLEL;
+	m88ds3103_pdata.ts_clk = 16000;
+	m88ds3103_pdata.ts_clk_pol = 1;
+	m88ds3103_pdata.agc = 0x99;
+	memset(&board_info, 0, sizeof(board_info));
+	strlcpy(board_info.type, "m88ds3103", I2C_NAME_SIZE);
+	board_info.addr = 0x68;
+	board_info.platform_data = &m88ds3103_pdata;
+	request_module("m88ds3103");
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
+	if (client == NULL || client->dev.driver == NULL) {
+		result = -ENODEV;
+		goto out_free;
+	}
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->fe[0] = m88ds3103_pdata.get_dvb_frontend(client);
+	i2c_adapter = m88ds3103_pdata.get_i2c_adapter(client);
+	dvb->i2c_client_demod = client;
+
+	/* attach tuner */
+	ts2020_config.fe = dvb->fe[0];
+	memset(&board_info, 0, sizeof(board_info));
+	strlcpy(board_info.type, "ts2022", I2C_NAME_SIZE);
+	board_info.addr = 0x60;
+	board_info.platform_data = &ts2020_config;
+	request_module("ts2020");
+	client = i2c_new_device(i2c_adapter, &board_info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->i2c_client_tuner = client;
+	/* delegate signal strength measurement to tuner */
+	dvb->fe[0]->ops.read_signal_strength =
+			dvb->fe[0]->ops.tuner_ops.get_rf_strength;
+
+	/* attach SEC */
+	a8293_pdata.dvb_frontend = dvb->fe[0];
+	memset(&board_info, 0, sizeof(board_info));
+	strlcpy(board_info.type, "a8293", I2C_NAME_SIZE);
+	board_info.addr = 0x08;
+	board_info.platform_data = &a8293_pdata;
+	request_module("a8293");
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_tuner->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_tuner);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_tuner->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_tuner);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->i2c_client_sec = client;
+	result = 0;
+out_free:
+	return result;
+}
+
+static noinline_for_kasan int em28178_dvb_init_pctv_292e(struct em28xx *dev)
+{
+	struct em28xx_dvb *dvb = dev->dvb;
+	struct i2c_adapter *adapter;
+	struct i2c_client *client;
+	struct i2c_board_info info;
+	struct si2168_config si2168_config;
+	struct si2157_config si2157_config;
+	int result;
+
+	/* attach demod */
+	memset(&si2168_config, 0, sizeof(si2168_config));
+	si2168_config.i2c_adapter = &adapter;
+	si2168_config.fe = &dvb->fe[0];
+	si2168_config.ts_mode = SI2168_TS_PARALLEL;
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "si2168", I2C_NAME_SIZE);
+	info.addr = 0x64;
+	info.platform_data = &si2168_config;
+	request_module(info.type);
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_demod = client;
+
+	/* attach tuner */
+	memset(&si2157_config, 0, sizeof(si2157_config));
+	si2157_config.fe = dvb->fe[0];
+	si2157_config.if_port = 1;
+#ifdef CONFIG_MEDIA_CONTROLLER_DVB
+	si2157_config.mdev = dev->media_dev;
+#endif
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "si2157", I2C_NAME_SIZE);
+	info.addr = 0x60;
+	info.platform_data = &si2157_config;
+	request_module(info.type);
+	client = i2c_new_device(adapter, &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_tuner = client;
+	dvb->fe[0]->ops.set_lna = em28xx_pctv_292e_set_lna;
+	result = 0;
+out_free:
+	return result;
+}
+
+static noinline_for_kasan int em28178_dvb_init_terratec_t2_stick_hd(struct em28xx *dev)
+{
+	struct em28xx_dvb *dvb = dev->dvb;
+	struct i2c_adapter *adapter;
+	struct i2c_client *client;
+	struct i2c_board_info info;
+	struct si2168_config si2168_config;
+	struct si2157_config si2157_config;
+	int result;
+
+	/* attach demod */
+	memset(&si2168_config, 0, sizeof(si2168_config));
+	si2168_config.i2c_adapter = &adapter;
+	si2168_config.fe = &dvb->fe[0];
+	si2168_config.ts_mode = SI2168_TS_PARALLEL;
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "si2168", I2C_NAME_SIZE);
+	info.addr = 0x64;
+	info.platform_data = &si2168_config;
+	request_module(info.type);
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_demod = client;
+
+	/* attach tuner */
+	memset(&si2157_config, 0, sizeof(si2157_config));
+	si2157_config.fe = dvb->fe[0];
+	si2157_config.if_port = 0;
+#ifdef CONFIG_MEDIA_CONTROLLER_DVB
+	si2157_config.mdev = dev->media_dev;
+#endif
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "si2146", I2C_NAME_SIZE);
+	info.addr = 0x60;
+	info.platform_data = &si2157_config;
+	request_module("si2157");
+	client = i2c_new_device(adapter, &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_tuner = client;
+	result = 0;
+out_free:
+	return result;
+}
+
+static noinline_for_kasan int em28178_dvb_init_plex_px_bcud(struct em28xx *dev)
+{
+	struct em28xx_dvb *dvb = dev->dvb;
+	struct i2c_client *client;
+	struct i2c_board_info info;
+	struct tc90522_config tc90522_config;
+	struct qm1d1c0042_config qm1d1c0042_config;
+	int result;
+
+	/* attach demod */
+	memset(&tc90522_config, 0, sizeof(tc90522_config));
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "tc90522sat", I2C_NAME_SIZE);
+	info.addr = 0x15;
+	info.platform_data = &tc90522_config;
+	request_module("tc90522");
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->i2c_client_demod = client;
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	/* attach tuner */
+	memset(&qm1d1c0042_config, 0,
+	       sizeof(qm1d1c0042_config));
+	qm1d1c0042_config.fe = tc90522_config.fe;
+	qm1d1c0042_config.lpf = 1;
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "qm1d1c0042", I2C_NAME_SIZE);
+	info.addr = 0x61;
+	info.platform_data = &qm1d1c0042_config;
+	request_module(info.type);
+	client = i2c_new_device(tc90522_config.tuner_i2c,
+				&info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->i2c_client_tuner = client;
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	dvb->fe[0] = tc90522_config.fe;
+	px_bcud_init(dev);
+	result = 0;
+out_free:
+	return result;
+}
+
+static noinline_for_kasan int em28174_dvb_init_hauppauge_wintv_dualhd_dvb(struct em28xx *dev)
+{
+	struct em28xx_dvb *dvb = dev->dvb;
+	struct i2c_adapter *adapter;
+	struct i2c_client *client;
+	struct i2c_board_info info;
+	struct si2168_config si2168_config;
+	struct si2157_config si2157_config;
+	int result;
+
+	/* attach demod */
+	memset(&si2168_config, 0, sizeof(si2168_config));
+	si2168_config.i2c_adapter = &adapter;
+	si2168_config.fe = &dvb->fe[0];
+	si2168_config.ts_mode = SI2168_TS_SERIAL;
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "si2168", I2C_NAME_SIZE);
+	info.addr = 0x64;
+	info.platform_data = &si2168_config;
+	request_module(info.type);
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_demod = client;
+
+	/* attach tuner */
+	memset(&si2157_config, 0, sizeof(si2157_config));
+	si2157_config.fe = dvb->fe[0];
+	si2157_config.if_port = 1;
+#ifdef CONFIG_MEDIA_CONTROLLER_DVB
+	si2157_config.mdev = dev->media_dev;
+#endif
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "si2157", I2C_NAME_SIZE);
+	info.addr = 0x60;
+	info.platform_data = &si2157_config;
+	request_module(info.type);
+	client = i2c_new_device(adapter, &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_tuner = client;
+	result = 0;
+out_free:
+	return result;
+}
+
+static int em28174_dvb_init_hauppauge_wintv_dualhd_01595(struct em28xx *dev)
+{
+	struct em28xx_dvb *dvb = dev->dvb;
+	struct i2c_adapter *adapter;
+	struct i2c_client *client;
+	struct i2c_board_info info = {};
+	struct lgdt3306a_config lgdt3306a_config;
+	struct si2157_config si2157_config = {};
+	int result;
+
+	/* attach demod */
+	lgdt3306a_config = hauppauge_01595_lgdt3306a_config;
+	lgdt3306a_config.fe = &dvb->fe[0];
+	lgdt3306a_config.i2c_adapter = &adapter;
+	strlcpy(info.type, "lgdt3306a", sizeof(info.type));
+	info.addr = 0x59;
+	info.platform_data = &lgdt3306a_config;
+	request_module(info.type);
+	client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus],
+			&info);
+	if (client == NULL || client->dev.driver == NULL) {
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_demod = client;
+
+	/* attach tuner */
+	si2157_config.fe = dvb->fe[0];
+	si2157_config.if_port = 1;
+	si2157_config.inversion = 1;
+#ifdef CONFIG_MEDIA_CONTROLLER_DVB
+	si2157_config.mdev = dev->media_dev;
+#endif
+	memset(&info, 0, sizeof(struct i2c_board_info));
+	strlcpy(info.type, "si2157", sizeof(info.type));
+	info.addr = 0x60;
+	info.platform_data = &si2157_config;
+	request_module(info.type);
+
+	client = i2c_new_device(adapter, &info);
+	if (client == NULL || client->dev.driver == NULL) {
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+	if (!try_module_get(client->dev.driver->owner)) {
+		i2c_unregister_device(client);
+		module_put(dvb->i2c_client_demod->dev.driver->owner);
+		i2c_unregister_device(dvb->i2c_client_demod);
+		result = -ENODEV;
+		goto out_free;
+	}
+
+	dvb->i2c_client_tuner = client;
+	result = 0;
+out_free:
+	return result;
+}
 static int em28xx_dvb_init(struct em28xx *dev)
 {
 	int result = 0;
@@ -1427,60 +1913,11 @@ static int em28xx_dvb_init(struct em28xx *dev)
 				   &dev->i2c_adap[dev->def_i2c_bus],
 				   &c3tech_duo_tda18271_config);
 		break;
-	case EM28174_BOARD_PCTV_460E: {
-		struct i2c_client *client;
-		struct i2c_board_info board_info;
-		struct tda10071_platform_data tda10071_pdata = {};
-		struct a8293_platform_data a8293_pdata = {};
-
-		/* attach demod + tuner combo */
-		tda10071_pdata.clk = 40444000, /* 40.444 MHz */
-		tda10071_pdata.i2c_wr_max = 64,
-		tda10071_pdata.ts_mode = TDA10071_TS_SERIAL,
-		tda10071_pdata.pll_multiplier = 20,
-		tda10071_pdata.tuner_i2c_addr = 0x14,
-		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "tda10071_cx24118", I2C_NAME_SIZE);
-		board_info.addr = 0x55;
-		board_info.platform_data = &tda10071_pdata;
-		request_module("tda10071");
-		client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
-		if (client == NULL || client->dev.driver == NULL) {
-			result = -ENODEV;
-			goto out_free;
-		}
-		if (!try_module_get(client->dev.driver->owner)) {
-			i2c_unregister_device(client);
-			result = -ENODEV;
-			goto out_free;
-		}
-		dvb->fe[0] = tda10071_pdata.get_dvb_frontend(client);
-		dvb->i2c_client_demod = client;
-
-		/* attach SEC */
-		a8293_pdata.dvb_frontend = dvb->fe[0];
-		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "a8293", I2C_NAME_SIZE);
-		board_info.addr = 0x08;
-		board_info.platform_data = &a8293_pdata;
-		request_module("a8293");
-		client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
-		if (client == NULL || client->dev.driver == NULL) {
-			module_put(dvb->i2c_client_demod->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_demod);
-			result = -ENODEV;
+	case EM28174_BOARD_PCTV_460E:
+		result = em28174_dvb_init_pctv_460e(dev);
+		if (result)
 			goto out_free;
-		}
-		if (!try_module_get(client->dev.driver->owner)) {
-			i2c_unregister_device(client);
-			module_put(dvb->i2c_client_demod->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_demod);
-			result = -ENODEV;
-			goto out_free;
-		}
-		dvb->i2c_client_sec = client;
 		break;
-	}
 	case EM2874_BOARD_DELOCK_61959:
 	case EM2874_BOARD_MAXMEDIA_UB425_TC:
 		/* attach demodulator */
@@ -1626,403 +2063,35 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			}
 		}
 		break;
-	case EM28178_BOARD_PCTV_461E: {
-		struct i2c_client *client;
-		struct i2c_adapter *i2c_adapter;
-		struct i2c_board_info board_info;
-		struct m88ds3103_platform_data m88ds3103_pdata = {};
-		struct ts2020_config ts2020_config = {};
-		struct a8293_platform_data a8293_pdata = {};
-
-		/* attach demod */
-		m88ds3103_pdata.clk = 27000000;
-		m88ds3103_pdata.i2c_wr_max = 33;
-		m88ds3103_pdata.ts_mode = M88DS3103_TS_PARALLEL;
-		m88ds3103_pdata.ts_clk = 16000;
-		m88ds3103_pdata.ts_clk_pol = 1;
-		m88ds3103_pdata.agc = 0x99;
-		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "m88ds3103", I2C_NAME_SIZE);
-		board_info.addr = 0x68;
-		board_info.platform_data = &m88ds3103_pdata;
-		request_module("m88ds3103");
-		client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
-		if (client == NULL || client->dev.driver == NULL) {
-			result = -ENODEV;
+	case EM28178_BOARD_PCTV_461E: 
+		result = em28178_dvb_init_pctv_461e(dev);
+		if (result)
 			goto out_free;
-		}
-		if (!try_module_get(client->dev.driver->owner)) {
-			i2c_unregister_device(client);
-			result = -ENODEV;
-			goto out_free;
-		}
-		dvb->fe[0] = m88ds3103_pdata.get_dvb_frontend(client);
-		i2c_adapter = m88ds3103_pdata.get_i2c_adapter(client);
-		dvb->i2c_client_demod = client;
-
-		/* attach tuner */
-		ts2020_config.fe = dvb->fe[0];
-		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "ts2022", I2C_NAME_SIZE);
-		board_info.addr = 0x60;
-		board_info.platform_data = &ts2020_config;
-		request_module("ts2020");
-		client = i2c_new_device(i2c_adapter, &board_info);
-		if (client == NULL || client->dev.driver == NULL) {
-			module_put(dvb->i2c_client_demod->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_demod);
-			result = -ENODEV;
-			goto out_free;
-		}
-		if (!try_module_get(client->dev.driver->owner)) {
-			i2c_unregister_device(client);
-			module_put(dvb->i2c_client_demod->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_demod);
-			result = -ENODEV;
-			goto out_free;
-		}
-		dvb->i2c_client_tuner = client;
-		/* delegate signal strength measurement to tuner */
-		dvb->fe[0]->ops.read_signal_strength =
-				dvb->fe[0]->ops.tuner_ops.get_rf_strength;
-
-		/* attach SEC */
-		a8293_pdata.dvb_frontend = dvb->fe[0];
-		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "a8293", I2C_NAME_SIZE);
-		board_info.addr = 0x08;
-		board_info.platform_data = &a8293_pdata;
-		request_module("a8293");
-		client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &board_info);
-		if (client == NULL || client->dev.driver == NULL) {
-			module_put(dvb->i2c_client_tuner->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_tuner);
-			module_put(dvb->i2c_client_demod->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_demod);
-			result = -ENODEV;
-			goto out_free;
-		}
-		if (!try_module_get(client->dev.driver->owner)) {
-			i2c_unregister_device(client);
-			module_put(dvb->i2c_client_tuner->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_tuner);
-			module_put(dvb->i2c_client_demod->dev.driver->owner);
-			i2c_unregister_device(dvb->i2c_client_demod);
-			result = -ENODEV;
-			goto out_free;
-		}
-		dvb->i2c_client_sec = client;
 		break;
-	}
 	case EM28178_BOARD_PCTV_292E:
-		{
-			struct i2c_adapter *adapter;
-			struct i2c_client *client;
-			struct i2c_board_info info;
-			struct si2168_config si2168_config;
-			struct si2157_config si2157_config;
-
-			/* attach demod */
-			memset(&si2168_config, 0, sizeof(si2168_config));
-			si2168_config.i2c_adapter = &adapter;
-			si2168_config.fe = &dvb->fe[0];
-			si2168_config.ts_mode = SI2168_TS_PARALLEL;
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2168", I2C_NAME_SIZE);
-			info.addr = 0x64;
-			info.platform_data = &si2168_config;
-			request_module(info.type);
-			client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_demod = client;
-
-			/* attach tuner */
-			memset(&si2157_config, 0, sizeof(si2157_config));
-			si2157_config.fe = dvb->fe[0];
-			si2157_config.if_port = 1;
-#ifdef CONFIG_MEDIA_CONTROLLER_DVB
-			si2157_config.mdev = dev->media_dev;
-#endif
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2157", I2C_NAME_SIZE);
-			info.addr = 0x60;
-			info.platform_data = &si2157_config;
-			request_module(info.type);
-			client = i2c_new_device(adapter, &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_tuner = client;
-			dvb->fe[0]->ops.set_lna = em28xx_pctv_292e_set_lna;
-		}
+		result = em28178_dvb_init_pctv_292e(dev);
+		if (result)
+			goto out_free;
 		break;
 	case EM28178_BOARD_TERRATEC_T2_STICK_HD:
-		{
-			struct i2c_adapter *adapter;
-			struct i2c_client *client;
-			struct i2c_board_info info;
-			struct si2168_config si2168_config;
-			struct si2157_config si2157_config;
-
-			/* attach demod */
-			memset(&si2168_config, 0, sizeof(si2168_config));
-			si2168_config.i2c_adapter = &adapter;
-			si2168_config.fe = &dvb->fe[0];
-			si2168_config.ts_mode = SI2168_TS_PARALLEL;
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2168", I2C_NAME_SIZE);
-			info.addr = 0x64;
-			info.platform_data = &si2168_config;
-			request_module(info.type);
-			client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_demod = client;
-
-			/* attach tuner */
-			memset(&si2157_config, 0, sizeof(si2157_config));
-			si2157_config.fe = dvb->fe[0];
-			si2157_config.if_port = 0;
-#ifdef CONFIG_MEDIA_CONTROLLER_DVB
-			si2157_config.mdev = dev->media_dev;
-#endif
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2146", I2C_NAME_SIZE);
-			info.addr = 0x60;
-			info.platform_data = &si2157_config;
-			request_module("si2157");
-			client = i2c_new_device(adapter, &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_tuner = client;
-		}
+		result = em28178_dvb_init_terratec_t2_stick_hd(dev);
+		if (result)
+			goto out_free;
 		break;
-
 	case EM28178_BOARD_PLEX_PX_BCUD:
-		{
-			struct i2c_client *client;
-			struct i2c_board_info info;
-			struct tc90522_config tc90522_config;
-			struct qm1d1c0042_config qm1d1c0042_config;
-
-			/* attach demod */
-			memset(&tc90522_config, 0, sizeof(tc90522_config));
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "tc90522sat", I2C_NAME_SIZE);
-			info.addr = 0x15;
-			info.platform_data = &tc90522_config;
-			request_module("tc90522");
-			client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				result = -ENODEV;
-				goto out_free;
-			}
-			dvb->i2c_client_demod = client;
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			/* attach tuner */
-			memset(&qm1d1c0042_config, 0,
-			       sizeof(qm1d1c0042_config));
-			qm1d1c0042_config.fe = tc90522_config.fe;
-			qm1d1c0042_config.lpf = 1;
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "qm1d1c0042", I2C_NAME_SIZE);
-			info.addr = 0x61;
-			info.platform_data = &qm1d1c0042_config;
-			request_module(info.type);
-			client = i2c_new_device(tc90522_config.tuner_i2c,
-						&info);
-			if (client == NULL || client->dev.driver == NULL) {
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-			dvb->i2c_client_tuner = client;
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-			dvb->fe[0] = tc90522_config.fe;
-			px_bcud_init(dev);
-		}
+		result = em28178_dvb_init_plex_px_bcud(dev);
+		if (result)
+			goto out_free;
 		break;
 	case EM28174_BOARD_HAUPPAUGE_WINTV_DUALHD_DVB:
-		{
-			struct i2c_adapter *adapter;
-			struct i2c_client *client;
-			struct i2c_board_info info;
-			struct si2168_config si2168_config;
-			struct si2157_config si2157_config;
-
-			/* attach demod */
-			memset(&si2168_config, 0, sizeof(si2168_config));
-			si2168_config.i2c_adapter = &adapter;
-			si2168_config.fe = &dvb->fe[0];
-			si2168_config.ts_mode = SI2168_TS_SERIAL;
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2168", I2C_NAME_SIZE);
-			info.addr = 0x64;
-			info.platform_data = &si2168_config;
-			request_module(info.type);
-			client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus], &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_demod = client;
-
-			/* attach tuner */
-			memset(&si2157_config, 0, sizeof(si2157_config));
-			si2157_config.fe = dvb->fe[0];
-			si2157_config.if_port = 1;
-#ifdef CONFIG_MEDIA_CONTROLLER_DVB
-			si2157_config.mdev = dev->media_dev;
-#endif
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2157", I2C_NAME_SIZE);
-			info.addr = 0x60;
-			info.platform_data = &si2157_config;
-			request_module(info.type);
-			client = i2c_new_device(adapter, &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_tuner = client;
-
-		}
+		result = em28174_dvb_init_hauppauge_wintv_dualhd_dvb(dev);
+		if (result)
+			goto out_free;
 		break;
 	case EM28174_BOARD_HAUPPAUGE_WINTV_DUALHD_01595:
-		{
-			struct i2c_adapter *adapter;
-			struct i2c_client *client;
-			struct i2c_board_info info = {};
-			struct lgdt3306a_config lgdt3306a_config;
-			struct si2157_config si2157_config = {};
-
-			/* attach demod */
-			lgdt3306a_config = hauppauge_01595_lgdt3306a_config;
-			lgdt3306a_config.fe = &dvb->fe[0];
-			lgdt3306a_config.i2c_adapter = &adapter;
-			strlcpy(info.type, "lgdt3306a", sizeof(info.type));
-			info.addr = 0x59;
-			info.platform_data = &lgdt3306a_config;
-			request_module(info.type);
-			client = i2c_new_device(&dev->i2c_adap[dev->def_i2c_bus],
-					&info);
-			if (client == NULL || client->dev.driver == NULL) {
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_demod = client;
-
-			/* attach tuner */
-			si2157_config.fe = dvb->fe[0];
-			si2157_config.if_port = 1;
-			si2157_config.inversion = 1;
-#ifdef CONFIG_MEDIA_CONTROLLER_DVB
-			si2157_config.mdev = dev->media_dev;
-#endif
-			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2157", sizeof(info.type));
-			info.addr = 0x60;
-			info.platform_data = &si2157_config;
-			request_module(info.type);
-
-			client = i2c_new_device(adapter, &info);
-			if (client == NULL || client->dev.driver == NULL) {
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-			if (!try_module_get(client->dev.driver->owner)) {
-				i2c_unregister_device(client);
-				module_put(dvb->i2c_client_demod->dev.driver->owner);
-				i2c_unregister_device(dvb->i2c_client_demod);
-				result = -ENODEV;
-				goto out_free;
-			}
-
-			dvb->i2c_client_tuner = client;
-		}
+		result = em28174_dvb_init_hauppauge_wintv_dualhd_01595(dev);
+		if (result)
+			goto out_free;
 		break;
 	default:
 		dev_err(&dev->intf->dev,
-- 
2.9.0
