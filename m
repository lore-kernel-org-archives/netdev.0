From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: ping -I eth1 ....
Date: Wed, 17 Nov 2010 11:09:09 +0100
Message-ID: <OF76197EA2.D5EFE8B7-ONC12577DE.0036FE30-C12577DE.0037C54E@transmode.se>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>	 <1288964206.2882.402.camel@edumazet-laptop>
	 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
	 <20101105142510.GA14986@canuck.infradead.org>	 <1288967665.2882.522.camel@edumazet-laptop>
	 <OF6C6C2970.245A64ED-ONC12577D2.00518CF6-C12577D2.00522AAD@transmode.se>
	 <1288969614.2882.590.camel@edumazet-laptop>	 <OFAA7963DE.C3F04675-ONC12577D2.0056F55C-C12577D2.00575EC2@transmode.se>
	 <20101105203150.GA12118@canuck.infradead.org>	 <OF921B3329.67FE598A-ONC12577D3.0033387A-C12577D3.00355AC4@LocalDomain>
	 <OFC0986D69.B0E22D17-ONC12577D6.006B4A38-C12577D6.006B72F9@LocalDomain>
	 <OFDE99BE0E.BC2CFBA0-ONC12577DE.00341E5C-C12577DE.00342E2E@transmode.se> <1289987467.2687.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:46907 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932693Ab0KQKJN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 05:09:13 -0500
In-Reply-To: <1289987467.2687.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/17 10:51:07:
>
> Le mercredi 17 novembre 2010 =E0 10:29 +0100, Joakim Tjernlund a =E9c=
rit :
> > Joakim Tjernlund/Transmode wrote on 2010/11/09 20:33:37:
> > >
> > > Joakim Tjernlund/Transmode wrote on 2010/11/06 10:42:46:
> > > > Thomas Graf <tgr@infradead.org> wrote on 2010/11/05 21:31:50:
> > > > >
> > > > > On Fri, Nov 05, 2010 at 04:54:18PM +0100, Joakim Tjernlund wr=
ote:
> > > > > > Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05 1=
6:06:54:
> > > > > > >
> > > > > > > > Hopefully most of that is legacy or just plain wrong? U=
nless
> > > > > > > > someone can say why only test IFF_UP one should conside=
r changing them.
> > > > > > > >
> > > > > > >
> > > > > > > Most of the places are hot path.
> > > > > > >
> > > > > > > You dont want to replace one test by four tests.
> > > > > > >
> > > > > > > _This_ would be wrong :)
> > > > > >
> > > > > > Wrong is wrong, even if it is in the hot path :)
> > > > > > Perhaps it is time define and internal IFF_OPERATIONAL flag
> > > > > > which is the sum of IFF_UP, IFF_RUNNING etc.? Tht
> > > > > > way you still get one test in the hot path and can abstract
> > > > > > what defines an operational link.
> > > > >
> > > > > You definitely don't want to have your send() call fail simpl=
y because
> > > > > the carrier was off for a few msec or the routing daemon has =
put a link
> > > > > down temporarly. Also, the outgoing interface looked up at ro=
uting
> > > > > decision is not necessarly the interface used for sending in =
the end.
> > > > > The packet may get mangled and rerouted by netfilter or tc on=
 the way.
> > > >
> > > > But do you handle the case when the link is non operational for=
 a long time?
> > > >
> > > > >
> > > > > Personally I'm even ok with the current behaviour of sendto()=
 while the
> > > > > socket is bound to an interface but if we choose to return an=
 error
> > > > > if the interface is down we might as well do so based on the =
operational
> > > > > status.
> >
> > > > Perhaps there is a better way. This all started when pppd hung =
because
> > > > of ping -I <ppp interface>, then someone pulled the cable for t=
he on the link.
> > > >
> > > > This is a strace where we have two ping -I,
> > > > ping -I p1-2-1-2-2 .. and ping -I p1-2-3-2-4 ..
> > > > Notice how pppd hangs for a long time in PPPIOCDETACH
> > > > As far as I can tell this is due to ping -I has claimed the ppp=
 interfaces
> > > > and doesn't noticed that the link is down. Ideally ping should =
receive
> > > > a ENODEV as soon as pppd calls PPPIOCDETACH.
> > > >
> > > >    0.000908 write(0, "Connection terminated.\n", 23) =3D 23
> > > >      0.000481 gettimeofday({1288952770, 566048}, NULL) =3D 0
> > > >      0.001553 ioctl(7, PPPIOCDETACH
> > > > Message from syslogd@Brazil at Fri Nov  5 11:26:20 2010 ...
> > > > Brazil kernel: unregister_netdevice: waiting for p1-2-1-2-2 to =
become free. Usage count =3D 3
> > > > Message from syslogd@Brazil at Fri Nov  5 11:26:20 2010 ...
> > > > Brazil kernel: unregister_netdevice: waiting for p1-2-3-2-4 to =
become free. Usage count =3D 3
> > > > Message from syslogd@Brazil at Fri Nov  5 11:26:51 2010 ...
> > > > Brazil last message repeated 3 times
> > > > , 0xbfbc3398) =3D 0
> > > >     66.559216 connect(9, {sa_family=3DAF_PPPOX, sa_data=3D"\0\0=
\0\0\0\0\0\252\273\314\335\356hd"}, 30) =3D 0
> > > >      0.000693 close(10)                 =3D 0
> > > >      0.000449 close(7)                  =3D 0
> > > >      0.009801 close(9)                  =3D 0
> > >
> > > Any comment on this last strace? It is expected that ping -I shou=
ld
> > > hold pppd hostage?
> > >
> >
> > Ping?
> >
>
> I thought I posted a patch, is there something else ?

yes, I wondered about the above strace and if it is expected that ping =
-I
should hold pppd hostage? Should not ping receive a ENODEV as soon as
pppd detaches an interface?

>
> Could you please test with latest net-next-2.6 and following patch ?

I tested the first patch you sent and that one worked well. I can try
again on 2.6.35( our boards takes a while to move forward)?

>
>
> Thanks
>
> [PATCH net-next-2.6] ipv4: dont create a route if device is down
>
> ip_route_output_slow() should not create a route if device is down, s=
o
> that we report -ENETUNREACH error to users.
>
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Reported-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/route.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 66610ea..3cc4191 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2559,8 +2559,11 @@ static int ip_route_output_slow(struct net *ne=
t, struct rtable **rp,
>           goto out;
>
>        /* RACE: Check return value of inet_select_addr instead. */
> -      if (rcu_dereference(dev_out->ip_ptr) =3D=3D NULL)
> -         goto out;   /* Wrong error code */
> +      if (!(dev_out->flags & IFF_UP) ||
> +          rcu_dereference(dev_out->ip_ptr) =3D=3D NULL) {
> +         err =3D -ENETUNREACH;
> +         goto out;
> +      }
>
>        if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
>            ipv4_is_lbcast(oldflp->fl4_dst)) {
>
>

