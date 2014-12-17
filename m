From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 08/10] tun: Re-uanble UFO support.
Date: Thu, 18 Dec 2014 00:33:40 +0200
Message-ID: <20141217223340.GB30969@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
	<1418840455-22598-9-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, stefanha@redhat.com,
	virtualization@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1418840455-22598-9-git-send-email-vyasevic@redhat.com>
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

subs: re-enable

On Wed, Dec 17, 2014 at 01:20:53PM -0500, Vladislav Yasevich wrote:
> Now that UFO is split into v4 and v6 parts, we can bring
> back v4 support without any trouble.
> 
> Continue to handle legacy applications by selecting the
> IPv6 fragment id but do not change the gso type.  Thist

s/Thist/this/

> makes sure that two legacy VMs may still communicate.

This means IPv6 skbs with UFO (not UFO6) flag set are present
in the stack.
If possible, I think it would be better to make GSO type correct: UFO6,
and then convert to UFO when copying to guest.

A similar approach should be possible  for OVS?


> Based on original work from Ben Hutchings.
> 
> Fixes: 88e0e0e5aa7a ("drivers/net: Disable UFO through virtio")
> CC: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/tun.c | 26 ++++++++++++++------------
>  1 file changed, 14 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 9dd3746..8c32fca 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -175,7 +175,7 @@ struct tun_struct {
>  	struct net_device	*dev;
>  	netdev_features_t	set_features;
>  #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
> -			  NETIF_F_TSO6)
> +			  NETIF_F_TSO6|NETIF_F_UFO)
>  
>  	int			vnet_hdr_sz;
>  	int			sndbuf;
> @@ -1152,20 +1152,15 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
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
> -			if (skb->protocol == htons(ETH_P_IPV6))
> +			if (vlan_get_protocol(skb) == htons(ETH_P_IPV6)) {
> +				/* This allows legacy application to work.
> +				 * Do not change the gso_type as it may
> +				 * not be upderstood by legacy applications.

Shouldn't we handle legacy applications when passing packets to
userspace?

> +				 */
>  				ipv6_proxy_select_ident(skb);
> +			}
>  			break;
> -		}
>  		default:
>  			tun->dev->stats.rx_frame_errors++;
>  			kfree_skb(skb);
> @@ -1273,6 +1268,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>  			else if (sinfo->gso_type & SKB_GSO_TCPV6)
>  				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> +			else if (sinfo->gso_type & SKB_GSO_UDP)
> +				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
>  			else {
>  				pr_err("unexpected GSO type: "
>  				       "0x%x, gso_size %d, hdr_len %d\n",
> @@ -1780,6 +1777,11 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
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
> -- 
> 1.9.3
