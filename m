From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/33] sfc: Provide hints to irqbalance daemon
Date: Fri, 12 Dec 2008 12:52:30 +0000
Message-ID: <20081212125229.GK10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:47293 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757130AbYLLMwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:52:32 -0500
Content-Disposition: inline
In-Reply-To: <cover.1229085672.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate IRQs with the name format <device>[-<type>]-<number> so that
future versions of irqbalanced understand what we're doing.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   24 ++++++++++++++++++++++++
 drivers/net/sfc/falcon.c     |    2 +-
 drivers/net/sfc/net_driver.h |    2 ++
 3 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 58cbbd5..183a440 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -356,6 +356,27 @@ static int efx_probe_channel(struct efx_channel *channel)
 }
 
 
+static void efx_set_channel_names(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+	const char *type = "";
+	int number;
+
+	efx_for_each_channel(channel, efx) {
+		number = channel->channel;
+		if (efx->n_channels > efx->n_rx_queues) {
+			if (channel->channel < efx->n_rx_queues) {
+				type = "-rx";
+			} else {
+				type = "-tx";
+				number -= efx->n_rx_queues;
+			}
+		}
+		snprintf(channel->name, sizeof(channel->name),
+			 "%s%s-%d", efx->name, type, number);
+	}
+}
+
 /* Channels are shutdown and reinitialised whilst the NIC is running
  * to propagate configuration changes (mtu, checksum offload), or
  * to clear hardware error conditions
@@ -1002,6 +1023,7 @@ static int efx_probe_all(struct efx_nic *efx)
 			goto fail3;
 		}
 	}
+	efx_set_channel_names(efx);
 
 	return 0;
 
@@ -1483,6 +1505,7 @@ static int efx_netdev_event(struct notifier_block *this,
 
 		strcpy(efx->name, net_dev->name);
 		efx_mtd_rename(efx);
+		efx_set_channel_names(efx);
 	}
 
 	return NOTIFY_DONE;
@@ -1516,6 +1539,7 @@ static int efx_register_netdev(struct efx_nic *efx)
 		return rc;
 	}
 	strcpy(efx->name, net_dev->name);
+	efx_set_channel_names(efx);
 
 	return 0;
 }
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9563c13..7421945 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1585,7 +1585,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 	efx_for_each_channel(channel, efx) {
 		rc = request_irq(channel->irq, falcon_msi_interrupt,
 				 IRQF_PROBE_SHARED, /* Not shared */
-				 efx->name, channel);
+				 channel->name, channel);
 		if (rc) {
 			EFX_ERR(efx, "failed to hook IRQ %d\n", channel->irq);
 			goto fail2;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 2c5b5fa..abff908 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -327,6 +327,7 @@ enum efx_rx_alloc_method {
  *
  * @efx: Associated Efx NIC
  * @channel: Channel instance number
+ * @name: Name for channel and IRQ
  * @used_flags: Channel is used by net driver
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
@@ -357,6 +358,7 @@ enum efx_rx_alloc_method {
 struct efx_channel {
 	struct efx_nic *efx;
 	int channel;
+	char name[IFNAMSIZ + 6];
 	int used_flags;
 	bool enabled;
 	int irq;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
