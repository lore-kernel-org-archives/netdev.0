From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 18/26] [media] i2c: cx25840: avoid stack overflow with KASAN
Date: Thu,  2 Mar 2017 17:38:26 +0100
Message-ID: <20170302163834.2273519-19-arnd@arndb.de>
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
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_KASAN, this driver has shown a ridiculously large stack frame
in one configuration:

drivers/media/i2c/cx25840/cx25840-core.c:4960:1: error: the frame size of 94000 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]

In most builds, it's only about 3300 bytes, but that's still large anough to
risk a kernel stack overflow.

Marking the two register access functions as noinline_for_kasan avoids
the problem and brings the largest stack frame size down to 232 bytes.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/i2c/cx25840/cx25840-core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/media/i2c/cx25840/cx25840-core.c b/drivers/media/i2c/cx25840/cx25840-core.c
index b8d3c070bfc1..fd72e5a11cb9 100644
--- a/drivers/media/i2c/cx25840/cx25840-core.c
+++ b/drivers/media/i2c/cx25840/cx25840-core.c
@@ -81,7 +81,7 @@ MODULE_PARM_DESC(debug, "Debugging messages [0=Off (default) 1=On]");
 /* ----------------------------------------------------------------------- */
 static void cx23888_std_setup(struct i2c_client *client);
 
-int cx25840_write(struct i2c_client *client, u16 addr, u8 value)
+noinline_for_kasan int cx25840_write(struct i2c_client *client, u16 addr, u8 value)
 {
 	u8 buffer[3];
 	buffer[0] = addr >> 8;
@@ -90,7 +90,7 @@ int cx25840_write(struct i2c_client *client, u16 addr, u8 value)
 	return i2c_master_send(client, buffer, 3);
 }
 
-int cx25840_write4(struct i2c_client *client, u16 addr, u32 value)
+noinline_for_kasan int cx25840_write4(struct i2c_client *client, u16 addr, u32 value)
 {
 	u8 buffer[6];
 	buffer[0] = addr >> 8;
-- 
2.9.0
