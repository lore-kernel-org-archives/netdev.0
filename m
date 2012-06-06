From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] Ethtool: Add EEE support
Date: Wed, 6 Jun 2012 16:48:54 +0100
Message-ID: <1338997734.2836.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
	 <1338878470-24784-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eilong@broadcom.com>,
	<peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28618 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756248Ab2FFPs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 11:48:58 -0400
In-Reply-To: <1338878470-24784-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 09:41 +0300, Yuval Mintz wrote:
> This patch adds 2 new ethtool commands which can be
> used to manipulate network interfaces' support in
> EEE.
> 
> Output of 'get' has the following form:
> 
> 	EEE Settings for p2p1:
> 		EEE status: enabled - active
> 		Tx LPI: 1000 (u)
> 		Supported EEE link modes:  10000baseT/Full
> 		Advertised EEE link modes:  10000baseT/Full
> 		Link partner advertised EEE link modes:  10000baseT/Full
> 
> Thanks goes to Giuseppe Cavallaro for his original patch.
[...]
> diff --git a/ethtool.c b/ethtool.c
> index f18f611..063e72b 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -359,7 +359,8 @@ static int do_version(struct cmd_context *ctx)
>  	return 0;
>  }
>  
> -static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask);
> +static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
> +			    u8 all);

For now, use int for booleans.  At some point I would like to see a
thorough cleanup of ethtool to use bool where appropriate - but that's
independent of this.

[...]
>  /* Print link capability flags (supported, advertised or lp_advertised).
>   * Assumes that the corresponding SUPPORTED and ADVERTISED flags are equal.
>   */
>  static void
> -dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
> +dump_link_caps(const char *prefix, const char *an_prefix, u32 mask, u8 all)
>  {
>  	int indent;
>  	int did1;
> @@ -456,24 +457,26 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
>  		 fprintf(stdout, "Not reported");
>  	fprintf(stdout, "\n");
>  
> -	fprintf(stdout, "	%s pause frame use: ", prefix);
> -	if (mask & ADVERTISED_Pause) {
> -		fprintf(stdout, "Symmetric");
> -		if (mask & ADVERTISED_Asym_Pause)
> -			fprintf(stdout, " Receive-only");
> -		fprintf(stdout, "\n");
> -	} else {
> -		if (mask & ADVERTISED_Asym_Pause)
> -			fprintf(stdout, "Transmit-only\n");
> +	if (all) {

It might be clearer to invert this flag and name it something like
'link_mode_only'.

> +		fprintf(stdout, "	%s pause frame use: ", prefix);
> +		if (mask & ADVERTISED_Pause) {
> +			fprintf(stdout, "Symmetric");
> +			if (mask & ADVERTISED_Asym_Pause)
> +				fprintf(stdout, " Receive-only");
> +			fprintf(stdout, "\n");
> +		} else {
> +			if (mask & ADVERTISED_Asym_Pause)
> +				fprintf(stdout, "Transmit-only\n");
> +			else
> +				fprintf(stdout, "No\n");
> +		}
> +
> +		fprintf(stdout, "	%s auto-negotiation: ", an_prefix);
> +		if (mask & ADVERTISED_Autoneg)
> +			fprintf(stdout, "Yes\n");
>  		else
>  			fprintf(stdout, "No\n");
>  	}
> -
> -	fprintf(stdout, "	%s auto-negotiation: ", an_prefix);
> -	if (mask & ADVERTISED_Autoneg)
> -		fprintf(stdout, "Yes\n");
> -	else
> -		fprintf(stdout, "No\n");
>  }
>  
>  static int dump_ecmd(struct ethtool_cmd *ep)
[...]
> @@ -1116,6 +1120,36 @@ static int dump_rxfhash(int fhash, u64 val)
>  	return 0;
>  }
>  
> +static int dump_eeecmd(struct ethtool_eee *ep)

Is there any reason for this not to return void?

> +{
> +
> +	fprintf(stdout, "	EEE status: ");
> +	if (!ep->supported) {
> +		fprintf(stdout, "not supported\n");
> +		return 0;
> +	} else if (!ep->eee_enabled) {
> +		fprintf(stdout, "disabled\n");
> +	} else {
> +		fprintf(stdout, "enabled - ");
> +		if (ep->eee_active)
> +			fprintf(stdout, "active\n");
> +		else
> +			fprintf(stdout, "inactive\n");
> +	}
> +
> +	fprintf(stdout, "	Tx LPI:");
> +	if (ep->tx_lpi_enabled)
> +		fprintf(stdout, " %d (u)\n", ep->tx_lpi_timer);

"us" not "(u)"

> +	else
> +		fprintf(stdout, " disabled\n");
> +
> +	dump_link_caps("Supported EEE", "", ep->supported, 0);
> +	dump_link_caps("Advertised EEE", "", ep->advertised, 0);
> +	dump_link_caps("Link partner advertised EEE", "", ep->lp_advertised, 0);
> +
> +	return 0;
> +}
> +
[...]
> +static int do_seee(struct cmd_context *ctx)
> +{
> +	int adv_c = -1, lpi_c = -1, lpi_time_c = -1, eee_c = -1;
> +	int change = -1, change2 = -1;
> +	struct ethtool_eee eeecmd;
> +	struct cmdline_info cmdline_eee[] = {
> +		{ "advertise",    CMDL_U32,  &adv_c,       &eeecmd.advertised },
> +		{ "tx-lpi",       CMDL_BOOL, &lpi_c,   &eeecmd.tx_lpi_enabled },
> +		{ "tx-timer",	  CMDL_U32,  &lpi_time_c, &eeecmd.tx_lpi_timer},
> +		{ "eee",	  CMDL_BOOL, &eee_c,	   &eeecmd.eee_enabled},
> +	};
> +
> +	if (ctx->argc == 0)
> +		exit_bad_args();
> +
> +	parse_generic_cmdline(ctx, &change, cmdline_eee,
> +			      ARRAY_SIZE(cmdline_eee));
> +
> +	eeecmd.cmd = ETHTOOL_GEEE;
> +	if (send_ioctl(ctx, &eeecmd)) {
> +		perror("Cannot get EEE settings");
> +		return 1;
> +	}
> +
> +	do_generic_set(cmdline_eee, ARRAY_SIZE(cmdline_eee), &change2);
> +
> +	if (change2) {
> +
> +		eeecmd.cmd = ETHTOOL_SEEE;
> +		if (send_ioctl(ctx, &eeecmd)) {
> +			perror("Cannot set EEE settings");
> +			return 1;
> +		}
> +	}
> +
> +	return 1;

return 0, I think!

> +}
> +
>  int send_ioctl(struct cmd_context *ctx, void *cmd)
>  {
>  #ifndef TEST_ETHTOOL
> @@ -3423,6 +3516,12 @@ static const struct option {
>  	  "		[ hex on|off ]\n"
>  	  "		[ offset N ]\n"
>  	  "		[ length N ]\n" },
> +	{ "--get-eee", 1, do_geee, "Get EEE settings"},
> +	{ "--set-eee", 1, do_seee, "Set EEE settings",
> +	  "		[ eee on|off ]\n"
> +	  "		[ advertise %x ]\n"
> +	  "		[ tx-lpi on|off ]\n"
> +	  "		[ tx-timer %x ]\n"},

The tx-timer value would normally be specified in decimal, so put "%d"
here.

>  	{ "-h|--help", 0, show_usage, "Show this help" },
>  	{ "--version", 0, do_version, "Show version number" },
>  	{}

You also need to add some test cases for the command line parsing in
test-cmdline.c.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
