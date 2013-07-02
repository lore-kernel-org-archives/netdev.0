From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH] core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()
Date: Tue,  2 Jul 2013 20:30:10 +0900
Message-ID: <0324dc4a3a7740e4766e16539f4ed41b356f991d.1372764542.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp, murphy.mccauley@gmail.com,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Patrick McHardy <kaber@trash.net>,
	Hong Zhiguo <honkiko@gmail.com>,
	Rami Rosen <ramirose@gmail.com>,
	Tom Parkin <tparkin@katalix.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:39628 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab3GBLaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 07:30:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev_forward_skb() assignment of pkt_type should be done
after the call to eth_type_trans().

ip-encapsulated packets can be handled by localhost. But skb->pkt_type
can be PACKET_OTHERHOST when packet comes via veth into ip tunnel device.
In that case, the packet is dropped by ip_rcv().
Although this example uses gretap. l2tp-eth also has same issue.
For l2tp-eth case, add dummy device for ip address and ip l2tp command.

netns A |                     root netns                      | netns B
   veth<->veth=bridge=gretap <-loop back-> gretap=bridge=veth<->veth

arp packet ->
pkt_type
         BROADCAST------------>ip_rcv()------------------------>

                                                             <- arp reply
                                                                pkt_type
                               ip_rcv()<-----------------OTHERHOST
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

Cc: Jason Wang <jasowang@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Hong Zhiguo <honkiko@gmail.com>
Cc: Rami Rosen <ramirose@gmail.com>
Cc: Tom Parkin <tparkin@katalix.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Jesse Gross <jesse@nicira.com>
Cc: dev@openvswitch.org
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 net/core/dev.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 722f633..b179b8a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1662,8 +1662,12 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	skb->skb_iif = 0;
 	skb_dst_drop(skb);
 	skb->tstamp.tv64 = 0;
-	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, dev);
+	/*
+	 * eth_type_trans() can set pkt_type.
+	 * clear pkt_type _after_ calling eth_type_trans()
+	 */
+	skb->pkt_type = PACKET_HOST;
 	skb->mark = 0;
 	secpath_reset(skb);
 	nf_reset(skb);
-- 
1.7.10.4
