From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [RFC 07/12] addrconf: put prefix address add in an own function
Date: Fri, 27 May 2016 15:17:31 +0200
Message-ID: <574848EB.8090907@osg.samsung.com>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
 <1464031328-17524-8-git-send-email-aar@pengutronix.de>
 <5748174A.4080309@osg.samsung.com>
 <7833ba52-9527-479e-135a-7ec392960fc1@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:55010 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948AbcE0NRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 09:17:37 -0400
In-Reply-To: <7833ba52-9527-479e-135a-7ec392960fc1@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 27/05/16 13:41, Alexander Aring wrote:
> Hi,
>
> On 05/27/2016 11:45 AM, Stefan Schmidt wrote:
>> Hello.
>>
> sorry, again I will change something on this patch which is buggy.
>
>> On 23/05/16 21:22, Alexander Aring wrote:
>>> This patch moves the functionality to add a RA PIO prefix generated
>>> address in an own function. This move prepares to add a hook for
>>> adding a second address for a second link-layer address. E.g. short
>>> address for 802.15.4 6LoWPAN.
>>>
>>> Cc: David S. Miller<davem@davemloft.net>
>>> Cc: Alexey Kuznetsov<kuznet@ms2.inr.ac.ru>
>>> Cc: James Morris<jmorris@namei.org>
>>> Cc: Hideaki YOSHIFUJI<yoshfuji@linux-ipv6.org>
>>> Cc: Patrick McHardy<kaber@trash.net>
>>> Signed-off-by: Alexander Aring<aar@pengutronix.de>
>>> ---
>>>    net/ipv6/addrconf.c | 191 ++++++++++++++++++++++++++++------------------------
>>>    1 file changed, 102 insertions(+), 89 deletions(-)
>>>
>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>> index beaad49..393cdbf 100644
>>> --- a/net/ipv6/addrconf.c
>>> +++ b/net/ipv6/addrconf.c
>>> @@ -2333,6 +2333,104 @@ static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
>>>               idev->addr_gen_mode == IN6_ADDR_GEN_MODE_RANDOM;
>>>    }
>>>    +static void addrconf_prefix_rcv_add_addr(struct net *net,
> will change to return int here to indicates errors.
>
>>> +                     struct net_device *dev,
>>> +                     const struct prefix_info *pinfo,
>>> +                     struct inet6_dev *in6_dev,
>>> +                     const struct in6_addr *addr,
>>> +                     int addr_type, u32 addr_flags,
>>> +                     bool sllao, bool tokenized,
>>> +                     __u32 valid_lft, u32 prefered_lft)
>>> +{
>>> +    struct inet6_ifaddr *ifp = ipv6_get_ifaddr(net, addr, dev, 1);
>>> +    int create = 0, update_lft = 0;
>>> +
>>> +    if (!ifp && valid_lft) {
>>> +        int max_addresses = in6_dev->cnf.max_addresses;
>>> +
>>> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>>> +        if (in6_dev->cnf.optimistic_dad &&
>>> +            !net->ipv6.devconf_all->forwarding && sllao)
>>> +            addr_flags |= IFA_F_OPTIMISTIC;
>>> +#endif
>>> +
>>> +        /* Do not allow to create too much of autoconfigured
>>> +         * addresses; this would be too easy way to crash kernel.
>>> +         */
>>> +        if (!max_addresses ||
>>> +            ipv6_count_addresses(in6_dev) < max_addresses)
>>> +            ifp = ipv6_add_addr(in6_dev, addr, NULL,
>>> +                        pinfo->prefix_len,
>>> +                        addr_type&IPV6_ADDR_SCOPE_MASK,
>>> +                        addr_flags, valid_lft,
>>> +                        prefered_lft);
>>> +
>>> +        if (IS_ERR_OR_NULL(ifp)) {
>>> +            in6_dev_put(in6_dev);
>>> +            return;
> return -1; and remove in6_dev_put stuff.
>
>>> +        }
>>> +
>>> +        update_lft = 0;
>>> +        create = 1;
>>> +        spin_lock_bh(&ifp->lock);
>>> +        ifp->flags |= IFA_F_MANAGETEMPADDR;
>>> +        ifp->cstamp = jiffies;
>>> +        ifp->tokenized = tokenized;
>>> +        spin_unlock_bh(&ifp->lock);
>>> +        addrconf_dad_start(ifp);
>>> +    }
>>> +
>>> +    if (ifp) {
>>> +        u32 flags;
>>> +        unsigned long now;
>>> +        u32 stored_lft;
>>> +
>>> +        /* update lifetime (RFC2462 5.5.3 e) */
>>> +        spin_lock_bh(&ifp->lock);
>>> +        now = jiffies;
>>> +        if (ifp->valid_lft > (now - ifp->tstamp) / HZ)
>>> +            stored_lft = ifp->valid_lft - (now - ifp->tstamp) / HZ;
>>> +        else
>>> +            stored_lft = 0;
>>> +        if (!update_lft && !create && stored_lft) {
>>> +            const u32 minimum_lft = min_t(u32,
>>> +                stored_lft, MIN_VALID_LIFETIME);
>>> +            valid_lft = max(valid_lft, minimum_lft);
>>> +
>>> +            /* RFC4862 Section 5.5.3e:
>>> +             * "Note that the preferred lifetime of the
>>> +             *  corresponding address is always reset to
>>> +             *  the Preferred Lifetime in the received
>>> +             *  Prefix Information option, regardless of
>>> +             *  whether the valid lifetime is also reset or
>>> +             *  ignored."
>>> +             *
>>> +             * So we should always update prefered_lft here.
>>> +             */
>>> +            update_lft = 1;
>>> +        }
>>> +
>>> +        if (update_lft) {
>>> +            ifp->valid_lft = valid_lft;
>>> +            ifp->prefered_lft = prefered_lft;
>>> +            ifp->tstamp = now;
>>> +            flags = ifp->flags;
>>> +            ifp->flags &= ~IFA_F_DEPRECATED;
>>> +            spin_unlock_bh(&ifp->lock);
>>> +
>>> +            if (!(flags&IFA_F_TENTATIVE))
>>> +                ipv6_ifa_notify(0, ifp);
>>> +        } else
>>> +            spin_unlock_bh(&ifp->lock);
>>> +
>>> +        manage_tempaddrs(in6_dev, ifp, valid_lft, prefered_lft,
>>> +                 create, now);
>>> +
>>> +        in6_ifa_put(ifp);
>>> +        addrconf_verify();
>>> +    }
>>> +}
>>> +
>>>    void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>>>    {
>>>        struct prefix_info *pinfo;
>>> @@ -2432,9 +2530,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>>>        /* Try to figure out our local address for this prefix */
>>>          if (pinfo->autoconf && in6_dev->cnf.autoconf) {
>>> -        struct inet6_ifaddr *ifp;
>>>            struct in6_addr addr;
>>> -        int create = 0, update_lft = 0;
>>>            bool tokenized = false;
>>>              if (pinfo->prefix_len == 64) {
>>> @@ -2464,93 +2560,10 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>>>            return;
>>>      ok:
>>> -
>>> -        ifp = ipv6_get_ifaddr(net, &addr, dev, 1);
>>> -
>>> -        if (!ifp && valid_lft) {
>>> -            int max_addresses = in6_dev->cnf.max_addresses;
>>> -
>>> -#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>>> -            if (in6_dev->cnf.optimistic_dad &&
>>> -                !net->ipv6.devconf_all->forwarding && sllao)
>>> -                addr_flags |= IFA_F_OPTIMISTIC;
>>> -#endif
>>> -
>>> -            /* Do not allow to create too much of autoconfigured
>>> -             * addresses; this would be too easy way to crash kernel.
>>> -             */
>>> -            if (!max_addresses ||
>>> -                ipv6_count_addresses(in6_dev) < max_addresses)
>>> -                ifp = ipv6_add_addr(in6_dev, &addr, NULL,
>>> -                            pinfo->prefix_len,
>>> -                            addr_type&IPV6_ADDR_SCOPE_MASK,
>>> -                            addr_flags, valid_lft,
>>> -                            prefered_lft);
>>> -
>>> -            if (IS_ERR_OR_NULL(ifp)) {
>>> -                in6_dev_put(in6_dev);
>>> -                return;
>>> -            }
>>> -
>>> -            update_lft = 0;
>>> -            create = 1;
>>> -            spin_lock_bh(&ifp->lock);
>>> -            ifp->flags |= IFA_F_MANAGETEMPADDR;
>>> -            ifp->cstamp = jiffies;
>>> -            ifp->tokenized = tokenized;
>>> -            spin_unlock_bh(&ifp->lock);
>>> -            addrconf_dad_start(ifp);
>>> -        }
>>> -
>>> -        if (ifp) {
>>> -            u32 flags;
>>> -            unsigned long now;
>>> -            u32 stored_lft;
>>> -
>>> -            /* update lifetime (RFC2462 5.5.3 e) */
>>> -            spin_lock_bh(&ifp->lock);
>>> -            now = jiffies;
>>> -            if (ifp->valid_lft > (now - ifp->tstamp) / HZ)
>>> -                stored_lft = ifp->valid_lft - (now - ifp->tstamp) / HZ;
>>> -            else
>>> -                stored_lft = 0;
>>> -            if (!update_lft && !create && stored_lft) {
>>> -                const u32 minimum_lft = min_t(u32,
>>> -                    stored_lft, MIN_VALID_LIFETIME);
>>> -                valid_lft = max(valid_lft, minimum_lft);
>>> -
>>> -                /* RFC4862 Section 5.5.3e:
>>> -                 * "Note that the preferred lifetime of the
>>> -                 *  corresponding address is always reset to
>>> -                 *  the Preferred Lifetime in the received
>>> -                 *  Prefix Information option, regardless of
>>> -                 *  whether the valid lifetime is also reset or
>>> -                 *  ignored."
>>> -                 *
>>> -                 * So we should always update prefered_lft here.
>>> -                 */
>>> -                update_lft = 1;
>>> -            }
>>> -
>>> -            if (update_lft) {
>>> -                ifp->valid_lft = valid_lft;
>>> -                ifp->prefered_lft = prefered_lft;
>>> -                ifp->tstamp = now;
>>> -                flags = ifp->flags;
>>> -                ifp->flags &= ~IFA_F_DEPRECATED;
>>> -                spin_unlock_bh(&ifp->lock);
>>> -
>>> -                if (!(flags&IFA_F_TENTATIVE))
>>> -                    ipv6_ifa_notify(0, ifp);
>>> -            } else
>>> -                spin_unlock_bh(&ifp->lock);
>>> -
>>> -            manage_tempaddrs(in6_dev, ifp, valid_lft, prefered_lft,
>>> -                     create, now);
>>> -
>>> -            in6_ifa_put(ifp);
>>> -            addrconf_verify();
>>> -        }
>>> +        addrconf_prefix_rcv_add_addr(net, dev, pinfo, in6_dev, &addr,
>>> +                         addr_type, addr_flags, sllao,
>>> +                         tokenized, valid_lft,
>>> +                         prefered_lft);
> check error here and goto in6_dev_put stuff. Oderwise
> inet6_prefix_notify will call on error.
>
>>>        }
>>>        inet6_prefix_notify(RTM_NEWPREFIX, in6_dev, pinfo);
>>>        in6_dev_put(in6_dev);
>> Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>
>>
> I hope this fits to your review by tag, I simple add it then in RFCv2.

You can do the change you described here and still keep my reviewed by.

regards
Stefan Schmidt
