From: Fan Du <fan.du@intel.com>
Subject: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Fri, 28 Nov 2014 14:33:05 +0800
Message-ID: <1417156385-18276-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, fw@strlen.de, Fan Du <fan.du@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40021 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbaK1Gfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 01:35:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test scenario: two KVM guests sitting in different
hosts communicate to each other with a vxlan tunnel.

All interface MTU is default 1500 Bytes, from guest point
of view, its skb gso_size could be as bigger as 1448Bytes,
however after guest skb goes through vxlan encapuslation,
individual segments length of a gso packet could exceed
physical NIC MTU 1500, which will be lost at recevier side.

So it's possible in virtualized environment, locally created
skb len after encapslation could be bigger than underlayer
MTU. In such case, it's reasonable to do GSO first,
then fragment any packet bigger than MTU as possible.

+---------------+ TX     RX +---------------+
|   KVM Guest   | -> ... -> |   KVM Guest   |
+-+-----------+-+           +-+-----------+-+
  |Qemu/VirtIO|               |Qemu/VirtIO|
  +-----------+               +-----------+
       |                            |
       v tap0                  tap0 v
  +-----------+               +-----------+
  | ovs bridge|               | ovs bridge|
  +-----------+               +-----------+
       | vxlan                vxlan |
       v                            v
  +-----------+               +-----------+
  |    NIC    |    <------>   |    NIC    |
  +-----------+               +-----------+

Steps to reproduce:
 1. Using kernel builtin openvswitch module to setup ovs bridge.
 2. Runing iperf without -M, communication will stuck.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/ipv4/ip_output.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index bc6471d..558b5f8 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -217,9 +217,10 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	struct sk_buff *segs;
 	int ret = 0;
 
-	/* common case: locally created skb or seglen is <= mtu */
-	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
-	      skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
+	/* Both locally created skb and forwarded skb could exceed
+	 * MTU size, so make a unified rule for them all.
+	 */
+	if (skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
 		return ip_finish_output2(skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
-- 
1.7.1
