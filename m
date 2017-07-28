From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v3 6/7] netvsc: fix error unwind on device setup failure
Date: Fri, 28 Jul 2017 08:59:46 -0700
Message-ID: <20170728155947.10062-7-sthemmin@microsoft.com>
References: <20170728155947.10062-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35190 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdG1P76 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:59:58 -0400
Received: by mail-pf0-f169.google.com with SMTP id e75so19203026pfj.2
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 08:59:58 -0700 (PDT)
In-Reply-To: <20170728155947.10062-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If setting receive buffer fails, the error unwind would cause
kernel panic because it was not correctly doing RCU and NAPI
unwind.  RCU'd pointer needs to be reset to NULL, and NAPI needs
to be disabled not deleted.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4c709b454d34..db95487807fd 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1307,7 +1307,8 @@ struct netvsc_device *netvsc_device_add(struct hv_device *device,
 	return net_device;
 
 close:
-	netif_napi_del(&net_device->chan_table[0].napi);
+	RCU_INIT_POINTER(net_device_ctx->nvdev, NULL);
+	napi_disable(&net_device->chan_table[0].napi);
 
 	/* Now, we can close the channel safely */
 	vmbus_close(device->channel);
-- 
2.11.0
