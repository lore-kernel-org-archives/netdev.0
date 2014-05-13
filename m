From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Tue, 13 May 2014 11:12:03 -0600
Message-ID: <53725263.2080903@gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>	<CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>	<CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com>	<CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com>	<CAKD1Yr0z40vY8ucGDuLo8rPDudtHeOeMPbN_vfSSS_K4KjCffg@mail.gmail.com> <CACP96tTRQqvQM6UTuqtVonZJW3LaHkBZkkpH+zCZa=GjHAEy+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: sowmini varadhan <sowmini05@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:64378 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaEMRMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:12:07 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so136845pbc.15
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 10:12:07 -0700 (PDT)
In-Reply-To: <CACP96tTRQqvQM6UTuqtVonZJW3LaHkBZkkpH+zCZa=GjHAEy+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/14, 4:49 AM, sowmini varadhan wrote:
> On Mon, May 12, 2014 at 6:53 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
>> On Tue, May 13, 2014 at 6:09 AM, sowmini varadhan <sowmini05@gmail.com> wrote:
>>> http://lwn.net/Articles/407495/, a single
>>> process should be able to open sockes in different namespaces.
>>
>> Other things that you can't do with namespaces are have the same physical
>> interface (and the same IP address?) in two different namespaces, or
>> have the same listening socket in two different namespaces. Namespaces
>> are not a panacea.'
>
> So this thread got unintentionally cut off by my not selecting Reply-All
> in the google gui.
>
> But to summarize a couple of private exchanges between Lorenzo and
> me, it still appears to me that the use-case here is what routers
> consider a "VRF". Thus it makes sense to add code (if/as needed)
> to fix the VRF support in linux, rather than adding yet-another-one-off
> feature with socket marking.
>
> Specifically addressing the two issues raised above:
> - yes, it is true that an interface can exist in only one netns at a time.
>    But the same ip address can exist in multiple netns-es. If the
>    app wants to listen to a proper-subset of networks that go in/out
>    a single physical interface, you can use macvlan, and assign the
>    macvlans to the desired netns.
> - "same listening socket for multiple namespaces". Clearly that problem
>    also exists for the socket-marks approach. But again this can actually
>    be solved (for both netns and sock-marks) by having the application
>    set up separate sockets for each netns (netns or whatever) of interest,
>    and build an epoll fd over that set of sockets. No need for any kernel
>    code for this.

using namespaces for VRFs has a number of problems:

1. It does not scale efficiently -- e.g., 1k VRFs.
    a. namespaces have high memory consumption. It depends on features 
enabled, but I see ~200kB/namespace. At 1024 namespaces that's a high 
memory hit.

    b. requiring separate processes/threads/sockets per namespace for a 
service to have a presence in each. ie., the 'same listening socket for 
multiple namespaces' problem.

2. Complicates L2 apps which should be vrf agnostic.

3. Requires root (CAP_SYS_ADMIN) to use setns. If you go the 
thread/socket per namespace route all of those processes need SYS_ADMIN 
capability which is not the desired security posture.

>
>    Or you can optimize this by building infra in the kernel to support the
>    Wildcard ALL_VRFS notion. Or add even more code to support something
>    less than ALL_VRFS.
>
> My point is: what is the real networking construct that this use-case needs?
> Isn't it what routers describe as the VRF? If yes, then shouldnt
> we have one single way of supporting that in linux, instead of having
> a little-bit-here and a little-bit-there?

 From a separation of resources perspective why not have the 
infrastructure kernel side that allows interfaces to be separated into 
namespaces for isolation and then within a namespace provide L3 
abstractions that allow separate routing tables, neighbor caches, etc -- 
ie., VRF abstraction within a network namespace. Allow apps to have a 
listen socket that works across the VRFs in a namespace; connected 
sockets are VRF based.

Nested network namespaces (which does not seem to work with 3.4 and 3.10 
kernels) would provide that layering but still suffers from the problems 
mentioned above.

David
