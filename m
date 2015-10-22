From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Thu, 22 Oct 2015 19:21:56 +0200
Message-ID: <1445534516.240647.417579361.507D42D3@webmail.messagingengine.com>
References: <20151021164613.24650836@griffin>
 <20151021.083214.534622235927401863.davem@davemloft.net>
 <20151021172502.63220dbb@griffin>
 <20151021.085635.1582760365341524949.davem@davemloft.net>
 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
 <5628F81D.1070009@6wind.com> <20151022170100.1e45a8b8@griffin>
 <20151022164558.GH23554@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	thaller@redhat.com
To: Thomas Graf <tgraf@suug.ch>, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:54573 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755280AbbJVRV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:21:57 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 05B982349E
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 13:21:57 -0400 (EDT)
In-Reply-To: <20151022164558.GH23554@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Thu, Oct 22, 2015, at 18:45, Thomas Graf wrote:
> On 10/22/15 at 05:00pm, Jiri Benc wrote:
> > On Thu, 22 Oct 2015 16:52:13 +0200, Nicolas Dichtel wrote:
> > > With the proposed scenario:
> > > 1. create netns 'new_netns'
> > > 2. in root netns, move the interface with ifindex 2 to new_netns
> > > 3. in new_netns, delete the interface with ifindex 2
> > > 4. in new_netns, create an interface - it will get ifindex 2
> > > 
> > > Operation 2 and 4 are done by dev_change_net_namespace() under rtnl_lock().
> > > RTM_DELLINK(root netns) and RTM_NEWLINK(new_netns) are sent by this function.
> > > It means that operation 3 has been done before and that RTM_DELLINK(new_netns)
> > > has been sent before.
> > 
> > Imagine the application trying to configure the interface with ifindex 2
> > after your step 2. It constructs a netlink message and sends it to the
> > kernel; but while doing so, steps 3 and 4 happen. Now the application
> > ends up configuring a different interface than it intended to. After
> > that, it polls the netlink socket and receives the notifications about
> > interface disappearing and a new one appearing.
> > 
> > I don't see any way the user space application can prevent this. There
> > will always be a race between receiving netlink notifications and
> > sending config requests.
> > 
> > I guess Thomas Haller can elaborate more as he ran into this.
> 
> I understand the race but when does it occur? Whoever creates
> the original interface owns it and is responsible for its
> lifecycle. *Iff* for some reason multiple entities manipulate
> the interface, then it's probably a lot safer to just use flock
> or something similar to serialize access entirely in user space.

This only works if all networking configuration programs would
standardize on the same flock. Also, under memory pressure we lose
netlink monitor messages, so we need to deal with timeouts and retries
and manual sync up on the networking configuration, which makes this
scheme a lot harder. For normal socket io, where we specify e.g. ifindex
in sin6_addr, this is not really usable at all.

Bye,
Hannes
