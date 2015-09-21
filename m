From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] net: Handle negative checksum offset in skb-checksum-help
Date: Sun, 20 Sep 2015 23:53:17 -0700
Message-ID: <1442818397-2210-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32784 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbbIUGxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 02:53:22 -0400
Received: by pacex6 with SMTP id ex6so108306027pac.0
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 23:53:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VXLAN device can receive skb with checksum partial. But the checksum
offset could be in outer header which is pulled on receive. This results
in negative checksum offset for the skb. Such skb can cause the assert
failure in skb_checksum_help(). The patch fixes the bug by checking for
negative offset in skb_checksum_help().

Following is the kernel panic msg from old kernel hitting the bug.

------------[ cut here ]------------
kernel BUG at net/core/dev.c:1906!
RIP: 0010:[<ffffffff81518034>] skb_checksum_help+0x144/0x150
Call Trace:
<IRQ>
[<ffffffffa0164c28>] queue_userspace_packet+0x408/0x470 [openvswitch]
[<ffffffffa016614d>] ovs_dp_upcall+0x5d/0x60 [openvswitch]
[<ffffffffa0166236>] ovs_dp_process_packet_with_key+0xe6/0x100 [openvswitch]
[<ffffffffa016629b>] ovs_dp_process_received_packet+0x4b/0x80 [openvswitch]
[<ffffffffa016c51a>] ovs_vport_receive+0x2a/0x30 [openvswitch]
[<ffffffffa0171383>] vxlan_rcv+0x53/0x60 [openvswitch]
[<ffffffffa01734cb>] vxlan_udp_encap_recv+0x8b/0xf0 [openvswitch]
[<ffffffff8157addc>] udp_queue_rcv_skb+0x2dc/0x3b0
[<ffffffff8157b56f>] __udp4_lib_rcv+0x1cf/0x6c0
[<ffffffff8157ba7a>] udp_rcv+0x1a/0x20
[<ffffffff8154fdbd>] ip_local_deliver_finish+0xdd/0x280
[<ffffffff81550128>] ip_local_deliver+0x88/0x90
[<ffffffff8154fa7d>] ip_rcv_finish+0x10d/0x370
[<ffffffff81550365>] ip_rcv+0x235/0x300
[<ffffffff8151ba1d>] __netif_receive_skb+0x55d/0x620
[<ffffffff8151c360>] netif_receive_skb+0x80/0x90
[<ffffffff81459935>] virtnet_poll+0x555/0x6f0
[<ffffffff8151cd04>] net_rx_action+0x134/0x290
[<ffffffff810683d8>] __do_softirq+0xa8/0x210
[<ffffffff8162fe6c>] call_softirq+0x1c/0x30
[<ffffffff810161a5>] do_softirq+0x65/0xa0
[<ffffffff810687be>] irq_exit+0x8e/0xb0
[<ffffffff81630733>] do_IRQ+0x63/0xe0
[<ffffffff81625f2e>] common_interrupt+0x6e/0x6e

Reported-by: Anupam Chanda <achanda@vmware.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ee0d628..008f1ae 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2408,6 +2408,9 @@ int skb_checksum_help(struct sk_buff *skb)
 		skb_warn_bad_offload(skb);
 		return -EINVAL;
 	}
+	offset = skb_checksum_start_offset(skb);
+	if (offset < 0)
+		goto out_set_summed;
 
 	/* Before computing a checksum, we should make sure no frag could
 	 * be modified by an external entity : checksum could be wrong.
@@ -2418,7 +2421,6 @@ int skb_checksum_help(struct sk_buff *skb)
 			goto out;
 	}
 
-	offset = skb_checksum_start_offset(skb);
 	BUG_ON(offset >= skb_headlen(skb));
 	csum = skb_checksum(skb, offset, skb->len - offset, 0);
 
-- 
1.7.1
