From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: fix client notify of VF reset
Date: Mon,  2 Oct 2017 12:48:51 -0700
Message-ID: <20171002194852.71970-15-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23140 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751460AbdJBTtU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:20 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Currently there is a bug in which the PF driver fails to inform clients
of a VF reset which then causes clients to leak resources.  The bug
exists because we were incorrectly checking the I40E_VF_STATE_PRE_ENABLE
bit.

When a VF is first init we go through a reset to initialize variables
and allocate resources but we don't want to inform clients of this first
reset since the client isn't fully enabled yet so we set a state bit
signifying we're in a "pre-enabled" client state.  During the first
reset we should be clearing the bit, allowing all following resets to
notify the client of the reset when the bit is not set.  This patch
fixes the issue by negating the 'test_and_clear_bit' check to accurately
reflect the behavior we want.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 989a65d60ac9..04568137e029 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1050,8 +1050,8 @@ static void i40e_cleanup_reset_vf(struct i40e_vf *vf)
 		set_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states);
 		clear_bit(I40E_VF_STATE_DISABLED, &vf->vf_states);
 		/* Do not notify the client during VF init */
-		if (test_and_clear_bit(I40E_VF_STATE_PRE_ENABLE,
-				       &vf->vf_states))
+		if (!test_and_clear_bit(I40E_VF_STATE_PRE_ENABLE,
+					&vf->vf_states))
 			i40e_notify_client_of_vf_reset(pf, abs_vf_id);
 		vf->num_vlan = 0;
 	}
-- 
2.14.2
