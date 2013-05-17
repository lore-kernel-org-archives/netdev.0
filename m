From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.29] datapath: Add basic MPLS support to kernel
Date: Fri, 17 May 2013 16:14:56 -0700
Message-ID: <CAEP_g=8GefFzMPSE0EkaLSTNtPJYtgoOKMaV_hN1ckE-Qxhsog@mail.gmail.com>
References: <1368774397-10700-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:42884 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751044Ab3EQXPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 19:15:17 -0400
Received: by mail-ie0-f181.google.com with SMTP id x12so10584305ief.12
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 16:15:16 -0700 (PDT)
In-Reply-To: <1368774397-10700-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 12:06 AM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index 0dac658..ac4423a 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> +/* The end of the mac header.
> + *
> + * For non-MPLS skbs this will correspond to the network header.
> + * For MPLS skbs it will be berfore the network_header as the MPLS
> + * label stack lies between the end of the mac header and the network
> + * header. That is, for MPLS skbs the end of the mac header
> + * is the top of the MPLS label stack.
> + */
> +static inline unsigned char *skb_mac_header_end(const struct sk_buff *skb)
> +{
> +       return skb_mac_header(skb) + skb->mac_len;
> +}

This should either be moved into skbuff.h or given a name that makes
it clear that it is a local function.

> +static void set_ethertype(struct sk_buff *skb, __be16 ethertype)
> +{
> +       __be16 *skb_ethertype = get_ethertype(skb);
> +       if (*skb_ethertype == ethertype)
> +               return;
> +       if (get_ip_summed(skb) == OVS_CSUM_COMPLETE) {
> +               __be16 diff[] = { ~*skb_ethertype, ethertype };
> +               skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> +                                         ~skb->csum);
> +       }

Inside of OVS the Ethernet header is not covered by CHECKSUM_COMPLETE.

> +static int push_mpls(struct sk_buff *skb,
> +                    const struct ovs_action_push_mpls *mpls)
> +{
> +       __be32 *new_mpls_lse;
> +       int err;
> +
> +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> +       if (unlikely(err))
> +               return err;
> +
> +       skb_push(skb, MPLS_HLEN);

What happens if there isn't enough headroom?

> +static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
> +{
> +       int err;
> +
> +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> +       if (unlikely(err))
> +               return err;
> +
> +       if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> +               skb->csum = csum_sub(skb->csum,
> +                                    csum_partial(skb_mac_header_end(skb),
> +                                                 MPLS_HLEN, 0));
> +
> +       memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
> +               skb->mac_len);
> +
> +       skb_pull(skb, MPLS_HLEN);

You could use __skb_pull() here.

>  /* remove VLAN header from packet and update csum accordingly. */
>  static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
>  {
> @@ -115,6 +229,9 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
>                 if (!__vlan_put_tag(skb, current_tag))
>                         return -ENOMEM;
>
> +               /* update mac_len for skb_mac_header_end() */
> +               skb_reset_mac_len(skb);

Doesn't this make us forget the start of the MPLS label stack?

> -/* Execute a list of actions against 'skb'. */
> +/* Execute a list of actions against 'skb'.
> + *
> + * The stack depth is only tracked in the case of a non-MPLS packet
> + * that becomes MPLS via an MPLS push action. The stack depth
> + * is passed to do_output() in order to allow it to prepare the
> + * skb for possible GSO segmentation. */

I don't think this comment applies any more.

> diff --git a/datapath/datapath.c b/datapath/datapath.c
> index 42af315..3a1c203 100644
> --- a/datapath/datapath.c
> +++ b/datapath/datapath.c

It's not clear to that using the depth is actually sufficient to
capture all possible combinations because the more common case is that
actions are a list, not nested. For example, consider the following
(invalid) action list on an IP input packet:

push_mpls, sample(pop_mpls), pop_mpls

I don't believe that this will be rejected since by the time we get to
the second pop_mpls we will have forgotten about the sample action.

> @@ -811,6 +869,35 @@ static int validate_and_copy_actions(const struct nlattr *attr,
>                                 return -EINVAL;
>                         break;
>
> +               case OVS_ACTION_ATTR_PUSH_MPLS: {
> +                       const struct ovs_action_push_mpls *mpls = nla_data(a);
> +                       if (!eth_p_mpls(mpls->mpls_ethertype))
> +                               return -EINVAL;
> +                       eth_types_set(eth_types, depth, mpls->mpls_ethertype);
> +                       break;
> +               }
> +
> +               case OVS_ACTION_ATTR_POP_MPLS: {
> +                       size_t i;
> +
> +                       for (i = 0; i < eth_types->depth; i++)
> +                               if (eth_types->types[i] != htons(ETH_P_IP))
> +                                       return -EINVAL;

I think the check here should be for MPLS, not IP.
> diff --git a/datapath/flow.c b/datapath/flow.c
> index 3ce926e..2a86f90 100644
> --- a/datapath/flow.c
> +++ b/datapath/flow.c
> @@ -848,6 +880,9 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>         [OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
>         [OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
>         [OVS_KEY_ATTR_TUNNEL] = -1,
> +
> +       /* Not upstream. */
> +       [OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),

At this point, we can probably treat this patch as the point where the
MPLS data structures are finalized and upstreamable. Therefore, this
patch can move the attribute to a final location.
