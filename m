From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/15] i40evf: correctly program RSS HLUT table
Date: Tue, 18 Mar 2014 20:42:00 -0700
Message-ID: <1395200533-16908-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47331 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933727AbaCSDmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 23:42:16 -0400
In-Reply-To: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The HLUT programming loop in in i40evf_configure_rss was a) overly-
complicated, and b) just plain broken. Most of the entries ended up being
not written at all, so most of the flows ended up at queue zero.

Refactor the HLUT programming loop to simply walk through the registers
and write four values to each one, incrementing through the number of
available queues.

Change-ID: I75766179bc67e4e997187794f3144e28c83fd00d
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d62e27f..7cb0cda 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1414,6 +1414,7 @@ restart_watchdog:
 	schedule_work(&adapter->adminq_task);
 }
 
+#define NEXT_QUEUE(_j) (++_j >= adapter->vsi_res->num_queue_pairs ? _j = 0 : _j)
 /**
  * i40evf_configure_rss - Prepare for RSS if used
  * @adapter: board private structure
@@ -1444,15 +1445,13 @@ static void i40evf_configure_rss(struct i40evf_adapter *adapter)
 	wr32(hw, I40E_VFQF_HENA(1), (u32)(hena >> 32));
 
 	/* Populate the LUT with max no. of queues in round robin fashion */
-	for (i = 0, j = 0; i < I40E_VFQF_HLUT_MAX_INDEX; i++, j++) {
-		if (j == adapter->vsi_res->num_queue_pairs)
-			j = 0;
-		/* lut = 4-byte sliding window of 4 lut entries */
-		lut = (lut << 8) | (j &
-			 ((0x1 << 8) - 1));
-		/* On i = 3, we have 4 entries in lut; write to the register */
-		if ((i & 3) == 3)
-			wr32(hw, I40E_VFQF_HLUT(i >> 2), lut);
+	j = adapter->vsi_res->num_queue_pairs;
+	for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
+		lut = NEXT_QUEUE(j);
+		lut |= NEXT_QUEUE(j) << 8;
+		lut |= NEXT_QUEUE(j) << 16;
+		lut |= NEXT_QUEUE(j) << 24;
+		wr32(hw, I40E_VFQF_HLUT(i), lut);
 	}
 	i40e_flush(hw);
 }
-- 
1.8.3.1
