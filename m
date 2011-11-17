From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] route: add more relaxed option for secure_redirects
Date: Wed, 16 Nov 2011 23:40:42 -0200
Message-ID: <20111116234042.6ad8d723@asterix.rh>
References: <1320710630-28335-1-git-send-email-fbl@redhat.com>
	<20111111.203321.93615255271311412.davem@davemloft.net>
	<20111116184612.25615c02@asterix.rh>
	<20111116.170213.1763930566851730338.davem@davemloft.net>
	<20111116211738.067354c0@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754855Ab1KQBkq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 20:40:46 -0500
In-Reply-To: <20111116211738.067354c0@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2011 21:17:38 -0200
Flavio Leitner <fbl@redhat.com> wrote:

> On Wed, 16 Nov 2011 17:02:13 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Flavio Leitner <fbl@redhat.com>
> > Date: Wed, 16 Nov 2011 18:46:12 -0200
> > 
> > > Thus, the only option at the sender side would be using iptables
> > > to change the ICMP redirect source address to be the float
> > > address, but that is not working as well. (It isn't passing
> > > through -t nat)
> > 
> > If it's going to mangle the packet in one direct, the only option
> > for sane operation is to make the exact reverse transformation in
> > the other direction for ICMP messages.
> > 
> > I'm sorry to be so difficult about this, but this is the only way to
> > handle this problem.  If packet mangling is performed to change the
> > world, that mangling entity has taken on the responsibility to make
> > everything look correct to all entities for the mangled packets
> > and any packets generated in response to such mangled packets.
> >
> 
> I'm sorry, I lost you there. There is no transformation happening in
> any side. The iptables is just a work around to force the outgoing
> ICMP redirect to use the correct source address (secondary or alias). 
> 
> The whole problem is the linux gateway sending ICMP redirects using
> *always* the primary address.
> 

To make sure we are in the same page, this simple setup reproduces
the issue.

IP: 10.0.0.1
gw: 10.0.0.100
+--------+          +-----+ primary: 10.0.0.2
| client |----+-----| GW1 |   alias: 10.0.0.100
+--------+    |     +-----+      gw: 10.0.0.254
           +--+--+
           | GW2 |---> internet
           +-----+
         10.0.0.254

1. Client sends TCP SYN to an internet host using
   GW1 alias address as default gw address

2. Then GW1 sends the ICMP redirect back to client
   using the primary address as source address.

3. GW1 forwards the original packet to GW2

4. client ignores the ICMP redirect because
   client.gw != gw1.primary.

Regards,
fbl
