From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/16] mlxsw: spectrum: Add initial support for Spectrum ASIC
Date: Fri, 16 Oct 2015 14:01:37 +0200
Message-ID: <1444996897-2708-17-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35892 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753935AbbJPMCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:02:03 -0400
Received: by wicgb1 with SMTP id gb1so6396747wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:02:00 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add support for new generation Mellanox Spectrum ASIC, 10/25/40/50 and
100Gb/s Ethernet Switch.

The initial driver implements bridge forwarding offload including
bridge internal VLAN support, FDB static entries, FDB learning and
HW ageing including their setup.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   11 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    3 +
 drivers/net/ethernet/mellanox/mlxsw/core.h         |    1 +
 drivers/net/ethernet/mellanox/mlxsw/pci.c          |    3 +
 drivers/net/ethernet/mellanox/mlxsw/pci.h          |    1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 1948 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  121 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |  422 +++++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  863 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/txheader.h     |    1 +
 10 files changed, 3374 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index 2941d9c..e36e122 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -30,3 +30,14 @@ config MLXSW_SWITCHX2
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called mlxsw_switchx2.
+
+config MLXSW_SPECTRUM
+	tristate "Mellanox Technologies Spectrum support"
+	depends on MLXSW_CORE && NET_SWITCHDEV
+	default m
+	---help---
+	  This driver supports Mellanox Technologies Spectrum Ethernet
+	  Switch ASICs.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called mlxsw_spectrum.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index 0a05f65..af01581 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -4,3 +4,6 @@ obj-$(CONFIG_MLXSW_PCI)		+= mlxsw_pci.o
 mlxsw_pci-objs			:= pci.o
 obj-$(CONFIG_MLXSW_SWITCHX2)	+= mlxsw_switchx2.o
 mlxsw_switchx2-objs		:= switchx2.o
+obj-$(CONFIG_MLXSW_SPECTRUM)	+= mlxsw_spectrum.o
+mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
+				   spectrum_switchdev.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index e92ab27..8078273 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -54,6 +54,7 @@
 	MODULE_ALIAS(MLXSW_MODULE_ALIAS_PREFIX kind)
 
 #define MLXSW_DEVICE_KIND_SWITCHX2 "switchx2"
+#define MLXSW_DEVICE_KIND_SPECTRUM "spectrum"
 
 struct mlxsw_core;
 struct mlxsw_driver;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 0fa44c8..879e000 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -57,6 +57,7 @@ static const char mlxsw_pci_driver_name[] = "mlxsw_pci";
 
 static const struct pci_device_id mlxsw_pci_id_table[] = {
 	{PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_SWITCHX2), 0},
+	{PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_SPECTRUM), 0},
 	{0, }
 };
 
@@ -67,6 +68,8 @@ static const char *mlxsw_pci_device_kind_get(const struct pci_device_id *id)
 	switch (id->device) {
 	case PCI_DEVICE_ID_MELLANOX_SWITCHX2:
 		return MLXSW_DEVICE_KIND_SWITCHX2;
+	case PCI_DEVICE_ID_MELLANOX_SPECTRUM:
+		return MLXSW_DEVICE_KIND_SPECTRUM;
 	default:
 		BUG();
 	}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
index 5b3453b..142f33d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -40,6 +40,7 @@
 #include "item.h"
 
 #define PCI_DEVICE_ID_MELLANOX_SWITCHX2	0xc738
