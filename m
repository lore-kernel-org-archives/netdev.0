From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/10] sfc: Explain why efx_mcdi_exit_assertion()
 ignores result of efx_mcdi_rpc()
Date: Tue, 17 Jul 2012 19:07:10 +0100
Message-ID: <1342548430.2698.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49438 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755474Ab2GQSHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:07:13 -0400
In-Reply-To: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix CID 113952 in Coverity report on Linux.

This is the one instance where we don't, and shouldn't, check the
return code from efx_mcdi_rpc().  It wasn't immediately obvious to me
why we didn't, so I think an explanation is in order.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 17b6463..fc5e7bb 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1001,12 +1001,17 @@ static void efx_mcdi_exit_assertion(struct efx_nic *efx)
 {
 	u8 inbuf[MC_CMD_REBOOT_IN_LEN];
 
-	/* Atomically reboot the mcfw out of the assertion handler */
+	/* If the MC is running debug firmware, it might now be
+	 * waiting for a debugger to attach, but we just want it to
+	 * reboot.  We set a flag that makes the command a no-op if it
+	 * has already done so.  We don't know what return code to
+	 * expect (0 or -EIO), so ignore it.
+	 */
 	BUILD_BUG_ON(MC_CMD_REBOOT_OUT_LEN != 0);
 	MCDI_SET_DWORD(inbuf, REBOOT_IN_FLAGS,
 		       MC_CMD_REBOOT_FLAGS_AFTER_ASSERTION);
-	efx_mcdi_rpc(efx, MC_CMD_REBOOT, inbuf, MC_CMD_REBOOT_IN_LEN,
-		     NULL, 0, NULL);
+	(void) efx_mcdi_rpc(efx, MC_CMD_REBOOT, inbuf, MC_CMD_REBOOT_IN_LEN,
+			    NULL, 0, NULL);
 }
 
 int efx_mcdi_handle_assertion(struct efx_nic *efx)
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
