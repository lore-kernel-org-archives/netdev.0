From: David Ahern <dsahern@gmail.com>
Subject: Re: VRFs and the scalability of namespaces
Date: Mon, 29 Sep 2014 07:06:57 -0600
Message-ID: <54295971.2040402@gmail.com>
References: <5425EAA6.7040302@gmail.com> <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64306 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbaI2NG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:06:59 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so846315pdi.5
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 06:06:58 -0700 (PDT)
In-Reply-To: <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes:

On 9/27/14, 7:29 AM, Hannes Frederic Sowa wrote:
> Did you already did an investigation how maybe the rule and table
> features could be exploited to suite your needs? Some time back I

I did look into the existing multiple table option but not to the extent 
of creating a POC. It has been on my to-do list for 4+ months now I just 
have not had time to get to it. Based on a number of Google searches to 
review the history of VRFs and the kernel, I did see the use of multiple 
routing tables has been suggested as well and its problems have been 
delineated. e.g.,

     http://www.spinics.net/lists/linux-net/msg17502.html


> suggested something like "ip route table foo exec ....", keep an default
> routing lookup indicator in task_struct which gets implicitly propagated
> to rtnetlink routing table requests/modification for the requested
> table. Tables already can be specified via rtnetlink, so no change would
> be needed here.
>
> For sockets something like SO_BINDTOTABLE might work, maybe even we can
> by default use the task_struct information to also bind the sockets to
> the per-process table. We certainly need to preserve the routing
> information on the socket as we need those in icmp error handling (e.g.
> where to apply ipv4/ipv6 redirects too). Directing incoming packets to
> specific table also works via ip-rule-iif match.
>
> Advantage with the ip route table foo exec... method would be, that
> conversion of some unmodified routing management daemons might be
> easier, others can either use rtnetlink extended attributes which are
> already available, and we only need to have per-process context routing
> table control, which seems not too hard to implement in ip-rule
> subsystem, but I haven't checked.
>
> The problem I see with rules is that some of those tables already work
> hand in hand, they already have a implicit semantics, e.g. local, main,
> default and unspec (this is even worse for IPv6, where addrconf already
> uses hardcoded tables). Working around this might be very tricky and
> even more problematic to do from user space.
>
> I think I am not yet sure what features you want from VRFs, some things
> seem to match the rule/table features but others I think are pretty hard
> to implement.

The features of note:
- resource efficiency -- not having to create a proces/thread/socket per 
VRF to have a "presence" in all VRFs. e.g., a VRF any context that 
allows 1 socket to work across VRFs (L3 raw socket, TCP listen socket, 
unconnected UDP socket). Daemons run a 'vrf any' context; connected 
clients run a specific vrf context. For non-connected sockets VRF 
context can be passed via cmsg.

- same IP address on different interfaces in different vrfs. i.e., VRF 
specific routing and neighbor tables

- cross VRF routing. ability to receive message on 1 vrf and send it on 
another. Can be handled by the process itself (e.g., L3 vpns).

Thanks,
David
