From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] bnx2x: off by one in bnx2x_ets_e3b0_sp_pri_to_cos_set()
Date: Wed, 18 Apr 2012 09:53:42 +0300
Message-ID: <20120418065342.GC12831@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:30627 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab2DRGxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 02:53:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sp_pri_to_cos[] array size depends on the config but lets say it is
BX_E3B0_MAX_NUM_COS_PORT0 and max_num_of_cos is also
DCBX_E3B0_MAX_NUM_COS_PORT0.  In the original code
"pri == max_num_of_cos" was accepted but it is one past the end of the
array.

Also we used "pri" before capping it.  It's a harmless read past the end
of the array, but it would affect which error message gets printed.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index ff882a4..6b21b21 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -922,6 +922,12 @@ static int bnx2x_ets_e3b0_sp_pri_to_cos_set(const struct link_params *params,
 	const u8 max_num_of_cos = (port) ? DCBX_E3B0_MAX_NUM_COS_PORT1 :
 		DCBX_E3B0_MAX_NUM_COS_PORT0;
 
+	if (pri >= max_num_of_cos) {
+		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_sp_pri_to_cos_set invalid "
+		   "parameter Illegal strict priority\n");
+	    return -EINVAL;
+	}
+
 	if (sp_pri_to_cos[pri] != DCBX_INVALID_COS) {
 		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_sp_pri_to_cos_set invalid "
 				   "parameter There can't be two COS's with "
@@ -929,12 +935,6 @@ static int bnx2x_ets_e3b0_sp_pri_to_cos_set(const struct link_params *params,
 		return -EINVAL;
 	}
 
-	if (pri > max_num_of_cos) {
-		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_sp_pri_to_cos_set invalid "
-		   "parameter Illegal strict priority\n");
-	    return -EINVAL;
-	}
-
 	sp_pri_to_cos[pri] = cos_entry;
 	return 0;
 
