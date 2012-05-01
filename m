From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 11/13 v4] usb/net: rndis: merge command codes
Date: Tue,  1 May 2012 20:23:37 +0200
Message-ID: <1335896617-13627-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:60791 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757977Ab2EASXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 14:23:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch the hyperv filter and rndis gadget driver to use the same command
enumerators as the other drivers and delete the surplus command codes.

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/hyperv/rndis_filter.c |   42 ++++++++++++++++++------------------
 drivers/usb/gadget/rndis.c        |   37 +++++++++++++++----------------
 include/linux/rndis.h             |   17 ---------------
 3 files changed, 39 insertions(+), 57 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 0d10348..981ebb1 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -129,8 +129,8 @@ static void dump_rndis_message(struct hv_device *hv_dev,
 	netdev = net_device->ndev;
 
 	switch (rndis_msg->ndis_msg_type) {
-	case REMOTE_NDIS_PACKET_MSG:
-		netdev_dbg(netdev, "REMOTE_NDIS_PACKET_MSG (len %u, "
+	case RNDIS_MSG_PACKET:
+		netdev_dbg(netdev, "RNDIS_MSG_PACKET (len %u, "
 			   "data offset %u data len %u, # oob %u, "
 			   "oob offset %u, oob len %u, pkt offset %u, "
 			   "pkt len %u\n",
@@ -144,8 +144,8 @@ static void dump_rndis_message(struct hv_device *hv_dev,
 			   rndis_msg->msg.pkt.per_pkt_info_len);
 		break;
 
-	case REMOTE_NDIS_INITIALIZE_CMPLT:
-		netdev_dbg(netdev, "REMOTE_NDIS_INITIALIZE_CMPLT "
+	case RNDIS_MSG_INIT_C:
+		netdev_dbg(netdev, "RNDIS_MSG_INIT_C "
 			"(len %u, id 0x%x, status 0x%x, major %d, minor %d, "
 			"device flags %d, max xfer size 0x%x, max pkts %u, "
 			"pkt aligned %u)\n",
@@ -162,8 +162,8 @@ static void dump_rndis_message(struct hv_device *hv_dev,
 			   pkt_alignment_factor);
 		break;
 
-	case REMOTE_NDIS_QUERY_CMPLT:
-		netdev_dbg(netdev, "REMOTE_NDIS_QUERY_CMPLT "
+	case RNDIS_MSG_QUERY_C:
+		netdev_dbg(netdev, "RNDIS_MSG_QUERY_C "
 			"(len %u, id 0x%x, status 0x%x, buf len %u, "
 			"buf offset %u)\n",
 			rndis_msg->msg_len,
@@ -175,16 +175,16 @@ static void dump_rndis_message(struct hv_device *hv_dev,
 			   info_buf_offset);
 		break;
 
-	case REMOTE_NDIS_SET_CMPLT:
+	case RNDIS_MSG_SET_C:
 		netdev_dbg(netdev,
-			"REMOTE_NDIS_SET_CMPLT (len %u, id 0x%x, status 0x%x)\n",
+			"RNDIS_MSG_SET_C (len %u, id 0x%x, status 0x%x)\n",
 			rndis_msg->msg_len,
 			rndis_msg->msg.set_complete.req_id,
 			rndis_msg->msg.set_complete.status);
 		break;
 
-	case REMOTE_NDIS_INDICATE_STATUS_MSG:
-		netdev_dbg(netdev, "REMOTE_NDIS_INDICATE_STATUS_MSG "
+	case RNDIS_MSG_INDICATE:
+		netdev_dbg(netdev, "RNDIS_MSG_INDICATE "
 			"(len %u, status 0x%x, buf len %u, buf offset %u)\n",
 			rndis_msg->msg_len,
 			rndis_msg->msg.indicate_status.status,
@@ -264,7 +264,7 @@ static void rndis_filter_receive_response(struct rndis_device *dev,
 				sizeof(struct rndis_filter_packet));
 
 			if (resp->ndis_msg_type ==
-			    REMOTE_NDIS_RESET_CMPLT) {
+			    RNDIS_MSG_RESET_C) {
 				/* does not have a request id field */
 				request->response_msg.msg.reset_complete.
 					status = RNDIS_STATUS_BUFFER_OVERFLOW;
@@ -415,19 +415,19 @@ int rndis_filter_receive(struct hv_device *dev,
 	dump_rndis_message(dev, rndis_msg);
 
 	switch (rndis_msg->ndis_msg_type) {
-	case REMOTE_NDIS_PACKET_MSG:
+	case RNDIS_MSG_PACKET:
 		/* data msg */
 		rndis_filter_receive_data(rndis_dev, rndis_msg, pkt);
 		break;
 
-	case REMOTE_NDIS_INITIALIZE_CMPLT:
-	case REMOTE_NDIS_QUERY_CMPLT:
-	case REMOTE_NDIS_SET_CMPLT:
+	case RNDIS_MSG_INIT_C:
+	case RNDIS_MSG_QUERY_C:
+	case RNDIS_MSG_SET_C:
 		/* completion msgs */
 		rndis_filter_receive_response(rndis_dev, rndis_msg);
 		break;
 
-	case REMOTE_NDIS_INDICATE_STATUS_MSG:
+	case RNDIS_MSG_INDICATE:
 		/* notification msgs */
 		rndis_filter_receive_indicate_status(rndis_dev, rndis_msg);
 		break;
@@ -456,7 +456,7 @@ static int rndis_filter_query_device(struct rndis_device *dev, u32 oid,
 		return -EINVAL;
 
 	*result_size = 0;
-	request = get_rndis_request(dev, REMOTE_NDIS_QUERY_MSG,
+	request = get_rndis_request(dev, RNDIS_MSG_QUERY,
 			RNDIS_MESSAGE_SIZE(struct rndis_query_request));
 	if (!request) {
 		ret = -ENOMEM;
@@ -536,7 +536,7 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 
 	ndev = dev->net_dev->ndev;
 
-	request = get_rndis_request(dev, REMOTE_NDIS_SET_MSG,
+	request = get_rndis_request(dev, RNDIS_MSG_SET,
 			RNDIS_MESSAGE_SIZE(struct rndis_set_request) +
 			sizeof(u32));
 	if (!request) {
@@ -588,7 +588,7 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 	u32 status;
 	int ret, t;
 
-	request = get_rndis_request(dev, REMOTE_NDIS_INITIALIZE_MSG,
+	request = get_rndis_request(dev, RNDIS_MSG_INIT,
 			RNDIS_MESSAGE_SIZE(struct rndis_initialize_request));
 	if (!request) {
 		ret = -ENOMEM;
@@ -641,7 +641,7 @@ static void rndis_filter_halt_device(struct rndis_device *dev)
 	struct rndis_halt_request *halt;
 
 	/* Attempt to do a rndis device halt */
-	request = get_rndis_request(dev, REMOTE_NDIS_HALT_MSG,
+	request = get_rndis_request(dev, RNDIS_MSG_HALT,
 				RNDIS_MESSAGE_SIZE(struct rndis_halt_request));
 	if (!request)
 		goto cleanup;
@@ -805,7 +805,7 @@ int rndis_filter_send(struct hv_device *dev,
 	if (isvlan)
 		rndis_msg_size += NDIS_VLAN_PPI_SIZE;
 
-	rndis_msg->ndis_msg_type = REMOTE_NDIS_PACKET_MSG;
+	rndis_msg->ndis_msg_type = RNDIS_MSG_PACKET;
 	rndis_msg->msg_len = pkt->total_data_buflen +
 				      rndis_msg_size;
 
diff --git a/drivers/usb/gadget/rndis.c b/drivers/usb/gadget/rndis.c
index d9086ca..d747e89 100644
--- a/drivers/usb/gadget/rndis.c
+++ b/drivers/usb/gadget/rndis.c
@@ -577,7 +577,7 @@ static int rndis_init_response(int configNr, rndis_init_msg_type *buf)
 		return -ENOMEM;
 	resp = (rndis_init_cmplt_type *)r->buf;
 
-	resp->MessageType = cpu_to_le32(REMOTE_NDIS_INITIALIZE_CMPLT);
+	resp->MessageType = cpu_to_le32(RNDIS_MSG_INIT_C);
 	resp->MessageLength = cpu_to_le32(52);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
 	resp->Status = cpu_to_le32(RNDIS_STATUS_SUCCESS);
@@ -621,7 +621,7 @@ static int rndis_query_response(int configNr, rndis_query_msg_type *buf)
 		return -ENOMEM;
 	resp = (rndis_query_cmplt_type *)r->buf;
 
-	resp->MessageType = cpu_to_le32(REMOTE_NDIS_QUERY_CMPLT);
+	resp->MessageType = cpu_to_le32(RNDIS_MSG_QUERY_C);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
 
 	if (gen_ndis_query_resp(configNr, le32_to_cpu(buf->OID),
@@ -668,7 +668,7 @@ static int rndis_set_response(int configNr, rndis_set_msg_type *buf)
 	pr_debug("\n");
 #endif
 
-	resp->MessageType = cpu_to_le32(REMOTE_NDIS_SET_CMPLT);
+	resp->MessageType = cpu_to_le32(RNDIS_MSG_SET_C);
 	resp->MessageLength = cpu_to_le32(16);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
 	if (gen_ndis_set_resp(configNr, le32_to_cpu(buf->OID),
@@ -692,7 +692,7 @@ static int rndis_reset_response(int configNr, rndis_reset_msg_type *buf)
 		return -ENOMEM;
 	resp = (rndis_reset_cmplt_type *)r->buf;
 
-	resp->MessageType = cpu_to_le32(REMOTE_NDIS_RESET_CMPLT);
+	resp->MessageType = cpu_to_le32(RNDIS_MSG_RESET_C);
 	resp->MessageLength = cpu_to_le32(16);
 	resp->Status = cpu_to_le32(RNDIS_STATUS_SUCCESS);
 	/* resent information */
@@ -716,8 +716,7 @@ static int rndis_keepalive_response(int configNr,
 		return -ENOMEM;
 	resp = (rndis_keepalive_cmplt_type *)r->buf;
 
-	resp->MessageType = cpu_to_le32(
-			REMOTE_NDIS_KEEPALIVE_CMPLT);
+	resp->MessageType = cpu_to_le32(RNDIS_MSG_KEEPALIVE_C);
 	resp->MessageLength = cpu_to_le32(16);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
 	resp->Status = cpu_to_le32(RNDIS_STATUS_SUCCESS);
@@ -745,7 +744,7 @@ static int rndis_indicate_status_msg(int configNr, u32 status)
 		return -ENOMEM;
 	resp = (rndis_indicate_status_msg_type *)r->buf;
 
-	resp->MessageType = cpu_to_le32(REMOTE_NDIS_INDICATE_STATUS_MSG);
+	resp->MessageType = cpu_to_le32(RNDIS_MSG_INDICATE);
 	resp->MessageLength = cpu_to_le32(20);
 	resp->Status = cpu_to_le32(status);
 	resp->StatusBufferLength = cpu_to_le32(0);
@@ -817,15 +816,15 @@ int rndis_msg_parser(u8 configNr, u8 *buf)
 
 	/* For USB: responses may take up to 10 seconds */
 	switch (MsgType) {
-	case REMOTE_NDIS_INITIALIZE_MSG:
-		pr_debug("%s: REMOTE_NDIS_INITIALIZE_MSG\n",
+	case RNDIS_MSG_INIT:
+		pr_debug("%s: RNDIS_MSG_INIT\n",
 			__func__);
 		params->state = RNDIS_INITIALIZED;
 		return rndis_init_response(configNr,
 					(rndis_init_msg_type *)buf);
 
-	case REMOTE_NDIS_HALT_MSG:
-		pr_debug("%s: REMOTE_NDIS_HALT_MSG\n",
+	case RNDIS_MSG_HALT:
+		pr_debug("%s: RNDIS_MSG_HALT\n",
 			__func__);
 		params->state = RNDIS_UNINITIALIZED;
 		if (params->dev) {
@@ -834,24 +833,24 @@ int rndis_msg_parser(u8 configNr, u8 *buf)
 		}
 		return 0;
 
-	case REMOTE_NDIS_QUERY_MSG:
+	case RNDIS_MSG_QUERY:
 		return rndis_query_response(configNr,
 					(rndis_query_msg_type *)buf);
 
-	case REMOTE_NDIS_SET_MSG:
+	case RNDIS_MSG_SET:
 		return rndis_set_response(configNr,
 					(rndis_set_msg_type *)buf);
 
-	case REMOTE_NDIS_RESET_MSG:
-		pr_debug("%s: REMOTE_NDIS_RESET_MSG\n",
+	case RNDIS_MSG_RESET:
+		pr_debug("%s: RNDIS_MSG_RESET\n",
 			__func__);
 		return rndis_reset_response(configNr,
 					(rndis_reset_msg_type *)buf);
 
-	case REMOTE_NDIS_KEEPALIVE_MSG:
+	case RNDIS_MSG_KEEPALIVE:
 		/* For USB: host does this every 5 seconds */
 		if (rndis_debug > 1)
-			pr_debug("%s: REMOTE_NDIS_KEEPALIVE_MSG\n",
+			pr_debug("%s: RNDIS_MSG_KEEPALIVE\n",
 				__func__);
 		return rndis_keepalive_response(configNr,
 						 (rndis_keepalive_msg_type *)
@@ -963,7 +962,7 @@ void rndis_add_hdr(struct sk_buff *skb)
 		return;
 	header = (void *)skb_push(skb, sizeof(*header));
 	memset(header, 0, sizeof *header);
-	header->MessageType = cpu_to_le32(REMOTE_NDIS_PACKET_MSG);
+	header->MessageType = cpu_to_le32(RNDIS_MSG_PACKET);
 	header->MessageLength = cpu_to_le32(skb->len);
 	header->DataOffset = cpu_to_le32(36);
 	header->DataLength = cpu_to_le32(skb->len - sizeof(*header));
@@ -1031,7 +1030,7 @@ int rndis_rm_hdr(struct gether *port,
 	__le32 *tmp = (void *)skb->data;
 
 	/* MessageType, MessageLength */
-	if (cpu_to_le32(REMOTE_NDIS_PACKET_MSG)
+	if (cpu_to_le32(RNDIS_MSG_PACKET)
 			!= get_unaligned(tmp++)) {
 		dev_kfree_skb_any(skb);
 		return -EINVAL;
diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index bdad7ab..18a27a4 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -199,23 +199,6 @@
 #define RNDIS_MAJOR_VERSION		0x00000001
 #define RNDIS_MINOR_VERSION		0x00000000
 
-/* Message Set for Connectionless (802.3) Devices */
-#define REMOTE_NDIS_PACKET_MSG		0x00000001U
-#define REMOTE_NDIS_INITIALIZE_MSG	0x00000002U	/* Initialize device */
-#define REMOTE_NDIS_HALT_MSG		0x00000003U
-#define REMOTE_NDIS_QUERY_MSG		0x00000004U
-#define REMOTE_NDIS_SET_MSG		0x00000005U
-#define REMOTE_NDIS_RESET_MSG		0x00000006U
-#define REMOTE_NDIS_INDICATE_STATUS_MSG	0x00000007U
-#define REMOTE_NDIS_KEEPALIVE_MSG	0x00000008U
-
-/* Message completion */
-#define REMOTE_NDIS_INITIALIZE_CMPLT	0x80000002U
-#define REMOTE_NDIS_QUERY_CMPLT		0x80000004U
-#define REMOTE_NDIS_SET_CMPLT		0x80000005U
-#define REMOTE_NDIS_RESET_CMPLT		0x80000006U
-#define REMOTE_NDIS_KEEPALIVE_CMPLT	0x80000008U
-
 /* Device Flags */
 #define RNDIS_DF_CONNECTIONLESS		0x00000001U
 #define RNDIS_DF_CONNECTION_ORIENTED	0x00000002U
-- 
1.7.7.6
