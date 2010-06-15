From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 10/12] ptp: Added a clock that uses the eTSEC found on the
	MPC85xx.
Date: Tue, 15 Jun 2010 11:20:41 -0600
Message-ID: <AANLkTikFc15j-Qhw9M2CnKLKq58Wi1xD7E2dtVNsVgeA@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<041faf3cb6ecbedf8f3ff2104914f91d2a24fc4d.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38663 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397Ab0FORVD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 13:21:03 -0400
Received: by gye5 with SMTP id 5so3374360gye.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 10:21:02 -0700 (PDT)
In-Reply-To: <041faf3cb6ecbedf8f3ff2104914f91d2a24fc4d.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 10:10 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> The eTSEC includes a PTP clock with quite a few features. This patch =
adds
> support for the basic clock adjustment functions, plus two external t=
ime
> stamps and one alarm.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Hi Richard,

comments below...

> ---
> =A0Documentation/powerpc/dts-bindings/fsl/tsec.txt | =A0 54 +++
> =A0arch/powerpc/boot/dts/mpc8313erdb.dts =A0 =A0 =A0 =A0 =A0 | =A0 13=
 +
> =A0arch/powerpc/boot/dts/p2020ds.dts =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 13 +
> =A0arch/powerpc/boot/dts/p2020rdb.dts =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 13 +
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 =A01 +
> =A0drivers/net/gianfar_ptp.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0518 +++++++++++++++++++++++
> =A0drivers/net/gianfar_ptp_reg.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0113 +++++

Is this header file used by anything other than gianfar_ptp.c?  If
not, then roll the two files together.

> =A0drivers/ptp/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 13 +
> =A08 files changed, 738 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/net/gianfar_ptp.c
> =A0create mode 100644 drivers/net/gianfar_ptp_reg.h
>
> diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Docume=
ntation/powerpc/dts-bindings/fsl/tsec.txt
> index edb7ae1..14577e9 100644
> --- a/Documentation/powerpc/dts-bindings/fsl/tsec.txt
> +++ b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
> @@ -74,3 +74,57 @@ Example:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrupt-parent =3D <&mpic>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy-handle =3D <&phy0>
> =A0 =A0 =A0 =A0};
> +
> +* Gianfar PTP clock nodes
> +
> +General Properties:
> +
> + =A0- compatible =A0 Should be "fsl,etsec-ptp"
> + =A0- reg =A0 =A0 =A0 =A0 =A0Offset and length of the register set f=
or the device
> + =A0- interrupts =A0 There should be at least two interrupts. Some d=
evices
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 have as many as four PTP related in=
terrupts.
> +
> +Clock Properties:
> +
> + =A0- tclk_period =A0Timer reference clock period in nanoseconds.
> + =A0- tmr_prsc =A0 =A0 Prescaler, divides the output clock.
> + =A0- tmr_add =A0 =A0 =A0Frequency compensation value.

Use dash ('-') not underscore ('_') in property names.

> + =A0- cksel =A0 =A0 =A0 =A00=3D external clock, 1=3D eTSEC system cl=
ock, 3=3D RTC clock input.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Currently the driver only supports =
choice "1".

If you encode this value as a string, then it will be friendly for huma=
ns too.

> + =A0- tmr_fiper1 =A0 Fixed interval period pulse generator.
> + =A0- tmr_fiper2 =A0 Fixed interval period pulse generator.

I could use more explication here.  Is this a divider value?
Computers are good at making calculations, and the driver can obtain
the clock frequency supplied to the device.  It may be more useful to
specify here the desired frequency rather than the divider.  Certainly
more human-friendly too.

> +
> + =A0These properties set the operational parameters for the PTP
> + =A0clock. You must choose these carefully for the clock to work rig=
ht.
> + =A0Here is how to figure good values:
> +
> + =A0TimerOsc =A0 =A0 =3D system clock =A0 =A0 =A0 =A0 =A0 =A0 =A0 MH=
z
> + =A0tclk_period =A0=3D desired clock period =A0 =A0 =A0 nanoseconds
> + =A0NominalFreq =A0=3D 1000 / tclk_period =A0 =A0 =A0 =A0 MHz
> + =A0FreqDivRatio =3D TimerOsc / NominalFreq =A0 =A0 (must be greater=
 that 1.0)
> + =A0tmr_add =A0 =A0 =A0=3D ceil(2^32 / FreqDivRatio)
> + =A0OutputClock =A0=3D NominalFreq / tmr_prsc =A0 =A0 MHz
> + =A0PulseWidth =A0 =3D 1 / OutputClock =A0 =A0 =A0 =A0 =A0 =A0micros=
econds
> + =A0FiperFreq1 =A0 =3D desired frequency in Hz
> + =A0FiperDiv1 =A0 =A0=3D 1000000 * OutputClock / FiperFreq1
> + =A0tmr_fiper1 =A0 =3D tmr_prsc * tclk_period * FiperDiv1 - tclk_per=
iod
> +
> + =A0The calculation for tmr_fiper2 is the same as for tmr_fiper1. Th=
e
> + =A0driver expects that tmr_fiper1 will be correctly set to produce =
a 1
> + =A0Pulse Per Second (PPS) signal, since this will be offered to the=
 PPS
