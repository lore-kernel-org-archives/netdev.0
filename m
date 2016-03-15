From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 15 Mar 2016 08:52:23 +0100
Message-ID: <20160315075223.GB2263@nanopsycho.orion>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com>
 <20160314145144.GE2346@nanopsycho.orion>
 <56E706C3.4030808@cumulusnetworks.com>
 <20160314190435.GA23419@nanopsycho.orion>
 <56E7AA96.8030305@cumulusnetworks.com>
 <20160315072856.GA2263@nanopsycho.orion>
 <56E7BC0B.3070107@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36709 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934166AbcCOHw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 03:52:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id l68so2094224wml.3
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 00:52:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56E7BC0B.3070107@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 15, 2016 at 08:38:51AM CET, roopa@cumulusnetworks.com wrote:
>On 3/15/16, 12:28 AM, Jiri Pirko wrote:
>> Tue, Mar 15, 2016 at 07:24:22AM CET, roopa@cumulusnetworks.com wrote:
>>> On 3/14/16, 12:04 PM, Jiri Pirko wrote:
>>>> Mon, Mar 14, 2016 at 07:45:23PM CET, roopa@cumulusnetworks.com wrote:
>>>>> On 3/14/16, 7:51 AM, Jiri Pirko wrote:
>>>>>> Sun, Mar 13, 2016 at 02:56:25AM CET, roopa@cumulusnetworks.com wrote:
>>>>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>>>
>>>>>>> This patch adds a new RTM_GETSTATS message to query link stats via netlink
>>>>>> >from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>>>>>>> returns a lot more than just stats and is expensive in some cases when
>>>>>>> frequent polling for stats from userspace is a common operation.
>>>>>>>
>>>>>>> RTM_GETSTATS is an attempt to provide a light weight netlink message
>>>>>>> to explicity query only link stats from the kernel on an interface.
>>>>>>> The idea is to also keep it extensible so that new kinds of stats can be
>>>>>>> added to it in the future.
>>>>>>>
>>>>>>> This patch adds the following attribute for NETDEV stats:
>>>>>>> struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
>>>>>>>        [IFLA_STATS_LINK64]  = { .len = sizeof(struct rtnl_link_stats64) },
>>>>>>> };
>>>>>>>
>>>>>>> This patch also allows for af family stats (an example af stats for IPV6
>>>>>>> is available with the second patch in the series).
>>>>>>>
>>>>>>> Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
>>>>>>> a single interface or all interfaces with NLM_F_DUMP.
>>>>>>>
>>>>>>> Future possible new types of stat attributes:
>>>>>>> - IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
>>>>>>> - IFLA_EXTENDED_STATS (nested. extended software netdev stats like bridge,
>>>>>>>  vlan, vxlan etc)
>>>>>>> - IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
>>>>>>>  available via ethtool today)
>>>>>>>
>>>>>>> This patch also declares a filter mask for all stat attributes.
>>>>>>> User has to provide a mask of stats attributes to query. This will be
>>>>>>> specified in a new hdr 'struct if_stats_msg' for stats messages.
>>>>>>>
>>>>>>> Without any attributes in the filter_mask, no stats will be returned.
>>>>>>>
>>>>>>> This patch has been tested with modified iproute2 ifstat.
>>>>>>>
>>>>>>> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>>>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>>> ---
>>> [snip]
>>>>>>> +
>>>>>>> +struct if_stats_msg {
>>>>>>> +	__u8  family;
>>>>>>> +	__u32 ifindex;
>>>>>>> +	__u32 filter_mask;
>>>>>> This limit future extension to only 32 groups of stats. I can imagine
>>>>>> that more than that can be added, easily.
>>>>> I thought about that, but it is going to be a while before we run out of the u32.
>>>>> Most of the other stats will be nested like per logical interface stats or
>>>>> per hw stats. If we do run out of them, in the future we could add a netlink
>>>>> attribute for extended filter mask to carry more bits (similar to IFLA_EXT_MASK).
>>>>> I did also start with just having a IFLA_STATS_EXT_MASK like attribute
>>>>> to begin with, but since no stats are dumped by default, having a way to easily specify
>>>>> mask in the hdr will be easier on apps. And this will again be a u32 anyways.
>>>> I believe that using *any* structs to send over netlink is a mistake.
>>>> Netlink is capable to transfer everything using attrs. Easy to compose,
>>>> easy to parse. easy to extend. Couple of more bytes in the message? So what?
>>>> For newly introduced things, I suggest to do this properly.
>>> Jiri, I hear you. I don't prefer structs for netlink attributes either.
>> Looks like you clearly prefer structs, otherwise we wouldn't be having
>> this discussion.
>>
>>
>>> But in this case, the struct is for the msg hdr which immediately follows the netlink
>>> header. Its not an attribute value. see my last reply below. rtnetlink_rcv_msg does assume
>>> a struct and family right after the netlink header.
>>> All messages define this struct (see struct ndmsg, or ifinfomsg, rtmsg, br_port_msg etc).
>>> so it is required.
>> Okay. So let's kee[ that struct as small as possible. Containing only
>> family and ifindex. That should be enough. 
>
>how does it matter if we have reached an agreement that the struct is required ?.
>unlike other messages, a filter_mask is an important and must attribute for
>stats. If you are worried about us running out of bits in u32, the netlink attribute you will
> define for the filter_mask will also be u32 to begin with.

No, you are missing the point:

enum {
	IFLA_STATS_UNSPEC,
	IFLA_STATS_FILTER, /* nest */
	IFLA_STATS_LINK64,
	IFLA_STATS_INET6,
	__IFLA_STATS_MAX,
};

#define IFLA_STATS_MAX (__IFLA_STATS_MAX - 1)

enum {
	IFLA_STATS_FILTER_UNSPEC,
	IFLA_STATS_FILTER_LINK64, /* flag */
	IFLA_STATS_FILTER_INET6, /* flag */
	...
	IFLA_STATS_FILTER_WHATEVER, /* flag */
	__IFLA_STATS_FILTER_MAX,
};

#define IFLA_STATS_FILTERMAX (__IFLA_STATS_FILTER_MAX - 1)


>So, i don't understand what we gain from making filter_mask a separate attribute right now.
>I would have agreed with your argument if filter_mask was optional.

Optional or not, that does not matter.


>
>
>>> And I do think this struct simplifies a minimum request message and
>>> I have also realized that it really helps if this struct contains basic minimum required
>>> attributes. Ifindex as a filter really helps with RTM_GETSTATS when not used with NLM_F_DUMP
>>> and filter_mask is important for RTM_GETSTATS with NLM_F_DUMP because without
>>> a filter no stats are reported. so, making it part of the base message simplifies the stats
>>> request message from app perspective.
>> I don't understand this argument. As I wrote earlier, user app can
>> easily specify filter mask by flag attrs. It is very easy.
>>
>>
>>> yes the struct cannot be extended, but further extensions can be done as netlink attributes.
>> Exactly, we now now that this is not extendable, we know that if will
>> likely get extended, yet you still argue for the non-extendable
>> approach. I don't get it, sorry :(
>>
>
