From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net v2] sfc: check for NULL efx->ptp_data in efx_ptp_event
Date: Tue, 25 Feb 2014 13:17:59 +0000
Message-ID: <alpine.LFD.2.03.1402251306530.16190@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Shradha Shah <sshah@solarflare.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34016 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbaBYNSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 08:18:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we receive a PTP event from the NIC when we haven't set up PTP state
in the driver, we attempt to read through a NULL pointer efx->ptp_data,
triggering a panic.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
v2: resent using alpine, because Thunderbird mangled v1

While this shouldn't happen with existing released firmware, future
sfn7322f firmware is planned to enable PPS irrespective of whether
timestamping (and thus PTP) is enabled.  We are considering workarounds,
but this defensive patch seemed like a good idea anyway in case the
firmware gets in a muddle.
Also, in principle this shouldn't happen on 3.14+ kernels as the driver
should always set up PTP state at probe time (though there might still
be a race against the firmware sending its first PPS), however 3.12 and
3.13 both supported EF10 but not PTP-on-EF10 and thus they never set up
the PTP state; hence this fix should also be backported to those series.

--- linux-3.13/drivers/net/ethernet/sfc/ptp.c.orig	2014-01-20 02:40:07.000000000 +0000
+++ linux-3.13/drivers/net/ethernet/sfc/ptp.c	2014-02-24 17:46:31.753497000 +0000
@@ -1360,6 +1360,13 @@ void efx_ptp_event(struct efx_nic *efx,
 	struct efx_ptp_data *ptp = efx->ptp_data;
 	int code = EFX_QWORD_FIELD(*ev, MCDI_EVENT_CODE);
 
+	if (!ptp) {
+		if (net_ratelimit())
+			netif_warn(efx, drv, efx->net_dev,
+				   "Received PTP event but PTP not set up\n");
+		return;
+	}
+
 	if (!ptp->enabled)
 		return;
 
