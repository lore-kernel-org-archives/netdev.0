From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/dccp: fix use-after-free in dccp_invalid_packet
Date: Mon, 28 Nov 2016 06:26:49 -0800
Message-ID: <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+zYNyuFUU+w0rLWvvZqivSedrqMpS5UYt=c4uqajS_Stw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36003 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932626AbcK1O0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 09:26:51 -0500
In-Reply-To: <CAAeHK+zYNyuFUU+w0rLWvvZqivSedrqMpS5UYt=c4uqajS_Stw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

pskb_may_pull() can reallocate skb->head, we need to reload dh pointer
in dccp_invalid_packet() or risk use after free.

Bug found by Andrey Konovalov using syzkaller.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/dccp/ipv4.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b567c8725aea..edbe59d203ef 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -700,6 +700,7 @@ int dccp_invalid_packet(struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh;
 	unsigned int cscov;
+	u8 dccph_doff;
 
 	if (skb->pkt_type != PACKET_HOST)
 		return 1;
@@ -721,18 +722,19 @@ int dccp_invalid_packet(struct sk_buff *skb)
 	/*
 	 * If P.Data Offset is too small for packet type, drop packet and return
 	 */
-	if (dh->dccph_doff < dccp_hdr_len(skb) / sizeof(u32)) {
-		DCCP_WARN("P.Data Offset(%u) too small\n", dh->dccph_doff);
+	dccph_doff = dh->dccph_doff;
+	if (dccph_doff < dccp_hdr_len(skb) / sizeof(u32)) {
+		DCCP_WARN("P.Data Offset(%u) too small\n", dccph_doff);
 		return 1;
 	}
 	/*
 	 * If P.Data Offset is too too large for packet, drop packet and return
 	 */
-	if (!pskb_may_pull(skb, dh->dccph_doff * sizeof(u32))) {
-		DCCP_WARN("P.Data Offset(%u) too large\n", dh->dccph_doff);
+	if (!pskb_may_pull(skb, dccph_doff * sizeof(u32))) {
+		DCCP_WARN("P.Data Offset(%u) too large\n", dccph_doff);
 		return 1;
 	}
-
+	dh = dccp_hdr(skb);
 	/*
 	 * If P.type is not Data, Ack, or DataAck and P.X == 0 (the packet
 	 * has short sequence numbers), drop packet and return
