From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 1/8] xen-netback: re-import canonical netif header
Date: Wed, 21 Oct 2015 11:36:18 +0100
Message-ID: <1445423785-4654-2-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:45975 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348AbbJUKhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 06:37:02 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The canonical netif header (in the Xen source repo) and the Linux variant
have diverged significantly. Recently much documentation has been added to
the canonical header and new definitions and types to support packet hash
configuration. Subsequent patches in this series add support for packet
hash configuration in xen-netback so this patch re-imports the canonical
header in readiness.

To maintain compatibility and some style consistency with the old Linux
variant, the header was stripped of its emacs boilerplate, and
post-processed and copied into place with the following commands:

ed -s netif.h << EOF
H
,s/NETTXF_/XEN_NETTXF_/g
,s/NETRXF_/XEN_NETRXF_/g
,s/NETIF_RSP/XEN_NETIF_RSP/g
,s/netif_tx/xen_netif_tx/g
,s/netif_rx/xen_netif_rx/g
,s/netif_extra_info/xen_netif_extra_info/g
w
EOF

indent --linux-style netif.h -o include/xen/interface/io/netif.h

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---

Whilst awaiting review of my patches to the canonical netif.h, import has
been done from my staging branch using:

wget http://xenbits.xen.org/gitweb/?p=people/pauldu/xen.git;a=blob_plain;f=xen/include/public/io/netif.h;hb=refs/heads/netif
---
 include/xen/interface/io/netif.h | 475 +++++++++++++++++++++++++++++++--------
 1 file changed, 381 insertions(+), 94 deletions(-)

diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index 252ffd4..832dc37 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -3,14 +3,32 @@
  *
  * Unified network-device I/O interface for Xen guest OSes.
  *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this software and associated documentation files (the "Software"), to
+ * deal in the Software without restriction, including without limitation the
+ * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
+ * sell copies of the Software, and to permit persons to whom the Software is
+ * furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
+ * DEALINGS IN THE SOFTWARE.
+ *
  * Copyright (c) 2003-2004, Keir Fraser
  */
 
 #ifndef __XEN_PUBLIC_IO_NETIF_H__
 #define __XEN_PUBLIC_IO_NETIF_H__
 
-#include <xen/interface/io/ring.h>
-#include <xen/interface/grant_table.h>
+#include "ring.h"
+#include "../grant_table.h"
 
 /*
  * Older implementation of Xen network frontend / backend has an
@@ -38,10 +56,10 @@
  * that it cannot safely queue packets (as it may not be kicked to send them).
  */
 
