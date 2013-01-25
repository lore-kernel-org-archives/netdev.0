From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V6 2/3] virtio-net: split out clean affinity function
Date: Fri, 25 Jan 2013 11:28:32 +0800
Message-ID: <5101FBE0.7040505@redhat.com>
References: <1358767524-17934-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<1358767524-17934-2-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>
To: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1358767524-17934-2-git-send-email-gaowanlong@cn.fujitsu.com>
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

On 01/21/2013 07:25 PM, Wanlong Gao wrote:
> Split out the clean affinity function to virtnet_clean_affinity().
>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Eric Dumazet <erdnetdev@gmail.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> ---
> V5->V6: NEW
>
>  drivers/net/virtio_net.c | 67 +++++++++++++++++++++++++++---------------------
>  1 file changed, 38 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 70cd957..1a35a8c 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1016,48 +1016,57 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
>  	return 0;
>  }
>  
> -static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
> +static void virtnet_clean_affinity(struct virtnet_info *vi, long hcpu)
>  {
>  	int i;
>  	int cpu;
>  
> -	/* In multiqueue mode, when the number of cpu is equal to the number of
> -	 * queue pairs, we let the queue pairs to be private to one cpu by
> -	 * setting the affinity hint to eliminate the contention.
> -	 */
> -	if ((vi->curr_queue_pairs == 1 ||
> -	     vi->max_queue_pairs != num_online_cpus()) && set) {
> -		if (vi->affinity_hint_set)
> -			set = false;
> -		else
> -			return;
> -	}
> -
> -	if (set) {
> -		i = 0;
> -		for_each_online_cpu(cpu) {
> -			virtqueue_/set_affinity(vi->rq[i].vq, cpu);
> -			virtqueue_set_affinity(vi->sq[i].vq, cpu);
> -			*per_cpu_ptr(vi->vq_index, cpu) = i;
> -			i++;
> -		}
> -
> -		vi->affinity_hint_set = true;
> -	} else {
> -		for(i = 0; i < vi->max_queue_pairs; i++) {
> +	if (vi->affinity_hint_set) {
> +		for (i = 0; i < vi->max_queue_pairs; i++) {
>  			virtqueue_set_affinity(vi->rq[i].vq, -1);
>  			virtqueue_set_affinity(vi->sq[i].vq, -1);
>  		}
>  
>  		i = 0;
> -		for_each_online_cpu(cpu)
> +		for_each_online_cpu(cpu) {
> +			if (cpu == hcpu)
> +				continue;
>  			*per_cpu_ptr(vi->vq_index, cpu) =
>  				++i % vi->curr_queue_pairs;
> +		}
>  

Some questions here:

- Did we need reset the affinity of the queue here like the this?

virtqueue_set_affinity(vi->sq[*per_cpu_ptr(vi->vq_index, hcpu)], -1);
virtqueue_set_affinity(vi->rq[*per_cpu_ptr(vi->vq_index, hcpu)], -1);

- Looks like we need also reset the percpu index when
vi->affinity_hint_set is false.
- Does this really need this reset? Consider we're going to reset the
percpu in CPU_DEAD?

Thanks
>  		vi->affinity_hint_set = false;
>  	}
>  }
>  
> +static void virtnet_set_affinity(struct virtnet_info *vi)
> +{
> +	int i;
> +	int cpu;
> +
> +	/* In multiqueue mode, when the number of cpu is equal to the number of
> +	 * queue pairs, we let the queue pairs to be private to one cpu by
> +	 * setting the affinity hint to eliminate the contention.
> +	 */
> +	if (vi->curr_queue_pairs == 1 ||
> +	    vi->max_queue_pairs != num_online_cpus()) {
> +		if (vi->affinity_hint_set)
> +			virtnet_clean_affinity(vi, -1);
> +		else
> +			return;
> +	}
> +
> +	i = 0;
> +	for_each_online_cpu(cpu) {
> +		virtqueue_set_affinity(vi->rq[i].vq, cpu);
> +		virtqueue_set_affinity(vi->sq[i].vq, cpu);
> +		*per_cpu_ptr(vi->vq_index, cpu) = i;
> +		i++;
> +	}
> +
> +	vi->affinity_hint_set = true;
> +}
> +
>  static void virtnet_get_ringparam(struct net_device *dev,
>  				struct ethtool_ringparam *ring)
>  {
> @@ -1105,7 +1114,7 @@ static int virtnet_set_channels(struct net_device *dev,
>  		netif_set_real_num_rx_queues(dev, queue_pairs);
>  
>  		get_online_cpus();
> -		virtnet_set_affinity(vi, true);
> +		virtnet_set_affinity(vi);
>  		put_online_cpus();
>  	}
>  
> @@ -1274,7 +1283,7 @@ static void virtnet_del_vqs(struct virtnet_info *vi)
>  {
>  	struct virtio_device *vdev = vi->vdev;
>  
> -	virtnet_set_affinity(vi, false);
> +	virtnet_clean_affinity(vi, -1);
>  
>  	vdev->config->del_vqs(vdev);
>  
> @@ -1398,7 +1407,7 @@ static int init_vqs(struct virtnet_info *vi)
>  		goto err_free;
>  
>  	get_online_cpus();
> -	virtnet_set_affinity(vi, true);
> +	virtnet_set_affinity(vi);
>  	put_online_cpus();
>  
>  	return 0;
