From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] e1000e: use disable_hardirq() also for MSIX vectors in e1000_netpoll()
Date: Tue,  6 Jun 2017 01:58:09 -0700
Message-ID: <20170606085809.78571-12-jeffrey.t.kirsher@intel.com>
References: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20068 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751435AbdFFI6R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:17 -0400
In-Reply-To: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Replace disable_irq() which waits for threaded irq handlers with
disable_hardirq() which waits only for hardirq part.

Fixes: 311191297125 ("e1000: use disable_hardirq() for e1000_netpoll()")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index fc1d92ca3ea2..e1d46c11cb61 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6743,20 +6743,20 @@ static irqreturn_t e1000_intr_msix(int __always_unused irq, void *data)
 
 		vector = 0;
 		msix_irq = adapter->msix_entries[vector].vector;
-		disable_irq(msix_irq);
-		e1000_intr_msix_rx(msix_irq, netdev);
+		if (disable_hardirq(msix_irq))
+			e1000_intr_msix_rx(msix_irq, netdev);
 		enable_irq(msix_irq);
 
 		vector++;
 		msix_irq = adapter->msix_entries[vector].vector;
-		disable_irq(msix_irq);
-		e1000_intr_msix_tx(msix_irq, netdev);
+		if (disable_hardirq(msix_irq))
+			e1000_intr_msix_tx(msix_irq, netdev);
 		enable_irq(msix_irq);
 
 		vector++;
 		msix_irq = adapter->msix_entries[vector].vector;
-		disable_irq(msix_irq);
-		e1000_msix_other(msix_irq, netdev);
+		if (disable_hardirq(msix_irq))
+			e1000_msix_other(msix_irq, netdev);
 		enable_irq(msix_irq);
 	}
 
-- 
2.12.2
