From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 06/10] be2net: post full RXQ on interface enable
Date: Mon,  4 May 2015 02:47:18 -0400
Message-ID: <1430722042-26449-7-git-send-email-sathya.perla@emulex.com>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63199 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752219AbbEDG7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 02:59:41 -0400
In-Reply-To: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

When an RXQ is created in be_open(), the driver currently posts only
64 buffers. This sometimes results in packet drops when there is a traffic
burst as soon as the interface is enabled.
This patch fixes this problem by posting the full RXQ on interface enable.

Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 66749d0..f6a226e 100644
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
