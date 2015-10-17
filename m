From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/35] netfilter: nfnetlink_log: autoload nf_conntrack_netlink module NFQA_CFG_F_CONNTRACK config flag
Date: Sat, 17 Oct 2015 13:32:51 +0200
Message-ID: <1445081590-2924-17-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48383 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610AbbJQL0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:22 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

This patch enables to load nf_conntrack_netlink module if
NFULNL_CFG_F_CONNTRACK config flag is specified.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index e1d1187..f8d9bd8 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -927,7 +927,16 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		}
 
 		if (flags & NFULNL_CFG_F_CONNTRACK &&
-		    rcu_access_pointer(nfnl_ct_hook) == NULL) {
+		    !rcu_access_pointer(nfnl_ct_hook)) {
+#ifdef CONFIG_MODULES
+			nfnl_unlock(NFNL_SUBSYS_ULOG);
+			request_module("ip_conntrack_netlink");
+			nfnl_lock(NFNL_SUBSYS_ULOG);
+			if (rcu_access_pointer(nfnl_ct_hook)) {
+				ret = -EAGAIN;
+				goto out;
+			}
+#endif
 			ret = -EOPNOTSUPP;
 			goto out;
 		}
-- 
2.1.4
