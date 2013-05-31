From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: RFC - VXLAN port range facility
Date: Fri, 31 May 2013 10:22:33 -0700
Message-ID: <20130531102233.13e51cff@nehalam.linuxnetplumber.net>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
	<20130530094141.7c125947@nehalam.linuxnetplumber.net>
	<OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>
	<20130531091338.12fc7df5@nehalam.linuxnetplumber.net>
	<OF19ABC0E6.77100D83-ON85257B7C.005AFB01-85257B7C.005E33DC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40719 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776Ab3EaRWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 13:22:37 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so2545088pbb.5
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 10:22:37 -0700 (PDT)
In-Reply-To: <OF19ABC0E6.77100D83-ON85257B7C.005AFB01-85257B7C.005E33DC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 May 2013 13:08:56 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> Stephen Hemminger <stephen@networkplumber.org> wrote on 05/31/2013 
> 12:13:38 PM:
> 
> > 
> > RFC text:
> >  Outer UDP Header:  This is the outer UDP header with a source
> >         port provided by the VTEP and the destination port being a well
> >         known UDP port to be obtained by IANA assignment. It is 
> recommended
> >         that the source port be a hash of the inner Ethernet frame's 
> headers
> >         to obtain a level of entropy for ECMP/load balancing of the VM 
> to VM
> >         traffic across the VXLAN overlay.
> > 
> > 
> > You can restrict to a smaller range if that is a requirement of your
> > infrastructure.
> 
>         I'm suggesting the smaller range, because the fix for the part
> that is broken would become a resource issue for the current, larger
> default range.
>         [and a "recommended" in a draft doesn't trump 35 years of UDP
>                 usage, even if it did say not to bind the ports...]
>  
> > Normal UDP applications assign their source port from the ephemeral 
> > port range,
> > so that is what VXLAN does.
> 
>         Normal UDP applications bind to the source port. If they are
> unbound, they bind just for the send and then unbind after. They
> cannot use a port already bound _because_the_bind_prohibits_it.
>         That is, in fact, the entire issue I'm raising. (!) If I have
> a UDP application that binds to port 35000, no other UDP application
> will ever use that port until I release it, and any ICMP errors delivered
> to my socket are triggered by my application.
>         That became no longer true with the addition of VXLAN port ranges,
> because VXLAN does not use UDP bind, or any of the UDP code, to enforce
> this. It simply generates a random number in the range, which _can_be_
> 35000 or any other bound port, and then sends its own, constructed UDP
> header using that port.
> 
>         The proper way to fix this would be to actually bind to a port in
> the range, and retry another port if the binding fails, until the binding
> succeeds. But as VXLAN picks a randomized source port _for_each_packet_,
> I'm not suggesting we do that.
>         I'm suggesting, instead, that we bind on all the source ports we
> will use at start-up, which then reserves those ports for VXLAN and
> prevents anyone else from binding on them.
>         That solves the issue of binding and unbinding on each packet,
> but I am not then suggesting that VXLAN should bind on 30,000 ports on
> start-up. That would be silly, especially on a system whose primary 
> function
> is not VXLAN.
>         So, the logical next question is: does VXLAN really need a range
> of 30,000 ports as the "normal" circumstance? I think the answer to that
> is definitely "no." In fact, just one port would work fine a lot of the
> time, and when multiple ports are needed, the capability is still there.
> That suggests changing the *default* range (I suggest to 1 port).

The range could be smaller yes, but that means you are restricting
hashing.

>         My conclusions from that reasoning:
> 
> 1) VXLAN use of UDP source ports is broken; it cannot use ports that are
>         already bound, and right now it does
> 2) while a bind/unbind would work, doing that on every packet is slow

The problem is the bind/unbind is  a flow state operation, and
doing keeping flow state wouldn't scale.
 

> 
> so,
> 
> 3) the default port range should be much smaller and VXLAN should bind
>         in advance to the set of ports it wants to use.

Probably should not overlap ephemeral port range for applications.


> 
> Now, maybe it wouldn't kill performance, and so doing a bind/unbind per
> packet is still an option, but that would definitely hurt performance
> for people who don't actually care about port entropy.

What about a peek operation that just avoids existing ports.

> Whether solved by a bind/unbind, pre-binding to a smaller default port
> range, or a switch between the two, I think VXLAN *must* follow the
> rules in its use of UDP and ensure that it doesn't send using source
> ports in use by something else. It can't just generate a random one
> and use it without checking it, as it does now.
> 
>                                                                 +-DLS
> 
