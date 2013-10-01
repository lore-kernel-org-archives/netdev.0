From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.41 5/5] datapath: Add basic MPLS support to kernel
Date: Tue, 1 Oct 2013 16:02:17 -0700
Message-ID: <CAEP_g=-+ttiZnxv95V17KQdN1Pg4UT1P80WSrFGHQWROvj+nMQ@mail.gmail.com>
References: <1380610064-14856-1-git-send-email-horms@verge.net.au> <1380610064-14856-6-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ben Pfaff <blp@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:40981 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751834Ab3JAXCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 19:02:38 -0400
Received: by mail-ie0-f175.google.com with SMTP id e14so15389iej.20
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 16:02:37 -0700 (PDT)
In-Reply-To: <1380610064-14856-6-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 30, 2013 at 11:47 PM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index d961e5d..bfab9ec 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> +/* Push MPLS after the ethernet header. */
> +static int push_mpls(struct sk_buff *skb,
> +                    const struct ovs_action_push_mpls *mpls)
[...]
> +       hdr = eth_hdr(skb);
> +       hdr->h_proto = mpls->mpls_ethertype;
> +       if (!eth_p_mpls(skb->protocol) && !ovs_skb_get_inner_protocol(skb))
> +               ovs_skb_set_inner_protocol(skb, skb->protocol);

Do we actually need the check for !eth_p_mpls(skb->protocol)? It's not
clear to me what condition it is trying to prevent.

> +static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
> +{
> +       struct ethhdr *hdr;
> +       int err;
> +
> +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> +       if (unlikely(err))
> +               return err;
> +
> +       if (unlikely(skb->len < skb->mac_len + MPLS_HLEN))
> +               return -ENOMEM;

I'm not sure that this is the right error code in this situation -
maybe -EINVAL would be better.

> @@ -545,6 +662,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                         output_userspace(dp, skb, a);
>                         break;
>
> +               case OVS_ACTION_ATTR_PUSH_MPLS:
> +                       err = push_mpls(skb, nla_data(a));
> +                       break;
> +
> +               case OVS_ACTION_ATTR_POP_MPLS:
> +                       err = pop_mpls(skb, nla_get_be16(a));
> +                       break;

I think we need something similar to POP_VLAN here - in the event of
an error the skb will have already been freed.

> diff --git a/datapath/datapath.h b/datapath/datapath.h
> index 4a49a7d..31fe10a 100644
> --- a/datapath/datapath.h
> +++ b/datapath/datapath.h
> @@ -95,6 +95,8 @@ struct datapath {
>   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
>   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
>   * packet is not being tunneled.
> + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
> + * kernels before 3.11.
>   */
>  struct ovs_skb_cb {
>         struct sw_flow          *flow;

I think this comment no longer applies now that inner_protocol has
been moved into the GSO struct.

> diff --git a/datapath/linux/compat/gso.c b/datapath/linux/compat/gso.c
> index 32f906c..f917356 100644
> --- a/datapath/linux/compat/gso.c
> +++ b/datapath/linux/compat/gso.c
>  int rpl_dev_queue_xmit(struct sk_buff *skb)
>  {
>  #undef dev_queue_xmit
>         int err = -ENOMEM;
> +       __be16 inner_protocol;
> +       bool vlan, mpls;
>
> -       if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev)) {
> +       vlan = mpls = false;
> +
> +       inner_protocol = ovs_skb_get_inner_protocol(skb);

I don't think this is actually used in this function.

Pravin, do you have any further comments?
