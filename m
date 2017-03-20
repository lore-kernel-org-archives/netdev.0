From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e: don't re-enable ATR when flushing filters if SB has TCP4/IPv4 rules
Date: Mon, 20 Mar 2017 16:47:09 -0700
Message-ID: <20170320234712.84157-11-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:49349 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932103AbdCTXrV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:21 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When flushing and replaying FDIR filters, it is possible we would
disable ATR, and then re-enable it even though we should have kept
it disabled due to existing TCP/IPv4 filters. Fix this by checking
whether we have TCP4/IPv4 filters before re-enabling.

Alternatively, we could instead restore ATR and then replay filters,
however, this would cause us to rapidly enable and then disable ATR in
some cases.

Change-ID: I076e4cc1e4409bce7f98f3c213295433a4ff43d8
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Avinash Dayanand <avinash.dayanand@intel.com>
Reviewed-by: Alan Brady <alan.brady@intel.com>
Reviewed-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 437b79eeb8b5..cc33ac835181 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6228,7 +6228,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 	} else {
 		/* replay sideband filters */
 		i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
-		if (!disable_atr)
+		if (!disable_atr && !pf->fd_tcp_rule)
 			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 		clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
 		if (I40E_DEBUG_FD & pf->hw.debug_mask)
-- 
2.12.0
