From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v4 4/9] em28xx: fix em28xx_dvb_init for KASAN
Date: Fri, 22 Sep 2017 23:29:15 +0200
Message-ID: <20170922212930.620249-5-arnd@arndb.de>
References: <20170922212930.620249-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Jiri Pirko <jiri@resnulli.us>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, kasan-dev@googlegroups.com
To: Mauro Carvalho Chehab <mchehab@kernel.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-1-arnd@arndb.de>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_KASAN, the init function uses a large amount of kernel stack:

drivers/media/usb/em28xx/em28xx-dvb.c: In function 'em28xx_dvb_init.part.4':
drivers/media/usb/em28xx/em28xx-dvb.c:2061:1: error: the frame size of 3232 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]

It seems that this is triggered in part by using strlcpy(), which the
compiler doesn't recognize as copying at most 'len' bytes, since strlcpy
is not part of the C standard.

It does however recognize the standard strncpy() and optimizes away
the extra checks for that, using only 1688 bytes in the end.
I have another larger patch that we could use in addition to this one,
in order to shrink the stack for -fsanitize-address-use-after-scope
(with gcc-7.1.1) as well, but that would not be appropriate for
stable backports, so let's focus on this one first.

Cc: stable@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/usb/em28xx/em28xx-dvb.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/media/usb/em28xx/em28xx-dvb.c b/drivers/media/usb/em28xx/em28xx-dvb.c
index 4a7db623fe29..06c363dc55ed 100644
--- a/drivers/media/usb/em28xx/em28xx-dvb.c
+++ b/drivers/media/usb/em28xx/em28xx-dvb.c
@@ -1440,7 +1440,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 		tda10071_pdata.pll_multiplier = 20,
 		tda10071_pdata.tuner_i2c_addr = 0x14,
 		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "tda10071_cx24118", I2C_NAME_SIZE);
+		strncpy(board_info.type, "tda10071_cx24118", I2C_NAME_SIZE - 1);
 		board_info.addr = 0x55;
 		board_info.platform_data = &tda10071_pdata;
 		request_module("tda10071");
@@ -1460,7 +1460,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 		/* attach SEC */
 		a8293_pdata.dvb_frontend = dvb->fe[0];
 		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "a8293", I2C_NAME_SIZE);
+		strncpy(board_info.type, "a8293", I2C_NAME_SIZE - 1);
 		board_info.addr = 0x08;
 		board_info.platform_data = &a8293_pdata;
 		request_module("a8293");
@@ -1643,7 +1643,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 		m88ds3103_pdata.ts_clk_pol = 1;
 		m88ds3103_pdata.agc = 0x99;
 		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "m88ds3103", I2C_NAME_SIZE);
+		strncpy(board_info.type, "m88ds3103", I2C_NAME_SIZE - 1);
 		board_info.addr = 0x68;
 		board_info.platform_data = &m88ds3103_pdata;
 		request_module("m88ds3103");
@@ -1664,7 +1664,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 		/* attach tuner */
 		ts2020_config.fe = dvb->fe[0];
 		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "ts2022", I2C_NAME_SIZE);
+		strncpy(board_info.type, "ts2022", I2C_NAME_SIZE - 1);
 		board_info.addr = 0x60;
 		board_info.platform_data = &ts2020_config;
 		request_module("ts2020");
@@ -1690,7 +1690,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 		/* attach SEC */
 		a8293_pdata.dvb_frontend = dvb->fe[0];
 		memset(&board_info, 0, sizeof(board_info));
-		strlcpy(board_info.type, "a8293", I2C_NAME_SIZE);
+		strncpy(board_info.type, "a8293", I2C_NAME_SIZE - 1);
 		board_info.addr = 0x08;
 		board_info.platform_data = &a8293_pdata;
 		request_module("a8293");
