From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] ipmr/ip6mr: add Netlink notifications on
 cache reports
Date: Sat, 17 Jun 2017 16:35:44 +0300
Message-ID: <dda70f88-9942-15fd-9b95-aaf994e594d7@cumulusnetworks.com>
References: <20170613170822.16310-1-julien@arista.com>
 <891d876f-18fb-706b-c269-ec8892d2f6ff@cumulusnetworks.com>
 <7b133850-bbdc-594c-f7f3-62e9d4adf1f3@arista.com>
 <2d412677-d31a-7740-952c-b1b007bbf075@cumulusnetworks.com>
 <01588135-b3d6-bc92-be31-0ae86310d904@cumulusnetworks.com>
 <f36d3b05-0598-38a4-0ffa-b6e73986a679@cumulusnetworks.com>
 <c5c5df94-dd57-41ca-d5ea-e9daf5b1b284@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Donald Sharp <sharpd@cumulusnetworks.com>
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:34721 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752990AbdFQNfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 09:35:47 -0400
Received: by mail-wr0-f171.google.com with SMTP id 77so50638824wrb.1
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 06:35:46 -0700 (PDT)
In-Reply-To: <c5c5df94-dd57-41ca-d5ea-e9daf5b1b284@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/06/17 22:26, Julien Gomes wrote:
> On 06/15/2017 06:00 AM, Nikolay Aleksandrov wrote:
>> On 15/06/17 14:44, Nikolay Aleksandrov wrote:
>>> On 15/06/17 14:33, Nikolay Aleksandrov wrote:
>>>> On 15/06/17 00:51, Julien Gomes wrote:
>>>>> Hi Nikolay,
>>>>>
>>>>> On 06/14/2017 05:04 AM, Nikolay Aleksandrov wrote:
>>>>>
>>>>>> This has been on our todo list and I'm definitely interested in the implementation.
>>>>>> A few things that need careful consideration from my POV. First are the security
>>>>>> implications - this sends rtnl multicast messages but the rtnl socket has
>>>>>> the NL_CFG_F_NONROOT_RECV flag thus allowing any user on the system to listen in.
>>>>>> This would allow them to see the full packets and all reports (granted they can see
>>>>>> the notifications even now), but the full packet is like giving them the opportunity
>>>>>> to tcpdump the PIM traffic.
>>>>> I definitely see how this can be an issue.
>>>>> From what I see, this means that either the packet should be
>>>>> transmitted another way, or another Netlink family should be used.
>>>>>
>>>>> NETLINK_ROUTE looks to be the logical family to choose though,
>>>>> but then I do not see a proper other way to handle this.
>>>> Right, currently me neither, unless it provides a bind callback when registering
>>>> the kernel socket.
>>>>
>>>>> However I may just not be looking into the right direction,
>>>>> maybe you currently have another approach in mind?
>>>> I haven't gotten around to make (or even try) them but I was thinking about 2 options
>>>> ending up with a similar result:
>>>>
>>>> 1) genetlink
>>>>  It also has the NONROOT_RECV flag, but it also allows for a callback - mcast_bind()
>>>>  which can be used to filter.
>>>>
>>>> or
>>>>
>>>> 2) Providing a bind callback to the NETLINK_ROUTE socket.
>>>>
>>> Ah nevermind, these cannot be used for filtering currently, so it seems
>>> the netlink interface would need to be extended too if going down this road.
>>>
>> Sorry for the multiple emails, just to be thorough - again if going down this
>> road all of these would obviously require a different group to bind to in order
>> to be able to filter on it, because users must keep receiving their notifications
>> for the ipmr one.
> 
> Actually, using a bind callback for NETLINK_ROUTE with a new group,
> without netlink interface extension, could  work.
> 
> I quickly tested something like this:
>> static int rtnetlink_bind(struct net *net, int group)
>> {
>>     switch (group) {
>>     case RTNLGRP_IPV4_MROUTE_R:
>>     case RTNLGRP_IPV6_MROUTE_R:
>>        if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
>>            return -EPERM;
>>        break;
>>     }
>>     return 0;
>> }
> 
> With the addition of one/two groups this does restrict the reports'
> potential listeners.
> The group names here are just placeholders, I am not especially fixed
> on these ones.
> 
> It is not perfect as this would introduce groups with specific
> requirements in NETLINK_ROUTE, but I think it can be decent.
> 
> What do you think about this?
> 

Oh yes, that is exactly what I had in mind. I missed that the netns is passed
to the bind function.

Thanks,
 Nik
