From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: fix a race in encap_rcv handling
Date: Tue, 01 Nov 2011 23:56:59 +0100
Message-ID: <1320188219.4728.7.camel@edumazet-laptop>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50384 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013Ab1KAW5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 18:57:05 -0400
Received: by wwi36 with SMTP id 36so3807887wwi.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 15:57:03 -0700 (PDT)
In-Reply-To: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp_queue_rcv_skb() has a possible race in encap_rcv handling, since
this pointer can be changed anytime.

We should use ACCESS_ONCE() to close the race.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/udp.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ebaa96b..15b50df 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1397,6 +1397,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	nf_reset(skb);
 
 	if (up->encap_type) {
+		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
+
 		/*
 		 * This is an encapsulation socket so pass the skb to
 		 * the socket's udp_encap_rcv() hook. Otherwise, just
@@ -1409,11 +1411,11 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		 */
 
 		/* if we're overly short, let UDP handle it */
-		if (skb->len > sizeof(struct udphdr) &&
-		    up->encap_rcv != NULL) {
+		encap_rcv = ACCESS_ONCE(up->encap_rcv);
+		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
 			int ret;
 
-			ret = (*up->encap_rcv)(sk, skb);
+			ret = encap_rcv(sk, skb);
 			if (ret <= 0) {
 				UDP_INC_STATS_BH(sock_net(sk),
 						 UDP_MIB_INDATAGRAMS,
