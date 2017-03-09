From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] netvsc: fix hang on netvsc module removal
Date: Thu,  9 Mar 2017 15:04:15 -0800
Message-ID: <20170309230415.8854-3-sthemmin@microsoft.com>
References: <20170309230415.8854-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36267 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdCIXEW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 18:04:22 -0500
Received: by mail-pf0-f169.google.com with SMTP id o126so34131981pfb.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 15:04:21 -0800 (PST)
In-Reply-To: <20170309230415.8854-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in netvsc_device_remove was incorrectly calling napi_disable
repeatedly on the same element. This would cause attempts
to remove netvsc module to hang.

Fixes: 2506b1dc4bbe ("netvsc: implement NAPI")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0e0c757c1681..8f9aeec2ce0f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -562,8 +562,8 @@ void netvsc_device_remove(struct hv_device *device)
 	/* Now, we can close the channel safely */
 	vmbus_close(device->channel);
 
-	for (i = 0; i < VRSS_CHANNEL_MAX; i++)
-		napi_disable(&net_device->chan_table[0].napi);
+	for (i = 0; i < net_device->num_chn; i++)
+		napi_disable(&net_device->chan_table[i].napi);
 
 	/* Release all resources */
 	free_netvsc_device(net_device);
-- 
2.11.0
