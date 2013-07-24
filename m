From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 2/2] net/tg3: Fix warning from pci_disable_device()
Date: Wed, 24 Jul 2013 17:25:09 +0800
Message-ID: <1374657909-26929-2-git-send-email-shangw@linux.vnet.ibm.com>
References: <1374657909-26929-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: nsujir@broadcom.com, mchan@broadcom.com, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:43829 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568Ab3GXJZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 05:25:24 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 05:25:23 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7168C6E803C
	for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 05:25:14 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O9PIY516187470
	for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 05:25:18 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O9PFYD013747
	for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 06:25:17 -0300
In-Reply-To: <1374657909-26929-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes following warning. The PCI device might have been
disabled somewhere else when we have EEH errors during early stage.

Device tg3 disabling already-disabled device
WARNING: at drivers/pci/pci.c:1403
:
NIP [c00000000044fd5c] .pci_disable_device+0xcc/0xe0
LR [c00000000044fd58] .pci_disable_device+0xc8/0xe0
Call Trace:
[c000003f80bc7370] [c00000000044fd58] .pci_disable_device+0xc8/0xe0
[c000003f80bc73f0] [d00000001cfe8fc0] .tg3_init_one+0x2f0/0x19f0 [tg3]
[c000003f80bc74d0] [c0000000004534e8] .local_pci_probe+0x68/0xb0
[c000003f80bc7560] [c0000000004537c8] .pci_device_probe+0x198/0x1a0
[c000003f80bc7610] [c0000000004f9e98] .driver_probe_device+0xd8/0x450
[c000003f80bc76a0] [c0000000004fa3bc] .__driver_attach+0x10c/0x110
[c000003f80bc7730] [c0000000004f6e94] .bus_for_each_dev+0x94/0x100
[c000003f80bc77d0] [c0000000004f9634] .driver_attach+0x34/0x50
[c000003f80bc7850] [c0000000004f8f98] .bus_add_driver+0x288/0x380
[c000003f80bc78f0] [c0000000004fae2c] .driver_register+0x9c/0x200
[c000003f80bc7980] [c000000000453214] .__pci_register_driver+0x64/0x90
[c000003f80bc7a10] [d00000001cff7a60] .tg3_driver_init+0x2c/0x40 [tg3]
[c000003f80bc7a80] [c00000000000b424] .do_one_initcall+0x144/0x1f0
[c000003f80bc7b70] [c0000000001244a0] .load_module+0x1f30/0x2700
[c000003f80bc7d40] [c000000000124e80] .SyS_finit_module+0xc0/0x110
[c000003f80bc7e30] [c000000000009dd4] syscall_exit+0x0/0x98

Reported-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index aee1b9a..ddebc7a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17625,7 +17625,8 @@ err_out_free_res:
 	pci_release_regions(pdev);
 
 err_out_disable_pdev:
-	pci_disable_device(pdev);
+	if (pci_is_enabled(pdev))
+		pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	return err;
 }
-- 
1.7.5.4
