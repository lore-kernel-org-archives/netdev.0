From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] e1000: use disable_hardirq() for e1000_netpoll()
Date: Sat, 10 Dec 2016 14:22:42 -0800
Message-ID: <1481408562-6529-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: sd@queasysnail.net, davej@codemonkey.org.uk,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "Peter Zijlstra (Intel)" <peterz@infradead.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34129 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbcLJWWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 17:22:53 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so6274516pgc.1
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 14:22:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 02cea3958664 ("genirq: Provide disable_hardirq()")
Peter introduced disable_hardirq() for netpoll, but it is forgotten
to use it for e1000.

This patch changes disable_irq() to disable_hardirq() for e1000.

Reported-by: Dave Jones <davej@codemonkey.org.uk>
Suggested-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c    | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index f42129d..164c3bb 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -5257,8 +5257,8 @@ static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
-	e1000_intr(adapter->pdev->irq, netdev);
+	if (disable_hardirq(adapter->pdev->irq))
+		e1000_intr(adapter->pdev->irq, netdev);
 	enable_irq(adapter->pdev->irq);
 }
 #endif
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7017281..9a0be77 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6762,13 +6762,13 @@ static void e1000_netpoll(struct net_device *netdev)
 		e1000_intr_msix(adapter->pdev->irq, netdev);
 		break;
 	case E1000E_INT_MODE_MSI:
-		disable_irq(adapter->pdev->irq);
-		e1000_intr_msi(adapter->pdev->irq, netdev);
+		if (disable_hardirq(adapter->pdev->irq))
+			e1000_intr_msi(adapter->pdev->irq, netdev);
 		enable_irq(adapter->pdev->irq);
 		break;
 	default:		/* E1000E_INT_MODE_LEGACY */
-		disable_irq(adapter->pdev->irq);
-		e1000_intr(adapter->pdev->irq, netdev);
+		if (disable_hardirq(adapter->pdev->irq))
+			e1000_intr(adapter->pdev->irq, netdev);
 		enable_irq(adapter->pdev->irq);
 		break;
 	}
-- 
2.5.5
