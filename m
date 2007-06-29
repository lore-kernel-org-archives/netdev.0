From: jamal <hadi@cyberus.ca>
Subject: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 07:43:35 -0400
Message-ID: <1183117415.5156.61.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>
	 <46840AF5.4020209@trash.net>
	 <20070628.212032.108743475.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:22956 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759174AbXF2Lnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 07:43:40 -0400
Received: by wx-out-0506.google.com with SMTP id h31so813673wxd
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 04:43:39 -0700 (PDT)
In-Reply-To: <20070628.212032.108743475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ive changed the topic for you friend - otherwise most people wont follow
(as youve said a few times yourself ;->).

On Thu, 2007-28-06 at 21:20 -0700, David Miller wrote:

> Now I get to pose a problem for everyone, prove to me how useful
> this new code is by showing me how it can be used to solve a
> reocurring problem in virtualized network drivers of which I've
> had to code one up recently, see my most recent blog entry at:
> 
> 	http://vger.kernel.org/~davem/cgi-bin/blog.cgi/index.html
> 

nice.

> Anyways the gist of the issue is (and this happens for Sun LDOMS
> networking, lguest, IBM iSeries, etc.) that we have a single
> virtualized network device.  There is a "port" to the control
> node (which switches packets to the real network for the guest)
> and one "port" to each of the other guests.
> 
> Each guest gets a unique MAC address.  There is a queue per-port
> that can fill up.
> 
> What all the drivers like this do right now is stop the queue if
> any of the per-port queues fill up, and that's why my sunvnet
> driver does right now as well.  We can only thus wakeup the
> queue when all of the ports have some space.

Is a netdevice really the correct construct for the host side?
Sounds to me a layer above the netdevice is the way to go. A bridge for
example or L3 routing or even simple tc classify/redirection etc.
I havent used what has become openvz these days in many years (or played
with Erics approach), but if i recall correctly - it used to have a
single netdevice per guest on the host. Thats close to what a basic
qemu/UML has today. In such a case it is something above netdevices
which does the guest selection.
 
> The ports (and thus the queues) are selected by destinationt
> MAC address.  Each port has a remote MAC address, if there
> is an exact match with a port's remote MAC we'd use that port
> and thus that port's queue.  If there is no exact match
> (some other node on the real network, broadcast, multicast,
> etc.) we want to use the control node's port and port queue.
> 

Ok, Dave, isnt that what a bridge does? ;-> Youd need filtering to go
with it (for example to restrict guest0 from getting certain brodcasts
etc) - but we already have that. 

> So the problem to solve is to make a way for drivers to do the queue
> selection before the generic queueing layer starts to try and push
> things to the driver.  Perhaps a classifier in the driver or similar.
>
> The solution to this problem generalizes to the other facility
> we want now, hashing the transmit queue by smp_processor_id()
> or similar.  With that in place we can look at doing the TX locking
> per-queue too as is hinted at by the comments above the per-queue
> structure in the current net-2.6.23 tree.

A major surgery will be needed on the tx path if you want to hash tx
queue to processor id. Our unit construct (today, net-2.6.23) that can
be tied to a cpu is a netdevice. OTOH, if you used a netdevice it should
work as is. But i am possibly missing something in your comments.
What do you have in mind.

> My current work-in-progress sunvnet.c driver is included below so
> we can discuss things concretely with code.
> 
> I'm listening. :-)

And you got words above.

cheers,
jamal


