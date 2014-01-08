From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/15] i40e: correctly setup ARQ descriptors
Date: Tue,  7 Jan 2014 22:07:36 -0800
Message-ID: <1389161256-24599-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62026 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755192AbaAHGIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:08:50 -0500
In-Reply-To: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When cleaning descriptors, we must set up ALL fields, not just the DMA
address. The initial setup does this correctly, but not the cleanup
code, so the firmware would process the ring exactly once and then fail.

Change-ID: I2930b83c76194b3016a8ac0fa693f9a573995640
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index c87dc15..2b32084 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -933,6 +933,11 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	 * size
 	 */
 	bi = &hw->aq.arq.r.arq_bi[ntc];
+	memset((void *)desc, 0, sizeof(struct i40e_aq_desc));
+
+	desc->flags = cpu_to_le16(I40E_AQ_FLAG_BUF);
+	if (hw->aq.arq_buf_size > I40E_AQ_LARGE_BUF)
+		desc->flags |= cpu_to_le16(I40E_AQ_FLAG_LB);
 	desc->datalen = cpu_to_le16((u16)bi->size);
 	desc->params.external.addr_high = cpu_to_le32(upper_32_bits(bi->pa));
 	desc->params.external.addr_low = cpu_to_le32(lower_32_bits(bi->pa));
-- 
1.8.3.1
