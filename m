From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 10/10] netvsc: keep track of some non-fatal overload conditions
Date: Wed,  9 Aug 2017 17:46:12 -0700
Message-ID: <20170810004612.22163-11-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36531 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752547AbdHJAq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:46:27 -0400
Received: by mail-pg0-f44.google.com with SMTP id v77so34436601pgb.3
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:46:26 -0700 (PDT)
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool statistics for case where send chimmeny buffer is
exhausted and driver has to fall back to doing scatter/gather
send. Also, add statistic for case where ring buffer is full and
receive completions are delayed.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |  2 ++
 drivers/net/hyperv/netvsc.c     | 19 +++++++++++++------
 drivers/net/hyperv/netvsc_drv.c |  2 ++
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 4ccfc335a356..345786321879 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -680,6 +680,8 @@ struct netvsc_ethtool_stats {
 	unsigned long tx_no_space;
 	unsigned long tx_too_big;
 	unsigned long tx_busy;
+	unsigned long tx_send_full;
+	unsigned long rx_comp_busy;
 };
 
 struct netvsc_vf_pcpu_stats {
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 5b3a2b8fa77e..938c9f3d2ea6 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -882,7 +882,9 @@ int netvsc_send(struct net_device_context *ndev_ctx,
 	} else if (pktlen + net_device->pkt_align <
 		   net_device->send_section_size) {
 		section_index = netvsc_get_next_send_section(net_device);
-		if (section_index != NETVSC_INVALID_INDEX) {
+		if (unlikely(section_index == NETVSC_INVALID_INDEX)) {
+			++ndev_ctx->eth_stats.tx_send_full;
+		} else {
 			move_pkt_msd(&msd_send, &msd_skb, msdp);
 			msd_len = 0;
 		}
@@ -948,9 +950,10 @@ int netvsc_send(struct net_device_context *ndev_ctx,
 }
 
 /* Send pending recv completions */
-static int send_recv_completions(struct netvsc_channel *nvchan)
+static int send_recv_completions(struct net_device *ndev,
+				 struct netvsc_device *nvdev,
+				 struct netvsc_channel *nvchan)
 {
-	struct netvsc_device *nvdev = nvchan->net_device;
 	struct multi_recv_comp *mrc = &nvchan->mrc;
 	struct recv_comp_msg {
 		struct nvsp_message_header hdr;
@@ -968,8 +971,12 @@ static int send_recv_completions(struct netvsc_channel *nvchan)
 		msg.status = rcd->status;
 		ret = vmbus_sendpacket(nvchan->channel, &msg, sizeof(msg),
 				       rcd->tid, VM_PKT_COMP, 0);
-		if (unlikely(ret))
+		if (unlikely(ret)) {
+			struct net_device_context *ndev_ctx = netdev_priv(ndev);
+
+			++ndev_ctx->eth_stats.rx_comp_busy;
 			return ret;
+		}
 
 		if (++mrc->first == nvdev->recv_completion_cnt)
 			mrc->first = 0;
@@ -1010,7 +1017,7 @@ static void enq_receive_complete(struct net_device *ndev,
 	recv_comp_slot_avail(nvdev, mrc, &filled, &avail);
 
 	if (unlikely(filled > NAPI_POLL_WEIGHT)) {
-		send_recv_completions(nvchan);
+		send_recv_completions(ndev, nvdev, nvchan);
 		recv_comp_slot_avail(nvdev, mrc, &filled, &avail);
 	}
 
@@ -1193,7 +1200,7 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 	 * then re-enable host interrupts
 	 *     and reschedule if ring is not empty.
 	 */
-	if (send_recv_completions(nvchan) == 0 &&
+	if (send_recv_completions(ndev, net_device, nvchan) == 0 &&
 	    work_done < budget &&
 	    napi_complete_done(napi, work_done) &&
 	    hv_end_read(&channel->inbound)) {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 873c83a66cc2..b33f0507c373 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1112,6 +1112,8 @@ static const struct {
 	{ "tx_no_space",  offsetof(struct netvsc_ethtool_stats, tx_no_space) },
 	{ "tx_too_big",	  offsetof(struct netvsc_ethtool_stats, tx_too_big) },
 	{ "tx_busy",	  offsetof(struct netvsc_ethtool_stats, tx_busy) },
+	{ "tx_send_full", offsetof(struct netvsc_ethtool_stats, tx_send_full) },
+	{ "rx_comp_busy", offsetof(struct netvsc_ethtool_stats, rx_comp_busy) },
 }, vf_stats[] = {
 	{ "vf_rx_packets", offsetof(struct netvsc_vf_pcpu_stats, rx_packets) },
 	{ "vf_rx_bytes",   offsetof(struct netvsc_vf_pcpu_stats, rx_bytes) },
-- 
2.11.0
