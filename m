From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: Socket receives packet to multicast group to which it was not
 joined since kernel 3.13.10-1
Date: Wed, 14 May 2014 15:40:10 -0500
Message-ID: <20140514204010.GA5719@sbohrermbp13-local.rgmadvisors.com>
References: <5370F8EB.2070009@oktetlabs.ru>
 <1399915082.7973.27.camel@edumazet-glaptop2.roam.corp.google.com>
 <5371BAE1.2090806@oktetlabs.ru>
 <20140513213641.GA19087@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:63362 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbaENUkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 16:40:20 -0400
Received: by mail-ob0-f181.google.com with SMTP id wm4so119643obc.40
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 13:40:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140513213641.GA19087@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 04:36:41PM -0500, Shawn Bohrer wrote:
> Eric can you (or someone) comment on if I actually broke something
> here?  The example Yurij provided binds to INADDR_ANY and thus will
> receive any packets destined to port 12345.  So for example even with
> ip_early_demux disabled simply running a second instance of the
> mult_recv example on the same host results in the same behavior, e.g.
> 
> ./mult_recv 225.168.2.9 7 >/dev/null 2>&1 &
> ./mult_recv 224.168.2.9 7
> 
> Both programs will receive packets destined to 224.168.2.9 and
> 225.168.2.9.  Specifically this works because of the IP_ADD_MEMBERSHIP
> for 225.168.2.9, which leads to my next question.  When we _don't_ do
> the IP_ADD_MEMBERSHIP for 225.168.2.9 why are they getting delivered
> to the interface in the first place?  Shouldn't igmp be preventing
> this?

Partially answering my own question here about why the 225.168.2.9
packets arrive at the host in the first place without doing an
IP_ADD_MEMBERSHIP.  Essentially the first 9 bits of the IP address do
not map to the MAC-layer multicast address.  Thus only incrementing
the first octect of the IP means they both have the same MAC-layer
multicast address and are both delivered to the interface.  Here is a
fine microsoft article explaining the mapping of IP multicast address
to MAC-layer Multicast.

http://technet.microsoft.com/en-us/library/cc957928.aspx

The Microsoft article mentions that the host may receive these packets
for groups to which it does not belong, but they will be dropped once
the destination IP is determined.  So it seems that I likely did
indeed break things.

> If I did "break" something here it appears to be because with
> ip_early_demux we only call ip_check_mc_rcu() once on the initial
> packet, and subsequent packets destined for that socket simply need to
> pass the __udp_is_mcast_sock() test.  With ip_early_demux disaled we
> call ip_check_mc_rcu() for every packet.

So is the solution to effectively call ip_check_mc_rcu() inside
udp_v4_early_demux()?

--
Shawn
