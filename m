From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 19/26] [media] r820t: mark register functions as noinline_for_kasan
Date: Thu,  2 Mar 2017 17:38:27 +0100
Message-ID: <20170302163834.2273519-20-arnd@arndb.de>
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

With KASAN, we get an overly long stack frame due to inlining
the register access function:

drivers/media/tuners/r820t.c: In function 'generic_set_freq.isra.7':
drivers/media/tuners/r820t.c:1334:1: error: the frame size of 2880 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]

An earlier patch I tried used an open-coded r820t_write_reg()
implementation that may have been more efficent, while this
version simply adds the annotation, which has a lower risk for
regressions.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/tuners/r820t.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/media/tuners/r820t.c b/drivers/media/tuners/r820t.c
index ba80376a3b86..0fbfa6416e38 100644
--- a/drivers/media/tuners/r820t.c
+++ b/drivers/media/tuners/r820t.c
@@ -396,7 +396,7 @@ static int r820t_write(struct r820t_priv *priv, u8 reg, const u8 *val,
 	return 0;
 }
 
-static int r820t_write_reg(struct r820t_priv *priv, u8 reg, u8 val)
+static noinline_for_kasan int r820t_write_reg(struct r820t_priv *priv, u8 reg, u8 val)
 {
 	return r820t_write(priv, reg, &val, 1);
 }
@@ -411,7 +411,7 @@ static int r820t_read_cache_reg(struct r820t_priv *priv, int reg)
 		return -EINVAL;
 }
 
-static int r820t_write_reg_mask(struct r820t_priv *priv, u8 reg, u8 val,
+static noinline_for_kasan int r820t_write_reg_mask(struct r820t_priv *priv, u8 reg, u8 val,
 				u8 bit_mask)
 {
 	int rc = r820t_read_cache_reg(priv, reg);
-- 
2.9.0
