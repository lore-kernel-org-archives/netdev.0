From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 09:12:05 -0700
Message-ID: <d987faff-ced4-8791-8bdb-ba8a66aec6f5@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
 <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
 <588E80DB.3070209@cumulusnetworks.com>
 <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com>
 <588EA2E8.2040302@cumulusnetworks.com>
 <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com>
 <588F607D.2050600@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36088 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753639AbdA3QMY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:12:24 -0500
Received: by mail-pg0-f52.google.com with SMTP id 3so43581599pgj.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 08:12:07 -0800 (PST)
In-Reply-To: <588F607D.2050600@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 8:49 AM, Roopa Prabhu wrote:
>> Single next hop delete will be around because IPv6 allows it -- and because IPv4 needs to support it.
>>
> understand single next hop delete for ipv6 will be around..and my only point was to leave it around but not optimize for that case.
> I don't think we should support single nexthop delete in ipv4 (I have not seen a requirement for that)... ipv4 is good as it is right now.
> the additional complexity is not needed.
> 

IPv4 has a known bug -- delete a virtual interface in a multihop route and the entire route is deleted, including the nexthops for other devices. This does not happen for IPv6.

Simple example of that bug:

ip li add dummy1 type dummy
ip li add dummy2 type dummy
ip addr add dev dummy1 10.11.1.1/28
ip li set dummy1 up
ip addr add dev dummy2 10.11.2.1/28
ip li set dummy2 up
ip ro add 1.1.1.0/24 nexthop via 10.11.1.2 nexthop via 10.11.2.2
ip li del dummy2

--> the entire multipath route has been deleted.


And, fixing this bug enables work to make IPv4 append to be sane -- appending a route should modify an existing route by adding the nexthop, not adding a new route that I believe can never actually be hit.

Both cases mean modifying an IPv4 route -- adding or removing nexthops -- a capability that IPv6 allows so fixing this means closing another difference between the stacks.
