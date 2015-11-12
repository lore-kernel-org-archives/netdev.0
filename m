From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Thu, 12 Nov 2015 17:19:39 +0100
Message-ID: <5644BC1B.1000109@free.fr>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
 <564241BF.4020700@free.fr> <yw1xbnb1r70r.fsf@unicorn.mansr.com>
 <5644953C.8000800@free.fr> <yw1xfv0bmhz3.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <festevam@gmail.com>
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xfv0bmhz3.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ CCing a few knowledgeable people ]

Despite the subject, this is about an Atheros 8035 PHY :-)

On 12/11/2015 15:04, M=E5ns Rullg=E5rd wrote:

> Mason wrote:
>=20
>> BTW, you're not using the PHY IRQ, right? I think I remember you say=
ing
>> it didn't work reliably?
>=20
> It doesn't seem to be wired up on any of my boards, or there's some
> magic required to activate it that I'm unaware of.

Weird. The board schematics for the 1172 show Tango ETH0_MDINT# pin
properly connected to AR8035 INT pin (pin 20).

<Thinking out loud>

http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf

INT pin 20
I/O, D, PD
Interrupt Signal to System; default OD-gate, needs an external
10Kohm pull-up, active low; can be configured to I/O by register,
active high.


4.1.17 Interrupt Enable
Offset: 0x12
Mode: Read/Write
Hardware Reset: 0


Strange... it looks like AT803X_INER and AT803X_INTR_ENABLE refer to
the same "Interrupt Enable" register?

In fact, AT803X_INER_INIT =3D=3D 0xec00 makes sense for register 0x12:
link success/fail, speed/duplex changed, autoneg error

Looks like at803x_config_intr() is used for 8031, but not for 8035...

Relevant commit:
77a9939426f7a "phy/at8031: enable at8031 to work on interrupt mode"

If I add .config_intr and .ack_interrupt to the 8035 struct, then I get
(also added some traces)

[    0.883517] *** at803x_config_intr: ENABLE
[    1.576108] *** at803x_config_intr: DISABLE
[    1.580467] *** at803x_config_intr: ENABLE
[    1.584959] *** at803x_config_intr: DISABLE
[    1.589297] *** at803x_config_intr: ENABLE
[    4.321722] *** at803x_config_intr: DISABLE
[    4.326054] *** at803x_config_intr: ENABLE
[    4.330489] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - fl=
ow control rx/tx
[    4.338335] *** at803x_config_intr: ENABLE

(Are all the ENABLE/DISABLE events expected?)

And if I unplug/replug the Ethernet cable,

[   71.903051] *** at803x_config_intr: DISABLE
[   71.907410] *** at803x_config_intr: ENABLE
[   71.912232] nb8800 26000.ethernet eth0: Link is Down
[   71.917309] *** at803x_config_intr: ENABLE
[   78.008972] *** at803x_config_intr: DISABLE
[   78.013375] *** at803x_config_intr: ENABLE
[   78.017797] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - fl=
ow control rx/tx
[   78.025702] *** at803x_config_intr: ENABLE

(Are all the ENABLE/DISABLE events expected there too?)

# cat /proc/interrupts=20
            CPU0       CPU1      =20
 18:        107          0      irq0   1 Level     serial
 54:          5          0      irq0  37 Edge      phy_interrupt
 55:       4953          0      irq0  38 Level     eth0
211:       1147        254       GIC  29 Edge      twd


Questions:

Can't at803x_ack_interrupt() just return phy_read(phydev, AT803X_INSR);
Can at803x_config_intr() be used with the 8035
What about AT803X_INER/AT803X_INTR_ENABLE and AT803X_INSR/AT803X_INTR_S=
TATUS

Regards.
