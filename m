From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 2/6] fjes: fix incorrect statistics information in fjes_xmit_frame()
Date: Fri, 15 Apr 2016 11:25:27 +0900
Message-ID: <1460687127-26623-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: jiri@resnulli.us, isimatu.yasuaki@jp.fujitsu.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:55162 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbcDOCd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:33:58 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id C8446AC023F
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 11:33:51 +0900 (JST)
In-Reply-To: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
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
index 061b4af..05bdd8b 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -653,7 +653,7 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				&adapter->hw.ep_shm_info[dest_epid].rx, 0)) {
 			/* version is NOT 0 */
 			adapter->stats64.tx_carrier_errors += 1;
-			hw->ep_shm_info[my_epid].net_stats
+			hw->ep_shm_info[dest_epid].net_stats
 						.tx_carrier_errors += 1;
 
 			ret = NETDEV_TX_OK;
@@ -661,9 +661,9 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				&adapter->hw.ep_shm_info[dest_epid].rx,
 				netdev->mtu)) {
 			adapter->stats64.tx_dropped += 1;
-			hw->ep_shm_info[my_epid].net_stats.tx_dropped += 1;
+			hw->ep_shm_info[dest_epid].net_stats.tx_dropped += 1;
 			adapter->stats64.tx_errors += 1;
-			hw->ep_shm_info[my_epid].net_stats.tx_errors += 1;
+			hw->ep_shm_info[dest_epid].net_stats.tx_errors += 1;
 
 			ret = NETDEV_TX_OK;
 		} else if (vlan &&
@@ -694,10 +694,10 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
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
@@ -714,10 +714,10 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
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
