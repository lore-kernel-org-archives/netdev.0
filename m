From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Fri, 16 Nov 2012 19:38:39 +0000
Message-ID: <1353094719.2743.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
	 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
	 <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com>
	 <CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
	 <50A570D7.3080409@gmail.com>
	 <1353022205.4867.76.camel@deadeye.wl.decadent.org.uk>
	 <CAPN4dA_ymo-Bx+GM+JLLKGHghq+qBYxR0zO7K6H6Nn0pqZsJRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>
To: <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20494 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841Ab2KPTim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 14:38:42 -0500
In-Reply-To: <CAPN4dA_ymo-Bx+GM+JLLKGHghq+qBYxR0zO7K6H6Nn0pqZsJRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 03:23 +0100, Aur=C3=A9lien wrote:
> On Fri, Nov 16, 2012 at 12:30 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > Yes, Jeff's the one you should be talking to about these drivers.  =
I
> > just look after the ethtool utility and API.
> >
>=20
> Ok, so I will discuss the ixgbe patch with Jeff :)
>=20
> Ben, on the ethtool side, attached is a patch to enable the following
> option and output; It's still missing externally calibrated optics
> support (my current one is internally calibrated, so that's difficult
> to test anything). What do you think ? Is there any other data that
> could be interesting to show with -O or -m options ?
[...]
> --- a/configure.ac
> +++ b/configure.ac
> @@ -13,9 +13,11 @@ AC_PROG_GCC_TRADITIONAL
>  AM_PROG_CC_C_O
> =20
>  dnl Checks for libraries.
> +AC_CHECK_LIB([m], [log10])
> =20
>  dnl Checks for header files.
>  AC_CHECK_HEADERS(sys/ioctl.h)
> +AC_CHECK_HEADERS(math.h)

This is silly; log10() and <math.h> are part of standard C and -lm is
standard on Unix.  Just use <math.h> and -lm unconditionally.

