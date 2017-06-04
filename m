From: "Chickles, Derek" <Derek.Chickles@cavium.com>
Subject: RE: [PATCH net-next] liquidio: add support for OVS offload
Date: Sun, 4 Jun 2017 20:43:28 +0000
Message-ID: <MWHPR07MB2943D144D84A2920F4A65FBBF3F50@MWHPR07MB2943.namprd07.prod.outlook.com>
References: <20170527155633.GA2358@felix-thinkpad.cavium.com>
 <20170527.200656.1963846123525565873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Burru, Veerasenareddy" <Veerasenareddy.Burru@cavium.com>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: David Miller <davem@davemloft.net>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0046.outbound.protection.outlook.com ([104.47.37.46]:51479
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751230AbdFDUni (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 16:43:38 -0400
In-Reply-To: <20170527.200656.1963846123525565873.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, May 27, 2017 5:07 PM
> Subject: Re: [PATCH net-next] liquidio: add support for OVS offload
>=20
> From: Felix Manlunas <felix.manlunas@cavium.com>
> Date: Sat, 27 May 2017 08:56:33 -0700
>=20
> > From: VSR Burru <veerasenareddy.burru@cavium.com>
> >
> > Add support for OVS offload.  By default PF driver runs in basic NIC
> > mode as usual.  To run in OVS mode, use the insmod parameter
> "fw_type=3Dovs".
> >
> > For OVS mode, create a management interface for communication with NIC
> > firmware.  This communication channel uses PF0's I/O rings.
> >
> > Bump up driver version to 1.6.0 to match newer firmware.
> >
> > Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> > Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
>=20

Hi David,

We probably should have put in a cover letter before submitting this patch,=
 but we'll try to explain how everything works here. We've also reassessed =
the mechanism for triggering the creating of the management interface, and =
will be submitting a revised patch shortly that triggers creation of this i=
nterface based on a message coming from the firmware at startup, instead of=
 that module parameter check.

Anyway, this patch is really a foundational change for a series of new feat=
ures that depend on having a private ethernet interface into the adapter. I=
t will enable features like OVS, traffic monitoring, remote management of L=
iquidIO and other things that are planned for LiquidIO down the road.

> How does this work?
>=20

LiquidIO can be thought of as a second computer within a NIC form factor. I=
t has a processor complex, various I/Os, and may run a full blown operating=
 system, like Linux. In such a configuration it is natural to have an ether=
net interface from the host operating system so one could communicate with =
the Linux instance running on the card. Things like regular TCP sockets, SS=
H, etc are all possible. That's what this patch specifically enables. Again=
, we're not going to create this interface based on some module parameter, =
but rather the card will tell the host that it needs this interface when it=
 starts.

Our initial versions of the LiquidIO host driver required LiquidIO firmware=
 that provided basic NIC features, as seen by our previous submissions into=
 the driver tree. Now, we're moving to running Linux on the LiquidIO adapte=
r itself.=20

So, in the OVS case, we simply replace the Ethernet Bridge in the "basic NI=
C" implementation with Linux running OVS. Since we have the management inte=
rface available to the host, this OVS implementation can communicate with a=
n external controller residing on the host.

> What in userspace installs the OVS rules onto the card?
>=20

There is no direct host involvement in the LiquidIO OVS configuration. The =
ovs-vswitchd runs on LiquidIO and can communicate with ovsdb-server running=
 on the LiquidIO processor or on the host using the management interface su=
pplied in this patch.

> We do not support direct offload of OVS, as an OVS entity, instead we
> required all vendors to make their OVS offloads visible as packet
> scheduler classifiers and actions.
>=20
> The same rules apply to liquidio.
>=20

We are running OVS as the switching infrastructure on the card instead of a=
 VEB. If someone wants to run OVS in the host they can still do that. We do=
 have plans to add the ndo interfaces for supporting classifiers and filter=
s, so the host could have accelerated OVS when a LiquidIO card is installed=
. However, in the near term, we're focusing on enabling an ethernet interfa=
ce to the Linux instance running on the card, so you can simply connect to =
ovs-switchd running on the card. This also enables a lot of flexibility in =
the types of applications that could be running on the adapter.

> If there is some special set of userspace interfaces that are used to
> comunicate with these different firmwares in some liquidio specific way, =
I
> am going to be very upset.  That is definitely not allowed.
>=20

Our solution does not require any special user or kernel space components o=
n the host. The OVS-based LiquidIO firmware can be configured just like OVS=
 on the host by usual means such as a remote Openflow controller on the net=
work.


> I'm not applying this patch until the above is resolved and at least more
> information is added to this commit log message to explain how this stuff
> works.

Thanks and regards,
Derek
