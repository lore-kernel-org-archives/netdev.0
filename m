From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net_sched: more precise pkt_len computation
Date: Thu, 10 Jan 2013 14:36:42 -0800
Message-ID: <1357857402.27446.2734.camel@edumazet-glaptop>
References: <1350965711-4390-1-git-send-email-amwang@redhat.com>
	 <F36C0EC1-0A4C-48FB-ABF3-A89575A9287E@unimore.it>
	 <1350982432.26308.8.camel@cr0>
	 <58DEB62C-6237-435E-8300-8E390F101F58@unimore.it>
	 <1351239007.6537.291.camel@edumazet-glaptop>
	 <1351243970.6537.321.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Paolo Valente <paolo.valente@unimore.it>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:46747 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab3AJWgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:36:46 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so453828dae.31
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 14:36:45 -0800 (PST)
In-Reply-To: <1351243970.6537.321.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

One long standing problem with TSO/GSO/GRO packets is that skb->len
doesn't represent a precise amount of bytes on wire.

Headers are only accounted for the first segment.
For TCP, thats typically 66 bytes per 1448 bytes segment missing,
an error of 4.5 % for normal MSS value.

As consequences :

1) TBF/CBQ/HTB/NETEM/... can send more bytes than the assigned limits.
2) Device stats are slightly under estimated as well.

Fix this by taking account of headers in qdisc_skb_cb(skb)->pkt_len
computation.

Packet schedulers should use qdisc pkt_len instead of skb->len for their
bandwidth limitations, and TSO enabled devices drivers could use pkt_len
if their statistics are not hardware assisted, and if they don't scratch
skb->cb[] first word.

Both egress and ingress paths work, thanks to commit fda55eca5a
(net: introduce skb_transport_header_was_set()) : If GRO built
a GSO packet, it also set the transport header for us.


Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Paolo Valente <paolo.valente@unimore.it>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/core/dev.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 594830e..3625f97 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2532,6 +2532,26 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 	return netdev_get_tx_queue(dev, queue_index);
 }
 
+static void qdisc_pkt_len_init(struct sk_buff *skb)
+{
+	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+	qdisc_skb_cb(skb)->pkt_len = skb->len;
+
+	/* To get more precise estimation of bytes sent on wire,
+	 * we add to pkt_len the headers size of all segments
+	 */
+	if (shinfo->gso_size)  {
+		unsigned int hdr_len = skb_transport_offset(skb);
+
+		if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
+			hdr_len += tcp_hdrlen(skb);
+		else
+			hdr_len += sizeof(struct udphdr);
+		qdisc_skb_cb(skb)->pkt_len += (shinfo->gso_segs - 1) * hdr_len;
+	}
+}
+
 static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct net_device *dev,
 				 struct netdev_queue *txq)
@@ -2540,7 +2560,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	bool contended;
 	int rc;
 
-	qdisc_skb_cb(skb)->pkt_len = skb->len;
+	qdisc_pkt_len_init(skb);
 	qdisc_calculate_pkt_len(skb, q);
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