- /*
+/*
  * "feature-split-event-channels" is introduced to separate guest TX
- * and RX notificaion. Backend either doesn't support this feature or
- * advertise it via xenstore as 0 (disabled) or 1 (enabled).
+ * and RX notification. Backend either doesn't support this feature or
+ * advertises it via xenstore as 0 (disabled) or 1 (enabled).
  *
  * To make use of this feature, frontend should allocate two event
  * channels for TX and RX, advertise them to backend as
@@ -96,11 +114,112 @@
  * error. This includes scenarios where more (or fewer) queues were
  * requested than the frontend provided details for.
  *
- * Mapping of packets to queues is considered to be a function of the
- * transmitting system (backend or frontend) and is not negotiated
- * between the two. Guests are free to transmit packets on any queue
- * they choose, provided it has been set up correctly. Guests must be
- * prepared to receive packets on any queue they have requested be set up.
+ * Unless a hash algorithm or mapping of packet hash to queues has been
+ * negotiated (see below), queue selection is considered to be a function of
+ * the transmitting system (backend or frontend) and either end is free to
+ * transmit packets on any queue, provided it has been set up correctly.
+ * Guests must therefore be prepared to receive packets on any queue they
+ * have requested be set up.
+ */
+
+/*
+ * Hash negotiation (only applicable if using multiple queues):
+ *
+ * A backend can advertise a set of hash algorithms that it can perform by
+ * naming it in a space separated list in the "multi-queue-hash-list"
+ * xenstore key. For example, if the backend supports the 'foo' and 'bar'
+ * algorithms it would set:
+ *
+ * /local/domain/X/backend/vif/Y/Z/multi-queue-hash-list = "foo bar"
+ *
+ * Additionally, in supporting a particular algorithm, it may be necessary
+ * for the backend to specify the capabilities of its implementation of
+ * that algorithm, e.g. what sections of packet header it can hash.
+ * To do that it can set algorithm-specific keys under a parent capabilities
+ * key. For example, if the 'bar' algorithm implementation in the backend
+ * is capable of hashing over an IP version 4 header and a TCP header, the
+ * backend might set:
+ *
+ * /local/domain/X/backend/vif/Y/Z/multi-queue-hash-caps-bar/types = "ipv4+tcp"
+ *
+ * The backend should set all such keys before it moves into the initwait
+ * state.
+ *
+ * The frontend can select a hash algorithm at any time after it moves into
+ * the connected state by setting the "multi-queue-hash" key. The backend
+ * must therefore watch this key and be prepared to change hash algorithms
+ * at any time whilst in the connected state. So, for example, if the
+ * frontend wants 'foo' hashing, it should set:
+ *
+ * /local/domain/Y/device/vif/Z/multi-queue-hash = "foo"
+ *
+ * Additionally it may set parameters for that algorithm by setting
+ * algorithm-specific keys under a parent parameters key. For example, if
+ * the 'foo' algorithm implementation in the backend is capable of hashing
+ * over an IP version 4 header, a TCP header or both but the frontend only
+ * wants it to hash over only the IP version 4 header then it might set:
+ *
+ * /local/domain/Y/device/vif/Z/multi-queue-hash-params-foo/types = "ipv4"
+ *
+ * The backend must also watch the parameters key as the frontend may
+ * change the parameters at any time whilst in the connected state.
+ *
+ * (Capabilities and parameters documentation for specific algorithms is
+ * below).
+ *
+ * TOEPLITZ:
+ *
+ * If the backend supports Toeplitz hashing then it should include
+ * the algorithm name 'toeplitz' in its "multi-queue-hash-list" key.
+ * It should also advertise the following capabilities:
+ *
+ * types: a space separated list containing any or all of 'ipv4', 'tcpv4',
+ *        'ipv6', 'tcpv6', indicating over which headers the hash algorithm
+ *        is capable of being performed.
+ *
+ * max-key-length: an integer value indicating the maximum key length (in
+ *                 octets) that the frontend may supply.
+ *
+ * Upon selecting this algorithm, the frontend may supply the following
+ * parameters.
+ *
+ * types: a space separated list containing none, any or all of the type
+ *        names included in the types list in the capabilities.
+ *        When the backend encounters a packet type not in this list it
+ *        will assign a hash value of 0.
+ *
+ * key: a ':' separated list of octets (up to the maximum length specified
+ *      in the capabilities) expressed in hexadecimal indicating the key
+ *      that should be used in the hash calculation.
+ *
+ * For more information on Toeplitz hash calculation see:
+ *
+ * https://msdn.microsoft.com/en-us/library/windows/hardware/ff570725.aspx
+ */
+
+/*
+ * Hash mapping (only applicable if using multiple queues):
+ *
+ * If the backend is not capable, or no mapping is specified by the frontend
+ * then it is assumed that the hash -> queue mapping is done by simple
+ * modular arithmetic.
+ *
+ * To advertise that it is capable of accepting a specific mapping from the
+ * frontend the backend should set the "multi-queue-max-hash-mapping-length"
+ * key to a non-zero value. The frontend may then specify a mapping (up to
+ * the maximum specified length) as a ',' separated list of decimal queue
+ * numbers in the "multi-queue-hash-mapping" key.
+ *
+ * The backend should parse this list into an array and perform the mapping
+ * as follows:
+ *
+ * queue = mapping[hash % length-of-list]
+ *
+ * If any of the queue values specified in the list is not connected then
+ * the backend is free to choose a connected queue arbitrarily.
+ *
+ * The backend must be prepared to handle updates the mapping list at any
+ * time whilst in the connected state.
  */
 
 /*
@@ -118,151 +237,319 @@
  */
 
 /*
+ * "feature-multicast-control" advertises the capability to filter ethernet
+ * multicast packets in the backend. To enable use of this capability the
+ * frontend must set "request-multicast-control" before moving into the
+ * connected state.
+ *
+ * If "request-multicast-control" is set then the backend transmit side should
+ * no longer flood multicast packets to the frontend, it should instead drop any
+ * multicast packet that does not match in a filter list. The list is
+ * amended by the frontend by sending dummy transmit requests containing
+ * XEN_NETIF_EXTRA_TYPE_MCAST_{ADD,DEL} extra-info fragments as specified below.
+ * Once enabled by the frontend, the feature cannot be disabled except by
+ * closing and re-connecting to the backend.
+ */
+
+/*
+ * "feature-hash" advertises the capability to accept extra info slots of
+ * type XEN_NETIF_EXTRA_TYPE_HASH. They will not be sent by either end
+ * unless the other end advertises this feature.
+ */
+
+/*
  * This is the 'wire' format for packets:
- *  Request 1: xen_netif_tx_request  -- XEN_NETTXF_* (any flags)
- * [Request 2: xen_netif_extra_info]    (only if request 1 has XEN_NETTXF_extra_info)
- * [Request 3: xen_netif_extra_info]    (only if request 2 has XEN_NETIF_EXTRA_MORE)
- *  Request 4: xen_netif_tx_request  -- XEN_NETTXF_more_data
- *  Request 5: xen_netif_tx_request  -- XEN_NETTXF_more_data
+ *  Request 1: xen_netif_tx_request_t -- XEN_NETTXF_* (any flags)
+ * [Request 2: xen_netif_extra_info_t] (only if request 1 has
+ *                                  XEN_NETTXF_extra_info)
+ * [Request 3: xen_netif_extra_info_t] (only if request 2 has
+ *                                  XEN_NETIF_EXTRA_MORE)
+ *  Request 4: xen_netif_tx_request_t -- XEN_NETTXF_more_data
+ *  Request 5: xen_netif_tx_request_t -- XEN_NETTXF_more_data
  *  ...
- *  Request N: xen_netif_tx_request  -- 0
+ *  Request N: xen_netif_tx_request_t -- 0
+ */
+
+/*
+ * Guest transmit
+ * ==============
+ *
+ * Ring slot size is 12 octets, however not all request/response
+ * structs use the full size.
+ *
+ * tx request data (xen_netif_tx_request_t)
+ * ------------------------------------
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * | grant ref             | offset    | flags     |
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * | id        | size      |
+ * +-----+-----+-----+-----+
+ *
+ * grant ref: Reference to buffer page.
+ * offset: Offset within buffer page.
+ * flags: XEN_NETTXF_*.
+ * id: request identifier, echoed in response.
+ * size: packet size in bytes.
+ *
+ * tx response (xen_netif_tx_response_t)
+ * ---------------------------------
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * | id        | status    | unused                |
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * | unused                |
+ * +-----+-----+-----+-----+
+ *
+ * id: reflects id in transmit request
+ * status: XEN_NETIF_RSP_*
+ *
+ * Guest receive
+ * =============
+ *
+ * Ring slot size is 8 octets.
+ *
+ * rx request (xen_netif_rx_request_t)
+ * -------------------------------
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * | id        | pad       | gref                  |
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ *
+ * id: request identifier, echoed in response.
+ * gref: reference to incoming granted frame.
+ *
+ * rx response (xen_netif_rx_response_t)
+ * ---------------------------------
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * | id        | offset    | flags     | status    |
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ *
+ * id: reflects id in receive request
+ * offset: offset in page of start of received packet
+ * flags: XEN_NETRXF_*
+ * status: -ve: XEN_NETIF_RSP_*; +ve: Rx'ed pkt size.
+ *
+ * NOTE: Historically, to support GSO on the frontend receive side, Linux
+ *       netfront does not make use of the rx response id (because, as
+ *       described below, extra info structures overlay the id field).
+ *       Instead it assumes that responses always appear in the same ring
+ *       slot as their corresponding request. Thus, to maintain
+ *       compatibility, backends must make sure this is the case.
+ *
+ * Extra Info
+ * ==========
+ *
+ * Can be present if initial request or response has NET{T,R}XF_extra_info,
+ * or previous extra request has XEN_NETIF_EXTRA_MORE.
+ *
+ * The struct therefore needs to fit into either a tx or rx slot and
+ * is therefore limited to 8 octets.
+ *
+ * NOTE: Because extra info data overlays the usual request/response
+ *       structures, there is no id information in the opposite direction.
+ *       So, if an extra info overlays an rx response the frontend can
+ *       assume that it is in the same ring slot as the request that was
+ *       consumed to make the slot available, and the backend must ensure
+ *       this assumption is true.
+ *
+ * extra info (xen_netif_extra_info_t)
+ * -------------------------------
+ *
+ * General format:
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * |type |flags| type specific data                |
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * | padding for tx        |
+ * +-----+-----+-----+-----+
+ *
+ * type: XEN_NETIF_EXTRA_TYPE_*
+ * flags: XEN_NETIF_EXTRA_FLAG_*
+ * padding for tx: present only in the tx case due to 8 octet limit
+ *                 from rx case. Not shown in type specific entries
+ *                 below.
+ *
+ * XEN_NETIF_EXTRA_TYPE_GSO:
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * |type |flags| size      |type | pad | features  |
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ *
+ * type: Must be XEN_NETIF_EXTRA_TYPE_GSO
+ * flags: XEN_NETIF_EXTRA_FLAG_*
+ * size: Maximum payload size of each segment. For example,
+ *       for TCP this is just the path MSS.
+ * type: XEN_NETIF_GSO_TYPE_*: This determines the protocol of
+ *       the packet and any extra features required to segment the
+ *       packet properly.
+ * features: EN_NETIF_GSO_FEAT_*: This specifies any extra GSO
+ *           features required to process this packet, such as ECN
+ *           support for TCPv4.
+ *
+ * XEN_NETIF_EXTRA_TYPE_MCAST_{ADD,DEL}:
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * |type |flags| addr                              |
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ *
+ * type: Must be XEN_NETIF_EXTRA_TYPE_MCAST_{ADD,DEL}
+ * flags: XEN_NETIF_EXTRA_FLAG_*
+ * addr: address to add/remove
+ *
+ * XEN_NETIF_EXTRA_TYPE_HASH:
+ *
+ *    0     1     2     3     4     5     6     7  octet
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ * |type |flags|htype| pad |LSB ---- value ---- MSB|
+ * +-----+-----+-----+-----+-----+-----+-----+-----+
+ *
+ * type: Must be XEN_NETIF_EXTRA_TYPE_HASH
+ * flags: XEN_NETIF_EXTRA_FLAG_*
+ * htype: XEN_NETIF_HASH_TYPE_*
+ * value: Hash value
  */
 
 /* Protocol checksum field is blank in the packet (hardware offload)? */
