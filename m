From: Cliff Spradlin <cspradlin@google.com>
Subject: [PATCH net] igb: protect TX timestamping from API misuse
Date: Fri, 16 Jun 2017 15:37:17 -0700
Message-ID: <20170616223717.66179-1-cspradlin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f74.google.com ([74.125.83.74]:36867 "EHLO
        mail-pg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbdFPWhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 18:37:21 -0400
Received: by mail-pg0-f74.google.com with SMTP id j186so455137pge.4
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 15:37:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW timestamping can only be requested for a packet if the NIC is first
setup via ioctl(SIOCSHWTSTAMP). If this step was skipped, then the igb
driver still allowed TX packets to request HW timestamping. In this
situation, the _IGB_PTP_TX_IN_PROGRESS flag was set and would never
clear. This prevented any future HW timestamping requests to succeed.

Fix this by checking that the NIC is configured for HW TX timestamping
before accepting a HW TX timestamping request.

Signed-off-by: Cliff Spradlin <cspradlin@google.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1cf74aa4ebd9..45c2a9c9fa03 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5381,7 +5381,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 
-		if (!test_and_set_bit_lock(__IGB_PTP_TX_IN_PROGRESS,
+		if (adapter->tstamp_config.tx_type & HWTSTAMP_TX_ON &&
+		    !test_and_set_bit_lock(__IGB_PTP_TX_IN_PROGRESS,
 					   &adapter->state)) {
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= IGB_TX_FLAGS_TSTAMP;
-- 
2.13.1.518.g3df882009-goog
