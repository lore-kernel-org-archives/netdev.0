From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH ethtool 1/2] net_tstamp.h: sync with net-next
Date: Tue, 23 May 2017 16:29:29 +0200
Message-ID: <20170523142930.28181-2-mlichvar@redhat.com>
References: <20170523142930.28181-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        "John W . Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49398 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933699AbdEWO3e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 10:29:34 -0400
In-Reply-To: <20170523142930.28181-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers kernel changes up to:

commit b50a5c70ffa4fd6b6da324ab54c84adf48fb17d9
Author: Miroslav Lichvar <mlichvar@redhat.com>
Date:   Fri May 19 17:52:40 2017 +0200

    net: allow simultaneous SW and HW transmit timestamping

    Add SOF_TIMESTAMPING_OPT_TX_SWHW option to allow an outgoing packet to
    be looped to the socket's error queue with a software timestamp even
    when a hardware transmit timestamp is expected to be provided by the
    driver.

    Applications using this option will receive two separate messages from
    the error queue, one with a software timestamp and the other with a
    hardware timestamp. As the hardware timestamp is saved to the shared skb
    info, which may happen before the first message with software timestamp
    is received by the application, the hardware timestamp is copied to the
    SCM_TIMESTAMPING control message only when the skb has no software
    timestamp or it is an incoming packet.

    While changing sw_tx_timestamp(), inline it in skb_tx_timestamp() as
    there are no other users.

    CC: Richard Cochran <richardcochran@gmail.com>
    CC: Willem de Bruijn <willemb@google.com>
    Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
    Acked-by: Willem de Bruijn <willemb@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

CC: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 net_tstamp-copy.h | 52 +++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 41 insertions(+), 11 deletions(-)

diff --git a/net_tstamp-copy.h b/net_tstamp-copy.h
index ae5df12..3d421d9 100644
--- a/net_tstamp-copy.h
+++ b/net_tstamp-copy.h
@@ -9,6 +9,7 @@
 #ifndef _NET_TIMESTAMPING_H
 #define _NET_TIMESTAMPING_H
 
+#include <linux/types.h>
 #include <linux/socket.h>   /* for SO_TIMESTAMPING */
 
 /* SO_TIMESTAMPING gets an integer bit field comprised of these values */
@@ -20,23 +21,42 @@ enum {
 	SOF_TIMESTAMPING_SOFTWARE = (1<<4),
 	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
 	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
-	SOF_TIMESTAMPING_MASK =
-	(SOF_TIMESTAMPING_RAW_HARDWARE - 1) |
-	SOF_TIMESTAMPING_RAW_HARDWARE
+	SOF_TIMESTAMPING_OPT_ID = (1<<7),
+	SOF_TIMESTAMPING_TX_SCHED = (1<<8),
+	SOF_TIMESTAMPING_TX_ACK = (1<<9),
+	SOF_TIMESTAMPING_OPT_CMSG = (1<<10),
+	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
+	SOF_TIMESTAMPING_OPT_STATS = (1<<12),
+	SOF_TIMESTAMPING_OPT_PKTINFO = (1<<13),
+	SOF_TIMESTAMPING_OPT_TX_SWHW = (1<<14),
+
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TX_SWHW,
+	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
+				 SOF_TIMESTAMPING_LAST
 };
 
+/*
+ * SO_TIMESTAMPING flags are either for recording a packet timestamp or for
+ * reporting the timestamp to user space.
+ * Recording flags can be set both via socket options and control messages.
+ */
+#define SOF_TIMESTAMPING_TX_RECORD_MASK	(SOF_TIMESTAMPING_TX_HARDWARE | \
+					 SOF_TIMESTAMPING_TX_SOFTWARE | \
+					 SOF_TIMESTAMPING_TX_SCHED | \
+					 SOF_TIMESTAMPING_TX_ACK)
+
 /**
- * struct hwtstamp_config - %SIOCSHWTSTAMP parameter
+ * struct hwtstamp_config - %SIOCGHWTSTAMP and %SIOCSHWTSTAMP parameter
  *
- * @flags:	no flags defined right now, must be zero
+ * @flags:	no flags defined right now, must be zero for %SIOCSHWTSTAMP
  * @tx_type:	one of HWTSTAMP_TX_*
- * @rx_type:	one of one of HWTSTAMP_FILTER_*
+ * @rx_filter:	one of HWTSTAMP_FILTER_*
  *
- * %SIOCSHWTSTAMP expects a &struct ifreq with a ifr_data pointer to
- * this structure. dev_ifsioc() in the kernel takes care of the
- * translation between 32 bit userspace and 64 bit kernel. The
- * structure is intentionally chosen so that it has the same layout on
- * 32 and 64 bit systems, don't break this!
+ * %SIOCGHWTSTAMP and %SIOCSHWTSTAMP expect a &struct ifreq with a
+ * ifr_data pointer to this structure.  For %SIOCSHWTSTAMP, if the
+ * driver or hardware does not support the requested @rx_filter value,
+ * the driver may use a more general filter mode.  In this case
+ * @rx_filter will indicate the actual mode on return.
  */
 struct hwtstamp_config {
 	int flags;
@@ -108,6 +128,16 @@ enum hwtstamp_rx_filters {
 	HWTSTAMP_FILTER_PTP_V2_SYNC,
 	/* PTP v2/802.AS1, any layer, Delay_req packet */
 	HWTSTAMP_FILTER_PTP_V2_DELAY_REQ,
+
+	/* NTP, UDP, all versions and packet modes */
+	HWTSTAMP_FILTER_NTP_ALL,
+};
+
+/* SCM_TIMESTAMPING_PKTINFO control message */
+struct scm_ts_pktinfo {
+	__u32 if_index;
+	__u32 pkt_length;
+	__u32 reserved[2];
 };
 
 #endif /* _NET_TIMESTAMPING_H */
-- 
2.9.3
