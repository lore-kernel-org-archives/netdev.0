From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/17] netfilter: nfnetlink_queue: autoload nf_conntrack_netlink module NFQA_CFG_F_CONNTRACK config flag
Date: Fri,  8 Jan 2016 15:02:13 +0100
Message-ID: <1452261737-7475-14-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

This patch enables to load nf_conntrack_netlink module if
NFQA_CFG_F_CONNTRACK config flag is specified.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index c1f6df4..1d39365 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1147,6 +1147,17 @@ static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 		if (flags & mask & NFQA_CFG_F_SECCTX)
 			return -EOPNOTSUPP;
 #endif
+		if ((flags & mask & NFQA_CFG_F_CONNTRACK) &&
+		    !rcu_access_pointer(nfnl_ct_hook)) {
+#ifdef CONFIG_MODULES
+			nfnl_unlock(NFNL_SUBSYS_QUEUE);
+			request_module("ip_conntrack_netlink");
+			nfnl_lock(NFNL_SUBSYS_QUEUE);
+			if (rcu_access_pointer(nfnl_ct_hook))
+				return -EAGAIN;
+#endif
+			return -EOPNOTSUPP;
+		}
 	}
 
 	rcu_read_lock();
-- 
2.1.4

