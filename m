From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH v2] of/phylib: Use device tree properties to initialize
 Marvell PHYs.
Date: Fri, 19 Nov 2010 17:02:08 -0600
Message-ID: <AANLkTikuikWgLbW67m1Ov0dt13A=DTSF150aTOs=PybT@mail.gmail.com>
References: <1290204798-28569-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Cyril Chemparathy <cyril@ti.com>,
	Arnaud Patard <arnaud.patard@rtp-net.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290204798-28569-1-git-send-email-ddaney@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 19, 2010 at 4:13 PM, David Daney <ddaney@caviumnetworks.com=
> wrote:
> Some aspects of PHY initialization are board dependent, things like
> indicator LED connections and some clocking modes cannot be determine=
d
> by probing. =A0The dev_flags element of struct phy_device can be used=
 to
> control these things if an appropriate value can be passed from the
> Ethernet driver. =A0We run into problems however if the PHY connectio=
ns
> are specified by the device tree. =A0There is no way for the Ethernet
> driver to know what flags it should pass.
>
> If we are using the device tree, the struct phy_device will be
> populated with the device tree node corresponding to the PHY, and we
> can extract extra configuration information from there.
>
> The next question is what should the format of that information be?
> It is highly device specific, and the device tree representation
> should not be tied to any arbitrary kernel defined constants. =A0A
> straight forward representation is just to specify the exact bits tha=
t
> should be set using the "marvell,reg-init" property:
>
> =A0 =A0 =A0phy5: ethernet-phy@5 {
> =A0 =A0 =A0 =A0reg =3D <5>;
> =A0 =A0 =A0 =A0compatible =3D "marvell,88e1149r";
> =A0 =A0 =A0 =A0marvell,reg-init =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* led[0]:1000, led[1]:100, led[2]:10,=
 led[3]:tx */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<3 0x10 0 0x5777>, /* Reg 3,16 <- 0x57=
77 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* mix %:0, led[0123]:drive low off hi=
Z */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<3 0x11 0 0x00aa>, /* Reg 3,17 <- 0x00=
aa */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* default blink periods. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<3 0x12 0 0x4105>, /* Reg 3,18 <- 0x41=
05 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* led[4]:rx, led[5]:dplx, led[45]:dri=
ve low off hiZ */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<3 0x13 0 0x0a60>; /* Reg 3,19 <- 0x0a=
60 */


My inclination is to shy away from such hard-coded values.  I agreed
with Grant's comment about separating into separate cells, but I think
specification of hard-coded register writes is too rigid.  I think a
better approach would be to specify configuration attributes, like:

marvell,blink-periods =3D <blah>;
marvell,led-config =3D <[drive type] [indicates]>;

=46or one, I always advocate making the DTS human-readable.  For
another, I think that there are a number of configuration sequences
that require read-modify-write, or write-wait-write.  In other words,
I think that there are enough cases where actual software will be
needed, that an attempt to generically specify a register
initialization sequence will be impossible, and leave us with the same
problems to solve later on.  For third...ly... allowing
device-tree-specified register initializations might encourage
developers to put all of their register initializations in the device
tree.  Especially when they realize that the LED initialization for
*their* PHY has to come between two standard initialization steps in
the driver.  Or before.  Or after.

By specifying actual functionality, the driver can work around those
problems, while being aware of the functional goal.  However, I'm
aware that such a path is more difficult, and perhaps just as futile,
as PHY vendors frequently don't want to document what their magic
sequences mean.

Andy
