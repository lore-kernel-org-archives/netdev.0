From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net 4/5] net/mlx4_en: Implement ndo_gso_check()
Date: Wed, 5 Nov 2014 14:41:57 +0200
Message-ID: <CAJ3xEMjFh=pg-0ytvjsLduO-+Z+oJc=6=2i1fKG_CXBPF2L3UQ@mail.gmail.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
	<1415138202-1197-5-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	sathya.perla@emulex.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux.nics@intel.com, Amir Vadai <amirv@mellanox.com>,
	shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	Tom Herbert <therbert@google.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415138202-1197-5-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2014 at 11:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
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
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index f3032fe..aca9908 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2344,6 +2344,17 @@ static void mlx4_en_del_vxlan_port(struct  net_device *dev,
>  }
>  #endif
>
> +static bool mlx4_en_gso_check(struct sk_buff *skb, struct net_device *dev)
> +{
> +       if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> +           (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> +            skb->inner_protocol != htons(ETH_P_TEB) ||
> +            skb_inner_mac_header(skb) - skb_transport_header(skb) != 16))
> +               return false;

Let's have this 16 constant to be more clear... e.g make it the sum of
sizeof struct udphdr and struct vxlanhdr - you would need to move the
latter from vxlan.c into a public header. All for the general patch I
suggested

Or.

> +
> +       return true;
> +}
> +
>  static const struct net_device_ops mlx4_netdev_ops = {
>         .ndo_open               = mlx4_en_open,
>         .ndo_stop               = mlx4_en_close,
> @@ -2374,6 +2385,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
>         .ndo_add_vxlan_port     = mlx4_en_add_vxlan_port,
>         .ndo_del_vxlan_port     = mlx4_en_del_vxlan_port,
>  #endif
> +       .ndo_gso_check          = mlx4_en_gso_check,
>  };
>
>  static const struct net_device_ops mlx4_netdev_ops_master = {
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
