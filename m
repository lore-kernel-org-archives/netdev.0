From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: Re: [PATCH] loopback: set pkt_type to PACKET_HOST explicitly
Date: Thu, 27 Jun 2013 14:29:38 +0900
Message-ID: <20130627052938.GD8524@valinux.co.jp>
References: <0cd1047a2432736459fabbe97a8fb81c449fd827.1372232028.git.yamahata@valinux.co.jp> <1372236022.3301.128.camel@edumazet-glaptop> <20130626093751.GB8524@valinux.co.jp> <20130626.152930.1401552744929449732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	murphy.mccauley@gmail.com, pshelar@nicira.com, jesse@nicira.com,
	dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:56469 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3F0F3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 01:29:39 -0400
Content-Disposition: inline
In-Reply-To: <20130626.152930.1401552744929449732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 03:29:30PM -0700, David Miller wrote:
> From: Isaku Yamahata <yamahata@valinux.co.jp>
> Date: Wed, 26 Jun 2013 18:37:51 +0900
> 
> > veth does. vethb-peer in the above example.
> > (veth_xmit() -> dev_forward_skb() -> eth_type_trans())
> > The destination mac address of arp reply is set to the one of
> > vetha (!= vethb-peer). So vethb-peer sets pkt_type to OTHERHOST.
> > bridge and gretap doesn't touch skb->pkt_type.
> 
> I think the dev_forward_skb() assignment of pkt_type should be done
> after the call to eth_type_trans().
> 
> That's the whole point, we know we're looping the packet back to a
> local device on this host.
> 
> I'm not applying this loopback patch, sorry.

So you mean like this patch?
The callers of dev_forward_skb() are only veth, macvlan and l2tp, which
seem fine with this change.


>From 99281ba2b4f383623fe8da238bc6616952334bfe Mon Sep 17 00:00:00 2001
Message-Id: <99281ba2b4f383623fe8da238bc6616952334bfe.1372310725.git.yamahata@valinux.co.jp>
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 27 Jun 2013 12:15:11 +0900
Subject: [PATCH] core/dev: set pkt_type after eth_type_trans()

The dev_forward_skb() assignment of pkt_type should be done
after the call to eth_type_trans().

ip-encapsulated packets can be handled by localhost. But skb->pkt_type
can be PACKET_OTHERHOST when packet comes via veth into ip tunnel device.
In that case, the packet is dropped by ip_rcv().

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

Cc: eric.dumazet@gmail.com
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
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



-- 
yamahata
