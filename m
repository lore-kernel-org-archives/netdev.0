From: Erik Kline <ek@google.com>
Subject: Re: [RFC PATCH v2 net-next] net: ipv6: Add a sysctl to make
 optimistic addresses useful candidates
Date: Wed, 22 Oct 2014 14:25:05 +0900
Message-ID: <CAAedzxpsaEGt+oO0xJWLxcjapdRYauHP4rAsKkf_skcdzbGEmg@mail.gmail.com>
References: <1413864306-20055-1-git-send-email-ek@google.com> <1413920743.32553.45.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Lorenzo Colitti <lorenzo@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:40161 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbaJVFZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 01:25:26 -0400
Received: by mail-ig0-f179.google.com with SMTP id h18so290031igc.0
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 22:25:25 -0700 (PDT)
In-Reply-To: <1413920743.32553.45.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On Wed, Oct 22, 2014 at 4:45 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi,
>
> On Di, 2014-10-21 at 13:05 +0900, Erik Kline wrote:
>> Add a sysctl that causes an interface's optimistic addresses
>> to be considered equivalent to other non-deprecated addresses
>> for source address selection purposes.  Preferred addresses
>> will still take precedence over optimistic addresses, subject
>> to other ranking in the source address selection algorithm.
>>
>> This is useful where different interfaces are connected to
>> different networks from different ISPs (e.g., a cell network
>> and a home wifi network).
>>
>> The current behaviour complies with RFC 3484/6724, and it
>> makes sense if the host has only one interface, or has
>> multiple interfaces on the same network (same or cooperating
>> administrative domain(s), but not in the multiple distinct
>> networks case.
>>
>> For example, if a mobile device has an IPv6 address on an LTE
>> network and then connects to IPv6-enabled wifi, while the wifi
>> IPv6 address is undergoing DAD, IPv6 connections will try use
>> the wifi default route with the LTE IPv6 address, and will get
>> stuck until they time out.
>>
>> Also, because optimistic addresses can actually be used, issue
>> an RTM_NEWADDR as soon as DAD starts.  If DAD fails an separate
>> RTM_DELADDR will be sent.
>>
>> Also: add an entry in ip-sysctl.txt for optimistic_dad.
>>
>> Signed-off-by: Erik Kline <ek@google.com>
>> ---
>>  Documentation/networking/ip-sysctl.txt | 13 ++++++++++++
>>  include/linux/ipv6.h                   |  1 +
>>  include/uapi/linux/ipv6.h              |  1 +
>>  net/ipv6/addrconf.c                    | 36 ++++++++++++++++++++++++++++++++--
>>  4 files changed, 49 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>> index 0307e28..e03cf49 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -1452,6 +1452,19 @@ suppress_frag_ndisc - INTEGER
>>       1 - (default) discard fragmented neighbor discovery packets
>>       0 - allow fragmented neighbor discovery packets
>>
>> +optimistic_dad - BOOLEAN
>> +     Whether to perform Optimistic Duplicate Address Detection (RFC 4429).
>> +             0: disabled (default)
>> +             1: enabled
>> +
>> +use_optimistic - BOOLEAN
>> +     If enabled, do not classify optimistic addresses as deprecated during
>> +     source address selection.  Preferred addresses will still be chosen
>> +     before optimistic addresses, subject to other ranking in the source
>> +     address selection algorithm.
>> +             0: disabled (default)
>> +             1: enabled
>> +
>>  icmp/*:
>>  ratelimit - INTEGER
>>       Limit the maximal rates for sending ICMPv6 packets.
>> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
>> index ff56053..7121a2e 100644
>> --- a/include/linux/ipv6.h
>> +++ b/include/linux/ipv6.h
>> @@ -42,6 +42,7 @@ struct ipv6_devconf {
>>       __s32           accept_ra_from_local;
>>  #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>>       __s32           optimistic_dad;
>> +     __s32           use_optimistic;
>>  #endif
>>  #ifdef CONFIG_IPV6_MROUTE
>>       __s32           mc_forwarding;
>> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
>> index efa2666..e863d08 100644
>> --- a/include/uapi/linux/ipv6.h
>> +++ b/include/uapi/linux/ipv6.h
>> @@ -164,6 +164,7 @@ enum {
>>       DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
>>       DEVCONF_SUPPRESS_FRAG_NDISC,
>>       DEVCONF_ACCEPT_RA_FROM_LOCAL,
>> +     DEVCONF_USE_OPTIMISTIC,
>>       DEVCONF_MAX
>>  };
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 725c763..c2fddb7 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -1169,6 +1169,9 @@ enum {
>>       IPV6_SADDR_RULE_LABEL,
>>       IPV6_SADDR_RULE_PRIVACY,
>>       IPV6_SADDR_RULE_ORCHID,
>> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>> +     IPV6_SADDR_RULE_NOT_OPTIMISTIC,
>> +#endif
>>       IPV6_SADDR_RULE_PREFIX,
>>       IPV6_SADDR_RULE_MAX
>>  };
>> @@ -1257,10 +1260,17 @@ static int ipv6_get_saddr_eval(struct net *net,
>>               score->scopedist = ret;
>>               break;
>>       case IPV6_SADDR_RULE_PREFERRED:
>> +         {
>>               /* Rule 3: Avoid deprecated and optimistic addresses */
>> +             u8 avoid = IFA_F_DEPRECATED;
>> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>> +             if (!score->ifa->idev->cnf.use_optimistic)
>> +                     avoid |= IFA_F_OPTIMISTIC;
>> +#endif
>>               ret = ipv6_saddr_preferred(score->addr_type) ||
>> -                   !(score->ifa->flags & (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC));
>> +                   !(score->ifa->flags & avoid);
>>               break;
>> +         }
>>  #ifdef CONFIG_IPV6_MIP6
>>       case IPV6_SADDR_RULE_HOA:
>>           {
>> @@ -1299,6 +1309,14 @@ static int ipv6_get_saddr_eval(struct net *net,
>>               ret = !(ipv6_addr_orchid(&score->ifa->addr) ^
>>                       ipv6_addr_orchid(dst->addr));
>>               break;
>> +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>> +     case IPV6_SADDR_RULE_NOT_OPTIMISTIC:
>> +             /* Optimistic addresses still have lower precedence than other
>> +              * preferred addresses.
>> +              */
>> +             ret = !(score->ifa->flags & IFA_F_OPTIMISTIC);
>> +             break;
>> +#endif
>
> I wonder a bit why this rule is not directly ordered after
> IPV6_SADDR_RULE_PREFERRED? This would e.g. matter for privacy addresses.

Privacy addresses ("tempaddrs") that win in earlier checks are
preferred before optimistic in this code (i.e. a tempaddr on the same
outgoing interface is preferred before an optimistic address).

Similarly, a non-tentative non-privacy address (same outgoing
interface, same label, ...) will match before an optimistic address,
but only until DAD completes and the address is no longer optimistic.
I think this is in keeping with the spirit of the RFC 3484/6724 rules.

After there's an RFC 7217 implementation, EUI-64-based SLAAC could be
disabled by folks.

>>       case IPV6_SADDR_RULE_PREFIX:
>>               /* Rule 8: Use longest matching prefix */
>>               ret = ipv6_addr_diff(&score->ifa->addr, dst->addr);
>> @@ -3222,8 +3240,13 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
>>        * Optimistic nodes can start receiving
>>        * Frames right away
>>        */
>> -     if (ifp->flags & IFA_F_OPTIMISTIC)
>> +     if (ifp->flags & IFA_F_OPTIMISTIC) {
>>               ip6_ins_rt(ifp->rt);
>> +             /* Because optimistic nodes can receive frames, notify
>> +              * listeners. If DAD fails, RTM_DELADDR is sent.
>> +              */
>> +             ipv6_ifa_notify(RTM_NEWADDR, ifp);
>> +     }
>
> I wonder if we can now delete the ipv6_ifa_notify(RTM_NEWADDR, ifp) in
> addrconf_dad_completed.

I don't know what everyone's general preference would be, but mine
would be to err on the side of notifying on state changes.  It seems
harmless to me to keep it in, and something in userspace might want to
know if/when DAD completes.

>>       addrconf_dad_kick(ifp);
>>  out:
>> @@ -4330,6 +4353,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
>>       array[DEVCONF_ACCEPT_SOURCE_ROUTE] = cnf->accept_source_route;
>>  #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>>       array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
>> +     array[DEVCONF_USE_OPTIMISTIC] = cnf->use_optimistic;
>>  #endif
>>  #ifdef CONFIG_IPV6_MROUTE
>>       array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
>> @@ -5155,6 +5179,14 @@ static struct addrconf_sysctl_table
>>                       .proc_handler   = proc_dointvec,
>>
>>               },
>> +             {
>> +                     .procname       = "use_optimistic",
>> +                     .data           = &ipv6_devconf.use_optimistic,
>> +                     .maxlen         = sizeof(int),
>> +                     .mode           = 0644,
>> +                     .proc_handler   = proc_dointvec,
>> +
>> +             },
>>  #endif
>>  #ifdef CONFIG_IPV6_MROUTE
>>               {
>
> Otherwise looks good.
>
> Thanks,
> Hannes
>
>

Thank /you/.
