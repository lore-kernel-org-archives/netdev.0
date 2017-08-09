From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] igb: protect TX timestamping from API misuse
Date: Wed,  9 Aug 2017 14:47:36 -0700
Message-ID: <20170809214746.28139-3-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Cliff Spradlin <cspradlin@google.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:44498 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752274AbdHIVr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:56 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cliff Spradlin <cspradlin@google.com>

HW timestamping can only be requested for a packet if the NIC is first
setup via ioctl(SIOCSHWTSTAMP). If this step was skipped, then the igb
driver still allowed TX packets to request HW timestamping. In this
situation, the _IGB_PTP_TX_IN_PROGRESS flag was set and would never
clear. This prevented any future HW timestamping requests to succeed.

Fix this by checking that the NIC is configured for HW TX timestamping
before accepting a HW TX timestamping request.

Signed-off-by: Cliff Spradlin <cspradlin@google.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a63ea564a57..5d0a75c1ba0c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5380,7 +5380,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 
-		if (!test_and_set_bit_lock(__IGB_PTP_TX_IN_PROGRESS,
+		if (adapter->tstamp_config.tx_type & HWTSTAMP_TX_ON &&
+		    !test_and_set_bit_lock(__IGB_PTP_TX_IN_PROGRESS,
 					   &adapter->state)) {
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= IGB_TX_FLAGS_TSTAMP;
-- 
2.13.3
