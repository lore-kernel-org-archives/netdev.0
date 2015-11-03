From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] mpls: support for dead routes
Date: Tue, 03 Nov 2015 09:21:17 -0800
Message-ID: <5638ED0D.5030301@cumulusnetworks.com>
References: <1446527581-64787-1-git-send-email-roopa@cumulusnetworks.com> <5638CDE4.2080501@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33302 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207AbbKCRVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 12:21:20 -0500
Received: by pabfh17 with SMTP id fh17so23882927pab.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 09:21:19 -0800 (PST)
In-Reply-To: <5638CDE4.2080501@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/15, 7:08 AM, Robert Shearman wrote:
> On 03/11/15 05:13, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
>> routes due to link events. Also adds code to ignore dead
>> routes during route selection
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> RFC to v1:
>>          Addressed a few comments from Eric and Robert:
>>          - remove support for weighted nexthops
>>          - Use rt_nhn_alive in the rt structure to keep count of alive
>>          routes.
>>          What i have not done is: sort nexthops on link events.
>>          I am not comfortable recreating or sorting nexthops on
>>          every carrier change. This leaves scope for optimizing in the future
>>
>> v1 to v2:
>>     Fix dead nexthop checks as suggested by dave
>>
>>   net/mpls/af_mpls.c  | 191 ++++++++++++++++++++++++++++++++++++++++++++--------
>>   net/mpls/internal.h |   3 +
>>   2 files changed, 166 insertions(+), 28 deletions(-)
>>
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index c70d750..5e88118 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
>> @@ -96,22 +96,15 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
>>   }
>>   EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
>>
>> -static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
>> -                         struct sk_buff *skb, bool bos)
>> +static u32 mpls_multipath_hash(struct mpls_route *rt,
>> +                   struct sk_buff *skb, bool bos)
>>   {
>>       struct mpls_entry_decoded dec;
>>       struct mpls_shim_hdr *hdr;
>>       bool eli_seen = false;
>>       int label_index;
>> -    int nh_index = 0;
>>       u32 hash = 0;
>>
>> -    /* No need to look further into packet if there's only
>> -     * one path
>> -     */
>> -    if (rt->rt_nhn == 1)
>> -        goto out;
>> -
>>       for (label_index = 0; label_index < MAX_MP_SELECT_LABELS && !bos;
>>            label_index++) {
>>           if (!pskb_may_pull(skb, sizeof(*hdr) * label_index))
>> @@ -165,9 +158,37 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
>>           }
>>       }
>>
>> -    nh_index = hash % rt->rt_nhn;
>> +    return hash;
>> +}
>> +
>> +static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
>> +                         struct sk_buff *skb, bool bos)
>> +{
>> +    u32 hash = 0;
>> +    int nh_index;
>> +    int n = 0;
>> +
>> +    /* No need to look further into packet if there's only
>> +     * one path
>> +     */
>> +    if (rt->rt_nhn == 1)
>> +        goto out;
>> +
>> +    if (rt->rt_nhn_alive <= 0)
>> +        return NULL;
>> +
>> +    hash = mpls_multipath_hash(rt, skb, bos);
>> +    nh_index = hash % rt->rt_nhn_alive;
>> +    for_nexthops(rt) {
>
> This should be optimised in the common rt->rt_nhn_alive == rt->rt_nhn case by doing the direct array index and avoid the nh walk.

sure, that is an optimization.  i will add that.
>
>> +        if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
>> +            continue;
>> +        if (n == nh_index)
>> +            return nh;
>> +        n++;
>> +    } endfor_nexthops(rt);
>> +
>>   out:
>> -    return &rt->rt_nh[nh_index];
>> +    return &rt->rt_nh[0];
>>   }
>>
>>   static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>> @@ -365,6 +386,7 @@ static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
>>                GFP_KERNEL);
>>       if (rt) {
>>           rt->rt_nhn = num_nh;
>> +        rt->rt_nhn_alive = num_nh;
>>           rt->rt_max_alen = max_alen_aligned;
>>       }
>>
>> @@ -536,6 +558,15 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
>>
>>       RCU_INIT_POINTER(nh->nh_dev, dev);
>>
>> +    if (!netif_carrier_ok(dev))
>> +        nh->nh_flags |= RTNH_F_LINKDOWN;
>> +
>> +    if (!(dev->flags & IFF_UP))
>> +        nh->nh_flags |= RTNH_F_DEAD;
>
> Below you're testing IFF_RUNNING | IFF_LOWER_UP. Is the difference intended here?
Not really. I can change it. This is during adding the route. I tried to keep the checks consistent with ipv4.

