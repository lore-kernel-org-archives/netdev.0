From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/6] netvsc: pass net_device to netvsc_init_buf and netvsc_connect_vsp
Date: Thu,  8 Jun 2017 16:21:22 -0700
Message-ID: <20170608232123.28366-6-sthemmin@microsoft.com>
References: <20170608232123.28366-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34604 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdFHXVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 19:21:38 -0400
Received: by mail-pf0-f180.google.com with SMTP id 9so22043815pfj.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 16:21:38 -0700 (PDT)
In-Reply-To: <20170608232123.28366-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't need to find netvsc_device structure, caller already had it.
Also rearrange declarations.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 31 +++++++++++--------------------
 1 file changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index caf89a245ba6..4d4fde0c7974 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -243,18 +243,15 @@ static void netvsc_destroy_buf(struct hv_device *device)
 	kfree(net_device->send_section_map);
 }
 
-static int netvsc_init_buf(struct hv_device *device)
+static int netvsc_init_buf(struct hv_device *device,
+			   struct netvsc_device *net_device)
 {
 	int ret = 0;
-	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
 	struct net_device *ndev;
 	size_t map_words;
 	int node;
 
-	net_device = get_outbound_net_device(device);
-	if (!net_device)
-		return -ENODEV;
 	ndev = hv_get_drvdata(device);
 
 	node = cpu_to_node(device->channel->target_cpu);
@@ -285,9 +282,7 @@ static int netvsc_init_buf(struct hv_device *device)
 
 	/* Notify the NetVsp of the gpadl handle */
 	init_packet = &net_device->channel_init_pkt;
-
 	memset(init_packet, 0, sizeof(struct nvsp_message));
-
 	init_packet->hdr.msg_type = NVSP_MSG1_TYPE_SEND_RECV_BUF;
 	init_packet->msg.v1_msg.send_recv_buf.
 		gpadl_handle = net_device->recv_buf_gpadl_handle;
@@ -486,20 +481,15 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 	return ret;
 }
 
-static int netvsc_connect_vsp(struct hv_device *device)
+static int netvsc_connect_vsp(struct hv_device *device,
+			      struct netvsc_device *net_device)
 {
-	int ret;
-	struct netvsc_device *net_device;
-	struct nvsp_message *init_packet;
-	int ndis_version;
 	const u32 ver_list[] = {
 		NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
-		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5 };
-	int i;
-
-	net_device = get_outbound_net_device(device);
-	if (!net_device)
-		return -ENODEV;
+		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5
+	};
+	struct nvsp_message *init_packet;
+	int ndis_version, i, ret;
 
 	init_packet = &net_device->channel_init_pkt;
 
@@ -549,7 +539,7 @@ static int netvsc_connect_vsp(struct hv_device *device)
 		net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE;
 	net_device->send_buf_size = NETVSC_SEND_BUFFER_SIZE;
 
-	ret = netvsc_init_buf(device);
+	ret = netvsc_init_buf(device, net_device);
 
 cleanup:
 	return ret;
@@ -1349,7 +1339,7 @@ int netvsc_device_add(struct hv_device *device,
 	rcu_assign_pointer(net_device_ctx->nvdev, net_device);
 
 	/* Connect with the NetVsp */
-	ret = netvsc_connect_vsp(device);
+	ret = netvsc_connect_vsp(device, net_device);
 	if (ret != 0) {
 		netdev_err(ndev,
 			"unable to connect to NetVSP - %d\n", ret);
@@ -1368,4 +1358,5 @@ int netvsc_device_add(struct hv_device *device,
 	free_netvsc_device(&net_device->rcu);
 
 	return ret;
+
 }
-- 
2.11.0
