From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 6/6] hv_netvsc: set nvdev link after populating chn_table
Date: Fri, 13 May 2016 13:55:25 +0200
Message-ID: <1463140525-27338-7-git-send-email-vkuznets@redhat.com>
References: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	"Lino Sanfilippo" <LinoSanfilippo@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753056AbcEMLzj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 07:55:39 -0400
In-Reply-To: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Crash in netvsc_send() is observed when netvsc device is re-created on
mtu change/set channels. The crash is caused by dereferencing of NULL
channel pointer which comes from chn_table. The root cause is a mixture
of two facts:
- we set nvdev pointer in net_device_context in alloc_net_device()
  before we populate chn_table.
- we populate chn_table[0] only.

The issue could be papered over by checking channel != NULL in
netvsc_send() but populating the whole chn_table and writing the
nvdev pointer afterwards seems more appropriate.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 96b3c32..719cb35 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -60,11 +60,9 @@ void netvsc_switch_datapath(struct net_device *ndev, bool vf)
 }
 
 
-static struct netvsc_device *alloc_net_device(struct hv_device *device)
+static struct netvsc_device *alloc_net_device(void)
 {
 	struct netvsc_device *net_device;
-	struct net_device *ndev = hv_get_drvdata(device);
-	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 
 	net_device = kzalloc(sizeof(struct netvsc_device), GFP_KERNEL);
 	if (!net_device)
@@ -86,8 +84,6 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 	net_device->vf_netdev = NULL;
 	net_device->vf_inject = false;
 
-	net_device_ctx->nvdev = net_device;
-
 	return net_device;
 }
 
@@ -1240,20 +1236,19 @@ void netvsc_channel_cb(void *context)
  */
 int netvsc_device_add(struct hv_device *device, void *additional_info)
 {
-	int ret = 0;
+	int i, ret = 0;
 	int ring_size =
 	((struct netvsc_device_info *)additional_info)->ring_size;
 	struct netvsc_device *net_device;
-	struct net_device *ndev;
+	struct net_device *ndev = hv_get_drvdata(device);
+	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 
-	net_device = alloc_net_device(device);
+	net_device = alloc_net_device();
 	if (!net_device)
 		return -ENOMEM;
 
 	net_device->ring_size = ring_size;
 
-	ndev = hv_get_drvdata(device);
-
 	/* Initialize the NetVSC channel extension */
 	init_completion(&net_device->channel_init_wait);
 
@@ -1272,7 +1267,19 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	/* Channel is opened */
 	pr_info("hv_netvsc channel opened successfully\n");
 
-	net_device->chn_table[0] = device->channel;
+	/* If we're reopening the device we may have multiple queues, fill the
+	 * chn_table with the default channel to use it before subchannels are
+	 * opened.
+	 */
+	for (i = 0; i < VRSS_CHANNEL_MAX; i++)
+		net_device->chn_table[i] = device->channel;
+
+	/* Writing nvdev pointer unlocks netvsc_send(), make sure chn_table is
+	 * populated.
+	 */
+	wmb();
+
+	net_device_ctx->nvdev = net_device;
 
 	/* Connect with the NetVsp */
 	ret = netvsc_connect_vsp(device);
-- 
2.5.5
