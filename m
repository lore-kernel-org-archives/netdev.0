From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 3/3] Revert "drivers/net: Disable UFO through virtio"
Date: Sat, 31 Jan 2015 19:11:54 +0200
Message-ID: <20150131171154.GD31871@redhat.com>
References: <1422646047-13168-1-git-send-email-vyasevic@redhat.com>
	<1422646047-13168-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	hannes@stressinduktion.org, ben@decadent.org.uk
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1422646047-13168-4-git-send-email-vyasevic@redhat.com>
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

On Fri, Jan 30, 2015 at 02:27:27PM -0500, Vladislav Yasevich wrote:
> This reverts commit 3d0ad09412ffe00c9afa201d01effdb6023d09b4.
> 
> Now that GSO functionality can correctly track if the fragment
> id has been selected and select a fragment id if necessary,
> we can re-enable UFO on tap/macvap and virtio devices.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c    | 13 ++++++++-----
>  drivers/net/tun.c        | 19 ++++++++-----------
>  drivers/net/virtio_net.c | 24 ++++++++++--------------
>  3 files changed, 26 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 0b86e46..919f4fc 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -80,7 +80,7 @@ static struct cdev macvtap_cdev;
>  static const struct proto_ops macvtap_socket_ops;
>  
>  #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
> -		      NETIF_F_TSO6)
> +		      NETIF_F_TSO6 | NETIF_F_UFO)
>  #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
>  #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
>  
> @@ -585,8 +585,6 @@ static int macvtap_skb_from_vnet_hdr(struct macvtap_queue *q,
>  			gso_type = SKB_GSO_TCPV6;
>  			break;
>  		case VIRTIO_NET_HDR_GSO_UDP:
> -			pr_warn_once("macvtap: %s: using disabled UFO feature; please fix this program\n",
> -				     current->comm);
>  			gso_type = SKB_GSO_UDP;
>  			break;
>  		default:
> @@ -633,6 +631,8 @@ static void macvtap_skb_to_vnet_hdr(struct macvtap_queue *q,
>  			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>  		else if (sinfo->gso_type & SKB_GSO_TCPV6)
>  			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> +		else if (sinfo->gso_type & SKB_GSO_UDP)
> +			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
>  		else
>  			BUG();
>  		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
> @@ -962,6 +962,9 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
>  			if (arg & TUN_F_TSO6)
>  				feature_mask |= NETIF_F_TSO6;
>  		}
> +
> +		if (arg & TUN_F_UFO)
> +			feature_mask |= NETIF_F_UFO;
>  	}
>  
>  	/* tun/tap driver inverts the usage for TSO offloads, where
> @@ -972,7 +975,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
>  	 * When user space turns off TSO, we turn off GSO/LRO so that
>  	 * user-space will not receive TSO frames.
>  	 */
> -	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6))
> +	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO))
>  		features |= RX_OFFLOADS;
>  	else
>  		features &= ~RX_OFFLOADS;
> @@ -1087,7 +1090,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  	case TUNSETOFFLOAD:
>  		/* let the user check for future flags */
>  		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
> -			    TUN_F_TSO_ECN))
> +			    TUN_F_TSO_ECN | TUN_F_UFO))
>  			return -EINVAL;
>  
>  		rtnl_lock();
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 5ca42b7..10f9e40 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -186,7 +186,7 @@ struct tun_struct {
>  	struct net_device	*dev;
>  	netdev_features_t	set_features;
>  #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
> -			  NETIF_F_TSO6)
> +			  NETIF_F_TSO6|NETIF_F_UFO)
>  
>  	int			vnet_hdr_sz;
>  	int			sndbuf;
> @@ -1176,18 +1176,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>  			break;
>  		case VIRTIO_NET_HDR_GSO_UDP:
> -		{
> -			static bool warned;
> -
> -			if (!warned) {
> -				warned = true;
> -				netdev_warn(tun->dev,
> -					    "%s: using disabled UFO feature; please fix this program\n",
> -					    current->comm);
> -			}
>  			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>  			break;
> -		}
>  		default:
>  			tun->dev->stats.rx_frame_errors++;
>  			kfree_skb(skb);
> @@ -1294,6 +1284,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>  			else if (sinfo->gso_type & SKB_GSO_TCPV6)
>  				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> +			else if (sinfo->gso_type & SKB_GSO_UDP)
> +				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
>  			else {
>  				pr_err("unexpected GSO type: "
>  				       "0x%x, gso_size %d, hdr_len %d\n",
> @@ -1742,6 +1734,11 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
>  				features |= NETIF_F_TSO6;
>  			arg &= ~(TUN_F_TSO4|TUN_F_TSO6);
>  		}
> +
> +		if (arg & TUN_F_UFO) {
> +			features |= NETIF_F_UFO;
> +			arg &= ~TUN_F_UFO;
> +		}
>  	}
>  
>  	/* This gives the user a way to test for new features in future by
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 5ca9771..059fdf1 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -490,17 +490,8 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
>  			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>  			break;
>  		case VIRTIO_NET_HDR_GSO_UDP:
> -		{
> -			static bool warned;
> -
> -			if (!warned) {
> -				warned = true;
> -				netdev_warn(dev,
> -					    "host using disabled UFO feature; please fix it\n");
> -			}
>  			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>  			break;
> -		}
>  		case VIRTIO_NET_HDR_GSO_TCPV6:
>  			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>  			break;
> @@ -888,6 +879,8 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>  			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>  		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
>  			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> +		else if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
> +			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
>  		else
>  			BUG();
>  		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
> @@ -1748,7 +1741,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>  			dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
>  
>  		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
> -			dev->hw_features |= NETIF_F_TSO
> +			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
>  				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
>  		}
>  		/* Individual feature bits: what can host handle? */
> @@ -1758,9 +1751,11 @@ static int virtnet_probe(struct virtio_device *vdev)
>  			dev->hw_features |= NETIF_F_TSO6;
>  		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
>  			dev->hw_features |= NETIF_F_TSO_ECN;
> +		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
> +			dev->hw_features |= NETIF_F_UFO;
>  
>  		if (gso)
> -			dev->features |= dev->hw_features & NETIF_F_ALL_TSO;
> +			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
>  		/* (!csum && gso) case will be fixed by register_netdev() */
>  	}
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
> @@ -1798,7 +1793,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	/* If we can receive ANY GSO packets, we must allocate large ones. */
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>  	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6) ||
> -	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
> +	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN) ||
> +	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_UFO))
>  		vi->big_packets = true;
>  
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
> @@ -1994,9 +1990,9 @@ static struct virtio_device_id id_table[] = {
>  static unsigned int features[] = {
>  	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
>  	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
> -	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_TSO6,
> +	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
>  	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
> -	VIRTIO_NET_F_GUEST_ECN,
> +	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
>  	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
> -- 
> 1.9.3
