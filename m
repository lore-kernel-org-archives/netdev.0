From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: deprecate 1-bit flag indicating watchdog
 kernel thread is running
Date: Wed, 25 Oct 2017 18:04:56 -0700
Message-ID: <20171026010456.GA17500@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0046.outbound.protection.outlook.com ([104.47.40.46]:29420
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751868AbdJZBFB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 21:05:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Deprecate the 1-bit flag (bit 2 in the SLI_SCRATCH_1 Octeon register) that
indicates that the liquidio watchdog kernel thread is running for this NIC.
Reason is:  it is incompatible with the firmware's use for SLI_SCRATCH_1.

In lieu of checking that now-deprecated flag, check the value of
oct_dev->adapter_refcount to determine whether or not to create the
watchdog kernel thread.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 963803b..d1a755b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1076,19 +1076,13 @@ liquidio_probe(struct pci_dev *pdev,
 	}
 
 	if (OCTEON_CN23XX_PF(oct_dev)) {
-		u64 scratch1;
 		u8 bus, device, function;
 
-		scratch1 = octeon_read_csr64(oct_dev, CN23XX_SLI_SCRATCH1);
-		if (!(scratch1 & 4ULL)) {
-			/* Bit 2 of SLI_SCRATCH_1 is a flag that indicates that
-			 * the lio watchdog kernel thread is running for this
-			 * NIC.  Each NIC gets one watchdog kernel thread.
+		if (atomic_read(oct_dev->adapter_refcount) == 1) {
+			/* Each NIC gets one watchdog kernel thread.  The first
+			 * PF (of each NIC) that gets pci_driver->probe()'d
+			 * creates that thread.
 			 */
-			scratch1 |= 4ULL;
-			octeon_write_csr64(oct_dev, CN23XX_SLI_SCRATCH1,
-					   scratch1);
-
 			bus = pdev->bus->number;
 			device = PCI_SLOT(pdev->devfn);
 			function = PCI_FUNC(pdev->devfn);
