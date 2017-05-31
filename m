From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: VF interrupt initialization cleanup
Date: Wed, 31 May 2017 09:48:09 -0700
Message-ID: <20170531164809.GA1497@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0086.outbound.protection.outlook.com ([104.47.33.86]:38912
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751034AbdEaQsP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 12:48:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Set initialization state variable to (reflect interrupt initialization) at
correct time (immediately after having configured interrupts).  This fixes
problem of inconsistent IRQ allocation in case of [obscure] failure when
negotiating with PF driver during init.

Clean-up of interrupt enablement during initialization & avoid potential
race condition with chip-specific code (i.e. perform interrupt control in
main driver module).  Added explanatory comments regarding interrupt
enablement.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 .../net/ethernet/cavium/liquidio/cn23xx_vf_device.c   | 10 ----------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c    | 19 +++++++++++++++++--
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
index b6117b6..20f3d2a 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
@@ -431,11 +431,6 @@ int cn23xx_octeon_pfvf_handshake(struct octeon_device *oct)
 	mbox_cmd.fn = (octeon_mbox_callback_t)octeon_pfvf_hs_callback;
 	mbox_cmd.fn_arg = &status;
 
-	/* Interrupts are not enabled at this point.
-	 * Enable them with default oq ticks
-	 */
-	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
-
 	octeon_mbox_write(oct, &mbox_cmd);
 
 	atomic_set(&status, 0);
@@ -444,11 +439,6 @@ int cn23xx_octeon_pfvf_handshake(struct octeon_device *oct)
 		schedule_timeout_uninterruptible(1);
 	} while ((!atomic_read(&status)) && (count++ < 100000));
 
-	/* Disable the interrupt so that the interrupsts will be reenabled
-	 * with the oq ticks received from the PF
-	 */
-	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
-
 	ret = atomic_read(&status);
 	if (!ret) {
 		dev_err(&oct->pci_dev->dev, "octeon_pfvf_handshake timeout\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 31d737c..0712409 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -3188,13 +3188,28 @@ static int octeon_device_init(struct octeon_device *oct)
 	if (octeon_setup_interrupt(oct))
 		return 1;
 
+	atomic_set(&oct->status, OCT_DEV_INTR_SET_DONE);
+
+	/* ***************************************************************
+	 * The interrupts need to be enabled for the PF<-->VF handshake.
+	 * They are [re]-enabled after the PF<-->VF handshake so that the
+	 * correct OQ tick value is used (i.e. the value retrieved from
+	 * the PF as part of the handshake).
+	 */
+
+	/* Enable Octeon device interrupts */
+	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
+
 	if (cn23xx_octeon_pfvf_handshake(oct))
 		return 1;
 
+	/* Here we [re]-enable the interrupts so that the correct OQ tick value
+	 * is used (i.e. the value that was retrieved during the handshake)
+	 */
+
 	/* Enable Octeon device interrupts */
 	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
-
-	atomic_set(&oct->status, OCT_DEV_INTR_SET_DONE);
+	/* *************************************************************** */
 
 	/* Enable the input and output queues for this Octeon device */
 	if (oct->fn_list.enable_io_queues(oct)) {
