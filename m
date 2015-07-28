From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 28 Jul 2015 14:15:12 -0700
Message-ID: <CALx6S36e1rr=4EbD+-FgodWam6KR5034X3jFsYYDTaLKbQF-PA@mail.gmail.com>
References: <55B6E8AC.4060600@alliedtelesis.co.nz>
	<CALx6S361R1UeEECQn9vFDCS-wi_StoV6mekqgSK-0t-0NPvWEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>, Martin Lau <kafai@fb.com>
To: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33275 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbbG1VPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 17:15:13 -0400
Received: by igbpg9 with SMTP id pg9so154462417igb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 14:15:12 -0700 (PDT)
In-Reply-To: <CALx6S361R1UeEECQn9vFDCS-wi_StoV6mekqgSK-0t-0NPvWEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2015 at 2:02 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Jul 27, 2015 at 7:27 PM, Richard Laing
> <Richard.Laing@alliedtelesis.co.nz> wrote:
>> From: Richard Laing <richard.laing@alliedtelesis.co.nz>
>>
>> Enable flow-based ECMP.
>>
>> Currently if equal-cost multipath is enabled the kernel chooses between
>> equal cost paths for each matching packet, essentially packets are
>> round-robined between the routes. This means that packets from a single
>> flow can traverse different routes. If one of the routes experiences
>> congestion this can result in delayed or out of order packets arriving
>> at the destination.
>>
> Richard, someone was complaining to me just last week about the
> weakness of the round robin algorithm. Thanks for looking into this!
>
>> This patch allows packets to be routed based on their
>> flow - packets in the same flow will always use the same route. This
>> prevents out of order packets. There are other issues with round-robin
>> based ECMP routing related to variable path MTU handling and debugging.
>> See RFC2991 for more details on the problems associated with packet
>> based ECMP routing.
>>

btw, it looks like IPv6 is already doing the hash but is calculating
it by hand instead of using sk_txhash or skb->hash. It would be nice
if we could unify this between v4 and v6 at some point to both using
the existing hashes.

Tom

