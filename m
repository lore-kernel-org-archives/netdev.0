From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 07/13] liquidio: chip reset changes
Date: Tue, 21 Jun 2016 22:53:09 -0700
Message-ID: <1466574795-4306-8-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0089.outbound.protection.outlook.com ([65.55.169.89]:19264
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751523AbcFVFzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:23 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch resolves the order of chip reset while destroying
the resources by postoponing soft reset in destroy resources
function until all queues are removed properly.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 4440086..56b1d67 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1180,12 +1180,6 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		if (oct->flags & LIO_FLAG_MSI_ENABLED)
 			pci_disable_msi(oct->pci_dev);
 
-		/* Soft reset the octeon device before exiting */
-		oct->fn_list.soft_reset(oct);
-
-		/* Disable the device, releasing the PCI INT */
-		pci_disable_device(oct->pci_dev);
-
 		/* fallthrough */
 	case OCT_DEV_IN_RESET:
 	case OCT_DEV_DROQ_INIT_DONE:
@@ -1232,11 +1226,18 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		/* fallthrough */
 	case OCT_DEV_PCI_MAP_DONE:
+
+		/* Soft reset the octeon device before exiting */
+		oct->fn_list.soft_reset(oct);
+
 		octeon_unmap_pci_barx(oct, 0);
 		octeon_unmap_pci_barx(oct, 1);
 
 		/* fallthrough */
 	case OCT_DEV_BEGIN_STATE:
+		/* Disable the device, releasing the PCI INT */
+		pci_disable_device(oct->pci_dev);
+
 		/* Nothing to be done here either */
 		break;
 	}                       /* end switch(oct->status) */
-- 
1.8.3.1
