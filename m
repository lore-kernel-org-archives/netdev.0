From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3  2/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:46 +0100
Message-ID: <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
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
	with ESMTP id S1752641AbZK3QB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:26 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX001O1GE7KF10@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:19 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:19 +0100 (CET)
In-reply-to: <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/generic/caif_layer.h |  341 +++++++++++++++++++++++++++++++++
 include/net/caif/generic/cfcnfg.h     |  211 ++++++++++++++++++++
 include/net/caif/generic/cfctrl.h     |  137 +++++++++++++
 include/net/caif/generic/cffrml.h     |   20 ++
 include/net/caif/generic/cfglue.h     |  174 +++++++++++++++++
 include/net/caif/generic/cfloopcfg.h  |   16 ++
 include/net/caif/generic/cflst.h      |   19 ++
 include/net/caif/generic/cfmsll.h     |   13 ++
 include/net/caif/generic/cfmuxl.h     |   22 ++
 include/net/caif/generic/cfpkt.h      |  264 +++++++++++++++++++++++++
 include/net/caif/generic/cfserl.h     |   20 ++
 include/net/caif/generic/cfshml.h     |   12 ++
 include/net/caif/generic/cfspil.h     |   85 ++++++++
 include/net/caif/generic/cfsrvl.h     |   33 ++++
 include/net/caif/generic/cfusbl.h     |   13 ++
 include/net/caif/generic/fcs.h        |   13 ++
 16 files changed, 1393 insertions(+), 0 deletions(-)
 create mode 100644 include/net/caif/generic/caif_layer.h
 create mode 100644 include/net/caif/generic/cfcnfg.h
 create mode 100644 include/net/caif/generic/cfctrl.h
 create mode 100644 include/net/caif/generic/cffrml.h
 create mode 100644 include/net/caif/generic/cfglue.h
 create mode 100644 include/net/caif/generic/cfloopcfg.h
 create mode 100644 include/net/caif/generic/cflst.h
 create mode 100644 include/net/caif/generic/cfmsll.h
 create mode 100644 include/net/caif/generic/cfmuxl.h
 create mode 100644 include/net/caif/generic/cfpkt.h
 create mode 100644 include/net/caif/generic/cfserl.h
 create mode 100644 include/net/caif/generic/cfshml.h
 create mode 100644 include/net/caif/generic/cfspil.h
 create mode 100644 include/net/caif/generic/cfsrvl.h
 create mode 100644 include/net/caif/generic/cfusbl.h
 create mode 100644 include/net/caif/generic/fcs.h

