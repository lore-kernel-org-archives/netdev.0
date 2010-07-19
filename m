From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: this_cpu_xxx conversions
Date: Mon, 19 Jul 2010 22:48:49 +0200
Message-ID: <1279572529.2458.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40964 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966583Ab0GSUsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 16:48:53 -0400
Received: by wyb42 with SMTP id 42so4743999wyb.19
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 13:48:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use modern this_cpu_xxx() api, saving few bytes on x86

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/sock.c         |    5 ++---
 net/sched/sch_generic.c |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 363bc26..854faff 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2232,8 +2232,7 @@ static DECLARE_BITMAP(proto_inuse_idx, PROTO_INUSE_NR);
 #ifdef CONFIG_NET_NS
 void sock_prot_inuse_add(struct net *net, struct proto *prot, int val)
 {
-	int cpu = smp_processor_id();
-	per_cpu_ptr(net->core.inuse, cpu)->val[prot->inuse_idx] += val;
+	__this_cpu_add(net->core.inuse->val[prot->inuse_idx], val);
 }
 EXPORT_SYMBOL_GPL(sock_prot_inuse_add);
 
@@ -2279,7 +2278,7 @@ static DEFINE_PER_CPU(struct prot_inuse, prot_inuse);
 
 void sock_prot_inuse_add(struct net *net, struct proto *prot, int val)
 {
-	__get_cpu_var(prot_inuse).val[prot->inuse_idx] += val;
+	__this_cpu_add(prot_inuse.val[prot->inuse_idx], val);
 }
 EXPORT_SYMBOL_GPL(sock_prot_inuse_add);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d20fcd2..2aeb3a4 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -96,7 +96,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * Another cpu is holding lock, requeue & delay xmits for
 		 * some time.
 		 */
-		__get_cpu_var(softnet_data).cpu_collision++;
+		__this_cpu_inc(softnet_data.cpu_collision);
 		ret = dev_requeue_skb(skb, q);
 	}
 