>> This patch relies on the skb hash value to select between routes. The
>> selection uses a hash-threshold algorithm (see RFC2992).
>>
>> Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>
>> ---
>>
>>   include/net/flow.h       |   14 ++++++++++++++
>>   include/net/ip_fib.h     |    9 +++++++++
>>   include/net/route.h      |    4 ++++
>>   net/ipv4/Kconfig         |    9 +++++++++
>>   net/ipv4/fib_semantics.c |   38 ++++++++++++++++++++++++++++++++++++++
>>   net/ipv4/route.c         |   14 +++++++++++++-
>>   6 files changed, 87 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/net/flow.h b/include/net/flow.h
>> index 8109a15..d1d933d 100644
>> --- a/include/net/flow.h
>> +++ b/include/net/flow.h
>> @@ -79,6 +79,10 @@ struct flowi4 {
>>   #define fl4_ipsec_spi        uli.spi
>>   #define fl4_mh_type        uli.mht.type
>>   #define fl4_gre_key        uli.gre_key
>> +
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>
> Why bother making this a CONFIG, round robin is a miserable algorithm
> anyway and nearly all the other packet steering mechanisms already use
> a hash.
>
>> +    __u32    flowi4_hash;
>> +#endif
>>   } __attribute__((__aligned__(BITS_PER_LONG/8)));
>>
>>   static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
>> @@ -99,6 +103,9 @@ static inline void flowi4_init_output(struct flowi4
>> *fl4, int oif,
>>       fl4->saddr = saddr;
>>       fl4->fl4_dport = dport;
>>       fl4->fl4_sport = sport;
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +    fl4->flowi4_hash = 0;
>> +#endif
>>   }
>>
>>   /* Reset some input parameters after previous lookup */
>> @@ -182,6 +189,13 @@ static inline struct flowi *flowidn_to_flowi(struct
>> flowidn *fldn)
>>       return container_of(fldn, struct flowi, u.dn);
>>   }
>>
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +static inline void flowi4_set_flow_hash(struct flowi4 *fl, __u32 hash)
>> +{
>> +    fl->flowi4_hash = hash;
>> +}
>> +#endif
>> +
>>   typedef unsigned long flow_compare_t;
>>
>>   static inline size_t flow_key_size(u16 family)
>> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
>> index 5fa643b..c841698 100644
>> --- a/include/net/ip_fib.h
>> +++ b/include/net/ip_fib.h
>> @@ -117,6 +117,10 @@ struct fib_info {
>>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>>       int            fib_power;
>>   #endif
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +    /* Cache the number of live nexthops for flow based ECMP
>> calculation. */
>> +    int            live_nexthops;
>> +#endif
>>       struct rcu_head        rcu;
>>       struct fib_nh        fib_nh[0];
>>   #define fib_dev        fib_nh[0].nh_dev
>> @@ -311,6 +315,11 @@ int fib_sync_down_addr(struct net *net, __be32 local);
>>   int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
>>   void fib_select_multipath(struct fib_result *res);
>>
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +void fib_select_multipath_for_flow(struct fib_result *res,
>> +                   const struct flowi4 *fl4);
>> +#endif
>> +
>>   /* Exported by fib_trie.c */
>>   void fib_trie_init(void);
>>   struct fib_table *fib_trie_table(u32 id, struct fib_table *alias);
>> diff --git a/include/net/route.h b/include/net/route.h
>> index fe22d03..fdbbe7f 100644
>> --- a/include/net/route.h
>> +++ b/include/net/route.h
>> @@ -252,6 +252,10 @@ static inline void ip_route_connect_init(struct
>> flowi4 *fl4, __be32 dst, __be32
>>
>>       flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
>>                  protocol, flow_flags, dst, src, dport, sport);
>> +
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +    flowi4_set_flow_hash(fl4, sk->sk_hash);
>
> Should be sk_txhash I think.
>
>> +#endif
>>   }
>>
>>   static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> index 6fb3c90..76714d0 100644
>> --- a/net/ipv4/Kconfig
>> +++ b/net/ipv4/Kconfig
>> @@ -90,6 +90,15 @@ config IP_ROUTE_MULTIPATH
>>         equal "cost" and chooses one of them in a non-deterministic fashion
>>         if a matching packet arrives.
>>
>> +config IP_FLOW_BASED_MULTIPATH
>> +    bool "IP: flow based equal cost multipath"
>> +    depends on IP_ROUTE_MULTIPATH
>> +    help
>> +      Normally if equal cost multipath is enabled the router chooses
>> between
>> +          equal "cost" paths for each matching packet, essentially
>> packets are round-
>> +          robined between the routes. This option allows packets to be
>> routed based on
>> +          their flow - packets in the same flow will always use the
>> same route.
>> +
>>   config IP_ROUTE_VERBOSE
>>       bool "IP: verbose route monitoring"
>>       depends on IP_ADVANCED_ROUTER
>> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
>> index 3a06586..e4750e6 100644
>> --- a/net/ipv4/fib_semantics.c
>> +++ b/net/ipv4/fib_semantics.c
>> @@ -981,6 +981,9 @@ link_it:
>>           head = &fib_info_devhash[hash];
>>           hlist_add_head(&nexthop_nh->nh_hash, head);
>>       } endfor_nexthops(fi)
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +    fi->live_nexthops = fi->fib_nhs;
>> +#endif
>>       spin_unlock_bh(&fib_info_lock);
>>       return fi;
>>
>> @@ -1196,6 +1199,9 @@ int fib_sync_down_dev(struct net_device *dev,
>> unsigned long event)
>>               }
>>               ret++;
>>           }
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +        fi->live_nexthops = fi->fib_nhs - dead;
>> +#endif
>>       }
>>
>>       return ret;
>> @@ -1331,6 +1337,9 @@ int fib_sync_up(struct net_device *dev, unsigned
>> int nh_flags)
>>           if (alive > 0) {
>>               fi->fib_flags &= ~nh_flags;
>>               ret++;
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +            fi->live_nexthops = alive;
>> +#endif
>>           }
>>       }
>>
>> @@ -1397,4 +1406,33 @@ void fib_select_multipath(struct fib_result *res)
>>       res->nh_sel = 0;
>>       spin_unlock_bh(&fib_multipath_lock);
>>   }
>> +
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +void fib_select_multipath_for_flow(struct fib_result *res,
>> +                   const struct flowi4 *fl4)
>> +{
>> +    struct fib_info *fi = res->fi;
>> +    int multipath_entry;
>> +    int region_size;
>> +
>> +    if (fl4->flowi4_hash) {
>> +        /* Hash-threshold algorithm, see RFC2992. */
>> +        region_size = U32_MAX / fi->live_nexthops;
>> +        multipath_entry = fl4->flowi4_hash / region_size;
>> +
>> +        spin_lock_bh(&fib_multipath_lock);
>> +        for_nexthops(fi) {
>> +            if (!(nh->nh_flags & RTNH_F_DEAD)) {
>> +                res->nh_sel = nhsel;
>> +                if (multipath_entry == 0)
>> +                    break;
>> +                multipath_entry--;
>> +            }
>> +        } endfor_nexthops(fi);
>> +        spin_unlock_bh(&fib_multipath_lock);
>> +    } else {
>> +        fib_select_multipath(res);
>> +    }
>> +}
>> +#endif
>>   #endif
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index e681b85..4629c04 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -1638,9 +1638,17 @@ static int ip_mkroute_input(struct sk_buff *skb,
>>                   __be32 daddr, __be32 saddr, u32 tos)
>>   {
>>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>> -    if (res->fi && res->fi->fib_nhs > 1)
>> +    if (res->fi && res->fi->fib_nhs > 1) {
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +        if (skb)
>> +            flowi4_set_flow_hash((struct flowi4 *)fl4,
>> +                         skb_get_hash(skb));
>> +        fib_select_multipath_for_flow(res, fl4);
>> +#else
>>           fib_select_multipath(res);
>>   #endif
>> +    }
>> +#endif
>>
>>       /* create a routing cache entry */
>>       return __mkroute_input(skb, res, in_dev, daddr, saddr, tos);
>> @@ -2170,7 +2178,11 @@ struct rtable *__ip_route_output_key(struct net
>> *net, struct flowi4 *fl4)
>>
>>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>>       if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
>> +#ifdef CONFIG_IP_FLOW_BASED_MULTIPATH
>> +        fib_select_multipath_for_flow(&res, fl4);
>> +#else
>>           fib_select_multipath(&res);
>> +#endif
>>       else
>>   #endif
>>       if (!res.prefixlen &&
