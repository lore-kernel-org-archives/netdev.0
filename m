From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/33] sfc: Do not use pci_disable_device() to disable bus mastering
Date: Fri, 12 Dec 2008 12:49:14 +0000
Message-ID: <20081212124913.GC10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:51163 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756760AbYLLMtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:49:16 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pci_disable_device() disables many features, like MSI-X, which we
never reenable in efx_reset().  Further, calls to pci_enable_device()
and pci_disable_device() must be matched since the nesting count was
introduced.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 271cbf8..ac0b671 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1344,6 +1344,17 @@ static inline void falcon_irq_ack_a1(struct efx_nic *efx)
 	falcon_readl(efx, &reg, WORK_AROUND_BROKEN_PCI_READS_REG_KER_A1);
 }
 
+static void efx_pci_clear_master(struct pci_dev *dev)
+{
+	u16 command;
+
+	if (dev->is_busmaster &&
+	    !pci_read_config_word(dev, PCI_COMMAND, &command) &&
+	    !pci_write_config_word(dev, PCI_COMMAND,
+				   command & ~PCI_COMMAND_MASTER))
+		dev->is_busmaster = false;
+}
+
 /* Process a fatal interrupt
  * Disable bus mastering ASAP and schedule a reset
  */
@@ -1375,9 +1386,9 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 	}
 
 	/* Disable both devices */
-	pci_disable_device(efx->pci_dev);
+	efx_pci_clear_master(efx->pci_dev);
 	if (FALCON_IS_DUAL_FUNC(efx))
-		pci_disable_device(nic_data->pci_dev2);
+		efx_pci_clear_master(nic_data->pci_dev2);
 	falcon_disable_interrupts(efx);
 
 	if (++n_int_errors < FALCON_MAX_INT_ERRORS) {
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
