From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] igb: fix timecompare_upate race condition
Date: Thu, 13 Oct 2011 23:21:27 -0700
Message-ID: <1318573288-18286-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8874 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504Ab1JNGVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 02:21:33 -0400
In-Reply-To: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch closes a possible race condition when timestamping using
the timecompare_update function as a method to detect clock skew of
the internal cycle counter. Because timecompare_update usually allows
skew detection no more than once a second, if ptpd or other software
performs a clock offset (for example, using the "date" command), there
is a small window of time where the clock skew will not match the
current kernel wall time. This patch forces the timecompare_update to
calculate skew every time we timestamp a packet, which removes the
possibility of this race condition.

Signed-off-by: Jacob E Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index c10cc71..8f3296d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5581,7 +5581,15 @@ static void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
 		regval <<= IGB_82580_TSYNC_SHIFT;
 
 	ns = timecounter_cyc2time(&adapter->clock, regval);
-	timecompare_update(&adapter->compare, ns);
+
+	/*
+	 * force timecompare_update to calculate the skew (even if
+	 * less than one second has passed since the last update) in
+	 * order to prevent the possibility that an offset has been
+	 * applied to the wall time. this ensures valid timestamps are
+	 * passed to the network stack.
+	 */
+	timecompare_update(&adapter->compare, 0);
 	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
 	shhwtstamps->hwtstamp = ns_to_ktime(ns);
 	shhwtstamps->syststamp = timecompare_transform(&adapter->compare, ns);
-- 
1.7.6.4
