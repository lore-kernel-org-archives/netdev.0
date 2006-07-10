From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG/PATCH/RFC] bridge: locally generated broadcast
 traffic may block sender
Date: Mon, 10 Jul 2006 09:26:31 -0700
Message-ID: <20060710092631.3f2937c7@dxpl.pdx.osdl.net>
References: <65170.217.5.191.115.1152028122.squirrel@sesamstrasse.dyndns.tv>
	<20060707153648.694f84c2@dxpl.pdx.osdl.net>
	<43150.217.5.191.115.1152350639.squirrel@sesamstrasse.dyndns.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@kernel.org, bridge@lists.osdl.org, Wolfgang Denk <wd@denx.de>
Return-path: <bridge-bounces@lists.osdl.org>
To: "Bernd Kischnick" <kisch@sesamstrasse.dyndns.tv>
In-Reply-To: <43150.217.5.191.115.1152350639.squirrel@sesamstrasse.dyndns.tv>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Sat, 8 Jul 2006 11:23:59 +0200 (CEST)
"Bernd Kischnick" <kisch@sesamstrasse.dyndns.tv> wrote:

> =

> On Sa, 8.07.2006, 00:36, Stephen Hemminger explained:
> =

> > The fix is not acceptable, because it eliminatess the whole sender memo=
ry
> > flow control limitation.
> >
> > The root cause is that the device incorrectly holds onto packets when
> > the carrier is lost. The device should clear it's own queue.
> > What hardware is this?
> >
> =

> That's the built-in Ethernet MAC of the 82xx series Motorola PowerQUICC
> CPUs. The driver is 2.4.32:arch/ppc/cpm2_io/fcc_enet.c, or
> 2.6.17.3:arch/ppc/8260_io/fcc_enet.c, with modifications by
> Wolfgang Denk to support a specific PHY chip.
> =

> Of course I've been examinating the driver first. It's obvious that the
> bridge code experiences much broader testing than the odd driver for
> the odd embedded target. But I didn't see a way to have the driver handle
> this problem correctly.
> =

> Perhaps that's because I couldn't see any relation between the conditions
> of "link down" (as reported on the MII connection) and "carrier lost" (as
> noticed by the MAC hardware) in the driver. If that's normally indeed
> the same thing, as you indicate, then that's the bug in the driver:
> In the 2.4 version, there's a check for "link down" right at the begin
> of the transmit-method fcc_enet_start_xmit():
> =

>         if (!cep->link) {
>                 /* Link is down or autonegotiation is in progress. */
>                 return 1;
>         }

The driver should call netif_carrier_off() when it detects the link is down.
When netif_carrier_off() is called it notifies the bridge layer that the li=
nk
is gone, so the port is marked as disabled, and no packets get sent on that=
 link.


When the link is reconnected, netif_carrier_on() should be called.

> This causes the transmit queue to fill up during link-down.
> This check is suspiciously absent from the 2.6 version of the driver.
> =

> Without the check in the transmit method, there's no reference to the
> link-down condition in either transmit or interrupt function - but to
> carrier-lost instead.

The device driver should also call netif_stop_queue when carrier is lost.
That prevents packets from being queued to the transmit ring.

> =

> I now understand that the correct way to handle link-down would be to
> still insert the incoming packets into the transmit ring of the hardware,
> which should then mark them as being "not transmitted due to carrier-lost=
",
> and you free those packets in the interrupt function.
> Is that correct?
> =

> Many thanks for your advice!
> I'll try if that cures the problem.
> =

> have a nice weekend,
> - Bernd
> =

> =