-#define _XEN_NETTXF_csum_blank		(0)
-#define  XEN_NETTXF_csum_blank		(1U<<_XEN_NETTXF_csum_blank)
+#define _XEN_NETTXF_csum_blank     (0)
+#define  XEN_NETTXF_csum_blank     (1U<<_XEN_NETTXF_csum_blank)
 
 /* Packet data has been validated against protocol checksum. */
-#define _XEN_NETTXF_data_validated	(1)
-#define  XEN_NETTXF_data_validated	(1U<<_XEN_NETTXF_data_validated)
+#define _XEN_NETTXF_data_validated (1)
+#define  XEN_NETTXF_data_validated (1U<<_XEN_NETTXF_data_validated)
 
 /* Packet continues in the next request descriptor. */
-#define _XEN_NETTXF_more_data		(2)
-#define  XEN_NETTXF_more_data		(1U<<_XEN_NETTXF_more_data)
+#define _XEN_NETTXF_more_data      (2)
+#define  XEN_NETTXF_more_data      (1U<<_XEN_NETTXF_more_data)
 
 /* Packet to be followed by extra descriptor(s). */
-#define _XEN_NETTXF_extra_info		(3)
-#define  XEN_NETTXF_extra_info		(1U<<_XEN_NETTXF_extra_info)
+#define _XEN_NETTXF_extra_info     (3)
+#define  XEN_NETTXF_extra_info     (1U<<_XEN_NETTXF_extra_info)
 
 #define XEN_NETIF_MAX_TX_SIZE 0xFFFF
 struct xen_netif_tx_request {
-    grant_ref_t gref;      /* Reference to buffer page */
-    uint16_t offset;       /* Offset within buffer page */
-    uint16_t flags;        /* XEN_NETTXF_* */
-    uint16_t id;           /* Echoed in response message. */
-    uint16_t size;         /* Packet size in bytes.       */
+	grant_ref_t gref;
+	uint16_t offset;
+	uint16_t flags;
+	uint16_t id;
+	uint16_t size;
 };
