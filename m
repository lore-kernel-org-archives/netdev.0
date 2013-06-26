From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH] loopback: set pkt_type to PACKET_HOST explicitly
Date: Wed, 26 Jun 2013 16:34:52 +0900
Message-ID: <0cd1047a2432736459fabbe97a8fb81c449fd827.1372232028.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp, murphy.mccauley@gmail.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:51830 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab3FZHey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 03:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset pkt_type to PACKET_HOST when loopback device receives packet
before calling eth_type_trans()

ip-encapsulated packets can be handled by localhost. But skb->pkt_type
can be PACKET_OTHERHOST when packet comes into ip tunnel device. In that case,
the packet is dropped by ip_rcv() because loopback_xmit() doesn't set
skb->pkt_type to PACKET_HOST.

netns A |                     root netns                      | netns B
   veth<->veth=bridge=gretap <-loop back-> gretap=bridge=veth<->veth

arp packet ->
pkt_type
         BROADCAST----loopback_xmit()-->ip_rcv()------------------->

                                                             <- arp reply
                                                                pkt_type
                       ip_rcv()<---loopback_xmit()-----OTHERHOST
                       drop

sample operations
  ip link add tapa type gretap remote 172.17.107.4 local 172.17.107.3
  ip link add tapb type gretap remote 172.17.107.3 local 172.17.107.4
  ip link set tapa up
  ip link set tapb up
  ip address add 172.17.107.3 dev tapa
  ip address add 172.17.107.4 dev tapb
  ip route get 172.17.107.3
  > local 172.17.107.3 dev lo  src 172.17.107.3
  >    cache <local>
  ip route get 172.17.107.4
  > local 172.17.107.4 dev lo  src 172.17.107.4
  >    cache <local>
  ip link add vetha type veth peer name vetha-peer
  ip link add vethb type veth peer name vethb-peer
  brctl addbr bra
  brctl addbr brb
  brctl addif bra tapa
  brctl addif bra vetha-peer
  brctl addif brb tapb
  brctl addif brb vethb-peer
  brctl show
  > bridge name     bridge id               STP enabled     interfaces
  > bra             8000.6ea21e758ff1       no              tapa
  >                                                         vetha-peer
  > brb             8000.420020eb92d5       no              tapb
  >                                                         vethb-peer
  ip link set vetha-peer up
  ip link set vethb-peer up
  ip link set bra up
  ip link set brb up
  ip netns add a
  ip netns add b
  ip link set vetha netns a
  ip link set vethb netns b
  ip netns exec a ip address add 10.0.0.3/24 dev vetha
  ip netns exec b ip address add 10.0.0.4/24 dev vethb
  ip netns exec a ip link set vetha up
  ip netns exec b ip link set vethb up
  ip netns exec a arping -I vetha 10.0.0.4
  ARPING 10.0.0.4 from 10.0.0.3 vetha
  ^CSent 2 probes (2 broadcast(s))
  Received 0 response(s)

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Jesse Gross <jesse@nicira.com>
Cc: dev@openvswitch.org
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/net/loopback.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index fcbf680..2694638 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -82,6 +82,12 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	 */
 	skb_dst_force(skb);
 
+	/* pkt_type is not always PACKET_HOST because
+	 * this skb comes from  other components.
+	 * Since eth_type_trans() sets pkt_type _except_ PACKET_HOST case,
+	 * set it explicitly.
+	 */
+	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
-- 
1.7.10.4
