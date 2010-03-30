From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 03/12] net-caif: add CAIF core protocol stack
 header files
Date: Wed, 31 Mar 2010 01:56:21 +0200
Message-ID: <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab0C3X4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:56:48 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CA8D6KAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:44 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:44 +0200 (CEST)
In-reply-to: <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Add include files for the CAIF Core protocol stack.

caif_layer.h - Defines the structure of the CAIF protocol layers
cfcnfg.h     - CAIF Configuration Module for services and link layers
cfctrl.h     - CAIF Control Protocol Layer
cffrml.h     - CAIF Framing Layer
cfmuxl.h     - CAIF Muxing Layer
cfpkt.h	     - CAIF Packet layer (skb helper functions)
cfserl.h     - CAIF Serial Layer
cfsrvl.h     - CAIF Service Layer

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_layer.h |  283 +++++++++++++++++++++++++++++++++++++++++
 include/net/caif/cfcnfg.h     |  133 +++++++++++++++++++
 include/net/caif/cfctrl.h     |  138 ++++++++++++++++++++
 include/net/caif/cffrml.h     |   16 +++
 include/net/caif/cfmuxl.h     |   22 +++
 include/net/caif/cfpkt.h      |  274 +++++++++++++++++++++++++++++++++++++++
 include/net/caif/cfserl.h     |   12 ++
 include/net/caif/cfsrvl.h     |   34 +++++
 8 files changed, 912 insertions(+), 0 deletions(-)

