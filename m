From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Mon, 14 Mar 2016 11:45:23 -0700
Message-ID: <56E706C3.4030808@cumulusnetworks.com>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com> <20160314145144.GE2346@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36408 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbcCNSpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:45:25 -0400
Received: by mail-pf0-f178.google.com with SMTP id u190so112239158pfb.3
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 11:45:24 -0700 (PDT)
In-Reply-To: <20160314145144.GE2346@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/14/16, 7:51 AM, Jiri Pirko wrote:
> Sun, Mar 13, 2016 at 02:56:25AM CET, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds a new RTM_GETSTATS message to query link stats via netlink
> >from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>> returns a lot more than just stats and is expensive in some cases when
>> frequent polling for stats from userspace is a common operation.
>>
>> RTM_GETSTATS is an attempt to provide a light weight netlink message
>> to explicity query only link stats from the kernel on an interface.
>> The idea is to also keep it extensible so that new kinds of stats can be
>> added to it in the future.
>>
>> This patch adds the following attribute for NETDEV stats:
>> struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
>>        [IFLA_STATS_LINK64]  = { .len = sizeof(struct rtnl_link_stats64) },
>> };
>>
>> This patch also allows for af family stats (an example af stats for IPV6
>> is available with the second patch in the series).
>>
>> Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
>> a single interface or all interfaces with NLM_F_DUMP.
>>
>> Future possible new types of stat attributes:
>> - IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
>> - IFLA_EXTENDED_STATS (nested. extended software netdev stats like bridge,
>>  vlan, vxlan etc)
>> - IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
>>  available via ethtool today)
>>
>> This patch also declares a filter mask for all stat attributes.
>> User has to provide a mask of stats attributes to query. This will be
>> specified in a new hdr 'struct if_stats_msg' for stats messages.
>>
>> Without any attributes in the filter_mask, no stats will be returned.
>>
>> This patch has been tested with modified iproute2 ifstat.
>>
>> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> include/net/rtnetlink.h        |   5 ++
>> include/uapi/linux/if_link.h   |  19 ++++
>> include/uapi/linux/rtnetlink.h |   7 ++
>> net/core/rtnetlink.c           | 200 +++++++++++++++++++++++++++++++++++++++++
>> 4 files changed, 231 insertions(+)
>>
>> diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
>> index 2f87c1b..fa68158 100644
>> --- a/include/net/rtnetlink.h
>> +++ b/include/net/rtnetlink.h
>> @@ -131,6 +131,11 @@ struct rtnl_af_ops {
>> 						    const struct nlattr *attr);
>> 	int			(*set_link_af)(struct net_device *dev,
>> 					       const struct nlattr *attr);
>> +	size_t			(*get_link_af_stats_size)(const struct net_device *dev,
>> +							  u32 filter_mask);
>> +	int			(*fill_link_af_stats)(struct sk_buff *skb,
>> +						      const struct net_device *dev,
>> +						      u32 filter_mask);
>> };
>>
>> void __rtnl_af_unregister(struct rtnl_af_ops *ops);
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index 249eef9..0840f3e 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -741,4 +741,23 @@ enum {
>>
>> #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
>>
>> +/* STATS section */
>> +
>> +struct if_stats_msg {
>> +	__u8  family;
>> +	__u32 ifindex;
>> +	__u32 filter_mask;
> This limit future extension to only 32 groups of stats. I can imagine
> that more than that can be added, easily.
I thought about that, but it is going to be a while before we run out of the u32.
Most of the other stats will be nested like per logical interface stats or
per hw stats. If we do run out of them, in the future we could add a netlink
attribute for extended filter mask to carry more bits (similar to IFLA_EXT_MASK).
I did also start with just having a IFLA_STATS_EXT_MASK like attribute
to begin with, but since no stats are dumped by default, having a way to easily specify
mask in the hdr will be easier on apps. And this will again be a u32 anyways.


>  Why don't you use nested
> attribute IFLA_STATS_FILTER with flag attributes for every type?
>  That
> would be easily extendable.
a u8 for each stats selector seems like an overkill.
> Using netlink header struct for this does not look correct to me.
> In past, this was done lot of times and turned out to be a problem later.
>
>
I started with not adding it, but rtnetlink rcv handler looks for family
in the hdr. And hence all of the messages have a struct header
with family as the first field (you can correct me if you find that it is not necessary.)
