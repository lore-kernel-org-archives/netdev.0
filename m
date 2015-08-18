From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] igb: do not re-init SR-IOV during probe
Date: Tue, 18 Aug 2015 14:09:10 -0700
Message-ID: <1439932162-1995-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9866 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429AbbHRVJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:26 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

During driver probing the following code path is triggered.
igb_probe
->igb_sw_init
  ->igb_probe_vfs
    ->igb_pci_enable_sriov
      ->igb_sriov_reinit

Doing the SR-IOV re-init is not necessary during probing since we're
starting from scratch. Here we can call igb_enable_sriov() right away.

Running igb_sriov_reinit() during igb_probe() also seems to cause
occasional packet loss on some onboard 82576 NICs. Reproduced on
Dell and HP servers with onboard 82576 NICs.
Example:
Intel Corporation 82576 Gigabit Network Connection [8086:10c9] (rev 01)
Subsystem: Dell Device [1028:0481]

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0069c32..67ac0ea 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2851,7 +2851,7 @@ static void igb_probe_vfs(struct igb_adapter *adapter)
 		return;
 
 	pci_sriov_set_totalvfs(pdev, 7);
-	igb_pci_enable_sriov(pdev, max_vfs);
+	igb_enable_sriov(pdev, max_vfs);
 
 #endif /* CONFIG_PCI_IOV */
 }
-- 
2.4.3
