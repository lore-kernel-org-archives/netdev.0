From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT)
Date: Thu, 2 Apr 2015 12:52:54 +0200
Message-ID: <551D1F86.8050200@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------080509080507060409060507"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay37-dus.antispameurope.com ([94.100.134.237]:46240 "EHLO
	mx-relay37-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750872AbbDBLAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 07:00:05 -0400
Received: from DIRAC.fokus.fraunhofer.de ([IPv6:2001:638:806:9::201])
	by smtpsrv2.fokus.fraunhofer.de (8.14.4/8.14.4) with ESMTP id t32ArKSx018048
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 2 Apr 2015 12:53:20 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------080509080507060409060507
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

Dear all,

we have encountered a problem where the send(MSG_DONTWAIT) call on a TX_RING is not 
fully non-blocking in cases where the device's sndBuf is full (i.e. we are trying to 
write faster than the device can handle).

This is on a WLAN radio (so it's not that hard to achieve :).

Comparing the TX_RING send() handler to the regular send() handler, the difference 
seems to be in the sock_alloc_send_skb() call where, the regular handler passes a 
(flags & MSG_DONTWAIT), while the TX_RING handler always passes a 0 (block).

The attached patch changes this behavior by

a) also passing (flags & MSG_DONTWAIT)
b) adjusting the return code so that -ENOBUFS is returned if no frame could be sent 
or to return the number of bytes sent, if frame(s) could be sent within this call.

The proposed modification works fine for us and has been tested extensively with 
WLAN and Ethernet device.

Feel free to apply this patch if you agree with this solution.
Of course, we're also open to other solutions / proposals / ideas.

Cheers,

Mathias

-- 
Dr. Mathias Kretschmer, Head of Competence Center
Fraunhofer FOKUS Network Research
A Schloss Birlinghoven, 53754 Sankt Augustin, Germany
T +49-2241-14-3466, F +49-2241-14-1050
E mathias.kretschmer@fokus.fraunhofer.de
W http://www.fokus.fraunhofer.de/en/net

--------------080509080507060409060507
Content-Type: text/x-patch; name="005-af_packet_no_block_tx.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="005-af_packet_no_block_tx.patch"

diff -uNpr linux-3.16.7.orig/net/packet/af_packet.c linux-3.16.7/net/packet/af_packet.c
--- linux-3.16.7.orig/net/packet/af_packet.c	2014-10-30 16:41:01.000000000 +0000
+++ linux-3.16.7/net/packet/af_packet.c	2015-04-02 08:43:37.386617712 +0000
@@ -2285,17 +2285,22 @@ static int tpacket_snd(struct packet_soc
 				schedule();
 			continue;
 		}
-
+	
 		status = TP_STATUS_SEND_REQUEST;
 		hlen = LL_RESERVED_SPACE(dev);
 		tlen = dev->needed_tailroom;
 		skb = sock_alloc_send_skb(&po->sk,
 				hlen + tlen + sizeof(struct sockaddr_ll),
-				0, &err);
+				!need_wait, &err);
 
-		if (unlikely(skb == NULL))
+		if (skb == NULL) {
+	                /* we assume the socket was initially writeable ... */
+                        if (likely(len_sum > 0))
+                        	err = len_sum;
+                	else
+                        	err = -ENOBUFS;
 			goto out_status;
-
+                }
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 					  addr, hlen);
 		if (tp_len > dev->mtu + dev->hard_header_len) {

--------------080509080507060409060507--