>> +
>> +    if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
>> +        rt->rt_nhn_alive--;
>
> You don't update your new rt->rt_flags field here. This highlights the issue with duplicating data, which you're doing with the rt_flags field.
I am not sure I understand completely. Would you prefer i loop and derive the rt_flags from nh_flags during dumps than storing them in rt_flags ?. Sure I can do that. I did not think it was such a big deal because, all routes (ipv4 and others) have rt_flags and all routes today carry RTNH_ flags and you have to send them to userspace in rtm_flags anyways.
I am just trying to keep the use and semantics of RTNH_F flags for mpls routes consistent with the other family routes.

>
>> +
>>       return 0;
>>
>>   errout:
>> @@ -577,7 +608,7 @@ errout:
>>   }
>>
>>   static int mpls_nh_build(struct net *net, struct mpls_route *rt,
>> -             struct mpls_nh *nh, int oif,
>> +             struct mpls_nh *nh, int oif, int hops,
>
> This change isn't required.
ack, this is a leftover from my attempt to add weights. will remove it.
>
>>                struct nlattr *via, struct nlattr *newdst)
>>   {
>>       int err = -ENOMEM;
>> @@ -666,7 +697,7 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
>>           /* neither weighted multipath nor any flags
>>            * are supported
>>            */
>> -        if (rtnh->rtnh_hops || rtnh->rtnh_flags)
>> +        if (rtnh->rtnh_flags || rtnh->rtnh_flags)
>
> As the build bot has pointed out, this change is not entirely correct.
yes, this was fixed later.
>
>>               goto errout;
>>
>>           attrlen = rtnh_attrlen(rtnh);
>> @@ -681,8 +712,8 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
>>               goto errout;
>>
>>           err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
>> -                    rtnh->rtnh_ifindex, nla_via,
>> -                    nla_newdst);
>> +                    rtnh->rtnh_ifindex, rtnh->rtnh_hops,
>> +                    nla_via, nla_newdst);
>
> This change isn't required.
yep, ack. same here left over from weights. will remove it.

