From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] netvsc: need napi scheduled during removal
Date: Thu,  9 Mar 2017 15:04:14 -0800
Message-ID: <20170309230415.8854-2-sthemmin@microsoft.com>
References: <20170309230415.8854-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35674 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754203AbdCIXEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 18:04:21 -0500
Received: by mail-pf0-f178.google.com with SMTP id j5so34114571pfb.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 15:04:20 -0800 (PST)
In-Reply-To: <20170309230415.8854-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since rndis_halt_device waits until all outstanding sends and
receives are completed. Netvsc device needs to still schedule
NAPI to see those completions.

Fixes: 2506b1dc4bbe ("netvsc: implement NAPI")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index b1328cef9d5a..0e0c757c1681 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -91,15 +91,6 @@ static void free_netvsc_device(struct netvsc_device *nvdev)
 }
 
 
-static inline bool netvsc_channel_idle(const struct netvsc_device *net_device,
-				       u16 q_idx)
-{
-	const struct netvsc_channel *nvchan = &net_device->chan_table[q_idx];
-
-	return atomic_read(&net_device->num_outstanding_recvs) == 0 &&
-		atomic_read(&nvchan->queue_sends) == 0;
-}
-
 static struct netvsc_device *get_outbound_net_device(struct hv_device *device)
 {
 	struct netvsc_device *net_device = hv_device_to_netvsc_device(device);
@@ -1273,13 +1264,10 @@ void netvsc_channel_cb(void *context)
 	if (unlikely(!ndev))
 		return;
 
-	net_device = net_device_to_netvsc_device(ndev);
-	if (unlikely(net_device->destroy) &&
-	    netvsc_channel_idle(net_device, q_idx))
-		return;
-
 	/* disable interupts from host */
 	hv_begin_read(&channel->inbound);
+
+	net_device = net_device_to_netvsc_device(ndev);
 	napi_schedule(&net_device->chan_table[q_idx].napi);
 }
 
-- 
2.11.0
