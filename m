From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 6/8] net: ixgbe: add minimal parser details for
 ixgbe
Date: Mon, 15 Feb 2016 22:02:43 -0800
Message-ID: <20160216060243.32452.50498.stgit@john-Precision-Tower-5810>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com
To: amir@vadai.me, john.fastabend@gmail.com, jhs@mojatatu.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34013 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbcBPGDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 01:03:05 -0500
Received: by mail-pf0-f170.google.com with SMTP id x65so99167338pfb.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 22:03:05 -0800 (PST)
In-Reply-To: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h |  112 ++++++++++++++++++++++++
 1 file changed, 112 insertions(+)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
new file mode 100644
index 0000000..43ebec4
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
@@ -0,0 +1,112 @@
+/*******************************************************************************
+ *
+ * Intel 10 Gigabit PCI Express Linux drive
+ * Copyright(c) 2013 - 2015 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
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
+	unsigned int type;
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
+	{ .off = 12, .mask = -1, .val = ixgbe_mat_prgm_sip,
+	  .type = IXGBE_ATR_FLOW_TYPE_IPV4},
+	{ .off = 16, .mask = -1, .val = ixgbe_mat_prgm_dip,
+	  .type = IXGBE_ATR_FLOW_TYPE_IPV4},
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
+	{.off = 0, .mask = 0xffff, .val = ixgbe_mat_prgm_sport,
+	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
+	{.off = 2, .mask = 0xffff, .val = ixgbe_mat_prgm_dport,
+	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
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
