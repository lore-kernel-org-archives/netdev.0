From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 16 Oct 2009 21:31:25 +0100
Message-ID: <1255725085.2869.81.camel@achroite>
References: <200910161824.n9GIOubY010138@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amathur@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27212 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbZJPUbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 16:31:23 -0400
In-Reply-To: <200910161824.n9GIOubY010138@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-16 at 11:24 -0700, Rasesh Mody wrote:
> From: Rasesh Mody <rmody@brocade.com>
> 
> This is patch 2/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> 
> We wish this patch to be considered for inclusion in 2.6.32
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  bfa_timer.c    |   97 ++
>  bfad_fwimg.c   |  102 ++
>  bna_fn.c       | 1991 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  bna_queue.c    |  496 ++++++++++++++
>  bnad_ethtool.c | 1101 +++++++++++++++++++++++++++++++
>  5 files changed, 3787 insertions(+)
> 
> diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfad_fwimg.c linux-2.6.32-rc4-mod/drivers/net/bna/bfad_fwimg.c
> --- linux-2.6.32-rc4-orig/drivers/net/bna/bfad_fwimg.c	1969-12-31 16:00:00.000000000 -0800
> +++ linux-2.6.32-rc4-mod/drivers/net/bna/bfad_fwimg.c	2009-10-16 10:30:53.222438000 -0700
> @@ -0,0 +1,102 @@
> +/*
> + * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
> + * All rights reserved
> + * www.brocade.com
> + *
> + * Linux network driver for Brocade Converged Network Adapter.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License (GPL) Version 2 as
> + * published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + */
> +/*
> + * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
> + * All rights reserved
> + * www.brocade.com
> + *
> + * See LICENSE.bna for copyright and licensing details.
> + */

I suppose this second copyright banner refers to the firmware itself,
which you have correctly separated from the driver.  You should probably
remove it to avoid confusion.

> +/**
> + *  bfad_fwimg.c Linux driver PCI interface module.
> + */
> +#include <bfa_os_inc.h>
> +#include <defs/bfa_defs_version.h>
> +#include <defs/bfa_defs_pci.h>
> +#include <linux/errno.h>
> +#include <linux/sched.h>
> +#include <linux/init.h>
> +#include <linux/fs.h>
> +#include <asm/uaccess.h>
> +#include <asm/fcntl.h>
> +#include <linux/pci.h>
> +#include <linux/firmware.h>
> +#include <bfa_fwimg_priv.h>
> +
> +u32 bfi_image_ct_size;
> +u32 bfi_image_cb_size;
> +u32 *bfi_image_ct;
> +u32 *bfi_image_cb;
> +
> +
> +#define	BFAD_FW_FILE_CT	"ctfw.bin"
> +#define	BFAD_FW_FILE_CB	"cbfw.bin"
> +
> +u32 *
> +bfad_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
> +			u32 *bfi_image_size, char *fw_name)
> +{
> +	const struct firmware *fw;
> +
> +	if (request_firmware(&fw, fw_name, &pdev->dev)) {
> +		printk(KERN_ALERT "Can't locate firmware %s\n", fw_name);
> +		goto error;
> +	}
> +
> +	*bfi_image = vmalloc(fw->size);
> +	if (NULL == *bfi_image) {
> +		printk(KERN_ALERT "Fail to allocate buffer for fw image "
> +			"size=%x!\n", (u32) fw->size);
> +		goto error;
> +	}
> +
> +	memcpy(*bfi_image, fw->data, fw->size);

This makes a completely pointless copy and then leaks the original
version.  Get rid of the copy and stash the struct firmware pointer to
be freed later.

[...]
> diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bnad_ethtool.c linux-2.6.32-rc4-mod/drivers/net/bna/bnad_ethtool.c
> --- linux-2.6.32-rc4-orig/drivers/net/bna/bnad_ethtool.c	1969-12-31 16:00:00.000000000 -0800
> +++ linux-2.6.32-rc4-mod/drivers/net/bna/bnad_ethtool.c	2009-10-16 10:30:53.269441000 -0700
[...]
> +static int bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
> +{
> +	struct bnad *bnad = netdev_priv(netdev);
> +	struct bna_port_param port_param;
> +
> +	bnad_lock();
> +	spin_lock_irq(&bnad->priv_lock);
> +	bna_port_param_get(bnad->priv, &port_param);
> +	spin_unlock_irq(&bnad->priv_lock);
> +
> +	if (port_param.speed == BNA_LINK_SPEED_10Gbps) {
> +		cmd->supported = SUPPORTED_10000baseT_Full;
> +		cmd->advertising = ADVERTISED_10000baseT_Full;

10GBASE-R and twinax are not 10GBASE-T!

> +	}
> +
> +	if (port_param.autoneg) {
> +		cmd->supported |= SUPPORTED_Autoneg;
> +		cmd->advertising |= ADVERTISED_Autoneg;
> +		cmd->autoneg = AUTONEG_ENABLE;

But you don't support autonegotiation.

[...]
> +/* XXX use get_sset_count */
> +static int bnad_get_stats_count(struct net_device *netdev)
[...]

Yes, delete this function.

I didn't look further.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

