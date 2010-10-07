From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: clear heap allocations for privileged ethtool
 actions
Date: Thu, 07 Oct 2010 22:34:44 +0100
Message-ID: <1286487284.2271.37.camel@achroite.uk.solarflarecom.com>
References: <20101007211004.GA20267@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Kees Cook <kees.cook@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53116 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0JGVet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 17:34:49 -0400
In-Reply-To: <20101007211004.GA20267@outflux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-07 at 14:10 -0700, Kees Cook wrote:
> Several other ethtool functions leave heap uncleared (potentially) by
> drivers. Some interfaces appear safe (eeprom, etc), in that the sizes
> are well controlled. In some situations (e.g. unchecked error conditions),
> the heap will remain unchanged in areas before copying back to userspace.
> Note that these are less of an issue since these all require CAP_NET_ADMIN.
> 
> Cc: stable@kernel.org
> Signed-off-by: Kees Cook <kees.cook@canonical.com>
> ---
>  net/core/ethtool.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 7a85367..fb9cf30 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -397,7 +397,7 @@ static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
>  	    (KMALLOC_MAX_SIZE - sizeof(*indir)) / sizeof(*indir->ring_index))
>  		return -ENOMEM;
>  	full_size = sizeof(*indir) + sizeof(*indir->ring_index) * table_size;
> -	indir = kmalloc(full_size, GFP_USER);
> +	indir = kzalloc(full_size, GFP_USER);
>  	if (!indir)
>  		return -ENOMEM;
>  
[...]

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

You could alternately recalculate full_size before copying back to the
user buffer:

	full_size = sizeof(*indir) + sizeof(*indir->ring_index) * indir->size;

but kzalloc() is more obviously safe.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

