From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 01/13] qla3xxx: Return proper error codes when the 4022/4032 is being probed
Date: Mon, 26 Feb 2007 11:06:31 -0800
Message-ID: <11725168032993-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933801AbXBZTHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:42 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Li <benjamin.li@qlogic.com>

The return code was not properly set when when allocating memory or mapping
memory failed.  Depending on the stack, the return code would sometimes
return 0, which indicates everything was ok, when in fact there was an error.
  This would cause trouble when the module was removed.  Now, we will pass
back the proper return code when an error occurs during the PCI probe.

Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 2429b27..d1c90ca 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3609,8 +3609,12 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	}
 
 	ndev = alloc_etherdev(sizeof(struct ql3_adapter));
-	if (!ndev)
+	if (!ndev) {
+		printk(KERN_ERR PFX "%s could not alloc etherdev\n",
+		       pci_name(pdev));
+		err = -ENOMEM;
 		goto err_out_free_regions;
+	}
 
 	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
@@ -3639,6 +3643,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	if (!qdev->mem_map_registers) {
 		printk(KERN_ERR PFX "%s: cannot map device registers\n",
 		       pci_name(pdev));
+		err = -EIO;
 		goto err_out_free_ndev;
 	}
 
@@ -3667,6 +3672,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 		printk(KERN_ALERT PFX
 		       "ql3xxx_probe: Adapter #%d, Invalid NVRAM parameters.\n",
 		       qdev->index);
+		err = -EIO;
 		goto err_out_iounmap;
 	}
 
-- 
1.5.0.rc4.16.g9e258

