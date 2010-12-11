From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 5/7] vxge: hotplug stall
Date: Fri, 10 Dec 2010 18:03:00 -0600
Message-ID: <1292025782-16372-5-git-send-email-jon.mason@exar.com>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45252 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646Ab0LKADf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:03:35 -0500
Received: by mail-yw0-f46.google.com with SMTP id 5so2401509ywl.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 16:03:35 -0800 (PST)
In-Reply-To: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When hot-unplugging a vxge adapter while running, the driver's remove
routine prints warning and then stalls the calling thread.  This is due
to vxge_remove calling vxge_device_unregister to unregister the netdev
before calling flush_scheduled_work clear any pending work.  Swapping
the order of these two functions resolves the issue.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 3ec8068..b771e4b 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3439,11 +3439,11 @@ static void vxge_device_unregister(struct __vxge_hw_device *hldev)
 
 	strncpy(buf, dev->name, IFNAMSIZ);
 
+	flush_scheduled_work();
+
 	/* in 2.6 will call stop() if device is up */
 	unregister_netdev(dev);
 
-	flush_scheduled_work();
-
 	vxge_debug_init(vdev->level_trace, "%s: ethernet device unregistered",
 			buf);
 	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d  Exiting...", buf,
-- 
1.7.0.4

