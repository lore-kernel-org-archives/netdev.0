From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 10:53:52 +0100
Message-ID: <1300701232.2884.12.camel@edumazet-laptop>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
	 <1300699294.10934.63.camel@firesoul.comx.local>
	 <1300700708.2884.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46432 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578Ab1CUJx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 05:53:57 -0400
Received: by wwa36 with SMTP id 36so7232366wwa.1
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 02:53:56 -0700 (PDT)
In-Reply-To: <1300700708.2884.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 mars 2011 =C3=A0 10:45 +0100, Eric Dumazet a =C3=A9crit :
> Le lundi 21 mars 2011 =C3=A0 10:21 +0100, Jesper Dangaard Brouer a =C3=
=A9crit :
> > On Fri, 2011-03-18 at 09:18 -0700, Alexander Duyck wrote:
> > > On 3/18/2011 4:12 AM, Jesper Dangaard Brouer wrote:
> > > > Hi
> > > >
> > > > I'm seeing the LRO disable warnings using kernel 2.6.38:
> > [...]
> > > >
> > > The error doesn't make any sense for igb to be triggering since i=
t=20
> > > doesn't support setting the NETIF_F_LRO flag in the 2.6.38 kernel=
=2E
> > >=20
> > > By any chance are there any ixgbe or other interfaces in the syst=
em?  I=20
> > > would suspect the error to come from a driver that at least conta=
ins the=20
> > > NETIF_F_LRO flag.
> >=20
> > The servers actually also have a four port semi-build in NIC (its a=
 PCIe
> > slot with an extra connector, most likely for controlling the LEDs)=
=2E  I
> > don't use that NIC as it (1) caused kernel panics on 2.6.35, (2) ne=
eds a
> > firmware blob, (3) reading through the driver code (at some point i=
n
> > time) they didn't implement multiqueue support correctly.
> >=20
> > So lets blame that driver ;-)
> >=20
> > lspci-info:
> >  Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10=
-Gigabit Server Adapter (rev 42)
> >=20
> > driver info via ethtool:
> > # ethtool -i eth01
> >  driver: netxen_nic
> >  version: 4.0.75
> >  firmware-version: 4.0.530
> >  bus-info: 0000:06:00.3
> >=20
> > The strange part is that my pre-prod server also have a netxen_nic,=
 but
> > it does not result in a WARN being tricked...=20
> >=20
> > The pre-prod server do have a different firmware version.
> > # ethtool -i eth01
> >  driver: netxen_nic
> >  version: 4.0.75
> >  firmware-version: 4.0.406
> >  bus-info: 0000:06:00.0
> >=20
> > (I have pulled the NIC out of some of the prod server, due to the r=
isk
> > of a kernel panic on the old kernel.  As operations have taken over=
 the
> > deployment process, these NICs are still in.  Guess I'll ask them t=
o
> > blacklist the driver, so they don't see the warn stacktrace, they g=
et so
> > nervous when they see stuff like that ;-))
> >=20
>=20
> Well, this warning can be ignored since these NIC dont receive packet=
s
> to be forwarded in your setup.
>=20
> I would say netxen_nic_set_flags() is buggy : It rejects data if othe=
r
> flag than ETH_FLAG_LRO is set.
>=20
> if (data & ~ETH_FLAG_LRO)
> 	return -EINVAL;
>=20
> Brought by commit ef2519b1dd39940 (netxen: fail when try to setup
> unsupported features) later corrected by commit 97d1935a61b7fe7a65f98=
f
> (Make ethtool_ops::set_flags() return -EINVAL for unsupported flags)
>=20
> Since this drivers asserts NETIF_F_HW_VLAN_TX (mirroring
> ETH_FLAG_TXVLAN), ethtool_op_get_flags() can return more than
> ETH_FLAG_LRO.
>=20
> dev_disable_lro() then calls netxen_nic_set_flags() with ETH_FLAG_TXV=
LAN
> -> -EINVAL, and ETH_FLAG_LRO stay ORed in dev->features -> WARNING
>=20
>=20
>=20
>=20

Couly you please send us the result of "ethtool -k eth01" to make sure
its the problem ?

Make sure your ethtool version includes these bits :
# ethtool -k eth0
Offload parameters for eth0:
=2E..
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off


Thanks



