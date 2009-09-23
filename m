From: sjur.brandeland@stericsson.com
Subject: [PATCH 2/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 19:31:10 +0200
Message-ID: <1253727070-10263-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Kim.xx.Lilliestierna@ericsson.com, sjur.brandeland@stericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55448 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbZIWSbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:31:21 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF003OIQ02F560@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:15 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF00JPVQ01H7C1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>


Signed-off-by: sjur.brandeland@stericsson.com
---
 include/net/caif/generic/caif_layer.h |  378 +++++++++++++++++++++++++++++++++
 include/net/caif/generic/cfcnfg.h     |  223 +++++++++++++++++++
 include/net/caif/generic/cfctrl.h     |  139 ++++++++++++
 include/net/caif/generic/cffrml.h     |   29 +++
 include/net/caif/generic/cfglue.h     |  206 ++++++++++++++++++
 include/net/caif/generic/cfloopcfg.h  |   28 +++
 include/net/caif/generic/cflst.h      |   27 +++
 include/net/caif/generic/cfmsll.h     |   22 ++
 include/net/caif/generic/cfmuxl.h     |   30 +++
 include/net/caif/generic/cfpkt.h      |  246 +++++++++++++++++++++
 include/net/caif/generic/cfserl.h     |   22 ++
 include/net/caif/generic/cfshml.h     |   21 ++
 include/net/caif/generic/cfspil.h     |   80 +++++++
 include/net/caif/generic/cfsrvl.h     |   48 ++++
 include/net/caif/generic/fcs.h        |   22 ++
 15 files changed, 1521 insertions(+), 0 deletions(-)
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
 create mode 100644 include/net/caif/generic/fcs.h

diff --git a/include/net/caif/generic/caif_layer.h b/include/net/caif/generic/caif_layer.h
new file mode 100644
index 0000000..76280e6
--- /dev/null
+++ b/include/net/caif/generic/caif_layer.h
@@ -0,0 +1,378 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Braendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+#ifndef CAIF_LAYER_H_
+#define CAIF_LAYER_H_
+
+#include "cfglue.h"
+/* Forward Declaration */
+struct _layer_t;
+struct _cfpkt_t;
+struct _cfpktq_t;
+struct _transmt_info;
+struct _caif_packet_funcs_t;
+typedef struct _cfpktq_t cfpktq_t;
+/* Type definitions*/
+typedef struct _transmt_info transmt_info;
+
+typedef struct _layer_t layer_t;
+typedef struct _caif_packet_funcs_t caif_packet_funcs_t;
+typedef struct _cfpkt_t cfpkt_t;
+
+#define CAIF_MAX_FRAMESIZE 4096
+#define CAIF_MAX_PAYLOAD_SIZE (4096 - 64)
+#define CAIF_NEEDED_HEADROOM (10)
+#define CAIF_NEEDED_TAILROOM (2)
+
+/*! \addtogroup GenCaifExternal
+ *  Additional documentation for group `GenCaifExternal'
+ *  @{
+ */
+
+
+/** CAIF Control Signaling.
+ *  These commands are sent upwards in the CAIF stack. They are used for
+ *  Signaling originating from Modem.
+ *  These are either responses (*_RSP) or events (*_IND).
+
+ */
+typedef enum _caif_ctrlcmd_t {
+	/** Flow Control is OFF, transmit function should stop sending data */
+	CAIF_CTRLCMD_FLOW_OFF_IND = 0,
+	/** Flow Control is ON, transmit function can start sending data */
+	CAIF_CTRLCMD_FLOW_ON_IND = 1,
+	/** Remote end CCPU has decided to close down channel */
+	CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND = 5,
+	/** Called initially when the layer below has finished initialization */
+	CAIF_CTRLCMD_INIT_RSP = 3,
+	/** Called when de-initialization is complete */
+	CAIF_CTRLCMD_DEINIT_RSP = 4,
+	/** Called if initialization failes */
+	CAIF_CTRLCMD_INIT_FAIL_RSP = 6,
+	/** Note: Only used internally in GenCaif.
+	 * Called if physical interface cannot send more packets */
+	_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND = 7,
+	/** Note: Only used internally in GenCaif.
+	 * Called if physical interface is able to send packets again */
+	_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND = 8
+} caif_ctrlcmd_t;
+
+
+
+/** Modem Control Signaling.
+ *  These are requests sent 'down-wards' in the stack.
+ *  Flow ON, OFF can be indicated to the modem.
+ *
+ */
+typedef enum _caif_modemcmd_t {
+	/** Flow Control is ON, transmit function can start sending data */
+	CAIF_MODEMCMD_FLOW_ON_REQ = 0,
+	/** Flow Control is OFF, transmit function should stop sending data */
+	CAIF_MODEMCMD_FLOW_OFF_REQ = 1,
+	/** Notify physical layer that it is in use */
+	_CAIF_MODEMCMD_PHYIF_USEFULL = 3,
+	/** Notify physical layer that it is no longer in use */
+	_CAIF_MODEMCMD_PHYIF_USELESS = 4
+} caif_modemcmd_t;
+
+/** CAIF Packet Direction.
+ *  Indicate if a packet is to be sent \b out or to be received \b in.
+ *
+ *
+ */
+typedef enum _caif_direction_t {
+	CAIF_DIR_IN = 0,	/*!< Incoming packet received. */
+	CAIF_DIR_OUT = 1	/*!< Outgoing packet to be transmitted. */
+} caif_direction_t;
+
+/*!
+ *  Receive Function.
+ *  Contract: Each layer must implement a receive function passing the Caif
+ *  Packets upwards in the stack.
+ *	Packet handling rules:
+ *	      -# The CAIF Packet (cfpkt) cannot be accessed after passing i
+ *		     to the next layer using up->receive().
+ *	      -# If parsing of the packet fail, the packet must be destroyed
+ *		     and -1 returned from the function.
+ *	      -# If parsing succeeds (and above layers return ok) function
+ *		     must return value > 0.
+ *
+ *  @param[in] layr Pointer to the current layer the receive function is
+ *		implemented for (this pointer).
+ *  @param[in] cfpkt Pointer to CaifPacket to be handled.
+ *  @return result < 0 indicates an error, 0 or positive value indicate success.
+ */
+typedef int (*receive_cb_t) (layer_t *layr, struct _cfpkt_t *cfpkt);
+
+/*!
+ *  Transmit Function.
+ *  Contract: Each layer must implement a transmit function passing the Caif
+ *	Packet downwards in the stack.
+ *	Packet handling rules:
+ *	      -# The CAIF Packet (cfpkt) ownership is passed to the transmit
+ *		 function. This means that the the packet cannot be access
+ *		 after passing it to the below layer using dn->transmit().
+ *
+ *
+ *	      -# However if transmit failes, the ownership is returned to
+ *		 caller. The caller of "dn->transmit()" must destroy or
+ *		 resend packet.
+ *
+ *	      -# Return less than zero means error, greater than zero means OK.
+ *
+ *  @param[in] layr  Pointer to the current layer the receive function is
+ *			     implemented for (this pointer).
+ *  @param[in] cfpkt Pointer to CaifPacket to be handled.
+ *  @param[in] info  Info about physical layer (filled in by MUX layer) and
+			     CAIF header size (each layer adds to hdr_len).
+ *  @return	     result < 0 indicates an error, 0 or positive value
+ *		     indicate success.
+ */
+typedef int (*transmit_cb_t) (layer_t *layr, transmt_info *info,
+		      struct _cfpkt_t *cfpkt);
+
+/*!
+ *  Control Function used to signal upwards in the CAIF stack.
+ *  Used for signaling responses (CAIF_CTRLCMD_*_RSP)
+ *  and asynchronous events from the modem  (CAIF_CTRLCMD_*_IND)
+ *
+ *  @param[in] layr  Pointer to the current layer the receive function is
+ *		     implemented for (this pointer).
+ *  @param[in] ctrl  Control Command.
+ */
+typedef void
+ (*ctrlcmd_cb_t) (layer_t *layr, caif_ctrlcmd_t ctrl, int phyid);
+
+/*!
+ *  Control Function used for controlling the modem. Used to signal down-wards
+ *  in the CAIF stack.
+ *  @returns 0 on success, < 0 upon failure.
+ *  @param[in] layr  Pointer to the current layer the receive function is
+ *		     implemented for (this pointer).
+ *  @param[in] ctrl  Control Command.
+ */
+typedef int (*modemcmd_cb_t) (layer_t *layr, caif_modemcmd_t ctrl);
+
+/*!
+ *  This function is used by the CAIF-Manager for initiating the adaptation
+ *  layer.
+ *  @param in caifstack The instance of layer below the adaptation layer in
+ *  the CAIF stack (service layer)
+ *  @param in pktfuncs The packet functions needed to create a packet is
+ *  passed in this structure
+ *  @param out adap_layer This layer is allocated and returned from the
+ *  adaptaion layer, and is inserted
+ *  in the CAIF stack as the topmost layer.
+ *
+ */
+typedef void
+ (*init_adaptation_layer) (layer_t *caifstack,
+			   caif_packet_funcs_t *pktfuncs,
+			   layer_t **adap_layer);
+
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
+ *       \code layer->up->receive(layer->up, packet); \endcode
+ *       \see {receive_cb_t }
+ *    -# In order to send data downwards do
+ *       \code layer->dn->transmit(layer->dn, info, packet); \endcode
+ *       \see {transmit_cb_t }
+ *
+ *
+ *
+ */
+struct _layer_t {
+
+	struct _layer_t *up;	/*!< Pointer to the layer above */
+	struct _layer_t *dn;	/*!< Pointer to the layer below */
+	receive_cb_t receive;	/*!< Pointer to the receive function for this
+				 *   layer,used by the layer below to pass data
+				 *   upwards in the CAIF stack.*/
+	transmit_cb_t transmit;	/*!< Pointer to the transmit function used for
+				 *   the layer above to pass packet to be
+				 *   sent out on the stack.*/
+	ctrlcmd_cb_t ctrlcmd;	/*!< Pointer to function used by the CAIF stack
+				 *    to signal to the layer above.*/
+	modemcmd_cb_t modemcmd;	/*!< Pointer to function used by the CAIF stack
+				 * to signal to the layer below. */
+	struct _layer_t *next;	/*!< Pointer to chain of layers, up/dn will
+				 *   then point at the first element of a
+				 *   which then should be iterated through
+				 * the next pointer.*/
+	unsigned short prio;	/*!< Priority of this layer */
+	unsigned int id;	/*!< The identity of this layer. */
+	unsigned int type;	/*<! The type of this layer */
+	char name[9];		/*!< Name of the layer */
+};
+
+/** Set the up pointer for a specified layer.
+ *  @param layr Layer where up pointer shall be set.
+ *  @param above Layer above.
+ */
+#define layer_set_up(layr, above) ((layr)->up = (struct _layer_t *)(above))
+
+/** Set the dn pointer for a specified layer.
+ *  @param layr Layer where down pointer shall be set.
+ *  @param below Layer below.
+ */
+#define layer_set_dn(layr, below) ((layr)->dn = (struct _layer_t *)(below))
+
+/**
+ *  Transmit info, passed down-wards in protocol layers.
+ */
+struct _transmt_info {
+  /** Channel ID of the logical CAIF connection.
+   *  Is used by Service Layer to indicate to mux the PHY-layer
+   *  (Physical-ID) to send packet over.
+   */
+	unsigned short channel_id;
+
+  /** Physical ID of the logical physical connection.
+   *  Used by Service Layers to identify their physical id to Caif MUX (CFMUXL)
+   *  so that the MUX can add the
+   *  correct physical Id to the packet.
+   */
+
+	unsigned short phid;
+  /** Header Length, used to align pay load on 32bit boundary.
+   *  Used by SPI Layer (CFSPIL) to align start of pay-load data (IP header
+   *  start) to 16 or 32 bits boundary.
+   *  All layers add the number of header bytes they are using, then SPI
+   *  layer adds padding to get correct alignment.
+   */
+
+	unsigned short hdr_len;
+	/** Packet priority. */
+	unsigned char prio;
+};
+
+/** Packet functions needed by Adaptation layer and PHY layer are exported in
+ *  this structure
+ *
+ */
+struct _caif_packet_funcs_t {
+
+#ifdef CAIF_USE_SKB
+  /** Used map from a "native" packet e.g. Linux Socket Buffer to a CAIF packet.
+   *  @param dir - Direction telling if this is an packet to be sent or received
+   *  @param nativepkt	- The native packet to be transformed to a CAIF packe
+   *  @returns the mapped CAIF Packet CFPKT.
+   */
+	cfpkt_t *
+	    (*cfpkt_fromnative)(caif_direction_t dir, void *nativepkt);
+
+  /** Used map from a CAIF packet to a "native" packet e.g. Linux Socket Buffer.
+   *  @param pkt  - The CAIF packet to be transformed to a "native" packet.
+   *  @returns The native packet transformed from a CAIF packet.
+   */
+	void *(*cfpkt_tonative)(cfpkt_t *pkt);
+#endif
+  /** Used by "app" layer to create an outgoing CAIF packet to be sent ou
+   *  of the CAIF Stack.
+   *  @param data - Packet data to copy into the packet. If NULL copying will
+   *		     not take place.
+   *  @param len  - Length of data to copy into the packe
+   *  @returns a new CAIF Packet CFPKT.
+   *  @deprecated Use \b cfpkt_create_pkt (above) instead.
+   */
+	cfpkt_t *
+	    (*cfpkt_create_recv_pkt)(const unsigned char *data,
+				      unsigned int len);
+
+  /** Used by PHY layer to create an incoming CAIF packet to be processed by
+   *  the CAIF Stack.
+   *  @param data - Packet data to copy into the packet. If NULL copying
+   *  will not take place.
+   *  @param len  - Length of data to copy into the packe
+   *  @returns a new CAIF Packet CFPKT.
+   *  @deprecated Use \b cfpkt_create_pkt (above) instead.
+   */
+	cfpkt_t *
+	    (*cfpkt_create_xmit_pkt)(const unsigned char *data,
+				      unsigned int len);
+
+  /** Used to extract data from a CAIF packe
+   *  @param cfpkt	 Packet to extract data from.
+   *  @param buf	 Buffer to hold the data to be extracted from the
+   *			 CAIF packet.
+   *  @param buflen	 Length of the buffer (maximum length of the data to
+   *			 copy into the buffer).
+   *  @param actual_len	 Amount of bytes copied from the packet into the buffer.
+   */
+	void
+	 (*cfpkt_extract)(cfpkt_t *cfpkt, void *buf, unsigned int buflen,
+			   unsigned int *actual_len);
+
+  /** Releases a CAIF Packe
+   *  @param cfpkt	 Packet to destroy.
+   */
+	void
+	 (*cfpkt_destroy)(cfpkt_t *cfpkt);
+
+
+
+/** Append by giving user access to packet buffer
+ * @param pkt Packet to append to
+ * @param buf Buffer inside pkt that user shall copy data into
+ * @param buflen Length of buffer and number of bytes added to packe
+ * @return < 0 on error
+ */
+
+	 int (*cfpkt_raw_append)(cfpkt_t *cfpkt, void **buf,
+				unsigned int buflen);
+
+/** Extract by giving user access to packet buffer
+ * @param pkt Packet to extract from
+ * @param buf Buffer inside pkt that user shall copy data from
+ * @param buflen Length of buffer and number of bytes removed from packe
+ * @return < 0 on error
+ */
+	 int (*cfpkt_raw_extract)(cfpkt_t *cfpkt, void **buf,
+				 unsigned int buflen);
+
+
+  /** Creates a packet queue */
+	cfpktq_t *(*cfpktq_create)(void);
+
+  /** Inserts a packet into the packet queue, packets are ordered by priority.
+   *  If the same priority is used packets are ordered as a FIFO.
+   */
+	void (*cfpkt_queue)(cfpktq_t *pktq, cfpkt_t *pkt,
+			     unsigned short prio);
+
+
+  /** Peek into the first packet in the queue */
+	cfpkt_t *(*cfpkt_qpeek)(cfpktq_t *pktq);
+
+  /** Dequeue a packet from the queue */
+	cfpkt_t *(*cfpkt_dequeue)(cfpktq_t *pktq);
+
+  /** Get length of a packet */
+	uint16(*cfpkt_getlen)(cfpkt_t *pkt);
+
+};
+
+/*! @} */
+
+#endif				/* CAIF_LAYER_H_ */
diff --git a/include/net/caif/generic/cfcnfg.h b/include/net/caif/generic/cfcnfg.h
new file mode 100644
index 0000000..853eff4
--- /dev/null
+++ b/include/net/caif/generic/cfcnfg.h
@@ -0,0 +1,223 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+
+#ifndef CFCNFG_H_
+#define CFCNFG_H_
+#include "caif_layer.h"
+#include "cfctrl.h"
+struct _cfctrl_t;
+struct _cfcnfg_t;
+
+/** CAIF Configuration Layer (CFCNFG)*/
+typedef struct _cfcnfg_t cfcnfg_t;
+
+/*! \addtogroup GenCaifExternal
+ *  Additional documentation for group `GenCaifExternal'
+ *  @{
+ */
+
+
+/** Types of Physical Layers defined in CAIF Stack */
+typedef enum _cfcnfg_phy_type_t {
+	CFPHYTYPE_UNKNOWN = 0,
+	CFPHYTYPE_SERIAL = 1,	/*!< Serial Physical Interface */
+	CFPHYTYPE_SPI = 2,	/*!< SPI Physical Interface */
+	CFPHYTYPE_MSL = 3,	/*!< MSL Physical Interface */
+	CFPHYTYPE_SHM = 4,	/*!< Shared Memory Physical Interface */
+	CFPHYTYPE_LOOP = 5,	/*!< Loopback Physical Interface */
+	_CFPHYTYPE_MAX = 6
+} cfcnfg_phy_type_t;
+
+/** Physical Preference - HW Abstraction */
+typedef enum _cfcnfg_phy_preference_t {
+	/** Default Physical Interface */
+	CFPHYPREF_UNSPECIFIED = 0xa0,
+	/** Default Physical Interface for Low Latency Traffic */
+	CFPHYPREF_LOW_LAT = 0xd0,
+	/** Default Physical Interface for High Bandwidth Traffic */
+	CFPHYPREF_HIGH_BW = 0xe0,
+	/** \b TEST \b ONLY Loop-back Interface Simulating Acc side responses */
+	CFPHYPREF_LOOP = 0x70,
+	/** \b TEST \b ONLY Raw loopback interface */
+	CFPHYPREF_RAW_LOOP = 0x80
+} cfcnfg_phy_preference_t;
+
+/** Types of CAIF Links defined in CAIF Stack
+ * @obsolete
+ */
+typedef enum _cfcnfg_link_type_t {
+	_CF_DECM = 0,		/*!< DECM link - NOT SUPPORTED */
+	CF_VEI = CFCTRL_SRV_VEI,	/*!< VEI link - AT */
+	CF_VIDEO = CFCTRL_SRV_VIDEO,	/*!< Video Link */
+	CF_DEBUG = CFCTRL_SRV_DBG,	/*!< Debug Link */
+	CF_DATAGRAM = CFCTRL_SRV_DATAGRAM,	/*!< Datagram link */
+	CF_RFM = CFCTRL_SRV_RFM,	/*!< RFM link */
+	CF_UTILITY = CFCTRL_SRV_UTIL	/*!< Utility link */
+} cfcnfg_link_type_t;
+
+
+/** Configuration parameters for a physical layer (e.g. Serial) */
+typedef struct cfcnfg_phy_param_t {
+	int foo;
+} cfcnfg_phy_param_t;
+
+/** Configuration information used to setup the CAIF Physical Interface */
+typedef struct cfcnfg_phy_config {
+	/** CAIF Physical Type */
+	cfcnfg_phy_type_t phy_type;
+	/** Instance Number, e.g. Uart Number */
+	uint8 phy_sub_instance;
+	/** Preference LowLatency/HighBandwithd */
+	cfcnfg_phy_preference_t pref;
+	/** Device Name */
+	char name[20];
+	/** Cheksum is used for Interface */
+	bool checksum;
+	/** Configuration param specific for the PHY Type */
+	cfcnfg_phy_param_t param;
+	/** Pointer to layer above */
+	layer_t *up;
+} cfcnfg_phy_config_t;
+
+/** Registration information used to setup the CAIF Physical Interface */
+typedef struct cfcnfg_phy_mgmt {
+	/** Registation of type */
+	cfcnfg_phy_type_t type;
+	/** Creates an instance of the physical layer (e.g. Serial)
+	 * and configures it */
+	layer_t *(*create_phy) (cfcnfg_phy_config_t *config);
+	 /** Delete an instance of the physical layer (e.g. Serial) */
+	int (*delete_phy) (layer_t *l);
+} cfcnfg_phy_mgmt_t;
+
+
+
+
+/**
+ * This variable is used as a global flag in order to set if STX is used on
+ * serial communication.
+ *  NOTE: This is not a fully future proof solution.
+ */
+
+extern int serial_use_stx;
+
+
+/**
+ * Create the CAIF Configuration Object.
+ * \image html CreateCaifConfig.jpg "Create Caif Configuration Object."
+ * @returns the created instance of a CFCNFG object.
+ */
+cfcnfg_t *cfcnfg_create(void);
+
+/**
+ * Adds a physical layer to the CAIF stack.
+ * \image html AddPhyCaifConfig.jpg "Add a PHY layer to CAIF Stack."
+ * @param cnfg Pointer to the Caif Configuration Class, created by
+ *				fcnfg_create().
+ * @param phy_type Specifies the type of physical interface e.g.
+ *		    CFPHYTYPE_SERIAL.
+ * @param phy_layer Specify the physical layer, the transmit function
+ *		    MUST be set in the structure.
+ * @param phyid [out] The assigned physical ID for this layer,
+ *		      used in \ref cfcnfg_add_adapt_layer to specify
+ *		      PHY for the link.
+ */
+
+void
+cfcnfg_add_phy_layer(cfcnfg_t *cnfg, cfcnfg_phy_type_t phy_type,
+		     layer_t *phy_layer, uint16 *phyid,
+		     cfcnfg_phy_preference_t pref);
+
+/**
+ * Deletes a Adaptation Layer from the CAIF Stack.
+ *
+ * @param cnfg Pointer to the CAIF Configuration Class, created by
+ *			   cfcnfg_create().
+ * @param adap_layer Adaptation layer to be removed.
+ * @return true on success, false upon failure.
+ */
+
+bool cfcnfg_del_adapt_layer(struct _cfcnfg_t *cnfg, layer_t *adap_layer);
+
+/**
+ * Adds a Adaptation Layer to the CAIF Stack.
+ * The Adaptation Layer is where the interface to application or higher-level
+ * driver functionality is implemented.
+ * \image html AddVeiCaifConfig.jpg "Add an Adaptation layer to CAIF Stack."
+ *
+ * @param cnfg	     Pointer to the CAIF Configuration Class, created by
+ *		     cfcnfg_create().
+ * @param linktype   Type of link which is set up e.g. CF_AT_PLAIN.
+ * @param connid     Connection ID, used for data-gram links.
+ * @param phyid	     PHY ID received from \ref	cfcnfg_add_phy_layer,
+ *		     specifying the PHY device to use for this link.
+ * @param adap_layer Specify the adaptation layer, the receive
+ *		     and flow-control functions MUST be set in the structure.
+ * @return	     true on success, false upon failure.
+ */
+bool
+cfcnfg_add_adapt_layer(cfcnfg_t *cnfg, cfcnfg_link_type_t linktype,
+		       uint32 connid, uint16 phyid, layer_t *adap_layer);
+
+
+
+/**
+ * Adds a Adaptation Layer to the CAIF Stack.
+ * The Adaptation Layer is where the interface to application or higher-level
+ * driver functionality is implemented.
+ * \image html AddVeiCaifConfig.jpg "Add an Adaptation layer to CAIF Stack."
+ *
+ * @param cnfg			Pointer to the CAIF Configuration Class, created by
+ *						cfcnfg_create().
+ * @param param			Link setup parameters.
+ * @param adap_layer	Specify the adaptation layer, the receive and flow-control functions MUST be set in the structure.
+ * @return				true on success, false upon failure.
+ */
+bool
+cfcnfg_add_adaptation_layer(cfcnfg_t *cnfg, cfctrl_link_param_t *param,
+			    layer_t *adap_layer);
+
+
+/**
+ * Returns a handle to the Packet Functions used to create packets with
+ * content, and extract information from packets.
+ */
+caif_packet_funcs_t cfcnfg_get_packet_funcs(void);
+
+/** Get Physical Id given type.
+ * @return Returns one of the physical interfaces matching the given type.
+ *	   Zero if no match is found.
+ */
+int cfcnfg_get_phyid(cfcnfg_t *cnfg, cfcnfg_phy_preference_t phy_pref);
+
+
+/** Get Physical Id given name.
+ * @return Returns the physical interface matching the specified name.
+ */
+int cfcnfg_get_named(cfcnfg_t *cnfg, char *name);
+
+int cfcnfg_instanciate(cfcnfg_t *cnfg, cfcnfg_phy_config_t *phy_config);
+int cfcnfg_instanciate2(cfcnfg_t *cnfg, cfcnfg_phy_type_t phy_type,
+			uint8 instance, char *name, bool checksum,
+			cfcnfg_phy_preference_t pref,
+			cfcnfg_phy_param_t *param);
+int cfcnfg_delete_phy_inst(cfcnfg_t *cfg, char *name);
+int cfcnfg_unregister_phy_type(cfcnfg_t *cfg, cfcnfg_phy_type_t type);
+int cfcnfg_register_phy_type(cfcnfg_t *cfg, cfcnfg_phy_mgmt_t *mgmt);
+int cfcnfg_del_phy_layer(struct _cfcnfg_t *cnfg, layer_t *phy_layer);
+
+/*! @} */
+#endif				/* CFCNFG_H_ */
diff --git a/include/net/caif/generic/cfctrl.h b/include/net/caif/generic/cfctrl.h
new file mode 100644
index 0000000..428d781
--- /dev/null
+++ b/include/net/caif/generic/cfctrl.h
@@ -0,0 +1,139 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFCTRL_H_
+#define CFCTRL_H_
+#include "caif_layer.h"
+#include "cfsrvl.h"
+
+
+/* CAIF Control packet commands*/
+typedef enum {
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
+} cfctrl_cmd_t;
+
+typedef enum {
+	CFCTRL_SRV_DECM = 0,
+	CFCTRL_SRV_VEI = 1,
+	CFCTRL_SRV_VIDEO = 2,
+	CFCTRL_SRV_DBG = 3,
+	CFCTRL_SRV_DATAGRAM = 4,
+	CFCTRL_SRV_RFM = 5,
+	CFCTRL_SRV_UTIL = 6,
+	CFCTRL_SRV_MASK = 0xf
+} cfctrl_srv_t;
+
+#define CFCTRL_RSP_BIT 0x20
+#define CFCTRL_ERR_BIT 0x10
+typedef void
+ (*cfctrl_rspcp_t) (void);
+
+
+
+typedef void
+ (*cfctrl_linkdestroy_rspcb_t) (layer_t *layer, uint8 linkid,
+				layer_t *client_layer);
+
+typedef void
+ (*cfctrl_linksetup_rspcb_t) (layer_t *layer, uint8 linkid,
+			      cfctrl_srv_t serv, uint8 phyid,
+			      layer_t *adapt_layer);
+
+typedef struct _cfctrl_rsp_t {
+	cfctrl_linksetup_rspcb_t linksetup_rsp;
+	cfctrl_linkdestroy_rspcb_t linkdestroy_rsp;
+	cfctrl_rspcp_t linkerror_ind;
+	cfctrl_rspcp_t enum_rsp;
+	cfctrl_rspcp_t sleep_rsp;
+	cfctrl_rspcp_t wake_rsp;
+	cfctrl_rspcp_t restart_rsp;
+	cfctrl_rspcp_t radioset_rsp;
+	cfctrl_linkdestroy_rspcb_t reject_rsp;
+} cfctrl_rsp_t;
+
+/** Link Setup Parameters for CAIF-Links. */
+typedef struct _cfctrl_link_param_t {
+	cfctrl_srv_t linktype;/*!< (T3,T0) Type of Channel */
+	uint8 priority;		  /*!< (P4,P0) Priority of the channel */
+	uint8 phyid;		  /*!< (U2-U0) Physical interface to connect */
+	uint8 endpoint;		  /*!< (E1,E0) Endpoint for data channels */
+	uint8 chtype;		  /*!< (H1,H0) Channel-Type,
+					       applies to VEI, DEBUG */
+	union {
+		struct {
+			uint8 connid;	/*!<  (D7,D0) Video LinkId */
+		} video;
+
+		struct {
+			uint32 connid;	/*!< (N31,Ngit0) Connection ID used
+					 *		  for Datagram */
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
+						 *    Parameters */
+		} utility;	/*!< Configuration for Utility Links (Psock) */
+	} u;
+} cfctrl_link_param_t;
+
+/** This structure is used internally in CFCTRL */
+struct cfctrl_request_info {
+	int sequence_no;
+	cfctrl_cmd_t cmd;
+	uint8 channel_id;
+	cfctrl_link_param_t param;
+	struct cfctrl_request_info *next;
+	layer_t *client_layer;
+};
+
+
+void cfctrl_enum_req(layer_t *cfctrl, uint8 physlinkid);
+
+
+
+void cfctrl_linkup_request(layer_t *cfctrl, cfctrl_link_param_t *param,
+			   layer_t *user_layer);
+
+
+void cfctrl_linkdown_req(layer_t *cfctrl, uint8 linkid, layer_t *client);
+void cfctrl_sleep_req(layer_t *cfctrl);
+void cfctrl_wake_req(layer_t *cfctrl);
+void cfctrl_getstartreason_req(layer_t *cfctrl);
+
+layer_t *cfctrl_create(void);
+void cfctrl_set_dnlayer(layer_t *this, layer_t *dn);
+void cfctrl_set_uplayer(layer_t *this, layer_t *up);
+void cfctrl_set_respfuncs(layer_t *this, cfctrl_rsp_t *respfuncs);
+#endif				/* CFCTRL_H_ */
diff --git a/include/net/caif/generic/cffrml.h b/include/net/caif/generic/cffrml.h
new file mode 100644
index 0000000..13d3ff1
--- /dev/null
+++ b/include/net/caif/generic/cffrml.h
@@ -0,0 +1,29 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFFRM_H_
+#define CFFRM_H_
+#include "cfglue.h"
+#include "caif_layer.h"
+#include "cflst.h"
+
+struct _cffrml_t;
+typedef struct _cffrml_t cffrml_t;
+layer_t *cffrml_create(uint16 phyid, bool DoFCS);
+void cffrml_set_uplayer(layer_t *this, layer_t *up);
+void cffrml_set_dnlayer(layer_t *this, layer_t *dn);
+void cffrml_destroy(layer_t *layer);
+
+#endif				/* CFFRM_H_ */
diff --git a/include/net/caif/generic/cfglue.h b/include/net/caif/generic/cfglue.h
new file mode 100644
index 0000000..0930309
--- /dev/null
+++ b/include/net/caif/generic/cfglue.h
@@ -0,0 +1,206 @@
+/*
+ *      Copyright (C) ST-Ericsson AB 2009
+ *
+ *      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+ *
+ *      License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+/*
+ *    Description: This file contains the OS and HW dependencies for CAIF.
+ */
+
+
+#ifndef CFGLU_H_
+#define CFGLU_H_
+
+/*! \addtogroup GenCaifGlue
+ *  Additional documentation for group `GenCaifGlue'
+ *  @{
+ */
+
+
+#define CFLOG_LEVEL_ERROR   1
+#define CFLOG_LEVEL_WARNING 2
+#define CFLOG_LEVEL_TRACE   3
+#define CFLOG_LEVEL_TRACE2  4
+#define CFLOG_LEVEL_TRACE3  5
+#define CFLOG_LEVEL_FUNC    6
+
+
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
+#include "linux/stddef.h"
+#include "linux/types.h"
+
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
+
+/* LOGGING */
+
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
+
+
+
+
+/* Critical Section support, one thread only between startsync
+ * and endsync */
+#define cfglu_lock_t spinlock_t
+#define cfglu_init_lock(sync) spin_lock_init(&(sync))
+#define cfglu_lock(sync) spin_lock(&(sync))
+#define cfglu_unlock(sync) spin_unlock(&(sync))
+#define cfglu_deinit_lock(sync)
+
+/* Read/Write lock, allows multiple readers, one writer */
+#define cfglu_rwlock_t rwlock_t
+#define cfglu_init_rwlock(rwlock) rwlock_init(&(rwlock))
+#define cfglu_deinit_rwlock(rwlock)
+#define cfglu_read_lock(rwlock)   read_lock(&rwlock)
+#define cfglu_read_unlock(rwlock) read_unlock(&rwlock)
+#define cfglu_write_lock(rwlock)    write_lock(&rwlock)
+#define cfglu_write_unlock(rwlock)  write_unlock(&rwlock)
+
+
+
+/* Atomic counting */
+#define cfglu_atomic_t atomic_t
+#define cfglu_atomic_read(a) atomic_read(&a)
+#define cfglu_atomic_set(a, val) atomic_set(&a, val)
+#define cfglu_atomic_inc(a) atomic_inc(&a)
+#define cfglu_atomic_dec(a) atomic_dec(&a)
+
+/* HEAP */
+#define cfglu_alloc(size) kmalloc(size, GFP_KERNEL)
+#define cfglu_free(ptr) kfree(ptr)
+
+/* ASSERT */
+#define cfglu_assert(exp) BUG_ON(!(exp))
+
+
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
+
+};
+
+#endif				/* CFGLU_H_ */
diff --git a/include/net/caif/generic/cfloopcfg.h b/include/net/caif/generic/cfloopcfg.h
new file mode 100644
index 0000000..ab982cb
--- /dev/null
+++ b/include/net/caif/generic/cfloopcfg.h
@@ -0,0 +1,28 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFLOOPCFG_H_
+#define CFLOOPCFG_H_
+#include "caif_layer.h"
+struct _cfloopcfg_t {
+	layer_t *loop;
+};
+typedef struct _cfloopcfg_t cfloopcfg_t;
+cfloopcfg_t *cfloopcfg_create(void);
+void cfloopcfg_add_phy_layer(cfloopcfg_t *cnfg,
+			     cfcnfg_phy_type_t phy_type,
+			     layer_t *phy_layer);
+
+#endif				/* CFLOOPCFG_H_ */
diff --git a/include/net/caif/generic/cflst.h b/include/net/caif/generic/cflst.h
new file mode 100644
index 0000000..25a7cb3
--- /dev/null
+++ b/include/net/caif/generic/cflst.h
@@ -0,0 +1,27 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFLST_H_
+#define CFLST_H_
+
+#include "cfglue.h"
+bool cflst_put(layer_t **lst, uint8 id, layer_t *node);
+layer_t *cflst_get(layer_t **lst, uint8 id);
+layer_t *cflst_del(layer_t **lst, uint8 id);
+#define CFLST_FIRST(lst) lst
+#define CFLST_MORE(node) ((node) != NULL)
+#define CFLST_NEXT(node) ((node)->next)
+void cflst_init(layer_t **lst);
+#endif				/* CFLST_H_ */
diff --git a/include/net/caif/generic/cfmsll.h b/include/net/caif/generic/cfmsll.h
new file mode 100644
index 0000000..f356b87
--- /dev/null
+++ b/include/net/caif/generic/cfmsll.h
@@ -0,0 +1,22 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFMSLL_H_
+#define CFMSLL_H_
+#include "caif_layer.h"
+#include "cfglue.h"
+layer_t *cfmsll_create(int type, int instance);
+
+#endif				/* CFMSLL_H_ */
diff --git a/include/net/caif/generic/cfmuxl.h b/include/net/caif/generic/cfmuxl.h
new file mode 100644
index 0000000..79c3974
--- /dev/null
+++ b/include/net/caif/generic/cfmuxl.h
@@ -0,0 +1,30 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFMUXL_H_
+#define CFMUXL_H_
+#include "caif_layer.h"
+struct _cfsrvl_t;
+struct _cffrml_t;
+
+layer_t *cfmuxl_create(void);
+bool cfmuxl_set_uplayer(layer_t *layr, layer_t *up, uint8 linkid);
+layer_t *cfmuxl_remove_dnlayer(layer_t *layr, uint8 phyid);
+bool cfmuxl_set_dnlayer(layer_t *layr, layer_t *up, uint8 phyid);
+layer_t *cfmuxl_remove_uplayer(layer_t *layr, uint8 linkid);
+bool cfmuxl_is_phy_inuse(layer_t *layr, uint8 phyid);
+uint8 cfmuxl_get_phyid(layer_t *layr, uint8 channel_id);
+
+#endif				/* CFMUXL_H_ */
diff --git a/include/net/caif/generic/cfpkt.h b/include/net/caif/generic/cfpkt.h
new file mode 100644
index 0000000..0bdfbe7
--- /dev/null
+++ b/include/net/caif/generic/cfpkt.h
@@ -0,0 +1,246 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFPKT_H_
+#define CFPKT_H_
+#include "caif_layer.h"
+
+
+struct _cfpkt_t;
+/*! \addtogroup GenCaifGlue
+ *  Additional documentation for group `GenCaifGlue'
+ *  @{
+ */
+
+/** Checksum iteration function used to iterate buffers
+ * (we may have packets consisting of a chain of buffers)
+ * @param chs Checksum calculated so far.
+ * @param buf pointer to the buffer to checksum
+ * @param len length of buf.
+ * @return checksum of buffer
+ */
+typedef uint16(*iterfunc_t)(uint16 chks, void *buf, uint16 len);
+
+caif_packet_funcs_t caif_get_packet_funcs(void);
+/** Create a Caif packet.
+ * @param len Length of packet to be created
+ * @returns new packet.
+ */
+cfpkt_t *cfpkt_create(uint16 len);
+/**
+ * Destroy a CAIF Packet.
+ * @param pkt Packet to be destoyed.
+ */
+void cfpkt_destroy(cfpkt_t *pkt);
+
+/**
+ * Extract header from packet.
+ *  \image html ExtractCaifPacketHeader.jpg "Extract Caif Packet Header"
+ *
+ * @param pkt Packet to extract header data from.
+ * @param data pointer to copy the header data into.
+ * @param len length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_extr_head(cfpkt_t *pkt, void *data, uint16 len);
+
+/**
+ * Peek header from packet.
+ * Reads data from packet without changing packet.
+ *
+ * @param pkt Packet to extract header data from.
+ * @param data pointer to copy the header data into.
+ * @param len length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_peek_head(cfpkt_t *pkt, void *data, uint16 len);
+
+/**
+ * Extract header from trailer (end of packet).
+ *  \image html ExtractCaifPacketTrailer.jpg "Extract Caif Packet Trailer"
+ *
+ * @param pkt Packet to extract header data from.
+ * @param data pointer to copy the trailer data into.
+ * @param len length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_extr_trail(cfpkt_t *pkt, void *data, uint16 len);
+/**
+ * Add header to packet.
+ *
+ *
+ * @param pkt Packet to add header data to.
+ * @param data pointer to copy into the header.
+ * @param len length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_add_head(cfpkt_t *pkt, const void *data, uint16 len);
+
+/**
+ * Add trailer to packet.
+ *
+ *
+ * @param pkt Packet to add trailer data from.
+ * @param data pointer to copy into the trailer.
+ * @param len length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_add_trail(cfpkt_t *pkt, const void *data, uint16 len);
+
+/**
+ * Pad trailer on packet.
+ * Moves data pointer in packet, no content copied.
+ *
+ * @param pkt Packet to add trailer data from.
+ * @param data pointer to copy into the trailer.
+ * @param len length of head data to copy.
+ * @return \ref true on success \ref false on failure
+ */
+bool cfpkt_pad_trail(cfpkt_t *pkt, uint16 len);
+
+/**
+ * Add a single byte to packet body (tail).
+ */
+
+bool cfpkt_addbdy(cfpkt_t *pkt, const uint8 data);
+
+/**
+ * Add a data to packet body (tail).
+ */
+bool cfpkt_add_body(cfpkt_t *pkt, const void *data, uint16 len);
+
+/**
+ * Checks if there is more data to process in packet.
+ * @param pkt Packet to check.
+ * @return \ref true on if more data is available in packet \ref false if no more data can be extracted
+ */
+bool cfpkt_more(cfpkt_t *pkt);
+/**
+ * Checks if the packet is erroneous, i.e. if it has been attempted to extract more data than available in packet
+ * or writing more data than has been allocated in \ref cfpkt_create().
+ * @param pkt Packet to check.
+ * @return \ref true on error \ref false otherwise
+ */
+bool cfpkt_erroneous(cfpkt_t *pkt);
+
+/**
+ * Get the packet length.
+ * @param pkt Packet to get lenght from.
+ * @return number of bytes in packet.
+ */
+uint16 cfpkt_getlen(cfpkt_t *pkt);
+
+/**
+ * Set the packet length, by adjusting the tailer pointer according to length.
+ * @param pkt Packet to set lenght.
+ * @param len Packet length.
+ * @return number of bytes in packet.
+ */
+int cfpkt_setlen(cfpkt_t *pkt, uint16 len);
+
+/**
+ * Appends a packet's data to another packet.
+ * NB: Input packets will be destroyed after appending and cannot be used
+ * after calling this function.
+ * @param dstpkt Packet to append data into, WILL BE FREED BY THIS FUNCTION
+ * @param addpkt Packet to be appended and automatically released, WILL BE FREED BY THIS FUNCTION.
+ * @param expectlen Packet's expected total length, this should be considered a hint.
+ * @returns the new appended packet.
+ */
+cfpkt_t *cfpkt_append(cfpkt_t *dstpkt, cfpkt_t *addpkt,
+		      uint16 expectlen);
+/**
+ * Split a packet into two packet at the specified split point.
+ * @param pkt Packet to be split
+ * @param pos Position to split packet in two part.
+ */
+cfpkt_t *cfpkt_split(cfpkt_t *pkt, uint16 pos);
+
+/** Iteration function, iterates the packet buffers from start to end*/
+uint16 cfpkt_iterate(cfpkt_t *pkt, iterfunc_t func, uint16 data);
+
+void
+cfpkt_extract(cfpkt_t *cfpkt, void *buf, unsigned int buflen,
+	      unsigned int *actual_len);
+
+/** Append by giving user access to packet buffer
+ * @param pkt Packet to append to
+ * @param buf Buffer inside pkt that user shall copy data into
+ * @param buflen Length of buffer and number of bytes added to packet
+ * @return 0 on error, 1 on success
+ */
+
+int cfpkt_raw_append(cfpkt_t *cfpkt, void **buf, unsigned int buflen);
+
+/** Extract by giving user access to packet buffer
+ * @param pkt Packet to extract from
+ * @param buf Buffer inside pkt that user shall copy data from
+ * @param buflen Length of buffer and number of bytes removed from packet
+ * @return 0 on error, 1 on success
+ */
+int cfpkt_raw_extract(cfpkt_t *cfpkt, void **buf, unsigned int buflen);
+
+
+
+/** Used map from a "native" packet e.g. Linux Socket Buffer to a CAIF packet.
+ *  @param dir - Direction telling if this is an packet to be sent or received.
+ *  @param nativepkt  - The native packet to be transformed to a CAIF packet
+ *  @returns the mapped CAIF Packet CFPKT.
+ */
+cfpkt_t *cfpkt_fromnative(caif_direction_t dir, void *nativepkt);
+
+/** Used map from a CAIF packet to a "native" packet e.g. Linux Socket Buffer.
+ *  @param pkt  - The CAIF packet to be transformed to a "native" packet.
+ *  @returns The native packet transformed from a CAIF packet.
+ */
+void *cfpkt_tonative(cfpkt_t *pkt);
+
+
+caif_packet_funcs_t cfpkt_get_packet_funcs(void);
+
+/**
+ * Insert a packet in the packet queue.
+ * @param pkt Packet to be inserted in queue
+ * @param pktq Packet queue to insert into
+ * @param prio Priority of packet
+ */
+void cfpkt_queue(cfpktq_t *pktq, cfpkt_t *pkt, unsigned short prio);
+
+/**
+ * Remove a packet from the packet queue.
+ * @param pktq Packet queue to fetch packets from.
+ * @returns dequeued packet.
+ */
+cfpkt_t *cfpkt_dequeue(cfpktq_t *pktq);
+
+/**
+ * Peek into a packet from the packet queue.
+ * @param pktq Packet queue to fetch packets from.
+ * @returns peek'ed packet.
+ */
+cfpkt_t *cfpkt_qpeek(cfpktq_t *pktq);
+
+/**
+ * Initiates the packet queue.
+ * @param pktq Packet queue to fetch packets from.
+ */
+cfpktq_t *cfpkt_queuecreate(void);
+
+/** Put content of packet into buffer for debuging purposes */
+char *cfpkt_log_pkt(cfpkt_t *pkt, char *buf, int buflen);
+
+
+/*! @} */
+#endif				/* CFPKT_H_ */
diff --git a/include/net/caif/generic/cfserl.h b/include/net/caif/generic/cfserl.h
new file mode 100644
index 0000000..2ed198d
--- /dev/null
+++ b/include/net/caif/generic/cfserl.h
@@ -0,0 +1,22 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFSERL_H_
+#define CFSERL_H_
+#include "caif_layer.h"
+#include "cfglue.h"
+layer_t *cfserl_create(int type, int instance, bool use_stx);
+
+#endif				/* CFSERL_H_ */
diff --git a/include/net/caif/generic/cfshml.h b/include/net/caif/generic/cfshml.h
new file mode 100644
index 0000000..d7e0247
--- /dev/null
+++ b/include/net/caif/generic/cfshml.h
@@ -0,0 +1,21 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFSHML_H_
+#define CFSHML_H_
+
+layer_t *cfshml_create(int type, int instance);
+
+#endif				/* CFSHML_H_ */
diff --git a/include/net/caif/generic/cfspil.h b/include/net/caif/generic/cfspil.h
new file mode 100644
index 0000000..062d67c
--- /dev/null
+++ b/include/net/caif/generic/cfspil.h
@@ -0,0 +1,80 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFSPIL_H_
+#define CFSPIL_H_
+#include "cfpkt.h"
+#define CAIF_MAX_SPI_FRAME 4096
+
+/* Forward declaration */
+struct _cfspil_t;
+
+typedef struct _cfspil_t cfspil_t;
+
+/** @page SPI PHY Layer description.
+ *
+ *  SPI Physical layer is not implemented in GenCaif. The SPI PHY Layer
+ *  is HW dependent. But the CFSPIL (Caif SPI Layer) provides support for
+ *  implementing the SPI Layer Protocol.
+ *
+ *  SPI PHY uses a different paradigm for transmit than the rest of GenCaif.
+ *  SPI PHY is pulling packets from CFSPIL. The SPI-PHY get a notification
+ *  about a transfer, and then request transfer length, and data to transfer
+ *  in the following way:
+ * \image html caif-spi.jpg "CAIF SPI Flow"
+ *
+ *  -# Wait for transmit request (packet will be \b null pointer) indicating
+ *     GenCaif want something to be sent to the modem.
+ *  -# Request the transfer length by using function \ref cfspil_xmitlen,
+ *  -# Add Caif SPI Command to SPI transfer.
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
+/** SPI-Layer
+ * Create and initializes SPI layer.
+ */
+layer_t *cfspil_create(int type, int instance);
+
+/**
+ *  Check the length of the next SPI frame to send.
+ *  @param layr Pointer to SPI layer
+ *  @return Length of next SPI transfer, 0 if nothink to  send.
+ */
+int cfspil_xmitlen(cfspil_t *layr);
+
+/**
+ *  Get the next CAIF SPI frame to send. This packet is guaranteed to have equal size to the
+ *  length given in \ref cfspil_getxmitpkt.
+ *  @param layr Pointer to SPI layer
+ *  @return The CAIF Packet to be sent.
+ */
+cfpkt_t *cfspil_getxmitpkt(cfspil_t *layr);
+
+/*! @} */
+
+#endif				/* CFSPIL_H_ */
diff --git a/include/net/caif/generic/cfsrvl.h b/include/net/caif/generic/cfsrvl.h
new file mode 100644
index 0000000..0286644
--- /dev/null
+++ b/include/net/caif/generic/cfsrvl.h
@@ -0,0 +1,48 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef CFSRVL_H_
+#define CFSRVL_H_
+#include "cflst.h"
+#include "cfglue.h"
+#include <stddef.h>
+
+
+
+typedef struct _cfsrvl_t {
+	layer_t layer;
+	/** Physical ID of the logical physical connection */
+	uint8 phid;
+	bool open;
+	bool phy_flow_on;
+	bool modem_flow_on;
+} cfsrvl_t;
+
+layer_t *cfvei_create(uint8 linkid, uint8 phyid);
+layer_t *cfdgml_create(uint8 linkid, uint8 phyid);
+
+layer_t *cfutill_create(uint8 linkid, uint8 phyid);
+layer_t *cfvidl_create(uint8 linkid, uint8 phyid);
+layer_t *cfrfml_create(uint8 linkid, uint8 phyid);
+bool cfsrvl_phyid_match(layer_t *layer, int phyid);
+void cfservl_destroy(layer_t *layer);
+
+
+void cfsrvl_init(cfsrvl_t *service, uint8 channel_id, uint8 phyid);
+bool cfsrvl_ready(cfsrvl_t *service, int *err);
+uint8 cfsrvl_getphyid(layer_t *layer);
+
+
+#endif				/* CFSRVL_H_ */
diff --git a/include/net/caif/generic/fcs.h b/include/net/caif/generic/fcs.h
new file mode 100644
index 0000000..0b82e2d
--- /dev/null
+++ b/include/net/caif/generic/fcs.h
@@ -0,0 +1,22 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Sjur Brendeland/sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+
+#ifndef FCS_H_
+#define FCS_H_
+
+uint16
+fcs16(uint16 fcs, uint8 *cp, uint16 len);
+
+#endif				/* FCS_H_ */
-- 
1.6.0.4

