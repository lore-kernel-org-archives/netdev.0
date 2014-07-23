From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [ethtool PATCH 1/1] ethtool: Support cpsw ale-table registers in -d
Date: Wed, 23 Jul 2014 14:59:24 +0530
Message-ID: <1406107764-1737-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:44262 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757442AbaGWJ3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 05:29:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPSW ale-table contains useful details of the MAC address added to the
table and learnt by the device. This dumps them with the -d option.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Makefile.am |   2 +-
 cpsw.c      | 204 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ethtool.c   |   2 +
 internal.h  |   3 +
 4 files changed, 210 insertions(+), 1 deletion(-)
 create mode 100644 cpsw.c

diff --git a/Makefile.am b/Makefile.am
index fd3b17f..79fd623 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -13,7 +13,7 @@ ethtool_SOURCES += \
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
-		  sfpid.c sfpdiag.c ixgbevf.c
+		  sfpid.c sfpdiag.c ixgbevf.c cpsw.c
 endif
 
 TESTS = test-cmdline test-features
diff --git a/cpsw.c b/cpsw.c
new file mode 100644
index 0000000..27c2eb2
--- /dev/null
+++ b/cpsw.c
@@ -0,0 +1,204 @@
+/*
+ * Texas Instruments Common Port Ethernet Switch
+ *
+ * Copyright (C) 2014 Texas Instruments
+ *
+ * Author: Mugunthan V N <mugunthanvnm@ti.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include "internal.h"
+
+#define CPSW_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
+#define CPSW_MINOR_VERSION(reg)		(reg & 0xff)
+#define CPSW_RTL_VERSION(reg)		((reg >> 11) & 0x1f)
+
+#define ADDR_FMT_ARGS(addr)	(addr)[0], (addr)[1], (addr)[2], \
+				(addr)[3], (addr)[4], (addr)[5]
+
+#define ALE_ENTRY_BITS          68
+#define ALE_ENTRY_WORDS         DIV_ROUND_UP(ALE_ENTRY_BITS, 32)
+
+#define BIT(nr)			(1 << (nr))
+#define BITMASK(bits)		(BIT(bits) - 1)
+
+#define ALE_TYPE_FREE			0
+#define ALE_TYPE_ADDR			1
+#define ALE_TYPE_VLAN			2
+#define ALE_TYPE_VLAN_ADDR		3
+
+static inline int cpsw_ale_get_field(u32 *ale_entry, u32 start, u32 bits)
+{
+	int idx;
+
+	idx    = start / 32;
+	start -= idx * 32;
+	idx    = 2 - idx; /* flip */
+	return (ale_entry[idx] >> start) & BITMASK(bits);
+}
+
+static inline void cpsw_ale_set_field(u32 *ale_entry, u32 start, u32 bits,
+				      u32 value)
+{
+	int idx;
+
+	value &= BITMASK(bits);
+	idx    = start / 32;
+	start -= idx * 32;
+	idx    = 2 - idx; /* flip */
+	ale_entry[idx] &= ~(BITMASK(bits) << start);
+	ale_entry[idx] |=  (value << start);
+}
+
+#define DEFINE_ALE_FIELD(name, start, bits)				\
+static inline int cpsw_ale_get_##name(u32 *ale_entry)			\
+{									\
+	return cpsw_ale_get_field(ale_entry, start, bits);		\
+}									\
+static inline void cpsw_ale_set_##name(u32 *ale_entry, u32 value)	\
+{									\
+	cpsw_ale_set_field(ale_entry, start, bits, value);		\
+}
+
+DEFINE_ALE_FIELD(entry_type,		60,	2)
+DEFINE_ALE_FIELD(vlan_id,		48,	12)
+DEFINE_ALE_FIELD(mcast_state,		62,	2)
+DEFINE_ALE_FIELD(port_mask,		66,     3)
+DEFINE_ALE_FIELD(super,			65,	1)
+DEFINE_ALE_FIELD(ucast_type,		62,     2)
+DEFINE_ALE_FIELD(port_num,		66,     2)
+DEFINE_ALE_FIELD(blocked,		65,     1)
+DEFINE_ALE_FIELD(secure,		64,     1)
+DEFINE_ALE_FIELD(vlan_untag_force,	24,	3)
+DEFINE_ALE_FIELD(vlan_reg_mcast,	16,	3)
+DEFINE_ALE_FIELD(vlan_unreg_mcast,	8,	3)
+DEFINE_ALE_FIELD(vlan_member_list,	0,	3)
+DEFINE_ALE_FIELD(mcast,			40,	1)
+
+static inline void cpsw_ale_get_addr(u32 *ale_entry, u8 *addr)
+{
+	int i;
+
+	for (i = 0; i < 6; i++)
+		addr[i] = cpsw_ale_get_field(ale_entry, 40 - 8*i, 8);
+}
+
+static void cpsw_ale_dump_vlan(int index, u32 *ale_entry)
+{
+	int vlan = cpsw_ale_get_vlan_id(ale_entry);
+	int untag_force = cpsw_ale_get_vlan_untag_force(ale_entry);
+	int reg_mcast   = cpsw_ale_get_vlan_reg_mcast(ale_entry);
+	int unreg_mcast = cpsw_ale_get_vlan_unreg_mcast(ale_entry);
+	int member_list = cpsw_ale_get_vlan_member_list(ale_entry);
+
+	fprintf(stdout, "%-4d: type: vlan , vid = %d, untag_force = 0x%x, reg_mcast = 0x%x, unreg_mcast = 0x%x, member_list = 0x%x\n",
+		index, vlan, untag_force, reg_mcast, unreg_mcast, member_list);
+}
+
+static void cpsw_ale_dump_addr(int index, u32 *ale_entry)
+{
+	u8 addr[6];
+
+	cpsw_ale_get_addr(ale_entry, addr);
+	if (cpsw_ale_get_mcast(ale_entry)) {
+		static const char *str_mcast_state[] = {"f", "blf", "lf", "f"};
+		int state     = cpsw_ale_get_mcast_state(ale_entry);
+		int port_mask = cpsw_ale_get_port_mask(ale_entry);
+		int super     = cpsw_ale_get_super(ale_entry);
+
+		fprintf(stdout, "%-4d: type: mcast, addr = %02x:%02x:%02x:%02x:%02x:%02x, mcast_state = %s, %ssuper, port_mask = 0x%x\n",
+			index, ADDR_FMT_ARGS(addr), str_mcast_state[state],
+			super ? "" : "no ", port_mask);
+	} else {
+		static const char *s_ucast_type[] = {"persistant", "untouched ",
+						     "oui       ", "touched   "};
+		int ucast_type = cpsw_ale_get_ucast_type(ale_entry);
+		int port_num   = cpsw_ale_get_port_num(ale_entry);
+		int secure     = cpsw_ale_get_secure(ale_entry);
+		int blocked    = cpsw_ale_get_blocked(ale_entry);
+
+		fprintf(stdout, "%-4d: type: ucast, addr = %02x:%02x:%02x:%02x:%02x:%02x, ucast_type = %s, port_num = 0x%x%s%s\n",
+			index, ADDR_FMT_ARGS(addr), s_ucast_type[ucast_type],
+			port_num, secure ? ", Secure" : "",
+			blocked ? ", Blocked" : "");
+	}
+}
+
+static void cpsw_ale_dump_vlan_addr(int index, u32 *ale_entry)
+{
+	u8 addr[6];
+	int vlan = cpsw_ale_get_vlan_id(ale_entry);
+
+	cpsw_ale_get_addr(ale_entry, addr);
+	if (cpsw_ale_get_mcast(ale_entry)) {
+		static const char *str_mcast_state[] = {"f", "blf", "lf", "f"};
+		int state     = cpsw_ale_get_mcast_state(ale_entry);
+		int port_mask = cpsw_ale_get_port_mask(ale_entry);
+		int super     = cpsw_ale_get_super(ale_entry);
+
+		fprintf(stdout, "%-4d: type: mcast, vid = %d, addr = %02x:%02x:%02x:%02x:%02x:%02x, mcast_state = %s, %ssuper, port_mask = 0x%x\n",
+			index, vlan, ADDR_FMT_ARGS(addr),
+			str_mcast_state[state], super ? "" : "no ", port_mask);
+	} else {
+		static const char *s_ucast_type[] = {"persistant", "untouched ",
+						     "oui       ", "touched   "};
+		int ucast_type = cpsw_ale_get_ucast_type(ale_entry);
+		int port_num   = cpsw_ale_get_port_num(ale_entry);
+		int secure     = cpsw_ale_get_secure(ale_entry);
+		int blocked    = cpsw_ale_get_blocked(ale_entry);
+
+		fprintf(stdout, "%-4d: type: ucast, vid = %d, addr = %02x:%02x:%02x:%02x:%02x:%02x, ucast_type = %s, port_num = 0x%x%s%s\n",
+			index, vlan, ADDR_FMT_ARGS(addr),
+			s_ucast_type[ucast_type], port_num,
+			secure ? ", Secure" : "", blocked ? ", Blocked" : "");
+	}
+}
+
+int cpsw_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u32 *reg = (u8 *)regs->data;
+	u32 len = regs->len / 3;
+	int i;
+
+	fprintf(stdout, "cpsw hw version %d.%d (%d)\n",
+		CPSW_MAJOR_VERSION(regs->version),
+		CPSW_MINOR_VERSION(regs->version),
+		CPSW_RTL_VERSION(regs->version));
+
+	for(i = 0; i < 1024; i++, reg += ALE_ENTRY_WORDS) {
+		int type;
+
+		type = cpsw_ale_get_entry_type(reg);
+		switch (type) {
+		case ALE_TYPE_FREE:
+			break;
+
+		case ALE_TYPE_ADDR:
+			cpsw_ale_dump_addr(i, reg);
+			break;
+
+		case ALE_TYPE_VLAN:
+			cpsw_ale_dump_vlan(i, reg);
+			break;
+
+		case ALE_TYPE_VLAN_ADDR:
+			cpsw_ale_dump_vlan_addr(i, reg);
+			break;
+
+		default:
+			fprintf(stdout, "%-4d: Invalid Entry type\n", i);
+		}
+	}
+
+	return 0;
+}
diff --git a/ethtool.c b/ethtool.c
index 8e968a8..8d2b53f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -20,6 +20,7 @@
  *	Copyright 2009, 2010 Solarflare Communications
  * MDI-X set support by Jesse Brandeburg <jesse.brandeburg@intel.com>
  *	Copyright 2012 Intel Corporation
+ * cpsw support by Mugunthan V N <mugunthanvnm@ti.com>
  *
  * TODO:
  *   * show settings for all devices
@@ -910,6 +911,7 @@ static const struct {
 	{ "st_mac100", st_mac100_dump_regs },
 	{ "st_gmac", st_gmac_dump_regs },
 	{ "et131x", et131x_dump_regs },
+	{ "cpsw", cpsw_dump_regs },
 #endif
 };
 
diff --git a/internal.h b/internal.h
index 86a64f2..c8247c2 100644
--- a/internal.h
+++ b/internal.h
@@ -243,6 +243,9 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 /* Et131x ethernet controller */
 int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+/* CPSW Ethernet Switch */
+int cpsw_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 /* Rx flow classification */
 int rxclass_parse_ruleopts(struct cmd_context *ctx,
 			   struct ethtool_rx_flow_spec *fsp);
-- 
2.0.2.673.g9ab0882