@@ -1729,7 +1729,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			si2168_config.fe = &dvb->fe[0];
 			si2168_config.ts_mode = SI2168_TS_PARALLEL;
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2168", I2C_NAME_SIZE);
+			strncpy(info.type, "si2168", I2C_NAME_SIZE - 1);
 			info.addr = 0x64;
 			info.platform_data = &si2168_config;
 			request_module(info.type);
@@ -1755,7 +1755,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			si2157_config.mdev = dev->media_dev;
 #endif
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2157", I2C_NAME_SIZE);
+			strncpy(info.type, "si2157", I2C_NAME_SIZE - 1);
 			info.addr = 0x60;
 			info.platform_data = &si2157_config;
 			request_module(info.type);
@@ -1793,7 +1793,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			si2168_config.fe = &dvb->fe[0];
 			si2168_config.ts_mode = SI2168_TS_PARALLEL;
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2168", I2C_NAME_SIZE);
+			strncpy(info.type, "si2168", I2C_NAME_SIZE - 1);
 			info.addr = 0x64;
 			info.platform_data = &si2168_config;
 			request_module(info.type);
@@ -1819,7 +1819,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			si2157_config.mdev = dev->media_dev;
 #endif
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2146", I2C_NAME_SIZE);
+			strncpy(info.type, "si2146", I2C_NAME_SIZE - 1);
 			info.addr = 0x60;
 			info.platform_data = &si2157_config;
 			request_module("si2157");
@@ -1853,7 +1853,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			/* attach demod */
 			memset(&tc90522_config, 0, sizeof(tc90522_config));
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "tc90522sat", I2C_NAME_SIZE);
+			strncpy(info.type, "tc90522sat", I2C_NAME_SIZE - 1);
 			info.addr = 0x15;
 			info.platform_data = &tc90522_config;
 			request_module("tc90522");
@@ -1875,7 +1875,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			qm1d1c0042_config.fe = tc90522_config.fe;
 			qm1d1c0042_config.lpf = 1;
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "qm1d1c0042", I2C_NAME_SIZE);
+			strncpy(info.type, "qm1d1c0042", I2C_NAME_SIZE - 1);
 			info.addr = 0x61;
 			info.platform_data = &qm1d1c0042_config;
 			request_module(info.type);
@@ -1913,7 +1913,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			si2168_config.fe = &dvb->fe[0];
 			si2168_config.ts_mode = SI2168_TS_SERIAL;
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2168", I2C_NAME_SIZE);
+			strncpy(info.type, "si2168", I2C_NAME_SIZE - 1);
 			info.addr = 0x64;
 			info.platform_data = &si2168_config;
 			request_module(info.type);
@@ -1939,7 +1939,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			si2157_config.mdev = dev->media_dev;
 #endif
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2157", I2C_NAME_SIZE);
+			strncpy(info.type, "si2157", I2C_NAME_SIZE - 1);
 			info.addr = 0x60;
 			info.platform_data = &si2157_config;
 			request_module(info.type);
@@ -1975,7 +1975,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			lgdt3306a_config = hauppauge_01595_lgdt3306a_config;
 			lgdt3306a_config.fe = &dvb->fe[0];
 			lgdt3306a_config.i2c_adapter = &adapter;
-			strlcpy(info.type, "lgdt3306a", sizeof(info.type));
+			strncpy(info.type, "lgdt3306a", sizeof(info.type) - 1);
 			info.addr = 0x59;
 			info.platform_data = &lgdt3306a_config;
 			request_module(info.type);
@@ -2002,7 +2002,7 @@ static int em28xx_dvb_init(struct em28xx *dev)
 			si2157_config.mdev = dev->media_dev;
 #endif
 			memset(&info, 0, sizeof(struct i2c_board_info));
-			strlcpy(info.type, "si2157", sizeof(info.type));
+			strncpy(info.type, "si2157", sizeof(info.type) - 1);
 			info.addr = 0x60;
 			info.platform_data = &si2157_config;
 			request_module(info.type);
-- 
2.9.0

