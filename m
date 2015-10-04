From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] i40evf: don't blow away MAC address
Date: Sat,  3 Oct 2015 19:54:43 -0700
Message-ID: <1443927283-18456-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56975 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbbJDCyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 22:54:47 -0400
In-Reply-To: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Under certain circumstances, we can get an extra VF_RESOURCES message
from the PF driver at runtime. When this happens, we need to parse it
because our VSI may have changed out from underneath us, and that will
affect our relationship with the PF driver.

However, parsing the resources message also blows away our current MAC
address in the hardware struct, usually with all zeros. When this
happens, the next time the interface is opened, it will have no MAC
address and will a) not work and b) complain.

Fix this issue by restoring the current MAC address from the netdev
struct after we parse the resource message.

Change-ID: I6cd1b624fc20432f81dc901166c8de195b8e0e65
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index d4eb1a5..fbf2a1c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -756,6 +756,8 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 			  sizeof(struct i40e_virtchnl_vsi_resource);
 		memcpy(adapter->vf_res, msg, min(msglen, len));
 		i40e_vf_parse_hw_config(&adapter->hw, adapter->vf_res);
+		/* restore current mac address */
+		ether_addr_copy(adapter->hw.mac.addr, netdev->dev_addr);
 		i40evf_process_config(adapter);
 		}
 		break;
-- 
2.4.3
