From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: HW bridging support using notifiers?
Date: Thu, 2 Oct 2014 22:13:35 -0700
Message-ID: <A97C2083-CFD9-4238-9C43-97EF43200124@cumulusnetworks.com>
References: <542E0089.5050005@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	stephen@networkplumber.org, andy@greyhouse.net, tgraf@suug.ch,
	nbd@openwrt.org, john.r.fastabend@intel.com, edumazet@google.com,
	vyasevic@redhat.com, buytenh@wantstofly.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:60803 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaJCFNo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 01:13:44 -0400
In-Reply-To: <542E0089.5050005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 2, 2014, at 6:48 PM, Florian Fainelli <f.fainelli@gmail.com> wro=
te:

> Hi all,
>=20
> I am taking a look at adding HW bridging support to DSA, in way that'=
s
> usable outside of DSA.
>=20
> Lennert's approach in 2008 [1] looks conceptually good to me,as he
> noted, it uses a bunch of new ndo's which is not only limiting to one
> ndo implementer per struct net_device, but also is mostly consuming t=
he
> information from the bridge layer, while the ndo is an action
>=20
> So here's what I am up to now:
>=20
> - use the NETDEV_JOIN notifier to discover when a bridge port is adde=
d
> - use the NETDEV_LEAVE notifier, still need to verify this does not
> break netconsole as indicated in net/bridge/br_if.c

I can=92t find a NETDEV_LEAVE...is this new?

=46or this, rocker is using netdev_notifier and watching for NETDEV_CHA=
NGEUPPER.  On CHANGEUPPER, use netdev_master_upper_dev_get(dev) to get =
master.  If master and master rtnl_link_ops->kind is =93bridge=94, then=
 dev port is in bridge; otherwise port is not in bridge.  Of course, ma=
ster could be =93openvswitch=94, if the driver swings both ways.

Would this approach work for DSA?

> - use the NETDEV_CHANGEINFODATA notifier to notify about STP state ch=
anges
>=20
> Now, this raises a bunch of questions:
>=20
> - we would need a getter to return the stp state of a given network
> device when called with NETDEV_CHANGEINFODATA, is that acceptable? Th=
is
> would be the first function exported by the bridge layer to expose
> internal data
>=20
> NB: this also raises the question of the race condition and locking
> within br_set_stp_state() and when the network devices notifier callb=
ack
> runs
>=20
> - or do we need a new network device notifier accepting an opaque
> pointer which could provide us with the data we what, something like
> this: call_netdevices_notifier_data(NETDEV_CHANGEINFODATA, dev, info)=
,
> where info would be a structure/union telling what's this data about
>=20

We need STP state change notification for rocker also, so we can instal=
l/remove STP/ARP filters on port state change.  Netdev_notifier would w=
ork.  I was also thinking about using Jiri=92s ndo_swdev_flow_install/r=
emove to install/remove the STP filters on the port, rather than using =
netdev_notifier.  In other words, does the HW bridge driver need to kno=
w the STP state or can it be dumb (stateless) and told when to accept S=
TP BPDUs, or not, using swdev_flow construct:

  dst_mac 01:80:c2:00:00:00 lasp 0x4242 in_port <port ifindex> actions =
output <br ifindex>

and later when reaching LEARNING state:

  dst_mac ff:ff:ff:ff:ff:ff eth_type ARP in_port <port ifindex> actions=
 output <br ifindex>

and finally when reaching FORWARDING state, the learned/static bridge f=
dbs:

  dst_mac <neigh_mac> in_port <br ifindex> actions output <port ifindex=
>

So driver doesn=92t really know what STP is; it=92s just installs/remov=
es port filter when told to, using the common ndo_swdev_flow API.  The =
smarts stay in the bridge driver.


> Let me know what you think, thanks!
>=20
> [1]: http://patchwork.ozlabs.org/patch/16578/
> --
> Florian


-scott
