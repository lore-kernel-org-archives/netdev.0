From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Mon, 15 Sep 2014 14:35:59 +0200
Message-ID: <5416DD2F.50106@ericsson.com>
References: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com> <1410424167-17427-5-git-send-email-richard.alpe@ericsson.com> <20140912.171038.1165432718811920305.davem@davemloft.net> <54169B6C.5060709@ericsson.com> <20140915085152.GC14006@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:42758 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbaIOMhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 08:37:01 -0400
In-Reply-To: <20140915085152.GC14006@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 10:51 AM, Florian Westphal wrote:
> Richard Alpe <richard.alpe@ericsson.com> wrote:
>>> You can't just say sometimes you'll partially list the set of nested
>>> attributes in an object, you must public the entire object fully in
>>> the netlink message or skip the object entirely.
>> Ok. I bluntly assumed we could put some reassemble logic in the
>> client as the end integrity should still be preserved(?).
>>
>>> I would suggest that you instead size the amount of space you'll
>>> need for at least the first socket being listed, and if NLMSG_GOODSIZE
>>> is insufficient, allocate as much as you will actually need.
>>>
>>> Then you put full socket netlink blobs in there, including all nested
>>> attributes, and then stop and reset back the the most recent full socket
>>> published if you run out of space.
>> The amount of publications a socket can have is large (~65 000). Do
>> you still think this a viable solution?
>
> I suggest to look at nf_conntrack_netlink.c ctnetlink_dump_table() and
> ctnetlink_fill_info().
>
> It should be doing something similar to what you want and it handles
> the restarts correctly, i.e., cancels all partial nested attributes
> on error and resumes at the beginning of said entry on the next dump.
Thanks. In the case of ctnetlink_fill_info() it looks to me as if a set 
of nested attributes is sure to fit inside a new message and that you 
only have to cancel if the accumulation of multiple top level entities 
along where their nested attributes fills the message(?).

The problem in this case isn't solely the listing of a large amount of 
publication attributes. The problem is that there can be an arbitrary 
amount of sockets with an arbitrary amount of associated (nested) 
publications (~65 000 max).

I "solved" this by nesting as many complete publications as possible for 
each socket. This "works" but as David points out the nested publication 
data for a specific socket might or might not be complete. This is 
solely indicated by the NLMSG_DONE flag, forcing the client to know this 
and reassemble.

I'm now considering splitting the socket and publication listing so that 
the client will have to ask for a list of sockets and then ask for there 
associated publications individually. This would reduce the complexity 
on the kernel side but it may introduce some additional overhead when 
the socket count is high. On the other hand it opens the opportunity for 
client to only ask for publications.

Cheers
Richard
