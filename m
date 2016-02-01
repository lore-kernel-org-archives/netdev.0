From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 6/7] net: ixgbe: add minimal parser details for ixgbe
Date: Sun, 31 Jan 2016 17:52:38 -0800
Message-ID: <20160201015238.13871.81573.stgit@john-Precision-Tower-5810>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, donald.c.skidmore@intel.com, horms@verge.net.au,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34322 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933349AbcBABxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 20:53:04 -0500
Received: by mail-pf0-f195.google.com with SMTP id 65so6786428pfd.1
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 17:53:03 -0800 (PST)
In-Reply-To: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds an ixgbe data structure that is used to determine what
headers:fields can be matched and in what order they are supported.

For hardware devices this can be a bit tricky because typically
only pre-programmed (firmware, ucode, rtl) parse graphs will be
supported and we don't yet have an interface to change these from
the OS. So its sort of a you get whatever your friendly vendor
provides affair at the moment.

In the future we can add the get routines and set routines to
update this data structure. One interesting thing to note here
is the data structure here identifies ethernet, ip, and tcp
fields without having to hardcode them as enumerations or use
other identifiers.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h |  110 ++++++++++++++++++++++++
 1 file changed, 110 insertions(+)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
new file mode 100644
index 0000000..747d14a
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
@@ -0,0 +1,110 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 2016 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBE_MODEL_H_
+#define _IXGBE_MODEL_H_
+
+#include "ixgbe.h"
+#include "ixgbe_type.h"
+
+struct ixgbe_mat_field {
+	unsigned int off;
+	unsigned int mask;
+	int (*val)(struct ixgbe_fdir_filter *input,
+		   union ixgbe_atr_input *mask,
+		   __u32 val, __u32 m);
+	int link;
+};
+
+static inline int ixgbe_mat_prgm_sip(struct ixgbe_fdir_filter *input,
+				     union ixgbe_atr_input *mask,
+				     __u32 val, __u32 m)
+{
+	input->filter.formatted.src_ip[0] = val;
+	mask->formatted.src_ip[0] = m;
+	return 0;
+}
+
+static inline int ixgbe_mat_prgm_dip(struct ixgbe_fdir_filter *input,
+				     union ixgbe_atr_input *mask,
+				     __u32 val, __u32 m)
+{
+	input->filter.formatted.dst_ip[0] = val;
+	mask->formatted.dst_ip[0] = m;
+	return 0;
+}
+
+static struct ixgbe_mat_field ixgbe_ipv4_fields[] = {
+	{ .off = 12, .mask = -1, .val = ixgbe_mat_prgm_sip, .link = 0},
+	{ .off = 16, .mask = -1, .val = ixgbe_mat_prgm_dip, .link = 0},
+	{ .val = NULL } /* terminal node */
+};
+
+static inline int ixgbe_mat_prgm_sport(struct ixgbe_fdir_filter *input,
+				       union ixgbe_atr_input *mask,
+				       __u32 val, __u32 m)
+{
+	input->filter.formatted.src_port = val & 0xffff;
+	mask->formatted.src_port = m & 0xffff;
+	return 0;
+};
+
+static inline int ixgbe_mat_prgm_dport(struct ixgbe_fdir_filter *input,
+				       union ixgbe_atr_input *mask,
+				       __u32 val, __u32 m)
+{
+	input->filter.formatted.dst_port = val & 0xffff;
+	mask->formatted.dst_port = m & 0xffff;
+	return 0;
+};
+
+static struct ixgbe_mat_field ixgbe_tcp_fields[] = {
+	{.off = 0, .mask = 0xffff, .val = ixgbe_mat_prgm_sport, .link = -1},
+	{.off = 2, .mask = 0xffff, .val = ixgbe_mat_prgm_dport, .link = -1},
+	{ .val = NULL } /* terminal node */
+};
+
+struct ixgbe_nexthdr {
+	/* offset, shift, and mask of position to next header */
+	unsigned int o;
+	__u32 s;
+	__u32 m;
+	/* match criteria to make this jump*/
+	unsigned int off;
+	__u32 val;
+	__u32 mask;
+	/* location of jump to make */
+	struct ixgbe_mat_field *jump;
+};
+
+static struct ixgbe_nexthdr ixgbe_ipv4_jumps[] = {
+	{ .o = 0, .s = 6, .m = 0xf,
+	  .off = 8, .val = 0x600, .mask = 0xff00, .jump = ixgbe_tcp_fields},
+	{ .jump = NULL } /* terminal node */
+};
+#endif /* _IXGBE_MODEL_H_ */
