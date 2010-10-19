From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Mon, 18 Oct 2010 23:16:57 -0300
Message-ID: <20101019021657.GZ8781@llucax.com.ar>
References: <20101018150422.GV8781@llucax.com.ar>
 <20101018184628.GX8781@llucax.com.ar>
 <AANLkTimKbOreV4Fuyw3TbCrk9aa5yBZQSuRbo3Vdx=Q1@mail.gmail.com>
 <20101018.151708.193712688.davem@davemloft.net>
 <4CBCD429.8090306@windriver.com>
 <20101018234547.GA5703@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alerce.vps.bitfolk.com ([212.13.194.134]:4831 "EHLO
	alerce.vps.bitfolk.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab0JSCRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 22:17:49 -0400
Content-Disposition: inline
In-Reply-To: <20101018234547.GA5703@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman, el 18 de octubre a las 19:45 me escribiste:
> > What I think has happened here (and I'll double check this
> > tomorrow, since it is before I started assisting with tipc)
> > is that a backwards incompatible change *did* inadvertently
> > creep in via these two (related) commits:
> > 
> > --------------
> > commit d88dca79d3852a3623f606f781e013d61486828a
> > Author: Neil Horman <nhorman@tuxdriver.com>
> > Date:   Mon Mar 8 12:20:58 2010 -0800
> > 
> >     tipc: fix endianness on tipc subscriber messages
> > --------------
> > 
> > and
> > 
> > ---------------
> > commit c6537d6742985da1fbf12ae26cde6a096fd35b5c
> > Author: Jon Paul Maloy <jon.maloy@ericsson.com>
> > Date:   Tue Apr 6 11:40:52 2010 +0000
> > 
> >     TIPC: Updated topology subscription protocol according to latest spec
> > ---------------
> > 
> > Based on Leandro's info, I think it comes down to userspace
> > not knowing exactly where to find these bits anymore:
> > 
> > #define TIPC_SUB_SERVICE       0x00    /* Filter for service availability    */
> > #define TIPC_SUB_PORTS         0x01    /* Filter for port availability  */
> > #define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */
> > 
> That shouldn't be the case.  Prior to the above changes the tipc implementation
> tracked the endianess of the hosts to which it was connected and swapped data
> that it sent to those hosts accordingly.  With these changes the kernel client
> simply swaps the data to network byte order on send and swaps it back to local
> order on receive universally.  That second commit added a bit from the reserved
> pool of one of the connection establishment messages to indicate that a peer was
> using this new protocol.  If some non-local byte order information is making it
> into user space, thats a bug that needs fixing.
> 
> What may be happening is some old client that doesn't know about the new bit
> might be communicating with an new client that does.  IIRC the spec called for
> clients that set bits in the reserved field to drop frames from that client, so
> that condition shouldn't occur, but TIPC may just be ignoring reserved bits.  I
> wouldn't be suprised.
> 
> Its also possible that the payload data between applications using tipc follow
> the same broken byte swapping method that the protocol itself did, but if that
> were the case I would expect the application to continue running normally,
> unless user space had direct access to the protocol header in its entirety, and
> read it directly, in which case I think I would just cry.

I think there is some misunderstanding here. The compatibility was
broken only for subscriptions messages. The subscriptions messages are
not sent between tipc clients (or maybe they are, but that's not how
tipc developers normally use them AFAIK). You send a subscription
message to your host tipc stack and the stack reply you with event
notifications. Even when they are message sent through a socket, they
are used as an API.

So, this has nothing to do with payload data transmitted by applications
using tipc. We are talking about the tipc API, which is "masked" into
a socket.

Here is a small example (~150 SLOC with comments). Using TIPC 2.0 API:
http://tipc.cslab.ericsson.net/cgi-bin/gitweb.cgi?p=people/allan/tipcutils.git;a=blob;h=efdfa3802e51d9a2a9091b3d97625de9e686b72e;hb=tipcutils2.0;f=demos/topology_subscr_demo/client_tipc.c

Using the "old" TIPC 1.6 API:
http://tipc.cslab.ericsson.net/cgi-bin/gitweb.cgi?p=people/allan/tipcutils.git;a=blob;h=ac5dfc5004b482372abb7905c90fe3073fc9165d;hb=15f57f7572898959e0aaa66293895a8255d77021;f=demos/topology_subscr_demo/subscriptions.c

> > ...because it doesn't know if there is the old auto endian
> >  swap thing being done or not being done.
> > 
> > Assuming it is possible to do so in some non-kludgy way,
> > it sounds like we want to be looking into an in-kernel change
> > that ensures the older user space binaries get their
> > functionality restored then?
> > 
> Lets try figure out exactly what data is getting mis-read first.  Maybe we can
> fix it without having to go back to making a sending host figure out a receiving
> hosts byte order.  That would be nice.  Can you describe the problem in more
> detail?

The problem is not between the tipc stacks in different hosts, is
between the tipc stack and the applications using it (well, maybe there
is a problem somewhere else too).

This was a deliberate API change, not a subtle bug...

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
For me to ask a woman out, I've got to get into a mental state like the karate
guys before they break the bricks.
	-- George Constanza
