From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] i40e: disable MSI-X interrupts if we cannot reserve enough vectors
Date: Thu, 22 Sep 2016 10:03:58 -0300
Message-ID: <1474549438-27468-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
        gpiccoli@linux.vnet.ibm.com
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44851 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755538AbcIVNES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 09:04:18 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8MD3wY1014076
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 09:04:17 -0400
Received: from e24smtp04.br.ibm.com (e24smtp04.br.ibm.com [32.104.18.25])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25m9p1k7bs-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 09:04:17 -0400
Received: from localhost
        by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Thu, 22 Sep 2016 10:04:11 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
        by d24dlp01.br.ibm.com (Postfix) with ESMTP id F22D9352005C
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 09:03:45 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
        by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8MD497K5308710
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 10:04:09 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
        by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8MD49RN004898
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 10:04:09 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we fail on allocating enough MSI-X interrupts, we should disable
them since they were previously enabled in this point of code.

Not disabling them can lead to WARN_ON() being triggered and subsequent
failure in enabling MSI as a fallback; the below message was shown without
this patch while we played with interrupt allocation in i40e driver:

[ 21.461346] sysfs: cannot create duplicate filename '/devices/pci0007:00/0007:00:00.0/0007:01:00.3/msi_irqs'
[ 21.461459] ------------[ cut here ]------------
[ 21.461514] WARNING: CPU: 64 PID: 1155 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x88/0xc0

Also, we noticed that without this patch, if we modprobe the module without
enough MSI-X interrupts (triggering the above warning), unload the module
and re-load it again, we got a crash on the system.

Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d0b3a1b..f8ebe78 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7721,6 +7721,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->flags &= ~I40E_FLAG_MSIX_ENABLED;
 		kfree(pf->msix_entries);
 		pf->msix_entries = NULL;
+		pci_disable_msix(pf->pdev);
 		return -ENODEV;
 
 	} else if (v_actual == I40E_MIN_MSIX) {
-- 
2.1.0
