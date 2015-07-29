From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/4] mlxsw: Introduce Mellanox switch driver core
Date: Wed, 29 Jul 2015 23:33:46 +0200
Message-ID: <1438205629-3108-2-git-send-email-jiri@resnulli.us>
References: <1438205629-3108-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com, tgraf@suug.ch,
	ast@plumgrid.com, jhs@mojatatu.com, daniel@iogearbox.net,
	john.fastabend@gmail.com, simon.horman@netronome.com,
	linville@tuxdriver.com, andy@greyhouse.net,
	shm@cumulusnetworks.com, nhorman@tuxdriver.com,
	rami.rosen@intel.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35338 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbbG2Vd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:33:59 -0400
Received: by wibxm9 with SMTP id xm9so219019048wib.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 14:33:57 -0700 (PDT)
In-Reply-To: <1438205629-3108-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add core components of Mellanox switch driver infrastructure.
Core infrastructure is designed so that it can be used by multiple
bus drivers (PCI now, I2C and SGMII are planned to be implemented
in the future). Multiple switch kind drivers can be registered as well.
This core serves as a glue between buses and drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Scott Feldman <sfeldma@gmail.com>
---
v1->v2:
- removed trap_id param from rx_listener callback and
  removed MLXSW_TRAP_ID_DONT_CARE - suggested by Rami Rosen
- added MLXSW_PORT_DONT_CARE definition and use it
  instead of MLXSW_PORT_MAX_PORTS as it is cleaner
---
 MAINTAINERS                                  |    9 +
 drivers/net/ethernet/mellanox/Kconfig        |    1 +
 drivers/net/ethernet/mellanox/Makefile       |    1 +
 drivers/net/ethernet/mellanox/mlxsw/Kconfig  |   11 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile |    2 +
 drivers/net/ethernet/mellanox/mlxsw/cmd.h    | 1090 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.c   |  550 +++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h   |  179 +++++
 drivers/net/ethernet/mellanox/mlxsw/item.h   |  405 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/port.h   |   52 ++
 drivers/net/ethernet/mellanox/mlxsw/trap.h   |   66 ++
 11 files changed, 2366 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/cmd.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/item.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/port.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/trap.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 0c78766..6712fd5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6645,6 +6645,15 @@ W:	http://www.mellanox.com
 Q:	http://patchwork.ozlabs.org/project/netdev/list/
 F:	drivers/net/ethernet/mellanox/mlx4/en_*
 
+MELLANOX ETHERNET SWITCH DRIVERS
+M:	Jiri Pirko <jiri@mellanox.com>
+M:	Ido Schimmel <idosch@mellanox.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+W:	http://www.mellanox.com
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
+F:	drivers/net/ethernet/mellanox/mlxsw/
+
 MEMORY MANAGEMENT
 L:	linux-mm@kvack.org
 W:	http://www.linux-mm.org
diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index 52a6665..d547010 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -18,5 +18,6 @@ if NET_VENDOR_MELLANOX
 
 source "drivers/net/ethernet/mellanox/mlx4/Kconfig"
 source "drivers/net/ethernet/mellanox/mlx5/core/Kconfig"
+source "drivers/net/ethernet/mellanox/mlxsw/Kconfig"
 
 endif # NET_VENDOR_MELLANOX
diff --git a/drivers/net/ethernet/mellanox/Makefile b/drivers/net/ethernet/mellanox/Makefile
index 38fe32ef..2e2a5ec 100644
--- a/drivers/net/ethernet/mellanox/Makefile
+++ b/drivers/net/ethernet/mellanox/Makefile
@@ -4,3 +4,4 @@
 
 obj-$(CONFIG_MLX4_CORE) += mlx4/
 obj-$(CONFIG_MLX5_CORE) += mlx5/core/
