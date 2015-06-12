From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH 3.4] ipv6: add check for blackhole or prohibited entry in rt6_redirect
Date: Fri, 12 Jun 2015 14:05:02 +0800
Message-ID: <1434089102-6732-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <lizefan@huawei.com>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weilong Chen <chenweilong@huawei.com>

There's a check for ip6_null_entry, but it's not enough if the config
CONFIG_IPV6_MULTIPLE_TABLES is selected. Blackhole or prohibited entries
should also be ignored.

This path is for kernel before v3.6, as there's a commit b94f1c0
use icmpv6_notify() instead of rt6_redirect() and rt6_redirect has
been deleted.

The oops as follow:
    [exception RIP: do_raw_write_lock+12]
    RIP: ffffffff8122c42c  RSP: ffff880666e45820  RFLAGS: 00010282
    RAX: ffff8801207bffd8  RBX: 0000000000000018  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: ffff880666e45898  RDI: 0000000000000018
    RBP: ffff880666e45830   R8: 000000000000001e   R9: 0000000006000000
    R10: ffff88011796b8a0  R11: 0000000000000004  R12: ffff88010391ed00
    R13: 0000000000000000  R14: ffff880666e45898  R15: ffff88011796b890
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
    [ffff880666e45838] _raw_write_lock_bh at ffffffff81450b39
    [ffff880666e45858] __ip6_ins_rt at ffffffff813ed8c1
    [ffff880666e45888] ip6_ins_rt at ffffffff813eef58
    [ffff880666e458b8] rt6_redirect at ffffffff813f0b84
    [ffff880666e45958] ndisc_rcv at ffffffff813f95d8
    [ffff880666e45a08] icmpv6_rcv at ffffffff814000e8
    [ffff880666e45ae8] ip6_input_finish at ffffffff813e43bb
    [ffff880666e45b38] ip6_input at ffffffff813e4b08
    [ffff880666e45b68] ipv6_rcv at ffffffff813e4969
    [ffff880666e45bc8] __netif_receive_skb at ffffffff8135158a
    [ffff880666e45c38] dev_gro_receive at ffffffff81351cb0
    [ffff880666e45c78] napi_gro_receive at ffffffff81351fc5
    [ffff880666e45cb8] tg3_rx at ffffffffa0bfb354 [tg]
    [ffff880666e45d88] tg3_poll_work at ffffffffa0c07857 [tg]
    [ffff880666e45e18] tg3_poll_msix at ffffffffa0c07d1b [tg]
    [ffff880666e45e68] net_rx_action at ffffffff81352219
    [ffff880666e45ec8] __do_softirq at ffffffff8103e5a1
    [ffff880666e45f38] call_softirq at ffffffff81459c4c
    [ffff880666e45f50] do_softirq at ffffffff8100413d
    [ffff880666e45f80] do_IRQ at ffffffff81003cce
This happened when ip6_route_redirect found a rt which was set
blackhole, the rt had a NULL rt6i_table argument which is accessed by
__ip6_ins_rt() when trying to lock rt6i_table->tb6_lock caused a BUG:
"BUG: unable to handle kernel NULL pointer"

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv6/route.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c8643a3..c604751 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1661,6 +1661,17 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 		goto out;
 	}
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	if (rt == net->ipv6.ip6_blk_hole_entry ||
+	    rt == net->ipv6.ip6_prohibit_entry) {
+		if (net_ratelimit())
+			printk(KERN_DEBUG "rt6_redirect: source isn't a valid" \
+			       " nexthop for redirect target " \
+			       "(blackhole or prohibited)\n");
+		goto out;
+	}
+#endif
+
 	/*
 	 *	We have finally decided to accept it.
 	 */
-- 
1.7.12
