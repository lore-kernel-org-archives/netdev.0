From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] ray_cs: Avoid reading past end of buffer
Date: Fri, 5 May 2017 15:38:41 -0700
Message-ID: <20170505223841.GA20367@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org, Daniel Micay <danielmicay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using memcpy() from a buffer that is shorter than the length copied means
the destination buffer is being filled with arbitrary data from the kernel
rodata segment. In this case, the source was made longer, since it did not
match the destination structure size. Additionally removes a needless cast.

This was found with the future CONFIG_FORTIFY_SOURCE feature.

Cc: Daniel Micay <danielmicay@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/ray_cs.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index b94479441b0c..170cd504e8ff 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -247,7 +247,10 @@ static const UCHAR b4_default_startup_parms[] = {
 	0x04, 0x08,		/* Noise gain, limit offset */
 	0x28, 0x28,		/* det rssi, med busy offsets */
 	7,			/* det sync thresh */
-	0, 2, 2			/* test mode, min, max */
+	0, 2, 2,		/* test mode, min, max */
+	0,			/* rx/tx delay */
+	0, 0, 0, 0, 0, 0,	/* current BSS id */
+	0			/* hop set */
 };
 
 /*===========================================================================*/
@@ -597,7 +600,7 @@ static void init_startup_params(ray_dev_t *local)
 	 *    a_beacon_period = hops    a_beacon_period = KuS
 	 *//* 64ms = 010000 */
 	if (local->fw_ver == 0x55) {
-		memcpy((UCHAR *) &local->sparm.b4, b4_default_startup_parms,
+		memcpy(&local->sparm.b4, b4_default_startup_parms,
 		       sizeof(struct b4_startup_params));
 		/* Translate sane kus input values to old build 4/5 format */
 		/* i = hop time in uS truncated to 3 bytes */
-- 
2.7.4


-- 
Kees Cook
Pixel Security
