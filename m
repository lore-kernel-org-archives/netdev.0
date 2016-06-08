From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2] netvsc: get rid of completion timeouts
Date: Wed,  8 Jun 2016 19:17:41 +0200
Message-ID: <1465406261-20233-1-git-send-email-vkuznets@redhat.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757549AbcFHRRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 13:17:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm hitting 5 second timeout in rndis_filter_set_rss_param() while setting
RSS parameters for the device. When this happens we end up returning
-ETIMEDOUT from the function and rndis_filter_device_add() falls back to
setting

	net_device->max_chn = 1;
        net_device->num_chn = 1;
        net_device->num_sc_offered = 0;

but after a moment the rndis request succeeds and subchannels start to
appear. netvsc_sc_open() does unconditional nvscdev->num_sc_offered-- and
it becomes U32_MAX-1. Consequent rndis_filter_device_remove() will hang
while waiting for all U32_MAX-1 subchannels to appear and this is not
going to happen.

The immediate issue could be solved by adding num_sc_offered > 0 check to
netvsc_sc_open() but we're getting out of sync with the host and it's not
easy to adjust things later, e.g. in this particular case we'll be creating
queues without a user request for it and races are expected. Same applies
to other parts of the driver which have the same completion timeout.

Following the trend in drivers/hv/* code I suggest we remove all these
timeouts completely. As a guest we can always trust the host we're running
on and if the host screws things up there is no easy way to recover anyway.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
---
Changes since v1 RFC:
- Non-RFC
- Restore (net_dev->num_sc_offered > 0) condition in
  rndis_filter_device_remove() as without it we may hang when there are no
  subchannels at all.
- Remove now unused ndev in rndis_filter_set_packet_filter() to fix the build
  warning reported by kbuild robot.
- Added Haiyang's ACK (hopefully it stands with the above mentioned
  changes).
---
 drivers/net/hyperv/netvsc.c       |  14 +----
 drivers/net/hyperv/rndis_filter.c | 117 +++++++++-----------------------------
 2 files changed, 31 insertions(+), 100 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 719cb35..89e0dea 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -249,7 +249,6 @@ static int netvsc_destroy_buf(struct hv_device *device)
 static int netvsc_init_buf(struct hv_device *device)
 {
 	int ret = 0;
-	unsigned long t;
 	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
 	struct net_device *ndev;
@@ -310,9 +309,7 @@ static int netvsc_init_buf(struct hv_device *device)
 		goto cleanup;
 	}
 
-	t = wait_for_completion_timeout(&net_device->channel_init_wait, 5*HZ);
-	BUG_ON(t == 0);
-
+	wait_for_completion(&net_device->channel_init_wait);
 
 	/* Check the response */
 	if (init_packet->msg.v1_msg.
@@ -395,8 +392,7 @@ static int netvsc_init_buf(struct hv_device *device)
 		goto cleanup;
 	}
 
