From: Gautam Kachroo <gk@aristanetworks.com>
Subject: Re: [PATCH] iproute2 flush: handle larger tables and deleted entries
Date: Thu, 20 Aug 2009 17:08:07 -0700
Message-ID: <4e0db5bc0908201708s2d1a4523q2a09eac418061893@mail.gmail.com>
References: <4e0db5bc0907130939k48b16256j8f60c786a7e5e44c@mail.gmail.com>
	 <4A5C5233.4010007@trash.net>
	 <4e0db5bc0907140945i3190cfb7g7b3e6a0f1c10bc8a@mail.gmail.com>
	 <4A5DF369.1090107@trash.net>
	 <4e0db5bc0907151050w56529bffh9878b99cc2fdaae5@mail.gmail.com>
	 <20090715121907.04b7f5b0@s6510>
	 <4e0db5bc0907151504i28ed3a00l85e6767e9ef59921@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:12365 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbZHUAIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 20:08:05 -0400
Received: by rv-out-0506.google.com with SMTP id f6so100139rvb.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 17:08:07 -0700 (PDT)
In-Reply-To: <4e0db5bc0907151504i28ed3a00l85e6767e9ef59921@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2009 at 3:04 PM, Gautam Kachroo<gk@aristanetworks.com> wrote:
> On Wed, Jul 15, 2009 at 12:19 PM, Stephen
> Hemminger<shemminger@vyatta.com> wrote:
>> On Wed, 15 Jul 2009 10:50:57 -0700
>> Gautam Kachroo <gk@aristanetworks.com> wrote:
>>
>>> On Wed, Jul 15, 2009 at 8:19 AM, Patrick McHardy<kaber@trash.net> wrote:
>>> > Gautam Kachroo wrote:
>>> >> On Tue, Jul 14, 2009 at 2:38 AM, Patrick McHardy<kaber@trash.net> wrote:
>>> >>> Gautam Kachroo wrote:
>>> >>>> use a new netlink socket when sending flush messages to avoid reading
>>> >>>> any pending data on the existing netlink socket.
>>> >>>>
>>> >>>> read all of the response from the netlink request -- this response can
>>> >>>> be split over multiple recv calls, pretty much one per netlink request
>>> >>>> message. ENOENT errors, which correspond to attempts to delete an
>>> >>>> already deleted entry, are ignored. Other errors are not ignored.
>>> >>>
>>> >>> In which case would there be any pending data? From what I can see,
>>> >>> this can only happen when using batching, but in that case the
>>> >>> previous command should continue reading until it has received all
>>> >>> responses (which the netlink functions appear to be doing properly).
>>> >>
>>> >> What is the "previous command"?
>>> >
>>> > The last command before the one executing when using batching.
>>>
>>> This is independent of batching (I assume you're referring to the
>>> -batch option to the ip command).
>>> It happens when running a command like "ip neigh flush to 0.0.0.0/0"
>>> if there are many neighbor entries.
>>>
>>> The implementation of flush commands, e.g. ip neigh flush, sends a
>>> dump request, e.g. RTM_GETNEIGH, and then sends requests, e.g.
>>> RTM_DELNEIGH, *while* there can be unread data from the dump request.
>>> There would be unread data if the response to the dump request was
>>> split over multiple calls to recvmsg.
>>>
>>> >> Are you referring to rtnl_dump_filter? If rtnl_send_check comes across
>>> >> a failure, rtnl_dump_filter will not continue reading.
>>> >>
>>> >> Here's the situation that I'm referring to:
>>> >>
>>> >> If rtnl_send_check detects an error, it returns -1. rtnl_send_check is
>>> >> called from flush_update. The multiple implementations of flush_update
>>> >> (e.g. in ipneigh.c, ipaddress.c) propagate this return value to their
>>> >> caller, e.g. print_neigh or print_addrinfo.
>>> >>
>>> >> print_neigh, print_addrinfo, etc. are called from rtnl_dump_filter.
>>> >> rtnl_dump_filter sits in a loop calling recvmsg on the netlink socket.
>>> >> However, it returns the error value if the filter function (e.g.
>>> >> print_neigh) returns an error. In this case, rtnl_dump_filter can
>>> >> return before it's read all the responses.
>>> >> The error return from rtnl_dump_filter causes the program to exit.
>>> >
>>> > Yes, and I agree with your patch so far. My question is why you
>>> > need another socket.
>>> >
>>> >> use a new netlink socket when sending flush messages to avoid reading
>>> >> any pending data on the existing netlink socket.
>>> >
>>> > Under what circumstances would there be pending data when
>>> > performing a new iproute operation?
>>>
>>> As above, it's not that there is pending data when performing a new
>>> iproute operation, it's that there can be pending data while
>>> performing a single iproute operation, namely ip <object> flush.
>>> The benefit of a new socket is that it won't have any data from the
>>> dump request waiting for it.
>>
>> I posted a better fix (using MSG_PEEK).
>
> Where did you post the fix? I didn't see it on netdev or in the iproute2 git...

> I had considered using MSG_PEEK in rtnl_send_check, but I don't think
> that notices errors with the requests in the "buf" argument of
> rtnl_send_check if there is already pending data -- the recv will peek
> the next chunk of the dump response. The error response will be
> waiting in the queue after the dump response.
> Of course, an error, e.g. EPERM, will eventually be noticed, just not
> as early...

I saw commit 2d8240f8d95dfdc276dcf447623129fb5ccedcd6.

Using MSG_PEEK will prevent pending data from being removed during the
check for errors, but re-using the same socket means that errors won't
be detected until all the pending data has been read.

rtnl_send_check still treats ENOENT as an error. It seems better for
flush to ignore ENOENT. That way a flush will not be disrupted by an
entry being removed since that's not really an error for a flush
operation.

thanks,
-gk


> thanks,
> -gk
>
