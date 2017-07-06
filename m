From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Thu, 6 Jul 2017 18:53:42 +0000
Message-ID: <MWHPR12MB1600E8A9A46A5BDF57E8B324C8D50@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628134139.GB12559@lunn.ch>
        <20170628214751.shjgnh2mv7ihgcum@cumulusnetworks.com>,<20170628180008.42059797@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lunn <andrew@lunn.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "vidya.chowdary@gmail.com" <vidya.chowdary@gmail.com>,
        "olson@cumulusnetworks.com" <olson@cumulusnetworks.com>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>,
        "yuval.mintz@qlogic.com" <yuval.mintz@qlogic.com>,
        "odedw@mellanox.com" <odedw@mellanox.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: Jakub Kicinski <kubakici@wp.pl>,
        Dustin Byford <dustin@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0104.outbound.protection.outlook.com ([104.47.34.104]:32016
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751816AbdGFSxv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 14:53:51 -0400
In-Reply-To: <20170628180008.42059797@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Jakub Kicinski <kubakici@wp.pl>
| Sent: Wednesday, June 28, 2017 6:00 PM
| =A0  =20
| On Wed, 28 Jun 2017 14:47:51 -0700, Dustin Byford wrote:
| >=20
| > You're not the first, or the second to ask that question.=A0 I agree it
| > could use clarification.
| >=20
| > I always read auto in this context as automatic rather than autoneg.
| > The best I can come up with is to perhaps fully spell out "automatic" i=
n
| > the documentation and the associated uapi enums.=A0 It's accurate, and
| > hopefully different enough from "autoneg" to hint people away from the
| > IEEE autoneg concept.
|=20
| So perhaps just "default"?=A0 Even saying something like ieee-selected
| doesn't really help, because apparently there are two autonegs defined
| - IEEE one and a "consortium" one...

First, sorry for the extreme delay in responding.  I was at the {25,100}Gb/=
s Ethernet "Plug Fest" all last week and then the holiday weekend added to =
the delay.

As Dustin notes, you're not the first to be confused by the use of the term=
 "auto".  It absolutely means.  It essentially means: "Use standard FEC set=
tings as specified by IEEE 802.3 interpretations of Cable Transceiver Modul=
e parameters."  But this is quite a mouthful.  In this sense, "auto" means =
"automatic".

Other keywords which we bandied about included: standard, default, ieee, ie=
ee802.3, ieee802.3-default, transceiver-default, etc.  As you can see, the =
quest to make the option more obvious lead to increasing verbosity.

I think that in the end, we decided to go with a moderately short keyword w=
ith tons of documentation to make the meaning clear.

By the way, this isn't the end of this problem.  The new QSFP28 and SFP28 P=
ort Types have introduced a problem which no one has ever seen with any pre=
ceding network technology.  With all previous networking technologies, a dr=
iver could look at an adapter Port Type and know what its Port Capabilities=
 were in terms of Speeds, etc. and those Port Capabilities would never chan=
ge.  With the new QSFP28 and SFP28 Port Types, the Physical Port Capabiliti=
es can change based on what Transceiver Modules you plug in.  For instance,=
 with one QSFP28 Transceiver Module you might see {100,50,25}Gb/s and with =
a different one {40,10}Gb/s.  One Transceiver Module might support Reed-Sol=
omon Forward Error Correction and another might also support BaseR/Reed-Sol=
omon.

For the proposed FEC controls, we've tried to cope with this by having this=
 "Automatic IEEE802.3 Transceiver Module-dictated FEC" via the "auto" selec=
tion (where most users will leave it we hope).  This allows the Firmware/Ho=
st Driver to automatically track the FEC needs of the currently plugged in =
Transceiver Module.

However, the first question which pops up is: what happens if a user explic=
itly selects a particular FEC for from the set offered by the current Trans=
ceiver Module, and then swap out Transceiver Modules to one which doesn't s=
upport that FEC?  Does the OS/Driver/Firmware "forget" the user's FEC setti=
ng?  Does it respect it and potentially not get a link established?  Do we =
"temporarily" put the user's FEC setting aside?  Or do we have FEC settings=
 per-Transceiver Module Type?  Each choice has downsides in terms of "expec=
ted behavior" and the complexity of the abstraction model offered to the us=
er.

In our discussions of the above, we decided that we should err in the direc=
tion of the absolutely simplest abstraction model, even when that might res=
ult in a failure to establish a link.  Our feeling was that doing anything =
else would result in endless user confusion.  Basically, if it takes longer=
 than a simple paragraph to explain, you're probably doing the wrong thing.=
  So, we decided that if a user sets up a particular FEC setting, we keep t=
hat regardless of conflict with different Transceiver Modules.  (But flag s=
uch issues in the System Log in order to try to give the user a chance to u=
nderstand what the new cable they plugged in wasn't working.)

As noted above, the "auto" FEC setting solves the problem of automatically =
tracking the FEC needs of whatever Transceiver Module happens to be plugged=
 in.

And now with QSFP28 and SFP28, we have the same issue with possible Speeds =
(and other Link Parameters).  It may well be that we're going to need to ex=
tend this idea into Link Speeds.

Casey=
