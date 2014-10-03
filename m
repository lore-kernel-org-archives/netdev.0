From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: HW bridging support using notifiers?
Date: Fri, 3 Oct 2014 09:53:18 +0200
Message-ID: <20141003075318.GA2814@nanopsycho.orion>
References: <542E0089.5050005@gmail.com>
 <A97C2083-CFD9-4238-9C43-97EF43200124@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, stephen@networkplumber.org,
	andy@greyhouse.net, tgraf@suug.ch, nbd@openwrt.org,
	john.r.fastabend@intel.com, edumazet@google.com,
	vyasevic@redhat.com, buytenh@wantstofly.org
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46014 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbaJCHxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 03:53:21 -0400
Received: by mail-wi0-f174.google.com with SMTP id cc10so6355969wib.7
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 00:53:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <A97C2083-CFD9-4238-9C43-97EF43200124@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Oct 03, 2014 at 07:13:35AM CEST, sfeldma@cumulusnetworks.com wro=
te:
>
>On Oct 2, 2014, at 6:48 PM, Florian Fainelli <f.fainelli@gmail.com> wr=
ote:
>
>> Hi all,
>>=20
>> I am taking a look at adding HW bridging support to DSA, in way that=
's
>> usable outside of DSA.
>>=20
>> Lennert's approach in 2008 [1] looks conceptually good to me,as he
>> noted, it uses a bunch of new ndo's which is not only limiting to on=
e
>> ndo implementer per struct net_device, but also is mostly consuming =
the
>> information from the bridge layer, while the ndo is an action
>>=20
>> So here's what I am up to now:
>>=20
>> - use the NETDEV_JOIN notifier to discover when a bridge port is add=
ed
>> - use the NETDEV_LEAVE notifier, still need to verify this does not
>> break netconsole as indicated in net/bridge/br_if.c
>
>I can=E2=80=99t find a NETDEV_LEAVE...is this new?
>
>For this, rocker is using netdev_notifier and watching for NETDEV_CHAN=
GEUPPER.  On CHANGEUPPER, use netdev_master_upper_dev_get(dev) to get m=
aster.  If master and master rtnl_link_ops->kind is =E2=80=9Cbridge=E2=80=
=9D, then dev port is in bridge; otherwise port is not in bridge.  Of c=
ourse, master could be =E2=80=9Copenvswitch=E2=80=9D, if the driver swi=
ngs both ways.

I agree that NETDEV_CHANGEUPPER should be used for this.

>
>Would this approach work for DSA?
>
>> - use the NETDEV_CHANGEINFODATA notifier to notify about STP state c=
hanges
>>=20
>> Now, this raises a bunch of questions:
>>=20
>> - we would need a getter to return the stp state of a given network
>> device when called with NETDEV_CHANGEINFODATA, is that acceptable? T=
his
>> would be the first function exported by the bridge layer to expose
>> internal data
>>=20
>> NB: this also raises the question of the race condition and locking
>> within br_set_stp_state() and when the network devices notifier call=
back
>> runs
>>=20
>> - or do we need a new network device notifier accepting an opaque
>> pointer which could provide us with the data we what, something like
>> this: call_netdevices_notifier_data(NETDEV_CHANGEINFODATA, dev, info=
),
>> where info would be a structure/union telling what's this data about
>>=20
>
>We need STP state change notification for rocker also, so we can insta=
ll/remove STP/ARP filters on port state change.  Netdev_notifier would =
work.  I was also thinking about using Jiri=E2=80=99s ndo_swdev_flow_in=
stall/remove to install/remove the STP filters on the port, rather than=
 using netdev_notifier.  In other words, does the HW bridge driver need=
 to know the STP state or can it be dumb (stateless) and told when to a=
ccept STP BPDUs, or not, using swdev_flow construct:
>
>  dst_mac 01:80:c2:00:00:00 lasp 0x4242 in_port <port ifindex> actions=
 output <br ifindex>
>
>and later when reaching LEARNING state:
>
>  dst_mac ff:ff:ff:ff:ff:ff eth_type ARP in_port <port ifindex> action=
s output <br ifindex>
>
>and finally when reaching FORWARDING state, the learned/static bridge =
fdbs:
>
>  dst_mac <neigh_mac> in_port <br ifindex> actions output <port ifinde=
x>
>
>So driver doesn=E2=80=99t really know what STP is; it=E2=80=99s just i=
nstalls/removes port filter when told to, using the common ndo_swdev_fl=
ow API.  The smarts stay in the bridge driver.
>
>
>> Let me know what you think, thanks!
>>=20
>> [1]: http://patchwork.ozlabs.org/patch/16578/
>> --
>> Florian
>
>
>-scott
>
>
>
