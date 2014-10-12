From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 08/25] virtio-net: drop config_mutex
Date: Sun, 12 Oct 2014 14:47:07 +0300
Message-ID: <1413114332-626-9-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

config_mutex served two purposes: prevent multiple concurrent config
change handlers, and synchronize access to config_enable flag.

Since commit dbf2576e37da0fcc7aacbfbb9fd5d3de7888a3c1
    workqueue: make all workqueues non-reentrant
all workqueues are non-reentrant, and config_enable
is now gone.

Get rid of the unnecessary lock.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/net/virtio_net.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 743fb04..23e4a69 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -132,9 +132,6 @@ struct virtnet_info {
 	/* Work struct for config space updates */
 	struct work_struct config_work;
 
-	/* Lock for config space updates */
-	struct mutex config_lock;
-
 	/* Does the affinity hint is set for virtqueues? */
 	bool affinity_hint_set;
 
@@ -1404,7 +1401,6 @@ static void virtnet_config_changed_work(struct work_struct *work)
 		container_of(work, struct virtnet_info, config_work);
 	u16 v;
 
-	mutex_lock(&vi->config_lock);
 	if (virtio_cread_feature(vi->vdev, VIRTIO_NET_F_STATUS,
 				 struct virtio_net_config, status, &v) < 0)
 		goto done;
@@ -1430,7 +1426,7 @@ static void virtnet_config_changed_work(struct work_struct *work)
 		netif_tx_stop_all_queues(vi->dev);
 	}
 done:
-	mutex_unlock(&vi->config_lock);
+	return;
 }
 
 static void virtnet_config_changed(struct virtio_device *vdev)
@@ -1751,7 +1747,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 		u64_stats_init(&virtnet_stats->rx_syncp);
 	}
 
-	mutex_init(&vi->config_lock);
 	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
-- 
MST
