From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 09/13] net/mlx5: E-Switch, Fix vport enable flow
Date: Fri, 10 Jun 2016 00:07:36 +0300
Message-ID: <1465506460-1854-10-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34461 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751118AbcFIVI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:58 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Reorder vport enable flow to mark the vport as enabled before calling
the vport change handler which was modified to handle the case for
when vport is not enabled.

This fixes the case for when the PF netdev is open before sriov is
enabled, once sriov is enabled at esw_enable_vport,
esw_vport_change_handle_locked didn't read the PF context since it
thought the PF vport was not enabled.

When we enable the vport, arming for events is not required anymore,
since it's done on the vport change handle

Fixes: 586cfa7f1d58 ('net/mlx5: E-Switch, Use vport event handler for vport cleanup')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index a350af2..cfec20c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1491,14 +1491,11 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 
 	/* Sync with current vport context */
 	vport->enabled_events = enable_events;
-	esw_vport_change_handle_locked(vport);
-
 	vport->enabled = true;
 
 	/* only PF is trusted by default */
 	vport->trusted = (vport_num) ? false : true;
-
-	arm_vport_context_events_cmd(esw->dev, vport_num, enable_events);
+	esw_vport_change_handle_locked(vport);
 
 	esw->enabled_vports++;
 	esw_debug(esw->dev, "Enabled VPORT(%d)\n", vport_num);
-- 
2.8.0
