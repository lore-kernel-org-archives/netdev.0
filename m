From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 03/13] net-caif: add CAIF generic protocol stack
 header files
Date: Wed, 20 Jan 2010 23:55:20 +0100
Message-ID: <1264028130-14364-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab0ATX4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:23 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00DPOIDFDL70@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:03 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:03 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Add include files for the generic CAIF protocol stack. This layer
is somewhat generic in order to be able to use and test it outside
the Linux Kernel.

caif_layer.h - Defines the structure of the CAIF protocol layers
cfcnfg.h     - CAIF Configuration Module for services and link layers
cfctrl.h     - CAIF Control Protocol Layer
cffrml.h     - CAIF Framing Layer
cfglue.h     - CAIF Glue Layer for allocation, logging etc
cflist.h     - CAIF List implementation
cfmuxl.h     - CAIF Muxing Layer
cfpkt.h	     - CAIF Packet layer (skb helper functions)
cfserl.h     - CAIF Serial Layer
cfsrvl.h     - CAIF Service Layer

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/generic/caif_layer.h |  225 +++++++++++++++++++++++++++
 include/net/caif/generic/cfcnfg.h     |  110 +++++++++++++
 include/net/caif/generic/cfctrl.h     |  136 ++++++++++++++++
 include/net/caif/generic/cffrml.h     |   19 +++
 include/net/caif/generic/cfglue.h     |  110 +++++++++++++
 include/net/caif/generic/cflst.h      |   19 +++
 include/net/caif/generic/cfmuxl.h     |   22 +++
 include/net/caif/generic/cfpkt.h      |  274 +++++++++++++++++++++++++++++++++
 include/net/caif/generic/cfserl.h     |   14 ++
 include/net/caif/generic/cfsrvl.h     |   33 ++++
 10 files changed, 962 insertions(+), 0 deletions(-)

