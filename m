From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH] FW dump support
Date: Wed, 04 May 2011 18:40:07 +0100
Message-ID: <1304530807.2926.28.camel@bwh-desktop>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, --no-chain-reply-to@mv.qlogic.com,
	davem@davemloft.net
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10338 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812Ab1EDRkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:40:10 -0400
In-Reply-To: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-02 at 16:29 -0700, anirban.chakraborty@qlogic.com wrote:
> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> 
> Added support to take FW dump via ethtool.
[...]
> --- a/ethtool.c
> +++ b/ethtool.c
[...]
> @@ -263,6 +270,12 @@ static struct option {
>  		"Get Rx ntuple filters and actions\n" },
>      { "-P", "--show-permaddr", MODE_PERMADDR,
>  		"Show permanent hardware address" },
> +    { "-W", "--get-dump", MODE_GET_DUMP,
> +		"Get dump level\n" },
> +    { "-Wd", "--get-dump-data", MODE_GET_DUMP_DATA,
> +		"Get dump data", "FILENAME " "Name of the dump file\n" },

The short options should only include one letter.  Also the general
pattern is that 'get' options use lower-case letters and 'set' options
use upper-case letters.  No, I'm not sure how best to handle a set of 3
options.  Maybe you can combine --get-dump and --get-dump-data, making
the filename optional?

> +    { "-w", "--set-dump", MODE_SET_DUMP,
> +		"Set dump level", "DUMPLEVEL " "Dump level for the device\n" },

The field this sets is described as 'flags' so does it consist of flags
or is it a level?

[...]
> @@ -3241,6 +3270,86 @@ static int do_grxntuple(int fd, struct ifreq *ifr)
>  	return 0;
>  }
>  
> +static void do_writedump(struct ethtool_dump *dump)
> +{
> +	FILE *f = fopen(dump_file, "wb+");
> +	size_t bytes;
> +
> +	if (!f ) {
> +		fprintf(stderr, "Can't open file %s: %s\n",
> +			dump_file, strerror(errno));
> +		return;

On error, we must exit with code 1.

> +	}
> +
> +	bytes = fwrite(dump->data, 1, dump->len, f);
> +	fclose(f);
[...]

These functions can also fail and need to be checked.  (Yes, fclose()
can fail, since it may have to flush buffered data.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

