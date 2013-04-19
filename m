From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Fri, 19 Apr 2013 17:51:57 -0400
Message-ID: <1366408317-16432-1-git-send-email-willemb@google.com>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net, paul.chavent@onera.fr,
	daniel.borkmann@tik.ee.ethz.ch, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:37428 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933335Ab3DSV6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:58:14 -0400
Received: by mail-ye0-f201.google.com with SMTP id m2so482152yen.0
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 14:58:13 -0700 (PDT)
In-Reply-To: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2:
- move sock_tx_timestamp near other sk reads (warm cacheline)
- remove duplicate flush_dcache_page
- enable hardware timestamps reporting using the error queue (not ring)
- use new ktime_to_timespec_cond API

When transmit timestamping is enabled at the socket level, record a
timestamp on packets written to a PACKET_TX_RING. Tx timestamps are
always looped to the application over the socket error queue. Software
timestamps are also written back into the packet frame header in the
packet ring.

Reported-by: Paul Chavent <paul.chavent@onera.fr>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c      | 12 ++++++------
 net/packet/af_packet.c | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 898cf5c..af9185d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3327,12 +3327,8 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (!sk)
 		return;
 
-	skb = skb_clone(orig_skb, GFP_ATOMIC);
-	if (!skb)
-		return;
-
 	if (hwtstamps) {
-		*skb_hwtstamps(skb) =
+		*skb_hwtstamps(orig_skb) =
 			*hwtstamps;
 	} else {
 		/*
@@ -3340,9 +3336,13 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 		 * so keep the shared tx_flags and only
 		 * store software time stamp
 		 */
-		skb->tstamp = ktime_get_real();
+		orig_skb->tstamp = ktime_get_real();
 	}
 
+	skb = skb_clone(orig_skb, GFP_ATOMIC);
+	if (!skb)
+		return;
+
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 7e387ff..ec8ea27 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -339,6 +339,37 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
 	}
 }
 
+static void __packet_set_timestamp(struct packet_sock *po, void *frame,
+				   ktime_t tstamp)
+{
+	union tpacket_uhdr h;
+	struct timespec ts;
+
+	if (!ktime_to_timespec_cond(tstamp, &ts) ||
+	    !sock_flag(&po->sk, SOCK_TIMESTAMPING_SOFTWARE))
+		return;
+
+	h.raw = frame;
+	switch (po->tp_version) {
+	case TPACKET_V1:
+		h.h1->tp_sec = ts.tv_sec;
+		h.h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
+		break;
+	case TPACKET_V2:
+		h.h2->tp_sec = ts.tv_sec;
+		h.h2->tp_nsec = ts.tv_nsec;
+		break;
+	case TPACKET_V3:
+	default:
+		WARN(1, "TPACKET version not supported.\n");
+		BUG();
+	}
+
+	/* one flush is safe, as both fields always lie on the same cacheline */
+	flush_dcache_page(pgv_to_page(&h.h1->tp_sec));
+	smp_wmb();
+}
+
 static void *packet_lookup_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		unsigned int position,
@@ -1877,6 +1908,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 		ph = skb_shinfo(skb)->destructor_arg;
 		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
 		atomic_dec(&po->tx_ring.pending);
+		__packet_set_timestamp(po, ph, skb->tstamp);
 		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
 	}
 
@@ -1900,6 +1932,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
+	sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
 	skb_shinfo(skb)->destructor_arg = ph.raw;
 
 	switch (po->tp_version) {
-- 
1.8.2.1
