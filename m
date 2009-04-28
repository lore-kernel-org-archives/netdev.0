From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/6] sctp: add feature bit for SCTP offload in
	hardware
Date: Tue, 28 Apr 2009 01:35:52 -0700
Message-ID: <20090428083551.32417.53117.stgit@localhost.localdomain>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:50608
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753662AbZD1IgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:36:12 -0400
In-Reply-To: <20090428083445.32417.77682.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

this is the sctp code to enable hardware crc32c offload for
adapters that support it.

Originally by: Vlad Yasevich <vladislav.yasevich@hp.com>

modified by Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |    2 ++
 net/sctp/output.c         |   17 ++++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3116745..6768861 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -670,7 +670,9 @@ struct net_device
 #define NETIF_F_GRO		16384	/* Generic receive offload */
 #define NETIF_F_LRO		32768	/* large receive offload */
 
+/* the GSO_MASK reserves bits 16 through 23 */
 #define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
+#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 7d08f52..f0c91df 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -412,6 +412,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 
 	/* Build the SCTP header.  */
 	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
+	skb_reset_transport_header(nskb);
 	sh->source = htons(packet->source_port);
 	sh->dest   = htons(packet->destination_port);
 
@@ -527,15 +528,25 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * Note: Adler-32 is no longer applicable, as has been replaced
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
-	if (!sctp_checksum_disable && !(dst->dev->features & NETIF_F_NO_CSUM)) {
+	if (!sctp_checksum_disable &&
+	    !(dst->dev->features & (NETIF_F_NO_CSUM | NETIF_F_SCTP_CSUM))) {
 		__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 
 		/* 3) Put the resultant value into the checksum field in the
 		 *    common header, and leave the rest of the bits unchanged.
 		 */
 		sh->checksum = sctp_end_cksum(crc32);
-	} else
-		nskb->ip_summed = CHECKSUM_UNNECESSARY;
+	} else {
+		if (dst->dev->features & NETIF_F_SCTP_CSUM) {
+			/* no need to seed psuedo checksum for SCTP */
+			nskb->ip_summed = CHECKSUM_PARTIAL;
+			nskb->csum_start = (skb_transport_header(nskb) -
+			                    nskb->head);
+			nskb->csum_offset = offsetof(struct sctphdr, checksum);
+		} else {
+			nskb->ip_summed = CHECKSUM_UNNECESSARY;
+		}
+	}
 
 	/* IP layer ECN support
 	 * From RFC 2481

