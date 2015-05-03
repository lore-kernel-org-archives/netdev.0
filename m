From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: PATCH: af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT)
Date: Sun, 3 May 2015 13:28:27 +0200
Message-ID: <5546065B.6080706@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------040903070401050404020107"
Cc: Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay36-dus.antispameurope.com ([94.100.134.236]:43812 "EHLO
	mx-relay36-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751062AbbECL2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 07:28:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------040903070401050404020107
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

following up on my initial post and the feedback I have received,
please find attached/in-line an updated patch.

Changes:
*) keep the unlikely() in the case sock_alloc_send_skb() fails, as here 
we enter the slow path, anyway.
*) pass on the return code from sock_alloc_send_skb(), i.e. EGAIN

Please consider this for inclusion.

Cheers,

Mathias

---
diff -uNpr linux-3.16.7.orig/net/packet/af_packet.c 
linux-3.16.7/net/packet/af_packet.c
--- linux-3.16.7.orig/net/packet/af_packet.c    2014-10-30 
16:41:01.000000000 +0000
+++ linux-3.16.7/net/packet/af_packet.c 2015-04-05 08:41:14.577535454 +0000
@@ -2291,11 +2291,14 @@ static int tpacket_snd(struct packet_soc
                 tlen = dev->needed_tailroom;
                 skb = sock_alloc_send_skb(&po->sk,
                                 hlen + tlen + sizeof(struct sockaddr_ll),
-                               0, &err);
+                               !need_wait, &err);

-               if (unlikely(skb == NULL))
+               if (unlikely(skb == NULL)) {
+                       /* we assume the socket was initially writeable 
... */
+                       if (likely(len_sum > 0))
+                               err = len_sum;
                         goto out_status;
-
+               }
                 tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, 
proto,
                                           addr, hlen);
                 if (tp_len > dev->mtu + dev->hard_header_len) {

--------------040903070401050404020107
Content-Type: text/x-patch; name="005-af_packet_no_block_tx.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="005-af_packet_no_block_tx.patch"

diff -uNpr linux-3.16.7.orig/net/packet/af_packet.c linux-3.16.7/net/packet/af_packet.c
--- linux-3.16.7.orig/net/packet/af_packet.c	2014-10-30 16:41:01.000000000 +0000
+++ linux-3.16.7/net/packet/af_packet.c	2015-04-05 08:41:14.577535454 +0000
@@ -2291,11 +2291,14 @@ static int tpacket_snd(struct packet_soc
 		tlen = dev->needed_tailroom;
 		skb = sock_alloc_send_skb(&po->sk,
 				hlen + tlen + sizeof(struct sockaddr_ll),
-				0, &err);
+				!need_wait, &err);
 
-		if (unlikely(skb == NULL))
+		if (unlikely(skb == NULL)) {
+			/* we assume the socket was initially writeable ... */
+			if (likely(len_sum > 0))
+				err = len_sum;
 			goto out_status;
-
+		}
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 					  addr, hlen);
 		if (tp_len > dev->mtu + dev->hard_header_len) {

--------------040903070401050404020107--
