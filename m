From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 15/26] [media] tuners: i2c: reduce stack usage for tuner_i2c_xfer_*
Date: Thu,  2 Mar 2017 17:38:23 +0100
Message-ID: <20170302163834.2273519-16-arnd@arndb.de>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:58845 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752664AbdCBRLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 12:11:16 -0500
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_KASAN is enabled, we see very large stack usage in some
functions, e.g.:

drivers/media/tuners/tda8290.c: In function 'tda8290_set_params':
drivers/media/tuners/tda8290.c:310:1: warning: the frame size of 3184 bytes is larger than 1024 bytes [-Wframe-larger-than=]
drivers/media/tuners/tda8290.c: In function 'tda829x_probe':
drivers/media/tuners/tda8290.c:878:1: warning: the frame size of 1088 bytes is larger than 1024 bytes [-Wframe-larger-than=]

By annotating the helpers as noinline_for_kasan, we can easily avoid this.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/tuners/tuner-i2c.h | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/media/tuners/tuner-i2c.h b/drivers/media/tuners/tuner-i2c.h
index bda67a5a76f2..c8970299799c 100644
--- a/drivers/media/tuners/tuner-i2c.h
+++ b/drivers/media/tuners/tuner-i2c.h
@@ -33,8 +33,8 @@ struct tuner_i2c_props {
 	char *name;
 };
 
-static inline int tuner_i2c_xfer_send(struct tuner_i2c_props *props,
-				      unsigned char *buf, int len)
+static noinline_for_kasan int
+tuner_i2c_xfer_send(struct tuner_i2c_props *props, unsigned char *buf, int len)
 {
 	struct i2c_msg msg = { .addr = props->addr, .flags = 0,
 			       .buf = buf, .len = len };
@@ -43,8 +43,8 @@ static inline int tuner_i2c_xfer_send(struct tuner_i2c_props *props,
 	return (ret == 1) ? len : ret;
 }
 
-static inline int tuner_i2c_xfer_recv(struct tuner_i2c_props *props,
-				      unsigned char *buf, int len)
+static noinline_for_kasan int
+tuner_i2c_xfer_recv(struct tuner_i2c_props *props, unsigned char *buf, int len)
 {
 	struct i2c_msg msg = { .addr = props->addr, .flags = I2C_M_RD,
 			       .buf = buf, .len = len };
@@ -53,9 +53,10 @@ static inline int tuner_i2c_xfer_recv(struct tuner_i2c_props *props,
 	return (ret == 1) ? len : ret;
 }
 
-static inline int tuner_i2c_xfer_send_recv(struct tuner_i2c_props *props,
-					   unsigned char *obuf, int olen,
-					   unsigned char *ibuf, int ilen)
+static noinline_for_kasan int
+tuner_i2c_xfer_send_recv(struct tuner_i2c_props *props,
+			 unsigned char *obuf, int olen,
+			 unsigned char *ibuf, int ilen)
 {
 	struct i2c_msg msg[2] = { { .addr = props->addr, .flags = 0,
 				    .buf = obuf, .len = olen },
-- 
2.9.0
