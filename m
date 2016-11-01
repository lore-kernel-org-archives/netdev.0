From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2 5/5] lwtunnel: Limit number of recursions on output to 5
Date: Tue,  1 Nov 2016 01:37:09 +0100
Message-ID: <f3f701803859d5aacff9134026de0ae656ede3a6.1477959702.git.tgraf@suug.ch>
References: <cover.1477959702.git.tgraf@suug.ch>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45304 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948231AbcKAAha (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 20:37:30 -0400
In-Reply-To: <cover.1477959702.git.tgraf@suug.ch>
In-Reply-To: <cover.1477959702.git.tgraf@suug.ch>
References: <cover.1477959702.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/lwtunnel.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 554d901..6363d0b 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -231,6 +231,10 @@ int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
 }
 EXPORT_SYMBOL(lwtunnel_cmp_encap);
 
+/* Per CPU recursion counter for dst_output() redirections via LWT */
+#define DST_RECURSION_LIMIT 5
+DEFINE_PER_CPU(int, dst_recursion);
+
 int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -246,11 +250,19 @@ int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
 		return 0;
 
+	if (unlikely(__this_cpu_read(dst_recursion) > DST_RECURSION_LIMIT)) {
+		net_crit_ratelimited("lwt: recursion limit reached of redirected dst_output calls\n");
+		return -EFAULT;
+	}
+
 	ret = -EOPNOTSUPP;
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
-	if (likely(ops && ops->output))
+	if (likely(ops && ops->output)) {
+		__this_cpu_inc(dst_recursion);
 		ret = ops->output(net, sk, skb);
+		__this_cpu_dec(dst_recursion);
+	}
 	rcu_read_unlock();
 
 	if (ret == -EOPNOTSUPP)
-- 
2.7.4
