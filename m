From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 3/4] net: added a BPF to help drivers detect PTP packets.
Date: Sat, 17 Jul 2010 20:49:17 +0200
Message-ID: <4bd18165f4f89e0ff7942a7dab7f9c814f63ab28.1279391885.git.richard.cochran@omicron.at>
References: <cover.1279391885.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65139 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756536Ab0GQStT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 14:49:19 -0400
Received: by mail-bw0-f46.google.com with SMTP id 1so1698395bwz.19
        for <netdev@vger.kernel.org>; Sat, 17 Jul 2010 11:49:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1279391885.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Certain kinds of hardware time stamping units in both MACs and PHYs have
the limitation that they can only time stamp PTP packets. Drivers for such
hardware are left with the task of correctly matching skbs to time stamps.
This patch adds a BPF that drivers can use to classify PTP packets when
needed.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/ptp_classify.h |  126 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 126 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/ptp_classify.h

diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.h
new file mode 100644
index 0000000..943a85a
--- /dev/null
+++ b/include/linux/ptp_classify.h
@@ -0,0 +1,126 @@
+/*
+ * PTP 1588 support
+ *
+ * This file implements a BPF that recognizes PTP event messages.
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef _PTP_CLASSIFY_H_
+#define _PTP_CLASSIFY_H_
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/filter.h>
+#ifdef __KERNEL__
+#include <linux/in.h>
+#else
+#include <netinet/in.h>
+#endif
+
+#define PTP_CLASS_NONE  0x00 /* not a PTP event message */
+#define PTP_CLASS_V1    0x01 /* protocol version 1 */
+#define PTP_CLASS_V2    0x02 /* protocol version 2 */
+#define PTP_CLASS_VMASK 0x0f /* max protocol version is 15 */
+#define PTP_CLASS_IPV4  0x10 /* event in an IPV4 UDP packet */
+#define PTP_CLASS_IPV6  0x20 /* event in an IPV6 UDP packet */
+#define PTP_CLASS_L2    0x30 /* event in a L2 packet */
+#define PTP_CLASS_VLAN  0x40 /* event in a VLAN tagged L2 packet */
+#define PTP_CLASS_PMASK 0xf0 /* mask for the packet type field */
+
+#define PTP_CLASS_V1_IPV4 (PTP_CLASS_V1 | PTP_CLASS_IPV4)
+#define PTP_CLASS_V1_IPV6 (PTP_CLASS_V1 | PTP_CLASS_IPV6) /*probably DNE*/
+#define PTP_CLASS_V2_IPV4 (PTP_CLASS_V2 | PTP_CLASS_IPV4)
+#define PTP_CLASS_V2_IPV6 (PTP_CLASS_V2 | PTP_CLASS_IPV6)
+#define PTP_CLASS_V2_L2   (PTP_CLASS_V2 | PTP_CLASS_L2)
+#define PTP_CLASS_V2_VLAN (PTP_CLASS_V2 | PTP_CLASS_VLAN)
+
+#define PTP_EV_PORT 319
+
+#define OFF_ETYPE	12
+#define OFF_IHL		14
+#define OFF_FRAG	20
+#define OFF_PROTO4	23
+#define OFF_NEXT	6
+#define OFF_UDP_DST	2
+
+#define IP6_HLEN	40
+#define UDP_HLEN	8
+
+#define RELOFF_DST4	(ETH_HLEN + OFF_UDP_DST)
+#define OFF_DST6	(ETH_HLEN + IP6_HLEN + OFF_UDP_DST)
+#define OFF_PTP6	(ETH_HLEN + IP6_HLEN + UDP_HLEN)
+
+#define OP_AND	(BPF_ALU | BPF_AND  | BPF_K)
+#define OP_JEQ	(BPF_JMP | BPF_JEQ  | BPF_K)
+#define OP_JSET	(BPF_JMP | BPF_JSET | BPF_K)
+#define OP_LDB	(BPF_LD  | BPF_B    | BPF_ABS)
+#define OP_LDH	(BPF_LD  | BPF_H    | BPF_ABS)
+#define OP_LDHI	(BPF_LD  | BPF_H    | BPF_IND)
+#define OP_LDX	(BPF_LDX | BPF_B    | BPF_MSH)
+#define OP_OR	(BPF_ALU | BPF_OR   | BPF_K)
+#define OP_RETA	(BPF_RET | BPF_A)
+#define OP_RETK	(BPF_RET | BPF_K)
+
+static inline int ptp_filter_init(struct sock_filter *f, int len)
+{
+	if (OP_LDH == f[0].code)
+		return sk_chk_filter(f, len);
+	else
+		return 0;
+}
+
+#define PTP_FILTER \
+	{OP_LDH,	0,   0, OFF_ETYPE		}, /*              */ \
+	{OP_JEQ,	0,  12, ETH_P_IP		}, /* f goto L20   */ \
+	{OP_LDB,	0,   0, OFF_PROTO4		}, /*              */ \
+	{OP_JEQ,	0,   9, IPPROTO_UDP		}, /* f goto L10   */ \
+	{OP_LDH,	0,   0, OFF_FRAG		}, /*              */ \
+	{OP_JSET,	7,   0, 0x1fff			}, /* t goto L11   */ \
+	{OP_LDX,	0,   0, OFF_IHL			}, /*              */ \
+	{OP_LDHI,	0,   0, RELOFF_DST4		}, /*              */ \
+	{OP_JEQ,	0,   4, PTP_EV_PORT		}, /* f goto L12   */ \
+	{OP_LDHI,	0,   0, ETH_HLEN + UDP_HLEN	}, /*              */ \
+	{OP_AND,	0,   0, PTP_CLASS_VMASK		}, /*              */ \
+	{OP_OR,		0,   0, PTP_CLASS_IPV4		}, /*              */ \
+	{OP_RETA,	0,   0, 0			}, /*              */ \
+/*L1x*/	{OP_RETK,	0,   0, PTP_CLASS_NONE		}, /*              */ \
+/*L20*/	{OP_JEQ,	0,   9, ETH_P_IPV6		}, /* f goto L40   */ \
+	{OP_LDB,	0,   0, ETH_HLEN + OFF_NEXT	}, /*              */ \
+	{OP_JEQ,	0,   6, IPPROTO_UDP		}, /* f goto L30   */ \
+	{OP_LDH,	0,   0, OFF_DST6		}, /*              */ \
+	{OP_JEQ,	0,   4, PTP_EV_PORT		}, /* f goto L31   */ \
+	{OP_LDH,	0,   0, OFF_PTP6		}, /*              */ \
+	{OP_AND,	0,   0, PTP_CLASS_VMASK		}, /*              */ \
+	{OP_OR,		0,   0, PTP_CLASS_IPV6		}, /*              */ \
+	{OP_RETA,	0,   0, 0			}, /*              */ \
+/*L3x*/	{OP_RETK,	0,   0, PTP_CLASS_NONE		}, /*              */ \
+/*L40*/	{OP_JEQ,	0,   6, ETH_P_8021Q		}, /* f goto L50   */ \
+	{OP_LDH,	0,   0, OFF_ETYPE + 4		}, /*              */ \
+	{OP_JEQ,	0,   9, ETH_P_1588		}, /* f goto L60   */ \
+	{OP_LDH,	0,   0, ETH_HLEN + VLAN_HLEN	}, /*              */ \
+	{OP_AND,	0,   0, PTP_CLASS_VMASK		}, /*              */ \
+	{OP_OR,		0,   0, PTP_CLASS_VLAN		}, /*              */ \
+	{OP_RETA,	0,   0, 0			}, /*              */ \
+/*L50*/	{OP_JEQ,	0,   4, ETH_P_1588		}, /* f goto L61   */ \
+	{OP_LDH,	0,   0, ETH_HLEN		}, /*              */ \
+	{OP_AND,	0,   0, PTP_CLASS_VMASK		}, /*              */ \
+	{OP_OR,		0,   0, PTP_CLASS_L2		}, /*              */ \
+	{OP_RETA,	0,   0, 0			}, /*              */ \
+/*L6x*/	{OP_RETK,	0,   0, PTP_CLASS_NONE		},
+
+#endif
-- 
1.7.0.4

