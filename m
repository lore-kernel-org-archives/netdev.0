From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: VLAN I/F's and TX queue.
Date: Fri, 7 May 2010 11:29:07 +0200
Message-ID: <OF803EE436.793B95D8-ONC125771C.003295C9-C125771C.00341AFF@transmode.se>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se> <1273222403.2261.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:37345 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755079Ab0EGJ3P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 05:29:15 -0400
In-Reply-To: <1273222403.2261.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/05/07 10:53:23:
>
> Le vendredi 07 mai 2010 =E0 10:04 +0200, Joakim Tjernlund a =E9crit :
> > Joakim Tjernlund/Transmode wrote on 2010/05/03 13:34:28:
> > >
> > > We noted dropped pkgs on our VLAN interfaces and i stated to look
> > > for a cause. Here is a ifconfig example:
> > >
> > > eth0      Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
> > >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> > >           RX packets:8886910 errors:0 dropped:0 overruns:0 frame:=
0
> > >           TX packets:8880219 errors:0 dropped:0 overruns:0 carrie=
r:0
> > >           collisions:0 txqueuelen:100
> > >           RX bytes:1626842951 (1.5 GiB)  TX bytes:1555540810 (1.4=
 GiB)
> > >
> > > eth0.1    Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
> > >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> > >           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:=
0
> > >           TX packets:2161943 errors:0 dropped:98 overruns:0 carri=
er:0
> > >           collisions:0 txqueuelen:0
> > >           RX bytes:2467090557 (2.2 GiB)  TX bytes:2480246455 (2.3=
 GiB)
> > >
> > > eth0.1.1  Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
> > >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> > >           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:=
0
> > >           TX packets:2161943 errors:0 dropped:98 overruns:0 carri=
er:0
> > >           collisions:0 txqueuelen:0
> > >           RX bytes:2458437901 (2.2 GiB)  TX bytes:2471598683 (2.3=
 GiB)
> > >
> > > Here I note that txqueuelen is 0 for eth0.1/eth0.1.1 and 100 for =
eth0 and
> > > that it is only eth0.1 and eth0.1.1 that drops pkgs. It feels as =
if eth0.1
> > > bypasses eth0's tx queue and passes pkgs directly to the HW drive=
r. Is that so?
> > > If so, that feels a bit strange and I am not sure how to best
> > > fix this. Any ides?
> > >
> > > Using kernel 2.6.33
> >
> > So I did some more testing
> > two nodes A and B connected over a slow link.
> > Create two VLAN's as above and start pinging from A to B
> > with pkg size 9600, start a few(4-10) parallel ping processes.
> >
> > Now I see dropped packages on B, the receiver of pings, and no
> > pkg loss on A.
> >
>
> dropped on RX path or TX path ?

On TX path(see the ifconfig listing above)

>
> > 1) since the link is symmetrical, why do I only see pkg loss
> >    at B?
> >
> > 2) pkg loss in B only manifests on the VLAN's interfaces and
> >    always in pair as if one lost pkg is counted twice?
> >
>
> Congestion notifications can be stacked since commit cbbef5e183079
> (vlan/macvlan: propagate transmission state to upper layers)

I see.

>
> > 3) I would expect lost pkgs to be accounted on eth0 instead of
> >    the VLAN interface(s) since that is where the pkg is lost, why
> >    isn't it so?
>
> You try to send packets on eth0.XXX, some are dropped, and accounted =
for
> on eth0.XXX stats. What is wrong with this ?

In this case one lost pkg is accounted for twice, once on eth0.1 and
once more on eth0.1.1. Note that eth0.1.1 is stacked on
top of eth0.1

I would at least expect eth0 to also account lost pkgs too.
I was confused by the current accounting as I knew that
the underlying HW I/F should be the only I/F that could
drop pkgs.

>
> If you want to avoid this, just add queues to your vlans
>
> ip link add link eth0 eth0.103 txqueuelen 100 type vlan id 103

=46rom memory now, but that didn't help. Still accounts pgks
as described. Why would where to account pkgs be affected by
queue or no queue?

  Jocke

