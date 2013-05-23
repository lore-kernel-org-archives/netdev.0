From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Thu, 23 May 2013 14:45:51 -0400
Message-ID: <OFCF66B423.CF0815E9-ON85257B74.0062F5C7-85257B74.0067134F@us.ibm.com>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>	<OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
	<20130520113000.0057ce90@nehalam.linuxnetplumber.net>	<20130522.150830.1305371698781503084.davem@davemloft.net>
	<OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com>	<20130522173954.7f75f62d@nehalam.linuxnetplumber.net>
	<OF0BD0286F.81969B78-ON85257B74.00097DBA-85257B74.000C5443@us.ibm.com> <20130523100854.6c9749d6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:39773 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757896Ab3EWSp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 14:45:59 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 23 May 2013 12:45:58 -0600
In-Reply-To: <20130523100854.6c9749d6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 05/23/2013 
01:08:54 PM:

> Let's go back to basic use cases.
> User wants to setup a vxlan between two hosts with custom port
>    On both hosts, he/she does:
>  # ip li add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth0 dstport 
4789
> 
> With net-next it works, with 3.10 it doesn't.

This does not "work" in net-next, either. If you set the one-and-only bind
port to one port and the one and only send port to another port on both
systems, they can't talk to each other in net-next, either. If you 
separately
have it listen on multiple ports, and if potential non-linux systems 
you're
talking to can do that too, then you can configure it to work, but the 
extra
listen ports are entirely unnecessary.

You're starting with the assumption, which I disagree with, that the 
receive
and send ports need to be the same. In fact, for two systems listening on
different ports to talk to each other, they *must* be different. It 
doesn't
require multiple ports, it only requires the listen and send ports be 
*different*.

If I have two existing systems, one listening on port 8472 and one 
listening
on port 4789, and I want to connect them, how would you do that? Yes, you
*can* add individual MAC entries with different ports for all VMs 
connected
on both machines, but if you have 2 hosts and 10,000 MAC addresses, that's
a ridiculous waste. If you simply don't know all the MAC addresses on the
remote machine, you can't do it. But if you can set the destination port 
for
the default fdb entry, which is what dstport does, then you can do both.

The dstport and dst are simply the default entry for the fdb table, used 
if
there is no exact match in the fdb. They should have every capability to 
use
alternate data that the fdb table does.

> Sure it works if they have your agent, or manually configure N-M static 
FDB
> entries, but that is corner case.
> 
> No matter if Dave decides to the revert the kernel part or not, I am
> pulling the option
> from 3.10 version of iproute to avoid user confusion.

I don't know what confusion you're concerned about here. How can anyone
be confused by packets going to a different destination port when they use
an option "dstport XXXX"? (!?!?!?!?)

You can't really prohibit people from using VXLAN however they choose to.
It simply means people wanting to do more interesting things will
have to patch your code, jump through hoops to edit packets with 
netfilter,
or use alternative implementations that are more flexible. None of those
things benefits VXLAN on linux.

                                                                +-DLS
