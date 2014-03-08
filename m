From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] e1000e: Fix ethtool offline tests for 82579 parts
Date: Sat,  8 Mar 2014 01:25:37 -0800
Message-ID: <1394270741-29926-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51114 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbaCHJZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:55 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Changes to the rar_entry_count value require a change to the indexing
used to access the SHRA[H|L] registers when testing them with
'ethtool -t <iface> offline'

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 7a47902..3c2898d 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -917,15 +917,21 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 		}
 		if (mac->type == e1000_pch2lan) {
 			/* SHRAH[0,1,2] different than previous */
-			if (i == 7)
+			if (i == 1)
 				mask &= 0xFFF4FFFF;
 			/* SHRAH[3] different than SHRAH[0,1,2] */
-			if (i == 10)
+			if (i == 4)
 				mask |= (1 << 30);
+			/* RAR[1-6] owned by management engine - skipping */
+			if (i > 0)
+				i += 6;
 		}
 
 		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1), mask,
 				       0xFFFFFFFF);
+		/* reset index to actual value */
+		if ((mac->type == e1000_pch2lan) && (i > 6))
+			i -= 6;
 	}
 
 	for (i = 0; i < mac->mta_reg_count; i++)
-- 
1.8.3.1
