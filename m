From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v2 02/12] net-caif: add CAIF socket and
 configuration headers
Date: Tue, 16 Feb 2010 14:46:47 +0100
Message-ID: <1266328017-28406-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1266328017-28406-1-git-send-email-sjur.brandeland@stericsson.com>
 <1266328017-28406-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	daniel.martensson@stericsson.com, kaber@trash.net,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:56525 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332Ab0BPNrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 08:47:36 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KXX00066SZ1VAD0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Tue, 16 Feb 2010 14:47:25 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KXX00DUYSYQXZJ0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Tue, 16 Feb 2010 14:47:17 +0100 (CET)
In-reply-to: <1266328017-28406-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Changes from PATCHv1:
- Updated to use kernel-doc-style comments.
- Removed CAIF IOCTL for creating CAIF net device.
- Removed CAIFSO_CHANNEL used to select device and set priority.
- Added use of socket options SO_PRIORITY and SO_BINDTODEVICE
- Added socket option CAIFSO_LINK_SELECT for link selection.

Add CAIF types for Socket Address, Socket Options,
and configuration parameters for the GPRS IP network interface.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/caif/caif_config.h |  163 +++++++++++++++++++++++++++++++
 include/linux/caif/caif_socket.h |  195 ++++++++++++++++++++++++++++++++++++++
 include/linux/caif/if_caif.h     |   34 +++++++
 3 files changed, 392 insertions(+), 0 deletions(-)

