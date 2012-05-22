From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] ethtool: Split out printing of hex data
Date: Wed, 23 May 2012 00:58:23 +0100
Message-ID: <1337731103.2953.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FB66390.2010704@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Yaniv Rosner <yanivr@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>
To: Stuart Hodgson <smhodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46018 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933017Ab2EVX6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 19:58:31 -0400
In-Reply-To: <4FB66390.2010704@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-18 at 15:58 +0100, Stuart Hodgson wrote:
> Split out printing of hex data to common function from
> dump_regs and dump_eeprom. Ready for use by module
> eeprom dumping.
> 
> Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
> ---
>  ethtool.c |   35 ++++++++++++++++++-----------------
>  1 files changed, 18 insertions(+), 17 deletions(-)
> 
> diff --git a/ethtool.c b/ethtool.c
> index e80b38b..fdc21de 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -787,6 +787,20 @@ static const struct {
>  	{ "st_gmac", st_gmac_dump_regs },
>  };
>  
> +static void dump_hex(__u8 *data, int len, int offset)
> +{
> +	int i;
> +
> +	fprintf(stdout, "Offset\tValues\n");
> +	fprintf(stdout, "--------\t-----");
> +	for (i = 0; i < len; i++) {
> +		if (i%16 == 0)
> +			fprintf(stdout, "\n0x%04x:\t", i + offset);
> +		fprintf(stdout, " %02x", data[i]);
> +	}

The problem with this (inherited from dump_regs()) is that the columns
don't line up.  So I've applied this but changed dump_hex() to look more
like the code removed from dump_eeprom().

Ben.

> +	fprintf(stdout, "\n\n");
> +}
> +
>  static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
>  		     const char *gregs_dump_file,
>  		     struct ethtool_drvinfo *info, struct ethtool_regs *regs)
> @@ -820,22 +834,14 @@ static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
>  				     ETHTOOL_BUSINFO_LEN))
>  				return driver_list[i].func(info, regs);
>  
> -	fprintf(stdout, "Offset\tValues\n");
> -	fprintf(stdout, "--------\t-----");
> -	for (i = 0; i < regs->len; i++) {
> -		if (i%16 == 0)
> -			fprintf(stdout, "\n%03x:\t", i);
> -		fprintf(stdout, " %02x", regs->data[i]);
> -	}
> -	fprintf(stdout, "\n\n");
> +	dump_hex(regs->data, regs->len, 0);
> +
>  	return 0;
>  }
>  
>  static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
>  		       struct ethtool_eeprom *ee)
>  {
> -	int i;
> -
>  	if (geeprom_dump_raw) {
>  		fwrite(ee->data, 1, ee->len, stdout);
>  		return 0;
> @@ -847,13 +853,8 @@ static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
>  		return tg3_dump_eeprom(info, ee);
>  	}
>  
> -	fprintf(stdout, "Offset\t\tValues\n");
> -	fprintf(stdout, "------\t\t------");
> -	for (i = 0; i < ee->len; i++) {
> -		if(!(i%16)) fprintf(stdout, "\n0x%04x\t\t", i + ee->offset);
> -		fprintf(stdout, "%02x ", ee->data[i]);
> -	}
> -	fprintf(stdout, "\n");
> +	dump_hex(ee->data, ee->len, ee->offset);
> +
>  	return 0;
>  }
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
