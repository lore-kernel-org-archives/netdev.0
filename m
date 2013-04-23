From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/5] packet: if hw/sw ts enabled in rx/tx ring, report which ts we got
Date: Tue, 23 Apr 2013 12:39:31 +0200
Message-ID: <1366713572-11978-5-git-send-email-dborkman@redhat.com>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, willemb@google.com, Paul.Chavent@onera.fr,
	richardcochran@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755402Ab3DWKn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 06:43:27 -0400
In-Reply-To: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there is no way to find out which timestamp is reported in
tpacket{,2,3}_hdr's tp_sec, tp_{n,u}sec members. It can be one of
SOF_TIMESTAMPING_SYS_HARDWARE, SOF_TIMESTAMPING_RAW_HARDWARE,
SOF_TIMESTAMPING_SOFTWARE, or a fallback variant late call from the
PF_PACKET code in software.

Therefore, report in the tp_status member of the ring buffer which
timestamp has been reported for RX and TX path. This should not break
anything for the following reasons: i) in RX ring path, the user needs
to test for tp_status & TP_STATUS_USER, and later for other flags as
well such as TP_STATUS_VLAN_VALID et al, so adding other flags will
do no harm; ii) in TX ring path, time stamps with PACKET_TIMESTAMP
socketoption are not available resp. had no effect except that the
application setting this is buggy. Next to TP_STATUS_AVAILABLE, the
user also should check for other flags such as TP_STATUS_WRONG_FORMAT
to reclaim frames to the application. Thus, in case TX ts are turned
off (default case), nothing happens to the application logic, and in
case we want to use this new feature, we now can also check which of
the ts source is reported in the status field as provided in the docs.

Reported-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/uapi/linux/if_packet.h |  5 +++++
 net/packet/af_packet.c         | 36 +++++++++++++++++++++++-------------
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index 4dfc234..b950c02 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -100,6 +100,11 @@ struct tpacket_auxdata {
 #define TP_STATUS_SENDING	(1 << 1)
 #define TP_STATUS_WRONG_FORMAT	(1 << 2)
 
+/* Rx and Tx ring - header status */
+#define TP_STATUS_TS_SOFTWARE		(1 << 29)
+#define TP_STATUS_TS_SYS_HARDWARE	(1 << 30)
+#define TP_STATUS_TS_RAW_HARDWARE	(1 << 31)
+
 /* Rx ring - feature request bits */
 #define TP_FT_REQ_FILL_RXHASH	0x1
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e7892a4..dd5cd49 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -339,34 +339,35 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
 	}
 }
 
-static bool tpacket_get_timestamp(struct sk_buff *skb, struct timespec *ts,
-				  unsigned int flags)
+static __u32 tpacket_get_timestamp(struct sk_buff *skb, struct timespec *ts,
+				   unsigned int flags)
 {
 	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 
 	if (shhwtstamps) {
 		if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) &&
 		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts))
-			return true;
+			return TP_STATUS_TS_SYS_HARDWARE;
 		if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
 		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts))
-			return true;
+			return TP_STATUS_TS_RAW_HARDWARE;
 	}
 
 	if (ktime_to_timespec_cond(skb->tstamp, ts))
-		return true;
+		return TP_STATUS_TS_SOFTWARE;
 
-	return false;
+	return 0;
 }
 
-static void __packet_set_timestamp(struct packet_sock *po, void *frame,
-				   struct sk_buff *skb)
+static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
+				    struct sk_buff *skb)
 {
 	union tpacket_uhdr h;
 	struct timespec ts;
+	__u32 ts_status;
 
-	if (!tpacket_get_timestamp(skb, &ts, po->tp_tstamp))
-		return;
+	if (!(ts_status = tpacket_get_timestamp(skb, &ts, po->tp_tstamp)))
+		return 0;
 
 	h.raw = frame;
 	switch (po->tp_version) {
@@ -387,6 +388,8 @@ static void __packet_set_timestamp(struct packet_sock *po, void *frame,
 	/* one flush is safe, as both fields always lie on the same cacheline */
 	flush_dcache_page(pgv_to_page(&h.h1->tp_sec));
 	smp_wmb();
+
+	return ts_status;
 }
 
 static void *packet_lookup_frame(struct packet_sock *po,
@@ -1721,6 +1724,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	unsigned short macoff, netoff, hdrlen;
 	struct sk_buff *copy_skb = NULL;
 	struct timespec ts;
+	__u32 ts_status;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -1803,9 +1807,12 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
-	if (!tpacket_get_timestamp(skb, &ts, po->tp_tstamp))
+
+	if (!(ts_status = tpacket_get_timestamp(skb, &ts, po->tp_tstamp)))
 		getnstimeofday(&ts);
 
+	status |= ts_status;
+
 	switch (po->tp_version) {
 	case TPACKET_V1:
 		h.h1->tp_len = skb->len;
@@ -1905,11 +1912,14 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 	void *ph;
 
 	if (likely(po->tx_ring.pg_vec)) {
+		__u32 ts;
+
 		ph = skb_shinfo(skb)->destructor_arg;
 		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
 		atomic_dec(&po->tx_ring.pending);
-		__packet_set_timestamp(po, ph, skb);
-		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
+
+		ts = __packet_set_timestamp(po, ph, skb);
+		__packet_set_status(po, ph, TP_STATUS_AVAILABLE | ts);
 	}
 
 	sock_wfree(skb);
-- 
1.7.11.7
