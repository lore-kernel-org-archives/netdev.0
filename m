From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 5/5] virtio-net: switch off offloads on demand
	if possible on XDP set
Date: Tue, 18 Jul 2017 23:07:42 +0300
Message-ID: <20170718225011-mutt-send-email-mst@kernel.org>
References: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
	<1500295441-19339-6-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1500295441-19339-6-git-send-email-jasowang@redhat.com>
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

On Mon, Jul 17, 2017 at 08:44:01PM +0800, Jason Wang wrote:
> Current XDP implementation want guest offloads feature to be disabled

s/want/wants/

> on qemu cli.

on the device.

> This is inconvenient and means guest can't benefit from
> offloads if XDP is not used. This patch tries to address this
> limitation by disable

disabling

> the offloads on demand through control guest
> offloads. Guest offloads will be disabled and enabled on demand on XDP
> set.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

In fact, since we no longer reset when XDP is set,
here device might have offloads enabled, buffers are
used but not consumed, then XDP is set.

This can result in
- packet scattered across multiple buffers
  (handled correctly but need to update the comment)
- packet may have VIRTIO_NET_HDR_F_NEEDS_CSUM, in that case
  the spec says "The checksum on the packet is incomplete".
  (probably needs to be handled by calculating the checksum).


Ideas for follow-up patches:

- skip looking at packet data completely
  won't work if you play with checksums dynamically
  but can be done if disabled on device
- allow ethtools to tweak offloads from userspace as well


> ---
>  drivers/net/virtio_net.c | 70 ++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 65 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index e732bd6..d970c2d 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -57,6 +57,11 @@ DECLARE_EWMA(pkt_len, 0, 64)
>  
>  #define VIRTNET_DRIVER_VERSION "1.0.0"
>  
> +const unsigned long guest_offloads[] = { VIRTIO_NET_F_GUEST_TSO4,
> +					 VIRTIO_NET_F_GUEST_TSO6,
> +					 VIRTIO_NET_F_GUEST_ECN,
> +					 VIRTIO_NET_F_GUEST_UFO };
> +
>  struct virtnet_stats {
>  	struct u64_stats_sync tx_syncp;
>  	struct u64_stats_sync rx_syncp;
> @@ -164,10 +169,13 @@ struct virtnet_info {
>  	u8 ctrl_promisc;
>  	u8 ctrl_allmulti;
>  	u16 ctrl_vid;
> +	u64 ctrl_offloads;
>  
>  	/* Ethtool settings */
>  	u8 duplex;
>  	u32 speed;
> +
> +	unsigned long guest_offloads;
>  };
>  
>  struct padded_vnet_hdr {
> @@ -1889,6 +1897,47 @@ static int virtnet_restore_up(struct virtio_device *vdev)
>  	return err;
>  }
>  
> +static int virtnet_set_guest_offloads(struct virtnet_info *vi, u64 offloads)
> +{
> +	struct scatterlist sg;
> +	vi->ctrl_offloads = cpu_to_virtio64(vi->vdev, offloads);
> +
> +	sg_init_one(&sg, &vi->ctrl_offloads, sizeof(vi->ctrl_offloads));
> +
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_GUEST_OFFLOADS,
> +				  VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET, &sg)) {
> +		dev_warn(&vi->dev->dev, "Fail to set guest offload. \n");
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +static int virtnet_clear_guest_offloads(struct virtnet_info *vi)
> +{
> +	u64 offloads = 0;
> +
> +	if (!vi->guest_offloads)
> +		return 0;
> +
> +	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_CSUM))
> +		offloads = 1ULL << VIRTIO_NET_F_GUEST_CSUM;
> +
> +	return virtnet_set_guest_offloads(vi, offloads);
> +}
> +
> +static int virtnet_restore_guest_offloads(struct virtnet_info *vi)
> +{
> +	u64 offloads = vi->guest_offloads;
> +
> +	if (!vi->guest_offloads)
> +		return 0;
> +	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_CSUM))
> +		offloads |= 1ULL << VIRTIO_NET_F_GUEST_CSUM;
> +
> +	return virtnet_set_guest_offloads(vi, offloads);
> +}
> +
>  static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>  			   struct netlink_ext_ack *extack)
>  {
> @@ -1898,10 +1947,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>  	u16 xdp_qp = 0, curr_qp;
>  	int i, err;
>  
> -	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
> -	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
> -	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
> -	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO)) {
> +	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS)
> +	    && (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
> +	        virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
> +	        virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
> +		virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO))) {
>  		NL_SET_ERR_MSG_MOD(extack, "Can't set XDP while host is implementing LRO, disable LRO first");
>  		return -EOPNOTSUPP;
>  	}
> @@ -1950,6 +2000,12 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
>  		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);
> +		if (i == 0) {
> +			if (!old_prog)
> +				virtnet_clear_guest_offloads(vi);
> +			if (!prog)
> +				virtnet_restore_guest_offloads(vi);
> +		}
>  		if (old_prog)
>  			bpf_prog_put(old_prog);
>  		napi_enable(&vi->rq[i].napi);
> @@ -2583,6 +2639,10 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		netif_carrier_on(dev);
>  	}
>  
> +	for (i = 0; i < ARRAY_SIZE(guest_offloads); i++)
> +		if (virtio_has_feature(vi->vdev, guest_offloads[i]))
> +			set_bit(guest_offloads[i], &vi->guest_offloads);
> +
>  	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
>  		 dev->name, max_queue_pairs);
>  
> @@ -2679,7 +2739,7 @@ static struct virtio_device_id id_table[] = {
>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, \
>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ, \
>  	VIRTIO_NET_F_CTRL_MAC_ADDR, \
> -	VIRTIO_NET_F_MTU
> +	VIRTIO_NET_F_MTU, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
>  
>  static unsigned int features[] = {
>  	VIRTNET_FEATURES,
> -- 
> 2.7.4