> + =A0subsystem to synchronize the Linux clock.
> +
> +Example:
> +
> + =A0 =A0 =A0 ptp_clock@24E00 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,etsec-ptp";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <0x24E00 0xB0>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupts =3D <12 0x8 13 0x8>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D < &ipic >;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tclk_period =3D <10>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_prsc =A0 =A0=3D <100>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_add =A0 =A0 =3D <0x999999A4>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cksel =A0 =A0 =A0 =3D <0x1>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper1 =A0=3D <0x3B9AC9F6>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper2 =A0=3D <0x00018696>;
> + =A0 =A0 =A0 };
> diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boo=
t/dts/mpc8313erdb.dts
> index 183f2aa..0526384 100644
> --- a/arch/powerpc/boot/dts/mpc8313erdb.dts
> +++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
> @@ -208,6 +208,19 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sleep =3D <&pmc 0x0030=
0000>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_clock@24E00 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,ets=
ec-ptp";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <0x24E00 0xB0>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupts =3D <12 0x8 =
13 0x8>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D < =
&ipic >;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tclk_period =3D <10>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_prsc =A0 =A0=3D <10=
0>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_add =A0 =A0 =3D <0x=
999999A4>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cksel =A0 =A0 =A0 =3D <=
0x1>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper1 =A0=3D <0x3B=
9AC9F6>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper2 =A0=3D <0x00=
018696>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enet0: ethernet@24000 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#address-cells =3D <1>=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#size-cells =3D <1>;
> diff --git a/arch/powerpc/boot/dts/p2020ds.dts b/arch/powerpc/boot/dt=
s/p2020ds.dts
> index 1101914..ae5dc4d 100644
> --- a/arch/powerpc/boot/dts/p2020ds.dts
> +++ b/arch/powerpc/boot/dts/p2020ds.dts
> @@ -336,6 +336,19 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_type =3D "ulpi";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_clock@24E00 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,ets=
ec-ptp";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <0x24E00 0xB0>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupts =3D <68 2 69=
 2 70 2>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D < =
&mpic >;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tclk_period =3D <5>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_prsc =3D <200>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_add =3D <0xCCCCCCCD=
>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cksel =3D <1>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper1 =3D <0x3B9AC=
9FB>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper2 =3D <0x00018=
69B>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enet0: ethernet@24000 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#address-cells =3D <1>=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#size-cells =3D <1>;
> diff --git a/arch/powerpc/boot/dts/p2020rdb.dts b/arch/powerpc/boot/d=
ts/p2020rdb.dts
> index da4cb0d..133945c 100644
> --- a/arch/powerpc/boot/dts/p2020rdb.dts
> +++ b/arch/powerpc/boot/dts/p2020rdb.dts
> @@ -396,6 +396,19 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_type =3D "ulpi";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_clock@24E00 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,ets=
ec-ptp";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <0x24E00 0xB0>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupts =3D <68 2 69=
 2 70 2>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D < =
