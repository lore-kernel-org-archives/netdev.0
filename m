From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Fri,  6 Dec 2013 18:17:18 -0800
Message-ID: <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21213 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758203Ab3LGCRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:30 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

RSS can steer packets based on recognition of all
sorts of different headers.  Enable some more of them.

Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 38 ++++++++++++++++++-----------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 273db99..40c64c4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5615,15 +5615,34 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
  **/
 static int i40e_config_rss(struct i40e_pf *pf)
 {
-	struct i40e_hw *hw = &pf->hw;
-	u32 lut = 0;
-	int i, j;
-	u64 hena;
+	const u64 default_hena =
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_SCTP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_SCTP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6) |
+			((u64)1 << I40E_FILTER_PCTYPE_L2_PAYLOAD);
+
 	/* Set of random keys generated using kernel random number generator */
 	static const u32 seed[I40E_PFQF_HKEY_MAX_INDEX + 1] = {0x41b01687,
 				0x183cfd8c, 0xce880440, 0x580cbc3c, 0x35897377,
 				0x328b25e1, 0x4fa98922, 0xb7d90c14, 0xd5bad70d,
 				0xcd15a2c1, 0xe8580225, 0x4a1e9d11, 0xfe5731be};
+	struct i40e_hw *hw = &pf->hw;
+	u32 lut = 0;
+	int i, j;
+	u64 hena;
 
 	/* Fill out hash function seed */
 	for (i = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++)
@@ -5632,16 +5651,7 @@ static int i40e_config_rss(struct i40e_pf *pf)
 	/* By default we enable TCP/UDP with IPv4/IPv6 ptypes */
 	hena = (u64)rd32(hw, I40E_PFQF_HENA(0)) |
 		((u64)rd32(hw, I40E_PFQF_HENA(1)) << 32);
-	hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
-		((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
-		((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
-		((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP) |
-		((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP) |
-		((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
-		((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
-		((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
-		((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4)|
-		((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6);
+	hena |= default_hena;
 	wr32(hw, I40E_PFQF_HENA(0), (u32)hena);
 	wr32(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
 
-- 
1.8.3.1
