From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Thu, 8 Jun 2017 06:33:11 +0000
Message-ID: <BLUPR0701MB200495371E8CD9FDC59748B78DC90@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
 <20170606061610.GA1911@nanopsycho>
 <20170606002105.7a84432f@cakuba.netronome.com>
 <20170606082336.GB1911@nanopsycho>
 <20170606020945.05a9bcc5@cakuba.netronome.com>
 <20170606091757.GC1911@nanopsycho>
 <BLUPR0701MB2004F8E6F28C1181003BEA788DCB0@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <20170606112043.GD1911@nanopsycho>
 <BLUPR0701MB200425BE49D0578371379A138DC80@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <20170608053853.GA2238@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jakub Kicinski <kubakici@wp.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0076.outbound.protection.outlook.com ([104.47.38.76]:33072
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750822AbdFHGdN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 02:33:13 -0400
In-Reply-To: <20170608053853.GA2238@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> >> >> >What were your plans with pre-netdev config?
> >> >> >>
> >> >> >> We need to pass come initial resource division. Generally the
> >> >> >> consensus is to have these options exposed through devlink, let
> >> >> >> the user configure them all and then to have a trigger that
> >> >> >> would cause driver re-orchestration according to the new
> >> >> >> values. The flow would look like
> >> >> >> this:
> >> >> >>
> >> >> >> -driver loads with defaults, inits hw and instantiates netdevs
> >> >> >> -driver exposes config options via devlink -user sets up the
> >> >> >> options -user pushes the "go" trigger -upon the trigger
> >> >> >> command, devlink calls the driver re-init callback -driver
> >> >> >> shuts down the current instances, re-initializes hw,
> >> >> >> re-instantiates the netdevs
> >> >> >>
> >> >> >> Makes sense?
> >> >> >
> >> >> >I like the idea of a "go"/apply/reload trigger and extending devli=
nk.
> >> >> >Do you plan on adding a way to persist the settings?  I'm
> >> >> >concerned NIC users may want to boot into the right mode once
> >> >> >it's set, without reloads and reconfigs upon boot.  Also is there
> >> >> >going to be a way to query the pending/running config?  Sounds
> >> >> >like we may want to expose three value sets - persistent/default,
> >> >> >running and pending/to be applied.
> >> >
> >> >> I don't think it is a good idea to introduce any kind of
> >> >> configuration persistency in HW. I believe that user is the master
> >> >> and he has all needed info. He can store it persistently, but it
> >> >> is up to
> >> him.
> >> >>
> >> >> So basicaly during boot, we need the devlink configuration to
> >> >> happen early on, before the netdevices get configured. udev? Not
> >> >> sure how exactly to do this. Have to ask around :)
> >> >
> >> >Thinking about use cases where we'd want information available at
> >> >probe time, it might have been even better to have it separated from
> >> >the netdevice, e.g., providing clients with node to configure
> >> >(generic?) information on top of their PCI nodes.
> >>
> >> Yuval, devlink is separated from the netdevices....
> >
> >Separate from the netdevices, yes. But I think it's still a networking f=
acility.
> >I.e., would it make sense creating devlink nodes for PCI devices?
>=20
> True that devlink is placed in net/core. But from the very beginning, it =
was
> designed to be multipurpose. So not only for net devices, but for any dev=
ice
> where is is suitable.
>=20
> >
> >Anyway, I don't think there's any *strong* need for what I was asking
> >for; It's simply that I was thinking of qed where there's quite a bit
> >going on during the pci probe, and thought how re-doing it can be avoide=
d.
>=20
> You can (should) register devlink early on way before netdevs.

Given that I can't really register it sooner than the PCI probe,
how would shortly-before or way-before differ?

Assume you have some userspace daemon monitoring devlink and applying
user-provided configuration.
How could it reliably apply the configuration between devlink registration
and netdevice registeration?

The merit of the udev suggestion was that the sync. point was in userspace,
so user could always make sure that devlink rules apply before netdev state=
 changes.
