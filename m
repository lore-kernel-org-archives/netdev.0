From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/12] sfc: Get port number from CS_PORT_NUM, not PCI
 function number
Date: Tue, 01 Jun 2010 22:32:43 +0100
Message-ID: <1275427963.2114.47.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51631 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531Ab0FAVcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:32:46 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A single shared memory region used to communicate with firmware is
mapped into both PCI PFs of the SFC9020 and SFL9021.  Drivers must be
able to identify which port they are addressing in order to use the
correct sub-region.  Currently we use the PCI function number, but the
PCI address may be virtualised.  Use the CS_PORT_NUM register field
defined for just this purpose.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
David,

I think this may be a candidate for 2.6.35 and 2.6.{33,34}.y. If a
driver uses the wrong sub-region of shared memory it will horribly
confuse the firmware and any driver bound to the other function.

Ben.

 drivers/net/sfc/net_driver.h |    4 +++-
 drivers/net/sfc/siena.c      |    4 ++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 40c0d93..6b2e440 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -649,6 +649,7 @@ union efx_multicast_hash {
  * struct efx_nic - an Efx NIC
  * @name: Device name (net device name or bus id before net device registered)
  * @pci_dev: The PCI device
+ * @port_num: Index of this host port within the controller
  * @type: Controller type attributes
  * @legacy_irq: IRQ number
  * @workqueue: Workqueue for port reconfigures and the HW monitor.
@@ -732,6 +733,7 @@ union efx_multicast_hash {
 struct efx_nic {
 	char name[IFNAMSIZ];
 	struct pci_dev *pci_dev;
+	unsigned port_num;
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	struct workqueue_struct *workqueue;
@@ -834,7 +836,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 
 static inline unsigned int efx_port_num(struct efx_nic *efx)
 {
-	return PCI_FUNC(efx->pci_dev->devfn);
+	return efx->port_num;
 }
 
 /**
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 727b422..7ecd255 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -206,6 +206,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 {
 	struct siena_nic_data *nic_data;
 	bool already_attached = 0;
+	efx_oword_t reg;
 	int rc;
 
 	/* Allocate storage for hardware specific data */
@@ -220,6 +221,9 @@ static int siena_probe_nic(struct efx_nic *efx)
 		goto fail1;
 	}
 
+	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
+	efx->port_num = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
+
 	efx_mcdi_init(efx);
 
 	/* Recover from a failed assertion before probing */
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