+typedef struct xen_netif_tx_request xen_netif_tx_request_t;
 
 /* Types of xen_netif_extra_info descriptors. */
-#define XEN_NETIF_EXTRA_TYPE_NONE	(0)  /* Never used - invalid */
-#define XEN_NETIF_EXTRA_TYPE_GSO	(1)  /* u.gso */
-#define XEN_NETIF_EXTRA_TYPE_MCAST_ADD	(2)  /* u.mcast */
-#define XEN_NETIF_EXTRA_TYPE_MCAST_DEL	(3)  /* u.mcast */
-#define XEN_NETIF_EXTRA_TYPE_MAX	(4)
+#define XEN_NETIF_EXTRA_TYPE_NONE       (0)	/* Never used - invalid */
+#define XEN_NETIF_EXTRA_TYPE_GSO        (1)	/* u.gso */
+#define XEN_NETIF_EXTRA_TYPE_MCAST_ADD  (2)	/* u.mcast */
+#define XEN_NETIF_EXTRA_TYPE_MCAST_DEL  (3)	/* u.mcast */
+#define XEN_NETIF_EXTRA_TYPE_HASH       (4)	/* u.hash */
+#define XEN_NETIF_EXTRA_TYPE_MAX        (5)
 
-/* xen_netif_extra_info flags. */
-#define _XEN_NETIF_EXTRA_FLAG_MORE	(0)
-#define  XEN_NETIF_EXTRA_FLAG_MORE	(1U<<_XEN_NETIF_EXTRA_FLAG_MORE)
+/* xen_netif_extra_info_t flags. */
+#define _XEN_NETIF_EXTRA_FLAG_MORE (0)
+#define XEN_NETIF_EXTRA_FLAG_MORE  (1U<<_XEN_NETIF_EXTRA_FLAG_MORE)
 
 /* GSO types */