diff --git a/include/net/caif/generic/caif_layer.h b/include/net/caif/generic/caif_layer.h
new file mode 100644
index 0000000..2ae3236
--- /dev/null
+++ b/include/net/caif/generic/caif_layer.h
@@ -0,0 +1,225 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_LAYER_H_
+#define CAIF_LAYER_H_
+
+#include <net/caif/generic/cfglue.h>
+
+struct layer;
+struct cfpkt;
+struct cfpktq;
+struct payload_info;
+struct caif_packet_funcs;
+
+#define CAIF_MAX_FRAMESIZE 4096
+#define CAIF_MAX_PAYLOAD_SIZE (4096 - 64)
+#define CAIF_NEEDED_HEADROOM (10)
+#define CAIF_NEEDED_TAILROOM (2)
+
+
+#define CAIF_LAYER_NAME_SZ 16
+#define CAIF_SUCCESS    1
+#define CAIF_FAILURE    0
+
+/*
+ * CAIF Control Signaling.
+ *  These commands are sent upwards in the CAIF stack. They are used for
+ *  signaling originating from the modem.
+ *  These are either responses (*_RSP) or events (*_IND).
+ */
+enum caif_ctrlcmd {
+	/* Flow Control is OFF, transmit function should stop sending data */
+	CAIF_CTRLCMD_FLOW_OFF_IND,
+	/* Flow Control is ON, transmit function can start sending data */
+	CAIF_CTRLCMD_FLOW_ON_IND,
+	/* Remote end modem has decided to close down channel */
+	CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND,
+	/* Called initially when the layer below has finished initialization */
+	CAIF_CTRLCMD_INIT_RSP,
+	/* Called when de-initialization is complete */
+	CAIF_CTRLCMD_DEINIT_RSP,
+	/* Called if initialization fails */
+	CAIF_CTRLCMD_INIT_FAIL_RSP,
+	/* Called if physical interface cannot send more packets. */
+	_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
+	/* Called if physical interface is able to send packets again. */
+	_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND,
+	/* Called if physical interface is going down. */
+	_CAIF_CTRLCMD_PHYIF_DOWN_IND,
+};
+
+/*
+ * Modem Control Signaling.
+ *  These are requests sent 'downwards' in the stack.
+ *  Flow ON, OFF can be indicated to the modem.
+ */
+enum caif_modemcmd {
+	/* Flow Control is ON, transmit function can start sending data */
+	CAIF_MODEMCMD_FLOW_ON_REQ = 0,
+	/* Flow Control is OFF, transmit function should stop sending data */
+	CAIF_MODEMCMD_FLOW_OFF_REQ = 1,
+	/* Notify physical layer that it is in use */
+	_CAIF_MODEMCMD_PHYIF_USEFULL = 3,
+	/* Notify physical layer that it is no longer in use */
+	_CAIF_MODEMCMD_PHYIF_USELESS = 4
+};
+
+/*
+ * CAIF Packet Direction.
+ * Indicate if a packet is to be sent out or to be received in.
+ */
+enum caif_direction {
+	CAIF_DIR_IN = 0,	/* Incoming packet received. */
+	CAIF_DIR_OUT = 1	/* Outgoing packet to be transmitted. */
+};
+
+/*
+ * This structure defines the generic layered structure in CAIF.
+ *  It is inspired by the "Protocol Layer Design Pattern" (Streams).
+ *
+ *  It defines a generic layering structure, used by all CAIF Layers and the
+ *  layers interfacing CAIF.
+ *
+ *  In order to integrate with CAIF an adaptation layer on top of the CAIF stack
+ *  and PHY layer below the CAIF stack
+ *  must be implemented. These layer must follow the design principles below.
+ *
+ *  Principles for layering of protocol layers:
+ *    -# All layers must use this structure. If embedding it, then place this
+ *	     structure first in the layer specific structure.
+ *    -# Each layer should not depend on any others layer private data.
+ *    -# In order to send data upwards do
+ *	 layer->up->receive(layer->up, packet);
+ *    -# In order to send data downwards do
+ *	 layer->dn->transmit(layer->dn, info, packet);
+ */
+struct layer {
+
+	struct layer *up;	/* Pointer to the layer above */
+	struct layer *dn;	/* Pointer to the layer below */
+	/*
+	 *  Receive Function.
+	 *  Contract: Each layer must implement a receive function passing the
+	 *  CAIF packets upwards in the stack.
+	 *	Packet handling rules:
+	 *	      -# The CAIF packet (cfpkt) cannot be accessed after
+	 *		     passing it to the next layer using up->receive().
+	 *	      -# If parsing of the packet fails, the packet must be
+	 *		     destroyed and -1 returned from the function.
+	 *	      -# If parsing succeeds (and above layers return OK) then
+	 *		      the function must return a value > 0.
+	 *
+	 *  @param[in] layr Pointer to the current layer the receive function is
+	 *		implemented for (this pointer).
+	 *  @param[in] cfpkt Pointer to CaifPacket to be handled.
+	 *  @return result < 0 indicates an error, 0 or positive value
+	 *	     indicates success.
+	 */
+	int (*receive)(struct layer *layr, struct cfpkt *cfpkt);
+
+	/*
+	 *  Transmit Function.
+	 *  Contract: Each layer must implement a transmit function passing the
+	 *	CAIF packet downwards in the stack.
+	 *	Packet handling rules:
+	 *	      -# The CAIF packet (cfpkt) ownership is passed to the
+	 *		 transmit function. This means that the the packet
+	 *		 cannot be accessed after passing it to the below
+	 *		 layer using dn->transmit().
+	 *
+	 *	      -# If transmit fails, however, the ownership is returned
+	 *		 to thecaller. The caller of "dn->transmit()" must
+	 *		 destroy or resend packet.
+	 *
+	 *	      -# Return value less than zero means error, zero or
+	 *		 greater than zero means OK.
+	 *
+	 *  @param[in] layr  Pointer to the current layer the receive function
+	 *			    is	implemented for (this pointer).
+	 *  @param[in] cfpkt Pointer to CaifPacket to be handled.
+	 *  @return	     result < 0 indicates an error, 0 or positive value
+	 *		     indicate success.
+	 */
+	int (*transmit) (struct layer *layr, struct cfpkt *cfpkt);
+
+	/*
+	 *  Control Function used to signal upwards in the CAIF stack.
+	 *  Used for signaling responses (CAIF_CTRLCMD_*_RSP)
+	 *  and asynchronous events from the modem  (CAIF_CTRLCMD_*_IND)
+	 *
+	 *  @param[in] layr  Pointer to the current layer the receive function
+	 *		     is implemented for (this pointer).
+	 *  @param[in] ctrl  Control Command.
+	 */
+	void (*ctrlcmd) (struct layer *layr, enum caif_ctrlcmd ctrl,
+			 int phyid);
+
+	/*
+	 *  Control Function used for controlling the modem. Used to signal
+	 *  down-wards in the CAIF stack.
+	 *  @returns 0 on success, < 0 upon failure.
+	 *  @param[in] layr  Pointer to the current layer the receive function
+	 *		     is implemented for (this pointer).
+	 *  @param[in] ctrl  Control Command.
+	 */
+	int (*modemcmd) (struct layer *layr, enum caif_modemcmd ctrl);
+
+	struct layer *next;	/*
+				 *   Pointer to chain of layers, up/dn will
+				 *   then point at the first element of a
+				 *   which then should be iterated through
+				 *   the next pointer.
+				 */
+	unsigned short prio;	/* Priority of this layer */
+	unsigned int id;	/* The identity of this layer. */
+	unsigned int type;	/* The type of this layer */
+	char name[CAIF_LAYER_NAME_SZ];		/* Name of the layer */
+};
+/*
+ * Set the up pointer for a specified layer.
+ *  @param layr Layer where up pointer shall be set.
+ *  @param above Layer above.
+ */
+#define layer_set_up(layr, above) ((layr)->up = (struct layer *)(above))
+
+/*
+ * Set the dn pointer for a specified layer.
+ *  @param layr Layer where down pointer shall be set.
+ *  @param below Layer below.
+ */
+#define layer_set_dn(layr, below) ((layr)->dn = (struct layer *)(below))
+
+/* Physical Device info, holding information about physical layer. */
+struct dev_info {
+	/* Pointer to native physical device */
+	void *dev;
+
+	/*
+	 * Physical ID of the physical connection used by the logical CAIF
+	 * connection. Used by service layers to identify their physical id
+	 * to Caif MUX (CFMUXL)so that the MUX can add the correct physical
+	 * ID to the packet.
+	 */
+	unsigned int id;
+};
+
+/* Transmit info, passed downwards in protocol layers.  */
+struct payload_info {
+	/* Information about the receiving device */
+	struct dev_info *dev_info;
+
+	/* Header length, used to align pay load on 32bit boundary.  */
+	unsigned short hdr_len;
+
+	/*
+	 * Channel ID of the logical CAIF connection.
+	 * Used by mux to insert channel id into the caif packet.
+	 */
+	unsigned short channel_id;
+};
+
+#endif	/* CAIF_LAYER_H_ */
diff --git a/include/net/caif/generic/cfcnfg.h b/include/net/caif/generic/cfcnfg.h
new file mode 100644
index 0000000..3461235
--- /dev/null
+++ b/include/net/caif/generic/cfcnfg.h
@@ -0,0 +1,110 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFCNFG_H_
+#define CFCNFG_H_
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfctrl.h>
+
+struct cfcnfg;
+
+/* Types of physical layers defined in CAIF Stack */
+enum cfcnfg_phy_type {
+	/* Fragmented frames physical interface */
+	CFPHYTYPE_FRAG = 1,
+	/* Generic CAIF physical interface */
+	CFPHYTYPE_CAIF,
+	CFPHYTYPE_MAX
+};
+
+/* Physical preference - HW Abstraction */
+enum cfcnfg_phy_preference {
+	/* Default physical interface */
+	CFPHYPREF_UNSPECIFIED,
+	/* Default physical interface for low-latency traffic */
+	CFPHYPREF_LOW_LAT,
+	/* Default physical interface for high-bandwidth traffic */
+	CFPHYPREF_HIGH_BW,
+	/* TEST only Loopback interface simulating modem responses */
+	CFPHYPREF_LOOP
+};
+
+/*
+ * Create the CAIF configuration object.
+ * @return The created instance of a CFCNFG object.
+ */
+struct cfcnfg *cfcnfg_create(void);
+
+/* Remove the CFCNFG object */
+void cfcnfg_remove(struct cfcnfg *cfg);
+
+/*
+ * Adds a physical layer to the CAIF stack.
+ * @param cnfg Pointer to a CAIF configuration object, created by
+ *				cfcnfg_create().
+ * @param phy_type Specifies the type of physical interface, e.g.
+ *		    CFPHYTYPE_FRAG.
+ * @param phy_layer Specify the physical layer. The transmit function
+ *		    MUST be set in the structure.
+ * @param phyid [out] The assigned physical ID for this layer,
+ *		      used in \ref cfcnfg_add_adapt_layer to specify
+ *		      PHY for the link.
+ */
+
+void
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
+		     void *dev, struct layer *phy_layer, uint16 *phyid,
+		     enum cfcnfg_phy_preference pref,
+		     bool fcs, bool stx);
+
+/*
+ * Deletes an phy layer from the CAIF stack.
+ *
+ * @param cnfg Pointer to a CAIF configuration object, created by
+ *			   cfcnfg_create().
+ * @param phy_layer Adaptation layer to be removed.
+ * @return 0 on success.
+ */
+int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct layer *phy_layer);
+
+
+/*
+ * Deletes an adaptation layer from the CAIF stack.
+ *
+ * @param cnfg Pointer to a CAIF configuration object, created by
+ *			   cfcnfg_create().
+ * @param adap_layer Adaptation layer to be removed.
+ * @return 0 on success.
+ */
+int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct layer *adap_layer);
+
+
+/*
+ * Adds an adaptation layer to the CAIF stack.
+ * The adaptation Layer is where the interface to application or higher-level
+ * driver functionality is implemented.
+ *
+ * @param cnfg		Pointer to a CAIF configuration object, created by
+ *				cfcnfg_create().
+ * @param param		Link setup parameters.
+ * @param adap_layer	Specify the adaptation layer; the receive and flow-control
+			functions MUST be set in the structure.
+ * @return		true on success, false upon failure.
+ */
+bool
+cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
+			    struct cfctrl_link_param *param,
+			    struct layer *adap_layer);
+/*
+ * Get physical ID, given type.
+ * @return Returns one of the physical interfaces matching the given type.
+ *	   Zero if no match is found.
+ */
+struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cnfg,
+		     enum cfcnfg_phy_preference phy_pref);
+int cfcnfg_get_named(struct cfcnfg *cnfg, char *name);
+
+#endif				/* CFCNFG_H_ */
diff --git a/include/net/caif/generic/cfctrl.h b/include/net/caif/generic/cfctrl.h
new file mode 100644
index 0000000..5c02de8
--- /dev/null
+++ b/include/net/caif/generic/cfctrl.h
@@ -0,0 +1,136 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFCTRL_H_
+#define CFCTRL_H_
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfsrvl.h>
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
+	void (*linksetup_rsp)(struct layer *layer, uint8 linkid,
+			      enum cfctrl_srv serv, uint8 phyid,
+			      struct layer *adapt_layer);
+	void (*linkdestroy_rsp)(struct layer *layer, uint8 linkid,
+				struct layer *client_layer);
+	void (*linkerror_ind)(void);
+	void (*enum_rsp)(void);
+	void (*sleep_rsp)(void);
+	void (*wake_rsp)(void);
+	void (*restart_rsp)(void);
+	void (*radioset_rsp)(void);
+	void (*reject_rsp)(struct layer *layer, uint8 linkid,
+				struct layer *client_layer);;
+};
+
+/* Link Setup Parameters for CAIF-Links. */
+struct cfctrl_link_param {
+	enum cfctrl_srv linktype;/* (T3,T0) Type of Channel */
+	uint8 priority;		  /* (P4,P0) Priority of the channel */
+	uint8 phyid;		  /* (U2-U0) Physical interface to connect */
+	uint8 endpoint;		  /* (E1,E0) Endpoint for data channels */
+	uint8 chtype;		  /* (H1,H0) Channel-Type, applies to
+				   *            VEI, DEBUG */
+	union {
+		struct {
+			uint8 connid;	/*  (D7,D0) Video LinkId */
+		} video;
+
+		struct {
+			uint32 connid;	/* (N31,Ngit0) Connection ID used
+					 *  for Datagram */
+		} datagram;
+
+		struct {
+			uint32 connid;	/* Connection ID used for RFM */
+			char volume[20];	/* Volume to mount for RFM */
+		} rfm;		/* Configuration for RFM */
+
+		struct {
+			uint16 fifosize_kb;	/* Psock FIFO size in KB */
+			uint16 fifosize_bufs;	/* Psock # signal buffers */
+			char name[16];	/* Name of the PSOCK service */
+			uint8 params[255];	/* Link setup Parameters> */
+			uint16 paramlen;	/* Length of Link Setup
+						 *   Parameters */
+		} utility;	/* Configuration for Utility Links (Psock) */
+	} u;
+};
+
+/* This structure is used internally in CFCTRL */
+struct cfctrl_request_info {
+	int sequence_no;
+	enum cfctrl_cmd cmd;
+	uint8 channel_id;
+	struct cfctrl_link_param param;
+	struct cfctrl_request_info *next;
+	struct layer *client_layer;
+};
+
+struct cfctrl {
+	struct cfsrvl serv;
+	struct cfctrl_rsp res;
+	cfglu_atomic_t req_seq_no;
+	cfglu_atomic_t rsp_seq_no;
+	struct cfctrl_request_info *first_req;
+	cfglu_lock_t info_list_lock;
+#ifndef CAIF_NO_LOOP
+	uint8 loop_linkid;
+	int loop_linkused[256];
+	cfglu_lock_t loop_linkid_lock;
+#endif
+
+};
+
+void cfctrl_enum_req(struct layer *cfctrl, uint8 physlinkid);
+void cfctrl_linkup_request(struct layer *cfctrl,
+			   struct cfctrl_link_param *param,
+			   struct layer *user_layer);
+int  cfctrl_linkdown_req(struct layer *cfctrl, uint8 linkid,
+			 struct layer *client);
+void cfctrl_sleep_req(struct layer *cfctrl);
+void cfctrl_wake_req(struct layer *cfctrl);
+void cfctrl_getstartreason_req(struct layer *cfctrl);
+struct layer *cfctrl_create(void);
+void cfctrl_set_dnlayer(struct layer *this, struct layer *dn);
+void cfctrl_set_uplayer(struct layer *this, struct layer *up);
+struct cfctrl_rsp *cfctrl_get_respfuncs(struct layer *layer);
+bool cfctrl_req_eq(struct cfctrl_request_info *r1,
+		   struct cfctrl_request_info *r2);
+void cfctrl_insert_req(struct cfctrl *ctrl,
+			      struct cfctrl_request_info *req);
+struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
+					      struct cfctrl_request_info *req);
+#endif				/* CFCTRL_H_ */
diff --git a/include/net/caif/generic/cffrml.h b/include/net/caif/generic/cffrml.h
new file mode 100644
index 0000000..83aab48
--- /dev/null
+++ b/include/net/caif/generic/cffrml.h
@@ -0,0 +1,19 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFFRML_H_
+#define CFFRML_H_
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cflst.h>
+
+struct cffrml;
+struct layer *cffrml_create(uint16 phyid, bool DoFCS);
+void cffrml_set_uplayer(struct layer *this, struct layer *up);
+void cffrml_set_dnlayer(struct layer *this, struct layer *dn);
+void cffrml_destroy(struct layer *layer);
+
+#endif /* CFFRML_H_ */
diff --git a/include/net/caif/generic/cfglue.h b/include/net/caif/generic/cfglue.h
new file mode 100644
index 0000000..3b573f6
--- /dev/null
+++ b/include/net/caif/generic/cfglue.h
@@ -0,0 +1,110 @@
+/*
+ * This file contains the OS and HW dependencies for CAIF.
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFGLUE_H_
+#define CFGLUE_H_
+
+#include <linux/module.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
+#include <linux/hardirq.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+#include <linux/crc-ccitt.h>
+
+/* Unsigned 8 bit */
+typedef __u8 uint8;
+
+/* Unsigned 16 bit */
+typedef __u16 uint16;
+
+/* Unsigned 32 bit */
+typedef __u32 uint32;
+
+/*
+ *  Handling endiannes:
+ *  CAIF uses little-endian byte order.
+ */
+
+/* CAIF Endian handling Net to Host of 16 bits unsigned */
+#define cfglu_le16_to_cpu(v)  le16_to_cpu(v)
+
+/* CAIF Endian handling Host to Net of 16 bits unsigned */
+#define cfglu_cpu_to_le16(v)  cpu_to_le16(v)
+
+/* CAIF Endian handling Host to Net of 32 bits unsigned */
+#define cfglu_le32_to_cpu(v)  le32_to_cpu(v)
+
+/* CAIF Endian handling Net to Host of 32 bits unsigned */
+#define cfglu_cpu_to_le32(v)  cpu_to_le32(v)
+
+
+/* Critical Section support, one thread only between startsync
+ * and endsync
+ */
+#define cfglu_lock_t spinlock_t
+#define cfglu_init_lock(sync) spin_lock_init(&(sync))
+#define cfglu_lock(sync) spin_lock(&(sync))
+#define cfglu_unlock(sync) spin_unlock(&(sync))
+#define cfglu_deinit_lock(sync)
+
+/* Atomic counting */
+#define cfglu_atomic_t atomic_t
+#define cfglu_atomic_read(a) atomic_read(&a)
+#define cfglu_atomic_set(a, val) atomic_set(&a, val)
+#define cfglu_atomic_inc(a) atomic_inc(&a)
+#define cfglu_atomic_dec(a) atomic_dec(&a)
+
+/* HEAP */
+static inline void *cfglu_alloc(size_t size)
+{
+	if (in_interrupt())
+		return kmalloc(size, GFP_ATOMIC);
+	else
+		return kmalloc(size, GFP_KERNEL);
+}
+
+#define cfglu_free(ptr) kfree(ptr)
+#define cfglu_container_of(p, t, m) container_of(p, t, m)
+
+/* Checksum */
+static inline uint16 fcs16(uint16 fcs, uint8 *cp, uint16 len)
+{
+	return crc_ccitt(fcs, cp, len);
+}
+
+
+#ifndef caif_assert
+#define caif_assert(assert)\
+do if (!(assert)) { \
+	pr_err("caif:Assert detected:'%s'\n", #assert); \
+	WARN_ON(!(assert));\
+} while (0)
+#endif
+
+/*FIXME: Comment error codes*/
+enum cfglu_errno {
+	CFGLU_EOK = 0,
+	CFGLU_EPKT = -EPROTO,
+	CFGLU_EADDRINUSE = -EADDRINUSE,
+	CFGLU_EIO = -EIO,
+	CFGLU_EFCS = -EILSEQ,
+	CFGLU_EBADPARAM = -EINVAL,
+	CFGLU_EINVAL = -EINVAL,
+	CFGLU_ENODEV = -ENODEV,
+	CFGLU_ENOTCONN = -ENOTCONN,
+	CFGLU_EPROTO = -EPROTO,
+	CFGLU_EOVERFLOW = -EOVERFLOW,
+	CFGLU_ENOMEM = -ENOMEM,
+	CFGLU_ERETRY = -EAGAIN,
+	CFGLU_ENOSPC = -ENOSPC,
+	CFGLU_ENXIO = -ENXIO
+};
+
+#endif /* CFGLUE_H_ */
diff --git a/include/net/caif/generic/cflst.h b/include/net/caif/generic/cflst.h
new file mode 100644
index 0000000..6ff7168
--- /dev/null
+++ b/include/net/caif/generic/cflst.h
@@ -0,0 +1,19 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFLST_H_
+#define CFLST_H_
+
+#include <net/caif/generic/cfglue.h>
+
+int cflst_put(struct layer **lst, uint8 id, struct layer *node);
+struct layer *cflst_get(struct layer **lst, uint8 id);
+struct layer *cflst_del(struct layer **lst, uint8 id);
+#define CFLST_FIRST(lst) lst
+#define CFLST_MORE(node) ((node) != NULL)
+#define CFLST_NEXT(node) ((node)->next)
+void cflst_init(struct layer **lst);
+#endif	/* CFLST_H_ */
diff --git a/include/net/caif/generic/cfmuxl.h b/include/net/caif/generic/cfmuxl.h
new file mode 100644
index 0000000..2520693
--- /dev/null
+++ b/include/net/caif/generic/cfmuxl.h
@@ -0,0 +1,22 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFMUXL_H_
+#define CFMUXL_H_
+#include <net/caif/generic/caif_layer.h>
+
+struct cfsrvl;
+struct cffrml;
+
+struct layer *cfmuxl_create(void);
+int cfmuxl_set_uplayer(struct layer *layr, struct layer *up, uint8 linkid);
+struct layer *cfmuxl_remove_dnlayer(struct layer *layr, uint8 phyid);
+int cfmuxl_set_dnlayer(struct layer *layr, struct layer *up, uint8 phyid);
+struct layer *cfmuxl_remove_uplayer(struct layer *layr, uint8 linkid);
+bool cfmuxl_is_phy_inuse(struct layer *layr, uint8 phyid);
+uint8 cfmuxl_get_phyid(struct layer *layr, uint8 channel_id);
+
+#endif				/* CFMUXL_H_ */
diff --git a/include/net/caif/generic/cfpkt.h b/include/net/caif/generic/cfpkt.h
new file mode 100644
index 0000000..adaa84a
--- /dev/null
+++ b/include/net/caif/generic/cfpkt.h
@@ -0,0 +1,274 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFPKT_H_
+#define CFPKT_H_
+#include <net/caif/generic/caif_layer.h>
+
+struct cfpkt;
+
+/* Create a CAIF packet.
+ * len: Length of packet to be created
+ * @return New packet.
+ */
+struct cfpkt *cfpkt_create(uint16 len);
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
+int cfpkt_extr_head(struct cfpkt *pkt, void *data, uint16 len);
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
+int cfpkt_peek_head(struct cfpkt *pkt, void *data, uint16 len);
+
+/*
+ * Extract header from trailer (end of packet).
+ *
+ * pkt Packet to extract header data from.
+ * data Pointer to copy the trailer data into.
+ * len Length of header data to copy.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_extr_trail(struct cfpkt *pkt, void *data, uint16 len);
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
+int cfpkt_add_head(struct cfpkt *pkt, const void *data, uint16 len);
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
+int cfpkt_add_trail(struct cfpkt *pkt, const void *data, uint16 len);
+
+/*
+ * Pad trailer on packet.
+ * Moves data pointer in packet, no content copied.
+ *
+ * pkt Packet in which to pad trailer.
+ * len Length of padding to add.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_pad_trail(struct cfpkt *pkt, uint16 len);
+
+/*
+ * Add a single byte to packet body (tail).
+ *
+ * pkt Packet in which to add byte.
+ * data Byte to add.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_addbdy(struct cfpkt *pkt, const uint8 data);
+
+/*
+ * Add a data to packet body (tail).
+ *
+ * pkt Packet in which to add data.
+ * data Pointer to data to copy into the packet body.
+ * len Length of data to add.
+ * @return zero on success and error code upon failure
+ */
+int cfpkt_add_body(struct cfpkt *pkt, const void *data, uint16 len);
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
+uint16 cfpkt_getlen(struct cfpkt *pkt);
+
+/*
+ * Set the packet length, by adjusting the trailer pointer according to length.
+ * pkt Packet to set length.
+ * len Packet length.
+ * @return Number of bytes in packet.
+ */
+int cfpkt_setlen(struct cfpkt *pkt, uint16 len);
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
+		      uint16 expectlen);
+
+/*
+ * cfpkt_split - Split a packet into two packets at the specified split point.
+ * pkt: Packet to be split (will contain the first part of the data on exit)
+ * pos: Position to split packet in two parts.
+ * @return The new packet, containing the second part of the data.
+ */
+struct cfpkt *cfpkt_split(struct cfpkt *pkt, uint16 pos);
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
+uint16 cfpkt_iterate(struct cfpkt *pkt,
+		uint16 (*iter_func)(uint16 chks, void *buf, uint16 len),
+		uint16 data);
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
+struct payload_info *cfpkt_info(struct cfpkt *pkt);
+/*! @} */
+#endif				/* CFPKT_H_ */
diff --git a/include/net/caif/generic/cfserl.h b/include/net/caif/generic/cfserl.h
new file mode 100644
index 0000000..715c82d
--- /dev/null
+++ b/include/net/caif/generic/cfserl.h
@@ -0,0 +1,14 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSERL_H_
+#define CFSERL_H_
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+
+struct layer *cfserl_create(int type, int instance, bool use_stx);
+
+#endif				/* CFSERL_H_ */
diff --git a/include/net/caif/generic/cfsrvl.h b/include/net/caif/generic/cfsrvl.h
new file mode 100644
index 0000000..f5a83f8
--- /dev/null
+++ b/include/net/caif/generic/cfsrvl.h
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSRVL_H_
+#define CFSRVL_H_
+#include <net/caif/generic/cfglue.h>
+#include <stddef.h>
+
+struct cfsrvl {
+	struct layer layer;
+	bool open;
+	bool phy_flow_on;
+	bool modem_flow_on;
+	struct dev_info dev_info;
+};
+
+struct layer *cfvei_create(uint8 linkid, struct dev_info *dev_info);
+struct layer *cfdgml_create(uint8 linkid, struct dev_info *dev_info);
+struct layer *cfutill_create(uint8 linkid, struct dev_info *dev_info);
+struct layer *cfvidl_create(uint8 linkid, struct dev_info *dev_info);
+struct layer *cfrfml_create(uint8 linkid, struct dev_info *dev_info);
+bool cfsrvl_phyid_match(struct layer *layer, int phyid);
+void cfservl_destroy(struct layer *layer);
+void cfsrvl_init(struct cfsrvl *service,
+		 uint8 channel_id,
+		 struct dev_info *dev_info);
+bool cfsrvl_ready(struct cfsrvl *service, int *err);
+uint8 cfsrvl_getphyid(struct layer *layer);
+
+#endif				/* CFSRVL_H_ */
-- 
1.6.3.3

