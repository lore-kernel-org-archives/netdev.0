From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH ethtool v2 2/2] Ethtool: Implements
 ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY downshift
Date: Mon, 14 Nov 2016 15:03:03 +0100
Message-ID: <20161114140303.GM26710@lunn.ch>
References: <1479115787-1265-1-git-send-email-allan.nielsen@microsemi.com>
 <1479115787-1265-3-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37897 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932414AbcKNOkP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 09:40:15 -0500
Content-Disposition: inline
In-Reply-To: <1479115787-1265-3-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +.B \-\-get\-phy\-tunable
> +Gets the PHY tunable parameters.
> +.RS 4
> +.TP
> +.B downshift
> +For operation in cabling environments that are incompatible with 1000BAST-T,

BASE

> +PHY device provides an automatic link speed downshift operation.
> +Link speed downshift after N failed 1000BASE-T auto-negotiation attempts.
> +
> +Gets the PHY downshift count/status.
> +.RE
>  .SH BUGS
>  Not supported (in part or whole) on all network drivers.
>  .SH AUTHOR
> diff --git a/ethtool.c b/ethtool.c
> index 49ac94e..3b7ea4e 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -4520,6 +4520,146 @@ static int do_seee(struct cmd_context *ctx)
>  	return 0;
>  }
>  
> +static int do_get_phy_tunable(struct cmd_context *ctx)
> +{
> +	int argc = ctx->argc;
> +	char **argp = ctx->argp;
> +	int err, i;
> +	u8 downshift_changed = 0;
> +
> +	if (argc < 1)
> +		exit_bad_args();
> +	for (i = 0; i < argc; i++) {
> +		if (!strcmp(argp[i], "downshift")) {
> +			downshift_changed = 1;
> +			i += 1;
> +		} else  {
> +			exit_bad_args();
> +		}
> +	}
> +
> +	if (downshift_changed) {
> +		struct ethtool_tunable ds;
> +		u8 count = 0;
> +
> +		ds.cmd = ETHTOOL_PHY_GTUNABLE;
> +		ds.id = ETHTOOL_PHY_DOWNSHIFT;
> +		ds.type_id = ETHTOOL_TUNABLE_U8;
> +		ds.len = 1;
> +		ds.data[0] = &count;
> +		err = send_ioctl(ctx, &ds);
> +		if (err < 0) {
> +			perror("Cannot Get PHY downshift count");
> +			err = 87;
> +		}
> +		count = *((u8 *)&ds.data[0]);
> +		if (count)
> +			fprintf(stdout, "  Downshift count: %d\n",
> +				count);
> +		else
> +			fprintf(stdout, " Downshift disabled\n");

Please be consistent with the spaces.

Also, if send_ioctl() returns an error, you print the error message,
and then still print the value of count. You look to be missing a
return or an else.

       Andrew