+#define PCI_DEVICE_ID_MELLANOX_SPECTRUM	0xcb84
 #define MLXSW_PCI_BAR0_SIZE		(1024 * 1024) /* 1MB */
 #define MLXSW_PCI_PAGE_SIZE		4096
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
new file mode 100644
index 0000000..6e9906d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -0,0 +1,1948 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum.c
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
+#include <linux/ethtool.h>
+#include <linux/slab.h>
+#include <linux/device.h>
+#include <linux/skbuff.h>
+#include <linux/if_vlan.h>
+#include <linux/if_bridge.h>
+#include <linux/workqueue.h>
+#include <linux/jiffies.h>
+#include <linux/bitops.h>
+#include <net/switchdev.h>
+#include <generated/utsrelease.h>
+
+#include "spectrum.h"
+#include "core.h"
+#include "reg.h"
+#include "port.h"
+#include "trap.h"
+#include "txheader.h"
+
+static const char mlxsw_sp_driver_name[] = "mlxsw_spectrum";
+static const char mlxsw_sp_driver_version[] = "1.0";
+
+/* tx_hdr_version
+ * Tx header version.
+ * Must be set to 1.
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
+/* tx_hdr_rx_is_router
+ * Packet is sent from the router. Valid for data packets only.
+ */
+MLXSW_ITEM32(tx, hdr, rx_is_router, 0x00, 19, 1);
+
+/* tx_hdr_fid_valid
+ * Indicates if the 'fid' field is valid and should be used for
+ * forwarding lookup. Valid for data packets only.
+ */
+MLXSW_ITEM32(tx, hdr, fid_valid, 0x00, 16, 1);
+
+/* tx_hdr_swid
+ * Switch partition ID. Must be set to 0.
+ */
+MLXSW_ITEM32(tx, hdr, swid, 0x00, 12, 3);
+
+/* tx_hdr_control_tclass
+ * Indicates if the packet should use the control TClass and not one
+ * of the data TClasses.
+ */
+MLXSW_ITEM32(tx, hdr, control_tclass, 0x00, 6, 1);
+
+/* tx_hdr_etclass
+ * Egress TClass to be used on the egress device on the egress port.
+ */
+MLXSW_ITEM32(tx, hdr, etclass, 0x00, 0, 4);
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
+/* tx_hdr_fid
+ * Forwarding ID used for L2 forwarding lookup. Valid only if 'fid_valid' is
+ * set, otherwise calculated based on the packet's VID using VID to FID mapping.
+ * Valid for data packets only.
+ */
+MLXSW_ITEM32(tx, hdr, fid, 0x08, 0, 16);
+
+/* tx_hdr_type
+ * 0 - Data packets
+ * 6 - Control packets
+ */
+MLXSW_ITEM32(tx, hdr, type, 0x0C, 0, 4);
+
+static void mlxsw_sp_txhdr_construct(struct sk_buff *skb,
+				     const struct mlxsw_tx_info *tx_info)
+{
+	char *txhdr = skb_push(skb, MLXSW_TXHDR_LEN);
+
+	memset(txhdr, 0, MLXSW_TXHDR_LEN);
+
+	mlxsw_tx_hdr_version_set(txhdr, MLXSW_TXHDR_VERSION_1);
+	mlxsw_tx_hdr_ctl_set(txhdr, MLXSW_TXHDR_ETH_CTL);
+	mlxsw_tx_hdr_proto_set(txhdr, MLXSW_TXHDR_PROTO_ETH);
+	mlxsw_tx_hdr_swid_set(txhdr, 0);
+	mlxsw_tx_hdr_control_tclass_set(txhdr, 1);
+	mlxsw_tx_hdr_port_mid_set(txhdr, tx_info->local_port);
+	mlxsw_tx_hdr_type_set(txhdr, MLXSW_TXHDR_TYPE_CONTROL);
+}
+
+static int mlxsw_sp_base_mac_get(struct mlxsw_sp *mlxsw_sp)
+{
+	char spad_pl[MLXSW_REG_SPAD_LEN];
+	int err;
+
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(spad), spad_pl);
+	if (err)
+		return err;
+	mlxsw_reg_spad_base_mac_memcpy_from(spad_pl, mlxsw_sp->base_mac);
+	return 0;
+}
+
+static int mlxsw_sp_port_admin_status_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					  bool is_up)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char paos_pl[MLXSW_REG_PAOS_LEN];
+
+	mlxsw_reg_paos_pack(paos_pl, mlxsw_sp_port->local_port,
+			    is_up ? MLXSW_PORT_ADMIN_STATUS_UP :
+			    MLXSW_PORT_ADMIN_STATUS_DOWN);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(paos), paos_pl);
+}
+
+static int mlxsw_sp_port_oper_status_get(struct mlxsw_sp_port *mlxsw_sp_port,
+					 bool *p_is_up)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char paos_pl[MLXSW_REG_PAOS_LEN];
+	u8 oper_status;
+	int err;
+
+	mlxsw_reg_paos_pack(paos_pl, mlxsw_sp_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(paos), paos_pl);
+	if (err)
+		return err;
+	oper_status = mlxsw_reg_paos_oper_status_get(paos_pl);
+	*p_is_up = oper_status == MLXSW_PORT_ADMIN_STATUS_UP ? true : false;
+	return 0;
+}
+
+static int mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp, u16 vfid)
+{
+	char sfmr_pl[MLXSW_REG_SFMR_LEN];
+	int err;
+
+	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_CREATE_FID,
+			    MLXSW_SP_VFID_BASE + vfid, 0);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
+
+	if (err)
+		return err;
+
+	set_bit(vfid, mlxsw_sp->active_vfids);
+	return 0;
+}
+
+static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp, u16 vfid)
+{
+	char sfmr_pl[MLXSW_REG_SFMR_LEN];
+
+	clear_bit(vfid, mlxsw_sp->active_vfids);
+
+	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_DESTROY_FID,
+			    MLXSW_SP_VFID_BASE + vfid, 0);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
+}
+
+static int mlxsw_sp_port_dev_addr_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				      unsigned char *addr)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char ppad_pl[MLXSW_REG_PPAD_LEN];
+
+	mlxsw_reg_ppad_pack(ppad_pl, true, mlxsw_sp_port->local_port);
+	mlxsw_reg_ppad_mac_memcpy_to(ppad_pl, addr);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ppad), ppad_pl);
+}
+
+static int mlxsw_sp_port_dev_addr_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	unsigned char *addr = mlxsw_sp_port->dev->dev_addr;
+
+	ether_addr_copy(addr, mlxsw_sp->base_mac);
+	addr[ETH_ALEN - 1] += mlxsw_sp_port->local_port;
+	return mlxsw_sp_port_dev_addr_set(mlxsw_sp_port, addr);
+}
+
+static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				       u16 vid, enum mlxsw_reg_spms_state state)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char *spms_pl;
+	int err;
+
+	spms_pl = kmalloc(MLXSW_REG_SPMS_LEN, GFP_KERNEL);
+	if (!spms_pl)
+		return -ENOMEM;
+	mlxsw_reg_spms_pack(spms_pl, mlxsw_sp_port->local_port);
+	mlxsw_reg_spms_vid_pack(spms_pl, vid, state);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spms), spms_pl);
+	kfree(spms_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_mtu_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mtu)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char pmtu_pl[MLXSW_REG_PMTU_LEN];
+	int max_mtu;
+	int err;
+
+	mtu += MLXSW_TXHDR_LEN + ETH_HLEN;
+	mlxsw_reg_pmtu_pack(pmtu_pl, mlxsw_sp_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(pmtu), pmtu_pl);
+	if (err)
+		return err;
+	max_mtu = mlxsw_reg_pmtu_max_mtu_get(pmtu_pl);
+
+	if (mtu > max_mtu)
+		return -EINVAL;
+
+	mlxsw_reg_pmtu_pack(pmtu_pl, mlxsw_sp_port->local_port, mtu);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pmtu), pmtu_pl);
+}
+
+static int mlxsw_sp_port_swid_set(struct mlxsw_sp_port *mlxsw_sp_port, u8 swid)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char pspa_pl[MLXSW_REG_PSPA_LEN];
+
+	mlxsw_reg_pspa_pack(pspa_pl, swid, mlxsw_sp_port->local_port);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pspa), pspa_pl);
+}
+
+static int mlxsw_sp_port_vp_mode_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     bool enable)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char svpe_pl[MLXSW_REG_SVPE_LEN];
+
+	mlxsw_reg_svpe_pack(svpe_pl, mlxsw_sp_port->local_port, enable);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(svpe), svpe_pl);
+}
+
+int mlxsw_sp_port_vid_to_fid_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				 enum mlxsw_reg_svfa_mt mt, bool valid, u16 fid,
+				 u16 vid)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char svfa_pl[MLXSW_REG_SVFA_LEN];
+
+	mlxsw_reg_svfa_pack(svfa_pl, mlxsw_sp_port->local_port, mt, valid,
+			    fid, vid);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(svfa), svfa_pl);
+}
+
+static int mlxsw_sp_port_vid_learning_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					  u16 vid, bool learn_enable)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char *spvmlr_pl;
+	int err;
+
+	spvmlr_pl = kmalloc(MLXSW_REG_SPVMLR_LEN, GFP_KERNEL);
+	if (!spvmlr_pl)
+		return -ENOMEM;
+	mlxsw_reg_spvmlr_pack(spvmlr_pl, mlxsw_sp_port->local_port, vid, vid,
+			      learn_enable);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvmlr), spvmlr_pl);
+	kfree(spvmlr_pl);
+	return err;
+}
+
+static int
+mlxsw_sp_port_system_port_mapping_set(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char sspr_pl[MLXSW_REG_SSPR_LEN];
+
+	mlxsw_reg_sspr_pack(sspr_pl, mlxsw_sp_port->local_port);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sspr), sspr_pl);
+}
+
+static int mlxsw_sp_port_module_check(struct mlxsw_sp_port *mlxsw_sp_port,
+				      bool *p_usable)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char pmlp_pl[MLXSW_REG_PMLP_LEN];
+	int err;
+
+	mlxsw_reg_pmlp_pack(pmlp_pl, mlxsw_sp_port->local_port);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(pmlp), pmlp_pl);
+	if (err)
+		return err;
+	*p_usable = mlxsw_reg_pmlp_width_get(pmlp_pl) ? true : false;
+	return 0;
+}
+
+static int mlxsw_sp_port_open(struct net_device *dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err;
+
+	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, true);
+	if (err)
+		return err;
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int mlxsw_sp_port_stop(struct net_device *dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	return mlxsw_sp_port_admin_status_set(mlxsw_sp_port, false);
+}
+
+static netdev_tx_t mlxsw_sp_port_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_port_pcpu_stats *pcpu_stats;
+	const struct mlxsw_tx_info tx_info = {
+		.local_port = mlxsw_sp_port->local_port,
+		.is_emad = false,
+	};
+	u64 len;
+	int err;
+
+	if (mlxsw_core_skb_transmit_busy(mlxsw_sp, &tx_info))
+		return NETDEV_TX_BUSY;
+
+	if (unlikely(skb_headroom(skb) < MLXSW_TXHDR_LEN)) {
+		struct sk_buff *skb_orig = skb;
+
+		skb = skb_realloc_headroom(skb, MLXSW_TXHDR_LEN);
+		if (!skb) {
+			this_cpu_inc(mlxsw_sp_port->pcpu_stats->tx_dropped);
+			dev_kfree_skb_any(skb_orig);
+			return NETDEV_TX_OK;
+		}
+	}
+
+	if (eth_skb_pad(skb)) {
+		this_cpu_inc(mlxsw_sp_port->pcpu_stats->tx_dropped);
+		return NETDEV_TX_OK;
+	}
+
+	mlxsw_sp_txhdr_construct(skb, &tx_info);
+	len = skb->len;
+	/* Due to a race we might fail here because of a full queue. In that
+	 * unlikely case we simply drop the packet.
+	 */
+	err = mlxsw_core_skb_transmit(mlxsw_sp, skb, &tx_info);
+
+	if (!err) {
+		pcpu_stats = this_cpu_ptr(mlxsw_sp_port->pcpu_stats);
+		u64_stats_update_begin(&pcpu_stats->syncp);
+		pcpu_stats->tx_packets++;
+		pcpu_stats->tx_bytes += len;
+		u64_stats_update_end(&pcpu_stats->syncp);
+	} else {
+		this_cpu_inc(mlxsw_sp_port->pcpu_stats->tx_dropped);
+		dev_kfree_skb_any(skb);
+	}
+	return NETDEV_TX_OK;
+}
+
+static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct sockaddr *addr = p;
+	int err;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	err = mlxsw_sp_port_dev_addr_set(mlxsw_sp_port, addr->sa_data);
+	if (err)
+		return err;
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	return 0;
+}
+
+static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err;
+
+	err = mlxsw_sp_port_mtu_set(mlxsw_sp_port, mtu);
+	if (err)
+		return err;
+	dev->mtu = mtu;
+	return 0;
+}
+
+static struct rtnl_link_stats64 *
+mlxsw_sp_port_get_stats64(struct net_device *dev,
+			  struct rtnl_link_stats64 *stats)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp_port_pcpu_stats *p;
+	u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+	u32 tx_dropped = 0;
+	unsigned int start;
+	int i;
+
+	for_each_possible_cpu(i) {
+		p = per_cpu_ptr(mlxsw_sp_port->pcpu_stats, i);
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
+int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
+			   u16 vid_end, bool is_member, bool untagged)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char *spvm_pl;
+	int err;
+
+	spvm_pl = kmalloc(MLXSW_REG_SPVM_LEN, GFP_KERNEL);
+	if (!spvm_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_spvm_pack(spvm_pl, mlxsw_sp_port->local_port,	vid_begin,
+			    vid_end, is_member, untagged);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvm), spvm_pl);
+	kfree(spvm_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_vp_mode_trans(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
+	u16 vid, last_visited_vid;
+	int err;
+
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
+		err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, true, vid,
+						   vid);
+		if (err) {
+			last_visited_vid = vid;
+			goto err_port_vid_to_fid_set;
+		}
+	}
+
+	err = mlxsw_sp_port_vp_mode_set(mlxsw_sp_port, true);
+	if (err) {
+		last_visited_vid = VLAN_N_VID;
+		goto err_port_vid_to_fid_set;
+	}
+
+	return 0;
+
+err_port_vid_to_fid_set:
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, last_visited_vid)
+		mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, false, vid,
+					     vid);
+	return err;
+}
+
+static int mlxsw_sp_port_vlan_mode_trans(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
+	u16 vid;
+	int err;
+
+	err = mlxsw_sp_port_vp_mode_set(mlxsw_sp_port, false);
+	if (err)
+		return err;
+
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
+		err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, false,
+						   vid, vid);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
+			  u16 vid)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char *sftr_pl;
+	int err;
+
+	/* VLAN 0 is added to HW filter when device goes up, but it is
+	 * reserved in our case, so simply return.
+	 */
+	if (!vid)
+		return 0;
+
+	if (test_bit(vid, mlxsw_sp_port->active_vfids)) {
+		netdev_warn(dev, "VID=%d already configured\n", vid);
+		return 0;
+	}
+
+	if (!test_bit(vid, mlxsw_sp->active_vfids)) {
+		err = mlxsw_sp_vfid_create(mlxsw_sp, vid);
+		if (err) {
+			netdev_err(dev, "Failed to create vFID=%d\n",
+				   MLXSW_SP_VFID_BASE + vid);
+			return err;
+		}
+
+		sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
+		if (!sftr_pl) {
+			err = -ENOMEM;
+			goto err_flood_table_alloc;
+		}
+		mlxsw_reg_sftr_pack(sftr_pl, 0, vid,
+				    MLXSW_REG_SFGC_TABLE_TYPE_FID, 0,
+				    MLXSW_PORT_CPU_PORT, true);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+		kfree(sftr_pl);
+		if (err) {
+			netdev_err(dev, "Failed to configure flood table\n");
+			goto err_flood_table_config;
+		}
+	}
+
+	/* In case we fail in the following steps, we intentionally do not
+	 * destroy the associated vFID.
+	 */
+
+	/* When adding the first VLAN interface on a bridged port we need to
+	 * transition all the active 802.1Q bridge VLANs to use explicit
+	 * {Port, VID} to FID mappings and set the port's mode to Virtual mode.
+	 */
+	if (!mlxsw_sp_port->nr_vfids) {
+		err = mlxsw_sp_port_vp_mode_trans(mlxsw_sp_port);
+		if (err) {
+			netdev_err(dev, "Failed to set to Virtual mode\n");
+			return err;
+		}
+	}
+
+	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port,
+					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
+					   true, MLXSW_SP_VFID_BASE + vid, vid);
+	if (err) {
+		netdev_err(dev, "Failed to map {Port, VID=%d} to vFID=%d\n",
+			   vid, MLXSW_SP_VFID_BASE + vid);
+		goto err_port_vid_to_fid_set;
+	}
+
+	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, false);
+	if (err) {
+		netdev_err(dev, "Failed to disable learning for VID=%d\n", vid);
+		goto err_port_vid_learning_set;
+	}
+
+	err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid, true, false);
+	if (err) {
+		netdev_err(dev, "Failed to set VLAN membership for VID=%d\n",
+			   vid);
+		goto err_port_add_vid;
+	}
+
+	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_port, vid,
+					  MLXSW_REG_SPMS_STATE_FORWARDING);
+	if (err) {
+		netdev_err(dev, "Failed to set STP state for VID=%d\n", vid);
+		goto err_port_stp_state_set;
+	}
+
+	mlxsw_sp_port->nr_vfids++;
+	set_bit(vid, mlxsw_sp_port->active_vfids);
+
+	return 0;
+
+err_flood_table_config:
+err_flood_table_alloc:
+	mlxsw_sp_vfid_destroy(mlxsw_sp, vid);
+	return err;
+
+err_port_stp_state_set:
+	mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid, false, false);
+err_port_add_vid:
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, true);
+err_port_vid_learning_set:
+	mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port,
+				     MLXSW_REG_SVFA_MT_PORT_VID_TO_FID, false,
+				     MLXSW_SP_VFID_BASE + vid, vid);
+err_port_vid_to_fid_set:
+	mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
+	return err;
+}
+
+int mlxsw_sp_port_kill_vid(struct net_device *dev,
+			   __be16 __always_unused proto, u16 vid)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err;
+
+	/* VLAN 0 is removed from HW filter when device goes down, but
+	 * it is reserved in our case, so simply return.
+	 */
+	if (!vid)
+		return 0;
+
+	if (!test_bit(vid, mlxsw_sp_port->active_vfids)) {
+		netdev_warn(dev, "VID=%d does not exist\n", vid);
+		return 0;
+	}
+
+	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_port, vid,
+					  MLXSW_REG_SPMS_STATE_DISCARDING);
+	if (err) {
+		netdev_err(dev, "Failed to set STP state for VID=%d\n", vid);
+		return err;
+	}
+
+	err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid, false, false);
+	if (err) {
+		netdev_err(dev, "Failed to set VLAN membership for VID=%d\n",
+			   vid);
+		return err;
+	}
+
+	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid, true);
+	if (err) {
+		netdev_err(dev, "Failed to enable learning for VID=%d\n", vid);
+		return err;
+	}
+
+	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port,
+					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
+					   false, MLXSW_SP_VFID_BASE + vid,
+					   vid);
+	if (err) {
+		netdev_err(dev, "Failed to invalidate {Port, VID=%d} to vFID=%d mapping\n",
+			   vid, MLXSW_SP_VFID_BASE + vid);
+		return err;
+	}
+
+	/* When removing the last VLAN interface on a bridged port we need to
+	 * transition all active 802.1Q bridge VLANs to use VID to FID
+	 * mappings and set port's mode to VLAN mode.
+	 */
+	if (mlxsw_sp_port->nr_vfids == 1) {
+		err = mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
+		if (err) {
+			netdev_err(dev, "Failed to set to VLAN mode\n");
+			return err;
+		}
+	}
+
+	mlxsw_sp_port->nr_vfids--;
+	clear_bit(vid, mlxsw_sp_port->active_vfids);
+
+	return 0;
+}
+
+static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
+	.ndo_open		= mlxsw_sp_port_open,
+	.ndo_stop		= mlxsw_sp_port_stop,
+	.ndo_start_xmit		= mlxsw_sp_port_xmit,
+	.ndo_set_mac_address	= mlxsw_sp_port_set_mac_address,
+	.ndo_change_mtu		= mlxsw_sp_port_change_mtu,
+	.ndo_get_stats64	= mlxsw_sp_port_get_stats64,
+	.ndo_vlan_rx_add_vid	= mlxsw_sp_port_add_vid,
+	.ndo_vlan_rx_kill_vid	= mlxsw_sp_port_kill_vid,
+	.ndo_fdb_add		= switchdev_port_fdb_add,
+	.ndo_fdb_del		= switchdev_port_fdb_del,
+	.ndo_fdb_dump		= switchdev_port_fdb_dump,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
+};
+
+static void mlxsw_sp_port_get_drvinfo(struct net_device *dev,
+				      struct ethtool_drvinfo *drvinfo)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+
+	strlcpy(drvinfo->driver, mlxsw_sp_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, mlxsw_sp_driver_version,
+		sizeof(drvinfo->version));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		 "%d.%d.%d",
+		 mlxsw_sp->bus_info->fw_rev.major,
+		 mlxsw_sp->bus_info->fw_rev.minor,
+		 mlxsw_sp->bus_info->fw_rev.subminor);
+	strlcpy(drvinfo->bus_info, mlxsw_sp->bus_info->device_name,
+		sizeof(drvinfo->bus_info));
+}
+
+struct mlxsw_sp_port_hw_stats {
+	char str[ETH_GSTRING_LEN];
+	u64 (*getter)(char *payload);
+};
+
+static const struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_stats[] = {
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
+#define MLXSW_SP_PORT_HW_STATS_LEN ARRAY_SIZE(mlxsw_sp_port_hw_stats)
+
+static void mlxsw_sp_port_get_strings(struct net_device *dev,
+				      u32 stringset, u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < MLXSW_SP_PORT_HW_STATS_LEN; i++) {
+			memcpy(p, mlxsw_sp_port_hw_stats[i].str,
+			       ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static void mlxsw_sp_port_get_stats(struct net_device *dev,
+				    struct ethtool_stats *stats, u64 *data)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
+	int i;
+	int err;
+
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
+	for (i = 0; i < MLXSW_SP_PORT_HW_STATS_LEN; i++)
+		data[i] = !err ? mlxsw_sp_port_hw_stats[i].getter(ppcnt_pl) : 0;
+}
+
+static int mlxsw_sp_port_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return MLXSW_SP_PORT_HW_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+struct mlxsw_sp_port_link_mode {
+	u32 mask;
+	u32 supported;
+	u32 advertised;
+	u32 speed;
+};
+
+static const struct mlxsw_sp_port_link_mode mlxsw_sp_port_link_mode[] = {
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
+#define MLXSW_SP_PORT_LINK_MODE_LEN ARRAY_SIZE(mlxsw_sp_port_link_mode)
+
+static u32 mlxsw_sp_from_ptys_supported_port(u32 ptys_eth_proto)
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
+static u32 mlxsw_sp_from_ptys_supported_link(u32 ptys_eth_proto)
+{
+	u32 modes = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
+		if (ptys_eth_proto & mlxsw_sp_port_link_mode[i].mask)
+			modes |= mlxsw_sp_port_link_mode[i].supported;
+	}
+	return modes;
+}
+
+static u32 mlxsw_sp_from_ptys_advert_link(u32 ptys_eth_proto)
+{
+	u32 modes = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
+		if (ptys_eth_proto & mlxsw_sp_port_link_mode[i].mask)
+			modes |= mlxsw_sp_port_link_mode[i].advertised;
+	}
+	return modes;
+}
+
+static void mlxsw_sp_from_ptys_speed_duplex(bool carrier_ok, u32 ptys_eth_proto,
+					    struct ethtool_cmd *cmd)
+{
+	u32 speed = SPEED_UNKNOWN;
+	u8 duplex = DUPLEX_UNKNOWN;
+	int i;
+
+	if (!carrier_ok)
+		goto out;
+
+	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
+		if (ptys_eth_proto & mlxsw_sp_port_link_mode[i].mask) {
+			speed = mlxsw_sp_port_link_mode[i].speed;
+			duplex = DUPLEX_FULL;
+			break;
+		}
+	}
+out:
+	ethtool_cmd_speed_set(cmd, speed);
+	cmd->duplex = duplex;
+}
+
+static u8 mlxsw_sp_port_connector_port(u32 ptys_eth_proto)
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
+static int mlxsw_sp_port_get_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char ptys_pl[MLXSW_REG_PTYS_LEN];
+	u32 eth_proto_cap;
+	u32 eth_proto_admin;
+	u32 eth_proto_oper;
+	int err;
+
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
+	if (err) {
+		netdev_err(dev, "Failed to get proto");
+		return err;
+	}
+	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap,
+			      &eth_proto_admin, &eth_proto_oper);
+
+	cmd->supported = mlxsw_sp_from_ptys_supported_port(eth_proto_cap) |
+			 mlxsw_sp_from_ptys_supported_link(eth_proto_cap) |
+			 SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	cmd->advertising = mlxsw_sp_from_ptys_advert_link(eth_proto_admin);
+	mlxsw_sp_from_ptys_speed_duplex(netif_carrier_ok(dev),
+					eth_proto_oper, cmd);
+
+	eth_proto_oper = eth_proto_oper ? eth_proto_oper : eth_proto_cap;
+	cmd->port = mlxsw_sp_port_connector_port(eth_proto_oper);
+	cmd->lp_advertising = mlxsw_sp_from_ptys_advert_link(eth_proto_oper);
+
+	cmd->transceiver = XCVR_INTERNAL;
+	return 0;
+}
+
+static u32 mlxsw_sp_to_ptys_advert_link(u32 advertising)
+{
+	u32 ptys_proto = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
+		if (advertising & mlxsw_sp_port_link_mode[i].advertised)
+			ptys_proto |= mlxsw_sp_port_link_mode[i].mask;
+	}
+	return ptys_proto;
+}
+
+static u32 mlxsw_sp_to_ptys_speed(u32 speed)
+{
+	u32 ptys_proto = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
+		if (speed == mlxsw_sp_port_link_mode[i].speed)
+			ptys_proto |= mlxsw_sp_port_link_mode[i].mask;
+	}
+	return ptys_proto;
+}
+
+static int mlxsw_sp_port_set_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
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
+		mlxsw_sp_to_ptys_advert_link(cmd->advertising) :
+		mlxsw_sp_to_ptys_speed(speed);
+
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
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
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, eth_proto_new);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
+	if (err) {
+		netdev_err(dev, "Failed to set proto admin");
+		return err;
+	}
+
+	err = mlxsw_sp_port_oper_status_get(mlxsw_sp_port, &is_up);
+	if (err) {
+		netdev_err(dev, "Failed to get oper status");
+		return err;
+	}
+	if (!is_up)
+		return 0;
+
+	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, false);
+	if (err) {
+		netdev_err(dev, "Failed to set admin status");
+		return err;
+	}
+
+	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, true);
+	if (err) {
+		netdev_err(dev, "Failed to set admin status");
+		return err;
+	}
+
+	return 0;
+}
+
+static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
+	.get_drvinfo		= mlxsw_sp_port_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_strings		= mlxsw_sp_port_get_strings,
+	.get_ethtool_stats	= mlxsw_sp_port_get_stats,
+	.get_sset_count		= mlxsw_sp_port_get_sset_count,
+	.get_settings		= mlxsw_sp_port_get_settings,
+	.set_settings		= mlxsw_sp_port_set_settings,
+};
+
+static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct net_device *dev;
+	bool usable;
+	int err;
+
+	dev = alloc_etherdev(sizeof(struct mlxsw_sp_port));
+	if (!dev)
+		return -ENOMEM;
+	mlxsw_sp_port = netdev_priv(dev);
+	mlxsw_sp_port->dev = dev;
+	mlxsw_sp_port->mlxsw_sp = mlxsw_sp;
+	mlxsw_sp_port->local_port = local_port;
+	mlxsw_sp_port->learning = 1;
+	mlxsw_sp_port->learning_sync = 1;
+	mlxsw_sp_port->pvid = 1;
+
+	mlxsw_sp_port->pcpu_stats =
+		netdev_alloc_pcpu_stats(struct mlxsw_sp_port_pcpu_stats);
+	if (!mlxsw_sp_port->pcpu_stats) {
+		err = -ENOMEM;
+		goto err_alloc_stats;
+	}
+
+	dev->netdev_ops = &mlxsw_sp_port_netdev_ops;
+	dev->ethtool_ops = &mlxsw_sp_port_ethtool_ops;
+
+	err = mlxsw_sp_port_dev_addr_init(mlxsw_sp_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Unable to init port mac address\n",
+			mlxsw_sp_port->local_port);
+		goto err_dev_addr_init;
+	}
+
+	netif_carrier_off(dev);
+
+	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_LLTX | NETIF_F_SG |
+			 NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	/* Each packet needs to have a Tx header (metadata) on top all other
+	 * headers.
+	 */
+	dev->hard_header_len += MLXSW_TXHDR_LEN;
+
+	err = mlxsw_sp_port_module_check(mlxsw_sp_port, &usable);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to check module\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_module_check;
+	}
+
+	if (!usable) {
+		dev_dbg(mlxsw_sp->bus_info->dev, "Port %d: Not usable, skipping initialization\n",
+			mlxsw_sp_port->local_port);
+		goto port_not_usable;
+	}
+
+	err = mlxsw_sp_port_system_port_mapping_set(mlxsw_sp_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set system port mapping\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_system_port_mapping_set;
+	}
+
+	err = mlxsw_sp_port_swid_set(mlxsw_sp_port, 0);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set SWID\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_swid_set;
+	}
+
+	err = mlxsw_sp_port_mtu_set(mlxsw_sp_port, ETH_DATA_LEN);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set MTU\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_mtu_set;
+	}
+
+	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, false);
+	if (err)
+		goto err_port_admin_status_set;
+
+	err = mlxsw_sp_port_buffers_init(mlxsw_sp_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to initialize buffers\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_buffers_init;
+	}
+
+	mlxsw_sp_port_switchdev_init(mlxsw_sp_port);
+	err = register_netdev(dev);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to register netdev\n",
+			mlxsw_sp_port->local_port);
+		goto err_register_netdev;
+	}
+
+	err = mlxsw_sp_port_vlan_init(mlxsw_sp_port);
+	if (err)
+		goto err_port_vlan_init;
+
+	mlxsw_sp->ports[local_port] = mlxsw_sp_port;
+	return 0;
+
+err_port_vlan_init:
+	unregister_netdev(dev);
+err_register_netdev:
+err_port_buffers_init:
+err_port_admin_status_set:
+err_port_mtu_set:
+err_port_swid_set:
+err_port_system_port_mapping_set:
+port_not_usable:
+err_port_module_check:
+err_dev_addr_init:
+	free_percpu(mlxsw_sp_port->pcpu_stats);
+err_alloc_stats:
+	free_netdev(dev);
+	return err;
+}
+
+static void mlxsw_sp_vfids_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	u16 vfid;
+
+	for_each_set_bit(vfid, mlxsw_sp->active_vfids, VLAN_N_VID)
+		mlxsw_sp_vfid_destroy(mlxsw_sp, vfid);
+}
+
+static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
+
+	if (!mlxsw_sp_port)
+		return;
+	mlxsw_sp_port_kill_vid(mlxsw_sp_port->dev, 0, 1);
+	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
+	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
+	free_percpu(mlxsw_sp_port->pcpu_stats);
+	free_netdev(mlxsw_sp_port->dev);
+}
+
+static void mlxsw_sp_ports_remove(struct mlxsw_sp *mlxsw_sp)
+{
+	int i;
+
+	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
+		mlxsw_sp_port_remove(mlxsw_sp, i);
+	kfree(mlxsw_sp->ports);
+}
+
+static int mlxsw_sp_ports_create(struct mlxsw_sp *mlxsw_sp)
+{
+	size_t alloc_size;
+	int i;
+	int err;
+
+	alloc_size = sizeof(struct mlxsw_sp_port *) * MLXSW_PORT_MAX_PORTS;
+	mlxsw_sp->ports = kzalloc(alloc_size, GFP_KERNEL);
+	if (!mlxsw_sp->ports)
+		return -ENOMEM;
+
+	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++) {
+		err = mlxsw_sp_port_create(mlxsw_sp, i);
+		if (err)
+			goto err_port_create;
+	}
+	return 0;
+
+err_port_create:
+	for (i--; i >= 1; i--)
+		mlxsw_sp_port_remove(mlxsw_sp, i);
+	kfree(mlxsw_sp->ports);
+	return err;
+}
+
+static void mlxsw_sp_pude_event_func(const struct mlxsw_reg_info *reg,
+				     char *pude_pl, void *priv)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	enum mlxsw_reg_pude_oper_status status;
+	u8 local_port;
+
+	local_port = mlxsw_reg_pude_local_port_get(pude_pl);
+	mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	if (!mlxsw_sp_port) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Port %d: Link event received for non-existent port\n",
+			 local_port);
+		return;
+	}
+
+	status = mlxsw_reg_pude_oper_status_get(pude_pl);
+	if (status == MLXSW_PORT_OPER_STATUS_UP) {
+		netdev_info(mlxsw_sp_port->dev, "link up\n");
+		netif_carrier_on(mlxsw_sp_port->dev);
+	} else {
+		netdev_info(mlxsw_sp_port->dev, "link down\n");
+		netif_carrier_off(mlxsw_sp_port->dev);
+	}
+}
+
+static struct mlxsw_event_listener mlxsw_sp_pude_event = {
+	.func = mlxsw_sp_pude_event_func,
+	.trap_id = MLXSW_TRAP_ID_PUDE,
+};
+
+static int mlxsw_sp_event_register(struct mlxsw_sp *mlxsw_sp,
+				   enum mlxsw_event_trap_id trap_id)
+{
+	struct mlxsw_event_listener *el;
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int err;
+
+	switch (trap_id) {
+	case MLXSW_TRAP_ID_PUDE:
+		el = &mlxsw_sp_pude_event;
+		break;
+	}
+	err = mlxsw_core_event_listener_register(mlxsw_sp->core, el, mlxsw_sp);
+	if (err)
+		return err;
+
+	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD, trap_id);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
+	if (err)
+		goto err_event_trap_set;
+
+	return 0;
+
+err_event_trap_set:
+	mlxsw_core_event_listener_unregister(mlxsw_sp->core, el, mlxsw_sp);
+	return err;
+}
+
+static void mlxsw_sp_event_unregister(struct mlxsw_sp *mlxsw_sp,
+				      enum mlxsw_event_trap_id trap_id)
+{
+	struct mlxsw_event_listener *el;
+
+	switch (trap_id) {
+	case MLXSW_TRAP_ID_PUDE:
+		el = &mlxsw_sp_pude_event;
+		break;
+	}
+	mlxsw_core_event_listener_unregister(mlxsw_sp->core, el, mlxsw_sp);
+}
+
+static void mlxsw_sp_rx_listener_func(struct sk_buff *skb, u8 local_port,
+				      void *priv)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	struct mlxsw_sp_port_pcpu_stats *pcpu_stats;
+
+	if (unlikely(!mlxsw_sp_port)) {
+		dev_warn_ratelimited(mlxsw_sp->bus_info->dev, "Port %d: skb received for non-existent port\n",
+				     local_port);
+		return;
+	}
+
+	skb->dev = mlxsw_sp_port->dev;
+
+	pcpu_stats = this_cpu_ptr(mlxsw_sp_port->pcpu_stats);
+	u64_stats_update_begin(&pcpu_stats->syncp);
+	pcpu_stats->rx_packets++;
+	pcpu_stats->rx_bytes += skb->len;
+	u64_stats_update_end(&pcpu_stats->syncp);
+
+	skb->protocol = eth_type_trans(skb, skb->dev);
+	netif_receive_skb(skb);
+}
+
+static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_FDB_MC,
+	},
+	/* Traps for specific L2 packet types, not trapped as FDB MC */
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_STP,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_LACP,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_EAPOL,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_LLDP,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_MMRP,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_MVRP,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_RPVST,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_DHCP,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_IGMP_QUERY,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V1_REPORT,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V2_REPORT,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V2_LEAVE,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_IGMP_V3_REPORT,
+	},
+};
+
+static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
+{
+	char htgt_pl[MLXSW_REG_HTGT_LEN];
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int i;
+	int err;
+
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_RX);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(htgt), htgt_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_CTRL);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(htgt), htgt_pl);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_rx_listener); i++) {
+		err = mlxsw_core_rx_listener_register(mlxsw_sp->core,
+						      &mlxsw_sp_rx_listener[i],
+						      mlxsw_sp);
+		if (err)
+			goto err_rx_listener_register;
+
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
+				    mlxsw_sp_rx_listener[i].trap_id);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
+		if (err)
+			goto err_rx_trap_set;
+	}
+	return 0;
+
+err_rx_trap_set:
+	mlxsw_core_rx_listener_unregister(mlxsw_sp->core,
+					  &mlxsw_sp_rx_listener[i],
+					  mlxsw_sp);
+err_rx_listener_register:
+	for (i--; i >= 0; i--) {
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
+				    mlxsw_sp_rx_listener[i].trap_id);
+		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
+
+		mlxsw_core_rx_listener_unregister(mlxsw_sp->core,
+						  &mlxsw_sp_rx_listener[i],
+						  mlxsw_sp);
+	}
+	return err;
+}
+
+static void mlxsw_sp_traps_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_rx_listener); i++) {
+		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
+				    mlxsw_sp_rx_listener[i].trap_id);
+		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
+
+		mlxsw_core_rx_listener_unregister(mlxsw_sp->core,
+						  &mlxsw_sp_rx_listener[i],
+						  mlxsw_sp);
+	}
+}
+
+static int __mlxsw_sp_flood_init(struct mlxsw_core *mlxsw_core,
+				 enum mlxsw_reg_sfgc_type type,
+				 enum mlxsw_reg_sfgc_bridge_type bridge_type)
+{
+	enum mlxsw_flood_table_type table_type;
+	enum mlxsw_sp_flood_table flood_table;
+	char sfgc_pl[MLXSW_REG_SFGC_LEN];
+
+	if (bridge_type == MLXSW_REG_SFGC_BRIDGE_TYPE_VFID) {
+		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID;
+		flood_table = 0;
+	} else {
+		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
+		if (type == MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST)
+			flood_table = MLXSW_SP_FLOOD_TABLE_UC;
+		else
+			flood_table = MLXSW_SP_FLOOD_TABLE_BM;
+	}
+
+	mlxsw_reg_sfgc_pack(sfgc_pl, type, bridge_type, table_type,
+			    flood_table);
+	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(sfgc), sfgc_pl);
+}
+
+static int mlxsw_sp_flood_init(struct mlxsw_sp *mlxsw_sp)
+{
+	int type, err;
+
+	/* For non-offloaded netdevs, flood all traffic types to CPU
+	 * port.
+	 */
+	for (type = 0; type < MLXSW_REG_SFGC_TYPE_MAX; type++) {
+		if (type == MLXSW_REG_SFGC_TYPE_RESERVED)
+			continue;
+
+		err = __mlxsw_sp_flood_init(mlxsw_sp->core, type,
+					    MLXSW_REG_SFGC_BRIDGE_TYPE_VFID);
+		if (err)
+			return err;
+	}
+
+	/* For bridged ports, use one flooding table for unknown unicast
+	 * traffic and a second table for unregistered multicast and
+	 * broadcast.
+	 */
+	for (type = 0; type < MLXSW_REG_SFGC_TYPE_MAX; type++) {
+		if (type == MLXSW_REG_SFGC_TYPE_RESERVED)
+			continue;
+
+		err = __mlxsw_sp_flood_init(mlxsw_sp->core, type,
+					    MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int mlxsw_sp_init(void *priv, struct mlxsw_core *mlxsw_core,
+			 const struct mlxsw_bus_info *mlxsw_bus_info)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	int err;
+
+	mlxsw_sp->core = mlxsw_core;
+	mlxsw_sp->bus_info = mlxsw_bus_info;
+
+	err = mlxsw_sp_base_mac_get(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to get base mac\n");
+		return err;
+	}
+
+	err = mlxsw_sp_ports_create(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
+		goto err_ports_create;
+	}
+
+	err = mlxsw_sp_event_register(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to register for PUDE events\n");
+		goto err_event_register;
+	}
+
+	err = mlxsw_sp_traps_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to set traps for RX\n");
+		goto err_rx_listener_register;
+	}
+
+	err = mlxsw_sp_flood_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to initialize flood tables\n");
+		goto err_flood_init;
+	}
+
+	err = mlxsw_sp_buffers_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to initialize buffers\n");
+		goto err_buffers_init;
+	}
+
+	err = mlxsw_sp_switchdev_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to initialize switchdev\n");
+		goto err_switchdev_init;
+	}
+
+	return 0;
+
+err_switchdev_init:
+err_buffers_init:
+err_flood_init:
+	mlxsw_sp_traps_fini(mlxsw_sp);
+err_rx_listener_register:
+	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
+err_event_register:
+	mlxsw_sp_ports_remove(mlxsw_sp);
+err_ports_create:
+	mlxsw_sp_vfids_fini(mlxsw_sp);
+	return err;
+}
+
+static void mlxsw_sp_fini(void *priv)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+
+	mlxsw_sp_switchdev_fini(mlxsw_sp);
+	mlxsw_sp_traps_fini(mlxsw_sp);
+	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
+	mlxsw_sp_ports_remove(mlxsw_sp);
+	mlxsw_sp_vfids_fini(mlxsw_sp);
+}
+
+static struct mlxsw_config_profile mlxsw_sp_config_profile = {
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
+	.max_system_port		= 64,
+	.used_max_vlan_groups		= 1,
+	.max_vlan_groups		= 127,
+	.used_max_regions		= 1,
+	.max_regions			= 400,
+	.used_flood_tables		= 1,
+	.used_flood_mode		= 1,
+	.flood_mode			= 3,
+	.max_fid_offset_flood_tables	= 2,
+	.fid_offset_flood_table_size	= VLAN_N_VID - 1,
+	.max_fid_flood_tables		= 1,
+	.fid_flood_table_size		= VLAN_N_VID,
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
+static struct mlxsw_driver mlxsw_sp_driver = {
+	.kind			= MLXSW_DEVICE_KIND_SPECTRUM,
+	.owner			= THIS_MODULE,
+	.priv_size		= sizeof(struct mlxsw_sp),
+	.init			= mlxsw_sp_init,
+	.fini			= mlxsw_sp_fini,
+	.txhdr_construct	= mlxsw_sp_txhdr_construct,
+	.txhdr_len		= MLXSW_TXHDR_LEN,
+	.profile		= &mlxsw_sp_config_profile,
+};
+
+static bool mlxsw_sp_port_dev_check(const struct net_device *dev)
+{
+	return dev->netdev_ops == &mlxsw_sp_port_netdev_ops;
+}
+
+static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct net_device *dev = mlxsw_sp_port->dev;
+	int err;
+
+	/* When port is not bridged untagged packets are tagged with
+	 * PVID=VID=1, thereby creating an implicit VLAN interface in
+	 * the device. Remove it and let bridge code take care of its
+	 * own VLANs.
+	 */
+	err = mlxsw_sp_port_kill_vid(dev, 0, 1);
+	if (err)
+		netdev_err(dev, "Failed to remove VID 1\n");
+
+	return err;
+}
+
+static int mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct net_device *dev = mlxsw_sp_port->dev;
+	int err;
+
+	/* Add implicit VLAN interface in the device, so that untagged
+	 * packets will be classified to the default vFID.
+	 */
+	err = mlxsw_sp_port_add_vid(dev, 0, 1);
+	if (err)
+		netdev_err(dev, "Failed to add VID 1\n");
+
+	return err;
+}
+
+static bool mlxsw_sp_master_bridge_check(struct mlxsw_sp *mlxsw_sp,
+					 struct net_device *br_dev)
+{
+	return !mlxsw_sp->master_bridge.dev ||
+	       mlxsw_sp->master_bridge.dev == br_dev;
+}
+
+static void mlxsw_sp_master_bridge_inc(struct mlxsw_sp *mlxsw_sp,
+				       struct net_device *br_dev)
+{
+	mlxsw_sp->master_bridge.dev = br_dev;
+	mlxsw_sp->master_bridge.ref_count++;
+}
+
+static void mlxsw_sp_master_bridge_dec(struct mlxsw_sp *mlxsw_sp,
+				       struct net_device *br_dev)
+{
+	if (--mlxsw_sp->master_bridge.ref_count == 0)
+		mlxsw_sp->master_bridge.dev = NULL;
+}
+
+static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
+				    unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct netdev_notifier_changeupper_info *info;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct net_device *upper_dev;
+	struct mlxsw_sp *mlxsw_sp;
+	int err;
+
+	if (!mlxsw_sp_port_dev_check(dev))
+		return NOTIFY_DONE;
+
+	mlxsw_sp_port = netdev_priv(dev);
+	mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	info = ptr;
+
+	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
+		upper_dev = info->upper_dev;
+		/* HW limitation forbids to put ports to multiple bridges. */
+		if (info->master && info->linking &&
+		    netif_is_bridge_master(upper_dev) &&
+		    !mlxsw_sp_master_bridge_check(mlxsw_sp, upper_dev))
+			return NOTIFY_BAD;
+		break;
+	case NETDEV_CHANGEUPPER:
+		upper_dev = info->upper_dev;
+		if (info->master &&
+		    netif_is_bridge_master(upper_dev)) {
+			if (info->linking) {
+				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port);
+				if (err)
+					netdev_err(dev, "Failed to join bridge\n");
+				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
+				mlxsw_sp_port->bridged = true;
+			} else {
+				err = mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
+				if (err)
+					netdev_err(dev, "Failed to leave bridge\n");
+				mlxsw_sp_port->bridged = false;
+				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
+			}
+		}
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block mlxsw_sp_netdevice_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_netdevice_event,
+};
+
+static int __init mlxsw_sp_module_init(void)
+{
+	int err;
+
+	register_netdevice_notifier(&mlxsw_sp_netdevice_nb);
+	err = mlxsw_core_driver_register(&mlxsw_sp_driver);
+	if (err)
+		goto err_core_driver_register;
+	return 0;
+
+err_core_driver_register:
+	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
+	return err;
+}
+
+static void __exit mlxsw_sp_module_exit(void)
+{
+	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
+	unregister_netdevice_notifier(&mlxsw_sp_netdevice_nb);
+}
+
+module_init(mlxsw_sp_module_init);
+module_exit(mlxsw_sp_module_exit);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
+MODULE_DESCRIPTION("Mellanox Spectrum driver");
+MODULE_MLXSW_DRIVER_ALIAS(MLXSW_DEVICE_KIND_SPECTRUM);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
new file mode 100644
index 0000000..fc00749
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -0,0 +1,121 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum.h
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
+#ifndef _MLXSW_SPECTRUM_H
+#define _MLXSW_SPECTRUM_H
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/bitops.h>
+#include <linux/if_vlan.h>
+#include <net/switchdev.h>
+
+#include "core.h"
+
+#define MLXSW_SP_VFID_BASE VLAN_N_VID
+
+struct mlxsw_sp_port;
+
+struct mlxsw_sp {
+	unsigned long active_vfids[BITS_TO_LONGS(VLAN_N_VID)];
+	unsigned long active_fids[BITS_TO_LONGS(VLAN_N_VID)];
+	struct mlxsw_sp_port **ports;
+	struct mlxsw_core *core;
+	const struct mlxsw_bus_info *bus_info;
+	unsigned char base_mac[ETH_ALEN];
+	struct {
+		struct delayed_work dw;
+#define MLXSW_SP_DEFAULT_LEARNING_INTERVAL 100
+		unsigned int interval; /* ms */
+	} fdb_notify;
+#define MLXSW_SP_DEFAULT_AGEING_TIME 300
+	u32 ageing_time;
+	struct {
+		struct net_device *dev;
+		unsigned int ref_count;
+	} master_bridge;
+};
+
+struct mlxsw_sp_port_pcpu_stats {
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+	u32			tx_dropped;
+};
+
+struct mlxsw_sp_port {
+	struct net_device *dev;
+	struct mlxsw_sp_port_pcpu_stats __percpu *pcpu_stats;
+	struct mlxsw_sp *mlxsw_sp;
+	u8 local_port;
+	u8 stp_state;
+	u8 learning:1;
+	u8 learning_sync:1;
+	u16 pvid;
+	bool bridged;
+	/* 802.1Q bridge VLANs */
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	/* VLAN interfaces */
+	unsigned long active_vfids[BITS_TO_LONGS(VLAN_N_VID)];
+	u16 nr_vfids;
+};
+
+enum mlxsw_sp_flood_table {
+	MLXSW_SP_FLOOD_TABLE_UC,
+	MLXSW_SP_FLOOD_TABLE_BM,
+};
+
+int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp);
+int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port);
+
+int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp);
+void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp);
+int mlxsw_sp_port_vlan_init(struct mlxsw_sp_port *mlxsw_sp_port);
+void mlxsw_sp_port_switchdev_init(struct mlxsw_sp_port *mlxsw_sp_port);
+void mlxsw_sp_port_switchdev_fini(struct mlxsw_sp_port *mlxsw_sp_port);
+int mlxsw_sp_port_vid_to_fid_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				 enum mlxsw_reg_svfa_mt mt, bool valid, u16 fid,
+				 u16 vid);
+int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
+			   u16 vid_end, bool is_member, bool untagged);
+int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
+			  u16 vid);
+int mlxsw_sp_port_kill_vid(struct net_device *dev,
+			   __be16 __always_unused proto, u16 vid);
+
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
new file mode 100644
index 0000000..d59195e
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -0,0 +1,422 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
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
+#include <linux/kernel.h>
+#include <linux/types.h>
+
+#include "spectrum.h"
+#include "core.h"
+#include "port.h"
+#include "reg.h"
+
+struct mlxsw_sp_pb {
+	u8 index;
+	u16 size;
+};
+
+#define MLXSW_SP_PB(_index, _size)	\
+	{				\
+		.index = _index,	\
+		.size = _size,		\
+	}
+
+static const struct mlxsw_sp_pb mlxsw_sp_pbs[] = {
+	MLXSW_SP_PB(0, 208),
+	MLXSW_SP_PB(1, 208),
+	MLXSW_SP_PB(2, 208),
+	MLXSW_SP_PB(3, 208),
+	MLXSW_SP_PB(4, 208),
+	MLXSW_SP_PB(5, 208),
+	MLXSW_SP_PB(6, 208),
+	MLXSW_SP_PB(7, 208),
+	MLXSW_SP_PB(9, 208),
+};
+
+#define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)
+
+static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	char pbmc_pl[MLXSW_REG_PBMC_LEN];
+	int i;
+
+	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port,
+			    0xffff, 0xffff / 2);
+	for (i = 0; i < MLXSW_SP_PBS_LEN; i++) {
+		const struct mlxsw_sp_pb *pb;
+
+		pb = &mlxsw_sp_pbs[i];
+		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pb->index, pb->size);
+	}
+	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core,
+			       MLXSW_REG(pbmc), pbmc_pl);
+}
+
+#define MLXSW_SP_SB_BYTES_PER_CELL 96
+
+struct mlxsw_sp_sb_pool {
+	u8 pool;
+	enum mlxsw_reg_sbpr_dir dir;
+	enum mlxsw_reg_sbpr_mode mode;
+	u32 size;
+};
+
+#define MLXSW_SP_SB_POOL_INGRESS_SIZE				\
+	((15000000 - (2 * 20000 * MLXSW_PORT_MAX_PORTS)) /	\
+	 MLXSW_SP_SB_BYTES_PER_CELL)
+#define MLXSW_SP_SB_POOL_EGRESS_SIZE				\
+	((14000000 - (8 * 1500 * MLXSW_PORT_MAX_PORTS)) /	\
+	 MLXSW_SP_SB_BYTES_PER_CELL)
+
+#define MLXSW_SP_SB_POOL(_pool, _dir, _mode, _size)		\
+	{							\
+		.pool = _pool,					\
+		.dir = _dir,					\
+		.mode = _mode,					\
+		.size = _size,					\
+	}
+
+#define MLXSW_SP_SB_POOL_INGRESS(_pool, _size)			\
+	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBPR_DIR_INGRESS,	\
+			 MLXSW_REG_SBPR_MODE_DYNAMIC, _size)
+
+#define MLXSW_SP_SB_POOL_EGRESS(_pool, _size)			\
+	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBPR_DIR_EGRESS,	\
+			 MLXSW_REG_SBPR_MODE_DYNAMIC, _size)
+
+static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools[] = {
+	MLXSW_SP_SB_POOL_INGRESS(0, MLXSW_SP_SB_POOL_INGRESS_SIZE),
+	MLXSW_SP_SB_POOL_INGRESS(1, 0),
+	MLXSW_SP_SB_POOL_INGRESS(2, 0),
+	MLXSW_SP_SB_POOL_INGRESS(3, 0),
+	MLXSW_SP_SB_POOL_EGRESS(0, MLXSW_SP_SB_POOL_EGRESS_SIZE),
+	MLXSW_SP_SB_POOL_EGRESS(1, 0),
+	MLXSW_SP_SB_POOL_EGRESS(2, 0),
+	MLXSW_SP_SB_POOL_EGRESS(2, MLXSW_SP_SB_POOL_EGRESS_SIZE),
+};
+
+#define MLXSW_SP_SB_POOLS_LEN ARRAY_SIZE(mlxsw_sp_sb_pools)
+
+static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
+{
+	char sbpr_pl[MLXSW_REG_SBPR_LEN];
+	int i;
+	int err;
+
+	for (i = 0; i < MLXSW_SP_SB_POOLS_LEN; i++) {
+		const struct mlxsw_sp_sb_pool *pool;
+
+		pool = &mlxsw_sp_sb_pools[i];
+		mlxsw_reg_sbpr_pack(sbpr_pl, pool->pool, pool->dir,
+				    pool->mode, pool->size);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpr), sbpr_pl);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+struct mlxsw_sp_sb_cm {
+	union {
+		u8 pg;
+		u8 tc;
+	} u;
+	enum mlxsw_reg_sbcm_dir dir;
+	u32 min_buff;
+	u32 max_buff;
+	u8 pool;
+};
+
+#define MLXSW_SP_SB_CM(_pg_tc, _dir, _min_buff, _max_buff, _pool)	\
+	{								\
+		.u.pg = _pg_tc,						\
+		.dir = _dir,						\
+		.min_buff = _min_buff,					\
+		.max_buff = _max_buff,					\
+		.pool = _pool,						\
+	}
+
+#define MLXSW_SP_SB_CM_INGRESS(_pg, _min_buff, _max_buff)		\
+	MLXSW_SP_SB_CM(_pg, MLXSW_REG_SBCM_DIR_INGRESS,			\
+		       _min_buff, _max_buff, 0)
+
+#define MLXSW_SP_SB_CM_EGRESS(_tc, _min_buff, _max_buff)		\
+	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBCM_DIR_EGRESS,			\
+		       _min_buff, _max_buff, 0)
+
+#define MLXSW_SP_CPU_PORT_SB_CM_EGRESS(_tc)				\
+	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBCM_DIR_EGRESS, 104, 2, 3)
+
+static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms[] = {
+	MLXSW_SP_SB_CM_INGRESS(0, 10000 / MLXSW_SP_SB_BYTES_PER_CELL, 8),
+	MLXSW_SP_SB_CM_INGRESS(1, 0, 0),
+	MLXSW_SP_SB_CM_INGRESS(2, 0, 0),
+	MLXSW_SP_SB_CM_INGRESS(3, 0, 0),
+	MLXSW_SP_SB_CM_INGRESS(4, 0, 0),
+	MLXSW_SP_SB_CM_INGRESS(5, 0, 0),
+	MLXSW_SP_SB_CM_INGRESS(6, 0, 0),
+	MLXSW_SP_SB_CM_INGRESS(7, 0, 0),
+	MLXSW_SP_SB_CM_INGRESS(9, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff),
+	MLXSW_SP_SB_CM_EGRESS(0, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(1, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(2, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(3, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(4, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(5, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(6, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(7, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_EGRESS(8, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(9, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(10, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(11, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(12, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(13, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(14, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(15, 0, 0),
+	MLXSW_SP_SB_CM_EGRESS(16, 1, 0xff),
+};
+
+#define MLXSW_SP_SB_CMS_LEN ARRAY_SIZE(mlxsw_sp_sb_cms)
+
+static const struct mlxsw_sp_sb_cm mlxsw_sp_cpu_port_sb_cms[] = {
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(0),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(1),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(2),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(3),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(4),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(5),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(6),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(7),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(8),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(9),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(10),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(11),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(12),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(13),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(14),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(15),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(16),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(17),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(18),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(19),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(20),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(21),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(22),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(23),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(24),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(25),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(26),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(27),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(28),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(29),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(30),
+	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(31),
+};
+
+#define MLXSW_SP_CPU_PORT_SB_MCS_LEN \
+	ARRAY_SIZE(mlxsw_sp_cpu_port_sb_cms)
+
+static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				const struct mlxsw_sp_sb_cm *cms,
+				size_t cms_len)
+{
+	char sbcm_pl[MLXSW_REG_SBCM_LEN];
+	int i;
+	int err;
+
+	for (i = 0; i < cms_len; i++) {
+		const struct mlxsw_sp_sb_cm *cm;
+
+		cm = &cms[i];
+		mlxsw_reg_sbcm_pack(sbcm_pl, local_port, cm->u.pg, cm->dir,
+				    cm->min_buff, cm->max_buff, cm->pool);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbcm), sbcm_pl);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int mlxsw_sp_port_sb_cms_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	return mlxsw_sp_sb_cms_init(mlxsw_sp_port->mlxsw_sp,
+				    mlxsw_sp_port->local_port, mlxsw_sp_sb_cms,
+				    MLXSW_SP_SB_CMS_LEN);
+}
+
+static int mlxsw_sp_cpu_port_sb_cms_init(struct mlxsw_sp *mlxsw_sp)
+{
+	return mlxsw_sp_sb_cms_init(mlxsw_sp, 0, mlxsw_sp_cpu_port_sb_cms,
+				    MLXSW_SP_CPU_PORT_SB_MCS_LEN);
+}
+
+struct mlxsw_sp_sb_pm {
+	u8 pool;
+	enum mlxsw_reg_sbpm_dir dir;
+	u32 min_buff;
+	u32 max_buff;
+};
+
+#define MLXSW_SP_SB_PM(_pool, _dir, _min_buff, _max_buff)	\
+	{							\
+		.pool = _pool,					\
+		.dir = _dir,					\
+		.min_buff = _min_buff,				\
+		.max_buff = _max_buff,				\
+	}
+
+#define MLXSW_SP_SB_PM_INGRESS(_pool, _min_buff, _max_buff)	\
+	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBPM_DIR_INGRESS,	\
+		       _min_buff, _max_buff)
+
+#define MLXSW_SP_SB_PM_EGRESS(_pool, _min_buff, _max_buff)	\
+	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBPM_DIR_EGRESS,	\
+		       _min_buff, _max_buff)
+
+static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms[] = {
+	MLXSW_SP_SB_PM_INGRESS(0, 0, 0xff),
+	MLXSW_SP_SB_PM_INGRESS(1, 0, 0),
+	MLXSW_SP_SB_PM_INGRESS(2, 0, 0),
+	MLXSW_SP_SB_PM_INGRESS(3, 0, 0),
+	MLXSW_SP_SB_PM_EGRESS(0, 0, 7),
+	MLXSW_SP_SB_PM_EGRESS(1, 0, 0),
+	MLXSW_SP_SB_PM_EGRESS(2, 0, 0),
+	MLXSW_SP_SB_PM_EGRESS(3, 0, 0),
+};
+
+#define MLXSW_SP_SB_PMS_LEN ARRAY_SIZE(mlxsw_sp_sb_pms)
+
+static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	char sbpm_pl[MLXSW_REG_SBPM_LEN];
+	int i;
+	int err;
+
+	for (i = 0; i < MLXSW_SP_SB_PMS_LEN; i++) {
+		const struct mlxsw_sp_sb_pm *pm;
+
+		pm = &mlxsw_sp_sb_pms[i];
+		mlxsw_reg_sbpm_pack(sbpm_pl, mlxsw_sp_port->local_port,
+				    pm->pool, pm->dir,
+				    pm->min_buff, pm->max_buff);
+		err = mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core,
+				      MLXSW_REG(sbpm), sbpm_pl);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+struct mlxsw_sp_sb_mm {
+	u8 prio;
+	u32 min_buff;
+	u32 max_buff;
+	u8 pool;
+};
+
+#define MLXSW_SP_SB_MM(_prio, _min_buff, _max_buff, _pool)	\
+	{							\
+		.prio = _prio,					\
+		.min_buff = _min_buff,				\
+		.max_buff = _max_buff,				\
+		.pool = _pool,					\
+	}
+
+static const struct mlxsw_sp_sb_mm mlxsw_sp_sb_mms[] = {
+	MLXSW_SP_SB_MM(0, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(1, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(2, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(3, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(4, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(5, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(6, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(7, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(8, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(9, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(10, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(11, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(12, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(13, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(14, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+};
+
+#define MLXSW_SP_SB_MMS_LEN ARRAY_SIZE(mlxsw_sp_sb_mms)
+
+static int mlxsw_sp_sb_mms_init(struct mlxsw_sp *mlxsw_sp)
+{
+	char sbmm_pl[MLXSW_REG_SBMM_LEN];
+	int i;
+	int err;
+
+	for (i = 0; i < MLXSW_SP_SB_MMS_LEN; i++) {
+		const struct mlxsw_sp_sb_mm *mc;
+
+		mc = &mlxsw_sp_sb_mms[i];
+		mlxsw_reg_sbmm_pack(sbmm_pl, mc->prio, mc->min_buff,
+				    mc->max_buff, mc->pool);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbmm), sbmm_pl);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
+{
+	int err;
+
+	err = mlxsw_sp_sb_pools_init(mlxsw_sp);
+	if (err)
+		return err;
+	err = mlxsw_sp_cpu_port_sb_cms_init(mlxsw_sp);
+	if (err)
+		return err;
+	err = mlxsw_sp_sb_mms_init(mlxsw_sp);
+
+	return err;
+}
+
+int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	int err;
+
+	err = mlxsw_sp_port_pb_init(mlxsw_sp_port);
+	if (err)
+		return err;
+	err = mlxsw_sp_port_sb_cms_init(mlxsw_sp_port);
+	if (err)
+		return err;
+	err = mlxsw_sp_port_sb_pms_init(mlxsw_sp_port);
+
+	return err;
+}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
new file mode 100644
index 0000000..c39b7a1
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -0,0 +1,863 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
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
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/slab.h>
+#include <linux/device.h>
+#include <linux/skbuff.h>
+#include <linux/if_vlan.h>
+#include <linux/if_bridge.h>
+#include <linux/workqueue.h>
+#include <linux/jiffies.h>
+#include <net/switchdev.h>
+
+#include "spectrum.h"
+#include "core.h"
+#include "reg.h"
+
+static int mlxsw_sp_port_attr_get(struct net_device *dev,
+				  struct switchdev_attr *attr)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		attr->u.ppid.id_len = sizeof(mlxsw_sp->base_mac);
+		memcpy(&attr->u.ppid.id, &mlxsw_sp->base_mac,
+		       attr->u.ppid.id_len);
+		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
+		attr->u.brport_flags =
+			(mlxsw_sp_port->learning ? BR_LEARNING : 0) |
+			(mlxsw_sp_port->learning_sync ? BR_LEARNING_SYNC : 0);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				       u8 state)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	enum mlxsw_reg_spms_state spms_state;
+	char *spms_pl;
+	u16 vid;
+	int err;
+
+	switch (state) {
+	case BR_STATE_DISABLED: /* fall-through */
+	case BR_STATE_FORWARDING:
+		spms_state = MLXSW_REG_SPMS_STATE_FORWARDING;
+		break;
+	case BR_STATE_LISTENING: /* fall-through */
+	case BR_STATE_LEARNING:
+		spms_state = MLXSW_REG_SPMS_STATE_LEARNING;
+		break;
+	case BR_STATE_BLOCKING:
+		spms_state = MLXSW_REG_SPMS_STATE_DISCARDING;
+		break;
+	default:
+		BUG();
+	}
+
+	spms_pl = kmalloc(MLXSW_REG_SPMS_LEN, GFP_KERNEL);
+	if (!spms_pl)
+		return -ENOMEM;
+	mlxsw_reg_spms_pack(spms_pl, mlxsw_sp_port->local_port);
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
+		mlxsw_reg_spms_vid_pack(spms_pl, vid, spms_state);
+
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spms), spms_pl);
+	kfree(spms_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					    struct switchdev_trans *trans,
+					    u8 state)
+{
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	mlxsw_sp_port->stp_state = state;
+	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port, state);
+}
+
+static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					   struct switchdev_trans *trans,
+					   unsigned long brport_flags)
+{
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	mlxsw_sp_port->learning = brport_flags & BR_LEARNING ? 1 : 0;
+	mlxsw_sp_port->learning_sync = brport_flags & BR_LEARNING_SYNC ? 1 : 0;
+	return 0;
+}
+
+static int mlxsw_sp_ageing_set(struct mlxsw_sp *mlxsw_sp, u32 ageing_time)
+{
+	char sfdat_pl[MLXSW_REG_SFDAT_LEN];
+	int err;
+
+	mlxsw_reg_sfdat_pack(sfdat_pl, ageing_time);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfdat), sfdat_pl);
+	if (err)
+		return err;
+	mlxsw_sp->ageing_time = ageing_time;
+	return 0;
+}
+
+static int mlxsw_sp_port_attr_br_ageing_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					    struct switchdev_trans *trans,
+					    unsigned long ageing_jiffies)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u32 ageing_time = jiffies_to_msecs(ageing_jiffies) / 1000;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	return mlxsw_sp_ageing_set(mlxsw_sp, ageing_time);
+}
+
+static int mlxsw_sp_port_attr_set(struct net_device *dev,
+				  const struct switchdev_attr *attr,
+				  struct switchdev_trans *trans)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
+		err = mlxsw_sp_port_attr_stp_state_set(mlxsw_sp_port, trans,
+						       attr->u.stp_state);
+		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
+		err = mlxsw_sp_port_attr_br_flags_set(mlxsw_sp_port, trans,
+						      attr->u.brport_flags);
+		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
+		err = mlxsw_sp_port_attr_br_ageing_set(mlxsw_sp_port, trans,
+						       attr->u.ageing_time);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char spvid_pl[MLXSW_REG_SPVID_LEN];
+
+	mlxsw_reg_spvid_pack(spvid_pl, mlxsw_sp_port->local_port, vid);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spvid), spvid_pl);
+}
+
+static int mlxsw_sp_fid_create(struct mlxsw_sp *mlxsw_sp, u16 fid)
+{
+	char sfmr_pl[MLXSW_REG_SFMR_LEN];
+	int err;
+
+	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_CREATE_FID, fid, fid);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
+
+	if (err)
+		return err;
+
+	set_bit(fid, mlxsw_sp->active_fids);
+	return 0;
+}
+
+static void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, u16 fid)
+{
+	char sfmr_pl[MLXSW_REG_SFMR_LEN];
+
+	clear_bit(fid, mlxsw_sp->active_fids);
+
+	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_DESTROY_FID,
+			    fid, fid);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
+}
+
+static int mlxsw_sp_port_fid_map(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
+{
+	enum mlxsw_reg_svfa_mt mt;
+
+	if (mlxsw_sp_port->nr_vfids)
+		mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
+	else
+		mt = MLXSW_REG_SVFA_MT_VID_TO_FID;
+
+	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, true, fid, fid);
+}
+
+static int mlxsw_sp_port_fid_unmap(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
+{
+	enum mlxsw_reg_svfa_mt mt;
+
+	if (!mlxsw_sp_port->nr_vfids)
+		return 0;
+
+	mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
+	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt, false, fid, fid);
+}
+
+static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 fid, bool set, bool only_uc)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char *sftr_pl;
+	int err;
+
+	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
+	if (!sftr_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, fid,
+			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, 0,
+			    mlxsw_sp_port->local_port, set);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+	if (err)
+		goto buffer_out;
+
+	/* Flooding control allows one to decide whether a given port will
+	 * flood unicast traffic for which there is no FDB entry.
+	 */
+	if (only_uc)
+		goto buffer_out;
+
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, fid,
+			    MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST, 0,
+			    mlxsw_sp_port->local_port, set);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+
+buffer_out:
+	kfree(sftr_pl);
+	return err;
+}
+
+static int mlxsw_sp_port_add_vids(struct net_device *dev, u16 vid_begin,
+				  u16 vid_end)
+{
+	u16 vid;
+	int err;
+
+	for (vid = vid_begin; vid <= vid_end; vid++) {
+		err = mlxsw_sp_port_add_vid(dev, 0, vid);
+		if (err)
+			goto err_port_add_vid;
+	}
+	return 0;
+
+err_port_add_vid:
+	for (vid--; vid >= vid_begin; vid--)
+		mlxsw_sp_port_kill_vid(dev, 0, vid);
+	return err;
+}
+
+static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 vid_begin, u16 vid_end,
+				     bool flag_untagged, bool flag_pvid)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct net_device *dev = mlxsw_sp_port->dev;
+	enum mlxsw_reg_svfa_mt mt;
+	u16 vid, vid_e;
+	int err;
+
+	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
+	 * not bridged, then packets ingressing through the port with
+	 * the specified VIDs will be directed to CPU.
+	 */
+	if (!mlxsw_sp_port->bridged)
+		return mlxsw_sp_port_add_vids(dev, vid_begin, vid_end);
+
+	for (vid = vid_begin; vid <= vid_end; vid++) {
+		if (!test_bit(vid, mlxsw_sp->active_fids)) {
+			err = mlxsw_sp_fid_create(mlxsw_sp, vid);
+			if (err) {
+				netdev_err(dev, "Failed to create FID=%d\n",
+					   vid);
+				return err;
+			}
+
+			/* When creating a FID, we set a VID to FID mapping
+			 * regardless of the port's mode.
+			 */
+			mt = MLXSW_REG_SVFA_MT_VID_TO_FID;
+			err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_port, mt,
+							   true, vid, vid);
+			if (err) {
+				netdev_err(dev, "Failed to create FID=VID=%d mapping\n",
+					   vid);
+				return err;
+			}
+		}
+
+		/* Set FID mapping according to port's mode */
+		err = mlxsw_sp_port_fid_map(mlxsw_sp_port, vid);
+		if (err) {
+			netdev_err(dev, "Failed to map FID=%d", vid);
+			return err;
+		}
+
+		err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, true,
+						false);
+		if (err) {
+			netdev_err(dev, "Failed to set flooding for FID=%d",
+				   vid);
+			return err;
+		}
+	}
+
+	for (vid = vid_begin; vid <= vid_end;
+	     vid += MLXSW_REG_SPVM_REC_MAX_COUNT) {
+		vid_e = min((u16) (vid + MLXSW_REG_SPVM_REC_MAX_COUNT - 1),
+			    vid_end);
+
+		err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e, true,
+					     flag_untagged);
+		if (err) {
+			netdev_err(mlxsw_sp_port->dev, "Unable to add VIDs %d-%d\n",
+				   vid, vid_e);
+			return err;
+		}
+	}
+
+	vid = vid_begin;
+	if (flag_pvid && mlxsw_sp_port->pvid != vid) {
+		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, vid);
+		if (err) {
+			netdev_err(mlxsw_sp_port->dev, "Unable to add PVID %d\n",
+				   vid);
+			return err;
+		}
+		mlxsw_sp_port->pvid = vid;
+	}
+
+	/* Changing activity bits only if HW operation succeded */
+	for (vid = vid_begin; vid <= vid_end; vid++)
+		set_bit(vid, mlxsw_sp_port->active_vlans);
+
+	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port,
+					   mlxsw_sp_port->stp_state);
+}
+
+static int mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
+				   const struct switchdev_obj_port_vlan *vlan,
+				   struct switchdev_trans *trans)
+{
+	bool untagged_flag = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	bool pvid_flag = vlan->flags & BRIDGE_VLAN_INFO_PVID;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	return __mlxsw_sp_port_vlans_add(mlxsw_sp_port,
+					 vlan->vid_begin, vlan->vid_end,
+					 untagged_flag, pvid_flag);
+}
+
+static int mlxsw_sp_port_fdb_op(struct mlxsw_sp_port *mlxsw_sp_port,
+				const char *mac, u16 vid, bool adding,
+				bool dynamic)
+{
+	enum mlxsw_reg_sfd_rec_policy policy;
+	enum mlxsw_reg_sfd_op op;
+	char *sfd_pl;
+	int err;
+
+	if (!vid)
+		vid = mlxsw_sp_port->pvid;
+
+	sfd_pl = kmalloc(MLXSW_REG_SFD_LEN, GFP_KERNEL);
+	if (!sfd_pl)
+		return -ENOMEM;
+
+	policy = dynamic ? MLXSW_REG_SFD_REC_POLICY_DYNAMIC_ENTRY_INGRESS :
+			   MLXSW_REG_SFD_REC_POLICY_STATIC_ENTRY;
+	op = adding ? MLXSW_REG_SFD_OP_WRITE_EDIT :
+		      MLXSW_REG_SFD_OP_WRITE_REMOVE;
+	mlxsw_reg_sfd_pack(sfd_pl, op, 0);
+	mlxsw_reg_sfd_uc_pack(sfd_pl, 0, policy,
+			      mac, vid, MLXSW_REG_SFD_REC_ACTION_NOP,
+			      mlxsw_sp_port->local_port);
+	err = mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(sfd),
+			      sfd_pl);
+	kfree(sfd_pl);
+
+	return err;
+}
+
+static int
+mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
+			     const struct switchdev_obj_port_fdb *fdb,
+			     struct switchdev_trans *trans)
+{
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	return mlxsw_sp_port_fdb_op(mlxsw_sp_port, fdb->addr, fdb->vid,
+				    true, false);
+}
+
+static int mlxsw_sp_port_obj_add(struct net_device *dev,
+				 const struct switchdev_obj *obj,
+				 struct switchdev_trans *trans)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
+		err = mlxsw_sp_port_vlans_add(mlxsw_sp_port,
+					      SWITCHDEV_OBJ_PORT_VLAN(obj),
+					      trans);
+		break;
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
+		err = mlxsw_sp_port_fdb_static_add(mlxsw_sp_port,
+						   SWITCHDEV_OBJ_PORT_FDB(obj),
+						   trans);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int mlxsw_sp_port_kill_vids(struct net_device *dev, u16 vid_begin,
+				   u16 vid_end)
+{
+	u16 vid;
+	int err;
+
+	for (vid = vid_begin; vid <= vid_end; vid++) {
+		err = mlxsw_sp_port_kill_vid(dev, 0, vid);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u16 vid_begin, u16 vid_end, bool init)
+{
+	struct net_device *dev = mlxsw_sp_port->dev;
+	u16 vid, vid_e;
+	int err;
+
+	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
+	 * not bridged, then prevent packets ingressing through the
+	 * port with the specified VIDs from being trapped to CPU.
+	 */
+	if (!init && !mlxsw_sp_port->bridged)
+		return mlxsw_sp_port_kill_vids(dev, vid_begin, vid_end);
+
+	for (vid = vid_begin; vid <= vid_end;
+	     vid += MLXSW_REG_SPVM_REC_MAX_COUNT) {
+		vid_e = min((u16) (vid + MLXSW_REG_SPVM_REC_MAX_COUNT - 1),
+			    vid_end);
+		err = mlxsw_sp_port_vlan_set(mlxsw_sp_port, vid, vid_e, false,
+					     false);
+		if (err) {
+			netdev_err(mlxsw_sp_port->dev, "Unable to del VIDs %d-%d\n",
+				   vid, vid_e);
+			return err;
+		}
+	}
+
+	if ((mlxsw_sp_port->pvid >= vid_begin) &&
+	    (mlxsw_sp_port->pvid <= vid_end)) {
+		/* Default VLAN is always 1 */
+		mlxsw_sp_port->pvid = 1;
+		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port,
+					     mlxsw_sp_port->pvid);
+		if (err) {
+			netdev_err(mlxsw_sp_port->dev, "Unable to del PVID %d\n",
+				   vid);
+			return err;
+		}
+	}
+
+	if (init)
+		goto out;
+
+	for (vid = vid_begin; vid <= vid_end; vid++) {
+		err = __mlxsw_sp_port_flood_set(mlxsw_sp_port, vid, false,
+						false);
+		if (err) {
+			netdev_err(dev, "Failed to clear flooding for FID=%d",
+				   vid);
+			return err;
+		}
+
+		/* Remove FID mapping in case of Virtual mode */
+		err = mlxsw_sp_port_fid_unmap(mlxsw_sp_port, vid);
+		if (err) {
+			netdev_err(dev, "Failed to unmap FID=%d", vid);
+			return err;
+		}
+	}
+
+out:
+	/* Changing activity bits only if HW operation succeded */
+	for (vid = vid_begin; vid <= vid_end; vid++)
+		clear_bit(vid, mlxsw_sp_port->active_vlans);
+
+	return 0;
+}
+
+static int mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
+				   const struct switchdev_obj_port_vlan *vlan)
+{
+	return __mlxsw_sp_port_vlans_del(mlxsw_sp_port,
+					 vlan->vid_begin, vlan->vid_end, false);
+}
+
+static int
+mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
+			     const struct switchdev_obj_port_fdb *fdb)
+{
+	return mlxsw_sp_port_fdb_op(mlxsw_sp_port, fdb->addr, fdb->vid,
+				    false, false);
+}
+
+static int mlxsw_sp_port_obj_del(struct net_device *dev,
+				 const struct switchdev_obj *obj)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
+		err = mlxsw_sp_port_vlans_del(mlxsw_sp_port,
+					      SWITCHDEV_OBJ_PORT_VLAN(obj));
+		break;
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
+		err = mlxsw_sp_port_fdb_static_del(mlxsw_sp_port,
+						   SWITCHDEV_OBJ_PORT_FDB(obj));
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
+				  struct switchdev_obj_port_fdb *fdb,
+				  switchdev_obj_dump_cb_t *cb)
+{
+	char *sfd_pl;
+	char mac[ETH_ALEN];
+	u16 vid;
+	u8 local_port;
+	u8 num_rec;
+	int stored_err = 0;
+	int i;
+	int err;
+
+	sfd_pl = kmalloc(MLXSW_REG_SFD_LEN, GFP_KERNEL);
+	if (!sfd_pl)
+		return -ENOMEM;
+
+	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
+	do {
+		mlxsw_reg_sfd_num_rec_set(sfd_pl, MLXSW_REG_SFD_REC_MAX_COUNT);
+		err = mlxsw_reg_query(mlxsw_sp_port->mlxsw_sp->core,
+				      MLXSW_REG(sfd), sfd_pl);
+		if (err)
+			goto out;
+
+		num_rec = mlxsw_reg_sfd_num_rec_get(sfd_pl);
+
+		/* Even in case of error, we have to run the dump to the end
+		 * so the session in firmware is finished.
+		 */
+		if (stored_err)
+			continue;
+
+		for (i = 0; i < num_rec; i++) {
+			switch (mlxsw_reg_sfd_rec_type_get(sfd_pl, i)) {
+			case MLXSW_REG_SFD_REC_TYPE_UNICAST:
+				mlxsw_reg_sfd_uc_unpack(sfd_pl, i, mac, &vid,
+							&local_port);
+				if (local_port == mlxsw_sp_port->local_port) {
+					ether_addr_copy(fdb->addr, mac);
+					fdb->ndm_state = NUD_REACHABLE;
+					fdb->vid = vid;
+					err = cb(&fdb->obj);
+					if (err)
+						stored_err = err;
+				}
+			}
+		}
+	} while (num_rec == MLXSW_REG_SFD_REC_MAX_COUNT);
+
+out:
+	kfree(sfd_pl);
+	return stored_err ? stored_err : err;
+}
+
+static int mlxsw_sp_port_vlan_dump(struct mlxsw_sp_port *mlxsw_sp_port,
+				   struct switchdev_obj_port_vlan *vlan,
+				   switchdev_obj_dump_cb_t *cb)
+{
+	u16 vid;
+	int err = 0;
+
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
+		vlan->flags = 0;
+		if (vid == mlxsw_sp_port->pvid)
+			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+		vlan->vid_begin = vid;
+		vlan->vid_end = vid;
+		err = cb(&vlan->obj);
+		if (err)
+			break;
+	}
+	return err;
+}
+
+static int mlxsw_sp_port_obj_dump(struct net_device *dev,
+				  struct switchdev_obj *obj,
+				  switchdev_obj_dump_cb_t *cb)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
+		err = mlxsw_sp_port_vlan_dump(mlxsw_sp_port,
+					      SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
+		break;
+	case SWITCHDEV_OBJ_ID_PORT_FDB:
+		err = mlxsw_sp_port_fdb_dump(mlxsw_sp_port,
+					     SWITCHDEV_OBJ_PORT_FDB(obj), cb);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+const struct switchdev_ops mlxsw_sp_port_switchdev_ops = {
+	.switchdev_port_attr_get	= mlxsw_sp_port_attr_get,
+	.switchdev_port_attr_set	= mlxsw_sp_port_attr_set,
+	.switchdev_port_obj_add		= mlxsw_sp_port_obj_add,
+	.switchdev_port_obj_del		= mlxsw_sp_port_obj_del,
+	.switchdev_port_obj_dump	= mlxsw_sp_port_obj_dump,
+};
+
+static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
+					    char *sfn_pl, int rec_index,
+					    bool adding)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	char mac[ETH_ALEN];
+	u8 local_port;
+	u16 vid;
+	int err;
+
+	mlxsw_reg_sfn_mac_unpack(sfn_pl, rec_index, mac, &vid, &local_port);
+	mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	if (!mlxsw_sp_port) {
+		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Incorrect local port in FDB notification\n");
+		return;
+	}
+
+	err = mlxsw_sp_port_fdb_op(mlxsw_sp_port, mac, vid,
+				   adding && mlxsw_sp_port->learning, true);
+	if (err) {
+		if (net_ratelimit())
+			netdev_err(mlxsw_sp_port->dev, "Failed to set FDB entry\n");
+		return;
+	}
+
+	if (mlxsw_sp_port->learning && mlxsw_sp_port->learning_sync) {
+		struct switchdev_notifier_fdb_info info;
+		unsigned long notifier_type;
+
+		info.addr = mac;
+		info.vid = vid;
+		notifier_type = adding ? SWITCHDEV_FDB_ADD : SWITCHDEV_FDB_DEL;
+		call_switchdev_notifiers(notifier_type, mlxsw_sp_port->dev,
+					 &info.info);
+	}
+}
+
+static void mlxsw_sp_fdb_notify_rec_process(struct mlxsw_sp *mlxsw_sp,
+					    char *sfn_pl, int rec_index)
+{
+	switch (mlxsw_reg_sfn_rec_type_get(sfn_pl, rec_index)) {
+	case MLXSW_REG_SFN_REC_TYPE_LEARNED_MAC:
+		mlxsw_sp_fdb_notify_mac_process(mlxsw_sp, sfn_pl,
+						rec_index, true);
+		break;
+	case MLXSW_REG_SFN_REC_TYPE_AGED_OUT_MAC:
+		mlxsw_sp_fdb_notify_mac_process(mlxsw_sp, sfn_pl,
+						rec_index, false);
+		break;
+	}
+}
+
+static void mlxsw_sp_fdb_notify_work_schedule(struct mlxsw_sp *mlxsw_sp)
+{
+	schedule_delayed_work(&mlxsw_sp->fdb_notify.dw,
+			      msecs_to_jiffies(mlxsw_sp->fdb_notify.interval));
+}
+
+static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
+{
+	struct mlxsw_sp *mlxsw_sp;
+	char *sfn_pl;
+	u8 num_rec;
+	int i;
+	int err;
+
+	sfn_pl = kmalloc(MLXSW_REG_SFN_LEN, GFP_KERNEL);
+	if (!sfn_pl)
+		return;
+
+	mlxsw_sp = container_of(work, struct mlxsw_sp, fdb_notify.dw.work);
+
+	do {
+		mlxsw_reg_sfn_pack(sfn_pl);
+		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(sfn), sfn_pl);
+		if (err) {
+			dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to get FDB notifications\n");
+			break;
+		}
+		num_rec = mlxsw_reg_sfn_num_rec_get(sfn_pl);
+		for (i = 0; i < num_rec; i++)
+			mlxsw_sp_fdb_notify_rec_process(mlxsw_sp, sfn_pl, i);
+
+	} while (num_rec);
+
+	kfree(sfn_pl);
+	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
+}
+
+static int mlxsw_sp_fdb_init(struct mlxsw_sp *mlxsw_sp)
+{
+	int err;
+
+	err = mlxsw_sp_ageing_set(mlxsw_sp, MLXSW_SP_DEFAULT_AGEING_TIME);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to set default ageing time\n");
+		return err;
+	}
+	INIT_DELAYED_WORK(&mlxsw_sp->fdb_notify.dw, mlxsw_sp_fdb_notify_work);
+	mlxsw_sp->fdb_notify.interval = MLXSW_SP_DEFAULT_LEARNING_INTERVAL;
+	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
+	return 0;
+}
+
+static void mlxsw_sp_fdb_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	cancel_delayed_work_sync(&mlxsw_sp->fdb_notify.dw);
+}
+
+static void mlxsw_sp_fids_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	u16 fid;
+
+	for_each_set_bit(fid, mlxsw_sp->active_fids, VLAN_N_VID)
+		mlxsw_sp_fid_destroy(mlxsw_sp, fid);
+}
+
+int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
+{
+	return mlxsw_sp_fdb_init(mlxsw_sp);
+}
+
+void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	mlxsw_sp_fdb_fini(mlxsw_sp);
+	mlxsw_sp_fids_fini(mlxsw_sp);
+}
+
+int mlxsw_sp_port_vlan_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	struct net_device *dev = mlxsw_sp_port->dev;
+	int err;
+
+	/* Allow only untagged packets to ingress and tag them internally
+	 * with VID 1.
+	 */
+	mlxsw_sp_port->pvid = 1;
+	err = __mlxsw_sp_port_vlans_del(mlxsw_sp_port, 0, VLAN_N_VID, true);
+	if (err) {
+		netdev_err(dev, "Unable to init VLANs\n");
+		return err;
+	}
+
+	/* Add implicit VLAN interface in the device, so that untagged
+	 * packets will be classified to the default vFID.
+	 */
+	err = mlxsw_sp_port_add_vid(dev, 0, 1);
+	if (err)
+		netdev_err(dev, "Failed to configure default vFID\n");
+
+	return err;
+}
+
+void mlxsw_sp_port_switchdev_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	mlxsw_sp_port->dev->switchdev_ops = &mlxsw_sp_port_switchdev_ops;
+}
+
+void mlxsw_sp_port_switchdev_fini(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/txheader.h b/drivers/net/ethernet/mellanox/mlxsw/txheader.h
index 06fc46c..fdf9472 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/txheader.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/txheader.h
@@ -38,6 +38,7 @@
 
 #define MLXSW_TXHDR_LEN 0x10
 #define MLXSW_TXHDR_VERSION_0 0
+#define MLXSW_TXHDR_VERSION_1 1
 
 enum {
 	MLXSW_TXHDR_ETH_CTL,
-- 
1.9.3
