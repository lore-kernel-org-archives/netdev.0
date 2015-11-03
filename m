From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] mpls: support for dead routes
Date: Tue, 03 Nov 2015 15:08:10 -0800
Message-ID: <56393E5A.6080108@cumulusnetworks.com>
References: <1446527581-64787-1-git-send-email-roopa@cumulusnetworks.com> <5638CDE4.2080501@brocade.com> <5638ED0D.5030301@cumulusnetworks.com> <878u6erk01.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35204 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbbKCXIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 18:08:13 -0500
Received: by pasz6 with SMTP id z6so32023009pas.2
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 15:08:13 -0800 (PST)
In-Reply-To: <878u6erk01.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/15, 10:54 AM, Eric W. Biederman wrote:
> roopa <roopa@cumulusnetworks.com> writes:
>
>> On 11/3/15, 7:08 AM, Robert Shearman wrote:
>>> On 03/11/15 05:13, Roopa Prabhu wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
>>>> routes due to link events. Also adds code to ignore dead
>>>> routes during route selection
>>>>
>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>> ---
>>>> RFC to v1:
>>>>          Addressed a few comments from Eric and Robert:
>>>>          - remove support for weighted nexthops
>>>>          - Use rt_nhn_alive in the rt structure to keep count of alive
>>>>          routes.
>>>>          What i have not done is: sort nexthops on link events.
>>>>          I am not comfortable recreating or sorting nexthops on
>>>>          every carrier change. This leaves scope for optimizing in the future
>>>>
>>>> v1 to v2:
>>>>     Fix dead nexthop checks as suggested by dave
>>>>
>>>>   net/mpls/af_mpls.c  | 191 ++++++++++++++++++++++++++++++++++++++++++++--------
>>>>   net/mpls/internal.h |   3 +
>>>>   2 files changed, 166 insertions(+), 28 deletions(-)
>>>>
>>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>>> index c70d750..5e88118 100644
>>>> --- a/net/mpls/af_mpls.c
>>>> +++ b/net/mpls/af_mpls.c
>>>> @@ -96,22 +96,15 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
>>>>   }
>>>>   EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
>>>>
>>>> -static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
>>>> -                         struct sk_buff *skb, bool bos)
>>>> +static u32 mpls_multipath_hash(struct mpls_route *rt,
>>>> +                   struct sk_buff *skb, bool bos)
>>>>   {
>>>>       struct mpls_entry_decoded dec;
>>>>       struct mpls_shim_hdr *hdr;
>>>>       bool eli_seen = false;
>>>>       int label_index;
>>>> -    int nh_index = 0;
>>>>       u32 hash = 0;
>>>>
>>>> -    /* No need to look further into packet if there's only
>>>> -     * one path
>>>> -     */
>>>> -    if (rt->rt_nhn == 1)
>>>> -        goto out;
>>>> -
>>>>       for (label_index = 0; label_index < MAX_MP_SELECT_LABELS && !bos;
>>>>            label_index++) {
>>>>           if (!pskb_may_pull(skb, sizeof(*hdr) * label_index))
>>>> @@ -165,9 +158,37 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
>>>>           }
>>>>       }
>>>>
>>>> -    nh_index = hash % rt->rt_nhn;
>>>> +    return hash;
>>>> +}
>>>> +
>>>> +static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
>>>> +                         struct sk_buff *skb, bool bos)
>>>> +{
>>>> +    u32 hash = 0;
>>>> +    int nh_index;
>>>> +    int n = 0;
>>>> +
>>>> +    /* No need to look further into packet if there's only
>>>> +     * one path
>>>> +     */
>>>> +    if (rt->rt_nhn == 1)
>>>> +        goto out;
>>>> +
>>>> +    if (rt->rt_nhn_alive <= 0)
>>>> +        return NULL;
>>>> +
>>>> +    hash = mpls_multipath_hash(rt, skb, bos);
>>>> +    nh_index = hash % rt->rt_nhn_alive;
>>>> +    for_nexthops(rt) {
>>> This should be optimised in the common rt->rt_nhn_alive == rt->rt_nhn case by doing the direct array index and avoid the nh walk.
>> sure, that is an optimization.  i will add that.
>>>> +        if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
>>>> +            continue;
>>>> +        if (n == nh_index)
>>>> +            return nh;
>>>> +        n++;
>>>> +    } endfor_nexthops(rt);
>>>> +
>>>>   out:
>>>> -    return &rt->rt_nh[nh_index];
>>>> +    return &rt->rt_nh[0];
>>>>   }
>>>>
>>>>   static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>>>> @@ -365,6 +386,7 @@ static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
>>>>                GFP_KERNEL);
>>>>       if (rt) {
>>>>           rt->rt_nhn = num_nh;
>>>> +        rt->rt_nhn_alive = num_nh;
>>>>           rt->rt_max_alen = max_alen_aligned;
>>>>       }
>>>>
>>>> @@ -536,6 +558,15 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
>>>>
>>>>       RCU_INIT_POINTER(nh->nh_dev, dev);
>>>>
>>>> +    if (!netif_carrier_ok(dev))
>>>> +        nh->nh_flags |= RTNH_F_LINKDOWN;
>>>> +
>>>> +    if (!(dev->flags & IFF_UP))
>>>> +        nh->nh_flags |= RTNH_F_DEAD;
>>> Below you're testing IFF_RUNNING | IFF_LOWER_UP. Is the difference intended here?
>> Not really. I can change it. This is during adding the route. I tried to keep the checks consistent with ipv4.
>>
>>>> +
>>>> +    if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
>>>> +        rt->rt_nhn_alive--;
>>> You don't update your new rt->rt_flags field here. This highlights the issue with duplicating data, which you're doing with the rt_flags field.
>> I am not sure I understand completely. Would you prefer i loop and derive the rt_flags from nh_flags during dumps than storing them in rt_flags ?. Sure I can do that. I did not think it was such a big deal because, all routes (ipv4 and others) have rt_flags and all routes today carry RTNH_ flags and you have to send them to userspace in rtm_flags anyways.
>> I am just trying to keep the use and semantics of RTNH_F flags for mpls routes consistent with the other family routes.
>>
>>>> +
>>>>       return 0;
>>>>
>>>>   errout:
>>>> @@ -577,7 +608,7 @@ errout:
>>>>   }
>>>>
>>>>   static int mpls_nh_build(struct net *net, struct mpls_route *rt,
>>>> -             struct mpls_nh *nh, int oif,
>>>> +             struct mpls_nh *nh, int oif, int hops,
>>> This change isn't required.
>> ack, this is a leftover from my attempt to add weights. will remove it.
>>>>                struct nlattr *via, struct nlattr *newdst)
>>>>   {
>>>>       int err = -ENOMEM;
>>>> @@ -666,7 +697,7 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
>>>>           /* neither weighted multipath nor any flags
>>>>            * are supported
>>>>            */
>>>> -        if (rtnh->rtnh_hops || rtnh->rtnh_flags)
>>>> +        if (rtnh->rtnh_flags || rtnh->rtnh_flags)
>>> As the build bot has pointed out, this change is not entirely correct.
>> yes, this was fixed later.
>>>>               goto errout;
>>>>
>>>>           attrlen = rtnh_attrlen(rtnh);
>>>> @@ -681,8 +712,8 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
>>>>               goto errout;
>>>>
>>>>           err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
>>>> -                    rtnh->rtnh_ifindex, nla_via,
>>>> -                    nla_newdst);
>>>> +                    rtnh->rtnh_ifindex, rtnh->rtnh_hops,
>>>> +                    nla_via, nla_newdst);
>>> This change isn't required.
>> yep, ack. same here left over from weights. will remove it.
>>
>>>>           if (err)
>>>>               goto errout;
>>>>
>>>> @@ -875,34 +906,100 @@ free:
>>>>       return ERR_PTR(err);
>>>>   }
>>>>
>>>> -static void mpls_ifdown(struct net_device *dev)
>>>> +static void mpls_ifdown(struct net_device *dev, int event)
>>>>   {
>>>>       struct mpls_route __rcu **platform_label;
>>>>       struct net *net = dev_net(dev);
>>>> -    struct mpls_dev *mdev;
>>>>       unsigned index;
>>>> +    int dead;
>>>>
>>>>       platform_label = rtnl_dereference(net->mpls.platform_label);
>>>>       for (index = 0; index < net->mpls.platform_labels; index++) {
>>>>           struct mpls_route *rt = rtnl_dereference(platform_label[index]);
>>>> +
>>>>           if (!rt)
>>>>               continue;
>>>> +        dead = 0;
>>>>           for_nexthops(rt) {
>>>> +            if ((event == NETDEV_DOWN &&
>>>> +                 (nh->nh_flags & RTNH_F_DEAD)) ||
>>>> +                 (event == NETDEV_CHANGE &&
>>>> +                 (nh->nh_flags & RTNH_F_LINKDOWN))) {
>>>> +                dead++;
>>>> +                continue;
>>>> +            }
>>>> +
>>>>               if (rtnl_dereference(nh->nh_dev) != dev)
>>>>                   continue;
>>>> -            nh->nh_dev = NULL;
>>>> +            switch (event) {
>>>> +            case NETDEV_DOWN:
>>>> +            case NETDEV_UNREGISTER:
>>>> +                nh->nh_flags |= RTNH_F_DEAD;
>>>> +                /* fall through */
>>>> +            case NETDEV_CHANGE:
>>>> +                nh->nh_flags |= RTNH_F_LINKDOWN;
>>>> +                rt->rt_nhn_alive--;
>>> Are these operations atomic on all architectures?
>> I think so.
> Ugh.  I don't see how.
> A) You are doing read-modify-write. 
> B) You are modifying multiple fields.
>
> So while the individual field writes may be atomic the changes certainly
> are not atomic.
>
>>> Even if they are, I'm a bit worried about the RCU-correctness of this. I think the fallthrough case in mpls_select_multipath saves you, causing traffic to get via nh0 instead of the one selected by the hash (which is fine transiently).
>>>
> I share your concern.  In-place modification sounds good in principle
> for handling RCU, but there is a reason why the original version of
> RCU was called Read-Copy-Update.   Given that there are multiple fields
> that seem to depend upon each other I am not certain we can perform rcu
> safe modifications without creating a fresh copy of the route.
>
I misread the initial comment. For some reason i thought the concern pointed out was between multiple updaters. And currently those are all under rtnl. I now realize it was the reader in the packet path you were talking about which may not see the update atomically.  I see how this will need to be a fresh copy and mpls_route_update on every link state change.
