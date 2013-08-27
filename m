From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/16] sfc: Do not assume efx_nic_type::ev_fini is
 idempotent
Date: Tue, 27 Aug 2013 21:39:09 +0100
Message-ID: <1377635949.13272.72.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62547 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191Ab3H0UjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:39:13 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_fini_eventq() needs to be idempotent but EF10 firmware is
picky about queue states.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 5 +++++
 drivers/net/ethernet/sfc/net_driver.h | 2 ++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 3977926..49d06ca 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -339,6 +339,7 @@ static void efx_init_eventq(struct efx_channel *channel)
 	channel->eventq_read_ptr = 0;
 
 	efx_nic_init_eventq(channel);
+	channel->eventq_init = true;
 }
 
 /* Enable event queue processing and NAPI */
@@ -367,10 +368,14 @@ static void efx_stop_eventq(struct efx_channel *channel)
 
 static void efx_fini_eventq(struct efx_channel *channel)
 {
+	if (!channel->eventq_init)
+		return;
+
 	netif_dbg(channel->efx, drv, channel->efx->net_dev,
 		  "chan %d fini event queue\n", channel->channel);
 
 	efx_nic_fini_eventq(channel);
+	channel->eventq_init = false;
 }
 
 static void efx_remove_eventq(struct efx_channel *channel)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 7aa0e0f..694c572 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -356,6 +356,7 @@ enum efx_rx_alloc_method {
  * @efx: Associated Efx NIC
  * @channel: Channel instance number
  * @type: Channel type definition
+ * @eventq_init: Event queue initialised flag
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
  * @irq_moderation: IRQ moderation value (in hardware ticks)
@@ -387,6 +388,7 @@ struct efx_channel {
 	struct efx_nic *efx;
 	int channel;
 	const struct efx_channel_type *type;
+	bool eventq_init;
 	bool enabled;
 	int irq;
 	unsigned int irq_moderation;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
