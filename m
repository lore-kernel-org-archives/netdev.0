From: Willem de Bruijn <willemb@google.com>
Subject: [net-next 3/4] packet: remove deprecated syststamp timestamp
Date: Fri, 25 Jul 2014 18:01:31 -0400
Message-ID: <1406325692-616-4-git-send-email-willemb@google.com>
References: <1406325692-616-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	kreese@caviumnetworks.com, ddaney@caviumnetworks.com,
	dborkman@redhat.com, jdmason@kudzu.us,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:33001 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbaGYWBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:01:45 -0400
Received: by mail-oa0-f73.google.com with SMTP id g18so1405230oah.2
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:01:44 -0700 (PDT)
In-Reply-To: <1406325692-616-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No device driver will ever return an skb_shared_info structure with
syststamp non-zero, so remove the branch that tests for this and
optionally marks the packet timestamp as TP_STATUS_TS_SYS_HARDWARE.

Do not remove the definition TP_STATUS_TS_SYS_HARDWARE, as processes
may refer to it.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/packet_mmap.txt | 18 ++++++------------
 include/uapi/linux/if_packet.h           |  2 +-
 net/packet/af_packet.c                   | 12 ++++--------
 3 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 38112d5..a6d7cb9 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -1008,14 +1008,9 @@ hardware timestamps to be used. Note: you may need to enable the generation
 of hardware timestamps with SIOCSHWTSTAMP (see related information from
 Documentation/networking/timestamping.txt).
 
-PACKET_TIMESTAMP accepts the same integer bit field as
-SO_TIMESTAMPING.  However, only the SOF_TIMESTAMPING_SYS_HARDWARE
-and SOF_TIMESTAMPING_RAW_HARDWARE values are recognized by
-PACKET_TIMESTAMP.  SOF_TIMESTAMPING_SYS_HARDWARE takes precedence over
-SOF_TIMESTAMPING_RAW_HARDWARE if both bits are set.
-
-    int req = 0;
-    req |= SOF_TIMESTAMPING_SYS_HARDWARE;
+PACKET_TIMESTAMP accepts the same integer bit field as SO_TIMESTAMPING:
+
+    int req = SOF_TIMESTAMPING_RAW_HARDWARE;
     setsockopt(fd, SOL_PACKET, PACKET_TIMESTAMP, (void *) &req, sizeof(req))
 
 For the mmap(2)ed ring buffers, such timestamps are stored in the
@@ -1023,14 +1018,13 @@ tpacket{,2,3}_hdr structure's tp_sec and tp_{n,u}sec members. To determine
 what kind of timestamp has been reported, the tp_status field is binary |'ed
 with the following possible bits ...
 
-    TP_STATUS_TS_SYS_HARDWARE
     TP_STATUS_TS_RAW_HARDWARE
     TP_STATUS_TS_SOFTWARE
 
 ... that are equivalent to its SOF_TIMESTAMPING_* counterparts. For the
-RX_RING, if none of those 3 are set (i.e. PACKET_TIMESTAMP is not set),
-then this means that a software fallback was invoked *within* PF_PACKET's
-processing code (less precise).
+RX_RING, if neither is set (i.e. PACKET_TIMESTAMP is not set), then a
+software fallback was invoked *within* PF_PACKET's processing code (less
+precise).
 
 Getting timestamps for the TX_RING works as follows: i) fill the ring frames,
 ii) call sendto() e.g. in blocking mode, iii) wait for status of relevant
diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index bac27fa..da2d668 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -108,7 +108,7 @@ struct tpacket_auxdata {
 
 /* Rx and Tx ring - header status */
 #define TP_STATUS_TS_SOFTWARE		(1 << 29)
-#define TP_STATUS_TS_SYS_HARDWARE	(1 << 30)
+#define TP_STATUS_TS_SYS_HARDWARE	(1 << 30) /* deprecated, never set */
 #define TP_STATUS_TS_RAW_HARDWARE	(1 << 31)
 
 /* Rx ring - feature request bits */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 614ca91..8d9f804 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -441,14 +441,10 @@ static __u32 tpacket_get_timestamp(struct sk_buff *skb, struct timespec *ts,
 {
 	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 
-	if (shhwtstamps) {
-		if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts))
-			return TP_STATUS_TS_SYS_HARDWARE;
-		if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts))
-			return TP_STATUS_TS_RAW_HARDWARE;
-	}
+	if (shhwtstamps &&
+	    (flags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
+	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts))
+		return TP_STATUS_TS_RAW_HARDWARE;
 
 	if (ktime_to_timespec_cond(skb->tstamp, ts))
 		return TP_STATUS_TS_SOFTWARE;
-- 
2.0.0.526.g5318336
