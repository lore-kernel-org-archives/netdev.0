From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: Properly maintain flow director filters list
Date: Fri,  6 Oct 2017 10:57:22 -0700
Message-ID: <20171006175727.868-11-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Filip Sadowski <filip.sadowski@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56459 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752536AbdJFR5v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:51 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Filip Sadowski <filip.sadowski@intel.com>

When there is no space for more flow director filters and user requested to
add a new one it is rejected by firmware and automatically removed from the
filter list maintained by driver. This behaviour is correct. Afterwards
existing filter can be removed making free slot for the new one. This
however causes the newly added filter to be accepted by firmware but
removed from driver filter list resulting in not showing after issuing
'ethtool -n <dev_name>'.

This happened due to not clearing the variable pf->fd_inv which stores
filter number to be removed from the list when firmware refused to add the
requested filter. It caused the filter with this specific ID to be
constantly removed once it was added to the list although it has been
accepted by firmware and effectively applied to the NIC.
It was fixed by clearing pf->fd_inv variable after removal of the filter
from the list when it was rejected by firmware.

Signed-off-by: Filip Sadowski <filip.sadowski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3d6d6a283327..9704cfef2f05 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6232,6 +6232,7 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 				hlist_del(&filter->fdir_node);
 				kfree(filter);
 				pf->fdir_pf_active_filters--;
+				pf->fd_inv = 0;
 			}
 		}
 	}
-- 
2.14.2
