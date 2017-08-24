From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] netvsc: fix deadlock betwen link status and removal
Date: Thu, 24 Aug 2017 16:49:16 -0700
Message-ID: <20170824234916.11490-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:37252 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753492AbdHXXtY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 19:49:24 -0400
Received: by mail-pg0-f50.google.com with SMTP id 83so5210977pgb.4
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:49:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a deadlock possible when canceling the link status
delayed work queue. The removal process is run with RTNL held,
and the link status callback is acquring RTNL.

Resolve the issue by using trylock and rescheduling.
If cancel is in process, that block it from happening.

Fixes: 122a5f6410f4 ("staging: hv: use delayed_work for netvsc_send_garp()")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
This should be queued for stable as well. Problem has existed back to 3.10

 drivers/net/hyperv/netvsc_drv.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 0d78727f1a14..d91cbc6c3ca4 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1269,7 +1269,12 @@ static void netvsc_link_change(struct work_struct *w)
 	bool notify = false, reschedule = false;
 	unsigned long flags, next_reconfig, delay;
 
-	rtnl_lock();
+	/* if changes are happening, comeback later */
+	if (!rtnl_trylock()) {
+		schedule_delayed_work(&ndev_ctx->dwork, LINKCHANGE_INT);
+		return;
+	}
+
 	net_device = rtnl_dereference(ndev_ctx->nvdev);
 	if (!net_device)
 		goto out_unlock;
-- 
2.11.0