+obj-$(CONFIG_MLXSW_CORE) += mlxsw/
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
new file mode 100644
index 0000000..46268f2
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -0,0 +1,11 @@
+#
+# Mellanox switch drivers configuration
+#
+
+config MLXSW_CORE
+	tristate "Mellanox Technologies Switch ASICs support"
+	---help---
+	  This driver supports Mellanox Technologies Switch ASICs family.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called mlxsw_core.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
new file mode 100644
index 0000000..271de28
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_MLXSW_CORE)	+= mlxsw_core.o
+mlxsw_core-objs			:= core.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
new file mode 100644
index 0000000..770db17
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -0,0 +1,1090 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/cmd.h
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
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
+#ifndef _MLXSW_CMD_H
+#define _MLXSW_CMD_H
+
+#include "item.h"
+
+#define MLXSW_CMD_MBOX_SIZE	4096
+
+static inline char *mlxsw_cmd_mbox_alloc(void)
+{
+	return kzalloc(MLXSW_CMD_MBOX_SIZE, GFP_KERNEL);
+}
+
+static inline void mlxsw_cmd_mbox_free(char *mbox)
+{
+	kfree(mbox);
+}
+
+static inline void mlxsw_cmd_mbox_zero(char *mbox)
+{
+	memset(mbox, 0, MLXSW_CMD_MBOX_SIZE);
+}
+
+struct mlxsw_core;
+
+int mlxsw_cmd_exec(struct mlxsw_core *mlxsw_core, u16 opcode, u8 opcode_mod,
+		   u32 in_mod, bool out_mbox_direct,
+		   char *in_mbox, size_t in_mbox_size,
+		   char *out_mbox, size_t out_mbox_size);
+
+static inline int mlxsw_cmd_exec_in(struct mlxsw_core *mlxsw_core, u16 opcode,
+				    u8 opcode_mod, u32 in_mod, char *in_mbox,
+				    size_t in_mbox_size)
+{
+	return mlxsw_cmd_exec(mlxsw_core, opcode, opcode_mod, in_mod, false,
+			      in_mbox, in_mbox_size, NULL, 0);
+}
+
+static inline int mlxsw_cmd_exec_out(struct mlxsw_core *mlxsw_core, u16 opcode,
+				     u8 opcode_mod, u32 in_mod,
+				     bool out_mbox_direct,
+				     char *out_mbox, size_t out_mbox_size)
+{
+	return mlxsw_cmd_exec(mlxsw_core, opcode, opcode_mod, in_mod,
+			      out_mbox_direct, NULL, 0,
+			      out_mbox, out_mbox_size);
+}
+
+static inline int mlxsw_cmd_exec_none(struct mlxsw_core *mlxsw_core, u16 opcode,
+				      u8 opcode_mod, u32 in_mod)
+{
+	return mlxsw_cmd_exec(mlxsw_core, opcode, opcode_mod, in_mod, false,
+			      NULL, 0, NULL, 0);
+}
+
+enum mlxsw_cmd_opcode {
+	MLXSW_CMD_OPCODE_QUERY_FW		= 0x004,
+	MLXSW_CMD_OPCODE_QUERY_BOARDINFO	= 0x006,
+	MLXSW_CMD_OPCODE_QUERY_AQ_CAP		= 0x003,
+	MLXSW_CMD_OPCODE_MAP_FA			= 0xFFF,
+	MLXSW_CMD_OPCODE_UNMAP_FA		= 0xFFE,
+	MLXSW_CMD_OPCODE_CONFIG_PROFILE		= 0x100,
+	MLXSW_CMD_OPCODE_ACCESS_REG		= 0x040,
+	MLXSW_CMD_OPCODE_SW2HW_DQ		= 0x201,
+	MLXSW_CMD_OPCODE_HW2SW_DQ		= 0x202,
+	MLXSW_CMD_OPCODE_2ERR_DQ		= 0x01E,
+	MLXSW_CMD_OPCODE_QUERY_DQ		= 0x022,
+	MLXSW_CMD_OPCODE_SW2HW_CQ		= 0x016,
+	MLXSW_CMD_OPCODE_HW2SW_CQ		= 0x017,
+	MLXSW_CMD_OPCODE_QUERY_CQ		= 0x018,
+	MLXSW_CMD_OPCODE_SW2HW_EQ		= 0x013,
+	MLXSW_CMD_OPCODE_HW2SW_EQ		= 0x014,
+	MLXSW_CMD_OPCODE_QUERY_EQ		= 0x015,
+};
+
+static inline const char *mlxsw_cmd_opcode_str(u16 opcode)
+{
+	switch (opcode) {
+	case MLXSW_CMD_OPCODE_QUERY_FW:
+		return "QUERY_FW";
+	case MLXSW_CMD_OPCODE_QUERY_BOARDINFO:
+		return "QUERY_BOARDINFO";
+	case MLXSW_CMD_OPCODE_QUERY_AQ_CAP:
+		return "QUERY_AQ_CAP";
+	case MLXSW_CMD_OPCODE_MAP_FA:
+		return "MAP_FA";
+	case MLXSW_CMD_OPCODE_UNMAP_FA:
+		return "UNMAP_FA";
+	case MLXSW_CMD_OPCODE_CONFIG_PROFILE:
+		return "CONFIG_PROFILE";
+	case MLXSW_CMD_OPCODE_ACCESS_REG:
+		return "ACCESS_REG";
+	case MLXSW_CMD_OPCODE_SW2HW_DQ:
+		return "SW2HW_DQ";
+	case MLXSW_CMD_OPCODE_HW2SW_DQ:
+		return "HW2SW_DQ";
+	case MLXSW_CMD_OPCODE_2ERR_DQ:
+		return "2ERR_DQ";
+	case MLXSW_CMD_OPCODE_QUERY_DQ:
+		return "QUERY_DQ";
+	case MLXSW_CMD_OPCODE_SW2HW_CQ:
+		return "SW2HW_CQ";
+	case MLXSW_CMD_OPCODE_HW2SW_CQ:
+		return "HW2SW_CQ";
+	case MLXSW_CMD_OPCODE_QUERY_CQ:
+		return "QUERY_CQ";
+	case MLXSW_CMD_OPCODE_SW2HW_EQ:
+		return "SW2HW_EQ";
+	case MLXSW_CMD_OPCODE_HW2SW_EQ:
+		return "HW2SW_EQ";
+	case MLXSW_CMD_OPCODE_QUERY_EQ:
+		return "QUERY_EQ";
+	default:
+		return "*UNKNOWN*";
+	}
+}
+
+enum mlxsw_cmd_status {
+	/* Command execution succeeded. */
+	MLXSW_CMD_STATUS_OK		= 0x00,
+	/* Internal error (e.g. bus error) occurred while processing command. */
+	MLXSW_CMD_STATUS_INTERNAL_ERR	= 0x01,
+	/* Operation/command not supported or opcode modifier not supported. */
+	MLXSW_CMD_STATUS_BAD_OP		= 0x02,
+	/* Parameter not supported, parameter out of range. */
+	MLXSW_CMD_STATUS_BAD_PARAM	= 0x03,
+	/* System was not enabled or bad system state. */
+	MLXSW_CMD_STATUS_BAD_SYS_STATE	= 0x04,
+	/* Attempt to access reserved or unallocated resource, or resource in
+	 * inappropriate ownership.
+	 */
+	MLXSW_CMD_STATUS_BAD_RESOURCE	= 0x05,
+	/* Requested resource is currently executing a command. */
+	MLXSW_CMD_STATUS_RESOURCE_BUSY	= 0x06,
+	/* Required capability exceeds device limits. */
+	MLXSW_CMD_STATUS_EXCEED_LIM	= 0x08,
+	/* Resource is not in the appropriate state or ownership. */
+	MLXSW_CMD_STATUS_BAD_RES_STATE	= 0x09,
+	/* Index out of range (might be beyond table size or attempt to
+	 * access a reserved resource).
+	 */
+	MLXSW_CMD_STATUS_BAD_INDEX	= 0x0A,
+	/* NVMEM checksum/CRC failed. */
+	MLXSW_CMD_STATUS_BAD_NVMEM	= 0x0B,
+	/* Bad management packet (silently discarded). */
+	MLXSW_CMD_STATUS_BAD_PKT	= 0x30,
+};
+
+static inline const char *mlxsw_cmd_status_str(u8 status)
+{
+	switch (status) {
+	case MLXSW_CMD_STATUS_OK:
+		return "OK";
+	case MLXSW_CMD_STATUS_INTERNAL_ERR:
+		return "INTERNAL_ERR";
+	case MLXSW_CMD_STATUS_BAD_OP:
+		return "BAD_OP";
+	case MLXSW_CMD_STATUS_BAD_PARAM:
+		return "BAD_PARAM";
+	case MLXSW_CMD_STATUS_BAD_SYS_STATE:
+		return "BAD_SYS_STATE";
+	case MLXSW_CMD_STATUS_BAD_RESOURCE:
+		return "BAD_RESOURCE";
+	case MLXSW_CMD_STATUS_RESOURCE_BUSY:
+		return "RESOURCE_BUSY";
+	case MLXSW_CMD_STATUS_EXCEED_LIM:
+		return "EXCEED_LIM";
+	case MLXSW_CMD_STATUS_BAD_RES_STATE:
+		return "BAD_RES_STATE";
+	case MLXSW_CMD_STATUS_BAD_INDEX:
+		return "BAD_INDEX";
+	case MLXSW_CMD_STATUS_BAD_NVMEM:
+		return "BAD_NVMEM";
+	case MLXSW_CMD_STATUS_BAD_PKT:
+		return "BAD_PKT";
+	default:
+		return "*UNKNOWN*";
+	}
+}
+
+/* QUERY_FW - Query Firmware
+ * -------------------------
+ * OpMod == 0, INMmod == 0
+ * -----------------------
+ * The QUERY_FW command retrieves information related to firmware, command
+ * interface version and the amount of resources that should be allocated to
+ * the firmware.
+ */
+
+static inline int mlxsw_cmd_query_fw(struct mlxsw_core *mlxsw_core,
+				     char *out_mbox)
+{
+	return mlxsw_cmd_exec_out(mlxsw_core, MLXSW_CMD_OPCODE_QUERY_FW,
+				  0, 0, false, out_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_query_fw_fw_pages
+ * Amount of physical memory to be allocatedfor firmware usage in 4KB pages.
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_pages, 0x00, 16, 16);
+
+/* cmd_mbox_query_fw_fw_rev_major
+ * Firmware Revision - Major
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_rev_major, 0x00, 0, 16);
+
+/* cmd_mbox_query_fw_fw_rev_subminor
+ * Firmware Sub-minor version (Patch level)
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_rev_subminor, 0x04, 16, 16);
+
+/* cmd_mbox_query_fw_fw_rev_minor
+ * Firmware Revision - Minor
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_rev_minor, 0x04, 0, 16);
+
+/* cmd_mbox_query_fw_core_clk
+ * Internal Clock Frequency (in MHz)
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, core_clk, 0x08, 16, 16);
+
+/* cmd_mbox_query_fw_cmd_interface_rev
+ * Command Interface Interpreter Revision ID. This number is bumped up
+ * every time a non-backward-compatible change is done for the command
+ * interface. The current cmd_interface_rev is 1.
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, cmd_interface_rev, 0x08, 0, 16);
+
+/* cmd_mbox_query_fw_dt
+ * If set, Debug Trace is supported
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, dt, 0x0C, 31, 1);
+
+/* cmd_mbox_query_fw_api_version
+ * Indicates the version of the API, to enable software querying
+ * for compatibility. The current api_version is 1.
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, api_version, 0x0C, 0, 16);
+
+/* cmd_mbox_query_fw_fw_hour
+ * Firmware timestamp - hour
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_hour, 0x10, 24, 8);
+
+/* cmd_mbox_query_fw_fw_minutes
+ * Firmware timestamp - minutes
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_minutes, 0x10, 16, 8);
+
+/* cmd_mbox_query_fw_fw_seconds
+ * Firmware timestamp - seconds
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_seconds, 0x10, 8, 8);
+
+/* cmd_mbox_query_fw_fw_year
+ * Firmware timestamp - year
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_year, 0x14, 16, 16);
+
+/* cmd_mbox_query_fw_fw_month
+ * Firmware timestamp - month
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_month, 0x14, 8, 8);
+
+/* cmd_mbox_query_fw_fw_day
+ * Firmware timestamp - day
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, fw_day, 0x14, 0, 8);
+
+/* cmd_mbox_query_fw_clr_int_base_offset
+ * Clear Interrupt register's offset from clr_int_bar register
+ * in PCI address space.
+ */
+MLXSW_ITEM64(cmd_mbox, query_fw, clr_int_base_offset, 0x20, 0, 64);
+
+/* cmd_mbox_query_fw_clr_int_bar
+ * PCI base address register (BAR) where clr_int register is located.
+ * 00 - BAR 0-1 (64 bit BAR)
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, clr_int_bar, 0x28, 30, 2);
+
+/* cmd_mbox_query_fw_error_buf_offset
+ * Read Only buffer for internal error reports of offset
+ * from error_buf_bar register in PCI address space).
+ */
+MLXSW_ITEM64(cmd_mbox, query_fw, error_buf_offset, 0x30, 0, 64);
+
+/* cmd_mbox_query_fw_error_buf_size
+ * Internal error buffer size in DWORDs
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, error_buf_size, 0x38, 0, 32);
+
+/* cmd_mbox_query_fw_error_int_bar
+ * PCI base address register (BAR) where error buffer
+ * register is located.
+ * 00 - BAR 0-1 (64 bit BAR)
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, error_int_bar, 0x3C, 30, 2);
+
+/* cmd_mbox_query_fw_doorbell_page_offset
+ * Offset of the doorbell page
+ */
+MLXSW_ITEM64(cmd_mbox, query_fw, doorbell_page_offset, 0x40, 0, 64);
+
+/* cmd_mbox_query_fw_doorbell_page_bar
+ * PCI base address register (BAR) of the doorbell page
+ * 00 - BAR 0-1 (64 bit BAR)
+ */
+MLXSW_ITEM32(cmd_mbox, query_fw, doorbell_page_bar, 0x48, 30, 2);
+
+/* QUERY_BOARDINFO - Query Board Information
+ * -----------------------------------------
+ * OpMod == 0 (N/A), INMmod == 0 (N/A)
+ * -----------------------------------
+ * The QUERY_BOARDINFO command retrieves adapter specific parameters.
+ */
+
+static inline int mlxsw_cmd_boardinfo(struct mlxsw_core *mlxsw_core,
+				      char *out_mbox)
+{
+	return mlxsw_cmd_exec_out(mlxsw_core, MLXSW_CMD_OPCODE_QUERY_BOARDINFO,
+				  0, 0, false, out_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_boardinfo_intapin
+ * When PCIe interrupt messages are being used, this value is used for clearing
+ * an interrupt. When using MSI-X, this register is not used.
+ */
+MLXSW_ITEM32(cmd_mbox, boardinfo, intapin, 0x10, 24, 8);
+
+/* cmd_mbox_boardinfo_vsd_vendor_id
+ * PCISIG Vendor ID (www.pcisig.com/membership/vid_search) of the vendor
+ * specifying/formatting the VSD. The vsd_vendor_id identifies the management
+ * domain of the VSD/PSID data. Different vendors may choose different VSD/PSID
+ * format and encoding as long as they use their assigned vsd_vendor_id.
+ */
+MLXSW_ITEM32(cmd_mbox, boardinfo, vsd_vendor_id, 0x1C, 0, 16);
+
+/* cmd_mbox_boardinfo_vsd
+ * Vendor Specific Data. The VSD string that is burnt to the Flash
+ * with the firmware.
+ */
+#define MLXSW_CMD_BOARDINFO_VSD_LEN 208
+MLXSW_ITEM_BUF(cmd_mbox, boardinfo, vsd, 0x20, MLXSW_CMD_BOARDINFO_VSD_LEN);
+
+/* cmd_mbox_boardinfo_psid
+ * The PSID field is a 16-ascii (byte) character string which acts as
+ * the board ID. The PSID format is used in conjunction with
+ * Mellanox vsd_vendor_id (15B3h).
+ */
+#define MLXSW_CMD_BOARDINFO_PSID_LEN 16
+MLXSW_ITEM_BUF(cmd_mbox, boardinfo, psid, 0xF0, MLXSW_CMD_BOARDINFO_PSID_LEN);
+
+/* QUERY_AQ_CAP - Query Asynchronous Queues Capabilities
+ * -----------------------------------------------------
+ * OpMod == 0 (N/A), INMmod == 0 (N/A)
+ * -----------------------------------
+ * The QUERY_AQ_CAP command returns the device asynchronous queues
+ * capabilities supported.
+ */
+
+static inline int mlxsw_cmd_query_aq_cap(struct mlxsw_core *mlxsw_core,
+					 char *out_mbox)
+{
+	return mlxsw_cmd_exec_out(mlxsw_core, MLXSW_CMD_OPCODE_QUERY_AQ_CAP,
+				  0, 0, false, out_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_query_aq_cap_log_max_sdq_sz
+ * Log (base 2) of max WQEs allowed on SDQ.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, log_max_sdq_sz, 0x00, 24, 8);
+
+/* cmd_mbox_query_aq_cap_max_num_sdqs
+ * Maximum number of SDQs.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, max_num_sdqs, 0x00, 0, 8);
+
+/* cmd_mbox_query_aq_cap_log_max_rdq_sz
+ * Log (base 2) of max WQEs allowed on RDQ.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, log_max_rdq_sz, 0x04, 24, 8);
+
+/* cmd_mbox_query_aq_cap_max_num_rdqs
+ * Maximum number of RDQs.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, max_num_rdqs, 0x04, 0, 8);
+
+/* cmd_mbox_query_aq_cap_log_max_cq_sz
+ * Log (base 2) of max CQEs allowed on CQ.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, log_max_cq_sz, 0x08, 24, 8);
+
+/* cmd_mbox_query_aq_cap_max_num_cqs
+ * Maximum number of CQs.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, max_num_cqs, 0x08, 0, 8);
+
+/* cmd_mbox_query_aq_cap_log_max_eq_sz
+ * Log (base 2) of max EQEs allowed on EQ.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, log_max_eq_sz, 0x0C, 24, 8);
+
+/* cmd_mbox_query_aq_cap_max_num_eqs
+ * Maximum number of EQs.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, max_num_eqs, 0x0C, 0, 8);
+
+/* cmd_mbox_query_aq_cap_max_sg_sq
+ * The maximum S/G list elements in an DSQ. DSQ must not contain
+ * more S/G entries than indicated here.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, max_sg_sq, 0x10, 8, 8);
+
+/* cmd_mbox_query_aq_cap_
+ * The maximum S/G list elements in an DRQ. DRQ must not contain
+ * more S/G entries than indicated here.
+ */
+MLXSW_ITEM32(cmd_mbox, query_aq_cap, max_sg_rq, 0x10, 0, 8);
+
+/* MAP_FA - Map Firmware Area
+ * --------------------------
+ * OpMod == 0 (N/A), INMmod == Number of VPM entries
+ * -------------------------------------------------
+ * The MAP_FA command passes physical pages to the switch. These pages
+ * are used to store the device firmware. MAP_FA can be executed multiple
+ * times until all the firmware area is mapped (the size that should be
+ * mapped is retrieved through the QUERY_FW command). All required pages
+ * must be mapped to finish the initialization phase. Physical memory
+ * passed in this command must be pinned.
+ */
+
+static inline int mlxsw_cmd_map_fa(struct mlxsw_core *mlxsw_core,
+				   char *in_mbox, u32 vpm_entries_count)
+{
+	return mlxsw_cmd_exec_in(mlxsw_core, MLXSW_CMD_OPCODE_MAP_FA,
+				 0, vpm_entries_count,
+				 in_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_map_fa_pa
+ * Physical Address.
+ */
+MLXSW_ITEM64_INDEXED(cmd_mbox, map_fa, pa, 0x00, 12, 52, 0x08, 0x00, true);
+
+/* cmd_mbox_map_fa_log2size
+ * Log (base 2) of the size in 4KB pages of the physical and contiguous memory
+ * that starts at PA_L/H.
+ */
+MLXSW_ITEM32_INDEXED(cmd_mbox, map_fa, log2size, 0x00, 0, 5, 0x08, 0x04, false);
+
+/* UNMAP_FA - Unmap Firmware Area
+ * ------------------------------
+ * OpMod == 0 (N/A), INMmod == 0 (N/A)
+ * -----------------------------------
+ * The UNMAP_FA command unload the firmware and unmaps all the
+ * firmware area. After this command is completed the device will not access
+ * the pages that were mapped to the firmware area. After executing UNMAP_FA
+ * command, software reset must be done prior to execution of MAP_FW command.
+ */
+
+static inline int mlxsw_cmd_unmap_fa(struct mlxsw_core *mlxsw_core)
+{
+	return mlxsw_cmd_exec_none(mlxsw_core, MLXSW_CMD_OPCODE_UNMAP_FA, 0, 0);
+}
+
+/* CONFIG_PROFILE (Set) - Configure Switch Profile
+ * ------------------------------
+ * OpMod == 1 (Set), INMmod == 0 (N/A)
+ * -----------------------------------
+ * The CONFIG_PROFILE command sets the switch profile. The command can be
+ * executed on the device only once at startup in order to allocate and
+ * configure all switch resources and prepare it for operational mode.
+ * It is not possible to change the device profile after the chip is
+ * in operational mode.
+ * Failure of the CONFIG_PROFILE command leaves the hardware in an indeterminate
+ * state therefore it is required to perform software reset to the device
+ * following an unsuccessful completion of the command. It is required
+ * to perform software reset to the device to change an existing profile.
+ */
+
+static inline int mlxsw_cmd_config_profile_set(struct mlxsw_core *mlxsw_core,
+					       char *in_mbox)
+{
+	return mlxsw_cmd_exec_in(mlxsw_core, MLXSW_CMD_OPCODE_CONFIG_PROFILE,
+				 1, 0, in_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_config_profile_set_max_vepa_channels
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_vepa_channels, 0x0C, 0, 1);
+
+/* cmd_mbox_config_profile_set_max_lag
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_lag, 0x0C, 1, 1);
+
+/* cmd_mbox_config_profile_set_max_port_per_lag
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_port_per_lag, 0x0C, 2, 1);
+
+/* cmd_mbox_config_profile_set_max_mid
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_mid, 0x0C, 3, 1);
+
+/* cmd_mbox_config_profile_set_max_pgt
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_pgt, 0x0C, 4, 1);
+
+/* cmd_mbox_config_profile_set_max_system_port
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_system_port, 0x0C, 5, 1);
+
+/* cmd_mbox_config_profile_set_max_vlan_groups
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_vlan_groups, 0x0C, 6, 1);
+
+/* cmd_mbox_config_profile_set_max_regions
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_regions, 0x0C, 7, 1);
+
+/* cmd_mbox_config_profile_set_fid_based
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_flood_mode, 0x0C, 8, 1);
+
+/* cmd_mbox_config_profile_set_max_flood_tables
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_flood_tables, 0x0C, 9, 1);
+
+/* cmd_mbox_config_profile_set_max_ib_mc
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_ib_mc, 0x0C, 12, 1);
+
+/* cmd_mbox_config_profile_set_max_pkey
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_max_pkey, 0x0C, 13, 1);
+
+/* cmd_mbox_config_profile_set_adaptive_routing_group_cap
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile,
+	     set_adaptive_routing_group_cap, 0x0C, 14, 1);
+
+/* cmd_mbox_config_profile_set_ar_sec
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_ar_sec, 0x0C, 15, 1);
+
+/* cmd_mbox_config_profile_max_vepa_channels
+ * Maximum number of VEPA channels per port (0 through 16)
+ * 0 - multi-channel VEPA is disabled
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_vepa_channels, 0x10, 0, 8);
+
+/* cmd_mbox_config_profile_max_lag
+ * Maximum number of LAG IDs requested.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_lag, 0x14, 0, 16);
+
+/* cmd_mbox_config_profile_max_port_per_lag
+ * Maximum number of ports per LAG requested.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_port_per_lag, 0x18, 0, 16);
+
+/* cmd_mbox_config_profile_max_mid
+ * Maximum Multicast IDs.
+ * Multicast IDs are allocated from 0 to max_mid-1
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_mid, 0x1C, 0, 16);
+
+/* cmd_mbox_config_profile_max_pgt
+ * Maximum records in the Port Group Table per Switch Partition.
+ * Port Group Table indexes are from 0 to max_pgt-1
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_pgt, 0x20, 0, 16);
+
+/* cmd_mbox_config_profile_max_system_port
+ * The maximum number of system ports that can be allocated.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_system_port, 0x24, 0, 16);
+
+/* cmd_mbox_config_profile_max_vlan_groups
+ * Maximum number VLAN Groups for VLAN binding.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_vlan_groups, 0x28, 0, 12);
+
+/* cmd_mbox_config_profile_max_regions
+ * Maximum number of TCAM Regions.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_regions, 0x2C, 0, 16);
+
+/* cmd_mbox_config_profile_max_flood_tables
+ * Maximum number of Flooding Tables. Flooding Tables are associated to
+ * the different packet types for the different switch partitions.
+ * Note that the table size depends on the fid_based mode.
+ * In SwitchX silicon, tables are split equally between the switch
+ * partitions. e.g. for 2 swids and 8 tables, the first 4 are associated
+ * with swid-1 and the last 4 are associated with swid-2.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_flood_tables, 0x30, 16, 4);
+
+/* cmd_mbox_config_profile_max_vid_flood_tables
+ * Maximum number of per-vid flooding tables. Flooding tables are associated
+ * to the different packet types for the different switch partitions.
+ * Table size is 4K entries covering all VID space.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_vid_flood_tables, 0x30, 8, 4);
+
+/* cmd_mbox_config_profile_fid_based
+ * FID Based Flood Mode
+ * 00 Do not use FID to offset the index into the Port Group Table/Multicast ID
+ * 01 Use FID to offset the index to the Port Group Table (pgi)
+ * 10 Use FID to offset the index to the Port Group Table (pgi) and
+ * the Multicast ID
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, flood_mode, 0x30, 0, 2);
+
+/* cmd_mbox_config_profile_max_ib_mc
+ * Maximum number of multicast FDB records for InfiniBand
+ * FDB (in 512 chunks) per InfiniBand switch partition.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_ib_mc, 0x40, 0, 15);
+
+/* cmd_mbox_config_profile_max_pkey
+ * Maximum per port PKEY table size (for PKEY enforcement)
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_pkey, 0x44, 0, 15);
+
+/* cmd_mbox_config_profile_ar_sec
+ * Primary/secondary capability
+ * Describes the number of adaptive routing sub-groups
+ * 0 - disable primary/secondary (single group)
+ * 1 - enable primary/secondary (2 sub-groups)
+ * 2 - 3 sub-groups: Not supported in SwitchX, SwitchX-2
+ * 3 - 4 sub-groups: Not supported in SwitchX, SwitchX-2
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, ar_sec, 0x4C, 24, 2);
+
+/* cmd_mbox_config_profile_adaptive_routing_group_cap
+ * Adaptive Routing Group Capability. Indicates the number of AR groups
+ * supported. Note that when Primary/secondary is enabled, each
+ * primary/secondary couple consumes 2 adaptive routing entries.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, adaptive_routing_group_cap, 0x4C, 0, 16);
+
+/* cmd_mbox_config_profile_arn
+ * Adaptive Routing Notification Enable
+ * Not supported in SwitchX, SwitchX-2
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, arn, 0x50, 31, 1);
+
+/* cmd_mbox_config_profile_swid_config_mask
+ * Modify Switch Partition Configuration mask. When set, the configu-
+ * ration value for the Switch Partition are taken from the mailbox.
+ * When clear, the current configuration values are used.
+ * Bit 0 - set type
+ * Bit 1 - properties
+ * Other - reserved
+ */
+MLXSW_ITEM32_INDEXED(cmd_mbox, config_profile, swid_config_mask,
+		     0x60, 24, 8, 0x08, 0x00, false);
+
+/* cmd_mbox_config_profile_swid_config_type
+ * Switch Partition type.
+ * 0000 - disabled (Switch Partition does not exist)
+ * 0001 - InfiniBand
+ * 0010 - Ethernet
+ * 1000 - router port (SwitchX-2 only)
+ * Other - reserved
+ */
+MLXSW_ITEM32_INDEXED(cmd_mbox, config_profile, swid_config_type,
+		     0x60, 20, 4, 0x08, 0x00, false);
+
+/* cmd_mbox_config_profile_swid_config_properties
+ * Switch Partition properties.
+ */
+MLXSW_ITEM32_INDEXED(cmd_mbox, config_profile, swid_config_properties,
+		     0x60, 0, 8, 0x08, 0x00, false);
+
+/* ACCESS_REG - Access EMAD Supported Register
+ * ----------------------------------
+ * OpMod == 0 (N/A), INMmod == 0 (N/A)
+ * -------------------------------------
+ * The ACCESS_REG command supports accessing device registers. This access
+ * is mainly used for bootstrapping.
+ */
+
+static inline int mlxsw_cmd_access_reg(struct mlxsw_core *mlxsw_core,
+				       char *in_mbox, char *out_mbox)
+{
+	return mlxsw_cmd_exec(mlxsw_core, MLXSW_CMD_OPCODE_ACCESS_REG,
+			      0, 0, false, in_mbox, MLXSW_CMD_MBOX_SIZE,
+			      out_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* SW2HW_DQ - Software to Hardware DQ
+ * ----------------------------------
+ * OpMod == 0 (send DQ) / OpMod == 1 (receive DQ)
+ * INMmod == DQ number
+ * ----------------------------------------------
+ * The SW2HW_DQ command transitions a descriptor queue from software to
+ * hardware ownership. The command enables posting WQEs and ringing DoorBells
+ * on the descriptor queue.
+ */
+
+static inline int __mlxsw_cmd_sw2hw_dq(struct mlxsw_core *mlxsw_core,
+				       char *in_mbox, u32 dq_number,
+				       u8 opcode_mod)
+{
+	return mlxsw_cmd_exec_in(mlxsw_core, MLXSW_CMD_OPCODE_SW2HW_DQ,
+				 opcode_mod, dq_number,
+				 in_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+enum {
+	MLXSW_CMD_OPCODE_MOD_SDQ = 0,
+	MLXSW_CMD_OPCODE_MOD_RDQ = 1,
+};
+
+static inline int mlxsw_cmd_sw2hw_sdq(struct mlxsw_core *mlxsw_core,
+				      char *in_mbox, u32 dq_number)
+{
+	return __mlxsw_cmd_sw2hw_dq(mlxsw_core, in_mbox, dq_number,
+				    MLXSW_CMD_OPCODE_MOD_SDQ);
+}
+
+static inline int mlxsw_cmd_sw2hw_rdq(struct mlxsw_core *mlxsw_core,
+				      char *in_mbox, u32 dq_number)
+{
+	return __mlxsw_cmd_sw2hw_dq(mlxsw_core, in_mbox, dq_number,
+				    MLXSW_CMD_OPCODE_MOD_RDQ);
+}
+
+/* cmd_mbox_sw2hw_dq_cq
+ * Number of the CQ that this Descriptor Queue reports completions to.
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_dq, cq, 0x00, 24, 8);
+
+/* cmd_mbox_sw2hw_dq_sdq_tclass
+ * SDQ: CPU Egress TClass
+ * RDQ: Reserved
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_dq, sdq_tclass, 0x00, 16, 6);
+
+/* cmd_mbox_sw2hw_dq_log2_dq_sz
+ * Log (base 2) of the Descriptor Queue size in 4KB pages.
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_dq, log2_dq_sz, 0x00, 0, 6);
+
+/* cmd_mbox_sw2hw_dq_pa
+ * Physical Address.
+ */
+MLXSW_ITEM64_INDEXED(cmd_mbox, sw2hw_dq, pa, 0x10, 12, 52, 0x08, 0x00, true);
+
+/* HW2SW_DQ - Hardware to Software DQ
+ * ----------------------------------
+ * OpMod == 0 (send DQ) / OpMod == 1 (receive DQ)
+ * INMmod == DQ number
+ * ----------------------------------------------
+ * The HW2SW_DQ command transitions a descriptor queue from hardware to
+ * software ownership. Incoming packets on the DQ are silently discarded,
+ * SW should not post descriptors on nonoperational DQs.
+ */
+
+static inline int __mlxsw_cmd_hw2sw_dq(struct mlxsw_core *mlxsw_core,
+				       u32 dq_number, u8 opcode_mod)
+{
+	return mlxsw_cmd_exec_none(mlxsw_core, MLXSW_CMD_OPCODE_HW2SW_DQ,
+				   opcode_mod, dq_number);
+}
+
+static inline int mlxsw_cmd_hw2sw_sdq(struct mlxsw_core *mlxsw_core,
+				      u32 dq_number)
+{
+	return __mlxsw_cmd_hw2sw_dq(mlxsw_core, dq_number,
+				    MLXSW_CMD_OPCODE_MOD_SDQ);
+}
+
+static inline int mlxsw_cmd_hw2sw_rdq(struct mlxsw_core *mlxsw_core,
+				      u32 dq_number)
+{
+	return __mlxsw_cmd_hw2sw_dq(mlxsw_core, dq_number,
+				    MLXSW_CMD_OPCODE_MOD_RDQ);
+}
+
+/* 2ERR_DQ - To Error DQ
+ * ---------------------
+ * OpMod == 0 (send DQ) / OpMod == 1 (receive DQ)
+ * INMmod == DQ number
+ * ----------------------------------------------
+ * The 2ERR_DQ command transitions the DQ into the error state from the state
+ * in which it has been. While the command is executed, some in-process
+ * descriptors may complete. Once the DQ transitions into the error state,
+ * if there are posted descriptors on the RDQ/SDQ, the hardware writes
+ * a completion with error (flushed) for all descriptors posted in the RDQ/SDQ.
+ * When the command is completed successfully, the DQ is already in
+ * the error state.
+ */
+
+static inline int __mlxsw_cmd_2err_dq(struct mlxsw_core *mlxsw_core,
+				      u32 dq_number, u8 opcode_mod)
+{
+	return mlxsw_cmd_exec_none(mlxsw_core, MLXSW_CMD_OPCODE_2ERR_DQ,
+				   opcode_mod, dq_number);
+}
+
+static inline int mlxsw_cmd_2err_sdq(struct mlxsw_core *mlxsw_core,
+				     u32 dq_number)
+{
+	return __mlxsw_cmd_2err_dq(mlxsw_core, dq_number,
+				   MLXSW_CMD_OPCODE_MOD_SDQ);
+}
+
+static inline int mlxsw_cmd_2err_rdq(struct mlxsw_core *mlxsw_core,
+				     u32 dq_number)
+{
+	return __mlxsw_cmd_2err_dq(mlxsw_core, dq_number,
+				   MLXSW_CMD_OPCODE_MOD_RDQ);
+}
+
+/* QUERY_DQ - Query DQ
+ * ---------------------
+ * OpMod == 0 (send DQ) / OpMod == 1 (receive DQ)
+ * INMmod == DQ number
+ * ----------------------------------------------
+ * The QUERY_DQ command retrieves a snapshot of DQ parameters from the hardware.
+ *
+ * Note: Output mailbox has the same format as SW2HW_DQ.
+ */
+
+static inline int __mlxsw_cmd_query_dq(struct mlxsw_core *mlxsw_core,
+				       char *out_mbox, u32 dq_number,
+				       u8 opcode_mod)
+{
+	return mlxsw_cmd_exec_out(mlxsw_core, MLXSW_CMD_OPCODE_2ERR_DQ,
+				  opcode_mod, dq_number, false,
+				  out_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+static inline int mlxsw_cmd_query_sdq(struct mlxsw_core *mlxsw_core,
+				      char *out_mbox, u32 dq_number)
+{
+	return __mlxsw_cmd_query_dq(mlxsw_core, out_mbox, dq_number,
+				    MLXSW_CMD_OPCODE_MOD_SDQ);
+}
+
+static inline int mlxsw_cmd_query_rdq(struct mlxsw_core *mlxsw_core,
+				      char *out_mbox, u32 dq_number)
+{
+	return __mlxsw_cmd_query_dq(mlxsw_core, out_mbox, dq_number,
+				    MLXSW_CMD_OPCODE_MOD_RDQ);
+}
+
+/* SW2HW_CQ - Software to Hardware CQ
+ * ----------------------------------
+ * OpMod == 0 (N/A), INMmod == CQ number
+ * -------------------------------------
+ * The SW2HW_CQ command transfers ownership of a CQ context entry from software
+ * to hardware. The command takes the CQ context entry from the input mailbox
+ * and stores it in the CQC in the ownership of the hardware. The command fails
+ * if the requested CQC entry is already in the ownership of the hardware.
+ */
+
+static inline int mlxsw_cmd_sw2hw_cq(struct mlxsw_core *mlxsw_core,
+				     char *in_mbox, u32 cq_number)
+{
+	return mlxsw_cmd_exec_in(mlxsw_core, MLXSW_CMD_OPCODE_SW2HW_CQ,
+				 0, cq_number, in_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_sw2hw_cq_cv
+ * CQE Version.
+ * 0 - CQE Version 0, 1 - CQE Version 1
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_cq, cv, 0x00, 28, 4);
+
+/* cmd_mbox_sw2hw_cq_c_eqn
+ * Event Queue this CQ reports completion events to.
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_cq, c_eqn, 0x00, 24, 1);
+
+/* cmd_mbox_sw2hw_cq_oi
+ * When set, overrun ignore is enabled. When set, updates of
+ * CQ consumer counter (poll for completion) or Request completion
+ * notifications (Arm CQ) DoorBells should not be rung on that CQ.
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_cq, oi, 0x00, 12, 1);
+
+/* cmd_mbox_sw2hw_cq_st
+ * Event delivery state machine
+ * 0x0 - FIRED
+ * 0x1 - ARMED (Request for Notification)
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_cq, st, 0x00, 8, 1);
+
+/* cmd_mbox_sw2hw_cq_log_cq_size
+ * Log (base 2) of the CQ size (in entries).
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_cq, log_cq_size, 0x00, 0, 4);
+
+/* cmd_mbox_sw2hw_cq_producer_counter
+ * Producer Counter. The counter is incremented for each CQE that is
+ * written by the HW to the CQ.
+ * Maintained by HW (valid for the QUERY_CQ command only)
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_cq, producer_counter, 0x04, 0, 16);
+
+/* cmd_mbox_sw2hw_cq_pa
+ * Physical Address.
+ */
+MLXSW_ITEM64_INDEXED(cmd_mbox, sw2hw_cq, pa, 0x10, 11, 53, 0x08, 0x00, true);
+
+/* HW2SW_CQ - Hardware to Software CQ
+ * ----------------------------------
+ * OpMod == 0 (N/A), INMmod == CQ number
+ * -------------------------------------
+ * The HW2SW_CQ command transfers ownership of a CQ context entry from hardware
+ * to software. The CQC entry is invalidated as a result of this command.
+ */
+
+static inline int mlxsw_cmd_hw2sw_cq(struct mlxsw_core *mlxsw_core,
+				     u32 cq_number)
+{
+	return mlxsw_cmd_exec_none(mlxsw_core, MLXSW_CMD_OPCODE_HW2SW_CQ,
+				   0, cq_number);
+}
+
+/* QUERY_CQ - Query CQ
+ * ----------------------------------
+ * OpMod == 0 (N/A), INMmod == CQ number
+ * -------------------------------------
+ * The QUERY_CQ command retrieves a snapshot of the current CQ context entry.
+ * The command stores the snapshot in the output mailbox in the software format.
+ * Note that the CQ context state and values are not affected by the QUERY_CQ
+ * command. The QUERY_CQ command is for debug purposes only.
+ *
+ * Note: Output mailbox has the same format as SW2HW_CQ.
+ */
+
+static inline int mlxsw_cmd_query_cq(struct mlxsw_core *mlxsw_core,
+				     char *out_mbox, u32 cq_number)
+{
+	return mlxsw_cmd_exec_out(mlxsw_core, MLXSW_CMD_OPCODE_QUERY_CQ,
+				  0, cq_number, false,
+				  out_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* SW2HW_EQ - Software to Hardware EQ
+ * ----------------------------------
+ * OpMod == 0 (N/A), INMmod == EQ number
+ * -------------------------------------
+ * The SW2HW_EQ command transfers ownership of an EQ context entry from software
+ * to hardware. The command takes the EQ context entry from the input mailbox
+ * and stores it in the EQC in the ownership of the hardware. The command fails
+ * if the requested EQC entry is already in the ownership of the hardware.
+ */
+
+static inline int mlxsw_cmd_sw2hw_eq(struct mlxsw_core *mlxsw_core,
+				     char *in_mbox, u32 eq_number)
+{
+	return mlxsw_cmd_exec_in(mlxsw_core, MLXSW_CMD_OPCODE_SW2HW_EQ,
+				 0, eq_number, in_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_sw2hw_eq_int_msix
+ * When set, MSI-X cycles will be generated by this EQ.
+ * When cleared, an interrupt will be generated by this EQ.
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_eq, int_msix, 0x00, 24, 1);
+
+/* cmd_mbox_sw2hw_eq_int_oi
+ * When set, overrun ignore is enabled.
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_eq, oi, 0x00, 12, 1);
+
+/* cmd_mbox_sw2hw_eq_int_st
+ * Event delivery state machine
+ * 0x0 - FIRED
+ * 0x1 - ARMED (Request for Notification)
+ * 0x11 - Always ARMED
+ * other - reserved
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_eq, st, 0x00, 8, 2);
+
+/* cmd_mbox_sw2hw_eq_int_log_eq_size
+ * Log (base 2) of the EQ size (in entries).
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_eq, log_eq_size, 0x00, 0, 4);
+
+/* cmd_mbox_sw2hw_eq_int_producer_counter
+ * Producer Counter. The counter is incremented for each EQE that is written
+ * by the HW to the EQ.
+ * Maintained by HW (valid for the QUERY_EQ command only)
+ */
+MLXSW_ITEM32(cmd_mbox, sw2hw_eq, producer_counter, 0x04, 0, 16);
+
+/* cmd_mbox_sw2hw_eq_int_pa
+ * Physical Address.
+ */
+MLXSW_ITEM64_INDEXED(cmd_mbox, sw2hw_eq, pa, 0x10, 11, 53, 0x08, 0x00, true);
+
+/* HW2SW_EQ - Hardware to Software EQ
+ * ----------------------------------
+ * OpMod == 0 (N/A), INMmod == EQ number
+ * -------------------------------------
+ */
+
+static inline int mlxsw_cmd_hw2sw_eq(struct mlxsw_core *mlxsw_core,
+				     u32 eq_number)
+{
+	return mlxsw_cmd_exec_none(mlxsw_core, MLXSW_CMD_OPCODE_HW2SW_EQ,
+				   0, eq_number);
+}
+
+/* QUERY_EQ - Query EQ
+ * ----------------------------------
+ * OpMod == 0 (N/A), INMmod == EQ number
+ * -------------------------------------
+ *
+ * Note: Output mailbox has the same format as SW2HW_EQ.
+ */
+
+static inline int mlxsw_cmd_query_eq(struct mlxsw_core *mlxsw_core,
+				     char *out_mbox, u32 eq_number)
+{
+	return mlxsw_cmd_exec_out(mlxsw_core, MLXSW_CMD_OPCODE_QUERY_EQ,
+				  0, eq_number, false,
+				  out_mbox, MLXSW_CMD_MBOX_SIZE);
+}
+
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
new file mode 100644
index 0000000..a4bb94b
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -0,0 +1,550 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/core.c
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
+#include <linux/device.h>
+#include <linux/export.h>
+#include <linux/err.h>
+#include <linux/if_link.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+#include <linux/u64_stats_sync.h>
+#include <linux/netdevice.h>
+
+#include "core.h"
+#include "item.h"
+#include "cmd.h"
+#include "port.h"
+#include "trap.h"
+
+static LIST_HEAD(mlxsw_core_driver_list);
+static DEFINE_SPINLOCK(mlxsw_core_driver_list_lock);
+
+static const char mlxsw_core_driver_name[] = "mlxsw_core";
+
+static struct dentry *mlxsw_core_dbg_root;
+
+struct mlxsw_core_pcpu_stats {
+	u64			trap_rx_packets[MLXSW_TRAP_ID_MAX];
+	u64			trap_rx_bytes[MLXSW_TRAP_ID_MAX];
+	u64			port_rx_packets[MLXSW_PORT_MAX_PORTS];
+	u64			port_rx_bytes[MLXSW_PORT_MAX_PORTS];
+	struct u64_stats_sync	syncp;
+	u32			trap_rx_dropped[MLXSW_TRAP_ID_MAX];
+	u32			port_rx_dropped[MLXSW_PORT_MAX_PORTS];
+	u32			trap_rx_invalid;
+	u32			port_rx_invalid;
+};
+
+struct mlxsw_core {
+	struct mlxsw_driver *driver;
+	const struct mlxsw_bus *bus;
+	void *bus_priv;
+	const struct mlxsw_bus_info *bus_info;
+	struct list_head rx_listener_list;
+	struct mlxsw_core_pcpu_stats __percpu *pcpu_stats;
+	struct dentry *dbg_dir;
+	struct {
+		struct debugfs_blob_wrapper vsd_blob;
+		struct debugfs_blob_wrapper psid_blob;
+	} dbg;
+	unsigned long driver_priv[0];
+	/* driver_priv has to be always the last item */
+};
+
+struct mlxsw_rx_listener_item {
+	struct list_head list;
+	struct mlxsw_rx_listener rxl;
+	void *priv;
+};
+
+/*****************
+ * Core functions
+ *****************/
+
+static int mlxsw_core_rx_stats_dbg_read(struct seq_file *file, void *data)
+{
+	struct mlxsw_core *mlxsw_core = file->private;
+	struct mlxsw_core_pcpu_stats *p;
+	u64 rx_packets, rx_bytes;
+	u64 tmp_rx_packets, tmp_rx_bytes;
+	u32 rx_dropped, rx_invalid;
+	unsigned int start;
+	int i;
+	int j;
+	static const char hdr[] =
+		"     NUM   RX_PACKETS     RX_BYTES RX_DROPPED\n";
+
+	seq_printf(file, hdr);
+	for (i = 0; i < MLXSW_TRAP_ID_MAX; i++) {
+		rx_packets = 0;
+		rx_bytes = 0;
+		rx_dropped = 0;
+		for_each_possible_cpu(j) {
+			p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
+			do {
+				start = u64_stats_fetch_begin(&p->syncp);
+				tmp_rx_packets = p->trap_rx_packets[i];
+				tmp_rx_bytes = p->trap_rx_bytes[i];
+			} while (u64_stats_fetch_retry(&p->syncp, start));
+
+			rx_packets += tmp_rx_packets;
+			rx_bytes += tmp_rx_bytes;
+			rx_dropped += p->trap_rx_dropped[i];
+		}
+		seq_printf(file, "trap %3d %12llu %12llu %10u\n",
+			   i, rx_packets, rx_bytes, rx_dropped);
+	}
+	rx_invalid = 0;
+	for_each_possible_cpu(j) {
+		p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
+		rx_invalid += p->trap_rx_invalid;
+	}
+	seq_printf(file, "trap INV                           %10u\n",
+		   rx_invalid);
+
+	for (i = 0; i < MLXSW_PORT_MAX_PORTS; i++) {
+		rx_packets = 0;
+		rx_bytes = 0;
+		rx_dropped = 0;
+		for_each_possible_cpu(j) {
+			p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
+			do {
+				start = u64_stats_fetch_begin(&p->syncp);
+				tmp_rx_packets = p->port_rx_packets[i];
+				tmp_rx_bytes = p->port_rx_bytes[i];
+			} while (u64_stats_fetch_retry(&p->syncp, start));
+
+			rx_packets += tmp_rx_packets;
+			rx_bytes += tmp_rx_bytes;
+			rx_dropped += p->port_rx_dropped[i];
+		}
+		seq_printf(file, "port %3d %12llu %12llu %10u\n",
+			   i, rx_packets, rx_bytes, rx_dropped);
+	}
+	rx_invalid = 0;
+	for_each_possible_cpu(j) {
+		p = per_cpu_ptr(mlxsw_core->pcpu_stats, j);
+		rx_invalid += p->port_rx_invalid;
+	}
+	seq_printf(file, "port INV                           %10u\n",
+		   rx_invalid);
+	return 0;
+}
+
+static int mlxsw_core_rx_stats_dbg_open(struct inode *inode, struct file *f)
+{
+	struct mlxsw_core *mlxsw_core = inode->i_private;
+
+	return single_open(f, mlxsw_core_rx_stats_dbg_read, mlxsw_core);
+}
+
+static const struct file_operations mlxsw_core_rx_stats_dbg_ops = {
+	.owner = THIS_MODULE,
+	.open = mlxsw_core_rx_stats_dbg_open,
+	.release = single_release,
+	.read = seq_read,
+	.llseek = seq_lseek
+};
+
+static void mlxsw_core_buf_dump_dbg(struct mlxsw_core *mlxsw_core,
+				    const char *buf, size_t size)
+{
+	__be32 *m = (__be32 *) buf;
+	int i;
+	int count = size / sizeof(__be32);
+
+	for (i = count - 1; i >= 0; i--)
+		if (m[i])
+			break;
+	i++;
+	count = i ? i : 1;
+	for (i = 0; i < count; i += 4)
+		dev_dbg(mlxsw_core->bus_info->dev, "%04x - %08x %08x %08x %08x\n",
+			i * 4, be32_to_cpu(m[i]), be32_to_cpu(m[i + 1]),
+			be32_to_cpu(m[i + 2]), be32_to_cpu(m[i + 3]));
+}
+
+int mlxsw_core_driver_register(struct mlxsw_driver *mlxsw_driver)
+{
+	spin_lock(&mlxsw_core_driver_list_lock);
+	list_add_tail(&mlxsw_driver->list, &mlxsw_core_driver_list);
+	spin_unlock(&mlxsw_core_driver_list_lock);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_core_driver_register);
+
+void mlxsw_core_driver_unregister(struct mlxsw_driver *mlxsw_driver)
+{
+	spin_lock(&mlxsw_core_driver_list_lock);
+	list_del(&mlxsw_driver->list);
+	spin_unlock(&mlxsw_core_driver_list_lock);
+}
+EXPORT_SYMBOL(mlxsw_core_driver_unregister);
+
+static struct mlxsw_driver *__driver_find(const char *kind)
+{
+	struct mlxsw_driver *mlxsw_driver;
+
+	list_for_each_entry(mlxsw_driver, &mlxsw_core_driver_list, list) {
+		if (strcmp(mlxsw_driver->kind, kind) == 0)
+			return mlxsw_driver;
+	}
+	return NULL;
+}
+
+static struct mlxsw_driver *mlxsw_core_driver_get(const char *kind)
+{
+	struct mlxsw_driver *mlxsw_driver;
+
+	spin_lock(&mlxsw_core_driver_list_lock);
+	mlxsw_driver = __driver_find(kind);
+	if (!mlxsw_driver) {
+		spin_unlock(&mlxsw_core_driver_list_lock);
+		request_module(MLXSW_MODULE_ALIAS_PREFIX "%s", kind);
+		spin_lock(&mlxsw_core_driver_list_lock);
+		mlxsw_driver = __driver_find(kind);
+	}
+	if (mlxsw_driver) {
+		if (!try_module_get(mlxsw_driver->owner))
+			mlxsw_driver = NULL;
+	}
+
+	spin_unlock(&mlxsw_core_driver_list_lock);
+	return mlxsw_driver;
+}
+
+static void mlxsw_core_driver_put(const char *kind)
+{
+	struct mlxsw_driver *mlxsw_driver;
+
+	spin_lock(&mlxsw_core_driver_list_lock);
+	mlxsw_driver = __driver_find(kind);
+	spin_unlock(&mlxsw_core_driver_list_lock);
+	if (!mlxsw_driver)
+		return;
+	module_put(mlxsw_driver->owner);
+}
+
+static int mlxsw_core_debugfs_init(struct mlxsw_core *mlxsw_core)
+{
+	const struct mlxsw_bus_info *bus_info = mlxsw_core->bus_info;
+
+	mlxsw_core->dbg_dir = debugfs_create_dir(bus_info->device_name,
+						 mlxsw_core_dbg_root);
+	if (!mlxsw_core->dbg_dir)
+		return -ENOMEM;
+	debugfs_create_file("rx_stats", S_IRUGO, mlxsw_core->dbg_dir,
+			    mlxsw_core, &mlxsw_core_rx_stats_dbg_ops);
+	mlxsw_core->dbg.vsd_blob.data = (void *) &bus_info->vsd;
+	mlxsw_core->dbg.vsd_blob.size = sizeof(bus_info->vsd);
+	debugfs_create_blob("vsd", S_IRUGO, mlxsw_core->dbg_dir,
+			    &mlxsw_core->dbg.vsd_blob);
+	mlxsw_core->dbg.psid_blob.data = (void *) &bus_info->psid;
+	mlxsw_core->dbg.psid_blob.size = sizeof(bus_info->psid);
+	debugfs_create_blob("psid", S_IRUGO, mlxsw_core->dbg_dir,
+			    &mlxsw_core->dbg.psid_blob);
+	return 0;
+}
+
+static void mlxsw_core_debugfs_fini(struct mlxsw_core *mlxsw_core)
+{
+	debugfs_remove_recursive(mlxsw_core->dbg_dir);
+}
+
+int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
+				   const struct mlxsw_bus *mlxsw_bus,
+				   void *bus_priv)
+{
+	const char *device_kind = mlxsw_bus_info->device_kind;
+	struct mlxsw_core *mlxsw_core;
+	struct mlxsw_driver *mlxsw_driver;
+	size_t alloc_size;
+	int err;
+
+	mlxsw_driver = mlxsw_core_driver_get(device_kind);
+	if (!mlxsw_driver)
+		return -EINVAL;
+	alloc_size = sizeof(*mlxsw_core) + mlxsw_driver->priv_size;
+	mlxsw_core = kzalloc(alloc_size, GFP_KERNEL);
+	if (!mlxsw_core) {
+		err = -ENOMEM;
+		goto err_core_alloc;
+	}
+
+	INIT_LIST_HEAD(&mlxsw_core->rx_listener_list);
+	mlxsw_core->driver = mlxsw_driver;
+	mlxsw_core->bus = mlxsw_bus;
+	mlxsw_core->bus_priv = bus_priv;
+	mlxsw_core->bus_info = mlxsw_bus_info;
+
+	mlxsw_core->pcpu_stats =
+		netdev_alloc_pcpu_stats(struct mlxsw_core_pcpu_stats);
+	if (!mlxsw_core->pcpu_stats) {
+		err = -ENOMEM;
+		goto err_alloc_stats;
+	}
+	err = mlxsw_bus->init(bus_priv, mlxsw_core, mlxsw_driver->profile);
+	if (err)
+		goto err_bus_init;
+
+	err = mlxsw_driver->init(mlxsw_core->driver_priv, mlxsw_core,
+				 mlxsw_bus_info);
+	if (err)
+		goto err_driver_init;
+
+	err = mlxsw_core_debugfs_init(mlxsw_core);
+	if (err)
+		goto err_debugfs_init;
+
+	return 0;
+
+err_debugfs_init:
+	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
+err_driver_init:
+	mlxsw_bus->fini(bus_priv);
+err_bus_init:
+	free_percpu(mlxsw_core->pcpu_stats);
+err_alloc_stats:
+	kfree(mlxsw_core);
+err_core_alloc:
+	mlxsw_core_driver_put(device_kind);
+	return err;
+}
+EXPORT_SYMBOL(mlxsw_core_bus_device_register);
+
+void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
+{
+	const char *device_kind = mlxsw_core->bus_info->device_kind;
+
+	mlxsw_core_debugfs_fini(mlxsw_core);
+	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
+	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
+	free_percpu(mlxsw_core->pcpu_stats);
+	kfree(mlxsw_core);
+	mlxsw_core_driver_put(device_kind);
+}
+EXPORT_SYMBOL(mlxsw_core_bus_device_unregister);
+
+static struct mlxsw_core *__mlxsw_core_get(void *driver_priv)
+{
+	return container_of(driver_priv, struct mlxsw_core, driver_priv);
+}
+
+int mlxsw_core_skb_transmit(void *driver_priv, struct sk_buff *skb,
+			    const struct mlxsw_tx_info *tx_info)
+{
+	struct mlxsw_core *mlxsw_core = __mlxsw_core_get(driver_priv);
+
+	return mlxsw_core->bus->skb_transmit(mlxsw_core->bus_priv, skb,
+					     tx_info);
+}
+EXPORT_SYMBOL(mlxsw_core_skb_transmit);
+
+static bool __is_rx_listener_equal(const struct mlxsw_rx_listener *rxl_a,
+				   const struct mlxsw_rx_listener *rxl_b)
+{
+	return (rxl_a->func == rxl_b->func &&
+		rxl_a->local_port == rxl_b->local_port &&
+		rxl_a->trap_id == rxl_b->trap_id);
+}
+
+static struct mlxsw_rx_listener_item *
+__find_rx_listener_item(struct mlxsw_core *mlxsw_core,
+			const struct mlxsw_rx_listener *rxl,
+			void *priv)
+{
+	struct mlxsw_rx_listener_item *rxl_item;
+
+	list_for_each_entry(rxl_item, &mlxsw_core->rx_listener_list, list) {
+		if (__is_rx_listener_equal(&rxl_item->rxl, rxl) &&
+		    rxl_item->priv == priv)
+			return rxl_item;
+	}
+	return NULL;
+}
+
+int mlxsw_core_rx_listener_register(struct mlxsw_core *mlxsw_core,
+				    const struct mlxsw_rx_listener *rxl,
+				    void *priv)
+{
+	struct mlxsw_rx_listener_item *rxl_item;
+
+	rxl_item = __find_rx_listener_item(mlxsw_core, rxl, priv);
+	if (rxl_item)
+		return -EEXIST;
+	rxl_item = kmalloc(sizeof(*rxl_item), GFP_KERNEL);
+	if (!rxl_item)
+		return -ENOMEM;
+	rxl_item->rxl = *rxl;
+	rxl_item->priv = priv;
+
+	list_add_rcu(&rxl_item->list, &mlxsw_core->rx_listener_list);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_core_rx_listener_register);
+
+void mlxsw_core_rx_listener_unregister(struct mlxsw_core *mlxsw_core,
+				       const struct mlxsw_rx_listener *rxl,
+				       void *priv)
+{
+	struct mlxsw_rx_listener_item *rxl_item;
+
+	rxl_item = __find_rx_listener_item(mlxsw_core, rxl, priv);
+	if (!rxl_item)
+		return;
+	list_del_rcu(&rxl_item->list);
+	synchronize_rcu();
+	kfree(rxl_item);
+}
+EXPORT_SYMBOL(mlxsw_core_rx_listener_unregister);
+
+void mlxsw_core_skb_receive(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
+			    struct mlxsw_rx_info *rx_info)
+{
+	struct mlxsw_rx_listener_item *rxl_item;
+	const struct mlxsw_rx_listener *rxl;
+	struct mlxsw_core_pcpu_stats *pcpu_stats;
+	u8 local_port = rx_info->sys_port;
+	bool found = false;
+
+	dev_dbg_ratelimited(mlxsw_core->bus_info->dev, "%s: sys_port = %d, trap_id = 0x%x\n",
+			    __func__, rx_info->sys_port, rx_info->trap_id);
+
+	if ((rx_info->trap_id >= MLXSW_TRAP_ID_MAX) ||
+	    (local_port >= MLXSW_PORT_MAX_PORTS))
+		goto drop;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(rxl_item, &mlxsw_core->rx_listener_list, list) {
+		rxl = &rxl_item->rxl;
+		if ((rxl->local_port == MLXSW_PORT_DONT_CARE ||
+		     rxl->local_port == local_port) &&
+		    rxl->trap_id == rx_info->trap_id) {
+			found = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	if (!found)
+		goto drop;
+
+	pcpu_stats = this_cpu_ptr(mlxsw_core->pcpu_stats);
+	u64_stats_update_begin(&pcpu_stats->syncp);
+	pcpu_stats->port_rx_packets[local_port]++;
+	pcpu_stats->port_rx_bytes[local_port] += skb->len;
+	pcpu_stats->trap_rx_packets[rx_info->trap_id]++;
+	pcpu_stats->trap_rx_bytes[rx_info->trap_id] += skb->len;
+	u64_stats_update_end(&pcpu_stats->syncp);
+
+	rxl->func(skb, local_port, rxl_item->priv);
+	return;
+
+drop:
+	if (rx_info->trap_id >= MLXSW_TRAP_ID_MAX)
+		this_cpu_inc(mlxsw_core->pcpu_stats->trap_rx_invalid);
+	else
+		this_cpu_inc(mlxsw_core->pcpu_stats->trap_rx_dropped[rx_info->trap_id]);
+	if (local_port >= MLXSW_PORT_MAX_PORTS)
+		this_cpu_inc(mlxsw_core->pcpu_stats->port_rx_invalid);
+	else
+		this_cpu_inc(mlxsw_core->pcpu_stats->port_rx_dropped[local_port]);
+	dev_kfree_skb(skb);
+}
+EXPORT_SYMBOL(mlxsw_core_skb_receive);
+
+int mlxsw_cmd_exec(struct mlxsw_core *mlxsw_core, u16 opcode, u8 opcode_mod,
+		   u32 in_mod, bool out_mbox_direct,
+		   char *in_mbox, size_t in_mbox_size,
+		   char *out_mbox, size_t out_mbox_size)
+{
+	u8 status;
+	int err;
+
+	BUG_ON(in_mbox_size % sizeof(u32) || out_mbox_size % sizeof(u32));
+	if (!mlxsw_core->bus->cmd_exec)
+		return -EOPNOTSUPP;
+
+	dev_dbg(mlxsw_core->bus_info->dev, "Cmd exec (opcode=%x(%s),opcode_mod=%x,in_mod=%x)\n",
+		opcode, mlxsw_cmd_opcode_str(opcode), opcode_mod, in_mod);
+	if (in_mbox) {
+		dev_dbg(mlxsw_core->bus_info->dev, "Input mailbox:\n");
+		mlxsw_core_buf_dump_dbg(mlxsw_core, in_mbox, in_mbox_size);
+	}
+
+	err = mlxsw_core->bus->cmd_exec(mlxsw_core->bus_priv, opcode,
+					opcode_mod, in_mod, out_mbox_direct,
+					in_mbox, in_mbox_size,
+					out_mbox, out_mbox_size, &status);
+
+	if (err == -EIO && status != MLXSW_CMD_STATUS_OK) {
+		dev_err(mlxsw_core->bus_info->dev, "Cmd exec failed (opcode=%x(%s),opcode_mod=%x,in_mod=%x,status=%x(%s))\n",
+			opcode, mlxsw_cmd_opcode_str(opcode), opcode_mod,
+			in_mod, status, mlxsw_cmd_status_str(status));
+	} else if (err == -ETIMEDOUT) {
+		dev_err(mlxsw_core->bus_info->dev, "Cmd exec timed-out (opcode=%x(%s),opcode_mod=%x,in_mod=%x)\n",
+			opcode, mlxsw_cmd_opcode_str(opcode), opcode_mod,
+			in_mod);
+	}
+
+	if (!err && out_mbox) {
+		dev_dbg(mlxsw_core->bus_info->dev, "Output mailbox:\n");
+		mlxsw_core_buf_dump_dbg(mlxsw_core, out_mbox, out_mbox_size);
+	}
+	return err;
+}
+EXPORT_SYMBOL(mlxsw_cmd_exec);
+
+static int __init mlxsw_core_module_init(void)
+{
+	mlxsw_core_dbg_root = debugfs_create_dir(mlxsw_core_driver_name, NULL);
+	if (!mlxsw_core_dbg_root)
+		return -ENOMEM;
+	return 0;
+}
+
+static void __exit mlxsw_core_module_exit(void)
+{
+	debugfs_remove_recursive(mlxsw_core_dbg_root);
+}
+
+module_init(mlxsw_core_module_init);
+module_exit(mlxsw_core_module_exit);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
+MODULE_DESCRIPTION("Mellanox switch device core driver");
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
new file mode 100644
index 0000000..f4ab36a
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -0,0 +1,179 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/core.h
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
+#ifndef _MLXSW_CORE_H
+#define _MLXSW_CORE_H
+
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/slab.h>
+#include <linux/gfp.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+
+#include "cmd.h"
+
+#define MLXSW_MODULE_ALIAS_PREFIX "mlxsw-driver-"
+#define MODULE_MLXSW_DRIVER_ALIAS(kind)	\
+	MODULE_ALIAS(MLXSW_MODULE_ALIAS_PREFIX kind)
+
+struct mlxsw_core;
+struct mlxsw_driver;
+struct mlxsw_bus;
+struct mlxsw_bus_info;
+
+int mlxsw_core_driver_register(struct mlxsw_driver *mlxsw_driver);
+void mlxsw_core_driver_unregister(struct mlxsw_driver *mlxsw_driver);
+
+int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
+				   const struct mlxsw_bus *mlxsw_bus,
+				   void *bus_priv);
+void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core);
+
+struct mlxsw_tx_info {
+	u8 local_port;
+	bool is_emad;
+};
+
+int mlxsw_core_skb_transmit(void *driver_priv, struct sk_buff *skb,
+			    const struct mlxsw_tx_info *tx_info);
+
+struct mlxsw_rx_listener {
+	void (*func)(struct sk_buff *skb, u8 local_port, void *priv);
+	u8 local_port;
+	u16 trap_id;
+};
+
+int mlxsw_core_rx_listener_register(struct mlxsw_core *mlxsw_core,
+				    const struct mlxsw_rx_listener *rxl,
+				    void *priv);
+void mlxsw_core_rx_listener_unregister(struct mlxsw_core *mlxsw_core,
+				       const struct mlxsw_rx_listener *rxl,
+				       void *priv);
+
+struct mlxsw_rx_info {
+	u16 sys_port;
+	int trap_id;
+};
+
+void mlxsw_core_skb_receive(struct mlxsw_core *mlxsw_core, struct sk_buff *skb,
+			    struct mlxsw_rx_info *rx_info);
+
+#define MLXSW_CONFIG_PROFILE_SWID_COUNT 8
+
+struct mlxsw_swid_config {
+	u8	used_type:1,
+		used_properties:1;
+	u8	type;
+	u8	properties;
+};
+
+struct mlxsw_config_profile {
+	u16	used_max_vepa_channels:1,
+		used_max_lag:1,
+		used_max_port_per_lag:1,
+		used_max_mid:1,
+		used_max_pgt:1,
+		used_max_system_port:1,
+		used_max_vlan_groups:1,
+		used_max_regions:1,
+		used_flood_tables:1,
+		used_flood_mode:1,
+		used_max_ib_mc:1,
+		used_max_pkey:1,
+		used_ar_sec:1,
+		used_adaptive_routing_group_cap:1;
+	u8	max_vepa_channels;
+	u16	max_lag;
+	u16	max_port_per_lag;
+	u16	max_mid;
+	u16	max_pgt;
+	u16	max_system_port;
+	u16	max_vlan_groups;
+	u16	max_regions;
+	u8	max_flood_tables;
+	u8	max_vid_flood_tables;
+	u8	flood_mode;
+	u16	max_ib_mc;
+	u16	max_pkey;
+	u8	ar_sec;
+	u16	adaptive_routing_group_cap;
+	u8	arn;
+	struct mlxsw_swid_config swid_config[MLXSW_CONFIG_PROFILE_SWID_COUNT];
+};
+
+struct mlxsw_driver {
+	struct list_head list;
+	const char *kind;
+	struct module *owner;
+	size_t priv_size;
+	int (*init)(void *driver_priv, struct mlxsw_core *mlxsw_core,
+		    const struct mlxsw_bus_info *mlxsw_bus_info);
+	void (*fini)(void *driver_priv);
+	void (*txhdr_construct)(struct sk_buff *skb,
+				const struct mlxsw_tx_info *tx_info);
+	u8 txhdr_len;
+	const struct mlxsw_config_profile *profile;
+};
+
+struct mlxsw_bus {
+	const char *kind;
+	int (*init)(void *bus_priv, struct mlxsw_core *mlxsw_core,
+		    const struct mlxsw_config_profile *profile);
+	void (*fini)(void *bus_priv);
+	int (*skb_transmit)(void *bus_priv, struct sk_buff *skb,
+			    const struct mlxsw_tx_info *tx_info);
+	int (*cmd_exec)(void *bus_priv, u16 opcode, u8 opcode_mod,
+			u32 in_mod, bool out_mbox_direct,
+			char *in_mbox, size_t in_mbox_size,
+			char *out_mbox, size_t out_mbox_size,
+			u8 *p_status);
+};
+
+struct mlxsw_bus_info {
+	const char *device_kind;
+	const char *device_name;
+	struct device *dev;
+	struct {
+		u16 major;
+		u16 minor;
+		u16 subminor;
+	} fw_rev;
+	u8 vsd[MLXSW_CMD_BOARDINFO_VSD_LEN];
+	u8 psid[MLXSW_CMD_BOARDINFO_PSID_LEN];
+};
+
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
new file mode 100644
index 0000000..4d0ac88
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -0,0 +1,405 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/item.h
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
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
+#ifndef _MLXSW_ITEM_H
+#define _MLXSW_ITEM_H
+
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/bitops.h>
+
+struct mlxsw_item {
+	unsigned short	offset;		/* bytes in container */
+	unsigned short	step;		/* step in bytes for indexed items */
+	unsigned short	in_step_offset; /* offset within one step */
+	unsigned char	shift;		/* shift in bits */
+	unsigned char	element_size;	/* size of element in bit array */
+	bool		no_real_shift;
+	union {
+		unsigned char	bits;
+		unsigned short	bytes;
+	} size;
+	const char	*name;
+};
+
+static inline unsigned int
+__mlxsw_item_offset(struct mlxsw_item *item, unsigned short index,
+		    size_t typesize)
+{
+	BUG_ON(index && !item->step);
+	if (item->offset % typesize != 0 ||
+	    item->step % typesize != 0 ||
+	    item->in_step_offset % typesize != 0) {
+		pr_err("mlxsw: item bug (name=%s,offset=%x,step=%x,in_step_offset=%x,typesize=%lx)\n",
+		       item->name, item->offset, item->step,
+		       item->in_step_offset, typesize);
+		BUG();
+	}
+
+	return ((item->offset + item->step * index + item->in_step_offset) /
+		typesize);
+}
+
+static inline u16 __mlxsw_item_get16(char *buf, struct mlxsw_item *item,
+				     unsigned short index)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u16));
+	__be16 *b = (__be16 *) buf;
+	u16 tmp;
+
+	tmp = be16_to_cpu(b[offset]);
+	tmp >>= item->shift;
+	tmp &= GENMASK(item->size.bits - 1, 0);
+	if (item->no_real_shift)
+		tmp <<= item->shift;
+	return tmp;
+}
+
+static inline void __mlxsw_item_set16(char *buf, struct mlxsw_item *item,
+				      unsigned short index, u16 val)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index,
+						  sizeof(u16));
+	__be16 *b = (__be16 *) buf;
+	u16 mask = GENMASK(item->size.bits - 1, 0) << item->shift;
+	u16 tmp;
+
+	if (!item->no_real_shift)
+		val <<= item->shift;
+	val &= mask;
+	tmp = be16_to_cpu(b[offset]);
+	tmp &= ~mask;
+	tmp |= val;
+	b[offset] = cpu_to_be16(tmp);
+}
+
+static inline u32 __mlxsw_item_get32(char *buf, struct mlxsw_item *item,
+				     unsigned short index)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u32));
+	__be32 *b = (__be32 *) buf;
+	u32 tmp;
+
+	tmp = be32_to_cpu(b[offset]);
+	tmp >>= item->shift;
+	tmp &= GENMASK(item->size.bits - 1, 0);
+	if (item->no_real_shift)
+		tmp <<= item->shift;
+	return tmp;
+}
+
+static inline void __mlxsw_item_set32(char *buf, struct mlxsw_item *item,
+				      unsigned short index, u32 val)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index,
+						  sizeof(u32));
+	__be32 *b = (__be32 *) buf;
+	u32 mask = GENMASK(item->size.bits - 1, 0) << item->shift;
+	u32 tmp;
+
+	if (!item->no_real_shift)
+		val <<= item->shift;
+	val &= mask;
+	tmp = be32_to_cpu(b[offset]);
+	tmp &= ~mask;
+	tmp |= val;
+	b[offset] = cpu_to_be32(tmp);
+}
+
+static inline u64 __mlxsw_item_get64(char *buf, struct mlxsw_item *item,
+				     unsigned short index)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u64));
+	__be64 *b = (__be64 *) buf;
+	u64 tmp;
+
+	tmp = be64_to_cpu(b[offset]);
+	tmp >>= item->shift;
+	tmp &= GENMASK_ULL(item->size.bits - 1, 0);
+	if (item->no_real_shift)
+		tmp <<= item->shift;
+	return tmp;
+}
+
+static inline void __mlxsw_item_set64(char *buf, struct mlxsw_item *item,
+				      unsigned short index, u64 val)
+{
+	unsigned int offset = __mlxsw_item_offset(item, index, sizeof(u64));
+	__be64 *b = (__be64 *) buf;
+	u64 mask = GENMASK_ULL(item->size.bits - 1, 0) << item->shift;
+	u64 tmp;
+
+	if (!item->no_real_shift)
+		val <<= item->shift;
+	val &= mask;
+	tmp = be64_to_cpu(b[offset]);
+	tmp &= ~mask;
+	tmp |= val;
+	b[offset] = cpu_to_be64(tmp);
+}
+
+static inline void __mlxsw_item_memcpy_from(char *buf, char *dst,
+					    struct mlxsw_item *item)
+{
+	memcpy(dst, &buf[item->offset], item->size.bytes);
+}
+
+static inline void __mlxsw_item_memcpy_to(char *buf, char *src,
+					  struct mlxsw_item *item)
+{
+	memcpy(&buf[item->offset], src, item->size.bytes);
+}
+
+static inline u16
+__mlxsw_item_bit_array_offset(struct mlxsw_item *item, u16 index, u8 *shift)
+{
+	u16 max_index, be_index;
+	u16 offset;		/* byte offset inside the array */
+
+	BUG_ON(index && !item->element_size);
+	if (item->offset % sizeof(u32) != 0 ||
+	    BITS_PER_BYTE % item->element_size != 0) {
+		pr_err("mlxsw: item bug (name=%s,offset=%x,element_size=%x)\n",
+		       item->name, item->offset, item->element_size);
+		BUG();
+	}
+
+	max_index = (item->size.bytes << 3) / item->element_size - 1;
+	be_index = max_index - index;
+	offset = be_index * item->element_size >> 3;
+	*shift = index % (BITS_PER_BYTE / item->element_size) << 1;
+
+	return item->offset + offset;
+}
+
+static inline u8 __mlxsw_item_bit_array_get(char *buf, struct mlxsw_item *item,
+					    u16 index)
+{
+	u8 shift, tmp;
+	u16 offset = __mlxsw_item_bit_array_offset(item, index, &shift);
+
+	tmp = buf[offset];
+	tmp >>= shift;
+	tmp &= GENMASK(item->element_size - 1, 0);
+	return tmp;
+}
+
+static inline void __mlxsw_item_bit_array_set(char *buf, struct mlxsw_item *item,
+					      u16 index, u8 val)
+{
+	u8 shift, tmp;
+	u16 offset = __mlxsw_item_bit_array_offset(item, index, &shift);
+	u8 mask = GENMASK(item->element_size - 1, 0) << shift;
+
+	val <<= shift;
+	val &= mask;
+	tmp = buf[offset];
+	tmp &= ~mask;
+	tmp |= val;
+	buf[offset] = tmp;
+}
+
+#define __ITEM_NAME(_type, _cname, _iname)					\
+	mlxsw_##_type##_##_cname##_##_iname##_item
+
+/* _type: cmd_mbox, reg, etc.
+ * _cname: containter name (e.g. command name, register name)
+ * _iname: item name within the container
+ */
+
+#define MLXSW_ITEM16(_type, _cname, _iname, _offset, _shift, _sizebits)		\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.shift = _shift,							\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u16 mlxsw_##_type##_##_cname##_##_iname##_get(char *buf)		\
+{										\
+	return __mlxsw_item_get16(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
+}										\
+static inline void mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, u16 val)\
+{										\
+	__mlxsw_item_set16(buf, &__ITEM_NAME(_type, _cname, _iname), 0, val);	\
+}
+
+#define MLXSW_ITEM16_INDEXED(_type, _cname, _iname, _offset, _shift, _sizebits,	\
+			     _step, _instepoffset, _norealshift)		\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.step = _step,								\
+	.in_step_offset = _instepoffset,					\
+	.shift = _shift,							\
+	.no_real_shift = _norealshift,						\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u16								\
+mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, unsigned short index)	\
+{										\
+	return __mlxsw_item_get16(buf, &__ITEM_NAME(_type, _cname, _iname),	\
+				  index);					\
+}										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, unsigned short index,	\
+					  u16 val)				\
+{										\
+	__mlxsw_item_set16(buf, &__ITEM_NAME(_type, _cname, _iname),		\
+			   index, val);						\
+}
+
+#define MLXSW_ITEM32(_type, _cname, _iname, _offset, _shift, _sizebits)		\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.shift = _shift,							\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u32 mlxsw_##_type##_##_cname##_##_iname##_get(char *buf)		\
+{										\
+	return __mlxsw_item_get32(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
+}										\
+static inline void mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, u32 val)\
+{										\
+	__mlxsw_item_set32(buf, &__ITEM_NAME(_type, _cname, _iname), 0, val);	\
+}
+
+#define MLXSW_ITEM32_INDEXED(_type, _cname, _iname, _offset, _shift, _sizebits,	\
+			     _step, _instepoffset, _norealshift)		\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.step = _step,								\
+	.in_step_offset = _instepoffset,					\
+	.shift = _shift,							\
+	.no_real_shift = _norealshift,						\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u32								\
+mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, unsigned short index)	\
+{										\
+	return __mlxsw_item_get32(buf, &__ITEM_NAME(_type, _cname, _iname),	\
+				  index);					\
+}										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, unsigned short index,	\
+					  u32 val)				\
+{										\
+	__mlxsw_item_set32(buf, &__ITEM_NAME(_type, _cname, _iname),		\
+			   index, val);						\
+}
+
+#define MLXSW_ITEM64(_type, _cname, _iname, _offset, _shift, _sizebits)		\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.shift = _shift,							\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u64 mlxsw_##_type##_##_cname##_##_iname##_get(char *buf)		\
+{										\
+	return __mlxsw_item_get64(buf, &__ITEM_NAME(_type, _cname, _iname), 0);	\
+}										\
+static inline void mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, u64 val)\
+{										\
+	__mlxsw_item_set64(buf, &__ITEM_NAME(_type, _cname, _iname), 0,	val);	\
+}
+
+#define MLXSW_ITEM64_INDEXED(_type, _cname, _iname, _offset, _shift,		\
+			     _sizebits, _step, _instepoffset, _norealshift)	\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.step = _step,								\
+	.in_step_offset = _instepoffset,					\
+	.shift = _shift,							\
+	.no_real_shift = _norealshift,						\
+	.size = {.bits = _sizebits,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u64								\
+mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, unsigned short index)	\
+{										\
+	return __mlxsw_item_get64(buf, &__ITEM_NAME(_type, _cname, _iname),	\
+				  index);					\
+}										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, unsigned short index,	\
+					  u64 val)				\
+{										\
+	__mlxsw_item_set64(buf, &__ITEM_NAME(_type, _cname, _iname),		\
+			   index, val);						\
+}
+
+#define MLXSW_ITEM_BUF(_type, _cname, _iname, _offset, _sizebytes)		\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.size = {.bytes = _sizebytes,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(char *buf, char *dst)		\
+{										\
+	__mlxsw_item_memcpy_from(buf, dst, &__ITEM_NAME(_type, _cname, _iname));\
+}										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_memcpy_to(char *buf, char *src)		\
+{										\
+	__mlxsw_item_memcpy_to(buf, src, &__ITEM_NAME(_type, _cname, _iname));	\
+}
+
+#define MLXSW_ITEM_BIT_ARRAY(_type, _cname, _iname, _offset, _sizebytes,	\
+			     _element_size)					\
+static struct mlxsw_item __ITEM_NAME(_type, _cname, _iname) = {			\
+	.offset = _offset,							\
+	.element_size = _element_size,						\
+	.size = {.bytes = _sizebytes,},						\
+	.name = #_type "_" #_cname "_" #_iname,					\
+};										\
+static inline u8								\
+mlxsw_##_type##_##_cname##_##_iname##_get(char *buf, u16 index)			\
+{										\
+	return __mlxsw_item_bit_array_get(buf,					\
+					  &__ITEM_NAME(_type, _cname, _iname),	\
+					  index);				\
+}										\
+static inline void								\
+mlxsw_##_type##_##_cname##_##_iname##_set(char *buf, u16 index, u8 val)		\
+{										\
+	return __mlxsw_item_bit_array_set(buf,					\
+					  &__ITEM_NAME(_type, _cname, _iname),	\
+					  index, val);				\
+}										\
+
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/port.h b/drivers/net/ethernet/mellanox/mlxsw/port.h
new file mode 100644
index 0000000..1b43c7d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/port.h
@@ -0,0 +1,52 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/port.h
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
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
+#ifndef _MLXSW_PORT_H
+#define _MLXSW_PORT_H
+
+#include <linux/types.h>
+
+#define MLXSW_PORT_MAX_MTU		10000
+
+#define MLXSW_PORT_DEFAULT_VID		1
+
+#define MLXSW_PORT_MAX_PHY_PORTS	0x40
+#define MLXSW_PORT_MAX_PORTS		MLXSW_PORT_MAX_PHY_PORTS
+
+#define MLXSW_PORT_CPU_PORT		0x0
+
+#define MLXSW_PORT_DONT_CARE		(MLXSW_PORT_MAX_PORTS)
+
+#endif /* _MLXSW_PORT_H */
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
new file mode 100644
index 0000000..53a9550
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -0,0 +1,66 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/trap.h
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
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
+#ifndef _MLXSW_TRAP_H
+#define _MLXSW_TRAP_H
+
+enum {
+	/* Ethernet EMAD and FDB miss */
+	MLXSW_TRAP_ID_FDB_MC = 0x01,
+	MLXSW_TRAP_ID_ETHEMAD = 0x05,
+	/* L2 traps for specific packet types */
+	MLXSW_TRAP_ID_STP = 0x10,
+	MLXSW_TRAP_ID_LACP = 0x11,
+	MLXSW_TRAP_ID_EAPOL = 0x12,
+	MLXSW_TRAP_ID_LLDP = 0x13,
+	MLXSW_TRAP_ID_MMRP = 0x14,
+	MLXSW_TRAP_ID_MVRP = 0x15,
+	MLXSW_TRAP_ID_RPVST = 0x16,
+	MLXSW_TRAP_ID_DHCP = 0x19,
+	MLXSW_TRAP_ID_IGMP_QUERY = 0x30,
+	MLXSW_TRAP_ID_IGMP_V1_REPORT = 0x31,
+	MLXSW_TRAP_ID_IGMP_V2_REPORT = 0x32,
+	MLXSW_TRAP_ID_IGMP_V2_LEAVE = 0x33,
+	MLXSW_TRAP_ID_IGMP_V3_REPORT = 0x34,
+
+	MLXSW_TRAP_ID_MAX = 0x1FF
+};
+
+enum mlxsw_event_trap_id {
+	/* Port Up/Down event generated by hardware */
+	MLXSW_TRAP_ID_PUDE = 0x8,
+};
+
+#endif /* _MLXSW_TRAP_H */
-- 
1.9.3
