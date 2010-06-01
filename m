From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/12] sfc: Wait for the link to stay up before running
 loopback selftest
Date: Tue, 01 Jun 2010 22:18:28 +0100
Message-ID: <1275427108.2114.30.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50603 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab0FAVSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:18:31 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

It's been observed that some phys (such as the qt2025c) can
do down-up-down-up transitions, presumably as pcs block lock
settles down.

The loopback selftest will start sending data immediately
after the link comes up. Work around this by waiting for
the link state to stay up for two consecutive polls, rather
than one.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 371e86c..52ac14a 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -545,7 +545,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 static int efx_wait_for_link(struct efx_nic *efx)
 {
 	struct efx_link_state *link_state = &efx->link_state;
-	int count;
+	int count, link_up_count = 0;
 	bool link_up;
 
 	for (count = 0; count < 40; count++) {
@@ -567,8 +567,12 @@ static int efx_wait_for_link(struct efx_nic *efx)
 			link_up = !efx->mac_op->check_fault(efx);
 		mutex_unlock(&efx->mac_lock);
 
-		if (link_up)
-			return 0;
+		if (link_up) {
+			if (++link_up_count == 2)
+				return 0;
+		} else {
+			link_up_count = 0;
+		}
 	}
 
 	return -ETIMEDOUT;
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

