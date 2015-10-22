From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Thu, 22 Oct 2015 17:10:37 +0200
Message-ID: <1445526637.1582313.417456297.3BA80560@webmail.messagingengine.com>
References: <20151021164613.24650836@griffin>
 <20151021.083214.534622235927401863.davem@davemloft.net>
 <20151021172502.63220dbb@griffin>
 <20151021.085635.1582760365341524949.davem@davemloft.net>
 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
 <5628F81D.1070009@6wind.com> <20151022170100.1e45a8b8@griffin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	thaller@redhat.com
To: Jiri Benc <jbenc@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:44694 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752073AbbJVPKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 11:10:37 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 63C9F21059
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 11:10:37 -0400 (EDT)
In-Reply-To: <20151022170100.1e45a8b8@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Oct 22, 2015, at 17:00, Jiri Benc wrote:
> On Thu, 22 Oct 2015 16:52:13 +0200, Nicolas Dichtel wrote:
> > With the proposed scenario:
> > 1. create netns 'new_netns'
> > 2. in root netns, move the interface with ifindex 2 to new_netns
> > 3. in new_netns, delete the interface with ifindex 2
> > 4. in new_netns, create an interface - it will get ifindex 2
> > 
> > Operation 2 and 4 are done by dev_change_net_namespace() under rtnl_lock().
> > RTM_DELLINK(root netns) and RTM_NEWLINK(new_netns) are sent by this function.
> > It means that operation 3 has been done before and that RTM_DELLINK(new_netns)
> > has been sent before.
> 
> Imagine the application trying to configure the interface with ifindex 2
> after your step 2. It constructs a netlink message and sends it to the
> kernel; but while doing so, steps 3 and 4 happen. Now the application
> ends up configuring a different interface than it intended to. After
> that, it polls the netlink socket and receives the notifications about
> interface disappearing and a new one appearing.
> 
> I don't see any way the user space application can prevent this. There
> will always be a race between receiving netlink notifications and
> sending config requests.

ifindexes are not only used with netlink monitor but also normal socket
api, so it would make sense to try to not reassign any ifindex before
the overflow of the net->ifindex as they don't listen for notifications
of interface removals or creations.

Thanks,
Hannes
