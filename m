From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP path MTU discovery
Date: Wed, 31 Mar 2010 17:06:19 -0700
Message-ID: <4BB3E37B.8040400@hp.com>
References: <1269561751.2891.8.camel@ilion> <4BAC0577.7070803@hp.com>	<20100325.202636.149498207.davem@davemloft.net>	<1270078923.2389.31.camel@ilion> <20100331235149.GE3042@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Glen Turner <gdt@gdt.id.au>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:34796 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755072Ab0DAAGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:06:22 -0400
In-Reply-To: <20100331235149.GE3042@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer wrote:
> * Glen Turner | 2010-04-01 10:12:03 [+1030]:
> 
> 
>>Does select() return from its blocking so the application can make
>>use of this indication immediately, rather than after the
>>application's exponentially-increasing wait?
> 
> 
> Yes, poll() will return immediately with POLLERR.
> 
> 
>>Is an incoming ICMP the only cause of EMSGSIZE?  That is, can an
>>application safely retransmit immediately?
> 
> 
> IIRC, yes.

Under Linux perhaps, and assuming it can guess which prior send triggered the 
EMSGSIZE, but under HP-UX EMSGSIZE means you tried to send a datagram larger 
than the socket buffer:

tusc src/netperf -t UDP_RR -- -s 1024 -r 60K
...
send(4, 0x4000ee68, 61440, 0) ............................ ERR#218 EMSGSIZE

I've not checked BSD, Solaris or AIX.

On a 2.6.22 kernel where I do the same thing, it returns ENOBUFS instead.

strace src/netperf -H localhost -t UDP_RR -- -s 1024 -r 60K
...
send(4, "netperf\0netperf\0netperf\0netperf\0n"..., 61440, 0) = -1 ENOBUFS (No 
buffer space available)

Of course the send() manpage on various Linux systems I've tried says:

        EMSGSIZE
               The  socket  type  requires that message be sent atomically, and
               the size of the message to be sent made this impossible.

        ENOBUFS
               The output queue for a network interface was full.  This  gener-
               ally  indicates  that the interface has stopped sending, but may
               be caused by transient congestion.   (Normally,  this  does  not
               occur in Linux.  Packets are just silently dropped when a device
               queue overflows.)

I suppose they are old on that system.  Netperf interprets an ENOBUFS per the 
manpage, and will not exit immediately in a UDP_STREAM test, but will simply 
count the send as failed and try again.  Not sure if it is worth trying to teach 
netperf differently here or not.

rick jones
