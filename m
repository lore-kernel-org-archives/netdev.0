From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40e: Check for new arq elements before leaving the adminq subtask loop
Date: Wed, 29 Mar 2017 03:12:06 -0700
Message-ID: <20170329101215.24513-5-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Christopher N Bednarz <christopher.n.bednarz@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21132 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755123AbdC2KMX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:23 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher N Bednarz <christopher.n.bednarz@intel.com>

Fix a case where we miss an arq element if a new one is added before we
enable interrupts and exit the arq subtask loop. This occurs frequently
with RDMA running on Windows VF and causes long delays that prevent SMB
from establishing connections.

Change-ID: I3e1c8b2b960c12857d9b8275bea2c1563674392e
Signed-off-by: Christopher N Bednarz <christopher.n.bednarz@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 96bedb54701c..cdf36713f4d1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6519,9 +6519,11 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 				 opcode);
 			break;
 		}
-	} while (pending && (i++ < pf->adminq_work_limit));
+	} while (i++ < pf->adminq_work_limit);
+
+	if (i < pf->adminq_work_limit)
+		clear_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state);
 
-	clear_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state);
 	/* re-enable Admin queue interrupt cause */
 	val = rd32(hw, I40E_PFINT_ICR0_ENA);
 	val |=  I40E_PFINT_ICR0_ENA_ADMINQ_MASK;
-- 
2.12.0