diff --git a/include/net/caif/generic/caif_layer.h b/include/net/caif/generic/caif_layer.h
new file mode 100644
index 0000000..0ae98b5
--- /dev/null
+++ b/include/net/caif/generic/caif_layer.h
@@ -0,0 +1,341 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Braendeland/sjur.brandeland@stericsson.com
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
+struct transmt_info;
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
+/*! \addtogroup GenCaifExternal
+ *  Additional documentation for group `GenCaifExternal'
+ *  @{
+ */
+
+/** CAIF Control Signaling.
+ *  These commands are sent upwards in the CAIF stack. They are used for
+ *  signaling originating from the modem.
+ *  These are either responses (*_RSP) or events (*_IND).
+ */
+enum caif_ctrlcmd {
+	/** Flow Control is OFF, transmit function should stop sending data */
+	CAIF_CTRLCMD_FLOW_OFF_IND = 0,
+	/** Flow Control is ON, transmit function can start sending data */
+	CAIF_CTRLCMD_FLOW_ON_IND = 1,
+	/** Remote end modem has decided to close down channel */
+	CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND = 5,
+	/** Called initially when the layer below has finished initialization */
+	CAIF_CTRLCMD_INIT_RSP = 3,
+	/** Called when de-initialization is complete */
+	CAIF_CTRLCMD_DEINIT_RSP = 4,
+	/** Called if initialization fails */
+	CAIF_CTRLCMD_INIT_FAIL_RSP = 6,
+	/** Note: Only used internally in GenCaif.
+	 * Called if physical interface cannot send more packets.
+	 */
+	_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND = 7,
+	/** Note: Only used internally in GenCaif.
+	 * Called if physical interface is able to send packets again.
+	 */
+	_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND = 8,
+	_CAIF_CTRLCMD_PHYIF_DOWN_IND = 9,
+};
+
+/** Modem Control Signaling.
+ *  These are requests sent 'downwards' in the stack.
+ *  Flow ON, OFF can be indicated to the modem.
+ */
+enum caif_modemcmd {
+	/** Flow Control is ON, transmit function can start sending data */
+	CAIF_MODEMCMD_FLOW_ON_REQ = 0,
+	/** Flow Control is OFF, transmit function should stop sending data */
+	CAIF_MODEMCMD_FLOW_OFF_REQ = 1,
+	/** Notify physical layer that it is in use */
+	_CAIF_MODEMCMD_PHYIF_USEFULL = 3,
+	/** Notify physical layer that it is no longer in use */
+	_CAIF_MODEMCMD_PHYIF_USELESS = 4
+};
+
+/** CAIF Packet Direction.
+ *  Indicate if a packet is to be sent \b out or to be received \b in.
+ */
+enum caif_direction {
+	CAIF_DIR_IN = 0,	/*!< Incoming packet received. */
+	CAIF_DIR_OUT = 1	/*!< Outgoing packet to be transmitted. */
+};
+
+/** This structure defines the generic layered structure in CAIF.
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
+ *	 \code layer->up->receive(layer->up, packet); \endcode
+ *    -# In order to send data downwards do
+ *	 \code layer->dn->transmit(layer->dn, info, packet); \endcode
+ *
+ *
+ *
+ */
+struct layer {
+
+	struct layer *up;	/*!< Pointer to the layer above */
+	struct layer *dn;	/*!< Pointer to the layer below */
+	/*!
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
+	/*!
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
+	 *  @param[in] info  Info about physical layer (filled in by MUX layer)
+	 *		     and CAIF header size (each layer adds to hdr_len).
+	 *  @return	     result < 0 indicates an error, 0 or positive value
+	 *		     indicate success.
+	 */
+	int (*transmit) (struct layer *layr, struct transmt_info *info,
+		      struct cfpkt *cfpkt);
+
+	/*!
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
+	/*!
+	 *  Control Function used for controlling the modem. Used to signal
+	 *  down-wards in the CAIF stack.
+	 *  @returns 0 on success, < 0 upon failure.
+	 *  @param[in] layr  Pointer to the current layer the receive function
+	 *		     is implemented for (this pointer).
+	 *  @param[in] ctrl  Control Command.
+	 */
+	int (*modemcmd) (struct layer *layr, enum caif_modemcmd ctrl);
+
+	struct layer *next;	/*!< Pointer to chain of layers, up/dn will
+				 *   then point at the first element of a
+				 *   which then should be iterated through
+				 *   the next pointer.
+				 */
+	unsigned short prio;	/*!< Priority of this layer */
+	unsigned int id;	/*!< The identity of this layer. */
+	unsigned int type;	/*<! The type of this layer */
+	char name[CAIF_LAYER_NAME_SZ];		/*!< Name of the layer */
+};
+/** Set the up pointer for a specified layer.
+ *  @param layr Layer where up pointer shall be set.
+ *  @param above Layer above.
+ */
+#define layer_set_up(layr, above) ((layr)->up = (struct layer *)(above))
+
+/** Set the dn pointer for a specified layer.
+ *  @param layr Layer where down pointer shall be set.
+ *  @param below Layer below.
+ */
+#define layer_set_dn(layr, below) ((layr)->dn = (struct layer *)(below))
+
+/**
+ *  Transmit info, passed downwards in protocol layers.
+ */
+struct transmt_info {
+	/** Channel ID of the logical CAIF connection.
+	 *  Used by the service layer to indicate to mux the PHY-layer
+	 *  (Physical-ID) to send packet over.
+	 */
+	unsigned short channel_id;
+
+	/** Physical ID of the	physical connection used by the logical CAIF
+	 *  connection. Used by service layers to identify their physical id
+	 *   to Caif MUX (CFMUXL)so that the MUX can add the correct physical
+	 * ID to the packet.
+	 */
+	unsigned short phid;
+
+	/** Header length, used to align pay load on 32bit boundary.
+	 *  Used by SPI Layer (CFSPIL) to align start of pay-load data (IP header
+	 *  start) to 16 or 32 bits boundary.
+	 *  All layers add the number of header bytes they are using, then SPI
+	 *  layer adds padding to get correct alignment.
+	 */
+	unsigned short hdr_len;
+
+	/** Packet priority. */
+	unsigned char prio;
+};
+
+/** Packet functions needed by the adaptation layer and PHY layer are exported
+ *  in this structure.
+ *
+ */
+struct caif_packet_funcs {
+
+	/** Used to map from a "native" packet (e.g. Linux Socket Buffer)
+	 *  to a CAIF packet.
+	 *  @param dir - Direction, indicating whether this packet is to be
+	 *  		sent or received.
+	 *  @param nativepkt - The native packet to be transformed to a CAIF
+	 *  		packet.
+	 *  @returns the mapped CAIF packet CFPKT.
+	 */
+	struct cfpkt *
+	    (*cfpkt_fromnative)(enum caif_direction dir, void *nativepkt);
+
+	/** Used to map from a CAIF packet to a "native" packet
+	 *  (e.g. Linux Socket Buffer).
+	 *  @param pkt	- The CAIF packet to be transformed to a "native"
+	 * 		  packet.
+	 *  @returns the native packet transformed from a CAIF packet.
+	 */
+	void *(*cfpkt_tonative)(struct cfpkt *pkt);
+
+	/** Used by "app" layer to create an outgoing CAIF packet to be sent
+	 *  out of the CAIF Stack.
+	 *  @param data - Packet data to copy into the packet.
+	 *		  If NULL then copying will not take place.
+	 *  @param len	- Length of data to copy into the packet.
+	 *  @returns a new CAIF packet CFPKT.
+	 *  @deprecated Use \b cfpkt_create_pkt (above) instead.
+	 */
+	struct cfpkt *
+	    (*cfpkt_create_recv_pkt)(const unsigned char *data,
+				      unsigned int len);
+
+	/** Used by PHY layer to create an incoming CAIF packet to be
+	 *  processed by the CAIF Stack.
+	 *  @param data - Packet data to copy into the packet. If NULL then
+	 *  copying will not take place.
+	 *  @param len	- Length of data to copy into the packet.
+	 *  @returns a new CAIF packet CFPKT.
+	 *  @deprecated Use \b cfpkt_create_pkt (above) instead.
+	 */
+	struct cfpkt *
+	    (*cfpkt_create_xmit_pkt)(const unsigned char *data,
+				      unsigned int len);
+
+	/** Used to extract data from a CAIF packet.
+	 *  @param cfpkt	 Packet to extract data from.
+	 *  @param buf	 Buffer to hold the data to be extracted from the
+	 *			 CAIF packet.
+	 *  @param buflen	 Length of the buffer (maximum length of the
+	 *			 data to copy into the buffer).
+	 *  @param actual_len	 Number of bytes copied from the packet into
+	 *                       the buffer.
+	 */
+	void
+	 (*cfpkt_extract)(struct cfpkt *cfpkt, void *buf, unsigned int buflen,
+			   unsigned int *actual_len);
+
+	/** Releases a CAIF packet.
+	 *  @param cfpkt	 Packet to destroy.
+	 */
+	void
+	 (*cfpkt_destroy)(struct cfpkt *cfpkt);
+
+	/** Append by giving user access to the packet buffer.
+	 * @param pkt Packet to append to.
+	 * @param buf Buffer inside pkt that user shall copy data into.
+	 * @param buflen Length of buffer and number of bytes added to packet.
+	 * @return < 0 on error.
+	 */
+	 int (*cfpkt_raw_append)(struct cfpkt *cfpkt, void **buf,
+				unsigned int buflen);
+
+	/** Extract by giving user access to the packet buffer.
+	 * @param pkt Packet to extract from.
+	 * @param buf Buffer inside pkt that user shall copy data from.
+	 * @param buflen Length of buffer and number of bytes removed from
+	 *        packet.
+	 * @return < 0 on error
+	 */
+	 int (*cfpkt_raw_extract)(struct cfpkt *cfpkt, void **buf,
+				 unsigned int buflen);
+
+	/** Creates a packet queue. */
+	struct cfpktq *(*cfpktq_create)(void);
+
+	/** Inserts a packet into the packet queue, packets are ordered by
+	 *  priority.
+	 *  If the same priority is used packets are ordered as a FIFO.
+	 */
+	void (*cfpkt_queue)(struct cfpktq *pktq, struct cfpkt *pkt,
+			     unsigned short prio);
+
+	/** Peek into the first packet in the queue. */
+	struct cfpkt *(*cfpkt_qpeek)(struct cfpktq *pktq);
+
+	/** Dequeue a packet from the queue. */
+	struct cfpkt *(*cfpkt_dequeue)(struct cfpktq *pktq);
+
+	/** Get length of a packet */
+	uint16(*cfpkt_getlen)(struct cfpkt *pkt);
+};
+
+/*! @} */
+
+#endif				/* CAIF_LAYER_H_ */
diff --git a/include/net/caif/generic/cfcnfg.h b/include/net/caif/generic/cfcnfg.h
new file mode 100644
index 0000000..7e4fc44
--- /dev/null
+++ b/include/net/caif/generic/cfcnfg.h
@@ -0,0 +1,211 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
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
+/*! \addtogroup GenCaifExternal
+ *  Additional documentation for group `GenCaifExternal'
+ *  @{
+ */
+
+/** Types of physical layers defined in CAIF Stack */
+enum cfcnfg_phy_type {
+	CFPHYTYPE_UNKNOWN = 0,
+	CFPHYTYPE_SERIAL = 1,	/*!< Serial physical interface */
+	CFPHYTYPE_SPI = 2,	/*!< SPI physical interface */
+	CFPHYTYPE_MSL = 3,	/*!< MSL physical interface */
+	CFPHYTYPE_SHM = 4,	/*!< Shared memory physical interface */
+	CFPHYTYPE_LOOP = 5,	/*!< Loopback physical interface */
+	CFPHYTYPE_USB = 6,	/*!< USB physical interface */
+	CFPHYTYPE_MAX = 7
+};
+
+/** Physical preference - HW Abstraction */
+enum cfcnfg_phy_preference {
+	/** Default physical interface */
+	CFPHYPREF_UNSPECIFIED = 0xa0,
+	/** Default physical interface for low-latency traffic */
+	CFPHYPREF_LOW_LAT = 0xd0,
+	/** Default physical interface for high-bandwidth traffic */
+	CFPHYPREF_HIGH_BW = 0xe0,
+	/** \b TEST \b ONLY Loopback interface simulating modem responses */
+	CFPHYPREF_LOOP = 0x70,
+	/** \b TEST \b ONLY Raw loopback interface */
+	CFPHYPREF_RAW_LOOP = 0x80
+};
+
+/** Types of CAIF Links defined in CAIF Stack
+ * @obsolete
+ */
+enum cfcnfg_link_type {
+	_CF_DECM = 0,		/*!< DECM link - NOT SUPPORTED */
+	CF_VEI = CFCTRL_SRV_VEI,	/*!< VEI link - AT */
+	CF_VIDEO = CFCTRL_SRV_VIDEO,	/*!< Video link */
+	CF_DEBUG = CFCTRL_SRV_DBG,	/*!< Debug link */
+	CF_DATAGRAM = CFCTRL_SRV_DATAGRAM,	/*!< Datagram link */
+	CF_RFM = CFCTRL_SRV_RFM,	/*!< RFM link */
+	CF_UTILITY = CFCTRL_SRV_UTIL	/*!< Utility link */
+};
+
+/** Configuration parameters for a physical layer (e.g. serial) */
+struct cfcnfg_phy_param {
+	int foo;
+};
+
+/** Configuration information used to setup the CAIF physical interface */
+struct cfcnfg_phy_config {
+	/** CAIF physical type */
+	enum cfcnfg_phy_type phy_type;
+	/** Instance number, e.g. UART number */
+	uint8 phy_sub_instance;
+	/** Preference low-latency/high-bandwidth */
+	enum cfcnfg_phy_preference pref;
+	/** Device name */
+	char name[20];
+	/** Checksum is used for interface */
+	bool checksum;
+	/** Configuration parameter specific to the PHY Type */
+	struct cfcnfg_phy_param param;
+	/** Pointer to layer above */
+	struct layer *up;
+};
+
+/** Registration information used to set up the CAIF physical interface */
+struct cfcnfg_phy_mgmt {
+	/** Registration of type */
+	enum cfcnfg_phy_type type;
+	/** Creates an instance of the physical layer (e.g. serial)
+	 * and configures it
+	 */
+	struct layer *(*create_phy) (struct cfcnfg_phy_config *config);
+	 /** Delete an instance of the physical layer (e.g. serial) */
+	int (*delete_phy) (struct layer *l);
+};
+
+/**
+ * This variable is used as a global flag, in order to set whether STX is used in
+ * serial communication.
+ * NOTE: This is not a fully future-proof solution.
+ */
+extern int serial_use_stx;
+
+/**
+ * These variable is used as a global flag, in order to configure padding on SPI communication.
+ * NOTE: This is not a fully future-proof solution.
+ */
+extern int spi_up_head_align;
+extern int spi_up_tail_align;
+extern int spi_down_head_align;
+extern int spi_down_tail_align;
+
+/**
+ * Create the CAIF configuration object.
+ * @return The created instance of a CFCNFG object.
+ */
+struct cfcnfg *cfcnfg_create(void);
+
+/**
+ * Adds a physical layer to the CAIF stack.
+ * @param cnfg Pointer to a CAIF configuration object, created by
+ *				cfcnfg_create().
+ * @param phy_type Specifies the type of physical interface, e.g.
+ *		    CFPHYTYPE_SERIAL.
+ * @param phy_layer Specify the physical layer. The transmit function
+ *		    MUST be set in the structure.
+ * @param phyid [out] The assigned physical ID for this layer,
+ *		      used in \ref cfcnfg_add_adapt_layer to specify
+ *		      PHY for the link.
+ */
+
+void
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
+		     struct layer *phy_layer, uint16 *phyid,
+		     enum cfcnfg_phy_preference pref);
+
+/**
+ * Deletes an adaptation layer from the CAIF stack.
+ *
+ * @param cnfg Pointer to a CAIF configuration object, created by
+ *			   cfcnfg_create().
+ * @param adap_layer Adaptation layer to be removed.
+ * @return 0 on success.
+ */
+int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct layer *adap_layer);
+
+/**
+ * Adds an adaptation layer to the CAIF stack.
+ * The adaptation Layer is where the interface to application or higher-level
+ * driver functionality is implemented.
+ *
+ * @param cnfg	     Pointer to a CAIF configuration object, created by
+ *		     cfcnfg_create().
+ * @param linktype   Type of link that is set up, e.g. CF_AT_PLAIN.
+ * @param connid     Connection ID, used for datagram links.
+ * @param phyid	     PHY ID received from \ref	cfcnfg_add_phy_layer,
+ *		     specifying the PHY device to use for this link.
+ * @param adap_layer Specify the adaptation layer; the receive
+ *		     and flow-control functions MUST be set in the structure.
+ * @return	     true on success, false upon failure.
+ */
+bool
+cfcnfg_add_adapt_layer(struct cfcnfg *cnfg, enum cfcnfg_link_type linktype,
+		       uint32 connid, uint16 phyid, struct layer *adap_layer);
+
+/**
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
+
+/**
+ * Returns a handle to the packet functions used to create packets with
+ * content and to extract information from packets.
+ */
+struct caif_packet_funcs cfcnfg_get_packet_funcs(void);
+
+/** Get physical ID, given type.
+ * @return Returns one of the physical interfaces matching the given type.
+ *	   Zero if no match is found.
+ */
+int cfcnfg_get_phyid(struct cfcnfg *cnfg,
+		     enum cfcnfg_phy_preference phy_pref);
+
+/** Get physical ID, given name.
+ * @return Returns the physical interface matching the specified name.
+ */
+int cfcnfg_get_named(struct cfcnfg *cnfg, char *name);
+
+int cfcnfg_instanciate(struct cfcnfg *cnfg,
+		       struct cfcnfg_phy_config *phy_config);
+int cfcnfg_instanciate2(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
+			uint8 instance, char *name, bool checksum,
+			enum cfcnfg_phy_preference pref,
+			struct cfcnfg_phy_param *param);
+int cfcnfg_delete_phy_inst(struct cfcnfg *cfg, char *name);
+int cfcnfg_unregister_phy_type(struct cfcnfg *cfg,
+			       enum cfcnfg_phy_type type);
+int cfcnfg_register_phy_type(struct cfcnfg *cfg,
+			     struct cfcnfg_phy_mgmt *mgmt);
+int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct layer *phy_layer);
+
+/*! @} */
+#endif				/* CFCNFG_H_ */
diff --git a/include/net/caif/generic/cfctrl.h b/include/net/caif/generic/cfctrl.h
new file mode 100644
index 0000000..8d0fcc3
--- /dev/null
+++ b/include/net/caif/generic/cfctrl.h
@@ -0,0 +1,137 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFCTRL_H_
+#define CFCTRL_H_
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfsrvl.h>
+
+/* CAIF Control packet commands*/
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
+	CFCTRL_CMD_DATA = 0,
+	CFCTRL_CMD_MASK = 0xf
+};
+
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
+/** Link Setup Parameters for CAIF-Links. */
+struct cfctrl_link_param {
+	enum cfctrl_srv linktype;/*!< (T3,T0) Type of Channel */
+	uint8 priority;		  /*!< (P4,P0) Priority of the channel */
+	uint8 phyid;		  /*!< (U2-U0) Physical interface to connect */
+	uint8 endpoint;		  /*!< (E1,E0) Endpoint for data channels */
+	uint8 chtype;		  /*!< (H1,H0) Channel-Type, applies to
+				   *            VEI, DEBUG */
+	union {
+		struct {
+			uint8 connid;	/*!<  (D7,D0) Video LinkId */
+		} video;
+
+		struct {
+			uint32 connid;	/*!< (N31,Ngit0) Connection ID used
+					 *    for Datagram */
+		} datagram;
+
+		struct {
+			uint32 connid;	/*!< Connection ID used for RFM */
+			char volume[20];	/*!< Volume to mount for RFM */
+		} rfm;		/*!< Configuration for RFM */
+
+		struct {
+			uint16 fifosize_kb;	/*!< Psock FIFO size in KB */
+			uint16 fifosize_bufs;	/*!< Psock # signal buffers */
+			char name[16];	/*!< Name of the PSOCK service */
+			uint8 params[255];	/*!< Link setup Parameters> */
+			uint16 paramlen;	/*!< Length of Link Setup
+						 *   Parameters */
+		} utility;	/*!< Configuration for Utility Links (Psock) */
+	} u;
+};
+
+/** This structure is used internally in CFCTRL */
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
+void cfctrl_set_respfuncs(struct layer *this,
+			  struct cfctrl_rsp *respfuncs);
+bool cfctrl_req_eq(struct cfctrl_request_info *r1,
+		   struct cfctrl_request_info *r2);
+void cfctrl_insert_req(struct cfctrl *ctrl,
+			      struct cfctrl_request_info *req);
+struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
+					      struct cfctrl_request_info *req);
+#endif				/* CFCTRL_H_ */
diff --git a/include/net/caif/generic/cffrml.h b/include/net/caif/generic/cffrml.h
new file mode 100644
index 0000000..b946111
--- /dev/null
+++ b/include/net/caif/generic/cffrml.h
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFFRM_H_
+#define CFFRM_H_
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cflst.h>
+
+struct cffrml;
+
+struct layer *cffrml_create(uint16 phyid, bool DoFCS);
+void cffrml_set_uplayer(struct layer *this, struct layer *up);
+void cffrml_set_dnlayer(struct layer *this, struct layer *dn);
+void cffrml_destroy(struct layer *layer);
+
+#endif				/* CFFRM_H_ */
diff --git a/include/net/caif/generic/cfglue.h b/include/net/caif/generic/cfglue.h
new file mode 100644
index 0000000..c84d39c
--- /dev/null
+++ b/include/net/caif/generic/cfglue.h
@@ -0,0 +1,174 @@
+/*
+ * This file contains the OS and HW dependencies for CAIF.
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFGLU_H_
+#define CFGLU_H_
+
+/*! \addtogroup GenCaifGlue
+ *  Additional documentation for group `GenCaifGlue'
+ *  @{
+ */
+
+#define CFLOG_LEVEL_ERROR   1
+#define CFLOG_LEVEL_WARNING 2
+#define CFLOG_LEVEL_TRACE   3
+#define CFLOG_LEVEL_TRACE2  4
+#define CFLOG_LEVEL_TRACE3  5
+#define CFLOG_LEVEL_FUNC    6
+
+#include <linux/module.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
+#include "linux/stddef.h"
+#include "linux/types.h"
+
+/** Unsigned 8 bit */
+typedef __u8 uint8;
+
+/** Unsigned 16 bit */
+typedef __u16 uint16;
+
+/** Unsigned 32 bit */
+typedef __u32 uint32;
+
+/******************************************
+ *  HANDLING ENDIANNES.
+ *  CAIF uses little-endian byte order.
+ ******************************************/
+
+/** CAIF Endian handling Net to Host of 16 bits unsigned */
+#define cfglu_le16_to_cpu(v)  le16_to_cpu(v)
+
+/** CAIF Endian handling Host to Net of 16 bits unsigned */
+#define cfglu_cpu_to_le16(v)  cpu_to_le16(v)
+
+/** CAIF Endian handling Host to Net of 32 bits unsigned */
+#define cfglu_le32_to_cpu(v)  le32_to_cpu(v)
+
+/** CAIF Endian handling Net to Host of 32 bits unsigned */
+#define cfglu_cpu_to_le32(v)  cpu_to_le32(v)
+
+extern int caif_dbg_level;
+
+/* LOGGING */
+#define _CFLOG_FATAL(format, args...) \
+	do {if (caif_dbg_level > CFLOG_LEVEL_ERROR) {\
+		printk(KERN_ERR "<%s:%d, FATAL> " format "\n",\
+				__func__, __LINE__ ,  ## args); } } while (0)
+
+#define CFLOG_FATAL(format) _CFLOG_FATAL format
+
+/** CAIF Error Logging. */
+#define _CFLOG_ERROR(format, args...)\
+	do {if (caif_dbg_level > CFLOG_LEVEL_ERROR) {\
+		printk(KERN_ERR "<%s:%d, ERROR> " format "\n",\
+				__func__, __LINE__ ,  ## args); } }  while (0)
+
+#define CFLOG_ERROR(format)  _CFLOG_ERROR format
+
+/** CAIF Warning Logging. */
+#define _CFLOG_WARN(format, args...)\
+	do {if (caif_dbg_level > CFLOG_LEVEL_WARNING) {\
+		printk(KERN_WARNING "<%s:%d, WARN> "  format "\n",\
+				__func__, __LINE__ ,  ## args); } }  while (0)
+
+#ifdef CAIF_DEBUG_ON
+#define CFLOG_WARN(format)   _CFLOG_WARN format
+
+/** CAIF Trace Control Logging. Level 1 control trace (Channel setup etc) */
+#define _CFLOG_TRACE(format, args...)  \
+	do { if (caif_dbg_level > CFLOG_LEVEL_TRACE) {\
+		printk(KERN_INFO "<%s:%d, TRACE> " format, \
+				__func__, __LINE__ ,  ## args); } }  while (0)
+
+#define CFLOG_TRACE(format)  _CFLOG_TRACE format
+
+/** CAIF Trace Payload Logging. Level payload trace */
+#define _CFLOG_TRACE2(format, args...) \
+	do {if (caif_dbg_level > CFLOG_LEVEL_TRACE2) {\
+		printk(KERN_INFO "<%s:%d, TRACE2> " format, \
+				__func__, __LINE__ ,  ## args); } }  while (0)
+
+#define CFLOG_TRACE2(format) _CFLOG_TRACE2 format
+
+/** CAIF Trace Detailed Logging including packet dumps */
+#define _CFLOG_TRACE3(format, args...)\
+	do {if (caif_dbg_level > CFLOG_LEVEL_TRACE3) {\
+		printk(KERN_INFO "<%s:%d, TRACE3> " format, \
+				__func__, __LINE__ ,  ## args); } }  while (0)
+
+#define CFLOG_TRACE3(format) _CFLOG_TRACE3 format
+
+/** CAIF Trace Entering Function */
+#define _CFLOG_ENTER(format, args...) \
+	do {if (caif_dbg_level > CFLOG_LEVEL_FUNC) {\
+		printk("KERN_INFO <%s:%d, ENTER> " format, \
+				__func__, __LINE__ ,  ## args); } }  while (0)
+#define CFLOG_ENTER(format)  _CFLOG_ENTER format
+
+/** CAIF Trace Exiting Function */
+
+#define _CFLOG_EXIT(format, args...)  \
+	do {if (caif_dbg_level > CFLOG_LEVEL_FUNC) {\
+		printk("KERN_INFO <%s:%d, EXIT> "  format "\n",\
+				__func__, __LINE__ ,  ## args); } }  while (0)
+#define CFLOG_EXIT(format)   _CFLOG_EXIT format
+
+#else
+
+#define CFLOG_WARN(args)
+#define CFLOG_TRACE(args)
+#define CFLOG_TRACE2(args)
+#define CFLOG_TRACE3(args)
+#define CFLOG_ENTER(args)
+#define CFLOG_EXIT(args)
+
+#endif
+
+/* Critical Section support, one thread only between startsync
+ * and endsync
+ */
+#define cfglu_lock_t spinlock_t
+#define cfglu_init_lock(sync) spin_lock_init(&(sync))
+#define cfglu_lock(sync) spin_lock_bh(&(sync))
+#define cfglu_unlock(sync) spin_unlock_bh(&(sync))
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
+#define cfglu_alloc(size) kmalloc(size, GFP_ATOMIC)
+#define cfglu_free(ptr) kfree(ptr)
+#define cfglu_container_of(p, t, m) container_of(p, t, m)
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
+#endif				/* CFGLU_H_ */
diff --git a/include/net/caif/generic/cfloopcfg.h b/include/net/caif/generic/cfloopcfg.h
new file mode 100644
index 0000000..3cffd73
--- /dev/null
+++ b/include/net/caif/generic/cfloopcfg.h
@@ -0,0 +1,16 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFLOOPCFG_H_
+#define CFLOOPCFG_H_
+#include <net/caif/generic/caif_layer.h>
+
+struct cfloopcfg *cfloopcfg_create(void);
+void cfloopcfg_add_phy_layer(struct cfloopcfg *cnfg,
+			     enum cfcnfg_phy_type phy_type,
+			     struct layer *phy_layer);
+struct layer *cflooplayer_create(void);
+#endif				/* CFLOOPCFG_H_ */
diff --git a/include/net/caif/generic/cflst.h b/include/net/caif/generic/cflst.h
new file mode 100644
index 0000000..29e4d33
--- /dev/null
+++ b/include/net/caif/generic/cflst.h
@@ -0,0 +1,19 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFLST_H_
+#define CFLST_H_
+
+#include <net/caif/generic/cfglue.h>
+
+bool cflst_put(struct layer **lst, uint8 id, struct layer *node);
+struct layer *cflst_get(struct layer **lst, uint8 id);
+struct layer *cflst_del(struct layer **lst, uint8 id);
+#define CFLST_FIRST(lst) lst
+#define CFLST_MORE(node) ((node) != NULL)
+#define CFLST_NEXT(node) ((node)->next)
+void cflst_init(struct layer **lst);
+#endif				/* CFLST_H_ */
diff --git a/include/net/caif/generic/cfmsll.h b/include/net/caif/generic/cfmsll.h
new file mode 100644
index 0000000..4339af8
--- /dev/null
+++ b/include/net/caif/generic/cfmsll.h
@@ -0,0 +1,13 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFMSLL_H_
+#define CFMSLL_H_
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+struct layer *cfmsll_create(int type, int instance);
+
+#endif				/* CFMSLL_H_ */
diff --git a/include/net/caif/generic/cfmuxl.h b/include/net/caif/generic/cfmuxl.h
new file mode 100644
index 0000000..0790574
--- /dev/null
+++ b/include/net/caif/generic/cfmuxl.h
@@ -0,0 +1,22 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
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
+bool cfmuxl_set_uplayer(struct layer *layr, struct layer *up, uint8 linkid);
+struct layer *cfmuxl_remove_dnlayer(struct layer *layr, uint8 phyid);
+bool cfmuxl_set_dnlayer(struct layer *layr, struct layer *up, uint8 phyid);
+struct layer *cfmuxl_remove_uplayer(struct layer *layr, uint8 linkid);
+bool cfmuxl_is_phy_inuse(struct layer *layr, uint8 phyid);
+uint8 cfmuxl_get_phyid(struct layer *layr, uint8 channel_id);
+
+#endif				/* CFMUXL_H_ */
diff --git a/include/net/caif/generic/cfpkt.h b/include/net/caif/generic/cfpkt.h
new file mode 100644
index 0000000..874f09b
--- /dev/null
+++ b/include/net/caif/generic/cfpkt.h
@@ -0,0 +1,264 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFPKT_H_
+#define CFPKT_H_
+#include <net/caif/generic/caif_layer.h>
+
+struct cfpkt;
+/*! \addtogroup GenCaifGlue
+ *  Additional documentation for group `GenCaifGlue'
+ *  @{
+ */
+
+/** Checksum iteration function used to iterate buffers
+ * (we may have packets consisting of a chain of buffers)
+ * @param chs Checksum calculated so far.
+ * @param buf Pointer to the buffer to checksum
+ * @param len Length of buf.
+ * @return Checksum of buffer
+ */
+typedef uint16(*iterfunc_t)(uint16 chks, void *buf, uint16 len);
+
+struct caif_packet_funcs caif_get_packet_funcs(void);
+
+/** Create a CAIF packet.
+ * @param len Length of packet to be created
+ * @return New packet.
+ */
+struct cfpkt *cfpkt_create(uint16 len);
+
+/**
+ * Destroy a CAIF Packet.
+ * @param pkt Packet to be destoyed.
+ */
+void cfpkt_destroy(struct cfpkt *pkt);
+
+/**
+ * Extract header from packet.
+ *
+ * @param pkt Packet to extract header data from.
+ * @param data Pointer to copy the header data into.
+ * @param len Length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_extr_head(struct cfpkt *pkt, void *data, uint16 len);
+
+/**
+ * Peek header from packet.
+ * Reads data from packet without changing packet.
+ *
+ * @param pkt Packet to extract header data from.
+ * @param data Pointer to copy the header data into.
+ * @param len Length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_peek_head(struct cfpkt *pkt, void *data, uint16 len);
+
+/**
+ * Extract header from trailer (end of packet).
+ *
+ * @param pkt Packet to extract header data from.
+ * @param data Pointer to copy the trailer data into.
+ * @param len Length of header data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_extr_trail(struct cfpkt *pkt, void *data, uint16 len);
+
+/**
+ * Add header to packet.
+ *
+ *
+ * @param pkt Packet to add header data to.
+ * @param data Pointer to data to copy into the header.
+ * @param len Length of header data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_add_head(struct cfpkt *pkt, const void *data, uint16 len);
+
+/**
+ * Add trailer to packet.
+ *
+ *
+ * @param pkt Packet to add trailer data to.
+ * @param data Pointer to data to copy into the trailer.
+ * @param len Length of trailer data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_add_trail(struct cfpkt *pkt, const void *data, uint16 len);
+
+/**
+ * Pad trailer on packet.
+ * Moves data pointer in packet, no content copied.
+ *
+ * @param pkt Packet in which to pad trailer.
+ * @param len Length of padding to add.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_pad_trail(struct cfpkt *pkt, uint16 len);
+
+/**
+ * Add a single byte to packet body (tail).
+ *
+ * @param pkt Packet in which to add byte.
+ * @param data Byte to add.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_addbdy(struct cfpkt *pkt, const uint8 data);
+
+/**
+ * Add a data to packet body (tail).
+ *
+ * @param pkt Packet in which to add data.
+ * @param data Pointer to data to copy into the packet body.
+ * @param len Length of data to add.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_add_body(struct cfpkt *pkt, const void *data, uint16 len);
+
+/**
+ * Checks whether there are more data to process in packet.
+ * @param pkt Packet to check.
+ * @return \ref true if more data are available in packet \ref false if no more data can be extracted
+ */
+bool cfpkt_more(struct cfpkt *pkt);
+
+/**
+ * Checks whether the packet is erroneous, i.e. if it has been attempted to extract more data than available in packet
+ * or writing more data than has been allocated in \ref cfpkt_create().
+ * @param pkt Packet to check.
+ * @return \ref true on error \ref false otherwise
+ */
+bool cfpkt_erroneous(struct cfpkt *pkt);
+
+/**
+ * Get the packet length.
+ * @param pkt Packet to get length from.
+ * @return Number of bytes in packet.
+ */
+uint16 cfpkt_getlen(struct cfpkt *pkt);
+
+/**
+ * Set the packet length, by adjusting the trailer pointer according to length.
+ * @param pkt Packet to set length.
+ * @param len Packet length.
+ * @return Number of bytes in packet.
+ */
+int cfpkt_setlen(struct cfpkt *pkt, uint16 len);
+
+/**
+ * Appends a packet's data to another packet.
+ * NB: Input packets will be destroyed after appending and cannot be used
+ * after calling this function.
+ * @param dstpkt Packet to append data into, WILL BE FREED BY THIS FUNCTION
+ * @param addpkt Packet to be appended and automatically released, WILL BE FREED BY THIS FUNCTION.
+ * @param expectlen Packet's expected total length. This should be considered as a hint.
+ * @return The new appended packet.
+ */
+struct cfpkt *cfpkt_append(struct cfpkt *dstpkt, struct cfpkt *addpkt,
+		      uint16 expectlen);
+
+/**
+ * Split a packet into two packets at the specified split point.
+ * @param pkt Packet to be split (will contain the first part of the data on exit)
+ * @param pos Position to split packet in two parts.
+ * @return The new packet, containing the second part of the data.
+ */
+struct cfpkt *cfpkt_split(struct cfpkt *pkt, uint16 pos);
+
+/** Iteration function, iterates the packet buffers from start to end.*/
+uint16 cfpkt_iterate(struct cfpkt *pkt, iterfunc_t func, uint16 data);
+
+void
+cfpkt_extract(struct cfpkt *cfpkt, void *buf, unsigned int buflen,
+	      unsigned int *actual_len);
+
+/** Append by giving user access to packet buffer
+ * @param pkt Packet to append to
+ * @param buf Buffer inside pkt that user shall copy data into
+ * @param buflen Length of buffer and number of bytes added to packet
+ * @return 0 on error, 1 on success
+ */
+int cfpkt_raw_append(struct cfpkt *cfpkt, void **buf, unsigned int buflen);
+
+/** Extract by giving user access to packet buffer
+ * @param pkt Packet to extract from
+ * @param buf Buffer inside pkt that user shall copy data from
+ * @param buflen Length of buffer and number of bytes removed from packet
+ * @return 0 on error, 1 on success
+ */
+int cfpkt_raw_extract(struct cfpkt *cfpkt, void **buf, unsigned int buflen);
+
+/** Map from a "native" packet (e.g. Linux Socket Buffer) to a CAIF packet.
+ *  @param dir - Direction indicating whether this packet is to be sent or received.
+ *  @param nativepkt  - The native packet to be transformed to a CAIF packet
+ *  @return The mapped CAIF Packet CFPKT.
+ */
+struct cfpkt *cfpkt_fromnative(enum caif_direction dir, void *nativepkt);
+
+/** Map from a CAIF packet to a "native" packet (e.g. Linux Socket Buffer).
+ *  @param pkt  - The CAIF packet to be transformed into a "native" packet.
+ *  @return The native packet transformed from a CAIF packet.
+ */
+void *cfpkt_tonative(struct cfpkt *pkt);
+
+struct caif_packet_funcs cfpkt_get_packet_funcs(void);
+
+/**
+ * Insert a packet in the packet queue.
+ * @param pkt Packet to be inserted in queue
+ * @param pktq Packet queue to insert into
+ * @param prio Priority of packet
+ */
+void cfpkt_queue(struct cfpktq *pktq, struct cfpkt *pkt,
+		 unsigned short prio);
+
+/**
+ * Remove a packet from the packet queue.
+ * @param pktq Packet queue to fetch packets from.
+ * @return Dequeued packet.
+ */
+struct cfpkt *cfpkt_dequeue(struct cfpktq *pktq);
+
+/**
+ * Peek into a packet from the packet queue.
+ * @param pktq Packet queue to fetch packets from.
+ * @return Peeked packet.
+ */
+struct cfpkt *cfpkt_qpeek(struct cfpktq *pktq);
+
+/**
+ * Initiates the packet queue.
+ * @return Pointer to new packet queue.
+ */
+struct cfpktq *cfpktq_create(void);
+
+/**
+ * Get the number of packets in the queue.
+ * @param pktq Packet queue to fetch count from.
+ * @return Number of packets in queue.
+ */
+int cfpkt_qcount(struct cfpktq *pktq);
+
+/**
+ * Put content of packet into buffer for debuging purposes.
+ * @param pkt Packet to copy data from
+ * @param buf Buffer to copy data into
+ * @param buflen Length of data to copy
+ * @return Pointer to copied data
+ */
+char *cfpkt_log_pkt(struct cfpkt *pkt, char *buf, int buflen);
+
+/**
+ * Clones a packet and releases the original packet.
+ * This is used for taking ownership of a packet e.g queueing.
+ * @param pkt Packet to clone and release.
+ * @return Cloned packet.
+ */
+struct cfpkt *cfpkt_clone_release(struct cfpkt *pkt);
+
+/*! @} */
+#endif				/* CFPKT_H_ */
diff --git a/include/net/caif/generic/cfserl.h b/include/net/caif/generic/cfserl.h
new file mode 100644
index 0000000..794ee85
--- /dev/null
+++ b/include/net/caif/generic/cfserl.h
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSERL_H_
+#define CFSERL_H_
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+
+/**
+ * This variable is used as a global flag, in order to set whether STX is
+ * used on serial communication.
+ * NOTE: This is not a fully future proof solution.
+ */
+extern int serial_use_stx;
+struct layer *cfserl_create(int type, int instance, bool use_stx);
+
+#endif				/* CFSERL_H_ */
diff --git a/include/net/caif/generic/cfshml.h b/include/net/caif/generic/cfshml.h
new file mode 100644
index 0000000..0757b02
--- /dev/null
+++ b/include/net/caif/generic/cfshml.h
@@ -0,0 +1,12 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSHML_H_
+#define CFSHML_H_
+
+struct layer *cfshml_create(int type, int instance);
+
+#endif				/* CFSHML_H_ */
diff --git a/include/net/caif/generic/cfspil.h b/include/net/caif/generic/cfspil.h
new file mode 100644
index 0000000..0145190
--- /dev/null
+++ b/include/net/caif/generic/cfspil.h
@@ -0,0 +1,85 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSPIL_H_
+#define CFSPIL_H_
+#include <net/caif/generic/cfpkt.h>
+
+struct cfspipad {
+	uint16 up_head_align;	/* Current uplink head alignment: 0 for byte
+				   alignment, 1 for 16bits, 3 for 32bits */
+	uint16 up_tail_align;	/* Current uplink tail alignment: 0 for byte
+				   alignment, 1 for 16bits, 3 for 32bits */
+	uint16 down_head_align;	/* Current downlink head alignment: 0 for byte
+				   alignment, 1 for 16bits, 3 for 32bits */
+	uint16 down_tail_align;	/* Current downlink tail alignment: 0 for byte
+				   alignment, 1 for 16bits, 3 for 32bits */
+};
+
+/* Forward declarations */
+struct cfspil;
+
+extern int spi_up_head_align;
+extern int spi_up_tail_align;
+extern int spi_down_head_align;
+extern int spi_down_tail_align;
+
+
+
+/** @page SPI PHY Layer description.
+ *
+ *  SPI Physical layer is not implemented in GenCaif. The SPI PHY Layer
+ *  is HW dependent. However, the CFSPIL (CAIF SPI Layer) provides support
+ *  for implementing the SPI Layer Protocol.
+ *
+ *  SPI PHY uses a different paradigm for transmit from the rest of GenCaif.
+ *  SPI PHY is pulling packets from CFSPIL. The SPI PHY gets a notification
+ *  about a transfer; it then requests transfer length and data to transfer
+ *  in the following way:
+ *
+ *  -# Wait for transmit request (packet will be \b null pointer), indicating
+ *     GenCaif wants something to be sent to the modem.
+ *  -# Request the transfer length by using function \ref cfspil_xmitlen,
+ *  -# Add CAIF SPI command to SPI transfer.
+ *  -# When SPI is ready for transfer, call \ref cfspil_getxmitpkt to get
+ *      the transfer packet.
+ *  -# Request new transfer length ( \ref cfspil_xmitlen) unless zero
+ *     length is returned.
+ *  -# Wait for next transfer request.
+ *
+ *
+ *   * CFSPIL Specification:
+ * \see { GenCaifSPI }
+ *
+ */
+/*! \addtogroup GenCaifSPI
+ *  Additional documentation for group `GenCaifSPI'
+ *  @{
+ */
+
+/**
+ * Create and initialize SPI layer.
+ */
+struct layer *cfspil_create(int type, int instance, struct cfspipad);
+
+/**
+ *  Check the length of the next SPI frame to send.
+ *  @param layr Pointer to SPI layer
+ *  @return Length of next SPI transfer, 0 if nothing to send.
+ */
+int cfspil_xmitlen(struct cfspil *layr);
+
+/**
+ *  Get the next CAIF SPI frame to send. This packet is guaranteed to have equal size to the
+ *  length given in \ref cfspil_getxmitpkt.
+ *  @param layr Pointer to SPI layer
+ *  @return The CAIF packet to be sent.
+ */
+struct cfpkt *cfspil_getxmitpkt(struct cfspil *layr);
+
+/*! @} */
+
+#endif				/* CFSPIL_H_ */
diff --git a/include/net/caif/generic/cfsrvl.h b/include/net/caif/generic/cfsrvl.h
new file mode 100644
index 0000000..c69f0e7
--- /dev/null
+++ b/include/net/caif/generic/cfsrvl.h
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFSRVL_H_
+#define CFSRVL_H_
+#include <net/caif/generic/cflst.h>
+#include <net/caif/generic/cfglue.h>
+#include <stddef.h>
+
+struct cfsrvl {
+	struct layer layer;
+	/** Physical ID of the logical physical connection */
+	uint8 phid;
+	bool open;
+	bool phy_flow_on;
+	bool modem_flow_on;
+};
+
+struct layer *cfvei_create(uint8 linkid, uint8 phyid);
+struct layer *cfdgml_create(uint8 linkid, uint8 phyid);
+struct layer *cfutill_create(uint8 linkid, uint8 phyid);
+struct layer *cfvidl_create(uint8 linkid, uint8 phyid);
+struct layer *cfrfml_create(uint8 linkid, uint8 phyid);
+bool cfsrvl_phyid_match(struct layer *layer, int phyid);
+void cfservl_destroy(struct layer *layer);
+void cfsrvl_init(struct cfsrvl *service, uint8 channel_id, uint8 phyid);
+bool cfsrvl_ready(struct cfsrvl *service, int *err);
+uint8 cfsrvl_getphyid(struct layer *layer);
+
+#endif				/* CFSRVL_H_ */
diff --git a/include/net/caif/generic/cfusbl.h b/include/net/caif/generic/cfusbl.h
new file mode 100644
index 0000000..cd83b39
--- /dev/null
+++ b/include/net/caif/generic/cfusbl.h
@@ -0,0 +1,13 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFUSBL_H_
+#define CFUSBL_H_
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfglue.h>
+struct layer *cfusbl_create(int type, int instance);
+
+#endif				/* CFUSBL_H_ */
diff --git a/include/net/caif/generic/fcs.h b/include/net/caif/generic/fcs.h
new file mode 100644
index 0000000..041f5c5
--- /dev/null
+++ b/include/net/caif/generic/fcs.h
@@ -0,0 +1,13 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef FCS_H_
+#define FCS_H_
+
+uint16
+fcs16(uint16 fcs, uint8 *cp, uint16 len);
+
+#endif				/* FCS_H_ */
-- 
1.6.2.2.1669.g7eaf8

