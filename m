From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] igb: Make TSO check for CHECKSUM_PARTIAL to avoid skb_is_gso check
Date: Tue, 13 Nov 2012 06:03:22 -0800
Message-ID: <1352815405-751-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53320 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754792Ab2KMODc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:32 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to reduce the overhead for workloads that are not
using either TSO or checksum offloads.  Most of the time the compiler
should jump ahead after failing this check to the VLAN check since in the
igb_tx_csum call we start with that check as well.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index da9fd7b..b0730e9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3998,6 +3998,9 @@ static int igb_tso(struct igb_ring *tx_ring,
 	u32 vlan_macip_lens, type_tucmd;
 	u32 mss_l4len_idx, l4len;
 
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
 	if (!skb_is_gso(skb))
 		return 0;
 
-- 
1.7.11.7
