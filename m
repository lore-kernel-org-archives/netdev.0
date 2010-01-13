From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Fix polling for slow MCDI operations
Date: Wed, 13 Jan 2010 14:34:25 +0000
Message-ID: <1263393265.2797.4.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50750 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755499Ab0AMOe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 09:34:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the interface is down and we are using polled mode for MCDI
operations, we busy-wait for completion for approximately 1 jiffy
using udelay() and then back off to schedule().  But the completion
will not wake the task, since we are using polled mode!  We must use
schedule_timeout_uninterruptible() instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 683353b..0d4eba7 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -142,8 +142,9 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 		if (spins != 0) {
 			--spins;
 			udelay(1);
-		} else
-			schedule();
+		} else {
+			schedule_timeout_uninterruptible(1);
+		}
 
 		time = get_seconds();
 
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

