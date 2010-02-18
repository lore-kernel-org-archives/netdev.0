From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 3/7] cxgb4: Add HW and FW support code
Date: Wed, 17 Feb 2010 17:37:38 -0800
Message-ID: <1266457062-31150-4-git-send-email-dm@chelsio.com>
References: <1266457062-31150-1-git-send-email-dm@chelsio.com>
 <1266457062-31150-2-git-send-email-dm@chelsio.com>
 <1266457062-31150-3-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21687 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108Ab0BRBho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 20:37:44 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o1I1bhAe024567
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 17:37:43 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o1I1bhrt031212
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 17:37:43 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o1I1bhOo031210
	for netdev@vger.kernel.org; Wed, 17 Feb 2010 17:37:43 -0800
In-Reply-To: <1266457062-31150-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c | 3116 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.h |  129 ++
 2 files changed, 3245 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/cxgb4/t4_hw.c
 create mode 100644 drivers/net/cxgb4/t4_hw.h

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
new file mode 100644
index 0000000..fee2f32
--- /dev/null
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -0,0 +1,3116 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/init.h>
+#include <linux/delay.h>
+#include "cxgb4.h"
+#include "t4_regs.h"
+#include "t4fw_api.h"
+
+/**
+ *	t4_wait_op_done_val - wait until an operation is completed
+ *	@adapter: the adapter performing the operation
+ *	@reg: the register to check for completion
+ *	@mask: a single-bit field within @reg that indicates completion
+ *	@polarity: the value of the field when the operation is completed
+ *	@attempts: number of check iterations
+ *	@delay: delay in usecs between iterations
+ *	@valp: where to store the value of the register at completion time
+ *
+ *	Wait until an operation is completed by checking a bit in a register
+ *	up to @attempts times.  If @valp is not NULL the value of the register
+ *	at the time it indicated completion is stored there.  Returns 0 if the
+ *	operation completes and	-EAGAIN	otherwise.
+ */
+int t4_wait_op_done_val(struct adapter *adapter, int reg, u32 mask,
+			int polarity, int attempts, int delay, u32 *valp)
+{
+	while (1) {
+		u32 val = t4_read_reg(adapter, reg);
+
+		if (!!(val & mask) == polarity) {
+			if (valp)
+				*valp = val;
+			return 0;
+		}
+		if (--attempts == 0)
+			return -EAGAIN;
+		if (delay)
+			udelay(delay);
+	}
+}
+
+static inline int t4_wait_op_done(struct adapter *adapter, int reg, u32 mask,
+				  int polarity, int attempts, int delay)
+{
+	return t4_wait_op_done_val(adapter, reg, mask, polarity, attempts,
+				   delay, NULL);
+}
+
+/**
+ *	t4_set_reg_field - set a register field to a value
+ *	@adapter: the adapter to program
+ *	@addr: the register address
+ *	@mask: specifies the portion of the register to modify
+ *	@val: the new value for the register field
+ *
+ *	Sets a register field specified by the supplied mask to the
+ *	given value.
+ */
+void t4_set_reg_field(struct adapter *adapter, unsigned int addr, u32 mask,
+		      u32 val)
+{
+	u32 v = t4_read_reg(adapter, addr) & ~mask;
+
+	t4_write_reg(adapter, addr, v | val);
+	(void) t4_read_reg(adapter, addr);      /* flush */
+}
+
+/**
+ *	t4_read_indirect - read indirectly addressed registers
+ *	@adap: the adapter
+ *	@addr_reg: register holding the indirect address
+ *	@data_reg: register holding the value of the indirect register
+ *	@vals: where the read register values are stored
+ *	@nregs: how many indirect registers to read
+ *	@start_idx: index of first indirect register to read
+ *
+ *	Reads registers that are accessed indirectly through an address/data
+ *	register pair.
+ */
+void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
+		      unsigned int data_reg, u32 *vals, unsigned int nregs,
+		      unsigned int start_idx)
+{
+	while (nregs--) {
+		t4_write_reg(adap, addr_reg, start_idx);
+		*vals++ = t4_read_reg(adap, data_reg);
+		start_idx++;
+	}
+}
+
+/**
+ *	t4_write_indirect - write indirectly addressed registers
+ *	@adap: the adapter
+ *	@addr_reg: register holding the indirect addresses
+ *	@data_reg: register holding the value for the indirect registers
+ *	@vals: values to write
+ *	@nregs: how many indirect registers to write
+ *	@start_idx: address of first indirect register to write
+ *
+ *	Writes a sequential block of registers that are accessed indirectly
+ *	through an address/data register pair.
+ */
+void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
+		       unsigned int data_reg, const u32 *vals,
+		       unsigned int nregs, unsigned int start_idx)
+{
+	while (nregs--) {
+		t4_write_reg(adap, addr_reg, start_idx++);
+		t4_write_reg(adap, data_reg, *vals++);
+	}
+}
+
+/*
+ * Get the reply to a mailbox command and store it in @rpl in big-endian order.
+ */
+static void get_mbox_rpl(struct adapter *adap, __be64 *rpl, int nflit,
+			 u32 mbox_addr)
+{
+	for ( ; nflit; nflit--, mbox_addr += 8)
+		*rpl++ = cpu_to_be64(t4_read_reg64(adap, mbox_addr));
+}
+
+/*
+ * Handle a FW assertion reported in a mailbox.
+ */
+static void fw_asrt(struct adapter *adap, u32 mbox_addr)
+{
+	struct fw_debug_cmd asrt;
+
+	get_mbox_rpl(adap, (__be64 *)&asrt, sizeof(asrt) / 8, mbox_addr);
+	CH_ALERT(adap, "FW assertion at %.16s:%u, val0 %#x, val1 %#x\n",
+		 asrt.u.assert.filename_0_7, ntohl(asrt.u.assert.line),
+		 ntohl(asrt.u.assert.x), ntohl(asrt.u.assert.y));
+}
+
+static void dump_mbox(struct adapter *adap, int mbox, u32 data_reg)
+{
+	CH_ERR(adap, "mbox %d: %llx %llx %llx %llx %llx %llx %llx %llx\n", mbox,
+	       (unsigned long long)t4_read_reg64(adap, data_reg),
+	       (unsigned long long)t4_read_reg64(adap, data_reg + 8),
+	       (unsigned long long)t4_read_reg64(adap, data_reg + 16),
+	       (unsigned long long)t4_read_reg64(adap, data_reg + 24),
+	       (unsigned long long)t4_read_reg64(adap, data_reg + 32),
+	       (unsigned long long)t4_read_reg64(adap, data_reg + 40),
+	       (unsigned long long)t4_read_reg64(adap, data_reg + 48),
+	       (unsigned long long)t4_read_reg64(adap, data_reg + 56));
+}
+
+/**
+ *	t4_wr_mbox_meat - send a command to FW through the given mailbox
+ *	@adap: the adapter
+ *	@mbox: index of the mailbox to use
+ *	@cmd: the command to write
+ *	@size: command length in bytes
+ *	@rpl: where to optionally store the reply
+ *	@sleep_ok: if true we may sleep while awaiting command completion
+ *
+ *	Sends the given command to FW through the selected mailbox and waits
+ *	for the FW to execute the command.  If @rpl is not %NULL it is used to
+ *	store the FW's reply to the command.  The command and its optional
+ *	reply are of the same length.  FW can take up to %FW_CMD_MAX_TIMEOUT ms
+ *	to respond.  @sleep_ok determines whether we may sleep while awaiting
+ *	the response.  If sleeping is allowed we use progressive backoff
+ *	otherwise we spin.
+ *
+ *	The return value is 0 on success or a negative errno on failure.  A
+ *	failure can happen either because we are not able to execute the
+ *	command or FW executes it but signals an error.  In the latter case
+ *	the return value is the error code indicated by FW (negated).
+ */
+int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
+		    void *rpl, bool sleep_ok)
+{
+	static int delay[] = {
+		1, 1, 3, 5, 10, 10, 20, 50, 100, 200
+	};
+
+	u32 v;
+	u64 res;
+	int i, ms, delay_idx;
+	const __be64 *p = cmd;
+	u32 data_reg = PF_REG(mbox, A_CIM_PF_MAILBOX_DATA);
+	u32 ctl_reg = PF_REG(mbox, A_CIM_PF_MAILBOX_CTRL);
+
+	if ((size & 15) || size > MBOX_LEN)
+		return -EINVAL;
+
+	v = G_MBOWNER(t4_read_reg(adap, ctl_reg));
+	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
+		v = G_MBOWNER(t4_read_reg(adap, ctl_reg));
+
+	if (v != MBOX_OWNER_DRV)
+		return v ? -EBUSY : -ETIMEDOUT;
+
+	for (i = 0; i < size; i += 8)
+		t4_write_reg64(adap, data_reg + i, be64_to_cpu(*p++));
+
+	t4_write_reg(adap, ctl_reg, F_MBMSGVALID | V_MBOWNER(MBOX_OWNER_FW));
+	t4_read_reg(adap, ctl_reg);          /* flush write */
+
+	delay_idx = 0;
+	ms = delay[0];
+
+	for (i = 0; i < FW_CMD_MAX_TIMEOUT; i += ms) {
+		if (sleep_ok) {
+			ms = delay[delay_idx];  /* last element may repeat */
+			if (delay_idx < ARRAY_SIZE(delay) - 1)
+				delay_idx++;
+			msleep(ms);
+		} else
+			mdelay(ms);
+
+		v = t4_read_reg(adap, ctl_reg);
+		if (G_MBOWNER(v) == MBOX_OWNER_DRV) {
+			if (!(v & F_MBMSGVALID)) {
+				t4_write_reg(adap, ctl_reg, 0);
+				continue;
+			}
+
+			res = t4_read_reg64(adap, data_reg);
+			if (G_FW_CMD_OP(res >> 32) == FW_DEBUG_CMD) {
+				fw_asrt(adap, data_reg);
+				res = V_FW_CMD_RETVAL(EIO);
+			} else if (rpl)
+				get_mbox_rpl(adap, rpl, size / 8, data_reg);
+
+			if (G_FW_CMD_RETVAL((int)res))
+				dump_mbox(adap, mbox, data_reg);
+			t4_write_reg(adap, ctl_reg, 0);
+			return -G_FW_CMD_RETVAL((int)res);
+		}
+	}
+
+	dump_mbox(adap, mbox, data_reg);
+	CH_ERR(adap, "command %#x in mailbox %d timed out\n",
+	       *(const u8 *)cmd, mbox);
+	return -ETIMEDOUT;
+}
+
+/**
+ *	t4_mc_read - read from MC through backdoor accesses
+ *	@adap: the adapter
+ *	@addr: address of first byte requested
+ *	@data: 64 bytes of data containing the requested address
+ *	@ecc: where to store the corresponding 64-bit ECC word
+ *
+ *	Read 64 bytes of data from MC starting at a 64-byte-aligned address
+ *	that covers the requested address @addr.  If @parity is not %NULL it
+ *	is assigned the 64-bit ECC word for the read data.
+ */
+int t4_mc_read(struct adapter *adap, u32 addr, __be32 *data, u64 *ecc)
+{
+	int i;
+
+	if (t4_read_reg(adap, A_MC_BIST_CMD) & F_START_BIST)
+		return -EBUSY;
+	t4_write_reg(adap, A_MC_BIST_CMD_ADDR, addr & ~0x3fU);
+	t4_write_reg(adap, A_MC_BIST_CMD_LEN, 64);
+	t4_write_reg(adap, A_MC_BIST_DATA_PATTERN, 0xc);
+	t4_write_reg(adap, A_MC_BIST_CMD, V_BIST_OPCODE(1) | F_START_BIST |
+		     V_BIST_CMD_GAP(1));
+	i = t4_wait_op_done(adap, A_MC_BIST_CMD, F_START_BIST, 0, 10, 1);
+	if (i)
+		return i;
+
+#define MC_DATA(i) MC_BIST_STATUS_REG(A_MC_BIST_STATUS_RDATA, i)
+
+	for (i = 15; i >= 0; i--)
+		*data++ = htonl(t4_read_reg(adap, MC_DATA(i)));
+	if (ecc)
+		*ecc = t4_read_reg64(adap, MC_DATA(16));
+#undef MC_DATA
+	return 0;
+}
+
+/**
+ *	t4_edc_read - read from EDC through backdoor accesses
+ *	@adap: the adapter
+ *	@idx: which EDC to access
+ *	@addr: address of first byte requested
+ *	@data: 64 bytes of data containing the requested address
+ *	@ecc: where to store the corresponding 64-bit ECC word
+ *
+ *	Read 64 bytes of data from EDC starting at a 64-byte-aligned address
+ *	that covers the requested address @addr.  If @parity is not %NULL it
+ *	is assigned the 64-bit ECC word for the read data.
+ */
+int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
+{
+	int i;
+
+	idx *= EDC_STRIDE;
+	if (t4_read_reg(adap, A_EDC_BIST_CMD + idx) & F_START_BIST)
+		return -EBUSY;
+	t4_write_reg(adap, A_EDC_BIST_CMD_ADDR + idx, addr & ~0x3fU);
+	t4_write_reg(adap, A_EDC_BIST_CMD_LEN + idx, 64);
+	t4_write_reg(adap, A_EDC_BIST_DATA_PATTERN + idx, 0xc);
+	t4_write_reg(adap, A_EDC_BIST_CMD + idx,
+		     V_BIST_OPCODE(1) | V_BIST_CMD_GAP(1) | F_START_BIST);
+	i = t4_wait_op_done(adap, A_EDC_BIST_CMD + idx, F_START_BIST, 0, 10, 1);
+	if (i)
+		return i;
+
+#define EDC_DATA(i) (EDC_BIST_STATUS_REG(A_EDC_BIST_STATUS_RDATA, i) + idx)
+
+	for (i = 15; i >= 0; i--)
+		*data++ = htonl(t4_read_reg(adap, EDC_DATA(i)));
+	if (ecc)
+		*ecc = t4_read_reg64(adap, EDC_DATA(16));
+#undef EDC_DATA
+	return 0;
+}
+
+#define VPD_ENTRY(name, len) \
+	u8 name##_kword[2]; u8 name##_len; u8 name##_data[len]
+
+/*
+ * Partial EEPROM Vital Product Data structure.  Includes only the ID and
+ * VPD-R sections.
+ */
+struct t4_vpd {
+	u8  id_tag;
+	u8  id_len[2];
+	u8  id_data[ID_LEN];
+	u8  vpdr_tag;
+	u8  vpdr_len[2];
+	VPD_ENTRY(pn, 16);                     /* part number */
+	VPD_ENTRY(ec, EC_LEN);                 /* EC level */
+	VPD_ENTRY(sn, SERNUM_LEN);             /* serial number */
+	VPD_ENTRY(na, 12);                     /* MAC address base */
+	VPD_ENTRY(port_type, 8);               /* port types */
+	VPD_ENTRY(gpio, 14);                   /* GPIO usage */
+	VPD_ENTRY(cclk, 6);                    /* core clock */
+	VPD_ENTRY(port_addr, 8);               /* port MDIO addresses */
+	VPD_ENTRY(rv, 1);                      /* csum */
+	u32 pad;                  /* for multiple-of-4 sizing and alignment */
+};
+
+#define EEPROM_STAT_ADDR   0x7bfc
+#define VPD_BASE           0
+
+/**
+ *	t4_seeprom_wp - enable/disable EEPROM write protection
+ *	@adapter: the adapter
+ *	@enable: whether to enable or disable write protection
+ *
+ *	Enables or disables write protection on the serial EEPROM.
+ */
+int t4_seeprom_wp(struct adapter *adapter, bool enable)
+{
+	unsigned int v = enable ? 0xc : 0;
+	int ret = pci_write_vpd(adapter->pdev, EEPROM_STAT_ADDR, 4, &v);
+	return ret < 0 ? ret : 0;
+}
+
+/**
+ *	get_vpd_params - read VPD parameters from VPD EEPROM
+ *	@adapter: adapter to read
+ *	@p: where to store the parameters
+ *
+ *	Reads card parameters stored in VPD EEPROM.
+ */
+static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
+{
+	int ret;
+	struct t4_vpd vpd;
+	u8 *q = (u8 *)&vpd, csum;
+
+	ret = pci_read_vpd(adapter->pdev, VPD_BASE, sizeof(vpd), &vpd);
+	if (ret < 0)
+		return ret;
+
+	for (csum = 0; q <= vpd.rv_data; q++)
+		csum += *q;
+
+	if (csum) {
+		CH_ERR(adapter, "corrupted VPD EEPROM, actual csum %u\n", csum);
+		return -EINVAL;
+	}
+
+	p->cclk = simple_strtoul(vpd.cclk_data, NULL, 10);
+	memcpy(p->id, vpd.id_data, sizeof(vpd.id_data));
+	strim(p->id);
+	memcpy(p->ec, vpd.ec_data, sizeof(vpd.ec_data));
+	strim(p->ec);
+	memcpy(p->sn, vpd.sn_data, sizeof(vpd.sn_data));
+	strim(p->sn);
+	return 0;
+}
+
+/* serial flash and firmware constants */
+enum {
+	SF_ATTEMPTS = 10,             /* max retries for SF operations */
+
+	/* flash command opcodes */
+	SF_PROG_PAGE    = 2,          /* program page */
+	SF_WR_DISABLE   = 4,          /* disable writes */
+	SF_RD_STATUS    = 5,          /* read status register */
+	SF_WR_ENABLE    = 6,          /* enable writes */
+	SF_RD_DATA_FAST = 0xb,        /* read flash */
+	SF_ERASE_SECTOR = 0xd8,       /* erase sector */
+
+	FW_START_SEC = 8,             /* first flash sector for FW */
+	FW_END_SEC = 15,              /* last flash sector for FW */
+	FW_IMG_START = FW_START_SEC * SF_SEC_SIZE,
+	FW_MAX_SIZE = (FW_END_SEC - FW_START_SEC + 1) * SF_SEC_SIZE,
+};
+
+/**
+ *	sf1_read - read data from the serial flash
+ *	@adapter: the adapter
+ *	@byte_cnt: number of bytes to read
+ *	@cont: whether another operation will be chained
+ *	@lock: whether to lock SF for PL access only
+ *	@valp: where to store the read data
+ *
+ *	Reads up to 4 bytes of data from the serial flash.  The location of
+ *	the read needs to be specified prior to calling this by issuing the
+ *	appropriate commands to the serial flash.
+ */
+static int sf1_read(struct adapter *adapter, unsigned int byte_cnt, int cont,
+		    int lock, u32 *valp)
+{
+	int ret;
+
+	if (!byte_cnt || byte_cnt > 4)
+		return -EINVAL;
+	if (t4_read_reg(adapter, A_SF_OP) & F_BUSY)
+		return -EBUSY;
+	t4_write_reg(adapter, A_SF_OP,
+		     V_SF_LOCK(lock) | V_CONT(cont) | V_BYTECNT(byte_cnt - 1));
+	ret = t4_wait_op_done(adapter, A_SF_OP, F_BUSY, 0, SF_ATTEMPTS, 5);
+	if (!ret)
+		*valp = t4_read_reg(adapter, A_SF_DATA);
+	return ret;
+}
+
+/**
+ *	sf1_write - write data to the serial flash
+ *	@adapter: the adapter
+ *	@byte_cnt: number of bytes to write
+ *	@cont: whether another operation will be chained
+ *	@lock: whether to lock SF for PL access only
+ *	@val: value to write
+ *
+ *	Writes up to 4 bytes of data to the serial flash.  The location of
+ *	the write needs to be specified prior to calling this by issuing the
+ *	appropriate commands to the serial flash.
+ */
+static int sf1_write(struct adapter *adapter, unsigned int byte_cnt, int cont,
+		     int lock, u32 val)
+{
+	if (!byte_cnt || byte_cnt > 4)
+		return -EINVAL;
+	if (t4_read_reg(adapter, A_SF_OP) & F_BUSY)
+		return -EBUSY;
+	t4_write_reg(adapter, A_SF_DATA, val);
+	t4_write_reg(adapter, A_SF_OP, V_SF_LOCK(lock) |
+		     V_CONT(cont) | V_BYTECNT(byte_cnt - 1) | V_OP(1));
+	return t4_wait_op_done(adapter, A_SF_OP, F_BUSY, 0, SF_ATTEMPTS, 5);
+}
+
+/**
+ *	flash_wait_op - wait for a flash operation to complete
+ *	@adapter: the adapter
+ *	@attempts: max number of polls of the status register
+ *	@delay: delay between polls in ms
+ *
+ *	Wait for a flash operation to complete by polling the status register.
+ */
+static int flash_wait_op(struct adapter *adapter, int attempts, int delay)
+{
+	int ret;
+	u32 status;
+
+	while (1) {
+		if ((ret = sf1_write(adapter, 1, 1, 1, SF_RD_STATUS)) != 0 ||
+		    (ret = sf1_read(adapter, 1, 0, 1, &status)) != 0)
+			return ret;
+		if (!(status & 1))
+			return 0;
+		if (--attempts == 0)
+			return -EAGAIN;
+		if (delay)
+			msleep(delay);
+	}
+}
+
+/**
+ *	t4_read_flash - read words from serial flash
+ *	@adapter: the adapter
+ *	@addr: the start address for the read
+ *	@nwords: how many 32-bit words to read
+ *	@data: where to store the read data
+ *	@byte_oriented: whether to store data as bytes or as words
+ *
+ *	Read the specified number of 32-bit words from the serial flash.
+ *	If @byte_oriented is set the read data is stored as a byte array
+ *	(i.e., big-endian), otherwise as 32-bit words in the platform's
+ *	natural endianess.
+ */
+int t4_read_flash(struct adapter *adapter, unsigned int addr,
+		  unsigned int nwords, u32 *data, int byte_oriented)
+{
+	int ret;
+
+	if (addr + nwords * sizeof(u32) > SF_SIZE || (addr & 3))
+		return -EINVAL;
+
+	addr = swab32(addr) | SF_RD_DATA_FAST;
+
+	if ((ret = sf1_write(adapter, 4, 1, 0, addr)) != 0 ||
+	    (ret = sf1_read(adapter, 1, 1, 0, data)) != 0)
+		return ret;
+
+	for ( ; nwords; nwords--, data++) {
+		ret = sf1_read(adapter, 4, nwords > 1, nwords == 1, data);
+		if (nwords == 1)
+			t4_write_reg(adapter, A_SF_OP, 0);    /* unlock SF */
+		if (ret)
+			return ret;
+		if (byte_oriented)
+			*data = htonl(*data);
+	}
+	return 0;
+}
+
+/**
+ *	t4_write_flash - write up to a page of data to the serial flash
+ *	@adapter: the adapter
+ *	@addr: the start address to write
+ *	@n: length of data to write in bytes
+ *	@data: the data to write
+ *
+ *	Writes up to a page of data (256 bytes) to the serial flash starting
+ *	at the given address.  All the data must be written to the same page.
+ */
+static int t4_write_flash(struct adapter *adapter, unsigned int addr,
+			  unsigned int n, const u8 *data)
+{
+	int ret;
+	u32 buf[64];
+	unsigned int i, c, left, val, offset = addr & 0xff;
+
+	if (addr >= SF_SIZE || offset + n > SF_PAGE_SIZE)
+		return -EINVAL;
+
+	val = swab32(addr) | SF_PROG_PAGE;
+
+	if ((ret = sf1_write(adapter, 1, 0, 1, SF_WR_ENABLE)) != 0 ||
+	    (ret = sf1_write(adapter, 4, 1, 1, val)) != 0)
+		goto unlock;
+
+	for (left = n; left; left -= c) {
+		c = min(left, 4U);
+		for (val = 0, i = 0; i < c; ++i)
+			val = (val << 8) + *data++;
+
+		ret = sf1_write(adapter, c, c != left, 1, val);
+		if (ret)
+			goto unlock;
+	}
+	if ((ret = flash_wait_op(adapter, 5, 1)) != 0)
+		goto unlock;
+
+	t4_write_reg(adapter, A_SF_OP, 0);    /* unlock SF */
+
+	/* Read the page to verify the write succeeded */
+	ret = t4_read_flash(adapter, addr & ~0xff, ARRAY_SIZE(buf), buf, 1);
+	if (ret)
+		return ret;
+
+	if (memcmp(data - n, (u8 *)buf + offset, n)) {
+		CH_ERR(adapter, "failed to correctly write the flash page "
+		       "at %#x\n", addr);
+		return -EIO;
+	}
+	return 0;
+
+unlock:
+	t4_write_reg(adapter, A_SF_OP, 0);    /* unlock SF */
+	return ret;
+}
+
+/**
+ *	t4_get_fw_version - read the firmware version
+ *	@adapter: the adapter
+ *	@vers: where to place the version
+ *
+ *	Reads the FW version from flash.
+ */
+int t4_get_fw_version(struct adapter *adapter, u32 *vers)
+{
+	return t4_read_flash(adapter,
+			     FW_IMG_START + offsetof(struct fw_hdr, fw_ver), 1,
+			     vers, 0);
+}
+
+/**
+ *	t4_get_tp_version - read the TP microcode version
+ *	@adapter: the adapter
+ *	@vers: where to place the version
+ *
+ *	Reads the TP microcode version from flash.
+ */
+int t4_get_tp_version(struct adapter *adapter, u32 *vers)
+{
+	return t4_read_flash(adapter, FW_IMG_START + offsetof(struct fw_hdr,
+							      tp_microcode_ver),
+			     1, vers, 0);
+}
+
+/**
+ *	t4_check_fw_version - check if the FW is compatible with this driver
+ *	@adapter: the adapter
+ *
+ *	Checks if an adapter's FW is compatible with the driver.  Returns 0
+ *	if there's exact match, a negative error if the version could not be
+ *	read or there's a major version mismatch, and a positive value if the
+ *	expected major version is found but there's a minor version mismatch.
+ */
+int t4_check_fw_version(struct adapter *adapter)
+{
+	int ret, major, minor;
+
+	ret = t4_get_fw_version(adapter, &adapter->params.fw_vers);
+	if (!ret)
+		ret = t4_get_tp_version(adapter, &adapter->params.tp_vers);
+	if (ret)
+		return ret;
+
+	major = G_FW_HDR_FW_VER_MAJOR(adapter->params.fw_vers);
+	minor = G_FW_HDR_FW_VER_MINOR(adapter->params.fw_vers);
+
+	if (major != FW_VERSION_MAJOR) {            /* major mismatch - fail */
+		CH_ERR(adapter, "card FW has major version %u, driver wants "
+		       "%u\n", major, FW_VERSION_MAJOR);
+		return -EINVAL;
+	}
+
+	if (minor == FW_VERSION_MINOR)              /* perfect match */
+		return 0;
+
+	/* Minor version mismatch.  Report it but often it can be dealt with. */
+	CH_WARN(adapter, "FW minor version mismatch, found %u.%u, prefer "
+		"%u.%u\n", major, minor, FW_VERSION_MAJOR, FW_VERSION_MINOR);
+	return minor < FW_VERSION_MINOR ? 1 : 2;
+}
+
+/**
+ *	t4_flash_erase_sectors - erase a range of flash sectors
+ *	@adapter: the adapter
+ *	@start: the first sector to erase
+ *	@end: the last sector to erase
+ *
+ *	Erases the sectors in the given inclusive range.
+ */
+static int t4_flash_erase_sectors(struct adapter *adapter, int start, int end)
+{
+	int ret = 0;
+
+	while (start <= end) {
+		if ((ret = sf1_write(adapter, 1, 0, 1, SF_WR_ENABLE)) != 0 ||
+		    (ret = sf1_write(adapter, 4, 0, 1,
+				     SF_ERASE_SECTOR | (start << 8))) != 0 ||
+		    (ret = flash_wait_op(adapter, 5, 500)) != 0) {
+			CH_ERR(adapter, "erase of flash sector %d failed, "
+			       "error %d\n", start, ret);
+			break;
+		}
+		start++;
+	}
+	t4_write_reg(adapter, A_SF_OP, 0);    /* unlock SF */
+	return ret;
+}
+
+/**
+ *	t4_load_fw - download firmware
+ *	@adap: the adapter
+ *	@fw_data: the firmware image to write
+ *	@size: image size
+ *
+ *	Write the supplied firmware image to the card's serial flash.
+ */
+int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
+{
+	u32 csum;
+	__be32 vers;
+	int ret, addr;
+	unsigned int i;
+	u8 first_page[SF_PAGE_SIZE];
+	const u32 *p = (const u32 *)fw_data;
+	struct fw_hdr *hdr = (struct fw_hdr *)fw_data;
+
+	if (!size) {
+		CH_ERR(adap, "FW image has no data\n");
+		return -EINVAL;
+	}
+	if (size & 511) {
+		CH_ERR(adap, "FW image size not multiple of 512 bytes\n");
+		return -EINVAL;
+	}
+	if (ntohs(hdr->len512) * 512 != size) {
+		CH_ERR(adap, "FW image size differs from size in FW header\n");
+		return -EINVAL;
+	}
+	if (size > FW_MAX_SIZE) {
+		CH_ERR(adap, "FW image too large, max is %u bytes\n",
+		       FW_MAX_SIZE);
+		return -EFBIG;
+	}
+
+	for (csum = 0, i = 0; i < size / sizeof(csum); i++)
+		csum += ntohl(p[i]);
+
+	if (csum != 0xffffffff) {
+		CH_ERR(adap, "corrupted firmware image, checksum %#x\n",
+		       csum);
+		return -EINVAL;
+	}
+
+	i = DIV_ROUND_UP(size, SF_SEC_SIZE);        /* # of sectors spanned */
+	ret = t4_flash_erase_sectors(adap, FW_START_SEC, FW_START_SEC + i - 1);
+	if (ret)
+		goto out;
+
+	/*
+	 * We write the correct version at the end so the driver can see a bad
+	 * version if the FW write fails.  Start by writing a copy of the
+	 * first page with a bad version.
+	 */
+	vers = hdr->fw_ver;
+	memcpy(first_page, fw_data, SF_PAGE_SIZE);
+	((struct fw_hdr *)first_page)->fw_ver = htonl(0xffffffff);
+	ret = t4_write_flash(adap, FW_IMG_START, SF_PAGE_SIZE, first_page);
+	if (ret)
+		goto out;
+
+	addr = FW_IMG_START;
+	for (size -= SF_PAGE_SIZE ; size; size -= SF_PAGE_SIZE) {
+		addr += SF_PAGE_SIZE;
+		fw_data += SF_PAGE_SIZE;
+		ret = t4_write_flash(adap, addr, SF_PAGE_SIZE, fw_data);
+		if (ret)
+			goto out;
+	}
+
+	ret = t4_write_flash(adap,
+			     FW_IMG_START + offsetof(struct fw_hdr, fw_ver),
+			     sizeof(vers), (const u8 *)&vers);
+out:
+	if (ret)
+		CH_ERR(adap, "firmware download failed, error %d\n", ret);
+	return ret;
+}
+
+#define ADVERT_MASK (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
+		     FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_ANEG)
+
+/**
+ *	t4_link_start - apply link configuration to MAC/PHY
+ *	@phy: the PHY to setup
+ *	@mac: the MAC to setup
+ *	@lc: the requested link configuration
+ *
+ *	Set up a port's MAC and PHY according to a desired link configuration.
+ *	- If the PHY can auto-negotiate first decide what to advertise, then
+ *	  enable/disable auto-negotiation as desired, and reset.
+ *	- If the PHY does not auto-negotiate just reset it.
+ *	- If auto-negotiation is off set the MAC to the proper speed/duplex/FC,
+ *	  otherwise do it later based on the outcome of auto-negotiation.
+ */
+int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
+		  struct link_config *lc)
+{
+	struct fw_port_cmd c;
+	unsigned int fc = 0, mdi = V_FW_PORT_MDI(FW_PORT_MDI_AUTO);
+
+	lc->link_ok = 0;
+	if (lc->requested_fc & PAUSE_RX)
+		fc |= FW_PORT_CAP_FC_RX;
+	if (lc->requested_fc & PAUSE_TX)
+		fc |= FW_PORT_CAP_FC_TX;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = htonl(V_FW_CMD_OP(FW_PORT_CMD) | F_FW_CMD_REQUEST |
+			       F_FW_CMD_EXEC | V_FW_PORT_CMD_PORTID(port));
+	c.action_to_len16 = htonl(V_FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
+				  FW_LEN16(c));
+
+	if (!(lc->supported & FW_PORT_CAP_ANEG)) {
+		c.u.l1cfg.rcap = htonl((lc->supported & ADVERT_MASK) | fc);
+		lc->fc = lc->requested_fc & (PAUSE_RX | PAUSE_TX);
+	} else if (lc->autoneg == AUTONEG_DISABLE) {
+		c.u.l1cfg.rcap = htonl(lc->requested_speed | fc | mdi);
+		lc->fc = lc->requested_fc & (PAUSE_RX | PAUSE_TX);
+	} else
+		c.u.l1cfg.rcap = htonl(lc->advertising | fc | mdi);
+
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ *	t4_restart_aneg - restart autonegotiation
+ *	@adap: the adapter
+ *	@mbox: mbox to use for the FW command
+ *	@port: the port id
+ *
+ *	Restarts autonegotiation for the selected port.
+ */
+int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port)
+{
+	struct fw_port_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = htonl(V_FW_CMD_OP(FW_PORT_CMD) | F_FW_CMD_REQUEST |
+			       F_FW_CMD_EXEC | V_FW_PORT_CMD_PORTID(port));
+	c.action_to_len16 = htonl(V_FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
+				  FW_LEN16(c));
+	c.u.l1cfg.rcap = htonl(FW_PORT_CAP_ANEG);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ *	t4_set_vlan_accel - configure HW VLAN extraction
+ *	@adap: the adapter
+ *	@ports: bitmap of adapter ports to operate on
+ *	@on: enable (1) or disable (0) HW VLAN extraction
+ *
+ *	Enables or disables HW extraction of VLAN tags for the ports specified
+ *	by @ports.  @ports is a bitmap with the ith bit designating the port
+ *	associated with the ith adapter channel.
+ */
+void t4_set_vlan_accel(struct adapter *adap, unsigned int ports, int on)
+{
+	ports <<= S_VLANEXTENABLEPORT0;
+	t4_set_reg_field(adap, A_TP_OUT_CONFIG, ports, on ? ports : 0);
+}
+
+struct intr_info {
+	unsigned int mask;       /* bits to check in interrupt status */
+	const char *msg;         /* message to print or NULL */
+	short stat_idx;          /* stat counter to increment or -1 */
+	unsigned short fatal;    /* whether the condition reported is fatal */
+};
+
+/**
+ *	t4_handle_intr_status - table driven interrupt handler
+ *	@adapter: the adapter that generated the interrupt
+ *	@reg: the interrupt status register to process
+ *	@acts: table of interrupt actions
+ *	@stats: statistics counters tracking interrupt occurences
+ *
+ *	A table driven interrupt handler that applies a set of masks to an
+ *	interrupt status word and performs the corresponding actions if the
+ *	interrupts described by the mask have occured.  The actions include
+ *	optionally emitting a warning or alert message, and optionally
+ *	incrementing a stat counter.  The table is terminated by an entry
+ *	specifying mask 0.  Returns the number of fatal interrupt conditions.
+ */
+static int t4_handle_intr_status(struct adapter *adapter, unsigned int reg,
+		const struct intr_info *acts, unsigned long *stats)
+{
+	int fatal = 0;
+	unsigned int mask = 0;
+	unsigned int status = t4_read_reg(adapter, reg);
+
+	for ( ; acts->mask; ++acts) {
+		if (!(status & acts->mask)) continue;
+		if (acts->fatal) {
+			fatal++;
+			CH_ALERT(adapter, "%s (0x%x)\n",
+				 acts->msg, status & acts->mask);
+		} else if (acts->msg)
+			CH_WARN_RATELIMIT(adapter, "%s (0x%x)\n",
+					  acts->msg, status & acts->mask);
+		if (acts->stat_idx >= 0)
+			stats[acts->stat_idx]++;
+		mask |= acts->mask;
+	}
+	status &= mask;
+	if (status)                           /* clear processed interrupts */
+		t4_write_reg(adapter, reg, status);
+	return fatal;
+}
+
+/*
+ * Interrupt handler for the PCIE module.
+ */
+static void pcie_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info sysbus_intr_info[] = {
+		{ F_RNPP, "RXNP array parity error", -1, 1 },
+		{ F_RPCP, "RXPC array parity error", -1, 1 },
+		{ F_RCIP, "RXCIF array parity error", -1, 1 },
+		{ F_RCCP, "Rx completions control array parity error", -1, 1 },
+		{ F_RFTP, "RXFT array parity error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info pcie_port_intr_info[] = {
+		{ F_TPCP, "TXPC array parity error", -1, 1 },
+		{ F_TNPP, "TXNP array parity error", -1, 1 },
+		{ F_TFTP, "TXFT array parity error", -1, 1 },
+		{ F_TCAP, "TXCA array parity error", -1, 1 },
+		{ F_TCIP, "TXCIF array parity error", -1, 1 },
+		{ F_RCAP, "RXCA array parity error", -1, 1 },
+		{ F_OTDD, "outbound request TLP discarded", -1, 1 },
+		{ F_RDPE, "Rx data parity error", -1, 1 },
+		{ F_TDUE, "Tx uncorrectable data error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info pcie_intr_info[] = {
+		{ F_MSIADDRLPERR, "MSI AddrL parity error", -1, 1 },
+		{ F_MSIADDRHPERR, "MSI AddrH parity error", -1, 1 },
+		{ F_MSIDATAPERR, "MSI data parity error", -1, 1 },
+		{ F_MSIXADDRLPERR, "MSI-X AddrL parity error", -1, 1 },
+		{ F_MSIXADDRHPERR, "MSI-X AddrH parity error", -1, 1 },
+		{ F_MSIXDATAPERR, "MSI-X data parity error", -1, 1 },
+		{ F_MSIXDIPERR, "MSI-X DI parity error", -1, 1 },
+		{ F_PIOCPLPERR, "PCI PIO completion FIFO parity error", -1, 1 },
+		{ F_PIOREQPERR, "PCI PIO request FIFO parity error", -1, 1 },
+		{ F_TARTAGPERR, "PCI PCI target tag FIFO parity error", -1, 1 },
+		{ F_CCNTPERR, "PCI CMD channel count parity error", -1, 1 },
+		{ F_CREQPERR, "PCI CMD channel request parity error", -1, 1 },
+		{ F_CRSPPERR, "PCI CMD channel response parity error", -1, 1 },
+		{ F_DCNTPERR, "PCI DMA channel count parity error", -1, 1 },
+		{ F_DREQPERR, "PCI DMA channel request parity error", -1, 1 },
+		{ F_DRSPPERR, "PCI DMA channel response parity error", -1, 1 },
+		{ F_HCNTPERR, "PCI HMA channel count parity error", -1, 1 },
+		{ F_HREQPERR, "PCI HMA channel request parity error", -1, 1 },
+		{ F_HRSPPERR, "PCI HMA channel response parity error", -1, 1 },
+		{ F_CFGSNPPERR, "PCI config snoop FIFO parity error", -1, 1 },
+		{ F_FIDPERR, "PCI FID parity error", -1, 1 },
+		{ F_INTXCLRPERR, "PCI INTx clear parity error", -1, 1 },
+		{ F_MATAGPERR, "PCI MA tag parity error", -1, 1 },
+		{ F_PIOTAGPERR, "PCI PIO tag parity error", -1, 1 },
+		{ F_RXCPLPERR, "PCI Rx completion parity error", -1, 1 },
+		{ F_RXWRPERR, "PCI Rx write parity error", -1, 1 },
+		{ F_RPLPERR, "PCI replay buffer parity error", -1, 1 },
+		{ F_PCIESINT, "PCI core secondary fault", -1, 1 },
+		{ F_PCIEPINT, "PCI core primary fault", -1, 1 },
+		{ F_UNXSPLCPLERR, "PCI unexpected split completion error", -1,
+		  0 },
+		{ 0 }
+	};
+
+	int fat;
+
+	fat = t4_handle_intr_status(adapter,
+				    A_PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS,
+				    sysbus_intr_info, NULL) +
+	      t4_handle_intr_status(adapter,
+				    A_PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS,
+				    pcie_port_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_PCIE_INT_CAUSE, pcie_intr_info,
+				    NULL);
+	if (fat)
+		t4_fatal_err(adapter);
+}
+
+/*
+ * TP interrupt handler.
+ */
+static void tp_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info tp_intr_info[] = {
+		{ 0x3fffffff, "TP parity error", -1, 1 },
+		{ F_FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1 },
+		{ 0 }
+	};
+
+	if (t4_handle_intr_status(adapter, A_TP_INT_CAUSE, tp_intr_info, NULL))
+		t4_fatal_err(adapter);
+}
+
+/*
+ * SGE interrupt handler.
+ */
+static void sge_intr_handler(struct adapter *adapter)
+{
+	u64 v;
+
+	static struct intr_info sge_intr_info[] = {
+		{ F_ERR_CPL_EXCEED_IQE_SIZE,
+		  "SGE received CPL exceeding IQE size", -1, 1 },
+		{ F_ERR_INVALID_CIDX_INC,
+		  "SGE GTS CIDX increment too large", -1, 0 },
+		{ F_ERR_CPL_OPCODE_0, "SGE received 0-length CPL", -1, 0 },
+		{ F_ERR_DROPPED_DB, "SGE doorbell dropped", -1, 0 },
+		{ F_ERR_DATA_CPL_ON_HIGH_QID1 | F_ERR_DATA_CPL_ON_HIGH_QID0,
+		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
+		{ F_ERR_BAD_DB_PIDX3, "SGE DBP 3 pidx increment too large", -1,
+		  0 },
+		{ F_ERR_BAD_DB_PIDX2, "SGE DBP 2 pidx increment too large", -1,
+		  0 },
+		{ F_ERR_BAD_DB_PIDX1, "SGE DBP 1 pidx increment too large", -1,
+		  0 },
+		{ F_ERR_BAD_DB_PIDX0, "SGE DBP 0 pidx increment too large", -1,
+		  0 },
+		{ F_ERR_ING_CTXT_PRIO,
+		  "SGE too many priority ingress contexts", -1, 0 },
+		{ F_ERR_EGR_CTXT_PRIO,
+		  "SGE too many priority egress contexts", -1, 0 },
+		{ F_INGRESS_SIZE_ERR, "SGE illegal ingress QID", -1, 0 },
+		{ F_EGRESS_SIZE_ERR, "SGE illegal egress QID", -1, 0 },
+		{ 0 }
+	};
+
+	v = (u64)t4_read_reg(adapter, A_SGE_INT_CAUSE1) |
+	    ((u64)t4_read_reg(adapter, A_SGE_INT_CAUSE2) << 32);
+	if (v) {
+		CH_ALERT(adapter, "SGE parity error (%#llx)\n",
+			 (unsigned long long)v);
+		t4_write_reg(adapter, A_SGE_INT_CAUSE1, v);
+		t4_write_reg(adapter, A_SGE_INT_CAUSE2, v >> 32);
+	}
+
+	if (t4_handle_intr_status(adapter, A_SGE_INT_CAUSE3,
+				  sge_intr_info, NULL) || v)
+		t4_fatal_err(adapter);
+}
+
+#define CIM_OBQ_INTR (F_OBQULP0PARERR | F_OBQULP1PARERR | F_OBQULP2PARERR |\
+		      F_OBQULP3PARERR | F_OBQSGEPARERR | F_OBQNCSIPARERR)
+#define CIM_IBQ_INTR (F_IBQTP0PARERR | F_IBQTP1PARERR | F_IBQULPPARERR |\
+		      F_IBQSGEHIPARERR | F_IBQSGELOPARERR | F_IBQNCSIPARERR)
+
+/*
+ * CIM interrupt handler.
+ */
+static void cim_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info cim_intr_info[] = {
+		{ F_PREFDROPINT, "CIM control register prefetch drop", -1, 1 },
+		{ CIM_OBQ_INTR, "CIM OBQ parity error", -1, 1 },
+		{ CIM_IBQ_INTR, "CIM IBQ parity error", -1, 1 },
+		{ F_MBUPPARERR, "CIM mailbox uP parity error", -1, 1 },
+		{ F_MBHOSTPARERR, "CIM mailbox host parity error", -1, 1 },
+		{ F_TIEQINPARERRINT, "CIM TIEQ outgoing parity error", -1, 1 },
+		{ F_TIEQOUTPARERRINT, "CIM TIEQ incoming parity error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info cim_upintr_info[] = {
+		{ F_RSVDSPACEINT, "CIM reserved space access", -1, 1 },
+		{ F_ILLTRANSINT, "CIM illegal transaction", -1, 1 },
+		{ F_ILLWRINT, "CIM illegal write", -1, 1 },
+		{ F_ILLRDINT, "CIM illegal read", -1, 1 },
+		{ F_ILLRDBEINT, "CIM illegal read BE", -1, 1 },
+		{ F_ILLWRBEINT, "CIM illegal write BE", -1, 1 },
+		{ F_SGLRDBOOTINT, "CIM single read from boot space", -1, 1 },
+		{ F_SGLWRBOOTINT, "CIM single write to boot space", -1, 1 },
+		{ F_BLKWRBOOTINT, "CIM block write to boot space", -1, 1 },
+		{ F_SGLRDFLASHINT, "CIM single read from flash space", -1, 1 },
+		{ F_SGLWRFLASHINT, "CIM single write to flash space", -1, 1 },
+		{ F_BLKWRFLASHINT, "CIM block write to flash space", -1, 1 },
+		{ F_SGLRDEEPROMINT, "CIM single EEPROM read", -1, 1 },
+		{ F_SGLWREEPROMINT, "CIM single EEPROM write", -1, 1 },
+		{ F_BLKRDEEPROMINT, "CIM block EEPROM read", -1, 1 },
+		{ F_BLKWREEPROMINT, "CIM block EEPROM write", -1, 1 },
+		{ F_SGLRDCTLINT , "CIM single read from CTL space", -1, 1 },
+		{ F_SGLWRCTLINT , "CIM single write to CTL space", -1, 1 },
+		{ F_BLKRDCTLINT , "CIM block read from CTL space", -1, 1 },
+		{ F_BLKWRCTLINT , "CIM block write to CTL space", -1, 1 },
+		{ F_SGLRDPLINT , "CIM single read from PL space", -1, 1 },
+		{ F_SGLWRPLINT , "CIM single write to PL space", -1, 1 },
+		{ F_BLKRDPLINT , "CIM block read from PL space", -1, 1 },
+		{ F_BLKWRPLINT , "CIM block write to PL space", -1, 1 },
+		{ F_REQOVRLOOKUPINT , "CIM request FIFO overwrite", -1, 1 },
+		{ F_RSPOVRLOOKUPINT , "CIM response FIFO overwrite", -1, 1 },
+		{ F_TIMEOUTINT , "CIM PIF timeout", -1, 1 },
+		{ F_TIMEOUTMAINT , "CIM PIF MA timeout", -1, 1 },
+		{ 0 }
+        };
+
+	int fat;
+
+	fat = t4_handle_intr_status(adapter, A_CIM_HOST_INT_CAUSE,
+				    cim_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_CIM_HOST_UPACC_INT_CAUSE,
+				    cim_upintr_info, NULL);
+	if (fat)
+		t4_fatal_err(adapter);
+}
+
+/*
+ * ULP RX interrupt handler.
+ */
+static void ulprx_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info ulprx_intr_info[] = {
+		{ 0x7fffff, "ULPRX parity error", -1, 1 },
+		{ 0 }
+        };
+
+	if (t4_handle_intr_status(adapter, A_ULP_RX_INT_CAUSE, ulprx_intr_info,
+				  NULL))
+		t4_fatal_err(adapter);
+}
+
+/*
+ * ULP TX interrupt handler.
+ */
+static void ulptx_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info ulptx_intr_info[] = {
+		{ F_PBL_BOUND_ERR_CH3, "ULPTX channel 3 PBL out of bounds", -1,
+		  0 },
+		{ F_PBL_BOUND_ERR_CH2, "ULPTX channel 2 PBL out of bounds", -1,
+		  0 },
+		{ F_PBL_BOUND_ERR_CH1, "ULPTX channel 1 PBL out of bounds", -1,
+		  0 },
+		{ F_PBL_BOUND_ERR_CH0, "ULPTX channel 0 PBL out of bounds", -1,
+		  0 },
+		{ 0xfffffff, "ULPTX parity error", -1, 1 },
+		{ 0 }
+        };
+
+	if (t4_handle_intr_status(adapter, A_ULP_TX_INT_CAUSE, ulptx_intr_info,
+				  NULL))
+		t4_fatal_err(adapter);
+}
+
+/*
+ * PM TX interrupt handler.
+ */
+static void pmtx_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info pmtx_intr_info[] = {
+		{ F_PCMD_LEN_OVFL0, "PMTX channel 0 pcmd too large", -1, 1 },
+		{ F_PCMD_LEN_OVFL1, "PMTX channel 1 pcmd too large", -1, 1 },
+		{ F_PCMD_LEN_OVFL2, "PMTX channel 2 pcmd too large", -1, 1 },
+		{ F_ZERO_C_CMD_ERROR, "PMTX 0-length pcmd", -1, 1 },
+		{ 0xffffff0, "PMTX framing error", -1, 1 },
+		{ F_OESPI_PAR_ERROR, "PMTX oespi parity error", -1, 1 },
+		{ F_DB_OPTIONS_PAR_ERROR, "PMTX db_options parity error", -1,
+		  1 },
+		{ F_ICSPI_PAR_ERROR, "PMTX icspi parity error", -1, 1 },
+		{ F_C_PCMD_PAR_ERROR, "PMTX c_pcmd parity error", -1, 1},
+		{ 0 }
+        };
+
+	if (t4_handle_intr_status(adapter, A_PM_TX_INT_CAUSE, pmtx_intr_info,
+				  NULL))
+		t4_fatal_err(adapter);
+}
+
+/*
+ * PM RX interrupt handler.
+ */
+static void pmrx_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info pmrx_intr_info[] = {
+		{ F_ZERO_E_CMD_ERROR, "PMRX 0-length pcmd", -1, 1 },
+		{ 0x3ffff0, "PMRX framing error", -1, 1 },
+		{ F_OCSPI_PAR_ERROR, "PMRX ocspi parity error", -1, 1 },
+		{ F_DB_OPTIONS_PAR_ERROR, "PMRX db_options parity error", -1,
+		  1 },
+		{ F_IESPI_PAR_ERROR, "PMRX iespi parity error", -1, 1 },
+		{ F_E_PCMD_PAR_ERROR, "PMRX e_pcmd parity error", -1, 1},
+		{ 0 }
+        };
+
+	if (t4_handle_intr_status(adapter, A_PM_RX_INT_CAUSE, pmrx_intr_info,
+				  NULL))
+		t4_fatal_err(adapter);
+}
+
+/*
+ * CPL switch interrupt handler.
+ */
+static void cplsw_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info cplsw_intr_info[] = {
+		{ F_CIM_OP_MAP_PERR, "CPLSW CIM op_map parity error", -1, 1 },
+		{ F_CIM_OVFL_ERROR, "CPLSW CIM overflow", -1, 1 },
+		{ F_TP_FRAMING_ERROR, "CPLSW TP framing error", -1, 1 },
+		{ F_SGE_FRAMING_ERROR, "CPLSW SGE framing error", -1, 1 },
+		{ F_CIM_FRAMING_ERROR, "CPLSW CIM framing error", -1, 1 },
+		{ F_ZERO_SWITCH_ERROR, "CPLSW no-switch error", -1, 1 },
+		{ 0 }
+        };
+
+	if (t4_handle_intr_status(adapter, A_CPL_INTR_CAUSE, cplsw_intr_info,
+				  NULL))
+		t4_fatal_err(adapter);
+}
+
+/*
+ * LE interrupt handler.
+ */
+static void le_intr_handler(struct adapter *adap)
+{
+	static struct intr_info le_intr_info[] = {
+		{ F_LIPMISS, "LE LIP miss", -1, 0 },
+		{ F_LIP0, "LE 0 LIP error", -1, 0 },
+		{ F_PARITYERR, "LE parity error", -1, 1 },
+		{ F_UNKNOWNCMD, "LE unknown command", -1, 1 },
+		{ F_REQQPARERR, "LE request queue parity error", -1, 1 },
+		{ 0 }
+	};
+
+	if (t4_handle_intr_status(adap, A_LE_DB_INT_CAUSE, le_intr_info, NULL))
+		t4_fatal_err(adap);
+}
+
+/*
+ * MPS interrupt handler.
+ */
+static void mps_intr_handler(struct adapter *adapter)
+{
+	static struct intr_info mps_rx_intr_info[] = {
+		{ 0xffffff, "MPS Rx parity error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info mps_tx_intr_info[] = {
+		{ V_TPFIFO(M_TPFIFO), "MPS Tx TP FIFO parity error", -1, 1 },
+		{ F_NCSIFIFO, "MPS Tx NC-SI FIFO parity error", -1, 1 },
+		{ V_TXDATAFIFO(M_TXDATAFIFO), "MPS Tx data FIFO parity error",
+		  -1, 1 },
+		{ V_TXDESCFIFO(M_TXDESCFIFO), "MPS Tx desc FIFO parity error",
+		  -1, 1 },
+		{ F_BUBBLE, "MPS Tx underflow", -1, 1 },
+		{ F_SECNTERR, "MPS Tx SOP/EOP error", -1, 1 },
+		{ F_FRMERR, "MPS Tx framing error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info mps_trc_intr_info[] = {
+		{ V_FILTMEM(M_FILTMEM), "MPS TRC filter parity error", -1, 1 },
+		{ V_PKTFIFO(M_PKTFIFO), "MPS TRC packet FIFO parity error", -1,
+		  1 },
+		{ F_MISCPERR, "MPS TRC misc parity error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info mps_stat_sram_intr_info[] = {
+		{ 0x1fffff, "MPS statistics SRAM parity error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info mps_stat_tx_intr_info[] = {
+		{ 0xfffff, "MPS statistics Tx FIFO parity error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info mps_stat_rx_intr_info[] = {
+		{ 0xffffff, "MPS statistics Rx FIFO parity error", -1, 1 },
+		{ 0 }
+	};
+	static struct intr_info mps_cls_intr_info[] = {
+		{ F_MATCHSRAM, "MPS match SRAM parity error", -1, 1 },
+		{ F_MATCHTCAM, "MPS match TCAM parity error", -1, 1 },
+		{ F_HASHSRAM, "MPS hash SRAM parity error", -1, 1 },
+		{ 0 }
+	};
+
+	int fat;
+
+	fat = t4_handle_intr_status(adapter, A_MPS_RX_PERR_INT_CAUSE,
+				    mps_rx_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_MPS_TX_INT_CAUSE,
+				    mps_tx_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_MPS_TRC_INT_CAUSE,
+				    mps_trc_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_MPS_STAT_PERR_INT_CAUSE_SRAM,
+				    mps_stat_sram_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_MPS_STAT_PERR_INT_CAUSE_TX_FIFO,
+				    mps_stat_tx_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_MPS_STAT_PERR_INT_CAUSE_RX_FIFO,
+				    mps_stat_rx_intr_info, NULL) +
+	      t4_handle_intr_status(adapter, A_MPS_CLS_INT_CAUSE,
+				    mps_cls_intr_info, NULL);
+
+	t4_write_reg(adapter, A_MPS_INT_CAUSE, F_CLSINT | F_TRCINT |
+		     F_RXINT | F_TXINT | F_STATINT);
+	t4_read_reg(adapter, A_MPS_INT_CAUSE);                    /* flush */
+	if (fat)
+		t4_fatal_err(adapter);
+}
+
+#define MEM_INT_MASK (F_PERR_INT_CAUSE | F_ECC_CE_INT_CAUSE | F_ECC_UE_INT_CAUSE)
+
+/*
+ * EDC/MC interrupt handler.
+ */
+static void mem_intr_handler(struct adapter *adapter, int idx)
+{
+	static const char name[3][5] = { "EDC0", "EDC1", "MC" };
+
+	unsigned int addr, cnt_addr, v;
+
+	if (idx <= MEM_EDC1) {
+		addr = EDC_REG(A_EDC_INT_CAUSE, idx);
+		cnt_addr = EDC_REG(A_EDC_ECC_STATUS, idx);
+	} else {
+		addr = A_MC_INT_CAUSE;
+		cnt_addr = A_MC_ECC_STATUS;
+	}
+
+	v = t4_read_reg(adapter, addr) & MEM_INT_MASK;
+	if (v & F_PERR_INT_CAUSE)
+		CH_ALERT(adapter, "%s FIFO parity error\n", name[idx]);
+	if (v & F_ECC_CE_INT_CAUSE) {
+		u32 cnt = G_ECC_CECNT(t4_read_reg(adapter, cnt_addr));
+
+		t4_write_reg(adapter, cnt_addr, V_ECC_CECNT(M_ECC_CECNT));
+		CH_WARN_RATELIMIT(adapter,
+				  "%u %s correctable ECC data error%s\n",
+				  cnt, name[idx], cnt > 1 ? "s" : "");
+	}
+	if (v & F_ECC_UE_INT_CAUSE)
+		CH_ALERT(adapter, "%s uncorrectable ECC data error\n",
+			 name[idx]);
+
+	t4_write_reg(adapter, addr, v);
+	if (v & (F_PERR_INT_CAUSE | F_ECC_UE_INT_CAUSE))
+		t4_fatal_err(adapter);
+}
+
+/*
+ * MA interrupt handler.
+ */
+static void ma_intr_handler(struct adapter *adapter)
+{
+	u32 v, status = t4_read_reg(adapter, A_MA_INT_CAUSE);
+
+	if (status & F_MEM_PERR_INT_CAUSE)
+		CH_ALERT(adapter, "MA parity error, parity status %#x\n",
+			 t4_read_reg(adapter, A_MA_PARITY_ERROR_STATUS));
+	if (status & F_MEM_WRAP_INT_CAUSE) {
+		v = t4_read_reg(adapter, A_MA_INT_WRAP_STATUS);
+		CH_ALERT(adapter, "MA address wrap-around error by client %u to"
+			 " address %#x\n", G_MEM_WRAP_CLIENT_NUM(v),
+			 G_MEM_WRAP_ADDRESS(v) << 4);
+	}
+	t4_write_reg(adapter, A_MA_INT_CAUSE, status);
+	t4_fatal_err(adapter);
+}
+
+/*
+ * SMB interrupt handler.
+ */
+static void smb_intr_handler(struct adapter *adap)
+{
+	static struct intr_info smb_intr_info[] = {
+		{ F_MSTTXFIFOPARINT, "SMB master Tx FIFO parity error", -1, 1 },
+		{ F_MSTRXFIFOPARINT, "SMB master Rx FIFO parity error", -1, 1 },
+		{ F_SLVFIFOPARINT, "SMB slave FIFO parity error", -1, 1 },
+		{ 0 }
+	};
+
+	if (t4_handle_intr_status(adap, A_SMB_INT_CAUSE, smb_intr_info, NULL))
+		t4_fatal_err(adap);
+}
+
+/*
+ * NC-SI interrupt handler.
+ */
+static void ncsi_intr_handler(struct adapter *adap)
+{
+	static struct intr_info ncsi_intr_info[] = {
+		{ F_CIM_DM_PRTY_ERR, "NC-SI CIM parity error", -1, 1 },
+		{ F_MPS_DM_PRTY_ERR, "NC-SI MPS parity error", -1, 1 },
+		{ F_TXFIFO_PRTY_ERR, "NC-SI Tx FIFO parity error", -1, 1 },
+		{ F_RXFIFO_PRTY_ERR, "NC-SI Rx FIFO parity error", -1, 1 },
+		{ 0 }
+	};
+
+	if (t4_handle_intr_status(adap, A_NCSI_INT_CAUSE, ncsi_intr_info, NULL))
+		t4_fatal_err(adap);
+}
+
+/*
+ * XGMAC interrupt handler.
+ */
+static void xgmac_intr_handler(struct adapter *adap, int port)
+{
+	u32 v = t4_read_reg(adap, PORT_REG(port, A_XGMAC_PORT_INT_CAUSE));
+
+	v &= F_TXFIFO_PRTY_ERR | F_RXFIFO_PRTY_ERR;
+	if (!v)
+		return;
+
+	if (v & F_TXFIFO_PRTY_ERR)
+		CH_ALERT(adap, "XGMAC %d Tx FIFO parity error\n", port);
+	if (v & F_RXFIFO_PRTY_ERR)
+		CH_ALERT(adap, "XGMAC %d Rx FIFO parity error\n", port);
+	t4_write_reg(adap, PORT_REG(port, A_XGMAC_PORT_INT_CAUSE), v);
+	t4_fatal_err(adap);
+}
+
+/*
+ * PL interrupt handler.
+ */
+static void pl_intr_handler(struct adapter *adap)
+{
+	static struct intr_info pl_intr_info[] = {
+		{ F_FATALPERR, "T4 fatal parity error", -1, 1 },
+		{ F_PERRVFID, "PL VFID_MAP parity error", -1, 1 },
+		{ 0 }
+	};
+
+	if (t4_handle_intr_status(adap, A_PL_PL_INT_CAUSE, pl_intr_info, NULL))
+		t4_fatal_err(adap);
+}
+
+#define PF_INTR_MASK (F_PFSW | F_PFCIM)
+#define GLBL_INTR_MASK (F_CIM | F_MPS | F_PL | F_PCIE | F_MC | F_EDC0 | \
+		F_EDC1 | F_LE | F_TP | F_MA | F_PM_TX | F_PM_RX | F_ULP_RX | \
+		F_CPL_SWITCH | F_SGE | F_ULP_TX)
+
+/**
+ *	t4_slow_intr_handler - control path interrupt handler
+ *	@adapter: the adapter
+ *
+ *	T4 interrupt handler for non-data global interrupt events, e.g., errors.
+ *	The designation 'slow' is because it involves register reads, while
+ *	data interrupts typically don't involve any MMIOs.
+ */
+int t4_slow_intr_handler(struct adapter *adapter)
+{
+	u32 cause = t4_read_reg(adapter, A_PL_INT_CAUSE);
+
+	if (!(cause & GLBL_INTR_MASK))
+		return 0;
+	if (cause & F_CIM)
+		cim_intr_handler(adapter);
+	if (cause & F_MPS)
+		mps_intr_handler(adapter);
+	if (cause & F_NCSI)
+		ncsi_intr_handler(adapter);
+	if (cause & F_PL)
+		pl_intr_handler(adapter);
+	if (cause & F_SMB)
+		smb_intr_handler(adapter);
+	if (cause & F_XGMAC0)
+		xgmac_intr_handler(adapter, 0);
+	if (cause & F_XGMAC1)
+		xgmac_intr_handler(adapter, 1);
+	if (cause & F_XGMAC_KR0)
+		xgmac_intr_handler(adapter, 2);
+	if (cause & F_XGMAC_KR1)
+		xgmac_intr_handler(adapter, 3);
+	if (cause & F_PCIE)
+		pcie_intr_handler(adapter);
+	if (cause & F_MC)
+		mem_intr_handler(adapter, MEM_MC);
+	if (cause & F_EDC0)
+		mem_intr_handler(adapter, MEM_EDC0);
+	if (cause & F_EDC1)
+		mem_intr_handler(adapter, MEM_EDC1);
+	if (cause & F_LE)
+		le_intr_handler(adapter);
+	if (cause & F_TP)
+		tp_intr_handler(adapter);
+	if (cause & F_MA)
+		ma_intr_handler(adapter);
+	if (cause & F_PM_TX)
+		pmtx_intr_handler(adapter);
+	if (cause & F_PM_RX)
+		pmrx_intr_handler(adapter);
+	if (cause & F_ULP_RX)
+		ulprx_intr_handler(adapter);
+	if (cause & F_CPL_SWITCH)
+		cplsw_intr_handler(adapter);
+	if (cause & F_SGE)
+		sge_intr_handler(adapter);
+	if (cause & F_ULP_TX)
+		ulptx_intr_handler(adapter);
+
+	/* Clear the interrupts just processed for which we are the master. */
+	t4_write_reg(adapter, A_PL_INT_CAUSE, cause & GLBL_INTR_MASK);
+	(void) t4_read_reg(adapter, A_PL_INT_CAUSE); /* flush */
+	return 1;
+}
+
+/**
+ *	t4_intr_enable - enable interrupts
+ *	@adapter: the adapter whose interrupts should be enabled
+ *
+ *	Enable PF-specific interrupts for the calling function and the top-level
+ *	interrupt concentrator for global interrupts.  Interrupts are already
+ *	enabled at each module,	here we just enable the roots of the interrupt
+ *	hierarchies.
+ *
+ *	Note: this function should be called only when the driver manages
+ *	non PF-specific interrupts from the various HW modules.  Only one PCI
+ *	function at a time should be doing this.
+ */
+void t4_intr_enable(struct adapter *adapter)
+{
+	u32 pf = G_SOURCEPF(t4_read_reg(adapter, A_PL_WHOAMI));
+
+	t4_write_reg(adapter, A_SGE_INT_ENABLE3, F_ERR_CPL_EXCEED_IQE_SIZE |
+		     F_ERR_INVALID_CIDX_INC | F_ERR_CPL_OPCODE_0 |
+		     F_ERR_DROPPED_DB | F_ERR_DATA_CPL_ON_HIGH_QID1 |
+		     F_ERR_DATA_CPL_ON_HIGH_QID0 | F_ERR_BAD_DB_PIDX3 |
+		     F_ERR_BAD_DB_PIDX2 | F_ERR_BAD_DB_PIDX1 |
+		     F_ERR_BAD_DB_PIDX0 | F_ERR_ING_CTXT_PRIO |
+		     F_ERR_EGR_CTXT_PRIO | F_INGRESS_SIZE_ERR |
+		     F_EGRESS_SIZE_ERR);
+	t4_write_reg(adapter, MYPF_REG(A_PL_PF_INT_ENABLE), PF_INTR_MASK);
+	t4_set_reg_field(adapter, A_PL_INT_MAP0, 0, 1 << pf);
+}
+
+/**
+ *	t4_intr_disable - disable interrupts
+ *	@adapter: the adapter whose interrupts should be disabled
+ *
+ *	Disable interrupts.  We only disable the top-level interrupt
+ *	concentrators.  The caller must be a PCI function managing global
+ *	interrupts.
+ */
+void t4_intr_disable(struct adapter *adapter)
+{
+	u32 pf = G_SOURCEPF(t4_read_reg(adapter, A_PL_WHOAMI));
+
+	t4_write_reg(adapter, MYPF_REG(A_PL_PF_INT_ENABLE), 0);
+	t4_set_reg_field(adapter, A_PL_INT_MAP0, 1 << pf, 0);
+}
+
+/**
+ *	t4_intr_clear - clear all interrupts
+ *	@adapter: the adapter whose interrupts should be cleared
+ *
+ *	Clears all interrupts.  The caller must be a PCI function managing
+ *	global interrupts.
+ */
+void t4_intr_clear(struct adapter *adapter)
+{
+	static const unsigned int cause_reg[] = {
+		A_SGE_INT_CAUSE1, A_SGE_INT_CAUSE2, A_SGE_INT_CAUSE3,
+		A_PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS,
+		A_PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS,
+		A_PCIE_NONFAT_ERR, A_PCIE_INT_CAUSE,
+		A_MC_INT_CAUSE,
+		A_MA_INT_WRAP_STATUS, A_MA_PARITY_ERROR_STATUS, A_MA_INT_CAUSE,
+		A_EDC_INT_CAUSE, EDC_REG(A_EDC_INT_CAUSE, 1),
+		A_CIM_HOST_INT_CAUSE, A_CIM_HOST_UPACC_INT_CAUSE,
+		MYPF_REG(A_CIM_PF_HOST_INT_CAUSE),
+		A_TP_INT_CAUSE,
+		A_ULP_RX_INT_CAUSE, A_ULP_TX_INT_CAUSE,
+		A_PM_RX_INT_CAUSE, A_PM_TX_INT_CAUSE,
+		A_MPS_RX_PERR_INT_CAUSE,
+		A_CPL_INTR_CAUSE,
+		MYPF_REG(A_PL_PF_INT_CAUSE),
+		A_PL_PL_INT_CAUSE,
+		A_LE_DB_INT_CAUSE,
+	};
+
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(cause_reg); ++i)
+		t4_write_reg(adapter, cause_reg[i], 0xffffffff);
+
+	t4_write_reg(adapter, A_PL_INT_CAUSE, GLBL_INTR_MASK);
+	(void) t4_read_reg(adapter, A_PL_INT_CAUSE);          /* flush */
+}
+
+/**
+ *	t4_hash_mac_addr - return the hash value of a MAC address
+ *	@addr: the 48-bit Ethernet MAC address
+ *
+ *	Hashes a MAC address according to the hash function used by HW inexact
+ *	(hash) address matching.
+ */
+int t4_hash_mac_addr(const u8 *addr)
+{
+	u32 a = ((u32)addr[0] << 16) | ((u32)addr[1] << 8) | addr[2];
+	u32 b = ((u32)addr[3] << 16) | ((u32)addr[4] << 8) | addr[5];
+	a ^= b;
+	a ^= (a >> 12);
+	a ^= (a >> 6);
+	return a & 0x3f;
+}
+
+/**
+ *	t4_config_rss_range - configure a portion of the RSS mapping table
+ *	@adapter: the adapter
+ *	@mbox: mbox to use for the FW command
+ *	@viid: virtual interface whose RSS subtable is to be written
+ *	@start: start entry in the table to write
+ *	@n: how many table entries to write
+ *	@rspq: values for the response queue lookup table
+ *	@nrspq: number of values in @rspq
+ *
+ *	Programs the selected part of the VI's RSS mapping table with the
+ *	provided values.  If @nrspq < @n the supplied values are used repeatedly
+ *	until the full table range is populated.
+ *
+ *	The caller must ensure the values in @rspq are in the range allowed for
+ *	@viid.
+ */
+int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
+			int start, int n, const u16 *rspq, unsigned int nrspq)
+{
+	int ret;
+	const u16 *rsp = rspq;
+	const u16 *rsp_end = rspq + nrspq;
+	struct fw_rss_ind_tbl_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = htonl(V_FW_CMD_OP(FW_RSS_IND_TBL_CMD) |
+			       F_FW_CMD_REQUEST | F_FW_CMD_WRITE |
+			       V_FW_RSS_IND_TBL_CMD_VIID(viid));
+	cmd.retval_len16 = htonl(FW_LEN16(cmd));
+
+	/* each fw_rss_ind_tbl_cmd takes up to 32 entries */
+	while (n > 0) {
+		int nq = min(n, 32);
+		__be32 *qp = &cmd.iq0_to_iq2;
+
+		cmd.niqid = htons(nq);
+		cmd.startidx = htons(start);
+
+		start += nq;
+		n -= nq;
+
+		while (nq > 0) {
+			unsigned int v;
+
+			v = V_FW_RSS_IND_TBL_CMD_IQ0(*rsp);
+			if (++rsp >= rsp_end)
+				rsp = rspq;
+			v |= V_FW_RSS_IND_TBL_CMD_IQ1(*rsp);
+			if (++rsp >= rsp_end)
+				rsp = rspq;
+			v |= V_FW_RSS_IND_TBL_CMD_IQ2(*rsp);
+			if (++rsp >= rsp_end)
+				rsp = rspq;
+
+			*qp++ = htonl(v);
+			nq -= 3;
+		}
+
+		ret = t4_wr_mbox(adapter, mbox, &cmd, sizeof(cmd), NULL);
+		if (ret != FW_SUCCESS)
+			return ret;
+	}
+	return 0;
+}
+
+/**
+ *	t4_config_glbl_rss - configure the global RSS mode
+ *	@adapter: the adapter
+ *	@mbox: mbox to use for the FW command
+ *	@mode: global RSS mode
+ *	@flags: mode-specific flags
+ *
+ *	Sets the global RSS mode.
+ */
+int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
+		       unsigned int flags)
+{
+	struct fw_rss_glb_config_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_write = htonl(V_FW_CMD_OP(FW_RSS_GLB_CONFIG_CMD) |
+			      F_FW_CMD_REQUEST | F_FW_CMD_WRITE);
+	c.retval_len16 = htonl(FW_LEN16(c));
+	if (mode == FW_RSS_GLB_CONFIG_CMD_MODE_MANUAL) {
+		c.u.manual.mode_pkd = htonl(V_FW_RSS_GLB_CONFIG_CMD_MODE(mode));
+	} else if (mode == FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL) {
+		c.u.basicvirtual.mode_pkd =
+			htonl(V_FW_RSS_GLB_CONFIG_CMD_MODE(mode));
+		c.u.basicvirtual.synmapen_to_hashtoeplitz = htonl(flags);
+	} else
+		return -EINVAL;
+	return t4_wr_mbox(adapter, mbox, &c, sizeof(c), NULL);
+}
+
+/* Read an RSS table row */
+static int rd_rss_row(struct adapter *adap, int row, u32 *val)
+{
+	t4_write_reg(adap, A_TP_RSS_LKP_TABLE, 0xfff00000 | row);
+	return t4_wait_op_done_val(adap, A_TP_RSS_LKP_TABLE, F_LKPTBLROWVLD, 1,
+				   5, 0, val);
+}
+
+/**
+ *	t4_read_rss - read the contents of the RSS mapping table
+ *	@adapter: the adapter
+ *	@map: holds the contents of the RSS mapping table
+ *
+ *	Reads the contents of the RSS hash->queue mapping table.
+ */
+int t4_read_rss(struct adapter *adapter, u16 *map)
+{
+	u32 val;
+	int i, ret;
+
+	for (i = 0; i < RSS_NENTRIES / 2; ++i) {
+		ret = rd_rss_row(adapter, i, &val);
+		if (ret)
+			return ret;
+		*map++ = G_LKPTBLQUEUE0(val);
+		*map++ = G_LKPTBLQUEUE1(val);
+	}
+	return 0;
+}
+
+/**
+ *	t4_tp_get_tcp_stats - read TP's TCP MIB counters
+ *	@adap: the adapter
+ *	@v4: holds the TCP/IP counter values
+ *	@v6: holds the TCP/IPv6 counter values
+ *
+ *	Returns the values of TP's TCP/IP and TCP/IPv6 MIB counters.
+ *	Either @v4 or @v6 may be %NULL to skip the corresponding stats.
+ */
+void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
+			 struct tp_tcp_stats *v6)
+{
+	u32 val[A_TP_MIB_TCP_RXT_SEG_LO - A_TP_MIB_TCP_OUT_RST + 1];
+
+#define STAT_IDX(x) ((A_TP_MIB_TCP_##x) - A_TP_MIB_TCP_OUT_RST)
+#define STAT(x)     val[STAT_IDX(x)]
+#define STAT64(x)   (((u64)STAT(x##_HI) << 32) | STAT(x##_LO))
+
+	if (v4) {
+		t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, val,
+				 ARRAY_SIZE(val), A_TP_MIB_TCP_OUT_RST);
+		v4->tcpOutRsts = STAT(OUT_RST);
+		v4->tcpInSegs  = STAT64(IN_SEG);
+		v4->tcpOutSegs = STAT64(OUT_SEG);
+		v4->tcpRetransSegs = STAT64(RXT_SEG);
+	}
+	if (v6) {
+		t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, val,
+				 ARRAY_SIZE(val), A_TP_MIB_TCP_V6OUT_RST);
+		v6->tcpOutRsts = STAT(OUT_RST);
+		v6->tcpInSegs  = STAT64(IN_SEG);
+		v6->tcpOutSegs = STAT64(OUT_SEG);
+		v6->tcpRetransSegs = STAT64(RXT_SEG);
+	}
+#undef STAT64
+#undef STAT
+#undef STAT_IDX
+}
+
+/**
+ *	t4_tp_get_err_stats - read TP's error MIB counters
+ *	@adap: the adapter
+ *	@st: holds the counter values
+ *
+ *	Returns the values of TP's error counters.
+ */
+void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st)
+{
+	t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, st->macInErrs,
+			 12, A_TP_MIB_MAC_IN_ERR_0);
+	t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, st->tnlCongDrops,
+			 8, A_TP_MIB_TNL_CNG_DROP_0);
+	t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, st->tnlTxDrops,
+			 4, A_TP_MIB_TNL_DROP_0);
+	t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, st->ofldVlanDrops,
+			 4, A_TP_MIB_OFD_VLN_DROP_0);
+	t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, st->tcp6InErrs,
+			 4, A_TP_MIB_TCP_V6IN_ERR_0);
+	t4_read_indirect(adap, A_TP_MIB_INDEX, A_TP_MIB_DATA, &st->ofldNoNeigh,
+			 2, A_TP_MIB_OFD_ARP_DROP);
+}
+
+/**
+ *	t4_read_mtu_tbl - returns the values in the HW path MTU table
+ *	@adap: the adapter
+ *	@mtus: where to store the MTU values
+ *	@mtu_log: where to store the MTU base-2 log (may be %NULL)
+ *
+ *	Reads the HW path MTU table.
+ */
+void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log)
+{
+	u32 v;
+	int i;
+
+	for (i = 0; i < NMTUS; ++i) {
+		t4_write_reg(adap, A_TP_MTU_TABLE,
+			     V_MTUINDEX(0xff) | V_MTUVALUE(i));
+		v = t4_read_reg(adap, A_TP_MTU_TABLE);
+		mtus[i] = G_MTUVALUE(v);
+		if (mtu_log)
+			mtu_log[i] = G_MTUWIDTH(v);
+	}
+}
+
+/**
+ *	init_cong_ctrl - initialize congestion control parameters
+ *	@a: the alpha values for congestion control
+ *	@b: the beta values for congestion control
+ *
+ *	Initialize the congestion control parameters.
+ */
+static void __devinit init_cong_ctrl(unsigned short *a, unsigned short *b)
+{
+	a[0] = a[1] = a[2] = a[3] = a[4] = a[5] = a[6] = a[7] = a[8] = 1;
+	a[9] = 2;
+	a[10] = 3;
+	a[11] = 4;
+	a[12] = 5;
+	a[13] = 6;
+	a[14] = 7;
+	a[15] = 8;
+	a[16] = 9;
+	a[17] = 10;
+	a[18] = 14;
+	a[19] = 17;
+	a[20] = 21;
+	a[21] = 25;
+	a[22] = 30;
+	a[23] = 35;
+	a[24] = 45;
+	a[25] = 60;
+	a[26] = 80;
+	a[27] = 100;
+	a[28] = 200;
+	a[29] = 300;
+	a[30] = 400;
+	a[31] = 500;
+
+	b[0] = b[1] = b[2] = b[3] = b[4] = b[5] = b[6] = b[7] = b[8] = 0;
+	b[9] = b[10] = 1;
+	b[11] = b[12] = 2;
+	b[13] = b[14] = b[15] = b[16] = 3;
+	b[17] = b[18] = b[19] = b[20] = b[21] = 4;
+	b[22] = b[23] = b[24] = b[25] = b[26] = b[27] = 5;
+	b[28] = b[29] = 6;
+	b[30] = b[31] = 7;
+}
+
+/* The minimum additive increment value for the congestion control table */
+#define CC_MIN_INCR 2U
+
+/**
+ *	t4_load_mtus - write the MTU and congestion control HW tables
+ *	@adap: the adapter
+ *	@mtus: the values for the MTU table
+ *	@alpha: the values for the congestion control alpha parameter
+ *	@beta: the values for the congestion control beta parameter
+ *
+ *	Write the HW MTU table with the supplied MTUs and the high-speed
+ *	congestion control table with the supplied alpha, beta, and MTUs.
+ *	We write the two tables together because the additive increments
+ *	depend on the MTUs.
+ */
+void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
+		  const unsigned short *alpha, const unsigned short *beta)
+{
+	static const unsigned int avg_pkts[NCCTRL_WIN] = {
+		2, 6, 10, 14, 20, 28, 40, 56, 80, 112, 160, 224, 320, 448, 640,
+		896, 1281, 1792, 2560, 3584, 5120, 7168, 10240, 14336, 20480,
+		28672, 40960, 57344, 81920, 114688, 163840, 229376
+	};
+
+	unsigned int i, w;
+
+	for (i = 0; i < NMTUS; ++i) {
+		unsigned int mtu = mtus[i];
+		unsigned int log2 = fls(mtu);
+
+		if (!(mtu & ((1 << log2) >> 2)))     /* round */
+			log2--;
+		t4_write_reg(adap, A_TP_MTU_TABLE, V_MTUINDEX(i) |
+			     V_MTUWIDTH(log2) | V_MTUVALUE(mtu));
+
+		for (w = 0; w < NCCTRL_WIN; ++w) {
+			unsigned int inc;
+
+			inc = max(((mtu - 40) * alpha[w]) / avg_pkts[w],
+				  CC_MIN_INCR);
+
+			t4_write_reg(adap, A_TP_CCTRL_TABLE, (i << 21) |
+				     (w << 16) | (beta[w] << 13) | inc);
+		}
+	}
+}
+
+/**
+ *	t4_set_trace_filter - configure one of the tracing filters
+ *	@adap: the adapter
+ *	@tp: the desired trace filter parameters
+ *	@idx: which filter to configure
+ *	@enable: whether to enable or disable the filter
+ *
+ *	Configures one of the tracing filters available in HW.  If @enable is
+ *	%0 @tp is not examined and may be %NULL.
+ */
+int t4_set_trace_filter(struct adapter *adap, const struct trace_params *tp,
+			int idx, int enable)
+{
+	int i, ofst = idx * 4;
+	u32 data_reg, mask_reg, cfg;
+	u32 multitrc = F_TRCMULTIFILTER;
+
+	if (!enable) {
+		t4_write_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A + ofst, 0);
+		goto out;
+	}
+
+	if (tp->port > 11 || tp->invert > 1 || tp->skip_len > M_TFLENGTH ||
+	    tp->skip_ofst > M_TFOFFSET || tp->min_len > M_TFMINPKTSIZE ||
+	    tp->snap_len > 9600 || (idx && tp->snap_len > 256))
+		return -EINVAL;
+
+	if (tp->snap_len > 256) {            /* must be tracer 0 */
+		if ((t4_read_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A + 4) |
+		     t4_read_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A + 8) |
+		     t4_read_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A + 12)) &
+		    F_TFEN)
+			return -EINVAL;  /* other tracers are enabled */
+		multitrc = 0;
+	} else if (idx) {
+		i = t4_read_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_B);
+		if (G_TFCAPTUREMAX(i) > 256 &&
+		    (t4_read_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A) & F_TFEN))
+			return -EINVAL;
+	}
+
+	/* stop the tracer we'll be changing */
+	t4_write_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A + ofst, 0);
+
+	/* disable tracing globally if running in the wrong single/multi mode */
+	cfg = t4_read_reg(adap, A_MPS_TRC_CFG);
+	if ((cfg & F_TRCEN) && multitrc != (cfg & F_TRCMULTIFILTER)) {
+		t4_write_reg(adap, A_MPS_TRC_CFG, cfg ^ F_TRCEN);
+		t4_read_reg(adap, A_MPS_TRC_CFG);                  /* flush */
+		msleep(1);
+		if (!(t4_read_reg(adap, A_MPS_TRC_CFG) & F_TRCFIFOEMPTY))
+			return -ETIMEDOUT;
+	}
+	/*
+	 * At this point either the tracing is enabled and in the right mode or
+	 * disabled.
+	 */
+
+	idx *= (A_MPS_TRC_FILTER1_MATCH - A_MPS_TRC_FILTER0_MATCH);
+	data_reg = A_MPS_TRC_FILTER0_MATCH + idx;
+	mask_reg = A_MPS_TRC_FILTER0_DONT_CARE + idx;
+
+	for (i = 0; i < TRACE_LEN / 4; i++, data_reg += 4, mask_reg += 4) {
+		t4_write_reg(adap, data_reg, tp->data[i]);
+		t4_write_reg(adap, mask_reg, ~tp->mask[i]);
+	}
+	t4_write_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_B + ofst,
+		     V_TFCAPTUREMAX(tp->snap_len) |
+		     V_TFMINPKTSIZE(tp->min_len));
+	t4_write_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A + ofst,
+		     V_TFOFFSET(tp->skip_ofst) | V_TFLENGTH(tp->skip_len) |
+		     V_TFPORT(tp->port) | F_TFEN | V_TFINVERTMATCH(tp->invert));
+
+	cfg &= ~F_TRCMULTIFILTER;
+	t4_write_reg(adap, A_MPS_TRC_CFG, cfg | F_TRCEN | multitrc);
+out:	t4_read_reg(adap, A_MPS_TRC_CFG);  /* flush */
+	return 0;
+}
+
+/**
+ *	t4_get_trace_filter - query one of the tracing filters
+ *	@adap: the adapter
+ *	@tp: the current trace filter parameters
+ *	@idx: which trace filter to query
+ *	@enabled: non-zero if the filter is enabled
+ *
+ *	Returns the current settings of one of the HW tracing filters.
+ */
+void t4_get_trace_filter(struct adapter *adap, struct trace_params *tp, int idx,
+			 int *enabled)
+{
+	u32 ctla, ctlb;
+	int i, ofst = idx * 4;
+	u32 data_reg, mask_reg;
+
+	ctla = t4_read_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_A + ofst);
+	ctlb = t4_read_reg(adap, A_MPS_TRC_FILTER_MATCH_CTL_B + ofst);
+
+	*enabled = !!(ctla & F_TFEN);
+	tp->snap_len = G_TFCAPTUREMAX(ctlb);
+	tp->min_len = G_TFMINPKTSIZE(ctlb);
+	tp->skip_ofst = G_TFOFFSET(ctla);
+	tp->skip_len = G_TFLENGTH(ctla);
+	tp->invert = !!(ctla & F_TFINVERTMATCH);
+	tp->port = G_TFPORT(ctla);
+
+	ofst = (A_MPS_TRC_FILTER1_MATCH - A_MPS_TRC_FILTER0_MATCH) * idx;
+	data_reg = A_MPS_TRC_FILTER0_MATCH + ofst;
+	mask_reg = A_MPS_TRC_FILTER0_DONT_CARE + ofst;
+
+	for (i = 0; i < TRACE_LEN / 4; i++, data_reg += 4, mask_reg += 4) {
+		tp->mask[i] = ~t4_read_reg(adap, mask_reg);
+		tp->data[i] = t4_read_reg(adap, data_reg) & tp->mask[i];
+	}
+}
+
+/**
+ *	get_mps_bg_map - return the buffer groups associated with a port
+ *	@adap: the adapter
+ *	@idx: the port index
+ *
+ *	Returns a bitmap indicating which MPS buffer groups are associated
+ *	with the given port.  Bit i is set if buffer group i is used by the
+ *	port.
+ */
+static unsigned int get_mps_bg_map(struct adapter *adap, int idx)
+{
+	u32 n = G_NUMPORTS(t4_read_reg(adap, A_MPS_CMN_CTL));
+
+	if (n == 0)
+		return idx == 0 ? 0xf : 0;
+	if (n == 1)
+		return idx < 2 ? (3 << (2 * idx)) : 0;
+	return 1 << idx;
+}
+
+/**
+ *	t4_get_port_stats - collect port statistics
+ *	@adap: the adapter
+ *	@idx: the port index
+ *	@p: the stats structure to fill
+ *
+ *	Collect statistics related to the given port from HW.
+ */
+void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
+{
+	u32 bgmap = get_mps_bg_map(adap, idx);
+
+#define GET_STAT(name) \
+	t4_read_reg64(adap, PORT_REG(idx, A_MPS_PORT_STAT_##name##_L))
+#define GET_STAT_COM(name) t4_read_reg64(adap, A_MPS_STAT_##name##_L)
+
+	p->tx_octets           = GET_STAT(TX_PORT_BYTES);
+	p->tx_frames           = GET_STAT(TX_PORT_FRAMES);
+	p->tx_bcast_frames     = GET_STAT(TX_PORT_BCAST);
+	p->tx_mcast_frames     = GET_STAT(TX_PORT_MCAST);
+	p->tx_ucast_frames     = GET_STAT(TX_PORT_UCAST);
+	p->tx_error_frames     = GET_STAT(TX_PORT_ERROR);
+	p->tx_frames_64        = GET_STAT(TX_PORT_64B);
+	p->tx_frames_65_127    = GET_STAT(TX_PORT_65B_127B);
+	p->tx_frames_128_255   = GET_STAT(TX_PORT_128B_255B);
+	p->tx_frames_256_511   = GET_STAT(TX_PORT_256B_511B);
+	p->tx_frames_512_1023  = GET_STAT(TX_PORT_512B_1023B);
+	p->tx_frames_1024_1518 = GET_STAT(TX_PORT_1024B_1518B);
+	p->tx_frames_1519_max  = GET_STAT(TX_PORT_1519B_MAX);
+	p->tx_drop             = GET_STAT(TX_PORT_DROP);
+	p->tx_pause            = GET_STAT(TX_PORT_PAUSE);
+	p->tx_ppp0             = GET_STAT(TX_PORT_PPP0);
+	p->tx_ppp1             = GET_STAT(TX_PORT_PPP1);
+	p->tx_ppp2             = GET_STAT(TX_PORT_PPP2);
+	p->tx_ppp3             = GET_STAT(TX_PORT_PPP3);
+	p->tx_ppp4             = GET_STAT(TX_PORT_PPP4);
+	p->tx_ppp5             = GET_STAT(TX_PORT_PPP5);
+	p->tx_ppp6             = GET_STAT(TX_PORT_PPP6);
+	p->tx_ppp7             = GET_STAT(TX_PORT_PPP7);
+
+	p->rx_octets           = GET_STAT(RX_PORT_BYTES);
+	p->rx_frames           = GET_STAT(RX_PORT_FRAMES);
+	p->rx_bcast_frames     = GET_STAT(RX_PORT_BCAST);
+	p->rx_mcast_frames     = GET_STAT(RX_PORT_MCAST);
+	p->rx_ucast_frames     = GET_STAT(RX_PORT_UCAST);
+	p->rx_too_long         = GET_STAT(RX_PORT_MTU_ERROR);
+	p->rx_jabber           = GET_STAT(RX_PORT_MTU_CRC_ERROR);
+	p->rx_fcs_err          = GET_STAT(RX_PORT_CRC_ERROR);
+	p->rx_len_err          = GET_STAT(RX_PORT_LEN_ERROR);
+	p->rx_symbol_err       = GET_STAT(RX_PORT_SYM_ERROR);
+	p->rx_runt             = GET_STAT(RX_PORT_LESS_64B);
+	p->rx_frames_64        = GET_STAT(RX_PORT_64B);
+	p->rx_frames_65_127    = GET_STAT(RX_PORT_65B_127B);
+	p->rx_frames_128_255   = GET_STAT(RX_PORT_128B_255B);
+	p->rx_frames_256_511   = GET_STAT(RX_PORT_256B_511B);
+	p->rx_frames_512_1023  = GET_STAT(RX_PORT_512B_1023B);
+	p->rx_frames_1024_1518 = GET_STAT(RX_PORT_1024B_1518B);
+	p->rx_frames_1519_max  = GET_STAT(RX_PORT_1519B_MAX);
+	p->rx_pause            = GET_STAT(RX_PORT_PAUSE);
+	p->rx_ppp0             = GET_STAT(RX_PORT_PPP0);
+	p->rx_ppp1             = GET_STAT(RX_PORT_PPP1);
+	p->rx_ppp2             = GET_STAT(RX_PORT_PPP2);
+	p->rx_ppp3             = GET_STAT(RX_PORT_PPP3);
+	p->rx_ppp4             = GET_STAT(RX_PORT_PPP4);
+	p->rx_ppp5             = GET_STAT(RX_PORT_PPP5);
+	p->rx_ppp6             = GET_STAT(RX_PORT_PPP6);
+	p->rx_ppp7             = GET_STAT(RX_PORT_PPP7);
+
+	p->rx_ovflow0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_MAC_DROP_FRAME) : 0;
+	p->rx_ovflow1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_MAC_DROP_FRAME) : 0;
+	p->rx_ovflow2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_MAC_DROP_FRAME) : 0;
+	p->rx_ovflow3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_MAC_DROP_FRAME) : 0;
+	p->rx_trunc0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_MAC_TRUNC_FRAME) : 0;
+	p->rx_trunc1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_MAC_TRUNC_FRAME) : 0;
+	p->rx_trunc2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_MAC_TRUNC_FRAME) : 0;
+	p->rx_trunc3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_MAC_TRUNC_FRAME) : 0;
+
+#undef GET_STAT
+#undef GET_STAT_COM
+}
+
+/**
+ *	t4_get_lb_stats - collect loopback port statistics
+ *	@adap: the adapter
+ *	@idx: the loopback port index
+ *	@p: the stats structure to fill
+ *
+ *	Return HW statistics for the given loopback port.
+ */
+void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p)
+{
+	u32 bgmap = get_mps_bg_map(adap, idx);
+
+#define GET_STAT(name) \
+	t4_read_reg64(adap, PORT_REG(idx, A_MPS_PORT_STAT_LB_PORT_##name##_L))
+#define GET_STAT_COM(name) t4_read_reg64(adap, A_MPS_STAT_##name##_L)
+
+	p->octets           = GET_STAT(BYTES);
+	p->frames           = GET_STAT(FRAMES);
+	p->bcast_frames     = GET_STAT(BCAST);
+	p->mcast_frames     = GET_STAT(MCAST);
+	p->ucast_frames     = GET_STAT(UCAST);
+	p->error_frames     = GET_STAT(ERROR);
+
+	p->frames_64        = GET_STAT(64B);
+	p->frames_65_127    = GET_STAT(65B_127B);
+	p->frames_128_255   = GET_STAT(128B_255B);
+	p->frames_256_511   = GET_STAT(256B_511B);
+	p->frames_512_1023  = GET_STAT(512B_1023B);
+	p->frames_1024_1518 = GET_STAT(1024B_1518B);
+	p->frames_1519_max  = GET_STAT(1519B_MAX);
+	p->drop             = t4_read_reg(adap, PORT_REG(idx,
+					  A_MPS_PORT_STAT_LB_PORT_DROP_FRAMES));
+
+	p->ovflow0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_DROP_FRAME) : 0;
+	p->ovflow1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_DROP_FRAME) : 0;
+	p->ovflow2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_DROP_FRAME) : 0;
+	p->ovflow3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_DROP_FRAME) : 0;
+	p->trunc0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_TRUNC_FRAME) : 0;
+	p->trunc1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_TRUNC_FRAME) : 0;
+	p->trunc2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_TRUNC_FRAME) : 0;
+	p->trunc3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_TRUNC_FRAME) : 0;
+
+#undef GET_STAT
+#undef GET_STAT_COM
+}
+
+/**
+ * 	t4_wol_magic_enable - enable/disable magic packet WoL
+ * 	@adap: the adapter
+ * 	@port: the physical port index
+ * 	@addr: MAC address expected in magic packets, %NULL to disable
+ *
+ * 	Enables/disables magic packet wake-on-LAN for the selected port.
+ */
+void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
+			 const u8 *addr)
+{
+	if (addr) {
+		t4_write_reg(adap, PORT_REG(port, A_XGMAC_PORT_MAGIC_MACID_LO),
+			     (addr[2] << 24) | (addr[3] << 16) |
+			     (addr[4] << 8) | addr[5]);
+		t4_write_reg(adap, PORT_REG(port, A_XGMAC_PORT_MAGIC_MACID_HI),
+			     (addr[0] << 8) | addr[1]);
+	}
+	t4_set_reg_field(adap, PORT_REG(port, A_XGMAC_PORT_CFG2), F_MAGICEN,
+			 V_MAGICEN(addr != NULL));
+}
+
+/**
+ *	t4_wol_pat_enable - enable/disable pattern-based WoL
+ *	@adap: the adapter
+ *	@port: the physical port index
+ *	@map: bitmap of which HW pattern filters to set
+ *	@mask0: byte mask for bytes 0-63 of a packet
+ *	@mask1: byte mask for bytes 64-127 of a packet
+ *	@crc: Ethernet CRC for selected bytes
+ *	@enable: enable/disable switch
+ *
+ *	Sets the pattern filters indicated in @map to mask out the bytes
+ *	specified in @mask0/@mask1 in received packets and compare the CRC of
+ *	the resulting packet against @crc.  If @enable is %true pattern-based
+ *	WoL is enabled, otherwise disabled.
+ */
+int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
+		      u64 mask0, u64 mask1, unsigned int crc, bool enable)
+{
+	int i;
+
+	if (!enable) {
+		t4_set_reg_field(adap, PORT_REG(port, A_XGMAC_PORT_CFG2),
+				 F_PATEN, 0);
+		return 0;
+	}
+	if (map > 0xff)
+		return -EINVAL;
+
+#define EPIO_REG(name) PORT_REG(port, A_XGMAC_PORT_EPIO_##name)
+
+	t4_write_reg(adap, EPIO_REG(DATA1), mask0 >> 32);
+	t4_write_reg(adap, EPIO_REG(DATA2), mask1);
+	t4_write_reg(adap, EPIO_REG(DATA3), mask1 >> 32);
+
+	for (i = 0; i < NWOL_PAT; i++, map >>= 1) {
+		if (!(map & 1))
+			continue;
+
+		/* write byte masks */
+		t4_write_reg(adap, EPIO_REG(DATA0), mask0);
+		t4_write_reg(adap, EPIO_REG(OP), V_ADDRESS(i) | F_EPIOWR);
+		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
+		if (t4_read_reg(adap, EPIO_REG(OP)) & F_BUSY)
+			return -ETIMEDOUT;
+
+		/* write CRC */
+		t4_write_reg(adap, EPIO_REG(DATA0), crc);
+		t4_write_reg(adap, EPIO_REG(OP), V_ADDRESS(i + 32) | F_EPIOWR);
+		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
+		if (t4_read_reg(adap, EPIO_REG(OP)) & F_BUSY)
+			return -ETIMEDOUT;
+	}
+#undef EPIO_REG
+
+	t4_set_reg_field(adap, PORT_REG(port, A_XGMAC_PORT_CFG2), 0, F_PATEN);
+	return 0;
+}
+
+#define INIT_CMD(var, cmd, rd_wr) \
+	(var).op_to_write = htonl(V_FW_CMD_OP(FW_##cmd##_CMD) | \
+				  F_FW_CMD_REQUEST | F_FW_CMD_##rd_wr); \
+	(var).retval_len16 = htonl(FW_LEN16(var))
+
+/**
+ * 	t4_mdio_rd - read a PHY register through MDIO
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@phy_addr: the PHY address
+ * 	@mmd: the PHY MMD to access (0 for clause 22 PHYs)
+ * 	@reg: the register to read
+ * 	@valp: where to store the value
+ *
+ * 	Issues a FW command through the given mailbox to read a PHY register.
+ */
+int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
+	       unsigned int mmd, unsigned int reg, u16 *valp)
+{
+	int ret;
+	struct fw_ldst_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_addrspace = htonl(V_FW_CMD_OP(FW_LDST_CMD) | F_FW_CMD_REQUEST |
+		F_FW_CMD_READ | V_FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
+	c.cycles_to_len16 = htonl(FW_LEN16(c));
+	c.u.mdio.paddr_mmd = htons(V_FW_LDST_CMD_PADDR(phy_addr) |
+				   V_FW_LDST_CMD_MMD(mmd));
+	c.u.mdio.raddr = htons(reg);
+
+	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+	if (ret == 0)
+		*valp = ntohs(c.u.mdio.rval);
+	return ret;
+}
+
+/**
+ * 	t4_mdio_wr - write a PHY register through MDIO
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@phy_addr: the PHY address
+ * 	@mmd: the PHY MMD to access (0 for clause 22 PHYs)
+ * 	@reg: the register to write
+ * 	@valp: value to write
+ *
+ * 	Issues a FW command through the given mailbox to write a PHY register.
+ */
+int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
+	       unsigned int mmd, unsigned int reg, u16 val)
+{
+	struct fw_ldst_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_addrspace = htonl(V_FW_CMD_OP(FW_LDST_CMD) | F_FW_CMD_REQUEST |
+		F_FW_CMD_WRITE | V_FW_LDST_CMD_ADDRSPACE(FW_LDST_ADDRSPC_MDIO));
+	c.cycles_to_len16 = htonl(FW_LEN16(c));
+	c.u.mdio.paddr_mmd = htons(V_FW_LDST_CMD_PADDR(phy_addr) |
+				   V_FW_LDST_CMD_MMD(mmd));
+	c.u.mdio.raddr = htons(reg);
+	c.u.mdio.rval = htons(val);
+
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_fw_hello - establish communication with FW
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@evt_mbox: mailbox to receive async FW events
+ * 	@master: specifies the caller's willingness to be the device master
+ * 	@state: returns the current device state
+ *
+ * 	Issues a command to establish communication with FW.
+ */
+int t4_fw_hello(struct adapter *adap, unsigned int mbox, unsigned int evt_mbox,
+		enum dev_master master, enum dev_state *state)
+{
+	int ret; 
+	struct fw_hello_cmd c;
+
+	INIT_CMD(c, HELLO, WRITE);
+	c.err_to_mbasyncnot = htonl(
+		V_FW_HELLO_CMD_MASTERDIS(master == MASTER_CANT) |
+		V_FW_HELLO_CMD_MASTERFORCE(master == MASTER_MUST) |
+		V_FW_HELLO_CMD_MBMASTER(master == MASTER_MUST ? mbox : 0xff) |
+		V_FW_HELLO_CMD_MBASYNCNOT(evt_mbox));
+
+	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+	if (ret == 0 && state) {
+		u32 v = ntohl(c.err_to_mbasyncnot);
+		if (v & F_FW_HELLO_CMD_INIT)
+			*state = DEV_STATE_INIT;
+		else if (v & F_FW_HELLO_CMD_ERR)
+			*state = DEV_STATE_ERR;
+		else
+			*state = DEV_STATE_UNINIT;
+	}
+	return ret;
+}
+
+/**
+ * 	t4_fw_bye - end communication with FW
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ *
+ * 	Issues a command to terminate communication with FW.
+ */
+int t4_fw_bye(struct adapter *adap, unsigned int mbox)
+{
+	struct fw_bye_cmd c;
+
+	INIT_CMD(c, BYE, WRITE);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_init_cmd - ask FW to initialize the device
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ *
+ * 	Issues a command to FW to partially initialize the device.  This
+ * 	performs initialization that generally doesn't depend on user input.
+ */
+int t4_early_init(struct adapter *adap, unsigned int mbox)
+{
+	struct fw_initialize_cmd c;
+
+	INIT_CMD(c, INITIALIZE, WRITE);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_fw_reset - issue a reset to FW
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@reset: specifies the type of reset to perform
+ *
+ * 	Issues a reset command of the specified type to FW.
+ */
+int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset)
+{
+	struct fw_reset_cmd c;
+
+	INIT_CMD(c, RESET, WRITE);
+	c.val = htonl(reset);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_query_params - query FW or device parameters
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@nparams: the number of parameters
+ * 	@params: the parameter names
+ * 	@val: the parameter values
+ *
+ * 	Reads the value of FW or device parameters.  Up to 7 parameters can be
+ * 	queried at once.
+ */
+int t4_query_params(struct adapter *adap, unsigned int mbox,
+		    unsigned int nparams, const u32 *params, u32 *val)
+{
+	int i, ret;
+	struct fw_params_cmd c;
+	__be32 *p = &c.param[0].mnem;
+
+	if (nparams > 7)
+		return -EINVAL;
+
+	memset(&c, 0, sizeof(c));
+	INIT_CMD(c, PARAMS, READ);
+	for (i = 0; i < nparams; i++, p += 2)
+		*p = htonl(*params++);
+
+	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+	if (ret == 0)
+		for (i = 0, p = &c.param[0].val; i < nparams; i++, p += 2)
+			*val++ = ntohl(*p);
+	return ret;
+}
+
+/**
+ * 	t4_set_params - sets FW or device parameters
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@nparams: the number of parameters
+ * 	@params: the parameter names
+ * 	@val: the parameter values
+ *
+ * 	Sets the value of FW or device parameters.  Up to 7 parameters can be
+ * 	specified at once.
+ */
+int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int nparams,
+		  const u32 *params, const u32 *val)
+{
+	struct fw_params_cmd c;
+	__be32 *p = &c.param[0].mnem;
+
+	if (nparams > 7)
+		return -EINVAL;
+
+	memset(&c, 0, sizeof(c));
+	INIT_CMD(c, PARAMS, WRITE);
+	while (nparams--) {
+		*p++ = htonl(*params++);
+		*p++ = htonl(*val++);
+	}
+
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_cfg_pfvf - configure PF/VF resource limits
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@pf: the PF being configured
+ * 	@vf: the VF being configured
+ * 	@txq: the max number of egress queues
+ * 	@txq_eth_ctrl: the max number of egress Ethernet or control queues
+ * 	@rxqi: the max number of interrupt-capable ingress queues
+ * 	@rxq: the max number of interruptless ingress queues
+ * 	@tc: the PCI traffic class
+ * 	@vi: the max number of virtual interfaces
+ * 	@cmask: the channel access rights mask for the PF/VF
+ * 	@pmask: the port access rights mask for the PF/VF
+ * 	@nexact: the maximum number of exact MPS filters
+ * 	@rcaps: read capabilities
+ * 	@wxcaps: write/execute capabilities
+ *
+ * 	Configures resource limits and capabilities for a physical or virtual
+ * 	function.
+ */
+int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		unsigned int vf, unsigned int txq, unsigned int txq_eth_ctrl,
+		unsigned int rxqi, unsigned int rxq, unsigned int tc,
+		unsigned int vi, unsigned int cmask, unsigned int pmask,
+		unsigned int nexact, unsigned int rcaps, unsigned int wxcaps)
+{
+	struct fw_pfvf_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_PFVF_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_WRITE | V_FW_PFVF_CMD_PFN(pf) |
+			    V_FW_PFVF_CMD_VFN(vf));
+	c.retval_len16 = htonl(FW_LEN16(c));
+	c.niqflint_niq = htonl(V_FW_PFVF_CMD_NIQFLINT(rxqi) |
+			       V_FW_PFVF_CMD_NIQ(rxq));
+	c.cmask_to_neq = htonl(V_FW_PFVF_CMD_CMASK(cmask) |
+			       V_FW_PFVF_CMD_PMASK(pmask) |
+			       V_FW_PFVF_CMD_NEQ(txq));
+	c.tc_to_nexactf = htonl(V_FW_PFVF_CMD_TC(tc) | V_FW_PFVF_CMD_NVI(vi) |
+				V_FW_PFVF_CMD_NEXACTF(nexact));
+	c.r_caps_to_nethctrl = htonl(V_FW_PFVF_CMD_R_CAPS(rcaps) |
+				     V_FW_PFVF_CMD_WX_CAPS(wxcaps) |
+				     V_FW_PFVF_CMD_NETHCTRL(txq_eth_ctrl));
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_alloc_vi - allocate a virtual interface
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@port: physical port associated with the VI
+ * 	@pf: the PF owning the VI
+ * 	@vf: the VF owning the VI
+ * 	@nmac: number of MAC addresses needed (1 to 5)
+ * 	@mac: the MAC addresses of the VI
+ * 	@rss_size: size of RSS table slice associated with this VI
+ *
+ * 	Allocates a virtual interface for the given physical port.  If @mac is
+ * 	not %NULL it contains the MAC addresses of the VI as assigned by FW.
+ * 	@mac should be large enough to hold @nmac Ethernet addresses, they are
+ * 	stored consecutively so the space needed is @nmac * 6 bytes.
+ * 	Returns a negative error number or the non-negative VI id.
+ */
+int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
+		unsigned int pf, unsigned int vf, unsigned int nmac, u8 *mac,
+		unsigned int *rss_size)
+{
+	int ret;
+	struct fw_vi_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_VI_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_WRITE | F_FW_CMD_EXEC |
+			    V_FW_VI_CMD_PFN(pf) | V_FW_VI_CMD_VFN(vf));
+	c.alloc_to_len16 = htonl(F_FW_VI_CMD_ALLOC | FW_LEN16(c));
+	c.portid_pkd = V_FW_VI_CMD_PORTID(port);
+	c.nmac = nmac - 1;
+
+	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+	if (ret)
+		return ret;
+
+       	if (mac) {
+		memcpy(mac, c.mac, sizeof(c.mac));
+		switch (nmac) {
+			case 5: memcpy(mac + 24, c.nmac3, sizeof(c.nmac3));
+			case 4: memcpy(mac + 18, c.nmac2, sizeof(c.nmac2));
+			case 3: memcpy(mac + 12, c.nmac1, sizeof(c.nmac1));
+			case 2: memcpy(mac + 6,  c.nmac0, sizeof(c.nmac0));
+		}
+	}
+	if (rss_size)
+		*rss_size = G_FW_VI_CMD_RSSSIZE(ntohs(c.rsssize_pkd));
+	return ntohs(c.viid_pkd);
+}
+
+/**
+ * 	t4_free_vi - free a virtual interface
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@pf: the PF owning the VI
+ * 	@vf: the VF owning the VI
+ * 	@viid: virtual interface identifiler
+ *
+ * 	Free a previously allocated virtual interface.
+ */
+int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
+	       unsigned int vf, unsigned int viid)
+{
+	struct fw_vi_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_VI_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_EXEC | V_FW_VI_CMD_PFN(pf) |
+			    V_FW_VI_CMD_VFN(vf));
+	c.alloc_to_len16 = htonl(F_FW_VI_CMD_FREE | FW_LEN16(c));
+	c.viid_pkd = htons(V_FW_VI_CMD_VIID(viid));
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+}
+
+/**
+ * 	t4_set_rxmode - set Rx properties of a virtual interface
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@viid: the VI id
+ * 	@mtu: the new MTU or -1
+ * 	@promisc: 1 to enable promiscuous mode, 0 to disable it, -1 no change
+ * 	@all_multi: 1 to enable all-multi mode, 0 to disable it, -1 no change
+ * 	@bcast: 1 to enable broadcast Rx, 0 to disable it, -1 no change
+ * 	@sleep_ok: if true we may sleep while awaiting command completion
+ *
+ * 	Sets Rx properties of a virtual interface.
+ */
+int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		  int mtu, int promisc, int all_multi, int bcast, bool sleep_ok)
+{
+	struct fw_vi_rxmode_cmd c;
+
+	/* convert to FW values */
+	if (mtu < 0)
+		mtu = M_FW_VI_RXMODE_CMD_MTU;
+	if (promisc < 0)
+		promisc = M_FW_VI_RXMODE_CMD_PROMISCEN;
+	if (all_multi < 0)
+		all_multi = M_FW_VI_RXMODE_CMD_ALLMULTIEN;
+	if (bcast < 0)
+		bcast = M_FW_VI_RXMODE_CMD_BROADCASTEN;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_viid = htonl(V_FW_CMD_OP(FW_VI_RXMODE_CMD) | F_FW_CMD_REQUEST |
+			     F_FW_CMD_WRITE | V_FW_VI_RXMODE_CMD_VIID(viid));
+	c.retval_len16 = htonl(FW_LEN16(c));
+	c.mtu_to_broadcasten = htonl(V_FW_VI_RXMODE_CMD_MTU(mtu) |
+				     V_FW_VI_RXMODE_CMD_PROMISCEN(promisc) |
+				     V_FW_VI_RXMODE_CMD_ALLMULTIEN(all_multi) |
+				     V_FW_VI_RXMODE_CMD_BROADCASTEN(bcast));
+	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
+}
+
+/**
+ * 	t4_alloc_mac_filt - allocates exact-match filters for MAC addresses
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@viid: the VI id
+ * 	@free: if true any existing filters for this VI id are first removed
+ * 	@naddr: the number of MAC addresses to allocate filters for (up to 7)
+ * 	@addr: the MAC address(es)
+ * 	@idx: where to store the index of each allocated filter
+ * 	@hash: pointer to hash address filter bitmap
+ * 	@sleep_ok: call is allowed to sleep
+ *
+ * 	Allocates an exact-match filter for each of the supplied addresses and
+ * 	sets it to the corresponding address.  If @idx is not %NULL it should
+ * 	have at least @naddr entries, each of which will be set to the index of
+ * 	the filter allocated for the corresponding MAC address.  If a filter
+ * 	could not be allocated for an address its index is set to 0xffff.
+ * 	If @hash is not %NULL addresses that fail to allocate an exact filter
+ * 	are hashed and update the hash filter bitmap pointed at by @hash.
+ *
+ * 	Returns a negative error number or the number of filters allocated.
+ */
+int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
+		      unsigned int viid, bool free, unsigned int naddr,
+		      const u8 **addr, u16 *idx, u64 *hash, bool sleep_ok)
+{
+	int i, ret;
+	struct fw_vi_mac_cmd c;
+	struct fw_vi_mac_exact *p;
+
+	if (naddr > 7)
+		return -EINVAL;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_viid = htonl(V_FW_CMD_OP(FW_VI_MAC_CMD) | F_FW_CMD_REQUEST |
+			     F_FW_CMD_WRITE | V_FW_CMD_EXEC(free) |
+			     V_FW_VI_MAC_CMD_VIID(viid));
+	c.freemacs_to_len16 = htonl(V_FW_VI_MAC_CMD_FREEMACS(free) |
+				    V_FW_CMD_LEN16((naddr + 2) / 2));
+
+	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
+		p->valid_to_idx = htons(F_FW_VI_MAC_CMD_VALID |
+				      V_FW_VI_MAC_CMD_IDX(FW_VI_MAC_ADD_MAC));
+		memcpy(p->macaddr, addr[i], sizeof(p->macaddr));
+	}
+
+	ret = t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), &c, sleep_ok);
+	if (ret)
+		return ret;
+
+	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
+		u16 index = G_FW_VI_MAC_CMD_IDX(ntohs(p->valid_to_idx));
+
+		if (idx)
+			idx[i] = index >= NEXACT_MAC ? 0xffff : index;
+		if (index < NEXACT_MAC)
+			ret++;
+		else if (hash)
+			*hash |= (1 << t4_hash_mac_addr(addr[i]));
+	}
+	return ret;
+}
+
+/**
+ * 	t4_change_mac - modifies the exact-match filter for a MAC address
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@viid: the VI id
+ * 	@idx: index of existing filter for old value of MAC address, or -1
+ * 	@addr: the new MAC address value
+ * 	@persist: whether a new MAC allocation should be persistent
+ *
+ *	Modifies an exact-match filter and sets it to the new MAC address.
+ *	Note that in general it is not possible to modify the value of a given
+ *	filter so the generic way to modify an address filter is to free the one
+ *	being used by the old address value and allocate a new filter for the
+ *	new address value.  @idx can be -1 if the address is a new addition.
+ *
+ * 	Returns a negative error number or the index of the filter with the new
+ * 	MAC value.
+ */
+int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		  int idx, const u8 *addr, bool persist)
+{
+	int ret;
+	struct fw_vi_mac_cmd c;
+	struct fw_vi_mac_exact *p = c.u.exact;
+
+	if (idx < 0)                             /* new allocation */
+		idx = persist ? FW_VI_MAC_ADD_PERSIST_MAC : FW_VI_MAC_ADD_MAC;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_viid = htonl(V_FW_CMD_OP(FW_VI_MAC_CMD) | F_FW_CMD_REQUEST |
+			     F_FW_CMD_WRITE | V_FW_VI_MAC_CMD_VIID(viid));
+	c.freemacs_to_len16 = htonl(V_FW_CMD_LEN16(1));
+	p->valid_to_idx = htons(F_FW_VI_MAC_CMD_VALID |
+				V_FW_VI_MAC_CMD_IDX(idx));
+	memcpy(p->macaddr, addr, sizeof(p->macaddr));
+
+	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+	if (ret == 0) {
+		ret = G_FW_VI_MAC_CMD_IDX(ntohs(p->valid_to_idx));
+		if (ret >= NEXACT_MAC)
+			ret = -ENOMEM;
+	}
+	return ret;
+}
+
+/**
+ * 	t4_set_addr_hash - program the MAC inexact-match hash filter
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@viid: the VI id
+ * 	@ucast: whether the hash filter should also match unicast addresses
+ * 	@vec: the value to be written to the hash filter
+ * 	@sleep_ok: call is allowed to sleep
+ *
+ * 	Sets the 64-bit inexact-match hash filter for a virtual interface.
+ */
+int t4_set_addr_hash(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		     bool ucast, u64 vec, bool sleep_ok)
+{
+	struct fw_vi_mac_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_viid = htonl(V_FW_CMD_OP(FW_VI_MAC_CMD) | F_FW_CMD_REQUEST |
+			     F_FW_CMD_WRITE | V_FW_VI_ENABLE_CMD_VIID(viid));
+	c.freemacs_to_len16 = htonl(F_FW_VI_MAC_CMD_HASHVECEN |
+				    V_FW_VI_MAC_CMD_HASHUNIEN(ucast) |
+				    V_FW_CMD_LEN16(1));
+	c.u.hash.hashvec = cpu_to_be64(vec);
+	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
+}
+
+/**
+ * 	t4_enable_vi - enable/disable a virtual interface
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@viid: the VI id
+ * 	@rx_en: 1=enable Rx, 0=disable Rx
+ * 	@tx_en: 1=enable Tx, 0=disable Tx
+ *
+ * 	Enables/disables a virtual interface.
+ */
+int t4_enable_vi(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		 bool rx_en, bool tx_en)
+{
+	struct fw_vi_enable_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_viid = htonl(V_FW_CMD_OP(FW_VI_ENABLE_CMD) | F_FW_CMD_REQUEST |
+			     F_FW_CMD_EXEC | V_FW_VI_ENABLE_CMD_VIID(viid));
+	c.ien_to_len16 = htonl(V_FW_VI_ENABLE_CMD_IEN(rx_en) |
+			       V_FW_VI_ENABLE_CMD_EEN(tx_en) | FW_LEN16(c));
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_identify_port - identify a VI's port by blinking its LED
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@viid: the VI id
+ * 	@nblinks: how many times to blink LED at 2.5 Hz
+ *
+ * 	Identifies a VI's port by blinking its LED.
+ */
+int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		     unsigned int nblinks)
+{
+	struct fw_vi_enable_cmd c;
+
+	c.op_to_viid = htonl(V_FW_CMD_OP(FW_VI_ENABLE_CMD) | F_FW_CMD_REQUEST |
+			     F_FW_CMD_EXEC | V_FW_VI_ENABLE_CMD_VIID(viid));
+	c.ien_to_len16 = htonl(F_FW_VI_ENABLE_CMD_LED | FW_LEN16(c));
+	c.blinkdur = htons(nblinks);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_iq_start_stop - enable/disable an ingress queue and its FLs
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@start: %true to enable the queues, %false to disable them
+ * 	@pf: the PF owning the queues
+ * 	@vf: the VF owning the queues
+ * 	@iqid: ingress queue id
+ * 	@fl0id: FL0 queue id or 0xffff if no attached FL0
+ * 	@fl1id: FL1 queue id or 0xffff if no attached FL1
+ *
+ * 	Starts or stops an ingress queue and its associated FLs, if any.
+ */
+int t4_iq_start_stop(struct adapter *adap, unsigned int mbox, bool start,
+		     unsigned int pf, unsigned int vf, unsigned int iqid,
+		     unsigned int fl0id, unsigned int fl1id)
+{
+	struct fw_iq_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_IQ_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_EXEC | V_FW_IQ_CMD_PFN(pf) |
+			    V_FW_IQ_CMD_VFN(vf));
+	c.alloc_to_len16 = htonl(V_FW_IQ_CMD_IQSTART(start) |
+				 V_FW_IQ_CMD_IQSTOP(!start) | FW_LEN16(c));
+	c.iqid = htons(iqid);
+	c.fl0id = htons(fl0id);
+	c.fl1id = htons(fl1id);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_iq_free - free an ingress queue and its FLs
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@pf: the PF owning the queues
+ * 	@vf: the VF owning the queues
+ * 	@iqtype: the ingress queue type
+ * 	@iqid: ingress queue id
+ * 	@fl0id: FL0 queue id or 0xffff if no attached FL0
+ * 	@fl1id: FL1 queue id or 0xffff if no attached FL1
+ *
+ * 	Frees an ingress queue and its associated FLs, if any.
+ */
+int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
+	       unsigned int fl0id, unsigned int fl1id)
+{
+	struct fw_iq_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_IQ_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_EXEC | V_FW_IQ_CMD_PFN(pf) |
+			    V_FW_IQ_CMD_VFN(vf));
+	c.alloc_to_len16 = htonl(F_FW_IQ_CMD_FREE | FW_LEN16(c));
+	c.type_to_iqandstindex = htonl(V_FW_IQ_CMD_TYPE(iqtype));
+	c.iqid = htons(iqid);
+	c.fl0id = htons(fl0id);
+	c.fl1id = htons(fl1id);
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_eth_eq_free - free an Ethernet egress queue
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@pf: the PF owning the queue
+ * 	@vf: the VF owning the queue
+ * 	@eqid: egress queue id
+ *
+ * 	Frees an Ethernet egress queue.
+ */
+int t4_eth_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		   unsigned int vf, unsigned int eqid)
+{
+	struct fw_eq_eth_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_EQ_ETH_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_EXEC | V_FW_EQ_ETH_CMD_PFN(pf) |
+			    V_FW_EQ_ETH_CMD_VFN(vf));
+	c.alloc_to_len16 = htonl(F_FW_EQ_ETH_CMD_FREE | FW_LEN16(c));
+	c.eqid_pkd = htonl(V_FW_EQ_ETH_CMD_EQID(eqid));
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_ctrl_eq_free - free a control egress queue
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@pf: the PF owning the queue
+ * 	@vf: the VF owning the queue
+ * 	@eqid: egress queue id
+ *
+ * 	Frees a control egress queue.
+ */
+int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		    unsigned int vf, unsigned int eqid)
+{
+	struct fw_eq_ctrl_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_EQ_CTRL_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_EXEC | V_FW_EQ_CTRL_CMD_PFN(pf) |
+			    V_FW_EQ_CTRL_CMD_VFN(vf));
+	c.alloc_to_len16 = htonl(F_FW_EQ_CTRL_CMD_FREE | FW_LEN16(c));
+	c.cmpliqid_eqid = htonl(V_FW_EQ_CTRL_CMD_EQID(eqid));
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_ofld_eq_free - free an offload egress queue
+ * 	@adap: the adapter
+ * 	@mbox: mailbox to use for the FW command
+ * 	@pf: the PF owning the queue
+ * 	@vf: the VF owning the queue
+ * 	@eqid: egress queue id
+ *
+ * 	Frees a control egress queue.
+ */
+int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		    unsigned int vf, unsigned int eqid)
+{
+	struct fw_eq_ofld_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_vfn = htonl(V_FW_CMD_OP(FW_EQ_OFLD_CMD) | F_FW_CMD_REQUEST |
+			    F_FW_CMD_EXEC | V_FW_EQ_OFLD_CMD_PFN(pf) |
+			    V_FW_EQ_OFLD_CMD_VFN(vf));
+	c.alloc_to_len16 = htonl(F_FW_EQ_OFLD_CMD_FREE | FW_LEN16(c));
+	c.eqid_pkd = htonl(V_FW_EQ_OFLD_CMD_EQID(eqid));
+	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
+}
+
+/**
+ * 	t4_handle_fw_rpl - process a FW reply message
+ * 	@adap: the adapter
+ * 	@rpl: start of the FW message
+ *
+ * 	Processes a FW message, such as link state change messages.
+ */
+int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl)
+{
+	u8 opcode = *(const u8 *)rpl;
+
+	if (opcode == FW_PORT_CMD) {    /* link/module state change message */
+		int speed = 0, fc = 0;
+		const struct fw_port_cmd *p = (void *)rpl;
+		int chan = G_FW_PORT_CMD_PORTID(ntohl(p->op_to_portid));
+		int port = adap->chan_map[chan];
+		struct port_info *pi = adap2pinfo(adap, port);
+		struct link_config *lc = &pi->link_cfg;
+		u32 stat = ntohl(p->u.info.lstatus_to_modtype);
+		int link_ok = (stat & F_FW_PORT_CMD_LSTATUS) != 0;
+		u32 mod = G_FW_PORT_CMD_MODTYPE(stat);
+
+		if (stat & F_FW_PORT_CMD_RXPAUSE)
+			fc |= PAUSE_RX;
+		if (stat & F_FW_PORT_CMD_TXPAUSE)
+			fc |= PAUSE_TX;
+		if (stat & V_FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_100M))
+			speed = SPEED_100;
+		else if (stat & V_FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_1G))
+			speed = SPEED_1000;
+		else if (stat & V_FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_10G))
+			speed = SPEED_10000;
+
+		if (link_ok != lc->link_ok || speed != lc->speed ||
+		    fc != lc->fc) {                    /* something changed */
+			lc->link_ok = link_ok;
+			lc->speed = speed;
+			lc->fc = fc;
+			t4_os_link_changed(adap, port, link_ok);
+		}
+		if (mod != pi->mod_type) {
+			pi->mod_type = mod;
+			t4_os_portmod_changed(adap, port);
+		}
+	}
+	return 0;
+}
+
+/**
+ *	get_pci_mode - determine a card's PCI mode
+ *	@adapter: the adapter
+ *	@p: where to store the PCI settings
+ *
+ *	Determines a card's PCI mode and associated parameters, such as speed
+ *	and width.
+ */
+static void __devinit get_pci_mode(struct adapter *adapter,
+				   struct pci_params *p)
+{
+	u16 val;
+	u32 pcie_cap;
+
+	pcie_cap = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	if (pcie_cap) {
+		pci_read_config_word(adapter->pdev, pcie_cap + PCI_EXP_LNKSTA,
+				     &val);
+		p->speed = val & PCI_EXP_LNKSTA_CLS;
+		p->width = (val & PCI_EXP_LNKSTA_NLW) >> 4;
+	}
+}
+
+/**
+ *	init_link_config - initialize a link's SW state
+ *	@lc: structure holding the link state
+ *	@caps: link capabilities
+ *
+ *	Initializes the SW state maintained for each link, including the link's
+ *	capabilities and default speed/flow-control/autonegotiation settings.
+ */
+static void __devinit init_link_config(struct link_config *lc,
+				       unsigned int caps)
+{
+	lc->supported = caps;
+	lc->requested_speed = 0;
+	lc->speed = 0;
+	lc->requested_fc = lc->fc = PAUSE_RX | PAUSE_TX;
+	if (lc->supported & FW_PORT_CAP_ANEG) {
+		lc->advertising = lc->supported & ADVERT_MASK;
+		lc->autoneg = AUTONEG_ENABLE;
+		lc->requested_fc |= PAUSE_AUTONEG;
+	} else {
+		lc->advertising = 0;
+		lc->autoneg = AUTONEG_DISABLE;
+	}
+}
+
+static int __devinit wait_dev_ready(struct adapter *adap)
+{
+	if (t4_read_reg(adap, A_PL_WHOAMI) != 0xffffffff)
+		return 0;
+	msleep(500);
+	return t4_read_reg(adap, A_PL_WHOAMI) != 0xffffffff ? 0 : -EIO;
+}
+
+/**
+ *	t4_prep_adapter - prepare SW and HW for operation
+ *	@adapter: the adapter
+ *	@reset: if true perform a HW reset
+ *
+ *	Initialize adapter SW state for the various HW modules, set initial
+ *	values for some adapter tunables, take PHYs out of reset, and
+ *	initialize the MDIO interface.
+ */
+int __devinit t4_prep_adapter(struct adapter *adapter)
+{
+	int ret;
+
+	ret = wait_dev_ready(adapter);
+	if (ret < 0)
+		return ret;
+
+	get_pci_mode(adapter, &adapter->params.pci);
+	adapter->params.rev = t4_read_reg(adapter, A_PL_REV);
+
+	ret = get_vpd_params(adapter, &adapter->params.vpd);
+	if (ret < 0)
+		return ret;
+
+	init_cong_ctrl(adapter->params.a_wnd, adapter->params.b_wnd);
+
+	/*
+	 * Default port for debugging in case we can't reach FW.
+	 */
+	adapter->params.nports = 1;
+	adapter->params.portvec = 1;
+	return 0;
+}
+
+int __devinit t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
+{
+	u8 addr[6];
+	int ret, i, j = 0;
+	struct fw_port_cmd c;
+
+	memset(&c, 0, sizeof(c));
+
+	for_each_port(adap, i) {
+		unsigned int rss_size;
+		struct port_info *p = adap2pinfo(adap, i);
+
+		while ((adap->params.portvec & (1 << j)) == 0)
+			j++;
+
+		c.op_to_portid = htonl(V_FW_CMD_OP(FW_PORT_CMD) |
+				       F_FW_CMD_REQUEST | F_FW_CMD_READ |
+				       V_FW_PORT_CMD_PORTID(j));
+		c.action_to_len16 = htonl(
+			V_FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
+			FW_LEN16(c));
+		ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+		if (ret)
+			return ret;
+
+		ret = t4_alloc_vi(adap, mbox, j, pf, vf, 1, addr, &rss_size);
+		if (ret < 0)
+			return ret;
+
+		p->viid = ret;
+		p->tx_chan = j;
+		p->lport = j;
+		p->rss_size = rss_size;
+		memcpy(adap->port[i]->dev_addr, addr, ETH_ALEN);
+		memcpy(adap->port[i]->perm_addr, addr, ETH_ALEN);
+
+		ret = ntohl(c.u.info.lstatus_to_modtype);
+		p->mdio_addr = (ret & F_FW_PORT_CMD_MDIOCAP) ?
+			G_FW_PORT_CMD_MDIOADDR(ret) : -1;
+		p->port_type = G_FW_PORT_CMD_PTYPE(ret);
+		p->mod_type = G_FW_PORT_CMD_MODTYPE(ret);
+
+		init_link_config(&p->link_cfg, ntohs(c.u.info.pcap));
+		j++;
+	}
+	return 0;
+}
diff --git a/drivers/net/cxgb4/t4_hw.h b/drivers/net/cxgb4/t4_hw.h
new file mode 100644
index 0000000..9e2228a
--- /dev/null
+++ b/drivers/net/cxgb4/t4_hw.h
@@ -0,0 +1,129 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __T4_HW_H
+#define __T4_HW_H
+
+#include <linux/types.h>
+
+enum {
+	NCHAN          = 4,     /* # of HW channels */
+	MAX_MTU        = 9600,  /* max MAC MTU, excluding header + FCS */
+	EEPROMSIZE     = 17408, /* Serial EEPROM physical size */
+	EEPROMVSIZE    = 32768, /* Serial EEPROM virtual address space size */
+	RSS_NENTRIES   = 2048,  /* # of entries in RSS mapping table */
+	TCB_SIZE       = 128,   /* TCB size */
+	NMTUS          = 16,    /* size of MTU table */
+	NCCTRL_WIN     = 32,    /* # of congestion control windows */
+	NEXACT_MAC     = 336,   /* # of exact MAC address filters */
+	L2T_SIZE       = 4096,  /* # of L2T entries */
+	MBOX_LEN       = 64,    /* mailbox size in bytes */
+	TRACE_LEN      = 112,   /* length of trace data and mask */
+	FILTER_OPT_LEN = 36,    /* filter tuple width for optional components */
+	NWOL_PAT       = 8,     /* # of WoL patterns */
+	WOL_PAT_LEN    = 128,   /* length of WoL patterns */
+};
+
+enum {
+	SF_PAGE_SIZE = 256,           /* serial flash page size */
+	SF_SEC_SIZE = 64 * 1024,      /* serial flash sector size */
+	SF_SIZE = SF_SEC_SIZE * 16,   /* serial flash size */
+};
+
+enum { RSP_TYPE_FLBUF, RSP_TYPE_CPL, RSP_TYPE_INTR }; /* response entry types */
+
+enum { MBOX_OWNER_NONE, MBOX_OWNER_FW, MBOX_OWNER_DRV };    /* mailbox owners */
+
+enum {
+	SGE_MAX_WR_LEN = 512,     /* max WR size in bytes */
+	SGE_CTXT_SIZE = 24,       /* size of SGE context */
+	SGE_NTIMERS = 6,          /* # of interrupt holdoff timer values */
+	SGE_NCOUNTERS = 4,        /* # of interrupt packet counter values */
+};
+
+struct sge_qstat {                /* data written to SGE queue status entries */
+	__be32 qid;
+	__be16 cidx;
+	__be16 pidx;
+};
+
+#define S_QSTAT_PIDX    0
+#define M_QSTAT_PIDX    0xffff
+#define G_QSTAT_PIDX(x) (((x) >> S_QSTAT_PIDX) & M_QSTAT_PIDX)
+
+#define S_QSTAT_CIDX    16
+#define M_QSTAT_CIDX    0xffff
+#define G_QSTAT_CIDX(x) (((x) >> S_QSTAT_CIDX) & M_QSTAT_CIDX)
+
+/*
+ * Structure for last 128 bits of response descriptors
+ */
+struct rsp_ctrl {
+	__be32 hdrbuflen_pidx;
+	__be32 pldbuflen_qid;
+	union {
+		u8 type_gen;
+		__be64 last_flit;
+	};
+};
+
+#define S_RSPD_NEWBUF    31
+#define V_RSPD_NEWBUF(x) ((x) << S_RSPD_NEWBUF)
+#define F_RSPD_NEWBUF    V_RSPD_NEWBUF(1U)
+
+#define S_RSPD_LEN    0
+#define M_RSPD_LEN    0x7fffffff
+#define V_RSPD_LEN(x) ((x) << S_RSPD_LEN)
+#define G_RSPD_LEN(x) (((x) >> S_RSPD_LEN) & M_RSPD_LEN)
+
+#define S_RSPD_GEN    7
+#define V_RSPD_GEN(x) ((x) << S_RSPD_GEN)
+#define F_RSPD_GEN    V_RSPD_GEN(1U)
+
+#define S_RSPD_TYPE    4
+#define M_RSPD_TYPE    0x3
+#define V_RSPD_TYPE(x) ((x) << S_RSPD_TYPE)
+#define G_RSPD_TYPE(x) (((x) >> S_RSPD_TYPE) & M_RSPD_TYPE)
+
+/* Rx queue interrupt deferral fields: counter enable and timer index */
+#define S_QINTR_CNT_EN    0
+#define V_QINTR_CNT_EN(x) ((x) << S_QINTR_CNT_EN)
+#define F_QINTR_CNT_EN    V_QINTR_CNT_EN(1U)
+
+#define S_QINTR_TIMER_IDX    1
+#define M_QINTR_TIMER_IDX    0x7
+#define V_QINTR_TIMER_IDX(x) ((x) << S_QINTR_TIMER_IDX)
+#define G_QINTR_TIMER_IDX(x) (((x) >> S_QINTR_TIMER_IDX) & M_QINTR_TIMER_IDX)
+
+#endif /* __T4_HW_H */
-- 
1.5.4