&mpic >;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tclk_period =3D <5>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_prsc =3D <200>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_add =3D <0xCCCCCCCD=
>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cksel =3D <1>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper1 =3D <0x3B9AC=
9FB>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmr_fiper2 =3D <0x00018=
69B>;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enet0: ethernet@24000 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#address-cells =3D <1>=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0#size-cells =3D <1>;
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 0a0512a..389c0d9 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -28,6 +28,7 @@ obj-$(CONFIG_ATL2) +=3D atlx/
> =A0obj-$(CONFIG_ATL1E) +=3D atl1e/
> =A0obj-$(CONFIG_ATL1C) +=3D atl1c/
> =A0obj-$(CONFIG_GIANFAR) +=3D gianfar_driver.o
> +obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) +=3D gianfar_ptp.o
> =A0obj-$(CONFIG_TEHUTI) +=3D tehuti.o
> =A0obj-$(CONFIG_ENIC) +=3D enic/
> =A0obj-$(CONFIG_JME) +=3D jme.o
> diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/gianfar_ptp.c
> new file mode 100644
> index 0000000..0991652
> --- /dev/null
> +++ b/drivers/net/gianfar_ptp.c
> @@ -0,0 +1,518 @@
> +/*
> + * PTP 1588 clock using the eTSEC
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or =
modify
> + * =A0it under the terms of the GNU General Public License as publis=
hed by
> + * =A0the Free Software Foundation; either version 2 of the License,=
 or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful=
,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See th=
e
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public Lice=
nse
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include <linux/device.h>
> +#include <linux/hrtimer.h>
> +#include <linux/init.h>
> +#include <linux/interrupt.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/of.h>
> +#include <linux/of_platform.h>
> +#include <linux/timex.h>
> +#include <linux/io.h>
> +
> +#include <linux/ptp_clock_kernel.h>
> +
> +#include "gianfar_ptp_reg.h"
> +#include "gianfar.h"
> +
> +#define DRIVER =A0 =A0 =A0 =A0 "gianfar_ptp"
> +#define N_ALARM =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01 /* first alarm is u=
sed internally to reset fipers */
> +#define N_EXT_TS =A0 =A0 =A0 2
> +#define REG_SIZE =A0 =A0 =A0 sizeof(struct gianfar_ptp_registers)
> +
> +struct etsects {
> + =A0 =A0 =A0 struct gianfar_ptp_registers *regs;
> + =A0 =A0 =A0 struct ptp_clock *clock;
> + =A0 =A0 =A0 int irq;
> + =A0 =A0 =A0 u64 alarm_interval; /* for periodic alarm */
> + =A0 =A0 =A0 u64 alarm_value;
> + =A0 =A0 =A0 u32 tclk_period; =A0/* nanoseconds */
> + =A0 =A0 =A0 u32 tmr_prsc;
> + =A0 =A0 =A0 u32 tmr_add;
> + =A0 =A0 =A0 u32 cksel;
> + =A0 =A0 =A0 u32 tmr_fiper1;
> + =A0 =A0 =A0 u32 tmr_fiper2;
> +};
> +
> +/* Private globals */
> +static struct etsects the_clock;

Will there ever be multiple instances of this device?

