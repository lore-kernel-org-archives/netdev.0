From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 6/7] net: add the AF_FLEXRAY protocol
Date: Tue, 13 Aug 2013 11:08:41 +0200
Message-ID: <1376384922-8519-8-git-send-email-b.spranger@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48295 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755921Ab3HMJJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:09:00 -0400
In-Reply-To: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lexRay is a networking technology used in automotive fields as
successor of the Controller Area Network (CAN). It provides the
core functionality and a RAW protocol driver.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 Documentation/networking/00-INDEX             |   2 +
 Documentation/networking/flexray.txt          |  24 ++
 include/linux/flexray.h                       | 168 ++++++++
 include/linux/flexray/core.h                  |  45 +++
 include/linux/flexray/dev.h                   |  64 +++
 include/linux/socket.h                        |   4 +-
 include/uapi/linux/flexray/Kbuild             |   4 +
 include/uapi/linux/flexray/flexcard_netlink.h |  53 +++
 include/uapi/linux/flexray/netlink.h          | 203 ++++++++++
 include/uapi/linux/flexray/raw.h              |  16 +
 include/uapi/linux/if_arp.h                   |   1 +
 include/uapi/linux/if_ether.h                 |   1 +
 net/Kconfig                                   |   1 +
 net/Makefile                                  |   1 +
 net/core/sock.c                               |   9 +-
 net/flexray/Kconfig                           |  28 ++
 net/flexray/Makefile                          |   9 +
 net/flexray/af_flexray.c                      | 548 ++++++++++++++++++=
++++++++
 net/flexray/af_flexray.h                      |  59 +++
 net/flexray/proc.c                            | 196 +++++++++
 net/flexray/raw.c                             | 446 ++++++++++++++++++=
+++
 21 files changed, 1878 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/networking/flexray.txt
 create mode 100644 include/linux/flexray.h
 create mode 100644 include/linux/flexray/core.h
 create mode 100644 include/linux/flexray/dev.h
 create mode 100644 include/uapi/linux/flexray/Kbuild
 create mode 100644 include/uapi/linux/flexray/flexcard_netlink.h
 create mode 100644 include/uapi/linux/flexray/netlink.h
 create mode 100644 include/uapi/linux/flexray/raw.h
 create mode 100644 net/flexray/Kconfig
 create mode 100644 net/flexray/Makefile
 create mode 100644 net/flexray/af_flexray.c
 create mode 100644 net/flexray/af_flexray.h
 create mode 100644 net/flexray/proc.c
 create mode 100644 net/flexray/raw.c

diff --git a/Documentation/networking/00-INDEX b/Documentation/networki=
ng/00-INDEX
index 18b64b2..1cb180e 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -74,6 +74,8 @@ fib_trie.txt
 	- Level Compressed Trie (LC-trie) notes: a structure for routing.
 filter.txt
 	- Linux Socket Filtering
+flexray.txt
+	- FlexRay Protocol Family
 fore200e.txt
 	- FORE Systems PCA-200E/SBA-200E ATM NIC driver info.
 framerelay.txt
diff --git a/Documentation/networking/flexray.txt b/Documentation/netwo=
rking/flexray.txt
new file mode 100644
index 0000000..9c0b844
--- /dev/null
+++ b/Documentation/networking/flexray.txt
@@ -0,0 +1,24 @@
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+
+flexray.txt
+
+Readme file for the FlexRay Protocol Family (aka Socket FlexRay)
+
+This file contains
+
+  1 Overview / What is Socket FlexRay
+
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+
+1 Overview / What is Socket FlexRay
+-----------------------------------
+
+The socket FlexRay package is an implementation of FlexRay protocols
+for Linux. FlexRay is a networking technology used in automotive field=
s as
+successor of the Controller Area Network (CAN). It is designed to be f=
aster
+and more reliable than CAN.
+The Socket FlexRay implementation uses the Berkeley socket API, the Li=
nux
+network stack and implements the FlexRay device drivers as network int=
erfaces.
+The FlexRay socket API has been designed as similar as possible to the=
 TCP/IP
