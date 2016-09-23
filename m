From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next v2 2/2] i40e: fix setting debug parameter early
Date: Fri, 23 Sep 2016 15:30:58 +0200
Message-ID: <1474637458-5255-3-git-send-email-sassmann@kpanic.de>
References: <1474637458-5255-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, carolyn.wyborny@intel.com,
        sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965854AbcIWNbW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 09:31:22 -0400
In-Reply-To: <1474637458-5255-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pf->msg_enable is a bitmask, therefore assigning the value of the
"debug" parameter is wrong. It is initialized again later in
i40e_sw_init() so it didn't cause any problem, except that we missed
early debug messages. Moved the initialization and assigned
pf->hw.debug_mask the bitmask as that's what the driver actually uses
in i40e_debug(). Otherwise the debug parameter is just a noop.

Fixes: 5b5faa4 ("i40e: enable debug earlier")

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 56369761..f972f0d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8498,11 +8498,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	int err = 0;
 	int size;
 
-	pf->msg_enable = netif_msg_init(debug,
-					NETIF_MSG_DRV    |
-					NETIF_MSG_PROBE  |
-					NETIF_MSG_LINK);
-
 	/* Set default capability flags */
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
 		    I40E_FLAG_MSI_ENABLED     |
@@ -10812,10 +10807,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	mutex_init(&hw->aq.asq_mutex);
 	mutex_init(&hw->aq.arq_mutex);
 
-	if (debug != -1) {
-		pf->msg_enable = pf->hw.debug_mask;
-		pf->msg_enable = debug;
-	}
+	/* enable debug prints if requested */
+	pf->msg_enable = netif_msg_init(debug,
+					NETIF_MSG_DRV   |
+					NETIF_MSG_PROBE |
+					NETIF_MSG_LINK);
+	if (debug != -1)
+		pf->hw.debug_mask = pf->msg_enable;
 
 	/* do a special CORER for clearing PXE mode once at init */
 	if (hw->revision_id == 0 &&
-- 
2.7.4