> +DEFINE_SPINLOCK(register_lock);
> +
> +/*
> + * Register access functions
> + */
> +
> +static u64 tmr_cnt_read(struct etsects *etsects)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 lo, hi;
> +
> + =A0 =A0 =A0 lo =3D gfar_read(&etsects->regs->tmr_cnt_l);
> + =A0 =A0 =A0 hi =3D gfar_read(&etsects->regs->tmr_cnt_h);
> + =A0 =A0 =A0 ns =3D ((u64) hi) << 32;
> + =A0 =A0 =A0 ns |=3D lo;
> + =A0 =A0 =A0 return ns;
> +}
> +
> +static void tmr_cnt_write(struct etsects *etsects, u64 ns)
> +{
> + =A0 =A0 =A0 u32 hi =3D ns >> 32;
> + =A0 =A0 =A0 u32 lo =3D ns & 0xffffffff;
> +
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_cnt_l, lo);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_cnt_h, hi);
> +}
> +
> +static void set_alarm(struct etsects *etsects)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 lo, hi;
> +
> + =A0 =A0 =A0 ns =3D tmr_cnt_read(etsects) + 1500000000ULL;
> + =A0 =A0 =A0 ns =3D div_u64(ns, 1000000000UL) * 1000000000ULL;
> + =A0 =A0 =A0 ns -=3D etsects->tclk_period;
> + =A0 =A0 =A0 hi =3D ns >> 32;
> + =A0 =A0 =A0 lo =3D ns & 0xffffffff;
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_alarm1_l, lo);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_alarm1_h, hi);
> +}
> +
> +static void set_fipers(struct etsects *etsects)
> +{
> + =A0 =A0 =A0 u32 tmr_ctrl =3D gfar_read(&etsects->regs->tmr_ctrl);
> +
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_ctrl, =A0 tmr_ctrl & (~T=
E));
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_prsc, =A0 etsects->tmr_p=
rsc);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fip=
er1);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fip=
er2);
> + =A0 =A0 =A0 set_alarm(etsects);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_ctrl, =A0 tmr_ctrl|TE);
> +}
> +
> +/*
> + * Interrupt service routine
> + */
> +
> +static irqreturn_t isr(int irq, void *priv)
> +{
> + =A0 =A0 =A0 struct etsects *etsects =3D priv;
> + =A0 =A0 =A0 struct ptp_clock_event event;
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 ack =3D 0, lo, hi, mask, val;
> +
> + =A0 =A0 =A0 val =3D gfar_read(&etsects->regs->tmr_tevent);
> +
> + =A0 =A0 =A0 if (val & ETS1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ack |=3D ETS1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hi =3D gfar_read(&etsects->regs->tmr_et=
ts1_h);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D gfar_read(&etsects->regs->tmr_et=
ts1_l);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.type =3D PTP_CLOCK_EXTTS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.index =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.timestamp =3D ((u64) hi) << 32;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.timestamp |=3D lo;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_clock_event(etsects->clock, &event)=
;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (val & ETS2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ack |=3D ETS2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hi =3D gfar_read(&etsects->regs->tmr_et=
ts2_h);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D gfar_read(&etsects->regs->tmr_et=
ts2_l);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.type =3D PTP_CLOCK_EXTTS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.index =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.timestamp =3D ((u64) hi) << 32;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.timestamp |=3D lo;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_clock_event(etsects->clock, &event)=
;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (val & ALM2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ack |=3D ALM2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (etsects->alarm_value) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.type =3D PTP_CLOC=
K_ALARM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.index =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 event.timestamp =3D ets=
ects->alarm_value;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_clock_event(etsects=
->clock, &event);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (etsects->alarm_interval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ns =3D etsects->alarm_v=
alue + etsects->alarm_interval;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hi =3D ns >> 32;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D ns & 0xffffffff;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&register_loc=
k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_write(&etsects->re=
gs->tmr_alarm2_l, lo);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_write(&etsects->re=
gs->tmr_alarm2_h, hi);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&register_l=
ock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 etsects->alarm_value =3D=
 ns;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_write(&etsects->re=
gs->tmr_tevent, ALM2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&register_loc=
k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D gfar_read(&ets=
ects->regs->tmr_temask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask &=3D ~ALM2EN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_write(&etsects->re=
gs->tmr_temask, mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&register_l=
ock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 etsects->alarm_value =3D=
 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 etsects->alarm_interval=
 =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (ack) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_tevent, =
ack);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_HANDLED;
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_NONE;
> +}
> +
> +/*
> + * PTP clock operations
> + */
> +
> +static int ptp_gianfar_adjfreq(void *priv, s32 ppb)
> +{
> + =A0 =A0 =A0 u64 adj;
> + =A0 =A0 =A0 u32 diff, tmr_add;
> + =A0 =A0 =A0 int neg_adj =3D 0;
> + =A0 =A0 =A0 struct etsects *etsects =3D priv;
> +
> + =A0 =A0 =A0 if (!ppb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if (ppb < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 neg_adj =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ppb =3D -ppb;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 tmr_add =3D etsects->tmr_add;
> + =A0 =A0 =A0 adj =3D tmr_add;
> + =A0 =A0 =A0 adj *=3D ppb;
> + =A0 =A0 =A0 diff =3D div_u64(adj, 1000000000ULL);
> +
> + =A0 =A0 =A0 tmr_add =3D neg_adj ? tmr_add - diff : tmr_add + diff;
> +
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_add, tmr_add);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_gianfar_adjtime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 s64 delta, now;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct etsects *etsects =3D priv;
> +
> + =A0 =A0 =A0 delta =3D 1000000000LL * ts->tv_sec;
> + =A0 =A0 =A0 delta +=3D ts->tv_nsec;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> +
> + =A0 =A0 =A0 now =3D tmr_cnt_read(etsects);
> + =A0 =A0 =A0 now +=3D delta;
> + =A0 =A0 =A0 tmr_cnt_write(etsects, now);
> +
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 set_fipers(etsects);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_gianfar_gettime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 remainder;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct etsects *etsects =3D priv;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> +
> + =A0 =A0 =A0 ns =3D tmr_cnt_read(etsects);
> +
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 ts->tv_sec =3D div_u64_rem(ns, 1000000000, &remainder);
> + =A0 =A0 =A0 ts->tv_nsec =3D remainder;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_gianfar_settime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct etsects *etsects =3D priv;
> +
> + =A0 =A0 =A0 ns =3D ts->tv_sec * 1000000000ULL;
> + =A0 =A0 =A0 ns +=3D ts->tv_nsec;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> +
> + =A0 =A0 =A0 tmr_cnt_write(etsects, ns);
> + =A0 =A0 =A0 set_fipers(etsects);
> +
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_gianfar_gettimer(void *priv, int index, struct itimer=
spec *ts)
> +{
> + =A0 =A0 =A0 u64 now, ns;
> + =A0 =A0 =A0 u32 remainder;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct etsects *etsects =3D priv;
> +
> + =A0 =A0 =A0 ns =3D etsects->alarm_interval;
> +
> + =A0 =A0 =A0 ts->it_interval.tv_sec =3D div_u64_rem(ns, 1000000000, =
&remainder);
> + =A0 =A0 =A0 ts->it_interval.tv_nsec =3D remainder;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> + =A0 =A0 =A0 now =3D tmr_cnt_read(etsects);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 ns =3D etsects->alarm_value - now;
> +
> + =A0 =A0 =A0 ts->it_value.tv_sec =3D div_u64_rem(ns, 1000000000, &re=
mainder);
> + =A0 =A0 =A0 ts->it_value.tv_nsec =3D remainder;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_gianfar_settimer(void *p, int i, int abs, struct itim=
erspec *ts)
> +{
> + =A0 =A0 =A0 u64 ns;
> + =A0 =A0 =A0 u32 lo, hi, mask;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct etsects *etsects =3D p;
> +
> + =A0 =A0 =A0 ns =3D ts->it_interval.tv_sec * 1000000000ULL;
> + =A0 =A0 =A0 ns +=3D ts->it_interval.tv_nsec;
> +
> + =A0 =A0 =A0 etsects->alarm_interval =3D ns;
> +
> + =A0 =A0 =A0 ns =3D ts->it_value.tv_sec * 1000000000ULL;
> + =A0 =A0 =A0 ns +=3D ts->it_value.tv_nsec;
> +
> + =A0 =A0 =A0 if (!ns) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Cancel the timer. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 etsects->alarm_value =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 etsects->alarm_interval =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!abs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ns +=3D tmr_cnt_read(etsects);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, =
flags);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 etsects->alarm_value =3D ns;
> +
> + =A0 =A0 =A0 hi =3D ns >> 32;
> + =A0 =A0 =A0 lo =3D ns & 0xffffffff;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags);
> +
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_alarm2_l, lo);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_alarm2_h, hi);
> +
> + =A0 =A0 =A0 mask =3D gfar_read(&etsects->regs->tmr_temask);
> + =A0 =A0 =A0 mask |=3D ALM2EN;
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_temask, mask);
> +
> + =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, flags);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_gianfar_enable(void *priv, struct ptp_clock_request *=
rq, int on)
> +{
> + =A0 =A0 =A0 struct etsects *etsects =3D priv;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 u32 bit, mask;
> +
> + =A0 =A0 =A0 switch (rq->type) {
> + =A0 =A0 =A0 case PTP_REQUEST_EXTTS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (rq->index) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 0:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bit =3D ETS1EN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 1:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bit =3D ETS2EN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&register_lock, flags=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (on) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D gfar_read(&ets=
ects->regs->tmr_temask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask |=3D bit;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_write(&etsects->re=
gs->tmr_temask, mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D gfar_read(&ets=
ects->regs->tmr_temask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask &=3D ~bit;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfar_write(&etsects->re=
gs->tmr_temask, mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&register_lock, =
flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return -EOPNOTSUPP;
> +}
> +
> +static struct ptp_clock_info ptp_gianfar_caps =3D {
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "gianfar clock",
> + =A0 =A0 =A0 .max_adj =A0 =A0 =A0 =A0=3D 512000,
> + =A0 =A0 =A0 .n_alarm =A0 =A0 =A0 =A0=3D N_ALARM,
> + =A0 =A0 =A0 .n_ext_ts =A0 =A0 =A0 =3D N_EXT_TS,
> + =A0 =A0 =A0 .n_per_out =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .pps =A0 =A0 =A0 =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .priv =A0 =A0 =A0 =A0 =A0 =3D &the_clock,
> + =A0 =A0 =A0 .adjfreq =A0 =A0 =A0 =A0=3D ptp_gianfar_adjfreq,
> + =A0 =A0 =A0 .adjtime =A0 =A0 =A0 =A0=3D ptp_gianfar_adjtime,
> + =A0 =A0 =A0 .gettime =A0 =A0 =A0 =A0=3D ptp_gianfar_gettime,
> + =A0 =A0 =A0 .settime =A0 =A0 =A0 =A0=3D ptp_gianfar_settime,
> + =A0 =A0 =A0 .gettimer =A0 =A0 =A0 =3D ptp_gianfar_gettimer,
> + =A0 =A0 =A0 .settimer =A0 =A0 =A0 =3D ptp_gianfar_settimer,
> + =A0 =A0 =A0 .enable =A0 =A0 =A0 =A0 =3D ptp_gianfar_enable,
> +};
> +
> +/* OF device tree */
> +
> +static int get_of_u32(struct device_node *node, char *str, u32 *val)
> +{
> + =A0 =A0 =A0 int plen;
> + =A0 =A0 =A0 const u32 *prop =3D of_get_property(node, str, &plen);
> +
> + =A0 =A0 =A0 if (!prop || plen !=3D sizeof(*prop))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 *val =3D *prop;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int gianfar_ptp_probe(struct of_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct=
 of_device_id *match)
> +{
> + =A0 =A0 =A0 u64 addr, size;
> + =A0 =A0 =A0 struct device_node *node =3D dev->dev.of_node;
> + =A0 =A0 =A0 struct etsects *etsects =3D &the_clock;
> + =A0 =A0 =A0 struct timespec now;
> + =A0 =A0 =A0 phys_addr_t reg_addr;
> + =A0 =A0 =A0 unsigned long reg_size;
> + =A0 =A0 =A0 u32 tmr_ctrl;
> +
> + =A0 =A0 =A0 if (get_of_u32(node, "tclk_period", &etsects->tclk_peri=
od) ||
> + =A0 =A0 =A0 =A0 =A0 get_of_u32(node, "tmr_prsc", &etsects->tmr_prsc=
) ||
> + =A0 =A0 =A0 =A0 =A0 get_of_u32(node, "tmr_add", &etsects->tmr_add) =
||
> + =A0 =A0 =A0 =A0 =A0 get_of_u32(node, "cksel", &etsects->cksel) ||
> + =A0 =A0 =A0 =A0 =A0 get_of_u32(node, "tmr_fiper1", &etsects->tmr_fi=
per1) ||
> + =A0 =A0 =A0 =A0 =A0 get_of_u32(node, "tmr_fiper2", &etsects->tmr_fi=
per2)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("device tree node missing requir=
ed elements\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 etsects->irq =3D irq_of_parse_and_map(node, 0);
> +
> + =A0 =A0 =A0 if (etsects->irq =3D=3D NO_IRQ) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("irq not in device tree\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (request_irq(etsects->irq, isr, 0, DRIVER, etsects))=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("request_irq failed\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 addr =3D of_translate_address(node, of_get_address(node=
, 0, &size, NULL));
> + =A0 =A0 =A0 reg_addr =3D addr;
> + =A0 =A0 =A0 reg_size =3D size;
> + =A0 =A0 =A0 if (reg_size < REG_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warning("device tree reg range %lu t=
oo small\n", reg_size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg_size =3D REG_SIZE;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 etsects->regs =3D ioremap(reg_addr, reg_size);
> + =A0 =A0 =A0 if (!etsects->regs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("ioremap ptp registers failed\n"=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }

Consider of_iomap(), it will simplify the code a bit.

> +
> + =A0 =A0 =A0 tmr_ctrl =3D
> + =A0 =A0 =A0 =A0 (etsects->tclk_period & TCLK_PERIOD_MASK) << TCLK_P=
ERIOD_SHIFT |
> + =A0 =A0 =A0 =A0 (etsects->cksel & CKSEL_MASK) << CKSEL_SHIFT;
> +
> + =A0 =A0 =A0 getnstimeofday(&now);
> + =A0 =A0 =A0 ptp_gianfar_settime(etsects, &now);
> +
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_ctrl, =A0 tmr_ctrl);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_add, =A0 =A0etsects->tmr=
_add);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_prsc, =A0 etsects->tmr_p=
rsc);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fip=
er1);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fip=
er2);
> + =A0 =A0 =A0 set_alarm(etsects);
> + =A0 =A0 =A0 gfar_write(&etsects->regs->tmr_ctrl, =A0 tmr_ctrl|FS|RT=
PE|TE);
> +
> + =A0 =A0 =A0 etsects->clock =3D ptp_clock_register(&ptp_gianfar_caps=
);
> +
> + =A0 =A0 =A0 return IS_ERR(etsects->clock) ? PTR_ERR(etsects->clock)=
 : 0;
> +}
> +
> +static int gianfar_ptp_remove(struct of_device *dev)
> +{
> + =A0 =A0 =A0 gfar_write(&the_clock.regs->tmr_temask, 0);
> + =A0 =A0 =A0 gfar_write(&the_clock.regs->tmr_ctrl, =A0 0);
> +
> + =A0 =A0 =A0 ptp_clock_unregister(the_clock.clock);
> +
> + =A0 =A0 =A0 free_irq(the_clock.irq, &the_clock);
> +
> + =A0 =A0 =A0 iounmap(the_clock.regs);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static struct of_device_id match_table[] =3D {
> + =A0 =A0 =A0 { .compatible =3D "fsl,etsec-ptp" },
> + =A0 =A0 =A0 {},
> +};
> +
> +static struct of_platform_driver gianfar_ptp_driver =3D {
> + =A0 =A0 =A0 .driver =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "gianfar_=
ptp",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .of_match_table =3D match_table,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODU=
LE,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 .probe =A0 =A0 =A0 =3D gianfar_ptp_probe,
> + =A0 =A0 =A0 .remove =A0 =A0 =A0=3D gianfar_ptp_remove,
> +};
> +
> +/* module operations */
> +
> +static void __exit ptp_gianfar_exit(void)
> +{
> + =A0 =A0 =A0 of_unregister_platform_driver(&gianfar_ptp_driver);
> +}
> +
> +static int __init ptp_gianfar_init(void)
> +{
> + =A0 =A0 =A0 return of_register_platform_driver(&gianfar_ptp_driver)=
;
> +}
> +
> +module_init(ptp_gianfar_init);

Move ptp_gianfar_exit() definition here so it is immediately before
the module_exit() line.

> +module_exit(ptp_gianfar_exit);
> +
> +MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
> +MODULE_DESCRIPTION("PTP clock using the eTSEC");
> +MODULE_LICENSE("GPL");
> diff --git a/drivers/net/gianfar_ptp_reg.h b/drivers/net/gianfar_ptp_=
reg.h
> new file mode 100644
> index 0000000..95e171f
> --- /dev/null
> +++ b/drivers/net/gianfar_ptp_reg.h
> @@ -0,0 +1,113 @@
> +/* gianfar_ptp_reg.h
> + * Generated by regen.tcl on Thu May 13 01:38:57 PM CEST 2010
> + *
> + * PTP 1588 clock using the gianfar eTSEC
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or =
modify
> + * =A0it under the terms of the GNU General Public License as publis=
hed by
> + * =A0the Free Software Foundation; either version 2 of the License,=
 or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful=
,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See th=
e
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public Lice=
nse
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#ifndef _GIANFAR_PTP_REG_H_
> +#define _GIANFAR_PTP_REG_H_
> +
> +struct gianfar_ptp_registers {
> + =A0 =A0 =A0 u32 tmr_ctrl; =A0 =A0 /* Timer control register */
> + =A0 =A0 =A0 u32 tmr_tevent; =A0 /* Timestamp event register */
> + =A0 =A0 =A0 u32 tmr_temask; =A0 /* Timer event mask register */
> + =A0 =A0 =A0 u32 tmr_pevent; =A0 /* Timestamp event register */
> + =A0 =A0 =A0 u32 tmr_pemask; =A0 /* Timer event mask register */
> + =A0 =A0 =A0 u32 tmr_stat; =A0 =A0 /* Timestamp status register */
> + =A0 =A0 =A0 u32 tmr_cnt_h; =A0 =A0/* Timer counter high register */
> + =A0 =A0 =A0 u32 tmr_cnt_l; =A0 =A0/* Timer counter low register */
> + =A0 =A0 =A0 u32 tmr_add; =A0 =A0 =A0/* Timer drift compensation add=
end register */
> + =A0 =A0 =A0 u32 tmr_acc; =A0 =A0 =A0/* Timer accumulator register *=
/
> + =A0 =A0 =A0 u32 tmr_prsc; =A0 =A0 /* Timer prescale */
> + =A0 =A0 =A0 u8 =A0res1[4];
> + =A0 =A0 =A0 u32 tmroff_h; =A0 =A0 /* Timer offset high */
> + =A0 =A0 =A0 u32 tmroff_l; =A0 =A0 /* Timer offset low */
> + =A0 =A0 =A0 u8 =A0res2[8];
> + =A0 =A0 =A0 u32 tmr_alarm1_h; /* Timer alarm 1 high register */
> + =A0 =A0 =A0 u32 tmr_alarm1_l; /* Timer alarm 1 high register */
> + =A0 =A0 =A0 u32 tmr_alarm2_h; /* Timer alarm 2 high register */
> + =A0 =A0 =A0 u32 tmr_alarm2_l; /* Timer alarm 2 high register */
> + =A0 =A0 =A0 u8 =A0res3[48];
> + =A0 =A0 =A0 u32 tmr_fiper1; =A0 /* Timer fixed period interval */
> + =A0 =A0 =A0 u32 tmr_fiper2; =A0 /* Timer fixed period interval */
> + =A0 =A0 =A0 u32 tmr_fiper3; =A0 /* Timer fixed period interval */
> + =A0 =A0 =A0 u8 =A0res4[20];
> + =A0 =A0 =A0 u32 tmr_etts1_h; =A0/* Timestamp of general purpose ext=
ernal trigger */
> + =A0 =A0 =A0 u32 tmr_etts1_l; =A0/* Timestamp of general purpose ext=
ernal trigger */
> + =A0 =A0 =A0 u32 tmr_etts2_h; =A0/* Timestamp of general purpose ext=
ernal trigger */
> + =A0 =A0 =A0 u32 tmr_etts2_l; =A0/* Timestamp of general purpose ext=
ernal trigger */
> +};
> +
> +/* Bit definitions for the TMR_CTRL register */
> +#define ALM1P =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<31) /* Alarm1 outp=
ut polarity */
> +#define ALM2P =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<30) /* Alarm2 outp=
ut polarity */
> +#define FS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<28) /* FIPER s=
tart indication */
> +#define PP1L =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<27) /* Fiper1 pu=
lse loopback mode enabled. */
> +#define PP2L =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<26) /* Fiper2 pu=
lse loopback mode enabled. */
> +#define TCLK_PERIOD_SHIFT =A0 =A0 (16) /* 1588 timer reference clock=
 period. */
> +#define TCLK_PERIOD_MASK =A0 =A0 =A0(0x3ff)
> +#define RTPE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<15) /* Record Tx=
 Timestamp to PAL Enable. */
> +#define FRD =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<14) /* FIPER Rea=
lignment Disable */
> +#define ESFDP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<11) /* External Tx=
/Rx SFD Polarity. */
> +#define ESFDE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<10) /* External Tx=
/Rx SFD Enable. */
> +#define ETEP2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<9) /* External tri=
gger 2 edge polarity */
> +#define ETEP1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<8) /* External tri=
gger 1 edge polarity */
> +#define COPH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<7) /* Generated =
clock (TSEC_1588_GCLK) output phase. */
> +#define CIPH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<6) /* External o=
scillator input clock phase. */
> +#define TMSR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<5) /* Timer soft=
 reset. When enabled, it resets all the timer registers and state machi=
nes. */
> +#define BYP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<3) /* Bypass dri=
ft compensated clock */
> +#define TE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<2) /* 1588 tim=
er enable. If not enabled, all the timer registers and state machines a=
re disabled. */
> +#define CKSEL_SHIFT =A0 =A0 =A0 =A0 =A0 (0) /* 1588 Timer reference =
clock source select. */
> +#define CKSEL_MASK =A0 =A0 =A0 =A0 =A0 =A0(0x3)
> +
> +/* Bit definitions for the TMR_TEVENT register */
> +#define ETS2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<25) /* External =
trigger 2 timestamp sampled */
> +#define ETS1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<24) /* External =
trigger 1 timestamp sampled */
> +#define ALM2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<17) /* Current t=
ime equaled alarm time register 2 */
> +#define ALM1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<16) /* Current t=
ime equaled alarm time register 1 */
> +#define PP1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<7) /* Indicates =
that a periodic pulse has been generated based on FIPER1 register */
> +#define PP2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<6) /* Indicates =
that a periodic pulse has been generated based on FIPER2 register */
> +#define PP3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<5) /* Indicates =
that a periodic pulse has been generated based on FIPER3 register */
> +
> +/* Bit definitions for the TMR_TEMASK register */
> +#define ETS2EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<25) /* External tr=
igger 2 timestamp sample event enable */
> +#define ETS1EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<24) /* External tr=
igger 1 timestamp sample event enable */
> +#define ALM2EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<17) /* Timer ALM2 =
event enable */
> +#define ALM1EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<16) /* Timer ALM1 =
event enable */
> +#define PP1EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<7) /* Periodic pul=
se event 1 enable */
> +#define PP2EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<6) /* Periodic pul=
se event 2 enable */
> +
> +/* Bit definitions for the TMR_PEVENT register */
> +#define TXP2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<9) /* Indicates =
that a PTP frame has been transmitted and its timestamp is stored in TX=
TS2 register */
> +#define TXP1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<8) /* Indicates =
that a PTP frame has been transmitted and its timestamp is stored in TX=
TS1 register */
> +#define RXP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<0) /* Indicates =
that a PTP frame has been received */
> +
> +/* Bit definitions for the TMR_PEMASK register */
> +#define TXP2EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<9) /* Transmit PTP=
 packet event 2 enable */
> +#define TXP1EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<8) /* Transmit PTP=
 packet event 1 enable */
> +#define RXPEN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1<<0) /* Receive PTP =
packet event enable */
> +
> +/* Bit definitions for the TMR_STAT register */
> +#define STAT_VEC_SHIFT =A0 =A0 =A0 =A0(0) /* Timer general purpose s=
tatus vector */
> +#define STAT_VEC_MASK =A0 =A0 =A0 =A0 (0x3f)
> +
> +/* Bit definitions for the TMR_PRSC register */
> +#define PRSC_OCK_SHIFT =A0 =A0 =A0 =A0(0) /* Output clock division/p=
rescale factor. */
> +#define PRSC_OCK_MASK =A0 =A0 =A0 =A0 (0xffff)
> +
> +#endif
> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> index 9390d44..3b7bd73 100644
> --- a/drivers/ptp/Kconfig
> +++ b/drivers/ptp/Kconfig
> @@ -35,4 +35,17 @@ config PTP_1588_CLOCK_LINUX
> =A0 =A0 =A0 =A0 =A0To compile this driver as a module, choose M here:=
 the module
> =A0 =A0 =A0 =A0 =A0will be called ptp_linux.
>
> +config PTP_1588_CLOCK_GIANFAR
> + =A0 =A0 =A0 tristate "Freescale eTSEC as PTP clock"
> + =A0 =A0 =A0 depends on PTP_1588_CLOCK
> + =A0 =A0 =A0 depends on GIANFAR
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 This driver adds support for using the eTSEC as a P=
TP
> + =A0 =A0 =A0 =A0 clock. This clock is only useful if your PTP progra=
ms are
> + =A0 =A0 =A0 =A0 getting hardware time stamps on the PTP Ethernet pa=
ckets
> + =A0 =A0 =A0 =A0 using the SO_TIMESTAMPING API.
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here: =
the module
> + =A0 =A0 =A0 =A0 will be called gianfar_ptp.
> +
> =A0endmenu
> --
> 1.6.3.3
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
