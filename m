From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/3] nfp: wait for board state before talking to the NSP
Date: Wed, 13 Sep 2017 08:51:30 -0700
Message-ID: <20170913155131.18090-3-jakub.kicinski@netronome.com>
References: <20170913155131.18090-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:46461 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdIMPvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 11:51:45 -0400
Received: by mail-pg0-f43.google.com with SMTP id i130so1137788pgc.3
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 08:51:44 -0700 (PDT)
In-Reply-To: <20170913155131.18090-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Board state informs us which low-level initialization stages the card
has completed.  We should wait for the card to be fully initialized
before trying to communicate with it, not only before we configure
passing traffic.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c     | 43 +++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 23 ------------
 2 files changed, 43 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index f055b1774d65..424707d41fbd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -74,6 +74,45 @@ static const struct pci_device_id nfp_pci_device_ids[] = {
 };
 MODULE_DEVICE_TABLE(pci, nfp_pci_device_ids);
 
+static bool nfp_board_ready(struct nfp_pf *pf)
+{
+	const char *cp;
+	long state;
+	int err;
+
+	cp = nfp_hwinfo_lookup(pf->hwinfo, "board.state");
+	if (!cp)
+		return false;
+
+	err = kstrtol(cp, 0, &state);
+	if (err < 0)
+		return false;
+
+	return state == 15;
+}
+
+static int nfp_pf_board_state_wait(struct nfp_pf *pf)
+{
+	const unsigned long wait_until = jiffies + 10 * HZ;
+
+	while (!nfp_board_ready(pf)) {
+		if (time_is_before_eq_jiffies(wait_until)) {
+			nfp_err(pf->cpp, "NFP board initialization timeout\n");
+			return -EINVAL;
+		}
+
+		nfp_info(pf->cpp, "waiting for board initialization\n");
+		if (msleep_interruptible(500))
+			return -ERESTARTSYS;
+
+		/* Refresh cached information */
+		kfree(pf->hwinfo);
+		pf->hwinfo = nfp_hwinfo_read(pf->cpp);
+	}
+
+	return 0;
+}
+
 static int nfp_pcie_sriov_read_nfd_limit(struct nfp_pf *pf)
 {
 	int err;
@@ -425,6 +464,10 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 		 nfp_hwinfo_lookup(pf->hwinfo, "assembly.revision"),
 		 nfp_hwinfo_lookup(pf->hwinfo, "cpld.version"));
 
+	err = nfp_pf_board_state_wait(pf);
+	if (err)
+		goto err_hwinfo_free;
+
 	err = devlink_register(devlink, &pdev->dev);
 	if (err)
 		goto err_hwinfo_free;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 5abb9ba31e7d..ff373acd28f3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -64,23 +64,6 @@
 
 #define NFP_PF_CSR_SLICE_SIZE	(32 * 1024)
 
-static int nfp_is_ready(struct nfp_pf *pf)
-{
-	const char *cp;
-	long state;
-	int err;
-
-	cp = nfp_hwinfo_lookup(pf->hwinfo, "board.state");
-	if (!cp)
-		return 0;
-
-	err = kstrtol(cp, 0, &state);
-	if (err < 0)
-		return 0;
-
-	return state == 15;
-}
-
 /**
  * nfp_net_get_mac_addr() - Get the MAC address.
  * @pf:       NFP PF handle
@@ -725,12 +708,6 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 
 	INIT_WORK(&pf->port_refresh_work, nfp_net_refresh_vnics);
 
-	/* Verify that the board has completed initialization */
-	if (!nfp_is_ready(pf)) {
-		nfp_err(pf->cpp, "NFP is not ready for NIC operation.\n");
-		return -EINVAL;
-	}
-
 	if (!pf->rtbl) {
 		nfp_err(pf->cpp, "No %s, giving up.\n",
 			pf->fw_loaded ? "symbol table" : "firmware found");
-- 
2.14.1
