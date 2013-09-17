From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Tue, 17 Sep 2013 11:38:18 -0700
Message-ID: <CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
	<1378711207-29890-8-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:44635 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753055Ab3IQSiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 14:38:19 -0400
Received: by mail-qe0-f48.google.com with SMTP id nd7so3969133qeb.21
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 11:38:18 -0700 (PDT)
In-Reply-To: <1378711207-29890-8-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> Allow datapath to recognize and extract MPLS labels into flow keys
> and execute actions which push, pop, and set labels on packets.
>
> Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
>
> Cc: Ravi K <rkerur@gmail.com>
> Cc: Leo Alterman <lalterman@nicira.com>
> Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> Cc: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> ---
....
> diff --git a/datapath/datapath.h b/datapath/datapath.h
> index 5d50dd4..babae3b 100644
> --- a/datapath/datapath.h
> +++ b/datapath/datapath.h
> @@ -36,6 +36,10 @@
>
>  #define SAMPLE_ACTION_DEPTH 3
>
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
> +#define HAVE_INNER_PROTOCOL
> +#endif
> +
>  /**
>   * struct dp_stats_percpu - per-cpu packet processing statistics for a given
>   * datapath.
> @@ -93,11 +97,16 @@ struct datapath {
>   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
>   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
>   * packet is not being tunneled.
> + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
> + * kernels before 3.11.
>   */
>  struct ovs_skb_cb {
>         struct sw_flow          *flow;
>         struct sw_flow_key      *pkt_key;
>         struct ovs_key_ipv4_tunnel  *tun_key;
> +#ifndef HAVE_INNER_PROTOCOL
> +       __be16                  inner_protocol;
> +#endif
>  };
>  #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
>
Can you move this to compat struct ovs_gso_cb {}

....
>
> +struct sk_buff *rpl___skb_gso_segment(struct sk_buff *skb,
> +                                     netdev_features_t features,
> +                                     bool tx_path)
> +{
> +       struct sk_buff *skb_gso;
> +       __be16 type = skb->protocol;
> +
> +       skb->protocol = skb_network_protocol(skb);
> +
> +       /* this hack needed to get regular skb_gso_segment() */
> +#ifdef HAVE___SKB_GSO_SEGMENT
> +#undef __skb_gso_segment
> +       skb_gso = __skb_gso_segment(skb, features, tx_path);
> +#else
> +#undef skb_gso_segment
> +       skb_gso = skb_gso_segment(skb, features);
> +#endif
> +
> +       if (!skb_gso || IS_ERR(skb_gso))
> +           return skb_gso;
> +
> +       skb = skb_gso;
> +       while (skb) {
> +               skb->protocol = type;
> +               skb = skb->next;
> +       }
> +

Protocol set is required if there is MPLS header, which is rare case.
So I think we can skip this loop if there is no mpls.

> +       return skb_gso;
> +}
> +
> +struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
.....
> +
> +       if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev))
> +               vlan = true;
> +
> +       if (vlan || mpls) {
> +               netdev_features_t features;
>
>                 features = netif_skb_features(skb);
>
> @@ -296,6 +309,20 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
>                         features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
>                                       NETIF_F_UFO | NETIF_F_FSO);
>
> +               /* As of v3.11 the kernel provides an mpls_features field in
> +                * struct net_device which allows devices to advertise which
> +                * features its supports for MPLS. This value defaults to
> +                * NETIF_F_SG and as of v3.11.
> +                *
> +                * This compatibility code is intended for kernels older
> +                * than v3.11 that do not support MPLS GSO and thus do not
> +                * provide mpls_features. Thus this code uses NETIF_F_SG
> +                * directly in place of mpls_features.
> +                */
> +
> +               if (mpls)
> +                       features &= NETIF_F_SG;
> +
>                 if (netif_needs_gso(skb, features)) {
>                         struct sk_buff *nskb;
>
> @@ -319,10 +346,12 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
>                                 nskb = skb->next;
>                                 skb->next = NULL;
>
> -                               skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> +                               if (vlan)
> +                                       skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
>                                 if (likely(skb)) {
>                                         len += skb->len;
> -                                       vlan_set_tci(skb, 0);
> +                                       if (vlan)
> +                                               vlan_set_tci(skb, 0);
>                                         dev_queue_xmit(skb);
>                                 }
>
> @@ -333,10 +362,12 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
>                 }
>
>  tag:
> -               skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> -               if (unlikely(!skb))
> -                       return 0;
> -               vlan_set_tci(skb, 0);
> +               if (vlan) {
> +                       skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> +                       if (unlikely(!skb))
> +                               return 0;
> +                       vlan_set_tci(skb, 0);
> +               }
>         }
>
I think we can simplify code by pushing vlan and then segmenting skb,
the way we do it for MPLS.
