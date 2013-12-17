From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 1/2] ipv6: add the IPV6_FL_F_REPLY flag to IPV6_FL_A_GET
Date: Tue, 17 Dec 2013 08:51:38 +0100
Message-ID: <20131217075138.GA18396@order.stressinduktion.org>
References: <1386844697-31169-1-git-send-email-florent.fourcot@enst-bretagne.fr> <52A99262.1090001@enst-bretagne.fr> <20131214095650.GD23563@order.stressinduktion.org> <52AF4547.8020304@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60888 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab3LQHvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:51:39 -0500
Content-Disposition: inline
In-Reply-To: <52AF4547.8020304@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 07:24:07PM +0100, Florent Fourcot wrote:
> Hello,
> 
> > Sorry, I am not up to date with flowlabel RFCs and applications. Couldn't
> > such a feature get in the way of RSVP flow control if a remote side
> > can dictate the label to use for the outgoing connection (I know, your
> > implementation is opt-in, but I don't want to give application developers
> > something at hand which could make their software difficult to operate
> > in future).
> > 
> 
> You are right, it could be a problem. But Flow Label are not only
> specified for Quality of Service, and RFC's does not forbid this use case.
> Since this option is opt-in, it should not be a problem. It is already
> possible to set flow label with random values in an application. A
> developper can do getsocketopt(FLOWINFO_SEND), and set the flow label to
> the result (but it lost first packets of TCP handshakes).

But the application would have to create the label prior to sending and
this could result in an error the application would get at label creation
time it has to deal with.

The flowinfo in the sockaddr_in6 structure will be checked against the flowmgr
cache at connect time. So this path is ok.

> >> I'm not sure of the best way to do that. First, should we allocate a
> >> real flow label in the global flow label? I don't think so, and it could
> >> add hard issues with the system of permission/sharing.
> > 
> > I wouldn't do that either. OTOH we are emitting frames with a flowlabel the
> > flowmgr does not know about. :/
> > 
> 
> Hum, what is the best way in your opinion? It is not hard to allocate
> the flow label at the first received packet, but there are for me two
> issues.

Actually it is hard IMHO. I don't think flowlabel cache has been in use
a lot and we would have to make sure it does have all the protections
current hash tables need (hash keying, eviction strategy hardening etc.).

It is not simple to insert items from the network into a globally in-kernel
data structure, especially if it was used locally only before. It may result
in DoS attacks or one could try to evict a label which is in need by another
application which maybe could bring another applications syscalls to fail.

So, I wouldn't do that until the flowlabel data structures have seen an
audit with that in mind.

I haven't looked at it in details but that are my concerns.

> The most important problem is the "sharing" of flow label: what happens
> if we receive a packet with a already reserved label? Should we return
> an error to the user (and them, how to do that?), or can we ignore it.
> 
> The second issue is the renew/release of label, more particularly if the
> label sent by the remote device change.

I am not a fan of lots of tunables, but maybe we can restrict this
with a sysctl. If you only care about the reflection feature, maybe
a setsockopt-IPPROTO_IPV6, IPV6_FLOWLABEL_REFLECT, on the listening
socket, which only succeeds if a sysctl has been switched from off to
on would do the trick. The documentation for the sysctl should state,
that this bypasses flowmgr and system-wide uniquness is not guaranteed
any more under any circumstance (EXCL flag does not hold any more). Am
I seeing this correctly?

> >> Second, I was not sure of the best way for the coverage for all TCP states.
> > 
> > And why would you only support TCP? Wouldn't this work for connected UDP
> > sockets, too?
> > 
> 
> Actually, I began with TCP, but of course others transport protocols
> could support this feature. For the UDP case, it could be implemented in
> user space with recvmg/sendmsg (because there are no extra SYN/ACK/etc
> packets), but add this option in the kernel space is a good idea.

It is ok to start with TCP only and add other protocols later.

Greetings,

  Hannes
