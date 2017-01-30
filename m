From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 08:59:54 -0700
Message-ID: <2f1b8d5d-6442-1fea-7fdd-cb7b6ff95572@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
 <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
 <588E80DB.3070209@cumulusnetworks.com>
 <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com>
 <588EA2E8.2040302@cumulusnetworks.com>
 <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com>
 <ef322f4a-07d7-31af-b402-769b0f446fc7@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34131 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdA3QBj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:01:39 -0500
Received: by mail-pf0-f171.google.com with SMTP id e4so91021170pfg.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 07:59:56 -0800 (PST)
In-Reply-To: <ef322f4a-07d7-31af-b402-769b0f446fc7@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 4:13 AM, Nicolas Dichtel wrote:
> Le 30/01/2017 à 03:57, David Ahern a écrit :
>> On 1/29/17 7:20 PM, Roopa Prabhu wrote:
>>>> 2. Delete - 1 notification for each hop for all combinations of delete commands
>>>
>>> here I was trying to say, for people deleting the full multipath route, you should send a RTA_MULTIPATH.
>>
>> The only way to do that is to call inet6_rt_notify() *before* the route delete work has been done in fib6_del_route. Right now it is called at the end - after all sibling associations have been dropped, a time in which it can no longer fill in RTA_MULTIPATH.
>>
>> fib6_del_route function does not have any failure paths and is called with the write lock held, so moving the notification might be ok. But it also means ignoring all subsequent failures from fib6_del, again which might be ok since the only failure is ENOENT which can not happen if we are walking the sibling list.
> Is it not possible to prepare the RTA_MULTIPATH attribute during the deletion
> (when needed information are still available) and to use/copy it later when the
> notification is done?

What I outlined above has the least complexity and does not require copies. And it is only proper for the 1 case where a multipath route is deleted by prefix and length -- the ability enabled by Patch 2.

> 
> Or at least, having RTA_MUTLTIPATH with one nexthop only, so that the user knows
> that this route was part of an ECMP routes?
> 

For the ip6_route_multipath_del path, sure the nexthops deleted can be wrapped in RTA_MULTIPATH if the nexthop indeed has siblings, but does it help userspace? If all attributes outside of the nexthops are identical, then userspace would match the route without it.
