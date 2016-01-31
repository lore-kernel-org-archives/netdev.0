From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Sun, 31 Jan 2016 16:50:32 +0200
Message-ID: <20160131145032.GA5869@redhat.com>
References: <56ABDA3D.8040100@cumulusnetworks.com>
 <28285.1454103900@famine>
 <56ABDE2A.7010301@cumulusnetworks.com>
 <20160129.225924.1343743091073159760.davem@davemloft.net>
 <56ACA15C.1080403@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jay.vosburgh@canonical.com,
	bjornar.ness@gmail.com, netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com, jiri@resnulli.us,
	virtualization@lists.linux-foundation.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757218AbcAaOui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jan 2016 09:50:38 -0500
Content-Disposition: inline
In-Reply-To: <56ACA15C.1080403@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2016 at 12:41:16PM +0100, Nikolay Aleksandrov wrote:
> On 01/30/2016 07:59 AM, David Miller wrote:
> > From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> > Date: Fri, 29 Jan 2016 22:48:26 +0100
> >=20
> >> On 01/29/2016 10:45 PM, Jay Vosburgh wrote:
> >>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> >>>
> >>>> On 01/25/2016 05:24 PM, Bj=F8rnar Ness wrote:
> >>>>> As subject says, 802.3ad bonding is not working with virtio net=
work model.
> >>>>>
> >>>>> The only errors I see is:
> >>>>>
> >>>>> No 802.3ad response from the link partner for any adapters in t=
he bond.
> >>>>>
> >>>>> Dumping the network traffic shows that no LACP packets are sent=
 from the
> >>>>> host running with virtio driver, changing to for example e1000 =
solves
> >>>>> this problem
> >>>>> with no configuration changes.
> >>>>>
> >>>>> Is this a known problem?
> >>>>>
> >>>> [Including bonding maintainers for comments]
> >>>>
> >>>> Hi,
> >>>> Here's a workaround patch for virtio_net devices that "cheats" t=
he
> >>>> duplex test (which is the actual problem). I've tested this loca=
lly
> >>>> and it works for me.
> >>>> I'd let the others comment on the implementation, there're other=
 signs
> >>>> that can be used to distinguish a virtio_net device so I'm open =
to suggestions.
> >>>> Also feedback if this is at all acceptable would be appreciated.
> >>>
> >>> 	Should virtio instead provide an arbitrary speed and full duplex
> >>> to ethtool, as veth does?
> >>>
> >>> 	Creating a magic whitelist of devices deep inside the 802.3ad
> >>> implementation seems less desirable.
> >>>
> >> TBH, I absolutely agree. In fact here's what we've been doing:
> >> add set_settings which allows the user to set any speed/duplex
> >> and get_settings of course to retrieve that. This is also useful
> >> for testing other stuff that requires speed and duplex, not only
> >> for the bonding case.
> >=20
> > I also agree.  Having a whitelist is just rediculous.
> >=20
> > There should be a default speed/duplex setting for such devices as =
well.
> > We can pick one that will be use universally for these kinds of dev=
ices.
> >=20
> Yes, that's the other thing - the default setting, from a brief grepp=
ing
> I see that veth uses 10Gbps, tun uses 10Mbps and batman-adv uses 10Mb=
ps.
>=20
> If we add a default get_settings that can be used by virtual devices
> in ethtool that returns 10Gbps with the settings set like veth does
> sounds good to me. What do you think ?
>=20
> In fact they all set the same settings (apart from speed) so we can
> consolidate them in a single default setting init function and for th=
e
> ones using different speed do something like:
> __ethtool_init_settings(); <- sets everything like veth would with 10=
Mbps speed
> __ethtool_cmd_speed_set(cmd, SPEED_10000);
> And we're done.
>=20

I think leaving speed alone would be preferable if possible.
=46aking speed might cause strange effects e.g. bonding prefering
virtio over a real device unexpectedly.
Also, wouldn't it break same link speed requirements?
Same applies to duplex really.

We could easily extend virtio with ability to pass
speed/duplex info from host, but that's not always
known to host and there are existing hypervisors,
so we are still left with the question of what to do
when this info is not available.


Is virtio somehow special that we want LACP for it
if duplex state and speed are unknown, but
don't want it for other devices?
If no, let's allow it for all such devices?

-->
bond_3ad: allow LACP when duplex is unknown

Devices would sometimes set speed and duplex as unknown.

It seem reasonable to allow LACP in this case.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
