From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.29] datapath: Add basic MPLS support to kernel
Date: Tue, 21 May 2013 09:07:06 -0700
Message-ID: <CAEP_g=-PDNYWPk+yi4czHw7V822GPRdgNX+csHMByF151Jb5oA@mail.gmail.com>
References: <1368774397-10700-1-git-send-email-horms@verge.net.au>
 <CAEP_g=8GefFzMPSE0EkaLSTNtPJYtgoOKMaV_hN1ckE-Qxhsog@mail.gmail.com> <20130521005519.GA14817@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:53408 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754456Ab3EUQH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 12:07:27 -0400
Received: by mail-ie0-f177.google.com with SMTP id 9so2034920iec.8
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 09:07:26 -0700 (PDT)
In-Reply-To: <20130521005519.GA14817@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 5:55 PM, Simon Horman <horms@verge.net.au> wrote:
> On Fri, May 17, 2013 at 04:14:56PM -0700, Jesse Gross wrote:
>> On Fri, May 17, 2013 at 12:06 AM, Simon Horman <horms@verge.net.au> wrote:
>> > +static int push_mpls(struct sk_buff *skb,
>> > +                    const struct ovs_action_push_mpls *mpls)
>> > +{
>> > +       __be32 *new_mpls_lse;
>> > +       int err;
>> > +
>> > +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
>> > +       if (unlikely(err))
>> > +               return err;
>> > +
>> > +       skb_push(skb, MPLS_HLEN);
>>
>> What happens if there isn't enough headroom?
>
> Good point. How about this?
>
>         if (unlikely(skb->data<skb->head))
>                 return -EINVAL;
>         skb_push(skb, MPLS_HLEN);

The amount of headroom is an internal kernel property so we can't
reject actions on the basis of it. We need to expand the headroom,
similar to __vlan_put_tag().

>> > diff --git a/datapath/datapath.c b/datapath/datapath.c
>> > index 42af315..3a1c203 100644
>> > --- a/datapath/datapath.c
>> > +++ b/datapath/datapath.c
>>
>> It's not clear to that using the depth is actually sufficient to
>> capture all possible combinations because the more common case is that
>> actions are a list, not nested. For example, consider the following
>> (invalid) action list on an IP input packet:
>>
>> push_mpls, sample(pop_mpls), pop_mpls
>>
>> I don't believe that this will be rejected since by the time we get to
>> the second pop_mpls we will have forgotten about the sample action.
>
> My intention when writing the code was that such a case would be rejected
> as follows:
>
> 1. When the nested pop_mpls is validated the following call is
>    made with depth = 1:
>
>   eth_types_set(eth_types, depth, htons(0));
>
>   This sets:
>         eth_types->depth = 1
>         eth_types[1] = htons(0);
>
> 2. When the second pop_mpls is validated the following
>    is executed (with the fix that you suggested below):
>
>    for (i = 0; i < eth_types->depth; i++)
>         if (!eth_p_mpls(eth_types->types[i]))
>                 return -EINVAL;
>
>    This will return -EINVAL due to the values of eth_type members set in 1.

OK, I see that the depth does't get reset for the next check. However,
what about this sequence?

push_mpls, sample(pop_mpls), sample(push_mpls), pop_mpls

My point is that in cases where sample actions aren't nested, the
depth doesn't capture all the combinations.

>> > diff --git a/datapath/flow.c b/datapath/flow.c
>> > index 3ce926e..2a86f90 100644
>> > --- a/datapath/flow.c
>> > +++ b/datapath/flow.c
>> > @@ -848,6 +880,9 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>> >         [OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
>> >         [OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
>> >         [OVS_KEY_ATTR_TUNNEL] = -1,
>> > +
>> > +       /* Not upstream. */
>> > +       [OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
>>
>> At this point, we can probably treat this patch as the point where the
>> MPLS data structures are finalized and upstreamable. Therefore, this
>> patch can move the attribute to a final location.
>
> Thanks, I will squash the following incremental change into the next
> posting of this patch.
>
> diff --git a/datapath/flow.c b/datapath/flow.c
> index 2a86f90..d67d6bf 100644
> --- a/datapath/flow.c
> +++ b/datapath/flow.c
> @@ -880,8 +880,6 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>         [OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
>         [OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
>         [OVS_KEY_ATTR_TUNNEL] = -1,
> -
> -       /* Not upstream. */
>         [OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
>  };
>
> diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
> index e890fd8..d90f585 100644
> --- a/include/linux/openvswitch.h
> +++ b/include/linux/openvswitch.h
> @@ -287,7 +287,7 @@ enum ovs_key_attr {
>         OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
>  #endif
>
> -       OVS_KEY_ATTR_MPLS = 62, /* array of struct ovs_key_mpls.
> +       OVS_KEY_ATTR_MPLS,      /* array of struct ovs_key_mpls.
>                                  * The implementation may restrict
>                                  * the accepted length of the array. */
>         __OVS_KEY_ATTR_MAX

I think this belongs more appropriately directly after OVS_KEY_ATTR_TUNNEL.
