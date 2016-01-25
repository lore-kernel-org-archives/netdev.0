From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix book keeping of skb during batching
 process
Date: Mon, 25 Jan 2016 09:49:31 -0800
Message-ID: <1453744171-31843-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, haiyangz@microsoft.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Since eliminating send_completion_tid from struct hv_netvsc_packet, we
haven't add proper book keeping for the skb of the batched packet. This
patch fixes this issue and allows the previous skb is properly freed.
Otherwise, a panic may happen.
Thanks to Simon Xiao <sixiao@microsoft.com> for bisecting and analysis.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 +
 drivers/net/hyperv/netvsc.c     |   33 ++++++++++++++++++++++-----------
 2 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index f4130af..fcb92c0 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -624,6 +624,7 @@ struct nvsp_message {
 #define RNDIS_PKT_ALIGN_DEFAULT 8
 
 struct multi_send_data {
+	struct sk_buff *skb; /* skb containing the pkt */
 	struct hv_netvsc_packet *pkt; /* netvsc pkt pending */
 	u32 count; /* counter of batched packets */
 };
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 059fc52..ec313fc 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -841,6 +841,18 @@ static inline int netvsc_send_pkt(
 	return ret;
 }
 
+/* Move packet out of multi send data (msd), and clear msd */
+static inline void move_pkt_msd(struct hv_netvsc_packet **msd_send,
+				struct sk_buff **msd_skb,
+				struct multi_send_data *msdp)
+{
+	*msd_skb = msdp->skb;
+	*msd_send = msdp->pkt;
+	msdp->skb = NULL;
+	msdp->pkt = NULL;
+	msdp->count = 0;
+}
+
 int netvsc_send(struct hv_device *device,
 		struct hv_netvsc_packet *packet,
 		struct rndis_message *rndis_msg,
@@ -855,6 +867,7 @@ int netvsc_send(struct hv_device *device,
 	unsigned int section_index = NETVSC_INVALID_INDEX;
 	struct multi_send_data *msdp;
 	struct hv_netvsc_packet *msd_send = NULL, *cur_send = NULL;
+	struct sk_buff *msd_skb = NULL;
 	bool try_batch;
 	bool xmit_more = (skb != NULL) ? skb->xmit_more : false;
 
@@ -897,10 +910,8 @@ int netvsc_send(struct hv_device *device,
 		   net_device->send_section_size) {
 		section_index = netvsc_get_next_send_section(net_device);
 		if (section_index != NETVSC_INVALID_INDEX) {
-				msd_send = msdp->pkt;
-				msdp->pkt = NULL;
-				msdp->count = 0;
-				msd_len = 0;
+			move_pkt_msd(&msd_send, &msd_skb, msdp);
+			msd_len = 0;
 		}
 	}
 
@@ -919,31 +930,31 @@ int netvsc_send(struct hv_device *device,
 			packet->total_data_buflen += msd_len;
 		}
 
-		if (msdp->pkt)
-			dev_kfree_skb_any(skb);
+		if (msdp->skb)
+			dev_kfree_skb_any(msdp->skb);
 
 		if (xmit_more && !packet->cp_partial) {
+			msdp->skb = skb;
 			msdp->pkt = packet;
 			msdp->count++;
 		} else {
 			cur_send = packet;
+			msdp->skb = NULL;
 			msdp->pkt = NULL;
 			msdp->count = 0;
 		}
 	} else {
-		msd_send = msdp->pkt;
-		msdp->pkt = NULL;
-		msdp->count = 0;
+		move_pkt_msd(&msd_send, &msd_skb, msdp);
 		cur_send = packet;
 	}
 
 	if (msd_send) {
-		m_ret = netvsc_send_pkt(msd_send, net_device, pb, skb);
+		m_ret = netvsc_send_pkt(msd_send, net_device, NULL, msd_skb);
 
 		if (m_ret != 0) {
 			netvsc_free_send_slot(net_device,
 					      msd_send->send_buf_index);
-			dev_kfree_skb_any(skb);
+			dev_kfree_skb_any(msd_skb);
 		}
 	}
 
-- 
1.7.4.1