diff --git a/include/net/caif/caif_layer.h b/include/net/caif/caif_layer.h
new file mode 100644
index 0000000..25c472f
--- /dev/null
+++ b/include/net/caif/caif_layer.h
@@ -0,0 +1,283 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_LAYER_H_
+#define CAIF_LAYER_H_
+
+#include <linux/list.h>
+
+struct cflayer;
+struct cfpkt;
+struct cfpktq;
+struct caif_payload_info;
+struct caif_packet_funcs;
+
+#define CAIF_MAX_FRAMESIZE 4096
+#define CAIF_MAX_PAYLOAD_SIZE (4096 - 64)
+#define CAIF_NEEDED_HEADROOM (10)
+#define CAIF_NEEDED_TAILROOM (2)
+
+#define CAIF_LAYER_NAME_SZ 16
+#define CAIF_SUCCESS	1
+#define CAIF_FAILURE	0
+
+/**
+ * caif_assert() - Assert function for CAIF.
+ * @assert: expression to evaluate.
+ *
+ * This function will print a error message and a do WARN_ON if the
+ * assertion failes. Normally this will do a stack up at the current location.
+ */
+#define caif_assert(assert)					\
+do {								\
+	if (!(assert)) {					\
+		pr_err("caif:Assert detected:'%s'\n", #assert); \
+		WARN_ON(!(assert));				\
+	}							\
+} while (0)
+
+
+/**
+ * enum caif_ctrlcmd - CAIF Stack Control Signaling sent in layer.ctrlcmd().
+ *
+ * @CAIF_CTRLCMD_FLOW_OFF_IND:		Flow Control is OFF, transmit function
+ *					should stop sending data
+ *
+ * @CAIF_CTRLCMD_FLOW_ON_IND:		Flow Control is ON, transmit function
+ *					can start sending data
+ *
+ * @CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:	Remote end modem has decided to close
+ *					down channel
+ *
+ * @CAIF_CTRLCMD_INIT_RSP:		Called initially when the layer below
+ *					has finished initialization
+ *
+ * @CAIF_CTRLCMD_DEINIT_RSP:		Called when de-initialization is
+ *					complete
+ *
+ * @CAIF_CTRLCMD_INIT_FAIL_RSP:		Called if initialization fails
+ *
+ * @_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:	CAIF Link layer temporarily cannot
+ *					send more packets.
+ * @_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND:	Called if CAIF Link layer is able
+ *					to send packets again.
+ * @_CAIF_CTRLCMD_PHYIF_DOWN_IND:	Called if CAIF Link layer is going
+ *					down.
+ *
+ * These commands are sent upwards in the CAIF stack to the CAIF Client.
+ * They are used for signaling originating from the modem or CAIF Link Layer.
+ * These are either responses (*_RSP) or events (*_IND).
+ */
+enum caif_ctrlcmd {
+	CAIF_CTRLCMD_FLOW_OFF_IND,
+	CAIF_CTRLCMD_FLOW_ON_IND,
+	CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND,
+	CAIF_CTRLCMD_INIT_RSP,
+	CAIF_CTRLCMD_DEINIT_RSP,
+	CAIF_CTRLCMD_INIT_FAIL_RSP,
+	_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
+	_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND,
+	_CAIF_CTRLCMD_PHYIF_DOWN_IND,
+};
+
+/**
+ * enum caif_modemcmd -	 Modem Control Signaling, sent from CAIF Client
+ *			 to the CAIF Link Layer or modem.
+ *
+ * @CAIF_MODEMCMD_FLOW_ON_REQ:		Flow Control is ON, transmit function
+ *					can start sending data.
+ *
+ * @CAIF_MODEMCMD_FLOW_OFF_REQ:		Flow Control is OFF, transmit function
+ *					should stop sending data.
+ *
+ * @_CAIF_MODEMCMD_PHYIF_USEFULL:	Notify physical layer that it is in use
+ *
+ * @_CAIF_MODEMCMD_PHYIF_USELESS:	Notify physical layer that it is
+ *					no longer in use.
+ *
+ * These are requests sent 'downwards' in the stack.
+ * Flow ON, OFF can be indicated to the modem.
+ */
+enum caif_modemcmd {
+	CAIF_MODEMCMD_FLOW_ON_REQ = 0,
+	CAIF_MODEMCMD_FLOW_OFF_REQ = 1,
+	_CAIF_MODEMCMD_PHYIF_USEFULL = 3,
+	_CAIF_MODEMCMD_PHYIF_USELESS = 4
+};
+
+/**
+ * enum caif_direction - CAIF Packet Direction.
+ * Indicate if a packet is to be sent out or to be received in.
+ * @CAIF_DIR_IN:		Incoming packet received.
+ * @CAIF_DIR_OUT:		Outgoing packet to be transmitted.
+ */
+enum caif_direction {
+	CAIF_DIR_IN = 0,
+	CAIF_DIR_OUT = 1
+};
+
+/**
+ * struct cflayer - CAIF Stack layer.
+ * Defines the framework for the CAIF Core Stack.
+ * @up:		Pointer up to the layer above.
+ * @dn:		Pointer down to the layer below.
+ * @node:	List node used when layer participate in a list.
+ * @receive:	Packet receive function.
+ * @transmit:	Packet transmit funciton.
+ * @ctrlcmd:	Used for control signalling upwards in the stack.
+ * @modemcmd:	Used for control signaling downwards in the stack.
+ * @prio:	Priority of this layer.
+ * @id:		The identity of this layer
+ * @type:	The type of this layer
+ * @name:	Name of the layer.
+ *
+ *  This structure defines the layered structure in CAIF.
+ *
+ *  It defines CAIF layering structure, used by all CAIF Layers and the
+ *  layers interfacing CAIF.
+ *
+ *  In order to integrate with CAIF an adaptation layer on top of the CAIF stack
+ *  and PHY layer below the CAIF stack
+ *  must be implemented. These layer must follow the design principles below.
+ *
+ *  Principles for layering of protocol layers:
+ *    - All layers must use this structure. If embedding it, then place this
+ *	structure first in the layer specific structure.
+ *
+ *    - Each layer should not depend on any others layer private data.
+ *
+ *    - In order to send data upwards do
+ *	layer->up->receive(layer->up, packet);
+ *
+ *    - In order to send data downwards do
+ *	layer->dn->transmit(layer->dn, info, packet);
+ */
+struct cflayer {
+	struct cflayer *up;
+	struct cflayer *dn;
+	struct list_head node;
+
+	/*
+	 *  receive() - Receive Function.
+	 *  Contract: Each layer must implement a receive function passing the
+	 *  CAIF packets upwards in the stack.
+	 *	Packet handling rules:
+	 *	      - The CAIF packet (cfpkt) cannot be accessed after
+	 *		     passing it to the next layer using up->receive().
+	 *	      - If parsing of the packet fails, the packet must be
+	 *		     destroyed and -1 returned from the function.
+	 *	      - If parsing succeeds (and above layers return OK) then
+	 *		      the function must return a value > 0.
+	 *
+	 *  Returns result < 0 indicates an error, 0 or positive value
+	 *	     indicates success.
+	 *
+	 *  @layr: Pointer to the current layer the receive function is
+	 *		implemented for (this pointer).
+	 *  @cfpkt: Pointer to CaifPacket to be handled.
+	 */
+	int (*receive)(struct cflayer *layr, struct cfpkt *cfpkt);
+
+	/*
+	 *  transmit() - Transmit Function.
+	 *  Contract: Each layer must implement a transmit function passing the
+	 *	CAIF packet downwards in the stack.
+	 *	Packet handling rules:
+	 *	      - The CAIF packet (cfpkt) ownership is passed to the
+	 *		transmit function. This means that the the packet
+	 *		cannot be accessed after passing it to the below
+	 *		layer using dn->transmit().
+	 *
+	 *	      - If transmit fails, however, the ownership is returned
+	 *		to thecaller. The caller of "dn->transmit()" must
+	 *		destroy or resend packet.
+	 *
+	 *	      - Return value less than zero means error, zero or
+	 *		greater than zero means OK.
+	 *
+	 *	 result < 0 indicates an error, 0 or positive value
+	 *	 indicate success.
+	 *
+	 *  @layr:	Pointer to the current layer the receive function
+	 *		isimplemented for (this pointer).
+	 *  @cfpkt:	 Pointer to CaifPacket to be handled.
+	 */
+	int (*transmit) (struct cflayer *layr, struct cfpkt *cfpkt);
+
+	/*
+	 *  cttrlcmd() - Control Function upwards in CAIF Stack.
+	 *  Used for signaling responses (CAIF_CTRLCMD_*_RSP)
+	 *  and asynchronous events from the modem  (CAIF_CTRLCMD_*_IND)
+	 *
+	 *  @layr:	Pointer to the current layer the receive function
+	 *		is implemented for (this pointer).
+	 *  @ctrl:	Control Command.
+	 */
+	void (*ctrlcmd) (struct cflayer *layr, enum caif_ctrlcmd ctrl,
+			 int phyid);
+
+	/*
+	 *  modemctrl() - Control Function used for controlling the modem.
+	 *  Used to signal down-wards in the CAIF stack.
+	 *  Returns 0 on success, < 0 upon failure.
+	 *
+	 *  @layr:	Pointer to the current layer the receive function
+	 *		is implemented for (this pointer).
+	 *  @ctrl:  Control Command.
+	 */
+	int (*modemcmd) (struct cflayer *layr, enum caif_modemcmd ctrl);
+
+	unsigned short prio;
+	unsigned int id;
+	unsigned int type;
+	char name[CAIF_LAYER_NAME_SZ];
+};
+
+/**
+ * layer_set_up() - Set the up pointer for a specified layer.
+ *  @layr: Layer where up pointer shall be set.
+ *  @above: Layer above.
+ */
+#define layer_set_up(layr, above) ((layr)->up = (struct cflayer *)(above))
+
+/**
+ *  layer_set_dn() - Set the down pointer for a specified layer.
+ *  @layr:  Layer where down pointer shall be set.
+ *  @below: Layer below.
+ */
+#define layer_set_dn(layr, below) ((layr)->dn = (struct cflayer *)(below))
+
+/**
+ * struct dev_info - Physical Device info information about physical layer.
+ * @dev:	Pointer to native physical device.
+ * @id:		Physical ID of the physical connection used by the
+ *		logical CAIF connection. Used by service layers to
+ *		identify their physical id to Caif MUX (CFMUXL)so
+ *		that the MUX can add the correct physical ID to the
+ *		packet.
+ */
+struct dev_info {
+	void *dev;
+	unsigned int id;
+};
+
+/**
+ * struct caif_payload_info - Payload information embedded in packet (sk_buff).
+ *
+ * @dev_info:	Information about the receiving device.
+ *
+ * @hdr_len:	Header length, used to align pay load on 32bit boundary.
+ *
+ * @channel_id: Channel ID of the logical CAIF connection.
+ *		Used by mux to insert channel id into the caif packet.
+ */
+struct caif_payload_info {
+	struct dev_info *dev_info;
+	unsigned short hdr_len;
+	unsigned short channel_id;
+};
+
+#endif	/* CAIF_LAYER_H_ */
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
new file mode 100644
index 0000000..366082c
--- /dev/null
+++ b/include/net/caif/cfcnfg.h
@@ -0,0 +1,133 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFCNFG_H_
+#define CFCNFG_H_
+#include <linux/spinlock.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfctrl.h>
+
+struct cfcnfg;
+
+/**
+ * enum cfcnfg_phy_type -  Types of physical layers defined in CAIF Stack
+ *
+ * @CFPHYTYPE_FRAG:	Fragmented frames physical interface.
+ * @CFPHYTYPE_CAIF:	Generic CAIF physical interface
+ */
+enum cfcnfg_phy_type {
+	CFPHYTYPE_FRAG = 1,
+	CFPHYTYPE_CAIF,
+	CFPHYTYPE_MAX
+};
+
+/**
+ * enum cfcnfg_phy_preference - Physical preference HW Abstraction
+ *
+ * @CFPHYPREF_UNSPECIFIED:	Default physical interface
+ *
+ * @CFPHYPREF_LOW_LAT:		Default physical interface for low-latency
+ *				traffic
+ * @CFPHYPREF_HIGH_BW:		Default physical interface for high-bandwidth
+ *				traffic
+ * @CFPHYPREF_LOOP:		TEST only Loopback interface simulating modem
+ *				responses.
+ *
+ */
+enum cfcnfg_phy_preference {
+	CFPHYPREF_UNSPECIFIED,
+	CFPHYPREF_LOW_LAT,
+	CFPHYPREF_HIGH_BW,
+	CFPHYPREF_LOOP
+};
+
+/**
+ * cfcnfg_create() - Create the CAIF configuration object.
+ */
+struct cfcnfg *cfcnfg_create(void);
+
+/**
+ * cfcnfg_remove() -  Remove the CFCNFG object
+ * @cfg: config object
+ */
+void cfcnfg_remove(struct cfcnfg *cfg);
+
+/**
+ * cfcnfg_add_phy_layer() - Adds a physical layer to the CAIF stack.
+ * @cnfg:	Pointer to a CAIF configuration object, created by
+ *		cfcnfg_create().
+ * @phy_type:	Specifies the type of physical interface, e.g.
+ *			CFPHYTYPE_FRAG.
+ * @dev:	Pointer to link layer device
+ * @phy_layer:	Specify the physical layer. The transmit function
+ *		MUST be set in the structure.
+ * @phyid:	The assigned physical ID for this layer, used in
+ *		cfcnfg_add_adapt_layer to specify PHY for the link.
+ * @pref:	The phy (link layer) preference.
+ * @fcs:	Specify if checksum is used in CAIF Framing Layer.
+ * @stx:	Specify if Start Of Frame eXtention is used.
+ */
+
+void
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
+		     void *dev, struct cflayer *phy_layer, u16 *phyid,
+		     enum cfcnfg_phy_preference pref,
+		     bool fcs, bool stx);
+
+/**
+ * cfcnfg_del_phy_layer - Deletes an phy layer from the CAIF stack.
+ *
+ * @cnfg:	Pointer to a CAIF configuration object, created by
+ *		cfcnfg_create().
+ * @phy_layer:	Adaptation layer to be removed.
+ */
+int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct cflayer *phy_layer);
+
+/**
+ * cfcnfg_del_adapt_layer - Deletes an adaptation layer from the CAIF stack.
+ *
+ * @cnfg:	Pointer to a CAIF configuration object, created by
+ *		cfcnfg_create().
+ * @adap_layer: Adaptation layer to be removed.
+ */
+int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer);
+
+/**
+ * cfcnfg_add_adaptation_layer - Add an adaptation layer to the CAIF stack.
+ *
+ * The adaptation Layer is where the interface to application or higher-level
+ * driver functionality is implemented.
+ *
+ * @cnfg:		Pointer to a CAIF configuration object, created by
+ *				cfcnfg_create().
+ * @param:		Link setup parameters.
+ * @adap_layer:		Specify the adaptation layer; the receive and
+ *			flow-control functions MUST be set in the structure.
+ *
+ */
+int
+cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
+			    struct cfctrl_link_param *param,
+			    struct cflayer *adap_layer);
+
+/**
+ * cfcnfg_get_phyid() - Get physical ID, given type.
+ * Returns one of the physical interfaces matching the given type.
+ * Zero if no match is found.
+ * @cnfg:	Configuration object
+ * @phy_pref:	Caif Link Layer preference
+ */
+struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cnfg,
+		     enum cfcnfg_phy_preference phy_pref);
+
+/**
+ * cfcnfg_get_named() - Get the Physical Identifier of CAIF Link Layer
+ * @cnfg:	Configuration object
+ * @name:	Name of the Physical Layer (Caif Link Layer)
+ */
+int cfcnfg_get_named(struct cfcnfg *cnfg, char *name);
+
+#endif				/* CFCNFG_H_ */
diff --git a/include/net/caif/cfctrl.h b/include/net/caif/cfctrl.h
new file mode 100644
index 0000000..dee25b8
--- /dev/null
+++ b/include/net/caif/cfctrl.h
@@ -0,0 +1,138 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFCTRL_H_
+#define CFCTRL_H_
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfsrvl.h>
+
+/* CAIF Control packet commands */
+enum cfctrl_cmd {
+	CFCTRL_CMD_LINK_SETUP = 0,
+	CFCTRL_CMD_LINK_DESTROY = 1,
+	CFCTRL_CMD_LINK_ERR = 2,
+	CFCTRL_CMD_ENUM = 3,
+	CFCTRL_CMD_SLEEP = 4,
+	CFCTRL_CMD_WAKE = 5,
+	CFCTRL_CMD_LINK_RECONF = 6,
+	CFCTRL_CMD_START_REASON = 7,
+	CFCTRL_CMD_RADIO_SET = 8,
+	CFCTRL_CMD_MODEM_SET = 9,
+	CFCTRL_CMD_MASK = 0xf
+};
+
+/* Channel types */
+enum cfctrl_srv {
+	CFCTRL_SRV_DECM = 0,
+	CFCTRL_SRV_VEI = 1,
+	CFCTRL_SRV_VIDEO = 2,
+	CFCTRL_SRV_DBG = 3,
+	CFCTRL_SRV_DATAGRAM = 4,
+	CFCTRL_SRV_RFM = 5,
+	CFCTRL_SRV_UTIL = 6,
+	CFCTRL_SRV_MASK = 0xf
+};
+
+#define CFCTRL_RSP_BIT 0x20
+#define CFCTRL_ERR_BIT 0x10
+
+struct cfctrl_rsp {
+	void (*linksetup_rsp)(struct cflayer *layer, u8 linkid,
+			      enum cfctrl_srv serv, u8 phyid,
+			      struct cflayer *adapt_layer);
+	void (*linkdestroy_rsp)(struct cflayer *layer, u8 linkid,
+				struct cflayer *client_layer);
+	void (*linkerror_ind)(void);
+	void (*enum_rsp)(void);
+	void (*sleep_rsp)(void);
+	void (*wake_rsp)(void);
+	void (*restart_rsp)(void);
+	void (*radioset_rsp)(void);
+	void (*reject_rsp)(struct cflayer *layer, u8 linkid,
+				struct cflayer *client_layer);;
+};
+
+/* Link Setup Parameters for CAIF-Links. */
+struct cfctrl_link_param {
+	enum cfctrl_srv linktype;/* (T3,T0) Type of Channel */
+	u8 priority;		  /* (P4,P0) Priority of the channel */
+	u8 phyid;		  /* (U2-U0) Physical interface to connect */
+	u8 endpoint;		  /* (E1,E0) Endpoint for data channels */
+	u8 chtype;		  /* (H1,H0) Channel-Type, applies to
+				   *            VEI, DEBUG */
+	union {
+		struct {
+			u8 connid;	/*  (D7,D0) Video LinkId */
+		} video;
+
+		struct {
+			u32 connid;	/* (N31,Ngit0) Connection ID used
+					 *  for Datagram */
+		} datagram;
+
+		struct {
+			u32 connid;	/* Connection ID used for RFM */
+			char volume[20];	/* Volume to mount for RFM */
+		} rfm;		/* Configuration for RFM */
+
+		struct {
+			u16 fifosize_kb;	/* Psock FIFO size in KB */
+			u16 fifosize_bufs;	/* Psock # signal buffers */
+			char name[16];	/* Name of the PSOCK service */
+			u8 params[255];	/* Link setup Parameters> */
+			u16 paramlen;	/* Length of Link Setup
+						 *   Parameters */
+		} utility;	/* Configuration for Utility Links (Psock) */
+	} u;
+};
+
+/* This structure is used internally in CFCTRL */
+struct cfctrl_request_info {
+	int sequence_no;
+	enum cfctrl_cmd cmd;
+	u8 channel_id;
+	struct cfctrl_link_param param;
+	struct cfctrl_request_info *next;
+	struct cflayer *client_layer;
+};
+
+struct cfctrl {
+	struct cfsrvl serv;
+	struct cfctrl_rsp res;
+	atomic_t req_seq_no;
+	atomic_t rsp_seq_no;
+	struct cfctrl_request_info *first_req;
+	/* Protects from simultaneous access to first_req list */
+	spinlock_t info_list_lock;
+#ifndef CAIF_NO_LOOP
+	u8 loop_linkid;
+	int loop_linkused[256];
+	/* Protects simultaneous access to loop_linkid and loop_linkused */
+	spinlock_t loop_linkid_lock;
+#endif
+
+};
+
+void cfctrl_enum_req(struct cflayer *cfctrl, u8 physlinkid);
+void cfctrl_linkup_request(struct cflayer *cfctrl,
+			   struct cfctrl_link_param *param,
+			   struct cflayer *user_layer);
+int  cfctrl_linkdown_req(struct cflayer *cfctrl, u8 linkid,
+			 struct cflayer *client);
+void cfctrl_sleep_req(struct cflayer *cfctrl);
+void cfctrl_wake_req(struct cflayer *cfctrl);
+void cfctrl_getstartreason_req(struct cflayer *cfctrl);
+struct cflayer *cfctrl_create(void);
+void cfctrl_set_dnlayer(struct cflayer *this, struct cflayer *dn);
+void cfctrl_set_uplayer(struct cflayer *this, struct cflayer *up);
+struct cfctrl_rsp *cfctrl_get_respfuncs(struct cflayer *layer);
+bool cfctrl_req_eq(struct cfctrl_request_info *r1,
+		   struct cfctrl_request_info *r2);
+void cfctrl_insert_req(struct cfctrl *ctrl,
+			      struct cfctrl_request_info *req);
+struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
+					      struct cfctrl_request_info *req);
+#endif				/* CFCTRL_H_ */
diff --git a/include/net/caif/cffrml.h b/include/net/caif/cffrml.h
new file mode 100644
index 0000000..3f14d2e
--- /dev/null
+++ b/include/net/caif/cffrml.h
@@ -0,0 +1,16 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFFRML_H_
+#define CFFRML_H_
+#include <net/caif/caif_layer.h>
+
+struct cffrml;
+struct cflayer *cffrml_create(u16 phyid, bool DoFCS);
+void cffrml_set_uplayer(struct cflayer *this, struct cflayer *up);
+void cffrml_set_dnlayer(struct cflayer *this, struct cflayer *dn);
+
+#endif /* CFFRML_H_ */
diff --git a/include/net/caif/cfmuxl.h b/include/net/caif/cfmuxl.h
new file mode 100644
index 0000000..4e1b4f3
--- /dev/null
+++ b/include/net/caif/cfmuxl.h
@@ -0,0 +1,22 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFMUXL_H_
+#define CFMUXL_H_
+#include <net/caif/caif_layer.h>
+
+struct cfsrvl;
+struct cffrml;
+
+struct cflayer *cfmuxl_create(void);
+int cfmuxl_set_uplayer(struct cflayer *layr, struct cflayer *up, u8 linkid);
+struct cflayer *cfmuxl_remove_dnlayer(struct cflayer *layr, u8 phyid);
+int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *up, u8 phyid);
+struct cflayer *cfmuxl_remove_uplayer(struct cflayer *layr, u8 linkid);
+bool cfmuxl_is_phy_inuse(struct cflayer *layr, u8 phyid);
+u8 cfmuxl_get_phyid(struct cflayer *layr, u8 channel_id);
+
+#endif				/* CFMUXL_H_ */
diff --git a/include/net/caif/cfpkt.h b/include/net/caif/cfpkt.h
new file mode 100644
index 0000000..fbc681b
--- /dev/null
+++ b/include/net/caif/cfpkt.h
@@ -0,0 +1,274 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFPKT_H_
+#define CFPKT_H_
+#include <net/caif/caif_layer.h>
+#include <linux/types.h>
+struct cfpkt;
+
+/* Create a CAIF packet.
+ * len: Length of packet to be created
+ * @return New packet.
+ */
+struct cfpkt *cfpkt_create(u16 len);
+
+/* Create a CAIF packet.
+ * data Data to copy.
+ * len Length of packet to be created
+ * @return New packet.
+ */
+struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned int len);
+/*
+ * Destroy a CAIF Packet.
+ * pkt Packet to be destoyed.
+ */
+void cfpkt_destroy(struct cfpkt *pkt);
+
+/*
+ * Extract header from packet.
+ *
+ * pkt Packet to extract header data from.
+ * data Pointer to copy the header data into.
+ * len Length of head data to copy.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_extr_head(struct cfpkt *pkt, void *data, u16 len);
+
+/*
+ * Peek header from packet.
+ * Reads data from packet without changing packet.
+ *
+ * pkt Packet to extract header data from.
+ * data Pointer to copy the header data into.
+ * len Length of head data to copy.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_peek_head(struct cfpkt *pkt, void *data, u16 len);
+
+/*
+ * Extract header from trailer (end of packet).
+ *
+ * pkt Packet to extract header data from.
+ * data Pointer to copy the trailer data into.
+ * len Length of header data to copy.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_extr_trail(struct cfpkt *pkt, void *data, u16 len);
+
+/*
+ * Add header to packet.
+ *
+ *
+ * pkt Packet to add header data to.
+ * data Pointer to data to copy into the header.
+ * len Length of header data to copy.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_add_head(struct cfpkt *pkt, const void *data, u16 len);
+
+/*
+ * Add trailer to packet.
+ *
+ *
+ * pkt Packet to add trailer data to.
+ * data Pointer to data to copy into the trailer.
+ * len Length of trailer data to copy.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_add_trail(struct cfpkt *pkt, const void *data, u16 len);
+
+/*
+ * Pad trailer on packet.
+ * Moves data pointer in packet, no content copied.
+ *
+ * pkt Packet in which to pad trailer.
+ * len Length of padding to add.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_pad_trail(struct cfpkt *pkt, u16 len);
+
+/*
+ * Add a single byte to packet body (tail).
+ *
+ * pkt Packet in which to add byte.
+ * data Byte to add.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_addbdy(struct cfpkt *pkt, const u8 data);
+
+/*
+ * Add a data to packet body (tail).
+ *
+ * pkt Packet in which to add data.
+ * data Pointer to data to copy into the packet body.
+ * len Length of data to add.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_add_body(struct cfpkt *pkt, const void *data, u16 len);
+
+/*
+ * Checks whether there are more data to process in packet.
+ * pkt Packet to check.
+ * @return true if more data are available in packet false otherwise
+ */
+bool cfpkt_more(struct cfpkt *pkt);
+
+/*
+ * Checks whether the packet is erroneous,
+ * i.e. if it has been attempted to extract more data than available in packet
+ * or writing more data than has been allocated in cfpkt_create().
+ * pkt Packet to check.
+ * @return true on error false otherwise
+ */
+bool cfpkt_erroneous(struct cfpkt *pkt);
+
+/*
+ * Get the packet length.
+ * pkt Packet to get length from.
+ * @return Number of bytes in packet.
+ */
+u16 cfpkt_getlen(struct cfpkt *pkt);
+
+/*
+ * Set the packet length, by adjusting the trailer pointer according to length.
+ * pkt Packet to set length.
+ * len Packet length.
+ * @return Number of bytes in packet.
+ */
+int cfpkt_setlen(struct cfpkt *pkt, u16 len);
+
+/*
+ * cfpkt_append - Appends a packet's data to another packet.
+ * dstpkt:    Packet to append data into, WILL BE FREED BY THIS FUNCTION
+ * addpkt:    Packet to be appended and automatically released,
+ *            WILL BE FREED BY THIS FUNCTION.
+ * expectlen: Packet's expected total length. This should be considered
+ *            as a hint.
+ * NB: Input packets will be destroyed after appending and cannot be used
+ * after calling this function.
+ * @return    The new appended packet.
+ */
+struct cfpkt *cfpkt_append(struct cfpkt *dstpkt, struct cfpkt *addpkt,
+		      u16 expectlen);
+
+/*
+ * cfpkt_split - Split a packet into two packets at the specified split point.
+ * pkt: Packet to be split (will contain the first part of the data on exit)
+ * pos: Position to split packet in two parts.
+ * @return The new packet, containing the second part of the data.
+ */
+struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos);
+
+/*
+ * Iteration function, iterates the packet buffers from start to end.
+ *
+ * Checksum iteration function used to iterate buffers
+ * (we may have packets consisting of a chain of buffers)
+ * pkt:       Packet to calculate checksum for
+ * iter_func: Function pointer to iteration function
+ * chks:      Checksum calculated so far.
+ * buf:       Pointer to the buffer to checksum
+ * len:       Length of buf.
+ * data:      Initial checksum value.
+ * @return    Checksum of buffer.
+ */
+
+u16 cfpkt_iterate(struct cfpkt *pkt,
+		u16 (*iter_func)(u16 chks, void *buf, u16 len),
+		u16 data);
+
+/* Append by giving user access to packet buffer
+ * cfpkt Packet to append to
+ * buf Buffer inside pkt that user shall copy data into
+ * buflen Length of buffer and number of bytes added to packet
+ * @return 0 on error, 1 on success
+ */
+int cfpkt_raw_append(struct cfpkt *cfpkt, void **buf, unsigned int buflen);
+
+/* Extract by giving user access to packet buffer
+ * cfpkt Packet to extract from
+ * buf Buffer inside pkt that user shall copy data from
+ * buflen Length of buffer and number of bytes removed from packet
+ * @return 0 on error, 1 on success
+ */
+int cfpkt_raw_extract(struct cfpkt *cfpkt, void **buf, unsigned int buflen);
+
+/* Map from a "native" packet (e.g. Linux Socket Buffer) to a CAIF packet.
+ *  dir - Direction indicating whether this packet is to be sent or received.
+ *  nativepkt  - The native packet to be transformed to a CAIF packet
+ *  @return The mapped CAIF Packet CFPKT.
+ */
+struct cfpkt *cfpkt_fromnative(enum caif_direction dir, void *nativepkt);
+
+/* Map from a CAIF packet to a "native" packet (e.g. Linux Socket Buffer).
+ *  pkt  - The CAIF packet to be transformed into a "native" packet.
+ *  @return The native packet transformed from a CAIF packet.
+ */
+void *cfpkt_tonative(struct cfpkt *pkt);
+
+/*
+ * Insert a packet in the packet queue.
+ * pktq Packet queue to insert into
+ * pkt Packet to be inserted in queue
+ * prio Priority of packet
+ */
+void cfpkt_queue(struct cfpktq *pktq, struct cfpkt *pkt,
+		 unsigned short prio);
+
+/*
+ * Remove a packet from the packet queue.
+ * pktq Packet queue to fetch packets from.
+ * @return Dequeued packet.
+ */
+struct cfpkt *cfpkt_dequeue(struct cfpktq *pktq);
+
+/*
+ * Peek into a packet from the packet queue.
+ * pktq Packet queue to fetch packets from.
+ * @return Peeked packet.
+ */
+struct cfpkt *cfpkt_qpeek(struct cfpktq *pktq);
+
+/*
+ * Initiates the packet queue.
+ * @return Pointer to new packet queue.
+ */
+struct cfpktq *cfpktq_create(void);
+
+/*
+ * Get the number of packets in the queue.
+ * pktq Packet queue to fetch count from.
+ * @return Number of packets in queue.
+ */
+int cfpkt_qcount(struct cfpktq *pktq);
+
+/*
+ * Put content of packet into buffer for debuging purposes.
+ * pkt Packet to copy data from
+ * buf Buffer to copy data into
+ * buflen Length of data to copy
+ * @return Pointer to copied data
+ */
+char *cfpkt_log_pkt(struct cfpkt *pkt, char *buf, int buflen);
+
+/*
+ * Clones a packet and releases the original packet.
+ * This is used for taking ownership of a packet e.g queueing.
+ * pkt Packet to clone and release.
+ * @return Cloned packet.
+ */
+struct cfpkt *cfpkt_clone_release(struct cfpkt *pkt);
+
+
+/*
+ * Returns packet information for a packet.
+ * pkt Packet to get info from;
+ * @return Packet information
+ */
+struct caif_payload_info *cfpkt_info(struct cfpkt *pkt);
+/*! @} */
+#endif				/* CFPKT_H_ */
diff --git a/include/net/caif/cfserl.h b/include/net/caif/cfserl.h
new file mode 100644
index 0000000..b837432
--- /dev/null
+++ b/include/net/caif/cfserl.h
@@ -0,0 +1,12 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSERL_H_
+#define CFSERL_H_
+#include <net/caif/caif_layer.h>
+
+struct cflayer *cfserl_create(int type, int instance, bool use_stx);
+#endif				/* CFSERL_H_ */
diff --git a/include/net/caif/cfsrvl.h b/include/net/caif/cfsrvl.h
new file mode 100644
index 0000000..b2a12db
--- /dev/null
+++ b/include/net/caif/cfsrvl.h
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSRVL_H_
+#define CFSRVL_H_
+#include <linux/list.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+struct cfsrvl {
+	struct cflayer layer;
+	bool open;
+	bool phy_flow_on;
+	bool modem_flow_on;
+	struct dev_info dev_info;
+};
+
+struct cflayer *cfvei_create(u8 linkid, struct dev_info *dev_info);
+struct cflayer *cfdgml_create(u8 linkid, struct dev_info *dev_info);
+struct cflayer *cfutill_create(u8 linkid, struct dev_info *dev_info);
+struct cflayer *cfvidl_create(u8 linkid, struct dev_info *dev_info);
+struct cflayer *cfrfml_create(u8 linkid, struct dev_info *dev_info);
+struct cflayer *cfdbgl_create(u8 linkid, struct dev_info *dev_info);
+bool cfsrvl_phyid_match(struct cflayer *layer, int phyid);
+void cfservl_destroy(struct cflayer *layer);
+void cfsrvl_init(struct cfsrvl *service,
+		 u8 channel_id,
+		 struct dev_info *dev_info);
+bool cfsrvl_ready(struct cfsrvl *service, int *err);
+u8 cfsrvl_getphyid(struct cflayer *layer);
+
+#endif				/* CFSRVL_H_ */
-- 
1.6.3.3