> > On Tue, 4 Jul 2006 17:48:42 +0200 (CEST)
> > "Bernd Kischnick" <kisch+linux@sesamstrasse.dyndns.tv> wrote:
> >
> >> Hello Stephen,
> >>
> >> I may have tracked down some unexpected behaviour from a common bridge
> >> setup, and would like to incite expert oppinion on my observations.
> >> The issue relates to both 2.6 and 2.4 kernel series bridging code,
> >> and as far as I can see might have been present in all releases
> >> hitherto.
> >>
> >> Consider this setup:
> >> - two ethernet devices in a simple bridge configuration
> >> - bridge-interface configured for IPv4
> >> - local application multicasting heavy UDP traffic down the bridge
> >> - one of the ethernet links goes down (=3D> disconnect cable).
> >>
> >> I would expect that IP-multicast/Ethernet-broadcast traffic is simply
> >> sent
> >> out of all the bridged interfaces still available and link-up.
> >>
> >> Instead we observe that the result --- rather surprisingly --- depends
> >> on
> >> WHICH of the ethernet links is down.
> >>
> >> One of the two ports doesn't cause troubles: the traffic flows out from
> >> that port which stays up, and the application doesn't mind.
> >>
> >> But if you disconnect the OTHER link, then SOME traffic is still sent
> >> out of
> >> the port that stays up, but then the sending application is blocked in
> >> the
> >> sendto() call. Consequentially, the network traffic then ceases, even
> >> though one of the interfaces is still up and available.
> >> When the link comes up again, everything continues as normal.
> >>
> >> You can create a testbed like this:
> >>
> >> # build the bridge
> >> ifconfig eth0 0.0.0.0 up
> >> ifconfig eth1 0.0.0.0 up
> >> brctl addbr br0
> >> brctl addif br0 eth0
> >> brctl addif br0 eth1
> >> # brctl stp br0 on/off doesn't matter
> >>
> >> # configure bridge interface
> >> ifconfig br0 10.20.30.40 up
> >> route add -net 224.0.0.0 netmask 240.0.0.0 dev br0
> >>
> >> # try to send a fixed amount of multicast UDP traffic
> >> nbytes=3D`cat /proc/sys/net/wmem_max`
> >> nbytes=3D$(( $nbytes * 2 ))
> >> dd if=3D/dev/zero bs=3D$nbytes count=3D1 | nc -nuvw1 224.0.0.123 1234
> >>
> >> # arguments to nc:
> >> # -w1 "wait 1sec" causes nc to exit after sending the _complete_ amount
> >> # -n no names, -v verbose, -u UDP to multicast 224.0.0.123 port 1234
> >>
> >>
> >> If both links are connected, the dd|nc-test completes.
> >> If eth1 link is disconnected, the dd|nc-test completes, too.
> >> If eth0 link is disconnected: dd|nc will block.
> >> If unicast UDP is used: no problems, regardless of link state.
> >>
> >> Mind that it's the FIRST bridge interface that stands out.
> >> If you /exchange/ the order of the interfaces when adding them to the
> >> bridge, then eth1 will show the awkward behaviour ---
> >> again the FIRST bridge interface.
> >>
> >>
> >> Why does the application block?
> >>
> >> ifconfig br0, ifconfig eth1, or a tcpdump on the other and of the eth1
> >> link will show that an amount of roundabout sys.net.wmem_max has been
> >> sent.
> >>
> >> cat /proc/net/udp shows that an EQUAL amount of bytes as has already
> >> been
> >> sent out is STILL queued on behalf of the socket openened by nc.
> >> It will be sent as soon as the link goes up again, and the application
> >> will promptly unblock and finish.
> >>
> >> The tx_queue indication for the sending socket is the clue.
> >> The packets (or rather sk_buffs) generated through the socket are
> >> accredited
> >> to the socket's wmem_alloc memory quota. Because one link is down,
> >> sk_buffs will be queued on the transmit queue of one interface.
> >> While they are queued, they won't be freed, causing the socket to run
> >> out
> >> of its wmem_alloc quota, because they are still associated to the
> >> socket.
> >>
> >>
> >> Why the first bridge interface only?
> >>
> >> Obviously the bridge has to copy outgoing packets to distribute them to
> >> its ports. Regard the copy loop br_flood() in br_forward.c.
> >> It has two modes of operation, selected by a "clone" flag.
> >> For distributing locally generated traffic, br_flood() is called in the
> >> mode "clone=3D0". This mode works like this:
> >>
> >> /* deliver this: */
> >> sk_buff* skb;
> >>
> >> prev_port=3DNULL;
> >> port=3Dtail of bridge port list;
> >> while (port) {
> >>     if (prev_port !=3D NULL) {
> >>           deliver (prev_port, skb_clone (skb));
> >>     }
> >>     prev_port =3D port;
> >>     port =3D next bridge port in list;
> >> }
> >> if (prev_port) {
> >>     deliver (prev_port, skb);
> >>     return;
> >> }
> >> kfree_skb (skb);
> >>
> >>
> >> This results in clones of the original sk_buff being send through all
> >> bridge ports except for the last in list traversal. This port
> >> receives the original sk_buff which was generated through the
> >> application's
> >> socket. The "last in list traversal" happens to be the first port added
> >> to the bridge.
> >>
> >> This means that the bridge port which shows link-down peculiarities is
> >> also the one which receives the original sk_buff. All ports that recei=
ve
> >> clones of the original sk_buff work as expected.
> >>
> >> This observation is consistent with the way skb_clone() works:
> >> the clones don't share the "sock" and "destructor" attributes of the
> >> original. This means that the clones are not credited to the originati=
ng
> >> socket, whereas the originals are.
> >>
> >> When the original sk_buffs are to be delivered across a link that's
> >> down,
> >> they will be queued on the transmit queue of physical device instead,
> >> and not be freed. Therefore the originating socket runs out of
> >> wmem_alloc
> >> quota and blocks the application.
> >>
> >> It's perhaps not surprising that this behaviour has gone unnoticed so
> >> far,
> >> because it only affects broadcast/multicast traffic, which only consis=
ts
> >> of tiny amounts of transferred volume in the protocols usually found.
> >> And additionally the wmem_alloc is available per socket, not per ether
> >> device, so that different protocols don't run into a cumulative traffic
> >> barrier.
> >>
> >>
> >>
> >> Fix.
> >>
> >> Should we agree that the observed behaviour should indeed be amended,
> >> i propose the following fix:
> >>
> >> in br_device.c, function br_dev_xmit() (or __br_dev_xmit() in 2.4):
> >> skb_orphan() the sk_buff to be delivered before handing it to the clone
> >> loop in br_flood_deliver(), calling br_flood().
> >>
> >> skb_orphan() disassociates the sk_buff from its owning socket and runs
> >> the "destructor" attached to the sk_buff, which restores the wmem_alloc
> >> quota of the sending socket.
> >>
> >> If the wmem_alloc is replenished, the application won't block and keep
> >> sending the broadcast messages to all available bridge ports.
> >> The transmit queue of the link-down port will eventually fill up,
> >> but the same happens currently when the non-first port goes link-down,
> >> without obvious hazards. The sk_buff will be freed as part of the
> >> transmit queue run, just like it is currently.
> >
> > Adding yourself to the credits for a minor patch is not the appropriate
> > protocol.
> =

