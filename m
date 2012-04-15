From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next V7 PATCH] virtio-net: send gratuitous packets when
	needed
Date: Sun, 15 Apr 2012 10:12:23 +0300
Message-ID: <20120415071223.GC3070@redhat.com>
References: <20120412064351.23243.84912.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20120412064351.23243.84912.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

On Thu, Apr 12, 2012 at 02:43:52PM +0800, Jason Wang wrote:
> As hypervior does not have the knowledge of guest network configuration, it's
> better to ask guest to send gratuitous packets when needed.
> 
> This patch implements VIRTIO_NET_F_GUEST_ANNOUNCE feature: hypervisor would
> notice the guest when it thinks it's time for guest to announce the link
> presnece. Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt
> and woule send gratuitous packets through netif_notify_peers() and ack the
> notification through ctrl vq.
> 
> We need to make sure the atomicy of read and ack in guest otherwise we may ack
> more times than being notified. This is done through handling the whole config
> change interrupt in an non-reentrant workqueue.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> 
> ---
> 
> Changes from v6:
> - move the whole event processing to system_nrt_wq
> - introduce the config_enable and config_lock to synchronize with dev removing
> and pm
> - protect the ack with rtnl_lock
> 
> Changes from v5:
> - notify the chain before acking the link annoucement
> - ack the link announcement notification through control vq
> 
> Changes from v4:
> - typos
> - handle workqueue unconditionally
> - move VIRTIO_NET_S_ANNOUNCE to bit 8 to separate rw bits from ro bits
> 
> Changes from v3:
> - cancel the workqueue during freeze
> 
> Changes from v2:
> - fix the race between unregister_dev() and workqueue
> ---
>  drivers/net/virtio_net.c   |   64 +++++++++++++++++++++++++++++++++++++++++---
>  include/linux/virtio_net.h |   14 ++++++++++
>  2 files changed, 73 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4de2760..23403b6 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -66,12 +66,21 @@ struct virtnet_info {
>  	/* Host will merge rx buffers for big packets (shake it! shake it!) */
>  	bool mergeable_rx_bufs;
>  
> +	/* enable config space updates */
> +	bool config_enable;
> +
>  	/* Active statistics */
>  	struct virtnet_stats __percpu *stats;
>  
>  	/* Work struct for refilling if we run low on memory. */
>  	struct delayed_work refill;
>  
> +	/* Work struct for config space updates */
> +	struct work_struct config_work;
> +
> +	/* Lock for config space updates */
> +	struct mutex config_lock;
> +
>  	/* Chain pages by the private ptr. */
>  	struct page *pages;
>  
> @@ -781,6 +790,16 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
>  	return status == VIRTIO_NET_OK;
>  }
>  
> +static void virtnet_ack_link_announce(struct virtnet_info *vi)
> +{
> +	rtnl_lock();
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_ANNOUNCE,
> +				  VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL,
> +				  0, 0))
> +		dev_warn(&vi->dev->dev, "Failed to ack link announce.\n");
> +	rtnl_unlock();
> +}
> +
>  static int virtnet_close(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> @@ -952,20 +971,31 @@ static const struct net_device_ops virtnet_netdev = {
>  #endif
>  };
>  
> -static void virtnet_update_status(struct virtnet_info *vi)
> +static void virtnet_config_changed_work(struct work_struct *work)
>  {
> +	struct virtnet_info *vi =
> +		container_of(work, struct virtnet_info, config_work);
>  	u16 v;
>  
> +	mutex_lock(&vi->config_lock);
> +	if (!vi->config_enable)
> +		goto done;
> +
>  	if (virtio_config_val(vi->vdev, VIRTIO_NET_F_STATUS,
>  			      offsetof(struct virtio_net_config, status),
>  			      &v) < 0)
> -		return;
> +		goto done;
> +
> +	if (v & VIRTIO_NET_S_ANNOUNCE) {
> +		netif_notify_peers(vi->dev);
> +		virtnet_ack_link_announce(vi);
> +	}
>  
>  	/* Ignore unknown (future) status bits */
>  	v &= VIRTIO_NET_S_LINK_UP;
>  
>  	if (vi->status == v)
> -		return;
> +		goto done;
>  
>  	vi->status = v;
>  
> @@ -976,13 +1006,15 @@ static void virtnet_update_status(struct virtnet_info *vi)
>  		netif_carrier_off(vi->dev);
>  		netif_stop_queue(vi->dev);
>  	}
> +done:
> +	mutex_unlock(&vi->config_lock);
>  }
>  
>  static void virtnet_config_changed(struct virtio_device *vdev)
>  {
>  	struct virtnet_info *vi = vdev->priv;
>  
> -	virtnet_update_status(vi);
> +	queue_work(system_nrt_wq, &vi->config_work);
>  }
>  
>  static int init_vqs(struct virtnet_info *vi)
> @@ -1076,6 +1108,9 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		goto free;
>  
>  	INIT_DELAYED_WORK(&vi->refill, refill_work);
> +	mutex_init(&vi->config_lock);
> +	vi->config_enable = true;
> +	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
>  	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
>  	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
>  
> @@ -1111,7 +1146,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	   otherwise get link status from config. */
>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
>  		netif_carrier_off(dev);
> -		virtnet_update_status(vi);
> +		queue_work(system_nrt_wq, &vi->config_work);
>  	} else {
>  		vi->status = VIRTIO_NET_S_LINK_UP;
>  		netif_carrier_on(dev);
> @@ -1170,10 +1205,17 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
>  {
>  	struct virtnet_info *vi = vdev->priv;
>  
> +	/* Prevent config work handler from accessing the device. */
> +	mutex_lock(&vi->config_lock);
> +	vi->config_enable = false;
> +	mutex_unlock(&vi->config_lock);
> +
>  	unregister_netdev(vi->dev);
>  
>  	remove_vq_common(vi);
>  
> +	flush_work(&vi->config_work);
> +
>  	free_percpu(vi->stats);
>  	free_netdev(vi->dev);
>  }
> @@ -1183,6 +1225,11 @@ static int virtnet_freeze(struct virtio_device *vdev)
>  {
>  	struct virtnet_info *vi = vdev->priv;
>  
> +	/* Prevent config work handler from accessing the device */
> +	mutex_lock(&vi->config_lock);
> +	vi->config_enable = false;
> +	mutex_unlock(&vi->config_lock);
> +
>  	virtqueue_disable_cb(vi->rvq);
>  	virtqueue_disable_cb(vi->svq);
>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
> @@ -1196,6 +1243,8 @@ static int virtnet_freeze(struct virtio_device *vdev)
>  
>  	remove_vq_common(vi);
>  
> +	flush_work(&vi->config_work);
> +
>  	return 0;
>  }
>  
> @@ -1216,6 +1265,10 @@ static int virtnet_restore(struct virtio_device *vdev)
>  	if (!try_fill_recv(vi, GFP_KERNEL))
>  		queue_delayed_work(system_nrt_wq, &vi->refill, 0);
>  
> +	mutex_lock(&vi->config_lock);
> +	vi->config_enable = true;
> +	mutex_unlock(&vi->config_lock);
> +
>  	return 0;
>  }
>  #endif
> @@ -1233,6 +1286,7 @@ static unsigned int features[] = {
>  	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
>  	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
> +	VIRTIO_NET_F_GUEST_ANNOUNCE,
>  };
>  
>  static struct virtio_driver virtio_net_driver = {
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 970d5a2..2470f54 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -49,8 +49,11 @@
>  #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
>  #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
>  #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
> +#define VIRTIO_NET_F_GUEST_ANNOUNCE 21	/* Guest can announce device on the
> +					 * network */
>  
>  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
> +#define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
>  
>  struct virtio_net_config {
>  	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
> @@ -152,4 +155,15 @@ struct virtio_net_ctrl_mac {
>   #define VIRTIO_NET_CTRL_VLAN_ADD             0
>   #define VIRTIO_NET_CTRL_VLAN_DEL             1
>  
> +/*
> + * Control link announce acknowledgement
> + *
> + * The command VIRTIO_NET_CTRL_ANNOUNCE_ACK is used to indicate that
> + * driver has recevied

received :)

> the notification; device would clear the
> + * VIRTIO_NET_S_ANNOUNCE bit in the status field after it receives
> + * this command.
> + */
> +#define VIRTIO_NET_CTRL_ANNOUNCE       3
> + #define VIRTIO_NET_CTRL_ANNOUNCE_ACK         0
> +
>  #endif /* _LINUX_VIRTIO_NET_H */
