From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: Change the notion of src and dst for FD_SB in ethtool
Date: Wed, 11 Jun 2014 09:33:14 -0700
Message-ID: <1402504404-8954-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12138 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932460AbaFKQd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:29 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

In XL710 devices we program FD filter's fields from Tx perspective of the flow.
However the user interface exposed in ethtool should be compliant with the
previous generation of drivers where a filter src and dst field are from
the RX perspective. This patch changes the ethtool interface in this regard
to match the other drivers.

Change-ID: Iec6ccddd87357c4fb53ccf33aa0fae699faf70cf
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 23 +++++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2af28fd..fc1bd10 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -159,6 +159,7 @@ struct i40e_fdir_filter {
 	/* filter ipnut set */
 	u8 flow_type;
 	u8 ip4_proto;
+	/* TX packet view of src and dst */
 	__be32 dst_ip[4];
 	__be32 src_ip[4];
 	__be16 src_port;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b16c251..c771863 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1249,10 +1249,13 @@ static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
 		fsp->m_u.usr_ip4_spec.proto = 0;
 	}
 
-	fsp->h_u.tcp_ip4_spec.psrc = rule->src_port;
-	fsp->h_u.tcp_ip4_spec.pdst = rule->dst_port;
-	fsp->h_u.tcp_ip4_spec.ip4src = rule->src_ip[0];
-	fsp->h_u.tcp_ip4_spec.ip4dst = rule->dst_ip[0];
+	/* Reverse the src and dest notion, since the HW views them from
+	 * Tx perspective where as the user expects it from Rx filter view.
+	 */
+	fsp->h_u.tcp_ip4_spec.psrc = rule->dst_port;
+	fsp->h_u.tcp_ip4_spec.pdst = rule->src_port;
+	fsp->h_u.tcp_ip4_spec.ip4src = rule->dst_ip[0];
+	fsp->h_u.tcp_ip4_spec.ip4dst = rule->src_ip[0];
 	fsp->ring_cookie = rule->q_index;
 
 	return 0;
@@ -1581,10 +1584,14 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	input->cnt_index = 0;
 	input->flow_type = fsp->flow_type;
 	input->ip4_proto = fsp->h_u.usr_ip4_spec.proto;
-	input->src_port = fsp->h_u.tcp_ip4_spec.psrc;
-	input->dst_port = fsp->h_u.tcp_ip4_spec.pdst;
-	input->src_ip[0] = fsp->h_u.tcp_ip4_spec.ip4src;
-	input->dst_ip[0] = fsp->h_u.tcp_ip4_spec.ip4dst;
+
+	/* Reverse the src and dest notion, since the HW expects them to be from
+	 * Tx perspective where as the input from user is from Rx filter view.
+	 */
+	input->dst_port = fsp->h_u.tcp_ip4_spec.psrc;
+	input->src_port = fsp->h_u.tcp_ip4_spec.pdst;
+	input->dst_ip[0] = fsp->h_u.tcp_ip4_spec.ip4src;
+	input->src_ip[0] = fsp->h_u.tcp_ip4_spec.ip4dst;
 
 	ret = i40e_add_del_fdir(vsi, input, true);
 	if (ret)
-- 
1.9.3
