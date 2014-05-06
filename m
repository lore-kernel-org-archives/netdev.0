From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] sfc: fix calling of free_irq with 0 argument
Date: Tue,  6 May 2014 14:49:16 +0200
Message-ID: <1399380556-25797-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	<linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753074AbaEFMyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 08:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the sfc driver is in legacy interrupt mode (either explicitly by
using interrupt_mode module param or by falling back to it) it will
hit a warning at kernel/irq/manage.c because it will try to free irq 0
in efx_nic_fini_interrupt() since the MSI interrupts were freed always,
but in legacy irq mode they're == 0. So fix it by checking if we
actually have an interrupt allocated and only then free it.

CC: <linux-net-drivers@solarflare.com>
CC: Shradha Shah <sshah@solarflare.com>
CC: David S. Miller <davem@davemloft.net>

Reported-by: Zenghui Shi <zshi@redhat.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
There're other ways to fix this as well, but I chose this one as it follows
the logic in the code. Also I saw it used in a few places to check if
there's an IRQ allocated for that channel.

 drivers/net/ethernet/sfc/nic.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 32d969e857f7..cab627defbc3 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -158,7 +158,9 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
 
 	/* Disable MSI/MSI-X interrupts */
 	efx_for_each_channel(channel, efx)
-		free_irq(channel->irq, &efx->msi_context[channel->channel]);
+		if (channel->irq)
+			free_irq(channel->irq,
+				 &efx->msi_context[channel->channel]);
 
 	/* Disable legacy interrupt */
 	if (efx->legacy_irq)
-- 
1.8.5.3
