From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: Fix a bug in ethtool for FD drop packet filter action
Date: Wed, 11 Jun 2014 09:33:22 -0700
Message-ID: <1402504404-8954-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55587 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932460AbaFKQdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:35 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

A drop action comes down as a ring_cookie value, so allow it as
a special value that can be used to configure destination control.

Also fix the output to filter read command accordingly.

Change-ID: I9956723cee42f3194885403317dd21ed4a151144
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index e330166..4a488ff 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1259,7 +1259,11 @@ static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
 	fsp->h_u.tcp_ip4_spec.pdst = rule->src_port;
 	fsp->h_u.tcp_ip4_spec.ip4src = rule->dst_ip[0];
 	fsp->h_u.tcp_ip4_spec.ip4dst = rule->src_ip[0];
-	fsp->ring_cookie = rule->q_index;
+
+	if (rule->dest_ctl == I40E_FILTER_PROGRAM_DESC_DEST_DROP_PACKET)
+		fsp->ring_cookie = RX_CLS_FLOW_DISC;
+	else
+		fsp->ring_cookie = rule->q_index;
 
 	return 0;
 }
@@ -1563,7 +1567,8 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 		return -EINVAL;
 	}
 
-	if (fsp->ring_cookie >= vsi->num_queue_pairs)
+	if ((fsp->ring_cookie != RX_CLS_FLOW_DISC) &&
+	    (fsp->ring_cookie >= vsi->num_queue_pairs))
 		return -EINVAL;
 
 	input = kzalloc(sizeof(*input), GFP_KERNEL);
-- 
1.9.3
