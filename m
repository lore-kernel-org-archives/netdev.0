From: Luis Henriques <luis.henriques@canonical.com>
Subject: [PATCH] net: rfkill: Do not ignore errors from regulator_enable()
Date: Wed, 14 Aug 2013 23:10:06 +0100
Message-ID: <1376518206-10710-1-git-send-email-luis.henriques@canonical.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function regulator_enable() may return an error that has to be checked.
This patch changes function rfkill_regulator_set_block() so that it checks
for the return code.  Also, rfkill_data->reg_enabled is set to 'true' only
if there is no error.

This fixes the following compilation warning:

net/rfkill/rfkill-regulator.c:43:20: warning: ignoring return value of 'regulator_enable', declared with attribute warn_unused_result [-Wunused-result]

Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 net/rfkill/rfkill-regulator.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
index d11ac79..cf5b145 100644
--- a/net/rfkill/rfkill-regulator.c
+++ b/net/rfkill/rfkill-regulator.c
@@ -30,6 +30,7 @@ struct rfkill_regulator_data {
 static int rfkill_regulator_set_block(void *data, bool blocked)
 {
 	struct rfkill_regulator_data *rfkill_data = data;
+	int ret = 0;
 
 	pr_debug("%s: blocked: %d\n", __func__, blocked);
 
@@ -40,15 +41,16 @@ static int rfkill_regulator_set_block(void *data, bool blocked)
 		}
 	} else {
 		if (!rfkill_data->reg_enabled) {
-			regulator_enable(rfkill_data->vcc);
-			rfkill_data->reg_enabled = true;
+			ret = regulator_enable(rfkill_data->vcc);
+			if (!ret)
+				rfkill_data->reg_enabled = true;
 		}
 	}
 
 	pr_debug("%s: regulator_is_enabled after set_block: %d\n", __func__,
 		regulator_is_enabled(rfkill_data->vcc));
 
-	return 0;
+	return ret;
 }
 
 static struct rfkill_ops rfkill_regulator_ops = {
-- 
1.8.3.2
