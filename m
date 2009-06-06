From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 05 Jun 2009 18:16:13 -0700 (PDT)
Message-ID: <20090605.181613.147549237.davem@davemloft.net>
References: <alpine.DEB.1.10.0906041150590.3204@gentwo.org>
	<20090604.153057.178458221.davem@davemloft.net>
	<alpine.DEB.1.10.0906050959380.23895@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753205AbZFFBQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 21:16:11 -0400
In-Reply-To: <alpine.DEB.1.10.0906050959380.23895@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Fri, 5 Jun 2009 10:18:15 -0400 (EDT)

> ARP is tied to managing small chunks of information about the network
> infrastructure. Buffering the first few and throwing the rest away is
> appropriate there for what the ARP protocol intends to do.
> 
> UDP multicasting can be used for streaming information. And right now the
> IPoIB layer is dropping thousands of packets whenever there was a pause of
> a few minutes or when a new multicast group is used and there is some
> delay that the network need to reestablish the multicast route.
> 
> On IPoIB the app can send without being throttled to the speed supported
> by the hardware in these cases. The faster the cpu we get the more packets
> will be dropped in these bursts. The socket layer has an option to not
> wait using MSG_DONTWAIT but in these cases we are not honoring that the
> flag is not set. We simply drop the packets.
> 
> If UDP multicasting is used for a purpose like ARP then this is
> appropriate but UDP multicasting has a variety of uses. If you want ARP
> style semantics then the buffer size can be limited in such a way that
> only 3 packets are bufferd by setting SO_SNDBUF and using MSG_DONTWAIT.

I can guarentee you that this will break in the future, because
very soon we are going to skb_orphan() (disassosicate the socket
from the SKB and thus detract the socket buffer allocation) right
before we give packets to the device layer.  It kills out TX
performance what we're doing now.

And Rusty has done tests showing that, as far as fairness is
concerned, doing the early skb_orphan() does not create problems
where sockets can "take over" a device keeping other sockets out.

But it will allow non-limiting schemes like your's to consume tons
of memory.  Normally device TX queue lengths keep the systems
collection of active sockets in check, so there is a real limit
under normal operation.   Your multicast-resolution list has no
limits.

It's fundamentally wrong.  You need some limit there.
