From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net v2] sfc: fix calling of free_irq with already free vector
Date: Thu,  8 May 2014 12:44:53 +0200
Message-ID: <1399545893-25563-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Zenghui Shi <zshi@redhat.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	<linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754441AbaEHKpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 06:45:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the sfc driver is in legacy interrupt mode (either explicitly by
using interrupt_mode module param or by falling back to it) it will
hit a warning at kernel/irq/manage.c because it will try to free an irq
which wasn't allocated by it in the first place because the MSI(X) irqs are
zero and it'll try to free them unconditionally. So fix it by checking if
we're in legacy mode and freeing the appropriate irqs.

CC: Zenghui Shi <zshi@redhat.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: <linux-net-drivers@solarflare.com>
CC: Shradha Shah <sshah@solarflare.com>
CC: David S. Miller <davem@davemloft.net>

Fixes: 1899c111a535 ("sfc: Fix IRQ cleanup in case of a probe failure")
Reported-by: Zenghui Shi <zshi@redhat.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: Change the fix to check for the interrupt mode and adjust the
commit message.

 drivers/net/ethernet/sfc/nic.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 32d969e857f7..43761d3b8651 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -156,13 +156,15 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
 	efx->net_dev->rx_cpu_rmap = NULL;
 #endif
 
-	/* Disable MSI/MSI-X interrupts */
-	efx_for_each_channel(channel, efx)
-		free_irq(channel->irq, &efx->msi_context[channel->channel]);
-
-	/* Disable legacy interrupt */
-	if (efx->legacy_irq)
+	if (efx->interrupt_mode != EFX_INT_MODE_LEGACY) {
+		/* Disable MSI/MSI-X interrupts */
+		efx_for_each_channel(channel, efx)
+			free_irq(channel->irq,
+				 &efx->msi_context[channel->channel]);
+	} else {
+		/* Disable legacy interrupt */
 		free_irq(efx->legacy_irq, efx);
+	}
 }
 
 /* Register dump */
-- 
1.8.5.3
