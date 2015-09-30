From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/17] i40e: fix 32 bit build warnings
Date: Wed, 30 Sep 2015 05:52:41 -0700
Message-ID: <1443617561-40490-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, kbuild-all@01.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8321 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932385AbbI3Mwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:51 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Sparse found some issues with 32 bit compilation, which probably should
at least work without warning.  Not only that, but the code was wrong.
Thanks sparse!!

And thanks to the kbuild robot zero day testing for finding this issue.

$ make ARCH=i386 M=drivers/net/ethernet/intel/i40e C=2 CF="-D__CHECK_ENDIAN__"
  CHECK   drivers/net/ethernet/intel/i40e/i40e_main.c
  include/linux/etherdevice.h:79:32: warning: restricted __be16 degrades to integer
  drivers/net/ethernet/intel/i40e/i40e_main.c:7565:17: warning: shift too big (32) for type unsigned long
  drivers/net/ethernet/intel/i40e/i40e_main.c:7565:17: warning: shift too big (42) for type unsigned long
  drivers/net/ethernet/intel/i40e/i40e_main.c:7565:17: warning: shift too big (39) for type unsigned long
  drivers/net/ethernet/intel/i40e/i40e_main.c:7565:17: warning: shift too big (40) for type unsigned long

CC: kbuild-all@01.org
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c |  5 -----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 12 ++++++------
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 80c354c..6833717 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -442,9 +442,6 @@ static i40e_status i40e_aq_get_set_rss_lut(struct i40e_hw *hw,
 					I40E_AQC_SET_RSS_LUT_TABLE_TYPE_SHIFT) &
 					I40E_AQC_SET_RSS_LUT_TABLE_TYPE_MASK));
 
-	cmd_resp->addr_high = cpu_to_le32(high_16_bits((u64)lut));
-	cmd_resp->addr_low = cpu_to_le32(lower_32_bits((u64)lut));
-
 	status = i40e_asq_send_command(hw, &desc, lut, lut_size, NULL);
 
 	return status;
@@ -519,8 +516,6 @@ static i40e_status i40e_aq_get_set_rss_key(struct i40e_hw *hw,
 					  I40E_AQC_SET_RSS_KEY_VSI_ID_SHIFT) &
 					  I40E_AQC_SET_RSS_KEY_VSI_ID_MASK));
 	cmd_resp->vsi_id |= cpu_to_le16((u16)I40E_AQC_SET_RSS_KEY_VSI_VALID);
-	cmd_resp->addr_high = cpu_to_le32(high_16_bits((u64)key));
-	cmd_resp->addr_low = cpu_to_le32(lower_32_bits((u64)key));
 
 	status = i40e_asq_send_command(hw, &desc, key, key_size, NULL);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index a3978c2..7c9975c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -79,12 +79,12 @@ enum i40e_dyn_idx_t {
 	BIT_ULL(I40E_FILTER_PCTYPE_L2_PAYLOAD))
 
 #define I40E_DEFAULT_RSS_HENA_EXPANDED (I40E_DEFAULT_RSS_HENA | \
-	BIT(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK) | \
-	BIT(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
-	BIT(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
-	BIT(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK) | \
-	BIT(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) | \
-	BIT(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP))
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) | \
+	BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP))
 
 #define i40e_pf_get_default_rss_hena(pf) \
 	(((pf)->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE) ? \
-- 
2.4.3
