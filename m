From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN egress performance
Date: Mon, 08 Feb 2010 14:24:32 +0100
Message-ID: <1265635472.3048.6.camel@edumazet-laptop>
References: <87wrynrk37.fsf@isengard.friendlyfire.se>
	 <4B700DF5.1080406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mattias =?ISO-8859-1?Q?R=F6nnblom?= <hofors@lysator.liu.se>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:36237 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab0BHNYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 08:24:36 -0500
Received: by bwz23 with SMTP id 23so1085482bwz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 05:24:35 -0800 (PST)
In-Reply-To: <4B700DF5.1080406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:13 +0100, Patrick McHardy a =C3=
=A9crit :
> Mattias R=C3=B6nnblom wrote:
> > Hi.
> >=20
> > I'm running Linux on PC w/ a Core i7 CPU and two Intel 82598 NICs, =
and
> > I see some anomalies when it comes to egress VLAN performance. I
> > thought maybe someone on this list was interested in my results.
> >=20
> > I'm running the stock Ubuntu 2.6.31 kernel, but with a newer ixgbe
> > driver (2.0.44.14).
> >=20
> > The benchmark is IP forwarding with unidirectional UDP flows @ 64 b=
yte
> > packets, and I get:
> >=20
> > Ingress VLAN  Egress VLAN  Packet Rate    CPU utilization (all core=
s)
> > No            No           5.0 Mpacket/s  ~70%
> > Yes           No           5.0 Mpacket/s  ~75%
> > No            Yes          1.4 Mpacket/s  ~26%
> > Yes           Yes          1.3 Mpacket/s  ~26%
> >=20
> > "VLAN" here mean I've put a VLAN device on top of the real ixgbe
> > device.
> >=20
> > As you can see, if the egress i/f is a VLAN i/f, the performance is
> > reduced to less than a third. And in the case of egress VLAN, the
> > systems basically only uses one HW thread (with a softirqd process
> > taking up all the time).
> >=20
> > Enabling lockdep, it looks like execution is serialized to a large
> > extent by contention around the "vlan_netdev_xmit_lock_key" lock.
> >=20
> > I call this anomaly because I was surprised to see it (as oppose to
> > other performance degradations/scalability issues in the area of
> > multicore and IP traffic handling performance).
>=20
> 2.6.32 contains VLAN multiqueue support and should scale better.

Yes, patches were added in September 2009, 2.6.32 should be OK.

commit 2f8bc32b7a08502a79e0ccec8697000f2977f2fd
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Sep 3 02:19:58 2009 -0700

    vlan: enable multiqueue xmits
   =20
    vlan_dev_hard_start_xmit() & vlan_dev_hwaccel_hard_start_xmit()
    select txqueue number 0, instead of using index provided by
    skb_get_queue_mapping().
   =20
    This is not correct after commit 2e59af3dcbdf11635c03f
    [vlan: multiqueue vlan device] because
    txq->tx_packets  & txq->tx_bytes changes are performed on
    a single location, and not the right locking.
   =20
    Fix is to take the appropriate struct netdev_queue pointer
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 2e59af3dcbdf11635c03f22bfc9706744465d589
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Sep 2 18:03:00 2009 -0700

    vlan: multiqueue vlan device
   =20
    vlan devices are currently not multi-queue capable.
   =20
    We can do that with a new rtnl_link_ops method,
    get_tx_queues(), called from rtnl_create_link()
   =20
    This new method gets num_tx_queues/real_num_tx_queues
    from real device.
   =20
    register_vlan_device() is also handled.
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>



