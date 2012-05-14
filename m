From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] Add command to dump module EEPROM
Date: Mon, 14 May 2012 15:18:59 +0100
Message-ID: <1337005139.2550.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337008431-6304-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Stuart Hodgson <smhodgson@solarflare.com>
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19087 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756440Ab2ENOTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 10:19:09 -0400
In-Reply-To: <1337008431-6304-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-14 at 18:13 +0300, Yaniv Rosner wrote:
> Hi Ben,
> This patch adds a new option to dump (SFP+, XFP, ...) module EEPROM following
> recent support to kernel side. Below some examples:
> 
> bash-3.00# ethtool -m eth1 offset 0x14 length 32 raw on
> JDSU            PLRXPLSCS432
> 
> bash-3.00# ethtool -m eth1 offset 0x14 length 32
> Offset          Values
> ------          ------
> 0x0014          4a 44 53 55 20 20 20 20 20 20 20 20 20 20 20 20
> 0x0024          00 00 01 9c 50 4c 52 58 50 4c 53 43 53 34 33 32
> 
> Please consider applying to ethtool.

I agree there should be ASCII-hex and binary dump modes, but we should
also support decoding of recognised EEPROM types (as Stuart proposed
earlier).

> Thanks,
> Yaniv
> 
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> ---
>  ethtool-copy.h |  312 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  ethtool.8.in   |   23 ++++-
>  ethtool.c      |   63 +++++++++++
>  3 files changed, 393 insertions(+), 5 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index d904c1a..604dbef 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -13,6 +13,9 @@
>  #ifndef _LINUX_ETHTOOL_H
>  #define _LINUX_ETHTOOL_H
>  
> +#ifdef __KERNEL__
> +#include <linux/compat.h>
> +#endif
>  #include <linux/types.h>
>  #include <linux/if_ether.h>
>  
[...]

You've updated this wrongly; run 'make headers_install' in the kernel
tree and then copy from usr/include/ethtool.h.

[...]
> diff --git a/ethtool.8.in b/ethtool.8.in
> index 63d5d48..470fd8d 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -325,6 +325,13 @@ ethtool \- query or control network driver and hardware settings
>  .I devname flag
>  .A1 on off
>  .RB ...
> +.HP
> +.B ethtool \-m|\-\-mod\-eeprom\-dump
> +.I devname
> +.B2 raw on off
> +.BN offset
> +.BN length
> +.HP
>  .
>  .\" Adjust lines (i.e. full justification) and hyphenate.
>  .ad
> @@ -800,6 +807,19 @@ Sets the device's private flags as specified.
>  .I flag
>  .A1 on off
>  Sets the state of the named private flag.
> +.TP
> +.B \-m \-\-mod\-eeprom\-dump
> +Retrieves and prints module (SFP+, XFP, ...) EEPROMs dump for the specified network device.
> +Default is to dump the entire EEPROM.
> +.TP
> +.BI raw \ on|off
> +Dumps the raw EEPROM data to stdout.

Only true for 'raw on', not 'raw off'!

> +.TP
> +.BI offset \ N
> +Start address of module EEPROM dump.
> +.TP
> +.BI length \ N
> +Length of module EEPROM dump.
>  .SH BUGS
>  Not supported (in part or whole) on all network drivers.
>  .SH AUTHOR
> @@ -815,7 +835,8 @@ Eli Kupermann,
>  Scott Feldman,
>  Andi Kleen,
>  Alexander Duyck,
> -Sucheta Chakraborty.
> +Sucheta Chakraborty,
> +Yaniv Rosner.
>  .SH AVAILABILITY
>  .B ethtool
>  is available from
> diff --git a/ethtool.c b/ethtool.c
> index e80b38b..6d022c3 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -2214,6 +2214,64 @@ static int do_nway_rst(struct cmd_context *ctx)
>  	return err;
>  }
>  
> +static int do_gmoduleeeprom(struct cmd_context *ctx)
> +{
> +	int geeprom_changed = 0;
> +	int geeprom_dump_raw = 0;
> +	u32 geeprom_offset = 0;
> +	u32 geeprom_length = -1;
> +	struct cmdline_info cmdline_geeprom[] = {
> +		{ "offset", CMDL_U32, &geeprom_offset, NULL },
> +		{ "length", CMDL_U32, &geeprom_length, NULL },
> +		{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
> +	};
> +	int err;
> +	struct ethtool_modinfo modinfo;
> +	struct ethtool_eeprom *eeprom;
> +	struct ethtool_drvinfo drvinfo;
> +
> +	parse_generic_cmdline(ctx, &geeprom_changed,
> +			      cmdline_geeprom, ARRAY_SIZE(cmdline_geeprom));
> +
> +	drvinfo.cmd = ETHTOOL_GDRVINFO;
> +	err = send_ioctl(ctx, &drvinfo);
> +	if (err < 0) {
> +		perror("Cannot get driver information");
> +		return 74;
> +	}

What is the point of running ETHTOOL_GDRVINFO?

> +	modinfo.cmd = ETHTOOL_GMODULEINFO;
> +	err = send_ioctl(ctx, &modinfo);
> +	if (err < 0) {
> +		perror("Cannot get driver information");
> +		return 74;

No more magic return codes, please.  Just return 1 on error.  Also the
error message here seems wrong.

> +	}
> +
> +	if (geeprom_length == -1)
> +		geeprom_length = modinfo.eeprom_len;
> +
> +	if (modinfo.eeprom_len < geeprom_offset + geeprom_length)
> +		geeprom_length = modinfo.eeprom_len - geeprom_offset;
> +	eeprom = calloc(1, sizeof(*eeprom)+geeprom_length);
> +	if (!eeprom) {
> +		perror("Cannot allocate memory for EEPROM data");
> +		return 75;
> +	}
> +	eeprom->cmd = ETHTOOL_GMODULEEEPROM;
> +	eeprom->len = geeprom_length;
> +	eeprom->offset = geeprom_offset;
> +	err = send_ioctl(ctx, eeprom);
> +	if (err < 0) {
> +		perror("Cannot get EEPROM data");
> +		free(eeprom);
> +		return 74;
> +	}
> +	err = dump_eeprom(geeprom_dump_raw, &drvinfo, eeprom);
> +	free(eeprom);
> +
> +	return err;
> +}
> +
>  static int do_geeprom(struct cmd_context *ctx)
>  {
>  	int geeprom_changed = 0;
> @@ -3231,6 +3289,11 @@ static const struct option {
>  	{ "--show-priv-flags" , 1, do_gprivflags, "Query private flags" },
>  	{ "--set-priv-flags", 1, do_sprivflags, "Set private flags",
>  	  "		FLAG on|off ...\n" },
> +	{ "-m|--mod-eeprom-dump", 1, do_gmoduleeeprom,
> +	  "Dumps SFP+ module EEPROM",

As you correctly noted in the manual page, this isn't limited to SFP+.

Ben.

> +	  "		[ raw on|off ]\n"
> +	  "		[ offset N ]\n"
> +	  "		[ length N ]\n" },
>  	{ "-h|--help", 0, show_usage, "Show this help" },
>  	{ "--version", 0, do_version, "Show version number" },
>  	{}

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
