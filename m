From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nft_queue: use raw_smp_processor_id()
Date: Thu,  5 Jan 2017 12:19:49 +0100
Message-ID: <1483615193-2931-3-git-send-email-pablo@netfilter.org>
References: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using smp_processor_id() causes splats with PREEMPT_RCU:

[19379.552780] BUG: using smp_processor_id() in preemptible [00000000] code: ping/32389
[19379.552793] caller is debug_smp_processor_id+0x17/0x19
[...]
[19379.552823] Call Trace:
[19379.552832]  [<ffffffff81274e9e>] dump_stack+0x67/0x90
[19379.552837]  [<ffffffff8129a4d4>] check_preemption_disabled+0xe5/0xf5
[19379.552842]  [<ffffffff8129a4fb>] debug_smp_processor_id+0x17/0x19
[19379.552849]  [<ffffffffa07c42dd>] nft_queue_eval+0x35/0x20c [nft_queue]

No need to disable preemption since we only fetch the numeric value, so
let's use raw_smp_processor_id() instead.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_queue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index 3e19fa1230dc..dbb6aaff67ec 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -38,7 +38,7 @@ static void nft_queue_eval(const struct nft_expr *expr,
 
 	if (priv->queues_total > 1) {
 		if (priv->flags & NFT_QUEUE_FLAG_CPU_FANOUT) {
-			int cpu = smp_processor_id();
+			int cpu = raw_smp_processor_id();
 
 			queue = priv->queuenum + cpu % priv->queues_total;
 		} else {
-- 
2.1.4

