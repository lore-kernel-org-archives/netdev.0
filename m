From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 05/13] net: ethernet: aquantia: Support for
 NIC-specific code
Date: Fri, 13 Jan 2017 18:00:36 -0800
Message-ID: <3dfe11ac-4215-21d0-2242-7a4ad6157e56@gmail.com>
References: <cover.1484283610.git.vomlehn@texas.net>
 <5e87af3b0effb96698d0c085366b1ba9320a6305.1484283610.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36703 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750963AbdANCAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 21:00:41 -0500
Received: by mail-io0-f193.google.com with SMTP id q20so7315541ioi.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 18:00:40 -0800 (PST)
In-Reply-To: <5e87af3b0effb96698d0c085366b1ba9320a6305.1484283610.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 09:02 PM, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
> 
> Add support for code specific to the Atlantic NIC.
> 
> Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
> Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
> Signed-off-by: David M. VomLehn <vomlehn@texas.net>
> ---
>  drivers/net/ethernet/aquantia/aq_main.c         | 291 ++++++++
>  drivers/net/ethernet/aquantia/aq_main.h         |  17 +
>  drivers/net/ethernet/aquantia/aq_nic.c          | 910 ++++++++++++++++++++++++
>  drivers/net/ethernet/aquantia/aq_nic.h          | 108 +++
>  drivers/net/ethernet/aquantia/aq_nic_internal.h |  46 ++
>  5 files changed, 1372 insertions(+)
>  create mode 100644 drivers/net/ethernet/aquantia/aq_main.c
>  create mode 100644 drivers/net/ethernet/aquantia/aq_main.h
>  create mode 100644 drivers/net/ethernet/aquantia/aq_nic.c
>  create mode 100644 drivers/net/ethernet/aquantia/aq_nic.h
>  create mode 100644 drivers/net/ethernet/aquantia/aq_nic_internal.h
> 
> diff --git a/drivers/net/ethernet/aquantia/aq_main.c b/drivers/net/ethernet/aquantia/aq_main.c
> new file mode 100644
> index 0000000..18a6012
> --- /dev/null
> +++ b/drivers/net/ethernet/aquantia/aq_main.c
> @@ -0,0 +1,291 @@
> +/*
> + * aQuantia Corporation Network Driver
> + * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + */
> +
> +/* File aq_main.c: Main file for aQuantia Linux driver. */
> +
> +#include "aq_main.h"
> +#include "aq_nic.h"
> +#include "aq_pci_func.h"
> +#include "aq_ethtool.h"
> +#include "hw_atl/hw_atl_a0.h"
> +#include "hw_atl/hw_atl_b0.h"
> +
> +#include <linux/netdevice.h>
> +#include <linux/module.h>
> +
> +static const struct pci_device_id aq_pci_tbl[] = {
> +	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_0001), },
> +	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D100), },
> +	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D107), },
> +	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D108), },
> +	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D109), },
> +	{}
> +};
> +
> +MODULE_DEVICE_TABLE(pci, aq_pci_tbl);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_VERSION(AQ_CFG_DRV_VERSION);
> +MODULE_AUTHOR(AQ_CFG_DRV_AUTHOR);
> +MODULE_DESCRIPTION(AQ_CFG_DRV_DESC);

Inline the defines directly into that file, and these typically go at
the end of the file.

