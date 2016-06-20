From: Maxim Altshul <maxim.altshul@ti.com>
Subject: [PATCH 3/3] mac80211: mesh: Add support for HW RC implementation
Date: Mon, 20 Jun 2016 16:00:22 +0300
Message-ID: <1466427622-5953-4-git-send-email-maxim.altshul@ti.com>
References: <1466427622-5953-1-git-send-email-maxim.altshul@ti.com>
 <1466427622-5953-2-git-send-email-maxim.altshul@ti.com>
 <1466427622-5953-3-git-send-email-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eliad@wizery.com>, <yanivma@ti.com>, <guym@ti.com>,
	<arik@wizery.com>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	Maxim Altshul <maxim.altshul@ti.com>
To: <johannes@sipsolutions.net>, <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:40483 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbcFTNAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 09:00:03 -0400
In-Reply-To: <1466427622-5953-3-git-send-email-maxim.altshul@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mesh HWMP module will be able to rely on the HW
RC algorithm if it exists, for path metric calculations.

This allows the metric calculation mechanism to calculate
a correct metric, based on PER and last TX rate both via
HW RC algorithm if it exists or via parameters collected
by the SW.

Signed-off-by: Maxim Altshul <maxim.altshul@ti.com>
---
 net/mac80211/mesh_hwmp.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index c6be0b4..e3ce40d 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -12,6 +12,7 @@
 #include <asm/unaligned.h>
 #include "wme.h"
 #include "mesh.h"
+#include "driver-ops.h"
 
 #define TEST_FRAME_LEN	8192
 #define MAX_METRIC	0xffffffff
@@ -322,19 +323,25 @@ static u32 airtime_link_metric_get(struct ieee80211_local *local,
 	int device_constant = 1 << ARITH_SHIFT;
 	int test_frame_len = TEST_FRAME_LEN << ARITH_SHIFT;
 	int s_unit = 1 << ARITH_SHIFT;
-	int rate, err;
+	int rate, err = 0;
 	u32 tx_time, estimated_retx;
 	u64 result;
 
-	if (sta->mesh->fail_avg >= 100)
-		return MAX_METRIC;
+	/* try to get rate based on HW RC algorithm */
+	rate = drv_get_expected_throughput(local, &sta->sta);
 
-	sta_set_rate_info_tx(sta, &sta->tx_stats.last_rate, &rinfo);
-	rate = cfg80211_calculate_bitrate(&rinfo);
-	if (WARN_ON(!rate))
-		return MAX_METRIC;
+	/* if HW does not provide us with a rate */
+	if (!rate) {
+		if (sta->mesh->fail_avg >= 100)
+			return MAX_METRIC;
 
-	err = (sta->mesh->fail_avg << ARITH_SHIFT) / 100;
+		sta_set_rate_info_tx(sta, &sta->tx_stats.last_rate, &rinfo);
+		rate = cfg80211_calculate_bitrate(&rinfo);
+		if (WARN_ON(!rate))
+			return MAX_METRIC;
+
+		err = (sta->mesh->fail_avg << ARITH_SHIFT) / 100;
+	}
 
 	/* bitrate is in units of 100 Kbps, while we need rate in units of
 	 * 1Mbps. This will be corrected on tx_time computation.
-- 
2.7.2