-#define XEN_NETIF_GSO_TYPE_NONE		(0)
-#define XEN_NETIF_GSO_TYPE_TCPV4	(1)
-#define XEN_NETIF_GSO_TYPE_TCPV6	(2)
+#define XEN_NETIF_GSO_TYPE_NONE         (0)
+#define XEN_NETIF_GSO_TYPE_TCPV4        (1)
+#define XEN_NETIF_GSO_TYPE_TCPV6        (2)
+
+/* Hash types */
+#define XEN_NETIF_HASH_TYPE_NONE        (0)
+#define XEN_NETIF_HASH_TYPE_TCPV4       (1)
+#define XEN_NETIF_HASH_TYPE_IPV4        (2)
+#define XEN_NETIF_HASH_TYPE_TCPV6       (3)
+#define XEN_NETIF_HASH_TYPE_IPV6        (4)
 
 /*
- * This structure needs to fit within both netif_tx_request and
- * netif_rx_response for compatibility.
+ * This structure needs to fit within both xen_netif_tx_request_t and
+ * xen_netif_rx_response_t for compatibility.
  */
 struct xen_netif_extra_info {
-	uint8_t type;  /* XEN_NETIF_EXTRA_TYPE_* */
-	uint8_t flags; /* XEN_NETIF_EXTRA_FLAG_* */
-
+	uint8_t type;
+	uint8_t flags;
 	union {
 		struct {
-			/*
-			 * Maximum payload size of each segment. For
-			 * example, for TCP this is just the path MSS.
-			 */
 			uint16_t size;
-
-			/*
-			 * GSO type. This determines the protocol of
-			 * the packet and any extra features required
-			 * to segment the packet properly.
-			 */
-			uint8_t type; /* XEN_NETIF_GSO_TYPE_* */
-
-			/* Future expansion. */
+			uint8_t type;
 			uint8_t pad;
-
-			/*
-			 * GSO features. This specifies any extra GSO
-			 * features required to process this packet,
-			 * such as ECN support for TCPv4.
-			 */
-			uint16_t features; /* XEN_NETIF_GSO_FEAT_* */
+			uint16_t features;
 		} gso;
-
 		struct {
-			uint8_t addr[6]; /* Address to add/remove. */
+			uint8_t addr[6];
 		} mcast;
+		struct {
+			uint8_t type;
+			uint8_t pad;
+			uint8_t value[4];
+		} hash;
 
 		uint16_t pad[3];
 	} u;
 };
