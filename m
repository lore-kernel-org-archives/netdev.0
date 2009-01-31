From: Todd Hayton <todd.hayton@gmail.com>
Subject: Re: Various strange things with ipv6 local multicast forwarding
Date: Sat, 31 Jan 2009 18:20:12 -0500
Message-ID: <50a66e370901311520h739ecc9bh5e14595d1ebb227e@mail.gmail.com>
References: <498303B5.6090609@slagter.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Erik Slagter <erik@slagter.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:63805 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbZAaXUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 18:20:14 -0500
Received: by qyk4 with SMTP id 4so1314698qyk.13
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2009 15:20:12 -0800 (PST)
In-Reply-To: <498303B5.6090609@slagter.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 8:42 AM, Erik Slagter <erik@slagter.name> wrote:
> Hi All,
>
> I am using a very simple setup: a linux server (linux 2.6.28.2, amd64) with
> 12 nics, almost each connected host has a nic uniquely to itself. On the
> server a program is running (poc-2250 to be precise) that streams data to
> multicast address ff05::4242. This data should be forwarded by the kernel to
> all interfaces that have hosts that are joined to ff05::4242. As it is such
> a simple setup, I do not want to use PIM nor a router application featuring
> PIM, I am using MLD messages only. I've written a very simple "MRT6_INIT"
> app that catches MLD messages and kernel upcalls, and joins interfaces on
> demand. This works :-)
>
> I have had a very hard time with the kernel upcalls, but that problem has
> been solved with the recent "unnecessary skb_pull" patch I found here,
> THANKS! (Hi Todd ;-))
>
> I now have still a few things that do not completely go like I want to or
> like I expect to. Can please someone clarify for me?
>
> 1: Next scenario:
>   - Start streaming application (poc-2250)
>        Now all packets go to a random interface, I cannot understand the
> logic, but most of the time it appears to be dummy0, which actually is a
> good thing. I guess it has something to do with the ff00:/8 routes in the
> "normal" routing table, from which the kernel selects one using some
> criterium. Tshark reveals the packets sent on dummy0 indeed.
>   - Start "MRT6_INIT" app
>   - This gets an upcall message from the kernel (which I can understand) for
> the above mc group.
>   - App installs a "MFC_ADD" mcast route with the parameters from the
> upcall, with NO interfaces. My goal is to silence the streaming application
> until the stream is requested.
>   - mc route gets installed OK
>   - YET packets still appear on dummy0 (tshark and counters) and the "Wrong"
> (interface) counter in /proc/net/ipv6_mr_cache starts to increment.
>
> This is not what I want and not what I expect. I expect the packets to be
> discarded if nobody is listening. I now have to run a "dummy" interface to
> drain unused packets.
>
>   - Most of the time this more or less works, but when for a few hours only
> one interface has been joined to the mc route, a "ghost" route appears,
> which routes the packets for the multicast group directly to this interface,
> so the multicast routing system is not consulted anymore (counters remain
> steady). The route cannot be seen using "ip -6 route" BUT it can be deleted
> using "ip -6 route ff05::4242" but only when the multicast streaming app has
> been stopped. Also, the command must be given several times before the route
> is "not found".
>
> I cannot see the logic behind this and also this is very annoying, as this
> way the mc packets always appear on this interface from this point,
> regardless whether the client on this interface has joined the group.
>
> I already once removed all mc routes from the route table, but that makes
> the complete box fail miserably :-/
>
> 2: When a client wants to join, it sends a MLDv2 message (in my case, it's
> all linux). I catch the message and incoming interface info using
> IPV6_PKTINFO. This yields not enough information to add the client to the mr
> cache though, MFC_ADD needs a "source" interface index and address (and
> cannot use a wildcard, according to the kernel source :-(). At this stage I
> retrieve these by requesting the kernel for the route to multicast address
> (ff05::4242) which until now has been working well, but still I believe it's
> a dirty hack. There must be a more elegant/appropriate way to achieve this?
>
> Somehow I get the impression the ip6 multicast routing code in the kernel is
> more targeted at multicast forwarding packets from outside the box than
> packets locally generated :-/
>

This was my impression as well. From your setup your machine is not
really acting as a multicast router per-se where you forward traffic
received on interface A onto interfaces B, C, D...My impression is
that when you are sourcing the traffic you can only send it out of one
interface (assuming you're doing only one call to sendto()). In fact,
options like IP_MULTICAST_IF and IPV6_MULTICAST_IF let you specify an
outgoing interface, but they only let you specify one outgoing
interface. My understanding was that when you are sending traffic the
normal IP routing table is used to determine the outgoing interface.
In fact, on FreeBSD systems I've worked on you have to explicitly add
a route to be able to send multicast traffic out of an interface (eg
"route add -inet6 -net ff15:: -prefixlen 16 -interface le0") otherwise
sendto() fails with "network is unreachable".

As you've seen, the multicast route downloaded (via MFC_ADD) needs the
incoming interface that the traffic is received on. Generally a
multicast route doesn't get downloaded to the kernel *until* traffic
starts showing up on some interface. The traffic then generates an
upcall which is sent to the user space process which can then look at
the traffic being sent and decide whether or not to download a route
into the kernel (using MRT6_ADD_MFC). The decision on whether or not
to download would be based on whether there were any interested
receivers - which your application would know because it's monitoring
the MLD reports.

Since you're not receiving the traffic from some other host, maybe you
could make it look like you are to the kernel by connecting two of
your interfaces back to back (say eth1 connects to eth2) using a
crossover cable and then enabling multicasting on one of them (using
MRT6_ADD_MIF) and then actually sending traffic out of the other one.
This traffic then gets looped back onto the MIF, generates an upcall
which your userland application gets and can then decide whether or
not it wants to add a route for the traffic...Dunno if this setup
would work but it's one idea...

Todd H