> oops... I'm sorry.
> Anyway it would have been the most major of my minor patches...
> =

> >
> >> diff -urN a/net/bridge/br_device.c b/net/bridge/br_device.c
> >> --- a/net/bridge/br_device.c    2006-06-30 19:37:38.000000000 +0200
> >> +++ b/net/bridge/br_device.c    2006-07-04 17:26:36.000000000 +0200
> >> @@ -40,12 +40,16 @@
> >>         skb->mac.raw =3D skb->data;
> >>         skb_pull(skb, ETH_HLEN);
> >>
> >> -       if (dest[0] & 1)
> >> +
> >> +       if (dest[0] & 1) {
> >> +               skb_orphan(skb);
> >>                 br_flood_deliver(br, skb, 0);
> >> -       else if ((dst =3D __br_fdb_get(br, dest)) !=3D NULL)
> >> +       } else if ((dst =3D __br_fdb_get(br, dest)) !=3D NULL) {
> >>                 br_deliver(dst->dst, skb);
> >> -       else
> >> +       } else {
> >> +               skb_orphan(skb);
> >>                 br_flood_deliver(br, skb, 0);
> >> +       }
> >>
> >>         return 0;
> >>  }
> >
> =



-- =

Stephen Hemminger <shemminger@osdl.org>
Quis custodiet ipsos custodes?
