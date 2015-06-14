From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: fec: Ensure clocks are enabled while using mdio
 bus
Date: Sun, 14 Jun 2015 12:31:36 -0700
Message-ID: <557DD698.3020300@gmail.com>
References: <1434123545-13549-1-git-send-email-andrew@lunn.ch> <BLUPR03MB373E1D5EADCB4753C8D0F15F5B90@BLUPR03MB373.namprd03.prod.outlook.com> <20150614144118.GA7800@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Duan Andy <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34862 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbbFNTbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 15:31:38 -0400
Received: by oihd6 with SMTP id d6so47186546oih.2
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 12:31:38 -0700 (PDT)
In-Reply-To: <20150614144118.GA7800@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/14/15 07:41, Andrew Lunn a =C3=A9crit :
> On Sun, Jun 14, 2015 at 08:07:12AM +0000, Duan Andy wrote:
>> From: Andrew Lunn <andrew@lunn.ch> Sent: Friday, June 12, 2015 11:39=
 PM
>>> To: David Miller
>>> Cc: Duan Fugang-B38611; Cory Tusar; netdev; Andrew Lunn
>>> Subject: [PATCH] net: fec: Ensure clocks are enabled while using md=
io bus
>>>
>>> When a switch is attached to the mdio bus, the mdio bus can be used=
 while
>>> the interface is not open. If the clocks are not enabled, MDIO
>>> reads/writes will simply time out. So enable the clocks before star=
ting a
>>> transaction, and disable them afterwards. The CCF performs referenc=
e
>>> counting so the clocks will only be disabled if there are no other =
users.
>>>
>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>> ---
>>
>> NAK the patch.
>=20
>> i.MX series MDIO bus is a part of ENET controller. If the eth
>> interface is not open, all clocks including MDIO bus clock are not
>> enabled for power saving.

Which is fine, but is an assumption you can only make when your ENET
controller is connected to an Ethernet PHY, with a switch, things get a
little different see below.

>=20
> Where do you see a power saving regression in this code? It is not as
> if i just unconditionally turn the clocks on. As the comment says, at
> the start of an MDIO transaction, the clocks are enabled. At the end
> of a transaction, they are disabled again. If you don't have a switch
> connected, there will be no transactions, hence no change to power
> savings.
>=20
>> In general, if you want to use mdio bus net interface must be
>> running status.
>=20
> This is not true for a number of Ethernet devices. All those currentl=
y
> used with DSA allow MDIO transactions at any time.

Right, the typical sequence looks like this:

- ethernet device is probed and registered first, for power savings
purposes, the probe function might turn off clocks since we do not know
whether the interface will be used at all, so until ndo_open is called,
such clocks can be disabled

- DSA is probed second, and probes the switches using MDIO bus accesses=
,
and if a switch is found, will configure it via MDIO bus reads/writes,
by then, the network interface is guaranteed to be down

- last, you could disable the parent network device, but still issue
MDIO reads/writes towards the switch to collect statistics, make it run
in an unmanaged mode with the CPU interface down/powered off

Since clocks are reference counted, I really do not see much problem
with Andrew's approach here.

If you are running without a switch and just a PHY, you will get an
occasional clock reference count > 1 during MDIO reads/writes, and past
your ndo_close() if the clock reference count is 1, aka still turned on=
,
then that means you are not using the PHY library properly and you have
dangling MDIO accesses.
--=20
=46lorian
