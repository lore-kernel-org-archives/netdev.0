From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Sat, 1 Dec 2012 04:18:18 +0000
Message-ID: <1354335498.2640.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
	 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
	 <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com>
	 <CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
	 <50A570D7.3080409@gmail.com>
	 <1353022205.4867.76.camel@deadeye.wl.decadent.org.uk>
	 <CAPN4dA_ymo-Bx+GM+JLLKGHghq+qBYxR0zO7K6H6Nn0pqZsJRg@mail.gmail.com>
	 <1353094719.2743.21.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA9f3y1mDPubqd9s+v5supj3hNvZaWym0_y3EMZd7L6MyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23921 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277Ab2LAESW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:18:22 -0500
In-Reply-To: <CAPN4dA9f3y1mDPubqd9s+v5supj3hNvZaWym0_y3EMZd7L6MyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-11-18 at 22:35 +0100, Aur=C3=A9lien wrote:


> Hi Ben,
>=20
> I've rewritten things according to your remarks.
>=20
> On Fri, Nov 16, 2012 at 8:38 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > This is silly; log10() and <math.h> are part of standard C and -lm =
is
> > standard on Unix.  Just use <math.h> and -lm unconditionally.
>=20
> Ok, I wasn't sure.

This version drops the -lm completely, so it doesn't link.  Maybe you
edited the generated Makefile or Makefile.in?

> > Please merge this with the existing -m option and update the
> > documentation to say that this covers diagnostics where available. =
 You
> > could add a long option alias like --dump-module or --module-info t=
hat
> > covers the two types of information.
>=20
> Done that, the current output of -m has been modified so that
> everything lines up correctly.
> The --module-info option alias has been added.

The option alias should be included in the manual page and in a
(trivial) test case in test-cmdline.c.

[...]
> > Please follow kernel coding style for spacing.  checkpatch.pl will =
show
> > you what should be changed.
>=20
> Ran a checkpatch, and fixed everything that should be fixed.

The indentation is still weird, though:

