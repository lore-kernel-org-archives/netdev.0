From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 5/9] sfc: Change falcon_probe_board() to fail for
 unsupported boards
Date: Fri, 23 Apr 2010 23:26:46 +0100
Message-ID: <1272061606.5520.18.camel@achroite.uk.solarflarecom.com>
References: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46280 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab0DWW0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:26:50 -0400
In-Reply-To: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver needs specific PHY and board support code for each SFC4000
board; there is no point trying to continue if it is missing.
Currently unsupported boards can trigger an 'oops'.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c        |    4 +++-
 drivers/net/sfc/falcon_boards.c |   13 +++----------
 drivers/net/sfc/nic.h           |    2 +-
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d294d66..08278e7 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1320,7 +1320,9 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 
 	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mdio.prtad);
 
-	falcon_probe_board(efx, board_rev);
+	rc = falcon_probe_board(efx, board_rev);
+	if (rc)
+		goto fail2;
 
 	kfree(nvconfig);
 	return 0;
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 5712fdd..c7a933a 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -728,15 +728,7 @@ static const struct falcon_board_type board_types[] = {
 	},
 };
 
-static const struct falcon_board_type falcon_dummy_board = {
-	.init		= efx_port_dummy_op_int,
-	.init_phy	= efx_port_dummy_op_void,
-	.fini		= efx_port_dummy_op_void,
-	.set_id_led	= efx_port_dummy_op_set_id_led,
-	.monitor	= efx_port_dummy_op_int,
-};
-
-void falcon_probe_board(struct efx_nic *efx, u16 revision_info)
+int falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 {
 	struct falcon_board *board = falcon_board(efx);
 	u8 type_id = FALCON_BOARD_TYPE(revision_info);
@@ -754,8 +746,9 @@ void falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 			 (efx->pci_dev->subsystem_vendor == EFX_VENDID_SFC)
 			 ? board->type->ref_model : board->type->gen_type,
 			 'A' + board->major, board->minor);
+		return 0;
 	} else {
 		EFX_ERR(efx, "unknown board type %d\n", type_id);
-		board->type = &falcon_dummy_board;
+		return -ENODEV;
 	}
 }
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 9351c03..3166baf 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -156,7 +156,7 @@ extern struct efx_nic_type siena_a0_nic_type;
  **************************************************************************
  */
 
-extern void falcon_probe_board(struct efx_nic *efx, u16 revision_info);
+extern int falcon_probe_board(struct efx_nic *efx, u16 revision_info);
 
 /* TX data path */
 extern int efx_nic_probe_tx(struct efx_tx_queue *tx_queue);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

