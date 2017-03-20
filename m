From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] netvsc: fix NAPI performance regression
Date: Mon, 20 Mar 2017 13:28:04 -0700
Message-ID: <20170320202805.19362-2-sthemmin@microsoft.com>
References: <20170320202805.19362-1-sthemmin@microsoft.com>
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36650 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932250AbdCTU2X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 16:28:23 -0400
Received: by mail-pg0-f44.google.com with SMTP id g2so82382566pge.3
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 13:28:14 -0700 (PDT)
In-Reply-To: <20170320202805.19362-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using NAPI, the single stream performance declined signifcantly
because the poll routine was updating host after every burst
of packets. This excess signalling caused host throttling.

This fix restores the old behavior. Host is only signalled
after the ring has been emptied.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |  1 +
 drivers/net/hyperv/netvsc.c     | 41 ++++++++++++++++++-----------------------
 2 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 6b5f75217694..a33f2ee86044 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -723,6 +723,7 @@ struct net_device_context {
 /* Per channel data */
 struct netvsc_channel {
 	struct vmbus_channel *channel;
+	const struct vmpacket_descriptor *desc;
 	struct napi_struct napi;
 	struct multi_send_data msd;
 	struct multi_recv_comp mrc;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 989b7cd99380..727762d0f13b 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1173,7 +1173,6 @@ static int netvsc_process_raw_pkt(struct hv_device *device,
 				  struct vmbus_channel *channel,
 				  struct netvsc_device *net_device,
 				  struct net_device *ndev,
-				  u64 request_id,
 				  const struct vmpacket_descriptor *desc)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
@@ -1195,7 +1194,7 @@ static int netvsc_process_raw_pkt(struct hv_device *device,
 
 	default:
 		netdev_err(ndev, "unhandled packet type %d, tid %llx\n",
-			   desc->type, request_id);
+			   desc->type, desc->trans_id);
 		break;
 	}
 
@@ -1222,28 +1221,20 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 	u16 q_idx = channel->offermsg.offer.sub_channel_index;
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct netvsc_device *net_device = net_device_to_netvsc_device(ndev);
-	const struct vmpacket_descriptor *desc;
 	int work_done = 0;
 
-	desc = hv_pkt_iter_first(channel);
-	while (desc) {
-		int count;
+	/* If starting a new interval */
+	if (!nvchan->desc)
+		nvchan->desc = hv_pkt_iter_first(channel);
 
-		count = netvsc_process_raw_pkt(device, channel, net_device,
-					       ndev, desc->trans_id, desc);
-		work_done += count;
-		desc = __hv_pkt_iter_next(channel, desc);
-
-		/* If receive packet budget is exhausted, reschedule */
-		if (work_done >= budget) {
-			work_done = budget;
-			break;
-		}
+	while (nvchan->desc && work_done < budget) {
+		work_done += netvsc_process_raw_pkt(device, channel, net_device,
+						    ndev, nvchan->desc);
+		nvchan->desc = hv_pkt_iter_next(channel, nvchan->desc);
 	}
-	hv_pkt_iter_close(channel);
 
-	/* If budget was not exhausted and
-	 * not doing busy poll
+	/* If receive ring was exhausted
+	 * and not doing busy poll
 	 * then re-enable host interrupts
 	 *  and reschedule if ring is not empty.
 	 */
@@ -1253,7 +1244,9 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 		napi_reschedule(napi);
 
 	netvsc_chk_recv_comp(net_device, channel, q_idx);
-	return work_done;
+
+	/* Driver may overshoot since multiple packets per descriptor */
+	return min(work_done, budget);
 }
 
 /* Call back when data is available in host ring buffer.
@@ -1263,10 +1256,12 @@ void netvsc_channel_cb(void *context)
 {
 	struct netvsc_channel *nvchan = context;
 
-	/* disable interupts from host */
-	hv_begin_read(&nvchan->channel->inbound);
+	if (napi_schedule_prep(&nvchan->napi)) {
+		/* disable interupts from host */
+		hv_begin_read(&nvchan->channel->inbound);
 
-	napi_schedule(&nvchan->napi);
+		__napi_schedule(&nvchan->napi);
+	}
 }
 
 /*
-- 
2.11.0
