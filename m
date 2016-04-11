From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 07/11] fjes: fix incorrect statistics information in fjes_xmit_frame()
Date: Mon, 11 Apr 2016 17:10:34 +0900
Message-ID: <1460362234-15294-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym04.jp.fujitsu.com ([211.128.242.43]:19174 "EHLO
	mgwym04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbcDKIS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:18:57 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id BA77DAC0175
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:50 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are bugs of acounting statistics in fjes_xmit_frame().
Accounting self stats is wrong. accounting stats of other
EPs to be transmitted  is right.
This patch fixes this bug.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index f2327d8..e785d89 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -668,7 +668,7 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				&adapter->hw.ep_shm_info[dest_epid].rx, 0)) {
 			/* version is NOT 0 */
 			adapter->stats64.tx_carrier_errors += 1;
-			hw->ep_shm_info[my_epid].net_stats
+			hw->ep_shm_info[dest_epid].net_stats
 						.tx_carrier_errors += 1;
 			hw->ep_shm_info[dest_epid].ep_stats
 						  .tx_dropped_version_mismatch += 1;
@@ -678,9 +678,9 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				&adapter->hw.ep_shm_info[dest_epid].rx,
 				netdev->mtu)) {
 			adapter->stats64.tx_dropped += 1;
-			hw->ep_shm_info[my_epid].net_stats.tx_dropped += 1;
+			hw->ep_shm_info[dest_epid].net_stats.tx_dropped += 1;
 			adapter->stats64.tx_errors += 1;
-			hw->ep_shm_info[my_epid].net_stats.tx_errors += 1;
+			hw->ep_shm_info[dest_epid].net_stats.tx_errors += 1;
 			hw->ep_shm_info[dest_epid].ep_stats
 						  .tx_dropped_buffer_size_discrepancy += 1;
 
@@ -715,10 +715,10 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 					    (long)adapter->tx_start_jiffies) >=
 					    FJES_TX_RETRY_TIMEOUT) {
 					adapter->stats64.tx_fifo_errors += 1;
-					hw->ep_shm_info[my_epid].net_stats
+					hw->ep_shm_info[dest_epid].net_stats
 								.tx_fifo_errors += 1;
 					adapter->stats64.tx_errors += 1;
-					hw->ep_shm_info[my_epid].net_stats
+					hw->ep_shm_info[dest_epid].net_stats
 								.tx_errors += 1;
 
 					ret = NETDEV_TX_OK;
@@ -737,10 +737,10 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			} else {
 				if (!is_multi) {
 					adapter->stats64.tx_packets += 1;
-					hw->ep_shm_info[my_epid].net_stats
+					hw->ep_shm_info[dest_epid].net_stats
 								.tx_packets += 1;
 					adapter->stats64.tx_bytes += len;
-					hw->ep_shm_info[my_epid].net_stats
+					hw->ep_shm_info[dest_epid].net_stats
 								.tx_bytes += len;
 				}
 
-- 
2.4.3
