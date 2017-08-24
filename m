From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] netfilter: x_tables: Fix use-after-free in ipt_do_table.
Date: Thu, 24 Aug 2017 16:43:29 +0200
Message-ID: <1503585811-13447-4-git-send-email-pablo@netfilter.org>
References: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Taehee Yoo <ap420073@gmail.com>

If verdict is NF_STOLEN in the SYNPROXY target,
the skb is consumed.
However, ipt_do_table() always tries to get ip header from the skb.
So that, KASAN triggers the use-after-free message.

We can reproduce this message using below command.
  # iptables -I INPUT -p tcp -j SYNPROXY --mss 1460

[ 193.542265] BUG: KASAN: use-after-free in ipt_do_table+0x1405/0x1c10
[ ... ]
[ 193.578603] Call Trace:
[ 193.581590] <IRQ>
[ 193.584107] dump_stack+0x68/0xa0
[ 193.588168] print_address_description+0x78/0x290
[ 193.593828] ? ipt_do_table+0x1405/0x1c10
[ 193.598690] kasan_report+0x230/0x340
[ 193.603194] __asan_report_load2_noabort+0x19/0x20
[ 193.608950] ipt_do_table+0x1405/0x1c10
[ 193.613591] ? rcu_read_lock_held+0xae/0xd0
[ 193.618631] ? ip_route_input_rcu+0x27d7/0x4270
[ 193.624348] ? ipt_do_table+0xb68/0x1c10
[ 193.629124] ? do_add_counters+0x620/0x620
[ 193.634234] ? iptable_filter_net_init+0x60/0x60
[ ... ]

After this patch, only when verdict is XT_CONTINUE,
ipt_do_table() tries to get ip header.
Also arpt_do_table() is modified because it has same bug.

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 10 +++++-----
 net/ipv4/netfilter/ip_tables.c  |  9 +++++----
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 0bc3c3d73e61..9e9d9afd18f7 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -268,14 +268,14 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 		acpar.targinfo = t->data;
 		verdict = t->u.kernel.target->target(skb, &acpar);
 
-		/* Target might have changed stuff. */
-		arp = arp_hdr(skb);
-
-		if (verdict == XT_CONTINUE)
+		if (verdict == XT_CONTINUE) {
+			/* Target might have changed stuff. */
+			arp = arp_hdr(skb);
 			e = arpt_next_entry(e);
-		else
+		} else {
 			/* Verdict */
 			break;
+		}
 	} while (!acpar.hotdrop);
 	xt_write_recseq_end(addend);
 	local_bh_enable();
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2a55a40211cb..622ed2887cd5 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -352,13 +352,14 @@ ipt_do_table(struct sk_buff *skb,
 		acpar.targinfo = t->data;
 
 		verdict = t->u.kernel.target->target(skb, &acpar);
-		/* Target might have changed stuff. */
-		ip = ip_hdr(skb);
-		if (verdict == XT_CONTINUE)
+		if (verdict == XT_CONTINUE) {
+			/* Target might have changed stuff. */
+			ip = ip_hdr(skb);
 			e = ipt_next_entry(e);
-		else
+		} else {
 			/* Verdict */
 			break;
+		}
 	} while (!acpar.hotdrop);
 
 	xt_write_recseq_end(addend);
-- 
2.1.4


