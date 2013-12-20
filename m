From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: [PATCH] nf_conntrack_timestamp: Fix BUG_ON after netns deletion
Date: Fri, 20 Dec 2013 14:41:54 +0100
Message-ID: <1387546914-24958-1-git-send-email-helmut.schaa@googlemail.com>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu,
	Helmut Schaa <helmut.schaa@googlemail.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When having nf_conntrack_timestamp enabled deleting a netns can lead
to the following BUG being triggered:

[63836.660000] Kernel bug detected[#1]:
[63836.660000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.10.18 #14
[63836.660000] task: 802d9420 ti: 802d2000 task.ti: 802d2000
[63836.660000] $ 0   : 00000000 00000000 00000000 00000000
[63836.660000] $ 4   : 00000001 00000004 00000020 00000020
[63836.660000] $ 8   : 00000000 80064910 00000000 00000000
[63836.660000] $12   : 0bff0002 00000001 00000000 0a0a0abe
[63836.660000] $16   : 802e70a0 85f29d80 00000000 00000004
[63836.660000] $20   : 85fb62a0 00000002 802d3bc0 85fb62a0
[63836.660000] $24   : 00000000 87138110
[63836.660000] $28   : 802d2000 802d3b40 00000014 871327cc
[63836.660000] Hi    : 000005ff
[63836.660000] Lo    : f2edd000
[63836.660000] epc   : 87138794 __nf_ct_ext_add_length+0xe8/0x1ec [nf_conntrack]
[63836.660000]     Not tainted
[63836.660000] ra    : 871327cc nf_conntrack_in+0x31c/0x7b8 [nf_conntrack]
[63836.660000] Status: 1100d403 KERNEL EXL IE
[63836.660000] Cause : 00800034
[63836.660000] PrId  : 0001974c (MIPS 74Kc)
[63836.660000] Modules linked in: ath9k ath9k_common pppoe ppp_async iptable_nat ath9k_hw ath pppox ppp_generic nf_nat_ipv4 nf_conntrack_ipv4 mac80211 ipt_MASQUERADE cfg80211 xt_time xt_tcpudp xt_state xt_quota xt_policy xt_pkttype xt_owner xt_nat xt_multiport xt_mark xh
[63836.660000] Process swapper (pid: 0, threadinfo=802d2000, task=802d9420, tls=00000000)
[63836.660000] Stack : 802e70a0 871323d4 00000005 87080234 802e70a0 86d2a840 00000000 00000000
[63836.660000] Call Trace:
[63836.660000] [<87138794>] __nf_ct_ext_add_length+0xe8/0x1ec [nf_conntrack]
[63836.660000] [<871327cc>] nf_conntrack_in+0x31c/0x7b8 [nf_conntrack]
[63836.660000] [<801ff63c>] nf_iterate+0x90/0xec
[63836.660000] [<801ff730>] nf_hook_slow+0x98/0x164
[63836.660000] [<80205968>] ip_rcv+0x3e8/0x40c
[63836.660000] [<801d9754>] __netif_receive_skb_core+0x624/0x6a4
[63836.660000] [<801da124>] process_backlog+0xa4/0x16c
[63836.660000] [<801d9bb4>] net_rx_action+0x10c/0x1e0
[63836.660000] [<8007c5a4>] __do_softirq+0xd0/0x1bc
[63836.660000] [<8007c730>] do_softirq+0x48/0x68
[63836.660000] [<8007c964>] irq_exit+0x54/0x70
[63836.660000] [<80060830>] ret_from_irq+0x0/0x4
[63836.660000] [<8006a9f8>] r4k_wait_irqoff+0x18/0x1c
[63836.660000] [<8009cfb8>] cpu_startup_entry+0xa4/0x104
[63836.660000] [<802eb918>] start_kernel+0x394/0x3ac
[63836.660000]
[63836.660000]
Code: 00821021  8c420000  2c440001 <00040336> 90440011  92350010  90560010  2485ffff  02a5a821
[63837.040000] ---[ end trace ebf660c3ce3b55e7 ]---
[63837.050000] Kernel panic - not syncing: Fatal exception in interrupt
[63837.050000] Rebooting in 3 seconds..

Fix this by not unregistering the conntrack extension in the per-netns
cleanup code.

Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>
---
 net/netfilter/nf_conntrack_timestamp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index 902fb0a..7a394df 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -97,7 +97,6 @@ int nf_conntrack_tstamp_pernet_init(struct net *net)
 void nf_conntrack_tstamp_pernet_fini(struct net *net)
 {
 	nf_conntrack_tstamp_fini_sysctl(net);
-	nf_ct_extend_unregister(&tstamp_extend);
 }
 
 int nf_conntrack_tstamp_init(void)
-- 
1.8.1.4

