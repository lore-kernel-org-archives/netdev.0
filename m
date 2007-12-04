From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: recovery deadlock fix
Date: Mon, 3 Dec 2007 17:02:17 -0800
Message-ID: <20071203170217.492d9eb9@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58280 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbXLDBD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 20:03:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent deadlock in sky2 recovery logic. sky2_down calls napi_synchronize
which gets stuck if napi was already disabled. 

Fix by rearranging slightly and not calling napi_disable until after
both ports are stopped. The napi_disable probably is being overly
paranoid, but it is safe now.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please apply for 2.6.24 (upstream-fixes)

--- a/drivers/net/sky2.c	2007-11-30 16:51:50.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-30 16:54:52.000000000 -0800
@@ -2906,16 +2906,14 @@ static void sky2_restart(struct work_str
 	int i, err;
 
 	rtnl_lock();
-	sky2_write32(hw, B0_IMSK, 0);
-	sky2_read32(hw, B0_IMSK);
-	napi_disable(&hw->napi);
-
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
 		if (netif_running(dev))
 			sky2_down(dev);
 	}
 
+	napi_disable(&hw->napi);
+	sky2_write32(hw, B0_IMSK, 0);
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
