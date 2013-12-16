From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: skbuff: improve comment on checksumming
Date: Mon, 16 Dec 2013 23:27:09 +0100
Message-ID: <1387232829-4469-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910Ab3LPW1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 17:27:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be a bit confusing when looking for checksumming flags that
the actual comment for this resides elsewhere further below in the
header file.

Thus, bring the documentation where we define these flags, and
slightly improve the doc text to make it a bit more clear/readable.

Also, whitespace-align values of the define while at it.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/skbuff.h | 131 ++++++++++++++++++++++++++++---------------------
 1 file changed, 75 insertions(+), 56 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 77c7aae..a7cd1fe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -34,11 +34,82 @@
 #include <linux/netdev_features.h>
 #include <net/flow_keys.h>
 
+/* A. Checksumming of received packets by device.
+ *
+ * CHECKSUM_NONE:
+ *
+ *   Device failed to checksum this packet e.g. due to lack of capabilities.
+ *   The packet contains full (though not verified) checksum in packet but
+ *   not in skb->csum. Thus, skb->csum is undefined in this case.
+ *
+ * CHECKSUM_UNNECESSARY:
+ *
+ *   The hardware you're dealing with doesn't calculate the full checksum
+ *   (as in CHECKSUM_COMPLETE), but it does parse headers and verify checksums
+ *   for specific protocols e.g. TCP/UDP/SCTP, then, for such packets it will
+ *   set CHECKSUM_UNNECESSARY if their checksums are okay. skb->csum is still
+ *   undefined in this case though. It is a bad option, but, unfortunately,
+ *   nowadays most vendors do this. Apparently with the secret goal to sell
+ *   you new devices, when you will add new protocol to your host, f.e. IPv6 8)
+ *
+ * CHECKSUM_COMPLETE:
+ *
+ *   This is the most generic way. The device supplied checksum of the _whole_
+ *   packet as seen by netif_rx() and fills out in skb->csum. Meaning, the
+ *   hardware doesn't need to parse L3/L4 headers to implement this.
+ *
+ *   Note: Even if device supports only some protocols, but is able to produce
+ *   skb->csum, it MUST use CHECKSUM_COMPLETE, not CHECKSUM_UNNECESSARY.
+ *
+ * CHECKSUM_PARTIAL:
+ *
+ *   This is identical to the case for output below. This may occur on a packet
+ *   received directly from another Linux OS, e.g., a virtualized Linux kernel
+ *   on the same host. The packet can be treated in the same way as
+ *   CHECKSUM_UNNECESSARY, except that on output (i.e., forwarding) the
+ *   checksum must be filled in by the OS or the hardware.
+ *
+ * B. Checksumming on output.
+ *
+ * CHECKSUM_NONE:
+ *
+ *   The skb was already checksummed by the protocol, or a checksum is not
+ *   required.
+ *
+ * CHECKSUM_PARTIAL:
+ *
+ *   The device is required to checksum the packet as seen by hard_start_xmit()
+ *   from skb->csum_start up to the end, and to record/write the checksum at
+ *   offset skb->csum_start + skb->csum_offset.
+ *
+ *   The device must show its capabilities in dev->features, set up at device
+ *   setup time, e.g. netdev_features.h:
+ *
+ *	NETIF_F_HW_CSUM	- It's a clever device, it's able to checksum everything.
+ *	NETIF_F_IP_CSUM - Device is dumb, it's able to checksum only TCP/UDP over
+ *			  IPv4. Sigh. Vendors like this way for an unknown reason.
+ *			  Though, see comment above about CHECKSUM_UNNECESSARY. 8)
+ *	NETIF_F_IPV6_CSUM - About as dumb as the last one but does IPv6 instead.
+ *	NETIF_F_...     - Well, you get the picture.
+ *
+ * CHECKSUM_UNNECESSARY:
+ *
+ *   Normally, the device will do per protocol specific checksumming. Protocol
+ *   implementations that do not want the NIC to perform the checksum
+ *   calculation should use this flag in their outgoing skbs.
+ *
+ *	NETIF_F_FCOE_CRC - This indicates that the device can do FCoE FC CRC
+ *			   offload. Correspondingly, the FCoE protocol driver
+ *			   stack should use CHECKSUM_UNNECESSARY.
+ *
+ * Any questions? No questions, good.		--ANK
+ */
+
 /* Don't change this without changing skb_csum_unnecessary! */
-#define CHECKSUM_NONE 0
-#define CHECKSUM_UNNECESSARY 1
-#define CHECKSUM_COMPLETE 2
-#define CHECKSUM_PARTIAL 3
+#define CHECKSUM_NONE		0
+#define CHECKSUM_UNNECESSARY	1
+#define CHECKSUM_COMPLETE	2
+#define CHECKSUM_PARTIAL	3
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
@@ -54,58 +125,6 @@
 			 SKB_DATA_ALIGN(sizeof(struct sk_buff)) +	\
 			 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
-/* A. Checksumming of received packets by device.
- *
- *	NONE: device failed to checksum this packet.
- *		skb->csum is undefined.
- *
- *	UNNECESSARY: device parsed packet and wouldbe verified checksum.
- *		skb->csum is undefined.
- *	      It is bad option, but, unfortunately, many of vendors do this.
- *	      Apparently with secret goal to sell you new device, when you
- *	      will add new protocol to your host. F.e. IPv6. 8)
- *
- *	COMPLETE: the most generic way. Device supplied checksum of _all_
- *	    the packet as seen by netif_rx in skb->csum.
- *	    NOTE: Even if device supports only some protocols, but
- *	    is able to produce some skb->csum, it MUST use COMPLETE,
- *	    not UNNECESSARY.
- *
- *	PARTIAL: identical to the case for output below.  This may occur
- *	    on a packet received directly from another Linux OS, e.g.,
- *	    a virtualised Linux kernel on the same host.  The packet can
- *	    be treated in the same way as UNNECESSARY except that on
- *	    output (i.e., forwarding) the checksum must be filled in
- *	    by the OS or the hardware.
- *
- * B. Checksumming on output.
- *
- *	NONE: skb is checksummed by protocol or csum is not required.
- *
- *	PARTIAL: device is required to csum packet as seen by hard_start_xmit
- *	from skb->csum_start to the end and to record the checksum
- *	at skb->csum_start + skb->csum_offset.
- *
- *	Device must show its capabilities in dev->features, set
- *	at device setup time.
- *	NETIF_F_HW_CSUM	- it is clever device, it is able to checksum
- *			  everything.
- *	NETIF_F_IP_CSUM - device is dumb. It is able to csum only
- *			  TCP/UDP over IPv4. Sigh. Vendors like this
- *			  way by an unknown reason. Though, see comment above
- *			  about CHECKSUM_UNNECESSARY. 8)
- *	NETIF_F_IPV6_CSUM about as dumb as the last one but does IPv6 instead.
- *
- *	UNNECESSARY: device will do per protocol specific csum. Protocol drivers
- *	that do not want net to perform the checksum calculation should use
- *	this flag in their outgoing skbs.
- *	NETIF_F_FCOE_CRC  this indicates the device can do FCoE FC CRC
- *			  offload. Correspondingly, the FCoE protocol driver
- *			  stack should use CHECKSUM_UNNECESSARY.
- *
- *	Any questions? No questions, good. 		--ANK
- */
-
 struct net_device;
 struct scatterlist;
 struct pipe_inode_info;
-- 
1.8.3.1