>
>>           if (err)
>>               goto errout;
>>
>> @@ -875,34 +906,100 @@ free:
>>       return ERR_PTR(err);
>>   }
>>
>> -static void mpls_ifdown(struct net_device *dev)
>> +static void mpls_ifdown(struct net_device *dev, int event)
>>   {
>>       struct mpls_route __rcu **platform_label;
>>       struct net *net = dev_net(dev);
>> -    struct mpls_dev *mdev;
>>       unsigned index;
>> +    int dead;
>>
>>       platform_label = rtnl_dereference(net->mpls.platform_label);
>>       for (index = 0; index < net->mpls.platform_labels; index++) {
>>           struct mpls_route *rt = rtnl_dereference(platform_label[index]);
>> +
>>           if (!rt)
>>               continue;
>> +        dead = 0;
>>           for_nexthops(rt) {
>> +            if ((event == NETDEV_DOWN &&
>> +                 (nh->nh_flags & RTNH_F_DEAD)) ||
>> +                 (event == NETDEV_CHANGE &&
>> +                 (nh->nh_flags & RTNH_F_LINKDOWN))) {
>> +                dead++;
>> +                continue;
>> +            }
>> +
>>               if (rtnl_dereference(nh->nh_dev) != dev)
>>                   continue;
>> -            nh->nh_dev = NULL;
>> +            switch (event) {
>> +            case NETDEV_DOWN:
>> +            case NETDEV_UNREGISTER:
>> +                nh->nh_flags |= RTNH_F_DEAD;
>> +                /* fall through */
>> +            case NETDEV_CHANGE:
>> +                nh->nh_flags |= RTNH_F_LINKDOWN;
>> +                rt->rt_nhn_alive--;
>
> Are these operations atomic on all architectures?

I think so.
>
> Even if they are, I'm a bit worried about the RCU-correctness of this. I think the fallthrough case in mpls_select_multipath saves you, causing traffic to get via nh0 instead of the one selected by the hash (which is fine transiently).
>
>> +                break;
>> +            }
>> +            if (event == NETDEV_UNREGISTER) {
>> +                nh->nh_dev = NULL;
>
> I realise this was just moved from the original code, but I think this should be at least RCU_INIT_POINTER(nh->nh_dev, NULL), if not rcu_assign_pointer.
sure,
>
>> +                dead = rt->rt_nhn;
>> +                break;
>> +            }
>> +            dead++;
>>           } endfor_nexthops(rt);
>> +
>> +        if (dead == rt->rt_nhn) {
>> +            switch (event) {
>> +            case NETDEV_DOWN:
>> +            case NETDEV_UNREGISTER:
>> +                rt->rt_flags |= RTNH_F_DEAD;
>> +                /* fall through */
>> +            case NETDEV_CHANGE:
>> +                rt->rt_flags |= RTNH_F_LINKDOWN;
>> +                rt->rt_nhn_alive = 0;
>
> Won't rt_nhn_alive be zero already at this point?

yes, i will remove that redundant set to zero.
>
> There's also the problem that depending on the type of the last event, rt->rt_flags will get set differently.
>
> E.g.
>
> - NETDEV_DOWN for nh0 followed by NETDEV_CHANGE[down] for nh1 then rt->rt_flags will be RTNH_F_LINKDOWN.
> - NETDEV_CHANGE[down] for nh1 followed by NETDEV_DOWN for nh0 then rt->rt_flags will be RTNH_F_LINKDOWN|RTNH_F_DEAD.
>
> That doesn't seem like desirable behaviour. What are expected semantics?


I have tried to retain the semantics or use of RTNH flags from ipv4's use of such flags. Since they are the same flags we use across all routing families..., the semantics need to be consistent.

If all nh_flags have RTNH_F_LINKDOWN, the rt_flags gets RTNH_F_LINKDOWN
if all nh_flags have RTNH_F_DEAD, then rt_flags gets RTNH_F_DEAD

RTNH_F_DEAD was always used for admin down (before RTNH_F_LINKDOWN so we need to carry that semantics)
RTNH_F_LINKDOWN was added recently for carrier down (Its a new flag to userspace too).

>
>> +                break;
>> +            }
>> +        }
>>       }
>>
>> -    mdev = mpls_dev_get(dev);
>> -    if (!mdev)
>> -        return;
>> +    return;
>> +}
>> +
>> +static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
>> +{
>> +    struct mpls_route __rcu **platform_label;
>> +    struct net *net = dev_net(dev);
>> +    unsigned index;
>> +    int alive;
>> +
>> +    platform_label = rtnl_dereference(net->mpls.platform_label);
>> +    for (index = 0; index < net->mpls.platform_labels; index++) {
>> +        struct mpls_route *rt = rtnl_dereference(platform_label[index]);
>> +
>> +        if (!rt)
>> +            continue;
>> +        alive = 0;
>> +        for_nexthops(rt) {
>> +            struct net_device *nh_dev =
>> +                rtnl_dereference(nh->nh_dev);
>>
>> -    mpls_dev_sysctl_unregister(mdev);
>> +            if (!(nh->nh_flags & nh_flags)) {
>> +                alive++;
>> +                continue;
>> +            }
>> +            if (nh_dev != dev)
>> +                continue;
>> +            alive++;
>> +            nh->nh_flags &= ~nh_flags;
>> +        } endfor_nexthops(rt);
>>
>> -    RCU_INIT_POINTER(dev->mpls_ptr, NULL);
>> +        if (alive > 0)
>> +            rt->rt_flags &= ~nh_flags;
>
> Again, this creates a dependence on the ordering of events.

Am not sure I understand. My earlier comments may help clarify things.

>
>> +        rt->rt_nhn_alive = alive;
>> +    }
>>
>> -    kfree_rcu(mdev, rcu);
>> +    return;
>>   }
>>
>>   static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
>> @@ -910,9 +1007,9 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
>>   {
>>       struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>>       struct mpls_dev *mdev;
>> +    unsigned int flags;
>>
>> -    switch(event) {
>> -    case NETDEV_REGISTER:
>> +    if (event == NETDEV_REGISTER) {
>>           /* For now just support ethernet devices */
>>           if ((dev->type == ARPHRD_ETHER) ||
>>               (dev->type == ARPHRD_LOOPBACK)) {
>> @@ -920,10 +1017,39 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
>>               if (IS_ERR(mdev))
>>                   return notifier_from_errno(PTR_ERR(mdev));
>>           }
>> -        break;
>> +        return NOTIFY_OK;
>> +    }
>>
>> +    mdev = mpls_dev_get(dev);
>> +    if (!mdev)
>> +        return NOTIFY_OK;
>> +
>> +    switch (event) {
>> +    case NETDEV_DOWN:
>> +        mpls_ifdown(dev, event);
>> +        break;
>> +    case NETDEV_UP:
>> +        flags = dev_get_flags(dev);
>> +        if (flags & (IFF_RUNNING | IFF_LOWER_UP))
>> +            mpls_ifup(dev, RTNH_F_DEAD | RTNH_F_LINKDOWN);
>> +        else
>> +            mpls_ifup(dev, RTNH_F_DEAD);
>> +        break;
>> +    case NETDEV_CHANGE:
>> +        flags = dev_get_flags(dev);
>> +        if (flags & (IFF_RUNNING | IFF_LOWER_UP))
>> +            mpls_ifup(dev, RTNH_F_DEAD | RTNH_F_LINKDOWN);
>> +        else
>> +            mpls_ifdown(dev, event);
>> +        break;
>>       case NETDEV_UNREGISTER:
>> -        mpls_ifdown(dev);
>> +        mpls_ifdown(dev, event);
>> +        mdev = mpls_dev_get(dev);
>> +        if (mdev) {
>> +            mpls_dev_sysctl_unregister(mdev);
>> +            RCU_INIT_POINTER(dev->mpls_ptr, NULL);
>> +            kfree_rcu(mdev, rcu);
>> +        }
>>           break;
>>       case NETDEV_CHANGENAME:
>>           mdev = mpls_dev_get(dev);
>> @@ -1237,6 +1363,10 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
>>           dev = rtnl_dereference(nh->nh_dev);
>>           if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
>>               goto nla_put_failure;
>> +        if (nh->nh_flags & RTNH_F_LINKDOWN)
>> +            rtm->rtm_flags |= RTNH_F_LINKDOWN;
>> +        if (nh->nh_flags & RTNH_F_DEAD)
>> +            rtm->rtm_flags |= RTNH_F_DEAD;
>>       } else {
>>           struct rtnexthop *rtnh;
>>           struct nlattr *mp;
>> @@ -1253,6 +1383,11 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
>>               dev = rtnl_dereference(nh->nh_dev);
>>               if (dev)
>>                   rtnh->rtnh_ifindex = dev->ifindex;
>> +            if (nh->nh_flags & RTNH_F_LINKDOWN)
>> +                rtnh->rtnh_flags |= RTNH_F_LINKDOWN;
>> +            if (nh->nh_flags & RTNH_F_DEAD)
>> +                rtnh->rtnh_flags |= RTNH_F_DEAD;
>> +
>
> You never read from rt->rt_flags. Was your intention to set rtm->rtm_flags using that field in this function?
yes, It was. Looks like i missed it. Will add it.

>
>>               if (nh->nh_labels && nla_put_labels(skb, RTA_NEWDST,
>>                                   nh->nh_labels,
>>                                   nh->nh_label))
>> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
>> index bde52ce..4f9bf2b 100644
>> --- a/net/mpls/internal.h
>> +++ b/net/mpls/internal.h
>> @@ -41,6 +41,7 @@ enum mpls_payload_type {
>>
>>   struct mpls_nh { /* next hop label forwarding entry */
>>       struct net_device __rcu *nh_dev;
>> +    unsigned int        nh_flags;
>
> This could be implemented as a u8 (or even two 1-bit fields) after nh_via_table (making use of the 1-byte hole already there) without increasing the size of the structure by a fifth.

We are using flags RTNH_F_* which is common to all routing families. So i wanted to keep the flags size consistent for any additional flags we may need to support.

>
>>       u32            nh_label[MAX_NEW_LABELS];
>>       u8            nh_labels;
>>       u8            nh_via_alen;
>> @@ -70,10 +71,12 @@ struct mpls_nh { /* next hop label forwarding entry */
>>    */
>>   struct mpls_route { /* next hop label forwarding entry */
>>       struct rcu_head        rt_rcu;
>> +    unsigned int        rt_flags;
>
> Storing this is unnecessary - it can be derived from rt_nhn_alive == 0 and looking at the nexthop flags, which also avoids the event ordering problems described above.
>
I don't think it can be derived from rt_nhn_alive. rt_nhn_alive == 0 can mean DEAD or LINKDOWN (ie dont use the nexthop). For user space you need to preserve the exact semantics of RTNH_F_DEAD and RTNH_F_LINKDOWN. One can derive this from nh_flags during dumps, but like I said, it did not seem so important to derive it or save it like the other routing families supporting these flags.


>
>>       u8            rt_protocol;
>>       u8            rt_payload_type;
>>       u8            rt_max_alen;
>>       unsigned int        rt_nhn;
>> +    unsigned int        rt_nhn_alive;
>>       struct mpls_nh        rt_nh[0];
>>   };
>>
>>
Thanks for the review.
