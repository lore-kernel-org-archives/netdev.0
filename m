From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] netvsc: avoid race with callback
Date: Thu, 16 Mar 2017 16:12:37 -0700
Message-ID: <20170316231239.12996-2-sthemmin@microsoft.com>
References: <20170316231239.12996-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net, haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33159 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751185AbdCPXpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:45:02 -0400
Received: by mail-pf0-f182.google.com with SMTP id w189so31306478pfb.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 16:45:02 -0700 (PDT)
In-Reply-To: <20170316231239.12996-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the argument to channel callback from the channel pointer
to the internal data structure containing per-channel info.
This avoids any possible races when callback happens during
initialization and makes IRQ code simpler.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c       | 18 +++++-------------
 drivers/net/hyperv/rndis_filter.c | 15 ++++++++++-----
 2 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0e71164849dd..0a2e9bd98d2c 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1250,21 +1250,12 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 
 void netvsc_channel_cb(void *context)
 {
-	struct vmbus_channel *channel = context;
-	struct hv_device *device = netvsc_channel_to_device(channel);
-	u16 q_idx = channel->offermsg.offer.sub_channel_index;
-	struct netvsc_device *net_device;
-	struct net_device *ndev;
-
-	ndev = hv_get_drvdata(device);
-	if (unlikely(!ndev))
-		return;
+	struct netvsc_channel *nvchan = context;
 
 	/* disable interupts from host */
-	hv_begin_read(&channel->inbound);
+	hv_begin_read(&nvchan->channel->inbound);
 
-	net_device = net_device_to_netvsc_device(ndev);
-	napi_schedule(&net_device->chan_table[q_idx].napi);
+	napi_schedule(&nvchan->napi);
 }
 
 /*
@@ -1294,7 +1285,8 @@ int netvsc_device_add(struct hv_device *device,
 	/* Open the channel */
 	ret = vmbus_open(device->channel, ring_size * PAGE_SIZE,
 			 ring_size * PAGE_SIZE, NULL, 0,
-			 netvsc_channel_cb, device->channel);
+			 netvsc_channel_cb,
+			 net_device->chan_table);
 
 	if (ret != 0) {
 		netdev_err(ndev, "unable to open channel: %d\n", ret);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index d7b6311e6c19..382b9a62e3c4 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -996,23 +996,28 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 		hv_get_drvdata(new_sc->primary_channel->device_obj);
 	struct netvsc_device *nvscdev = net_device_to_netvsc_device(ndev);
 	u16 chn_index = new_sc->offermsg.offer.sub_channel_index;
-	int ret;
+	struct netvsc_channel *nvchan;
 	unsigned long flags;
+	int ret;
 
 	if (chn_index >= nvscdev->num_chn)
 		return;
 
-	nvscdev->chan_table[chn_index].mrc.buf
+	nvchan = nvscdev->chan_table + chn_index;
+	nvchan->mrc.buf
 		= vzalloc(NETVSC_RECVSLOT_MAX * sizeof(struct recv_comp_data));
 
+	if (!nvchan->mrc.buf)
+		return;
+
 	ret = vmbus_open(new_sc, nvscdev->ring_size * PAGE_SIZE,
 			 nvscdev->ring_size * PAGE_SIZE, NULL, 0,
-			 netvsc_channel_cb, new_sc);
+			 netvsc_channel_cb, nvchan);
 
 	if (ret == 0)
-		nvscdev->chan_table[chn_index].channel = new_sc;
+		nvchan->channel = new_sc;
 
-	napi_enable(&nvscdev->chan_table[chn_index].napi);
+	napi_enable(&nvchan->napi);
 
 	spin_lock_irqsave(&nvscdev->sc_lock, flags);
 	nvscdev->num_sc_offered--;
-- 
2.11.0
