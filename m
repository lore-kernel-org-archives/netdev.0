From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: avoid harmless unnitialized variable warnings
Date: Thu, 19 Nov 2015 13:49:59 +0100
Message-ID: <5585663.OcpAQiytKY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: coreteam@netfilter.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several ARM default configurations give us warnings on recent
compilers about potentially uninitialized variables in the
nfnetlink code in two functions:

net/netfilter/nfnetlink_queue.c: In function 'nfqnl_build_packet_message':
net/netfilter/nfnetlink_queue.c:519:19: warning: 'nfnl_ct' may be used uninitialized in this function [-Wmaybe-uninitialized]
  if (ct && nfnl_ct->build(skb, ct, ctinfo, NFQA_CT, NFQA_CT_INFO) < 0)

Moving the rcu_dereference(nfnl_ct_hook) call outside of the
conditional code avoids the warning without forcing us to
preinitialize the variable.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: a4b4766c3ceb ("netfilter: nfnetlink_queue: rename related to nfqueue attaching conntrack info")

---

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7d81d280cb4f..3e240544f346 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -365,8 +365,9 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		break;
 	}
 
+	nfnl_ct = rcu_dereference(nfnl_ct_hook);
+
 	if (queue->flags & NFQA_CFG_F_CONNTRACK) {
-		nfnl_ct = rcu_dereference(nfnl_ct_hook);
 		if (nfnl_ct != NULL) {
 			ct = nfnl_ct->get_ct(entskb, &ctinfo);
 			if (ct != NULL)
@@ -1064,9 +1065,10 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	if (entry == NULL)
 		return -ENOENT;
 
+	/* rcu lock already held from nfnl->call_rcu. */
+	nfnl_ct = rcu_dereference(nfnl_ct_hook);
+
 	if (nfqa[NFQA_CT]) {
-		/* rcu lock already held from nfnl->call_rcu. */
-		nfnl_ct = rcu_dereference(nfnl_ct_hook);
 		if (nfnl_ct != NULL)
 			ct = nfqnl_ct_parse(nfnl_ct, nlh, nfqa, entry, &ctinfo);
 	}