+protocols to allow programmers, familiar with network programming, to =
easily
+learn how to use FlexRay sockets.
diff --git a/include/linux/flexray.h b/include/linux/flexray.h
new file mode 100644
index 0000000..75e07e8
--- /dev/null
+++ b/include/linux/flexray.h
@@ -0,0 +1,168 @@
+/*
+ * linux/flexray.h
+ *
+ * Definitions for FlexRay network layer (socket addr / FlexRay frame)
+ *
+ */
+
+#ifndef FLEXRAY_H
+#define FLEXRAY_H
+
+#include <linux/types.h>
+#include <linux/socket.h>
+
+/* FlexRay kernel definitions */
+
+/* special address description flags for the FLEXRAY_ID */
+#define FLEXRAY_PPI_FLAG	0x40 /* Payload preamble indicator */
+#define FLEXRAY_NFI_FLAG	0x20 /* Null frame indikator */
+#define FLEXRAY_SYN_FLAG	0x10 /* Sync frame indikator */
+#define FLEXRAY_SFI_FLAG	0x08 /* Startup frame indikator */
+
+/*
+ * FlexRay Frame structure
+ *
+ * Bit 0     reserved
+ * Bit 1     Payload preamble indicator
+ * Bit 2     Null frame indikator
+ * Bit 3     Sync frame indikator
+ * Bit 4     Startup frame indikator
+ * Bit 5-15  Frame ID
+ * Bit 16-22 Payload length
+ * Bit 23-33 Header CRC
+ * Bit 34-39 Cycle count
+ * PAYLOAD [0-254 Bytes]
+ * 24 Bit CRC
+ */
+
+/* define Flexray Header Type for Filters */
+typedef __u64 flexray_header_t;
+
+/**
+ * struct flexray_frame - basic FlexRay frame structure
+ * @head:	Header
+ * @data:       the FlexRay frame payload.
+ * @crc:	the FlexRay frame CRC
+ */
+
+struct flexray_frame {
+	__u8		head[5];
+	__u8		data[254] __aligned(8);
+	__u8		crc[3];
+};
+
+static inline int flexray_get_ppi(__u8 *head)
+{
+	return !!(head[0] & FLEXRAY_PPI_FLAG);
+}
+
+static inline void flexray_set_ppi(int ppi, __u8 *head)
+{
+	if (ppi)
+		head[0] |=3D FLEXRAY_PPI_FLAG;
+	else
+		head[0] &=3D ~FLEXRAY_PPI_FLAG;
+}
+
+static inline int flexray_get_nfi(__u8 *head)
+{
+	return !!(head[0] & FLEXRAY_NFI_FLAG);
+}
+
+static inline void flexray_set_nfi(int nfi, __u8 *head)
+{
+	if (nfi)
+		head[0] |=3D FLEXRAY_NFI_FLAG;
+	else
+		head[0] &=3D ~FLEXRAY_NFI_FLAG;
+}
+
+static inline int flexray_get_syn(__u8 *head)
+{
+	return !!(head[0] & FLEXRAY_SYN_FLAG);
+}
+
+static inline void flexray_set_syn(int syn, __u8 *head)
+{
+	if (syn)
+		head[0] |=3D FLEXRAY_SYN_FLAG;
+	else
+		head[0] &=3D ~FLEXRAY_SYN_FLAG;
+}
+
+static inline int flexray_get_sfi(__u8 *head)
+{
+	return !!(head[0] & FLEXRAY_SFI_FLAG);
+}
+
+static inline void flexray_set_sfi(int sfi, __u8 *head)
+{
+	if (sfi)
+		head[0] |=3D FLEXRAY_SFI_FLAG;
+	else
+		head[0] &=3D ~FLEXRAY_SFI_FLAG;
+}
+
+static inline __u16 flexray_get_id(__u8 *head)
+{
+	return ((head[0] & 0x3) << 8) | head[1];
+}
+
+static inline void flexray_set_id(__u16 id, __u8 *head)
+{
+	head[0] &=3D ~0x3;
+	head[0] |=3D (id >> 8) & 0x3;
+	head[1] =3D id & 0xff;
+}
+
+static inline __u8 flexray_get_pl(__u8 *head)
+{
+	return head[2] >> 1;
+}
+
+static inline void flexray_set_pl(__u8 pl, __u8 *head)
+{
+	head[2] &=3D 0x1;
+	head[2] |=3D pl << 1;
+}
+
+static inline __u16 flexray_get_hcrc(__u8 *head)
+{
+	return ((head[2] & 0x1) << 10) | (head[3] << 2) | (head[4] >> 6);
+}
+
+static inline void flexray_set_hcrc(__u16 hcrc, __u8 *head)
+{
+	head[2] &=3D 0xfe;
+	head[4] &=3D 0x3f;
+	head[2] |=3D (hcrc >> 10) & 0x1;
+	head[3] =3D (hcrc >> 2) & 0xff;
+	head[4] |=3D (hcrc & 0x3) << 6;
+}
+
+static inline __u8 flexray_get_cc(__u8 *head)
+{
+	return head[4] & 0x3f;
+}
+
+static inline void flexray_set_cc(__u8 cc, __u8 *head)
+{
+	head[4] &=3D ~0x3f;
+	head[4] |=3D cc & 0x3f;
+}
+
+/* particular protocols of the protocol family PF_FLEXRAY */
+#define FLEXRAY_RAW	1 /* RAW sockets */
+#define FLEXRAY_NPROTO	2
+
+struct sockaddr_flexray {
+	sa_family_t	flexray_family;
+	int		flexray_ifindex;
+};
+
+struct flexray_filter {
+	flexray_header_t flexray_id;
+	flexray_header_t flexray_mask;
+};
+
+#endif /* FLEXRAY_H */
diff --git a/include/linux/flexray/core.h b/include/linux/flexray/core.=
h
new file mode 100644
index 0000000..90a0f06
--- /dev/null
+++ b/include/linux/flexray/core.h
@@ -0,0 +1,45 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef FLEXRAY_CORE_H
+#define FLEXRAY_CORE_H
+
+#include <linux/flexray.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+#define DNAME(dev) ((dev) ? (dev)->name : "any")
+
+/**
+ * struct flexray_proto - FlexRay protocol structure
+ * @type:       type argument in socket() syscall, e.g. SOCK_DGRAM.
+ * @protocol:   protocol number in socket() syscall.
+ * @ops:        pointer to struct proto_ops for sock->ops.
+ * @prot:       pointer to struct proto structure.
+ */
+struct flexray_proto {
+	int type;
+	int protocol;
+	const struct proto_ops *ops;
+	struct proto *prot;
+};
+
+/* function prototypes for the FlexRay networklayer core (af_flexray.c=
) */
+
+extern int  flexray_proto_register(const struct flexray_proto *frp);
+extern void flexray_proto_unregister(const struct flexray_proto *frp);
+
+extern int  flexray_rx_register(struct net_device *dev,
+				void (*func)(struct sk_buff *, void *),
+				void *data, char *ident);
+
+extern void flexray_rx_unregister(struct net_device *dev,
+				  void (*func)(struct sk_buff *, void *),
+				  void *data);
+
+extern int flexray_send(struct sk_buff *skb);
+extern int flexray_ioctl(struct socket *sock, unsigned int cmd,
+			 unsigned long arg);
+
+#endif /* FLEXRAY_CORE_H */
diff --git a/include/linux/flexray/dev.h b/include/linux/flexray/dev.h
new file mode 100644
index 0000000..999ebab
--- /dev/null
+++ b/include/linux/flexray/dev.h
@@ -0,0 +1,64 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef FLEXRAY_DEV_H
+#define FLEXRAY_DEV_H
+
+#include <linux/flexray.h>
+#include <linux/flexray/netlink.h>
+
+/* FlexRay common private data */
+
+struct flexray_priv {
+	struct flexray_device_stats flexray_stats;
+
+	enum flexray_state state;
+
+	int (*do_get_state)(const struct net_device *dev,
+			    enum flexray_state *state);
+	int (*do_set_state)(struct net_device *dev,
+			    enum flexray_state state);
+	int (*do_validate)(struct sk_buff *skb);
+
+	struct flexray_cluster_param cluster;
+	struct flexray_node_param node;
+	struct flexray_symbol_param symbol;
+	__u32 sw_filter[FLEXRAY_MAX_SW_FILTER];
+	u8 version;
+};
+
+/* Drop a given socketbuffer if it does not contain a valid FlexRay fr=
ame. */
+static inline int flexray_dropped_invalid_skb(struct net_device *dev,
+					      struct sk_buff *skb)
+{
+	const struct flexray_frame *frf =3D (struct flexray_frame *)skb->data=
;
+
+	if (unlikely(skb->len !=3D sizeof(*frf))) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return 1;
+	}
+
+	return 0;
+}
+
+struct net_device *alloc_flexraydev(int sizeof_priv, u8 version);
+void free_flexraydev(struct net_device *dev);
+
+int open_flexraydev(struct net_device *dev);
+void close_flexraydev(struct net_device *dev);
+
+int register_flexraydev(struct net_device *dev);
+void unregister_flexraydev(struct net_device *dev);
+
+int flexray_restart_now(struct net_device *dev);
+
+struct sk_buff *alloc_flexray_skb(struct net_device *dev,
+				  struct flexray_frame **cf);
+
+void print_cluster_config(struct flexray_cluster_param *cp, int is_v3)=
;
+void print_node_config(struct flexray_node_param *np, int is_v3);
+void print_symbol_config(struct flexray_symbol_param *sp);
+
+#endif /* FLEXRAY_DEV_H */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 230c04b..a7c316b 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -180,7 +180,8 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_FLEXRAY	41	/* Flexray			*/
+#define AF_MAX		42	/* For now.. */
=20
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -225,6 +226,7 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_FLEXRAY	AF_FLEXRAY
 #define PF_MAX		AF_MAX