> +
> +static struct aq_hw_ops *aq_pci_probe_get_hw_ops_by_id(struct pci_dev *pdev)
> +{
> +	struct aq_hw_ops *ops = NULL;
> +	int err = 0;
> +
> +	ops = hw_atl_a0_get_ops_by_id(pdev);
> +	if (ops) {
> +		err = 0;
> +		goto err_exit;
> +	}

Should not that come from the pci_device_id .driver_data structure?

> +
> +	ops = hw_atl_b0_get_ops_by_id(pdev);
> +	if (ops) {
> +		err = 0;
> +		goto err_exit;
> +	}
> +
> +/* the H/W was not recognized */
> +	err = -EFAULT;
> +
> +err_exit:
> +	return ops;
> +}
> +
> +static int aq_ndev_open(struct net_device *ndev)
> +{
> +	struct aq_nic_s *aq_nic = NULL;
> +	int err = 0;
> +
> +	aq_nic = aq_nic_alloc_hot(ndev);
> +	if (!aq_nic) {
> +		err = -ENOMEM;
> +		goto err_exit;
> +	}
> +	err = aq_nic_init(aq_nic);
> +	if (err < 0)
> +		goto err_exit;
> +	err = aq_nic_start(aq_nic);
> +	if (err < 0)
> +		goto err_exit;
> +
> +err_exit:
> +	if (err < 0) {

Just make the error label be taken only if there is an error instead of
checking here again for a negative error code.

> +		if (aq_nic)
> +			aq_nic_deinit(aq_nic);
> +	}
> +	return err;
> +}
> +
> +static int aq_ndev_close(struct net_device *ndev)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);

No casting needed.

> +
> +	aq_nic_stop(aq_nic);
> +	aq_nic_deinit(aq_nic);
> +	aq_nic_free_hot_resources(aq_nic);
> +
> +	return 0;
> +}
> +
> +static int aq_ndev_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +	int err = 0;
> +
> +	err = aq_nic_xmit(aq_nic, skb);
> +	if (err < 0)
> +		goto err_exit;
> +
> +err_exit:
> +	return err;

Just inline the contents of aq_nic_xmit(), this function serves nothing
useful here.

> +}
> +
> +static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +	int err = 0;
> +
> +	if (new_mtu == ndev->mtu) {
> +		err = 0;
> +		goto err_exit;
> +	}
> +	if (new_mtu < 68) {
> +		err = -EINVAL;
> +		goto err_exit;
> +	}

What's so special about 68 here?

> +	err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);

Why do not need to include ETH_HLEN here?

> +	if (err < 0)
> +		goto err_exit;
> +	ndev->mtu = new_mtu;
> +
> +	if (netif_running(ndev)) {
> +		aq_ndev_close(ndev);
> +		aq_ndev_open(ndev);
> +	}
> +
> +err_exit:
> +	return err;
> +}
> +
> +static int aq_ndev_set_features(struct net_device *ndev,
> +				netdev_features_t features)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +	struct aq_nic_cfg_s *aq_cfg = aq_nic_get_cfg(aq_nic);
> +	bool is_lro = false;
> +
> +	if (aq_cfg->hw_features & NETIF_F_LRO) {
> +		is_lro = features & NETIF_F_LRO;
> +
> +		if (aq_cfg->is_lro != is_lro) {
> +			aq_cfg->is_lro = is_lro;
> +
> +			if (netif_running(ndev)) {
> +				aq_ndev_close(ndev);
> +				aq_ndev_open(ndev);
> +			}

Can this be made less disruptive to the network interface?

> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int aq_ndev_set_mac_address(struct net_device *ndev, void *addr)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +	int err = 0;
> +
> +	err = eth_mac_addr(ndev, addr);
> +	if (err < 0)
> +		goto err_exit;
> +	err = aq_nic_set_mac(aq_nic, ndev);
> +	if (err < 0)
> +		goto err_exit;
> +
> +err_exit:
> +	return err;
> +}
> +
> +static void aq_ndev_set_multicast_settings(struct net_device *ndev)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +	int err = 0;
> +
> +	err = aq_nic_set_packet_filter(aq_nic, ndev->flags);
> +	if (err < 0)
> +		goto err_exit;
> +
> +	if (netdev_mc_count(ndev)) {
> +		err = aq_nic_set_multicast_list(aq_nic, ndev);
> +		if (err < 0)
> +			goto err_exit;
> +	}

That's not enough, you need to deal with Unicast address filtering,
promiscuous mode, and if you run out of space in your multicast address
filter.
-- 
Florian
