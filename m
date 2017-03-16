From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netvsc: fix race during initialization
Date: Thu, 16 Mar 2017 12:21:32 -0700
Message-ID: <20170316192132.9095-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36545 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752494AbdCPTsV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:48:21 -0400
Received: by mail-pg0-f54.google.com with SMTP id g2so29876482pge.3
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 12:48:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When device is being setup on boot, there is a small race where
network device callback is registered, but the netvsc_device pointer
is not set yet.  This can cause a NULL ptr dereference if packet
arrives during this window.

Fixes: 46b4f7f5d1f7 ("netvsc: eliminate per-device outstanding send counter")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
Applies to 4.11 only, not in earlier versions.
net-next needs different patch

 drivers/net/hyperv/netvsc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4c1d8cca247b..8dd0b8770328 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1231,8 +1231,11 @@ void netvsc_channel_cb(void *context)
 		return;
 
 	net_device = net_device_to_netvsc_device(ndev);
-	if (unlikely(net_device->destroy) &&
-	    netvsc_channel_idle(net_device, q_idx))
+	if (unlikely(!net_device))
+		return;
+
+	if (unlikely(net_device->destroy &&
+		     netvsc_channel_idle(net_device, q_idx)))
 		return;
 
 	/* commit_rd_index() -> hv_signal_on_read() needs this. */
-- 
2.11.0
