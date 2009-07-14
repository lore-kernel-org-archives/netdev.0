From: Gautam Kachroo <gk@aristanetworks.com>
Subject: Re: [PATCH] iproute2 flush: handle larger tables and deleted entries
Date: Tue, 14 Jul 2009 09:45:47 -0700
Message-ID: <4e0db5bc0907140945i3190cfb7g7b3e6a0f1c10bc8a@mail.gmail.com>
References: <4e0db5bc0907130939k48b16256j8f60c786a7e5e44c@mail.gmail.com>
	 <4A5C5233.4010007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:50801 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755255AbZGNQpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 12:45:49 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1047035wfd.4
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 09:45:47 -0700 (PDT)
In-Reply-To: <4A5C5233.4010007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2009 at 2:38 AM, Patrick McHardy<kaber@trash.net> wrote:
> Gautam Kachroo wrote:
>> use a new netlink socket when sending flush messages to avoid reading
>> any pending data on the existing netlink socket.
>>
>> read all of the response from the netlink request -- this response can
>> be split over multiple recv calls, pretty much one per netlink request
>> message. ENOENT errors, which correspond to attempts to delete an
>> already deleted entry, are ignored. Other errors are not ignored.
>
> In which case would there be any pending data? From what I can see,
> this can only happen when using batching, but in that case the
> previous command should continue reading until it has received all
> responses (which the netlink functions appear to be doing properly).

What is the "previous command"?
Are you referring to rtnl_dump_filter? If rtnl_send_check comes across
a failure, rtnl_dump_filter will not continue reading.

Here's the situation that I'm referring to:

If rtnl_send_check detects an error, it returns -1. rtnl_send_check is
called from flush_update. The multiple implementations of flush_update
(e.g. in ipneigh.c, ipaddress.c) propagate this return value to their
caller, e.g. print_neigh or print_addrinfo.

print_neigh, print_addrinfo, etc. are called from rtnl_dump_filter.
rtnl_dump_filter sits in a loop calling recvmsg on the netlink socket.
However, it returns the error value if the filter function (e.g.
print_neigh) returns an error. In this case, rtnl_dump_filter can
return before it's read all the responses.
The error return from rtnl_dump_filter causes the program to exit.

Note, rtnl_send_check treats any pending data as an error. It could be
changed to only complain if the response contains NLMSG_ERROR
messages, but that delays error detection because it will read all the
responses to the dump request first.

thanks,
-gk
