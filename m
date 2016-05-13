From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 1/6] hv_netvsc: move start_remove flag to
 net_device_context
Date: Fri, 13 May 2016 13:55:20 +0200
Message-ID: <1463140525-27338-2-git-send-email-vkuznets@redhat.com>
References: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
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

struct netvsc_device is destroyed on mtu change so keeping the
protection flag there is not a good idea. Move it to struct
net_device_context which is preserved.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/hyperv_net.h |  4 +++-
 drivers/net/hyperv/netvsc.c     |  3 +--
 drivers/net/hyperv/netvsc_drv.c | 12 +++++++++---
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 6700a4d..18e9cc8 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -672,6 +672,9 @@ struct net_device_context {
 	/* Ethtool settings */
 	u8 duplex;
 	u32 speed;
+
+	/* the device is going away */
+	bool start_remove;
 };
 
 /* Per netvsc device */
@@ -682,7 +685,6 @@ struct netvsc_device {
 
 	atomic_t num_outstanding_sends;
 	wait_queue_head_t wait_drain;
-	bool start_remove;
 	bool destroy;
 
 	/* Receive buffer allocated by us but manages by NetVSP */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index eddce3c..5e2017b 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -74,7 +74,6 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 	}
 
 	init_waitqueue_head(&net_device->wait_drain);
-	net_device->start_remove = false;
 	net_device->destroy = false;
 	atomic_set(&net_device->open_cnt, 0);
 	atomic_set(&net_device->vf_use_cnt, 0);
@@ -691,7 +690,7 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 			wake_up(&net_device->wait_drain);
 
 		if (netif_tx_queue_stopped(netdev_get_tx_queue(ndev, q_idx)) &&
-		    !net_device->start_remove &&
+		    !net_device->nd_ctx->start_remove &&
 		    (hv_ringbuf_avail_percent(&channel->outbound) >
 		     RING_AVAIL_PERCENT_HIWATER || queue_sends < 1))
 				netif_tx_wake_queue(netdev_get_tx_queue(
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index ba3f3f3..b3fa2cd 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -793,7 +793,7 @@ static int netvsc_set_channels(struct net_device *net,
 		goto out;
 
  do_set:
-	nvdev->start_remove = true;
+	net_device_ctx->start_remove = true;
 	rndis_filter_device_remove(dev);
 
 	nvdev->num_chn = channels->combined_count;
@@ -837,6 +837,7 @@ static int netvsc_set_channels(struct net_device *net,
 
  out:
 	netvsc_open(net);
+	net_device_ctx->start_remove = false;
 
 	return ret;
 
@@ -927,7 +928,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 
 	num_chn = nvdev->num_chn;
 
-	nvdev->start_remove = true;
+	ndevctx->start_remove = true;
 	rndis_filter_device_remove(hdev);
 
 	ndev->mtu = mtu;
@@ -943,6 +944,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 
 out:
 	netvsc_open(ndev);
+	ndevctx->start_remove = false;
 
 	return ret;
 }
@@ -1358,6 +1360,9 @@ static int netvsc_probe(struct hv_device *dev,
 	}
 
 	hv_set_drvdata(dev, net);
+
+	net_device_ctx->start_remove = false;
+
 	INIT_DELAYED_WORK(&net_device_ctx->dwork, netvsc_link_change);
 	INIT_WORK(&net_device_ctx->work, do_set_multicast);
 	INIT_WORK(&net_device_ctx->gwrk.dwrk, netvsc_notify_peers);
@@ -1419,9 +1424,10 @@ static int netvsc_remove(struct hv_device *dev)
 		return 0;
 	}
 
-	net_device->start_remove = true;
 
 	ndev_ctx = netdev_priv(net);
+	ndev_ctx->start_remove = true;
+
 	cancel_delayed_work_sync(&ndev_ctx->dwork);
 	cancel_work_sync(&ndev_ctx->work);
 
-- 
2.5.5
