From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] mpls: move mpls_route nexthop fields to
 a new nhlfe struct
Date: Wed, 12 Aug 2015 20:16:51 -0700
Message-ID: <55CC0C23.2050901@cumulusnetworks.com>
References: <1439329548-50935-2-git-send-email-roopa@cumulusnetworks.com> <55CB9B3B.1060809@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ebiederm@xmission.com, netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33035 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbHMDQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 23:16:54 -0400
Received: by pdrh1 with SMTP id h1so14120604pdr.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 20:16:54 -0700 (PDT)
In-Reply-To: <55CB9B3B.1060809@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/15, 12:15 PM, Robert Shearman wrote:
> On 11/08/15 22:45, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> moves mpls_route nexthop fields to a new mpls_nhlfe
>> struct. mpls_nhlfe represents a mpls nexthop label forwarding entry.
>> It prepares mpls route structure for multipath support.
>>
>> In the process moves mpls_route structure into internal.h.
>
> Is there a requirement for moving this and the new datastructures into 
> internal.h? I may have missed it, but I don't see any dependency on 
> this in this patch series.

No dependency really. In my initial implementation of iptunnels I had 
some shared code and it had been in internal.h since then.
  i don't share any of this with iptunnels now. But, if you see patch 
3/3, there is a lot more macros I add with struct nhlfe etc and it is 
cleaner
to move all this to a header file than keeping it in the .c file.
>
>> Moves some of the code from mpls_route_add into a separate mpls
>> nhlfe build function. changed mpls_rt_alloc to take number of
>> nexthops as argument.
>>
>> A mpls route can point to multiple mpls_nhlfe. This patch
>> does not support multipath yet, hence the rest of the changes
>> assume that a mpls route points to a single mpls_nhlfe
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>   net/mpls/af_mpls.c  |  225 
>> ++++++++++++++++++++++++++++-----------------------
>>   net/mpls/internal.h |   35 ++++++++
>>   2 files changed, 158 insertions(+), 102 deletions(-)
>>
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index 8c5707d..cf86e9d 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
>> @@ -21,35 +21,6 @@
>>   #endif
>>   #include "internal.h"
>>
>> -#define LABEL_NOT_SPECIFIED (1<<20)
>> -#define MAX_NEW_LABELS 2
>> -
>> -/* This maximum ha length copied from the definition of struct 
>> neighbour */
>> -#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
>> -
>> -enum mpls_payload_type {
>> -    MPT_UNSPEC, /* IPv4 or IPv6 */
>> -    MPT_IPV4 = 4,
>> -    MPT_IPV6 = 6,
>> -
>> -    /* Other types not implemented:
>> -     *  - Pseudo-wire with or without control word (RFC4385)
>> -     *  - GAL (RFC5586)
>> -     */
>> -};
>> -
>> -struct mpls_route { /* next hop label forwarding entry */
>> -    struct net_device __rcu *rt_dev;
>> -    struct rcu_head        rt_rcu;
>> -    u32            rt_label[MAX_NEW_LABELS];
>> -    u8            rt_protocol; /* routing protocol that set this 
>> entry */
>> -    u8                      rt_payload_type;
>> -    u8            rt_labels;
>> -    u8            rt_via_alen;
>> -    u8            rt_via_table;
>> -    u8            rt_via[0];
>> -};
>> -
>>   static int zero = 0;
>>   static int label_limit = (1 << 20) - 1;
>>
> ...
>> @@ -281,13 +254,15 @@ struct mpls_route_config {
>>       struct nl_info        rc_nlinfo;
>>   };
>>
>> -static struct mpls_route *mpls_rt_alloc(size_t alen)
>> +static struct mpls_route *mpls_rt_alloc(int num_nh)
>>   {
>>       struct mpls_route *rt;
>>
>> -    rt = kzalloc(sizeof(*rt) + alen, GFP_KERNEL);
>> +    rt = kzalloc(sizeof(*rt) + (num_nh * sizeof(struct mpls_nhlfe)),
>
> How about this instead:
>   offsetof(typeof(*rt), rt_nh[num_nh])
> ?
>
> That way, you don't need to write out the type of rt_nh here.
I don't mind, but i followed existing convention for this (especially 
the fib code).
would prefer keeping it the current way.
>
>> +             GFP_KERNEL);
>>       if (rt)
>> -        rt->rt_via_alen = alen;
>> +        rt->rt_nhn = num_nh;
>> +
>>       return rt;
>>   }
>>
>> @@ -322,7 +297,7 @@ static void mpls_route_update(struct net *net, 
>> unsigned index,
>>
>>       platform_label = rtnl_dereference(net->mpls.platform_label);
>>       rt = rtnl_dereference(platform_label[index]);
>> -    if (!dev || (rt && (rtnl_dereference(rt->rt_dev) == dev))) {
>> +    if (!dev || (rt && (rtnl_dereference(rt->rt_nh->nh_dev) == dev))) {
>>           rcu_assign_pointer(platform_label[index], new);
>>           old = rt;
>>       }
>> @@ -406,23 +381,23 @@ static struct net_device 
>> *inet6_fib_lookup_dev(struct net *net, void *addr)
>>   #endif
>>
>>   static struct net_device *find_outdev(struct net *net,
>> -                      struct mpls_route_config *cfg)
>> +                      struct mpls_nhlfe *nhlfe, int oif)
>>   {
>>       struct net_device *dev = NULL;
>>
>> -    if (!cfg->rc_ifindex) {
>> -        switch (cfg->rc_via_table) {
>> +    if (!oif) {
>> +        switch (nhlfe->nh_via_table) {
>>           case NEIGH_ARP_TABLE:
>> -            dev = inet_fib_lookup_dev(net, cfg->rc_via);
>> +            dev = inet_fib_lookup_dev(net, nhlfe->nh_via);
>>               break;
>>           case NEIGH_ND_TABLE:
>> -            dev = inet6_fib_lookup_dev(net, cfg->rc_via);
>> +            dev = inet6_fib_lookup_dev(net, nhlfe->nh_via);
>>               break;
>>           case NEIGH_LINK_TABLE:
>>               break;
>>           }
>>       } else {
>> -        dev = dev_get_by_index(net, cfg->rc_ifindex);
>> +        dev = dev_get_by_index(net, oif);
>>       }
>>
>>       if (!dev)
>> @@ -431,15 +406,81 @@ static struct net_device *find_outdev(struct 
>> net *net,
>>       return dev;
>>   }
>>
>> +int mpls_nhlfe_assign_dev(struct net *net, struct mpls_nhlfe *nhlfe, 
>> int oif)
>> +{
>> +    struct net_device *dev = NULL;
>> +    int err = -ENODEV;
>> +
>> +    dev = find_outdev(net, nhlfe, oif);
>> +    if (IS_ERR(dev)) {
>> +        err = PTR_ERR(dev);
>> +        dev = NULL;
>> +        goto errout;
>> +    }
>> +
>> +    /* Ensure this is a supported device */
>> +    err = -EINVAL;
>> +    if (!mpls_dev_get(dev))
>> +        goto errout;
>> +
>> +    /* For now just support ethernet devices */
>> +    err = -EINVAL;
>> +    if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
>> +        goto errout;
>
> Isn't this interface type check redundant with the mpls_dev_get call 
> just above?

That is correct. I had this check before mpls_dev_get was added. Will 
remove it
>
>> +
>> +    RCU_INIT_POINTER(nhlfe->nh_dev, dev);
>> +    dev_put(dev);
>
> Is it safe to release the reference to dev here? Prior to these 
> changes, it was released after mpls_route_update is called in 
> mpls_route_add - is that OK without a reference?
>

>> +
>> +    return 0;
>> +
>> +errout:
>> +    if (dev)
>> +        dev_put(dev);
>> +    return err;
>> +}
>> +
>> +static int mpls_nhlfe_build(struct mpls_route_config *cfg,
>> +                struct mpls_nhlfe *nhlfe)
>> +{
>> +    struct net *net = cfg->rc_nlinfo.nl_net;
>> +    int err = -ENOMEM;
>> +    int i;
>> +
>> +    if (!nhlfe)
>> +        goto errout;
>> +
>> +    err = -EINVAL;
>> +    /* Ensure only a supported number of labels are present */
>> +    if (cfg->rc_output_labels > MAX_NEW_LABELS)
>> +        goto errout;
>> +
>> +    nhlfe->nh_labels = cfg->rc_output_labels;
>> +    for (i = 0; i < nhlfe->nh_labels; i++)
>> +        nhlfe->nh_label[i] = cfg->rc_output_label[i];
>> +
>> +    nhlfe->nh_payload_type = cfg->rc_payload_type;
>> +    nhlfe->nh_via_table = cfg->rc_via_table;
>> +    memcpy(nhlfe->nh_via, cfg->rc_via, cfg->rc_via_alen);
>> +    nhlfe->nh_via_alen = cfg->rc_via_alen;
>
> Shouldn't this check that was removed from mpls_route_add be added here:
>
> -    if ((cfg->rc_via_table == NEIGH_LINK_TABLE) &&
> -        (dev->addr_len != cfg->rc_via_alen))
> -        goto errout;
>
> ?
>
>> +
>> +    err = mpls_nhlfe_assign_dev(net, nhlfe, cfg->rc_ifindex);
>> +    if (err)
>> +        goto errout;
>> +
>> +    return 0;
>> +
>> +errout:
>> +    return err;
>> +}
>> +
>>   static int mpls_route_add(struct mpls_route_config *cfg)
>>   {
>>       struct mpls_route __rcu **platform_label;
>>       struct net *net = cfg->rc_nlinfo.nl_net;
>> -    struct net_device *dev = NULL;
>>       struct mpls_route *rt, *old;
>> -    unsigned index;
>> -    int i;
>>       int err = -EINVAL;
>> +    unsigned index;
>> +    int nhs = 1; /* default to one nexthop */
>>
>>       index = cfg->rc_label;
>>
>> @@ -457,27 +498,6 @@ static int mpls_route_add(struct 
>> mpls_route_config *cfg)
>>       if (index >= net->mpls.platform_labels)
>>           goto errout;
>>
>> -    /* Ensure only a supported number of labels are present */
>> -    if (cfg->rc_output_labels > MAX_NEW_LABELS)
>> -        goto errout;
>> -
>> -    dev = find_outdev(net, cfg);
>> -    if (IS_ERR(dev)) {
>> -        err = PTR_ERR(dev);
>> -        dev = NULL;
>> -        goto errout;
>> -    }
>> -
>> -    /* Ensure this is a supported device */
>> -    err = -EINVAL;
>> -    if (!mpls_dev_get(dev))
>> -        goto errout;
>> -
>> -    err = -EINVAL;
>> -    if ((cfg->rc_via_table == NEIGH_LINK_TABLE) &&
>> -        (dev->addr_len != cfg->rc_via_alen))
>> -        goto errout;
>> -
>>       /* Append makes no sense with mpls */
>>       err = -EOPNOTSUPP;
>>       if (cfg->rc_nlflags & NLM_F_APPEND)
> ...
>> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
>> index 2681a4b..f05e2e8 100644
>> --- a/net/mpls/internal.h
>> +++ b/net/mpls/internal.h
> ...
>> @@ -21,6 +32,30 @@ struct mpls_dev {
>>
>>   struct sk_buff;
>>
>> +#define LABEL_NOT_SPECIFIED (1 << 20)
>> +#define MAX_NEW_LABELS 2
>> +
>> +/* This maximum ha length copied from the definition of struct 
>> neighbour */
>> +#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
>> +
>> +struct mpls_nhlfe { /* next hop label forwarding entry */
>
> Can we just call this mpls_nh? IMHO, NHLFE is a bit of MPLS-specific 
> jargon that doesn't really add anything and may impact readability for 
> anybody familiar with other protocols, but not with the MPLS RFCs.
sure..., i did like the name nhlfe...but i have no problems changing it :)
>
>> +    struct net_device __rcu *nh_dev;
>> +    u32            nh_label[MAX_NEW_LABELS];
>> +    unsigned int        nh_flags;
>
> Is it worth adding the nh_flags field? Unless I missed something it 
> isn't used in this patch and isn't written in any subsequent patches.
Not right now. I was thinking of adding the DEAD flags soon. But i can 
skip it now and add it later.
>
>> +    u8            nh_payload_type;
>
> nh_payload_type isn't really an attribute of the nexthop, but of the 
> route - it's signally the type of traffic that is using that route.
hmm..., ok i think i see it now, will move it.
>
>
>> +    u8            nh_labels;
>> +    u8            nh_via_alen;
>> +    u8            nh_via_table;
>> +    u8            nh_via[MAX_VIA_ALEN];
>
> MAX_VIA_ALEN is 32 bytes, so there is now a 28 byte overhead per 
> nexthop for the common case of using an IPv4 nexthop. With a large 
> number of routes/nexthops, this will become noticeable. If we avoided 
> using a fixed allocation, it would mitigate this.

yeah, I did go back and forth about this. Let me see what i can do.
>
>> +};
>> +
>> +struct mpls_route { /* next hop label forwarding entry */
>
> Is it still the NHLFE? :-)
oops :), will fix the comment.
>
>> +    struct rcu_head        rt_rcu;
>> +    u8            rt_protocol;
>> +    int            rt_nhn;
>> +    struct mpls_nhlfe    rt_nh[0];
>> +};
>> +
>>   static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff 
>> *skb)
>>   {
>>       return (struct mpls_shim_hdr *)skb_network_header(skb);
>>
>
Thanks for the review.
