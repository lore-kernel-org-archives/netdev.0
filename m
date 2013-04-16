From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] packet: move hw/sw timestamp extraction into a small helper
Date: Tue, 16 Apr 2013 13:29:11 +0200
Message-ID: <1366111751-14886-2-git-send-email-dborkman@redhat.com>
References: <1366111751-14886-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, willemb@google.com, hawk@diku.dk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754226Ab3DPL3U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 07:29:20 -0400
In-Reply-To: <1366111751-14886-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a small, internal helper function, that is used by
PF_PACKET. Based on the flags that are passed, it extracts the packet
timestamp in the receive path. This is merely a refactoring to remove
some duplicate code in tpacket_rcv(), to make it more readable, and to
enable others to use this function in PF_PACKET as well, e.g. for TX.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2:
   - To not break user space, I decided for now to not get rid of tp_tstamp
   - After some more thinking about it, I'm now with Willem to not make it
     too generic, thus having it stay in af_packet.c
   - Use ktime_to_timespec_cond() from patch 1 to make it more similar to
     __sock_recv_timestamp()

 net/packet/af_packet.c | 57 ++++++++++++++++++++------------------------------
 1 file changed, 23 insertions(+), 34 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 77d71f8..e381adf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1663,6 +1663,26 @@ drop:
 	return 0;
 }
 
+static void tpacket_get_timestamp(struct sk_buff *skb, struct timespec *ts,
+				  unsigned int flags)
+{
+	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+
+	if (shhwtstamps) {
+		if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) &&
+		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts))
+			return;
+		if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
+		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts))
+			return;
+	}
+
+	if (ktime_to_timespec_cond(skb->tstamp, ts))
+		return;
+
+	getnstimeofday(ts);
+}
+
 static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		       struct packet_type *pt, struct net_device *orig_dev)
 {
@@ -1681,9 +1701,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	unsigned long status = TP_STATUS_USER;
 	unsigned short macoff, netoff, hdrlen;
 	struct sk_buff *copy_skb = NULL;
-	struct timeval tv;
 	struct timespec ts;
-	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -1766,6 +1784,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
+	tpacket_get_timestamp(skb, &ts, po->tp_tstamp);
 
 	switch (po->tp_version) {
 	case TPACKET_V1:
@@ -1773,18 +1792,8 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		h.h1->tp_snaplen = snaplen;
 		h.h1->tp_mac = macoff;
 		h.h1->tp_net = netoff;
-		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
-				&& shhwtstamps->syststamp.tv64)
-			tv = ktime_to_timeval(shhwtstamps->syststamp);
-		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
-				&& shhwtstamps->hwtstamp.tv64)
-			tv = ktime_to_timeval(shhwtstamps->hwtstamp);
-		else if (skb->tstamp.tv64)
-			tv = ktime_to_timeval(skb->tstamp);
-		else
-			do_gettimeofday(&tv);
-		h.h1->tp_sec = tv.tv_sec;
-		h.h1->tp_usec = tv.tv_usec;
+		h.h1->tp_sec = ts.tv_sec;
+		h.h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
 		hdrlen = sizeof(*h.h1);
 		break;
 	case TPACKET_V2:
@@ -1792,16 +1801,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		h.h2->tp_snaplen = snaplen;
 		h.h2->tp_mac = macoff;
 		h.h2->tp_net = netoff;
-		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
-				&& shhwtstamps->syststamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->syststamp);
-		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
-				&& shhwtstamps->hwtstamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->hwtstamp);
-		else if (skb->tstamp.tv64)
-			ts = ktime_to_timespec(skb->tstamp);
-		else
-			getnstimeofday(&ts);
 		h.h2->tp_sec = ts.tv_sec;
 		h.h2->tp_nsec = ts.tv_nsec;
 		if (vlan_tx_tag_present(skb)) {
@@ -1822,16 +1821,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		h.h3->tp_snaplen = snaplen;
 		h.h3->tp_mac = macoff;
 		h.h3->tp_net = netoff;
-		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
-				&& shhwtstamps->syststamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->syststamp);
-		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
-				&& shhwtstamps->hwtstamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->hwtstamp);
-		else if (skb->tstamp.tv64)
-			ts = ktime_to_timespec(skb->tstamp);
-		else
-			getnstimeofday(&ts);
 		h.h3->tp_sec  = ts.tv_sec;
 		h.h3->tp_nsec = ts.tv_nsec;
 		hdrlen = sizeof(*h.h3);
-- 
1.7.11.7
