From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH v2 net-next 5/9] be2net: post full RXQ on interface enable
Date: Wed,  6 May 2015 05:30:36 -0400
Message-ID: <1430904640-31918-6-git-send-email-sathya.perla@avagotech.com>
References: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:51843 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752523AbbEFJmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:42:44 -0400
In-Reply-To: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@avagotech.com>

When an RXQ is created in be_open(), the driver currently posts only
64 buffers. This sometimes results in packet drops when there is a traffic
burst as soon as the interface is enabled.
This patch fixes this problem by posting the full RXQ on interface enable.

Signed-off-by: Suresh Reddy <Suresh.Reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b25c509..5611466 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3324,9 +3324,12 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 
 	memcpy(rss->rss_hkey, rss_key, RSS_HASH_KEY_LEN);
 
-	/* First time posting */
+	/* Post 1 less than RXQ-len to avoid head being equal to tail,
+	 * which is a queue empty condition
+	 */
 	for_all_rx_queues(adapter, rxo, i)
-		be_post_rx_frags(rxo, GFP_KERNEL, MAX_RX_POST);
+		be_post_rx_frags(rxo, GFP_KERNEL, RX_Q_LEN - 1);
+
 	return 0;
 }
 
-- 
2.2.0
