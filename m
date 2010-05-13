From: kaber@trash.net
Subject: [PATCH 09/12] netfilter: bridge-netfilter: fix crash in br_nf_forward_finish()
Date: Thu, 13 May 2010 18:16:22 +0200
Message-ID: <1273767385-18225-10-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bart De Schuymer <bdschuym@pandora.be>

[ 4593.956206] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[ 4593.956219] IP: [<ffffffffa03357a4>] br_nf_forward_finish+0x154/0x170 [bridge]
[ 4593.956232] PGD 195ece067 PUD 1ba005067 PMD 0
[ 4593.956241] Oops: 0000 [#1] SMP
[ 4593.956248] last sysfs file:
/sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:08/ATK0110:00/hwmon/hwmon0/temp2_label
[ 4593.956253] CPU 3
...
[ 4593.956380] Pid: 29512, comm: kvm Not tainted 2.6.34-rc7-net #195 P6T DELUXE/System Product Name
[ 4593.956384] RIP: 0010:[<ffffffffa03357a4>]  [<ffffffffa03357a4>] br_nf_forward_finish+0x154/0x170 [bridge]
[ 4593.956395] RSP: 0018:ffff880001e63b78  EFLAGS: 00010246
[ 4593.956399] RAX: 0000000000000608 RBX: ffff880057181700 RCX: ffff8801b813d000
[ 4593.956402] RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffff880057181700
[ 4593.956406] RBP: ffff880001e63ba8 R08: ffff8801b9d97000 R09: ffffffffa0335650
[ 4593.956410] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801b813d000
[ 4593.956413] R13: ffffffff81ab3940 R14: ffff880057181700 R15: 0000000000000002
[ 4593.956418] FS:  00007fc40d380710(0000) GS:ffff880001e60000(0000) knlGS:0000000000000000
[ 4593.956422] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4593.956426] CR2: 0000000000000018 CR3: 00000001ba1d7000 CR4: 00000000000026e0
[ 4593.956429] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4593.956433] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4593.956437] Process kvm (pid: 29512, threadinfo ffff8801ba566000, task ffff8801b8003870)
[ 4593.956441] Stack:
[ 4593.956443]  0000000100000020 ffff880001e63ba0 ffff880001e63ba0 ffff880057181700
[ 4593.956451] <0> ffffffffa0335650 ffffffff81ab3940 ffff880001e63bd8 ffffffffa03350e6
[ 4593.956462] <0> ffff880001e63c40 000000000000024d ffff880057181700 0000000080000000
[ 4593.956474] Call Trace:
[ 4593.956478]  <IRQ>
[ 4593.956488]  [<ffffffffa0335650>] ? br_nf_forward_finish+0x0/0x170 [bridge]
[ 4593.956496]  [<ffffffffa03350e6>] NF_HOOK_THRESH+0x56/0x60 [bridge]
[ 4593.956504]  [<ffffffffa0335282>] br_nf_forward_arp+0x112/0x120 [bridge]
[ 4593.956511]  [<ffffffff813f7184>] nf_iterate+0x64/0xa0
[ 4593.956519]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [bridge]
[ 4593.956524]  [<ffffffff813f722c>] nf_hook_slow+0x6c/0x100
[ 4593.956531]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [bridge]
[ 4593.956538]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridge]
[ 4593.956545]  [<ffffffffa032f86d>] __br_forward+0x6d/0xc0 [bridge]
[ 4593.956550]  [<ffffffff813c5d8e>] ? skb_clone+0x3e/0x70
[ 4593.956557]  [<ffffffffa032f462>] deliver_clone+0x32/0x60 [bridge]
[ 4593.956564]  [<ffffffffa032f6b6>] br_flood+0xa6/0xe0 [bridge]
[ 4593.956571]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridge]

Don't call nf_bridge_update_protocol() for ARP traffic as skb->nf_bridge isn't
used in the ARP case.

Reported-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/bridge/br_netfilter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 93f80fe..4442099 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -643,10 +643,10 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 			skb->pkt_type = PACKET_OTHERHOST;
 			nf_bridge->mask ^= BRNF_PKT_TYPE;
 		}
+		nf_bridge_update_protocol(skb);
 	} else {
 		in = *((struct net_device **)(skb->cb));
 	}
-	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
 
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,
-- 
1.7.0.4

