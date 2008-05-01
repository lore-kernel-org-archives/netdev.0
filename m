From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 08/13] QLogic VNIC: sysfs interface implementation for
 the driver
Date: Thu, 1 May 2008 07:56:06 -0700
Message-ID: <20080501075606.4963afa3@extreme>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430171955.31725.7771.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, amar.mudrankit@qlogic.com,
	poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37380 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505AbYEAO4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 10:56:12 -0400
In-Reply-To: <20080430171955.31725.7771.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Apr 2008 22:49:55 +0530
Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:

> From: Amar Mudrankit <amar.mudrankit@qlogic.com>
> 
> The sysfs interface for the QLogic VNIC driver is implemented through
> this patch.
> 
> Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
> Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
> ---
> 
>  drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c | 1127 +++++++++++++++++++++++++++
>  drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h |   62 +
>  2 files changed, 1189 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
>  create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h
> 
> diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> new file mode 100644
> index 0000000..7e70b0c
> --- /dev/null
> +++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> @@ -0,0 +1,1127 @@
> +/*
> + * Copyright (c) 2006 QLogic, Inc.  All rights reserved.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
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
> +#include <linux/parser.h>
> +#include <linux/netdevice.h>
> +#include <linux/if.h>
> +
> +#include "vnic_util.h"
> +#include "vnic_config.h"
> +#include "vnic_ib.h"
> +#include "vnic_viport.h"
> +#include "vnic_main.h"
> +#include "vnic_stats.h"
> +
> +/*
> + * target eiocs are added by writing
> + *
> + * ioc_guid=<EIOC GUID>,dgid=<dest GID>,pkey=<P_key>,name=<interface_name>
> + * to the create_primary  sysfs attribute.
> + */
> +enum {
> +	VNIC_OPT_ERR = 0,
> +	VNIC_OPT_IOC_GUID = 1 << 0,
> +	VNIC_OPT_DGID = 1 << 1,
> +	VNIC_OPT_PKEY = 1 << 2,
> +	VNIC_OPT_NAME = 1 << 3,
> +	VNIC_OPT_INSTANCE = 1 << 4,
> +	VNIC_OPT_RXCSUM = 1 << 5,
> +	VNIC_OPT_TXCSUM = 1 << 6,
> +	VNIC_OPT_HEARTBEAT = 1 << 7,
> +	VNIC_OPT_IOC_STRING = 1 << 8,
> +	VNIC_OPT_IB_MULTICAST = 1 << 9,
> +	VNIC_OPT_ALL = (VNIC_OPT_IOC_GUID |
> +			VNIC_OPT_DGID | VNIC_OPT_NAME | VNIC_OPT_PKEY),
> +};
> +
> +static match_table_t vnic_opt_tokens = {
> +	{VNIC_OPT_IOC_GUID, "ioc_guid=%s"},
> +	{VNIC_OPT_DGID, "dgid=%s"},
> +	{VNIC_OPT_PKEY, "pkey=%x"},
> +	{VNIC_OPT_NAME, "name=%s"},
> +	{VNIC_OPT_INSTANCE, "instance=%d"},
> +	{VNIC_OPT_RXCSUM, "rx_csum=%s"},
> +	{VNIC_OPT_TXCSUM, "tx_csum=%s"},
> +	{VNIC_OPT_HEARTBEAT, "heartbeat=%d"},
> +	{VNIC_OPT_IOC_STRING, "ioc_string=\"%s"},
> +	{VNIC_OPT_IB_MULTICAST, "ib_multicast=%s"},
> +	{VNIC_OPT_ERR, NULL}
> +};
> 

NO

1. Most of this shouldn't be done via sysfs (rx_csum, tx_csum, ...)

2. Sysfs is one value per file not name=value

