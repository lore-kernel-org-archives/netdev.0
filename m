From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: ipt_CLUSTERIP: fix use-after-free of proc entry
Date: Thu, 24 Aug 2017 16:43:27 +0200
Message-ID: <1503585811-13447-2-git-send-email-pablo@netfilter.org>
References: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sabrina Dubroca <sd@queasysnail.net>

When we delete a netns with a CLUSTERIP rule, clusterip_net_exit() is
called first, removing /proc/net/ipt_CLUSTERIP.
Then clusterip_config_entry_put() is called from clusterip_tg_destroy(),
and tries to remove its entry under /proc/net/ipt_CLUSTERIP/.

Fix this by checking that the parent directory of the entry to remove
hasn't already been deleted.

The following triggers a KASAN splat (stealing the reproducer from
202f59afd441, thanks to Jianlin Shi and Xin Long):

    ip netns add test
    ip link add veth0_in type veth peer name veth0_out
    ip link set veth0_in netns test
    ip netns exec test ip link set lo up
    ip netns exec test ip link set veth0_in up
    ip netns exec test iptables -I INPUT -d 1.2.3.4 -i veth0_in -j     \
        CLUSTERIP --new --clustermac 89:d4:47:eb:9a:fa --total-nodes 3 \
        --local-node 1 --hashmode sourceip-sourceport
    ip netns del test

Fixes: ce4ff76c15a8 ("netfilter: ipt_CLUSTERIP: make proc directory per net namespace")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 7d72decb80f9..efaa04dcc80e 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -117,7 +117,8 @@ clusterip_config_entry_put(struct net *net, struct clusterip_config *c)
 		 * functions are also incrementing the refcount on their own,
 		 * so it's safe to remove the entry even if it's in use. */
 #ifdef CONFIG_PROC_FS
-		proc_remove(c->pde);
+		if (cn->procdir)
+			proc_remove(c->pde);
 #endif
 		return;
 	}
@@ -815,6 +816,7 @@ static void clusterip_net_exit(struct net *net)
 #ifdef CONFIG_PROC_FS
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 	proc_remove(cn->procdir);
+	cn->procdir = NULL;
 #endif
 	nf_unregister_net_hook(net, &cip_arp_ops);
 }
-- 
2.1.4


