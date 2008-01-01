From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 25/26] atl1: add NAPI support
Date: Mon, 31 Dec 2007 21:58:17 -0800
Message-ID: <20071231215817.10c64320@deepthought>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
	<1199154173-4058-26-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59918 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbYAAF74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 00:59:56 -0500
In-Reply-To: <1199154173-4058-26-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Dec 2007 20:22:52 -0600
Jay Cliburn <jacliburn@bellsouth.net> wrote:

> Add support for NAPI, styled after the e1000 NAPI implementation.  That we
> follow the e1000 for NAPI shouldn't come as much of a surprise, since the
> entire atl1 driver is based heavily upon it.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/Kconfig     |   14 ++++
>  drivers/net/atlx/atl1.c |  151 +++++++++++++++++++++++++++++++++++++++++++++--
>  drivers/net/atlx/atl1.h |   20 ++++++
>  drivers/net/atlx/atlx.h |    7 ++-
>  4 files changed, 186 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index d9107e5..095629f 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2371,6 +2371,20 @@ config ATL1
>  	  To compile this driver as a module, choose M here.  The module
>  	  will be called atl1.
>  
> +config ATL1_NAPI
> +	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
> +	depends on ATL1 && EXPERIMENTAL
> +	help
> +	  NAPI is a new driver API designed to reduce CPU and interrupt load
> +	  when the driver is receiving lots of packets from the card. It is
> +	  still somewhat experimental and thus not yet enabled by default.
> +
> +	  If your estimated Rx load is 10kpps or more, or if the card will be
> +	  deployed on potentially unfriendly networks (e.g. in a firewall),
> +	  then say Y here.
> +
> +	  If in doubt, say N.
> +
>  endif # NETDEV_1000
>  
>  #
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index 237622e..10bccf6 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -756,7 +756,16 @@ static void atl1_set_mac_addr(struct atl1_hw *hw)
>  
>  static int atl1_alloc_queues(struct atl1_adapter *adapter)
>  {
> -	/* temporary placeholder function for NAPI */
> +#ifdef CONFIG_ATL1_NAPI
> +	int size;
> +
> +	size = sizeof(struct net_device) * adapter->num_rx_queues;
> +	adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
> +	if (!adapter->polling_netdev)
> +		return -ENOMEM;
> +
> +	memset(adapter->polling_netdev, 0, size);
> +#endif

You don't need to allocate pseudo-devices anymore in 2.6.24 or later.
rework to just use napi structures.



-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
