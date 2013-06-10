From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] sfc: Store port number in private data, not
 net_device::dev_id
Date: Mon, 10 Jun 2013 18:03:17 +0100
Message-ID: <1370883797.1933.14.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	Narendra K <narendra_k@dell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25943 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab3FJRDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 13:03:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not use net_device::dev_id to indicate the port number, as
this affects the way the local part of IPv6 addresses is normally
generated.

This field was intended for use where multiple devices may share a
single assigned MAC address and need to have different IPv6 addresses.
Siena's two ports each have their own MAC addresses.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h | 3 ++-
 drivers/net/ethernet/sfc/siena.c      | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 39d6bd77..9a2914c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -784,6 +784,7 @@ struct efx_nic {
 
 	char name[IFNAMSIZ];
 	struct pci_dev *pci_dev;
+	unsigned int port_num;
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	bool legacy_irq_enabled;
@@ -916,7 +917,7 @@ static inline int efx_dev_registered(struct efx_nic *efx)
 
 static inline unsigned int efx_port_num(struct efx_nic *efx)
 {
-	return efx->net_dev->dev_id;
+	return efx->port_num;
 }
 
 /**
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 5166924..8c91775 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -304,7 +304,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 	}
 
 	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
-	efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
+	efx->port_num = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
 
 	efx_mcdi_init(efx);
 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
