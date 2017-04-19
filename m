From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netvsc: fix use after free on module removal
Date: Wed, 19 Apr 2017 15:22:02 -0700
Message-ID: <20170419222202.17992-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34801 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965145AbdDSWWP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 18:22:15 -0400
Received: by mail-io0-f172.google.com with SMTP id a103so40855981ioj.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 15:22:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NAPI data structure is embedded in the netvsc_device structure
and is freed when device is closed. There is still a reference
(in NAPI list) to this which causes a crash in netif_napi_del
when device is removed. Fix by managing NAPI instances correctly.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
Note: resend with correct list address

 drivers/net/hyperv/netvsc.c       | 9 +++++----
 drivers/net/hyperv/rndis_filter.c | 9 ++++++---
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index fd21d5aab580..e282bdff7aa0 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -568,8 +568,9 @@ void netvsc_device_remove(struct hv_device *device)
 	/* Now, we can close the channel safely */
 	vmbus_close(device->channel);
 
+	/* And dissassociate NAPI context from device */
 	for (i = 0; i < net_device->num_chn; i++)
-		napi_disable(&net_device->chan_table[i].napi);
+		netif_napi_del(&net_device->chan_table[i].napi);
 
 	/* Release all resources */
 	free_netvsc_device_rcu(net_device);
@@ -1304,8 +1305,6 @@ int netvsc_device_add(struct hv_device *device,
 		struct netvsc_channel *nvchan = &net_device->chan_table[i];
 
 		nvchan->channel = device->channel;
-		netif_napi_add(ndev, &nvchan->napi,
-			       netvsc_poll, NAPI_POLL_WEIGHT);
 	}
 
 	/* Open the channel */
@@ -1323,6 +1322,8 @@ int netvsc_device_add(struct hv_device *device,
 	netdev_dbg(ndev, "hv_netvsc channel opened successfully\n");
 
 	/* Enable NAPI handler for init callbacks */
+	netif_napi_add(ndev, &net_device->chan_table[0].napi,
+		       netvsc_poll, NAPI_POLL_WEIGHT);
 	napi_enable(&net_device->chan_table[0].napi);
 
 	/* Writing nvdev pointer unlocks netvsc_send(), make sure chn_table is
@@ -1341,7 +1342,7 @@ int netvsc_device_add(struct hv_device *device,
 	return ret;
 
 close:
-	napi_disable(&net_device->chan_table[0].napi);
+	netif_napi_del(&net_device->chan_table[0].napi);
 
 	/* Now, we can close the channel safely */
 	vmbus_close(device->channel);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 1e9445bc4539..ab92c3c95951 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1009,13 +1009,16 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 
 	/* Set the channel before opening.*/
 	nvchan->channel = new_sc;
+	netif_napi_add(ndev, &nvchan->napi,
+		       netvsc_poll, NAPI_POLL_WEIGHT);
 
 	ret = vmbus_open(new_sc, nvscdev->ring_size * PAGE_SIZE,
 			 nvscdev->ring_size * PAGE_SIZE, NULL, 0,
 			 netvsc_channel_cb, nvchan);
-
-
-	napi_enable(&nvchan->napi);
+	if (ret == 0)
+		napi_enable(&nvchan->napi);
+	else
+		netdev_err(ndev, "sub channel open failed (%d)\n", ret);
 
 	if (refcount_dec_and_test(&nvscdev->sc_offered))
 		complete(&nvscdev->channel_init_wait);
-- 
2.11.0
