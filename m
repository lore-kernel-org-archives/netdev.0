From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: [PATCH net] net: fix UDP tunnel GSO of frag_list GRO packets
Date: Sun,  8 Jun 2014 23:48:54 -0700
Message-ID: <1402296534-8978-1-git-send-email-weichunc@plumgrid.com>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:43659 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbaFIGs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 02:48:59 -0400
Received: by mail-pd0-f177.google.com with SMTP id g10so4451090pdj.8
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 23:48:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a kernel BUG_ON in skb_segment. It is hit when
testing two VMs on openvswitch with one VM acting as VXLAN gateway.

During VXLAN packet GSO, skb_segment is called with skb->data
pointing to inner TCP payload. skb_segment calls skb_network_protocol
to retrieve the inner protocol. skb_network_protocol actually expects
skb->data to point to MAC and it calls pskb_may_pull with ETH_HLEN.
This ends up pulling in ETH_HLEN data from header tail. As a result,
pskb_trim logic is skipped and BUG_ON is hit later.

Move skb_push in front of skb_network_protocol so that skb->data
lines up properly.

kernel BUG at net/core/skbuff.c:2999!
Call Trace:
[<ffffffff816ac412>] tcp_gso_segment+0x122/0x410
[<ffffffff816bc74c>] inet_gso_segment+0x13c/0x390
[<ffffffff8164b39b>] skb_mac_gso_segment+0x9b/0x170
[<ffffffff816b3658>] skb_udp_tunnel_segment+0xd8/0x390
[<ffffffff816b3c00>] udp4_ufo_fragment+0x120/0x140
[<ffffffff816bc74c>] inet_gso_segment+0x13c/0x390
[<ffffffff8109d742>] ? default_wake_function+0x12/0x20
[<ffffffff8164b39b>] skb_mac_gso_segment+0x9b/0x170
[<ffffffff8164b4d0>] __skb_gso_segment+0x60/0xc0
[<ffffffff8164b6b3>] dev_hard_start_xmit+0x183/0x550
[<ffffffff8166c91e>] sch_direct_xmit+0xfe/0x1d0
[<ffffffff8164bc94>] __dev_queue_xmit+0x214/0x4f0
[<ffffffff8164bf90>] dev_queue_xmit+0x10/0x20
[<ffffffff81687edb>] ip_finish_output+0x66b/0x890
[<ffffffff81688a58>] ip_output+0x58/0x90
[<ffffffff816c628f>] ? fib_table_lookup+0x29f/0x350
[<ffffffff816881c9>] ip_local_out_sk+0x39/0x50
[<ffffffff816cbfad>] iptunnel_xmit+0x10d/0x130
[<ffffffffa0212200>] vxlan_xmit_skb+0x1d0/0x330 [vxlan]
[<ffffffffa02a3919>] vxlan_tnl_send+0x129/0x1a0 [openvswitch]
[<ffffffffa02a2cd6>] ovs_vport_send+0x26/0xa0 [openvswitch]
[<ffffffffa029931e>] do_output+0x2e/0x50 [openvswitch]

Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
---
 net/core/skbuff.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8383b2b..9433047 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2881,12 +2881,13 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	int pos;
 	int dummy;
 
+	__skb_push(head_skb, doffset);
 	proto = skb_network_protocol(head_skb, &dummy);
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
 	csum = !!can_checksum_protocol(features, proto);
-	__skb_push(head_skb, doffset);
+
 	headroom = skb_headroom(head_skb);
 	pos = skb_headlen(head_skb);
 
-- 
1.7.9.5