=20
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/uapi/linux/flexray/Kbuild b/include/uapi/linux/fle=
xray/Kbuild
new file mode 100644
index 0000000..8c45658
--- /dev/null
+++ b/include/uapi/linux/flexray/Kbuild
@@ -0,0 +1,4 @@
+header-y +=3D error.h
+header-y +=3D netlink.h
+header-y +=3D raw.h
+header-y +=3D flexcard_netlink.h
diff --git a/include/uapi/linux/flexray/flexcard_netlink.h b/include/ua=
pi/linux/flexray/flexcard_netlink.h
new file mode 100644
index 0000000..d04e2dd
--- /dev/null
+++ b/include/uapi/linux/flexray/flexcard_netlink.h
@@ -0,0 +1,53 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef _FLEXCARD_NETLINK_H
+#define _FLEXCARD_NETLINK_H
+
+#include <linux/types.h>
+
+#define FC_MSGBUF_VERSION	1
+
+/* Start Flexcard flags beyond ERAY flags */
+#define FC_MSGBUF_ACK		0x00010000
+#define FC_MSGBUF_ACK_NULL	0x00020000
+#define FC_MSGBUF_ACK_PAYLOAD	0x00040000
+#define FC_MSGBUF_SELFSYNC	0x00080000
+
+struct fc_msgbuf_cfg {
+	__u32 flags;
+	__u8 buf_id;
+	__u8 cyc;
+	__u16 len;
+	__u16 max;
+	__u16 start;
+	__u32 frame_id;
+	__u32 reject_mask;
+	enum eray_msgbuf_type type;
+	enum eray_msgbuf_channel channel;
+} __packed;
+
+/* commands */
+enum fc_msgbuf_cmd {
+	FC_MSGBUF_CMD_UNSPEC,
+	FC_MSGBUF_CMD_GET_CFG,
+	FC_MSGBUF_CMD_SET_CFG,
+	FC_MSGBUF_CMD_RESET_CFG,
+	FC_MSGBUF_CMD_READ_CFG,
+	__FC_MSGBUF_CMD_MAX,
+};
+#define FC_MSGBUF_CMD_MAX (__FC_MSGBUF_CMD_MAX - 1)
+
+/* attributes */
+enum fc_msgbuf_attr {
+	FC_MSGBUF_ATTR_UNSPEC,
+	FC_MSGBUF_ATTR_BUF_ID,
+	FC_MSGBUF_ATTR_DEV_ID,
+	FC_MSGBUF_ATTR_DEV_NAME,
+	FC_MSGBUF_ATTR_CFG,
+	__FC_MSGBUF_ATTR_MAX,
+};
+#define FC_MSGBUF_ATTR_MAX (__FC_MSGBUF_ATTR_MAX - 1)
+
+#endif /* _FLEXCARD_NETLINK_H */
diff --git a/include/uapi/linux/flexray/netlink.h b/include/uapi/linux/=
flexray/netlink.h
new file mode 100644
index 0000000..3d1dbaf
--- /dev/null
+++ b/include/uapi/linux/flexray/netlink.h
@@ -0,0 +1,203 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef FLEXRAY_NETLINK_H
+#define FLEXRAY_NETLINK_H
+
+#include <linux/types.h>
+
+#define FLEXRAY_MAX_SW_FILTER	2048
+
+/*
+ * FlexRay operational and error states
+ */
+enum flexray_state {
+	FLEXRAY_STATE_UNSPEC,
+	FLEXRAY_STATE_DEFAULT_CONFIG,
+	FLEXRAY_STATE_CONFIG,
+	FLEXRAY_STATE_READY,
+	FLEXRAY_STATE_WAKEUP,
+	FLEXRAY_STATE_STARTUP,
+	FLEXRAY_STATE_NORMAL_ACTIVE,
+	FLEXRAY_STATE_NORMAL_PASSIVE,
+	FLEXRAY_STATE_HALT,
+	FLEXRAY_STATE_MONITOR_MODE,
+	FLEXRAY_STATE_COLDSTART,
+	FLEXRAY_STATE_MAX
+};
+
+/*
+ * FlexRay device statistics
+ */
+struct flexray_device_stats {
+	__u32 txack;
+	__u32 manage;
+	__u32 info;
+	__u32 status;
+	__u32 notify;
+};
+
+/*
+ * FlexRay netlink interface
+ */
+enum {
+	IFLA_FLEXRAY_UNSPEC,
+	IFLA_FLEXRAY_STATE,
+	IFLA_FLEXRAY_VERSION,
+	IFLA_FLEXRAY_CLUSTER,
+	IFLA_FLEXRAY_NODE,
+	IFLA_FLEXRAY_SYMBOL,
+	IFLA_FLEXRAY_SW_FILTER,
+	__IFLA_FLEXRAY_MAX
+};
+
+#define IFLA_FLEXRAY_MAX    (__IFLA_FLEXRAY_MAX - 1)
+
+/*
+ * FlexRay filter netlink interface
+ */
+enum {
+	IFLA_FLEXRAY_FILTER_UNSPEC,
+	IFLA_FLEXRAY_FILTER_ENTRY,
+	__IFLA_FLEXRAY_FILTER_MAX
+};
+
+#define IFLA_FLEXRAY_FILTER_MAX    (__IFLA_FLEXRAY_FILTER_MAX - 1)
+
+struct cluster_v2 {
+	__u16 gAssumedPrecision;
+	__u8 gdMaxInitializationError;
+	__u8 gdMaxMicrotick;
+	__u8 gdMaxPropagationDelay;
+	__u8 gdMinPropagationDelay;
+	__u8 gdWakeupSymbolRxIdle;
+	__u8 gdWakeupSymbolRxLow;
+	__u16 gdWakeupSymbolRxWindow;
+	__u8 gdWakeupSymbolTxIdle;
+	__u8 gdWakeupSymbolTxLow;
+	__u32 gOffsetCorrectionMax;
+	__u16 gOffsetCorrectionStart;
+	__u8 gSyncNodeMax;
+};
+
+struct cluster_v3 {
+	__u16 gClockDeviationMax;
+	__u8 gCycleCountMax;
+	__u8 gdIgnoreAfterTx;
+	__u8 gdSymbolWindowActionPointOffset;
+	__u8 gdWakeupRxIdle;
+	__u8 gdWakeupRxLow;
+	__u16 gdWakeupRxWindow;
+	__u8 gdWakeupTxActive;
+	__u8 gdWakeupTxIdle;
+	__u8 gExternOffsetCorrection;
+	__u8 gExternRateCorrection;
+	__u8 gSyncFrameIDCountMax;
+};
+
+struct flexray_cluster_param {
+	/* Protocol relevant */
+	__u8 gColdstartAttempts;
+	__u8 gdActionPointOffset;
+	__u8 gdCASRxLowMax;
+	__u8 gdDynamicSlotIdlePhase;
+	__u8 gdMinislot;
+	__u8 gdMinislotActionPointOffset;
+	__u16 gdStaticSlot;
+	__u8 gdSymbolWindow;
+	__u8 gdTSSTransmitter;
+	__u8 gListenNoise;
+	__u16 gMacroPerCycle;
+	__u8 gMaxWithoutClockCorrectionFatal;
+	__u8 gMaxWithoutClockCorrectionPassive;
+	__u16 gNumberOfMinislots;
+	__u16 gNumberOfStaticSlots;
+	__u8 gPayloadLengthStatic;
+
+	/* Protocol related */
+	__u8 gChannels;
+	__u8 gClusterDriftDamping;
+	__u8 gdBit;
+	__u16 gdCycle;
+	__u8 gdMacrotick;
+	__u16 gdNIT;
+	__u8 gdSampleClockPeriod;
+	__u8 gNetworkManagementVectorLength;
+	union {
+		struct cluster_v2 v2;
+		struct cluster_v3 v3;
+	};
+};
+
+struct node_v2 {
+	__u16 pdMaxDrift;
+	__u8 pMicroPerMacroNom;
+	__u8 pSingleSlotEnabled;
+};
+
+struct node_v3 {
+	__u8 pExternalSync;
+	__u8 pFallBackInternal;
+	__u8 pKeySlotOnlyEnabled;
+	__u8 pNMVectorEarlyUpdate;
+	__u8 pOffsetCorrectionStart;
+	__u8 pSecondKeySlotID;
+	__u8 pTwoKeySlotMode;
+};
+
+struct flexray_node_param {
+	/* Protocol relevant */
+	__u8 pAllowHaltDueToClock;
+	__u8 pAllowPassiveToActive;
+	__u8 pChannels;
+	__u8 pClusterDriftDamping;
+	__u16 pdAcceptedStartupRange;
+	__u8 pDecodingCorrection;
+	__u8 pDelayCompensationA;
+	__u8 pDelayCompensationB;
+	__u32 pdListenTimeout;
+	__s8 vExternOffsetControl;
+	__s8 vExternRateControl;
+	__u8 pExternOffsetCorrection;
+	__u8 pExternRateCorrection;
+	__u16 pKeySlotID;
+	__u8 pKeySlotUsedForStartup;
+	__u8 pKeySlotUsedForSync;
+	__u16 pLatestTx;
+	__u8 pMacroInitialOffsetA;
+	__u8 pMacroInitialOffsetB;
+	__u16 pMicroInitialOffsetA;
+	__u16 pMicroInitialOffsetB;
+	__u32 pMicroPerCycle;
+	__u16 pOffsetCorrectionOut;
+	__u16 pRateCorrectionOut;
+	__u8 pWakeupChannel;
+	__u8 pWakeupPattern;
+
+	/* Protocol related */
+	__u8 pdMicrotick;
+	__u8 pPayloadLengthDynMax;
+	__u8 pSamplesPerMicrotick;
+
+	union {
+		struct node_v2 v2;
+		struct node_v3 v3;
+	};
+};
+
+struct flexray_symbol_param {
+	/* Protocol related */
+	__u8 pChannelsMTS;
+};
+
+/*
+ * FlexRay software ID filter
+ */
+
+struct flexray_sw_filter {
+	__u32 pos;
+	__u32 id;
+};
+
+#endif /* FLEXRAY_NETLINK_H */
diff --git a/include/uapi/linux/flexray/raw.h b/include/uapi/linux/flex=
ray/raw.h
new file mode 100644
index 0000000..0b12068
--- /dev/null
+++ b/include/uapi/linux/flexray/raw.h
@@ -0,0 +1,16 @@
+/*
+ * Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ */
+
+#ifndef FLEXRAY_RAW_H
+#define FLEXRAY_RAW_H
+
+#include <linux/flexray.h>
+
+/* for socket options affecting the socket (not the global system) */
+
+enum {
+	FLEXRAY_RAW_FILTER =3D 1,     /* set 0 .. n can_filter(s) */
+};
+
+#endif
diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index d7fea34..d64971f 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -53,6 +53,7 @@
 #define ARPHRD_X25	271		/* CCITT X.25			*/
 #define ARPHRD_HWX25	272		/* Boards with X.25 in firmware	*/
 #define ARPHRD_CAN	280		/* Controller Area Network      */
+#define ARPHRD_FLEXRAY	290		/* FlexRay			*/
 #define ARPHRD_PPP	512
 #define ARPHRD_CISCO	513		/* Cisco HDLC	 		*/
 #define ARPHRD_HDLC	ARPHRD_CISCO
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ethe=
r.h
index ade07f1..05e886e 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -112,6 +112,7 @@
 #define ETH_P_LOCALTALK 0x0009		/* Localtalk pseudo type 	*/
 #define ETH_P_CAN	0x000C		/* CAN: Controller Area Network */
 #define ETH_P_CANFD	0x000D		/* CANFD: CAN flexible data rate*/
