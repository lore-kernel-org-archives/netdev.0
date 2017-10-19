From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 4/7] net: aquantia: Limit number of MSIX irqs to the number of cpus
Date: Thu, 19 Oct 2017 18:23:56 +0300
Message-ID: <f7a0434c00b44cbe870192914addb25b0128d119.1508159232.git.igor.russkikh@aquantia.com>
References: <cover.1508159232.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0070.outbound.protection.outlook.com ([104.47.32.70]:29217
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751014AbdJSPYt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:24:49 -0400
In-Reply-To: <cover.1508159232.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no much practical use from having MSIX vectors more that number
of cpus, thus cap this first with preconfigured limit, then with number
of cpus online.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
index 4c6c882..727f0a4 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
@@ -85,6 +85,7 @@ int aq_pci_func_init(struct aq_pci_func_s *self)
 	int err = 0;
 	unsigned int bar = 0U;
 	unsigned int port = 0U;
+	unsigned int numvecs = 0U;
 
 	err = pci_enable_device(self->pdev);
 	if (err < 0)
@@ -142,10 +143,12 @@ int aq_pci_func_init(struct aq_pci_func_s *self)
 		}
 	}
 
-	/*enable interrupts */
+	numvecs = min((u8)AQ_CFG_VECS_DEF, self->aq_hw_caps.msix_irqs);
+	numvecs = min(numvecs, num_online_cpus());
+
+	/* enable interrupts */
 #if !AQ_CFG_FORCE_LEGACY_INT
-	err = pci_alloc_irq_vectors(self->pdev, self->aq_hw_caps.msix_irqs,
-			      self->aq_hw_caps.msix_irqs, PCI_IRQ_MSIX);
+	err = pci_alloc_irq_vectors(self->pdev, numvecs, numvecs, PCI_IRQ_MSIX);
 
 	if (err < 0) {
 		err = pci_alloc_irq_vectors(self->pdev, 1, 1,
@@ -153,7 +156,7 @@ int aq_pci_func_init(struct aq_pci_func_s *self)
 		if (err < 0)
 			goto err_exit;
 	}
-#endif
+#endif /* AQ_CFG_FORCE_LEGACY_INT */
 
 	/* net device init */
 	for (port = 0; port < self->ports; ++port) {
-- 
2.7.4
