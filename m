From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] mlxsw: Introduce Mellanox SwitchX-2 ASIC support
Date: Thu, 23 Jul 2015 17:43:36 +0200
Message-ID: <1437666216-3149-5-git-send-email-jiri@resnulli.us>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com, tgraf@suug.ch,
	ast@plumgrid.com, jhs@mojatatu.com, daniel@iogearbox.net,
	john.fastabend@gmail.com, simon.horman@netronome.com,
	linville@tuxdriver.com, andy@greyhouse.net,
	shm@cumulusnetworks.com, nhorman@tuxdriver.com,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35635 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbbGWPnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 11:43:55 -0400
Received: by wibxm9 with SMTP id xm9so214317902wib.0
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 08:43:53 -0700 (PDT)
In-Reply-To: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the previously introduced Mellanox Switch infrastructure and
add driver for SwitchX-2 ASIC. Note that this driver is very simple now.
It implements bare minimum for getting device to work on slow-path.
Fast-path offload functionality is going to be added soon.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig    |   11 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile   |    2 +
 drivers/net/ethernet/mellanox/mlxsw/core.h     |    2 +
 drivers/net/ethernet/mellanox/mlxsw/pci.c      |    3 +
 drivers/net/ethernet/mellanox/mlxsw/pci.h      |    1 +
 drivers/net/ethernet/mellanox/mlxsw/port.h     |    4 +
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1541 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/txheader.h |   80 ++
 8 files changed, 1644 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/switchx2.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/txheader.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index 1385f2c..8d1080d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -19,3 +19,14 @@ config MLXSW_PCI
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called mlxsw_pci.
+
+config MLXSW_SWITCHX2
+	tristate "Mellanox Technologies SwitchX-2 support"
+	depends on MLXSW_CORE && NET_SWITCHDEV
+	default m
+	---help---
+	  This driver supports Mellanox Technologies SwitchX-2 Ethernet
+	  Switch ASICs.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called mlxsw_switchx2.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index 94841c3..0a05f65 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -2,3 +2,5 @@ obj-$(CONFIG_MLXSW_CORE)	+= mlxsw_core.o
 mlxsw_core-objs			:= core.o
 obj-$(CONFIG_MLXSW_PCI)		+= mlxsw_pci.o
 mlxsw_pci-objs			:= pci.o
+obj-$(CONFIG_MLXSW_SWITCHX2)	+= mlxsw_switchx2.o
+mlxsw_switchx2-objs		:= switchx2.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index b6c11d2..fbc94da 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -53,6 +53,8 @@
 #define MODULE_MLXSW_DRIVER_ALIAS(kind)	\
 	MODULE_ALIAS(MLXSW_MODULE_ALIAS_PREFIX kind)
 
+#define MLXSW_DEVICE_KIND_SWITCHX2 "switchx2"
+
 struct mlxsw_core;
 struct mlxsw_driver;
 struct mlxsw_bus;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 8371e08..de8ff32 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -55,6 +55,7 @@
 static const char mlxsw_pci_driver_name[] = "mlxsw_pci";
 
 static const struct pci_device_id mlxsw_pci_id_table[] = {
+	{PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_SWITCHX2), 0},
 	{0, }
 };
 
