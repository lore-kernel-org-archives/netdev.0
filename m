From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next 2/4] hv_netvsc: protect nvdev->extension with RCU
Date: Tue, 31 Oct 2017 14:42:02 +0100
Message-ID: <20171031134204.15287-3-vkuznets@redhat.com>
References: <20171031134204.15287-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20171031134204.15287-1-vkuznets@redhat.com>
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

rndis_filter_receive() is called from interrupt context and may race with
rndis_filter_device_remove() resetting extension pointer. RNDIS_MSG_HALT
does not help, host may still send us messages after it. Protect extension
pointer with RCU.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/hyperv_net.h   |  2 +-
 drivers/net/hyperv/netvsc_drv.c   | 10 +++++----
 drivers/net/hyperv/rndis_filter.c | 43 +++++++++++++++++++++++++--------------
 3 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 4958bb6b7376..4f003e85781c 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -798,7 +798,7 @@ struct netvsc_device {
 	struct work_struct subchan_work;
 	wait_queue_head_t subchan_open;
 
-	struct rndis_device *extension;
+	struct rndis_device __rcu *extension;
 
 	int ring_size;
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index da216ca4f2b2..8ad018305aa5 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -94,7 +94,7 @@ static int netvsc_open(struct net_device *net)
 
 	netif_tx_wake_all_queues(net);
 
-	rdev = nvdev->extension;
+	rdev = rtnl_dereference(nvdev->extension);
 
 	if (!rdev->link_state)
 		netif_carrier_on(net);
@@ -1431,7 +1431,7 @@ static int netvsc_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;	/* Toeplitz */
 
-	rndis_dev = ndev->extension;
+	rndis_dev = rtnl_dereference(ndev->extension);
 	if (indir) {
 		for (i = 0; i < ITAB_NUM; i++)
 			indir[i] = rndis_dev->rx_table[i];
@@ -1457,7 +1457,7 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
-	rndis_dev = ndev->extension;
+	rndis_dev = rtnl_dereference(ndev->extension);
 	if (indir) {
 		for (i = 0; i < ITAB_NUM; i++)
 			if (indir[i] >= ndev->num_chn)
@@ -1640,7 +1640,7 @@ static void netvsc_link_change(struct work_struct *w)
 	if (!net_device)
 		goto out_unlock;
 
-	rdev = net_device->extension;
+	rdev = rtnl_dereference(net_device->extension);
 
 	next_reconfig = ndev_ctx->last_reconfig + LINKCHANGE_INT;
 	if (time_is_after_jiffies(next_reconfig)) {
@@ -2002,7 +2002,9 @@ static int netvsc_probe(struct hv_device *dev,
 	device_info.recv_sections = NETVSC_DEFAULT_RX;
 	device_info.recv_section_size = NETVSC_RECV_SECTION_SIZE;
 
+	rtnl_lock();
 	nvdev = rndis_filter_device_add(dev, &device_info);
+	rtnl_unlock();
 	if (IS_ERR(nvdev)) {
 		ret = PTR_ERR(nvdev);
 		netdev_err(net, "unable to add netvsc device (ret %d)\n", ret);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 0648eebda829..1c31e2b0216e 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -402,20 +402,27 @@ int rndis_filter_receive(struct net_device *ndev,
 			 void *data, u32 buflen)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
-	struct rndis_device *rndis_dev = net_dev->extension;
+	struct rndis_device *rndis_dev;
 	struct rndis_message *rndis_msg = data;
+	int ret = 0;
+
+	rcu_read_lock_bh();
+
+	rndis_dev = rcu_dereference_bh(net_dev->extension);
 
 	/* Make sure the rndis device state is initialized */
 	if (unlikely(!rndis_dev)) {
 		netif_err(net_device_ctx, rx_err, ndev,
 			  "got rndis message but no rndis device!\n");
-		return NVSP_STAT_FAIL;
+		ret = NVSP_STAT_FAIL;
+		goto unlock;
 	}
 
 	if (unlikely(rndis_dev->state == RNDIS_DEV_UNINITIALIZED)) {
 		netif_err(net_device_ctx, rx_err, ndev,
 			  "got rndis message uninitialized\n");
-		return NVSP_STAT_FAIL;
+		ret = NVSP_STAT_FAIL;
+		goto unlock;
 	}
 
 	if (netif_msg_rx_status(net_device_ctx))
@@ -423,8 +430,9 @@ int rndis_filter_receive(struct net_device *ndev,
 
 	switch (rndis_msg->ndis_msg_type) {
 	case RNDIS_MSG_PACKET:
-		return rndis_filter_receive_data(ndev, rndis_dev, rndis_msg,
-						 channel, data, buflen);
+		ret = rndis_filter_receive_data(ndev, rndis_dev, rndis_msg,
+						channel, data, buflen);
+		break;
 	case RNDIS_MSG_INIT_C:
 	case RNDIS_MSG_QUERY_C:
 	case RNDIS_MSG_SET_C:
@@ -444,7 +452,10 @@ int rndis_filter_receive(struct net_device *ndev,
 		break;
 	}
 
-	return 0;
+unlock:
+	rcu_read_unlock_bh();
+
+	return ret;
 }
 
 static int rndis_filter_query_device(struct rndis_device *dev,
@@ -597,7 +608,7 @@ static int rndis_filter_query_device_mac(struct rndis_device *dev,
 int rndis_filter_set_device_mac(struct netvsc_device *nvdev,
 				const char *mac)
 {
-	struct rndis_device *rdev = nvdev->extension;
+	struct rndis_device *rdev = rtnl_dereference(nvdev->extension);
 	struct rndis_request *request;
 	struct rndis_set_request *set;
 	struct rndis_config_parameter_info *cpi;
@@ -663,7 +674,7 @@ rndis_filter_set_offload_params(struct net_device *ndev,
 				struct netvsc_device *nvdev,
 				struct ndis_offload_params *req_offloads)
 {
-	struct rndis_device *rdev = nvdev->extension;
+	struct rndis_device *rdev = rtnl_dereference(nvdev->extension);
 	struct rndis_request *request;
 	struct rndis_set_request *set;
 	struct ndis_offload_params *offload_params;
@@ -868,7 +879,7 @@ static void rndis_set_multicast(struct work_struct *w)
 
 void rndis_filter_update(struct netvsc_device *nvdev)
 {
-	struct rndis_device *rdev = nvdev->extension;
+	struct rndis_device *rdev = rtnl_dereference(nvdev->extension);
 
 	schedule_work(&rdev->mcast_work);
 }
@@ -1072,7 +1083,7 @@ void rndis_set_subchannel(struct work_struct *w)
 		return;
 	}
 
-	rdev = nvdev->extension;
+	rdev = rtnl_dereference(nvdev->extension);
 	if (!rdev)
 		goto unlock;	/* device was removed */
 
@@ -1167,7 +1178,7 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 	net_device->max_chn = 1;
 	net_device->num_chn = 1;
 
-	net_device->extension = rndis_device;
+	rcu_assign_pointer(net_device->extension, rndis_device);
 	rndis_device->ndev = net;
 
 	/* Send the rndis initialization message */
@@ -1326,12 +1337,14 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 void rndis_filter_device_remove(struct hv_device *dev,
 				struct netvsc_device *net_dev)
 {
-	struct rndis_device *rndis_dev = net_dev->extension;
+	struct rndis_device *rndis_dev = rtnl_dereference(net_dev->extension);
 
 	/* Halt and release the rndis device */
 	rndis_filter_halt_device(rndis_dev);
 
-	net_dev->extension = NULL;
+	rcu_assign_pointer(net_dev->extension, NULL);
+
+	synchronize_rcu();
 
 	netvsc_device_remove(dev);
 	kfree(rndis_dev);
@@ -1345,7 +1358,7 @@ int rndis_filter_open(struct netvsc_device *nvdev)
 	if (atomic_inc_return(&nvdev->open_cnt) != 1)
 		return 0;
 
-	return rndis_filter_open_device(nvdev->extension);
+	return rndis_filter_open_device(rtnl_dereference(nvdev->extension));
 }
 
 int rndis_filter_close(struct netvsc_device *nvdev)
@@ -1356,7 +1369,7 @@ int rndis_filter_close(struct netvsc_device *nvdev)
 	if (atomic_dec_return(&nvdev->open_cnt) != 0)
 		return 0;
 
-	return rndis_filter_close_device(nvdev->extension);
+	return rndis_filter_close_device(rtnl_dereference(nvdev->extension));
 }
 
 bool rndis_filter_opened(const struct netvsc_device *nvdev)
-- 
2.13.6
