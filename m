From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] route: add more relaxed option for secure_redirects
Date: Wed, 16 Nov 2011 18:46:12 -0200
Message-ID: <20111116184612.25615c02@asterix.rh>
References: <20111107170517.6acb1f87@asterix.rh>
	<1320710630-28335-1-git-send-email-fbl@redhat.com>
	<20111111.203321.93615255271311412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595Ab1KPUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 15:46:15 -0500
In-Reply-To: <20111111.203321.93615255271311412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Nov 2011 20:33:21 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Flavio Leitner <fbl@redhat.com>
> Date: Mon,  7 Nov 2011 22:03:50 -0200
> 
> > When the host uses a gateway IP address that is actually an alias
> > address, the ICMP redirect message source address can be the
> > gateway's main IP address, so the message is ignored by the host
> > regardless of the secure_redirects setup.
> > 
> > The new value (2) allows that ICMP message to be processed.
> > The possible values are:
> > 
> >  0 - Accept ICMP redirect messages only if its source address is the
> >      previous gateway address.
> >  1 - The same as above. However, if shared_media is FALSE, it has to
> >      be for gateways listed in default gateway list as well.
> >  2 - Accept ICMP redirects messages ignoring the conditions above.
> >  default value is 1.
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> The more I look at this the less I like it.
> 
> Look, if IPVS or whatever is translating addresses and this is what
> causes the problem then this entity can very well translate the damn
> addresses right back in the redirect so it looks legitimate to the
> sender.
> 
I thought about that, see below.

> You can't translate people's addresses, and them let them see that
> intenal remapping in ICMP errors.  The redirect is dropped by the
> sender because it not only looks like crap, it is crap.
> 
> This is fundamentally not the correct way to handle this.
> 

I agree. The problem is that the communication is between the host
and another external host, so it's not with the gateway. Therefore,
the original packet has the saddr of the origin host and the daddr
is an external host.  When the gateway receives that packet, there
is no way to tell which IP address should be used to reply with.

Today Linux picks the primary address of an existing interface.
There is the sysctl icmp_errors_use_inbound_ifaddr to use the
primary address of the interface that _received_ the packet that
caused the icmp error. Yet, it doesn't help if the host used
the alias address (i.e. secondary address) as the gw address.

It may possible to promote the secondary address to be the primary
one in the gateway, but this can't be done if you use more than
just one address in the same subnet as gw for some reason.

Thus, the only option at the sender side would be using iptables
to change the ICMP redirect source address to be the float address,
but that is not working as well. (It isn't passing through -t nat)

fbl
