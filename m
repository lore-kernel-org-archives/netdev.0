From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 4/4] mlxsw: Introduce Mellanox SwitchX-2 ASIC
 support
Date: Thu, 23 Jul 2015 21:42:53 +0200
Message-ID: <20150723194253.GB17136@nanopsycho.orion>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <1437666216-3149-5-git-send-email-jiri@resnulli.us>
 <55B12232.1020000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com, tgraf@suug.ch,
	ast@plumgrid.com, jhs@mojatatu.com, daniel@iogearbox.net,
	john.fastabend@gmail.com, simon.horman@netronome.com,
	linville@tuxdriver.com, andy@greyhouse.net,
	shm@cumulusnetworks.com, nhorman@tuxdriver.com,
	Jiri Pirko <jiri@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35297 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbbGWTm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 15:42:57 -0400
Received: by wibxm9 with SMTP id xm9so222904830wib.0
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 12:42:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55B12232.1020000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 23, 2015 at 07:19:46PM CEST, alexander.duyck@gmail.com wrote:
>On 07/23/2015 08:43 AM, Jiri Pirko wrote:
>>From: Jiri Pirko <jiri@mellanox.com>
>>
>>Benefit from the previously introduced Mellanox Switch infrastructure and
>>add driver for SwitchX-2 ASIC. Note that this driver is very simple now.
>>It implements bare minimum for getting device to work on slow-path.
>>Fast-path offload functionality is going to be added soon.
>>
>>Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>>Signed-off-by: Elad Raz <eladr@mellanox.com>
>>---
>>  drivers/net/ethernet/mellanox/mlxsw/Kconfig    |   11 +
>>  drivers/net/ethernet/mellanox/mlxsw/Makefile   |    2 +
>>  drivers/net/ethernet/mellanox/mlxsw/core.h     |    2 +
>>  drivers/net/ethernet/mellanox/mlxsw/pci.c      |    3 +
>>  drivers/net/ethernet/mellanox/mlxsw/pci.h      |    1 +
>>  drivers/net/ethernet/mellanox/mlxsw/port.h     |    4 +
>>  drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1541 ++++++++++++++++++++++++
>>  drivers/net/ethernet/mellanox/mlxsw/txheader.h |   80 ++
>>  8 files changed, 1644 insertions(+)
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/switchx2.c
>>  create mode 100644 drivers/net/ethernet/mellanox/mlxsw/txheader.h
>>
>
><snip>
>
>>diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
>>new file mode 100644
>>index 0000000..15dc53b
>>--- /dev/null
>>+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
>>@@ -0,0 +1,1541 @@
>>+/*
>>+ * drivers/net/ethernet/mellanox/mlxsw/switchx2.c
>>+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
>>+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
>>+ * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
>>+ * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
>>+ *
>>+ * Redistribution and use in source and binary forms, with or without
>>+ * modification, are permitted provided that the following conditions are met:
>>+ *
>>+ * 1. Redistributions of source code must retain the above copyright
>>+ *    notice, this list of conditions and the following disclaimer.
>>+ * 2. Redistributions in binary form must reproduce the above copyright
>>+ *    notice, this list of conditions and the following disclaimer in the
>>+ *    documentation and/or other materials provided with the distribution.
>>+ * 3. Neither the names of the copyright holders nor the names of its
>>+ *    contributors may be used to endorse or promote products derived from
>>+ *    this software without specific prior written permission.
>>+ *
>>+ * Alternatively, this software may be distributed under the terms of the
>>+ * GNU General Public License ("GPL") version 2 as published by the Free
>>+ * Software Foundation.
>>+ *
>>+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
>>+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
>>+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
>>+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
>>+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
>>+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
>>+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
>>+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
>>+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
>>+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
>>+ * POSSIBILITY OF SUCH DAMAGE.
>>+ */
>>+
>>+#include <linux/kernel.h>
>>+#include <linux/module.h>
>>+#include <linux/types.h>
>>+#include <linux/netdevice.h>
>>+#include <linux/etherdevice.h>
>>+#include <linux/slab.h>
>>+#include <linux/device.h>
>>+#include <linux/skbuff.h>
>>+#include <linux/if_vlan.h>
>>+#include <net/switchdev.h>
>>+#include <generated/utsrelease.h>
>>+
>>+#include "core.h"
>>+#include "reg.h"
>>+#include "port.h"
>>+#include "trap.h"
>>+#include "txheader.h"
>>+
>>+static const char mlxsw_sx_driver_name[] = "mlxsw_switchx2";
>>+static const char mlxsw_sx_driver_version[] = "1.0";
>>+
>>+struct mlxsw_sx_port;
>>+
>>+#define MLXSW_SW_HW_ID_LEN 6
>>+
>>+struct mlxsw_sx {
>>+	struct mlxsw_sx_port **ports;
>>+	struct mlxsw_core *core;
>>+	const struct mlxsw_bus_info *bus_info;
>>+	u8 hw_id[MLXSW_SW_HW_ID_LEN];
>>+};
>>+
>>+struct mlxsw_sx_port_pcpu_stats {
>>+	u64			rx_packets;
>>+	u64			rx_bytes;
>>+	u64			tx_packets;
>>+	u64			tx_bytes;
>>+	struct u64_stats_sync	syncp;
>>+	u32			tx_dropped;
>>+};
>>+
>
>It seems like this is the second time I have seen someone have to invent a
>new pcpu stats to add tx_dropped.  Maybe you should look at adding tx_dropped
>to pcpu_sw_netstats and just use that.

I don't mind doing that. Multiple drivers use custom stat structures.
We can easily change that into some common structure if needed.
