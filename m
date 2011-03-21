From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 10:45:08 +0100
Message-ID: <1300700708.2884.10.camel@edumazet-laptop>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
	 <1300699294.10934.63.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab1CUJpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 05:45:13 -0400
Received: by wya21 with SMTP id 21so5580966wya.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 02:45:12 -0700 (PDT)
In-Reply-To: <1300699294.10934.63.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 mars 2011 =C3=A0 10:21 +0100, Jesper Dangaard Brouer a =C3=A9=
crit :
> On Fri, 2011-03-18 at 09:18 -0700, Alexander Duyck wrote:
> > On 3/18/2011 4:12 AM, Jesper Dangaard Brouer wrote:
> > > Hi
> > >
> > > I'm seeing the LRO disable warnings using kernel 2.6.38:
> [...]
> > >
> > The error doesn't make any sense for igb to be triggering since it=20
> > doesn't support setting the NETIF_F_LRO flag in the 2.6.38 kernel.
> >=20
> > By any chance are there any ixgbe or other interfaces in the system=
?  I=20
> > would suspect the error to come from a driver that at least contain=
s the=20
> > NETIF_F_LRO flag.
>=20
> The servers actually also have a four port semi-build in NIC (its a P=
CIe
> slot with an extra connector, most likely for controlling the LEDs). =
 I
> don't use that NIC as it (1) caused kernel panics on 2.6.35, (2) need=
s a
> firmware blob, (3) reading through the driver code (at some point in
> time) they didn't implement multiqueue support correctly.
>=20
> So lets blame that driver ;-)
>=20
> lspci-info:
>  Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-G=
igabit Server Adapter (rev 42)
>=20
> driver info via ethtool:
> # ethtool -i eth01
>  driver: netxen_nic
>  version: 4.0.75
>  firmware-version: 4.0.530
>  bus-info: 0000:06:00.3
>=20
> The strange part is that my pre-prod server also have a netxen_nic, b=
ut
> it does not result in a WARN being tricked...=20
>=20
> The pre-prod server do have a different firmware version.
> # ethtool -i eth01
>  driver: netxen_nic
>  version: 4.0.75
>  firmware-version: 4.0.406
>  bus-info: 0000:06:00.0
>=20
> (I have pulled the NIC out of some of the prod server, due to the ris=
k
> of a kernel panic on the old kernel.  As operations have taken over t=
he
> deployment process, these NICs are still in.  Guess I'll ask them to
> blacklist the driver, so they don't see the warn stacktrace, they get=
 so
> nervous when they see stuff like that ;-))
>=20

Well, this warning can be ignored since these NIC dont receive packets
to be forwarded in your setup.

I would say netxen_nic_set_flags() is buggy : It rejects data if other
flag than ETH_FLAG_LRO is set.

if (data & ~ETH_FLAG_LRO)
	return -EINVAL;

Brought by commit ef2519b1dd39940 (netxen: fail when try to setup
unsupported features) later corrected by commit 97d1935a61b7fe7a65f98f
(Make ethtool_ops::set_flags() return -EINVAL for unsupported flags)

Since this drivers asserts NETIF_F_HW_VLAN_TX (mirroring
ETH_FLAG_TXVLAN), ethtool_op_get_flags() can return more than
ETH_FLAG_LRO.

dev_disable_lro() then calls netxen_nic_set_flags() with ETH_FLAG_TXVLA=
N
-> -EINVAL, and ETH_FLAG_LRO stay ORed in dev->features -> WARNING