>  dnl Checks for typedefs, structures, and compiler characteristics.
>  AC_MSG_CHECKING([whether <linux/types.h> defines big-endian types])
> diff --git a/ethtool.c b/ethtool.c
> index 3db7fec..e18fc85 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -3549,6 +3549,47 @@ static int do_tsinfo(struct cmd_context *ctx)
>         return 0;
>  }
> =20
> +static int do_getmoduleoptics(struct cmd_context *ctx)
> +{
> +       struct ethtool_modinfo modinfo;
> +       struct ethtool_eeprom *eeprom;
> +       int err;
> +
> +       modinfo.cmd =3D ETHTOOL_GMODULEINFO;
> +       err =3D send_ioctl(ctx, &modinfo);
> +       if (err < 0) {
> +               perror("Cannot get module information");
> +               return 1;
> +       }
> +
> +       if (modinfo.type !=3D ETH_MODULE_SFF_8472)
> +       {
> +               perror("Module is not SFF-8472 (DOM) compliant");
> +               return 1;
> +       }
> +
> +       eeprom =3D calloc(1, sizeof(*eeprom) + modinfo.eeprom_len);
> +       if (!eeprom) {
> +               perror("Cannot allocate memory for module EEPROM data=
");
> +               return 1;
> +       }
> +
> +       eeprom->cmd =3D ETHTOOL_GMODULEEEPROM;
> +       eeprom->len =3D modinfo.eeprom_len;
> +       eeprom->offset =3D 0;
> +       err =3D send_ioctl(ctx, eeprom);
> +       if (err < 0) {
> +               perror("Cannot access module EEPROM");
> +               free(eeprom);
> +               return 1;
> +       }
> +
> +       printf("Physical interface: %s\n", ctx->devname);
> +       sff8472_show_all(eeprom->data);
> +       free(eeprom);
> +       return 0;
> +}

Please merge this with the existing -m option and update the
documentation to say that this covers diagnostics where available.  You
could add a long option alias like --dump-module or --module-info that
covers the two types of information.

>  static int do_getmodule(struct cmd_context *ctx)
>  {
>         struct ethtool_modinfo modinfo;
> @@ -3832,11 +3873,13 @@ static const struct option {
>         { "--set-priv-flags", 1, do_sprivflags, "Set private flags",
>           "             FLAG on|off ...\n" },
>         { "-m|--dump-module-eeprom", 1, do_getmodule,
> -         "Qeuery/Decode Module EEPROM information",
> +         "Query/Decode Module EEPROM information",
>           "             [ raw on|off ]\n"
>           "             [ hex on|off ]\n"
>           "             [ offset N ]\n"
>           "             [ length N ]\n" },
> +       { "-O|--module-optics", 1, do_getmoduleoptics,
> +         "Show module optical diagnostics" },
>         { "--show-eee", 1, do_geee, "Show EEE settings"},
>         { "--set-eee", 1, do_seee, "Set EEE settings",
>           "             [ eee on|off ]\n"
> diff --git a/internal.h b/internal.h
> index 4f96fd5..e977a81 100644
> --- a/internal.h
> +++ b/internal.h
> @@ -253,4 +253,7 @@ int rxclass_rule_del(struct cmd_context *ctx, __u=
32 loc);
>  /* Module EEPROM parsing code */
>  void sff8079_show_all(const __u8 *id);
> =20
> +/* Optics diagnostics */
> +void sff8472_show_all(const __u8 *id);
> +
>  #endif /* ETHTOOL_INTERNAL_H__ */
> diff --git a/sfpdiag.c b/sfpdiag.c
> new file mode 100644
> index 0000000..aa7c14c
> --- /dev/null
> +++ b/sfpdiag.c
[...]
> +#define SFF_A2_TEMP                       0x100 + 96
> +#define SFF_A2_TEMP_HALRM                 0x100 + 0
[...]
> +#define SFF_A2_ALRM_FLG                   0x100 + 112
> +#define SFF_A2_WARN_FLG                   0x100 + 116

All the above offsets need parentheses around their definitions.

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
> +       __u8 calibrated_int;    /* Is internally calibrated */
> +       __u16 bias_cur[5];              /* Measured bias current in 2=
uA units (cur, l/h warn, l/h alarm) */
> +       __u16 tx_power[5];              /* Measured TX Power in 0.1uW=
 units (cur, warn, alarm) */
> +       __u16 rx_power[5];              /* Measured RX Power (cur, wa=
rn, alarm) */
> +       __u8  rx_power_type;    /* 0 =3D OMA, 1 =3D Average power */
> +       __s16 sfp_temp[5];      /* SFP Temp in 0.1 Celcius (cur, warn=
, alarm) */
> +       __u16 sfp_voltage[5];   /* SFP voltage in 0.1mV units (cur, w=
arn, alarm) */
> +
> +};
> +
> +static struct sff8472_aw_flags {
> +       const char *str;        /* Human-readable string, null at the=
 end */
> +       int offset;             /* A2-relative adress offset */

This is commented as an offset in the A2 'EEPROM' but the offsets
actually used include the 0x100 offset from the start of the
concatenated 'EEPROM'.

> +       __u8 value;             /* 1-bit mask, alarm is on if offset =
& value !=3D 0. */
> +} sff8472_aw_flags[] =3D
> +{
> +       { "Laser bias current high alarm",   SFF_A2_ALRM_FLG, (1 << 3=
) },
> +       { "Laser bias current low alarm",    SFF_A2_ALRM_FLG, (1 << 2=
) },
> +       { "Laser bias current high warning", SFF_A2_WARN_FLG, (1 << 3=
) },
> +       { "Laser bias current low warning",  SFF_A2_WARN_FLG, (1 << 2=
) },
> +
> +       { "Laser output power high alarm",   SFF_A2_ALRM_FLG, (1 << 1=
) },
> +       { "Laser output power low alarm",    SFF_A2_ALRM_FLG, (1 << 0=
) },
> +       { "Laser output power high warning", SFF_A2_WARN_FLG, (1 << 1=
) },
> +       { "Laser output power low warning",  SFF_A2_WARN_FLG, (1 << 0=
) },
> +
> +       { "Module temperature high alarm",   SFF_A2_ALRM_FLG, (1 << 7=
) },
> +       { "Module temperature low alarm",    SFF_A2_ALRM_FLG, (1 << 6=
) },
> +       { "Module temperature high warning", SFF_A2_WARN_FLG, (1 << 7=
) },
> +       { "Module temperature low warning",  SFF_A2_WARN_FLG, (1 << 6=
) },
> +
> +       { "Module voltage high alarm",   SFF_A2_ALRM_FLG, (1 << 5) },
> +       { "Module voltage low alarm",    SFF_A2_ALRM_FLG, (1 << 4) },
> +       { "Module voltage high warning", SFF_A2_WARN_FLG, (1 << 5) },
> +       { "Module voltage low warning",  SFF_A2_WARN_FLG, (1 << 4) },
> +
> +       { "Laser rx power high alarm",   SFF_A2_ALRM_FLG + 1, (1 << 7=
) },
> +       { "Laser rx power low alarm",    SFF_A2_ALRM_FLG + 1, (1 << 6=
) },
> +       { "Laser rx power high warning", SFF_A2_WARN_FLG + 1, (1 << 7=
) },
> +       { "Laser rx power low warning",  SFF_A2_WARN_FLG + 1, (1 << 6=
) },
> +
> +       { NULL, 0, 0 },
> +};
> +
> +#ifdef HAVE_LIBM
> +
> +static double convert_mw_to_dbm(double mw)
> +{
> +       return (10.f * log10(mw / 1000.f)) + 30.f;

Why are all the literals explicitly float and not double?

> +}
> +
> +#endif
> +
> +/* Externally calibrated SFP calculations */
> +#define ECAL(v, s, o) (( ((double) (s>>8)) + (s & 0xFF)) * (double) =
v + o)    =20

Please follow kernel coding style for spacing.  checkpatch.pl will show
you what should be changed.

> +static void sff8472_parse_eeprom(const __u8 *id, struct sff8472_diag=
s *sd)
> +{
> +       sd->supports_dom =3D id[SFF_A0_DOM] & SFF_A0_DOM_IMPL;
> +       sd->supports_alarms =3D id[SFF_A0_OPTIONS] & SFF_A0_OPTIONS_A=
W;
> +       sd->calibrated_int =3D id[SFF_A0_DOM] & SFF_A0_DOM_INTCAL;
> +       sd->rx_power_type =3D id[SFF_A0_DOM] & SFF_A0_DOM_PWRT;
> +
> +
> +#define OFFSET_TO_U16(offset) (id[(offset)] << 8 | id[(offset) + 1])=
=20
> +
> +       sd->bias_cur[MCURR] =3D OFFSET_TO_U16(SFF_A2_BIAS);
> +       sd->bias_cur[HALRM] =3D OFFSET_TO_U16(SFF_A2_BIAS_HALRM);
> +       sd->bias_cur[LALRM] =3D OFFSET_TO_U16(SFF_A2_BIAS_LALRM);
> +       sd->bias_cur[HWARN] =3D OFFSET_TO_U16(SFF_A2_BIAS_HWARN);
> +       sd->bias_cur[LWARN] =3D OFFSET_TO_U16(SFF_A2_BIAS_LWARN);
> +
> +       sd->sfp_voltage[MCURR] =3D OFFSET_TO_U16(SFF_A2_VCC);
> +       sd->sfp_voltage[HALRM] =3D OFFSET_TO_U16(SFF_A2_VCC_HALRM);
> +       sd->sfp_voltage[LALRM] =3D OFFSET_TO_U16(SFF_A2_VCC_LALRM);
> +       sd->sfp_voltage[HWARN] =3D OFFSET_TO_U16(SFF_A2_VCC_HWARN);
> +       sd->sfp_voltage[LWARN] =3D OFFSET_TO_U16(SFF_A2_VCC_LWARN);
> +
> +       sd->tx_power[MCURR] =3D OFFSET_TO_U16(SFF_A2_TX_PWR);
> +       sd->tx_power[HALRM] =3D OFFSET_TO_U16(SFF_A2_TX_PWR_HALRM);
> +       sd->tx_power[LALRM] =3D OFFSET_TO_U16(SFF_A2_TX_PWR_LALRM);
> +       sd->tx_power[HWARN] =3D OFFSET_TO_U16(SFF_A2_TX_PWR_HWARN);
> +       sd->tx_power[LWARN] =3D OFFSET_TO_U16(SFF_A2_TX_PWR_LWARN);
> +
> +       sd->rx_power[MCURR] =3D OFFSET_TO_U16(SFF_A2_RX_PWR);
> +       sd->rx_power[HALRM] =3D OFFSET_TO_U16(SFF_A2_RX_PWR_HALRM);
> +       sd->rx_power[LALRM] =3D OFFSET_TO_U16(SFF_A2_RX_PWR_LALRM);
> +       sd->rx_power[HWARN] =3D OFFSET_TO_U16(SFF_A2_RX_PWR_HWARN);
> +       sd->rx_power[LWARN] =3D OFFSET_TO_U16(SFF_A2_RX_PWR_LWARN);
> +
> +       /* Temperature conversions */
> +#define OFFSET_TO_TEMP(offset) \
> +    ((*(__s8 *)(&id[(offset)])) * 1000 + ((id[(offset) + 1] * 1000) =
/ 256)) / 100;

This seems awfuly complicated; why not:

#define OFFSET_TO_TEMP(offset) (((s16)OFFSET_TO_U16(offset)) * 10 / 256=
)

But why round to tenths of a degree here and then round again to whole
degrees celsius/fahrenheit when printing?

[...]
> +#define PRINT_TEMP(string, index) \
> +       printf("    %-41s :  %.0f degrees C / %.0f degrees F\n", (str=
ing), \
> +                  (double)(sd.sfp_temp[(index)] / 10.f), \
> +                  (double)(sd.sfp_temp[(index)] / 10.f * 1.8f + 32.f=
));
[...]

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
