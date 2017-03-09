From: David Arcari <darcari@redhat.com>
Subject: [PATCH] net: ethernet: aquantia: call set_irq_affinity_hint before free_irq
Date: Thu,  9 Mar 2017 13:28:33 -0500
Message-ID: <1489084113-1420-1-git-send-email-darcari@redhat.com>
Cc: David Arcari <darcari@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46942 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750781AbdCIS2x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 13:28:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a network interface controlled by the aquantia ethernet driver is brought
down a warning is output in dmesg (see below).

The problem is that aq_pci_func_free_irqs() is calling free_irq() before it is
calling irq_set_affinity_hint().

WARNING: CPU: 4 PID: 10068 at kernel/irq/manage.c:1503 __free_irq+0x24d/0x2b0
<snip>
Call Trace:
 dump_stack+0x63/0x87
 __warn+0xd1/0xf0
 warn_slowpath_null+0x1d/0x20
 __free_irq+0x24d/0x2b0
 free_irq+0x39/0x90
 aq_pci_func_free_irqs+0x52/0xa0 [atlantic]
 aq_nic_stop+0xca/0xd0 [atlantic]
 aq_ndev_close+0x1d/0x40 [atlantic]
 __dev_close_many+0x99/0x100
 __dev_close+0x67/0xb0
<snip>

Fixes: 36a4a50f4048 ("net: ethernet: aquantia: switch to pci_alloc_irq_vectors")

Cc: Christoph Hellwig <hch@lst.de>
Cc: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: David Arcari <darcari@redhat.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
index 581de71..4c6c882 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
@@ -213,9 +213,9 @@ void aq_pci_func_free_irqs(struct aq_pci_func_s *self)
 		if (!((1U << i) & self->msix_entry_mask))
 			continue;
 
-		free_irq(pci_irq_vector(pdev, i), self->aq_vec[i]);
 		if (pdev->msix_enabled)
 			irq_set_affinity_hint(pci_irq_vector(pdev, i), NULL);
+		free_irq(pci_irq_vector(pdev, i), self->aq_vec[i]);
 		self->msix_entry_mask &= ~(1U << i);
 	}
 }
-- 
1.8.3.1
