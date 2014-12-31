From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Add Transparent Ethernet Bridging GRO support.
Date: Wed, 31 Dec 2014 11:19:20 +0200
Message-ID: <CAJ3xEMhSJN5yNm69Hfpe3L9kv0kDx=hSABkD_NPz2dsQDt3Xnw@mail.gmail.com>
References: <1419995416-29987-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:51659 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbaLaJTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 04:19:21 -0500
Received: by mail-oi0-f45.google.com with SMTP id x69so35144727oia.4
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 01:19:20 -0800 (PST)
In-Reply-To: <1419995416-29987-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 5:10 AM, Jesse Gross <jesse@nicira.com> wrote:
> Currently the only tunnel protocol that supports GRO with encapsulated
> Ethernet is VXLAN. This pulls out the Ethernet code into a proper layer
> so that it can be used by other tunnel protocols such as GRE and Geneve.

Hi Jesse,

Thanks for taking care of that, I also had it coded under the
intention of adding GRO support for OVS's TEB based GRE, but didn't
make it to submit before your post... anyway, I would recommend that
you break this patch into two:

1. basic TEB GRO support
2. refactoring of the VXLAN GRO logic to use it

Or.

>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  drivers/net/vxlan.c         | 53 +++-----------------------
>  include/linux/etherdevice.h |  4 ++
>  net/ethernet/eth.c          | 92 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 102 insertions(+), 47 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 7fbd89f..2ab0922 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -549,10 +549,7 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
>  {
>         struct sk_buff *p, **pp = NULL;
>         struct vxlanhdr *vh, *vh2;
> -       struct ethhdr *eh, *eh2;
> -       unsigned int hlen, off_vx, off_eth;
> -       const struct packet_offload *ptype;
> -       __be16 type;
> +       unsigned int hlen, off_vx;
>         int flush = 1;
>
>         off_vx = skb_gro_offset(skb);
> @@ -563,17 +560,6 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
>                 if (unlikely(!vh))
>                         goto out;
>         }
> -       skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
> -       skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
> -
> -       off_eth = skb_gro_offset(skb);
> -       hlen = off_eth + sizeof(*eh);
> -       eh   = skb_gro_header_fast(skb, off_eth);
> -       if (skb_gro_header_hard(skb, hlen)) {
> -               eh = skb_gro_header_slow(skb, hlen, off_eth);
> -               if (unlikely(!eh))
> -                       goto out;
> -       }
>
>         flush = 0;
>
> @@ -582,28 +568,16 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
>                         continue;
>
>                 vh2 = (struct vxlanhdr *)(p->data + off_vx);
> -               eh2 = (struct ethhdr   *)(p->data + off_eth);
> -               if (vh->vx_vni != vh2->vx_vni || compare_ether_header(eh, eh2)) {
> +               if (vh->vx_vni != vh2->vx_vni) {
>                         NAPI_GRO_CB(p)->same_flow = 0;
>                         continue;
>                 }
>         }
>
> -       type = eh->h_proto;
> -
> -       rcu_read_lock();
> -       ptype = gro_find_receive_by_type(type);
> -       if (ptype == NULL) {
> -               flush = 1;
> -               goto out_unlock;
> -       }
> -
> -       skb_gro_pull(skb, sizeof(*eh)); /* pull inner eth header */
> -       skb_gro_postpull_rcsum(skb, eh, sizeof(*eh));
> -       pp = ptype->callbacks.gro_receive(head, skb);
> +       skb_gro_pull(skb, sizeof(struct vxlanhdr));
> +       skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
> +       pp = eth_gro_receive(head, skb);
>
> -out_unlock:
> -       rcu_read_unlock();
>  out:
>         NAPI_GRO_CB(skb)->flush |= flush;
>
> @@ -612,24 +586,9 @@ out:
>
>  static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
>  {
> -       struct ethhdr *eh;
> -       struct packet_offload *ptype;
> -       __be16 type;
> -       int vxlan_len  = sizeof(struct vxlanhdr) + sizeof(struct ethhdr);
> -       int err = -ENOSYS;
> -
>         udp_tunnel_gro_complete(skb, nhoff);
>
> -       eh = (struct ethhdr *)(skb->data + nhoff + sizeof(struct vxlanhdr));
> -       type = eh->h_proto;
> -
> -       rcu_read_lock();
> -       ptype = gro_find_complete_by_type(type);
> -       if (ptype != NULL)
> -               err = ptype->callbacks.gro_complete(skb, nhoff + vxlan_len);
> -
> -       rcu_read_unlock();
> -       return err;
> +       return eth_gro_complete(skb, nhoff + sizeof(struct vxlanhdr));
>  }
>
>  /* Notify netdevs that UDP port started listening */
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index 41c891d..1d869d1 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -52,6 +52,10 @@ struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
>  #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
>  #define alloc_etherdev_mq(sizeof_priv, count) alloc_etherdev_mqs(sizeof_priv, count, count)
>
> +struct sk_buff **eth_gro_receive(struct sk_buff **head,
> +                                struct sk_buff *skb);
> +int eth_gro_complete(struct sk_buff *skb, int nhoff);
> +
>  /* Reserved Ethernet Addresses per IEEE 802.1Q */
>  static const u8 eth_reserved_addr_base[ETH_ALEN] __aligned(2) =
>  { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 33a140e..238f38d 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -424,3 +424,95 @@ ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
>         return scnprintf(buf, PAGE_SIZE, "%*phC\n", len, addr);
>  }
>  EXPORT_SYMBOL(sysfs_format_mac);
> +
> +struct sk_buff **eth_gro_receive(struct sk_buff **head,
> +                                struct sk_buff *skb)
> +{
> +       struct sk_buff *p, **pp = NULL;
> +       struct ethhdr *eh, *eh2;
> +       unsigned int hlen, off_eth;
> +       const struct packet_offload *ptype;
> +       __be16 type;
> +       int flush = 1;
> +
> +       off_eth = skb_gro_offset(skb);
> +       hlen = off_eth + sizeof(*eh);
> +       eh = skb_gro_header_fast(skb, off_eth);
> +       if (skb_gro_header_hard(skb, hlen)) {
> +               eh = skb_gro_header_slow(skb, hlen, off_eth);
> +               if (unlikely(!eh))
> +                       goto out;
> +       }
> +
> +       flush = 0;
> +
> +       for (p = *head; p; p = p->next) {
> +               if (!NAPI_GRO_CB(p)->same_flow)
> +                       continue;
> +
> +               eh2 = (struct ethhdr *)(p->data + off_eth);
> +               if (compare_ether_header(eh, eh2)) {
> +                       NAPI_GRO_CB(p)->same_flow = 0;
> +                       continue;
> +               }
> +       }
> +
> +       type = eh->h_proto;
> +
> +       rcu_read_lock();
> +       ptype = gro_find_receive_by_type(type);
> +       if (ptype == NULL) {
> +               flush = 1;
> +               goto out_unlock;
> +       }
> +
> +       skb_gro_pull(skb, sizeof(*eh));
> +       skb_gro_postpull_rcsum(skb, eh, sizeof(*eh));
> +       pp = ptype->callbacks.gro_receive(head, skb);
> +
> +out_unlock:
> +       rcu_read_unlock();
> +out:
> +       NAPI_GRO_CB(skb)->flush |= flush;
> +
> +       return pp;
> +}
> +EXPORT_SYMBOL(eth_gro_receive);
> +
> +int eth_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +       struct ethhdr *eh = (struct ethhdr *)(skb->data + nhoff);
> +       __be16 type = eh->h_proto;
> +       struct packet_offload *ptype;
> +       int err = -ENOSYS;
> +
> +       if (skb->encapsulation)
> +               skb_set_inner_mac_header(skb, nhoff);
> +
> +       rcu_read_lock();
> +       ptype = gro_find_complete_by_type(type);
> +       if (ptype != NULL)
> +               err = ptype->callbacks.gro_complete(skb, nhoff +
> +                                                   sizeof(struct ethhdr));
> +
> +       rcu_read_unlock();
> +       return err;
> +}
> +EXPORT_SYMBOL(eth_gro_complete);
> +
> +static struct packet_offload eth_packet_offload __read_mostly = {
> +       .type = cpu_to_be16(ETH_P_TEB),
> +       .callbacks = {
> +               .gro_receive = eth_gro_receive,
> +               .gro_complete = eth_gro_complete,
> +       },
> +};
> +
> +static int __init eth_offload_init(void)
> +{
> +       dev_add_offload(&eth_packet_offload);
> +
> +       return 0;
> +}
> +
> +fs_initcall(eth_offload_init);
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