+#define ETH_P_FLEXRAY	0x000F		/* Flexray			*/
 #define ETH_P_PPPTALK	0x0010		/* Dummy type for Atalk over PPP*/
 #define ETH_P_TR_802_2	0x0011		/* 802.2 frames 		*/
 #define ETH_P_MOBITEX	0x0015		/* Mobitex (kaz@cafe.net)	*/
diff --git a/net/Kconfig b/net/Kconfig
index ee02136..8b7e604 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -328,6 +328,7 @@ endmenu
=20
 source "net/ax25/Kconfig"
 source "net/can/Kconfig"
+source "net/flexray/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index 9492e8c..8d03e63 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -32,6 +32,7 @@ obj-$(CONFIG_NETROM)		+=3D netrom/
 obj-$(CONFIG_ROSE)		+=3D rose/
 obj-$(CONFIG_AX25)		+=3D ax25/
 obj-$(CONFIG_CAN)		+=3D can/
+obj-$(CONFIG_FLEXRAY)		+=3D flexray/
 obj-$(CONFIG_IRDA)		+=3D irda/
 obj-$(CONFIG_BT)		+=3D bluetooth/
 obj-$(CONFIG_SUNRPC)		+=3D sunrpc/
diff --git a/net/core/sock.c b/net/core/sock.c
index 83667de..820e44e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -213,7 +213,8 @@ static const char *const af_family_key_strings[AF_M=
AX+1] =3D {
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
-  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_MAX"
+  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_FLEXRAY"  ,
+  "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] =3D {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -229,7 +230,8 @@ static const char *const af_family_slock_key_string=
s[AF_MAX+1] =3D {
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
-  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_MAX"
+  "slock-AF_NFC"   , "slock-AF_VSOCK"    , "slock-AF_FLEXRAY"  ,
+  "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] =3D {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -245,7 +247,8 @@ static const char *const af_family_clock_key_string=
s[AF_MAX+1] =3D {
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
-  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_MAX"
+  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_FLEXRAY"  ,
+  "clock-AF_MAX"
 };
=20
 /*
diff --git a/net/flexray/Kconfig b/net/flexray/Kconfig
new file mode 100644
index 0000000..18d9d69
--- /dev/null
+++ b/net/flexray/Kconfig
@@ -0,0 +1,28 @@
+#
+# FlexRay network layer core configuration
+#
+
+menuconfig FLEXRAY
+	depends on NET
+	tristate "FlexRay bus subsystem support"
+	---help---
+	  FlexRay is a slow (up to 10Mbit/s) serial communications
+	  protocol which was developed by the FlexRay Consortium, a
+	  cooperation of leading companies in the automotive industry, from
+	  2000 till 2010, which result in ISO 10681.
+	  More information on the FlexRay network protocol family PF_FLEXRAY
+	  is contained in <Documentation/networking/flexray.txt>.
+
+	  If you want FLEXRAY support you should say Y here and also to the
+	  specific driver for your controller(s) below.
+
+config FLEXRAY_RAW
+	tristate "Raw FlexRay Protocol"
+	depends on FLEXRAY
+	default N
+	---help---
+	  The raw FlexRay protocol option offers access to the FlexRay bus
+	  via the BSD socket API. You probably want to use the raw socket in
+	  most cases where no higher level protocol is being used.
+	  To receive/send raw FLEXRAY messages, use AF_FLEXRAY with protocol
+	  FLEXRAY_RAW.
diff --git a/net/flexray/Makefile b/net/flexray/Makefile
new file mode 100644
index 0000000..f5e05b6c
--- /dev/null
+++ b/net/flexray/Makefile
@@ -0,0 +1,9 @@
+#
+#  Makefile for the Linux FlexRay core.
+#
+
+obj-$(CONFIG_FLEXRAY)		+=3D flexray.o
+flexray-y			:=3D af_flexray.o proc.o
+
+obj-$(CONFIG_FLEXRAY_RAW)	+=3D flexray-raw.o
+flexray-raw-y			:=3D raw.o
diff --git a/net/flexray/af_flexray.c b/net/flexray/af_flexray.c
new file mode 100644
index 0000000..e5fd1c4
--- /dev/null
+++ b/net/flexray/af_flexray.c
@@ -0,0 +1,548 @@
+/* Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kmod.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/rcupdate.h>
+#include <linux/uaccess.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/socket.h>
+#include <linux/if_ether.h>
+#include <linux/if_arp.h>
+#include <linux/skbuff.h>
+#include <linux/flexray.h>
+#include <linux/flexray/core.h>
+#include <linux/flexray/dev.h>
+#include <linux/ratelimit.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include "af_flexray.h"
+
+/* receive filters subscribed for 'all' FlexRay devices */
+struct dev_rcv_lists flexray_rx_alldev_list;
+static DEFINE_SPINLOCK(flexray_rcvlists_lock);
+
+static struct kmem_cache *rcv_cache __read_mostly;
+
+/* table of registered FlexRay protocols */
+static const struct flexray_proto *proto_tab[FLEXRAY_NPROTO] __read_mo=
stly;
+static DEFINE_MUTEX(proto_tab_lock);
+
+struct s_stats	flexray_stats;	/* packet statistics */
+struct s_pstats	flexray_pstats;	/* receive list statistics */
+
+/* af_flexray socket functions */
+
+int flexray_ioctl(struct socket *sock, unsigned int cmd, unsigned long=
 arg)
+{
+	struct sock *sk =3D sock->sk;
+
+	switch (cmd) {
+
+	case SIOCGSTAMP:
+		return sock_get_timestamp(sk, (struct timeval __user *)arg);
+
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+EXPORT_SYMBOL(flexray_ioctl);
+
+static void flexray_sock_destruct(struct sock *sk)
+{
+	skb_queue_purge(&sk->sk_receive_queue);
+}
+
+static const struct flexray_proto *flexray_get_proto(int protocol)
+{
+	const struct flexray_proto *frp;
+
+	rcu_read_lock();
+	frp =3D rcu_dereference(proto_tab[protocol]);
+	if (frp && !try_module_get(frp->prot->owner))
+		frp =3D NULL;
+	rcu_read_unlock();
+
+	return frp;
+}
+
+static inline void flexray_put_proto(const struct flexray_proto *frp)
+{
+	module_put(frp->prot->owner);
+}
+
+static int flexray_create(struct net *net, struct socket *sock, int pr=
otocol,
+			  int kern)
+{
+	struct sock *sk;
+	const struct flexray_proto *frp;
+	int err =3D 0;
+
+	sock->state =3D SS_UNCONNECTED;
+
+	if (protocol < 0 || protocol >=3D FLEXRAY_NPROTO)
+		return -EINVAL;
+
+	if (!net_eq(net, &init_net))
+		return -EAFNOSUPPORT;
+
+	frp =3D flexray_get_proto(protocol);
+
+#ifdef CONFIG_MODULES
+	if (!frp) {
+		request_module("flexray-proto-%d", protocol);
+		frp =3D flexray_get_proto(protocol);
+	}
+#endif
+	/* check for available protocol and correct usage */
+	if (!frp)
+		return -EPROTONOSUPPORT;
+
+	if (frp->type !=3D sock->type) {
+		err =3D -EPROTOTYPE;
+		goto errout;
+	}
+
+	sock->ops =3D frp->ops;
+
+	sk =3D sk_alloc(net, PF_FLEXRAY, GFP_KERNEL, frp->prot);
+	if (!sk) {
+		err =3D -ENOMEM;
+		goto errout;
+	}
+
+	sock_init_data(sock, sk);
+	sk->sk_destruct =3D flexray_sock_destruct;
+
+	if (sk->sk_prot->init)
+		err =3D sk->sk_prot->init(sk);
+
+	if (err) {
+		/* release sk on errors */
+		sock_orphan(sk);
+		sock_put(sk);
+	}
+
+errout:
+	flexray_put_proto(frp);
+	return err;
+}
+
+/**
+ * flexray_send - transmit a FlexRay frame
+ * @skb: pointer to socket buffer with FlexRay frame in data section
+ *
+ * Return:
+ *  0 on success
+ *  -ENETDOWN when the selected interface is down
+ *  -ENOBUFS on full driver queue (see net_xmit_errno())
+ *  -EPERM when trying to send on a non-FlexRay interface
+ *  -EINVAL when the skb->data does not contain a valid FlexRay frame
+ *  The skb is always consumed.
+ */
+int flexray_send(struct sk_buff *skb)
+{
+	struct flexray_priv *priv;
+	int err;
+
+	priv =3D netdev_priv(skb->dev);
+
+	if (skb->dev->type !=3D ARPHRD_FLEXRAY) {
+		err =3D -EPERM;
+		goto err_skb;
+	}
+
+	if (!(skb->dev->flags & IFF_UP)) {
+		err =3D -ENETDOWN;
+		goto err_skb;
+	}
+
+	if (!priv->do_validate) {
+		err =3D -EINVAL;
+		goto err_skb;
+	}
+
+	err =3D priv->do_validate(skb);
+	if (err)
+		goto err_skb;
+
+	skb->protocol =3D htons(ETH_P_FLEXRAY);
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+
+	skb->pkt_type =3D PACKET_HOST;
+
+	/* send to netdevice */
+	err =3D dev_queue_xmit(skb);
+	if (err > 0) {
+		err =3D net_xmit_errno(err);
+		return err;
+	}
+
+	/* update statistics */
+	flexray_stats.tx_frames++;
+
+	return 0;
+err_skb:
+	kfree_skb(skb);
+	return err;
+}
+EXPORT_SYMBOL(flexray_send);
+
+/* af_flexray rx path */
+
+static struct dev_rcv_lists *find_dev_rcv_lists(struct net_device *dev=
)
+{
+	if (!dev)
+		return &flexray_rx_alldev_list;
+	else
+		return (struct dev_rcv_lists *)dev->ml_priv;
+}
+
+int flexray_rx_register(struct net_device *dev,
+			void (*func)(struct sk_buff *, void *),
+			void *data, char *ident)
+{
+	struct receiver *r;
+	struct dev_rcv_lists *d;
+	int err =3D 0;
+
+	if (dev && dev->type !=3D ARPHRD_FLEXRAY)
+		return -ENODEV;
+
+	r =3D kmem_cache_alloc(rcv_cache, GFP_KERNEL);
+	if (!r)
+		return -ENOMEM;
+
+	spin_lock(&flexray_rcvlists_lock);
+
+	d =3D find_dev_rcv_lists(dev);
+	if (d) {
+		r->func		=3D func;
+		r->data		=3D data;
+		r->ident	=3D ident;
+
+		hlist_add_head_rcu(&r->list, &d->rx[RX_ALL]);
+		d->entries++;
+
+		flexray_pstats.rcv_entries++;
+		if (flexray_pstats.rcv_entries_max < flexray_pstats.rcv_entries)
+			flexray_pstats.rcv_entries_max =3D
+				flexray_pstats.rcv_entries;
+	} else {
+		kmem_cache_free(rcv_cache, r);
+		err =3D -ENODEV;
+	}
+
+	spin_unlock(&flexray_rcvlists_lock);
+
+	return err;
+}
+EXPORT_SYMBOL(flexray_rx_register);
+
+static void flexray_rx_delete_receiver(struct rcu_head *rp)
+{
+	struct receiver *r =3D container_of(rp, struct receiver, rcu);
+
+	kmem_cache_free(rcv_cache, r);
+}
+
+void flexray_rx_unregister(struct net_device *dev,
+			   void (*func)(struct sk_buff *, void *), void *data)
+{
+	struct receiver *r =3D NULL;
+	struct hlist_head *rl;
+	struct dev_rcv_lists *d;
+	bool found =3D false;
+
+	if (dev && dev->type !=3D ARPHRD_FLEXRAY)
+		return;
+
+	spin_lock(&flexray_rcvlists_lock);
+
+	d =3D find_dev_rcv_lists(dev);
+	if (!d) {
+		netdev_err(dev, "BUG: receive list not found\n");
+		goto out;
+	}
+
+	rl =3D &d->rx[RX_ALL];
+
+	/* Search the receiver list for the item to delete. This should
+	 * exist, since no receiver may be unregistered that hasn't
+	 * been registered before.
+	 */
+
+	hlist_for_each_entry_rcu(r, rl, list) {
+		if (r->func =3D=3D func && r->data =3D=3D data) {
+			found =3D true;
+			break;
+		}
+	}
+
+	if (!found) {
+		netdev_err(dev, "BUG: receive list entry not found\n");
+		r =3D NULL;
+		goto out;
+	}
+
+	hlist_del_rcu(&r->list);
+	d->entries--;
+
+	if (flexray_pstats.rcv_entries > 0)
+		flexray_pstats.rcv_entries--;
+
+	/* remove device structure requested by NETDEV_UNREGISTER */
+	if (d->remove_on_zero_entries && !d->entries) {
+		kfree(d);
+		dev->ml_priv =3D NULL;
+	}
+
+out:
+	spin_unlock(&flexray_rcvlists_lock);
+
+	/* schedule the receiver item for deletion */
+	if (r)
+		call_rcu(&r->rcu, flexray_rx_delete_receiver);
+}
+EXPORT_SYMBOL(flexray_rx_unregister);
+
+static inline void deliver(struct sk_buff *skb, struct receiver *r)
+{
+	r->func(skb, r->data);
+}
+
+static int flexray_rcv_filter(struct dev_rcv_lists *d, struct sk_buff =
*skb)
+{
+	struct receiver *r;
+	int matches =3D 0;
+
+	if (d->entries =3D=3D 0)
+		return 0;
+
+	/* check for unfiltered entries */
+	hlist_for_each_entry_rcu(r, &d->rx[RX_ALL], list) {
+		deliver(skb, r);
+		matches++;
+	}
+
+	return matches;
+}
+
+static int flexray_rcv(struct sk_buff *skb, struct net_device *dev,
+		       struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dev_rcv_lists *d;
+	struct flexray_frame *frf =3D (struct flexray_frame *)skb->data;
+	int matches;
+
+	if (!net_eq(dev_net(dev), &init_net))
+		goto drop;
+
+	if (WARN_ONCE(dev->type !=3D ARPHRD_FLEXRAY,
+		      "PF_FLEXRAY: dropped non conform skbuf: "
+		      "dev type %d, len %d, payload %d\n",
+		      dev->type, skb->len, flexray_get_pl(frf->head)))
+		goto drop;
+
+	/* update statistics */
+	flexray_stats.rx_frames++;
+
+	rcu_read_lock();
+
+	/* deliver the packet to sockets listening on all devices */
+	matches =3D flexray_rcv_filter(&flexray_rx_alldev_list, skb);
+
+	/* find receive list for this device */
+	d =3D find_dev_rcv_lists(dev);
+	if (d)
+		matches +=3D flexray_rcv_filter(d, skb);
+
+	rcu_read_unlock();
+
+	/* consume the skbuff allocated by the netdevice driver */
+	consume_skb(skb);
+
+	if (matches > 0)
+		flexray_stats.matches++;
+
+	return NET_RX_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+/* af_flexray protocol functions */
+int flexray_proto_register(const struct flexray_proto *frp)
+{
+	int proto =3D frp->protocol;
+	int err =3D 0;
+
+	if (proto < 0 || proto >=3D FLEXRAY_NPROTO) {
+		pr_err("flexray: protocol number %d out of range\n", proto);
+		return -EINVAL;
+	}
+
+	err =3D proto_register(frp->prot, 0);
+	if (err < 0)
+		return err;
+
+	mutex_lock(&proto_tab_lock);
+
+	if (proto_tab[proto]) {
+		pr_err("flexray: protocol %d already registered\n",
+		       proto);
+		err =3D -EBUSY;
+	} else
+		rcu_assign_pointer(proto_tab[proto], frp);
+
+	mutex_unlock(&proto_tab_lock);
+
+	if (err < 0)
+		proto_unregister(frp->prot);
+
+	return err;
+}
+EXPORT_SYMBOL(flexray_proto_register);
+
+void flexray_proto_unregister(const struct flexray_proto *frp)
+{
+	int proto =3D frp->protocol;
+
+	mutex_lock(&proto_tab_lock);
+	BUG_ON(proto_tab[proto] !=3D frp);
+	rcu_assign_pointer(proto_tab[proto], NULL);
+	mutex_unlock(&proto_tab_lock);
+
+	synchronize_rcu();
+
+	proto_unregister(frp->prot);
+}
+EXPORT_SYMBOL(flexray_proto_unregister);
+
+/* af_flexray notifier to create/remove FlexRay netdevice specific str=
ucts */
+static int flexray_notifier(struct notifier_block *nb, unsigned long m=
sg,
+			    void *data)
+{
+	struct net_device *dev =3D (struct net_device *)data;
+	struct dev_rcv_lists *d;
+
+	if (!net_eq(dev_net(dev), &init_net))
+		return NOTIFY_DONE;
+
+	if (dev->type !=3D ARPHRD_FLEXRAY)
+		return NOTIFY_DONE;
+
+	switch (msg) {
+
+	case NETDEV_REGISTER:
+		/* create new dev_rcv_lists for this device */
+		d =3D kzalloc(sizeof(*d), GFP_KERNEL);
+		if (!d) {
+			netdev_err(dev, "allocation of receive list failed\n");
+			return NOTIFY_DONE;
+		}
+		BUG_ON(dev->ml_priv);
+		dev->ml_priv =3D d;
+
+		break;
+
+	case NETDEV_UNREGISTER:
+		spin_lock(&flexray_rcvlists_lock);
+
+		d =3D dev->ml_priv;
+		if (d) {
+			if (d->entries)
+				d->remove_on_zero_entries =3D 1;
+			else {
+				kfree(d);
+				dev->ml_priv =3D NULL;
+			}
+		} else
+			netdev_err(dev, "notifier: receive list not found\n");
+
+		spin_unlock(&flexray_rcvlists_lock);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+/* af_flexray module init/exit functions */
+
+static struct packet_type flexray_packet __read_mostly =3D {
+	.type =3D cpu_to_be16(ETH_P_FLEXRAY),
+	.func =3D flexray_rcv,
+};
+
+static const struct net_proto_family flexray_family_ops =3D {
+	.family =3D PF_FLEXRAY,
+	.create =3D flexray_create,
+	.owner  =3D THIS_MODULE,
+};
+
+/* notifier block for netdevice event */
+static struct notifier_block flexray_netdev_notifier __read_mostly =3D=
 {
+	.notifier_call =3D flexray_notifier,
+};
+
+static __init int flexray_init(void)
+{
+	memset(&flexray_rx_alldev_list, 0, sizeof(flexray_rx_alldev_list));
+
+	rcv_cache =3D kmem_cache_create("flexray_receiver",
+				      sizeof(struct receiver), 0, 0, NULL);
+	if (!rcv_cache)
+		return -ENOMEM;
+
+	flexray_init_proc();
+
+	/* protocol register */
+	sock_register(&flexray_family_ops);
+	register_netdevice_notifier(&flexray_netdev_notifier);
+	dev_add_pack(&flexray_packet);
+	return 0;
+}
+module_init(flexray_init);
+
+static __exit void flexray_exit(void)
+{
+	struct net_device *dev;
+
+	flexray_remove_proc();
+
+	/* protocol unregister */
+	dev_remove_pack(&flexray_packet);
+	unregister_netdevice_notifier(&flexray_netdev_notifier);
+	sock_unregister(PF_FLEXRAY);
+
+	/* remove created dev_rcv_lists from still registered FlexRay devices=
 */
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
+		if (dev->type =3D=3D ARPHRD_FLEXRAY && dev->ml_priv) {
+			struct dev_rcv_lists *d =3D dev->ml_priv;
+
+			BUG_ON(d->entries);
+			kfree(d);
+			dev->ml_priv =3D NULL;
+		}
+	}
+	rcu_read_unlock();
+
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
+
+	kmem_cache_destroy(rcv_cache);
+}
+module_exit(flexray_exit);
+
+MODULE_DESCRIPTION("FlexRay PF_FLEXRAY core");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
+
+MODULE_ALIAS_NETPROTO(PF_FLEXRAY);
diff --git a/net/flexray/af_flexray.h b/net/flexray/af_flexray.h
new file mode 100644
index 0000000..5aec894
--- /dev/null
+++ b/net/flexray/af_flexray.h
@@ -0,0 +1,59 @@
+/* Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved */
+
+#ifndef AF_FLEXRAY_H
+#define AF_FLEXRAY_H
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/list.h>
+#include <linux/rcupdate.h>
+#include <linux/flexray.h>
+
+/* af_flexray rx dispatcher structures */
+
+struct receiver {
+	struct hlist_node list;
+	struct rcu_head rcu;
+	void (*func)(struct sk_buff *, void *);
+	void *data;
+	char *ident;
+};
+
+enum {RX_ALL, RX_MAX};
+
+/* per device receive filters linked at dev->ml_priv */
+struct dev_rcv_lists {
+	struct hlist_head rx[RX_MAX];
+	struct hlist_head rx_sff[0x800];
+	int remove_on_zero_entries;
+	int entries;
+};
+
+/* can be reset e.g. by flexray_init_stats() */
+struct s_stats {
+	unsigned long rx_frames;
+	unsigned long tx_frames;
+	unsigned long matches;
+};
+
+/* persistent statistics */
+struct s_pstats {
+	unsigned long stats_reset;
+	unsigned long user_reset;
+	unsigned long rcv_entries;
+	unsigned long rcv_entries_max;
+};
+
+/* function prototypes for the FlexRay networklayer procfs (proc.c) */
+extern void flexray_init_proc(void);
+extern void flexray_remove_proc(void);
+extern void flexray_stat_update(unsigned long data);
+
+/* structures and variables from af_flexray.c needed in proc.c for rea=
ding */
+extern struct s_stats	flexray_stats;		/* packet statistics */
+extern struct s_pstats	flexray_pstats;		/* receive list statistics */
+extern struct hlist_head flexray_rx_dev_list;	/* rx dispatcher structu=
res */
+/* receive filters subscribed for 'all' FlexRay devices */
+extern struct dev_rcv_lists flexray_rx_alldev_list;
+
+#endif /* AF_FLEXRAY_H */
diff --git a/net/flexray/proc.c b/net/flexray/proc.c
new file mode 100644
index 0000000..e82f844
--- /dev/null
+++ b/net/flexray/proc.c
@@ -0,0 +1,196 @@
+/* Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved */
+
+#include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/list.h>
+#include <linux/rcupdate.h>
+#include <linux/if_arp.h>
+#include <linux/flexray/core.h>
+
+#include "af_flexray.h"
+
+/* proc filenames for the PF_FLEXRAY core */
+
+#define FLEXRAY_PROC_STATS       "stats"
+#define FLEXRAY_PROC_RESET_STATS "reset_stats"
+#define FLEXRAY_PROC_RCVLIST_ALL "rcvlist_all"
+#define FLEXRAY_PROC_RCVLIST_FIL "rcvlist_fil"
+
+static struct proc_dir_entry *flexray_dir;
+static struct proc_dir_entry *pde_stats;
+static struct proc_dir_entry *pde_reset_stats;
+static struct proc_dir_entry *pde_rcvlist_all;
+
+static const char rx_list_name[][8] =3D {
+	[RX_ALL] =3D "rx_all",
+};
+
+static void flexray_print_rcvlist(struct seq_file *m,
+				  struct hlist_head *rx_list,
+				  struct net_device *dev)
+{
+	struct receiver *r;
+
+	hlist_for_each_entry_rcu(r, rx_list, list)
+		seq_printf(m, "   %-5s     %pK  %pK  %s\n",
+				DNAME(dev), r->func, r->data, r->ident);
+}
+
+static void flexray_print_recv_banner(struct seq_file *m)
+{
+	seq_puts(m, "  device   flexray_id   flexray_mask  function"
+		 "  userdata   matches  ident\n");
+}
+
+static int flexray_stats_proc_show(struct seq_file *m, void *v)
+{
+	seq_putc(m, '\n');
+	seq_printf(m, " %8ld transmitted frames (TXF)\n",
+		   flexray_stats.tx_frames);
+	seq_printf(m, " %8ld received frames (RXF)\n",
+		   flexray_stats.rx_frames);
+	seq_printf(m, " %8ld matched frames (RXMF)\n",
+		   flexray_stats.matches);
+
+	seq_putc(m, '\n');
+
+	seq_printf(m, " %8ld current receive list entries (CRCV)\n",
+		   flexray_pstats.rcv_entries);
+	seq_printf(m, " %8ld maximum receive list entries (MRCV)\n",
+		   flexray_pstats.rcv_entries_max);
+
+	if (flexray_pstats.stats_reset)
+		seq_printf(m, "\n %8ld statistic resets (STR)\n",
+			   flexray_pstats.stats_reset);
+
+	if (flexray_pstats.user_reset)
+		seq_printf(m, " %8ld user statistic resets (USTR)\n",
+			   flexray_pstats.user_reset);
+
+	seq_putc(m, '\n');
+	return 0;
+}
+
+static int flexray_stats_proc_open(struct inode *inode, struct file *f=
ile)
+{
+	return single_open(file, flexray_stats_proc_show, NULL);
+}
+
+static const struct file_operations flexray_stats_proc_fops =3D {
+	.owner		=3D THIS_MODULE,
+	.open		=3D flexray_stats_proc_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D single_release,
+};
+
+static int flexray_reset_stats_proc_show(struct seq_file *m, void *v)
+{
+	seq_printf(m, "Performed statistic reset #%ld.\n",
+		   flexray_pstats.stats_reset);
+
+	return 0;
+}
+
+static int flexray_reset_stats_proc_open(struct inode *inode,
+					 struct file *file)
+{
+	return single_open(file, flexray_reset_stats_proc_show, NULL);
+}
+
+static const struct file_operations flexray_reset_stats_proc_fops =3D =
{
+	.owner		=3D THIS_MODULE,
+	.open		=3D flexray_reset_stats_proc_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D single_release,
+};
+
+static void flexray_rcvlist_proc_show_one(struct seq_file *m, int idx,
+						 struct net_device *dev,
+						 struct dev_rcv_lists *d)
+{
+	if (!hlist_empty(&d->rx[idx])) {
+		flexray_print_recv_banner(m);
+		flexray_print_rcvlist(m, &d->rx[idx], dev);
+	} else
+		seq_printf(m, "  (%s: no entry)\n", DNAME(dev));
+}
+
+static int flexray_rcvlist_proc_show(struct seq_file *m, void *v)
+{
+	int idx =3D (int)(long)m->private;
+	struct net_device *dev;
+	struct dev_rcv_lists *d;
+
+	seq_printf(m, "\nreceive list '%s':\n", rx_list_name[idx]);
+
+	rcu_read_lock();
+
+	/* receive list for 'all' FlexRay devices (dev =3D=3D NULL) */
+	d =3D &flexray_rx_alldev_list;
+	flexray_rcvlist_proc_show_one(m, idx, NULL, d);
+
+	/* receive list for registered FlexRay devices */
+	for_each_netdev_rcu(&init_net, dev) {
+		if (dev->type =3D=3D ARPHRD_FLEXRAY && dev->ml_priv)
+			flexray_rcvlist_proc_show_one(m, idx, dev,
+						      dev->ml_priv);
+	}
+
+	rcu_read_unlock();
+
+	seq_putc(m, '\n');
+	return 0;
+}
+
+static int flexray_rcvlist_proc_open(struct inode *inode, struct file =
*file)
+{
+	return single_open(file, flexray_rcvlist_proc_show, PDE_DATA(inode));
+}
+
+static const struct file_operations flexray_rcvlist_proc_fops =3D {
+	.owner		=3D THIS_MODULE,
+	.open		=3D flexray_rcvlist_proc_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D single_release,
+};
+
+static void flexray_remove_proc_readentry(const char *name)
+{
+	remove_proc_entry(name, flexray_dir);
+}
+
+void flexray_init_proc(void)
+{
+	int perm =3D S_IRUGO | S_IWUSR;
+
+	flexray_dir =3D proc_mkdir("flexray", init_net.proc_net);
+	if (!flexray_dir)
+		return;
+
+	pde_stats =3D proc_create(FLEXRAY_PROC_STATS, perm, flexray_dir,
+			&flexray_stats_proc_fops);
+	pde_reset_stats =3D proc_create(FLEXRAY_PROC_RESET_STATS, perm,
+			flexray_dir, &flexray_reset_stats_proc_fops);
+	pde_rcvlist_all =3D proc_create_data(FLEXRAY_PROC_RCVLIST_ALL, perm,
+			flexray_dir, &flexray_rcvlist_proc_fops,
+			(void *)RX_ALL);
+}
+
+void flexray_remove_proc(void)
+{
+	if (!flexray_dir)
+		return;
+	if (pde_stats)
+		flexray_remove_proc_readentry(FLEXRAY_PROC_STATS);
+
+	if (pde_reset_stats)
+		flexray_remove_proc_readentry(FLEXRAY_PROC_RESET_STATS);
+
+	if (pde_rcvlist_all)
+		flexray_remove_proc_readentry(FLEXRAY_PROC_RCVLIST_ALL);
+
+	remove_proc_entry("flexray", init_net.proc_net);
+}
diff --git a/net/flexray/raw.c b/net/flexray/raw.c
new file mode 100644
index 0000000..78fd0de
--- /dev/null
+++ b/net/flexray/raw.c
@@ -0,0 +1,446 @@
+/* Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/uio.h>
+#include <linux/net.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <linux/socket.h>
+#include <linux/if_arp.h>
+#include <linux/skbuff.h>
+#include <linux/flexray.h>
+#include <linux/flexray/core.h>
+#include <linux/flexray/raw.h>
+#include <net/sock.h>
+#include <net/net_namespace.h>
+
+#define MASK_ALL 0
+
+struct flexray_raw_sock {
+	struct sock sk;
+	int bound;
+	int ifindex;
+	struct notifier_block notifier;
+	struct flexray_filter dfilter;	/* default/single filter */
+};
+
+static inline unsigned int *raw_flags(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) <=3D (sizeof(struct sockaddr_flexray) +
+					 sizeof(unsigned int)));
+
+	/* return pointer after struct sockaddr_flexray */
+	return (unsigned int *)(&((struct sockaddr_flexray *)skb->cb)[1]);
+}
+
+static inline struct flexray_raw_sock *raw_sk(const struct sock *sk)
+{
+	return (struct flexray_raw_sock *)sk;
+}
+
+static void raw_rcv(struct sk_buff *oskb, void *data)
+{
+	struct sock *sk =3D (struct sock *)data;
+	struct sockaddr_flexray *addr;
+	struct sk_buff *skb;
+	unsigned int *pflags;
+
+	/* check the received tx sock reference */
+	if (oskb->sk =3D=3D sk)
+		return;
+
+	/* clone the given skb to be able to enqueue it into the rcv queue */
+	skb =3D skb_clone(oskb, GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	/*  Put the datagram to the queue so that raw_recvmsg() can
+	 *  get it from there.  We need to pass the interface index to
+	 *  raw_recvmsg().  We pass a whole struct sockaddr_flexray in skb->c=
b
+	 *  containing the interface index.
+	 */
+
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct sockaddr_flexray));
+	addr =3D (struct sockaddr_flexray *)skb->cb;
+	memset(addr, 0, sizeof(*addr));
+	addr->flexray_family  =3D AF_FLEXRAY;
+	addr->flexray_ifindex =3D skb->dev->ifindex;
+
+	/* add FlexRay specific message flags for raw_recvmsg() */
+	pflags =3D raw_flags(skb);
+	*pflags =3D 0;
+	if (oskb->sk)
+		*pflags |=3D MSG_DONTROUTE;
+	if (oskb->sk =3D=3D sk)
+		*pflags |=3D MSG_CONFIRM;
+
+	if (sock_queue_rcv_skb(sk, skb) < 0)
+		kfree_skb(skb);
+}
+
+static int raw_enable_allfilters(struct net_device *dev, struct sock *=
sk)
+{
+	return flexray_rx_register(dev, raw_rcv, sk, "raw");
+}
+
+static inline void raw_disable_allfilters(struct net_device *dev,
+					  struct sock *sk)
+{
+	flexray_rx_unregister(dev, raw_rcv, sk);
+}
+
+static struct flexray_raw_sock *nb_to_raw_sock(struct notifier_block *=
nb)
+{
+	return container_of(nb, struct flexray_raw_sock, notifier);
+}
+
+static int raw_notifier(struct notifier_block *nb,
+			unsigned long msg, void *data)
+{
+	struct net_device *dev =3D (struct net_device *)data;
+	struct flexray_raw_sock *ro =3D nb_to_raw_sock(nb);
+	struct sock *sk =3D &ro->sk;
+
+	if (!net_eq(dev_net(dev), &init_net))
+		return NOTIFY_DONE;
+
+	if (dev->type !=3D ARPHRD_FLEXRAY)
+		return NOTIFY_DONE;
+
+	if (ro->ifindex !=3D dev->ifindex)
+		return NOTIFY_DONE;
+
+	switch (msg) {
+
+	case NETDEV_UNREGISTER:
+		lock_sock(sk);
+		/* remove current filters & unregister */
+		if (ro->bound)
+			raw_disable_allfilters(dev, sk);
+
+		ro->ifindex =3D 0;
+		ro->bound   =3D 0;
+		release_sock(sk);
+
+		sk->sk_err =3D ENODEV;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_error_report(sk);
+		break;
+
+	case NETDEV_DOWN:
+		sk->sk_err =3D ENETDOWN;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_error_report(sk);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static int raw_init(struct sock *sk)
+{
+	struct flexray_raw_sock *ro =3D raw_sk(sk);
+
+	ro->bound			=3D 0;
+	ro->ifindex			=3D 0;
+
+	/* set notifier */
+	ro->notifier.notifier_call	=3D raw_notifier;
+
+	register_netdevice_notifier(&ro->notifier);
+
+	return 0;
+}
+
+static int raw_release(struct socket *sock)
+{
+	struct sock *sk =3D sock->sk;
+	struct flexray_raw_sock *ro;
+
+	if (!sk)
+		return 0;
+
+	ro =3D raw_sk(sk);
+
+	unregister_netdevice_notifier(&ro->notifier);
+
+	lock_sock(sk);
+
+	/* remove current filters & unregister */
+	if (ro->bound) {
+		if (ro->ifindex) {
+			struct net_device *dev;
+
+			dev =3D dev_get_by_index(&init_net, ro->ifindex);
+			if (dev) {
+				raw_disable_allfilters(dev, sk);
+				dev_put(dev);
+			}
+		} else
+			raw_disable_allfilters(NULL, sk);
+	}
+
+	ro->ifindex =3D 0;
+	ro->bound   =3D 0;
+
+	sock_orphan(sk);
+	sock->sk =3D NULL;
+
+	release_sock(sk);
+	sock_put(sk);
+
+	return 0;
+}
+
+static int raw_bind(struct socket *sock, struct sockaddr *uaddr, int l=
en)
+{
+	struct sockaddr_flexray *addr =3D (struct sockaddr_flexray *)uaddr;
+	struct sock *sk =3D sock->sk;
+	struct flexray_raw_sock *ro =3D raw_sk(sk);
+	int ifindex;
+	int err =3D 0;
+	int notify_enetdown =3D 0;
+
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	if (ro->bound && addr->flexray_ifindex =3D=3D ro->ifindex)
+		goto out;
+
+	if (addr->flexray_ifindex) {
+		struct net_device *dev;
+
+		dev =3D dev_get_by_index(&init_net, addr->flexray_ifindex);
+		if (!dev) {
+			err =3D -ENODEV;
+			goto out;
+		}
+
+		if (dev->type !=3D ARPHRD_FLEXRAY) {
+			dev_put(dev);
+			err =3D -ENODEV;
+			goto out;
+		}
+
+		if (!(dev->flags & IFF_UP))
+			notify_enetdown =3D 1;
+
+		ifindex =3D dev->ifindex;
+
+		/* filters set by default/setsockopt */
+		err =3D raw_enable_allfilters(dev, sk);
+
+		dev_put(dev);
+	} else {
+		ifindex =3D 0;
+
+		/* filters set by default/setsockopt */
+		err =3D raw_enable_allfilters(NULL, sk);
+	}
+
+	if (!err) {
+		if (ro->bound) {
+			/* unregister old filters */
+			if (ro->ifindex) {
+				struct net_device *dev;
+
+				dev =3D dev_get_by_index(&init_net, ro->ifindex);
+				if (dev) {
+					raw_disable_allfilters(dev, sk);
+					dev_put(dev);
+				}
+			} else
+				raw_disable_allfilters(NULL, sk);
+		}
+
+		ro->ifindex =3D ifindex;
+		ro->bound =3D 1;
+	}
+
+out:
+	release_sock(sk);
+
+	if (notify_enetdown) {
+		sk->sk_err =3D ENETDOWN;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_error_report(sk);
+	}
+
+	return err;
+}
+
+static int raw_getname(struct socket *sock, struct sockaddr *uaddr,
+		       int *len, int peer)
+{
+	struct sockaddr_flexray *addr =3D (struct sockaddr_flexray *)uaddr;
+	struct sock *sk =3D sock->sk;
+	struct flexray_raw_sock *ro =3D raw_sk(sk);
+
+	if (peer)
+		return -EOPNOTSUPP;
+
+	memset(addr, 0, sizeof(*addr));
+	addr->flexray_family  =3D AF_FLEXRAY;
+	addr->flexray_ifindex =3D ro->ifindex;
+
+	*len =3D sizeof(*addr);
+
+	return 0;
+}
+
+static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *msg, size_t size)
+{
+	struct sock *sk =3D sock->sk;
+	struct flexray_raw_sock *ro =3D raw_sk(sk);
+	struct sk_buff *skb;
+	struct net_device *dev;
+	int ifindex;
+	int err;
+
+	if (msg->msg_name) {
+		struct sockaddr_flexray *addr =3D
+			(struct sockaddr_flexray *)msg->msg_name;
+
+		if (msg->msg_namelen < sizeof(*addr))
+			return -EINVAL;
+
+		if (addr->flexray_family !=3D AF_FLEXRAY)
+			return -EINVAL;
+
+		ifindex =3D addr->flexray_ifindex;
+	} else
+		ifindex =3D ro->ifindex;
+
+	dev =3D dev_get_by_index(&init_net, ifindex);
+	if (!dev)
+		return -ENXIO;
+
+	skb =3D sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT,
+				  &err);
+	if (!skb)
+		goto put_dev;
+
+	err =3D memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	if (err < 0)
+		goto free_skb;
+
+	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+
+	skb->dev =3D dev;
+	skb->sk  =3D sk;
+
+	err =3D flexray_send(skb);
+	if (err)
+		goto put_dev;
+
+	dev_put(dev);
+
+	return size;
+
+free_skb:
+	kfree_skb(skb);
+put_dev:
+	dev_put(dev);
+
+	return err;
+}
+
+static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *msg, size_t size, int flags)
+{
+	struct sock *sk =3D sock->sk;
+	struct sk_buff *skb;
+	int err =3D 0;
+	int noblock;
+
+	noblock =3D  flags & MSG_DONTWAIT;
+	flags   &=3D ~MSG_DONTWAIT;
+
+	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		return err;
+
+	if (size < skb->len)
+		msg->msg_flags |=3D MSG_TRUNC;
+	else
+		size =3D skb->len;
+
+	err =3D memcpy_toiovec(msg->msg_iov, skb->data, size);
+	if (err < 0) {
+		skb_free_datagram(sk, skb);
+		return err;
+	}
+
+	sock_recv_ts_and_drops(msg, sk, skb);
+
+	if (msg->msg_name) {
+		msg->msg_namelen =3D sizeof(struct sockaddr_flexray);
+		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
+	}
+
+	/* assign the flags that have been recorded in raw_rcv() */
+	msg->msg_flags |=3D *(raw_flags(skb));
+
+	skb_free_datagram(sk, skb);
+
+	return size;
+}
+
+static const struct proto_ops raw_ops =3D {
+	.family		=3D PF_FLEXRAY,
+	.release	=3D raw_release,
+	.bind		=3D raw_bind,
+	.connect	=3D sock_no_connect,
+	.socketpair	=3D sock_no_socketpair,
+	.accept		=3D sock_no_accept,
+	.getname	=3D raw_getname,
+	.poll		=3D datagram_poll,
+	.ioctl		=3D flexray_ioctl,
+	.listen		=3D sock_no_listen,
+	.shutdown	=3D sock_no_shutdown,
+	.sendmsg	=3D raw_sendmsg,
+	.recvmsg	=3D raw_recvmsg,
+	.mmap		=3D sock_no_mmap,
+	.sendpage	=3D sock_no_sendpage,
+};
+
+static struct proto raw_proto __read_mostly =3D {
+	.name		=3D "FLEXRAY_RAW",
+	.owner		=3D THIS_MODULE,
+	.obj_size	=3D sizeof(struct flexray_raw_sock),
+	.init		=3D raw_init,
+};
+
+static const struct flexray_proto raw_flexray_proto =3D {
+	.type		=3D SOCK_RAW,
+	.protocol	=3D FLEXRAY_RAW,
+	.ops		=3D &raw_ops,
+	.prot		=3D &raw_proto,
+};
+
+static __init int raw_module_init(void)
+{
+	int err;
+
+	err =3D flexray_proto_register(&raw_flexray_proto);
+	if (err < 0)
+		pr_err("flexray: registration of raw protocol failed\n");
+
+	return err;
+}
+module_init(raw_module_init);
+
+static __exit void raw_module_exit(void)
+{
+	flexray_proto_unregister(&raw_flexray_proto);
+}
+module_exit(raw_module_exit);
+
+MODULE_DESCRIPTION("PF_FLEXRAY raw protocol");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
+MODULE_ALIAS("flexray-proto-1");
--=20
1.8.4.rc2
