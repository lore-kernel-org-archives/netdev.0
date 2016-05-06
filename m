From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCHv2 bluetooth-next 07/10] ipv6: introduce neighbour
 discovery ops
Date: Fri, 6 May 2016 11:47:11 +0200
Message-ID: <741404ec-e23e-30a9-c954-83b26ea71d7e@pengutronix.de>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-8-git-send-email-aar@pengutronix.de>
 <5729E9AB.5000301@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5729E9AB.5000301-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi,

On 05/04/2016 02:23 PM, Stefan Schmidt wrote:
> Hello.
> 
> On 20/04/16 10:19, Alexander Aring wrote:
>> This patch introduces neighbour discovery ops callback structure. The
>> structure contains at first receive and transmit handling for NS/NA and
>> userspace option field functionality.
>>
>> These callback offers 6lowpan different handling, such as 802.15.4 short
>> address handling or RFC6775 (Neighbor Discovery Optimization for IPv6 over
>> 6LoWPANs).
>>
>> Cc: David S. Miller<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> Cc: Alexey Kuznetsov<kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
>> Cc: James Morris<jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
>> Cc: Hideaki YOSHIFUJI<yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
>> Cc: Patrick McHardy<kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
>> Signed-off-by: Alexander Aring<aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> ---
>>   include/linux/netdevice.h |  3 ++
>>   include/net/ndisc.h       | 96 +++++++++++++++++++++++++++++++++++++++++++----
>>   net/ipv6/addrconf.c       |  1 +
>>   net/ipv6/ndisc.c          | 71 ++++++++++++++++++++++++-----------
>>   net/ipv6/route.c          |  2 +-
>>   5 files changed, 144 insertions(+), 29 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 0052c42..bc60033 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1677,6 +1677,9 @@ struct net_device {
>>   #ifdef CONFIG_NET_L3_MASTER_DEV
>>       const struct l3mdev_ops    *l3mdev_ops;
>>   #endif
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +    const struct ndisc_ops *ndisc_ops;
>> +#endif
>>         const struct header_ops *header_ops;
>>   diff --git a/include/net/ndisc.h b/include/net/ndisc.h
>> index aac868e..14ed016 100644
>> --- a/include/net/ndisc.h
>> +++ b/include/net/ndisc.h
>> @@ -110,7 +110,8 @@ struct ndisc_options {
>>     #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
>>   -struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
>> +struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
>> +                      u8 *opt, int opt_len,
>>                         struct ndisc_options *ndopts);
>>     /*
>> @@ -173,6 +174,93 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
>>       return n;
>>   }
>>   +static inline int __ip6_ndisc_is_useropt(struct nd_opt_hdr *opt)
> 
> Name it __ipv6... instead of __ip6...?

I had ipv6 before, but then I saw ip6... prefixes functionality in
ndisc.c and changed it to ip6...., but both seems to be used.

See "ip6_nd_hdr".

>> +{
>> +    return opt->nd_opt_type == ND_OPT_RDNSS ||
>> +        opt->nd_opt_type == ND_OPT_DNSSL;
>> +}
>> +
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +struct ndisc_ops {
>> +    int    (*is_useropt)(struct nd_opt_hdr *opt);
>> +    void    (*send_na)(struct net_device *dev,
>> +               const struct in6_addr *daddr,
>> +               const struct in6_addr *solicited_addr,
>> +               bool router, bool solicited,
>> +               bool override, bool inc_opt);
>> +    void    (*recv_na)(struct sk_buff *skb);
>> +    void    (*send_ns)(struct net_device *dev,
>> +               const struct in6_addr *solicit,
>> +               const struct in6_addr *daddr,
>> +               const struct in6_addr *saddr);
>> +    void    (*recv_ns)(struct sk_buff *skb);
>> +};
>> +
>> +static inline int ndisc_is_useropt(const struct net_device *dev,
>> +                   struct nd_opt_hdr *opt)
>> +{
>> +    if (likely(dev->ndisc_ops->is_useropt))
>> +        return dev->ndisc_ops->is_useropt(opt);
>> +    else
>> +        return 0;
>> +}
>> +
>> +static inline void ndisc_send_na(struct net_device *dev,
>> +                 const struct in6_addr *daddr,
>> +                 const struct in6_addr *solicited_addr,
>> +                 bool router, bool solicited, bool override,
>> +                 bool inc_opt)
>> +{
>> +    if (likely(dev->ndisc_ops->send_na))
>> +        dev->ndisc_ops->send_na(dev, daddr, solicited_addr, router,
>> +                    solicited, override, inc_opt);
>> +}
>> +
>> +static inline void ndisc_recv_na(struct sk_buff *skb)
>> +{
>> +    if (likely(skb->dev->ndisc_ops->recv_na))
>> +        skb->dev->ndisc_ops->recv_na(skb);
>> +}
>> +
>> +static inline void ndisc_send_ns(struct net_device *dev,
>> +                 const struct in6_addr *solicit,
>> +                 const struct in6_addr *daddr,
>> +                 const struct in6_addr *saddr)
>> +{
>> +    if (likely(dev->ndisc_ops->send_ns))
>> +        dev->ndisc_ops->send_ns(dev, solicit, daddr, saddr);
>> +}
>> +
>> +static inline void ndisc_recv_ns(struct sk_buff *skb)
>> +{
>> +    if (likely(skb->dev->ndisc_ops->recv_ns))
>> +        skb->dev->ndisc_ops->recv_ns(skb);
>> +}
>> +#else
>> +static inline int ndisc_is_useropt(const struct net_device *dev,
>> +                   struct nd_opt_hdr *opt)
>> +{
>> +    return 0;
>> +}
>> +
>> +static inline void ndisc_send_na(struct net_device *dev,
>> +                 const struct in6_addr *daddr,
>> +                 const struct in6_addr *solicited_addr,
>> +                 bool router, bool solicited, bool override,
>> +                 bool inc_opt) { }
>> +
>> +static inline void ndisc_recv_na(struct sk_buff *skb) { }
>> +
>> +static inline void ndisc_send_ns(struct net_device *dev,
>> +                 const struct in6_addr *solicit,
>> +                 const struct in6_addr *daddr,
>> +                 const struct in6_addr *saddr) { }
>> +
>> +static inline void ndisc_recv_ns(struct sk_buff *skb) { }
>> +#endif
>> +
>> +void ip6_register_ndisc_ops(struct net_device *dev);
>> +
>>   int ndisc_init(void);
>>   int ndisc_late_init(void);
>>   @@ -181,14 +269,8 @@ void ndisc_cleanup(void);
>>     int ndisc_rcv(struct sk_buff *skb);
>>   -void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
>> -           const struct in6_addr *daddr, const struct in6_addr *saddr);
>> -
>>   void ndisc_send_rs(struct net_device *dev,
>>              const struct in6_addr *saddr, const struct in6_addr *daddr);
>> -void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
>> -           const struct in6_addr *solicited_addr,
>> -           bool router, bool solicited, bool override, bool inc_opt);
>>     void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target);
>>   diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 54e18c2..a2ef04b 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -3266,6 +3266,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>>               idev = ipv6_add_dev(dev);
>>               if (IS_ERR(idev))
>>                   return notifier_from_errno(PTR_ERR(idev));
>> +            ip6_register_ndisc_ops(dev);
>>           }
>>           break;
>>   diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>> index 176c7c4..297080a 100644
>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -185,24 +185,25 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
>>       return cur <= end && cur->nd_opt_type == type ? cur : NULL;
>>   }
>>   -static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
>> +static inline int ip6_ndisc_is_useropt(struct nd_opt_hdr *opt)
>>   {
>> -    return opt->nd_opt_type == ND_OPT_RDNSS ||
>> -        opt->nd_opt_type == ND_OPT_DNSSL;
>> +    return __ip6_ndisc_is_useropt(opt);
> 
> Why putting this check into a different function? It looks like a not needed redirection.

because these IPv6 userspace options are valid in 6LoWPAN-ND and IPv6-ND.

In 6LoWPAN we do:

static inline int lowpan_ndisc_is_useropt(struct nd_opt_hdr *opt)
{
        return __ip6_ndisc_is_useropt(opt) || opt->nd_opt_type == ND_OPT_6CO;
}

I don't believe that _any_ IPv6 implementation in userspace can do something
with 6CO option fields. For this reason ARPHRD_6LOWPAN should make them
valid for userspace only. (btw: the radvd maintainer wants to add some
patches for 6CO processing support).

- Alex
