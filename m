From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH] be2net: Revert "make the RX_FILTER command asynchronous" commit
Date: Thu,  3 Sep 2015 07:41:53 -0400
Message-ID: <1441280513-27531-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:52705 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752775AbbICLes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 07:34:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The be_cmd_rx_filter() routine sends a non-embedded cmd to the FW and used
a pre-allocated dma memory to hold the cmd payload. This worked fine when
this cmd was synchronous. This cmd was changed to asynchronous mode by the
commit 8af65c2f4("make the RX_FILTER command asynchronous"). So now when
there are two quick invocations of this cmd, the 2nd request may end up
overwriting the first request, causing FW cmd corruption.

This patch reverts the offending commit and hence fixes the regression.

Fixes: 8af65c2f4("be2net: make the RX_FILTER command asynchronous")
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
David, the culprit commit that this patch is reverting was applied on
the net-next tree. As net-next tree is closed now, I'm assuming you've
merged the net-next tree onto the net tree. Thanks!

 drivers/net/ethernet/emulex/benet/be_cmds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3be1fbd..eb32391 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1968,7 +1968,7 @@ static int __be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
 	}
 
-	status = be_mcc_notify(adapter);
+	status = be_mcc_notify_wait(adapter);
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
-- 
2.4.1
