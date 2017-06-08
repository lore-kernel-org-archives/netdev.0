From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/6] netvsc: fold in get_outbound_net_device
Date: Thu,  8 Jun 2017 16:21:23 -0700
Message-ID: <20170608232123.28366-7-sthemmin@microsoft.com>
References: <20170608232123.28366-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:32806 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdFHXVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 19:21:40 -0400
Received: by mail-pg0-f52.google.com with SMTP id f185so20619924pgc.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 16:21:39 -0700 (PDT)
In-Reply-To: <20170608232123.28366-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer need common code to find get_outbound_net_device.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4d4fde0c7974..7c5ed8fe7a4f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -97,16 +97,6 @@ static void free_netvsc_device_rcu(struct netvsc_device *nvdev)
 	call_rcu(&nvdev->rcu, free_netvsc_device);
 }
 
-static struct netvsc_device *get_outbound_net_device(struct hv_device *device)
-{
-	struct netvsc_device *net_device = hv_device_to_netvsc_device(device);
-
-	if (net_device && net_device->destroy)
-		net_device = NULL;
-
-	return net_device;
-}
-
 static void netvsc_destroy_buf(struct hv_device *device)
 {
 	struct nvsp_message *revoke_packet;
@@ -833,7 +823,7 @@ int netvsc_send(struct hv_device *device,
 		struct hv_page_buffer **pb,
 		struct sk_buff *skb)
 {
-	struct netvsc_device *net_device;
+	struct netvsc_device *net_device = hv_device_to_netvsc_device(device);
 	int ret = 0;
 	struct netvsc_channel *nvchan;
 	u32 pktlen = packet->total_data_buflen, msd_len = 0;
@@ -844,8 +834,8 @@ int netvsc_send(struct hv_device *device,
 	bool try_batch;
 	bool xmit_more = (skb != NULL) ? skb->xmit_more : false;
 
-	net_device = get_outbound_net_device(device);
-	if (unlikely(!net_device))
+	/* If device is rescinded, return error and packet will get dropped. */
+	if (unlikely(net_device->destroy))
 		return -ENODEV;
 
 	/* We may race with netvsc_connect_vsp()/netvsc_init_buf() and get
-- 
2.11.0
