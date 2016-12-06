From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH RFC v1 1/2] rxclass: use ethtool_get_flow_spec_ring to display queue and VF
Date: Tue,  6 Dec 2016 04:40:30 -0800
Message-ID: <20161206124031.32346-2-jacob.e.keller@intel.com>
References: <20161206124031.32346-1-jacob.e.keller@intel.com>
Cc: netdev@vger.kernel.org, Jacob Keller <jacob.e.keller@intel.com>
To: "John W . Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18386 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752183AbcLFMkh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 07:40:37 -0500
In-Reply-To: <20161206124031.32346-1-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent kernels have made the ring_cookie store both the Queue index as
well as a VF identifier. This allows for drivers to direct traffic to
specific VF queues, without having the user have to understand the
physical queue layout. Add support to display this notation so that
users do not have to manually parse the value.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 rxclass.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/rxclass.c b/rxclass.c
index c7bfebaf6e22..7f0e765d3b47 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -247,11 +247,19 @@ static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 
 	rxclass_print_nfc_spec_ext(fsp);
 
-	if (fsp->ring_cookie != RX_CLS_FLOW_DISC)
-		fprintf(stdout, "\tAction: Direct to queue %llu\n",
-			fsp->ring_cookie);
-	else
+	if (fsp->ring_cookie != RX_CLS_FLOW_DISC) {
+		u64 vf = ethtool_get_flow_spec_ring_vf(fsp->ring_cookie);
+		u64 queue = ethtool_get_flow_spec_ring(fsp->ring_cookie);
+
+		if (vf)
+			fprintf(stdout, "\tAction: Direct to queue %llu\n",
+				queue);
+		else
+			fprintf(stdout, "\tAction: Direct to VF %llu queue %llu\n",
+				vf, queue);
+	} else {
 		fprintf(stdout, "\tAction: Drop\n");
+	}
 
 	fprintf(stdout, "\n");
 }
-- 
2.11.0.rc2.152.g4d04e67
