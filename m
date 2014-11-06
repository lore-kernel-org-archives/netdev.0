From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Wed, 05 Nov 2014 18:54:00 -0800
Message-ID: <545AE2C8.3070705@gmail.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com> <1415138202-1197-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, jeffrey.t.kirsher@intel.com,
	linux.nics@intel.com, amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, therbert@google.com,
	linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415138202-1197-4-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/04/2014 01:56 PM, Joe Stringer wrote:
> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an
> implementation for this driver which checks for something that looks
> like VXLAN.
>
> Implementation shamelessly stolen from Tom Herbert:
> http://thread.gmane.org/gmane.linux.network/332428/focus=333111
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> Should this driver report support for GSO on packets with tunnel headers
> up to 64B like the i40e driver does?
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> index 8811364..b9ef622 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> @@ -1350,6 +1350,17 @@ static void fm10k_dfwd_del_station(struct net_device *dev, void *priv)
>  	}
>  }
>  
> +static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)
> +{
> +	if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> +	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> +	     skb->inner_protocol != htons(ETH_P_TEB) ||
> +	     skb_inner_mac_header(skb) - skb_transport_header(skb) != 16))
> +		return false;
> +
> +	return true;
> +}
> +
>  static const struct net_device_ops fm10k_netdev_ops = {
>  	.ndo_open		= fm10k_open,
>  	.ndo_stop		= fm10k_close,
> @@ -1372,6 +1383,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
>  	.ndo_do_ioctl		= fm10k_ioctl,
>  	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
>  	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
> +	.ndo_gso_check		= fm10k_gso_check,
>  };
>  
>  #define DEFAULT_DEBUG_LEVEL_SHIFT 3

I'm thinking this check is far too simplistic.  If you look the fm10k
driver already has fm10k_tx_encap_offload() in the TSO function for
verifying if it can support offloading tunnels or not.  I would
recommend starting there or possibly even just adapting that function to
suit your purpose.

Thanks,

Alex