-	t = wait_for_completion_timeout(&net_device->channel_init_wait, 5*HZ);
-	BUG_ON(t == 0);
+	wait_for_completion(&net_device->channel_init_wait);
 
 	/* Check the response */
 	if (init_packet->msg.v1_msg.
@@ -450,7 +446,6 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 {
 	struct net_device *ndev = hv_get_drvdata(device);
 	int ret;
-	unsigned long t;
 
 	memset(init_packet, 0, sizeof(struct nvsp_message));
 	init_packet->hdr.msg_type = NVSP_MSG_TYPE_INIT;
@@ -467,10 +462,7 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 	if (ret != 0)
 		return ret;
 
-	t = wait_for_completion_timeout(&net_device->channel_init_wait, 5*HZ);
-
-	if (t == 0)
-		return -ETIMEDOUT;
+	wait_for_completion(&net_device->channel_init_wait);
 
 	if (init_packet->msg.init_msg.init_complete.status !=
 	    NVSP_STAT_SUCCESS)
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 97c292b..f5bf267 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -466,7 +466,6 @@ static int rndis_filter_query_device(struct rndis_device *dev, u32 oid,
 	struct rndis_query_request *query;
 	struct rndis_query_complete *query_complete;
 	int ret = 0;
-	unsigned long t;
 
 	if (!result)
 		return -EINVAL;
@@ -503,11 +502,7 @@ static int rndis_filter_query_device(struct rndis_device *dev, u32 oid,
 	if (ret != 0)
 		goto cleanup;
 
-	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
-	if (t == 0) {
-		ret = -ETIMEDOUT;
-		goto cleanup;
-	}
+	wait_for_completion(&request->wait_event);
 
 	/* Copy the response back */
 	query_complete = &request->response_msg.msg.query_complete;
@@ -558,7 +553,6 @@ int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
 	u32 extlen = sizeof(struct rndis_config_parameter_info) +
 		2*NWADR_STRLEN + 4*ETH_ALEN;
 	int ret;
-	unsigned long t;
 
 	request = get_rndis_request(rdev, RNDIS_MSG_SET,
 		RNDIS_MESSAGE_SIZE(struct rndis_set_request) + extlen);
@@ -599,21 +593,13 @@ int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac)
 	if (ret != 0)
 		goto cleanup;
 
-	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
-	if (t == 0) {
-		netdev_err(ndev, "timeout before we got a set response...\n");
-		/*
-		 * can't put_rndis_request, since we may still receive a
-		 * send-completion.
-		 */
-		return -EBUSY;
-	} else {
-		set_complete = &request->response_msg.msg.set_complete;
-		if (set_complete->status != RNDIS_STATUS_SUCCESS) {
-			netdev_err(ndev, "Fail to set MAC on host side:0x%x\n",
-				   set_complete->status);
-			ret = -EINVAL;
-		}
+	wait_for_completion(&request->wait_event);
+
+	set_complete = &request->response_msg.msg.set_complete;
+	if (set_complete->status != RNDIS_STATUS_SUCCESS) {
+		netdev_err(ndev, "Fail to set MAC on host side:0x%x\n",
+			   set_complete->status);
+		ret = -EINVAL;
 	}
 
 cleanup:
@@ -635,7 +621,6 @@ rndis_filter_set_offload_params(struct hv_device *hdev,
 	struct rndis_set_complete *set_complete;
 	u32 extlen = sizeof(struct ndis_offload_params);
 	int ret;
-	unsigned long t;
 	u32 vsp_version = nvdev->nvsp_version;
 
 	if (vsp_version <= NVSP_PROTOCOL_VERSION_4) {
@@ -669,20 +654,12 @@ rndis_filter_set_offload_params(struct hv_device *hdev,
 	if (ret != 0)
 		goto cleanup;
 
-	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
-	if (t == 0) {
-		netdev_err(ndev, "timeout before we got aOFFLOAD set response...\n");
-		/* can't put_rndis_request, since we may still receive a
-		 * send-completion.
-		 */
-		return -EBUSY;
-	} else {
-		set_complete = &request->response_msg.msg.set_complete;
-		if (set_complete->status != RNDIS_STATUS_SUCCESS) {
-			netdev_err(ndev, "Fail to set offload on host side:0x%x\n",
-				   set_complete->status);
-			ret = -EINVAL;
-		}
+	wait_for_completion(&request->wait_event);
+	set_complete = &request->response_msg.msg.set_complete;
+	if (set_complete->status != RNDIS_STATUS_SUCCESS) {
+		netdev_err(ndev, "Fail to set offload on host side:0x%x\n",
+			   set_complete->status);
+		ret = -EINVAL;
 	}
 
 cleanup:
@@ -710,7 +687,6 @@ static int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
 	u32 *itab;
 	u8 *keyp;
 	int i, ret;
-	unsigned long t;
 
 	request = get_rndis_request(
 			rdev, RNDIS_MSG_SET,
@@ -753,20 +729,12 @@ static int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
 	if (ret != 0)
 		goto cleanup;
 
-	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
-	if (t == 0) {
-		netdev_err(ndev, "timeout before we got a set response...\n");
-		/* can't put_rndis_request, since we may still receive a
-		 * send-completion.
-		 */
-		return -ETIMEDOUT;
-	} else {
-		set_complete = &request->response_msg.msg.set_complete;
-		if (set_complete->status != RNDIS_STATUS_SUCCESS) {
-			netdev_err(ndev, "Fail to set RSS parameters:0x%x\n",
-				   set_complete->status);
-			ret = -EINVAL;
-		}
+	wait_for_completion(&request->wait_event);
+	set_complete = &request->response_msg.msg.set_complete;
+	if (set_complete->status != RNDIS_STATUS_SUCCESS) {
+		netdev_err(ndev, "Fail to set RSS parameters:0x%x\n",
+			   set_complete->status);
+		ret = -EINVAL;
 	}
 
 cleanup:
@@ -795,8 +763,6 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	struct rndis_set_complete *set_complete;
 	u32 status;
 	int ret;
-	unsigned long t;
-	struct net_device *ndev = dev->ndev;
 
 	request = get_rndis_request(dev, RNDIS_MSG_SET,
 			RNDIS_MESSAGE_SIZE(struct rndis_set_request) +
@@ -819,26 +785,14 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	if (ret != 0)
 		goto cleanup;
 
-	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
+	wait_for_completion(&request->wait_event);
 
-	if (t == 0) {
-		netdev_err(ndev,
-			"timeout before we got a set response...\n");
-		ret = -ETIMEDOUT;
-		/*
-		 * We can't deallocate the request since we may still receive a
-		 * send completion for it.
-		 */
-		goto exit;
-	} else {
-		set_complete = &request->response_msg.msg.set_complete;
-		status = set_complete->status;
-	}
+	set_complete = &request->response_msg.msg.set_complete;
+	status = set_complete->status;
 
 cleanup:
 	if (request)
 		put_rndis_request(dev, request);
-exit:
 	return ret;
 }
 
@@ -850,7 +804,6 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 	struct rndis_initialize_complete *init_complete;
 	u32 status;
 	int ret;
-	unsigned long t;
 	struct net_device_context *net_device_ctx = netdev_priv(dev->ndev);
 	struct netvsc_device *nvdev = net_device_ctx->nvdev;
 
@@ -875,12 +828,7 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 		goto cleanup;
 	}
 
-	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
-
-	if (t == 0) {
-		ret = -ETIMEDOUT;
-		goto cleanup;
-	}
+	wait_for_completion(&request->wait_event);
 
 	init_complete = &request->response_msg.msg.init_complete;
 	status = init_complete->status;
@@ -1014,7 +962,6 @@ int rndis_filter_device_add(struct hv_device *dev,
 	struct netvsc_device_info *device_info = additional_info;
 	struct ndis_offload_params offloads;
 	struct nvsp_message *init_packet;
-	unsigned long t;
 	struct ndis_recv_scale_cap rsscap;
 	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
 	u32 mtu, size;
@@ -1157,11 +1104,8 @@ int rndis_filter_device_add(struct hv_device *dev,
 			       VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
 	if (ret)
 		goto out;
-	t = wait_for_completion_timeout(&net_device->channel_init_wait, 5*HZ);
-	if (t == 0) {
-		ret = -ETIMEDOUT;
-		goto out;
-	}
+	wait_for_completion(&net_device->channel_init_wait);
+
 	if (init_packet->msg.v5_msg.subchn_comp.status !=
 	    NVSP_STAT_SUCCESS) {
 		ret = -ENODEV;
@@ -1200,17 +1144,12 @@ void rndis_filter_device_remove(struct hv_device *dev)
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	struct netvsc_device *net_dev = net_device_ctx->nvdev;
 	struct rndis_device *rndis_dev = net_dev->extension;
-	unsigned long t;
 
 	/* If not all subchannel offers are complete, wait for them until
 	 * completion to avoid race.
 	 */
-	while (net_dev->num_sc_offered > 0) {
-		t = wait_for_completion_timeout(&net_dev->channel_init_wait,
-						10 * HZ);
-		if (t == 0)
-			WARN(1, "Netvsc: Waiting for sub-channel processing");
-	}
+	if (net_dev->num_sc_offered > 0)
+		wait_for_completion(&net_dev->channel_init_wait);
 
 	/* Halt and release the rndis device */
 	rndis_filter_halt_device(rndis_dev);
-- 
2.5.5
