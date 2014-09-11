From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: FlexCAN driver triggers kernel BUG in BUSOFF restart
Date: Thu, 11 Sep 2014 09:36:29 +0200
Message-ID: <541150FD.7060104@pengutronix.de>
References: <5411205A.4080606@lsirobway.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="PkgubkJPD4hOWJnSvq4fnAKuAk1mswlDw"
To: Keith Lugsden <keith@lsirobway.com.au>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5411205A.4080606@lsirobway.com.au>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PkgubkJPD4hOWJnSvq4fnAKuAk1mswlDw
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/11/2014 06:08 AM, Keith Lugsden wrote:
> I was asked by Freescale to post this kernel BUG to you and your email
> address appears in the kernel documentation, so please accept my
> apologies if you did not wish to see this.

Thanks for the bug report.

> A kernel BUG is triggered during a CAN send operation (kernel version
> 3.15.7, stack trace follows below). A simple program, such as the one
> included in the kernel's CAN documentation, will cause this problem, as=

> will the can-utils programs 'cangen' and 'cansend'.

[...]

> Typical stack trace:
>=20
> BUG: scheduling while atomic: swapper/0/0/0x00000100
> 1 lock held by swapper/0/0:
> #0: (((&priv->restart_timer))){+.-...}, at: [<8002fe60>]
> call_timer_fn+0x0/0xe8
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper/0 Tainted: G W 3.15.7 #5
> Backtrace:
> [<80011ba4>] (dump_backtrace) from [<80011d40>] (show_stack+0x18/0x1c)
> r6:00000000 r5:00000000 r4:00000000 r3:00000000
> [<80011d28>] (show_stack) from [<805de120>] (dump_stack+0x88/0xa4)
> [<805de098>] (dump_stack) from [<805db3ec>] (__schedule_bug+0x64/0x7c)
> r5:80867268 r4:80867268
> [<805db388>] (__schedule_bug) from [<805e09b0>] (__schedule+0x540/0x5f8=
)
> r4:bf7c7b00 r3:00000002
> [<805e0470>] (__schedule) from [<805e0b5c>] (schedule+0x38/0x88)
> r10:8085c000 r9:00000000 r8:00000001 r7:00000000 r6:00004e20 r5:0000000=
0
> r4:00002710
> [<805e0b24>] (schedule) from [<805e03c4>]
> (schedule_hrtimeout_range_clock+0xe0/0x158)
> [<805e02e4>] (schedule_hrtimeout_range_clock) from [<805e0450>]
> (schedule_hrtimeout_range+0x14/0x18)
> r10:808644c4 r8:bf335e00 r7:00000000 r6:c09b8000 r5:c09b8000 r4:bf33580=
0
> [<805e043c>] (schedule_hrtimeout_range) from [<8002fb58>]
> (usleep_range+0x50/0x58)
> [<8002fb08>] (usleep_range) from [<803f2964>]
> (flexcan_chip_start+0x7c/0x440)
> [<803f28e8>] (flexcan_chip_start) from [<803f3994>]
> (flexcan_set_mode+0x28/0x54)

[...]

David Jander already provided a fix for this problem:

8badd65 can: flexcan: avoid calling usleep_range from interrupt context

It will hit mainline soon and then be backported to the stable trees.

Marc

---

=46rom 8badd65e48c90d66587359d5329c2813088c0f50 Mon Sep 17 00:00:00 2001
From: David Jander <david@protonic.nl>
Date: Wed, 27 Aug 2014 12:02:16 +0200
Subject: [PATCH] can: flexcan: avoid calling usleep_range from interrupt
 context

Apparently can_restart() runs from a (timer-) interrupt and can call
flexcan_chip_[en|dis]able(), so avoid using usleep_range()

Signed-off-by: David Jander <david@protonic.nl>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 944aa5d..630c7bf 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -298,7 +298,7 @@ static int flexcan_chip_enable(struct flexcan_priv *p=
riv)
 	flexcan_write(reg, &regs->mcr);
=20
 	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
-		usleep_range(10, 20);
+		udelay(10);
=20
 	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK)
 		return -ETIMEDOUT;
@@ -317,7 +317,7 @@ static int flexcan_chip_disable(struct flexcan_priv *=
priv)
 	flexcan_write(reg, &regs->mcr);
=20
 	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
-		usleep_range(10, 20);
+		udelay(10);
=20
 	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_LPM_ACK))
 		return -ETIMEDOUT;
@@ -336,7 +336,7 @@ static int flexcan_chip_freeze(struct flexcan_priv *p=
riv)
 	flexcan_write(reg, &regs->mcr);
=20
 	while (timeout-- && !(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
-		usleep_range(100, 200);
+		udelay(100);
=20
 	if (!(flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
 		return -ETIMEDOUT;
@@ -355,7 +355,7 @@ static int flexcan_chip_unfreeze(struct flexcan_priv =
*priv)
 	flexcan_write(reg, &regs->mcr);
=20
 	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK))
-		usleep_range(10, 20);
+		udelay(10);
=20
 	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_FRZ_ACK)
 		return -ETIMEDOUT;
@@ -370,7 +370,7 @@ static int flexcan_chip_softreset(struct flexcan_priv=
 *priv)
=20
 	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
 	while (timeout-- && (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST))
-		usleep_range(10, 20);
+		udelay(10);
=20
 	if (flexcan_read(&regs->mcr) & FLEXCAN_MCR_SOFTRST)
 		return -ETIMEDOUT;
--=20
2.1.0
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--PkgubkJPD4hOWJnSvq4fnAKuAk1mswlDw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQRUQAACgkQjTAFq1RaXHMaeACfdZm83F1AibBMuosI0LNqsJ8g
KuQAn0apVxVfqnPlmB2eQoaEu8EgJ3cE
=5NoW
-----END PGP SIGNATURE-----

--PkgubkJPD4hOWJnSvq4fnAKuAk1mswlDw--