@@ -63,6 +64,8 @@ static struct dentry *mlxsw_pci_dbg_root;
 static const char *mlxsw_pci_device_kind_get(const struct pci_device_id *id)
 {
 	switch (id->device) {
+	case PCI_DEVICE_ID_MELLANOX_SWITCHX2:
+		return MLXSW_DEVICE_KIND_SWITCHX2;
 	default:
 		BUG();
 	}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
index 6176a93..887af84 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -39,6 +39,7 @@
 
 #include "item.h"
 
+#define PCI_DEVICE_ID_MELLANOX_SWITCHX2	0xc738
 #define MLXSW_PCI_BAR0_SIZE		(1024 * 1024) /* 1MB */
 #define MLXSW_PCI_PAGE_SIZE		4096
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/port.h b/drivers/net/ethernet/mellanox/mlxsw/port.h
index e626231..795b21c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/port.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/port.h
@@ -51,6 +51,10 @@
 #define MLXSW_PORT_MAX_PHY_PORTS	0x40
 #define MLXSW_PORT_MAX_PORTS		MLXSW_PORT_MAX_PHY_PORTS
 
+#define MLXSW_PORT_DEVID_BITS_OFFSET	10
+#define MLXSW_PORT_PHY_BITS_OFFSET	4
+#define MLXSW_PORT_PHY_BITS_MASK	(MLXSW_PORT_MAX_PHY_PORTS - 1)
+
 #define MLXSW_PORT_CPU_PORT		0x0
 
 enum mlxsw_port_admin_status {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
new file mode 100644
index 0000000..15dc53b
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -0,0 +1,1541 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
+ * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/slab.h>
+#include <linux/device.h>
+#include <linux/skbuff.h>
+#include <linux/if_vlan.h>
+#include <net/switchdev.h>
+#include <generated/utsrelease.h>
+
+#include "core.h"
+#include "reg.h"
+#include "port.h"
+#include "trap.h"
+#include "txheader.h"
+
+static const char mlxsw_sx_driver_name[] = "mlxsw_switchx2";
+static const char mlxsw_sx_driver_version[] = "1.0";
+
+struct mlxsw_sx_port;
+
+#define MLXSW_SW_HW_ID_LEN 6
+
+struct mlxsw_sx {
+	struct mlxsw_sx_port **ports;
+	struct mlxsw_core *core;
+	const struct mlxsw_bus_info *bus_info;
+	u8 hw_id[MLXSW_SW_HW_ID_LEN];
+};
+
+struct mlxsw_sx_port_pcpu_stats {
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+	u32			tx_dropped;
+};
+
+struct mlxsw_sx_port {
+	struct net_device *dev;
+	struct mlxsw_sx_port_pcpu_stats __percpu *pcpu_stats;
+	struct mlxsw_sx *mlxsw_sx;
+	u8 local_port;
+};
+
+/* tx_hdr_version
+ * Tx header version.
+ * Must be set to 0.
+ */
+MLXSW_ITEM32(tx, hdr, version, 0x00, 28, 4);
+
+/* tx_hdr_ctl
+ * Packet control type.
+ * 0 - Ethernet control (e.g. EMADs, LACP)
+ * 1 - Ethernet data
+ */
+MLXSW_ITEM32(tx, hdr, ctl, 0x00, 26, 2);
+
+/* tx_hdr_proto
+ * Packet protocol type. Must be set to 1 (Ethernet).
+ */
+MLXSW_ITEM32(tx, hdr, proto, 0x00, 21, 3);
+
+/* tx_hdr_etclass
+ * Egress TClass to be used on the egress device on the egress port.
+ * The MSB is specified in the 'ctclass3' field.
+ * Range is 0-15, where 15 is the highest priority.
+ */
+MLXSW_ITEM32(tx, hdr, etclass, 0x00, 18, 3);
+
+/* tx_hdr_swid
+ * Switch partition ID.
+ */
+MLXSW_ITEM32(tx, hdr, swid, 0x00, 12, 3);
+
+/* tx_hdr_port_mid
+ * Destination local port for unicast packets.
+ * Destination multicast ID for multicast packets.
+ *
+ * Control packets are directed to a specific egress port, while data
+ * packets are transmitted through the CPU port (0) into the switch partition,
+ * where forwarding rules are applied.
+ */
+MLXSW_ITEM32(tx, hdr, port_mid, 0x04, 16, 16);
+
+/* tx_hdr_ctclass3
+ * See field 'etclass'.
+ */
+MLXSW_ITEM32(tx, hdr, ctclass3, 0x04, 14, 1);
+
+/* tx_hdr_rdq
+ * RDQ for control packets sent to remote CPU.
+ * Must be set to 0x1F for EMADs, otherwise 0.
+ */
+MLXSW_ITEM32(tx, hdr, rdq, 0x04, 9, 5);
+
+/* tx_hdr_cpu_sig
+ * Signature control for packets going to CPU. Must be set to 0.
+ */
+MLXSW_ITEM32(tx, hdr, cpu_sig, 0x04, 0, 9);
+
+/* tx_hdr_sig
+ * Stacking protocl signature. Must be set to 0xE0E0.
+ */
+MLXSW_ITEM32(tx, hdr, sig, 0x0C, 16, 16);
+
+/* tx_hdr_stclass
+ * Stacking TClass.
+ */
+MLXSW_ITEM32(tx, hdr, stclass, 0x0C, 13, 3);
+
+/* tx_hdr_emad
+ * EMAD bit. Must be set for EMADs.
+ */
+MLXSW_ITEM32(tx, hdr, emad, 0x0C, 5, 1);
+
+/* tx_hdr_type
+ * 0 - Data packets
+ * 6 - Control packets
+ */
+MLXSW_ITEM32(tx, hdr, type, 0x0C, 0, 4);
+
+static void mlxsw_sx_txhdr_construct(struct sk_buff *skb,
+				     const struct mlxsw_tx_info *tx_info)
+{
+	char *txhdr = skb_push(skb, MLXSW_TXHDR_LEN);
+	bool is_emad = tx_info->is_emad;
+
+	memset(txhdr, 0, MLXSW_TXHDR_LEN);
+
+	/* We currently set default values for the egress tclass (QoS). */
+	mlxsw_tx_hdr_version_set(txhdr, MLXSW_TXHDR_VERSION_0);
+	mlxsw_tx_hdr_ctl_set(txhdr, MLXSW_TXHDR_ETH_CTL);
+	mlxsw_tx_hdr_proto_set(txhdr, MLXSW_TXHDR_PROTO_ETH);
+	mlxsw_tx_hdr_etclass_set(txhdr, is_emad ? MLXSW_TXHDR_ETCLASS_6 :
+						  MLXSW_TXHDR_ETCLASS_5);
+	mlxsw_tx_hdr_swid_set(txhdr, 0);
+	mlxsw_tx_hdr_port_mid_set(txhdr, tx_info->local_port);
+	mlxsw_tx_hdr_ctclass3_set(txhdr, MLXSW_TXHDR_CTCLASS3);
+	mlxsw_tx_hdr_rdq_set(txhdr, is_emad ? MLXSW_TXHDR_RDQ_EMAD :
+					      MLXSW_TXHDR_RDQ_OTHER);
+	mlxsw_tx_hdr_cpu_sig_set(txhdr, MLXSW_TXHDR_CPU_SIG);
+	mlxsw_tx_hdr_sig_set(txhdr, MLXSW_TXHDR_SIG);
+	mlxsw_tx_hdr_stclass_set(txhdr, MLXSW_TXHDR_STCLASS_NONE);
+	mlxsw_tx_hdr_emad_set(txhdr, is_emad ? MLXSW_TXHDR_EMAD :
+					       MLXSW_TXHDR_NOT_EMAD);
+	mlxsw_tx_hdr_type_set(txhdr, MLXSW_TXHDR_TYPE_CONTROL);
+}
+
+static int mlxsw_sx_port_admin_status_set(struct mlxsw_sx_port *mlxsw_sx_port,
+					  bool is_up)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char paos_pl[MLXSW_REG_PAOS_LEN];
+
+	mlxsw_reg_paos_pack(paos_pl, mlxsw_sx_port->local_port,
+			    is_up ? MLXSW_PORT_ADMIN_STATUS_UP :
+			    MLXSW_PORT_ADMIN_STATUS_DOWN);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(paos), paos_pl);
+}
+
+static int mlxsw_sx_port_oper_status_get(struct mlxsw_sx_port *mlxsw_sx_port,
+					 bool *p_is_up)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char paos_pl[MLXSW_REG_PAOS_LEN];
+	u8 oper_status;
+	int err;
+
+	mlxsw_reg_paos_pack(paos_pl, mlxsw_sx_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(paos), paos_pl);
+	if (err)
+		return err;
+	oper_status = mlxsw_reg_paos_oper_status_get(paos_pl);
+	*p_is_up = oper_status == MLXSW_PORT_ADMIN_STATUS_UP ? true : false;
+	return 0;
+}
+
+static int mlxsw_sx_port_mtu_set(struct mlxsw_sx_port *mlxsw_sx_port, u16 mtu)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char pmtu_pl[MLXSW_REG_PMTU_LEN];
+	int max_mtu;
+	int err;
+
+	mtu += MLXSW_TXHDR_LEN + ETH_HLEN;
+	mlxsw_reg_pmtu_pack(pmtu_pl, mlxsw_sx_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(pmtu), pmtu_pl);
+	if (err)
+		return err;
+	max_mtu = mlxsw_reg_pmtu_max_mtu_get(pmtu_pl);
+
+	if (mtu > max_mtu)
+		return -EINVAL;
+
+	mlxsw_reg_pmtu_pack(pmtu_pl, mlxsw_sx_port->local_port, mtu);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(pmtu), pmtu_pl);
+}
+
+static int mlxsw_sx_port_swid_set(struct mlxsw_sx_port *mlxsw_sx_port, u8 swid)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char pspa_pl[MLXSW_REG_PSPA_LEN];
+
+	mlxsw_reg_pspa_pack(pspa_pl, swid, mlxsw_sx_port->local_port);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(pspa), pspa_pl);
+}
+
+static int mlxsw_sx_port_module_check(struct mlxsw_sx_port *mlxsw_sx_port,
+				      bool *p_usable)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char pmlp_pl[MLXSW_REG_PMLP_LEN];
+	int err;
+
+	mlxsw_reg_pmlp_pack(pmlp_pl, mlxsw_sx_port->local_port);
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(pmlp), pmlp_pl);
+	if (err)
+		return err;
+	*p_usable = mlxsw_reg_pmlp_width_get(pmlp_pl) ? true : false;
+	return 0;
+}
+
+static int mlxsw_sx_port_open(struct net_device *dev)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	int err;
+
+	err = mlxsw_sx_port_admin_status_set(mlxsw_sx_port, true);
+	if (err)
+		return err;
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int mlxsw_sx_port_stop(struct net_device *dev)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	int err;
+
+	netif_stop_queue(dev);
+	err = mlxsw_sx_port_admin_status_set(mlxsw_sx_port, false);
+	if (err)
+		return err;
+	return 0;
+}
+
+static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	struct mlxsw_sx_port_pcpu_stats *pcpu_stats;
+	const struct mlxsw_tx_info tx_info = {
+		.local_port = mlxsw_sx_port->local_port,
+		.is_emad = false,
+	};
+	int err;
+
+	if (unlikely(skb_headroom(skb) < MLXSW_TXHDR_LEN)) {
+		struct sk_buff *skb_new;
+
+		skb_new = skb_realloc_headroom(skb, MLXSW_TXHDR_LEN);
+		dev_kfree_skb_any(skb);
+		if (!skb_new) {
+			this_cpu_inc(mlxsw_sx_port->pcpu_stats->tx_dropped);
+			return NETDEV_TX_OK;
+		}
+		skb = skb_new;
+	}
+	mlxsw_sx_txhdr_construct(skb, &tx_info);
+	err = mlxsw_core_skb_transmit(mlxsw_sx, skb, &tx_info);
+	if (err == -EAGAIN)
+		return NETDEV_TX_BUSY;
+
+	pcpu_stats = this_cpu_ptr(mlxsw_sx_port->pcpu_stats);
+	u64_stats_update_begin(&pcpu_stats->syncp);
+	pcpu_stats->tx_packets++;
+	pcpu_stats->tx_bytes += skb->len;
+	u64_stats_update_end(&pcpu_stats->syncp);
+
+	return NETDEV_TX_OK;
+}
+
+static int mlxsw_sx_port_change_mtu(struct net_device *dev, int mtu)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	int err;
+
+	err = mlxsw_sx_port_mtu_set(mlxsw_sx_port, mtu);
+	if (err)
+		return err;
+	dev->mtu = mtu;
+	return 0;
+}
+
+static struct rtnl_link_stats64 *
+mlxsw_sx_port_get_stats64(struct net_device *dev,
+			  struct rtnl_link_stats64 *stats)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	struct mlxsw_sx_port_pcpu_stats *p;
+	u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+	u32 tx_dropped = 0;
+	unsigned int start;
+	int i;
+
+	for_each_possible_cpu(i) {
+		p = per_cpu_ptr(mlxsw_sx_port->pcpu_stats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&p->syncp);
+			rx_packets	= p->rx_packets;
+			rx_bytes	= p->rx_bytes;
+			tx_packets	= p->tx_packets;
+			tx_bytes	= p->tx_bytes;
+		} while (u64_stats_fetch_retry_irq(&p->syncp, start));
+
+		stats->rx_packets	+= rx_packets;
+		stats->rx_bytes		+= rx_bytes;
+		stats->tx_packets	+= tx_packets;
+		stats->tx_bytes		+= tx_bytes;
+		/* tx_dropped is u32, updated without syncp protection. */
+		tx_dropped	+= p->tx_dropped;
+	}
+	stats->tx_dropped	= tx_dropped;
+	return stats;
+}
+
+static const struct net_device_ops mlxsw_sx_port_netdev_ops = {
+	.ndo_open		= mlxsw_sx_port_open,
+	.ndo_stop		= mlxsw_sx_port_stop,
+	.ndo_start_xmit		= mlxsw_sx_port_xmit,
+	.ndo_change_mtu		= mlxsw_sx_port_change_mtu,
+	.ndo_get_stats64	= mlxsw_sx_port_get_stats64,
+};
+
+static void mlxsw_sx_port_get_drvinfo(struct net_device *dev,
+				      struct ethtool_drvinfo *drvinfo)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+
+	strlcpy(drvinfo->driver, mlxsw_sx_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, mlxsw_sx_driver_version,
+		sizeof(drvinfo->version));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		 "%d.%d.%d",
+		 mlxsw_sx->bus_info->fw_rev.major,
+		 mlxsw_sx->bus_info->fw_rev.minor,
+		 mlxsw_sx->bus_info->fw_rev.subminor);
+	strlcpy(drvinfo->bus_info, mlxsw_sx->bus_info->device_name,
+		sizeof(drvinfo->bus_info));
+}
+
+struct mlxsw_sx_port_hw_stats {
+	char str[ETH_GSTRING_LEN];
+	u64 (*getter)(char *payload);
+};
+
+static const struct mlxsw_sx_port_hw_stats mlxsw_sx_port_hw_stats[] = {
+	{
+		.str = "a_frames_transmitted_ok",
+		.getter = mlxsw_reg_ppcnt_a_frames_transmitted_ok_get,
+	},
+	{
+		.str = "a_frames_received_ok",
+		.getter = mlxsw_reg_ppcnt_a_frames_received_ok_get,
+	},
+	{
+		.str = "a_frame_check_sequence_errors",
+		.getter = mlxsw_reg_ppcnt_a_frame_check_sequence_errors_get,
+	},
+	{
+		.str = "a_alignment_errors",
+		.getter = mlxsw_reg_ppcnt_a_alignment_errors_get,
+	},
+	{
+		.str = "a_octets_transmitted_ok",
+		.getter = mlxsw_reg_ppcnt_a_octets_transmitted_ok_get,
+	},
+	{
+		.str = "a_octets_received_ok",
+		.getter = mlxsw_reg_ppcnt_a_octets_received_ok_get,
+	},
+	{
+		.str = "a_multicast_frames_xmitted_ok",
+		.getter = mlxsw_reg_ppcnt_a_multicast_frames_xmitted_ok_get,
+	},
+	{
+		.str = "a_broadcast_frames_xmitted_ok",
+		.getter = mlxsw_reg_ppcnt_a_broadcast_frames_xmitted_ok_get,
+	},
+	{
+		.str = "a_multicast_frames_received_ok",
+		.getter = mlxsw_reg_ppcnt_a_multicast_frames_received_ok_get,
+	},
+	{
+		.str = "a_broadcast_frames_received_ok",
+		.getter = mlxsw_reg_ppcnt_a_broadcast_frames_received_ok_get,
+	},
+	{
+		.str = "a_in_range_length_errors",
+		.getter = mlxsw_reg_ppcnt_a_in_range_length_errors_get,
+	},
+	{
+		.str = "a_out_of_range_length_field",
+		.getter = mlxsw_reg_ppcnt_a_out_of_range_length_field_get,
+	},
+	{
+		.str = "a_frame_too_long_errors",
+		.getter = mlxsw_reg_ppcnt_a_frame_too_long_errors_get,
+	},
+	{
+		.str = "a_symbol_error_during_carrier",
+		.getter = mlxsw_reg_ppcnt_a_symbol_error_during_carrier_get,
+	},
+	{
+		.str = "a_mac_control_frames_transmitted",
+		.getter = mlxsw_reg_ppcnt_a_mac_control_frames_transmitted_get,
+	},
+	{
+		.str = "a_mac_control_frames_received",
+		.getter = mlxsw_reg_ppcnt_a_mac_control_frames_received_get,
+	},
+	{
+		.str = "a_unsupported_opcodes_received",
+		.getter = mlxsw_reg_ppcnt_a_unsupported_opcodes_received_get,
+	},
+	{
+		.str = "a_pause_mac_ctrl_frames_received",
+		.getter = mlxsw_reg_ppcnt_a_pause_mac_ctrl_frames_received_get,
+	},
+	{
+		.str = "a_pause_mac_ctrl_frames_xmitted",
+		.getter = mlxsw_reg_ppcnt_a_pause_mac_ctrl_frames_transmitted_get,
+	},
+};
+
+#define MLXSW_SX_PORT_HW_STATS_LEN ARRAY_SIZE(mlxsw_sx_port_hw_stats)
+
+static void mlxsw_sx_port_get_strings(struct net_device *dev,
+				      u32 stringset, u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < MLXSW_SX_PORT_HW_STATS_LEN; i++) {
+			memcpy(p, mlxsw_sx_port_hw_stats[i].str,
+			       ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static void mlxsw_sx_port_get_stats(struct net_device *dev,
+				    struct ethtool_stats *stats, u64 *data)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
+	int i;
+	int err;
+
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sx_port->local_port);
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ppcnt), ppcnt_pl);
+	for (i = 0; i < MLXSW_SX_PORT_HW_STATS_LEN; i++)
+		data[i] = !err ? mlxsw_sx_port_hw_stats[i].getter(ppcnt_pl) : 0;
+}
+
+static int mlxsw_sx_port_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return MLXSW_SX_PORT_HW_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+struct mlxsw_sx_port_link_mode {
+	u32 mask;
+	u32 supported;
+	u32 advertised;
+	u32 speed;
+};
+
+static const struct mlxsw_sx_port_link_mode mlxsw_sx_port_link_mode[] = {
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100BASE_T,
+		.supported	= SUPPORTED_100baseT_Full,
+		.advertised	= ADVERTISED_100baseT_Full,
+		.speed		= 100,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100BASE_TX,
+		.speed		= 100,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_SGMII |
+				  MLXSW_REG_PTYS_ETH_SPEED_1000BASE_KX,
+		.supported	= SUPPORTED_1000baseKX_Full,
+		.advertised	= ADVERTISED_1000baseKX_Full,
+		.speed		= 1000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_10GBASE_T,
+		.supported	= SUPPORTED_10000baseT_Full,
+		.advertised	= ADVERTISED_10000baseT_Full,
+		.speed		= 10000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CX4 |
+				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KX4,
+		.supported	= SUPPORTED_10000baseKX4_Full,
+		.advertised	= ADVERTISED_10000baseKX4_Full,
+		.speed		= 10000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KR |
+				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CR |
+				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_SR |
+				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_ER_LR,
+		.supported	= SUPPORTED_10000baseKR_Full,
+		.advertised	= ADVERTISED_10000baseKR_Full,
+		.speed		= 10000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_20GBASE_KR2,
+		.supported	= SUPPORTED_20000baseKR2_Full,
+		.advertised	= ADVERTISED_20000baseKR2_Full,
+		.speed		= 20000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4,
+		.supported	= SUPPORTED_40000baseCR4_Full,
+		.advertised	= ADVERTISED_40000baseCR4_Full,
+		.speed		= 40000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_KR4,
+		.supported	= SUPPORTED_40000baseKR4_Full,
+		.advertised	= ADVERTISED_40000baseKR4_Full,
+		.speed		= 40000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_SR4,
+		.supported	= SUPPORTED_40000baseSR4_Full,
+		.advertised	= ADVERTISED_40000baseSR4_Full,
+		.speed		= 40000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_LR4_ER4,
+		.supported	= SUPPORTED_40000baseLR4_Full,
+		.advertised	= ADVERTISED_40000baseLR4_Full,
+		.speed		= 40000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_25GBASE_CR |
+				  MLXSW_REG_PTYS_ETH_SPEED_25GBASE_KR |
+				  MLXSW_REG_PTYS_ETH_SPEED_25GBASE_SR,
+		.speed		= 25000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_50GBASE_KR4 |
+				  MLXSW_REG_PTYS_ETH_SPEED_50GBASE_CR2 |
+				  MLXSW_REG_PTYS_ETH_SPEED_50GBASE_KR2,
+		.speed		= 50000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_56GBASE_R4,
+		.supported	= SUPPORTED_56000baseKR4_Full,
+		.advertised	= ADVERTISED_56000baseKR4_Full,
+		.speed		= 56000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100GBASE_CR4 |
+				  MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4 |
+				  MLXSW_REG_PTYS_ETH_SPEED_100GBASE_KR4 |
+				  MLXSW_REG_PTYS_ETH_SPEED_100GBASE_LR4_ER4,
+		.speed		= 100000,
+	},
+};
+
+#define MLXSW_SX_PORT_LINK_MODE_LEN ARRAY_SIZE(mlxsw_sx_port_link_mode)
+
+static u32 mlxsw_sx_from_ptys_supported_port(u32 ptys_eth_proto)
+{
+	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CR |
+			      MLXSW_REG_PTYS_ETH_SPEED_10GBASE_SR |
+			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_SR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_SGMII))
+		return SUPPORTED_FIBRE;
+
+	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KR |
+			      MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KX4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_KR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_KR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_1000BASE_KX))
+		return SUPPORTED_Backplane;
+	return 0;
+}
+
+static u32 mlxsw_sx_from_ptys_supported_link(u32 ptys_eth_proto)
+{
+	u32 modes = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SX_PORT_LINK_MODE_LEN; i++) {
+		if (ptys_eth_proto & mlxsw_sx_port_link_mode[i].mask)
+			modes |= mlxsw_sx_port_link_mode[i].supported;
+	}
+	return modes;
+}
+
+static u32 mlxsw_sx_from_ptys_advert_link(u32 ptys_eth_proto)
+{
+	u32 modes = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SX_PORT_LINK_MODE_LEN; i++) {
+		if (ptys_eth_proto & mlxsw_sx_port_link_mode[i].mask)
+			modes |= mlxsw_sx_port_link_mode[i].advertised;
+	}
+	return modes;
+}
+
+static void mlxsw_sx_from_ptys_speed_duplex(bool carrier_ok, u32 ptys_eth_proto,
+					    struct ethtool_cmd *cmd)
+{
+	u32 speed = SPEED_UNKNOWN;
+	u8 duplex = DUPLEX_UNKNOWN;
+	int i;
+
+	if (!carrier_ok)
+		goto out;
+
+	for (i = 0; i < MLXSW_SX_PORT_LINK_MODE_LEN; i++) {
+		if (ptys_eth_proto & mlxsw_sx_port_link_mode[i].mask) {
+			speed = mlxsw_sx_port_link_mode[i].speed;
+			duplex = DUPLEX_FULL;
+			break;
+		}
+	}
+out:
+	ethtool_cmd_speed_set(cmd, speed);
+	cmd->duplex = duplex;
+}
+
+static u8 mlxsw_sx_port_connector_port(u32 ptys_eth_proto)
+{
+	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_SR |
+			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_SR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_SGMII))
+		return PORT_FIBRE;
+
+	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CR |
+			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_CR4))
+		return PORT_DA;
+
+	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KR |
+			      MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KX4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_KR4 |
+			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_KR4))
+		return PORT_NONE;
+
+	return PORT_OTHER;
+}
+
+static int mlxsw_sx_port_get_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char ptys_pl[MLXSW_REG_PTYS_LEN];
+	u32 eth_proto_cap;
+	u32 eth_proto_admin;
+	u32 eth_proto_oper;
+	int err;
+
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
+	if (err) {
+		netdev_err(dev, "Failed to get proto");
+		return err;
+	}
+	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap,
+			      &eth_proto_admin, &eth_proto_oper);
+
+	cmd->supported = mlxsw_sx_from_ptys_supported_port(eth_proto_cap) |
+			 mlxsw_sx_from_ptys_supported_link(eth_proto_cap) |
+			 SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	cmd->advertising = mlxsw_sx_from_ptys_advert_link(eth_proto_admin);
+	mlxsw_sx_from_ptys_speed_duplex(netif_carrier_ok(dev),
+					eth_proto_oper, cmd);
+
+	eth_proto_oper = eth_proto_oper ? eth_proto_oper : eth_proto_cap;
+	cmd->port = mlxsw_sx_port_connector_port(eth_proto_oper);
+	cmd->lp_advertising = mlxsw_sx_from_ptys_advert_link(eth_proto_oper);
+
+	cmd->transceiver = XCVR_INTERNAL;
+	return 0;
+}
+
+static u32 mlxsw_sx_to_ptys_advert_link(u32 advertising)
+{
+	u32 ptys_proto = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SX_PORT_LINK_MODE_LEN; i++) {
+		if (advertising & mlxsw_sx_port_link_mode[i].advertised)
+			ptys_proto |= mlxsw_sx_port_link_mode[i].mask;
+	}
+	return ptys_proto;
+}
+
+static u32 mlxsw_sx_to_ptys_speed(u32 speed)
+{
+	u32 ptys_proto = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SX_PORT_LINK_MODE_LEN; i++) {
+		if (speed == mlxsw_sx_port_link_mode[i].speed)
+			ptys_proto |= mlxsw_sx_port_link_mode[i].mask;
+	}
+	return ptys_proto;
+}
+
+static int mlxsw_sx_port_set_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char ptys_pl[MLXSW_REG_PTYS_LEN];
+	u32 speed;
+	u32 eth_proto_new;
+	u32 eth_proto_cap;
+	u32 eth_proto_admin;
+	bool is_up;
+	int err;
+
+	speed = ethtool_cmd_speed(cmd);
+
+	eth_proto_new = cmd->autoneg == AUTONEG_ENABLE ?
+		mlxsw_sx_to_ptys_advert_link(cmd->advertising) :
+		mlxsw_sx_to_ptys_speed(speed);
+
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
+	if (err) {
+		netdev_err(dev, "Failed to get proto");
+		return err;
+	}
+	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap, &eth_proto_admin, NULL);
+
+	eth_proto_new = eth_proto_new & eth_proto_cap;
+	if (!eth_proto_new) {
+		netdev_err(dev, "Not supported proto admin requested");
+		return -EINVAL;
+	}
+	if (eth_proto_new == eth_proto_admin)
+		return 0;
+
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, eth_proto_new);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
+	if (err) {
+		netdev_err(dev, "Failed to set proto admin");
+		return err;
+	}
+
+	err = mlxsw_sx_port_oper_status_get(mlxsw_sx_port, &is_up);
+	if (err) {
+		netdev_err(dev, "Failed to get oper status");
+		return err;
+	}
+	if (!is_up)
+		return 0;
+
+	err = mlxsw_sx_port_admin_status_set(mlxsw_sx_port, false);
+	if (err) {
+		netdev_err(dev, "Failed to set admin status");
+		return err;
+	}
+
+	err = mlxsw_sx_port_admin_status_set(mlxsw_sx_port, true);
+	if (err) {
+		netdev_err(dev, "Failed to set admin status");
+		return err;
+	}
+
+	return 0;
+}
+
+static const struct ethtool_ops mlxsw_sx_port_ethtool_ops = {
+	.get_drvinfo		= mlxsw_sx_port_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_strings		= mlxsw_sx_port_get_strings,
+	.get_ethtool_stats	= mlxsw_sx_port_get_stats,
+	.get_sset_count		= mlxsw_sx_port_get_sset_count,
+	.get_settings		= mlxsw_sx_port_get_settings,
+	.set_settings		= mlxsw_sx_port_set_settings,
+};
+
+static int mlxsw_sx_port_attr_get(struct net_device *dev,
+				  struct switchdev_attr *attr)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_PORT_PARENT_ID:
+		attr->u.ppid.id_len = sizeof(mlxsw_sx->hw_id);
+		memcpy(&attr->u.ppid.id, &mlxsw_sx->hw_id, attr->u.ppid.id_len);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static const struct switchdev_ops mlxsw_sx_port_switchdev_ops = {
+	.switchdev_port_attr_get	= mlxsw_sx_port_attr_get,
+};
+
+static int mlxsw_sx_hw_id_get(struct mlxsw_sx *mlxsw_sx)
+{
+	char spad_pl[MLXSW_REG_SPAD_LEN];
+	int err;
+
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(spad), spad_pl);
+	if (err)
+		return err;
+	mlxsw_reg_spad_base_mac_memcpy_from(spad_pl, mlxsw_sx->hw_id);
+	return 0;
+}
+
+static int mlxsw_sx_port_dev_addr_get(struct mlxsw_sx_port *mlxsw_sx_port)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	struct net_device *dev = mlxsw_sx_port->dev;
+	char ppad_pl[MLXSW_REG_PPAD_LEN];
+	int err;
+
+	mlxsw_reg_ppad_pack(ppad_pl, false, 0);
+	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ppad), ppad_pl);
+	if (err)
+		return err;
+	mlxsw_reg_ppad_mac_memcpy_from(ppad_pl, dev->dev_addr);
+	/* The last byte in base mac address is always 0 */
+	dev->dev_addr[ETH_ALEN - 1] += mlxsw_sx_port->local_port;
+	return 0;
+}
+
+static int mlxsw_sx_port_stp_state_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				       u16 vid, enum mlxsw_reg_spms_state state)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char *spms_pl;
+	int err;
+
+	spms_pl = kmalloc(MLXSW_REG_SPMS_LEN, GFP_KERNEL);
+	if (!spms_pl)
+		return -ENOMEM;
+	mlxsw_reg_spms_pack(spms_pl, mlxsw_sx_port->local_port, vid, state);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(spms), spms_pl);
+	kfree(spms_pl);
+	return err;
+}
+
+static int mlxsw_sx_port_speed_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				   u32 speed)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char ptys_pl[MLXSW_REG_PTYS_LEN];
+
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, speed);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
+}
+
+static int
+mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
+				    enum mlxsw_reg_spmlr_learn_mode mode)
+{
+	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	char spmlr_pl[MLXSW_REG_SPMLR_LEN];
+
+	mlxsw_reg_spmlr_pack(spmlr_pl, mlxsw_sx_port->local_port, mode);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(spmlr), spmlr_pl);
+}
+
+static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port;
+	struct net_device *dev;
+	bool usable;
+	int err;
+
+	dev = alloc_etherdev(sizeof(struct mlxsw_sx_port));
+	if (!dev)
+		return -ENOMEM;
+	mlxsw_sx_port = netdev_priv(dev);
+	mlxsw_sx_port->dev = dev;
+	mlxsw_sx_port->mlxsw_sx = mlxsw_sx;
+	mlxsw_sx_port->local_port = local_port;
+
+	mlxsw_sx_port->pcpu_stats =
+		netdev_alloc_pcpu_stats(struct mlxsw_sx_port_pcpu_stats);
+	if (!mlxsw_sx_port->pcpu_stats) {
+		err = -ENOMEM;
+		goto err_alloc_stats;
+	}
+
+	dev->netdev_ops = &mlxsw_sx_port_netdev_ops;
+	dev->ethtool_ops = &mlxsw_sx_port_ethtool_ops;
+	dev->switchdev_ops = &mlxsw_sx_port_switchdev_ops;
+
+	err = mlxsw_sx_port_dev_addr_get(mlxsw_sx_port);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Unable to get port mac address\n",
+			mlxsw_sx_port->local_port);
+		goto err_dev_addr_get;
+	}
+
+	netif_carrier_off(dev);
+
+	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_LLTX |
+			 NETIF_F_VLAN_CHALLENGED;
+
+	/* Each packet needs to have a Tx header (metadata) on top all other
+	 * headers.
+	 */
+	dev->hard_header_len += MLXSW_TXHDR_LEN;
+
+	err = mlxsw_sx_port_module_check(mlxsw_sx_port, &usable);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to check module\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_module_check;
+	}
+
+	if (!usable) {
+		dev_dbg(mlxsw_sx->bus_info->dev, "Port %d: Not usable, skipping initialization\n",
+			mlxsw_sx_port->local_port);
+		goto port_not_usable;
+	}
+
+	err = mlxsw_sx_port_swid_set(mlxsw_sx_port, 0);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set SWID\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_swid_set;
+	}
+
+	err = mlxsw_sx_port_speed_set(mlxsw_sx_port,
+				      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set speed\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_speed_set;
+	}
+
+	err = mlxsw_sx_port_mtu_set(mlxsw_sx_port, ETH_DATA_LEN);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set MTU\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_mtu_set;
+	}
+
+	err = mlxsw_sx_port_admin_status_set(mlxsw_sx_port, false);
+	if (err)
+		goto err_port_admin_status_set;
+
+	err = mlxsw_sx_port_stp_state_set(mlxsw_sx_port,
+					  MLXSW_PORT_DEFAULT_VID,
+					  MLXSW_REG_SPMS_STATE_FORWARDING);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set STP state\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_stp_state_set;
+	}
+
+	err = mlxsw_sx_port_mac_learning_mode_set(mlxsw_sx_port,
+						  MLXSW_REG_SPMLR_LEARN_MODE_DISABLE);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set MAC learning mode\n",
+			mlxsw_sx_port->local_port);
+		goto err_port_mac_learning_mode_set;
+	}
+
+	err = register_netdev(dev);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to register netdev\n",
+			mlxsw_sx_port->local_port);
+		goto err_register_netdev;
+	}
+
+	mlxsw_sx->ports[local_port] = mlxsw_sx_port;
+	return 0;
+
+err_register_netdev:
+err_port_admin_status_set:
+err_port_mac_learning_mode_set:
+err_port_stp_state_set:
+err_port_mtu_set:
+err_port_speed_set:
+err_port_swid_set:
+port_not_usable:
+err_port_module_check:
+err_dev_addr_get:
+	free_percpu(mlxsw_sx_port->pcpu_stats);
+err_alloc_stats:
+	free_netdev(dev);
+	return err;
+}
+
+static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+{
+	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
+
+	if (!mlxsw_sx_port)
+		return;
+	unregister_netdev(mlxsw_sx_port->dev); /* This calls ndo_stop */
+	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
+	free_percpu(mlxsw_sx_port->pcpu_stats);
+}
+
+static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
+{
+	int i;
+
+	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
+		mlxsw_sx_port_remove(mlxsw_sx, i);
+	kfree(mlxsw_sx->ports);
+}
+
+static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
+{
+	size_t alloc_size;
+	int i;
+	int err;
+
+	alloc_size = sizeof(struct mlxsw_sx_port *) * MLXSW_PORT_MAX_PORTS;
+	mlxsw_sx->ports = kzalloc(alloc_size, GFP_KERNEL);
+	if (!mlxsw_sx->ports)
+		return -ENOMEM;
+
+	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
+		err = mlxsw_sx_port_create(mlxsw_sx, i);
+		if (err)
+			goto err_port_create;
+	}
+	return 0;
+
+err_port_create:
+	for (i--; i >= 1; i--)
+		mlxsw_sx_port_remove(mlxsw_sx, i);
+	kfree(mlxsw_sx->ports);
+	return err;
+}
+
+static void mlxsw_sx_pude_event_func(const struct mlxsw_reg_info *reg,
+				     char *pude_pl, void *priv)
+{
+	struct mlxsw_sx *mlxsw_sx = priv;
+	struct mlxsw_sx_port *mlxsw_sx_port;
+	enum mlxsw_reg_pude_oper_status status;
+	u8 local_port;
+
+	local_port = mlxsw_reg_pude_local_port_get(pude_pl);
+	mlxsw_sx_port = mlxsw_sx->ports[local_port];
+	if (!mlxsw_sx_port) {
+		dev_warn(mlxsw_sx->bus_info->dev, "Port %d: Link event received for non-existent port\n",
+			 local_port);
+		return;
+	}
+
+	status = mlxsw_reg_pude_oper_status_get(pude_pl);
+	if (MLXSW_PORT_OPER_STATUS_UP == status) {
+		netdev_info(mlxsw_sx_port->dev, "link up\n");
+		netif_carrier_on(mlxsw_sx_port->dev);
+	} else {
+		netdev_info(mlxsw_sx_port->dev, "link down\n");
+		netif_carrier_off(mlxsw_sx_port->dev);
+	}
+}
+
+static struct mlxsw_event_listener mlxsw_sx_pude_event = {
+	.func = mlxsw_sx_pude_event_func,
+	.trap_id = MLXSW_TRAP_ID_PUDE,
+};
+
+static int mlxsw_sx_event_register(struct mlxsw_sx *mlxsw_sx,
+				   enum mlxsw_event_trap_id trap_id)
+{
+	struct mlxsw_event_listener *el;
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int err;
+
+	switch (trap_id) {
+	case MLXSW_TRAP_ID_PUDE:
+		el = &mlxsw_sx_pude_event;
+		break;
+	}
+	err = mlxsw_core_event_listener_register(mlxsw_sx->core, el, mlxsw_sx);
+	if (err)
+		return err;
+
+	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
+			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD, trap_id);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
+	if (err)
+		goto err_event_trap_set;
+
+	return 0;
+
+err_event_trap_set:
+	mlxsw_core_event_listener_unregister(mlxsw_sx->core, el, mlxsw_sx);
+	return err;
+}
+
+static void mlxsw_sx_event_unregister(struct mlxsw_sx *mlxsw_sx,
+				      enum mlxsw_event_trap_id trap_id)
+{
+	struct mlxsw_event_listener *el;
+
+	switch (trap_id) {
+	case MLXSW_TRAP_ID_PUDE:
+		el = &mlxsw_sx_pude_event;
+		break;
+	}
+	mlxsw_core_event_listener_unregister(mlxsw_sx->core, el, mlxsw_sx);
+}
+
+static void mlxsw_sx_rx_listener_func(struct sk_buff *skb, u8 local_port,
+				      u16 trap_id, void *priv)
+{
+	struct mlxsw_sx *mlxsw_sx = priv;
+	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
+	struct mlxsw_sx_port_pcpu_stats *pcpu_stats;
+
+	if (unlikely(!mlxsw_sx_port)) {
+		if (net_ratelimit())
+			dev_warn(mlxsw_sx->bus_info->dev, "Port %d: skb received for non-existent port\n",
+				 local_port);
+		return;
+	}
+
+	skb->dev = mlxsw_sx_port->dev;
+
+	pcpu_stats = this_cpu_ptr(mlxsw_sx_port->pcpu_stats);
+	u64_stats_update_begin(&pcpu_stats->syncp);
+	pcpu_stats->rx_packets++;
+	pcpu_stats->rx_bytes += skb->len;
+	u64_stats_update_end(&pcpu_stats->syncp);
+
+	skb->protocol = eth_type_trans(skb, skb->dev);
+	netif_receive_skb(skb);
+}
+
+static const struct mlxsw_rx_listener mlxsw_sx_rx_listener[] = {
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_FDB_MC,
+	},
+	/* Traps for specific L2 packet types, not trapped as FDB MC */
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_STP,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_LACP,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_EAPOL,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_LLDP,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_MMRP,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_MVRP,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_RPVST,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_DHCP,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_IGMP_QUERY,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V1_REPORT,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V2_REPORT,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V2_LEAVE,
+	},
+	{
+		.func = mlxsw_sx_rx_listener_func,
+		.local_port = MLXSW_PORT_MAX_PORTS,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V3_REPORT,
+	},
+};
+
+static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
+{
+	char htgt_pl[MLXSW_REG_HTGT_LEN];
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int i;
+	int err;
+
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_RX);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(htgt), htgt_pl);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
+		err = mlxsw_core_rx_listener_register(mlxsw_sx->core,
+						      &mlxsw_sx_rx_listener[i],
+						      mlxsw_sx);
+		if (err)
+			goto err_rx_listener_register;
+
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
+				    MLXSW_REG_HTGT_TRAP_GROUP_RX,
+				    mlxsw_sx_rx_listener[i].trap_id);
+		err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
+		if (err)
+			goto err_rx_trap_set;
+	}
+	return 0;
+
+err_rx_trap_set:
+	mlxsw_core_rx_listener_unregister(mlxsw_sx->core,
+					  &mlxsw_sx_rx_listener[i],
+					  mlxsw_sx);
+err_rx_listener_register:
+	for (i--; i >= 0; i--) {
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
+				    MLXSW_REG_HTGT_TRAP_GROUP_RX,
+				    mlxsw_sx_rx_listener[i].trap_id);
+		mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
+
+		mlxsw_core_rx_listener_unregister(mlxsw_sx->core,
+						  &mlxsw_sx_rx_listener[i],
+						  mlxsw_sx);
+	}
+	return err;
+}
+
+static void mlxsw_sx_traps_fini(struct mlxsw_sx *mlxsw_sx)
+{
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
+				    MLXSW_REG_HTGT_TRAP_GROUP_RX,
+				    mlxsw_sx_rx_listener[i].trap_id);
+		mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
+
+		mlxsw_core_rx_listener_unregister(mlxsw_sx->core,
+						  &mlxsw_sx_rx_listener[i],
+						  mlxsw_sx);
+	}
+}
+
+static int mlxsw_sx_flood_init(struct mlxsw_sx *mlxsw_sx)
+{
+	char sfgc_pl[MLXSW_REG_SFGC_LEN];
+	char sgcr_pl[MLXSW_REG_SGCR_LEN];
+	char *smid_pl;
+	char *sftr_pl;
+	int err;
+
+	/* Due to FW bug, we must configure SMID. */
+	smid_pl = kmalloc(MLXSW_REG_SMID_LEN, GFP_KERNEL);
+	if (!smid_pl)
+		return -ENOMEM;
+	mlxsw_reg_smid_pack(smid_pl, MLXSW_PORT_MID);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(smid), smid_pl);
+	kfree(smid_pl);
+	if (err)
+		return err;
+
+	/* Configure a flooding table, which includes only CPU port. */
+	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
+	if (!sftr_pl)
+		return -ENOMEM;
+	mlxsw_reg_sftr_pack(sftr_pl, 0, 0, MLXSW_REG_SFGC_TABLE_TYPE_SINGLE, 0);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sftr), sftr_pl);
+	kfree(sftr_pl);
+	if (err)
+		return err;
+
+	/* Flood different packet types using the flooding table. */
+	mlxsw_reg_sfgc_pack(sfgc_pl,
+			    MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST,
+			    MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
+			    MLXSW_REG_SFGC_TABLE_TYPE_SINGLE,
+			    0);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sfgc), sfgc_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_sfgc_pack(sfgc_pl,
+			    MLXSW_REG_SFGC_TYPE_BROADCAST,
+			    MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
+			    MLXSW_REG_SFGC_TABLE_TYPE_SINGLE,
+			    0);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sfgc), sfgc_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_sfgc_pack(sfgc_pl,
+			    MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_NON_IP,
+			    MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
+			    MLXSW_REG_SFGC_TABLE_TYPE_SINGLE,
+			    0);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sfgc), sfgc_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_sfgc_pack(sfgc_pl,
+			    MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV6,
+			    MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
+			    MLXSW_REG_SFGC_TABLE_TYPE_SINGLE,
+			    0);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sfgc), sfgc_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_sfgc_pack(sfgc_pl,
+			    MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV4,
+			    MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
+			    MLXSW_REG_SFGC_TABLE_TYPE_SINGLE,
+			    0);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sfgc), sfgc_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_sgcr_pack(sgcr_pl, true);
+	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sgcr), sgcr_pl);
+}
+
+static int mlxsw_sx_init(void *priv, struct mlxsw_core *mlxsw_core,
+			 const struct mlxsw_bus_info *mlxsw_bus_info)
+{
+	struct mlxsw_sx *mlxsw_sx = priv;
+	int err;
+
+	mlxsw_sx->core = mlxsw_core;
+	mlxsw_sx->bus_info = mlxsw_bus_info;
+
+	err = mlxsw_sx_hw_id_get(mlxsw_sx);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Failed to get switch HW ID\n");
+		return err;
+	}
+
+	err = mlxsw_sx_ports_create(mlxsw_sx);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Failed to create ports\n");
+		return err;
+	}
+
+	err = mlxsw_sx_event_register(mlxsw_sx, MLXSW_TRAP_ID_PUDE);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Failed to register for PUDE events\n");
+		goto err_event_register;
+	}
+
+	err = mlxsw_sx_traps_init(mlxsw_sx);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Failed to set traps for RX\n");
+		goto err_rx_listener_register;
+	}
+
+	err = mlxsw_sx_flood_init(mlxsw_sx);
+	if (err) {
+		dev_err(mlxsw_sx->bus_info->dev, "Failed to initialize flood tables\n");
+		goto err_flood_init;
+	}
+
+	return 0;
+
+err_flood_init:
+	mlxsw_sx_traps_fini(mlxsw_sx);
+err_rx_listener_register:
+	mlxsw_sx_event_unregister(mlxsw_sx, MLXSW_TRAP_ID_PUDE);
+err_event_register:
+	mlxsw_sx_ports_remove(mlxsw_sx);
+	return err;
+}
+
+static void mlxsw_sx_fini(void *priv)
+{
+	struct mlxsw_sx *mlxsw_sx = priv;
+
+	mlxsw_sx_traps_fini(mlxsw_sx);
+	mlxsw_sx_event_unregister(mlxsw_sx, MLXSW_TRAP_ID_PUDE);
+	mlxsw_sx_ports_remove(mlxsw_sx);
+}
+
+static struct mlxsw_config_profile mlxsw_sx_config_profile = {
+	.used_max_vepa_channels		= 1,
+	.max_vepa_channels		= 0,
+	.used_max_lag			= 1,
+	.max_lag			= 64,
+	.used_max_port_per_lag		= 1,
+	.max_port_per_lag		= 16,
+	.used_max_mid			= 1,
+	.max_mid			= 7000,
+	.used_max_pgt			= 1,
+	.max_pgt			= 0,
+	.used_max_system_port		= 1,
+	.max_system_port		= 48000,
+	.used_max_vlan_groups		= 1,
+	.max_vlan_groups		= 127,
+	.used_max_regions		= 1,
+	.max_regions			= 400,
+	.used_flood_tables		= 1,
+	.max_flood_tables		= 2,
+	.max_vid_flood_tables		= 1,
+	.used_flood_mode		= 1,
+	.flood_mode			= 3,
+	.used_max_ib_mc			= 1,
+	.max_ib_mc			= 0,
+	.used_max_pkey			= 1,
+	.max_pkey			= 0,
+	.swid_config			= {
+		{
+			.used_type	= 1,
+			.type		= MLXSW_PORT_SWID_TYPE_ETH,
+		}
+	},
+};
+
+static struct mlxsw_driver mlxsw_sx_driver = {
+	.kind			= MLXSW_DEVICE_KIND_SWITCHX2,
+	.owner			= THIS_MODULE,
+	.priv_size		= sizeof(struct mlxsw_sx),
+	.init			= mlxsw_sx_init,
+	.fini			= mlxsw_sx_fini,
+	.txhdr_construct	= mlxsw_sx_txhdr_construct,
+	.txhdr_len		= MLXSW_TXHDR_LEN,
+	.profile		= &mlxsw_sx_config_profile,
+};
+
+static int __init mlxsw_sx_module_init(void)
+{
+	return mlxsw_core_driver_register(&mlxsw_sx_driver);
+}
+
+static void __exit mlxsw_sx_module_exit(void)
+{
+	mlxsw_core_driver_unregister(&mlxsw_sx_driver);
+}
+
+module_init(mlxsw_sx_module_init);
+module_exit(mlxsw_sx_module_exit);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
+MODULE_DESCRIPTION("Mellanox SwitchX-2 driver");
+MODULE_MLXSW_DRIVER_ALIAS(MLXSW_DEVICE_KIND_SWITCHX2);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/txheader.h b/drivers/net/ethernet/mellanox/mlxsw/txheader.h
new file mode 100644
index 0000000..06fc46c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/txheader.h
@@ -0,0 +1,80 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/txheader.h
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _MLXSW_TXHEADER_H
+#define _MLXSW_TXHEADER_H
+
+#define MLXSW_TXHDR_LEN 0x10
+#define MLXSW_TXHDR_VERSION_0 0
+
+enum {
+	MLXSW_TXHDR_ETH_CTL,
+	MLXSW_TXHDR_ETH_DATA,
+};
+
+#define MLXSW_TXHDR_PROTO_ETH 1
+
+enum {
+	MLXSW_TXHDR_ETCLASS_0,
+	MLXSW_TXHDR_ETCLASS_1,
+	MLXSW_TXHDR_ETCLASS_2,
+	MLXSW_TXHDR_ETCLASS_3,
+	MLXSW_TXHDR_ETCLASS_4,
+	MLXSW_TXHDR_ETCLASS_5,
+	MLXSW_TXHDR_ETCLASS_6,
+	MLXSW_TXHDR_ETCLASS_7,
+};
+
+enum {
+	MLXSW_TXHDR_RDQ_OTHER,
+	MLXSW_TXHDR_RDQ_EMAD = 0x1f,
+};
+
+#define MLXSW_TXHDR_CTCLASS3 0
+#define MLXSW_TXHDR_CPU_SIG 0
+#define MLXSW_TXHDR_SIG 0xE0E0
+#define MLXSW_TXHDR_STCLASS_NONE 0
+
+enum {
+	MLXSW_TXHDR_NOT_EMAD,
+	MLXSW_TXHDR_EMAD,
+};
+
+enum {
+	MLXSW_TXHDR_TYPE_DATA,
+	MLXSW_TXHDR_TYPE_CONTROL = 6,
+};
+
+#endif
-- 
1.9.3
