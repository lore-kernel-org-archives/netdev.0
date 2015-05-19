From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/4] sfc: add module parameter to enable MCDI logging
 on new functions
Date: Tue, 19 May 2015 18:36:40 +0100
Message-ID: <555B74A8.30200@solarflare.com>
References: <555B7403.3060006@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:6044 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbbESRgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 13:36:52 -0400
In-Reply-To: <555B7403.3060006@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As many issues are encountered at probe time, where MCDI logging can't be
 enabled through the sysfs node, this change adds a module parameter
 'mcdi_logging_default', which defaults to false.  When set to true, newly-
 probed functions will have MCDI logging enabled.  The setting can
 subsequently be changed as normal through the sysfs node.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index a147bfc..50b8ff8 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/moduleparam.h>
 #include <asm/cmpxchg.h>
 #include "net_driver.h"
 #include "nic.h"
@@ -54,6 +55,13 @@ static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 static bool efx_mcdi_poll_once(struct efx_nic *efx);
 static void efx_mcdi_abandon(struct efx_nic *efx);
 
+#ifdef CONFIG_SFC_MCDI_LOGGING
+static bool mcdi_logging_default;
+module_param(mcdi_logging_default, bool, 0644);
+MODULE_PARM_DESC(mcdi_logging_default,
+		 "Enable MCDI logging on newly-probed functions");
+#endif
+
 int efx_mcdi_init(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi;
@@ -71,6 +79,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	mcdi->logging_buffer = (char *)__get_free_page(GFP_KERNEL);
 	if (!mcdi->logging_buffer)
 		goto fail1;
+	mcdi->logging_enabled = mcdi_logging_default;
 #endif
 	init_waitqueue_head(&mcdi->wq);
 	spin_lock_init(&mcdi->iface_lock);
