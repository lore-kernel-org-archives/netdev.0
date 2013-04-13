From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Sat, 13 Apr 2013 14:56:52 -0400
Message-ID: <1365879412-9541-1-git-send-email-willemb@google.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: paul.chavent@onera.fr, richardcochran@gmail.com,
	edumazet@google.com, daniel.borkmann@tik.ee.ethz.ch,
	xemul@parallels.com, ebiederm@xmission.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:60439 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367Ab3DMS4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 14:56:55 -0400
Received: by mail-qe0-f74.google.com with SMTP id b10so346354qen.5
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 11:56:54 -0700 (PDT)
In-Reply-To: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When transmit timestamping is enabled at the socket level, have
writes to a PACKET_TX_RING record a timestamp for the generated
skbuffs. Tx timestamps are always looped to the application over
the socket error queue.

The patch also loops software timestamps back into the ring.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c      |  2 +-
 net/packet/af_packet.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ba64614..44b9c2a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3311,7 +3311,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 		 * so keep the shared tx_flags and only
 		 * store software time stamp
 		 */
-		skb->tstamp = ktime_get_real();
+		orig_skb->tstamp = skb->tstamp = ktime_get_real();
 	}
 
 	serr = SKB_EXT_ERR(skb);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8e4644f..dc5d224 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -341,6 +341,45 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
 	}
 }
 
+static void __packet_set_timestamp(struct packet_sock *po, void *frame,
+				   ktime_t tstamp)
+{
+	struct tpacket_hdr *h1;
+	struct tpacket2_hdr *h2;
+	struct timespec ts;
+
+	if (!tstamp.tv64 || !sock_flag(&po->sk, SOCK_TIMESTAMPING_SOFTWARE))
+		return;
+
+	ts = ktime_to_timespec(tstamp);
+
+	switch (po->tp_version) {
+	case TPACKET_V1:
+		h1 = frame;
+		h1->tp_sec = ts.tv_sec;
+		h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
+
+		flush_dcache_page(pgv_to_page(&h1->tp_sec));
+		flush_dcache_page(pgv_to_page(&h1->tp_usec));
+		break;
+	case TPACKET_V2:
+		h2 = frame;
+		h2->tp_sec = ts.tv_sec;
+		h2->tp_nsec = ts.tv_nsec;
+
+		flush_dcache_page(pgv_to_page(&h2->tp_sec));
+		flush_dcache_page(pgv_to_page(&h2->tp_nsec));
+		break;
+	case TPACKET_V3:
+	default:
+		WARN(1, "TPACKET version not supported.\n");
+		BUG();
+	}
+
+
+	smp_wmb();
+}
+
 static void *packet_lookup_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		unsigned int position,
@@ -1900,6 +1939,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 		ph = skb_shinfo(skb)->destructor_arg;
 		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
 		atomic_dec(&po->tx_ring.pending);
+		__packet_set_timestamp(po, ph, skb->tstamp);
 		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
 	}
 
@@ -2119,6 +2159,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			}
 		}
 
+		sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
+
 		skb->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		atomic_inc(&po->tx_ring.pending);
-- 
1.8.1.3
