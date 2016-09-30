From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/3] netfilter: hide reference to nf_hooks_ingress
Date: Fri, 30 Sep 2016 18:05:35 +0200
Message-ID: <20160930160559.4102745-2-arnd@arndb.de>
References: <20160930160559.4102745-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Aaron Conole <aconole@bytheb.org>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160930160559.4102745-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent cleanup added an unconditional reference to the nf_hooks_ingress pointer,
but that fails when CONFIG_NETFILTER_INGRESS is disabled and that member is
not present in net_device:

net/netfilter/core.c: In function 'nf_set_hooks_head':
net/netfilter/core.c:96:30: error: 'struct net_device' has no member named 'nf_hooks_ingress'

This avoids the build error by simply enclosing the assignment in an #ifdef,
which may or may not be the correct fix.

Fixes: e3b37f11e6e4 ("netfilter: replace list_head with single linked list")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/netfilter/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 576a9c0406a9..5ccff1d9f209 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -90,10 +90,12 @@ static void nf_set_hooks_head(struct net *net, const struct nf_hook_ops *reg,
 {
 	switch (reg->pf) {
 	case NFPROTO_NETDEV:
+#ifdef CONFIG_NETFILTER_INGRESS
 		/* We already checked in nf_register_net_hook() that this is
 		 * used from ingress.
 		 */
 		rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
+#endif
 		break;
 	default:
 		rcu_assign_pointer(net->nf.hooks[reg->pf][reg->hooknum],
-- 
2.9.0
