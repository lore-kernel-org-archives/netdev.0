From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] net: batch nf_conntrack_net_exit
Date: Mon, 30 Jul 2012 19:16:15 +0400
Message-ID: <1343661375-23442-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vladimir Davydov <vdavydov@parallels.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch introduces nf_conntrack_cleanup_list(), which cleanups
nf_conntracks for a list of netns and calls synchronize_net() only
once for them all.
---
 include/net/netfilter/nf_conntrack_core.h |   10 +++++++++-
 net/netfilter/nf_conntrack_core.c         |   21 +++++++++++++--------
 net/netfilter/nf_conntrack_standalone.c   |   14 +++++++++-----
 3 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index d8f5b9f..f53b855 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -26,7 +26,15 @@ extern unsigned int nf_conntrack_in(struct net *net,
 				    struct sk_buff *skb);
 
 extern int nf_conntrack_init(struct net *net);
-extern void nf_conntrack_cleanup(struct net *net);
+extern void nf_conntrack_cleanup_list(struct list_head *net_exit_list);
+
+static inline void nf_conntrack_cleanup(struct net *net)
+{
+	LIST_HEAD(single);
+
+	list_add(&net->exit_list, &single);
+	nf_conntrack_cleanup_list(&single);
+}
 
 extern int nf_conntrack_proto_init(struct net *net);
 extern void nf_conntrack_proto_fini(struct net *net);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index cf48755..afa62f7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1363,21 +1363,26 @@ static void nf_conntrack_cleanup_net(struct net *net)
 
 /* Mishearing the voices in his head, our hero wonders how he's
    supposed to kill the mall. */
-void nf_conntrack_cleanup(struct net *net)
+void nf_conntrack_cleanup_list(struct list_head *net_exit_list)
 {
-	if (net_eq(net, &init_net))
-		RCU_INIT_POINTER(ip_ct_attach, NULL);
+	struct net *net;
+
+	list_for_each_entry(net, net_exit_list, exit_list)
+		if (net_eq(net, &init_net))
+			RCU_INIT_POINTER(ip_ct_attach, NULL);
 
 	/* This makes sure all current packets have passed through
 	   netfilter framework.  Roll on, two-stage module
 	   delete... */
 	synchronize_net();
-	nf_conntrack_proto_fini(net);
-	nf_conntrack_cleanup_net(net);
 
-	if (net_eq(net, &init_net)) {
-		RCU_INIT_POINTER(nf_ct_destroy, NULL);
-		nf_conntrack_cleanup_init_net();
+	list_for_each_entry(net, net_exit_list, exit_list) {
+		nf_conntrack_proto_fini(net);
+		nf_conntrack_cleanup_net(net);
+		if (net_eq(net, &init_net)) {
+			RCU_INIT_POINTER(nf_ct_destroy, NULL);
+			nf_conntrack_cleanup_init_net();
+		}
 	}
 }
 
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 9b39432..8f60708 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -551,16 +551,20 @@ out_init:
 	return ret;
 }
 
-static void nf_conntrack_net_exit(struct net *net)
+static void nf_conntrack_net_exit(struct list_head *net_exit_list)
 {
-	nf_conntrack_standalone_fini_sysctl(net);
-	nf_conntrack_standalone_fini_proc(net);
-	nf_conntrack_cleanup(net);
+	struct net *net;
+
+	list_for_each_entry(net, net_exit_list, exit_list) {
+		nf_conntrack_standalone_fini_sysctl(net);
+		nf_conntrack_standalone_fini_proc(net);
+	}
+	nf_conntrack_cleanup_list(net_exit_list);
 }
 
 static struct pernet_operations nf_conntrack_net_ops = {
 	.init = nf_conntrack_net_init,
-	.exit = nf_conntrack_net_exit,
+	.exit_batch = nf_conntrack_net_exit,
 };
 
 static int __init nf_conntrack_standalone_init(void)
-- 
1.7.1
