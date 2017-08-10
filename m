From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 05/10] netvsc: no need to allocate send/receive on numa node
Date: Wed,  9 Aug 2017 17:46:07 -0700
Message-ID: <20170810004612.22163-6-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34696 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdHJAqV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:46:21 -0400
Received: by mail-pf0-f171.google.com with SMTP id o86so34362337pfj.1
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:46:20 -0700 (PDT)
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The send and receive buffers are both per-device (not per-channel).
The associated NUMA node is a property of the CPU which is per-channel
therefore it makes no sense to force the receive/send buffer to be
allocated on a particular node (since it is a shared resource).

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index c842265d1df9..91b0674cfdb0 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -245,20 +245,13 @@ int netvsc_alloc_recv_comp_ring(struct netvsc_device *net_device, u32 q_idx)
 static int netvsc_init_buf(struct hv_device *device,
 			   struct netvsc_device *net_device)
 {
-	int ret = 0;
-	struct nvsp_message *init_packet;
 	struct nvsp_1_message_send_receive_buffer_complete *resp;
-	struct net_device *ndev;
+	struct net_device *ndev = hv_get_drvdata(device);
+	struct nvsp_message *init_packet;
 	size_t map_words;
-	int node;
-
-	ndev = hv_get_drvdata(device);
-
-	node = cpu_to_node(device->channel->target_cpu);
-	net_device->recv_buf = vzalloc_node(net_device->recv_buf_size, node);
-	if (!net_device->recv_buf)
-		net_device->recv_buf = vzalloc(net_device->recv_buf_size);
+	int ret = 0;
 
+	net_device->recv_buf = vzalloc(net_device->recv_buf_size);
 	if (!net_device->recv_buf) {
 		netdev_err(ndev, "unable to allocate receive "
 			"buffer of size %d\n", net_device->recv_buf_size);
@@ -339,9 +332,7 @@ static int netvsc_init_buf(struct hv_device *device,
 		goto cleanup;
 
 	/* Now setup the send buffer. */
-	net_device->send_buf = vzalloc_node(net_device->send_buf_size, node);
-	if (!net_device->send_buf)
-		net_device->send_buf = vzalloc(net_device->send_buf_size);
+	net_device->send_buf = vzalloc(net_device->send_buf_size);
 	if (!net_device->send_buf) {
 		netdev_err(ndev, "unable to allocate send "
 			   "buffer of size %d\n", net_device->send_buf_size);
-- 
2.11.0
