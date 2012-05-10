From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Fix division by zero when using one RX channel and
 no SR-IOV
Date: Thu, 10 May 2012 03:08:13 +0100
Message-ID: <1336615693.2499.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336615595.2499.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7537 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752541Ab2EJCIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:08:16 -0400
In-Reply-To: <1336615595.2499.24.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If RSS is disabled on the PF (efx->n_rx_channels == 1) we try to set
up the indirection table so that VFs can use it, setting
efx->rss_spread = efx_vf_size(efx).  But if SR-IOV was disabled at
compile time, this evaluates to 0 and we end up dividing by zero when
initialising the table.

I considered changing the fallback definition of efx_vf_size() to
return 1, but its value is really meaningless if we are not going to
enable VFs.  Therefore add a condition of efx_sriov_wanted(efx) in
efx_probe_interrupts().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 3cbfbff..4a00053 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1349,7 +1349,7 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 	}
 
 	/* RSS might be usable on VFs even if it is disabled on the PF */
-	efx->rss_spread = (efx->n_rx_channels > 1 ?
+	efx->rss_spread = ((efx->n_rx_channels > 1 || !efx_sriov_wanted(efx)) ?
 			   efx->n_rx_channels : efx_vf_size(efx));
 
 	return 0;
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
