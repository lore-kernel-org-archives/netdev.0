From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 16/26] [media] i2c: adv7604: mark register access as noinline_for_kasan
Date: Thu,  2 Mar 2017 17:38:24 +0100
Message-ID: <20170302163834.2273519-17-arnd@arndb.de>
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

When building with KASAN, we get a stack frame size warning about a function
that could potentially cause a stack overflow:

drivers/media/i2c/adv7604.c: In function 'adv76xx_log_status':
drivers/media/i2c/adv7604.c:2615:1: error: the frame size of 3248 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

This is caused by adv76xx_read_check() being inlined repeatedly, and
marking this function as noinline_for_kasan solves the problem
completely.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/i2c/adv7604.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/media/i2c/adv7604.c b/drivers/media/i2c/adv7604.c
index d8bf435db86d..176f46ac85fd 100644
--- a/drivers/media/i2c/adv7604.c
+++ b/drivers/media/i2c/adv7604.c
@@ -339,8 +339,8 @@ static inline unsigned vtotal(const struct v4l2_bt_timings *t)
 
 /* ----------------------------------------------------------------------- */
 
-static int adv76xx_read_check(struct adv76xx_state *state,
-			     int client_page, u8 reg)
+static noinline_for_kasan int adv76xx_read_check(struct adv76xx_state *state,
+						 int client_page, u8 reg)
 {
 	struct i2c_client *client = state->i2c_clients[client_page];
 	int err;
-- 
2.9.0
