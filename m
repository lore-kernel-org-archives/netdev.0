From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/1 v3] Ethtool: Add EEE support
Date: Tue, 12 Jun 2012 14:48:53 +0200
Message-ID: <4FD73AB5.8030400@st.com>
References: <1339318088-27126-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	eilong@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:44606 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751840Ab2FLMtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 08:49:01 -0400
In-Reply-To: <1339318088-27126-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Yuval.

On 6/10/2012 10:48 AM, Yuval Mintz wrote:
> This patch adds 2 new ethtool commands which can be
> used to manipulate network interfaces' support in
> EEE.
> 
> Output of 'get' has the following form:
> 
> 	EEE Settings for p2p1:
> 		EEE status: enabled - active
> 		Tx LPI: 1000 (us)
> 		Supported EEE link modes:  10000baseT/Full
> 		Advertised EEE link modes:  10000baseT/Full
> 		Link partner advertised EEE link modes:  10000baseT/Full
> 
> Thanks goes to Giuseppe Cavallaro for his original patch.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

I've tested it with the stmmac on STB SH4 platform and it seems to be ok
on my side.

peppe

> ---
> Changes from Version 2:
> 	- Changed --get-eee into --show-eee
> 	- Corrected EEE tests in test-cmdline.c
> 	- Corrected documentation
> ---
>  ethtool.8.in   |   32 +++++++++++++
>  ethtool.c      |  136 +++++++++++++++++++++++++++++++++++++++++++++++--------
>  test-cmdline.c |   11 +++++
>  3 files changed, 159 insertions(+), 20 deletions(-)
> 
> diff --git a/ethtool.8.in b/ethtool.8.in
> index 70ae31d..178322b 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -325,6 +325,16 @@ ethtool \- query or control network driver and hardware settings
>  .I devname flag
>  .A1 on off
>  .RB ...
> +.HP
> +.B ethtool \-\-show\-eee
> +.I devname
> +.HP
> +.B ethtool \-\-set\-eee
> +.I devname
> +.B2 eee on off
> +.B2 tx-lpi on off
> +.BN tx-timer
> +.BN advertise
>  .
>  .\" Adjust lines (i.e. full justification) and hyphenate.
>  .ad
> @@ -810,6 +820,28 @@ Sets the device's private flags as specified.
>  .I flag
>  .A1 on off
>  Sets the state of the named private flag.
> +.TP
> +.B \-\-show\-eee
> +Queries the specified network device for its support of Efficient Energy
> +Ethernet (according to the IEEE 802.3az specifications)
> +.TP
> +.B \-\-set\-eee
> +Sets the device EEE behaviour.
> +.TP
> +.A2 eee on off
> +Enables/disables the device support of EEE.
> +.TP
> +.A2 tx-lpi on off
> +Determines whether the device should assert its Tx LPI.
> +.TP
> +.BI advertise \ N
> +Sets the speeds for which the device should advertise EEE capabiliities.
> +Values are as for
> +.B \-\-change advertise
> +.TP
> +.BI tx-timer \ N
> +Sets the amount of time the device should stay in idle mode prior to asserting
> +its Tx LPI (in microseconds). This has meaning only when Tx LPI is enabled.
>  .SH BUGS
>  Not supported (in part or whole) on all network drivers.
>  .SH AUTHOR
> diff --git a/ethtool.c b/ethtool.c
> index f09a032..73e0e28 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -416,7 +416,8 @@ static int do_version(struct cmd_context *ctx)
>  	return 0;
>  }
>  
> -static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask);
> +static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
> +			   int link_mode_only);
>  
>  static void dump_supported(struct ethtool_cmd *ep)
>  {
> @@ -435,14 +436,15 @@ static void dump_supported(struct ethtool_cmd *ep)
>  		fprintf(stdout, "FIBRE ");
>  	fprintf(stdout, "]\n");
>  
> -	dump_link_caps("Supported", "Supports", mask);
> +	dump_link_caps("Supported", "Supports", mask, 0);
>  }
>  
>  /* Print link capability flags (supported, advertised or lp_advertised).
>   * Assumes that the corresponding SUPPORTED and ADVERTISED flags are equal.
>   */
>  static void
> -dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
> +dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
> +	       int link_mode_only)
>  {
>  	int indent;
>  	int did1;
> @@ -527,24 +529,26 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
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
> +	if (!link_mode_only) {
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
> @@ -552,10 +556,11 @@ static int dump_ecmd(struct ethtool_cmd *ep)
>  	u32 speed;
>  
>  	dump_supported(ep);
> -	dump_link_caps("Advertised", "Advertised", ep->advertising);
> +	dump_link_caps("Advertised", "Advertised", ep->advertising, 0);
>  	if (ep->lp_advertising)
>  		dump_link_caps("Link partner advertised",
> -			       "Link partner advertised", ep->lp_advertising);
> +			       "Link partner advertised", ep->lp_advertising,
> +			       0);
>  
>  	fprintf(stdout, "	Speed: ");
>  	speed = ethtool_cmd_speed(ep);
> @@ -1234,6 +1239,34 @@ static int dump_rxfhash(int fhash, u64 val)
>  	return 0;
>  }
>  
> +static void dump_eeecmd(struct ethtool_eee *ep)
> +{
> +
> +	fprintf(stdout, "	EEE status: ");
> +	if (!ep->supported) {
> +		fprintf(stdout, "not supported\n");
> +		return;
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
> +		fprintf(stdout, " %d (us)\n", ep->tx_lpi_timer);
> +	else
> +		fprintf(stdout, " disabled\n");
> +
> +	dump_link_caps("Supported EEE", "", ep->supported, 1);
> +	dump_link_caps("Advertised EEE", "", ep->advertised, 1);
> +	dump_link_caps("Link partner advertised EEE", "", ep->lp_advertised, 1);
> +}
> +
>  #define N_SOTS 7
>  
>  static char *so_timestamping_labels[N_SOTS] = {
> @@ -3463,6 +3496,63 @@ static int do_getmodule(struct cmd_context *ctx)
>  	return 0;
>  }
>  
> +static int do_geee(struct cmd_context *ctx)
> +{
> +	struct ethtool_eee eeecmd;
> +
> +	if (ctx->argc != 0)
> +		exit_bad_args();
> +
> +	eeecmd.cmd = ETHTOOL_GEEE;
> +	if (send_ioctl(ctx, &eeecmd)) {
> +		perror("Cannot get EEE settings");
> +		return 1;
> +	}
> +
> +	fprintf(stdout, "EEE Settings for %s:\n", ctx->devname);
> +	dump_eeecmd(&eeecmd);
> +
> +	return 0;
> +}
> +
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
> +	return 0;
> +}
> +
>  #ifndef TEST_ETHTOOL
>  int send_ioctl(struct cmd_context *ctx, void *cmd)
>  {
> @@ -3611,6 +3701,12 @@ static const struct option {
>  	  "		[ hex on|off ]\n"
>  	  "		[ offset N ]\n"
>  	  "		[ length N ]\n" },
> +	{ "--show-eee", 1, do_geee, "Show EEE settings"},
> +	{ "--set-eee", 1, do_seee, "Set EEE settings",
> +	  "		[ eee on|off ]\n"
> +	  "		[ advertise %x ]\n"
> +	  "		[ tx-lpi on|off ]\n"
> +	  "		[ tx-timer %d ]\n"},
>  	{ "-h|--help", 0, show_usage, "Show this help" },
>  	{ "--version", 0, do_version, "Show version number" },
>  	{}
> diff --git a/test-cmdline.c b/test-cmdline.c
> index 978c312..8fc2b48 100644
> --- a/test-cmdline.c
> +++ b/test-cmdline.c
> @@ -217,6 +217,17 @@ static struct test_case {
>  	{ 0, "-m devname hex off" },
>  	{ 1, "-m devname hex on raw on" },
>  	{ 0, "-m devname offset 4 length 6" },
> +	{ 1, "--show-eee" },
> +	{ 0, "--show-eee devname" },
> +	{ 1, "--show-eee devname foo" },
> +	{ 1, "--set-eee" },
> +	{ 1, "--set-eee devname" },
> +	{ 0, "--set-eee devname eee on" },
> +	{ 0, "--set-eee devname eee off" },
> +	{ 0, "--set-eee devname tx-lpi on" },
> +	{ 0, "--set-eee devname tx-lpi off" },
> +	{ 1, "--set-eee devname tx-timer foo" },
> +	{ 1, "--set-eee devname advertise foo" },
>  	/* can't test --set-priv-flags yet */
>  	{ 0, "-h" },
>  	{ 0, "--help" },
> 
