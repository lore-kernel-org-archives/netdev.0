From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/14] nfp: explicitly check if application FW is loaded
Date: Tue, 27 Jun 2017 00:50:15 -0700
Message-ID: <20170627075028.4009-2-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35929 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751659AbdF0HvH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:07 -0400
Received: by mail-pf0-f172.google.com with SMTP id q86so12572547pfl.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:07 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We support application FW being either loaded automatically at
boot from flash or (more commonly) by the driver from disk.
If FW is not found on disk and nothing is preloaded users are
faced with this unintuitive error:

nfp 0000:04:00.0: nfp: Failed to find PF symbol _pf0_net_bar0

We can do better.  Since we rely on symbol table being present -
check early if it could be correctly read out of from the device
and if not print a more informative message.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index cfcbc3b9a9aa..3169400dd474 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -589,10 +589,7 @@ static int nfp_net_pci_map_mem(struct nfp_pf *pf)
 				   ctrl_bar_sz, &pf->data_vnic_bar);
 	if (IS_ERR(mem)) {
 		nfp_err(pf->cpp, "Failed to find data vNIC memory symbol\n");
-		err = PTR_ERR(mem);
-		if (!pf->fw_loaded && err == -ENOENT)
-			err = -EPROBE_DEFER;
-		return err;
+		return PTR_ERR(mem);
 	}
 
 	pf->mac_stats_mem = nfp_net_pf_map_rtsym(pf, "net.macstats",
@@ -786,6 +783,12 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 		return -EINVAL;
 	}
 
+	if (!pf->rtbl) {
+		nfp_err(pf->cpp, "No %s, giving up.\n",
+			pf->fw_loaded ? "symbol table" : "firmware found");
+		return -EPROBE_DEFER;
+	}
+
 	mutex_lock(&pf->lock);
 	pf->max_data_vnics = nfp_net_pf_get_num_ports(pf);
 	if ((int)pf->max_data_vnics < 0) {
-- 
2.11.0
