From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 30/33] sfc: Treat probe as unsuccessful if it scheduled a reset
Date: Fri, 12 Dec 2008 13:00:12 +0000
Message-ID: <20081212130011.GD10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42580 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758033AbYLLNAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 08:00:14 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

efx_pci_probe_main() can return success despite a reset being scheduled.
Catch this and retry or abort probe depending on the reset type.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c094845..0d57c6d 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2115,8 +2115,6 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	 * we're in STATE_INIT. */
 	for (i = 0; i < 5; i++) {
 		rc = efx_pci_probe_main(efx);
-		if (rc == 0)
-			break;
 
 		/* Serialise against efx_reset(). No more resets will be
 		 * scheduled since efx_stop_all() has been called, and we
@@ -2124,6 +2122,17 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 		 * the rtnetlink or driverlink layers. */
 		cancel_work_sync(&efx->reset_work);
 
+		if (rc == 0) {
+			if (efx->reset_pending != RESET_TYPE_NONE) {
+				/* If there was a scheduled reset during
+				 * probe, the NIC is probably hosed anyway */
+				efx_pci_remove_main(efx);
+				rc = -EIO;
+			} else {
+				break;
+			}
+		}
+
 		/* Retry if a recoverably reset event has been scheduled */
 		if ((efx->reset_pending != RESET_TYPE_INVISIBLE) &&
 		    (efx->reset_pending != RESET_TYPE_ALL))
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
