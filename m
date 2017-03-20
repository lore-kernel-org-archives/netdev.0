From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e: exit ATR mode only when adding TCP/IPv4 filter succeeds
Date: Mon, 20 Mar 2017 16:47:06 -0700
Message-ID: <20170320234712.84157-8-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:49349 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755925AbdCTXrU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:20 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Move ATR exit check after we have sent the TCP/IPv4 filter to the ring
successfully. This avoids an issue where we potentially update the
filter count without actually succeeding in adding the filter. Now, we
only increment the fd_tcp_rule after we've succeeded. Additionally, we
will re-enable ATR mode only after deletion of the filter is actually
posted to the FDIR ring.

Change-ID: If5c1dea422081cc5e2de65618b01b4c3bf6bd586
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 34 ++++++++++++++---------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 005257b4f218..05f3d0d5a004 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -284,23 +284,6 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	ip->saddr = fd_data->src_ip;
 	tcp->source = fd_data->src_port;
 
-	if (add) {
-		pf->fd_tcp_rule++;
-		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
-		    I40E_DEBUG_FD & pf->hw.debug_mask)
-			dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 flow being applied\n");
-		pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
-	} else {
-		pf->fd_tcp_rule = (pf->fd_tcp_rule > 0) ?
-				  (pf->fd_tcp_rule - 1) : 0;
-		if (pf->fd_tcp_rule == 0) {
-			if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
-			    I40E_DEBUG_FD & pf->hw.debug_mask)
-				dev_info(&pf->pdev->dev, "ATR re-enabled due to no sideband TCP/IPv4 rules\n");
-			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
-		}
-	}
-
 	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
 	ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
 	if (ret) {
@@ -320,6 +303,23 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 				 fd_data->pctype, fd_data->fd_id);
 	}
 
+	if (add) {
+		pf->fd_tcp_rule++;
+		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
+		    I40E_DEBUG_FD & pf->hw.debug_mask)
+			dev_info(&pf->pdev->dev, "Forcing ATR off, sideband rules for TCP/IPv4 flow being applied\n");
+		pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
+	} else {
+		pf->fd_tcp_rule = (pf->fd_tcp_rule > 0) ?
+				  (pf->fd_tcp_rule - 1) : 0;
+		if (pf->fd_tcp_rule == 0) {
+			if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
+			    I40E_DEBUG_FD & pf->hw.debug_mask)
+				dev_info(&pf->pdev->dev, "ATR re-enabled due to no sideband TCP/IPv4 rules\n");
+			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+		}
+	}
+
 	return 0;
 }
 
-- 
2.12.0
