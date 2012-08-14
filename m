From: Ilya Shchepetkov <shchepetkov@ispras.ru>
Subject: [PATCH 4/5] sungem: Call netif_carrier_off() after register_netdev()
Date: Tue, 14 Aug 2012 14:28:54 +0400
Message-ID: <1344940135-17079-5-git-send-email-shchepetkov@ispras.ru>
References: <1344940135-17079-1-git-send-email-shchepetkov@ispras.ru>
Cc: Ilya Shchepetkov <shchepetkov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ispras.ru ([83.149.198.202]:54160 "EHLO smtp.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755680Ab2HNK3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2012 06:29:14 -0400
In-Reply-To: <1344940135-17079-1-git-send-email-shchepetkov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For carrier detection to work properly when binding the driver with a
cable unplugged, netif_carrier_off() should be called after
register_netdev(), not before.

Calling netif_carrier_off() before register_netdev() was causing the
network interface to miss a linkwatch pending event leading to an
inconsistent state if the link is not up when interface is initialized.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Ilya Shchepetkov <shchepetkov@ispras.ru>
---
 drivers/net/ethernet/sun/sungem.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 9ae12d0..c57c9f6 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2909,7 +2909,6 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	gp->lstate = link_down;
 	gp->timer_ticks = 0;
-	netif_carrier_off(dev);
 
 	gp->regs = ioremap(gemreg_base, gemreg_len);
 	if (!gp->regs) {
@@ -2988,6 +2987,9 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		goto err_out_free_consistent;
 	}
 
+	/* Turn off carrier */
+	netif_carrier_off(dev);
+
 	/* Undo the get_cell with appropriate locking (we could use
 	 * ndo_init/uninit but that would be even more clumsy imho)
 	 */
-- 
1.7.7
