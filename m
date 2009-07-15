From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2 flush: handle larger tables and deleted entries
Date: Wed, 15 Jul 2009 17:19:05 +0200
Message-ID: <4A5DF369.1090107@trash.net>
References: <4e0db5bc0907130939k48b16256j8f60c786a7e5e44c@mail.gmail.com>	 <4A5C5233.4010007@trash.net> <4e0db5bc0907140945i3190cfb7g7b3e6a0f1c10bc8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gautam Kachroo <gk@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57423 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408AbZGOPTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 11:19:11 -0400
In-Reply-To: <4e0db5bc0907140945i3190cfb7g7b3e6a0f1c10bc8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gautam Kachroo wrote:
> On Tue, Jul 14, 2009 at 2:38 AM, Patrick McHardy<kaber@trash.net> wrote:
>> Gautam Kachroo wrote:
>>> use a new netlink socket when sending flush messages to avoid reading
>>> any pending data on the existing netlink socket.
>>>
>>> read all of the response from the netlink request -- this response can
>>> be split over multiple recv calls, pretty much one per netlink request
>>> message. ENOENT errors, which correspond to attempts to delete an
>>> already deleted entry, are ignored. Other errors are not ignored.
>>
>> In which case would there be any pending data? From what I can see,
>> this can only happen when using batching, but in that case the
>> previous command should continue reading until it has received all
>> responses (which the netlink functions appear to be doing properly).
> 
> What is the "previous command"?

The last command before the one executing when using batching.

> Are you referring to rtnl_dump_filter? If rtnl_send_check comes across
> a failure, rtnl_dump_filter will not continue reading.
> 
> Here's the situation that I'm referring to:
> 
> If rtnl_send_check detects an error, it returns -1. rtnl_send_check is
> called from flush_update. The multiple implementations of flush_update
> (e.g. in ipneigh.c, ipaddress.c) propagate this return value to their
> caller, e.g. print_neigh or print_addrinfo.
> 
> print_neigh, print_addrinfo, etc. are called from rtnl_dump_filter.
> rtnl_dump_filter sits in a loop calling recvmsg on the netlink socket.
> However, it returns the error value if the filter function (e.g.
> print_neigh) returns an error. In this case, rtnl_dump_filter can
> return before it's read all the responses.
> The error return from rtnl_dump_filter causes the program to exit.

Yes, and I agree with your patch so far. My question is why you
need another socket.

> use a new netlink socket when sending flush messages to avoid reading
> any pending data on the existing netlink socket.

Under what circumstances would there be pending data when
performing a new iproute operation?
