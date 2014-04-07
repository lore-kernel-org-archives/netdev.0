From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: Re: [PATCH] ipv6: Reparent temporary address(es) if global address
 was deleted from userspace
Date: Mon, 07 Apr 2014 07:18:10 +0200
Message-ID: <53423512.2030706@web.de>
References: <5341A52B.2070207@web.de> <5341B897.1080105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:54520 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317AbaDGFn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 01:43:29 -0400
In-Reply-To: <5341B897.1080105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 06.04.2014 22:27, schrieb Daniel Borkmann:
> On 04/06/2014 09:04 PM, Heiner Kallweit wrote:
>> If the kernel takes care of global and temporary addresses it can happen that the global
>> address is deleted from userspace, e.g. by network managers in case the link goes (temporarily) down.
>> In addition to the then orphaned temporary address(es) the next RA will create a new temporary address.
>> Therefore we might end up with more than one non-deprecated temporary address for the same prefix
>> for a longer period of time (>regen_advance). According to RfC 4941 sect. 3.4 this should not happen.
>
> Nit: your commit description should only be ~75 chars wide max
>
>> Fix this by reparenting orphaned temporary addresses.
>>
>> Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
>> ---
>>   net/ipv6/addrconf.c | 34 +++++++++++++++++++++++++++++++---
>>   1 file changed, 31 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 6c7fa08..4d5595b 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -2077,14 +2077,34 @@ static void manage_tempaddrs(struct inet6_dev *idev,
>>   {
>>       u32 flags;
>>       struct inet6_ifaddr *ift;
>> +    unsigned long regen_advance;
>>
>>       read_lock_bh(&idev->lock);
>> +    regen_advance = idev->cnf.regen_max_retry *
>> +            idev->cnf.dad_transmits *
>> +            NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
>>       /* update all temporary addresses in the list */
>>       list_for_each_entry(ift, &idev->tempaddr_list, tmp_list) {
>>           int age, max_valid, max_prefered;
>> +        bool reparent;
>>
>> -        if (ifp != ift->ifpub)
>> -            continue;
>> +        reparent = false;
>
> You can collapse initialization where you declare the variable.
>
>> +        spin_lock(&ift->lock);
>> +        if (ifp != ift->ifpub) {
>> +            /* reparent if orphaned temporary address with same
>> +             * prefix is found
>> +             */
>> +            if (ipv6_prefix_equal(&ift->addr, &ifp->addr,
>> +                          ift->prefix_len)) {
>> +                in6_ifa_hold(ifp);
>> +                in6_ifa_put(ift->ifpub);
>> +                ift->ifpub = ifp;
>> +                reparent = true;
>> +            } else {
>> +                spin_unlock(&ift->lock);
>> +                continue;
>> +            }
>> +        }
>>
>>           /* RFC 4941 section 3.3:
>>            * If a received option will extend the lifetime of a public
>> @@ -2110,7 +2130,6 @@ static void manage_tempaddrs(struct inet6_dev *idev,
>>           if (prefered_lft > max_prefered)
>>               prefered_lft = max_prefered;
>>
>> -        spin_lock(&ift->lock);
>>           flags = ift->flags;
>>           ift->valid_lft = valid_lft;
>>           ift->prefered_lft = prefered_lft;
>> @@ -2119,6 +2138,15 @@ static void manage_tempaddrs(struct inet6_dev *idev,
>>               ift->flags &= ~IFA_F_DEPRECATED;
>>
>>           spin_unlock(&ift->lock);
>> +        /* Don't create a temporary address if we reparented one which
>> +         * is prefered more than regen_advance
>
> Nit: s/prefered/preferred/
>
>> +         */
>> +        if (reparent && prefered_lft > regen_advance) {
>> +            create = false;
>> +            pr_info("%s: reparent orphaned temporary address\n",
>> +                __func__);
>
> The pr_info() should ideally be removed (or at least made pr_debug()).
>
>> +        }
>> +
>>           if (!(flags&IFA_F_TENTATIVE))
>>               ipv6_ifa_notify(0, ift);
>>       }
>>
>
Thanks for the hints, will send a revised patch.
Rgds, Heiner
