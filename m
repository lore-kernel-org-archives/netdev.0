From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: more precise pkt_len computation
Date: Fri, 26 Oct 2012 11:32:50 +0200
Message-ID: <1351243970.6537.321.camel@edumazet-glaptop>
References: <1350965711-4390-1-git-send-email-amwang@redhat.com>
	 <F36C0EC1-0A4C-48FB-ABF3-A89575A9287E@unimore.it>
	 <1350982432.26308.8.camel@cr0>
	 <58DEB62C-6237-435E-8300-8E390F101F58@unimore.it>
	 <1351239007.6537.291.camel@edumazet-glaptop>
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
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48966 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab2JZJcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 05:32:54 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1165009bkc.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 02:32:52 -0700 (PDT)
In-Reply-To: <1351239007.6537.291.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

One long standing problem with TSO/GSO/GRO packets is that skb->len
doesnt represent a precise amount of bytes on wire.

Headers are only accounted for the first segment.
For TCP, thats typically 66 bytes per 1448 bytes segment missing,
an error of 4.5 %

As consequences :

1) TBF/CBQ/HTB/NETEM/... can send more bytes than the assigned limits.
2) Device stats are slightly under estimated as well.

Fix this by taking account of headers in qdisc_skb_cb(skb)->pkt_len
computation.

Packet schedulers should use pkt_len instead of skb->len for their
bandwidth limitations, and TSO enabled devices drivers could use pkt_len
if their statistics are not hardware assisted, and if they dont scratch
skb->cb[] first word.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Paolo Valente <paolo.valente@unimore.it>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/core/dev.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b4978e2..cf2b5f4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2442,7 +2442,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	bool contended;
 	int rc;
 
-	qdisc_skb_cb(skb)->pkt_len = skb->len;
 	qdisc_calculate_pkt_len(skb, q);
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
@@ -2579,6 +2578,16 @@ int dev_queue_xmit(struct sk_buff *skb)
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
 #endif
 	trace_net_dev_queue(skb);
+	qdisc_skb_cb(skb)->pkt_len = skb->len;
+	if (skb_is_gso(skb)) {
+		unsigned int hdr_len = skb_transport_offset(skb);
+
+		if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))
+			hdr_len += tcp_hdrlen(skb);
+		else
+			hdr_len += sizeof(struct udphdr);
+		qdisc_skb_cb(skb)->pkt_len += (skb_shinfo(skb)->gso_segs - 1) * hdr_len;
+	}
 	if (q->enqueue) {
 		rc = __dev_xmit_skb(skb, q, dev, txq);
 		goto out;
