From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/2] ptp: fix L2 event message recognition
Date: Tue, 20 Sep 2011 13:25:41 +0200
Message-ID: <9647244ddf78388f5d0dba6fcc0ad8eb0b0c4c72.1316516990.git.richard.cochran@omicron.at>
References: <cover.1316516989.git.richard.cochran@omicron.at>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	<stable@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1316516989.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1316516989.git.richard.cochran@omicron.at>
References: <cover.1316516989.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IEEE 1588 standard defines two kinds of messages, event and general
messages. Event messages require time stamping, and general do not. When
using UDP transport, two separate ports are used for the two message
types.

The BPF designed to recognize event messages incorrectly classifies L2
general messages as event messages. This commit fixes the issue by
extending the filter to check the message type field for L2 PTP packets.
Event messages are be distinguished from general messages by testing
the "general" bit.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Cc: <stable@kernel.org>
---
 include/linux/ptp_classify.h |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.h
index e07e274..1dc420b 100644
--- a/include/linux/ptp_classify.h
+++ b/include/linux/ptp_classify.h
@@ -51,6 +51,7 @@
 #define PTP_CLASS_V2_VLAN (PTP_CLASS_V2 | PTP_CLASS_VLAN)
 
 #define PTP_EV_PORT 319
+#define PTP_GEN_BIT 0x08 /* indicates general message, if set in message type */
 
 #define OFF_ETYPE	12
 #define OFF_IHL		14
@@ -116,14 +117,20 @@ static inline int ptp_filter_init(struct sock_filter *f, int len)
 	{OP_OR,		0,   0, PTP_CLASS_IPV6		}, /*              */ \
 	{OP_RETA,	0,   0, 0			}, /*              */ \
 /*L3x*/	{OP_RETK,	0,   0, PTP_CLASS_NONE		}, /*              */ \
-/*L40*/	{OP_JEQ,	0,   6, ETH_P_8021Q		}, /* f goto L50   */ \
+/*L40*/	{OP_JEQ,	0,   9, ETH_P_8021Q		}, /* f goto L50   */ \
 	{OP_LDH,	0,   0, OFF_ETYPE + 4		}, /*              */ \
-	{OP_JEQ,	0,   9, ETH_P_1588		}, /* f goto L60   */ \
+	{OP_JEQ,	0,  15, ETH_P_1588		}, /* f goto L60   */ \
+	{OP_LDB,	0,   0, ETH_HLEN + VLAN_HLEN	}, /*              */ \
+	{OP_AND,	0,   0, PTP_GEN_BIT		}, /*              */ \
+	{OP_JEQ,	0,  12, 0			}, /* f goto L6x   */ \
 	{OP_LDH,	0,   0, ETH_HLEN + VLAN_HLEN	}, /*              */ \
 	{OP_AND,	0,   0, PTP_CLASS_VMASK		}, /*              */ \
 	{OP_OR,		0,   0, PTP_CLASS_VLAN		}, /*              */ \
 	{OP_RETA,	0,   0, 0			}, /*              */ \
-/*L50*/	{OP_JEQ,	0,   4, ETH_P_1588		}, /* f goto L61   */ \
+/*L50*/	{OP_JEQ,	0,   7, ETH_P_1588		}, /* f goto L61   */ \
+	{OP_LDB,	0,   0, ETH_HLEN		}, /*              */ \
+	{OP_AND,	0,   0, PTP_GEN_BIT		}, /*              */ \
+	{OP_JEQ,	0,   4, 0			}, /* f goto L6x   */ \
 	{OP_LDH,	0,   0, ETH_HLEN		}, /*              */ \
 	{OP_AND,	0,   0, PTP_CLASS_VMASK		}, /*              */ \
 	{OP_OR,		0,   0, PTP_CLASS_L2		}, /*              */ \
-- 
1.7.2.5
