From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 11/13] net: ethernet: aquantia: Ethtool support
Date: Fri, 13 Jan 2017 17:47:15 -0800
Message-ID: <a47675a9-8878-5a00-9adc-5dcac909c8d3@gmail.com>
References: <cover.1484283610.git.vomlehn@texas.net>
 <b2236a13fcf9ac65f15cfc084de670948517e003.1484283610.git.vomlehn@texas.net>
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
Received: from mail-io0-f194.google.com ([209.85.223.194]:35578 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdANBrV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 20:47:21 -0500
Received: by mail-io0-f194.google.com with SMTP id m98so7325128iod.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 17:47:18 -0800 (PST)
In-Reply-To: <b2236a13fcf9ac65f15cfc084de670948517e003.1484283610.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 09:02 PM, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
> 
> Add the driver interfaces required for support by the ethtool utility.
> 
> Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
> Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
> Signed-off-by: David M. VomLehn <vomlehn@texas.net>
> ---
>  drivers/net/ethernet/aquantia/aq_ethtool.c | 250 +++++++++++++++++++++++++++++
>  drivers/net/ethernet/aquantia/aq_ethtool.h |  19 +++
>  2 files changed, 269 insertions(+)
>  create mode 100644 drivers/net/ethernet/aquantia/aq_ethtool.c
>  create mode 100644 drivers/net/ethernet/aquantia/aq_ethtool.h
> 
> diff --git a/drivers/net/ethernet/aquantia/aq_ethtool.c b/drivers/net/ethernet/aquantia/aq_ethtool.c
> new file mode 100644
> index 0000000..f11bdb1
> --- /dev/null
> +++ b/drivers/net/ethernet/aquantia/aq_ethtool.c
> @@ -0,0 +1,250 @@
> +/*
> + * aQuantia Corporation Network Driver
> + * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + */
> +
> +/* File aq_ethtool.c: Definition of ethertool related functions. */
> +
> +#include "aq_ethtool.h"
> +#include "aq_nic.h"
> +
> +static void aq_ethtool_get_regs(struct net_device *ndev,
> +				struct ethtool_regs *regs, void *p)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);

netdev_priv() returns a void * which requires no casting, please fix
this through the entire 13 patches.

> +	u32 regs_count = aq_nic_get_regs_count(aq_nic);
> +
> +	memset(p, 0, regs_count * sizeof(u32));
> +	aq_nic_get_regs(aq_nic, regs, p);
> +}
> +
> +static int aq_ethtool_get_regs_len(struct net_device *ndev)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +	u32 regs_count = aq_nic_get_regs_count(aq_nic);
> +
> +	return regs_count * sizeof(u32);
> +}
> +
> +static u32 aq_ethtool_get_link(struct net_device *ndev)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +
> +	return aq_nic_get_link_speed(aq_nic) ? 1U : 0U;

Can you either use PHYLIB to interface to your PHY (which does all the
nice state machine management) or at the very least ethtool_op_get_link()?

> +}
> +
> +static int aq_ethtool_get_settings(struct net_device *ndev,
> +				   struct ethtool_cmd *cmd)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +
> +	cmd->port = PORT_TP;
> +	cmd->transceiver = XCVR_EXTERNAL;
> +
> +	ethtool_cmd_speed_set(cmd, netif_carrier_ok(ndev) ?
> +				aq_nic_get_link_speed(aq_nic) : 0U);
> +
> +	cmd->duplex = DUPLEX_FULL;
> +	aq_nic_get_link_settings(aq_nic, cmd);
> +	return 0;

Consider switching to the new ksettings API and filling in a bit more
information like cmd->autoneg?

> +}
> +
> +static int aq_ethtool_set_settings(struct net_device *ndev,
> +				   struct ethtool_cmd *cmd)
> +{
> +	struct aq_nic_s *aq_nic = (struct aq_nic_s *)netdev_priv(ndev);
> +
> +	return aq_nic_set_link_settings(aq_nic, cmd);
> +}
> +
> +static const char aq_ethtool_stat_names[][ETH_GSTRING_LEN] = {
> +	"InPackets",
> +	"InUCast",
> +	"InMCast",
> +	"InBCast",
> +	"InErrors",
> +	"OutPackets",
> +	"OutUCast",
> +	"OutMCast",
> +	"OutBCast",
> +	"InUCastOctects",
> +	"OutUCastOctects",
> +	"InMCastOctects",
> +	"OutMCastOctects",
> +	"InBCastOctects",
> +	"OutBCastOctects",
> +	"InOctects",
> +	"OutOctects",
> +	"InPacketsDma",
> +	"OutPacketsDma",
> +	"InOctetsDma",
> +	"OutOctetsDma",
> +	"InDroppedDma",
> +	"Queue[0] InPackets",
> +	"Queue[0] OutPackets",
> +	"Queue[0] InJumboPackets",
> +	"Queue[0] InLroPackets",
> +	"Queue[0] InErrors",
> +#if 1 < AQ_CFG_VECS_DEF

Yoda notations are usually frowned upon. Instead of making this decision
here, can you push that down to the actual function reading the statistics?

> +static void aq_ethtool_get_strings(struct net_device *ndev,
> +				   u32 stringset, u8 *data)
> +{

You need to check that stringset == ETH_SS_STATS here since that's the
only thing you support. ethtool usually does not do it if the ioctl()
returning the data does not exist, but other bogus applications might.

> +	memcpy(data, *aq_ethtool_stat_names, sizeof(aq_ethtool_stat_names));
> +}
> +
> +static int aq_ethtool_get_sset_count(struct net_device *ndev, int stringset)
> +{

Same here.

> +	return ARRAY_SIZE(aq_ethtool_stat_names);

> +#ifndef AQ_ETHTOOL_H
> +#define AQ_ETHTOOL_H
> +
> +#include "aq_common.h"
> +
> +extern const struct ethtool_ops aq_ethtool_ops;

The extern does not appear necessary here. Alternatively you may define
all the ethtool function pointers in this header file, but leave the
struct ethtool_ops in the main driver file which registers them at the
time of the netdev creation, up to you.

> +
> +#endif /* AQ_ETHTOOL_H */
> 


-- 
Florian
