From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2] net: Enable 64-bit net device statistics on
 32-bit architectures
Date: Mon, 07 Jun 2010 21:18:29 -0700 (PDT)
Message-ID: <20100607.211829.63035366.davem@davemloft.net>
References: <1275689093.2095.36.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079Ab0FHEST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:18:19 -0400
In-Reply-To: <1275689093.2095.36.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 04 Jun 2010 23:04:53 +0100

> +#if BITS_PER_LONG == 64
> +#define NET_DEVICE_STATS_DEFINE(name)	u64 name
> +#elif defined(__LITTLE_ENDIAN)
> +#define NET_DEVICE_STATS_DEFINE(name)	u32 name, pad_ ## name
> +#else
> +#define NET_DEVICE_STATS_DEFINE(name)	u32 pad_ ## name, name
> +#endif
> +
 ...
> +	NET_DEVICE_STATS_DEFINE(rx_packets);
> +	NET_DEVICE_STATS_DEFINE(tx_packets);
> +	NET_DEVICE_STATS_DEFINE(rx_bytes);
 ...
>  	static const char fmt[] = "%30s %12lu\n";
> +	static const char fmt64[] = "%30s %12llu\n";
 ...
> +	seq_printf(seq, fmt64, "total frames received", stats->rx_packets);
> +	seq_printf(seq, fmt64, "total bytes received", stats->rx_bytes);
> +	seq_printf(seq, fmt64, "Broadcast/Multicast Rcvd", stats->multicast);

I guess you only built this on a 64-bit platform that defines u64 as a
long long type.

The rest of the world will receive tons of warnings for these print
statements.

You have basically 3 cases to handle:

1) u64 defined as "unsigned long long"

2) u64 defined as "unsigned long"

3) u32 defined as "unsigned int"

And the whole tree needs to be inspected to make sure there isn't going
to be fallout in areas your patch didn't take care of wrt. printf format
strings and the like.

What was always "unsigned long" is now a variable type, therefore using
a fixed printf format string is impossible unless you always cast these
things when passed in as printf arguments.

