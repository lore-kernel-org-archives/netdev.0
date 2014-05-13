From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: Socket receives packet to multicast group to which it was not
 joined since kernel 3.13.10-1
Date: Tue, 13 May 2014 16:36:41 -0500
Message-ID: <20140513213641.GA19087@sbohrermbp13-local.rgmadvisors.com>
References: <5370F8EB.2070009@oktetlabs.ru>
 <1399915082.7973.27.camel@edumazet-glaptop2.roam.corp.google.com>
 <5371BAE1.2090806@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:38592 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbaEMVgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 17:36:53 -0400
Received: by mail-ob0-f182.google.com with SMTP id wn1so1132744obc.13
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 14:36:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5371BAE1.2090806@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 10:25:37AM +0400, Yurij M. Plotnikov wrote:
> On 12/05/14 21:18, Eric Dumazet wrote:
> >On Mon, 2014-05-12 at 20:38 +0400, Yurij M. Plotnikov wrote:
> >>On kernel 3.13.10-1 I see that socket joined to one multicast group
> >>receives packets to another multicast address. That can be reproduced by
> >>the following example:
> >>
> >>1. socket(DGRAM) -> 3
> >>2. bind(3, 0.0.0.0:12345) -> 0
> >>3. setsockopt(3, IP_MULTICAST_IF, {224.168.2.9, 7}) -> 0
> >>// "7" is correct interface index
> >>
> >>4. Send packet from peer host to 224.168.2.9:12345
> >>5. poll({3, POLLIN}) -> 1
> >>6. recv(3) -> <data_length>
> >>
> >>5. Send packet from peer host to 225.168.2.9:12345
> >>// Note that the address is not the same!
> >>6. poll({3, POLLIN}) -> 1
> >>7. recv(3) -> <data_length>
> >>
> >>I checked kernel 3.12.6-2, there is no such problem. I have placed
> >>simple C-program in attachment to reproduce the behaviour. It should be
> >>called:
> >>./mult_recv <mcast_address> <interface index> i.e. in example above:
> >>./mult_recv 224.168.2.9 7
> >
> >I suspect problem came with commit
> >421b3885bf6d56391297844f43fb7154a6396e12
> >("udp: ipv4: Add udp early demux")
> >
> >Is that better if you try :
> >
> >echo 0 >/proc/sys/net/ipv4/ip_early_demux
> >
> Yes, this fixes the problem.

Eric can you (or someone) comment on if I actually broke something
here?  The example Yurij provided binds to INADDR_ANY and thus will
receive any packets destined to port 12345.  So for example even with
ip_early_demux disabled simply running a second instance of the
mult_recv example on the same host results in the same behavior, e.g.

./mult_recv 225.168.2.9 7 >/dev/null 2>&1 &
./mult_recv 224.168.2.9 7

Both programs will receive packets destined to 224.168.2.9 and
225.168.2.9.  Specifically this works because of the IP_ADD_MEMBERSHIP
for 225.168.2.9, which leads to my next question.  When we _don't_ do
the IP_ADD_MEMBERSHIP for 225.168.2.9 why are they getting delivered
to the interface in the first place?  Shouldn't igmp be preventing
this?

If I did "break" something here it appears to be because with
ip_early_demux we only call ip_check_mc_rcu() once on the initial
packet, and subsequent packets destined for that socket simply need to
pass the __udp_is_mcast_sock() test.  With ip_early_demux disaled we
call ip_check_mc_rcu() for every packet.

--
Shawn
