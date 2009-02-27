From: david@lang.hm
Subject: Re: ip_nonlocal_bind and sendto (fwd)
Date: Fri, 27 Feb 2009 09:50:40 -0800 (PST)
Message-ID: <alpine.DEB.1.10.0902270946560.26625@asgard.lang.hm>
References: <alpine.DEB.1.10.0902270119060.7158@asgard.lang.hm> <20090227145015.GG22152@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:59379 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062AbZB0RwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 12:52:15 -0500
In-Reply-To: <20090227145015.GG22152@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Feb 2009, Arnaldo Carvalho de Melo wrote:

> Em Fri, Feb 27, 2009 at 01:20:07AM -0800, david@lang.hm escreveu:
>> I've got a need to forge the source IP of UDP packets (a stupid syslog
>> receiver app that I need to deal with)
>>
>> I know that this can be done with raw sockets, but with the
>> IP_nonlocal_bind option I thought that it may be possible to do this
>> without dealing with raw sockets
>>
>> so I have an app that does the socket call, followed by the bind call
>> without any errors, but when I issue the sendto call it generates error
>> 22 (invalid parameter) if the source IP doesn't exist on the local box
>> somewhere.
>>
>> is this the kernel that is doing whatever check is failing? or is glibc
>> wrapping the kernel syscall and doing some additional checking?
>>
>> if it is the kernel that's throwing the error, is there some way of
>> disabling this check? or do I have to go to raw sockets?
>
> Follow:
>
> udp_sendmsg
>    ip_route_output_flow
>        __ip_route_output_key
>
> And then look at this line:
>
> 	rth->fl.fl4_src == flp->fl4_src &&
>
> It'll fail and so another function will be called:
>
> 	    ip_route_output_slow
>
> Many, many details later, this comment:
>
>                           Because we are allowed to send to iface
>                           even if it has NO routes and NO assigned
>                           addresses. When oif is specified, routing
>                           tables are looked up with only one purpose:
>                           to catch if destination is gatewayed, rather than
>                           direct. Moreover, if MSG_DONTROUTE is set,
>                           we send packet, ignoring both routing tables
>                           and ifaddr state. --ANK
>
> So try using:
>
> setsockopt(udp_sock, SOL_SOCKET, SO_BINDTODEVICE, "eth0", 5);
>
> Replacing "eth0" with the interface you want your forged packets to fly by.
>
> The device name will be transformed into an index and stored in
> sk->sk_bound_dev_if, that later, at udp_sendmsg time, will get stashed into
> that oif field and then that comment will hold.
>
> Caveat emptor: I never tried this, this is just after 5 minutes code inspection 8)

this did not work.

I didn't really expect it to because routing should only look at the 
destination address in the packet, so the source address shouldn't matter.

to clarify

the syslog server I am sending to is on my local subnet, I can send 
messages to it normally.

I am needing to relay syslog messages I have received from another 
machine to this syslog server, but forge the source IP address to make it 
look to the syslog server like the packet initiated from the remote 
machine instead of the syslog relay.

David Lang