+typedef struct xen_netif_extra_info xen_netif_extra_info_t;
 
 struct xen_netif_tx_response {
 	uint16_t id;
-	int16_t  status;       /* XEN_NETIF_RSP_* */
+	int16_t status;
 };
+typedef struct xen_netif_tx_response xen_netif_tx_response_t;
 
 struct xen_netif_rx_request {
-	uint16_t    id;        /* Echoed in response message.        */
-	grant_ref_t gref;      /* Reference to incoming granted frame */
+	uint16_t id;
+	uint16_t pad;
+	grant_ref_t gref;
 };
+typedef struct xen_netif_rx_request xen_netif_rx_request_t;
 
 /* Packet data has been validated against protocol checksum. */
-#define _XEN_NETRXF_data_validated	(0)
-#define  XEN_NETRXF_data_validated	(1U<<_XEN_NETRXF_data_validated)
+#define _XEN_NETRXF_data_validated (0)
+#define  XEN_NETRXF_data_validated (1U<<_XEN_NETRXF_data_validated)
 
 /* Protocol checksum field is blank in the packet (hardware offload)? */
-#define _XEN_NETRXF_csum_blank		(1)
-#define  XEN_NETRXF_csum_blank		(1U<<_XEN_NETRXF_csum_blank)
+#define _XEN_NETRXF_csum_blank     (1)
+#define  XEN_NETRXF_csum_blank     (1U<<_XEN_NETRXF_csum_blank)
 
 /* Packet continues in the next request descriptor. */
-#define _XEN_NETRXF_more_data		(2)
-#define  XEN_NETRXF_more_data		(1U<<_XEN_NETRXF_more_data)
+#define _XEN_NETRXF_more_data      (2)
+#define  XEN_NETRXF_more_data      (1U<<_XEN_NETRXF_more_data)
 
 /* Packet to be followed by extra descriptor(s). */
-#define _XEN_NETRXF_extra_info		(3)
-#define  XEN_NETRXF_extra_info		(1U<<_XEN_NETRXF_extra_info)
+#define _XEN_NETRXF_extra_info     (3)
+#define  XEN_NETRXF_extra_info     (1U<<_XEN_NETRXF_extra_info)
 
-/* GSO Prefix descriptor. */
-#define _XEN_NETRXF_gso_prefix		(4)
-#define  XEN_NETRXF_gso_prefix		(1U<<_XEN_NETRXF_gso_prefix)
+/* Packet has GSO prefix. Deprecated but included for compatibility */
+#define _XEN_NETRXF_gso_prefix     (4)
+#define  XEN_NETRXF_gso_prefix     (1U<<_XEN_NETRXF_gso_prefix)
 
 struct xen_netif_rx_response {
-    uint16_t id;
-    uint16_t offset;       /* Offset in page of start of received packet  */
-    uint16_t flags;        /* XEN_NETRXF_* */
-    int16_t  status;       /* -ve: BLKIF_RSP_* ; +ve: Rx'ed pkt size. */
+	uint16_t id;
+	uint16_t offset;
+	uint16_t flags;
+	int16_t status;
 };
+typedef struct xen_netif_rx_response xen_netif_rx_response_t;
 
 /*
  * Generate netif ring structures and types.
  */
 
-DEFINE_RING_TYPES(xen_netif_tx,
-		  struct xen_netif_tx_request,
+DEFINE_RING_TYPES(xen_netif_tx, struct xen_netif_tx_request,
 		  struct xen_netif_tx_response);
-DEFINE_RING_TYPES(xen_netif_rx,
-		  struct xen_netif_rx_request,
+DEFINE_RING_TYPES(xen_netif_rx, struct xen_netif_rx_request,
 		  struct xen_netif_rx_response);
 
-#define XEN_NETIF_RSP_DROPPED	-2
-#define XEN_NETIF_RSP_ERROR	-1
-#define XEN_NETIF_RSP_OKAY	 0
-/* No response: used for auxiliary requests (e.g., xen_netif_extra_info). */
-#define XEN_NETIF_RSP_NULL	 1
+#define XEN_NETIF_RSP_DROPPED         -2
+#define XEN_NETIF_RSP_ERROR           -1
+#define XEN_NETIF_RSP_OKAY             0
+/* No response: used for auxiliary requests (e.g., xen_netif_extra_info_t). */
+#define XEN_NETIF_RSP_NULL             1
 
 #endif
-- 
2.1.4
