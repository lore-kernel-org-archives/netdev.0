From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3  1/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:45 +0100
Message-ID: <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55100 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbZK3QBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:24 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX001LXGE1KF10@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:14 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:13 +0100 (CET)
In-reply-to: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/caif/caif_config.h |  174 ++++++++++++++++++++++++++++++++++++++
 include/linux/caif/caif_ioctl.h  |   91 ++++++++++++++++++++
 include/linux/caif/caif_socket.h |  157 ++++++++++++++++++++++++++++++++++
 include/linux/caif/if_caif.h     |   69 +++++++++++++++
 include/linux/if_arp.h           |    1 +
 include/linux/if_ether.h         |    1 +
 include/linux/socket.h           |    5 +-
 include/linux/tty.h              |    3 +-
 8 files changed, 499 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/caif/caif_config.h
 create mode 100644 include/linux/caif/caif_ioctl.h
 create mode 100644 include/linux/caif/caif_socket.h
 create mode 100644 include/linux/caif/if_caif.h

diff --git a/include/linux/caif/caif_config.h b/include/linux/caif/caif_config.h
new file mode 100644
index 0000000..b4ff87f
--- /dev/null
+++ b/include/linux/caif/caif_config.h
@@ -0,0 +1,174 @@
+/*
+ * CAIF Channel Configuration definitions.
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_CONFIG_H_
+#define CAIF_CONFIG_H_
+
+/**
+ * enum caif_phy_preference     Types of physical HW interfaces
+ *				towards modem defined in CAIF stack
+ * @CAIF_PHYPREF_UNSPECIFIED:	Default physical interface
+ * @CAIF_PHYPREF_LOW_LAT:	Default physical interface for low-latency
+ *				traffic
+ * @CAIF_PHYPREF_HIGH_BW:	Default physical interface for high-bandwidth
+ *				traffic
+ * @_CAIF_PHYPREF_LOOP:		TEST Loopback interface, simulating modem
+ *				responses
+ *
+ * For client convenience, two special types are defined:
+ * CAIF_PHYPREF_LOW_LAT is the preferred low-latency physical link.
+ * Typically used for "control" purposes.
+ * CAIF_PHYPREF_HIGH_BW is the preferred high-bandwidth physical link.
+ * Typically used for "payload" purposes.
+ *
+ */
+enum caif_phy_preference {
+	CAIF_PHYPREF_UNSPECIFIED	= 0x00,
+	CAIF_PHYPREF_LOW_LAT		= 0xd0,
+	CAIF_PHYPREF_HIGH_BW		= 0xe0,
+	_CAIF_PHYPREF_LOOP		= 0x70
+};
+
+/*!
+ * Define CAIF channel priority.
+ * Used when setting up a channel to specify the
+ * priority level of the channel.
+ */
+#define CAIF_PRIO_UNSPCEIFIED  0x0
+#define CAIF_PRIO_MIN	       0x01	/*! Minimum priority level */
+#define CAIF_PRIO_LOW	       0x04	/*!< Suggested priority level for
+					 *   low-priority channel.
+					 */
+#define CAIF_PRIO_NORMAL       0x0f	/*!< Suggested normal/default
+					 *   priority level.
+					 */
+#define CAIF_PRIO_HIGH	       0x14	/*!< Suggested high priority level */
+#define CAIF_PRIO_MAX	       0x1F	/*!< Max priority for channel
+					 *   (do not use)
+					 */
+
+/**
+ * enum caif_channel_type  	Types of CAIF channel type defined in CAIF Stack.
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
+ * @CAIF_CHTY_RAW:		DO NOT USE. This is for testing only.
+ *
+ * This is used for channel configuration, specifying the type of channel.
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
+	CAIF_CHTY_UTILITY,
+	CAIF_CHTY_RAW
+};
+
+/**
+ *struct caif_channel_config This structure is used for configuring
+ *			     CAIF channels.
+ * @name: 		     Mandatory - Nickname for this device
+ * @type:		     Mandatory - Define the type of caif service
+ * @priority:		     Mandatory - Value between  CAIF_PRIO_MIN and
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
+ * @u.dgm.connection_id:     Mandatory - Connection ID must be specified.
+ *
+ * @u.video:		     CAIF_CHTYPE_VIDEO
+ * @u.video.connection_id:   Mandatory - Connection ID must be specified.
+ *
+ * @u.rfm		     CAIF_CHTYPE_RFM
+ * @u.rfm.connection_id:     Mandatory - Connection ID must be specified.
+ * @u.rfm.volume:	     Mandatory - Volume to mount.
+ *
+ * @u.utility:		     CAIF_CHTYPE_UTILITY
+ * @u.utility.fifosize_kb:   Psock: FIFO size in KB
+ * @u.utility.fifosize_bufs: Psock: Number of signal buffers
+ * @u.utility.name:	     Psock: Name of service
+ * @u.utility.params:	     Psock: Channel config parameters
+ * @u.utility.paramlen:	     Psock: Length of channel config parameters
+ *
+ *
+ * It holds configuration parameters for setting up all defined CAIF
+ * channel types.
+ * The four first fields are mandatory, then physical interface can be specified
+ * either by name or by prefered characteristics.
+ * The rest of the configuration fields are held in a union for each
+ * channel type and are channel type specific.
+ */
+struct caif_channel_config {
+	char name[16];
+	enum caif_channel_type type;
+	unsigned priority;
+	enum caif_phy_preference phy_pref;
+	char phy_name[16];
+
+	/** Union of channel type-specific configuration parameters.
+	 * 'switched' by attribute type.
+	 */
+	union {
+		/* CAIF_CHTYPE_DATAGRAM */
+		struct {
+			unsigned connection_id;
+		} dgm;
+		/* CAIF_CHTYPE_VIDEO */
+		struct {
+			unsigned connection_id;
+		} video;
+		/* CAIF_CHTYPE_RFM */
+		struct {
+			unsigned connection_id;
+			char volume[20];
+		} rfm;
+		/* CAIF_CHTYPE_UTILITY */
+		struct {
+			unsigned fifosize_kb;
+			unsigned fifosize_bufs;
+			char name[16];
+			unsigned char params[256];
+			int paramlen;
+		} utility;
+
+		/* Raw data configuration: DO NOT USE.
+		 * Applies for testing only.
+		 */
+		struct raw {
+			unsigned channeltype;
+			unsigned char endpoint:2;
+			unsigned char subtype:2;
+			unsigned char serviceconfig[512];
+			unsigned int service_length;
+		} _raw;
+	} u;
+};
+
+#endif				/* CAIF_CONFIG_H_ */
diff --git a/include/linux/caif/caif_ioctl.h b/include/linux/caif/caif_ioctl.h
new file mode 100644
index 0000000..a42adf5
--- /dev/null
+++ b/include/linux/caif/caif_ioctl.h
@@ -0,0 +1,91 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_IOCTL_H_
+#define CAIF_IOCTL_H_
+#include <linux/caif/caif_config.h>
+
+/*!\page  caif_ioctl.h
+ * This file defines the management interface to CAIF.
+ * It defines how CAIF channels are configured and become visible in the
+ * Linux file system, typically under "/dev".
+ *
+ *\b Example - creating a new AT character device:
+ * \code
+   fd = open("/dev/caifconfig",..);
+   struct caif_channel_create_action at_config = {
+	 .name = "cnhl2",
+	 .config = {
+	    .channel = CAIF_CHTY_AT,
+	    .phy_ref = CAIF_PHY_LOW_LAT,
+	    .priority = CAIF_PRIO_HIGH
+	 }};
+   ioctl(fd, CAIF_IOC_CONFIG_DEVICE,&at_config);
+   close(fd);
+ * \endcode
+ * This will cause a new AT channel to be available in at "/dev/chnl2".
+ * This CAIF channel can then be connected by using \ref open.
+ */
+
+#define CAIF_IOC_MAGIC 'g'
+#define DEVICE_NAME_LEN 16
+
+/* Specifies the type of device to create: NET device or CHAR device*/
+enum caif_dev_type {
+	CAIF_DEV_CHR = 1,
+	CAIF_DEV_NET = 2
+};
+
+/** Used for identifying devices, PHY interfaces, etc.*/
+struct caif_device_name {
+	char name[DEVICE_NAME_LEN];	/*!< Device name */
+	enum caif_dev_type devtype;	/*!< Device type */
+};
+
+/**
+ * CAIF ACTION for \ref CAIF_ACT_CHANNEL_CONFIG.
+ * This structure is used to configure a new CAIF Channel and
+ * create the corresponding character device.
+ */
+struct caif_channel_create_action {
+	/** \b in  CAIF configuration request */
+	struct caif_channel_config config;
+	/** \b in/out Device name returned from ACTION */
+	struct caif_device_name name;
+	/** \b out Major device id */
+	int major;
+	/** \b out Minor device id */
+	int minor;
+};
+
+/**
+ * union caif_action
+ * This union is used to create and delete CAIF channels.
+ */
+union caif_action {
+	struct caif_device_name delete_channel;
+	struct caif_channel_create_action create_channel;
+};
+
+/**
+ * CAIF IOCTL for \ref CAIF_IOC_CHANNEL_CONFIG.
+ * This structure is used to configure a new CAIF Channel and
+ * create the corresponding character device.
+ */
+
+/** Create and Configure a new CAIF device.
+ * Note that the device is not implicitly connected.
+ */
+#define CAIF_IOC_CONFIG_DEVICE		_IOWR(CAIF_IOC_MAGIC, 1,\
+struct caif_channel_create_action)
+
+/** Remove a CAIF device. Requires the device to be previously disconnected. */
+#define CAIF_IOC_REMOVE_DEVICE		_IOWR(CAIF_IOC_MAGIC, 2,\
+		struct caif_device_name)
+#define CAIF__IOC_MAXNR				9
+/*! @} */
+
+#endif				/* CAIF_IOCTL_H_ */
diff --git a/include/linux/caif/caif_socket.h b/include/linux/caif/caif_socket.h
new file mode 100644
index 0000000..239fb00
--- /dev/null
+++ b/include/linux/caif/caif_socket.h
@@ -0,0 +1,157 @@
+/* linux/caif_socket.h
+ * CAIF Definitions for CAIF socket and network layer
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	 Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef _LINUX_CAIF_SOCKET_H
+#define _LINUX_CAIF_SOCKET_H
+#ifdef __cplusplus
+extern "C" {
+#endif
+#include <linux/types.h>
+#include <linux/socket.h>
+
+/* TODO: Move these defs to /usr/include/linux/socket.h */
+#define AF_CAIF    37 		/* CAIF Socket Address Family */
+#define PF_CAIF    37           /* CAIF Socket Protocol Family */
+#define SOL_CAIF   278		/* CAIF Socket Option Level */
+
+#define CAIF_DEFAULT_PRI       0xf
+
+/*
+ * enum caif_link_selector -   Physical Link Selection.
+ * @CAIF_LINK_UNSPECIFIED:	Default physical interface
+ * @CAIF_LINK_LOW_LATENCY:	Default physical interface for low-latency
+ *                              traffic.
+ * @CAIF_LINK_HIGH_BANDW:	Default physical interface for high-bandwidth
+ *				traffic.
+ */
+enum caif_link_selector {
+	CAIF_LINK_UNSPECIFIED	= 0x00,
+	CAIF_LINK_LOW_LATENCY	= 0xd0,
+	CAIF_LINK_HIGH_BANDW	= 0xe0
+};
+
+/**
+ * enum caif_protocol_type  	Types of CAIF protocols in the CAIF Stack.
+ * @CAIFPROTO_AT:		Classic AT channel.
+ * @CAIFPROTO_DATAGRAM:		Datagram channel.
+ * @CAIFPROTO_DATAGRAM_LOOP:	Datagram loopback channel,used for test purpose
+ * @CAIFPROTO_UTILITY:		Utility (Psock) channel.
+ * @CAIFPROTO_RFM:		Remote File Manager
+ */
+enum caif_protocol_type {
+	CAIFPROTO_AT,
+	CAIFPROTO_DATAGRAM,
+	CAIFPROTO_DATAGRAM_LOOP,
+	CAIFPROTO_UTIL,
+	CAIFPROTO_RFM,
+	CAIFPROTO_MAX
+};
+
+enum caif_at_type {
+	CAIF_ATTYPE_PLAIN
+};
+
+/*
+ * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
+ * @family:	address family number AF_CAIF
+ * @u.dgm:		     CAIFPROTO_AT
+ * @u.dgm.at_type: 	     Type of AT link to setup of type enum caif_at_type
+ * @u.dgm:		     CAIFPROTO_DATAGRAM
+ * @u.dgm.connection_id:     Datagram connection id.
+ * @u.dgm.nsapi:             NSAPI of the PDP-Context.
+ * @u.rfm		     CAIFPROTO_RFM
+ * @u.rfm.connection_id:     Connection ID for RFM.
+ * @u.rfm.volume:	     Volume to mount.
+ * @u.util:		     CAIFPROTO_UTILITY
+ * @u.utility.name:	     Service name.
+ */
+struct sockaddr_caif {
+	sa_family_t  family;
+	union {
+		struct {
+			u_int8_t  type; 	/* type: enum caif_at_type */
+		} at;				/* CAIFPROTO_AT */
+		union {
+			u_int32_t connection_id;
+			u_int8_t  nsapi;
+		} dgm;				/* CAIFPROTO_DATAGRAM */
+		struct {
+			char      service[16];
+		} util;				/* CAIFPROTO_UTIL */
+		struct {
+			u_int32_t connection_id;
+			char 	  volume[16];
+		} rfm;				/* CAIFPROTO_RFM */
+	} u;
+};
+
+/*
+ * struct caif_channel_opt - CAIF channel connect options.
+ * @priority:		Priority of the channel (between 0 and 0x1f)
+ * @link_selector:	Selector for the physical link.
+ *              	(see enum caif_phy_preference in caif_config.h)
+ * @phy_name    Prefered physical link name.
+ */
+struct caif_channel_opt {
+	u_int16_t  priority;
+	u_int16_t  link_selector;
+	char       link_name[16];
+};
+
+/*
+ * struct caif_param - CAIF parameters
+ * @datalen:	Length of data
+ * @data:	Binary Data Blob
+ */
+struct caif_param {
+	u_int16_t  size;
+	u_int8_t   data[256];
+};
+
+/*
+ * struct caif_util_modem_flow_opt - CAIF utility channel flow parameters.
+ * This specifies the queue size for down-link messages.
+ * @fifosize_kb:	Maximum number of unsent DN
+ * @fifosize_bufs:	Actual parameters
+ */
+struct caif_util_modem_flow_opt {
+	u_int32_t  fifosize_kb;
+	u_int32_t  fifosize_bufs;
+};
+
+/* enum caif_socket_opts - CAIF option values for getsockopt and setsockopt.
+ * @CAIF_CHANNEL_OPT:	        Used to set the connect options on a CAIF
+ *				socket. (struct caif_config_opt). This must
+ *				be set before connecting.
+ * @CAIF_REQ_PARAM_OPT:		Used to set the request parameters for a
+ *				utility channel. (struct caif_param). This
+ *				must be set before connecting.
+ *
+ * @CAIF_RES_PARAM_OPT:		Gets the request parameters for a utility
+ *				channel. (struct caif_param). This must be
+ *				fetched after connecting the socket.
+ *
+ * @CAIF_UTIL_FLOW_OPT:		Sets the utility channels flow options.
+ *				This must be set before connecting.
+ *				(struct caif_util_modem_flow_opt)
+ *
+ * @CAIF_CONN_ID_OPT:           Gets the channel id on a CAIF Channel.
+ *				This can only be done after connect.
+ *                              ( u_int32_t)
+ */
+enum caif_socket_opts {
+	CAIF_CHANNEL_OPT = 127,
+	CAIF_REQ_PARAM_OPT  	= 128,
+	CAIF_RSP_PARAM_OPT  	= 129,
+	CAIF_UTIL_FLOW_OPT  	= 130,
+	CAIF_CONN_ID_OPT    	= 131
+};
+
+#ifdef __cplusplus
+}				/* extern "C" */
+#endif
+#endif /* _LINUX_CAIF_SOCKET_H */
diff --git a/include/linux/caif/if_caif.h b/include/linux/caif/if_caif.h
new file mode 100644
index 0000000..ab1d154
--- /dev/null
+++ b/include/linux/caif/if_caif.h
@@ -0,0 +1,69 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef IF_CAIF_H_
+#define IF_CAIF_H_
+
+/**
+ * enum sioc_caif
+ *
+ * CAIF IP Interface can be created, changed and deleted,
+ * by this enum. In addition standard Socket IO Controls (SIGIOC*)
+ * can be used to manage standard IP Interface parameters.
+ * The struct ifreq are used to carry parameters.
+ *
+ * @SIOCCAIFNETNEW    - Used to create a new instance of the CAIF IP Interface.
+ *                      struct ifreq containing struct ifcaif_param are used
+ *                      as parameters. ifr_name must be filled in.
+ * @SIOCCAIFNETCHANGE - As above, but changes a disconnected CAIF IP Inteface.
+ * @SIOCCAIFNETREMOVE - Removes a CAIF IP Interface.
+ */
+enum sioc_caif {
+	SIOCCAIFNETNEW = SIOCPROTOPRIVATE,
+	SIOCCAIFNETCHANGE,
+	SIOCCAIFNETREMOVE,
+};
+
+
+/**
+ * struct ifcaif_param
+ *
+ * When using SIOCCAIFNETNEW to create a CAIF IP interface, this structure
+ * is used for configuration data.
+ * The attribute ifr_ifru.ifru_data in struct struct ifreq must be set
+ * point at an instance of struct ifcaif_param.
+ *
+ * @ipv4_connif - Connection ID for IPv4 PDP Context.
+ * @ipv6_connif - Connection ID for IPv6 PDP Context.
+ * @loop        - If different from zero, device is doing loopback
+ */
+struct ifcaif_param {
+	__u32                   ipv4_connid;
+	__u32                   ipv6_connid;
+	__u8			loop;
+};
+
+/**
+ * enum ifla_caif
+ * When using RT Netlink to create, destroy or configure a CAIF IP interface,
+ * enum ifla_caif is used to specify the configuration attributes.
+ *
+ * @IFLA_CAIF_IPV4_CONNID - Connection ID for IPv4 PDP Context.
+ *                          The type of attribute is NLA_U32.
+ * @IFLA_CAIF_IPV6_CONNID - Connection ID for IPv6 PDP Context.
+ *                          The type of attribute is NLA_U32.
+ * @IFLA_CAIF_LOOPBACK   -  If different from zero, device is doing loopback
+ *                          The type of attribute is NLA_U8.
+ */
+enum ifla_caif {
+	IFLA_CAIF_IPV4_CONNID,
+	IFLA_CAIF_IPV6_CONNID,
+	IFLA_CAIF_LOOPBACK,
+	__IFLA_CAIF_MAX
+};
+#define	IFLA_CAIF_MAX (__IFLA_CAIF_MAX-1)
+
+#endif /*IF_CAIF_H_*/
diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 282eb37..4efa69a 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -90,6 +90,7 @@
 
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
+#define ARPHRD_CAIF     822		/* CAIF media type		*/
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 580b600..c66d48a 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -109,6 +109,7 @@
 #define ETH_P_TRAILER	0x001C		/* Trailer switch tagging	*/
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
+#define ETH_P_CAIF      0x00F7          /* ST-Ericsson CAIF protocol    */
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3273a0c..ad0dd43 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -180,7 +180,8 @@ struct ucred {
 #define AF_ISDN		34	/* mISDN sockets 		*/
 #define AF_PHONET	35	/* Phonet sockets		*/
 #define AF_IEEE802154	36	/* IEEE802154 sockets		*/
-#define AF_MAX		37	/* For now.. */
+#define AF_CAIF		37	/* CAIF sockets		        */
+#define AF_MAX		38	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -220,6 +221,7 @@ struct ucred {
 #define PF_ISDN		AF_ISDN
 #define PF_PHONET	AF_PHONET
 #define PF_IEEE802154	AF_IEEE802154
+#define PF_CAIF         AF_CAIF
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -291,6 +293,7 @@ struct ucred {
 #define SOL_PNPIPE	275
 #define SOL_RDS		276
 #define SOL_IUCV	277
+#define SOL_CAIF	278
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/include/linux/tty.h b/include/linux/tty.h
index f0f43d0..3f8e793 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -23,7 +23,7 @@
  */
 #define NR_UNIX98_PTY_DEFAULT	4096      /* Default maximum for Unix98 ptys */
 #define NR_UNIX98_PTY_MAX	(1 << MINORBITS) /* Absolute limit */
-#define NR_LDISCS		20
+#define NR_LDISCS		21
 
 /* line disciplines */
 #define N_TTY		0
@@ -48,6 +48,7 @@
 #define N_PPS		18	/* Pulse per Second */
 
 #define N_V253		19	/* Codec control over voice modem */
+#define N_CAIF		20
 
 /*
  * This character is the same as _POSIX_VDISABLE: it cannot be used as
-- 
1.6.2.2.1669.g7eaf8

