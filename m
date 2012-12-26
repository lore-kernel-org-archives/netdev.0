From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [RFC PATCH] virtio-net: reset virtqueue affinity when doing
 cpu hotplug
Date: Wed, 26 Dec 2012 07:51:12 -0800
Message-ID: <1356537072.20133.20400.camel@edumazet-glaptop>
References: <1356505614-16683-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356505614-16683-1-git-send-email-gaowanlong@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-12-26 at 15:06 +0800, Wanlong Gao wrote:
> Add a cpu notifier to virtio-net, so that we can reset the
> virtqueue affinity if the cpu hotplug happens. It improve
> the performance through enabling or disabling the virtqueue
> affinity after doing cpu hotplug.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> ---
>  drivers/net/virtio_net.c | 39 ++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 38 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index a6fcf15..9710cf4 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -26,6 +26,7 @@
>  #include <linux/scatterlist.h>
>  #include <linux/if_vlan.h>
>  #include <linux/slab.h>
> +#include <linux/cpu.h>
>  
>  static int napi_weight = 128;
>  module_param(napi_weight, int, 0444);
> @@ -34,6 +35,8 @@ static bool csum = true, gso = true;
>  module_param(csum, bool, 0444);
>  module_param(gso, bool, 0444);
>  
> +static bool cpu_hotplug = false;
> +
>  /* FIXME: MTU in config. */
>  #define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
>  #define GOOD_COPY_LEN	128
> @@ -1041,6 +1044,26 @@ static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
>  		vi->affinity_hint_set = false;
>  }
>  
> +static int virtnet_cpu_callback(struct notifier_block *nfb,
> +			       unsigned long action, void *hcpu)
> +{
> +	switch(action) {
> +	case CPU_ONLINE:
> +	case CPU_ONLINE_FROZEN:
> +	case CPU_DEAD:
> +	case CPU_DEAD_FROZEN:
> +		cpu_hotplug = true;
> +		break;
> +	default:
> +		break;
> +	}
> +	return NOTIFY_OK;
> +}
> +
> +static struct notifier_block virtnet_cpu_notifier = {
> +	.notifier_call = virtnet_cpu_callback,
> +};
> +
>  static void virtnet_get_ringparam(struct net_device *dev,
>  				struct ethtool_ringparam *ring)
>  {
> @@ -1131,7 +1154,14 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>   */
>  static u16 virtnet_select_queue(struct net_device *dev, struct sk_buff *skb)
>  {
> -	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
> +	int txq;
> +
> +	if (unlikely(cpu_hotplug == true)) {
> +		virtnet_set_affinity(netdev_priv(dev), true);
> +		cpu_hotplug = false;
> +	}
> +
> +	txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
>  		  smp_processor_id();
>  
>  	while (unlikely(txq >= dev->real_num_tx_queues))
> @@ -1248,6 +1278,8 @@ static void virtnet_del_vqs(struct virtnet_info *vi)
>  {
>  	struct virtio_device *vdev = vi->vdev;
>  
> +	unregister_hotcpu_notifier(&virtnet_cpu_notifier);
> +
>  	virtnet_set_affinity(vi, false);
>  
>  	vdev->config->del_vqs(vdev);
> @@ -1372,6 +1404,11 @@ static int init_vqs(struct virtnet_info *vi)
>  		goto err_free;
>  
>  	virtnet_set_affinity(vi, true);
> +
> +	ret = register_hotcpu_notifier(&virtnet_cpu_notifier);
> +	if (ret)
> +		goto err_free;
> +
>  	return 0;
>  
>  err_free:

It looks like this patch assumes virtio_net supports a single instance.

Try your patch with two instances, I am pretty sure it wont do very
well.

It seems to me you need something else than a single boolean.

A sequence number for example should be better...
