From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next PATCH 1/5] enic: Bug Fix: Fix hardware descriptor reads
Date: Thu, 18 Mar 2010 19:19:44 -0700
Message-ID: <20100319021943.10527.93124.stgit@savbu-pc100.cisco.com>
References: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:42758 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab0CSCTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 22:19:45 -0400
In-Reply-To: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

The last bit written to a completion descriptor by hardware is the color
bit. Driver must read all other descriptor fields only after reading the
color bit to avoid reading stale descriptor fields.  There is a rmb() after
reading the color bit to avoid any compiler/cpu reordering of the reads.
The color bit is the generation bit that toggles each pass through the
completion descriptor ring.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/cq_enet_desc.h |   12 ++++++++----
 drivers/net/enic/enic.h         |    2 +-
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/enic/cq_enet_desc.h b/drivers/net/enic/cq_enet_desc.h
index 03dce9e..337d194 100644
--- a/drivers/net/enic/cq_enet_desc.h
+++ b/drivers/net/enic/cq_enet_desc.h
@@ -101,14 +101,18 @@ static inline void cq_enet_rq_desc_dec(struct cq_enet_rq_desc *desc,
 	u8 *tcp_udp_csum_ok, u8 *udp, u8 *tcp, u8 *ipv4_csum_ok,
 	u8 *ipv6, u8 *ipv4, u8 *ipv4_fragment, u8 *fcs_ok)
 {
-	u16 completed_index_flags = le16_to_cpu(desc->completed_index_flags);
-	u16 q_number_rss_type_flags =
-		le16_to_cpu(desc->q_number_rss_type_flags);
-	u16 bytes_written_flags = le16_to_cpu(desc->bytes_written_flags);
+	u16 completed_index_flags;
+	u16 q_number_rss_type_flags;
+	u16 bytes_written_flags;
 
 	cq_desc_dec((struct cq_desc *)desc, type,
 		color, q_number, completed_index);
 
+	completed_index_flags = le16_to_cpu(desc->completed_index_flags);
+	q_number_rss_type_flags =
+		le16_to_cpu(desc->q_number_rss_type_flags);
+	bytes_written_flags = le16_to_cpu(desc->bytes_written_flags);
+
 	*ingress_port = (completed_index_flags &
 		CQ_ENET_RQ_DESC_FLAGS_INGRESS_PORT) ? 1 : 0;
 	*fcoe = (completed_index_flags & CQ_ENET_RQ_DESC_FLAGS_FCOE) ?
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index ee01f5a..9f5ed3e 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -34,7 +34,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
-#define DRV_VERSION		"1.1.0.241a"
+#define DRV_VERSION		"1.3.1.1"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 

