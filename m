From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] ixgbe: reduce PTP rx path overhead
Date: Tue, 30 Oct 2012 00:04:25 -0700
Message-ID: <1351580670-8292-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5842 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755285Ab2J3HEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 03:04:36 -0400
In-Reply-To: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>

Hw timestamping code caused performance regression in ixgbe driver when the
timestamping is not enabled. The culprit is IXGBE_READ_REG call in the Rx
path which is executed for every received skb. This call is not needed when
the timestamping is disabled or for non-ptp packets.

netperf results:

The ixgbe side of the connection was acting as a server, the netperf command
line on the other side was:
netperf -H 192.168.1.23 -T0,0 -t UDP_STREAM -l 20

The values below mean throughput as reported by netperf (local/remote), for
3 runs, with timestamping not enabled.

3.7.0-rc1+ with CONFIG_IXGBE_PTP off:
5373.83 / 3329.32
5721.88 / 3033.89
5653.42 / 3112.38

3.7.0-rc1+ with CONFIG_IXGBE_PTP on:
5233.64 / 1226.85
5448.67 / 1039.32
5421.36 / 1095.66

Patched 3.7.0-rc1+ with CONFIG_IXGBE_PTP on:
5594.72 / 2942.53
5428.95 / 3110.16
5343.56 / 3200.48

Reported-by: Jesper Brouer <jbrouer@redhat.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
Signed-off-by: Andy Gospodarek <gospo@redhat.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 5e71ddb..842ba15 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -554,12 +554,14 @@ void ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
 	adapter = q_vector->adapter;
 	hw = &adapter->hw;
 
+	if (likely(!ixgbe_ptp_match(skb, adapter->rx_hwtstamp_filter)))
+		return;
+
 	tsyncrxctl = IXGBE_READ_REG(hw, IXGBE_TSYNCRXCTL);
 
 	/* Check if we have a valid timestamp and make sure the skb should
 	 * have been timestamped */
-	if (likely(!(tsyncrxctl & IXGBE_TSYNCRXCTL_VALID) ||
-		   !ixgbe_ptp_match(skb, adapter->rx_hwtstamp_filter)))
+	if (!(tsyncrxctl & IXGBE_TSYNCRXCTL_VALID))
 		return;
 
 	/*
-- 
1.7.11.7
