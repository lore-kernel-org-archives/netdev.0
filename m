From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Mon, 14 Mar 2016 23:30:30 -0700
Message-ID: <56E7AC06.8040905@cumulusnetworks.com>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com> <56E6D224.5020701@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33276 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857AbcCOGac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 02:30:32 -0400
Received: by mail-pf0-f170.google.com with SMTP id 124so15103148pfg.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 23:30:32 -0700 (PDT)
In-Reply-To: <56E6D224.5020701@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/14/16, 8:00 AM, Nicolas Dichtel wrote:
> Le 13/03/2016 02:56, Roopa Prabhu a =C3=A9crit :
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds a new RTM_GETSTATS message to query link stats via n=
etlink
>> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>> returns a lot more than just stats and is expensive in some cases wh=
en
>> frequent polling for stats from userspace is a common operation.
>>
>> RTM_GETSTATS is an attempt to provide a light weight netlink message
>> to explicity query only link stats from the kernel on an interface.
>> The idea is to also keep it extensible so that new kinds of stats ca=
n be
>> added to it in the future.
>>
>> This patch adds the following attribute for NETDEV stats:
>> struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] =3D {
>>          [IFLA_STATS_LINK64]  =3D { .len =3D sizeof(struct rtnl_link=
_stats64) },
>> };
>>
>> This patch also allows for af family stats (an example af stats for =
IPV6
>> is available with the second patch in the series).
>>
>> Like any other rtnetlink message, RTM_GETSTATS can be used to get st=
ats of
>> a single interface or all interfaces with NLM_F_DUMP.
>>
>> Future possible new types of stat attributes:
>> - IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
>> - IFLA_EXTENDED_STATS (nested. extended software netdev stats like b=
ridge,
>>    vlan, vxlan etc)
>> - IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
>>    available via ethtool today)
>>
>> This patch also declares a filter mask for all stat attributes.
>> User has to provide a mask of stats attributes to query. This will b=
e
>> specified in a new hdr 'struct if_stats_msg' for stats messages.
>>
>> Without any attributes in the filter_mask, no stats will be returned=
=2E
>>
>> This patch has been tested with modified iproute2 ifstat.
>>
>> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> [snip]
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_li=
nk.h
>> index 249eef9..0840f3e 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
> [snip]
>> +enum {
>> +    IFLA_STATS_UNSPEC,
>> +    IFLA_STATS_LINK64,
>> +    IFLA_STATS_INET6,
> IFLA_STATS_INET6 is part on patch #2, it's not used in this patch.
yep, will fix it
>
>> +    __IFLA_STATS_MAX,
>> +};
>> +
>> +#define IFLA_STATS_MAX (__IFLA_STATS_MAX - 1)
>> +
>> +#define IFLA_STATS_FILTER_BIT(ATTR)    (1 << (ATTR))
>> +
>>   #endif /* _UAPI_LINUX_IF_LINK_H */
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtn=
etlink.h
>> index ca764b5..2bbb300 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -139,6 +139,13 @@ enum {
>>       RTM_GETNSID =3D 90,
>>   #define RTM_GETNSID RTM_GETNSID
>>
>> +    RTM_NEWSTATS =3D 92,
>> +#define RTM_NEWSTATS RTM_NEWSTATS
>> +    RTM_DELSTATS =3D 93,
>> +#define RTM_DELSTATS RTM_DELSTATS
> RTM_DELSTATS is never used.

yeah, i had to define it just because rtnetlink_rcv_msg seems to expect=
 all three to be
there when it tries to check if it is a get msg. But, i could sure not =
declare this
but make rtnetlink_rcv_msg happy by keeping the GET msg at the right of=
fset.
>
>> +    RTM_GETSTATS =3D 94,
>> +#define RTM_GETSTATS RTM_GETSTATS
>> +
>>       __RTM_MAX,
>>   #define RTM_MAX        (((__RTM_MAX + 3) & ~3) - 1)
>>   };
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index d2d9e5e..d1e3d17 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
> [snip]
>> +static noinline size_t if_nlmsg_stats_size(const struct net_device =
*dev,
>> +                       u32 filter_mask)
> Why are you using the 'noinline' attribute?

I actually picked it up from if_nlmsg_size ...

>
>> +{
>> +    size_t size =3D 0;
>> +
>> +    if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK64))
>> +        size +=3D nla_total_size(sizeof(struct rtnl_link_stats64));
>> +
>> +    size +=3D rtnl_link_get_af_stats_size(dev, filter_mask);
>> +
>> +    return size;
>> +}
>
