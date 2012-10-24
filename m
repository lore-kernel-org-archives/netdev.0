From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH] ixgbe: reduce PTP rx path overhead
Date: Wed, 24 Oct 2012 17:17:26 +0200
Message-ID: <1351091846-17677-1-git-send-email-jbenc@redhat.com>
Cc: e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Andy Gospodarek <gospo@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933816Ab2JXPSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 11:18:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hw timestamping code caused performance regression in ixgbe driver when the
timestamping is not enabled. The culprit is IXGBE_READ_REG call in the rx
path which is executed for every received skb. This call is not needed when
the timestamping is disabled or for non-ptp packets.

netperf results:

The ixge side of the connection was acting as a server, the netperf command
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
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

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
1.7.6.5
