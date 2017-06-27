From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/14] nfp: handle SR-IOV already enabled when driver is probing
Date: Tue, 27 Jun 2017 00:50:25 -0700
Message-ID: <20170627075028.4009-12-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33126 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751819AbdF0HvP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:15 -0400
Received: by mail-pf0-f169.google.com with SMTP id e7so12632970pfk.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:15 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We assumed that when we probe number of enabled VFs will be at 0.
This doesn't have to be the case for example if previous driver left
SR-IOV enabled due to some VFs being assigned.  Read the number of VFs
enabled.  Fail probe if it's above current FWs limit.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 748e54cc885e..d47adb4c86d6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -414,6 +414,14 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_fw_unload;
 
+	pf->num_vfs = pci_num_vf(pdev);
+	if (pf->num_vfs > pf->limit_vfs) {
+		dev_err(&pdev->dev,
+			"Error: %d VFs already enabled, but loaded FW can only support %d\n",
+			pf->num_vfs, pf->limit_vfs);
+		goto err_fw_unload;
+	}
+
 	err = nfp_net_pci_probe(pf);
 	if (err)
 		goto err_sriov_unlimit;
-- 
2.11.0
