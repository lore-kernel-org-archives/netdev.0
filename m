From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] i40e: disable MSI-X interrupts if we cannot reserve enough vectors
Date: Thu, 27 Oct 2016 14:27:56 -0700
Message-ID: <1477603677-39957-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:29768 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031934AbcJ0V2C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:28:02 -0400
In-Reply-To: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>

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

Signed-off-by: Guilherme G Piccoli <gpiccoli@linux.vnet.ibm.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 050d005..6abc130 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7684,6 +7684,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->flags &= ~I40E_FLAG_MSIX_ENABLED;
 		kfree(pf->msix_entries);
 		pf->msix_entries = NULL;
+		pci_disable_msix(pf->pdev);
 		return -ENODEV;
 
 	} else if (v_actual == I40E_MIN_MSIX) {
-- 
2.7.4
