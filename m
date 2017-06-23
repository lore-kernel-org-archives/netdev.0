From: <netanel@amazon.com>
Subject: [PATCH V2 net-next 10/11] net: ena: update driver's rx drop statistics
Date: Fri, 23 Jun 2017 11:21:59 +0300
Message-ID: <1498206120-13805-11-git-send-email-netanel@amazon.com>
References: <1498206120-13805-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:32666 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754052AbdFWIXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 04:23:17 -0400
In-Reply-To: <1498206120-13805-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

rx drop counter is reported by the device in the keep-alive
event.
update the driver's counter with the device counter.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 7dee448157bb..f7dc22f65d9f 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -3478,8 +3478,17 @@ static void ena_keep_alive_wd(void *adapter_data,
 			      struct ena_admin_aenq_entry *aenq_e)
 {
 	struct ena_adapter *adapter = (struct ena_adapter *)adapter_data;
+	struct ena_admin_aenq_keep_alive_desc *desc;
+	u64 rx_drops;
 
+	desc = (struct ena_admin_aenq_keep_alive_desc *)aenq_e;
 	adapter->last_keep_alive_jiffies = jiffies;
+
+	rx_drops = ((u64)desc->rx_drops_high << 32) | desc->rx_drops_low;
+
+	u64_stats_update_begin(&adapter->syncp);
+	adapter->dev_stats.rx_drops = rx_drops;
+	u64_stats_update_end(&adapter->syncp);
 }
 
 static void ena_notification(void *adapter_data,
-- 
2.7.4
