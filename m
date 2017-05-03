From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 12/15] netvsc: size receive completion ring based on receive area
Date: Wed,  3 May 2017 16:01:14 -0700
Message-ID: <20170503230117.20070-13-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35621 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752205AbdECXBj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:39 -0400
Received: by mail-pg0-f43.google.com with SMTP id o3so1962265pgn.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:34 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that receive area is parameterized, also need to adjust the
size of the ring for receive completions based on receive area.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  4 +---
 drivers/net/hyperv/netvsc.c       | 22 ++++++++++++++--------
 drivers/net/hyperv/rndis_filter.c |  5 ++---
 3 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 21666df4cd35..5627003bd8b6 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -653,13 +653,11 @@ struct recv_comp_data {
 	u32 status;
 };
 
-/* Netvsc Receive Slots Max */
-#define NETVSC_RECVSLOT_MAX (NETVSC_RECEIVE_BUFFER_SIZE / ETH_DATA_LEN + 1)
-
 struct multi_recv_comp {
 	void *buf; /* queued receive completions */
 	u32 first; /* first data entry */
 	u32 next; /* next entry for writing */
+	u32 size; /* number of slots in ring */
 };
 
 struct netvsc_stats {
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 767ff20d659e..56e0721f703c 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -61,16 +61,22 @@ void netvsc_switch_datapath(struct net_device *ndev, bool vf)
 			       VM_PKT_DATA_INBAND, 0);
 }
 
-static struct netvsc_device *alloc_net_device(void)
+static struct netvsc_device *alloc_net_device(u32 recvslot_max)
 {
 	struct netvsc_device *net_device;
+	struct multi_recv_comp *mrc;
 
 	net_device = kzalloc(sizeof(struct netvsc_device), GFP_KERNEL);
 	if (!net_device)
 		return NULL;
 
-	net_device->chan_table[0].mrc.buf
-		= vzalloc(NETVSC_RECVSLOT_MAX * sizeof(struct recv_comp_data));
+	mrc = &net_device->chan_table[0].mrc;
+	mrc->size = recvslot_max;
+	mrc->buf = vzalloc(recvslot_max * sizeof(struct recv_comp_data));
+	if (!mrc->buf) {
+		kfree(net_device);
+		return NULL;
+	}
 
 	init_waitqueue_head(&net_device->wait_drain);
 	net_device->destroy = false;
@@ -993,10 +999,10 @@ static inline void count_recv_comp_slot(struct netvsc_device *nvdev, u16 q_idx,
 	u32 first = mrc->first;
 	u32 next = mrc->next;
 
-	*filled = (first > next) ? NETVSC_RECVSLOT_MAX - first + next :
+	*filled = (first > next) ? mrc->size - first + next :
 		  next - first;
 
-	*avail = NETVSC_RECVSLOT_MAX - *filled - 1;
+	*avail = mrc->size - *filled - 1;
 }
 
 /* Read the first filled slot, no change to index */
@@ -1022,7 +1028,7 @@ static inline void put_recv_comp_slot(struct netvsc_device *nvdev, u16 q_idx)
 	struct multi_recv_comp *mrc = &nvdev->chan_table[q_idx].mrc;
 	int num_recv;
 
-	mrc->first = (mrc->first + 1) % NETVSC_RECVSLOT_MAX;
+	mrc->first = (mrc->first + 1) % mrc->size;
 
 	num_recv = atomic_dec_return(&nvdev->num_outstanding_recvs);
 
@@ -1077,7 +1083,7 @@ static inline struct recv_comp_data *get_recv_comp_slot(
 
 	next = mrc->next;
 	rcd = mrc->buf + next * sizeof(struct recv_comp_data);
-	mrc->next = (next + 1) % NETVSC_RECVSLOT_MAX;
+	mrc->next = (next + 1) % mrc->size;
 
 	atomic_inc(&nvdev->num_outstanding_recvs);
 
@@ -1315,7 +1321,7 @@ int netvsc_device_add(struct hv_device *device,
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 
-	net_device = alloc_net_device();
+	net_device = alloc_net_device(device_info->recv_buf_size / ETH_DATA_LEN + 1);
 	if (!net_device)
 		return -ENOMEM;
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index f9d5b0b8209a..bfeaa0549f7f 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -996,9 +996,8 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 		return;
 
 	nvchan = nvscdev->chan_table + chn_index;
-	nvchan->mrc.buf
-		= vzalloc(NETVSC_RECVSLOT_MAX * sizeof(struct recv_comp_data));
-
+	nvchan->mrc.size = nvscdev->recv_buf_size / ETH_DATA_LEN + 1;
+	nvchan->mrc.buf = vzalloc(nvchan->mrc.size * sizeof(struct recv_comp_data));
 	if (!nvchan->mrc.buf)
 		return;
 
-- 
2.11.0
