From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 50/53] netfilter: nf_log: don't call synchronize_rcu in nf_log_unset
Date: Mon,  1 May 2017 12:47:17 +0200
Message-ID: <1493635640-24325-51-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

nf_log_unregister() (which is what gets called in the logger backends
module exit paths) does a (required, module is removed) synchronize_rcu().

But nf_log_unset() is only called from pernet exit handlers. It doesn't
free any memory so there appears to be no need to call synchronize_rcu.

v2: Liping Zhang points out that nf_log_unregister() needs to be called
after pernet unregister, else rmmod would become unsafe.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c        | 1 -
 net/netfilter/nfnetlink_log.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index cc32727e3f32..8bb152a7cca4 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -71,7 +71,6 @@ void nf_log_unset(struct net *net, const struct nf_logger *logger)
 			RCU_INIT_POINTER(net->nf.nf_loggers[i], NULL);
 	}
 	mutex_unlock(&nf_log_mutex);
-	synchronize_rcu();
 }
 EXPORT_SYMBOL(nf_log_unset);
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 896741206a50..da9704971a83 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1140,10 +1140,10 @@ static int __init nfnetlink_log_init(void)
 
 static void __exit nfnetlink_log_fini(void)
 {
-	nf_log_unregister(&nfulnl_logger);
 	nfnetlink_subsys_unregister(&nfulnl_subsys);
 	netlink_unregister_notifier(&nfulnl_rtnl_notifier);
 	unregister_pernet_subsys(&nfnl_log_net_ops);
+	nf_log_unregister(&nfulnl_logger);
 }
 
 MODULE_DESCRIPTION("netfilter userspace logging");
-- 
2.1.4

