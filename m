From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: introduce VIRTIO_NET_HDR_F_DATA_VALID
Date: Fri, 10 Jun 2011 14:28:28 +0300
Message-ID: <20110610112828.GA21037@redhat.com>
References: <1307703377-3798-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, yvugenfi@redhat.com,
	kvm@vger.kernel.org, herbert@gondor.hengli.com.au
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1307703377-3798-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 10, 2011 at 06:56:17PM +0800, Jason Wang wrote:
> There's no need for the guest to validate the checksum if it have been
> validated by host nics. So this patch introduces a new flag -
> VIRTIO_NET_HDR_F_DATA_VALID which is used to bypass the checksum
> examing in guest. The backend (tap/macvtap) may set this flag when
> met skbs with CHECKSUM_UNNECESSARY to save cpu utilization.
> 
> No feature negotiation is needed as old driver just ignore this flag.

This wasn't required by the spec, but maybe it should be.

> Iperf shows 12%-30% performance improvement for UDP traffic. For TCP,
> when gro is on no difference as it produces skb with partial
> checksum. But when gro is disabled, 20% or even higher improvement
> could be measured by netperf.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c      |    2 ++
>  drivers/net/tun.c          |    2 ++
>  drivers/net/virtio_net.c   |    2 ++
>  include/linux/virtio_net.h |    1 +
>  net/packet/af_packet.c     |    2 ++
>  5 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 6696e56..ecee0fe 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -508,6 +508,8 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
>  		vnet_hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
>  		vnet_hdr->csum_start = skb_checksum_start_offset(skb);
>  		vnet_hdr->csum_offset = skb->csum_offset;
> +	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
> +		vnet_hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
>  	} /* else everything is zero */
>  
>  	return 0;
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 74e9405..f43fa45 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -788,6 +788,8 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
>  			gso.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
>  			gso.csum_start = skb_checksum_start_offset(skb);
>  			gso.csum_offset = skb->csum_offset;
> +		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
> +			gso.flags = VIRTIO_NET_HDR_F_DATA_VALID;
>  		} /* else everything is zero */
>  
>  		if (unlikely(memcpy_toiovecend(iv, (void *)&gso, total,
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f685324..be3686a 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -274,6 +274,8 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
>  					  hdr->hdr.csum_start,
>  					  hdr->hdr.csum_offset))
>  			goto frame_err;
> +	} else if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID) {
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;
>  	}
>  
>  	skb->protocol = eth_type_trans(skb, dev);
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 136040b..970d5a2 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -63,6 +63,7 @@ struct virtio_net_config {
>   * specify GSO or CSUM features, you can simply ignore the header. */
>  struct virtio_net_hdr {
>  #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
> +#define VIRTIO_NET_HDR_F_DATA_VALID	2	// Csum is valid
>  	__u8 flags;
>  #define VIRTIO_NET_HDR_GSO_NONE		0	// Not a GSO frame
>  #define VIRTIO_NET_HDR_GSO_TCPV4	1	// GSO frame, IPv4 TCP (TSO)
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index c0c3cda..99ca471 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1681,6 +1681,8 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
>  			vnet_hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
>  			vnet_hdr.csum_start = skb_checksum_start_offset(skb);
>  			vnet_hdr.csum_offset = skb->csum_offset;
> +		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
> +			vnet_hdr.flags = VIRTIO_NET_HDR_F_DATA_VALID;
>  		} /* else everything is zero */
>  
>  		err = memcpy_toiovec(msg->msg_iov, (void *)&vnet_hdr,
> -- 
> 1.7.1
