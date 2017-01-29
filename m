From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Sun, 29 Jan 2017 15:55:07 -0800
Message-ID: <588E80DB.3070209@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com> <588D3EB9.1070107@cumulusnetworks.com> <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34029 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdA2XzJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 18:55:09 -0500
Received: by mail-pg0-f42.google.com with SMTP id 14so96088035pgg.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 15:55:09 -0800 (PST)
In-Reply-To: <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/17, 10:02 AM, David Ahern wrote:
> On 1/28/17 6:00 PM, Roopa Prabhu wrote:
>>> 4. Route Appends
>>>    - IPv6 allows nexthops to be appended to an existing route. In this
>>>      case one notification is sent per nexthop added
>> thanks for listing all of these...I think you mentioned this case to me..
>> but I don't remember now why this notification is
>> sent per nexthop added. This is an update to an existing multipath route.
>> so seems like the notification should be a RTM_NEWROUTE with the full RTA_MULTIPATH route
>> (similar to route add)
> It could be; it's a question of what should userspace get -- the full route or the change? Append to me suggests the latter - userspace is told what changed. It is simpler kernel code wise to send the full new route. The append changes were done after our conversation. ;-)
ok, yeah. you listing all the cases here made it more simpler to understand in the context of other notifications :). I would prefer all
RTM_NEWLINK notifications (ie new add or update to an existing route..replace/append), contain the full route via RTA_MULTIPATH.

>
>> Same holds for replace, I know the code might be tricky here...but the route replace
>> is also an update to an existing multipath route and hence should be a RTM_NEWROUTE
>> with the full multipath route (RTA_MULTIPATH) that changed (from userspace semantics POV)
> It is. The only change on a replace is the encoding of all routes in RTA_MULTIPATH which is the point of this patch set. On successful replace, only 1 notification is sent with the full route.
ok, good.
>
>> I don't have a better solution, but with the above still being different, wondering
>> if its worth the risk changing the api for just a few notifications.
> Data centers are moving to L3, and multipath is a big part of that. Anyone who looks at ip -6 route enough knows it gets painful mentally pulling the individual routes into a single one. In addition, using RTA_MULTIPATH is more efficient at scale.
>
> Furthermore, I have a follow on patch set that returns the route matched on an ip route get lookup. Returning the full multipath route is an important part to understanding the full context of the route to an address.

ok, sure.  If we are moving to RTA_MULTIPATH, I just want to make sure all the notifications consistently move to multipath.

so, to summarize and to get on the same page as you,
- all RTM_NEWLINK notifications will contain RTA_MULTIPATH when the route in the kernel is a multipath route:
            - since ipv6 allows add/append of a single nexthop, the notification for the first nexthop may go out without a RTA_MULTIPATH
- RTM_DELETE will also contain RTA_MULTIPATH when the user tries to delete the full route with RTA_MULTIPATH
            - since ipv6 allows deleting of a single nexthop, RTM_DELETE may contain a single nexthop delete ie without RTA_MULTIPATH (this is just to continue
                supporting the single nexthop delete support that ipv6 has)

Thanks.
