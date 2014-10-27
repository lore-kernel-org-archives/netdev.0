From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net 1/2] drivers/net: Disable UFO through virtio
Date: Mon, 27 Oct 2014 10:15:56 +0530
Message-ID: <544DCE04.50403@gmail.com>
References: <1414383425.16849.18.camel@decadent.org.uk>
	<1414383748.16849.21.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414383748.16849.21.camel@decadent.org.uk>
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

On 10/27/2014 09:52 AM, Ben Hutchings wrote:
> IPv6 does not allow fragmentation by routers, so there is no
> fragmentation ID in the fixed header.  UFO for IPv6 requires the ID to
> be passed separately, but there is no provision for this in the virtio
> net protocol.
>
> Until recently our software implementation of UFO/IPv6 generated a new
> ID, but this was a bug.  Now we will use ID=0 for any UFO/IPv6 packet
> passed through a tap, which is even worse.
>
> Unfortunately there is no distinction between UFO/IPv4 and v6
> features, so disable UFO on taps and virtio_net completely until we
> have a proper solution.
>
> We cannot depend on VM managers respecting the tap feature flags, so
> keep accepting UFO packets but log a warning the first time we do
> this.

(...)

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 186ce54..e8b949a 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -174,7 +174,7 @@ struct tun_struct {
>   	struct net_device	*dev;
>   	netdev_features_t	set_features;
>   #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
> -			  NETIF_F_TSO6|NETIF_F_UFO)
> +			  NETIF_F_TSO6)
>   
>   	int			vnet_hdr_sz;
>   	int			sndbuf;
> @@ -1149,8 +1149,17 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>   			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>   			break;
>   		case VIRTIO_NET_HDR_GSO_UDP:
> +		{
> +			static bool warned;

one line space after declaration..

> +			if (!warned) {
> +				warned = true;
> +				netdev_warn(tun->dev,
> +					    "%s: using disabled UFO feature; please fix this program\n",
> +					    current->comm);
> +			}
>   			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>   			break;
> +		}
>   		default:
>   			tun->dev->stats.rx_frame_errors++;
>   			kfree_skb(skb);
> @@ -1251,8 +1260,6 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>   				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>   			else if (sinfo->gso_type & SKB_GSO_TCPV6)
>   				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> -			else if (sinfo->gso_type & SKB_GSO_UDP)
> -				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
>   			else {
>   				pr_err("unexpected GSO type: "
>   				       "0x%x, gso_size %d, hdr_len %d\n",
> @@ -1762,11 +1769,6 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
>   				features |= NETIF_F_TSO6;
>   			arg &= ~(TUN_F_TSO4|TUN_F_TSO6);
>   		}
> -
> -		if (arg & TUN_F_UFO) {
> -			features |= NETIF_F_UFO;
> -			arg &= ~TUN_F_UFO;
> -		}
>   	}
>   
>   	/* This gives the user a way to test for new features in future by
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index d75256bd..e9e269d 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -491,8 +491,16 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>   			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>   			break;
>   		case VIRTIO_NET_HDR_GSO_UDP:
> +		{
> +			static bool warned;

dto...

> +			if (!warned) {
> +				warned = true;
> +				netdev_warn(dev,
> +					    "host using disabled UFO feature; please fix it\n");
> +			}
>   			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>   			break;
> +		}
>   

(...)

>
>
-- 
Thanks and Regards,
Varka Bhadram.
