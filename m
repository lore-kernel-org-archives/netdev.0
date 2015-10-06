From: dho@fastly.com
Subject: [PATCH net] xps: clear skb sender_cpu before tee
Date: Tue,  6 Oct 2015 12:38:46 -0700
Message-ID: <1444160326-9375-1-git-send-email-dho@fastly.com>
Cc: "Devon H. O'Dell" <dho@fastly.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33947 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbJFTi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 15:38:57 -0400
Received: by padhy16 with SMTP id hy16so78687371pad.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 12:38:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Devon H. O'Dell" <dho@fastly.com>

The netfilter tee code does not clear skb->sender_cpu after copying the
skb. When both CONFIG_XPS and CONFIG_NET_RX_BUSY_POLL are active, it is
possible for a tee rule to duplicate a skb from input, leaving its
its napi queue id set. Because this field is shared in a union with
sender_cpu, we can get an invalid offset in __netdev_pick_tx when the
napi_id exceeds the number of logical CPUs in the system. This yields
the following panic:

BUG: unable to handle kernel paging request at 0000333300000000
IP: [<ffffffff8168c87d>] __netdev_pick_tx+0x6d/0x150
PGD 0
Oops: 0000 [#1] SMP
Call Trace:
 <IRQ>
 [<ffffffffa0061cf2>] ixgbe_select_queue+0xe2/0x190 [ixgbe]
 [<ffffffff8168cc1b>] netdev_pick_tx+0x6b/0x100
 [<ffffffff81695cd4>] __dev_queue_xmit+0x84/0x540
 [<ffffffff8173d858>] ? ipt_do_table+0x208/0x5f0
 [<ffffffff816961b3>] dev_queue_xmit_sk+0x13/0x20
 [<ffffffffa0225d21>] macvlan_start_xmit+0xb1/0x150 [macvlan]
 [<ffffffff81695aab>] dev_hard_start_xmit+0x22b/0x3d0
 [<ffffffff816955e9>] ? validate_xmit_skb.isra.98.part.99+0x29/0x2c0
 [<ffffffff816960b1>] __dev_queue_xmit+0x461/0x540
 [<ffffffff816961b3>] dev_queue_xmit_sk+0x13/0x20
 [<ffffffff816ee0a8>] ip_finish_output+0x258/0x8c0
 [<ffffffff816ef08b>] ip_output+0x6b/0xc0
 [<ffffffff816ede50>] ? ip_finish_output2+0x370/0x370
 [<ffffffff816ee80a>] ip_local_out_sk+0x3a/0x50
 [<ffffffffa024a526>] tee_tg4+0x186/0x208 [xt_TEE]
 [<ffffffff8173d94b>] ipt_do_table+0x2fb/0x5f0
 [<ffffffff81703132>] ? tcp_rcv_established+0x4b2/0x800
 [<ffffffff8173d858>] ? ipt_do_table+0x208/0x5f0
 [<ffffffffa006bc25>] ? ixgbe_xmit_frame_ring+0x415/0xe20 [ixgbe]
 [<ffffffff8173fb9b>] iptable_mangle_hook+0x4b/0x140
 [<ffffffff816c700f>] nf_iterate+0x7f/0xb0
 [<ffffffff816c70e4>] nf_hook_slow+0xa4/0x110
 [<ffffffff816e93a1>] ip_rcv+0x2d1/0x3b0
 ...

Investigation shows that Eric Dumazet fixed a similar issue in
commit c29390c6dfeee094 ("xps: must clear sender_cpu before forwarding"),
which was introduced by his commit 2bd82484bb4c5db1 ("xps: fix xps for
stacked devices").

Thanks-to: Eric Hoffman <ehoffman@fastly.com>
Thanks-to: Grant Zhang <gzhang@fastly.com>
Tested-by: Jonathan Steinert <hachi@fastly.com>
Signed-off-by: Devon H. O'Dell <dho@fastly.com>

---
 net/ipv4/netfilter/nf_dup_ipv4.c | 2 ++
 net/ipv6/netfilter/nf_dup_ipv6.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index 2d79e6e..2f2a79b 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -81,6 +81,8 @@ void nf_dup_ipv4(struct sk_buff *skb, unsigned int hooknum,
 	if (skb == NULL)
 		return;
 
+	skb_sender_cpu_clear(skb);
+
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Avoid counting cloned packets towards the original connection. */
 	nf_conntrack_put(skb->nfct);
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index c8ab626..03f0a15 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -70,6 +70,8 @@ void nf_dup_ipv6(struct sk_buff *skb, unsigned int hooknum,
 	if (skb == NULL)
 		return;
 
+	skb_sender_cpu_clear(skb);
+
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 	skb->nfct     = &nf_ct_untracked_get()->ct_general;
-- 
2.1.4
