From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/8] net: Clarification of CHECKSUM_UNNECESSARY
Date: Mon, 25 Aug 2014 17:55:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408251738110.5541@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:37529 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:55:57 -0400
Received: by mail-pd0-f201.google.com with SMTP id g10so3790438pdj.0
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 17:55:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
 - Clarifies the specific requirements of devices returning
   CHECKSUM_UNNECESSARY (comments in skbuff.h).
 - Adds csum_level field to skbuff. This is used to express how
   many checksums are covered by CHECKSUM_UNNECESSARY (stores n - 1).
   This replaces the overloading of skb->encapsulation, that field is
   is now only used to indicate inner headers are valid.
 - Change __skb_checksum_validate_needed to "consume" each checksum
   as indicated by csum_level as layers of the the packet are parsed.
 - Remove skb_pop_rcv_encapsulation, no longer needed in the new
   csum_level model.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c    |  2 --
 include/linux/skbuff.h | 74 ++++++++++++++++++++++++++++++++++----------------
 net/ipv4/gre_demux.c   |  1 -
 3 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index beb377b..67527f3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1158,8 +1158,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!vs)
 		goto drop;
 
-	skb_pop_rcv_encapsulation(skb);
-
 	vs->rcv(vs, skb, vxh->vx_vni);
 	return 0;
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 18ddf96..fb5dafa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -47,11 +47,29 @@
  *
  *   The hardware you're dealing with doesn't calculate the full checksum
  *   (as in CHECKSUM_COMPLETE), but it does parse headers and verify checksums
- *   for specific protocols e.g. TCP/UDP/SCTP, then, for such packets it will
- *   set CHECKSUM_UNNECESSARY if their checksums are okay. skb->csum is still
- *   undefined in this case though. It is a bad option, but, unfortunately,
- *   nowadays most vendors do this. Apparently with the secret goal to sell
- *   you new devices, when you will add new protocol to your host, f.e. IPv6 8)
+ *   for specific protocols. For such packets it will set CHECKSUM_UNNECESSARY
+ *   if their checksums are okay. skb->csum is still undefined in this case
+ *   though. It is a bad option, but, unfortunately, nowadays most vendors do
+ *   this. Apparently with the secret goal to sell you new devices, when you
+ *   will add new protocol to your host, f.e. IPv6 8)
+ *
+ *   CHECKSUM_UNNECESSARY is applicable to following protocols:
+ *     TCP: IPv6 and IPv4.
+ *     UDP: IPv4 and IPv6. A device may apply CHECKSUM_UNNECESSARY to a
+ *       zero UDP checksum for either IPv4 or IPv6, the networking stack
+ *       may perform further validation in this case.
+ *     GRE: only if the checksum is present in the header.
+ *     SCTP: indicates the CRC in SCTP header has been validated.
+ *
+ *   skb->csum_level indicates the number of consecutive checksums found in
+ *   the packet minus one that have been verified as CHECKSUM_UNNECESSARY.
+ *   For instance if a device receives an IPv6->UDP->GRE->IPv4->TCP packet
+ *   and a device is able to verify the checksums for UDP (possibly zero),
+ *   GRE (checksum flag is set), and TCP-- skb->csum_level would be set to
+ *   two. If the device were only able to verify the UDP checksum and not
+ *   GRE, either because it doesn't support GRE checksum of because GRE
+ *   checksum is bad, skb->csum_level would be set to zero (TCP checksum is
+ *   not considered in this case).
  *
  * CHECKSUM_COMPLETE:
  *
@@ -112,6 +130,9 @@
 #define CHECKSUM_COMPLETE	2
 #define CHECKSUM_PARTIAL	3
 
+/* Maximum value in skb->csum_level */
+#define SKB_MAX_CSUM_LEVEL	3
+
 #define SKB_DATA_ALIGN(X)	ALIGN(X, SMP_CACHE_BYTES)
 #define SKB_WITH_OVERHEAD(X)	\
 	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
@@ -569,16 +590,13 @@ struct sk_buff {
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
 	__u8			head_frag:1;
-	/* Encapsulation protocol and NIC drivers should use
-	 * this flag to indicate to each other if the skb contains
-	 * encapsulated packet or not and maybe use the inner packet
-	 * headers if needed
-	 */
+	/* Indicates the the inner headers are valid in the skbuff. */
 	__u8			encapsulation:1;
 	__u8			encap_hdr_csum:1;
 	__u8			csum_valid:1;
 	__u8			csum_complete_sw:1;
-	/* 2/4 bit hole (depending on ndisc_nodetype presence) */
+	__u8			csum_level:2;
+	/* 0/2 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -1860,18 +1878,6 @@ static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 	return pskb_may_pull(skb, skb_network_offset(skb) + len);
 }
 
-static inline void skb_pop_rcv_encapsulation(struct sk_buff *skb)
-{
-	/* Only continue with checksum unnecessary if device indicated
-	 * it is valid across encapsulation (skb->encapsulation was set).
-	 */
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY && !skb->encapsulation)
-		skb->ip_summed = CHECKSUM_NONE;
-
-	skb->encapsulation = 0;
-	skb->csum_valid = 0;
-}
-
 /*
  * CPUs often take a performance hit when accessing unaligned memory
  * locations. The actual performance hit varies, it can be small if the
@@ -2792,6 +2798,27 @@ static inline __sum16 skb_checksum_complete(struct sk_buff *skb)
 	       0 : __skb_checksum_complete(skb);
 }
 
+static inline void __skb_decr_checksum_unnecessary(struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		if (skb->csum_level == 0)
+			skb->ip_summed = CHECKSUM_NONE;
+		else
+			skb->csum_level--;
+	}
+}
+
+static inline void __skb_incr_checksum_unnecessary(struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		if (skb->csum_level < SKB_MAX_CSUM_LEVEL)
+			skb->csum_level++;
+	} else if (skb->ip_summed == CHECKSUM_NONE) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->csum_level = 0;
+	}
+}
+
 /* Check if we need to perform checksum complete validation.
  *
  * Returns true if checksum complete is needed, false otherwise
@@ -2803,6 +2830,7 @@ static inline bool __skb_checksum_validate_needed(struct sk_buff *skb,
 {
 	if (skb_csum_unnecessary(skb) || (zero_okay && !check)) {
 		skb->csum_valid = 1;
+		__skb_decr_checksum_unnecessary(skb);
 		return false;
 	}
 
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 7c1a8ff..0485bf7 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -125,7 +125,6 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			*csum_err = true;
 			return -EINVAL;
 		}
-		skb_pop_rcv_encapsulation(skb);
 		options++;
 	}
 
-- 
2.1.0.rc2.206.gedb03e5
