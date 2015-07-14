From: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Subject: [PATCH] brouted packet identified as PACKET_OTHERHOST blocked by
 higher protocol
Date: Tue, 14 Jul 2015 10:37:44 +0000
Message-ID: <3167EFAB95044A4EB6B134B9A39AA98A055B5DBE@xmb-rcd-x05.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-5.cisco.com ([173.37.86.76]:25344 "EHLO
	rcdn-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbGNKrF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 06:47:05 -0400
Received: from xhc-rcd-x01.cisco.com (xhc-rcd-x01.cisco.com [173.37.183.75])
	by alln-core-3.cisco.com (8.14.5/8.14.5) with ESMTP id t6EAbjOR014744
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 10:37:45 GMT
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem I'm trying to solve is that when packets being sent from one bridged interface to the other are "brouted" they get dropped by the IP layer. The reason is that the packet being raised has pkt_type of type PACKET_OTHERHOST.

The semantics of "brouting" a packet is that it is sent up to higher network layers. Problem is that when the pkt_type of the packet is 
PACKET_OTHERHOST it (at least for IP) gets dropped. (e.g. dropping OTHERHOST packets is the first thing ip_rcv() does).

The suggested patch below changes the packet type to PACKET_HOST which fixes the problem. This is a bit of a cheat but I didn't find any side effects and couldn't find a better way w/o defining a new packet type. 

Also removed " dest = eth_hdr(skb)->h_dest;" which does nothing as far as I can see as it is already assigned the same value before.

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f921a5d..2cae324 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -291,12 +291,11 @@ forward:
        switch (p->state) {
        case BR_STATE_FORWARDING:
                rhook = rcu_dereference(br_should_route_hook);
-               if (rhook) {
-                       if ((*rhook)(skb)) {
-                               *pskb = skb;
-                               return RX_HANDLER_PASS;
-                       }
-                       dest = eth_hdr(skb)->h_dest;
+               if (rhook && (*rhook)(skb)) {
+                   if (skb->pkt_type == PACKET_OTHERHOST)
+                       skb->pkt_type = PACKET_HOST; /* so it does not get rejected by higher protocol receiver, e.g. by ip_rcv()  */
+                   *pskb = skb;
+                   return RX_HANDLER_PASS;
                }
                /* fall through */
        case BR_STATE_LEARNING:
