From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 5/9] net/eipoib: Add ethtool file support
Date: Tue, 10 Jul 2012 18:48:13 +0100
Message-ID: <1341942493.2605.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
	 <1341922569-4118-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8773 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752517Ab2GJRsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 13:48:17 -0400
In-Reply-To: <1341922569-4118-6-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 15:16 +0300, Or Gerlitz wrote:
> From: Erez Shitrit <erezsh@mellanox.co.il>
> 
> Via ethtool the driver describes its version, ABI version, on what PIF
> interface it runs and various statistics.
> 
> Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/eipoib/eth_ipoib_ethtool.c |  147 ++++++++++++++++++++++++++++++++
>  1 files changed, 147 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/eipoib/eth_ipoib_ethtool.c
> 
> diff --git a/drivers/net/eipoib/eth_ipoib_ethtool.c b/drivers/net/eipoib/eth_ipoib_ethtool.c
> new file mode 100644
> index 0000000..b5c20ec
> --- /dev/null
> +++ b/drivers/net/eipoib/eth_ipoib_ethtool.c
> @@ -0,0 +1,147 @@
> +/*
> + * Copyright (c) 2012 Mellanox Technologies. All rights reserved
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * openfabric.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include "eth_ipoib.h"
> +
> +static void parent_ethtool_get_drvinfo(struct net_device *parent_dev,
> +				       struct ethtool_drvinfo *drvinfo)
> +{
> +	struct parent *parent = netdev_priv(parent_dev);
> +
> +	if (strlen(DRV_NAME) + strlen(parent->ipoib_main_interface) > 31)
> +		strncpy(drvinfo->driver, "driver name is too long", 32);

Returning error messages like is stupid; either truncate or WARN.

> +	else
> +		sprintf(drvinfo->driver, "%s:%s",
> +			DRV_NAME, parent->ipoib_main_interface);

Why do you not use the separate driver and bus_info fields?

> +	strncpy(drvinfo->version, DRV_VERSION, 32);
> +
> +	/* indicates ABI version */
> +	snprintf(drvinfo->fw_version, 32, "%d", EIPOIB_ABI_VER);
> +}
> +
> +static const char parent_strings[][ETH_GSTRING_LEN] = {
> +	/* public statistics */
> +	"rx_packets", "tx_packets", "rx_bytes",
> +	"tx_bytes", "rx_errors", "tx_errors",
> +	"rx_dropped", "tx_dropped", "multicast",
> +	"collisions", "rx_length_errors", "rx_over_errors",
> +	"rx_crc_errors", "rx_frame_errors", "rx_fifo_errors",
> +	"rx_missed_errors", "tx_aborted_errors", "tx_carrier_errors",
> +	"tx_fifo_errors", "tx_heartbeat_errors", "tx_window_errors",
> +#define PUB_STATS_LEN	21
[...]

This is duplicating the basic netdev statistics that are already
available without ethtool.  Most of them are completely meaningless for
Infiniband, I suspect.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