diff --git a/include/linux/caif/caif_config.h b/include/linux/caif/caif_config.h
new file mode 100644
index 0000000..2fb1cb3
--- /dev/null
+++ b/include/linux/caif/caif_config.h
@@ -0,0 +1,163 @@
+/*
+ * CAIF Channel Configuration definitions.
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_CONFIG_H_
+#define CAIF_CONFIG_H_
+#include <linux/caif/caif_socket.h>
+/*
+ *       This file is here for legacy reasons, definitions
+ *       in this files should be replaced with types from
+ *       caif_socket.h
+ */
+
+/*
+ * enum caif_phy_preference  -	Class of CAIF Link Layer.
+ * @CAIF_PHYPREF_UNSPECIFIED:	Default physical interface.
+ * @CAIF_PHYPREF_LOW_LAT:	Default physical interface for low-latency
+ *				traffic.
+ * @CAIF_PHYPREF_HIGH_BW:	Default physical interface for high-bandwidth
+ *				traffic.
+ * @CAIF_PHYPREF_LOOP:		TEST Loopback interface, simulating modem
+ *				responses.
+ *
+ * For client convenience, two special types are defined
+ * CAIF_PHYPREF_LOW_LAT is the preferred low-latency physical link.
+ * Typically used for "control" purposes.
+ * CAIF_PHYPREF_HIGH_BW is the preferred high-bandwidth physical link.
+ * Typically used for "payload" purposes.
+ *
+ * TODO:
+ * This enum should go away and be replaced by enum
+ * caif_link_selector defined in caif_socket.h
+ */
+enum caif_phy_preference {
+	CAIF_PHYPREF_UNSPECIFIED,
+	CAIF_PHYPREF_LOW_LAT,
+	CAIF_PHYPREF_HIGH_BW,
+	CAIF_PHYPREF_LOOP
+};
+
+
+/*
+ * enum caif_channel_type - Types of CAIF channel type defined in CAIF Stack.
+ * @CAIF_CHTY_AT:		Classical AT
+ * @CAIF_CHTY_AT_CTRL:		AT control only
+ * @CAIF_CHTY_AT_PAIRED:	Paired control and data
+ * @CAIF_CHTY_DATAGRAM:		Datagram. Requires: connection_id
+ * @CAIF_CHTY_DATAGRAM_LOOP:	Datagram loopback (testing purposes only)
+ * @CAIF_CHTY_VIDEO:		Video channel
+ * @CAIF_CHTY_DEBUG:		Debug service (Debug server and
+ *					       interactive debug)
+ * @CAIF_CHTY_DEBUG_TRACE:	Debug server only
+ * @CAIF_CHTY_DEBUG_INTERACT:	Debug interactive
+ * @CAIF_CHTY_RFM:		RFM service. Params: connection_id, volume
+ * @CAIF_CHTY_UTILITY:		Utility (Psock) service.
+ *				Params: fifo_kb,fifo_pkt, name, psock_param
+ *
+ * This is used for channel configuration, specifying the type of channel.
+ *
+ * TODO:
+ * This enum should go away and be replaced by
+ * enum caif_protoco_type defined in caif_socket.h
+ */
+enum caif_channel_type {
+	CAIF_CHTY_AT,
+	CAIF_CHTY_AT_CTRL,
+	CAIF_CHTY_AT_PAIRED,
+	CAIF_CHTY_DATAGRAM,
+	CAIF_CHTY_DATAGRAM_LOOP,
+	CAIF_CHTY_VIDEO,
+	CAIF_CHTY_DEBUG,
+	CAIF_CHTY_DEBUG_TRACE,
+	CAIF_CHTY_DEBUG_INTERACT,
+	CAIF_CHTY_RFM,
+	CAIF_CHTY_UTILITY
+};
+
+/*
+ *struct caif_channel_config - This structure is used for configuring
+ *			     CAIF channels.
+ * @name:		     Mandatory - Nickname for this device
+ * @type:		     Mandatory - Define the type of caif service
+ * @priority:		     Mandatory - Value between	CAIF_PRIO_MIN and
+ *			     CAIF_PRIO_MAX.
+ *			     CAIF_PRIO_LOW, CAIF_PRIO_NORMAL, CAIF_PRIO_HIGH
+ *			     are suggested values.
+ * @phy_pref:		     Either: Specify type of physical interface to use.
+ * @phy_name:		     Or: Specify identity of the physical interface.
+ *
+ * @u:			     Union of channel type-specific configuration
+ *			     parameters
+ *
+ * @u.dgm:		     CAIF_CHTYPE_DATAGRAM
+ *
+ * @u.dgm.connection_id:     Mandatory - Connection ID must be specified.
+ *
+ *
+ * @u.video:		     CAIF_CHTYPE_VIDEO
+ *
+ * @u.video.connection_id:   Mandatory - Connection ID must be specified.
+ *
+ * @u.rfm		     CAIF_CHTYPE_RFM
+ *
+ * @u.rfm.connection_id:     Mandatory - Connection ID must be specified.
+ *
+ * @u.rfm.volume:	     Mandatory - Volume to mount.
+ *
+ * @u.utility:		     CAIF_CHTYPE_UTILITY
+ *
+ * @u.utility.fifosize_kb:   Psock: FIFO size in KB
+ *
+ * @u.utility.fifosize_bufs: Psock: Number of signal buffers
+ *
+ * @u.utility.name:	     Psock: Name of service
+ *
+ * @u.utility.params:	     Psock: Channel config parameters
+ *
+ * @u.utility.paramlen:	     Psock: Length of channel config parameters
+ *
+ *
+ * It holds configuration parameters for setting up all defined CAIF
+ * channel types.
+ * The four first fields are mandatory, then physical interface can be specified
+ * either by name or by preferred characteristics.
+ * The rest of the configuration fields are held in a union for each
+ * channel type and are channel type specific.
+ *
+ * TODO:
+ * This struct should go away and be replaced by
+ * struct sockadd_caif in caif_socket.h
+ */
+struct caif_channel_config {
+	char name[16];
+	enum caif_channel_type type;
+	unsigned priority;
+	enum caif_phy_preference phy_pref;
+	char phy_name[16];
+	union {
+		struct {
+			unsigned connection_id;
+		} dgm;
+		struct {
+			unsigned connection_id;
+		} video;
+		struct {
+			unsigned connection_id;
+			char volume[20];
+		} rfm;
+		struct {
+			unsigned fifosize_kb;
+			unsigned fifosize_bufs;
+			char name[16];
+			unsigned char params[256];
+			int paramlen;
+		} utility;
+
+	} u;
+};
+
+#endif				/* CAIF_CONFIG_H_ */
diff --git a/include/linux/caif/caif_socket.h b/include/linux/caif/caif_socket.h
new file mode 100644
index 0000000..30a2258
--- /dev/null
+++ b/include/linux/caif/caif_socket.h
@@ -0,0 +1,195 @@
+/* linux/caif_socket.h
+ * CAIF Definitions for CAIF socket and network layer
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	 Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef _LINUX_CAIF_SOCKET_H
+#define _LINUX_CAIF_SOCKET_H
+
+#ifdef __KERNEL__
+#include <linux/types.h>
+#include <linux/socket.h>
+#else
+#include <sys/types.h>
+#include <sys/socket.h>
+#endif
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+/**
+ * enum caif_link_selector -    Physical Link Selection.
+ * @CAIF_LINK_HIGH_BANDW:	Physical interface for high-bandwidth
+ *				traffic.
+ * @CAIF_LINK_LOW_LATENCY:	Physical interface for low-latency
+ *				traffic.
+ *
+ * CAIF Link Layers can register their link properties.
+ * This enum is used for choosing between CAIF Link Layers when
+ * setting up CAIF Channels when multiple CAIF Link Layers exists.
+ */
+enum caif_link_selector {
+	CAIF_LINK_HIGH_BANDW,
+	CAIF_LINK_LOW_LATENCY
+};
+
+/**
+ * enum caif_channel_priority - CAIF channel priorities.
+ *
+ * @CAIF_PRIO_MIN:	Min priority for a channel.
+ * @CAIF_PRIO_LOW:	Low-priority channel.
+ * @CAIF_PRIO_NORMAL:	Normal/default priority level.
+ * @CAIF_PRIO_HIGH:	High priority level
+ * @CAIF_PRIO_MAX:	Max priority for channel
+ *
+ * Priority can be set on CAIF Channels in order to
+ * prioritize between traffic on different CAIF Channels.
+ * These priority levels are recommended, but the priority value
+ * is not restricted to the values defined in this enum, any value
+ * between CAIF_PRIO_MIN and CAIF_PRIO_MAX could be used.
+ */
+enum caif_channel_priority {
+	CAIF_PRIO_MIN	 = 0x01,
+	CAIF_PRIO_LOW	 = 0x04,
+	CAIF_PRIO_NORMAL = 0x0f,
+	CAIF_PRIO_HIGH	 = 0x14,
+	CAIF_PRIO_MAX	 = 0x1F
+};
+
+/**
+ * enum caif_protocol_type  -	CAIF Channel type.
+ * @CAIFPROTO_AT:		Classic AT channel.
+ * @CAIFPROTO_DATAGRAM:		Datagram channel.
+ * @CAIFPROTO_DATAGRAM_LOOP:	Datagram loopback channel, used for testing.
+ * @CAIFPROTO_UTIL:		Utility (Psock) channel.
+ * @CAIFPROTO_RFM:		Remote File Manager
+ *
+ * This enum defines the CAIF Channel type to be used. This defines
+ * the service to connect to on the modem.
+ */
+enum caif_protocol_type {
+	CAIFPROTO_AT,
+	CAIFPROTO_DATAGRAM,
+	CAIFPROTO_DATAGRAM_LOOP,
+	CAIFPROTO_UTIL,
+	CAIFPROTO_RFM,
+	_CAIFPROTO_MAX
+};
+#define	CAIFPROTO_MAX _CAIFPROTO_MAX
+
+/**
+ * enum caif_at_type - AT Service Endpoint
+ * @CAIF_ATTYPE_PLAIN:	     Connects to a plain vanilla AT channel.
+ */
+enum caif_at_type {
+	CAIF_ATTYPE_PLAIN
+};
+
+/**
+ * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
+ * @u:			     Union of address data 'switched' by family.
+ * :
+ * @u.at:                    Applies when family = CAIFPROTO_AT.
+ *
+ * @u.at.type:               Type of AT link to set up (enum caif_at_type).
+ *
+ * @u.util:                  Applies when family = CAIFPROTO_UTIL
+ *
+ * @u.util.service:          Utility service name.
+ *
+ * @u.dgm:                   Applies when family = CAIFPROTO_DATAGRAM
+ *
+ * @u.dgm.connection_id:     Datagram connection id.
+ *
+ * @u.dgm.nsapi:             NSAPI of the PDP-Context.
+ *
+ * @u.rfm:                   Applies when family = CAIFPROTO_RFM
+ *
+ * @u.rfm.connection_id:     Connection ID for RFM.
+ *
+ * @u.rfm.volume:            Volume to mount.
+ *
+ * Description:
+ * This structure holds the connect parameters used for setting up a
+ * CAIF Channel. It defines the service to connect to on the modem.
+ */
+struct sockaddr_caif {
+	sa_family_t  family;
+	union {
+		struct {
+			u_int8_t  type;		/* type: enum caif_at_type */
+		} at;				/* CAIFPROTO_AT */
+		struct {
+			char	  service[16];
+		} util;				/* CAIFPROTO_UTIL */
+		union {
+			u_int32_t connection_id;
+			u_int8_t  nsapi;
+		} dgm;				/* CAIFPROTO_DATAGRAM(_LOOP)*/
+		struct {
+			u_int32_t connection_id;
+			char	  volume[16];
+		} rfm;				/* CAIFPROTO_RFM */
+	} u;
+};
+
+/**
+ * struct caif_param - CAIF parameters.
+ * @size:	Length of data
+ * @data:	Binary Data Blob
+ */
+struct caif_param {
+	u_int16_t  size;
+	u_int8_t   data[256];
+};
+
+
+/**
+ * enum caif_socket_opts - CAIF option values for getsockopt and setsockopt.
+ *
+ * @CAIFSO_LINK_SELECT:		Selector used if multiple CAIF Link layers are
+ *				available. Either a high bandwidth
+ *				link can be selected (CAIF_LINK_HIGH_BANDW) or
+ *				or a low latency link (CAIF_LINK_LOW_LATENCY).
+ *                              This option is of type u_int32_t.
+ *				Alternatively SO_BINDTODEVICE can be used.
+ *
+ * @CAIFSO_REQ_PARAM:		Used to set the request parameters for a
+ *				utility channel. (struct caif_param). This
+ *				option must be set before connecting.
+ *
+ * @CAIFSO_RSP_PARAM:		Gets the request parameters for a utility
+ *				channel. (struct caif_param). This option
+ *				is valid after a successful connect.
+ *
+ * @CAIFSO_CHANNEL_ID:		Gets the channel id on a CAIF Channel.
+ *				This option is valid after a successful connect.
+ *				( u_int32_t)
+ *
+ * @CAIFSO_NEXT_PAKCET_LEN:	Gets the size of next received packet.
+ *				Value is 0 if no packet is available.
+ *				This option is valid after a successful connect.
+ *				( u_int32_t)
+ *
+ * @CAIFSO_MAX_PAKCET_LEN:	Gets the maximum packet size for this
+ *				connection. ( u_int32_t)
+ *
+ * This enum defines the CAIF Socket options to be used on a socket
+ *
+ */
+enum caif_socket_opts {
+	CAIFSO_LINK_SELECT	= 127,
+	CAIFSO_REQ_PARAM	= 128,
+	CAIFSO_RSP_PARAM	= 129,
+	CAIFSO_CHANNEL_ID	= 130,
+	CAIFSO_NEXT_PACKET_LEN	= 131,
+	CAIFSO_MAX_PACKET_LEN	= 132,
+};
+
+#ifdef __cplusplus
+}				/* extern "C" */
+#endif
+#endif /* _LINUX_CAIF_SOCKET_H */
diff --git a/include/linux/caif/if_caif.h b/include/linux/caif/if_caif.h
new file mode 100644
index 0000000..5e7eed4
--- /dev/null
+++ b/include/linux/caif/if_caif.h
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef IF_CAIF_H_
+#define IF_CAIF_H_
+#include <linux/sockios.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+
+/**
+ * enum ifla_caif - CAIF NetlinkRT parameters.
+ * @IFLA_CAIF_IPV4_CONNID:  Connection ID for IPv4 PDP Context.
+ *			    The type of attribute is NLA_U32.
+ * @IFLA_CAIF_IPV6_CONNID:  Connection ID for IPv6 PDP Context.
+ *			    The type of attribute is NLA_U32.
+ * @IFLA_CAIF_LOOPBACK:	    If different from zero, device is doing loopback
+ *			    The type of attribute is NLA_U8.
+ *
+ * When using RT Netlink to create, destroy or configure a CAIF IP interface,
+ * enum ifla_caif is used to specify the configuration attributes.
+ */
+enum ifla_caif {
+	__IFLA_CAIF_UNSPEC,
+	IFLA_CAIF_IPV4_CONNID,
+	IFLA_CAIF_IPV6_CONNID,
+	IFLA_CAIF_LOOPBACK,
+	__IFLA_CAIF_MAX
+};
+#define	IFLA_CAIF_MAX (__IFLA_CAIF_MAX-1)
+
+#endif /*IF_CAIF_H_*/
-- 
1.6.3.3

