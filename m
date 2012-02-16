From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/19] sfc: Do not retry hardware probe if it
 schedules a reset
Date: Thu, 16 Feb 2012 00:44:52 +0000
Message-ID: <1329353092.2565.28.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27524 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753356Ab2BPAoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:44:55 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If efx_pci_probe_main() schedules an INVISIBLE or ALL reset (but
nothing more drastic), we retry it up to 5 times.  So far as I'm
aware, this was a workaround for bugs in Falcon A0 which were fixed
in production silicon.  Remove the retry.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   50 ++++++++++++---------------------------
 1 files changed, 16 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b7cf9f0..2e6389c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2440,7 +2440,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	const struct efx_nic_type *type = (const struct efx_nic_type *) entry->driver_data;
 	struct net_device *net_dev;
 	struct efx_nic *efx;
-	int i, rc;
+	int rc;
 
 	/* Allocate and initialise a struct net_device and struct efx_nic */
 	net_dev = alloc_etherdev_mqs(sizeof(*efx), EFX_MAX_CORE_TX_QUEUES,
@@ -2473,39 +2473,22 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	if (rc)
 		goto fail2;
 
-	/* No serialisation is required with the reset path because
-	 * we're in STATE_INIT. */
-	for (i = 0; i < 5; i++) {
-		rc = efx_pci_probe_main(efx);
-
-		/* Serialise against efx_reset(). No more resets will be
-		 * scheduled since efx_stop_all() has been called, and we
-		 * have not and never have been registered with either
-		 * the rtnetlink or driverlink layers. */
-		cancel_work_sync(&efx->reset_work);
-
-		if (rc == 0) {
-			if (efx->reset_pending) {
-				/* If there was a scheduled reset during
-				 * probe, the NIC is probably hosed anyway */
-				efx_pci_remove_main(efx);
-				rc = -EIO;
-			} else {
-				break;
-			}
-		}
+	rc = efx_pci_probe_main(efx);
 
-		/* Retry if a recoverably reset event has been scheduled */
-		if (efx->reset_pending &
-		    ~(1 << RESET_TYPE_INVISIBLE | 1 << RESET_TYPE_ALL) ||
-		    !efx->reset_pending)
-			goto fail3;
+	/* Serialise against efx_reset(). No more resets will be
+	 * scheduled since efx_stop_all() has been called, and we have
+	 * not and never have been registered.
+	 */
+	cancel_work_sync(&efx->reset_work);
 
-		efx->reset_pending = 0;
-	}
+	if (rc)
+		goto fail3;
 
-	if (rc) {
-		netif_err(efx, probe, efx->net_dev, "Could not reset NIC\n");
+	/* If there was a scheduled reset during probe, the NIC is
+	 * probably hosed anyway.
+	 */
+	if (efx->reset_pending) {
+		rc = -EIO;
 		goto fail4;
 	}
 
@@ -2515,7 +2498,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 
 	rc = efx_register_netdev(efx);
 	if (rc)
-		goto fail5;
+		goto fail4;
 
 	netif_dbg(efx, probe, efx->net_dev, "initialisation successful\n");
 
@@ -2524,9 +2507,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	rtnl_unlock();
 	return 0;
 
- fail5:
-	efx_pci_remove_main(efx);
  fail4:
+	efx_pci_remove_main(efx);
  fail3:
 	efx_fini_io(efx);
  fail2:
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