[...]
> --- /dev/null
> +++ b/sfpdiag.c
[...]
> +struct sff8472_diags {
> +
> +#define MCURR 0
> +#define LWARN 1
> +#define HWARN 2
> +#define LALRM 3
> +#define HALRM 4
> +
> +       /* [5] tables are current, low/high warn, low/high alarm */
> +       __u8 supports_dom;      /* Supports DOM */
> +       __u8 supports_alarms;   /* Supports alarm/warning thold */
> +       __u8 calibrated_ext;    /* Is externally calibrated */
> +       __u16 bias_cur[5];              /* Measured bias current in 2=
uA units */
> +       __u16 tx_power[5];              /* Measured TX Power in 0.1uW=
 units */
> +       __u16 rx_power[5];              /* Measured RX Power */

These comments should be lined up vertically.

[...]
> +/* Converts to a float from a big-endian 4-byte source buffer. */
> +static float befloattoh(const __u32 *source)
> +{
> +       union {
> +               __u32 src;
> +               float dst;
> +       } converter;
> +
> +       converter.src =3D be32toh(*source);

be32toh() is non-standard and was apparently added to glibc relatively
recently (version 2.9).  Therefore please use the equivalent ntohl()
instead.

[...]
> +static void sff8472_parse_eeprom(const __u8 *id, struct sff8472_diag=
s *sd)
> +{
> +       sd->supports_dom =3D id[SFF_A0_DOM] & SFF_A0_DOM_IMPL;
> +       sd->supports_alarms =3D id[SFF_A0_OPTIONS] & SFF_A0_OPTIONS_A=
W;
> +       sd->calibrated_ext =3D id[SFF_A0_DOM] & SFF_A0_DOM_EXTCAL;
> +       sd->rx_power_type =3D id[SFF_A0_DOM] & SFF_A0_DOM_PWRT;
> +
> +       sff8472_dom_parse(id, sd);
> +
> +       /*
> +        * If the SFP is externally calibrated, we need to read calib=
ration data
> +        * and compensate the already stored readings.
> +        */
> +       if (sd->calibrated_ext)
> +               sff8472_calibration(id, sd);
> +}
> +
> +
> +

One line between functions is enough.

> +void sff8472_show_all(const __u8 *id)
> +{
> +       struct sff8472_diags sd;
> +       char *rx_power_string =3D NULL;
> +       int i;
> +
> +       sff8472_parse_eeprom(id, &sd);
> +
> +       if (!sd.supports_dom) {
> +               printf("\t%-41s : No\n", "Optical diagnostics support=
");
> +               return ;
> +       }
> +       printf("\t%-41s : Yes\n", "Optical diagnostics support");
> +
> +#define PRINT_BIAS(string, index) \
> +       printf("\t%-41s : %.3f mA\n", (string), \
> +                  (double)(sd.bias_cur[(index)] / 500.));
> +
> +# define PRINT_xX_PWR(string, var, index) \
> +       printf("\t%-41s : %.4f mW / %.2f dBm\n", (string), \
> +                  (double)((var)[(index)] / 10000.), \
> +                  convert_mw_to_dbm((double)((var)[(index)] / 10000.=
)));
> +
> +#define PRINT_TEMP(string, index) \
> +       printf("\t%-41s : %.2f degrees C / %.2f degrees F\n", (string=
), \
> +                  (double)(sd.sfp_temp[(index)] / 256.), \
> +                  (double)(sd.sfp_temp[(index)] / 256. * 1.8 + 32.))=
;
> +
> +#define PRINT_VCC(string, index) \
> +       printf("\t%-41s : %.4f V\n", (string), \
> +                  (double)(sd.sfp_voltage[(index)] / 10000.));

=46unction-like macros generally shouldn't be defined with a trailing
semi-colon, as that will be added at the point of use.

The backslashes should be lined up on the right, and continuation lines
within parentheses should be indented so they begin just to the right o=
f
the opening parenthesis, e.g.:

#define PRINT_VCC(string, index)				\
	printf("\t%-41s : %.4f V\n", (string),			\
	       (double)(sd.sfp_voltage[(index)] / 10000.))

[...]
> +               PRINT_xX_PWR("Laser output power high alarm threshold=
",
> +                                        sd.tx_power, HALRM);
> +               PRINT_xX_PWR("Laser output power low alarm threshold"=
,
> +                                        sd.tx_power, LALRM);
> +               PRINT_xX_PWR("Laser output power high warning thresho=
ld",
> +                                        sd.tx_power, HWARN);
> +               PRINT_xX_PWR("Laser output power low warning threshol=
d",
> +                                        sd.tx_power, LWARN);

The continuation lines are over-indented here.

[...]
> +               PRINT_xX_PWR("Laser rx power high alarm threshold",
> +                                        sd.rx_power, HALRM);
> +               PRINT_xX_PWR("Laser rx power low alarm threshold",
> +                                        sd.rx_power, LALRM);
> +               PRINT_xX_PWR("Laser rx power high warning threshold",
> +                                        sd.rx_power, HWARN);
> +               PRINT_xX_PWR("Laser rx power low warning threshold",
> +                                        sd.rx_power, LWARN);
> +       }

Same here.

> +}
> +
> diff --git a/sfpid.c b/sfpid.c
> index a4a671d..2982d0d 100644
> --- a/sfpid.c
> +++ b/sfpid.c
[...]
>  static void sff8079_show_wavelength_or_copper_compliance(const __u8 =
*id)
>  {
>         if (id[8] & (1 << 2)) {
> -               printf("\tPassive Cu cmplnce. : 0x%02x", id[60]);
> +               printf("\t%-41s : 0x%02x", "Passive copper compliance=
", id[60]);
>                 switch (id[60]) {
>                 case 0x00:
>                         printf(" (unspecified)");
> @@ -316,7 +318,7 @@ static void sff8079_show_wavelength_or_copper_com=
pliance(const __u8 *id)
>                 }
>                 printf(" [SFF-8472 rev10.4 only]\n");
>         } else if (id[8] & (1 << 3)) {
> -               printf("\tActive Cu cmplnce.  : 0x%02x", id[60]);
> +               printf("\t%-41s : 0x%02x", "Active copper compliance"=
, id[60]);
>                 switch (id[60]) {
>                 case 0x00:
>                         printf(" (unspecified)");

If you want to change these labels, do that in a separate patch.

[...]
> @@ -368,14 +370,15 @@ void sff8079_show_all(const __u8 *id)
>                 sff8079_show_connector(id);
>                 sff8079_show_transceiver(id);
>                 sff8079_show_encoding(id);
> -               sff8079_show_value_with_unit(id, 12, "BR, Nominal", 1=
00, "MBd");
> +               sff8079_show_value_with_unit(id, 12,
> +                               "Nominal signalling rate", 100, "MBd"=
);
>                 sff8079_show_rate_identifier(id);
>                 sff8079_show_value_with_unit(id, 14,
> -                                            "Length (SMF,km)", 1, "k=
m");
> +                               "Length (SMF,km)", 1, "km");
>                 sff8079_show_value_with_unit(id, 15, "Length (SMF)", =
100, "m");
>                 sff8079_show_value_with_unit(id, 16, "Length (50um)",=
 10, "m");
>                 sff8079_show_value_with_unit(id, 17,
> -                                            "Length (62.5um)", 10, "=
m");
> +                               "Length (62.5um)", 10, "m");
>                 sff8079_show_value_with_unit(id, 18, "Length (Copper)=
", 1, "m");
>                 sff8079_show_value_with_unit(id, 19, "Length (OM3)", =
10, "m");
>                 sff8079_show_wavelength_or_copper_compliance(id);

These changes are unnecessary.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
