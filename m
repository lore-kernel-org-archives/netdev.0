From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH stable 4.1] openvswitch: gre: filter gre packets
Date: Sun,  8 Jan 2017 06:14:27 -0800
Message-ID: <1483884867-7264-1-git-send-email-pshelar@ovn.org>
Cc: uri@zoey.com, Pravin B Shelar <pshelar@ovn.org>,
        Joe Stringer <joe@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33450 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967840AbdAHOOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 09:14:39 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so4570709pgd.0
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 06:14:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS can only process L2 packets. But OVS GRE receive handler
can accept IP-GRE packets. When such packet is processed by
OVS datapath it can trigger following assert failure due
to insufficient linear data in skb. Following patch filters
received packets to avoid this issue.

[68240.441681] ------------[ cut here ]------------
[68240.496918] kernel BUG at /build/linux-lts-trusty-D60X6T/linux-lts-trusty-3.13.0/include/linux/skbuff.h:1486!
[68240.615520] invalid opcode: 0000 [#1] SMP
[68241.953939] RIP: [<ffffffffa052b4fe>] __skb_pull.part.7+0x4/0x6 [openvswitch]
[68243.099945] Call Trace:
[68243.129188]  <IRQ>
[68243.152204]  [<ffffffffa0524e64>] ovs_flow_extract+0x664/0x720 [openvswitch]
[68243.314912]  [<ffffffffa0523a80>] ovs_dp_process_received_packet+0x60/0x130 [openvswitch]
[68243.481559]  [<ffffffffa0529e3a>] ovs_vport_receive+0x2a/0x30 [openvswitch]
[68243.564884]  [<ffffffffa052b374>] gre_rcv+0xa4/0xb8 [openvswitch]
[68243.637802]  [<ffffffffa03e2795>] gre_cisco_rcv+0x75/0xbc [gre]
[68243.708621]  [<ffffffffa03e22f5>] gre_rcv+0x65/0x90 [gre]
[68243.773214]  [<ffffffff816941d8>] ip_local_deliver_finish+0xa8/0x220
[68243.849244]  [<ffffffff816944db>] ip_local_deliver+0x4b/0x90
[68243.916951]  [<ffffffff81693ed1>] ip_rcv_finish+0x121/0x380
[68243.983627]  [<ffffffff816947a6>] ip_rcv+0x286/0x380
[68244.043023]  [<ffffffff8165b80a>] __netif_receive_skb_core+0x61a/0x760
[68244.121122]  [<ffffffff8165b971>] __netif_receive_skb+0x21/0x70
[68244.191942]  [<ffffffff8165c131>] process_backlog+0xb1/0x190
[68244.259642]  [<ffffffff8165ca09>] net_rx_action+0x139/0x280
[68244.326305]  [<ffffffff8107367d>] __do_softirq+0xed/0x360
[68244.390887]  [<ffffffff81073c8e>] irq_exit+0x11e/0x140
[68244.452358]  [<ffffffff8177d873>] do_IRQ+0x63/0xe0
[68244.509674]  [<ffffffff817728ad>] common_interrupt+0x6d/0x6d
[68245.392237] RIP  [<ffffffffa052b4fe>] __skb_pull.part.7+0x4/0x6 [openvswitch]
[68245.520082] ---[ end trace 383bac9f3e676970 ]---

Fixes: aa310701e7 ("openvswitch: Add gre tunnel support.")
Reported-by: Uri Foox <uri@zoey.com>
CC: Joe Stringer <joe@ovn.org>
Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
Newer OVS GRE vport uses LWT interface which does not have this issue.
---
 net/openvswitch/vport-gre.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index f17ac96..de67fd1 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -102,6 +102,9 @@ static int gre_rcv(struct sk_buff *skb,
 	struct vport *vport;
 	__be64 key;
 
+	if (tpi->proto != htons(ETH_P_TEB))
+		return PACKET_REJECT;
+
 	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
 	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
 	if (unlikely(!vport))
-- 
2.9.3
