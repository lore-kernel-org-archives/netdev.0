From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/6] sfc: Fix MCDI structure field lookup
Date: Tue, 2 Oct 2012 02:27:47 +0100
Message-ID: <1349141267.2577.76.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17175 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752282Ab2JBB1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:27:50 -0400
In-Reply-To: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The least significant bit number (LBN) of a field within an MCDI
structure is counted from the start of the structure, not the
containing dword.  In MCDI_ARRAY_FIELD() we need to mask it rather
than using the usual EFX_DWORD_FIELD() macro.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index dc25caa..3ba2e5b 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -113,11 +113,13 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 #define MCDI_EVENT_FIELD(_ev, _field)			\
 	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)
 #define MCDI_ARRAY_FIELD(_buf, _field1, _type, _index, _field2)		\
-	EFX_DWORD_FIELD(						\
+	EFX_EXTRACT_DWORD(						\
 		*((efx_dword_t *)					\
 		  (MCDI_ARRAY_PTR(_buf, _field1, _type, _index) +	\
 		   (MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _OFST & ~3))), \
-		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2)
+		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _LBN & 0x1f, \
+		(MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _LBN & 0x1f) + \
+		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _WIDTH - 1)
 
 extern void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len);
 extern int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
