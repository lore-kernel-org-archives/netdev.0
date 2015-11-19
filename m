From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 08/15] net: Elaborate on checksum offload interface description
Date: Thu, 19 Nov 2015 11:55:54 -0800
Message-ID: <1447962961-2106059-9-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54160 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759286AbbKST4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:17 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJJsEuc022559
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:17 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y8r6u785y-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:17 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 985dd6708ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:16 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add specifics and details the description of the interface between
the stack and drivers for doing checksum offload. This description
is meant to be as specific and complete as possible.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 138 ++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 109 insertions(+), 29 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0713080..a3a7557 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -39,11 +39,55 @@
 #include <linux/in6.h>
 #include <net/flow.h>
 
-/* A. Checksumming of received packets by device.
+/* The interface for checksum offload between the stack and networking drivers
+ * is as follows...
+ *
+ * A. IP checksum related features
+ *
+ * Drivers advertise checksum offload capabilities in the features of a device.
+ * From the stack's point of view these are capabilities offered by the driver,
+ * a driver typically only advertises features that it is capable of offloading
+ * to its device.
+ *
+ * The checksum related features are:
+ *
+ *	NETIF_F_HW_CSUM	- The driver (or its device) is able to compute the
+ *			  IP (one's complement) checksum for any combination
+ *			  of protocols or protocol layering. The checksum is
+ *			  computed and set in a packet per the CHECKSUM_PARTIAL
+ *			  interface (see below).
+ *
+ *	NETIF_F_IP_CSUM - Driver (device) is only able to checksum plain
+ *			  TCP or UDP packets over IPv4. These are specifically
+ *			  unencapsulated packets of the form IPv4|TCP or
+ *			  IPv4|UDP where the Protocol field in the IPv4 header
+ *			  is TCP or UDP. The IPv4 header may contain IP options
+ *			  This feature cannot be set in features for a device
+ *			  with NETIF_F_HW_CSUM also set. This feature is being
+ *			  DEPRECATED (see below).
+ *
+ *	NETIF_F_IPV6_CSUM - Driver (device) is only able to checksum plain
+ *			  TCP or UDP packets over IPv6. These are specifically
+ *			  unencapsulated packets of the form IPv6|TCP or
+ *			  IPv4|UDP where the Next Header field in the IPv6
+ *			  header is either TCP or UDP. IPv6 extension headers
+ *			  are not supported with this feature. This feature
+ *			  cannot be set in features for a device with
+ *			  NETIF_F_HW_CSUM also set. This feature is being
+ *			  DEPRECATED (see below).
+ *
+ *	NETIF_F_RXCSUM - Driver (device) performs receive checksum offload.
+ *			 This flag is used only used to disable the RX checksum
+ *			 feature for a device. The stack will accept receive
+ *			 checksum indication in packets received on a device
+ *			 regardless of whether NETIF_F_RXCSUM is set.
+ *
+ * B. Checksumming of received packets by device. Indication of checksum
+ *    verification is in set skb->ip_summed. Possible values are:
  *
  * CHECKSUM_NONE:
  *
- *   Device failed to checksum this packet e.g. due to lack of capabilities.
+ *   Device did not checksum this packet e.g. due to lack of capabilities.
  *   The packet contains full (though not verified) checksum in packet but
  *   not in skb->csum. Thus, skb->csum is undefined in this case.
  *
@@ -53,9 +97,8 @@
  *   (as in CHECKSUM_COMPLETE), but it does parse headers and verify checksums
  *   for specific protocols. For such packets it will set CHECKSUM_UNNECESSARY
  *   if their checksums are okay. skb->csum is still undefined in this case
- *   though. It is a bad option, but, unfortunately, nowadays most vendors do
- *   this. Apparently with the secret goal to sell you new devices, when you
- *   will add new protocol to your host, f.e. IPv6 8)
+ *   though. A driver or device must never modify the checksum field in the
+ *   packet even if checksum is verified.
  *
  *   CHECKSUM_UNNECESSARY is applicable to following protocols:
  *     TCP: IPv6 and IPv4.
@@ -96,40 +139,77 @@
  *   packet that are after the checksum being offloaded are not considered to
  *   be verified.
  *
- * B. Checksumming on output.
- *
- * CHECKSUM_NONE:
- *
- *   The skb was already checksummed by the protocol, or a checksum is not
- *   required.
+ * C. Checksumming on transmit for non-GSO. The stack requests checksum offload
+ *    in the skb->ip_summed for a packet. Values are:
  *
  * CHECKSUM_PARTIAL:
  *
- *   The device is required to checksum the packet as seen by hard_start_xmit()
+ *   The driver is required to checksum the packet as seen by hard_start_xmit()
  *   from skb->csum_start up to the end, and to record/write the checksum at
- *   offset skb->csum_start + skb->csum_offset.
+ *   offset skb->csum_start + skb->csum_offset. A driver may verify that the
+ *   csum_start and csum_offset values are valid values given the length and
+ *   offset of the packet, however they should not attempt to validate that the
+ *   checksum refers to a legitimate transport layer checksum-- it is the
+ *   purview of the stack to validate that csum_start and csum_offset are set
+ *   correctly.
+ *
+ *   When the stack requests checksum offload for a packet, the driver MUST
+ *   ensure that the checksum is set correctly. A driver can either offload the
+ *   checksum calculation to the device, or call skb_checksum_help (in the case
+ *   that the device does not support offload for a particular checksum).
+ *
+ *   NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM are being deprecated in favor of
+ *   NETIF_F_HW_CSUM. New devices should use NETIF_F_HW_CSUM to indicate
+ *   checksum offload capability. If a	device has limited checksum capabilities
+ *   (for instance can only perform NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM as
+ *   described above) a helper function can be called to resolve
+ *   CHECKSUM_PARTIAL. The helper functions are skb_csum_off_chk*. The helper
+ *   function takes a spec argument that describes the protocol layer that is
+ *   supported for checksum offload and can be called for each packet. If a
+ *   packet does not match the specification for offload, skb_checksum_help
+ *   is called to resolve the checksum.
  *
- *   The device must show its capabilities in dev->features, set up at device
- *   setup time, e.g. netdev_features.h:
+ * CHECKSUM_NONE:
  *
- *	NETIF_F_HW_CSUM	- It's a clever device, it's able to checksum everything.
- *	NETIF_F_IP_CSUM - Device is dumb, it's able to checksum only TCP/UDP over
- *			  IPv4. Sigh. Vendors like this way for an unknown reason.
- *			  Though, see comment above about CHECKSUM_UNNECESSARY. 8)
- *	NETIF_F_IPV6_CSUM - About as dumb as the last one but does IPv6 instead.
- *	NETIF_F_...     - Well, you get the picture.
+ *   The skb was already checksummed by the protocol, or a checksum is not
+ *   required.
  *
  * CHECKSUM_UNNECESSARY:
  *
- *   Normally, the device will do per protocol specific checksumming. Protocol
- *   implementations that do not want the NIC to perform the checksum
- *   calculation should use this flag in their outgoing skbs.
+ *   This has the same meaning on as CHECKSUM_NONE for checksum offload on
+ *   output.
  *
- *	NETIF_F_FCOE_CRC - This indicates that the device can do FCoE FC CRC
- *			   offload. Correspondingly, the FCoE protocol driver
- *			   stack should use CHECKSUM_UNNECESSARY.
- *
- * Any questions? No questions, good.		--ANK
+ * CHECKSUM_COMPLETE:
+ *   Not used in checksum output. If a driver observes a packet with this value
+ *   set in skbuff, if should treat as CHECKSUM_NONE being set.
+ *
+ * D. Non-IP checksum (CRC) offloads
+ *
+ *   NETIF_F_SCTP_CRC - This feature indicates that a device is capable of
+ *     offloading the SCTP CRC in a packet. To perform this offload the stack
+ *     will set ip_summed to CHECKSUM_PARTIAL and set csum_start and csum_offset
+ *     accordingly. Note the there is no indication in the skbuff that the
+ *     CHECKSUM_PARTIAL refers to an SCTP checksum, a driver that supports
+ *     both IP checksum offload and SCTP CRC offload must verify which offload
+ *     is configured for a packet presumably by inspecting packet headers.
+ *
+ *   NETIF_F_FCOE_CRC - This feature indicates that a device is capable of
+ *     offloading the FCOE CRC in a packet. To perform this offload the stack
+ *     will set ip_summed to CHECKSUM_PARTIAL and set csum_start and csum_offset
+ *     accordingly. Note the there is no indication in the skbuff that the
+ *     CHECKSUM_PARTIAL refers to an FCOE checksum, a driver that supports
+ *     both IP checksum offload and FCOE CRC offload must verify which offload
+ *     is configured for a packet presumably by inspecting packet headers.
+ *
+ * E. Checksumming on output with GSO.
+ *
+ * In the case of a GSO packet (skb_is_gso(skb) is true), checksum offload
+ * is implied by the SKB_GSO_* flags in gso_type. Most obviously, if the
+ * gso_type is SKB_GSO_TCPV4 or SKB_GSO_TCPV6, TCP checksum offload as
+ * part of the GSO operation is implied. If a checksum is being offloaded
+ * with GSO then ip_summed is CHECKSUM_PARTIAL, csum_start and csum_offset
+ * are set to refer to the outermost checksum being offload (two offloaded
+ * checksums are possible with UDP encapsulation).
  */
 
 /* Don't change this without changing skb_csum_unnecessary! */
-- 
2.4.6
